import DomainModel
import Foundation

/// Data Catalog / Scenario Replay 边界定义 MTP-103 的术语、目标引擎职责和禁止能力基线。
///
/// 本文件只提供可编码、可测试的合同 fixture，用于固定 local-first、deterministic、versioned
/// scenario replay 共同语言。它不解析 manifest、不新增 fixture 数据、不实现 replay cursor、
/// report input versioning、生产数据平台、真实网络下载、signed/account/listenKey、broker、OMS、
/// LiveExecutionAdapter、live command 或交易按钮。

/// DataCatalogScenarioReplayTerm 固定 MTP-103 允许命名的 Data Catalog / Scenario Replay 术语。
///
/// 这些术语只是后续 scenario manifest、fixture、replay evidence、quality gate 和 report input
/// versioning 的共同语言；当前 issue 不能把任一术语实现为 parser、runtime、data platform 或 UI command。
public enum DataCatalogScenarioReplayTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localDataCatalog = "local data catalog"
    case scenarioReplay = "scenario replay"
    case scenarioManifest = "scenario manifest"
    case scenarioID = "scenario id"
    case datasetVersion = "dataset version"
    case fixtureVersion = "fixture version"
    case replayWindow = "replay window"
    case replayCursor = "replay cursor"
    case checksumEvidence = "checksum evidence"
    case freshnessEvidence = "freshness evidence"
    case dataQualityGate = "data quality gate"
    case reportInputVersioning = "report input versioning"
    case workbenchScenarioReplayEvidence = "Workbench scenario replay evidence"
}

/// DataCatalogScenarioReplayTargetEngine 固定 MTP-103 的三类目标引擎职责。
///
/// `Data Engine` 只负责数据身份和 replay evidence 语言；`State & Persistence Engine` 只负责后续
/// append-only / versioned source facts 的持久化边界；`Workbench Interface` 只消费 read model evidence。
public enum DataCatalogScenarioReplayTargetEngine: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngine = "Data Engine"
    case statePersistenceEngine = "State & Persistence Engine"
    case workbenchInterface = "Workbench Interface"
}

/// DataCatalogScenarioReplayBoundaryPrinciple 描述 MTP-103 必须保持的边界原则。
///
/// 这些原则只服务本地可重复验证，不代表 production data platform、cloud data lake、
/// 实时 ingestion pipeline 或 Live / broker runtime 已进入当前 scope。
public enum DataCatalogScenarioReplayBoundaryPrinciple: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFirst = "local-first"
    case deterministicReplay = "deterministic scenario replay"
    case versionedInputIdentity = "versioned scenario input identity"
    case readModelOnlySurface = "read-model-only Workbench / Report / Events surface"
    case noProductionDataPlatform = "no production data platform"
    case noLiveBrokerSignedBoundary = "no Live / broker / signed endpoint boundary"
}

/// DataCatalogScenarioReplayForbiddenCapability 枚举 MTP-103 必须保持禁止的能力面。
///
/// 当前 issue 只能把这些能力作为 forbidden baseline 和 validation anchor；任何初始化或 Codable 解码
/// 试图打开这些能力都必须失败，避免后续 PR 把术语合同误升级为实现。
public enum DataCatalogScenarioReplayForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case scenarioManifestParser = "scenario manifest parser"
    case fixtureData = "fixture data"
    case replayCursorRuntime = "replay cursor runtime"
    case reportInputVersioningRuntime = "report input versioning runtime"
    case simulatedExchangeBacktestParityRuntime = "Simulated Exchange / Backtest Parity runtime"
    case secretRead = "secret read"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case brokerIntegration = "broker integration"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realOrderLifecycle = "real order lifecycle"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case reconciliation = "reconciliation"
    case realAccountBrokerPositionRead = "real account / broker position read"
    case liveRuntime = "live runtime"
    case liveCommand = "live command"
    case tradingButton = "trading button"
    case productionDataPlatform = "production data platform"
    case largeScaleIngestionPipeline = "large-scale ingestion pipeline"
    case realNetworkDownload = "real network download"
    case graphifyUpdate = "Graphify update"
    case figmaChange = "Figma change"
}

/// DataCatalogScenarioReplayEvidenceKind 限定 MTP-103 当前可以输出的非执行证据。
///
/// 允许证据只包括 contract、source docs、validation anchors、deterministic boundary fixture、
/// forbidden capability tests 和 PR boundary evidence，不包含 manifest 数据或 replay output。
public enum DataCatalogScenarioReplayEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case sourceDocsAnchor = "source docs anchor"
    case validationPlanAnchor = "validation plan anchor"
    case validationMatrixCandidate = "validation matrix candidate"
    case deterministicBoundaryFixture = "deterministic boundary fixture"
    case forbiddenCapabilityTest = "forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// DataCatalogScenarioReplayBoundary 是 MTP-103 的 local-first terminology / boundary fixture。
