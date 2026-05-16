import Foundation
import MTPROCore

public struct MTPROPersistenceBoundary: Equatable, Sendable {
    public let factSource: String
    public let sqliteResponsibility: String
    public let duckDBResponsibility: String
    public let uiExposure: String
    public let exposesDatabaseTablesToUI: Bool
    public let persistsRuntimeObjectsAsUIContract: Bool

    public init(
        factSource: String = "append-only event log",
        sqliteResponsibility: String = "runtime state and lightweight projections",
        duckDBResponsibility: String = "market data and backtest analytical projections",
        uiExposure: String = "stable read model projections only",
        exposesDatabaseTablesToUI: Bool = false,
        persistsRuntimeObjectsAsUIContract: Bool = false
    ) {
        self.factSource = factSource
        self.sqliteResponsibility = sqliteResponsibility
        self.duckDBResponsibility = duckDBResponsibility
        self.uiExposure = uiExposure
        self.exposesDatabaseTablesToUI = exposesDatabaseTablesToUI
        self.persistsRuntimeObjectsAsUIContract = persistsRuntimeObjectsAsUIContract
    }
}

/// 持久化重放边界复用 Core 只追加事件日志，输出稳定投影而不是数据库表。
public struct MTPROPersistenceReplayBoundary: Equatable, Sendable {
    private let eventLog: AppendOnlyEventLog

    public init(envelopes: [EventEnvelope]) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: envelopes)
    }

    public var envelopes: [EventEnvelope] {
        eventLog.envelopes
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        eventLog.replay(command)
    }

    public func rebuildMarketDataCache(from command: EventReplayCommand) -> MTPROMarketDataCacheSnapshot {
        let replay = replay(command)
        return MTPROMarketDataCache.project(replay.envelopes)
    }

    public func rebuildSQLiteRuntimeProjection(
        from command: EventReplayCommand
    ) -> MTPROSQLiteRuntimeProjectionSnapshot {
        let replay = replay(command)
        return MTPROSQLiteRuntimeProjectionStore.project(replay.envelopes)
    }

    public func rebuildDuckDBAnalyticalProjection(
        from command: EventReplayCommand
    ) -> MTPRODuckDBAnalyticalProjectionSnapshot {
        let replay = replay(command)
        return MTPRODuckDBAnalyticalProjectionStore.project(replay.envelopes)
    }
}

public enum MTPROProjectionLifecycleState: String, Codable, Equatable, Sendable {
    case requested
    case completed
}

public struct MTPROSQLitePaperSessionProjection: Codable, Equatable, Sendable {
    public let sessionID: MTPROIdentifier
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let riskProfileID: MTPROIdentifier
    public let executionMode: MTPROExecutionMode
    public let state: MTPROProjectionLifecycleState
    public let signalCount: Int
    public let requestedAt: Date
    public let completedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        sessionID: MTPROIdentifier,
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        riskProfileID: MTPROIdentifier,
        executionMode: MTPROExecutionMode,
        state: MTPROProjectionLifecycleState,
        signalCount: Int,
        requestedAt: Date,
        completedAt: Date?,
        lastUpdatedAt: Date
    ) {
        self.sessionID = sessionID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
        self.state = state
        self.signalCount = signalCount
        self.requestedAt = requestedAt
        self.completedAt = completedAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}

public enum MTPROSQLitePortfolioProjectionState: String, Codable, Equatable, Sendable {
    case requested
    case updated
}

public struct MTPROSQLitePortfolioProjection: Codable, Equatable, Sendable {
    public let portfolioID: MTPROIdentifier
    public let state: MTPROSQLitePortfolioProjectionState
    public let requestedAt: Date?
    public let updatedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        portfolioID: MTPROIdentifier,
        state: MTPROSQLitePortfolioProjectionState,
        requestedAt: Date?,
        updatedAt: Date?,
        lastUpdatedAt: Date
    ) {
        self.portfolioID = portfolioID
        self.state = state
        self.requestedAt = requestedAt
        self.updatedAt = updatedAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}

