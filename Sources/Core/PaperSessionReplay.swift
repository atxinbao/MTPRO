import Foundation

/// PaperSessionReplayEvidenceSummary 是 MTP-35 的 replay 证据摘要。
///
/// 输入只能是 append-only event log 产生的 `EventReplayResult`；输出把 paper lifecycle、
/// proposal、risk blocker 和 portfolio projection event 汇总成稳定可编码证据。该摘要不读取
/// SQLite / DuckDB schema，不连接 broker / exchange，不恢复真实订单授权，也不提供 Live fallback。
public struct PaperSessionReplayEvidenceSummary: Codable, Equatable, Sendable {
    public let factsSource: String
    public let replayedSequences: [Int]
    public let replayedStreams: [EventStreamID]
    public let firstSequence: Int?
    public let lastSequence: Int?
    public let sessionIDs: [Identifier]
    public let lifecycleStates: [PaperSessionLifecycleState]
    public let signalEventCount: Int
    public let proposalIDs: [Identifier]
    public let riskEvaluationRequestedCount: Int
    public let riskBlockerEvidenceIDs: [Identifier]
    public let rejectedPaperOrderIDs: [Identifier]
    public let portfolioUpdateIDs: [Identifier]
    public let portfolioIDs: [Identifier]
    public let coversSessionEvents: Bool
    public let coversProposalEvents: Bool
    public let coversRiskBlockerEvents: Bool
    public let coversPortfolioProjectionEvents: Bool
    public let appendOnlyFactsSourceIsReplaySource: Bool
    public let replayResultIsDeterministic: Bool
    public let paperOnlyBoundaryHeld: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
}

/// PaperSessionReplayPath 从本地 replay result 生成 deterministic evidence summary。
///
/// 该路径只检查已经 replay 出来的 envelope 顺序和领域事件内容。它不会追加事件、不会写数据库、
/// 不暴露投影 schema，也不调用 Binance、signed endpoint、account endpoint、broker 或真实订单能力。
public enum PaperSessionReplayPath {
    public static func summarize(
        _ replay: EventReplayResult
    ) throws -> PaperSessionReplayEvidenceSummary {
        try validateReplayOrder(replay.envelopes)

        var sessionIDs: [Identifier] = []
        var lifecycleStates: [PaperSessionLifecycleState] = []
        var signalEventCount = 0
        var proposals: [PaperActionProposal] = []
        var riskEvaluationRequestedCount = 0
        var riskBlockerEvidence: [RiskBlockerEvidence] = []
        var portfolioUpdates: [PaperPortfolioProjectionUpdate] = []
        var portfolioIDs: [Identifier] = []

        for envelope in replay.envelopes {
            switch envelope.event {
            case let .paper(event):
                apply(
                    paperEvent: event,
                    sessionIDs: &sessionIDs,
                    lifecycleStates: &lifecycleStates,
                    signalEventCount: &signalEventCount,
                    proposals: &proposals
                )

            case let .risk(event):
                apply(
                    riskEvent: event,
                    riskEvaluationRequestedCount: &riskEvaluationRequestedCount,
                    riskBlockerEvidence: &riskBlockerEvidence
                )

            case let .portfolio(event):
                apply(
                    portfolioEvent: event,
                    sessionIDs: &sessionIDs,
                    portfolioUpdates: &portfolioUpdates,
                    portfolioIDs: &portfolioIDs
                )

            default:
                continue
            }
        }

        let replayedSequences = replay.envelopes.map(\.sequence)
        let replayedStreams = uniqueStreams(replay.envelopes.map(\.stream))
        let proposalPaperBoundary = proposals.allSatisfy { proposal in
            proposal.executionMode == .paper
                && proposal.executionAuthorization == .paperIntentOnly
                && proposal.executionAuthorization.allowsBrokerAction == false
                && proposal.executionAuthorization.allowsRealOrder == false
                && proposal.isExecutableAsRealOrder == false
        }
        let portfolioPaperBoundary = portfolioUpdates.allSatisfy { update in
            update.executionMode == .paper
                && update.authorizesTradingExecution == false
                && update.readsRealAccountBalance == false
                && update.syncsBrokerPosition == false
        }

        return PaperSessionReplayEvidenceSummary(
            factsSource: "append-only event log replay",
            replayedSequences: replayedSequences,
            replayedStreams: replayedStreams,
            firstSequence: replayedSequences.first,
            lastSequence: replayedSequences.last,
            sessionIDs: uniqueIdentifiers(sessionIDs),
            lifecycleStates: lifecycleStates,
            signalEventCount: signalEventCount,
            proposalIDs: uniqueIdentifiers(proposals.map(\.proposalID)),
            riskEvaluationRequestedCount: riskEvaluationRequestedCount,
            riskBlockerEvidenceIDs: uniqueIdentifiers(riskBlockerEvidence.map(\.evidenceID)),
            rejectedPaperOrderIDs: uniqueIdentifiers(riskBlockerEvidence.map(\.paperOrderID)),
            portfolioUpdateIDs: uniqueIdentifiers(portfolioUpdates.map(\.updateID)),
            portfolioIDs: uniqueIdentifiers(portfolioIDs),
            coversSessionEvents: lifecycleStates.contains(.started)
                && lifecycleStates.contains(.updated)
                && lifecycleStates.contains(.closed),
            coversProposalEvents: proposals.isEmpty == false,
            coversRiskBlockerEvents: riskBlockerEvidence.isEmpty == false,
            coversPortfolioProjectionEvents: portfolioUpdates.isEmpty == false,
            appendOnlyFactsSourceIsReplaySource: true,
            replayResultIsDeterministic: replayedSequences == Array(Set(replayedSequences)).sorted(),
            paperOnlyBoundaryHeld: proposalPaperBoundary && portfolioPaperBoundary,
            authorizesLiveTrading: false,
            touchesBrokerAction: false
        )
    }

