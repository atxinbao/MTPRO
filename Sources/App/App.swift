import Foundation
import Core
import Persistence

/// DashboardSection 定义研究工作台 shell 的只读区域顺序。
///
/// MTP-23 新增 Report 区域用于展示研究输出快照；所有区域都只消费 App 层 ViewModel，
/// 不承载外部系统命令、broker action、signed endpoint 或真实交易入口。
public enum DashboardSection: String, CaseIterable, Codable, Hashable, Sendable {
    case market = "Market"
    case strategy = "Strategy"
    case backtest = "Backtest"
    case report = "Report"
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
    public let riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection]
    public let lastAppliedSequence: Int?

    public init(
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.riskBlockerEvidence = riskBlockerEvidence.sorted { lhs, rhs in
            lhs.sourceSequence == rhs.sourceSequence
                ? lhs.evidenceID.rawValue < rhs.evidenceID.rawValue
                : lhs.sourceSequence < rhs.sourceSequence
        }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: SQLiteRuntimeProjectionSnapshot) {
        self.init(
            riskBlockerEvidence: runtimeProjection.riskBlockerEvidence,
            lastAppliedSequence: runtimeProjection.lastAppliedSequence
        )
    }

    public var rejectedPaperOrderIDs: [Identifier] {
        riskBlockerEvidence.map(\.paperOrderID)
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

    public var exposures: [SQLitePortfolioExposureProjection] {
        portfolios
            .flatMap(\.exposures)
            .sorted { lhs, rhs in
                if lhs.portfolioID != rhs.portfolioID {
                    return lhs.portfolioID.rawValue < rhs.portfolioID.rawValue
                }
                if lhs.symbol != rhs.symbol {
                    return lhs.symbol.rawValue < rhs.symbol.rawValue
                }
                return lhs.timeframe.rawValue < rhs.timeframe.rawValue
            }
    }
}

public struct EventTimelineReadModel: Equatable, Sendable {
    public let envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) {
        self.envelopes = envelopes.sorted { $0.sequence < $1.sequence }
    }
}

/// ReportParityStatus 描述报告层能从 projection snapshot 证明的 Backtest / Paper 一致性证据。
///
/// 这里不会替代 Core 层 `BacktestPaperParity` 的完整信号时间线校验；报告只消费稳定投影，
/// 因此只能表达同策略、同 symbol / timeframe 和信号数量的投影级证据。
public enum ReportParityStatus: String, Codable, Equatable, Sendable {
    case matchedProjectionEvidence = "matched projection evidence"
    case missingPaperProjection = "missing paper projection"
    case mismatchedProjectionEvidence = "mismatched projection evidence"
}

/// ReportExecutionAuthorization 明确报告只是研究输出，不是交易执行授权。
///
/// 该值会进入 Dashboard ViewModel 和 shell snapshot，作为 Paper / Live 禁区的可观察证据；
/// 它不提供 order submit、broker action、signed endpoint 或真实账户访问能力。
public enum ReportExecutionAuthorization: String, Codable, Equatable, Sendable {
    case researchOutputOnly = "research output only"
}

/// ReportExecutionCostEvidence 把 MTP-27 固定费用 / 滑点假设映射成报告层只读证据。
///
/// 该证据只从 portfolio exposure projection 的 symbol、timeframe、paper quantity 和 reference price
/// 派生，并同时计算 Backtest / Paper 两种本地模式的成本估算一致性；它不读取交易所费率表、
/// 不连接 broker、不提交订单，也不代表真实成交或账户成本。
public struct ReportExecutionCostEvidence: Codable, Equatable, Sendable {
    public let assumptionID: String
    public let symbol: String
    public let timeframe: String
    public let liquidityRole: ExecutionCostLiquidityRole
    public let grossNotional: Double
    public let feeAmount: Double
    public let slippageAmount: Double
    public let backtestTotalCostAmount: Double
    public let paperTotalCostAmount: Double
    public let roundingDecimalPlaces: Int
    public let sourceSequence: Int
    public let parityConsistent: Bool