public struct MTPROSQLiteRuntimeProjectionSnapshot: Equatable, Sendable {
    public let paperSessions: [MTPROIdentifier: MTPROSQLitePaperSessionProjection]
    public let rejectedPaperOrderIDs: [MTPROIdentifier]
    public let portfolioProjections: [MTPROIdentifier: MTPROSQLitePortfolioProjection]
    public let lastAppliedSequence: Int?

    public init(
        paperSessions: [MTPROIdentifier: MTPROSQLitePaperSessionProjection] = [:],
        rejectedPaperOrderIDs: [MTPROIdentifier] = [],
        portfolioProjections: [MTPROIdentifier: MTPROSQLitePortfolioProjection] = [:],
        lastAppliedSequence: Int? = nil
    ) {
        self.paperSessions = paperSessions
        self.rejectedPaperOrderIDs = rejectedPaperOrderIDs
        self.portfolioProjections = portfolioProjections
        self.lastAppliedSequence = lastAppliedSequence
    }
}

/// SQLite 运行投影边界保存轻量运行状态，不暴露 SQL schema 给 UI。
public struct MTPROSQLiteRuntimeProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: MTPROSQLiteRuntimeProjectionSnapshot

    public init(snapshot: MTPROSQLiteRuntimeProjectionSnapshot = MTPROSQLiteRuntimeProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> MTPROSQLiteRuntimeProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> MTPROSQLiteRuntimeProjectionSnapshot {
        var paperSessions: [MTPROIdentifier: MTPROSQLitePaperSessionProjection] = [:]
        var rejectedPaperOrderIDs: [MTPROIdentifier] = []
        var portfolioProjections: [MTPROIdentifier: MTPROSQLitePortfolioProjection] = [:]
        var lastAppliedSequence: Int?

        for envelope in envelopes.sorted(by: { $0.sequence < $1.sequence }) {
            switch envelope.event {
            case let .paper(event):
                apply(
                    paperEvent: event,
                    envelope: envelope,
                    paperSessions: &paperSessions
                )
                lastAppliedSequence = envelope.sequence
            case let .risk(event):
                apply(
                    riskEvent: event,
                    rejectedPaperOrderIDs: &rejectedPaperOrderIDs
                )
                lastAppliedSequence = envelope.sequence
            case let .portfolio(event):
                apply(
                    portfolioEvent: event,
                    envelope: envelope,
                    portfolioProjections: &portfolioProjections
                )
                lastAppliedSequence = envelope.sequence
            default:
                continue
            }
        }

        return MTPROSQLiteRuntimeProjectionSnapshot(
            paperSessions: paperSessions,
            rejectedPaperOrderIDs: rejectedPaperOrderIDs,
            portfolioProjections: portfolioProjections,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func apply(
        paperEvent: MTPROPaperEvent,
        envelope: EventEnvelope,
        paperSessions: inout [MTPROIdentifier: MTPROSQLitePaperSessionProjection]
    ) {
        switch paperEvent {
        case let .sessionRequested(command):
            let existing = paperSessions[command.sessionID]
            paperSessions[command.sessionID] = MTPROSQLitePaperSessionProjection(
                sessionID: command.sessionID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                riskProfileID: command.riskProfileID,
                executionMode: command.executionMode,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                completedAt: existing?.completedAt,
                lastUpdatedAt: envelope.recordedAt
            )

        case .signalGenerated:
            break

        case let .sessionCompleted(result):
            let existing = paperSessions[result.sessionID]
            paperSessions[result.sessionID] = MTPROSQLitePaperSessionProjection(
                sessionID: result.sessionID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                riskProfileID: result.command.riskProfileID,
                executionMode: result.command.executionMode,
                state: .completed,
                signalCount: result.signalSamples.count,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                completedAt: result.completedAt,
                lastUpdatedAt: envelope.recordedAt
            )
        }
    }

    private static func apply(
        riskEvent: MTPRORiskEvent,
        rejectedPaperOrderIDs: inout [MTPROIdentifier]
    ) {
        guard case let .rejected(paperOrderID) = riskEvent else {
            return
        }
        if rejectedPaperOrderIDs.contains(paperOrderID) == false {
            rejectedPaperOrderIDs.append(paperOrderID)
        }
    }

    private static func apply(
        portfolioEvent: MTPROPortfolioEvent,
        envelope: EventEnvelope,
        portfolioProjections: inout [MTPROIdentifier: MTPROSQLitePortfolioProjection]
    ) {
        switch portfolioEvent {
        case let .projectionRequested(query):
            let existing = portfolioProjections[query.portfolioID]
            portfolioProjections[query.portfolioID] = MTPROSQLitePortfolioProjection(
                portfolioID: query.portfolioID,
                state: existing?.state ?? .requested,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                updatedAt: existing?.updatedAt,
                lastUpdatedAt: envelope.recordedAt
            )

        case let .projectionUpdated(portfolioID):
            let existing = portfolioProjections[portfolioID]
            portfolioProjections[portfolioID] = MTPROSQLitePortfolioProjection(
                portfolioID: portfolioID,
                state: .updated,
                requestedAt: existing?.requestedAt,
                updatedAt: envelope.recordedAt,
                lastUpdatedAt: envelope.recordedAt
            )
        }
    }
}

public enum MTPRODuckDBSignalSource: String, Codable, Equatable, Sendable {
    case backtest
    case orderBookImbalanceResearch
}

public struct MTPRODuckDBSignalTimelineProjection: Codable, Equatable, Sendable {
    public let source: MTPRODuckDBSignalSource
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let generatedAt: Date
    public let direction: MTPROSignalDirection
    public let close: Double?
    public let shortEMA: Double?
    public let longEMA: Double?
    public let bidNotional: Double?
    public let askNotional: Double?
    public let imbalanceRatio: Double?

    public init(
        source: MTPRODuckDBSignalSource,
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        generatedAt: Date,
        direction: MTPROSignalDirection,
        close: Double? = nil,
        shortEMA: Double? = nil,
        longEMA: Double? = nil,
        bidNotional: Double? = nil,
        askNotional: Double? = nil,
        imbalanceRatio: Double? = nil
    ) {
        self.source = source
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.generatedAt = generatedAt
        self.direction = direction
        self.close = close
        self.shortEMA = shortEMA
        self.longEMA = longEMA
        self.bidNotional = bidNotional
        self.askNotional = askNotional
        self.imbalanceRatio = imbalanceRatio
    }
}

public struct MTPRODuckDBBacktestProjection: Codable, Equatable, Sendable {
    public let runID: MTPROIdentifier
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let state: MTPROProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        runID: MTPROIdentifier,
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        state: MTPROProjectionLifecycleState,
        signalCount: Int,
        completedAt: Date?
    ) {
        self.runID = runID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.state = state
        self.signalCount = signalCount
        self.completedAt = completedAt
    }
}

public struct MTPRODuckDBOrderBookResearchProjection: Codable, Equatable, Sendable {
    public let researchID: MTPROIdentifier
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let depth: Int
    public let state: MTPROProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        researchID: MTPROIdentifier,
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        depth: Int,
        state: MTPROProjectionLifecycleState,
        signalCount: Int,
        completedAt: Date?
    ) {
        self.researchID = researchID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.depth = depth
        self.state = state
        self.signalCount = signalCount
        self.completedAt = completedAt
    }
}