    private static func validateReplayOrder(_ envelopes: [EventEnvelope]) throws {
        let sequences = envelopes.map(\.sequence)
        let sortedUnique = Array(Set(sequences)).sorted()
        guard sequences == sortedUnique else {
            throw CoreError.invalidSequenceRange
        }
    }

    private static func apply(
        paperEvent: PaperEvent,
        sessionIDs: inout [Identifier],
        lifecycleStates: inout [PaperSessionLifecycleState],
        signalEventCount: inout Int,
        proposals: inout [PaperActionProposal]
    ) {
        switch paperEvent {
        case let .sessionStarted(started):
            sessionIDs.append(started.sessionID)
            lifecycleStates.append(started.state)
        case let .sessionUpdated(updated):
            sessionIDs.append(updated.sessionID)
            lifecycleStates.append(updated.state)
        case let .sessionClosed(closed):
            sessionIDs.append(closed.sessionID)
            lifecycleStates.append(closed.state)
        case let .actionProposed(proposal):
            sessionIDs.append(proposal.sessionID)
            proposals.append(proposal)
        case let .sessionRequested(command):
            sessionIDs.append(command.sessionID)
        case .signalGenerated:
            signalEventCount += 1
        case let .sessionCompleted(result):
            sessionIDs.append(result.sessionID)
        }
    }

    private static func apply(
        riskEvent: RiskEvent,
        riskEvaluationRequestedCount: inout Int,
        riskBlockerEvidence: inout [RiskBlockerEvidence]
    ) {
        switch riskEvent {
        case .evaluationRequested:
            riskEvaluationRequestedCount += 1
        case let .blocked(evidence):
            riskBlockerEvidence.append(evidence)
        }
    }

    private static func apply(
        portfolioEvent: PortfolioEvent,
        sessionIDs: inout [Identifier],
        portfolioUpdates: inout [PaperPortfolioProjectionUpdate],
        portfolioIDs: inout [Identifier]
    ) {
        switch portfolioEvent {
        case let .projectionRequested(query):
            portfolioIDs.append(query.portfolioID)
        case let .paperProjectionUpdated(update):
            sessionIDs.append(update.sessionID)
            portfolioUpdates.append(update)
            portfolioIDs.append(update.portfolioID)
        case let .exposureUpdated(exposure):
            portfolioIDs.append(exposure.portfolioID)
        }
    }

    private static func uniqueIdentifiers(_ identifiers: [Identifier]) -> [Identifier] {
        var seen = Set<String>()
        var unique: [Identifier] = []
        for identifier in identifiers.sorted(by: { $0.rawValue < $1.rawValue }) {
            guard seen.insert(identifier.rawValue).inserted else {
                continue
            }
            unique.append(identifier)
        }
        return unique
    }

    private static func uniqueStreams(_ streams: [EventStreamID]) -> [EventStreamID] {
        var seen = Set<String>()
        var unique: [EventStreamID] = []
        for stream in streams.sorted(by: { $0.rawValue < $1.rawValue }) {
            guard seen.insert(stream.rawValue).inserted else {
                continue
            }
            unique.append(stream)
        }
        return unique
    }
}

/// PaperSessionReplayFixture 生成 MTP-35 的完整 deterministic replay evidence。
///
/// Fixture 串联 Paper lifecycle、action proposal、risk blocker 和 portfolio projection event，
/// 只写入本地 append-only event log。它固定所有时间戳和 sequence，用于 XCTest 与 PR evidence；
/// 不代表生产级 event sourcing 平台、真实 broker event replay 或外部 execution venue。
public enum PaperSessionReplayFixture {
    public static func deterministicReplayResult() throws -> EventReplayResult {
        let eventLog = try deterministicEventLog()
        return eventLog.replay(
            EventReplayCommand(
                range: try EventSequenceRange(
                    lowerBound: 1,
                    upperBound: eventLog.envelopes.count
                ),
                streams: [.paper, .risk, .portfolio]
            )
        )
    }

