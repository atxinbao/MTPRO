import Foundation
import Core

public struct PersistenceBoundary: Equatable, Sendable {
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
public struct PersistenceReplayBoundary: Equatable, Sendable {
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

    public func rebuildMarketDataCache(from command: EventReplayCommand) -> MarketDataCacheSnapshot {
        let replay = replay(command)
        return MarketDataCache.project(replay.envelopes)
    }

    public func rebuildSQLiteRuntimeProjection(
        from command: EventReplayCommand
    ) -> SQLiteRuntimeProjectionSnapshot {
        let replay = replay(command)
        return SQLiteRuntimeProjectionStore.project(replay.envelopes)
    }

    public func rebuildDuckDBAnalyticalProjection(
        from command: EventReplayCommand
    ) -> DuckDBAnalyticalProjectionSnapshot {
        let replay = replay(command)
        return DuckDBAnalyticalProjectionStore.project(replay.envelopes)
    }
}

public enum ProjectionLifecycleState: String, Codable, Equatable, Sendable {
    case requested
    case completed
}

public struct SQLitePaperSessionProjection: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let riskProfileID: Identifier
    public let executionMode: ExecutionMode
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let requestedAt: Date
    public let completedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        sessionID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        riskProfileID: Identifier,
        executionMode: ExecutionMode,
        state: ProjectionLifecycleState,
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

public enum SQLitePortfolioProjectionState: String, Codable, Equatable, Sendable {
    case requested
    case updated
}

public struct SQLitePortfolioProjection: Codable, Equatable, Sendable {
    public let portfolioID: Identifier
    public let state: SQLitePortfolioProjectionState
    public let requestedAt: Date?
    public let updatedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        portfolioID: Identifier,
        state: SQLitePortfolioProjectionState,
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

public struct SQLiteRuntimeProjectionSnapshot: Equatable, Sendable {
    public let paperSessions: [Identifier: SQLitePaperSessionProjection]
    public let rejectedPaperOrderIDs: [Identifier]
    public let portfolioProjections: [Identifier: SQLitePortfolioProjection]
    public let lastAppliedSequence: Int?

    public init(
        paperSessions: [Identifier: SQLitePaperSessionProjection] = [:],
        rejectedPaperOrderIDs: [Identifier] = [],
        portfolioProjections: [Identifier: SQLitePortfolioProjection] = [:],
        lastAppliedSequence: Int? = nil
    ) {
        self.paperSessions = paperSessions
        self.rejectedPaperOrderIDs = rejectedPaperOrderIDs
        self.portfolioProjections = portfolioProjections
        self.lastAppliedSequence = lastAppliedSequence
    }
}

/// SQLite 运行投影边界保存轻量运行状态，不暴露 SQL schema 给 UI。
public struct SQLiteRuntimeProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: SQLiteRuntimeProjectionSnapshot

