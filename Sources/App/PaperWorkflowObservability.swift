import Foundation
import Core
import Persistence

/// PaperWorkflowReplayFreshnessStatus 描述 replay 证据相对当前事件流水的 freshness。
///
/// 该状态只比较 append-only event timeline 和已汇总 replay evidence 的 sequence，不触发 replay、
/// 不读取数据库 schema，也不调用 Runtime / Adapter。
public enum PaperWorkflowReplayFreshnessStatus: String, Codable, Equatable, Sendable {
    case fresh
    case stale
    case unavailable
}

/// PaperWorkflowObservabilityReadModel 汇总 Paper workflow 可观察性的稳定输入。
///
/// 输入只能来自既有 Report / Paper / Risk / Portfolio / Event read model。该类型可以持有
/// Persistence projection snapshot 派生的数据，但它不暴露 SQLite / DuckDB schema、SQL、ORM
/// model、Runtime object、adapter request，也不提供任何 order-level command 或真实交易入口。
public struct PaperWorkflowObservabilityReadModel: Equatable, Sendable {
    public let reportArtifacts: [ResearchBacktestReportArtifact]
    public let paperSessions: [SQLitePaperSessionProjection]
    public let riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection]
    public let portfolioExposures: [SQLitePortfolioExposureProjection]
    public let eventEnvelopes: [EventEnvelope]
    public let lastAppliedSequence: Int?

    public init(
        reportArtifacts: [ResearchBacktestReportArtifact] = [],
        paperSessions: [SQLitePaperSessionProjection] = [],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        portfolioExposures: [SQLitePortfolioExposureProjection] = [],
        eventEnvelopes: [EventEnvelope] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.reportArtifacts = reportArtifacts.sorted { $0.reportID < $1.reportID }
        self.paperSessions = paperSessions.sorted { $0.sessionID.rawValue < $1.sessionID.rawValue }
        self.riskBlockerEvidence = riskBlockerEvidence.sorted { lhs, rhs in
            lhs.sourceSequence == rhs.sourceSequence
                ? lhs.evidenceID.rawValue < rhs.evidenceID.rawValue
                : lhs.sourceSequence < rhs.sourceSequence
        }
        self.portfolioExposures = portfolioExposures.sorted { lhs, rhs in
            if lhs.sourceSequence != rhs.sourceSequence {
                return lhs.sourceSequence < rhs.sourceSequence
            }
            if lhs.portfolioID != rhs.portfolioID {
                return lhs.portfolioID.rawValue < rhs.portfolioID.rawValue
            }
            return lhs.symbol.rawValue < rhs.symbol.rawValue
        }
        self.eventEnvelopes = eventEnvelopes.sorted { $0.sequence < $1.sequence }
        self.lastAppliedSequence = lastAppliedSequence
    }

    /// 从 Dashboard 已有 read model 聚合 Paper workflow 观察输入。
    ///
    /// 该初始化器只组合已存在的稳定 read model，不新增 projection schema，不读取 adapter request，
    /// 也不把 session control evidence 解释成订单、成交或 broker 行为。
    public init(
        report: ReportReadModel = ReportReadModel(),
        paper: PaperReadModel = PaperReadModel(),
        risk: RiskReadModel = RiskReadModel(),
        portfolio: PortfolioReadModel = PortfolioReadModel(),
        events: EventTimelineReadModel = EventTimelineReadModel()
    ) {
        self.init(
            reportArtifacts: report.artifacts,
            paperSessions: paper.sessions,
            riskBlockerEvidence: risk.riskBlockerEvidence,
            portfolioExposures: portfolio.exposures,
            eventEnvelopes: events.envelopes,
            lastAppliedSequence: Self.maxSequence(
                report.lastAppliedSequence,
                paper.lastAppliedSequence,
                risk.lastAppliedSequence,
                portfolio.lastAppliedSequence,
                events.envelopes.map(\.sequence).max()
            )
        )
    }

    private static func maxSequence(_ values: Int?...) -> Int? {
        values.compactMap { $0 }.max()
    }
}