///
/// 该 fixture 把目标引擎职责、术语、local-first / deterministic / versioned boundary、
/// forbidden capability baseline、source docs anchors 和 validation anchors 固定为可测试值对象。
/// 它不持有数据记录、不读写文件、不访问网络、不暴露 persistence schema，也不启动任何 Runtime。
public struct DataCatalogScenarioReplayBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [DataCatalogScenarioReplayTerm]
    public let targetEngines: [DataCatalogScenarioReplayTargetEngine]
    public let boundaryPrinciples: [DataCatalogScenarioReplayBoundaryPrinciple]
    public let forbiddenCapabilities: [DataCatalogScenarioReplayForbiddenCapability]
    public let allowedEvidenceKinds: [DataCatalogScenarioReplayEvidenceKind]
    public let sourceDocumentAnchors: [String]
    public let validationAnchors: [String]
    public let isLocalFirst: Bool
    public let isDeterministic: Bool
    public let isVersioned: Bool
    public let exposesReadModelOnlySurface: Bool
    public let parsesScenarioManifest: Bool
    public let addsFixtureData: Bool
    public let implementsReplayCursor: Bool
    public let implementsReportInputVersioning: Bool
    public let implementsSimulatedExchangeBacktestParity: Bool
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
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let readsRealAccountOrBrokerPosition: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let buildsProductionDataPlatform: Bool
    public let buildsLargeScaleIngestionPipeline: Bool
    public let downloadsRealNetworkData: Bool
    public let runsGraphifyUpdate: Bool
    public let modifiesFigma: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var terminologyBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && targetEngines == Self.requiredTargetEngines
            && boundaryPrinciples == Self.requiredBoundaryPrinciples
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && sourceDocumentAnchors == Self.requiredSourceDocumentAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var targetEngineBoundaryHeld: Bool {
        targetEngines == Self.requiredTargetEngines
            && exposesReadModelOnlySurface
            && buildsProductionDataPlatform == false
            && buildsLargeScaleIngestionPipeline == false
            && downloadsRealNetworkData == false
    }

    public var localFirstDeterministicVersionedBoundaryHeld: Bool {
        isLocalFirst
            && isDeterministic
            && isVersioned
            && parsesScenarioManifest == false
            && addsFixtureData == false
            && implementsReplayCursor == false
            && implementsReportInputVersioning == false
            && requiredValidationDependsOnNetwork == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allForbiddenFlagsRemainFalse
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isLocalFirst
            && isDeterministic
            && isVersioned
            && exposesReadModelOnlySurface
            && parsesScenarioManifest == false
            && addsFixtureData == false
            && implementsReplayCursor == false
            && implementsReportInputVersioning == false
            && implementsSimulatedExchangeBacktestParity == false
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
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && readsRealAccountOrBrokerPosition == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && buildsProductionDataPlatform == false
            && buildsLargeScaleIngestionPipeline == false
            && downloadsRealNetworkData == false
            && runsGraphifyUpdate == false
            && modifiesFigma == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-103-data-catalog-scenario-replay-boundary"),
        issueID: Identifier = try! Identifier("MTP-103"),
        terms: [DataCatalogScenarioReplayTerm] = Self.requiredTerms,
        targetEngines: [DataCatalogScenarioReplayTargetEngine] = Self.requiredTargetEngines,
        boundaryPrinciples: [DataCatalogScenarioReplayBoundaryPrinciple] = Self.requiredBoundaryPrinciples,
        forbiddenCapabilities: [DataCatalogScenarioReplayForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [DataCatalogScenarioReplayEvidenceKind] = Self.allowedEvidenceKinds,
        sourceDocumentAnchors: [String] = Self.requiredSourceDocumentAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        isLocalFirst: Bool = true,
        isDeterministic: Bool = true,
        isVersioned: Bool = true,
        exposesReadModelOnlySurface: Bool = true,
        parsesScenarioManifest: Bool = false,
        addsFixtureData: Bool = false,
        implementsReplayCursor: Bool = false,
        implementsReportInputVersioning: Bool = false,
        implementsSimulatedExchangeBacktestParity: Bool = false,
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
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountOrBrokerPosition: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        buildsProductionDataPlatform: Bool = false,
        buildsLargeScaleIngestionPipeline: Bool = false,
        downloadsRealNetworkData: Bool = false,
        runsGraphifyUpdate: Bool = false,
        modifiesFigma: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            targetEngines: targetEngines,
            boundaryPrinciples: boundaryPrinciples,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            sourceDocumentAnchors: sourceDocumentAnchors,
            validationAnchors: validationAnchors
        )
        try Self.validateBoundaryFlags(
            isLocalFirst: isLocalFirst,
            isDeterministic: isDeterministic,
            isVersioned: isVersioned,
            exposesReadModelOnlySurface: exposesReadModelOnlySurface,
            parsesScenarioManifest: parsesScenarioManifest,
            addsFixtureData: addsFixtureData,
            implementsReplayCursor: implementsReplayCursor,
            implementsReportInputVersioning: implementsReportInputVersioning,
            implementsSimulatedExchangeBacktestParity: implementsSimulatedExchangeBacktestParity,
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
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountOrBrokerPosition: readsRealAccountOrBrokerPosition,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            buildsLargeScaleIngestionPipeline: buildsLargeScaleIngestionPipeline,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsGraphifyUpdate: runsGraphifyUpdate,
            modifiesFigma: modifiesFigma,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.targetEngines = targetEngines
        self.boundaryPrinciples = boundaryPrinciples
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.sourceDocumentAnchors = sourceDocumentAnchors
        self.validationAnchors = validationAnchors
        self.isLocalFirst = isLocalFirst
        self.isDeterministic = isDeterministic
        self.isVersioned = isVersioned
        self.exposesReadModelOnlySurface = exposesReadModelOnlySurface
        self.parsesScenarioManifest = parsesScenarioManifest
        self.addsFixtureData = addsFixtureData
        self.implementsReplayCursor = implementsReplayCursor
        self.implementsReportInputVersioning = implementsReportInputVersioning
        self.implementsSimulatedExchangeBacktestParity = implementsSimulatedExchangeBacktestParity
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
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.readsRealAccountOrBrokerPosition = readsRealAccountOrBrokerPosition
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.buildsProductionDataPlatform = buildsProductionDataPlatform
        self.buildsLargeScaleIngestionPipeline = buildsLargeScaleIngestionPipeline
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.runsGraphifyUpdate = runsGraphifyUpdate
        self.modifiesFigma = modifiesFigma
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([DataCatalogScenarioReplayTerm].self, forKey: .terms),
            targetEngines: try container.decode([DataCatalogScenarioReplayTargetEngine].self, forKey: .targetEngines),
            boundaryPrinciples: try container.decode(
                [DataCatalogScenarioReplayBoundaryPrinciple].self,
                forKey: .boundaryPrinciples
            ),
            forbiddenCapabilities: try container.decode(
                [DataCatalogScenarioReplayForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [DataCatalogScenarioReplayEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            sourceDocumentAnchors: try container.decode([String].self, forKey: .sourceDocumentAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            isLocalFirst: try container.decode(Bool.self, forKey: .isLocalFirst),
            isDeterministic: try container.decode(Bool.self, forKey: .isDeterministic),
            isVersioned: try container.decode(Bool.self, forKey: .isVersioned),
            exposesReadModelOnlySurface: try container.decode(Bool.self, forKey: .exposesReadModelOnlySurface),
            parsesScenarioManifest: try container.decode(Bool.self, forKey: .parsesScenarioManifest),
            addsFixtureData: try container.decode(Bool.self, forKey: .addsFixtureData),
            implementsReplayCursor: try container.decode(Bool.self, forKey: .implementsReplayCursor),
            implementsReportInputVersioning: try container.decode(
                Bool.self,
                forKey: .implementsReportInputVersioning
            ),
            implementsSimulatedExchangeBacktestParity: try container.decode(
                Bool.self,
                forKey: .implementsSimulatedExchangeBacktestParity
            ),
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
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            readsRealAccountOrBrokerPosition: try container.decode(
                Bool.self,
                forKey: .readsRealAccountOrBrokerPosition
            ),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            buildsProductionDataPlatform: try container.decode(Bool.self, forKey: .buildsProductionDataPlatform),
            buildsLargeScaleIngestionPipeline: try container.decode(
                Bool.self,
                forKey: .buildsLargeScaleIngestionPipeline
            ),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            runsGraphifyUpdate: try container.decode(Bool.self, forKey: .runsGraphifyUpdate),
            modifiesFigma: try container.decode(Bool.self, forKey: .modifiesFigma),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: DataCatalogScenarioReplayForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredTerms: [DataCatalogScenarioReplayTerm] = DataCatalogScenarioReplayTerm.allCases

    public static let requiredTargetEngines: [DataCatalogScenarioReplayTargetEngine] = [
        .dataEngine,
        .statePersistenceEngine,
        .workbenchInterface
    ]

    public static let requiredBoundaryPrinciples: [DataCatalogScenarioReplayBoundaryPrinciple] = [
        .localFirst,
        .deterministicReplay,
        .versionedInputIdentity,
        .readModelOnlySurface,
        .noProductionDataPlatform,
        .noLiveBrokerSignedBoundary
    ]

    public static let requiredForbiddenCapabilities: [DataCatalogScenarioReplayForbiddenCapability] =
        DataCatalogScenarioReplayForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [DataCatalogScenarioReplayEvidenceKind] = [
        .contractDocumentation,
        .sourceDocsAnchor,
        .validationPlanAnchor,
        .validationMatrixCandidate,
        .deterministicBoundaryFixture,
        .forbiddenCapabilityTest,
        .prBoundaryEvidence
    ]

    public static let requiredSourceDocumentAnchors: [String] = [
        "GOAL.md",
        "BLUEPRINT.md",
        "architecture.md",
        "docs/roadmap.md",
        "docs/domain/context.md",
        "docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md",
        "docs/validation/latest-verification-summary.md"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY",
        "MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY",
        "MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY",
        "MTP-103-FORBIDDEN-CAPABILITY-BASELINE",
        "MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY"
    ]

    public static let deterministicFixture: DataCatalogScenarioReplayBoundary = {
        do {
            return try DataCatalogScenarioReplayBoundary()
        } catch {
            preconditionFailure("MTP-103 Data Catalog / Scenario Replay boundary fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [DataCatalogScenarioReplayTerm],
        targetEngines: [DataCatalogScenarioReplayTargetEngine],
        boundaryPrinciples: [DataCatalogScenarioReplayBoundaryPrinciple],
        forbiddenCapabilities: [DataCatalogScenarioReplayForbiddenCapability],
        allowedEvidenceKinds: [DataCatalogScenarioReplayEvidenceKind],
        sourceDocumentAnchors: [String],
        validationAnchors: [String]
    ) throws {
        try validateList(
            field: "terms",
            expected: Self.requiredTerms.map(\.rawValue),
            actual: terms.map(\.rawValue)
        )
        try validateList(
            field: "targetEngines",
            expected: Self.requiredTargetEngines.map(\.rawValue),
            actual: targetEngines.map(\.rawValue)
        )
        try validateList(
            field: "boundaryPrinciples",
            expected: Self.requiredBoundaryPrinciples.map(\.rawValue),
            actual: boundaryPrinciples.map(\.rawValue)
        )
        try validateList(
            field: "forbiddenCapabilities",
            expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
            actual: forbiddenCapabilities.map(\.rawValue)
        )
        try validateList(
            field: "allowedEvidenceKinds",
            expected: Self.allowedEvidenceKinds.map(\.rawValue),
            actual: allowedEvidenceKinds.map(\.rawValue)
        )
        try validateList(
            field: "sourceDocumentAnchors",
            expected: Self.requiredSourceDocumentAnchors,
            actual: sourceDocumentAnchors
        )
        try validateList(
            field: "validationAnchors",
            expected: Self.requiredValidationAnchors,
            actual: validationAnchors
        )
    }

    private static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    private static func validateBoundaryFlags(
        isLocalFirst: Bool,
        isDeterministic: Bool,
        isVersioned: Bool,
        exposesReadModelOnlySurface: Bool,
        parsesScenarioManifest: Bool,
        addsFixtureData: Bool,
        implementsReplayCursor: Bool,
        implementsReportInputVersioning: Bool,
        implementsSimulatedExchangeBacktestParity: Bool,
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
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        readsRealAccountOrBrokerPosition: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        buildsProductionDataPlatform: Bool,
        buildsLargeScaleIngestionPipeline: Bool,
        downloadsRealNetworkData: Bool,
        runsGraphifyUpdate: Bool,
        modifiesFigma: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let requiredTrueFlags = [
            ("isLocalFirst", isLocalFirst),
            ("isDeterministic", isDeterministic),
            ("isVersioned", isVersioned),
            ("exposesReadModelOnlySurface", exposesReadModelOnlySurface)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: flag.0,
                expected: "true",
                actual: "false"
            )
        }

        let forbiddenFlags = [
            ("parsesScenarioManifest", parsesScenarioManifest),
            ("addsFixtureData", addsFixtureData),
            ("implementsReplayCursor", implementsReplayCursor),
            ("implementsReportInputVersioning", implementsReportInputVersioning),
            ("implementsSimulatedExchangeBacktestParity", implementsSimulatedExchangeBacktestParity),
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
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("runsReconciliation", runsReconciliation),
            ("readsRealAccountOrBrokerPosition", readsRealAccountOrBrokerPosition),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton),
            ("buildsProductionDataPlatform", buildsProductionDataPlatform),
            ("buildsLargeScaleIngestionPipeline", buildsLargeScaleIngestionPipeline),
            ("downloadsRealNetworkData", downloadsRealNetworkData),
            ("runsGraphifyUpdate", runsGraphifyUpdate),
            ("modifiesFigma", modifiesFigma),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(capability.0)
        }
    }
}
