import DomainModel
import Foundation

/// MTP-120 Workbench beta demo scenario 只固定本地 beta fixture 选择与 evidence wiring。
///
/// 本文件复用已完成的 L1.5 Scenario Replay 与 L2 Simulated Exchange / Backtest Parity
/// deterministic evidence，把它们绑定为后续 first-run、Report / Dashboard / Events acceptance path
/// 可以消费的稳定输入。它不新增 fixture 数据、不下载真实历史数据、不实现 production data catalog、
/// 不启动 Runtime job，也不接 signed endpoint、account endpoint、listenKey、broker、OMS、Live PRO
/// Console、live command 或交易按钮。

/// DashboardBetaDemoScenarioSelection 固定 MTP-120 允许进入 beta demo 的唯一 scenario identity。
///
/// Selection 只表达选择合同：scenario id、dataset version、fixture version、symbol、timeframe、
/// source anchors 和 validation anchors。所有外部系统、真实交易和 production data capability flag
/// 必须保持 false，Codable 解码也会重新执行同一校验。
public struct DashboardBetaDemoScenarioSelection: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let selectedForLocalBetaDemo: Bool
    public let usesLocalDeterministicFixture: Bool
    public let bindsScenarioReplayEvidence: Bool
    public let bindsSimulatedExchangeParityEvidence: Bool
    public let outputsChecksumFreshnessEvidence: Bool
    public let recordsL15L2Relationship: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let downloadsRealNetworkData: Bool
    public let runsLargeScaleIngestionPipeline: Bool
    public let buildsProductionDataPlatform: Bool
    public let performsAutomaticDownload: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let modifiesFigma: Bool
    public let runsGraphify: Bool

    public var demoScenarioIdentity: String {
        [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            symbol.rawValue,
            timeframe.rawValue
        ].joined(separator: "|")
    }

    public var selectionBoundaryHeld: Bool {
        scenarioID == Self.requiredScenarioID
            && datasetVersion == Self.requiredDatasetVersion
            && fixtureVersion == Self.requiredFixtureVersion
            && symbol == Self.requiredSymbol
            && timeframe == Self.requiredTimeframe
            && sourceAnchors == Self.requiredSourceAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && selectedForLocalBetaDemo
            && usesLocalDeterministicFixture
            && bindsScenarioReplayEvidence
            && bindsSimulatedExchangeParityEvidence
            && outputsChecksumFreshnessEvidence
            && recordsL15L2Relationship
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && downloadsRealNetworkData == false
            && runsLargeScaleIngestionPipeline == false
            && buildsProductionDataPlatform == false
            && performsAutomaticDownload == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && modifiesFigma == false
            && runsGraphify == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-120-workbench-beta-demo-scenario-selection"),
        issueID: Identifier = try! Identifier("MTP-120"),
        scenarioID: ScenarioID = Self.requiredScenarioID,
        datasetVersion: DatasetVersion = Self.requiredDatasetVersion,
        fixtureVersion: FixtureVersion = Self.requiredFixtureVersion,
        symbol: Symbol = Self.requiredSymbol,
        timeframe: Timeframe = Self.requiredTimeframe,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        selectedForLocalBetaDemo: Bool = true,
        usesLocalDeterministicFixture: Bool = true,
        bindsScenarioReplayEvidence: Bool = true,
        bindsSimulatedExchangeParityEvidence: Bool = true,
        outputsChecksumFreshnessEvidence: Bool = true,
        recordsL15L2Relationship: Bool = true,
        requiredValidationDependsOnNetwork: Bool = false,
        downloadsRealNetworkData: Bool = false,
        runsLargeScaleIngestionPipeline: Bool = false,
        buildsProductionDataPlatform: Bool = false,
        performsAutomaticDownload: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        modifiesFigma: Bool = false,
        runsGraphify: Bool = false
    ) throws {
        try Self.validate(
            scenarioID: scenarioID,
            datasetVersion: datasetVersion,
            fixtureVersion: fixtureVersion,
            symbol: symbol,
            timeframe: timeframe,
            sourceAnchors: sourceAnchors,
            validationAnchors: validationAnchors,
            selectedForLocalBetaDemo: selectedForLocalBetaDemo,
            usesLocalDeterministicFixture: usesLocalDeterministicFixture,
            bindsScenarioReplayEvidence: bindsScenarioReplayEvidence,
            bindsSimulatedExchangeParityEvidence: bindsSimulatedExchangeParityEvidence,
            outputsChecksumFreshnessEvidence: outputsChecksumFreshnessEvidence,
            recordsL15L2Relationship: recordsL15L2Relationship,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsLargeScaleIngestionPipeline: runsLargeScaleIngestionPipeline,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            performsAutomaticDownload: performsAutomaticDownload,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            modifiesFigma: modifiesFigma,
            runsGraphify: runsGraphify
        )

        self.contractID = contractID
        self.issueID = issueID
        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.sourceAnchors = sourceAnchors
        self.validationAnchors = validationAnchors
        self.selectedForLocalBetaDemo = selectedForLocalBetaDemo
        self.usesLocalDeterministicFixture = usesLocalDeterministicFixture
        self.bindsScenarioReplayEvidence = bindsScenarioReplayEvidence
        self.bindsSimulatedExchangeParityEvidence = bindsSimulatedExchangeParityEvidence
        self.outputsChecksumFreshnessEvidence = outputsChecksumFreshnessEvidence
        self.recordsL15L2Relationship = recordsL15L2Relationship
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.runsLargeScaleIngestionPipeline = runsLargeScaleIngestionPipeline
        self.buildsProductionDataPlatform = buildsProductionDataPlatform
        self.performsAutomaticDownload = performsAutomaticDownload
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.modifiesFigma = modifiesFigma
        self.runsGraphify = runsGraphify
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            scenarioID: try container.decode(ScenarioID.self, forKey: .scenarioID),
            datasetVersion: try container.decode(DatasetVersion.self, forKey: .datasetVersion),
            fixtureVersion: try container.decode(FixtureVersion.self, forKey: .fixtureVersion),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            selectedForLocalBetaDemo: try container.decode(Bool.self, forKey: .selectedForLocalBetaDemo),
            usesLocalDeterministicFixture: try container.decode(Bool.self, forKey: .usesLocalDeterministicFixture),
            bindsScenarioReplayEvidence: try container.decode(Bool.self, forKey: .bindsScenarioReplayEvidence),
            bindsSimulatedExchangeParityEvidence: try container.decode(
                Bool.self,
                forKey: .bindsSimulatedExchangeParityEvidence
            ),
            outputsChecksumFreshnessEvidence: try container.decode(
                Bool.self,
                forKey: .outputsChecksumFreshnessEvidence
            ),
            recordsL15L2Relationship: try container.decode(Bool.self, forKey: .recordsL15L2Relationship),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            runsLargeScaleIngestionPipeline: try container.decode(
                Bool.self,
                forKey: .runsLargeScaleIngestionPipeline
            ),
            buildsProductionDataPlatform: try container.decode(Bool.self, forKey: .buildsProductionDataPlatform),
            performsAutomaticDownload: try container.decode(Bool.self, forKey: .performsAutomaticDownload),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            modifiesFigma: try container.decode(Bool.self, forKey: .modifiesFigma),
            runsGraphify: try container.decode(Bool.self, forKey: .runsGraphify)
        )
    }

    public static let deterministicFixture: DashboardBetaDemoScenarioSelection = {
        do {
            return try DashboardBetaDemoScenarioSelection()
        } catch {
            preconditionFailure("MTP-120 beta demo scenario selection must be valid: \(error)")
        }
    }()

    public static let requiredScenarioID = try! ScenarioID("mtp-104-btcusdt-1m-first-scenario")
    public static let requiredDatasetVersion = try! DatasetVersion("dataset-v1")
    public static let requiredFixtureVersion = try! FixtureVersion("fixture-v1")
    public static let requiredSymbol = try! Symbol(rawValue: "BTCUSDT")
    public static let requiredTimeframe = Timeframe.oneMinute

    public static let requiredSourceAnchors: [String] = [
        "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
        "MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE",
        "MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION",
        "MTP-107-REPORT-INPUT-VERSIONING",
        "MTP-112-SCENARIO-REPLAY-DETERMINISTIC-MATCHING",
        "MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-120-DEMO-SCENARIO-SELECTION",
        "MTP-120-DATASET-FIXTURE-VERSION-LOCK",
        "MTP-120-SCENARIO-REPLAY-FIXTURE-WIRING",
        "MTP-120-CHECKSUM-FRESHNESS-EVIDENCE",
        "MTP-120-L15-L2-EVIDENCE-RELATIONSHIP",
        "MTP-120-NO-NETWORK-DOWNLOAD-LIVE-BROKER",
        "MTP-120-DEMO-SCENARIO-FIXTURE-VALIDATION",
        "TVM-WORKBENCH-BETA-READINESS"
    ]

    private static func validate(
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        fixtureVersion: FixtureVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        sourceAnchors: [String],
        validationAnchors: [String],
        selectedForLocalBetaDemo: Bool,
        usesLocalDeterministicFixture: Bool,
        bindsScenarioReplayEvidence: Bool,
        bindsSimulatedExchangeParityEvidence: Bool,
        outputsChecksumFreshnessEvidence: Bool,
        recordsL15L2Relationship: Bool,
        requiredValidationDependsOnNetwork: Bool,
        downloadsRealNetworkData: Bool,
        runsLargeScaleIngestionPipeline: Bool,
        buildsProductionDataPlatform: Bool,
        performsAutomaticDownload: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        modifiesFigma: Bool,
        runsGraphify: Bool
    ) throws {
        let actualIdentity = [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            symbol.rawValue,
            timeframe.rawValue
        ].joined(separator: "|")
        let expectedIdentity = [
            requiredScenarioID.rawValue,
            requiredDatasetVersion.rawValue,
            requiredFixtureVersion.rawValue,
            requiredSymbol.rawValue,
            requiredTimeframe.rawValue
        ].joined(separator: "|")
        guard actualIdentity == expectedIdentity else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoScenarioSelection.identity",
                expected: expectedIdentity,
                actual: actualIdentity
            )
        }
        try validateList(
            field: "workbenchBetaDemoScenarioSelection.sourceAnchors",
            expected: requiredSourceAnchors,
            actual: sourceAnchors
        )
        try validateList(
            field: "workbenchBetaDemoScenarioSelection.validationAnchors",
            expected: requiredValidationAnchors,
            actual: validationAnchors
        )
        let requiredTrueFlags = [
            ("selectedForLocalBetaDemo", selectedForLocalBetaDemo),
            ("usesLocalDeterministicFixture", usesLocalDeterministicFixture),
            ("bindsScenarioReplayEvidence", bindsScenarioReplayEvidence),
            ("bindsSimulatedExchangeParityEvidence", bindsSimulatedExchangeParityEvidence),
            ("outputsChecksumFreshnessEvidence", outputsChecksumFreshnessEvidence),
            ("recordsL15L2Relationship", recordsL15L2Relationship)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoScenarioSelection.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
        try validateForbiddenFlags(
            prefix: "workbenchBetaDemoScenarioSelection",
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsLargeScaleIngestionPipeline: runsLargeScaleIngestionPipeline,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            performsAutomaticDownload: performsAutomaticDownload,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            modifiesFigma: modifiesFigma,
            runsGraphify: runsGraphify
        )
    }
}