    public init(
        exposure: SQLitePortfolioExposureProjection,
        liquidityRole: ExecutionCostLiquidityRole,
        assumptions: ExecutionCostAssumptions = .deterministicFixture
    ) {
        let backtest = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: exposure.symbol,
                timeframe: exposure.timeframe,
                executionMode: .backtest,
                referencePrice: exposure.referencePrice,
                quantity: exposure.paperQuantity,
                liquidityRole: liquidityRole
            ),
            assumptions: assumptions
        )
        let paper = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: exposure.symbol,
                timeframe: exposure.timeframe,
                executionMode: .paper,
                referencePrice: exposure.referencePrice,
                quantity: exposure.paperQuantity,
                liquidityRole: liquidityRole
            ),
            assumptions: assumptions
        )
        let parity = ExecutionCostParity.verify(backtest: backtest, paper: paper)

        self.assumptionID = assumptions.assumptionID.rawValue
        self.symbol = exposure.symbol.rawValue
        self.timeframe = exposure.timeframe.rawValue
        self.liquidityRole = liquidityRole
        self.grossNotional = backtest.grossNotional
        self.feeAmount = backtest.feeAmount
        self.slippageAmount = backtest.slippageAmount
        self.backtestTotalCostAmount = backtest.totalCostAmount
        self.paperTotalCostAmount = paper.totalCostAmount
        self.roundingDecimalPlaces = assumptions.roundingDecimalPlaces
        self.sourceSequence = exposure.sourceSequence
        self.parityConsistent = parity.isConsistent
    }
}

/// TradingValidationEvidenceSummary 是 Report / Dashboard 共享的交易验证证据聚合。
///
/// 它把 projection-level parity、固定 fees / slippage 成本一致性、risk blocker 和 paper-only
/// portfolio exposure 收敛到一个只读快照中。所有字段都来自 Core / Persistence 的稳定 read model，
/// 不暴露 SQLite / DuckDB schema、runtime object、adapter request 或任何真实交易能力。
public struct TradingValidationEvidenceSummary: Codable, Equatable, Sendable {
    public let parityStatus: ReportParityStatus
    public let executionCostEvidence: [ReportExecutionCostEvidence]
    public let riskBlockerEvidenceIDs: [String]
    public let riskBlockerReasons: [RiskBlockerReason]
    public let portfolioExposureSymbols: [String]
    public let portfolioExposureCount: Int
    public let portfolioGrossExposureNotional: Double
    public let sourceSequences: [Int]
    public let authorizesTradingExecution: Bool

    public init(
        parityStatus: ReportParityStatus,
        executionCostEvidence: [ReportExecutionCostEvidence] = [],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        portfolioExposures: [SQLitePortfolioExposureProjection] = []
    ) {
        self.parityStatus = parityStatus
        self.executionCostEvidence = executionCostEvidence.sortedByCostEvidence()
        self.riskBlockerEvidenceIDs = riskBlockerEvidence
            .map(\.evidenceID.rawValue)
            .uniqueSorted()
        self.riskBlockerReasons = riskBlockerEvidence
            .map(\.reason.rawValue)
            .uniqueSorted()
            .compactMap(RiskBlockerReason.init(rawValue:))
        self.portfolioExposureSymbols = portfolioExposures
            .map(\.symbol.rawValue)
            .uniqueSorted()
        self.portfolioExposureCount = portfolioExposures.count
        self.portfolioGrossExposureNotional = portfolioExposures.reduce(0) {
            $0 + $1.grossExposureNotional
        }
        self.sourceSequences = (
            executionCostEvidence.map(\.sourceSequence)
                + riskBlockerEvidence.map(\.sourceSequence)
                + portfolioExposures.map(\.sourceSequence)
        ).uniqueSorted()
        self.authorizesTradingExecution = false
    }

