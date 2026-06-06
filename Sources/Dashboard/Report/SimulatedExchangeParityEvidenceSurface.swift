import Core
import Foundation

/// SimulatedExchangeParityEvidenceTimelineEntry 是 MTP-116 Report / Dashboard / Events 的只读 timeline 行。
///
/// Entry 只复制 MTP-112 至 MTP-115 已验证的 scenario、matching、execution、fill、cost 和
/// portfolio parity 摘要。它不保存 Runtime object、Persistence schema、adapter request、broker
/// payload，也不提供 live command、order-level command UI 或交易按钮。
public struct SimulatedExchangeParityEvidenceTimelineEntry: Codable, Equatable, Sendable {
    public let entryID: String
    public let kind: String
    public let title: String
    public let summary: String
    public let sourceAnchor: String

    public init(entryID: String, kind: String, title: String, summary: String, sourceAnchor: String) {
        self.entryID = entryID
        self.kind = kind
        self.title = title
        self.summary = summary
        self.sourceAnchor = sourceAnchor
    }
}

/// SimulatedExchangeParityEvidenceItem 是 MTP-116 的 App 层 parity evidence 行。
///
/// Item 从 Core 的 deterministic value objects 复制字段：scenario id、dataset / fixture version、
/// replay window、matching result、market / limit execution outcome、partial / full / reject / expire
/// evidence、latency、fee / slippage、portfolio parity、report input version 和 replay sequence。
/// App 层只做只读聚合，不执行撮合、不运行 portfolio runtime、不读取数据库 schema，也不接
/// signed endpoint、account endpoint、listenKey、broker、OMS 或任何真实订单能力。
public struct SimulatedExchangeParityEvidenceItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let scenarioID: String
    public let datasetVersion: String
    public let fixtureVersion: String
    public let symbol: String
    public let timeframe: String
    public let replayWindowDescription: String
    public let matchingResultIdentity: String
    public let matchingEventID: String
    public let matchingResult: String
    public let matchedPrice: Double
    public let matchedQuantity: Double
    public let orderID: String
    public let orderType: String
    public let partialFillState: String
    public let fullFillState: String
    public let rejectedState: String
    public let expiredState: String
    public let outcomeLabels: [String]
    public let latencyMilliseconds: Double
    public let latencyRecordRange: String
    public let feeAmount: Double
    public let slippageAmount: Double
    public let totalCostImpactAmount: Double
    public let costAssumptionID: String
    public let costParityConsistent: Bool
    public let backtestProjectionID: String
    public let paperProjectionID: String
    public let reportInputVersionIdentity: String
    public let sourceReplaySequence: Int
    public let deterministicResultIdentity: String
    public let netQuantity: Double
    public let cashBalance: Double
    public let equity: Double
    public let grossExposureNotional: Double
    public let netSimulatedPnL: Double
    public let projectionParityHeld: Bool
    public let reportReproducibilityEvidenceHeld: Bool
    public let validationAnchors: [String]
    public let timelineEntries: [SimulatedExchangeParityEvidenceTimelineEntry]
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        evidence: SimulatedExchangePortfolioProjectionParityEvidence =
            SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidenceFixture,
        fullFillEvidence: PartialFillLatencyFeeSlippageParityReportEvidence =
            .deterministicFullFixture,
        rejectedExecutionOutput: MarketLimitSimulatedExecutionOutput =
            .deterministicRejectedFixture,
        expiredExecutionOutput: MarketLimitSimulatedExecutionOutput =
            .deterministicLimitExpireFixture
    ) {
        let sourceReport = evidence.sourceReportEvidence
        let sourceExecution = sourceReport.sourceExecutionOutput
        let sourceEvent = sourceReport.parityEvent
        let matchingOutput = sourceExecution.matchingOutput
        let matchingEvent = matchingOutput?.simulatedExchangeEvent
        let backtestProjection = evidence.backtestProjection
        let paperProjection = evidence.paperProjection
        let outcomeLabels = [
            sourceEvent.fillCompletion.rawValue,
            fullFillEvidence.parityEvent.fillCompletion.rawValue,
            rejectedExecutionOutput.executionEvent.outcome.rawValue,
            expiredExecutionOutput.executionEvent.outcome.rawValue
        ]
        let validationAnchors = Self.validationAnchors
        let requiredValidationDependsOnNetwork = evidence.requiredValidationDependsOnNetwork
            || sourceReport.requiredValidationDependsOnNetwork
            || sourceExecution.requiredValidationDependsOnNetwork
            || matchingOutput?.requiredValidationDependsOnNetwork == true
            || fullFillEvidence.requiredValidationDependsOnNetwork
            || rejectedExecutionOutput.requiredValidationDependsOnNetwork
            || expiredExecutionOutput.requiredValidationDependsOnNetwork
        let providesLiveCommand = evidence.providesLiveCommand
            || sourceReport.providesLiveCommand
            || sourceExecution.providesLiveCommand
            || matchingOutput?.providesLiveCommand == true
            || sourceEvent.providesLiveCommand
            || fullFillEvidence.providesLiveCommand
            || rejectedExecutionOutput.providesLiveCommand
            || expiredExecutionOutput.providesLiveCommand
        let providesOrderLevelCommand = evidence.providesOrderLevelCommandUI
            || sourceReport.providesOrderLevelCommandUI
            || sourceExecution.providesOrderLevelCommandUI
            || sourceEvent.providesOrderLevelCommandUI
            || fullFillEvidence.providesOrderLevelCommandUI
            || rejectedExecutionOutput.providesOrderLevelCommandUI
            || expiredExecutionOutput.providesOrderLevelCommandUI
        let providesTradingButton = evidence.providesTradingButton
            || sourceReport.providesTradingButton
            || sourceExecution.providesTradingButton
            || matchingOutput?.providesTradingButton == true
            || sourceEvent.providesTradingButton
            || fullFillEvidence.providesTradingButton
            || rejectedExecutionOutput.providesTradingButton
            || expiredExecutionOutput.providesTradingButton
        let touchesBrokerAction = sourceExecution.executionEvent.recordsBrokerFill
            || sourceExecution.executionEvent.ingestsExecutionReport
            || sourceExecution.executionEvent.runsReconciliation
            || sourceEvent.recordsBrokerFill
            || sourceEvent.ingestsExecutionReport
            || sourceEvent.runsReconciliation
            || matchingEvent?.recordsBrokerFill == true
            || matchingEvent?.ingestsExecutionReport == true
            || matchingEvent?.runsReconciliation == true
            || evidence.readsBrokerPosition
            || evidence.runsBrokerReconciliation
        let timelineEntries = Self.makeTimelineEntries(
            evidenceID: evidence.evidenceID.rawValue,
            evidence: evidence,
            matchingResultIdentity: matchingOutput?.deterministicResultIdentity ?? "missing matching result",
            outcomeLabels: outcomeLabels,
            rejectedExecutionOutput: rejectedExecutionOutput,
            expiredExecutionOutput: expiredExecutionOutput
        )

        self.evidenceID = evidence.evidenceID.rawValue
        self.scenarioID = evidence.reportInputVersion.scenarioID.rawValue
        self.datasetVersion = evidence.reportInputVersion.datasetVersion.rawValue
        self.fixtureVersion = evidence.reportInputVersion.fixtureVersion.rawValue
        self.symbol = evidence.reportInputVersion.symbol.rawValue
        self.timeframe = evidence.reportInputVersion.timeframe.rawValue
        self.replayWindowDescription = matchingEvent?.replayWindowDescription
            ?? evidence.reportInputVersion.replayWindowDescription
        self.matchingResultIdentity = matchingOutput?.deterministicResultIdentity ?? "missing matching result"
        self.matchingEventID = matchingEvent?.eventID.rawValue ?? "missing matching event"
        self.matchingResult = matchingEvent?.eventKind.rawValue ?? "missing matching result"
        self.matchedPrice = sourceEvent.matchedPrice.rawValue
        self.matchedQuantity = matchingEvent?.matchedQuantity.rawValue ?? sourceEvent.orderQuantity.rawValue
        self.orderID = sourceEvent.orderID.rawValue
        self.orderType = sourceEvent.orderType.rawValue
        self.partialFillState = sourceEvent.sharedOrderState.rawValue
        self.fullFillState = fullFillEvidence.parityEvent.sharedOrderState.rawValue
        self.rejectedState = rejectedExecutionOutput.executionEvent.sharedOrderState.rawValue
        self.expiredState = expiredExecutionOutput.executionEvent.sharedOrderState.rawValue
        self.outcomeLabels = outcomeLabels
        self.latencyMilliseconds = sourceEvent.latencyMilliseconds
        self.latencyRecordRange = "\(sourceEvent.latencyInputRecordSequence)->\(sourceEvent.latencyOutputRecordSequence)"
        self.feeAmount = sourceEvent.backtestCostEstimate.feeAmount
        self.slippageAmount = sourceEvent.backtestCostEstimate.slippageAmount
        self.totalCostImpactAmount = sourceEvent.backtestCostEstimate.totalCostAmount
        self.costAssumptionID = sourceEvent.backtestCostEstimate.assumptionID.rawValue
        self.costParityConsistent = sourceEvent.costParityResult.isConsistent
        self.backtestProjectionID = backtestProjection.projectionID.rawValue
        self.paperProjectionID = paperProjection.projectionID.rawValue
        self.reportInputVersionIdentity = evidence.reportInputVersion.versionIdentity
        self.sourceReplaySequence = backtestProjection.sourceReplaySequence
        self.deterministicResultIdentity = evidence.deterministicResultIdentity
        self.netQuantity = backtestProjection.netQuantity.rawValue
        self.cashBalance = backtestProjection.cashBalance
        self.equity = backtestProjection.equity
        self.grossExposureNotional = backtestProjection.grossExposureNotional
        self.netSimulatedPnL = backtestProjection.netSimulatedPnL
        self.projectionParityHeld = evidence.projectionParityHeld
        self.reportReproducibilityEvidenceHeld = evidence.parityEvidenceBoundaryHeld
        self.validationAnchors = validationAnchors
        self.timelineEntries = timelineEntries
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.exposesDatabaseSchema = false
        self.exposesRuntimeObject = false
        self.exposesAdapterRequest = false
        self.readsSecret = false
        self.usesSignedEndpoint = false
        self.callsAccountEndpoint = false
        self.createsListenKey = false
        self.connectsBroker = false
        self.implementsLiveExecutionAdapter = false
        self.implementsOMS = false
        self.implementsRealOrderLifecycle = false
        self.runsLiveRuntime = false
        self.providesCommandSurface = false
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.authorizesLiveTrading = false
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = false
        self.readModelOnlyBoundaryHeld = evidence.parityEvidenceBoundaryHeld
            && sourceReport.reportEvidenceBoundaryHeld
            && sourceExecution.executionOutputBoundaryHeld
            && matchingOutput?.matchingOutputBoundaryHeld == true
            && fullFillEvidence.reportEvidenceBoundaryHeld
            && rejectedExecutionOutput.executionOutputBoundaryHeld
            && expiredExecutionOutput.executionOutputBoundaryHeld
            && projectionParityHeld
            && reportReproducibilityEvidenceHeld
            && requiredValidationDependsOnNetwork == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }

    /// MTP-116 的机械验收 anchors；用于 docs、automation readiness 和 focused App tests 对齐。
    public static let validationAnchors: [String] = [
        "MTP-116-PARITY-EVIDENCE-READ-MODEL",
        "MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE",
        "MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT",
        "MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
        "MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT",
        "MTP-116-SIMULATED-EXCHANGE-PARITY-SURFACE-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    private static func makeTimelineEntries(
        evidenceID: String,
        evidence: SimulatedExchangePortfolioProjectionParityEvidence,
        matchingResultIdentity: String,
        outcomeLabels: [String],
        rejectedExecutionOutput: MarketLimitSimulatedExecutionOutput,
        expiredExecutionOutput: MarketLimitSimulatedExecutionOutput
    ) -> [SimulatedExchangeParityEvidenceTimelineEntry] {
        let sourceEvent = evidence.sourceReportEvidence.parityEvent
        let backtest = evidence.backtestProjection
        let paper = evidence.paperProjection
        return [
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-scenario",
                kind: "scenario replay",
                title: "Simulated exchange scenario",
                summary: "scenario=\(evidence.reportInputVersion.scenarioID.rawValue); dataset=\(evidence.reportInputVersion.datasetVersion.rawValue); fixture=\(evidence.reportInputVersion.fixtureVersion.rawValue); window=\(evidence.reportInputVersion.replayWindowDescription)",
                sourceAnchor: "MTP-116-PARITY-EVIDENCE-READ-MODEL"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-matching",
                kind: "matching result",
                title: "Simulated exchange matching",
                summary: "matching=\(matchingResultIdentity)",
                sourceAnchor: "MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-fill-summary",
                kind: "fill summary",
                title: "Partial / full fill evidence",
                summary: "partial=\(sourceEvent.sharedOrderState.rawValue); full=\(outcomeLabels[1]); order=\(sourceEvent.orderID.rawValue)",
                sourceAnchor: "MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-reject-expire",
                kind: "reject expire",
                title: "Reject / expire simulated evidence",
                summary: "reject=\(rejectedExecutionOutput.executionEvent.sharedOrderState.rawValue); expire=\(expiredExecutionOutput.executionEvent.sharedOrderState.rawValue)",
                sourceAnchor: "MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-latency-cost",
                kind: "latency cost",
                title: "Latency / fee / slippage evidence",
                summary: "latency=\(format(sourceEvent.latencyMilliseconds))ms; fee=\(format(sourceEvent.backtestCostEstimate.feeAmount)); slippage=\(format(sourceEvent.backtestCostEstimate.slippageAmount)); costParity=\(sourceEvent.costParityResult.isConsistent)",
                sourceAnchor: "MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-portfolio",
                kind: "portfolio parity",
                title: "Backtest / paper portfolio parity",
                summary: "backtest=\(backtest.projectionID.rawValue); paper=\(paper.projectionID.rawValue); quantity=\(format(backtest.netQuantity.rawValue)); netPnL=\(format(backtest.netSimulatedPnL))",
                sourceAnchor: "MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT"
            ),
            SimulatedExchangeParityEvidenceTimelineEntry(
                entryID: "\(evidenceID)-report-input",
                kind: "report input",
                title: "Report input / replay consistency",
                summary: "reportInput=\(evidence.reportInputVersion.versionIdentity); replaySequence=\(backtest.sourceReplaySequence)",
                sourceAnchor: "MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE"
            )
        ]
    }
}