public struct MTPRODuckDBAnalyticalProjectionSnapshot: Equatable, Sendable {
    public let marketBars: [MTPROMarketBar]
    public let trades: [MTPROTradeTick]
    public let bestBidAsks: [MTPROBestBidAsk]
    public let orderBookSnapshots: [MTPROOrderBookSnapshot]
    public let orderBookDeltas: [MTPROOrderBookDelta]
    public let backtestRuns: [MTPROIdentifier: MTPRODuckDBBacktestProjection]
    public let orderBookResearchRuns: [MTPROIdentifier: MTPRODuckDBOrderBookResearchProjection]
    public let signalTimeline: [MTPRODuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        marketBars: [MTPROMarketBar] = [],
        trades: [MTPROTradeTick] = [],
        bestBidAsks: [MTPROBestBidAsk] = [],
        orderBookSnapshots: [MTPROOrderBookSnapshot] = [],
        orderBookDeltas: [MTPROOrderBookDelta] = [],
        backtestRuns: [MTPROIdentifier: MTPRODuckDBBacktestProjection] = [:],
        orderBookResearchRuns: [MTPROIdentifier: MTPRODuckDBOrderBookResearchProjection] = [:],
        signalTimeline: [MTPRODuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.marketBars = marketBars
        self.trades = trades
        self.bestBidAsks = bestBidAsks
        self.orderBookSnapshots = orderBookSnapshots
        self.orderBookDeltas = orderBookDeltas
        self.backtestRuns = backtestRuns
        self.orderBookResearchRuns = orderBookResearchRuns
        self.signalTimeline = signalTimeline
        self.lastAppliedSequence = lastAppliedSequence
    }
}

/// DuckDB 分析投影边界面向 market data、backtest 和研究分析，不保存运行时对象。
public struct MTPRODuckDBAnalyticalProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: MTPRODuckDBAnalyticalProjectionSnapshot