    public static func deterministicSummary() throws -> PaperSessionReplayEvidenceSummary {
        try PaperSessionReplayPath.summarize(deterministicReplayResult())
    }

    public static func deterministicEventLog() throws -> AppendOnlyEventLog {
        var eventLog = try AppendOnlyEventLog()
        let paperBoundary = PaperSessionEventLogBoundary()
        let command = try PaperSessionCommand(
            sessionID: try Identifier("paper-replay-session"),
            strategy: deterministicStrategy(),
            marketData: deterministicMarketDataQuery(),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let run = try PaperSessionEventFlow().start(
            command,
            bars: deterministicBars(),
            startedAt: Date(timeIntervalSince1970: 1_500),
            updatedAt: Date(timeIntervalSince1970: 1_760),
            completedAt: Date(timeIntervalSince1970: 1_900)
        )

        for (index, event) in run.events.enumerated() {
            try paperBoundary.append(
                event,
                to: &eventLog,
                recordedAt: Date(timeIntervalSince1970: 2_000 + TimeInterval(index))
            )
        }

        let proposal = try PaperActionProposal(
            proposalID: try Identifier("paper-replay-proposal"),
            sessionID: command.sessionID,
            signal: run.result.signalSamples[0].signal,
            sizingAssumption: .deterministicFixture,
            proposedAt: Date(timeIntervalSince1970: 2_100)
        )
        let proposalEnvelope = try paperBoundary.append(
            .actionProposed(proposal),
            to: &eventLog,
            recordedAt: Date(timeIntervalSince1970: 2_100)
        )

        let allowedDecision = try PaperActionProposalRiskLink.evaluate(
            decisionID: try Identifier("paper-replay-risk-allowed"),
            proposal: proposal,
            policy: .deterministicAllowingFixture,
            sourceSequence: proposalEnvelope.sequence,
            evaluatedAt: Date(timeIntervalSince1970: 2_200)
        )
        for (index, event) in allowedDecision.riskEvents.enumerated() {
            try eventLog.append(
                .risk(event),
                stream: .risk,
                recordedAt: Date(timeIntervalSince1970: 2_200 + TimeInterval(index))
            )
        }

        let update = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-replay-portfolio-update"),
            portfolioID: try Identifier("portfolio-main"),
            decision: allowedDecision,
            updatedAt: Date(timeIntervalSince1970: 2_300)
        )
        try eventLog.append(
            .portfolio(.paperProjectionUpdated(update)),
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 2_301)
        )

        let blockedProposal = try PaperActionProposal(
            proposalID: try Identifier("paper-replay-proposal-blocked"),
            sessionID: command.sessionID,
            signal: run.result.signalSamples[1].signal,
            sizingAssumption: .deterministicFixture,
            proposedAt: Date(timeIntervalSince1970: 2_350)
        )
        let blockedProposalEnvelope = try paperBoundary.append(
            .actionProposed(blockedProposal),
            to: &eventLog,
            recordedAt: Date(timeIntervalSince1970: 2_350)
        )

        let blockedDecision = try PaperActionProposalRiskLink.evaluate(
            decisionID: try Identifier("paper-replay-risk-blocked"),
            proposal: blockedProposal,
            policy: .deterministicBlockingFixture,
            sourceSequence: blockedProposalEnvelope.sequence,
            evaluatedAt: Date(timeIntervalSince1970: 2_400)
        )
        for (index, event) in blockedDecision.riskEvents.enumerated() {
            try eventLog.append(
                .risk(event),
                stream: .risk,
                recordedAt: Date(timeIntervalSince1970: 2_400 + TimeInterval(index))
            )
        }

        return eventLog
    }

    private static func deterministicStrategy() throws -> EMACrossStrategyConfiguration {
        try EMACrossStrategyConfiguration(
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            shortPeriod: 2,
            longPeriod: 3
        )
    }

    private static func deterministicMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 500)
            )
        )
    }

    private static func deterministicBars() throws -> [MarketBar] {
        try [10.0, 11.0, 12.0, 11.0, 10.0, 13.0].enumerated().map { index, close in
            let start = 100 + TimeInterval(index * 60)
            return try MarketBar(
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                interval: try DateRange(
                    start: Date(timeIntervalSince1970: start),
                    end: Date(timeIntervalSince1970: start + 60)
                ),
                open: close,
                high: close + 1,
                low: close - 1,
                close: close,
                volume: 1
            )
        }
    }
}