/// SimulatedExchangeParityEvidenceReadModel 汇总 MTP-116 Report / Dashboard / Events 可消费的 parity evidence。
///
/// 上游只能传入 Core deterministic evidence 或后续稳定 projection 派生的 value object；App 层只排序、
/// 聚合和暴露 read-model-only boundary，不运行 matching / execution / portfolio runtime。
public struct SimulatedExchangeParityEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [SimulatedExchangeParityEvidenceItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        items: [SimulatedExchangeParityEvidenceItem] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.items = items.sorted { left, right in
            if left.scenarioID != right.scenarioID {
                return left.scenarioID < right.scenarioID
            }
            return left.evidenceID < right.evidenceID
        }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly && items.allSatisfy(\.readModelOnlyBoundaryHeld)
    }

    public static var deterministicFixture: SimulatedExchangeParityEvidenceReadModel {
        SimulatedExchangeParityEvidenceReadModel(
            items: [SimulatedExchangeParityEvidenceItem()],
            lastAppliedSequence: 3
        )
    }
}

/// SimulatedExchangeParityEvidenceViewModel 是 Dashboard / Report / Dashboard / Events 的可编码只读快照。
///
/// ViewModel 只从 `SimulatedExchangeParityEvidenceReadModel` 派生计数、ID、timeline 和 boundary
/// flags。它不提供按钮、order form、query language、Runtime command、Live PRO Console 或交易授权。
public struct SimulatedExchangeParityEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [SimulatedExchangeParityEvidenceItem]
    public let evidenceCount: Int
    public let scenarioIDs: [String]
    public let datasetVersions: [String]
    public let fixtureVersions: [String]
    public let symbols: [String]
    public let timeframes: [String]
    public let replayWindows: [String]
    public let matchingResults: [String]
    public let matchingEventIDs: [String]
    public let orderIDs: [String]
    public let orderTypes: [String]
    public let outcomeLabels: [String]
    public let reportInputVersionIdentities: [String]
    public let sourceReplaySequences: [Int]
    public let timelineEntries: [SimulatedExchangeParityEvidenceTimelineEntry]
    public let timelineEntryCount: Int
    public let validationAnchors: [String]
    public let validationAnchorCount: Int
    public let matchedPrice: Double?
    public let matchedQuantity: Double?
    public let netQuantity: Double
    public let cashBalance: Double
    public let equity: Double
    public let grossExposureNotional: Double
    public let netSimulatedPnL: Double
    public let feeAmount: Double
    public let slippageAmount: Double
    public let totalCostImpactAmount: Double
    public let latencyMilliseconds: Double?
    public let projectionParityHeld: Bool
    public let costParityConsistent: Bool
    public let reportReproducibilityEvidenceHeld: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: SimulatedExchangeParityEvidenceReadModel) {
        let items = readModel.items
        let timelineEntries = items.flatMap(\.timelineEntries)
        let exposesDatabaseSchema = readModel.source.exposesDatabaseTables
            || readModel.source.exposesORMModels
            || items.contains(where: \.exposesDatabaseSchema)
        let exposesRuntimeObject = readModel.source.exposesRuntimeObjects
            || items.contains(where: \.exposesRuntimeObject)
        let exposesAdapterRequest = readModel.source.callsBinanceAdapter
            || items.contains(where: \.exposesAdapterRequest)
        let providesCommandSurface = items.contains(where: \.providesCommandSurface)
        let providesOrderLevelCommand = items.contains(where: \.providesOrderLevelCommand)
        let providesLiveCommand = items.contains(where: \.providesLiveCommand)
        let providesTradingButton = items.contains(where: \.providesTradingButton)
        let authorizesLiveTrading = items.contains(where: \.authorizesLiveTrading)
        let touchesBrokerAction = items.contains(where: \.touchesBrokerAction)
        let authorizesTradingExecution = readModel.source.providesLiveOrderAction
            || items.contains(where: \.authorizesTradingExecution)
        let requiredValidationDependsOnNetwork = items.contains(where: \.requiredValidationDependsOnNetwork)

        self.source = readModel.source
        self.items = items
        self.evidenceCount = items.count
        self.scenarioIDs = items.map(\.scenarioID).uniqueSortedStrings()
        self.datasetVersions = items.map(\.datasetVersion).uniqueSortedStrings()
        self.fixtureVersions = items.map(\.fixtureVersion).uniqueSortedStrings()
        self.symbols = items.map(\.symbol).uniqueSortedStrings()
        self.timeframes = items.map(\.timeframe).uniqueSortedStrings()
        self.replayWindows = items.map(\.replayWindowDescription).uniqueSortedStrings()
        self.matchingResults = items.map(\.matchingResult).uniqueSortedStrings()
        self.matchingEventIDs = items.map(\.matchingEventID).uniqueSortedStrings()
        self.orderIDs = items.map(\.orderID).uniqueSortedStrings()
        self.orderTypes = items.map(\.orderType).uniqueSortedStrings()
        self.outcomeLabels = items.flatMap(\.outcomeLabels).uniquePreservingOrder()
        self.reportInputVersionIdentities = items.map(\.reportInputVersionIdentity)
        self.sourceReplaySequences = items.map(\.sourceReplaySequence).uniqueSortedInts()
        self.timelineEntries = timelineEntries
        self.timelineEntryCount = timelineEntries.count
        self.validationAnchors = items.flatMap(\.validationAnchors).uniquePreservingOrder()
        self.validationAnchorCount = validationAnchors.count
        self.matchedPrice = items.first?.matchedPrice
        self.matchedQuantity = items.first?.matchedQuantity
        self.netQuantity = items.reduce(0) { $0 + $1.netQuantity }
        self.cashBalance = items.first?.cashBalance ?? 0
        self.equity = items.first?.equity ?? 0
        self.grossExposureNotional = items.reduce(0) { $0 + $1.grossExposureNotional }
        self.netSimulatedPnL = items.reduce(0) { $0 + $1.netSimulatedPnL }
        self.feeAmount = items.reduce(0) { $0 + $1.feeAmount }
        self.slippageAmount = items.reduce(0) { $0 + $1.slippageAmount }
        self.totalCostImpactAmount = items.reduce(0) { $0 + $1.totalCostImpactAmount }
        self.latencyMilliseconds = items.first?.latencyMilliseconds
        self.projectionParityHeld = items.isEmpty == false && items.allSatisfy(\.projectionParityHeld)
        self.costParityConsistent = items.isEmpty == false && items.allSatisfy(\.costParityConsistent)
        self.reportReproducibilityEvidenceHeld = items.isEmpty
            || items.allSatisfy(\.reportReproducibilityEvidenceHeld)
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private func format(_ value: Double) -> String {
    String(format: "%.8f", value)
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}

private extension Array where Element: Hashable {
    func uniquePreservingOrder() -> [Element] {
        var seen = Set<Element>()
        var result: [Element] = []
        for value in self where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }
}

private extension Array where Element == Int {
    func uniqueSortedInts() -> [Int] {
        Array(Set(self)).sorted()
    }
}