    public init(snapshot: MTPRODuckDBAnalyticalProjectionSnapshot = MTPRODuckDBAnalyticalProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> MTPRODuckDBAnalyticalProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> MTPRODuckDBAnalyticalProjectionSnapshot {
        var marketBars: [MTPROMarketBar] = []
        var trades: [MTPROTradeTick] = []
        var bestBidAsks: [MTPROBestBidAsk] = []
        var orderBookSnapshots: [MTPROOrderBookSnapshot] = []
        var orderBookDeltas: [MTPROOrderBookDelta] = []
        var backtestRuns: [MTPROIdentifier: MTPRODuckDBBacktestProjection] = [:]
        var orderBookResearchRuns: [MTPROIdentifier: MTPRODuckDBOrderBookResearchProjection] = [:]
        var signalTimeline: [MTPRODuckDBSignalTimelineProjection] = []
        var lastAppliedSequence: Int?

        for envelope in envelopes.sorted(by: { $0.sequence < $1.sequence }) {
            switch envelope.event {
            case let .market(event):
                apply(
                    marketEvent: event,
                    marketBars: &marketBars,
                    trades: &trades,
                    bestBidAsks: &bestBidAsks,
                    orderBookSnapshots: &orderBookSnapshots,
                    orderBookDeltas: &orderBookDeltas
                )
                lastAppliedSequence = envelope.sequence
            case let .backtest(event):
                apply(
                    backtestEvent: event,
                    backtestRuns: &backtestRuns,
                    signalTimeline: &signalTimeline
                )
                lastAppliedSequence = envelope.sequence
            case let .orderBookImbalanceResearch(event):
                apply(
                    researchEvent: event,
                    orderBookResearchRuns: &orderBookResearchRuns,
                    signalTimeline: &signalTimeline
                )
                lastAppliedSequence = envelope.sequence
            default:
                continue
            }
        }

        return MTPRODuckDBAnalyticalProjectionSnapshot(
            marketBars: marketBars,
            trades: trades,
            bestBidAsks: bestBidAsks,
            orderBookSnapshots: orderBookSnapshots,
            orderBookDeltas: orderBookDeltas,
            backtestRuns: backtestRuns,
            orderBookResearchRuns: orderBookResearchRuns,
            signalTimeline: signalTimeline,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func apply(
        marketEvent: MTPROMarketEvent,
        marketBars: inout [MTPROMarketBar],
        trades: inout [MTPROTradeTick],
        bestBidAsks: inout [MTPROBestBidAsk],
        orderBookSnapshots: inout [MTPROOrderBookSnapshot],
        orderBookDeltas: inout [MTPROOrderBookDelta]
    ) {
        switch marketEvent {
        case let .bar(bar):
            marketBars.append(bar)
        case let .trade(trade):
            trades.append(trade)
        case let .bestBidAsk(bestBidAsk):
            bestBidAsks.append(bestBidAsk)
        case let .orderBookSnapshot(snapshot):
            orderBookSnapshots.append(snapshot)
        case let .orderBookDelta(delta):
            orderBookDeltas.append(delta)
        }
    }

    private static func apply(
        backtestEvent: MTPROBacktestEvent,
        backtestRuns: inout [MTPROIdentifier: MTPRODuckDBBacktestProjection],
        signalTimeline: inout [MTPRODuckDBSignalTimelineProjection]
    ) {
        switch backtestEvent {
        case let .requested(command):
            let existing = backtestRuns[command.runID]
            backtestRuns[command.runID] = MTPRODuckDBBacktestProjection(
                runID: command.runID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                completedAt: existing?.completedAt
            )

        case let .signalGenerated(sample):
            signalTimeline.append(signalProjection(from: sample))

        case let .completed(result):
            backtestRuns[result.runID] = MTPRODuckDBBacktestProjection(
                runID: result.runID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                state: .completed,
                signalCount: result.signalSamples.count,
                completedAt: result.completedAt
            )
        }
    }

    private static func apply(
        researchEvent: MTPROOrderBookImbalanceResearchEvent,
        orderBookResearchRuns: inout [MTPROIdentifier: MTPRODuckDBOrderBookResearchProjection],
        signalTimeline: inout [MTPRODuckDBSignalTimelineProjection]
    ) {
        switch researchEvent {
        case let .requested(command):
            let existing = orderBookResearchRuns[command.researchID]
            orderBookResearchRuns[command.researchID] = MTPRODuckDBOrderBookResearchProjection(
                researchID: command.researchID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                depth: command.strategy.depth,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                completedAt: existing?.completedAt
            )

        case let .signalGenerated(sample):
            signalTimeline.append(signalProjection(from: sample))

        case let .completed(result):
            orderBookResearchRuns[result.researchID] = MTPRODuckDBOrderBookResearchProjection(
                researchID: result.researchID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                depth: result.command.strategy.depth,
                state: .completed,
                signalCount: result.signalSamples.count,
                completedAt: result.completedAt
            )
        }
    }

    private static func signalProjection(
        from sample: MTPROEMACrossSignalSample
    ) -> MTPRODuckDBSignalTimelineProjection {
        MTPRODuckDBSignalTimelineProjection(
            source: .backtest,
            strategyID: sample.signal.strategyID,
            symbol: sample.signal.symbol,
            timeframe: sample.signal.timeframe,
            generatedAt: sample.signal.generatedAt,
            direction: sample.signal.direction,
            close: sample.close.rawValue,
            shortEMA: sample.shortEMA.rawValue,
            longEMA: sample.longEMA.rawValue
        )
    }

    private static func signalProjection(
        from sample: MTPROOrderBookImbalanceSignalSample
    ) -> MTPRODuckDBSignalTimelineProjection {
        MTPRODuckDBSignalTimelineProjection(
            source: .orderBookImbalanceResearch,
            strategyID: sample.signal.strategyID,
            symbol: sample.signal.symbol,
            timeframe: sample.signal.timeframe,
            generatedAt: sample.signal.generatedAt,
            direction: sample.signal.direction,
            bidNotional: sample.bidNotional,
            askNotional: sample.askNotional,
            imbalanceRatio: sample.imbalanceRatio
        )
    }
}
