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
    public let paperAccounts: [SQLitePaperAccountProjection]
    public let paperPositions: [SQLitePaperPositionProjection]
    public let lastAppliedSequence: Int?

    public init(
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        paperAccounts: [SQLitePaperAccountProjection] = [],
        paperPositions: [SQLitePaperPositionProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.riskBlockerEvidence = riskBlockerEvidence.sorted { lhs, rhs in
            lhs.sourceSequence == rhs.sourceSequence
                ? lhs.evidenceID.rawValue < rhs.evidenceID.rawValue
                : lhs.sourceSequence < rhs.sourceSequence
        }
        self.paperAccounts = paperAccounts.sorted {
            $0.accountID.rawValue < $1.accountID.rawValue
        }
        self.paperPositions = paperPositions.sortedByPaperPosition()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public init(runtimeProjection: SQLiteRuntimeProjectionSnapshot) {
        let portfolios = Array(runtimeProjection.portfolioProjections.values)
        self.init(
            riskBlockerEvidence: runtimeProjection.riskBlockerEvidence,
            paperAccounts: portfolios.compactMap(\.paperAccount),
            paperPositions: portfolios.flatMap(\.paperPositions),
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

    public var paperAccounts: [SQLitePaperAccountProjection] {
        portfolios
            .compactMap(\.paperAccount)
            .sorted { $0.accountID.rawValue < $1.accountID.rawValue }
    }

    public var paperPositions: [SQLitePaperPositionProjection] {
        portfolios
            .flatMap(\.paperPositions)
            .sortedByPaperPosition()
    }

    public var paperPnLSummaries: [SQLitePaperPortfolioPnLProjection] {
        portfolios
            .compactMap(\.paperPnLSummary)
            .sorted { $0.sourceSequence < $1.sourceSequence }
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
    public let paperAccountIDs: [String]
    public let paperPositionCount: Int
    public let paperNetPnL: Double
    public let sourceSequences: [Int]
    public let authorizesTradingExecution: Bool

    public init(
        parityStatus: ReportParityStatus,
        executionCostEvidence: [ReportExecutionCostEvidence] = [],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        portfolioExposures: [SQLitePortfolioExposureProjection] = [],
        paperAccounts: [SQLitePaperAccountProjection] = [],
        paperPositions: [SQLitePaperPositionProjection] = [],
        paperPnLSummaries: [SQLitePaperPortfolioPnLProjection] = []
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
        self.paperAccountIDs = paperAccounts.map(\.accountID.rawValue).uniqueSorted()
        self.paperPositionCount = paperPositions.count
        self.paperNetPnL = paperPnLSummaries.reduce(0) {
            $0 + $1.netPaperPnL
        }
        self.sourceSequences = (
            executionCostEvidence.map(\.sourceSequence)
                + riskBlockerEvidence.map(\.sourceSequence)
                + portfolioExposures.map(\.sourceSequence)
                + paperAccounts.map(\.sourceSequence)
                + paperPositions.map(\.sourceSequence)
                + paperPnLSummaries.map(\.sourceSequence)
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

/// PaperSessionRuntimeEvidenceSummary 汇总 Paper Session runtime 的只读证据。
///
/// 输入只允许来自 append-only event timeline 的 replay summary，以及 SQLite runtime projection
/// 已经输出的稳定 read model。它把 lifecycle、proposal、risk blocker、portfolio exposure
/// 和 replay flags 收敛给 Report / Dashboard 展示，不暴露数据库 schema、runtime object、
/// broker action、signed endpoint 或真实订单授权。
public struct PaperSessionRuntimeEvidenceSummary: Codable, Equatable, Sendable {
    public let factsSource: String
    public let replayAvailable: Bool
    public let replayedSequences: [Int]
    public let replayedStreams: [String]
    public let sessionIDs: [String]
    public let lifecycleStates: [PaperSessionLifecycleState]
    public let signalEventCount: Int
    public let proposalIDs: [String]
    public let riskEvaluationRequestedCount: Int
    public let riskBlockerEvidenceIDs: [String]
    public let rejectedPaperOrderIDs: [String]
    public let portfolioUpdateIDs: [String]
    public let portfolioIDs: [String]
    public let portfolioExposureSymbols: [String]
    public let portfolioExposureCount: Int
    public let portfolioGrossExposureNotional: Double
    public let sourceSequences: [Int]
    public let coversSessionEvents: Bool
    public let coversProposalEvents: Bool
    public let coversRiskBlockerEvents: Bool
    public let coversPortfolioProjectionEvents: Bool
    public let appendOnlyFactsSourceIsReplaySource: Bool
    public let replayResultIsDeterministic: Bool
    public let paperOnlyBoundaryHeld: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        replaySummary: PaperSessionReplayEvidenceSummary? = nil,
        paperSessions: [SQLitePaperSessionProjection] = [],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection] = [],
        portfolioExposures: [SQLitePortfolioExposureProjection] = []
    ) {
        let replayedSequences = replaySummary?.replayedSequences ?? []
        let replaySessionIDs = replaySummary?.sessionIDs.map(\.rawValue) ?? []
        let replayRiskEvidenceIDs = replaySummary?.riskBlockerEvidenceIDs.map(\.rawValue) ?? []
        let replayRejectedOrderIDs = replaySummary?.rejectedPaperOrderIDs.map(\.rawValue) ?? []
        let replayPortfolioIDs = replaySummary?.portfolioIDs.map(\.rawValue) ?? []
        let projectionPortfolioIDs = portfolioExposures.map(\.portfolioID.rawValue)
        let runtimePaperBoundaryHeld = paperSessions.allSatisfy { $0.executionMode == .paper }
            && riskBlockerEvidence.allSatisfy { $0.executionMode == .paper }
            && portfolioExposures.allSatisfy { $0.source == .paperProjection }

        self.factsSource = replaySummary?.factsSource ?? "no matching append-only replay facts"
        self.replayAvailable = replaySummary != nil
        self.replayedSequences = replayedSequences
        self.replayedStreams = (replaySummary?.replayedStreams.map(\.rawValue) ?? []).uniqueSorted()
        self.sessionIDs = (
            replaySessionIDs + paperSessions.map(\.sessionID.rawValue)
        ).uniqueSorted()
        self.lifecycleStates = replaySummary?.lifecycleStates ?? []
        self.signalEventCount = replaySummary?.signalEventCount ?? 0
        self.proposalIDs = (replaySummary?.proposalIDs.map(\.rawValue) ?? []).uniqueSorted()
        self.riskEvaluationRequestedCount = replaySummary?.riskEvaluationRequestedCount ?? 0
        self.riskBlockerEvidenceIDs = (
            replayRiskEvidenceIDs + riskBlockerEvidence.map(\.evidenceID.rawValue)
        ).uniqueSorted()
        self.rejectedPaperOrderIDs = (
            replayRejectedOrderIDs + riskBlockerEvidence.map(\.paperOrderID.rawValue)
        ).uniqueSorted()
        self.portfolioUpdateIDs = (replaySummary?.portfolioUpdateIDs.map(\.rawValue) ?? []).uniqueSorted()
        self.portfolioIDs = (
            replayPortfolioIDs + projectionPortfolioIDs
        ).uniqueSorted()
        self.portfolioExposureSymbols = portfolioExposures
            .map(\.symbol.rawValue)
            .uniqueSorted()
        self.portfolioExposureCount = portfolioExposures.count
        self.portfolioGrossExposureNotional = portfolioExposures.reduce(0) {
            $0 + $1.grossExposureNotional
        }
        self.sourceSequences = (
            replayedSequences
                + riskBlockerEvidence.map(\.sourceSequence)
                + portfolioExposures.map(\.sourceSequence)
        ).uniqueSorted()
        self.coversSessionEvents = replaySummary?.coversSessionEvents ?? false
        self.coversProposalEvents = replaySummary?.coversProposalEvents ?? false
        self.coversRiskBlockerEvents = (replaySummary?.coversRiskBlockerEvents ?? false)
            || riskBlockerEvidence.isEmpty == false
        self.coversPortfolioProjectionEvents = (replaySummary?.coversPortfolioProjectionEvents ?? false)
            || portfolioExposures.isEmpty == false
        self.appendOnlyFactsSourceIsReplaySource = replaySummary?.appendOnlyFactsSourceIsReplaySource ?? false
        self.replayResultIsDeterministic = replaySummary?.replayResultIsDeterministic ?? false
        self.paperOnlyBoundaryHeld = (replaySummary?.paperOnlyBoundaryHeld ?? true)
            && runtimePaperBoundaryHeld
        self.authorizesLiveTrading = replaySummary?.authorizesLiveTrading ?? false
        self.touchesBrokerAction = replaySummary?.touchesBrokerAction ?? false
        self.authorizesTradingExecution = false
    }

    public var hasEvidence: Bool {
        replayAvailable
            || sessionIDs.isEmpty == false
            || riskBlockerEvidenceIDs.isEmpty == false
            || portfolioExposureCount > 0
    }

    public var replayedSequenceCount: Int {
        replayedSequences.count
    }

    public var proposalCount: Int {
        proposalIDs.count
    }
}

/// PaperExecutionWorkflowEvidenceSummary 汇总 paper execution workflow 的只读证据。
///
/// 输入只来自 append-only replay summary 和同一批 replay envelope，用于把 decision -> order
/// -> local lifecycle -> simulated fill -> portfolio projection 的本地 evidence 暴露给 Report / Dashboard。
/// 该摘要不创建订单、不读取 SQLite / DuckDB schema、不调用 Runtime / Adapter，也不授权真实交易。
public struct PaperExecutionWorkflowEvidenceSummary: Codable, Equatable, Sendable {
    public let factsSource: String
    public let replayAvailable: Bool
    public let workflowSequences: [Int]
    public let workflowStreams: [String]
    public let localLifecycleTransitionIDs: [String]
    public let decisionIDs: [String]
    public let paperOrderIDs: [String]
    public let simulatedFillIDs: [String]
    public let paperAccountPortfolioSnapshotIDs: [String]
    public let portfolioUpdateIDs: [String]
    public let portfolioIDs: [String]
    public let simulatedFillGrossNotional: Double
    public let simulatedFillFeeAmount: Double
    public let simulatedFillSlippageAmount: Double
    public let simulatedFillCostImpactAmount: Double
    public let coversLocalLifecycleEvents: Bool
    public let coversDecisionEvents: Bool
    public let coversPaperOrderEvents: Bool
    public let coversSimulatedFillEvents: Bool
    public let coversDecisionOrderFillChain: Bool
    public let projectsPortfolioFromSimulatedFill: Bool
    public let appendOnlyFactsSourceIsReplaySource: Bool
    public let replayResultIsDeterministic: Bool
    public let paperOnlyBoundaryHeld: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        replaySummary: PaperSessionReplayEvidenceSummary? = nil,
        workflowEnvelopes: [EventEnvelope] = []
    ) {
        let paperExecutionEnvelopes = workflowEnvelopes.filter(Self.isPaperExecutionWorkflowEnvelope)
        let localLifecycleTransitions = paperExecutionEnvelopes.compactMap(Self.localLifecycleTransition)
        let simulatedFillEvents = paperExecutionEnvelopes.compactMap(Self.simulatedFill)
        let accountPortfolioSnapshots = paperExecutionEnvelopes.compactMap(Self.accountPortfolioSnapshot)
        let replayDecisionIDs = replaySummary?.paperExecutionDecisionIDs.map(\.rawValue) ?? []
        let localLifecycleDecisionIDs = localLifecycleTransitions.map(\.riskDecisionID.rawValue)
        let replayPaperOrderIDs = replaySummary?.paperOrderIDs.map(\.rawValue) ?? []
        let localLifecyclePaperOrderIDs = localLifecycleTransitions.map(\.orderID.rawValue)
        let simulatedFillPaperOrderIDs = simulatedFillEvents.map(\.orderID.rawValue)
        let simulatedFillIDs = (
            replaySummary?.simulatedFillIDs.map(\.rawValue) ?? []
        ) + simulatedFillEvents.map(\.fillID.rawValue)
        let portfolioUpdateIDs = replaySummary?.portfolioUpdateIDs.map(\.rawValue) ?? []
        let decisionIDs = (replayDecisionIDs + localLifecycleDecisionIDs).uniqueSorted()
        let paperOrderIDs = (
            replayPaperOrderIDs + localLifecyclePaperOrderIDs + simulatedFillPaperOrderIDs
        ).uniqueSorted()
        let coversDecisionEvents = (replaySummary?.coversPaperExecutionDecisionEvents ?? false)
            || localLifecycleDecisionIDs.isEmpty == false
        let coversPaperOrderEvents = (replaySummary?.coversPaperOrderEvents ?? false)
            || localLifecyclePaperOrderIDs.isEmpty == false
            || simulatedFillPaperOrderIDs.isEmpty == false
        let coversSimulatedFillEvents = (replaySummary?.coversSimulatedFillEvents ?? false)
            || simulatedFillEvents.isEmpty == false
        let coversDecisionOrderFillChain = coversDecisionEvents
            && coversPaperOrderEvents
            && coversSimulatedFillEvents
            && decisionIDs.isEmpty == false
            && paperOrderIDs.isEmpty == false
            && simulatedFillIDs.isEmpty == false
        let workflowEnvelopeBoundaryHeld = localLifecycleTransitions.allSatisfy(\.paperOnlyBoundaryHeld)
            && simulatedFillEvents.allSatisfy(\.paperOnlyBoundaryHeld)
            && accountPortfolioSnapshots.allSatisfy(\.paperOnlyBoundaryHeld)

        self.factsSource = replaySummary?.factsSource ?? "no matching append-only paper execution workflow facts"
        self.replayAvailable = replaySummary != nil
        self.workflowSequences = paperExecutionEnvelopes
            .map(\.sequence)
            .uniqueSorted()
        self.workflowStreams = paperExecutionEnvelopes
            .map(\.stream.rawValue)
            .uniqueSorted()
        self.localLifecycleTransitionIDs = localLifecycleTransitions
            .map(\.transitionID.rawValue)
            .uniqueSorted()
        self.decisionIDs = decisionIDs
        self.paperOrderIDs = paperOrderIDs
        self.simulatedFillIDs = simulatedFillIDs.uniqueSorted()
        self.paperAccountPortfolioSnapshotIDs = accountPortfolioSnapshots
            .map(\.snapshotID.rawValue)
            .uniqueSorted()
        self.portfolioUpdateIDs = portfolioUpdateIDs.uniqueSorted()
        self.portfolioIDs = (replaySummary?.portfolioIDs.map(\.rawValue) ?? []).uniqueSorted()
        self.simulatedFillGrossNotional = simulatedFillEvents.reduce(0) {
            $0 + $1.grossNotional
        }
        self.simulatedFillFeeAmount = simulatedFillEvents.reduce(0) {
            $0 + $1.costEstimate.feeAmount
        }
        self.simulatedFillSlippageAmount = simulatedFillEvents.reduce(0) {
            $0 + $1.costEstimate.slippageAmount
        }
        self.simulatedFillCostImpactAmount = simulatedFillEvents.reduce(0) {
            $0 + $1.costImpactAmount
        }
        self.coversLocalLifecycleEvents = localLifecycleTransitions.isEmpty == false
        self.coversDecisionEvents = coversDecisionEvents
        self.coversPaperOrderEvents = coversPaperOrderEvents
        self.coversSimulatedFillEvents = coversSimulatedFillEvents
        self.coversDecisionOrderFillChain = coversDecisionOrderFillChain
        self.projectsPortfolioFromSimulatedFill = (
            coversDecisionOrderFillChain
                && (replaySummary?.coversPortfolioProjectionEvents ?? false)
                && portfolioUpdateIDs.isEmpty == false
        ) || (simulatedFillEvents.isEmpty == false && accountPortfolioSnapshots.isEmpty == false)
        self.appendOnlyFactsSourceIsReplaySource = replaySummary?.appendOnlyFactsSourceIsReplaySource ?? false
        self.replayResultIsDeterministic = replaySummary?.replayResultIsDeterministic ?? false
        self.paperOnlyBoundaryHeld = (replaySummary?.paperOnlyBoundaryHeld ?? true)
            && workflowEnvelopeBoundaryHeld
        self.authorizesLiveTrading = replaySummary?.authorizesLiveTrading ?? false
        self.touchesBrokerAction = replaySummary?.touchesBrokerAction ?? false
        self.authorizesTradingExecution = false
    }

    public var hasEvidence: Bool {
        decisionIDs.isEmpty == false
            || localLifecycleTransitionIDs.isEmpty == false
            || paperOrderIDs.isEmpty == false
            || simulatedFillIDs.isEmpty == false
            || paperAccountPortfolioSnapshotIDs.isEmpty == false
            || portfolioUpdateIDs.isEmpty == false
    }

    public var workflowSequenceCount: Int {
        workflowSequences.count
    }

    private static func isPaperExecutionWorkflowEnvelope(_ envelope: EventEnvelope) -> Bool {
        switch envelope.event {
        case .paper(.executionDecisionRecorded),
             .paper(.orderIntentRecorded),
             .paper(.orderLocalLifecycleTransitionRecorded),
             .paper(.simulatedFillRecorded),
             .portfolio(.paperProjectionUpdated),
             .portfolio(.paperAccountPortfolioProjectionUpdated):
            return true
        default:
            return false
        }
    }

    private static func localLifecycleTransition(
        _ envelope: EventEnvelope
    ) -> PaperOrderLocalLifecycleTransition? {
        if case let .paper(.orderLocalLifecycleTransitionRecorded(transition)) = envelope.event {
            return transition
        }
        return nil
    }

    private static func simulatedFill(_ envelope: EventEnvelope) -> PaperSimulatedFillEvidence? {
        if case let .paper(.simulatedFillRecorded(fill)) = envelope.event {
            return fill
        }
        return nil
    }

    private static func accountPortfolioSnapshot(
        _ envelope: EventEnvelope
    ) -> PaperAccountPortfolioProjectionV2Snapshot? {
        if case let .portfolio(.paperAccountPortfolioProjectionUpdated(snapshot)) = envelope.event {
            return snapshot
        }
        return nil
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
    public let paperRuntimeEvidence: PaperSessionRuntimeEvidenceSummary
    public let paperExecutionWorkflowEvidence: PaperExecutionWorkflowEvidenceSummary
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
        paperRuntimeEvidence: PaperSessionRuntimeEvidenceSummary,
        paperExecutionWorkflowEvidence: PaperExecutionWorkflowEvidenceSummary,
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
        self.paperRuntimeEvidence = paperRuntimeEvidence
        self.paperExecutionWorkflowEvidence = paperExecutionWorkflowEvidence
        self.executionAuthorization = executionAuthorization
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var authorizesTradingExecution: Bool {
        false
    }
}

/// ReportReadModel 从现有 projection snapshots 生成 Research -> Backtest -> Report 最小观察面。
///
/// 它把订单簿研究投影、EMA 回测投影、Paper session 投影、事件流水、Live blocked evidence、
/// Live monitoring evidence、Scenario replay evidence、Live Risk blocked evidence 和 incident / stop blocked evidence 汇总成报告 artifact / boundary evidence；
/// 该 read model 不重跑策略、不读取数据库 schema、不调用 Runtime / Adapters，也不把报告、
/// scenario replay、Live readiness blocked 状态、monitoring 状态、risk blocked evidence 或 incident / stop evidence 解释为交易授权。
public struct ReportReadModel: Equatable, Sendable {
    public let artifacts: [ResearchBacktestReportArtifact]
    public let marketDataReplayOperations: MarketDataReplayOperationsEvidenceReadModel
    public let scenarioReplayEvidence: ScenarioReplayEvidenceReadModel
    public let liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel
    public let liveMonitoringEvidence: LiveMonitoringEvidenceReadModel
    public let liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel
    public let liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel
    public let liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel
    public let lastAppliedSequence: Int?

    public init(
        artifacts: [ResearchBacktestReportArtifact] = [],
        marketDataReplayOperations: MarketDataReplayOperationsEvidenceReadModel = MarketDataReplayOperationsEvidenceReadModel(),
        scenarioReplayEvidence: ScenarioReplayEvidenceReadModel = ScenarioReplayEvidenceReadModel(),
        liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel = LiveTradingBlockedEvidenceReadModel(),
        liveMonitoringEvidence: LiveMonitoringEvidenceReadModel = LiveMonitoringEvidenceReadModel(),
        liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel = LiveExecutionControlBlockedEvidenceReadModel(),
        liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel = LiveRiskGateBlockedEvidenceReadModel(),
        liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel = LiveIncidentStopBlockedEvidenceReadModel(),
        lastAppliedSequence: Int? = nil
    ) {
        self.artifacts = artifacts.sorted { left, right in
            left.reportID < right.reportID
        }
        self.marketDataReplayOperations = marketDataReplayOperations
        self.scenarioReplayEvidence = scenarioReplayEvidence
        self.liveTradingBlockedEvidence = liveTradingBlockedEvidence
        self.liveMonitoringEvidence = liveMonitoringEvidence
        self.liveExecutionControlBlockedEvidence = liveExecutionControlBlockedEvidence
        self.liveRiskGateBlockedEvidence = liveRiskGateBlockedEvidence
        self.liveIncidentStopBlockedEvidence = liveIncidentStopBlockedEvidence
        self.lastAppliedSequence = Self.maxSequence(
            lastAppliedSequence,
            marketDataReplayOperations.lastAppliedSequence,
            scenarioReplayEvidence.lastAppliedSequence,
            liveTradingBlockedEvidence.lastAppliedSequence,
            liveMonitoringEvidence.lastAppliedSequence,
            liveExecutionControlBlockedEvidence.lastAppliedSequence,
            liveRiskGateBlockedEvidence.lastAppliedSequence,
            liveIncidentStopBlockedEvidence.lastAppliedSequence
        )
    }

    public init(
        analyticalProjection: DuckDBAnalyticalProjectionSnapshot,
        runtimeProjection: SQLiteRuntimeProjectionSnapshot,
        eventTimeline: [EventEnvelope],
        marketDataReplayOperations: MarketDataReplayOperationsEvidenceReadModel = MarketDataReplayOperationsEvidenceReadModel(),
        scenarioReplayEvidence: ScenarioReplayEvidenceReadModel = ScenarioReplayEvidenceReadModel(),
        liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel = LiveTradingBlockedEvidenceReadModel(),
        liveMonitoringEvidence: LiveMonitoringEvidenceReadModel = LiveMonitoringEvidenceReadModel(),
        liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel = LiveExecutionControlBlockedEvidenceReadModel(),
        liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel = LiveRiskGateBlockedEvidenceReadModel(),
        liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel = LiveIncidentStopBlockedEvidenceReadModel()
    ) {
        let sortedBacktests = analyticalProjection.backtestRuns.values.sorted {
            $0.runID.rawValue < $1.runID.rawValue
        }
        let researchRuns = Array(analyticalProjection.orderBookResearchRuns.values)
        let paperSessions = Array(runtimeProjection.paperSessions.values)
        let riskBlockerEvidence = runtimeProjection.riskBlockerEvidence
        let portfolioProjections = Array(runtimeProjection.portfolioProjections.values)
        let portfolioExposures = portfolioProjections.flatMap(\.exposures)
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
                portfolioProjections: portfolioProjections,
                eventTimeline: eventTimeline,
                lastAppliedSequence: lastAppliedSequence
            )
        }

        self.init(
            artifacts: artifacts,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence,
            liveTradingBlockedEvidence: liveTradingBlockedEvidence,
            liveMonitoringEvidence: liveMonitoringEvidence,
            liveExecutionControlBlockedEvidence: liveExecutionControlBlockedEvidence,
            liveRiskGateBlockedEvidence: liveRiskGateBlockedEvidence,
            liveIncidentStopBlockedEvidence: liveIncidentStopBlockedEvidence,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func makeArtifact(
        backtest: DuckDBBacktestProjection,
        researchRuns: [DuckDBOrderBookResearchProjection],
        signalTimeline: [DuckDBSignalTimelineProjection],
        paperSessions: [SQLitePaperSessionProjection],
        riskBlockerEvidence: [SQLiteRiskBlockerEvidenceProjection],
        portfolioExposures: [SQLitePortfolioExposureProjection],
        portfolioProjections: [SQLitePortfolioProjection],
        eventTimeline: [EventEnvelope],
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
        let matchingPortfolioProjections = portfolioProjections.filter { projection in
            projection.exposures.contains {
                $0.symbol == backtest.symbol && $0.timeframe == backtest.timeframe
            }
        }
        let matchingPaperAccounts = matchingPortfolioProjections.compactMap(\.paperAccount)
        let matchingPaperPositions = matchingPortfolioProjections
            .flatMap(\.paperPositions)
            .filter { $0.symbol == backtest.symbol && $0.timeframe == backtest.timeframe }
        let matchingPaperPnLSummaries = matchingPortfolioProjections.compactMap(\.paperPnLSummary)
        let parityEvidenceStatus = parityStatus(backtest: backtest, paperSessions: matchingPaperSessions)
        let executionCostEvidence = makeExecutionCostEvidence(from: matchingPortfolioExposures)
        let matchingReplayEnvelopes = matchingPaperRuntimeEnvelopes(
            backtest: backtest,
            eventTimeline: eventTimeline
        )
        let replaySummary = makePaperRuntimeReplaySummary(from: matchingReplayEnvelopes)
        let paperRuntimeEvidence = PaperSessionRuntimeEvidenceSummary(
            replaySummary: replaySummary,
            paperSessions: matchingPaperSessions,
            riskBlockerEvidence: matchingRiskBlockers,
            portfolioExposures: matchingPortfolioExposures
        )
        let paperExecutionWorkflowEvidence = PaperExecutionWorkflowEvidenceSummary(
            replaySummary: replaySummary,
            workflowEnvelopes: matchingReplayEnvelopes
        )

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
            eventCount: eventTimeline.count,
            parityStatus: parityEvidenceStatus,
            tradingValidationEvidence: TradingValidationEvidenceSummary(
                parityStatus: parityEvidenceStatus,
                executionCostEvidence: executionCostEvidence,
                riskBlockerEvidence: matchingRiskBlockers,
                portfolioExposures: matchingPortfolioExposures,
                paperAccounts: matchingPaperAccounts,
                paperPositions: matchingPaperPositions,
                paperPnLSummaries: matchingPaperPnLSummaries
            ),
            paperRuntimeEvidence: paperRuntimeEvidence,
            paperExecutionWorkflowEvidence: paperExecutionWorkflowEvidence,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func matchingPaperRuntimeEnvelopes(
        backtest: DuckDBBacktestProjection,
        eventTimeline: [EventEnvelope]
    ) -> [EventEnvelope] {
        eventTimeline
            .filter {
                matchesPaperRuntimeEvidence(
                    envelope: $0,
                    symbol: backtest.symbol,
                    timeframe: backtest.timeframe
                )
            }
            .sorted { $0.sequence < $1.sequence }
    }

    private static func makePaperRuntimeReplaySummary(
        from envelopes: [EventEnvelope]
    ) -> PaperSessionReplayEvidenceSummary? {
        guard
            let lowerBound = envelopes.map(\.sequence).min(),
            let upperBound = envelopes.map(\.sequence).max()
        else {
            return nil
        }

        let command: EventReplayCommand
        do {
            command = EventReplayCommand(
                range: try EventSequenceRange(
                    lowerBound: lowerBound,
                    upperBound: upperBound
                ),
                streams: Set(envelopes.map(\.stream))
            )
        } catch {
            return nil
        }

        return try? PaperSessionReplayPath.summarize(
            EventReplayResult(command: command, envelopes: envelopes)
        )
    }

    private static func matchesPaperRuntimeEvidence(
        envelope: EventEnvelope,
        symbol: Symbol,
        timeframe: Timeframe
    ) -> Bool {
        switch envelope.event {
        case let .paper(event):
            return matchesPaperEvent(event, symbol: symbol, timeframe: timeframe)
        case let .risk(event):
            return matchesRiskEvent(event, symbol: symbol, timeframe: timeframe)
        case let .portfolio(event):
            return matchesPortfolioEvent(event, symbol: symbol, timeframe: timeframe)
        default:
            return false
        }
    }

    private static func matchesPaperEvent(
        _ event: PaperEvent,
        symbol: Symbol,
        timeframe: Timeframe
    ) -> Bool {
        switch event {
        case let .sessionStarted(started):
            return started.command.strategy.symbol == symbol
                && started.command.strategy.timeframe == timeframe
        case let .sessionUpdated(updated):
            return updated.command.strategy.symbol == symbol
                && updated.command.strategy.timeframe == timeframe
        case let .sessionClosed(closed):
            return closed.result.command.strategy.symbol == symbol
                && closed.result.command.strategy.timeframe == timeframe
        case let .actionProposed(proposal):
            return proposal.symbol == symbol && proposal.timeframe == timeframe
        case let .executionDecisionRecorded(decision):
            return decision.riskDecision.proposal.symbol == symbol
                && decision.riskDecision.proposal.timeframe == timeframe
        case let .orderIntentRecorded(orderIntent):
            return orderIntent.symbol == symbol && orderIntent.timeframe == timeframe
        case let .orderLocalLifecycleTransitionRecorded(transition):
            // MTP-99 本地 order lifecycle transition 可作为 paper runtime evidence 被匹配，
            // 但 App 层仍只消费 read model，不读取 coordinator、Runtime object 或 persistence schema。
            return transition.symbol == symbol && transition.timeframe == timeframe
        case let .simulatedFillRecorded(fill):
            return fill.symbol == symbol && fill.timeframe == timeframe
        case .sessionControlApplied, .sessionControlRejected:
            // MTP-49 的 session control facts 只记录本地控制壳 evidence，不携带 symbol/timeframe，
            // 当前 App read model 不消费这些 facts，避免提前实现 Event Timeline / Evidence Explorer。
            return false
        case let .sessionRequested(command):
            return command.strategy.symbol == symbol && command.strategy.timeframe == timeframe
        case let .signalGenerated(sample):
            return sample.signal.symbol == symbol && sample.signal.timeframe == timeframe
        case let .sessionCompleted(result):
            return result.command.strategy.symbol == symbol
                && result.command.strategy.timeframe == timeframe
        }
    }

    private static func matchesRiskEvent(
        _ event: RiskEvent,
        symbol: Symbol,
        timeframe: Timeframe
    ) -> Bool {
        switch event {
        case let .evaluationRequested(query):
            return query.symbol == symbol && query.timeframe == timeframe
        case let .blocked(evidence):
            return evidence.symbol == symbol && evidence.timeframe == timeframe
        }
    }

    private static func matchesPortfolioEvent(
        _ event: PortfolioEvent,
        symbol: Symbol,
        timeframe: Timeframe
    ) -> Bool {
        switch event {
        case .projectionRequested:
            return false
        case let .paperProjectionUpdated(update):
            return update.exposure.symbol == symbol && update.exposure.timeframe == timeframe
        case let .paperAccountPortfolioProjectionUpdated(snapshot):
            return snapshot.exposures.contains {
                $0.symbol == symbol && $0.timeframe == timeframe
            }
        case let .exposureUpdated(exposure):
            return exposure.symbol == symbol && exposure.timeframe == timeframe
        }
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
/// 输入来自 Persistence projection snapshots、append-only event timeline 和 Core Live readiness
/// blocked read model；新增 Report / Event Timeline evidence 也遵循同一来源边界，禁止 UI
/// 直接读取数据库 schema、Runtime object、行情 adapter、真实 Live trading capability 或真实
/// Live Risk / incident stop runtime。
public struct DashboardReadModel: Equatable, Sendable {
    public let market: MarketReadModel
    public let strategy: StrategyReadModel
    public let backtest: BacktestReadModel
    public let report: ReportReadModel
    public let paperWorkflowObservability: PaperWorkflowObservabilityReadModel
    public let paperWorkflowEvidenceExplorer: PaperWorkflowEvidenceExplorerReadModel
    public let paper: PaperReadModel
    public let risk: RiskReadModel
    public let portfolio: PortfolioReadModel
    public let events: EventTimelineReadModel

    public init(
        market: MarketReadModel,
        strategy: StrategyReadModel,
        backtest: BacktestReadModel,
        report: ReportReadModel,
        paperWorkflowObservability: PaperWorkflowObservabilityReadModel = PaperWorkflowObservabilityReadModel(),
        paperWorkflowEvidenceExplorer: PaperWorkflowEvidenceExplorerReadModel? = nil,
        paper: PaperReadModel,
        risk: RiskReadModel,
        portfolio: PortfolioReadModel,
        events: EventTimelineReadModel
    ) {
        self.market = market
        self.strategy = strategy
        self.backtest = backtest
        self.report = report
        self.paperWorkflowObservability = paperWorkflowObservability
        self.paperWorkflowEvidenceExplorer = paperWorkflowEvidenceExplorer ?? PaperWorkflowEvidenceExplorerReadModel(
            market: market,
            strategy: strategy,
            report: report,
            scenarioReplayEvidence: report.scenarioReplayEvidence,
            liveTradingBlockedEvidence: report.liveTradingBlockedEvidence,
            liveMonitoringEvidence: report.liveMonitoringEvidence,
            liveExecutionControlBlockedEvidence: report.liveExecutionControlBlockedEvidence,
            liveRiskGateBlockedEvidence: report.liveRiskGateBlockedEvidence,
            liveIncidentStopBlockedEvidence: report.liveIncidentStopBlockedEvidence,
            paperWorkflowObservability: paperWorkflowObservability,
            events: events
        )
        self.paper = paper
        self.risk = risk
        self.portfolio = portfolio
        self.events = events
    }

    public init(
        runtimeProjection: SQLiteRuntimeProjectionSnapshot,
        analyticalProjection: DuckDBAnalyticalProjectionSnapshot,
        eventTimeline: [EventEnvelope],
        marketDataReplayOperations: MarketDataReplayOperationsEvidenceReadModel = MarketDataReplayOperationsEvidenceReadModel(),
        scenarioReplayEvidence: ScenarioReplayEvidenceReadModel = ScenarioReplayEvidenceReadModel(),
        liveTradingBlockedEvidence: LiveTradingBlockedEvidenceReadModel = LiveTradingBlockedEvidenceReadModel(),
        liveMonitoringEvidence: LiveMonitoringEvidenceReadModel = LiveMonitoringEvidenceReadModel(),
        liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceReadModel = LiveExecutionControlBlockedEvidenceReadModel(),
        liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceReadModel = LiveRiskGateBlockedEvidenceReadModel(),
        liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceReadModel = LiveIncidentStopBlockedEvidenceReadModel()
    ) {
        let report = ReportReadModel(
            analyticalProjection: analyticalProjection,
            runtimeProjection: runtimeProjection,
            eventTimeline: eventTimeline,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence,
            liveTradingBlockedEvidence: liveTradingBlockedEvidence,
            liveMonitoringEvidence: liveMonitoringEvidence,
            liveExecutionControlBlockedEvidence: liveExecutionControlBlockedEvidence,
            liveRiskGateBlockedEvidence: liveRiskGateBlockedEvidence,
            liveIncidentStopBlockedEvidence: liveIncidentStopBlockedEvidence
        )
        let paper = PaperReadModel(runtimeProjection: runtimeProjection)
        let risk = RiskReadModel(runtimeProjection: runtimeProjection)
        let portfolio = PortfolioReadModel(runtimeProjection: runtimeProjection)
        let events = EventTimelineReadModel(envelopes: eventTimeline)
        let market = MarketReadModel(analyticalProjection: analyticalProjection)
        let strategy = StrategyReadModel(analyticalProjection: analyticalProjection)
        let backtest = BacktestReadModel(analyticalProjection: analyticalProjection)
        let paperWorkflowObservability = PaperWorkflowObservabilityReadModel(
            report: report,
            paper: paper,
            risk: risk,
            portfolio: portfolio,
            events: events
        )
        self.init(
            market: market,
            strategy: strategy,
            backtest: backtest,
            report: report,
            paperWorkflowObservability: paperWorkflowObservability,
            paperWorkflowEvidenceExplorer: PaperWorkflowEvidenceExplorerReadModel(
                market: market,
                strategy: strategy,
                report: report,
                scenarioReplayEvidence: report.scenarioReplayEvidence,
                liveTradingBlockedEvidence: report.liveTradingBlockedEvidence,
                liveMonitoringEvidence: report.liveMonitoringEvidence,
                liveExecutionControlBlockedEvidence: report.liveExecutionControlBlockedEvidence,
                liveRiskGateBlockedEvidence: report.liveRiskGateBlockedEvidence,
                liveIncidentStopBlockedEvidence: report.liveIncidentStopBlockedEvidence,
                paperWorkflowObservability: paperWorkflowObservability,
                events: events
            ),
            paper: paper,
            risk: risk,
            portfolio: portfolio,
            events: events
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
    public let paperRuntimeEvidence: PaperSessionRuntimeEvidenceSummary
    public let paperExecutionWorkflowEvidence: PaperExecutionWorkflowEvidenceSummary
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
        self.paperRuntimeEvidence = artifact.paperRuntimeEvidence
        self.paperExecutionWorkflowEvidence = artifact.paperExecutionWorkflowEvidence
        self.executionAuthorization = artifact.executionAuthorization
        self.authorizesTradingExecution = artifact.authorizesTradingExecution
        self.lastAppliedSequence = artifact.lastAppliedSequence
    }
}

/// ReportViewModel 汇总 MTP-23 最小报告路径的只读指标。
///
/// 指标来自 `ReportReadModel`，用于展示报告数、研究运行数、投影级 parity evidence 和
/// scenario replay evidence、Live trading foundation blocked gates、Live monitoring evidence、Live Risk blocked evidence 和
/// incident / stop blocked evidence；
/// 该 ViewModel 不调用 Runtime / Adapters，不暴露数据库实现细节，也不提供 live command、
/// risk command、stop command、交易按钮或真实交易控制。
public struct ReportViewModel: Codable, Equatable, Sendable {
    public let section: DashboardSection
    public let source: ViewModelSourceContract
    public let artifacts: [ReportArtifactViewModel]
    public let marketDataReplayOperations: MarketDataReplayOperationsEvidenceViewModel
    public let scenarioReplayEvidence: ScenarioReplayEvidenceViewModel
    public let liveTradingBlockedEvidence: LiveTradingBlockedEvidenceViewModel
    public let liveMonitoringEvidence: LiveMonitoringEvidenceViewModel
    public let liveExecutionControlBlockedEvidence: LiveExecutionControlBlockedEvidenceViewModel
    public let liveRiskGateBlockedEvidence: LiveRiskGateBlockedEvidenceViewModel
    public let liveIncidentStopBlockedEvidence: LiveIncidentStopBlockedEvidenceViewModel
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
    public let paperAccountIDs: [String]
    public let paperPositionCount: Int
    public let paperNetPnL: Double
    public let paperRuntimeEvidenceCount: Int
    public let paperRuntimeSessionIDs: [String]
    public let paperRuntimeLifecycleStates: [String]
    public let paperRuntimeProposalIDs: [String]
    public let paperRuntimeRiskBlockerEvidenceIDs: [String]
    public let paperRuntimePortfolioUpdateIDs: [String]
    public let paperRuntimePortfolioIDs: [String]
    public let paperRuntimeReplaySequenceCount: Int
    public let paperRuntimeReplayStreams: [String]
    public let paperRuntimeCoversSessionEvents: Bool
    public let paperRuntimeCoversProposalEvents: Bool
    public let paperRuntimeCoversRiskBlockerEvents: Bool
    public let paperRuntimeCoversPortfolioProjectionEvents: Bool
    public let paperRuntimeReplayDeterministic: Bool
    public let paperRuntimePaperOnlyBoundaryHeld: Bool
    public let paperRuntimeAuthorizesLiveTrading: Bool
    public let paperRuntimeTouchesBrokerAction: Bool
    public let paperRuntimeAuthorizesTradingExecution: Bool
    public let paperExecutionWorkflowEvidenceCount: Int
    public let paperExecutionWorkflowLocalLifecycleTransitionIDs: [String]
    public let paperExecutionWorkflowDecisionIDs: [String]
    public let paperExecutionWorkflowOrderIDs: [String]
    public let paperExecutionWorkflowSimulatedFillIDs: [String]
    public let paperExecutionWorkflowAccountPortfolioSnapshotIDs: [String]
    public let paperExecutionWorkflowPortfolioUpdateIDs: [String]
    public let paperExecutionWorkflowPortfolioIDs: [String]
    public let paperExecutionWorkflowSimulatedFillGrossNotional: Double
    public let paperExecutionWorkflowSimulatedFillFeeAmount: Double
    public let paperExecutionWorkflowSimulatedFillSlippageAmount: Double
    public let paperExecutionWorkflowSimulatedFillCostImpactAmount: Double
    public let paperExecutionWorkflowSequenceCount: Int
    public let paperExecutionWorkflowStreams: [String]
    public let paperExecutionWorkflowCoversLocalLifecycleEvents: Bool
    public let paperExecutionWorkflowCoversDecisionEvents: Bool
    public let paperExecutionWorkflowCoversOrderEvents: Bool
    public let paperExecutionWorkflowCoversSimulatedFillEvents: Bool
    public let paperExecutionWorkflowCoversDecisionOrderFillChain: Bool
    public let paperExecutionWorkflowProjectsPortfolioFromSimulatedFill: Bool
    public let paperExecutionWorkflowReplayDeterministic: Bool
    public let paperExecutionWorkflowPaperOnlyBoundaryHeld: Bool
    public let paperExecutionWorkflowAuthorizesLiveTrading: Bool
    public let paperExecutionWorkflowTouchesBrokerAction: Bool
    public let paperExecutionWorkflowAuthorizesTradingExecution: Bool
    public let marketDataReplayEvidenceCount: Int
    public let marketDataReplayBatchIDs: [String]
    public let marketDataReplayRunIDs: [String]
    public let marketDataReplayFreshnessStatuses: [String]
    public let marketDataReplayRetentionStatuses: [MarketDataReplayOperationsRetentionStatus]
    public let marketDataReplayProjectionConsistencySummaries: [String]
    public let marketDataReplayEventLogRecordCount: Int
    public let marketDataReplayReplayedRecordCount: Int
    public let marketDataReplayProjectionConsistencyHeld: Bool
    public let marketDataReplayReadModelOnlyBoundaryHeld: Bool
    public let marketDataReplayAuthorizesTradingExecution: Bool
    public let scenarioReplayEvidenceCount: Int
    public let scenarioReplayScenarioIDs: [String]
    public let scenarioReplayDatasetVersions: [String]
    public let scenarioReplayFixtureVersions: [String]
    public let scenarioReplaySymbols: [String]
    public let scenarioReplayTimeframes: [String]
    public let scenarioReplayWindows: [String]
    public let scenarioReplayChecksums: [String]
    public let scenarioReplayFreshnessStatuses: [ScenarioReplayFreshnessStatus]
    public let scenarioReplayQualityVerdicts: [ScenarioDataQualityVerdict]
    public let scenarioReplayReportInputVersionIdentities: [String]
    public let scenarioReplayDrillDownEntries: [String]
    public let scenarioReplayTimelineEntryCount: Int
    public let scenarioReplayQualityGateTimelineCount: Int
    public let scenarioReplayAllQualityAccepted: Bool
    public let scenarioReplayReportReproducibilityEvidenceHeld: Bool
    public let scenarioReplayReadModelOnlyBoundaryHeld: Bool
    public let scenarioReplayExposesDatabaseSchema: Bool
    public let scenarioReplayExposesRuntimeObject: Bool
    public let scenarioReplayExposesAdapterRequest: Bool
    public let scenarioReplayProvidesCommandSurface: Bool
    public let scenarioReplayProvidesOrderLevelCommand: Bool
    public let scenarioReplaySupportsQueryLanguage: Bool
    public let scenarioReplayProvidesLiveCommand: Bool
    public let scenarioReplayProvidesTradingButton: Bool
    public let scenarioReplayAuthorizesLiveTrading: Bool
    public let scenarioReplayTouchesBrokerAction: Bool
    public let scenarioReplayAuthorizesTradingExecution: Bool
    public let scenarioReplayRequiredValidationDependsOnNetwork: Bool
    public let liveBlockedEvidenceCount: Int
    public let liveBlockedCapabilityLabels: [String]
    public let liveBlockedGateLabels: [String]
    public let liveBlockedSourceAnchors: [String]
    public let liveReadinessStatus: LiveReadinessStatus
    public let liveReadinessAllGatesBlocked: Bool
    public let liveReadinessReadModelOnlyBoundaryHeld: Bool
    public let liveReadinessProvidesCommandSurface: Bool
    public let liveReadinessAuthorizesLiveTrading: Bool
    public let liveReadinessTouchesBrokerAction: Bool
    public let liveReadinessAuthorizesTradingExecution: Bool
    public let liveReadinessExposesDatabaseSchema: Bool
    public let liveReadinessExposesRuntimeObject: Bool
    public let liveReadinessExposesAdapterSurface: Bool
    public let liveReadinessReadsAPIKey: Bool
    public let liveReadinessUsesSignedEndpoint: Bool
    public let liveReadinessCallsAccountEndpoint: Bool
    public let liveReadinessCreatesListenKey: Bool
    public let liveReadinessInstantiatesBrokerAdapter: Bool
    public let liveReadinessRepresentsRealOrderLifecycle: Bool
    public let liveMonitoringHealthStatus: LiveMonitoringStatus
    public let liveMonitoringConnectionCount: Int
    public let liveMonitoringConnectionStatusLabels: [String]
    public let liveMonitoringStreamEvidenceCount: Int
    public let liveMonitoringMarketStreamEvidenceCount: Int
    public let liveMonitoringOrderStreamEvidenceCount: Int
    public let liveMonitoringLatencyEvidenceCount: Int
    public let liveMonitoringLatencyBucketLabels: [String]
    public let liveMonitoringErrorEvidenceCount: Int
    public let liveMonitoringErrorCodes: [String]
    public let liveMonitoringDegradedStateEvidenceCount: Int
    public let liveMonitoringDegradedStateStatusLabels: [String]
    public let liveMonitoringReadModelOnlyBoundaryHeld: Bool
    public let liveMonitoringProvidesCommandSurface: Bool
    public let liveMonitoringProvidesOrderLevelCommand: Bool
    public let liveMonitoringProvidesTradingButton: Bool
    public let liveMonitoringProvidesRiskCommand: Bool
    public let liveMonitoringProvidesPositionCommand: Bool
    public let liveMonitoringExposesDatabaseSchema: Bool
    public let liveMonitoringExposesRuntimeObject: Bool
    public let liveMonitoringExposesAdapterSurface: Bool
    public let liveMonitoringOpensNetworkConnection: Bool
    public let liveMonitoringUsesProductionTelemetry: Bool
    public let liveMonitoringUsesExternalMetricsService: Bool
    public let liveMonitoringProvidesAlertingCommand: Bool
    public let liveMonitoringProvidesPagingCommand: Bool
    public let liveMonitoringProvidesReconnectCommand: Bool
    public let liveMonitoringProvidesStopControl: Bool
    public let liveMonitoringProvidesLiveRiskControl: Bool
    public let liveMonitoringTriggersIncidentCommand: Bool
    public let liveMonitoringTriggersAutoRecovery: Bool
    public let liveMonitoringReadsAPIKey: Bool
    public let liveMonitoringReadsSecret: Bool
    public let liveMonitoringCallsSignedEndpoint: Bool
    public let liveMonitoringCallsAccountEndpoint: Bool
    public let liveMonitoringCreatesListenKey: Bool
    public let liveMonitoringReadsAccountPayload: Bool
    public let liveMonitoringInstantiatesBrokerAdapter: Bool
    public let liveMonitoringImplementsRealOrderStateMachine: Bool
    public let liveMonitoringAuthorizesLiveTrading: Bool
    public let liveMonitoringAuthorizesTradingExecution: Bool
    public let liveMonitoringRequiredValidationDependsOnNetwork: Bool
    public let liveExecutionControlBlockedGateCount: Int
    public let liveExecutionControlBlockedGateLabels: [String]
    public let liveExecutionControlBlockedReasonLabels: [String]
    public let liveExecutionControlSourceAnchors: [String]
    public let liveExecutionControlDeterministicSnapshot: [String]
    public let liveExecutionControlAllGatesBlocked: Bool
    public let liveExecutionControlReadModelOnlyBoundaryHeld: Bool
    public let liveExecutionControlExposesPersistenceSchema: Bool
    public let liveExecutionControlReadsAdapter: Bool
    public let liveExecutionControlInvokesRuntimeControl: Bool
    public let liveExecutionControlProvidesCommandSurface: Bool
    public let liveExecutionControlProvidesOrderLevelCommand: Bool
    public let liveExecutionControlExposesOrderForm: Bool
    public let liveExecutionControlExposesOrderLevelCommandUI: Bool
    public let liveExecutionControlProvidesTradingButton: Bool
    public let liveExecutionControlAuthorizesLiveExecution: Bool
    public let liveExecutionControlAuthorizesTradingExecution: Bool
    public let liveExecutionControlReadsAPIKey: Bool
    public let liveExecutionControlUsesSignedEndpoint: Bool
    public let liveExecutionControlCallsAccountEndpoint: Bool
    public let liveExecutionControlCreatesListenKey: Bool
    public let liveExecutionControlInstantiatesBrokerExecutionAdapter: Bool
    public let liveExecutionControlInstantiatesExchangeExecutionAdapter: Bool
    public let liveExecutionControlImplementsLiveExecutionAdapter: Bool
    public let liveExecutionControlImplementsRealOrderStateMachine: Bool
    public let liveExecutionControlImplementsOMS: Bool
    public let liveExecutionControlSubmitsRealOrder: Bool
    public let liveExecutionControlCancelsRealOrder: Bool
    public let liveExecutionControlReplacesRealOrder: Bool
    public let liveExecutionControlConsumesExecutionReport: Bool
    public let liveExecutionControlRecordsBrokerFill: Bool
    public let liveExecutionControlPerformsReconciliation: Bool
    public let liveExecutionControlExecutesIncidentFallback: Bool
    public let liveExecutionControlRequiredValidationDependsOnNetwork: Bool
    public let tradingValidationAuthorizesExecution: Bool
    public let authorizesTradingExecution: Bool
    public let latestParityStatus: ReportParityStatus?
    public let lastAppliedSequence: Int?

    public init(readModel: ReportReadModel) {
        let tradingEvidence = readModel.artifacts.map(\.tradingValidationEvidence)
        let costEvidence = tradingEvidence.flatMap(\.executionCostEvidence)
        let runtimeEvidence = readModel.artifacts.map(\.paperRuntimeEvidence)
        let workflowEvidence = readModel.artifacts.map(\.paperExecutionWorkflowEvidence)
        let replayOperations = MarketDataReplayOperationsEvidenceViewModel(
            readModel: readModel.marketDataReplayOperations
        )
        let scenarioReplayEvidence = ScenarioReplayEvidenceViewModel(
            readModel: readModel.scenarioReplayEvidence
        )
        let liveBlockedEvidence = LiveTradingBlockedEvidenceViewModel(
            readModel: readModel.liveTradingBlockedEvidence
        )
        let liveMonitoringEvidence = LiveMonitoringEvidenceViewModel(
            readModel: readModel.liveMonitoringEvidence
        )
        let liveExecutionControlBlockedEvidence = LiveExecutionControlBlockedEvidenceViewModel(
            readModel: readModel.liveExecutionControlBlockedEvidence
        )
        let liveRiskGateBlockedEvidence = LiveRiskGateBlockedEvidenceViewModel(
            readModel: readModel.liveRiskGateBlockedEvidence
        )
        let liveIncidentStopBlockedEvidence = LiveIncidentStopBlockedEvidenceViewModel(
            readModel: readModel.liveIncidentStopBlockedEvidence
        )
        self.section = .report
        self.source = ViewModelSourceContract()
        self.artifacts = readModel.artifacts.map(ReportArtifactViewModel.init)
        self.marketDataReplayOperations = replayOperations
        self.scenarioReplayEvidence = scenarioReplayEvidence
        self.liveTradingBlockedEvidence = liveBlockedEvidence
        self.liveMonitoringEvidence = liveMonitoringEvidence
        self.liveExecutionControlBlockedEvidence = liveExecutionControlBlockedEvidence
        self.liveRiskGateBlockedEvidence = liveRiskGateBlockedEvidence
        self.liveIncidentStopBlockedEvidence = liveIncidentStopBlockedEvidence
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
        self.paperAccountIDs = tradingEvidence
            .flatMap(\.paperAccountIDs)
            .uniqueSorted()
        self.paperPositionCount = tradingEvidence.reduce(0) {
            $0 + $1.paperPositionCount
        }
        self.paperNetPnL = tradingEvidence.reduce(0) {
            $0 + $1.paperNetPnL
        }
        self.paperRuntimeEvidenceCount = runtimeEvidence.filter(\.hasEvidence).count
        self.paperRuntimeSessionIDs = runtimeEvidence
            .flatMap(\.sessionIDs)
            .uniqueSorted()
        self.paperRuntimeLifecycleStates = runtimeEvidence
            .flatMap(\.lifecycleStates)
            .map(\.rawValue)
            .uniquePreservingOrder()
        self.paperRuntimeProposalIDs = runtimeEvidence
            .flatMap(\.proposalIDs)
            .uniqueSorted()
        self.paperRuntimeRiskBlockerEvidenceIDs = runtimeEvidence
            .flatMap(\.riskBlockerEvidenceIDs)
            .uniqueSorted()
        self.paperRuntimePortfolioUpdateIDs = runtimeEvidence
            .flatMap(\.portfolioUpdateIDs)
            .uniqueSorted()
        self.paperRuntimePortfolioIDs = runtimeEvidence
            .flatMap(\.portfolioIDs)
            .uniqueSorted()
        self.paperRuntimeReplaySequenceCount = runtimeEvidence.reduce(0) {
            $0 + $1.replayedSequenceCount
        }
        self.paperRuntimeReplayStreams = runtimeEvidence
            .flatMap(\.replayedStreams)
            .uniqueSorted()
        self.paperRuntimeCoversSessionEvents = runtimeEvidence.contains {
            $0.coversSessionEvents
        }
        self.paperRuntimeCoversProposalEvents = runtimeEvidence.contains {
            $0.coversProposalEvents
        }
        self.paperRuntimeCoversRiskBlockerEvents = runtimeEvidence.contains {
            $0.coversRiskBlockerEvents
        }
        self.paperRuntimeCoversPortfolioProjectionEvents = runtimeEvidence.contains {
            $0.coversPortfolioProjectionEvents
        }
        self.paperRuntimeReplayDeterministic = runtimeEvidence.isEmpty
            || runtimeEvidence.allSatisfy(\.replayResultIsDeterministic)
        self.paperRuntimePaperOnlyBoundaryHeld = runtimeEvidence.isEmpty
            || runtimeEvidence.allSatisfy(\.paperOnlyBoundaryHeld)
        self.paperRuntimeAuthorizesLiveTrading = runtimeEvidence.contains {
            $0.authorizesLiveTrading
        }
        self.paperRuntimeTouchesBrokerAction = runtimeEvidence.contains {
            $0.touchesBrokerAction
        }
        self.paperRuntimeAuthorizesTradingExecution = runtimeEvidence.contains {
            $0.authorizesTradingExecution
        }
        self.paperExecutionWorkflowEvidenceCount = workflowEvidence.filter(\.hasEvidence).count
        self.paperExecutionWorkflowLocalLifecycleTransitionIDs = workflowEvidence
            .flatMap(\.localLifecycleTransitionIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowDecisionIDs = workflowEvidence
            .flatMap(\.decisionIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowOrderIDs = workflowEvidence
            .flatMap(\.paperOrderIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowSimulatedFillIDs = workflowEvidence
            .flatMap(\.simulatedFillIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowAccountPortfolioSnapshotIDs = workflowEvidence
            .flatMap(\.paperAccountPortfolioSnapshotIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowPortfolioUpdateIDs = workflowEvidence
            .flatMap(\.portfolioUpdateIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowPortfolioIDs = workflowEvidence
            .flatMap(\.portfolioIDs)
            .uniqueSorted()
        self.paperExecutionWorkflowSimulatedFillGrossNotional = workflowEvidence.reduce(0) {
            $0 + $1.simulatedFillGrossNotional
        }
        self.paperExecutionWorkflowSimulatedFillFeeAmount = workflowEvidence.reduce(0) {
            $0 + $1.simulatedFillFeeAmount
        }
        self.paperExecutionWorkflowSimulatedFillSlippageAmount = workflowEvidence.reduce(0) {
            $0 + $1.simulatedFillSlippageAmount
        }
        self.paperExecutionWorkflowSimulatedFillCostImpactAmount = workflowEvidence.reduce(0) {
            $0 + $1.simulatedFillCostImpactAmount
        }
        self.paperExecutionWorkflowSequenceCount = workflowEvidence.reduce(0) {
            $0 + $1.workflowSequenceCount
        }
        self.paperExecutionWorkflowStreams = workflowEvidence
            .flatMap(\.workflowStreams)
            .uniqueSorted()
        self.paperExecutionWorkflowCoversLocalLifecycleEvents = workflowEvidence.contains {
            $0.coversLocalLifecycleEvents
        }
        self.paperExecutionWorkflowCoversDecisionEvents = workflowEvidence.contains {
            $0.coversDecisionEvents
        }
        self.paperExecutionWorkflowCoversOrderEvents = workflowEvidence.contains {
            $0.coversPaperOrderEvents
        }
        self.paperExecutionWorkflowCoversSimulatedFillEvents = workflowEvidence.contains {
            $0.coversSimulatedFillEvents
        }
        self.paperExecutionWorkflowCoversDecisionOrderFillChain = workflowEvidence.contains {
            $0.coversDecisionOrderFillChain
        }
        self.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill = workflowEvidence.contains {
            $0.projectsPortfolioFromSimulatedFill
        }
        self.paperExecutionWorkflowReplayDeterministic = workflowEvidence.isEmpty
            || workflowEvidence.allSatisfy(\.replayResultIsDeterministic)
        self.paperExecutionWorkflowPaperOnlyBoundaryHeld = workflowEvidence.isEmpty
            || workflowEvidence.allSatisfy(\.paperOnlyBoundaryHeld)
        self.paperExecutionWorkflowAuthorizesLiveTrading = workflowEvidence.contains {
            $0.authorizesLiveTrading
        }
        self.paperExecutionWorkflowTouchesBrokerAction = workflowEvidence.contains {
            $0.touchesBrokerAction
        }
        self.paperExecutionWorkflowAuthorizesTradingExecution = workflowEvidence.contains {
            $0.authorizesTradingExecution
        }
        self.marketDataReplayEvidenceCount = replayOperations.evidenceCount
        self.marketDataReplayBatchIDs = replayOperations.batchIDs
        self.marketDataReplayRunIDs = replayOperations.replayRunIDs
        self.marketDataReplayFreshnessStatuses = replayOperations.freshnessStatuses
        self.marketDataReplayRetentionStatuses = replayOperations.retentionStatuses
        self.marketDataReplayProjectionConsistencySummaries = replayOperations
            .projectionConsistencySummaries
        self.marketDataReplayEventLogRecordCount = replayOperations.eventLogRecordCount
        self.marketDataReplayReplayedRecordCount = replayOperations.replayedRecordCount
        self.marketDataReplayProjectionConsistencyHeld = replayOperations
            .projectionSnapshotConsistencyHeld
        self.marketDataReplayReadModelOnlyBoundaryHeld = replayOperations
            .readModelOnlyBoundaryHeld
        self.marketDataReplayAuthorizesTradingExecution = replayOperations
            .authorizesTradingExecution
        self.scenarioReplayEvidenceCount = scenarioReplayEvidence.evidenceCount
        self.scenarioReplayScenarioIDs = scenarioReplayEvidence.scenarioIDs
        self.scenarioReplayDatasetVersions = scenarioReplayEvidence.datasetVersions
        self.scenarioReplayFixtureVersions = scenarioReplayEvidence.fixtureVersions
        self.scenarioReplaySymbols = scenarioReplayEvidence.symbols
        self.scenarioReplayTimeframes = scenarioReplayEvidence.timeframes
        self.scenarioReplayWindows = scenarioReplayEvidence.replayWindows
        self.scenarioReplayChecksums = scenarioReplayEvidence.checksums
        self.scenarioReplayFreshnessStatuses = scenarioReplayEvidence.freshnessStatuses
        self.scenarioReplayQualityVerdicts = scenarioReplayEvidence.qualityVerdicts
        self.scenarioReplayReportInputVersionIdentities = scenarioReplayEvidence
            .reportInputVersionIdentities
        self.scenarioReplayDrillDownEntries = scenarioReplayEvidence.drillDownEntries
        self.scenarioReplayTimelineEntryCount = scenarioReplayEvidence.timelineEntryCount
        self.scenarioReplayQualityGateTimelineCount = scenarioReplayEvidence
            .qualityGateTimelineCount
        self.scenarioReplayAllQualityAccepted = scenarioReplayEvidence.allQualityAccepted
        self.scenarioReplayReportReproducibilityEvidenceHeld = scenarioReplayEvidence
            .reportReproducibilityEvidenceHeld
        self.scenarioReplayReadModelOnlyBoundaryHeld = scenarioReplayEvidence
            .readModelOnlyBoundaryHeld
        self.scenarioReplayExposesDatabaseSchema = scenarioReplayEvidence.exposesDatabaseSchema
        self.scenarioReplayExposesRuntimeObject = scenarioReplayEvidence.exposesRuntimeObject
        self.scenarioReplayExposesAdapterRequest = scenarioReplayEvidence.exposesAdapterRequest
        self.scenarioReplayProvidesCommandSurface = scenarioReplayEvidence.providesCommandSurface
        self.scenarioReplayProvidesOrderLevelCommand = scenarioReplayEvidence.providesOrderLevelCommand
        self.scenarioReplaySupportsQueryLanguage = scenarioReplayEvidence.supportsQueryLanguage
        self.scenarioReplayProvidesLiveCommand = scenarioReplayEvidence.providesLiveCommand
        self.scenarioReplayProvidesTradingButton = scenarioReplayEvidence.providesTradingButton
        self.scenarioReplayAuthorizesLiveTrading = scenarioReplayEvidence.authorizesLiveTrading
        self.scenarioReplayTouchesBrokerAction = scenarioReplayEvidence.touchesBrokerAction
        self.scenarioReplayAuthorizesTradingExecution = scenarioReplayEvidence.authorizesTradingExecution
        self.scenarioReplayRequiredValidationDependsOnNetwork = scenarioReplayEvidence
            .requiredValidationDependsOnNetwork
        self.liveBlockedEvidenceCount = liveBlockedEvidence.blockedEvidenceCount
        self.liveBlockedCapabilityLabels = liveBlockedEvidence.blockedCapabilityLabels
        self.liveBlockedGateLabels = liveBlockedEvidence.blockedGateLabels
        self.liveBlockedSourceAnchors = liveBlockedEvidence.sourceAnchors
        self.liveReadinessStatus = liveBlockedEvidence.status
        self.liveReadinessAllGatesBlocked = liveBlockedEvidence.allLiveGatesBlocked
        self.liveReadinessReadModelOnlyBoundaryHeld = liveBlockedEvidence.readModelOnlyBoundaryHeld
        self.liveReadinessProvidesCommandSurface = liveBlockedEvidence.providesCommandSurface
        self.liveReadinessAuthorizesLiveTrading = liveBlockedEvidence.authorizesLiveTrading
        self.liveReadinessTouchesBrokerAction = liveBlockedEvidence.touchesBrokerAction
        self.liveReadinessAuthorizesTradingExecution = liveBlockedEvidence.authorizesTradingExecution
        self.liveReadinessExposesDatabaseSchema = liveBlockedEvidence.exposesDatabaseSchema
        self.liveReadinessExposesRuntimeObject = liveBlockedEvidence.exposesRuntimeObject
        self.liveReadinessExposesAdapterSurface = liveBlockedEvidence.exposesAdapterSurface
        self.liveReadinessReadsAPIKey = liveBlockedEvidence.readsAPIKey
        self.liveReadinessUsesSignedEndpoint = liveBlockedEvidence.usesSignedEndpoint
        self.liveReadinessCallsAccountEndpoint = liveBlockedEvidence.callsAccountEndpoint
        self.liveReadinessCreatesListenKey = liveBlockedEvidence.createsListenKey
        self.liveReadinessInstantiatesBrokerAdapter = liveBlockedEvidence.instantiatesBrokerAdapter
        self.liveReadinessRepresentsRealOrderLifecycle = liveBlockedEvidence.representsRealOrderLifecycle
        self.liveMonitoringHealthStatus = liveMonitoringEvidence.runtimeHealthStatus
        self.liveMonitoringConnectionCount = liveMonitoringEvidence.connectionCount
        self.liveMonitoringConnectionStatusLabels = liveMonitoringEvidence.connectionStatusLabels
        self.liveMonitoringStreamEvidenceCount = liveMonitoringEvidence.streamEvidenceCount
        self.liveMonitoringMarketStreamEvidenceCount = liveMonitoringEvidence.marketStreamEvidenceCount
        self.liveMonitoringOrderStreamEvidenceCount = liveMonitoringEvidence.orderStreamEvidenceCount
        self.liveMonitoringLatencyEvidenceCount = liveMonitoringEvidence.latencyEvidenceCount
        self.liveMonitoringLatencyBucketLabels = liveMonitoringEvidence.latencyBucketLabels
        self.liveMonitoringErrorEvidenceCount = liveMonitoringEvidence.errorEvidenceCount
        self.liveMonitoringErrorCodes = liveMonitoringEvidence.errorCodes
        self.liveMonitoringDegradedStateEvidenceCount = liveMonitoringEvidence.degradedStateEvidenceCount
        self.liveMonitoringDegradedStateStatusLabels = liveMonitoringEvidence
            .degradedStateStatusLabels
        self.liveMonitoringReadModelOnlyBoundaryHeld = liveMonitoringEvidence
            .readModelOnlyBoundaryHeld
        self.liveMonitoringProvidesCommandSurface = liveMonitoringEvidence.providesCommandSurface
        self.liveMonitoringProvidesOrderLevelCommand = liveMonitoringEvidence
            .providesOrderLevelCommand
        self.liveMonitoringProvidesTradingButton = liveMonitoringEvidence.providesTradingButton
        self.liveMonitoringProvidesRiskCommand = liveMonitoringEvidence.providesRiskCommand
        self.liveMonitoringProvidesPositionCommand = liveMonitoringEvidence.providesPositionCommand
        self.liveMonitoringExposesDatabaseSchema = liveMonitoringEvidence.exposesDatabaseSchema
        self.liveMonitoringExposesRuntimeObject = liveMonitoringEvidence.exposesRuntimeObject
        self.liveMonitoringExposesAdapterSurface = liveMonitoringEvidence.exposesAdapterSurface
        self.liveMonitoringOpensNetworkConnection = liveMonitoringEvidence.opensNetworkConnection
        self.liveMonitoringUsesProductionTelemetry = liveMonitoringEvidence.usesProductionTelemetry
        self.liveMonitoringUsesExternalMetricsService = liveMonitoringEvidence
            .usesExternalMetricsService
        self.liveMonitoringProvidesAlertingCommand = liveMonitoringEvidence.providesAlertingCommand
        self.liveMonitoringProvidesPagingCommand = liveMonitoringEvidence.providesPagingCommand
        self.liveMonitoringProvidesReconnectCommand = liveMonitoringEvidence.providesReconnectCommand
        self.liveMonitoringProvidesStopControl = liveMonitoringEvidence.providesStopControl
        self.liveMonitoringProvidesLiveRiskControl = liveMonitoringEvidence.providesLiveRiskControl
        self.liveMonitoringTriggersIncidentCommand = liveMonitoringEvidence.triggersIncidentCommand
        self.liveMonitoringTriggersAutoRecovery = liveMonitoringEvidence.triggersAutoRecovery
        self.liveMonitoringReadsAPIKey = liveMonitoringEvidence.readsAPIKey
        self.liveMonitoringReadsSecret = liveMonitoringEvidence.readsSecret
        self.liveMonitoringCallsSignedEndpoint = liveMonitoringEvidence.callsSignedEndpoint
        self.liveMonitoringCallsAccountEndpoint = liveMonitoringEvidence.callsAccountEndpoint
        self.liveMonitoringCreatesListenKey = liveMonitoringEvidence.createsListenKey
        self.liveMonitoringReadsAccountPayload = liveMonitoringEvidence.readsAccountPayload
        self.liveMonitoringInstantiatesBrokerAdapter = liveMonitoringEvidence
            .instantiatesBrokerAdapter
        self.liveMonitoringImplementsRealOrderStateMachine = liveMonitoringEvidence
            .implementsRealOrderStateMachine
        self.liveMonitoringAuthorizesLiveTrading = liveMonitoringEvidence.authorizesLiveTrading
        self.liveMonitoringAuthorizesTradingExecution = liveMonitoringEvidence
            .authorizesTradingExecution
        self.liveMonitoringRequiredValidationDependsOnNetwork = liveMonitoringEvidence
            .requiredValidationDependsOnNetwork
        self.liveExecutionControlBlockedGateCount = liveExecutionControlBlockedEvidence
            .blockedGateCount
        self.liveExecutionControlBlockedGateLabels = liveExecutionControlBlockedEvidence
            .blockedGateLabels
        self.liveExecutionControlBlockedReasonLabels = liveExecutionControlBlockedEvidence
            .blockedReasonLabels
        self.liveExecutionControlSourceAnchors = liveExecutionControlBlockedEvidence.sourceAnchors
        self.liveExecutionControlDeterministicSnapshot = liveExecutionControlBlockedEvidence
            .deterministicSnapshot
        self.liveExecutionControlAllGatesBlocked = liveExecutionControlBlockedEvidence
            .allExecutionControlGatesBlocked
        self.liveExecutionControlReadModelOnlyBoundaryHeld = liveExecutionControlBlockedEvidence
            .readModelOnlyBoundaryHeld
        self.liveExecutionControlExposesPersistenceSchema = liveExecutionControlBlockedEvidence
            .exposesPersistenceSchema
        self.liveExecutionControlReadsAdapter = liveExecutionControlBlockedEvidence.readsAdapter
        self.liveExecutionControlInvokesRuntimeControl = liveExecutionControlBlockedEvidence
            .invokesRuntimeControl
        self.liveExecutionControlProvidesCommandSurface = liveExecutionControlBlockedEvidence
            .providesCommandSurface
        self.liveExecutionControlProvidesOrderLevelCommand = liveExecutionControlBlockedEvidence
            .providesOrderLevelCommand
        self.liveExecutionControlExposesOrderForm = liveExecutionControlBlockedEvidence
            .exposesOrderForm
        self.liveExecutionControlExposesOrderLevelCommandUI = liveExecutionControlBlockedEvidence
            .exposesOrderLevelCommandUI
        self.liveExecutionControlProvidesTradingButton = liveExecutionControlBlockedEvidence
            .providesTradingButton
        self.liveExecutionControlAuthorizesLiveExecution = liveExecutionControlBlockedEvidence
            .authorizesLiveExecution
        self.liveExecutionControlAuthorizesTradingExecution = liveExecutionControlBlockedEvidence
            .authorizesTradingExecution
        self.liveExecutionControlReadsAPIKey = liveExecutionControlBlockedEvidence.readsAPIKey
        self.liveExecutionControlUsesSignedEndpoint = liveExecutionControlBlockedEvidence
            .usesSignedEndpoint
        self.liveExecutionControlCallsAccountEndpoint = liveExecutionControlBlockedEvidence
            .callsAccountEndpoint
        self.liveExecutionControlCreatesListenKey = liveExecutionControlBlockedEvidence
            .createsListenKey
        self.liveExecutionControlInstantiatesBrokerExecutionAdapter = liveExecutionControlBlockedEvidence
            .instantiatesBrokerExecutionAdapter
        self.liveExecutionControlInstantiatesExchangeExecutionAdapter = liveExecutionControlBlockedEvidence
            .instantiatesExchangeExecutionAdapter
        self.liveExecutionControlImplementsLiveExecutionAdapter = liveExecutionControlBlockedEvidence
            .implementsLiveExecutionAdapter
        self.liveExecutionControlImplementsRealOrderStateMachine = liveExecutionControlBlockedEvidence
            .implementsRealOrderStateMachine
        self.liveExecutionControlImplementsOMS = liveExecutionControlBlockedEvidence.implementsOMS
        self.liveExecutionControlSubmitsRealOrder = liveExecutionControlBlockedEvidence
            .submitsRealOrder
        self.liveExecutionControlCancelsRealOrder = liveExecutionControlBlockedEvidence
            .cancelsRealOrder
        self.liveExecutionControlReplacesRealOrder = liveExecutionControlBlockedEvidence
            .replacesRealOrder
        self.liveExecutionControlConsumesExecutionReport = liveExecutionControlBlockedEvidence
            .consumesExecutionReport
        self.liveExecutionControlRecordsBrokerFill = liveExecutionControlBlockedEvidence
            .recordsBrokerFill
        self.liveExecutionControlPerformsReconciliation = liveExecutionControlBlockedEvidence
            .performsReconciliation
        self.liveExecutionControlExecutesIncidentFallback = liveExecutionControlBlockedEvidence
            .executesIncidentFallback
        self.liveExecutionControlRequiredValidationDependsOnNetwork = liveExecutionControlBlockedEvidence
            .requiredValidationDependsOnNetwork
        self.tradingValidationAuthorizesExecution = tradingEvidence.contains {
            $0.authorizesTradingExecution
        }
        self.authorizesTradingExecution = readModel.artifacts.contains {
            $0.authorizesTradingExecution
        } || scenarioReplayEvidence.authorizesTradingExecution
            || liveBlockedEvidence.authorizesTradingExecution
            || liveMonitoringEvidence.authorizesTradingExecution
            || liveExecutionControlBlockedEvidence.authorizesTradingExecution
            || liveRiskGateBlockedEvidence.authorizesTradingExecution
            || liveIncidentStopBlockedEvidence.authorizesTradingExecution
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
    public let paperAccountIDs: [String]
    public let paperAvailableBalance: Double
    public let paperPositionCount: Int
    public let lastAppliedSequence: Int?

    public init(readModel: RiskReadModel) {
        let evidence = readModel.riskBlockerEvidence.map(RiskBlockerEvidenceViewModel.init)
        self.section = .risk
        self.source = ViewModelSourceContract()
        self.evidence = evidence
        self.rejectedPaperOrderIDs = readModel.rejectedPaperOrderIDs.map(\.rawValue)
        self.rejectionCount = evidence.count
        self.blockerReasons = evidence.map(\.reason)
        self.paperAccountIDs = readModel.paperAccounts.map(\.accountID.rawValue)
        self.paperAvailableBalance = readModel.paperAccounts.reduce(0) {
            $0 + $1.availablePaperBalance
        }
        self.paperPositionCount = readModel.paperPositions.count
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

public struct PaperAccountProjectionViewModel: Codable, Equatable, Sendable {
    public let accountID: String
    public let currency: String
    public let cashBalance: Double
    public let availablePaperBalance: Double
    public let equity: Double
    public let netPaperPnL: Double
    public let sourceSequences: [Int]

    public init(projection: SQLitePaperAccountProjection) {
        self.accountID = projection.accountID.rawValue
        self.currency = projection.currency
        self.cashBalance = projection.cashBalance
        self.availablePaperBalance = projection.availablePaperBalance
        self.equity = projection.equity
        self.netPaperPnL = projection.netPaperPnL
        self.sourceSequences = projection.sourceSequences
    }
}

public struct PaperPositionProjectionViewModel: Codable, Equatable, Sendable {
    public let positionID: String
    public let portfolioID: String
    public let symbol: String
    public let timeframe: String
    public let netQuantity: Double
    public let averageEntryPrice: Double
    public let lastFillPrice: Double
    public let marketValue: Double
    public let costBasisNotional: Double
    public let totalCostImpactAmount: Double
    public let unrealizedPaperPnL: Double
    public let sourceSequences: [Int]

    public init(projection: SQLitePaperPositionProjection) {
        self.positionID = projection.positionID.rawValue
        self.portfolioID = projection.portfolioID.rawValue
        self.symbol = projection.symbol.rawValue
        self.timeframe = projection.timeframe.rawValue
        self.netQuantity = projection.netQuantity.rawValue
        self.averageEntryPrice = projection.averageEntryPrice.rawValue
        self.lastFillPrice = projection.lastFillPrice.rawValue
        self.marketValue = projection.marketValue
        self.costBasisNotional = projection.costBasisNotional
        self.totalCostImpactAmount = projection.totalCostImpactAmount
        self.unrealizedPaperPnL = projection.unrealizedPaperPnL
        self.sourceSequences = projection.sourceSequences
    }
}

public struct PaperPortfolioPnLViewModel: Codable, Equatable, Sendable {
    public let grossExposureNotional: Double
    public let costBasisNotional: Double
    public let totalCostImpactAmount: Double
    public let unrealizedPaperPnL: Double
    public let netPaperPnL: Double
    public let sourceSequence: Int

    public init(projection: SQLitePaperPortfolioPnLProjection) {
        self.grossExposureNotional = projection.grossExposureNotional
        self.costBasisNotional = projection.costBasisNotional
        self.totalCostImpactAmount = projection.totalCostImpactAmount
        self.unrealizedPaperPnL = projection.unrealizedPaperPnL
        self.netPaperPnL = projection.netPaperPnL
        self.sourceSequence = projection.sourceSequence
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
    public let paperAccounts: [PaperAccountProjectionViewModel]
    public let paperPositions: [PaperPositionProjectionViewModel]
    public let paperPnLSummaries: [PaperPortfolioPnLViewModel]
    public let exposureCount: Int
    public let paperAccountCount: Int
    public let paperPositionCount: Int
    public let totalGrossExposureNotional: Double
    public let totalPaperEquity: Double
    public let totalNetPaperPnL: Double
    public let lastAppliedSequence: Int?

    public init(readModel: PortfolioReadModel) {
        let exposures = readModel.exposures.map(PortfolioExposureViewModel.init)
        let paperAccounts = readModel.paperAccounts.map(PaperAccountProjectionViewModel.init)
        let paperPositions = readModel.paperPositions.map(PaperPositionProjectionViewModel.init)
        let paperPnLSummaries = readModel.paperPnLSummaries.map(PaperPortfolioPnLViewModel.init)
        self.section = .portfolio
        self.source = ViewModelSourceContract()
        self.portfolioIDs = readModel.portfolios.map(\.portfolioID.rawValue)
        self.updatedPortfolioCount = readModel.portfolios.filter { $0.state == .updated }.count
        self.exposures = exposures
        self.paperAccounts = paperAccounts
        self.paperPositions = paperPositions
        self.paperPnLSummaries = paperPnLSummaries
        self.exposureCount = exposures.count
        self.paperAccountCount = paperAccounts.count
        self.paperPositionCount = paperPositions.count
        self.totalGrossExposureNotional = exposures.reduce(0) {
            $0 + $1.grossExposureNotional
        }
        self.totalPaperEquity = paperAccounts.reduce(0) {
            $0 + $1.equity
        }
        self.totalNetPaperPnL = paperPnLSummaries.reduce(0) {
            $0 + $1.netPaperPnL
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
    public let paperWorkflowObservability: PaperWorkflowObservabilityViewModel
    public let paperWorkflowEvidenceExplorer: PaperWorkflowEvidenceExplorerViewModel
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
        self.paperWorkflowObservability = PaperWorkflowObservabilityViewModel(
            readModel: readModel.paperWorkflowObservability
        )
        self.paperWorkflowEvidenceExplorer = PaperWorkflowEvidenceExplorerViewModel(
            readModel: readModel.paperWorkflowEvidenceExplorer
        )
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
            report.marketDataReplayOperations.source,
            report.scenarioReplayEvidence.source,
            report.liveTradingBlockedEvidence.source,
            report.liveMonitoringEvidence.source,
            report.liveExecutionControlBlockedEvidence.source,
            report.liveRiskGateBlockedEvidence.source,
            report.liveIncidentStopBlockedEvidence.source,
            paperWorkflowObservability.source,
            paperWorkflowEvidenceExplorer.source,
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

private extension Array where Element == SQLitePaperPositionProjection {
    func sortedByPaperPosition() -> [SQLitePaperPositionProjection] {
        sorted { lhs, rhs in
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

    func uniquePreservingOrder() -> [String] {
        var seen = Set<String>()
        var values: [String] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}

private extension Array where Element == Int {
    func uniqueSorted() -> [Int] {
        Array(Set(self)).sorted()
    }
}