/// DashboardBetaDemoFixtureEvidence 把被选择的 beta scenario 绑定到 L1.5 / L2 deterministic evidence。
///
/// Evidence 输出 checksum、freshness、report input version、simulated parity identity 和 relationship
/// summary，供后续 issue 在 read-model-only 路径中消费。它只做值对象校验和证据复制，不启动 replay
/// job、不读取 schema、不下载数据、不执行撮合 runtime，也不产生任何真实交易授权。
public struct DashboardBetaDemoFixtureEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let selection: DashboardBetaDemoScenarioSelection
    public let scenarioReplayEvidence: ScenarioDataQualityReportInputEvidence
    public let simulatedParityEvidence: SimulatedExchangePortfolioProjectionParityEvidence
    public let checksum: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let qualityVerdict: ScenarioDataQualityVerdict
    public let reportInputVersionIdentity: String
    public let simulatedParityEvidenceIdentity: String
    public let deterministicDemoIdentity: String
    public let relationshipSummary: String
    public let validationAnchors: [String]
    public let scenarioReplayWiringHeld: Bool
    public let simulatedParityWiringHeld: Bool
    public let localDeterministicFixtureOnly: Bool
    public let readModelOnlyHandoff: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let downloadsRealNetworkData: Bool
    public let runsLargeScaleIngestionPipeline: Bool
    public let buildsProductionDataPlatform: Bool
    public let performsAutomaticDownload: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let modifiesFigma: Bool
    public let runsGraphify: Bool

    public var fixtureWiringBoundaryHeld: Bool {
        selection.selectionBoundaryHeld
            && scenarioReplayEvidence.evidenceBoundaryHeld
            && simulatedParityEvidence.parityEvidenceBoundaryHeld
            && scenarioReplayWiringHeld
            && simulatedParityWiringHeld
            && localDeterministicFixtureOnly
            && readModelOnlyHandoff
            && checksum == scenarioReplayEvidence.reportInputVersion.checksum
            && freshnessStatus == .fresh
            && qualityVerdict == .accepted
            && validationAnchors == DashboardBetaDemoScenarioSelection.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && downloadsRealNetworkData == false
            && runsLargeScaleIngestionPipeline == false
            && buildsProductionDataPlatform == false
            && performsAutomaticDownload == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && modifiesFigma == false
            && runsGraphify == false
    }

    public init(
        evidenceID: Identifier = try! Identifier("mtp-120-workbench-beta-demo-fixture-evidence"),
        issueID: Identifier = try! Identifier("MTP-120"),
        selection: DashboardBetaDemoScenarioSelection = .deterministicFixture,
        scenarioReplayEvidence: ScenarioDataQualityReportInputEvidence = .deterministicFixture,
        simulatedParityEvidence: SimulatedExchangePortfolioProjectionParityEvidence =
            try! SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence(),
        validationAnchors: [String] = DashboardBetaDemoScenarioSelection.requiredValidationAnchors,
        scenarioReplayWiringHeld: Bool = true,
        simulatedParityWiringHeld: Bool = true,
        localDeterministicFixtureOnly: Bool = true,
        readModelOnlyHandoff: Bool = true,
        requiredValidationDependsOnNetwork: Bool = false,
        downloadsRealNetworkData: Bool = false,
        runsLargeScaleIngestionPipeline: Bool = false,
        buildsProductionDataPlatform: Bool = false,
        performsAutomaticDownload: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        modifiesFigma: Bool = false,
        runsGraphify: Bool = false
    ) throws {
        try Self.validate(
            selection: selection,
            scenarioReplayEvidence: scenarioReplayEvidence,
            simulatedParityEvidence: simulatedParityEvidence,
            validationAnchors: validationAnchors,
            scenarioReplayWiringHeld: scenarioReplayWiringHeld,
            simulatedParityWiringHeld: simulatedParityWiringHeld,
            localDeterministicFixtureOnly: localDeterministicFixtureOnly,
            readModelOnlyHandoff: readModelOnlyHandoff,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsLargeScaleIngestionPipeline: runsLargeScaleIngestionPipeline,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            performsAutomaticDownload: performsAutomaticDownload,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            modifiesFigma: modifiesFigma,
            runsGraphify: runsGraphify
        )

        let reportInput = scenarioReplayEvidence.reportInputVersion
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.selection = selection
        self.scenarioReplayEvidence = scenarioReplayEvidence
        self.simulatedParityEvidence = simulatedParityEvidence
        self.checksum = reportInput.checksum
        self.freshnessStatus = reportInput.freshnessStatus
        self.qualityVerdict = reportInput.qualityVerdict
        self.reportInputVersionIdentity = reportInput.versionIdentity
        self.simulatedParityEvidenceIdentity = simulatedParityEvidence.deterministicResultIdentity
        self.deterministicDemoIdentity = [
            selection.demoScenarioIdentity,
            reportInput.versionIdentity,
            simulatedParityEvidence.deterministicResultIdentity
        ].joined(separator: "|")
        self.relationshipSummary = [
            "scenario=\(selection.scenarioID.rawValue)",
            "dataset=\(selection.datasetVersion.rawValue)",
            "fixture=\(selection.fixtureVersion.rawValue)",
            "checksum=\(reportInput.checksum)",
            "freshness=\(reportInput.freshnessStatus.rawValue)",
            "quality=\(reportInput.qualityVerdict.rawValue)",
            "l15=Scenario Replay",
            "l2=Simulated Exchange Backtest Parity"
        ].joined(separator: "; ")
        self.validationAnchors = validationAnchors
        self.scenarioReplayWiringHeld = scenarioReplayWiringHeld
        self.simulatedParityWiringHeld = simulatedParityWiringHeld
        self.localDeterministicFixtureOnly = localDeterministicFixtureOnly
        self.readModelOnlyHandoff = readModelOnlyHandoff
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
            || scenarioReplayEvidence.requiredValidationDependsOnNetwork
            || simulatedParityEvidence.requiredValidationDependsOnNetwork
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.runsLargeScaleIngestionPipeline = runsLargeScaleIngestionPipeline
        self.buildsProductionDataPlatform = buildsProductionDataPlatform
        self.performsAutomaticDownload = performsAutomaticDownload
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.modifiesFigma = modifiesFigma
        self.runsGraphify = runsGraphify
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rebuilt = try DashboardBetaDemoFixtureEvidence(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            selection: try container.decode(DashboardBetaDemoScenarioSelection.self, forKey: .selection),
            scenarioReplayEvidence: try container.decode(
                ScenarioDataQualityReportInputEvidence.self,
                forKey: .scenarioReplayEvidence
            ),
            simulatedParityEvidence: try container.decode(
                SimulatedExchangePortfolioProjectionParityEvidence.self,
                forKey: .simulatedParityEvidence
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            scenarioReplayWiringHeld: try container.decode(Bool.self, forKey: .scenarioReplayWiringHeld),
            simulatedParityWiringHeld: try container.decode(Bool.self, forKey: .simulatedParityWiringHeld),
            localDeterministicFixtureOnly: try container.decode(Bool.self, forKey: .localDeterministicFixtureOnly),
            readModelOnlyHandoff: try container.decode(Bool.self, forKey: .readModelOnlyHandoff),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            runsLargeScaleIngestionPipeline: try container.decode(
                Bool.self,
                forKey: .runsLargeScaleIngestionPipeline
            ),
            buildsProductionDataPlatform: try container.decode(Bool.self, forKey: .buildsProductionDataPlatform),
            performsAutomaticDownload: try container.decode(Bool.self, forKey: .performsAutomaticDownload),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            modifiesFigma: try container.decode(Bool.self, forKey: .modifiesFigma),
            runsGraphify: try container.decode(Bool.self, forKey: .runsGraphify)
        )

        let decodedChecksum = try container.decode(String.self, forKey: .checksum)
        let decodedFreshness = try container.decode(ScenarioReplayFreshnessStatus.self, forKey: .freshnessStatus)
        let decodedQuality = try container.decode(ScenarioDataQualityVerdict.self, forKey: .qualityVerdict)
        let decodedReportInput = try container.decode(String.self, forKey: .reportInputVersionIdentity)
        let decodedParity = try container.decode(String.self, forKey: .simulatedParityEvidenceIdentity)
        let decodedIdentity = try container.decode(String.self, forKey: .deterministicDemoIdentity)
        let decodedRelationship = try container.decode(String.self, forKey: .relationshipSummary)
        guard decodedChecksum == rebuilt.checksum,
              decodedFreshness == rebuilt.freshnessStatus,
              decodedQuality == rebuilt.qualityVerdict,
              decodedReportInput == rebuilt.reportInputVersionIdentity,
              decodedParity == rebuilt.simulatedParityEvidenceIdentity,
              decodedIdentity == rebuilt.deterministicDemoIdentity,
              decodedRelationship == rebuilt.relationshipSummary else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoFixtureEvidence.derivedEvidence",
                expected: rebuilt.deterministicDemoIdentity,
                actual: decodedIdentity
            )
        }

        self = rebuilt
    }

    public static let deterministicFixture: DashboardBetaDemoFixtureEvidence = {
        do {
            return try DashboardBetaDemoFixtureEvidence()
        } catch {
            preconditionFailure("MTP-120 beta demo fixture evidence must be valid: \(error)")
        }
    }()

    /// containsForbiddenCapabilityText 用于测试 demo identity / relationship summary 没有混入禁区能力文本。
    public func containsForbiddenCapabilityText(_ forbiddenTokens: [String]) -> Bool {
        let serialized = [
            deterministicDemoIdentity,
            relationshipSummary,
            reportInputVersionIdentity
        ]
        .joined(separator: " ")
        .lowercased()

        return forbiddenTokens.contains { token in
            serialized.contains(token.lowercased())
        }
    }

    private static func validate(
        selection: DashboardBetaDemoScenarioSelection,
        scenarioReplayEvidence: ScenarioDataQualityReportInputEvidence,
        simulatedParityEvidence: SimulatedExchangePortfolioProjectionParityEvidence,
        validationAnchors: [String],
        scenarioReplayWiringHeld: Bool,
        simulatedParityWiringHeld: Bool,
        localDeterministicFixtureOnly: Bool,
        readModelOnlyHandoff: Bool,
        requiredValidationDependsOnNetwork: Bool,
        downloadsRealNetworkData: Bool,
        runsLargeScaleIngestionPipeline: Bool,
        buildsProductionDataPlatform: Bool,
        performsAutomaticDownload: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        modifiesFigma: Bool,
        runsGraphify: Bool
    ) throws {
        guard selection.selectionBoundaryHeld else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoFixtureEvidence.selection",
                expected: "selection boundary held",
                actual: "false"
            )
        }
        let reportInput = scenarioReplayEvidence.reportInputVersion
        let parityReportInput = simulatedParityEvidence.reportInputVersion
        let expectedIdentity = selection.demoScenarioIdentity
        let actualReplayIdentity = [
            reportInput.scenarioID.rawValue,
            reportInput.datasetVersion.rawValue,
            reportInput.fixtureVersion.rawValue,
            reportInput.symbol.rawValue,
            reportInput.timeframe.rawValue
        ].joined(separator: "|")
        let actualParityIdentity = [
            parityReportInput.scenarioID.rawValue,
            parityReportInput.datasetVersion.rawValue,
            parityReportInput.fixtureVersion.rawValue,
            parityReportInput.symbol.rawValue,
            parityReportInput.timeframe.rawValue
        ].joined(separator: "|")
        guard actualReplayIdentity == expectedIdentity,
              actualParityIdentity == expectedIdentity,
              reportInput.versionIdentity == parityReportInput.versionIdentity else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoFixtureEvidence.evidenceIdentity",
                expected: expectedIdentity,
                actual: "replay=\(actualReplayIdentity); parity=\(actualParityIdentity)"
            )
        }
        guard scenarioReplayEvidence.evidenceBoundaryHeld,
              simulatedParityEvidence.parityEvidenceBoundaryHeld,
              reportInput.checksum == "fnv1a64:3c6cd4ff13cd4062",
              reportInput.freshnessStatus == .fresh,
              reportInput.qualityVerdict == .accepted else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoFixtureEvidence.replayParityEvidence",
                expected: "accepted local deterministic replay and parity evidence",
                actual: "\(reportInput.checksum)|\(reportInput.freshnessStatus.rawValue)|\(reportInput.qualityVerdict.rawValue)"
            )
        }
        try DashboardBetaDemoScenarioSelection.validateList(
            field: "workbenchBetaDemoFixtureEvidence.validationAnchors",
            expected: DashboardBetaDemoScenarioSelection.requiredValidationAnchors,
            actual: validationAnchors
        )
        let requiredTrueFlags = [
            ("scenarioReplayWiringHeld", scenarioReplayWiringHeld),
            ("simulatedParityWiringHeld", simulatedParityWiringHeld),
            ("localDeterministicFixtureOnly", localDeterministicFixtureOnly),
            ("readModelOnlyHandoff", readModelOnlyHandoff)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: "workbenchBetaDemoFixtureEvidence.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
        try DashboardBetaDemoScenarioSelection.validateForbiddenFlags(
            prefix: "workbenchBetaDemoFixtureEvidence",
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
                || scenarioReplayEvidence.requiredValidationDependsOnNetwork
                || simulatedParityEvidence.requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsLargeScaleIngestionPipeline: runsLargeScaleIngestionPipeline,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            performsAutomaticDownload: performsAutomaticDownload,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            modifiesFigma: modifiesFigma,
            runsGraphify: runsGraphify
        )
    }
}

fileprivate extension DashboardBetaDemoScenarioSelection {
    static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.workbenchBetaReadinessContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    static func validateForbiddenFlags(
        prefix: String,
        requiredValidationDependsOnNetwork: Bool,
        downloadsRealNetworkData: Bool,
        runsLargeScaleIngestionPipeline: Bool,
        buildsProductionDataPlatform: Bool,
        performsAutomaticDownload: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        modifiesFigma: Bool,
        runsGraphify: Bool
    ) throws {
        let forbiddenFlags = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("downloadsRealNetworkData", downloadsRealNetworkData),
            ("runsLargeScaleIngestionPipeline", runsLargeScaleIngestionPipeline),
            ("buildsProductionDataPlatform", buildsProductionDataPlatform),
            ("performsAutomaticDownload", performsAutomaticDownload),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton),
            ("modifiesFigma", modifiesFigma),
            ("runsGraphify", runsGraphify)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.workbenchBetaReadinessForbiddenCapability("\(prefix).\(capability.0)")
        }
    }
}
