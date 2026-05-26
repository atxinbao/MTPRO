import Core
import Foundation

/// WorkbenchBetaAcceptancePathTraceItem 是 MTP-122 的 Report / Dashboard / Events 验收轨迹行。
///
/// Trace item 只保存已经进入 App read model 的 evidence id、surface、title 和 summary。它不携带
/// Runtime object、Persistence schema、adapter request、broker payload、order form、live command 或交易按钮。
public struct WorkbenchBetaAcceptancePathTraceItem: Codable, Equatable, Sendable {
    public let traceID: String
    public let surface: String
    public let title: String
    public let summary: String
    public let evidenceID: String
    public let sourceAnchor: String

    public init(
        traceID: String,
        surface: String,
        title: String,
        summary: String,
        evidenceID: String,
        sourceAnchor: String
    ) {
        self.traceID = traceID
        self.surface = surface
        self.title = title
        self.summary = summary
        self.evidenceID = evidenceID
        self.sourceAnchor = sourceAnchor
    }
}

/// WorkbenchBetaAcceptancePathItem 是 MTP-122 的单个 beta acceptance path 聚合证据。
///
/// 该 item 只把 MTP-120 / MTP-121 的同一 demo scenario、MTP-108 scenario replay、MTP-116
/// simulated exchange parity 和 L2 portfolio parity 字段组合成 Report / Dashboard / Events
/// 可验收摘要。它不触发 replay、不读取数据库 schema、不运行 matching / portfolio runtime，
/// 也不授权 signed endpoint、account endpoint、listenKey、broker、OMS、Live PRO Console、
/// live command、order-level command 或交易按钮。
public struct WorkbenchBetaAcceptancePathItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let issueID: String
    public let scenarioID: String
    public let datasetVersion: String
    public let fixtureVersion: String
    public let symbol: String
    public let timeframe: String
    public let reportInputVersionIdentity: String
    public let scenarioReplayEvidenceID: String
    public let simulatedParityEvidenceID: String
    public let portfolioEvidenceID: String
    public let portfolioSummary: String
    public let netQuantity: Double
    public let grossExposureNotional: Double
    public let netSimulatedPnL: Double
    public let feeAmount: Double
    public let slippageAmount: Double
    public let sourceReplaySequences: [Int]
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let eventTraceItems: [WorkbenchBetaAcceptancePathTraceItem]
    public let validationAnchors: [String]
    public let sameDemoScenarioHeld: Bool
    public let reportSurfaceReady: Bool
    public let dashboardPanelsReady: Bool
    public let eventsTraceReady: Bool
    public let scenarioReplayEvidenceHeld: Bool
    public let simulatedParityEvidenceHeld: Bool
    public let portfolioEvidenceHeld: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init?(
        report: ReportReadModel,
        firstRun: WorkbenchBetaFirstRunReadModel
    ) {
        guard firstRun.state == .defaultDemo,
              firstRun.readModelOnlyBoundaryHeld,
              let firstRunSummary = firstRun.evidenceSummary,
              let scenarioReplay = report.scenarioReplayEvidence.items.first(where: {
                  $0.scenarioID == firstRunSummary.scenarioID
                      && $0.datasetVersion == firstRunSummary.datasetVersion
                      && $0.fixtureVersion == firstRunSummary.fixtureVersion
                      && $0.reportInputVersionIdentity == firstRunSummary.reportInputVersionIdentity
              }),
              let simulatedParity = report.simulatedExchangeParityEvidence.items.first(where: {
                  $0.scenarioID == firstRunSummary.scenarioID
                      && $0.datasetVersion == firstRunSummary.datasetVersion
                      && $0.fixtureVersion == firstRunSummary.fixtureVersion
                      && $0.reportInputVersionIdentity == firstRunSummary.reportInputVersionIdentity
              }) else {
            return nil
        }

        let evidenceID = "mtp-122-workbench-beta-acceptance-path"
        let portfolioEvidenceID = "\(simulatedParity.evidenceID)-portfolio-parity"
        let portfolioSummary =
            "portfolio=\(portfolioEvidenceID); netQuantity=\(simulatedParity.netQuantity); grossExposure=\(simulatedParity.grossExposureNotional); netPnL=\(simulatedParity.netSimulatedPnL)"
        let reportSummary =
            "Report acceptance scenario=\(scenarioReplay.scenarioID); replay=\(scenarioReplay.evidenceID); parity=\(simulatedParity.evidenceID); portfolio=\(portfolioEvidenceID)"
        let dashboardPanelSummaries = [
            "First-run panel confirms \(firstRunSummary.scenarioID) selected",
            "Scenario replay panel confirms \(scenarioReplay.reportInputVersionIdentity)",
            "Simulated parity panel confirms \(simulatedParity.matchingResult)",
            "Portfolio panel confirms gross exposure \(simulatedParity.grossExposureNotional) and net PnL \(simulatedParity.netSimulatedPnL)"
        ]
        let eventTraceItems = Self.makeTraceItems(
            evidenceID: evidenceID,
            scenarioReplay: scenarioReplay,
            simulatedParity: simulatedParity,
            portfolioEvidenceID: portfolioEvidenceID,
            portfolioSummary: portfolioSummary
        )

        let sameDemoScenarioHeld = firstRunSummary.scenarioID == scenarioReplay.scenarioID
            && firstRunSummary.scenarioID == simulatedParity.scenarioID
            && firstRunSummary.datasetVersion == scenarioReplay.datasetVersion
            && firstRunSummary.datasetVersion == simulatedParity.datasetVersion
            && firstRunSummary.fixtureVersion == scenarioReplay.fixtureVersion
            && firstRunSummary.fixtureVersion == simulatedParity.fixtureVersion
            && firstRunSummary.reportInputVersionIdentity == scenarioReplay.reportInputVersionIdentity
            && firstRunSummary.reportInputVersionIdentity == simulatedParity.reportInputVersionIdentity
        let scenarioReplayEvidenceHeld = scenarioReplay.readModelOnlyBoundaryHeld
            && scenarioReplay.reportReproducibilityEvidenceHeld
        let simulatedParityEvidenceHeld = simulatedParity.readModelOnlyBoundaryHeld
            && simulatedParity.reportReproducibilityEvidenceHeld
        let portfolioEvidenceHeld = simulatedParity.projectionParityHeld
            && simulatedParity.grossExposureNotional > 0
        let requiredValidationDependsOnNetwork = firstRun.requiredValidationDependsOnNetwork
            || scenarioReplay.requiredValidationDependsOnNetwork
            || simulatedParity.requiredValidationDependsOnNetwork
        let exposesDatabaseSchema = firstRun.exposesDatabaseSchema
            || scenarioReplay.exposesDatabaseSchema
            || simulatedParity.exposesDatabaseSchema
        let exposesRuntimeObject = firstRun.exposesRuntimeObject
            || scenarioReplay.readsRuntimeObject
            || simulatedParity.exposesRuntimeObject
        let exposesAdapterRequest = firstRun.exposesAdapterRequest
            || scenarioReplay.exposesAdapterRequest
            || simulatedParity.exposesAdapterRequest
        let usesSignedEndpoint = scenarioReplay.usesSignedEndpoint || simulatedParity.usesSignedEndpoint
        let callsAccountEndpoint = scenarioReplay.callsAccountEndpoint || simulatedParity.callsAccountEndpoint
        let createsListenKey = scenarioReplay.createsListenKey || simulatedParity.createsListenKey
        let connectsBroker = scenarioReplay.connectsBroker || simulatedParity.connectsBroker
        let implementsLiveExecutionAdapter = scenarioReplay.implementsLiveExecutionAdapter
            || simulatedParity.implementsLiveExecutionAdapter
        let implementsOMS = scenarioReplay.implementsOMS || simulatedParity.implementsOMS
        let implementsRealOrderLifecycle = scenarioReplay.implementsRealOrderLifecycle
            || simulatedParity.implementsRealOrderLifecycle
        let providesCommandSurface = firstRun.providesCommandSurface
            || scenarioReplay.providesCommandSurface
            || simulatedParity.providesCommandSurface
        let providesOrderLevelCommand = firstRun.providesOrderLevelCommand
            || scenarioReplay.providesOrderLevelCommand
            || simulatedParity.providesOrderLevelCommand
        let providesLiveCommand = firstRun.providesLiveCommand
            || scenarioReplay.providesLiveCommand
            || simulatedParity.providesLiveCommand
        let providesTradingButton = firstRun.providesTradingButton
            || scenarioReplay.providesTradingButton
            || simulatedParity.providesTradingButton
        let authorizesLiveTrading = firstRun.authorizesLiveTrading
            || scenarioReplay.authorizesLiveTrading
            || simulatedParity.authorizesLiveTrading
        let touchesBrokerAction = firstRun.touchesBrokerAction
            || scenarioReplay.touchesBrokerAction
            || simulatedParity.touchesBrokerAction
        let authorizesTradingExecution = firstRun.authorizesTradingExecution
            || scenarioReplay.authorizesTradingExecution
            || simulatedParity.authorizesTradingExecution
        let reportSurfaceReady = sameDemoScenarioHeld
            && scenarioReplayEvidenceHeld
            && simulatedParityEvidenceHeld
            && portfolioEvidenceHeld
        let dashboardPanelsReady = reportSurfaceReady
            && firstRun.readModelOnlyBoundaryHeld
            && dashboardPanelSummaries.count == 4
        let eventsTraceReady = eventTraceItems.count == 5
        let readModelOnlyBoundaryHeld = reportSurfaceReady
            && dashboardPanelsReady
            && eventsTraceReady
            && requiredValidationDependsOnNetwork == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false

        self.evidenceID = evidenceID
        self.issueID = "MTP-122"
        self.scenarioID = scenarioReplay.scenarioID
        self.datasetVersion = scenarioReplay.datasetVersion
        self.fixtureVersion = scenarioReplay.fixtureVersion
        self.symbol = scenarioReplay.symbol
        self.timeframe = scenarioReplay.timeframe
        self.reportInputVersionIdentity = scenarioReplay.reportInputVersionIdentity
        self.scenarioReplayEvidenceID = scenarioReplay.evidenceID
        self.simulatedParityEvidenceID = simulatedParity.evidenceID
        self.portfolioEvidenceID = portfolioEvidenceID
        self.portfolioSummary = portfolioSummary
        self.netQuantity = simulatedParity.netQuantity
        self.grossExposureNotional = simulatedParity.grossExposureNotional
        self.netSimulatedPnL = simulatedParity.netSimulatedPnL
        self.feeAmount = simulatedParity.feeAmount
        self.slippageAmount = simulatedParity.slippageAmount
        self.sourceReplaySequences = simulatedParity.sourceReplaySequence == 0
            ? []
            : [simulatedParity.sourceReplaySequence]
        self.reportSummary = reportSummary
        self.dashboardPanelSummaries = dashboardPanelSummaries
        self.eventTraceItems = eventTraceItems
        self.validationAnchors = WorkbenchBetaAcceptancePathReadModel.validationAnchors
        self.sameDemoScenarioHeld = sameDemoScenarioHeld
        self.reportSurfaceReady = reportSurfaceReady
        self.dashboardPanelsReady = dashboardPanelsReady
        self.eventsTraceReady = eventsTraceReady
        self.scenarioReplayEvidenceHeld = scenarioReplayEvidenceHeld
        self.simulatedParityEvidenceHeld = simulatedParityEvidenceHeld
        self.portfolioEvidenceHeld = portfolioEvidenceHeld
        self.readModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    private static func makeTraceItems(
        evidenceID: String,
        scenarioReplay: ScenarioReplayEvidenceItem,
        simulatedParity: SimulatedExchangeParityEvidenceItem,
        portfolioEvidenceID: String,
        portfolioSummary: String
    ) -> [WorkbenchBetaAcceptancePathTraceItem] {
        [
            WorkbenchBetaAcceptancePathTraceItem(
                traceID: "\(evidenceID)-report",
                surface: "Report",
                title: "Report beta acceptance summary",
                summary: "scenario=\(scenarioReplay.scenarioID); reportInput=\(scenarioReplay.reportInputVersionIdentity)",
                evidenceID: scenarioReplay.reportInputVersionIdentity,
                sourceAnchor: "MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY"
            ),
            WorkbenchBetaAcceptancePathTraceItem(
                traceID: "\(evidenceID)-scenario-replay",
                surface: "Report / Events",
                title: "Scenario replay acceptance evidence",
                summary: "checksum=\(scenarioReplay.checksum); freshness=\(scenarioReplay.freshnessStatus.rawValue); quality=\(scenarioReplay.qualityVerdict.rawValue)",
                evidenceID: scenarioReplay.evidenceID,
                sourceAnchor: "MTP-122-SCENARIO-REPLAY-ACCEPTANCE-EVIDENCE"
            ),
            WorkbenchBetaAcceptancePathTraceItem(
                traceID: "\(evidenceID)-simulated-parity",
                surface: "Report / Dashboard",
                title: "Simulated parity acceptance evidence",
                summary: "matching=\(simulatedParity.matchingResult); outcomes=\(simulatedParity.outcomeLabels.joined(separator: ", "))",
                evidenceID: simulatedParity.evidenceID,
                sourceAnchor: "MTP-122-SIMULATED-PARITY-ACCEPTANCE-EVIDENCE"
            ),
            WorkbenchBetaAcceptancePathTraceItem(
                traceID: "\(evidenceID)-portfolio",
                surface: "Dashboard / Events",
                title: "Portfolio acceptance evidence",
                summary: portfolioSummary,
                evidenceID: portfolioEvidenceID,
                sourceAnchor: "MTP-122-PORTFOLIO-ACCEPTANCE-EVIDENCE"
            ),
            WorkbenchBetaAcceptancePathTraceItem(
                traceID: "\(evidenceID)-events",
                surface: "Events",
                title: "Events beta acceptance trace",
                summary: "Report, Dashboard and Events trace the same demo scenario \(scenarioReplay.scenarioID)",
                evidenceID: evidenceID,
                sourceAnchor: "MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE"
            )
        ]
    }
}

