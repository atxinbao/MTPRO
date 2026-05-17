import Foundation
import Core
import Persistence

public enum DashboardSection: String, CaseIterable, Codable, Hashable, Sendable {
    case market = "Market"
    case strategy = "Strategy"
    case backtest = "Backtest"
    case paper = "Paper"
    case risk = "Risk"
    case portfolio = "Portfolio"
    case events = "Events"
}

public struct AppBaseline: Equatable, Sendable {
    public let sections: [DashboardSection]

    public init(sections: [DashboardSection] = DashboardSection.allCases) {
        self.sections = sections
    }
}

public enum ViewModelSourceKind: String, Codable, Equatable, Sendable {
    case stableReadModelProjection = "stable read model projection"
}

public struct ViewModelSourceContract: Codable, Equatable, Sendable {
    public let sourceKind: ViewModelSourceKind
    public let exposesDatabaseTables: Bool
    public let exposesORMModels: Bool
    public let exposesRuntimeObjects: Bool
    public let callsBinanceAdapter: Bool
    public let providesLiveOrderAction: Bool

    public init(
        sourceKind: ViewModelSourceKind = .stableReadModelProjection,
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

public struct MarketReadModel: Equatable, Sendable {
    public let bars: [MarketBar]
    public let trades: [TradeTick]
    public let bestBidAsks: [BestBidAsk]
    public let orderBookSnapshots: [OrderBookSnapshot]
    public let orderBookDeltas: [OrderBookDelta]
    public let lastAppliedSequence: Int?

    public init(
        bars: [MarketBar] = [],
        trades: [TradeTick] = [],
        bestBidAsks: [BestBidAsk] = [],
        orderBookSnapshots: [OrderBookSnapshot] = [],
        orderBookDeltas: [OrderBookDelta] = [],
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

    public init(analyticalProjection: DuckDBAnalyticalProjectionSnapshot) {
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

public struct StrategyReadModel: Equatable, Sendable {
    public let signals: [DuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        signals: [DuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.signals = signals.sortedBySignalTime()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(analyticalProjection: DuckDBAnalyticalProjectionSnapshot) {
        self.init(
            signals: analyticalProjection.signalTimeline,
            lastAppliedSequence: analyticalProjection.lastAppliedSequence
        )
    }
}

public struct BacktestReadModel: Equatable, Sendable {
    public let runs: [DuckDBBacktestProjection]
    public let signals: [DuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        runs: [DuckDBBacktestProjection] = [],
        signals: [DuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.runs = runs.sorted { $0.runID.rawValue < $1.runID.rawValue }
        self.signals = signals
            .filter { $0.source == .backtest }
            .sortedBySignalTime()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(analyticalProjection: DuckDBAnalyticalProjectionSnapshot) {
        self.init(
            runs: Array(analyticalProjection.backtestRuns.values),
            signals: analyticalProjection.signalTimeline,
            lastAppliedSequence: analyticalProjection.lastAppliedSequence
        )
    }
}

public struct PaperReadModel: Equatable, Sendable {
    public let sessions: [SQLitePaperSessionProjection]
    public let lastAppliedSequence: Int?

    public init(
        sessions: [SQLitePaperSessionProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.sessions = sessions.sorted { $0.sessionID.rawValue < $1.sessionID.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: SQLiteRuntimeProjectionSnapshot) {
        self.init(
            sessions: Array(runtimeProjection.paperSessions.values),
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct RiskReadModel: Equatable, Sendable {
    public let rejectedPaperOrderIDs: [Identifier]
    public let lastAppliedSequence: Int?

    public init(
        rejectedPaperOrderIDs: [Identifier] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.rejectedPaperOrderIDs = rejectedPaperOrderIDs.sorted { $0.rawValue < $1.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: SQLiteRuntimeProjectionSnapshot) {
        self.init(
            rejectedPaperOrderIDs: runtimeProjection.rejectedPaperOrderIDs,
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct PortfolioReadModel: Equatable, Sendable {
    public let portfolios: [SQLitePortfolioProjection]
    public let lastAppliedSequence: Int?

    public init(
        portfolios: [SQLitePortfolioProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.portfolios = portfolios.sorted { $0.portfolioID.rawValue < $1.portfolioID.rawValue }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: SQLiteRuntimeProjectionSnapshot) {
        self.init(
            portfolios: Array(runtimeProjection.portfolioProjections.values),
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }
}

public struct EventTimelineReadModel: Equatable, Sendable {
    public let envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) {
        self.envelopes = envelopes.sorted { $0.sequence < $1.sequence }
    }
}

public struct DashboardReadModel: Equatable, Sendable {
    public let market: MarketReadModel
    public let strategy: StrategyReadModel
    public let backtest: BacktestReadModel
    public let paper: PaperReadModel
    public let risk: RiskReadModel
    public let portfolio: PortfolioReadModel
    public let events: EventTimelineReadModel

    public init(
        market: MarketReadModel,
        strategy: StrategyReadModel,
        backtest: BacktestReadModel,
        paper: PaperReadModel,
        risk: RiskReadModel,
        portfolio: PortfolioReadModel,
        events: EventTimelineReadModel
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
        runtimeProjection: SQLiteRuntimeProjectionSnapshot,
        analyticalProjection: DuckDBAnalyticalProjectionSnapshot,
        eventTimeline: [EventEnvelope]
    ) {
        self.init(
            market: MarketReadModel(analyticalProjection: analyticalProjection),
            strategy: StrategyReadModel(analyticalProjection: analyticalProjection),
            backtest: BacktestReadModel(analyticalProjection: analyticalProjection),
            paper: PaperReadModel(runtimeProjection: runtimeProjection),
            risk: RiskReadModel(runtimeProjection: runtimeProjection),
            portfolio: PortfolioReadModel(runtimeProjection: runtimeProjection),
            events: EventTimelineReadModel(envelopes: eventTimeline)
        )
    }
}

public struct MarketViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let symbols: [String]
    public let barCount: Int
    public let tradeCount: Int
    public let bestBidAskCount: Int
    public let orderBookSnapshotCount: Int
    public let orderBookDeltaCount: Int
    public let latestBarClose: Double?
    public let lastAppliedSequence: Int?

    public init(readModel: MarketReadModel) {
        self.section = .market
        self.source = ViewModelSourceContract()
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

public struct StrategyViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let strategyIDs: [String]
    public let signalCount: Int
    public let latestSignalDirection: SignalDirection?
    public let lastAppliedSequence: Int?

    public init(readModel: StrategyReadModel) {
        self.section = .strategy
        self.source = ViewModelSourceContract()
        self.strategyIDs = readModel.signals.map(\.strategyID.rawValue).uniqueSorted()
        self.signalCount = readModel.signals.count
        self.latestSignalDirection = readModel.signals.last?.direction
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct BacktestRunViewModel: Codable, Equatable, Sendable {
    public let runID: String
    public let strategyID: String
    public let symbol: String
    public let timeframe: String
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(projection: DuckDBBacktestProjection) {
        self.runID = projection.runID.rawValue
        self.strategyID = projection.strategyID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.state = projection.state
        self.signalCount = projection.signalCount
        self.completedAt = projection.completedAt
    }
}

public struct BacktestViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let runs: [BacktestRunViewModel]
    public let totalSignalCount: Int
    public let completedRunCount: Int
    public let latestSignalDirection: SignalDirection?
    public let lastAppliedSequence: Int?

    public init(readModel: BacktestReadModel) {
        self.section = .backtest
        self.source = ViewModelSourceContract()
        self.runs = readModel.runs.map(BacktestRunViewModel.init)
        self.totalSignalCount = readModel.runs.reduce(0) { $0 + $1.signalCount }
        self.completedRunCount = readModel.runs.filter { $0.state == .completed }.count
        self.latestSignalDirection = readModel.signals.last?.direction
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct PaperSessionViewModel: Codable, Equatable, Sendable {
    public let sessionID: String
    public let strategyID: String
    public let symbol: String
    public let timeframe: String
    public let riskProfileID: String
    public let executionMode: ExecutionMode
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(projection: SQLitePaperSessionProjection) {
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

public struct PaperViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let sessions: [PaperSessionViewModel]
    public let activeSessionCount: Int
    public let completedSessionCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: PaperReadModel) {
        self.section = .paper
        self.source = ViewModelSourceContract()
        self.sessions = readModel.sessions.map(PaperSessionViewModel.init)
        self.activeSessionCount = readModel.sessions.filter { $0.state == .requested }.count
        self.completedSessionCount = readModel.sessions.filter { $0.state == .completed }.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct RiskViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let rejectedPaperOrderIDs: [String]
    public let rejectionCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: RiskReadModel) {
        self.section = .risk
        self.source = ViewModelSourceContract()
        self.rejectedPaperOrderIDs = readModel.rejectedPaperOrderIDs.map(\.rawValue)
        self.rejectionCount = readModel.rejectedPaperOrderIDs.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct PortfolioViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let portfolioIDs: [String]
    public let updatedPortfolioCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: PortfolioReadModel) {
        self.section = .portfolio
        self.source = ViewModelSourceContract()
        self.portfolioIDs = readModel.portfolios.map(\.portfolioID.rawValue)
        self.updatedPortfolioCount = readModel.portfolios.filter { $0.state == .updated }.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct EventLogViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let eventCount: Int
    public let streams: [String]
    public let lastSequence: Int?

    public init(readModel: EventTimelineReadModel) {
        self.section = .events
        self.source = ViewModelSourceContract()
        self.eventCount = readModel.envelopes.count
        self.streams = readModel.envelopes.map(\.stream.rawValue).uniqueSorted()
        self.lastSequence = readModel.envelopes.last?.sequence
    }
}

public struct DashboardViewModel: Codable, Equatable, Sendable {
    public let sections: [DashboardSection]
    public let market: MarketViewModel
    public let strategy: StrategyViewModel
    public let backtest: BacktestViewModel
    public let paper: PaperViewModel
    public let risk: RiskViewModel
    public let portfolio: PortfolioViewModel
    public let events: EventLogViewModel

    public init(
        readModel: DashboardReadModel,
        sections: [DashboardSection] = DashboardSection.allCases
    ) {
        self.sections = sections
        self.market = MarketViewModel(readModel: readModel.market)
        self.strategy = StrategyViewModel(readModel: readModel.strategy)
        self.backtest = BacktestViewModel(readModel: readModel.backtest)
        self.paper = PaperViewModel(readModel: readModel.paper)
        self.risk = RiskViewModel(readModel: readModel.risk)
        self.portfolio = PortfolioViewModel(readModel: readModel.portfolio)
        self.events = EventLogViewModel(readModel: readModel.events)
    }

    public var viewModelSources: [ViewModelSourceContract] {
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

private extension Array where Element == MarketBar {
    func sortedByBarTime() -> [MarketBar] {
        sorted { lhs, rhs in
            lhs.interval.end == rhs.interval.end
                ? lhs.symbol.rawValue < rhs.symbol.rawValue
                : lhs.interval.end < rhs.interval.end
        }
    }
}

private extension Array where Element == DuckDBSignalTimelineProjection {
    func sortedBySignalTime() -> [DuckDBSignalTimelineProjection] {
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

private extension MarketReadModel {
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
