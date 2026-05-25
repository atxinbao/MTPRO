import Core
import Foundation

/// ScenarioReplayEvidenceTimelineEntry 是 MTP-108 Events / Evidence Explorer 的只读 timeline 行。
///
/// Entry 只复制 MTP-106 replay evidence 和 MTP-107 quality gate 的稳定摘要，用于 Workbench
/// drill-down 与 Event Timeline 展示；它不持有 Runtime object、SQLite / DuckDB schema、
/// adapter request、query language、command surface、live command 或交易按钮。
public struct ScenarioReplayEvidenceTimelineEntry: Codable, Equatable, Sendable {
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

/// ScenarioReplayEvidenceItem 是 MTP-108 的 App 层 scenario replay 只读证据行。
///
/// Item 从 Core `ScenarioDataQualityReportInputEvidence` 复制允许进入 Dashboard / Report /
/// Events 的字段：scenario identity、dataset / fixture version、replay window、cursor、checksum、
/// freshness、quality verdict 和 report input version。该类型不执行 replay、不读 schema、不调用
/// adapter、不读取 secret，也不提供 command surface、live command、broker action 或交易授权。
public struct ScenarioReplayEvidenceItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let scenarioID: String
    public let datasetVersion: String
    public let fixtureVersion: String
    public let symbol: String
    public let timeframe: String
    public let replayWindowIdentity: String
    public let replayWindowDescription: String
    public let cursorIdentity: String
    public let cursorSummary: String
    public let cursorState: ScenarioReplayCursorState
    public let checksum: String
    public let checksumAlgorithm: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let freshnessSummary: String
    public let qualityVerdict: ScenarioDataQualityVerdict
    public let qualitySummary: String
    public let reportInputVersionIdentity: String
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let timelineEntries: [ScenarioReplayEvidenceTimelineEntry]
    public let drillDownEntry: String
    public let reportReproducibilityEvidenceHeld: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let buildsProductionDataPlatform: Bool
    public let runsProductionDataObservability: Bool
    public let performsAutomaticDownload: Bool
    public let performsAutomaticRepair: Bool
    public let performsBrokerAccountReconciliation: Bool
    public let implementsSimulatedExchangeBacktestParity: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsRuntimeObject: Bool
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
    public let supportsQueryLanguage: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(evidence: ScenarioDataQualityReportInputEvidence = .deterministicFixture) {
        let replay = evidence.replayEvidence
        let reportInput = evidence.reportInputVersion
        let quality = evidence.qualityEvaluation
        let scenarioID = reportInput.scenarioID.rawValue
        let fixtureVersion = reportInput.fixtureVersion.rawValue
        let evidenceID = "scenario-replay-\(scenarioID)-\(fixtureVersion)"
        let timelineEntries = Self.makeTimelineEntries(
            evidenceID: evidenceID,
            replay: replay,
            quality: quality,
            reportInput: reportInput
        )

        self.evidenceID = evidenceID
        self.scenarioID = scenarioID
        self.datasetVersion = reportInput.datasetVersion.rawValue
        self.fixtureVersion = fixtureVersion
        self.symbol = reportInput.symbol.rawValue
        self.timeframe = reportInput.timeframe.rawValue
        self.replayWindowIdentity = reportInput.replayWindowIdentity
        self.replayWindowDescription = reportInput.replayWindowDescription
        self.cursorIdentity = replay.cursorSummary.cursorIdentity
        self.cursorSummary = replay.cursorSummary.summaryLine
        self.cursorState = replay.cursorSummary.state
        self.checksum = reportInput.checksum
        self.checksumAlgorithm = replay.checksumEvidence.algorithm
        self.freshnessStatus = reportInput.freshnessStatus
        self.freshnessSummary = replay.freshnessEvidence.freshnessSummary
        self.qualityVerdict = reportInput.qualityVerdict
        self.qualitySummary = reportInput.qualitySummary
        self.reportInputVersionIdentity = reportInput.versionIdentity
        self.sourceAnchors = reportInput.sourceAnchors
        self.validationAnchors = evidence.validationAnchors
        self.timelineEntries = timelineEntries
        self.drillDownEntry = "scenario replay / \(scenarioID) / \(reportInput.qualityVerdict.rawValue)"
        self.reportReproducibilityEvidenceHeld = evidence.reportReproducibilityEvidenceHeld
        self.requiredValidationDependsOnNetwork = evidence.requiredValidationDependsOnNetwork
        self.buildsProductionDataPlatform = evidence.buildsProductionDataPlatform
        self.runsProductionDataObservability = evidence.runsProductionDataObservability
        self.performsAutomaticDownload = evidence.performsAutomaticDownload
        self.performsAutomaticRepair = evidence.performsAutomaticRepair
        self.performsBrokerAccountReconciliation = evidence.performsBrokerAccountReconciliation
        self.implementsSimulatedExchangeBacktestParity = evidence.implementsSimulatedExchangeBacktestParity
        self.exposesDatabaseSchema = evidence.exposesDatabaseSchema || reportInput.exposesDatabaseSchema
        self.exposesAdapterRequest = evidence.exposesAdapterRequest || reportInput.exposesAdapterRequest
        self.readsRuntimeObject = evidence.readsRuntimeObject || reportInput.readsRuntimeObject
        self.readsSecret = evidence.readsSecret
        self.usesSignedEndpoint = evidence.usesSignedEndpoint
        self.callsAccountEndpoint = evidence.callsAccountEndpoint
        self.createsListenKey = evidence.createsListenKey
        self.connectsBroker = evidence.connectsBroker
        self.implementsLiveExecutionAdapter = evidence.implementsLiveExecutionAdapter
        self.implementsOMS = evidence.implementsOMS
        self.implementsRealOrderLifecycle = evidence.implementsRealOrderLifecycle
        self.runsLiveRuntime = evidence.runsLiveRuntime
        self.providesCommandSurface = false
        self.providesOrderLevelCommand = false
        self.supportsQueryLanguage = false
        self.providesLiveCommand = evidence.providesLiveCommand
        self.providesTradingButton = evidence.providesTradingButton
        self.authorizesLiveTrading = false
        self.touchesBrokerAction = false
        self.authorizesTradingExecution = false
        self.readModelOnlyBoundaryHeld = evidence.evidenceBoundaryHeld
            && reportInput.reportInputBoundaryHeld
            && reportReproducibilityEvidenceHeld
            && requiredValidationDependsOnNetwork == false
            && buildsProductionDataPlatform == false
            && runsProductionDataObservability == false
            && performsAutomaticDownload == false
            && performsAutomaticRepair == false
            && performsBrokerAccountReconciliation == false
            && implementsSimulatedExchangeBacktestParity == false
            && self.exposesDatabaseSchema == false
            && self.exposesAdapterRequest == false
            && self.readsRuntimeObject == false
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
            && supportsQueryLanguage == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }

    private static func makeTimelineEntries(
        evidenceID: String,
        replay: ScenarioReplayEvidence,
        quality: ScenarioDataQualityGateEvaluation,
        reportInput: ScenarioReportInputVersion
    ) -> [ScenarioReplayEvidenceTimelineEntry] {
        let prefix = evidenceID
        let replayEntries = [
            ScenarioReplayEvidenceTimelineEntry(
                entryID: "\(prefix)-window",
                kind: "replay window",
                title: "Scenario replay window",
                summary: "window=\(reportInput.replayWindowDescription); records=\(replay.replayWindow.recordCount); scenario=\(reportInput.scenarioID.rawValue)",
                sourceAnchor: "MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE"
            ),
            ScenarioReplayEvidenceTimelineEntry(
                entryID: "\(prefix)-cursor",
                kind: "replay cursor",
                title: "Scenario replay cursor",
                summary: replay.cursorSummary.summaryLine,
                sourceAnchor: "MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS"
            ),
            ScenarioReplayEvidenceTimelineEntry(
                entryID: "\(prefix)-checksum",
                kind: "checksum",
                title: "Scenario replay checksum",
                summary: "\(replay.checksumEvidence.algorithm)=\(reportInput.checksum)",
                sourceAnchor: "MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS"
            ),
            ScenarioReplayEvidenceTimelineEntry(
                entryID: "\(prefix)-freshness",
                kind: "freshness",
                title: "Scenario replay freshness",
                summary: "freshness=\(reportInput.freshnessStatus.rawValue); \(replay.freshnessEvidence.freshnessSummary)",
                sourceAnchor: "MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS"
            )
        ]
        let gateEntries = quality.gates.map { gate in
            ScenarioReplayEvidenceTimelineEntry(
                entryID: "\(prefix)-gate-\(gate.kind.rawValue.replacingOccurrences(of: " ", with: "-"))",
                kind: "quality gate",
                title: "Scenario data quality gate",
                summary: "\(gate.kind.rawValue)=\(gate.verdict.rawValue); expected=\(gate.expected); actual=\(gate.actual)",
                sourceAnchor: "MTP-108-QUALITY-GATE-TIMELINE"
            )
        }
        return replayEntries + gateEntries
    }
}

