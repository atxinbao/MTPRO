import Foundation
import MTPROCore
import MTPROPersistence

public enum MTPRODashboardSection: String, CaseIterable, Codable, Sendable {
    case market = "Market"
    case strategy = "Strategy"
    case backtest = "Backtest"
    case paper = "Paper"
    case risk = "Risk"
    case portfolio = "Portfolio"
    case events = "Events"
}

public struct MTPROAppBaseline: Equatable, Sendable {
    public let sections: [MTPRODashboardSection]

    public init(sections: [MTPRODashboardSection] = MTPRODashboardSection.allCases) {
        self.sections = sections
    }
}

public enum MTPROViewModelSourceKind: String, Codable, Equatable, Sendable {
    case stableReadModelProjection = "stable read model projection"
}

public struct MTPROViewModelSourceContract: Codable, Equatable, Sendable {
    public let sourceKind: MTPROViewModelSourceKind
    public let exposesDatabaseTables: Bool
    public let exposesORMModels: Bool
    public let exposesRuntimeObjects: Bool
    public let callsBinanceAdapter: Bool
    public let providesLiveOrderAction: Bool

    public init(
        sourceKind: MTPROViewModelSourceKind = .stableReadModelProjection,
        exposesDatabaseTables: Bool = false,
        exposesORMModels: Bool = false,
        exposesRuntimeObjects: Bool = false,
        callsBinanceAdapter: Bool = false,
        providesLiveOrderAction: Bool = false
    ) {
        self.sourceKind = sourceKind
        self.exposesDatabaseTables = exposesDatabaseTables
        self.exposesORMModels = exposesORMModels
        self.exposesRuntimeObjects = exposesRuntimeObjects
        self.callsBinanceAdapter = callsBinanceAdapter
        self.providesLiveOrderAction = providesLiveOrderAction
    }

    public var isReadModelOnly: Bool {
        sourceKind == .stableReadModelProjection
            && exposesDatabaseTables == false
            && exposesORMModels == false
            && exposesRuntimeObjects == false
            && callsBinanceAdapter == false
            && providesLiveOrderAction == false
    }
}

public struct MTPROMarketReadModel: Equatable, Sendable {
    public let bars: [MTPROMarketBar]
    public let trades: [MTPROTradeTick]
    public let bestBidAsks: [MTPROBestBidAsk]
    public let orderBookSnapshots: [MTPROOrderBookSnapshot]
    public let orderBookDeltas: [MTPROOrderBookDelta]
    public let lastAppliedSequence: Int?