/// WorkbenchBetaAcceptancePathReadModel 汇总 MTP-122 可进入 App / Dashboard 的验收路径。
///
/// Read model 只从 `ReportReadModel` 与 `WorkbenchBetaFirstRunReadModel` 派生，不读取 Core
/// fixture 以外的运行时对象，也不触发 replay / matching / portfolio projection side effect。
public struct WorkbenchBetaAcceptancePathReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [WorkbenchBetaAcceptancePathItem]
    public let lastAppliedSequence: Int?

    public static let validationAnchors: [String] = [
        "MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY",
        "MTP-122-DASHBOARD-BETA-EVIDENCE-PANELS",
        "MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE",
        "MTP-122-SAME-DEMO-SCENARIO-EVIDENCE",
        "MTP-122-SCENARIO-PARITY-PORTFOLIO-TRACE",
        "MTP-122-READ-MODEL-ONLY-NO-RUNTIME-COMMAND",
        "MTP-122-BETA-ACCEPTANCE-PATH-VALIDATION"
    ]

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        items: [WorkbenchBetaAcceptancePathItem] = [],
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

    public init(
        report: ReportReadModel,
        firstRun: WorkbenchBetaFirstRunReadModel
    ) {
        let item = WorkbenchBetaAcceptancePathItem(report: report, firstRun: firstRun)
        self.init(
            items: item.map { [$0] } ?? [],
            lastAppliedSequence: report.lastAppliedSequence
        )
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly && items.allSatisfy(\.readModelOnlyBoundaryHeld)
    }
}