/// ScenarioReplayEvidenceReadModel 汇总 Report / Workbench / Events 可消费的 scenario replay 输入。
///
/// 上游只需要传入已经由 Core deterministic fixture 或后续 projection 生成的 evidence item；App 层只
/// 排序、聚合和暴露 read-model-only boundary，不触发 replay、不读 schema、不调用 adapter。
public struct ScenarioReplayEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [ScenarioReplayEvidenceItem]
    public let lastAppliedSequence: Int?

    /// MTP-108 的机械验收 anchors；只用于验证 App read-model surface 是否完整接入。
    public static let validationAnchors: [String] = [
        "MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE",
        "MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE",
        "MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN",
        "MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS",
        "MTP-108-QUALITY-GATE-TIMELINE",
        "MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
        "MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION"
    ]

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        items: [ScenarioReplayEvidenceItem] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.items = items.sorted { left, right in
            if left.scenarioID != right.scenarioID {
                return left.scenarioID < right.scenarioID
            }
            return left.fixtureVersion < right.fixtureVersion
        }
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly && items.allSatisfy(\.readModelOnlyBoundaryHeld)
    }

    public static var deterministicFixture: ScenarioReplayEvidenceReadModel {
        ScenarioReplayEvidenceReadModel(items: [ScenarioReplayEvidenceItem()])
    }
}

/// ScenarioReplayEvidenceViewModel 是 Dashboard / Report / Workbench / Events 的可编码只读快照。
///
/// ViewModel 只从 `ScenarioReplayEvidenceReadModel` 派生计数、ID、quality verdict、timeline 和
/// boundary flags。它不提供按钮、查询语言、命令模型、下载控制台、Live PRO Console 或交易授权。
public struct ScenarioReplayEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [ScenarioReplayEvidenceItem]
    public let evidenceCount: Int
    public let scenarioIDs: [String]
    public let datasetVersions: [String]
    public let fixtureVersions: [String]
    public let symbols: [String]
    public let timeframes: [String]
    public let replayWindows: [String]
    public let cursorSummaries: [String]
    public let checksums: [String]
    public let freshnessStatuses: [ScenarioReplayFreshnessStatus]
    public let qualityVerdicts: [ScenarioDataQualityVerdict]
    public let reportInputVersionIdentities: [String]
    public let drillDownEntries: [String]
    public let timelineEntries: [ScenarioReplayEvidenceTimelineEntry]
    public let timelineEntryCount: Int
    public let qualityGateTimelineCount: Int
    public let allQualityAccepted: Bool
    public let reportReproducibilityEvidenceHeld: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let supportsQueryLanguage: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: ScenarioReplayEvidenceReadModel) {
        let items = readModel.items
        let timelineEntries = items.flatMap(\.timelineEntries)
        let exposesDatabaseSchema = readModel.source.exposesDatabaseTables
            || readModel.source.exposesORMModels
            || items.contains(where: \.exposesDatabaseSchema)
        let exposesRuntimeObject = readModel.source.exposesRuntimeObjects
            || items.contains(where: \.readsRuntimeObject)
        let exposesAdapterRequest = readModel.source.callsBinanceAdapter
            || items.contains(where: \.exposesAdapterRequest)
        let providesCommandSurface = items.contains(where: \.providesCommandSurface)
        let providesOrderLevelCommand = items.contains(where: \.providesOrderLevelCommand)
        let supportsQueryLanguage = items.contains(where: \.supportsQueryLanguage)
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
        self.cursorSummaries = items.map(\.cursorSummary)
        self.checksums = items.map(\.checksum).uniqueSortedStrings()
        self.freshnessStatuses = items.map(\.freshnessStatus).uniqueFreshnessStatuses()
        self.qualityVerdicts = items.map(\.qualityVerdict).uniqueQualityVerdicts()
        self.reportInputVersionIdentities = items.map(\.reportInputVersionIdentity)
        self.drillDownEntries = items.map(\.drillDownEntry)
        self.timelineEntries = timelineEntries
        self.timelineEntryCount = timelineEntries.count
        self.qualityGateTimelineCount = timelineEntries.filter { $0.kind == "quality gate" }.count
        self.allQualityAccepted = items.isEmpty == false && items.allSatisfy {
            $0.qualityVerdict == .accepted
        }
        self.reportReproducibilityEvidenceHeld = items.isEmpty
            || items.allSatisfy(\.reportReproducibilityEvidenceHeld)
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.supportsQueryLanguage = supportsQueryLanguage
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
            && supportsQueryLanguage == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}

private extension Array where Element == ScenarioReplayFreshnessStatus {
    func uniqueFreshnessStatuses() -> [ScenarioReplayFreshnessStatus] {
        var seen = Set<ScenarioReplayFreshnessStatus>()
        var values: [ScenarioReplayFreshnessStatus] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}

private extension Array where Element == ScenarioDataQualityVerdict {
    func uniqueQualityVerdicts() -> [ScenarioDataQualityVerdict] {
        var seen = Set<ScenarioDataQualityVerdict>()
        var values: [ScenarioDataQualityVerdict] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}