    public var executionCostEvidenceCount: Int {
        executionCostEvidence.count
    }

    public var executionCostParityConsistent: Bool {
        executionCostEvidence.isEmpty == false
            && executionCostEvidence.allSatisfy(\.parityConsistent)
    }

    public var riskBlockerEvidenceCount: Int {
        riskBlockerEvidenceIDs.count
    }
}

/// ResearchBacktestReportArtifact 是 MTP-23 的最小报告 artifact。
///
/// 输入来自 `DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot` 和 append-only
/// event timeline 派生的 read model；输出只保留报告观察字段，不暴露数据库表、SQL、runtime object、
/// Binance adapter 或任何可触发真实交易的命令。
public struct ResearchBacktestReportArtifact: Codable, Equatable, Sendable {
    public let reportID: String
    public let backtestRunID: String
    public let backtestState: ProjectionLifecycleState
    public let researchIDs: [String]
    public let paperSessionIDs: [String]
    public let strategyIDs: [String]
    public let symbol: String
    public let timeframe: String
    public let backtestSignalCount: Int
    public let researchSignalCount: Int
    public let paperSignalCount: Int
    public let eventCount: Int
    public let parityStatus: ReportParityStatus
    public let tradingValidationEvidence: TradingValidationEvidenceSummary
    public let executionAuthorization: ReportExecutionAuthorization
    public let lastAppliedSequence: Int?

    public init(
        reportID: String,
        backtestRunID: String,
        backtestState: ProjectionLifecycleState,
        researchIDs: [String],
        paperSessionIDs: [String],
        strategyIDs: [String],
        symbol: String,
        timeframe: String,
        backtestSignalCount: Int,
        researchSignalCount: Int,
        paperSignalCount: Int,
        eventCount: Int,
        parityStatus: ReportParityStatus,
        tradingValidationEvidence: TradingValidationEvidenceSummary,
        executionAuthorization: ReportExecutionAuthorization = .researchOutputOnly,
        lastAppliedSequence: Int?
    ) {
        self.reportID = reportID
        self.backtestRunID = backtestRunID
        self.backtestState = backtestState
        self.researchIDs = researchIDs.uniqueSorted()
        self.paperSessionIDs = paperSessionIDs.uniqueSorted()
        self.strategyIDs = strategyIDs.uniqueSorted()
        self.symbol = symbol
        self.timeframe = timeframe
        self.backtestSignalCount = backtestSignalCount
        self.researchSignalCount = researchSignalCount
        self.paperSignalCount = paperSignalCount
        self.eventCount = eventCount
        self.parityStatus = parityStatus
        self.tradingValidationEvidence = tradingValidationEvidence
        self.executionAuthorization = executionAuthorization
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var authorizesTradingExecution: Bool {
        false
    }
}

/// ReportReadModel 从现有 projection snapshots 生成 Research -> Backtest -> Report 最小观察面。
///
/// 它把订单簿研究投影、EMA 回测投影、Paper session 投影和事件流水汇总成报告 artifact；
/// 该 read model 不重跑策略、不读取数据库 schema、不调用 Runtime / Adapters，也不把报告解释为交易授权。
public struct ReportReadModel: Equatable, Sendable {
    public let artifacts: [ResearchBacktestReportArtifact]
    public let lastAppliedSequence: Int?