/// PaperWorkflowObservabilityViewModel 是 Dashboard / Workbench 可消费的 Paper workflow 观察快照。
///
/// 它展示 session status、allowed / blocked evidence、decision -> order -> simulated fill ->
/// portfolio projection chain coverage、replay freshness 和 report artifact status。所有字段都来自
/// `PaperWorkflowObservabilityReadModel`，并保持 read-model-only、paper-only 和 no broker boundary。
public struct PaperWorkflowObservabilityViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let sessionIDs: [String]
    public let sessionStatusLabels: [String]
    public let activeSessionCount: Int
    public let completedSessionCount: Int
    public let proposalIDs: [String]
    public let allowedDecisionIDs: [String]
    public let allowedPaperOrderIDs: [String]
    public let allowedSimulatedFillIDs: [String]
    public let portfolioUpdateIDs: [String]
    public let portfolioIDs: [String]
    public let blockedRiskEvidenceIDs: [String]
    public let blockedPaperOrderIDs: [String]
    public let allowedEvidenceCount: Int
    public let blockedEvidenceCount: Int
    public let coversSessionStatus: Bool
    public let coversProposalEvidence: Bool
    public let coversRiskDecisionEvidence: Bool
    public let coversPaperOrderEvidence: Bool
    public let coversSimulatedFillEvidence: Bool
    public let coversPortfolioProjectionEvidence: Bool
    public let coversAllowedExecutionChain: Bool
    public let coversBlockedEvidence: Bool
    public let coversReportArtifactStatus: Bool
    public let replayAvailable: Bool
    public let replayDeterministic: Bool
    public let appendOnlyFactsSourceIsReplaySource: Bool
    public let replaySequenceCount: Int
    public let lastReplaySequence: Int?
    public let eventTimelineLastSequence: Int?
    public let replayFreshness: PaperWorkflowReplayFreshnessStatus
    public let reportArtifactIDs: [String]
    public let reportArtifactStatuses: [ReportParityStatus]
    public let reportArtifactCount: Int
    public let completedReportArtifactCount: Int
    public let latestReportParityStatus: ReportParityStatus?
    public let reportArtifactsHavePaperOnlyAuthorization: Bool
    public let paperOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesOrderLevelCommand: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: PaperWorkflowObservabilityReadModel) {
        let source = ViewModelSourceContract()
        let runtimeEvidence = readModel.reportArtifacts.map(\.paperRuntimeEvidence)
        let workflowEvidence = readModel.reportArtifacts.map(\.paperExecutionWorkflowEvidence)
        let replaySequences = uniqueSortedInts(
            runtimeEvidence.flatMap(\.replayedSequences)
                + workflowEvidence.flatMap(\.workflowSequences)
        )
        let runtimeReplayEvidence = runtimeEvidence.filter(\.replayAvailable)
        let workflowReplayEvidence = workflowEvidence.filter(\.replayAvailable)
        let replayAvailable = runtimeReplayEvidence.isEmpty == false
            || workflowReplayEvidence.isEmpty == false
        let lastReplaySequence = replaySequences.max()
        let eventTimelineLastSequence = readModel.eventEnvelopes.last?.sequence
        let allowedDecisionIDs = uniqueSortedStrings(workflowEvidence.flatMap(\.decisionIDs))
        let allowedPaperOrderIDs = uniqueSortedStrings(workflowEvidence.flatMap(\.paperOrderIDs))
        let allowedSimulatedFillIDs = uniqueSortedStrings(workflowEvidence.flatMap(\.simulatedFillIDs))
        let portfolioUpdateIDs = uniqueSortedStrings(
            workflowEvidence.flatMap(\.portfolioUpdateIDs)
                + runtimeEvidence.flatMap(\.portfolioUpdateIDs)
        )
        let portfolioIDs = uniqueSortedStrings(
            workflowEvidence.flatMap(\.portfolioIDs)
                + runtimeEvidence.flatMap(\.portfolioIDs)
                + readModel.portfolioExposures.map(\.portfolioID.rawValue)
        )
        let blockedRiskEvidenceIDs = uniqueSortedStrings(
            readModel.riskBlockerEvidence.map(\.evidenceID.rawValue)
                + runtimeEvidence.flatMap(\.riskBlockerEvidenceIDs)
        )
        let blockedPaperOrderIDs = uniqueSortedStrings(
            readModel.riskBlockerEvidence.map(\.paperOrderID.rawValue)
                + runtimeEvidence.flatMap(\.rejectedPaperOrderIDs)
        )
        let proposalIDs = uniqueSortedStrings(runtimeEvidence.flatMap(\.proposalIDs))
        let reportArtifactStatuses = uniqueReportStatuses(
            readModel.reportArtifacts.map(\.parityStatus)
        )
        let authorizesLiveTrading = runtimeEvidence.contains(where: \.authorizesLiveTrading)
            || workflowEvidence.contains(where: \.authorizesLiveTrading)
        let touchesBrokerAction = runtimeEvidence.contains(where: \.touchesBrokerAction)
            || workflowEvidence.contains(where: \.touchesBrokerAction)
        let authorizesTradingExecution = readModel.reportArtifacts.contains(where: \.authorizesTradingExecution)
            || runtimeEvidence.contains(where: \.authorizesTradingExecution)
            || workflowEvidence.contains(where: \.authorizesTradingExecution)
            || readModel.reportArtifacts.map(\.tradingValidationEvidence).contains(where: \.authorizesTradingExecution)
        let paperSessionsRemainPaperOnly = readModel.paperSessions.allSatisfy {
            $0.executionMode == .paper
        }
        let paperOnlyBoundaryHeld = paperSessionsRemainPaperOnly
            && (runtimeEvidence.isEmpty || runtimeEvidence.allSatisfy(\.paperOnlyBoundaryHeld))
            && (workflowEvidence.isEmpty || workflowEvidence.allSatisfy(\.paperOnlyBoundaryHeld))
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
        let exposesDatabaseSchema = source.exposesDatabaseTables || source.exposesORMModels
        let exposesRuntimeObject = source.exposesRuntimeObjects
        let exposesAdapterRequest = source.callsBinanceAdapter
        let providesOrderLevelCommand = false

        self.source = source
        self.sessionIDs = uniqueSortedStrings(
            readModel.paperSessions.map(\.sessionID.rawValue)
                + runtimeEvidence.flatMap(\.sessionIDs)
        )
        self.sessionStatusLabels = uniquePreservingOrder(
            runtimeEvidence.flatMap { $0.lifecycleStates.map(\.rawValue) }
                + readModel.paperSessions.map { $0.state.rawValue }
        )
        self.activeSessionCount = readModel.paperSessions.filter { $0.state.isActive }.count
        self.completedSessionCount = readModel.paperSessions.filter { $0.state.isTerminal }.count
        self.proposalIDs = proposalIDs
        self.allowedDecisionIDs = allowedDecisionIDs
        self.allowedPaperOrderIDs = allowedPaperOrderIDs
        self.allowedSimulatedFillIDs = allowedSimulatedFillIDs
        self.portfolioUpdateIDs = portfolioUpdateIDs
        self.portfolioIDs = portfolioIDs
        self.blockedRiskEvidenceIDs = blockedRiskEvidenceIDs
        self.blockedPaperOrderIDs = blockedPaperOrderIDs
        self.allowedEvidenceCount = allowedDecisionIDs.count
            + allowedPaperOrderIDs.count
            + allowedSimulatedFillIDs.count
        self.blockedEvidenceCount = blockedRiskEvidenceIDs.count
        self.coversSessionStatus = self.sessionIDs.isEmpty == false
            || runtimeEvidence.contains(where: \.coversSessionEvents)
        self.coversProposalEvidence = proposalIDs.isEmpty == false
            || runtimeEvidence.contains(where: \.coversProposalEvents)
        self.coversRiskDecisionEvidence = allowedDecisionIDs.isEmpty == false
            || blockedRiskEvidenceIDs.isEmpty == false
        self.coversPaperOrderEvidence = allowedPaperOrderIDs.isEmpty == false
            || workflowEvidence.contains(where: \.coversPaperOrderEvents)
        self.coversSimulatedFillEvidence = allowedSimulatedFillIDs.isEmpty == false
            || workflowEvidence.contains(where: \.coversSimulatedFillEvents)
        self.coversPortfolioProjectionEvidence = portfolioUpdateIDs.isEmpty == false
            || readModel.portfolioExposures.isEmpty == false
            || workflowEvidence.contains(where: \.projectsPortfolioFromSimulatedFill)
            || runtimeEvidence.contains(where: \.coversPortfolioProjectionEvents)
        self.coversAllowedExecutionChain = workflowEvidence.contains {
            $0.coversDecisionOrderFillChain && $0.projectsPortfolioFromSimulatedFill
        }
        self.coversBlockedEvidence = blockedRiskEvidenceIDs.isEmpty == false
        self.coversReportArtifactStatus = readModel.reportArtifacts.isEmpty == false
        self.replayAvailable = replayAvailable
        self.replayDeterministic = replayAvailable
            && runtimeReplayEvidence.allSatisfy(\.replayResultIsDeterministic)
            && workflowReplayEvidence.allSatisfy(\.replayResultIsDeterministic)
        self.appendOnlyFactsSourceIsReplaySource = replayAvailable
            && runtimeReplayEvidence.allSatisfy(\.appendOnlyFactsSourceIsReplaySource)
            && workflowReplayEvidence.allSatisfy(\.appendOnlyFactsSourceIsReplaySource)
        self.replaySequenceCount = replaySequences.count
        self.lastReplaySequence = lastReplaySequence
        self.eventTimelineLastSequence = eventTimelineLastSequence
        self.replayFreshness = Self.makeReplayFreshness(
            replayAvailable: replayAvailable,
            lastReplaySequence: lastReplaySequence,
            eventTimelineLastSequence: eventTimelineLastSequence
        )
        self.reportArtifactIDs = readModel.reportArtifacts.map(\.reportID)
        self.reportArtifactStatuses = reportArtifactStatuses
        self.reportArtifactCount = readModel.reportArtifacts.count
        self.completedReportArtifactCount = readModel.reportArtifacts.filter {
            $0.backtestState == .completed
        }.count
        self.latestReportParityStatus = readModel.reportArtifacts.last?.parityStatus
        self.reportArtifactsHavePaperOnlyAuthorization = readModel.reportArtifacts.allSatisfy {
            $0.executionAuthorization == .researchOutputOnly
                && $0.authorizesTradingExecution == false
        }
        self.paperOnlyBoundaryHeld = paperOnlyBoundaryHeld
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && providesOrderLevelCommand == false
            && paperOnlyBoundaryHeld
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }

    private static func makeReplayFreshness(
        replayAvailable: Bool,
        lastReplaySequence: Int?,
        eventTimelineLastSequence: Int?
    ) -> PaperWorkflowReplayFreshnessStatus {
        guard replayAvailable, let lastReplaySequence else {
            return .unavailable
        }
        guard let eventTimelineLastSequence else {
            return .fresh
        }
        return lastReplaySequence >= eventTimelineLastSequence ? .fresh : .stale
    }
}

private func uniqueSortedStrings(_ values: [String]) -> [String] {
    Array(Set(values)).sorted()
}

private func uniqueSortedInts(_ values: [Int]) -> [Int] {
    Array(Set(values)).sorted()
}

private func uniquePreservingOrder(_ values: [String]) -> [String] {
    var seen = Set<String>()
    var unique: [String] = []
    for value in values where seen.insert(value).inserted {
        unique.append(value)
    }
    return unique
}

private func uniqueReportStatuses(_ values: [ReportParityStatus]) -> [ReportParityStatus] {
    var seen = Set<String>()
    var unique: [ReportParityStatus] = []
    for value in values where seen.insert(value.rawValue).inserted {
        unique.append(value)
    }
    return unique
}