/// WorkbenchBetaAcceptancePathViewModel 是 Report / Dashboard / Events 可以共同消费的 MTP-122 快照。
///
/// ViewModel 只做计数、ID 聚合、summary 聚合和 boundary flag 聚合；它不暴露 schema、Runtime、
/// adapter、signed/account endpoint、broker action、Live PRO Console、live command 或交易按钮。
public struct WorkbenchBetaAcceptancePathViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [WorkbenchBetaAcceptancePathItem]
    public let acceptancePathCount: Int
    public let scenarioIDs: [String]
    public let datasetVersions: [String]
    public let fixtureVersions: [String]
    public let reportInputVersionIdentities: [String]
    public let reportSummaries: [String]
    public let dashboardPanelSummaries: [String]
    public let eventTraceItems: [WorkbenchBetaAcceptancePathTraceItem]
    public let eventTraceItemCount: Int
    public let portfolioEvidenceIDs: [String]
    public let grossExposureNotional: Double
    public let netSimulatedPnL: Double
    public let validationAnchors: [String]
    public let sameDemoScenarioHeld: Bool
    public let reportSurfaceReady: Bool
    public let dashboardPanelsReady: Bool
    public let eventsTraceReady: Bool
    public let scenarioReplayEvidenceHeld: Bool
    public let simulatedParityEvidenceHeld: Bool
    public let portfolioEvidenceHeld: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: WorkbenchBetaAcceptancePathReadModel) {
        let items = readModel.items
        self.source = readModel.source
        self.items = items
        self.acceptancePathCount = items.count
        self.scenarioIDs = items.map(\.scenarioID).uniqueSortedStrings()
        self.datasetVersions = items.map(\.datasetVersion).uniqueSortedStrings()
        self.fixtureVersions = items.map(\.fixtureVersion).uniqueSortedStrings()
        self.reportInputVersionIdentities = items.map(\.reportInputVersionIdentity).uniqueSortedStrings()
        self.reportSummaries = items.map(\.reportSummary).uniqueSortedStrings()
        self.dashboardPanelSummaries = items.flatMap(\.dashboardPanelSummaries).uniqueSortedStrings()
        self.eventTraceItems = items.flatMap(\.eventTraceItems)
        self.eventTraceItemCount = eventTraceItems.count
        self.portfolioEvidenceIDs = items.map(\.portfolioEvidenceID).uniqueSortedStrings()
        self.grossExposureNotional = items.reduce(0) { $0 + $1.grossExposureNotional }
        self.netSimulatedPnL = items.reduce(0) { $0 + $1.netSimulatedPnL }
        self.validationAnchors = WorkbenchBetaAcceptancePathReadModel.validationAnchors
        self.sameDemoScenarioHeld = items.isEmpty == false
            && items.allSatisfy(\.sameDemoScenarioHeld)
        self.reportSurfaceReady = items.isEmpty == false
            && items.allSatisfy(\.reportSurfaceReady)
        self.dashboardPanelsReady = items.isEmpty == false
            && items.allSatisfy(\.dashboardPanelsReady)
        self.eventsTraceReady = items.isEmpty == false
            && items.allSatisfy(\.eventsTraceReady)
        self.scenarioReplayEvidenceHeld = items.isEmpty == false
            && items.allSatisfy(\.scenarioReplayEvidenceHeld)
        self.simulatedParityEvidenceHeld = items.isEmpty == false
            && items.allSatisfy(\.simulatedParityEvidenceHeld)
        self.portfolioEvidenceHeld = items.isEmpty == false
            && items.allSatisfy(\.portfolioEvidenceHeld)
        self.requiredValidationDependsOnNetwork = items.contains {
            $0.requiredValidationDependsOnNetwork
        }
        self.exposesDatabaseSchema = readModel.source.exposesDatabaseTables
            || readModel.source.exposesORMModels
            || items.contains { $0.exposesDatabaseSchema }
        self.exposesRuntimeObject = readModel.source.exposesRuntimeObjects
            || items.contains { $0.exposesRuntimeObject }
        self.exposesAdapterRequest = readModel.source.callsBinanceAdapter
            || items.contains { $0.exposesAdapterRequest }
        self.usesSignedEndpoint = items.contains { $0.usesSignedEndpoint }
        self.callsAccountEndpoint = items.contains { $0.callsAccountEndpoint }
        self.createsListenKey = items.contains { $0.createsListenKey }
        self.connectsBroker = items.contains { $0.connectsBroker }
        self.implementsLiveExecutionAdapter = items.contains { $0.implementsLiveExecutionAdapter }
        self.implementsOMS = items.contains { $0.implementsOMS }
        self.implementsRealOrderLifecycle = items.contains { $0.implementsRealOrderLifecycle }
        self.providesCommandSurface = items.contains { $0.providesCommandSurface }
        self.providesOrderLevelCommand = items.contains { $0.providesOrderLevelCommand }
        self.providesLiveCommand = items.contains { $0.providesLiveCommand }
        self.providesTradingButton = items.contains { $0.providesTradingButton }
        self.authorizesLiveTrading = items.contains { $0.authorizesLiveTrading }
        self.touchesBrokerAction = items.contains { $0.touchesBrokerAction }
        self.authorizesTradingExecution = readModel.source.providesLiveOrderAction
            || items.contains { $0.authorizesTradingExecution }
        self.readModelOnlyBoundaryHeld = readModel.source.isReadModelOnly
            && readModel.readModelOnlyBoundaryHeld
            && (items.isEmpty || items.allSatisfy(\.readModelOnlyBoundaryHeld))
            && requiredValidationDependsOnNetwork == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}