    public init(
        artifacts: [ResearchBacktestReportArtifact] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.artifacts = artifacts.sorted { left, right in
            left.reportID < right.reportID
        }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(
        analyticalProjection: DuckDBAnalyticalProjectionSnapshot,
        runtimeProjection: SQLiteRuntimeProjectionSnapshot,
        eventTimeline: [EventEnvelope]
    ) {
        let sortedBacktests = analyticalProjection.backtestRuns.values.sorted {
            $0.runID.rawValue < $1.runID.rawValue
        }
        let researchRuns = Array(analyticalProjection.orderBookResearchRuns.values)
        let paperSessions = Array(runtimeProjection.paperSessions.values)
        let riskBlockerEvidence = runtimeProjection.riskBlockerEvidence
        let portfolioExposures = runtimeProjection.portfolioProjections.values.flatMap(\.exposures)
        let lastAppliedSequence = Self.maxSequence(
            analyticalProjection.lastAppliedSequence,
            runtimeProjection.lastAppliedSequence,
            eventTimeline.map(\.sequence).max()
        )

        let artifacts = sortedBacktests.map { backtest in
            Self.makeArtifact(
                backtest: backtest,
                researchRuns: researchRuns,
                signalTimeline: analyticalProjection.signalTimeline,
                paperSessions: paperSessions,
                riskBlockerEvidence: riskBlockerEvidence,
                portfolioExposures: portfolioExposures,
                eventCount: eventTimeline.count,
                lastAppliedSequence: lastAppliedSequence
            )
        }

        self.init(artifacts: artifacts, lastAppliedSequence: lastAppliedSequence)
    }

    private static func makeArtifact(
        backtest: DuckDBBacktestProjection,
        researchRuns: [DuckDBOrderBookResearchProjection],
        signalTimeline: [DuckDBSignalTimelineProjection],
        paperSessions: [SQLitePaperSessionProjection],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection],
        portfolioExposures: [SQLitePortfolioExposureProjection],
        eventCount: Int,
        lastAppliedSequence: Int?
    ) -> ResearchBacktestReportArtifact {
        let matchingResearchRuns = researchRuns.filter {
            $0.symbol == backtest.symbol && $0.timeframe == backtest.timeframe
        }
        let matchingPaperSessions = paperSessions.filter {
            $0.strategyID == backtest.strategyID
                && $0.symbol == backtest.symbol
                && $0.timeframe == backtest.timeframe
        }
        let matchingResearchSignals = signalTimeline.filter {
            $0.source == .orderBookImbalanceResearch
                && $0.symbol == backtest.symbol
                && $0.timeframe == backtest.timeframe
        }
        let matchingRiskBlockers = riskBlockerEvidence.filter {
            $0.symbol == backtest.symbol && $0.timeframe == backtest.timeframe
        }
        let matchingPortfolioExposures = portfolioExposures.filter {
            $0.symbol == backtest.symbol && $0.timeframe == backtest.timeframe
        }
        let parityEvidenceStatus = parityStatus(backtest: backtest, paperSessions: matchingPaperSessions)
        let executionCostEvidence = makeExecutionCostEvidence(from: matchingPortfolioExposures)

        return ResearchBacktestReportArtifact(
            reportID: "report-\(backtest.runID.rawValue)",
            backtestRunID: backtest.runID.rawValue,
            backtestState: backtest.state,
            researchIDs: matchingResearchRuns.map(\.researchID.rawValue),
            paperSessionIDs: matchingPaperSessions.map(\.sessionID.rawValue),
            strategyIDs: ([backtest.strategyID.rawValue] + matchingResearchRuns.map(\.strategyID.rawValue)),
            symbol: backtest.symbol.rawValue,
            timeframe: backtest.timeframe.rawValue,
            backtestSignalCount: backtest.signalCount,
            researchSignalCount: matchingResearchSignals.count,
            paperSignalCount: matchingPaperSessions.reduce(0) { $0 + $1.signalCount },
            eventCount: eventCount,
            parityStatus: parityEvidenceStatus,
            tradingValidationEvidence: TradingValidationEvidenceSummary(
                parityStatus: parityEvidenceStatus,
                executionCostEvidence: executionCostEvidence,
                riskBlockerEvidence: matchingRiskBlockers,
                portfolioExposures: matchingPortfolioExposures
            ),
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func makeExecutionCostEvidence(
        from exposures: [SQLitePortfolioExposureProjection]
    ) -> [ReportExecutionCostEvidence] {
        exposures.flatMap { exposure in
            ExecutionCostLiquidityRole.allCases.map { liquidityRole in
                ReportExecutionCostEvidence(
                    exposure: exposure,
                    liquidityRole: liquidityRole
                )
            }
        }
    }

    private static func parityStatus(
        backtest: DuckDBBacktestProjection,
        paperSessions: [SQLitePaperSessionProjection]
    ) -> ReportParityStatus {
        guard paperSessions.isEmpty == false else {
            return .missingPaperProjection
        }
        let completedPaperSignalCount = paperSessions
            .filter { $0.state.isTerminal }
            .reduce(0) { $0 + $1.signalCount }
        guard completedPaperSignalCount == backtest.signalCount else {
            return .mismatchedProjectionEvidence
        }
        return .matchedProjectionEvidence
    }

    private static func maxSequence(_ values: Int?...) -> Int? {
        values.compactMap { $0 }.max()
    }
}

/// DashboardReadModel 聚合 Dashboard 所需的稳定 read model。
///
/// 输入来自 Persistence projection snapshots 和 append-only event timeline；新增 Report read model
/// 也遵循同一来源边界，禁止 UI 直接读取数据库 schema、Runtime object 或行情 adapter。
public struct DashboardReadModel: Equatable, Sendable {
    public let market: MarketReadModel
    public let strategy: StrategyReadModel
    public let backtest: BacktestReadModel
    public let report: ReportReadModel
    public let paper: PaperReadModel
    public let risk: RiskReadModel
    public let portfolio: PortfolioReadModel
    public let events: EventTimelineReadModel

    public init(
        market: MarketReadModel,
        strategy: StrategyReadModel,
        backtest: BacktestReadModel,
        report: ReportReadModel,
        paper: PaperReadModel,
        risk: RiskReadModel,
        portfolio: PortfolioReadModel,
        events: EventTimelineReadModel
    ) {
        self.market = market
        self.strategy = strategy
        self.backtest = backtest
        self.report = report
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
            report: ReportReadModel(
                analyticalProjection: analyticalProjection,
                runtimeProjection: runtimeProjection,
                eventTimeline: eventTimeline
            ),
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

/// ReportArtifactViewModel 是单个报告 artifact 的可编码展示快照。
///
/// 它只复制 `ResearchBacktestReportArtifact` 的只读字段，供 Dashboard shell 展示；
/// `authorizesTradingExecution` 必须保持 false，避免把报告误用为 Paper / Live 执行入口。
public struct ReportArtifactViewModel: Codable, Equatable, Sendable {
    public let reportID: String
    public let backtestRunID: String
    public let backtestState: ProjectionLifecycleState
    public let researchIDs: [String]
    public let paperSessionIDs: [String]
    public let strategyIDs: [String]
    public let symbol: String
    public let timeframe: String
    public let backtestSignalCount: Int
    public let researchSignalCount: Int
    public let paperSignalCount: Int
    public let eventCount: Int
    public let parityStatus: ReportParityStatus
    public let tradingValidationEvidence: TradingValidationEvidenceSummary
    public let executionAuthorization: ReportExecutionAuthorization
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(artifact: ResearchBacktestReportArtifact) {
        self.reportID = artifact.reportID
        self.backtestRunID = artifact.backtestRunID
        self.backtestState = artifact.backtestState
        self.researchIDs = artifact.researchIDs
        self.paperSessionIDs = artifact.paperSessionIDs
        self.strategyIDs = artifact.strategyIDs
        self.symbol = artifact.symbol
        self.timeframe = artifact.timeframe
        self.backtestSignalCount = artifact.backtestSignalCount
        self.researchSignalCount = artifact.researchSignalCount
        self.paperSignalCount = artifact.paperSignalCount
        self.eventCount = artifact.eventCount
        self.parityStatus = artifact.parityStatus
        self.tradingValidationEvidence = artifact.tradingValidationEvidence
        self.executionAuthorization = artifact.executionAuthorization
        self.authorizesTradingExecution = artifact.authorizesTradingExecution
        self.lastAppliedSequence = artifact.lastAppliedSequence
    }
}

/// ReportViewModel 汇总 MTP-23 最小报告路径的只读指标。
///
/// 指标来自 `ReportReadModel`，用于展示报告数、研究运行数和投影级 parity evidence；
/// 该 ViewModel 不调用 Runtime / Adapters，不暴露数据库实现细节，也不提供真实交易控制。
public struct ReportViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let artifacts: [ReportArtifactViewModel]
    public let artifactCount: Int
    public let completedBacktestCount: Int
    public let researchRunCount: Int
    public let paperSessionCount: Int
    public let matchedParityEvidenceCount: Int
    public let tradingValidationEvidenceCount: Int
    public let executionCostEvidenceCount: Int
    public let executionCostAssumptionIDs: [String]
    public let executionCostParityConsistent: Bool
    public let riskBlockerEvidenceCount: Int
    public let riskBlockerEvidenceIDs: [String]
    public let portfolioExposureEvidenceCount: Int
    public let portfolioExposureSymbols: [String]
    public let portfolioGrossExposureNotional: Double
    public let tradingValidationAuthorizesExecution: Bool
    public let authorizesTradingExecution: Bool
    public let latestParityStatus: ReportParityStatus?
    public let lastAppliedSequence: Int?

    public init(readModel: ReportReadModel) {
        let tradingEvidence = readModel.artifacts.map(\.tradingValidationEvidence)
        let costEvidence = tradingEvidence.flatMap(\.executionCostEvidence)
        self.section = .report
        self.source = ViewModelSourceContract()
        self.artifacts = readModel.artifacts.map(ReportArtifactViewModel.init)
        self.artifactCount = readModel.artifacts.count
        self.completedBacktestCount = readModel.artifacts.filter { $0.backtestState == .completed }.count
        self.researchRunCount = readModel.artifacts
            .flatMap(\.researchIDs)
            .uniqueSorted()
            .count
        self.paperSessionCount = readModel.artifacts
            .flatMap(\.paperSessionIDs)
            .uniqueSorted()
            .count
        self.matchedParityEvidenceCount = readModel.artifacts.filter {
            $0.parityStatus == .matchedProjectionEvidence
        }.count
        self.tradingValidationEvidenceCount = tradingEvidence.count
        self.executionCostEvidenceCount = costEvidence.count
        self.executionCostAssumptionIDs = costEvidence
            .map(\.assumptionID)
            .uniqueSorted()
        self.executionCostParityConsistent = costEvidence.isEmpty == false
            && costEvidence.allSatisfy(\.parityConsistent)
        self.riskBlockerEvidenceCount = tradingEvidence.reduce(0) {
            $0 + $1.riskBlockerEvidenceCount
        }
        self.riskBlockerEvidenceIDs = tradingEvidence
            .flatMap(\.riskBlockerEvidenceIDs)
            .uniqueSorted()
        self.portfolioExposureEvidenceCount = tradingEvidence.reduce(0) {
            $0 + $1.portfolioExposureCount
        }
        self.portfolioExposureSymbols = tradingEvidence
            .flatMap(\.portfolioExposureSymbols)
            .uniqueSorted()
        self.portfolioGrossExposureNotional = tradingEvidence.reduce(0) {
            $0 + $1.portfolioGrossExposureNotional
        }
        self.tradingValidationAuthorizesExecution = tradingEvidence.contains {
            $0.authorizesTradingExecution
        }
        self.authorizesTradingExecution = readModel.artifacts.contains {
            $0.authorizesTradingExecution
        }
        self.latestParityStatus = readModel.artifacts.last?.parityStatus
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
        self.activeSessionCount = readModel.sessions.filter { $0.state.isActive }.count
        self.completedSessionCount = readModel.sessions.filter { $0.state.isTerminal }.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct RiskBlockerEvidenceViewModel: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let paperOrderID: String
    public let symbol: String
    public let timeframe: String
    public let proposedQuantity: Double
    public let riskProfileID: String
    public let executionMode: ExecutionMode
    public let reason: RiskBlockerReason
    public let sourceSequence: Int

    public init(projection: SQLiteRiskBlockerEvidenceProjection) {
        self.evidenceID = projection.evidenceID.rawValue
        self.paperOrderID = projection.paperOrderID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.proposedQuantity = projection.proposedQuantity.rawValue
        self.riskProfileID = projection.riskProfileID.rawValue
        self.executionMode = projection.executionMode
        self.reason = projection.reason
        self.sourceSequence = projection.sourceSequence
    }
}

public struct RiskViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let evidence: [RiskBlockerEvidenceViewModel]
    public let rejectedPaperOrderIDs: [String]
    public let rejectionCount: Int
    public let blockerReasons: [RiskBlockerReason]
    public let lastAppliedSequence: Int?

    public init(readModel: RiskReadModel) {
        let evidence = readModel.riskBlockerEvidence.map(RiskBlockerEvidenceViewModel.init)
        self.section = .risk
        self.source = ViewModelSourceContract()
        self.evidence = evidence
        self.rejectedPaperOrderIDs = readModel.rejectedPaperOrderIDs.map(\.rawValue)
        self.rejectionCount = evidence.count
        self.blockerReasons = evidence.map(\.reason)
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct PortfolioExposureViewModel: Codable, Equatable, Sendable {
    public let portfolioID: String
    public let symbol: String
    public let timeframe: String
    public let paperQuantity: Double
    public let referencePrice: Double
    public let grossExposureNotional: Double
    public let source: PortfolioExposureSource
    public let sourceSequence: Int

    public init(projection: SQLitePortfolioExposureProjection) {
        self.portfolioID = projection.portfolioID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.paperQuantity = projection.paperQuantity.rawValue
        self.referencePrice = projection.referencePrice.rawValue
        self.grossExposureNotional = projection.grossExposureNotional
        self.source = projection.source
        self.sourceSequence = projection.sourceSequence
    }
}

public struct PortfolioViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let portfolioIDs: [String]
    public let updatedPortfolioCount: Int
    public let exposures: [PortfolioExposureViewModel]
    public let exposureCount: Int
    public let totalGrossExposureNotional: Double
    public let lastAppliedSequence: Int?

    public init(readModel: PortfolioReadModel) {
        let exposures = readModel.exposures.map(PortfolioExposureViewModel.init)
        self.section = .portfolio
        self.source = ViewModelSourceContract()
        self.portfolioIDs = readModel.portfolios.map(\.portfolioID.rawValue)
        self.updatedPortfolioCount = readModel.portfolios.filter { $0.state == .updated }.count
        self.exposures = exposures
        self.exposureCount = exposures.count
        self.totalGrossExposureNotional = exposures.reduce(0) {
            $0 + $1.grossExposureNotional
        }
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
    public let report: ReportViewModel
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
        self.report = ReportViewModel(readModel: readModel.report)
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
            report.source,
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

private extension Array where Element == ReportExecutionCostEvidence {
    func sortedByCostEvidence() -> [ReportExecutionCostEvidence] {
        sorted { lhs, rhs in
            if lhs.symbol != rhs.symbol {
                return lhs.symbol < rhs.symbol
            }
            if lhs.timeframe != rhs.timeframe {
                return lhs.timeframe < rhs.timeframe
            }
            if lhs.sourceSequence != rhs.sourceSequence {
                return lhs.sourceSequence < rhs.sourceSequence
            }
            return lhs.liquidityRole.rawValue < rhs.liquidityRole.rawValue
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

private extension Array where Element == Int {
    func uniqueSorted() -> [Int] {
        Array(Set(self)).sorted()
    }
}