    public init(snapshot: SQLiteRuntimeProjectionSnapshot = SQLiteRuntimeProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> SQLiteRuntimeProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> SQLiteRuntimeProjectionSnapshot {
        var paperSessions: [Identifier: SQLitePaperSessionProjection] = [:]
        var rejectedPaperOrderIDs: [Identifier] = []
        var portfolioProjections: [Identifier: SQLitePortfolioProjection] = [:]
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

        return SQLiteRuntimeProjectionSnapshot(
            paperSessions: paperSessions,
            rejectedPaperOrderIDs: rejectedPaperOrderIDs,
            portfolioProjections: portfolioProjections,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func apply(
        paperEvent: PaperEvent,
        envelope: EventEnvelope,
        paperSessions: inout [Identifier: SQLitePaperSessionProjection]
    ) {
        switch paperEvent {
        case let .sessionRequested(command):
            let existing = paperSessions[command.sessionID]
            paperSessions[command.sessionID] = SQLitePaperSessionProjection(
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
            paperSessions[result.sessionID] = SQLitePaperSessionProjection(
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
        riskEvent: RiskEvent,
        rejectedPaperOrderIDs: inout [Identifier]
    ) {
        guard case let .rejected(paperOrderID) = riskEvent else {
            return
        }
        if rejectedPaperOrderIDs.contains(paperOrderID) == false {
            rejectedPaperOrderIDs.append(paperOrderID)
        }
    }

    private static func apply(
        portfolioEvent: PortfolioEvent,
        envelope: EventEnvelope,
        portfolioProjections: inout [Identifier: SQLitePortfolioProjection]
    ) {
        switch portfolioEvent {
        case let .projectionRequested(query):
            let existing = portfolioProjections[query.portfolioID]
            portfolioProjections[query.portfolioID] = SQLitePortfolioProjection(
                portfolioID: query.portfolioID,
                state: existing?.state ?? .requested,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                updatedAt: existing?.updatedAt,
                lastUpdatedAt: envelope.recordedAt
            )

        case let .projectionUpdated(portfolioID):
            let existing = portfolioProjections[portfolioID]
            portfolioProjections[portfolioID] = SQLitePortfolioProjection(
                portfolioID: portfolioID,
                state: .updated,
                requestedAt: existing?.requestedAt,
                updatedAt: envelope.recordedAt,
                lastUpdatedAt: envelope.recordedAt
            )
        }
    }
}

public enum DuckDBSignalSource: String, Codable, Equatable, Sendable {
    case backtest
    case orderBookImbalanceResearch
}

public struct DuckDBSignalTimelineProjection: Codable, Equatable, Sendable {
    public let source: DuckDBSignalSource
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let generatedAt: Date
    public let direction: SignalDirection
    public let close: Double?
    public let shortEMA: Double?
    public let longEMA: Double?
    public let bidNotional: Double?
    public let askNotional: Double?
    public let imbalanceRatio: Double?

    public init(
        source: DuckDBSignalSource,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        generatedAt: Date,
        direction: SignalDirection,
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

public struct DuckDBBacktestProjection: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        runID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        state: ProjectionLifecycleState,
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

public struct DuckDBOrderBookResearchProjection: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let depth: Int
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        researchID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        depth: Int,
        state: ProjectionLifecycleState,
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

public struct DuckDBAnalyticalProjectionSnapshot: Equatable, Sendable {
    public let marketBars: [MarketBar]
    public let trades: [TradeTick]
    public let bestBidAsks: [BestBidAsk]
    public let orderBookSnapshots: [OrderBookSnapshot]
    public let orderBookDeltas: [OrderBookDelta]
    public let backtestRuns: [Identifier: DuckDBBacktestProjection]
    public let orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection]
    public let signalTimeline: [DuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        marketBars: [MarketBar] = [],
        trades: [TradeTick] = [],
        bestBidAsks: [BestBidAsk] = [],
        orderBookSnapshots: [OrderBookSnapshot] = [],
        orderBookDeltas: [OrderBookDelta] = [],
        backtestRuns: [Identifier: DuckDBBacktestProjection] = [:],
        orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection] = [:],
        signalTimeline: [DuckDBSignalTimelineProjection] = [],
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
public struct DuckDBAnalyticalProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: DuckDBAnalyticalProjectionSnapshot

    public init(snapshot: DuckDBAnalyticalProjectionSnapshot = DuckDBAnalyticalProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> DuckDBAnalyticalProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> DuckDBAnalyticalProjectionSnapshot {
        var marketBars: [MarketBar] = []
        var trades: [TradeTick] = []
        var bestBidAsks: [BestBidAsk] = []
        var orderBookSnapshots: [OrderBookSnapshot] = []
        var orderBookDeltas: [OrderBookDelta] = []
        var backtestRuns: [Identifier: DuckDBBacktestProjection] = [:]
        var orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection] = [:]
        var signalTimeline: [DuckDBSignalTimelineProjection] = []
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

        return DuckDBAnalyticalProjectionSnapshot(
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
        marketEvent: MarketEvent,
        marketBars: inout [MarketBar],
        trades: inout [TradeTick],
        bestBidAsks: inout [BestBidAsk],
        orderBookSnapshots: inout [OrderBookSnapshot],
        orderBookDeltas: inout [OrderBookDelta]
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
        backtestEvent: BacktestEvent,
        backtestRuns: inout [Identifier: DuckDBBacktestProjection],
        signalTimeline: inout [DuckDBSignalTimelineProjection]
    ) {
        switch backtestEvent {
        case let .requested(command):
            let existing = backtestRuns[command.runID]
            backtestRuns[command.runID] = DuckDBBacktestProjection(
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
            backtestRuns[result.runID] = DuckDBBacktestProjection(
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
        researchEvent: OrderBookImbalanceResearchEvent,
        orderBookResearchRuns: inout [Identifier: DuckDBOrderBookResearchProjection],
        signalTimeline: inout [DuckDBSignalTimelineProjection]
    ) {
        switch researchEvent {
        case let .requested(command):
            let existing = orderBookResearchRuns[command.researchID]
            orderBookResearchRuns[command.researchID] = DuckDBOrderBookResearchProjection(
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
            orderBookResearchRuns[result.researchID] = DuckDBOrderBookResearchProjection(
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
        from sample: EMACrossSignalSample
    ) -> DuckDBSignalTimelineProjection {
        DuckDBSignalTimelineProjection(
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
        from sample: OrderBookImbalanceSignalSample
    ) -> DuckDBSignalTimelineProjection {
        DuckDBSignalTimelineProjection(
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