    public init(
        bars: [MTPROMarketBar] = [],
        trades: [MTPROTradeTick] = [],
        bestBidAsks: [MTPROBestBidAsk] = [],
        orderBookSnapshots: [MTPROOrderBookSnapshot] = [],
        orderBookDeltas: [MTPROOrderBookDelta] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.bars = bars.sortedByBarTime()
        self.trades = trades.sorted { $0.tradedAt < $1.tradedAt }
        self.bestBidAsks = bestBidAsks.sorted { lhs, rhs in
            lhs.observedAt == rhs.observedAt
                ? lhs.symbol.rawValue < rhs.symbol.rawValue
                : lhs.observedAt < rhs.observedAt
        }
        self.orderBookSnapshots = orderBookSnapshots.sorted { lhs, rhs in
            lhs.observedAt == rhs.observedAt
                ? lhs.symbol.rawValue < rhs.symbol.rawValue
                : lhs.observedAt < rhs.observedAt
        }
        self.orderBookDeltas = orderBookDeltas.sorted { lhs, rhs in
            lhs.observedAt == rhs.observedAt
                ? lhs.symbol.rawValue < rhs.symbol.rawValue
                : lhs.observedAt < rhs.observedAt
        }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(analyticalProjection: MTPRODuckDBAnalyticalProjectionSnapshot) {
        self.init(
            bars: analyticalProjection.marketBars,
            trades: analyticalProjection.trades,
            bestBidAsks: analyticalProjection.bestBidAsks,
            orderBookSnapshots: analyticalProjection.orderBookSnapshots,
            orderBookDeltas: analyticalProjection.orderBookDeltas,
            lastAppliedSequence: analyticalProjection.lastAppliedSequence
        )
    }
}

public struct MTPROStrategyReadModel: Equatable, Sendable {
    public let signals: [MTPRODuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        signals: [MTPRODuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.signals = signals.sortedBySignalTime()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(analyticalProjection: MTPRODuckDBAnalyticalProjectionSnapshot) {
        self.init(
            signals: analyticalProjection.signalTimeline,
            lastAppliedSequence: analyticalProjection.lastAppliedSequence
        )
    }
}

public struct MTPROBacktestReadModel: Equatable, Sendable {
    public let runs: [MTPRODuckDBBacktestProjection]
    public let signals: [MTPRODuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        runs: [MTPRODuckDBBacktestProjection] = [],
        signals: [MTPRODuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.runs = runs.sorted { $0.runID.rawValue < $1.runID.rawValue }
        self.signals = signals
            .filter { $0.source == .backtest }
            .sortedBySignalTime()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(analyticalProjection: MTPRODuckDBAnalyticalProjectionSnapshot) {
        self.init(
            runs: Array(analyticalProjection.backtestRuns.values),
            signals: analyticalProjection.signalTimeline,
            lastAppliedSequence: analyticalProjection.lastAppliedSequence
        )
    }
}

public struct MTPROPaperReadModel: Equatable, Sendable {
    public let sessions: [MTPROSQLitePaperSessionProjection]
    public let lastAppliedSequence: Int?

    public init(
        sessions: [MTPROSQLitePaperSessionProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.sessions = sessions.sorted { $0.sessionID.rawValue < $1.sessionID.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: MTPROSQLiteRuntimeProjectionSnapshot) {
        self.init(
            sessions: Array(runtimeProjection.paperSessions.values),
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct MTPRORiskReadModel: Equatable, Sendable {
    public let rejectedPaperOrderIDs: [MTPROIdentifier]
    public let lastAppliedSequence: Int?

    public init(
        rejectedPaperOrderIDs: [MTPROIdentifier] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.rejectedPaperOrderIDs = rejectedPaperOrderIDs.sorted { $0.rawValue < $1.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: MTPROSQLiteRuntimeProjectionSnapshot) {
        self.init(
            rejectedPaperOrderIDs: runtimeProjection.rejectedPaperOrderIDs,
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct MTPROPortfolioReadModel: Equatable, Sendable {
    public let portfolios: [MTPROSQLitePortfolioProjection]
    public let lastAppliedSequence: Int?

    public init(
        portfolios: [MTPROSQLitePortfolioProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.portfolios = portfolios.sorted { $0.portfolioID.rawValue < $1.portfolioID.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: MTPROSQLiteRuntimeProjectionSnapshot) {
        self.init(
            portfolios: Array(runtimeProjection.portfolioProjections.values),
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct MTPROEventTimelineReadModel: Equatable, Sendable {
    public let envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) {
        self.envelopes = envelopes.sorted { $0.sequence < $1.sequence }
    }
}

public struct MTPRODashboardReadModel: Equatable, Sendable {
    public let market: MTPROMarketReadModel
    public let strategy: MTPROStrategyReadModel
    public let backtest: MTPROBacktestReadModel
    public let paper: MTPROPaperReadModel
    public let risk: MTPRORiskReadModel
    public let portfolio: MTPROPortfolioReadModel
    public let events: MTPROEventTimelineReadModel

    public init(
        market: MTPROMarketReadModel,
        strategy: MTPROStrategyReadModel,
        backtest: MTPROBacktestReadModel,
        paper: MTPROPaperReadModel,
        risk: MTPRORiskReadModel,
        portfolio: MTPROPortfolioReadModel,
        events: MTPROEventTimelineReadModel
    ) {
        self.market = market
        self.strategy = strategy
        self.backtest = backtest
        self.paper = paper
        self.risk = risk
        self.portfolio = portfolio
        self.events = events
    }

    public init(
        runtimeProjection: MTPROSQLiteRuntimeProjectionSnapshot,
        analyticalProjection: MTPRODuckDBAnalyticalProjectionSnapshot,
        eventTimeline: [EventEnvelope]
    ) {
        self.init(
            market: MTPROMarketReadModel(analyticalProjection: analyticalProjection),
            strategy: MTPROStrategyReadModel(analyticalProjection: analyticalProjection),
            backtest: MTPROBacktestReadModel(analyticalProjection: analyticalProjection),
            paper: MTPROPaperReadModel(runtimeProjection: runtimeProjection),
            risk: MTPRORiskReadModel(runtimeProjection: runtimeProjection),
            portfolio: MTPROPortfolioReadModel(runtimeProjection: runtimeProjection),
            events: MTPROEventTimelineReadModel(envelopes: eventTimeline)
        )
    }
}

public struct MTPROMarketViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let symbols: [String]
    public let barCount: Int
    public let tradeCount: Int
    public let bestBidAskCount: Int
    public let orderBookSnapshotCount: Int
    public let orderBookDeltaCount: Int
    public let latestBarClose: Double?
    public let lastAppliedSequence: Int?

    public init(readModel: MTPROMarketReadModel) {
        self.section = .market
        self.source = MTPROViewModelSourceContract()
        self.symbols = readModel.marketSymbols()
        self.barCount = readModel.bars.count
        self.tradeCount = readModel.trades.count
        self.bestBidAskCount = readModel.bestBidAsks.count
        self.orderBookSnapshotCount = readModel.orderBookSnapshots.count
        self.orderBookDeltaCount = readModel.orderBookDeltas.count
        self.latestBarClose = readModel.bars.last?.close.rawValue
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPROStrategyViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let strategyIDs: [String]
    public let signalCount: Int
    public let latestSignalDirection: MTPROSignalDirection?
    public let lastAppliedSequence: Int?

    public init(readModel: MTPROStrategyReadModel) {
        self.section = .strategy
        self.source = MTPROViewModelSourceContract()
        self.strategyIDs = readModel.signals.map(\.strategyID.rawValue).uniqueSorted()
        self.signalCount = readModel.signals.count
        self.latestSignalDirection = readModel.signals.last?.direction
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPROBacktestRunViewModel: Codable, Equatable, Sendable {
    public let runID: String
    public let strategyID: String
    public let symbol: String
    public let timeframe: String
    public let state: MTPROProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(projection: MTPRODuckDBBacktestProjection) {
        self.runID = projection.runID.rawValue
        self.strategyID = projection.strategyID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.state = projection.state
        self.signalCount = projection.signalCount
        self.completedAt = projection.completedAt
    }
}

public struct MTPROBacktestViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let runs: [MTPROBacktestRunViewModel]
    public let totalSignalCount: Int
    public let completedRunCount: Int
    public let latestSignalDirection: MTPROSignalDirection?
    public let lastAppliedSequence: Int?

    public init(readModel: MTPROBacktestReadModel) {
        self.section = .backtest
        self.source = MTPROViewModelSourceContract()
        self.runs = readModel.runs.map(MTPROBacktestRunViewModel.init)
        self.totalSignalCount = readModel.runs.reduce(0) { $0 + $1.signalCount }
        self.completedRunCount = readModel.runs.filter { $0.state == .completed }.count
        self.latestSignalDirection = readModel.signals.last?.direction
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPROPaperSessionViewModel: Codable, Equatable, Sendable {
    public let sessionID: String
    public let strategyID: String
    public let symbol: String
    public let timeframe: String
    public let riskProfileID: String
    public let executionMode: MTPROExecutionMode
    public let state: MTPROProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(projection: MTPROSQLitePaperSessionProjection) {
        self.sessionID = projection.sessionID.rawValue
        self.strategyID = projection.strategyID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.riskProfileID = projection.riskProfileID.rawValue
        self.executionMode = projection.executionMode
        self.state = projection.state
        self.signalCount = projection.signalCount
        self.completedAt = projection.completedAt
    }
}

public struct MTPROPaperViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let sessions: [MTPROPaperSessionViewModel]
    public let activeSessionCount: Int
    public let completedSessionCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: MTPROPaperReadModel) {
        self.section = .paper
        self.source = MTPROViewModelSourceContract()
        self.sessions = readModel.sessions.map(MTPROPaperSessionViewModel.init)
        self.activeSessionCount = readModel.sessions.filter { $0.state == .requested }.count
        self.completedSessionCount = readModel.sessions.filter { $0.state == .completed }.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPRORiskViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let rejectedPaperOrderIDs: [String]
    public let rejectionCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: MTPRORiskReadModel) {
        self.section = .risk
        self.source = MTPROViewModelSourceContract()
        self.rejectedPaperOrderIDs = readModel.rejectedPaperOrderIDs.map(\.rawValue)
        self.rejectionCount = readModel.rejectedPaperOrderIDs.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPROPortfolioViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let portfolioIDs: [String]
    public let updatedPortfolioCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: MTPROPortfolioReadModel) {
        self.section = .portfolio
        self.source = MTPROViewModelSourceContract()
        self.portfolioIDs = readModel.portfolios.map(\.portfolioID.rawValue)
        self.updatedPortfolioCount = readModel.portfolios.filter { $0.state == .updated }.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct MTPROEventLogViewModel: Codable, Equatable, Sendable {
    public let section: MTPRODashboardSection
    public let source: MTPROViewModelSourceContract
    public let eventCount: Int
    public let streams: [String]
    public let lastSequence: Int?

    public init(readModel: MTPROEventTimelineReadModel) {
        self.section = .events
        self.source = MTPROViewModelSourceContract()
        self.eventCount = readModel.envelopes.count
        self.streams = readModel.envelopes.map(\.stream.rawValue).uniqueSorted()
        self.lastSequence = readModel.envelopes.last?.sequence
    }
}

public struct MTPRODashboardViewModel: Codable, Equatable, Sendable {
    public let sections: [MTPRODashboardSection]
    public let market: MTPROMarketViewModel
    public let strategy: MTPROStrategyViewModel
    public let backtest: MTPROBacktestViewModel
    public let paper: MTPROPaperViewModel
    public let risk: MTPRORiskViewModel
    public let portfolio: MTPROPortfolioViewModel
    public let events: MTPROEventLogViewModel

    public init(
        readModel: MTPRODashboardReadModel,
        sections: [MTPRODashboardSection] = MTPRODashboardSection.allCases
    ) {
        self.sections = sections
        self.market = MTPROMarketViewModel(readModel: readModel.market)
        self.strategy = MTPROStrategyViewModel(readModel: readModel.strategy)
        self.backtest = MTPROBacktestViewModel(readModel: readModel.backtest)
        self.paper = MTPROPaperViewModel(readModel: readModel.paper)
        self.risk = MTPRORiskViewModel(readModel: readModel.risk)
        self.portfolio = MTPROPortfolioViewModel(readModel: readModel.portfolio)
        self.events = MTPROEventLogViewModel(readModel: readModel.events)
    }

    public var viewModelSources: [MTPROViewModelSourceContract] {
        [
            market.source,
            strategy.source,
            backtest.source,
            paper.source,
            risk.source,
            portfolio.source,
            events.source
        ]
    }
}

private extension Array where Element == MTPROMarketBar {
    func sortedByBarTime() -> [MTPROMarketBar] {
        sorted { lhs, rhs in
            lhs.interval.end == rhs.interval.end
                ? lhs.symbol.rawValue < rhs.symbol.rawValue
                : lhs.interval.end < rhs.interval.end
        }
    }
}

private extension Array where Element == MTPRODuckDBSignalTimelineProjection {
    func sortedBySignalTime() -> [MTPRODuckDBSignalTimelineProjection] {
        sorted { lhs, rhs in
            if lhs.generatedAt != rhs.generatedAt {
                return lhs.generatedAt < rhs.generatedAt
            }
            if lhs.strategyID != rhs.strategyID {
                return lhs.strategyID.rawValue < rhs.strategyID.rawValue
            }
            return lhs.symbol.rawValue < rhs.symbol.rawValue
        }
    }
}

private extension MTPROMarketReadModel {
    func marketSymbols() -> [String] {
        (
            bars.map(\.symbol.rawValue)
                + trades.map(\.symbol.rawValue)
                + bestBidAsks.map(\.symbol.rawValue)
                + orderBookSnapshots.map(\.symbol.rawValue)
                + orderBookDeltas.map(\.symbol.rawValue)
        ).uniqueSorted()
    }
}

private extension Array where Element == String {
    func uniqueSorted() -> [String] {
        Array(Set(self)).sorted()
    }
}
