import Foundation

/// Simulated Exchange / Backtest Parity 边界定义 MTP-110 的 L2 术语、目标引擎职责和禁止能力基线。
///
/// 本文件只提供可编码、可测试的合同 fixture，用于固定 deterministic simulation 共同语言。
/// 它不实现撮合、订单执行、portfolio 投影、UI、signed/account/listenKey、broker、OMS、
/// LiveExecutionAdapter、Live PRO Console、live command 或交易按钮。

/// SimulatedExchangeBacktestParityTerm 固定 MTP-110 允许命名的 L2 parity 术语。
///
/// 这些术语只服务后续 shared order semantics、matching model、fill / latency / cost parity、
/// portfolio parity 和 read-model evidence；当前 issue 不能把任一术语实现为 runtime。
public enum SimulatedExchangeBacktestParityTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case simulatedExchange = "simulated exchange"
    case backtestParity = "backtest parity"
    case matchingModel = "matching model"
    case fillModel = "fill model"
    case latencyModel = "latency model"
    case feeSlippageParity = "fee / slippage parity"
    case portfolioProjectionParity = "portfolio projection parity"
    case scenarioReplayIntegration = "scenario replay integration"
    case deterministicSimulation = "deterministic simulation"
    case sharedBacktestPaperOrderSemantics = "shared backtest-paper order semantics"
}

/// SimulatedExchangeBacktestParityTargetEngine 固定 MTP-110 的目标引擎职责。
///
/// Simulation / Backtest Engine 只获得 L2 术语入口；Execution Engine 仍限定为 paper-only /
/// simulated；Portfolio、Data、State & Persistence 和 Workbench 只能作为后续 parity evidence
/// 的边界名称，不允许在本 issue 实现运行时行为。
public enum SimulatedExchangeBacktestParityTargetEngine: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case simulationBacktestEngine = "Simulation / Backtest Engine"
    case executionEnginePaperOnlySimulated = "Execution Engine (paper-only / simulated)"
    case portfolioEngine = "Portfolio Engine"
    case dataEngine = "Data Engine"
    case statePersistenceEngine = "State & Persistence Engine"
    case workbenchInterface = "Workbench Interface"
}

/// SimulatedExchangeBacktestParityBoundaryPrinciple 描述 MTP-110 必须保持的边界原则。
///
/// 这些原则只表示 L1 Paper Runtime 与 L1.5 Data Catalog / Scenario Replay 的 deterministic
/// handoff，不表示真实交易所、live readiness 或 production trading engine 已进入当前 scope。
public enum SimulatedExchangeBacktestParityBoundaryPrinciple: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case deterministicSimulationOnly = "deterministic simulation only"
    case backtestPaperSharedSimulationSemantics = "backtest-paper shared simulation semantics"
    case l1PaperRuntimeHandoff = "L1 Paper Runtime handoff"
    case l15ScenarioReplayHandoff = "L1.5 Data Catalog / Scenario Replay handoff"
    case readModelOnlyParityEvidenceSurface = "read-model-only parity evidence surface"
    case noLiveBrokerSignedAccountOMS = "no live / broker / signed / account / OMS boundary"
}

/// SimulatedExchangeBacktestParityForbiddenCapability 枚举 MTP-110 必须禁止的能力面。
///
/// 当前 issue 只能把这些能力作为 forbidden baseline 和 validation anchor；任何初始化或 Codable
/// 解码试图打开这些能力都必须失败，避免后续 PR 把术语合同误升级为实现。
public enum SimulatedExchangeBacktestParityForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case matchingRuntime = "matching runtime"
    case orderExecutionRuntime = "order execution runtime"
    case portfolioProjectionRuntime = "portfolio projection runtime"
    case uiImplementation = "UI implementation"
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
    case realAccountBrokerPositionMarginLeverageRead = "real account / broker position / margin / leverage read"
    case liveRuntime = "live runtime"
    case liveProConsole = "Live PRO Console"
    case liveCommand = "live command"
    case tradingButton = "trading button"
    case emergencyStopShutdownRestore = "emergency stop / shutdown / restore"
    case graphifyUpdate = "Graphify update"
    case figmaChange = "Figma change"
}

/// SimulatedExchangeBacktestParityEvidenceKind 限定 MTP-110 当前可以输出的非执行证据。
///
/// 允许证据只包括 contract、source docs、validation anchors、deterministic boundary fixture、
/// forbidden capability tests 和 PR boundary evidence，不包含 matching output 或 UI surface。
public enum SimulatedExchangeBacktestParityEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case sourceDocsAnchor = "source docs anchor"
    case validationPlanAnchor = "validation plan anchor"
    case validationMatrixCandidate = "validation matrix candidate"
    case deterministicBoundaryFixture = "deterministic boundary fixture"
    case forbiddenCapabilityTest = "forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// SimulatedExchangeBacktestParityBoundary 是 MTP-110 的 terminology / boundary fixture。
///
/// 该 fixture 把 L2 目标引擎、术语、L1 Paper Runtime handoff、L1.5 Scenario Replay handoff、
/// forbidden capability baseline、source docs anchors 和 validation anchors 固定为可测试值对象。
/// 它不持有订单、不读写文件、不访问网络、不暴露 persistence schema，也不启动任何 Runtime。
public struct SimulatedExchangeBacktestParityBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [SimulatedExchangeBacktestParityTerm]
    public let targetEngines: [SimulatedExchangeBacktestParityTargetEngine]
    public let boundaryPrinciples: [SimulatedExchangeBacktestParityBoundaryPrinciple]
    public let forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability]
    public let allowedEvidenceKinds: [SimulatedExchangeBacktestParityEvidenceKind]
    public let sourceDocumentAnchors: [String]
    public let validationAnchors: [String]
    public let isDeterministicSimulation: Bool
    public let sharesBacktestPaperSimulationSemantics: Bool
    public let linksL1PaperRuntime: Bool
    public let linksL15ScenarioReplay: Bool
    public let exposesReadModelOnlyParityEvidence: Bool
    public let implementsMatchingRuntime: Bool
    public let implementsOrderExecutionRuntime: Bool
    public let implementsPortfolioProjectionRuntime: Bool
    public let implementsUI: Bool
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
    public let readsRealAccountBrokerPositionMarginLeverage: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveProConsole: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let implementsEmergencyStopShutdownRestore: Bool
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
            && linksL1PaperRuntime
            && linksL15ScenarioReplay
            && implementsMatchingRuntime == false
            && implementsOrderExecutionRuntime == false
            && implementsPortfolioProjectionRuntime == false
            && implementsUI == false
    }

    public var deterministicSimulationBoundaryHeld: Bool {
        isDeterministicSimulation
            && sharesBacktestPaperSimulationSemantics
            && linksL1PaperRuntime
            && linksL15ScenarioReplay
            && exposesReadModelOnlyParityEvidence
            && requiredValidationDependsOnNetwork == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allForbiddenFlagsRemainFalse
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isDeterministicSimulation
            && sharesBacktestPaperSimulationSemantics
            && linksL1PaperRuntime
            && linksL15ScenarioReplay
            && exposesReadModelOnlyParityEvidence
            && implementsMatchingRuntime == false
            && implementsOrderExecutionRuntime == false
            && implementsPortfolioProjectionRuntime == false
            && implementsUI == false
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
            && readsRealAccountBrokerPositionMarginLeverage == false
            && runsLiveRuntime == false
            && providesLiveProConsole == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && implementsEmergencyStopShutdownRestore == false
            && runsGraphifyUpdate == false
            && modifiesFigma == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-110-simulated-exchange-backtest-parity-boundary"),
        issueID: Identifier = try! Identifier("MTP-110"),
        terms: [SimulatedExchangeBacktestParityTerm] = Self.requiredTerms,
        targetEngines: [SimulatedExchangeBacktestParityTargetEngine] = Self.requiredTargetEngines,
        boundaryPrinciples: [SimulatedExchangeBacktestParityBoundaryPrinciple] = Self.requiredBoundaryPrinciples,
        forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [SimulatedExchangeBacktestParityEvidenceKind] = Self.allowedEvidenceKinds,
        sourceDocumentAnchors: [String] = Self.requiredSourceDocumentAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        isDeterministicSimulation: Bool = true,
        sharesBacktestPaperSimulationSemantics: Bool = true,
        linksL1PaperRuntime: Bool = true,
        linksL15ScenarioReplay: Bool = true,
        exposesReadModelOnlyParityEvidence: Bool = true,
        implementsMatchingRuntime: Bool = false,
        implementsOrderExecutionRuntime: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        implementsUI: Bool = false,
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
        readsRealAccountBrokerPositionMarginLeverage: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        implementsEmergencyStopShutdownRestore: Bool = false,
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
            isDeterministicSimulation: isDeterministicSimulation,
            sharesBacktestPaperSimulationSemantics: sharesBacktestPaperSimulationSemantics,
            linksL1PaperRuntime: linksL1PaperRuntime,
            linksL15ScenarioReplay: linksL15ScenarioReplay,
            exposesReadModelOnlyParityEvidence: exposesReadModelOnlyParityEvidence,
            implementsMatchingRuntime: implementsMatchingRuntime,
            implementsOrderExecutionRuntime: implementsOrderExecutionRuntime,
            implementsPortfolioProjectionRuntime: implementsPortfolioProjectionRuntime,
            implementsUI: implementsUI,
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
            readsRealAccountBrokerPositionMarginLeverage: readsRealAccountBrokerPositionMarginLeverage,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveProConsole: providesLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            implementsEmergencyStopShutdownRestore: implementsEmergencyStopShutdownRestore,
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
        self.isDeterministicSimulation = isDeterministicSimulation
        self.sharesBacktestPaperSimulationSemantics = sharesBacktestPaperSimulationSemantics
        self.linksL1PaperRuntime = linksL1PaperRuntime
        self.linksL15ScenarioReplay = linksL15ScenarioReplay
        self.exposesReadModelOnlyParityEvidence = exposesReadModelOnlyParityEvidence
        self.implementsMatchingRuntime = implementsMatchingRuntime
        self.implementsOrderExecutionRuntime = implementsOrderExecutionRuntime
        self.implementsPortfolioProjectionRuntime = implementsPortfolioProjectionRuntime
        self.implementsUI = implementsUI
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
        self.readsRealAccountBrokerPositionMarginLeverage = readsRealAccountBrokerPositionMarginLeverage
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveProConsole = providesLiveProConsole
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.implementsEmergencyStopShutdownRestore = implementsEmergencyStopShutdownRestore
        self.runsGraphifyUpdate = runsGraphifyUpdate
        self.modifiesFigma = modifiesFigma
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([SimulatedExchangeBacktestParityTerm].self, forKey: .terms),
            targetEngines: try container.decode(
                [SimulatedExchangeBacktestParityTargetEngine].self,
                forKey: .targetEngines
            ),
            boundaryPrinciples: try container.decode(
                [SimulatedExchangeBacktestParityBoundaryPrinciple].self,
                forKey: .boundaryPrinciples
            ),
            forbiddenCapabilities: try container.decode(
                [SimulatedExchangeBacktestParityForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [SimulatedExchangeBacktestParityEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            sourceDocumentAnchors: try container.decode([String].self, forKey: .sourceDocumentAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            isDeterministicSimulation: try container.decode(Bool.self, forKey: .isDeterministicSimulation),
            sharesBacktestPaperSimulationSemantics: try container.decode(
                Bool.self,
                forKey: .sharesBacktestPaperSimulationSemantics
            ),
            linksL1PaperRuntime: try container.decode(Bool.self, forKey: .linksL1PaperRuntime),
            linksL15ScenarioReplay: try container.decode(Bool.self, forKey: .linksL15ScenarioReplay),
            exposesReadModelOnlyParityEvidence: try container.decode(
                Bool.self,
                forKey: .exposesReadModelOnlyParityEvidence
            ),
            implementsMatchingRuntime: try container.decode(Bool.self, forKey: .implementsMatchingRuntime),
            implementsOrderExecutionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsOrderExecutionRuntime
            ),
            implementsPortfolioProjectionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPortfolioProjectionRuntime
            ),
            implementsUI: try container.decode(Bool.self, forKey: .implementsUI),
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
            readsRealAccountBrokerPositionMarginLeverage: try container.decode(
                Bool.self,
                forKey: .readsRealAccountBrokerPositionMarginLeverage
            ),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveProConsole: try container.decode(Bool.self, forKey: .providesLiveProConsole),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            implementsEmergencyStopShutdownRestore: try container.decode(
                Bool.self,
                forKey: .implementsEmergencyStopShutdownRestore
            ),
            runsGraphifyUpdate: try container.decode(Bool.self, forKey: .runsGraphifyUpdate),
            modifiesFigma: try container.decode(Bool.self, forKey: .modifiesFigma),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: SimulatedExchangeBacktestParityForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredTerms: [SimulatedExchangeBacktestParityTerm] =
        SimulatedExchangeBacktestParityTerm.allCases

    public static let requiredTargetEngines: [SimulatedExchangeBacktestParityTargetEngine] = [
        .simulationBacktestEngine,
        .executionEnginePaperOnlySimulated,
        .portfolioEngine,
        .dataEngine,
        .statePersistenceEngine,
        .workbenchInterface
    ]

    public static let requiredBoundaryPrinciples: [SimulatedExchangeBacktestParityBoundaryPrinciple] = [
        .deterministicSimulationOnly,
        .backtestPaperSharedSimulationSemantics,
        .l1PaperRuntimeHandoff,
        .l15ScenarioReplayHandoff,
        .readModelOnlyParityEvidenceSurface,
        .noLiveBrokerSignedAccountOMS
    ]

    public static let requiredForbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] =
        SimulatedExchangeBacktestParityForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [SimulatedExchangeBacktestParityEvidenceKind] = [
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
        "docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md",
        "docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md",
        "docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md",
        "docs/planning/projects/mtpro-simulated-exchange-backtest-parity-v1-plan.md",
        "docs/validation/latest-verification-summary.md"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY",
        "MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY",
        "MTP-110-L1-L15-L2-HANDOFF-BOUNDARY",
        "MTP-110-FORBIDDEN-CAPABILITY-BASELINE",
        "MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: SimulatedExchangeBacktestParityBoundary = {
        do {
            return try SimulatedExchangeBacktestParityBoundary()
        } catch {
            preconditionFailure("MTP-110 Simulated Exchange / Backtest Parity boundary fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [SimulatedExchangeBacktestParityTerm],
        targetEngines: [SimulatedExchangeBacktestParityTargetEngine],
        boundaryPrinciples: [SimulatedExchangeBacktestParityBoundaryPrinciple],
        forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability],
        allowedEvidenceKinds: [SimulatedExchangeBacktestParityEvidenceKind],
        sourceDocumentAnchors: [String],
        validationAnchors: [String]
    ) throws {
        try validateList(field: "terms", expected: Self.requiredTerms.map(\.rawValue), actual: terms.map(\.rawValue))
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
        try validateList(field: "sourceDocumentAnchors", expected: Self.requiredSourceDocumentAnchors, actual: sourceDocumentAnchors)
        try validateList(field: "validationAnchors", expected: Self.requiredValidationAnchors, actual: validationAnchors)
    }

    private static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    private static func validateBoundaryFlags(
        isDeterministicSimulation: Bool,
        sharesBacktestPaperSimulationSemantics: Bool,
        linksL1PaperRuntime: Bool,
        linksL15ScenarioReplay: Bool,
        exposesReadModelOnlyParityEvidence: Bool,
        implementsMatchingRuntime: Bool,
        implementsOrderExecutionRuntime: Bool,
        implementsPortfolioProjectionRuntime: Bool,
        implementsUI: Bool,
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
        readsRealAccountBrokerPositionMarginLeverage: Bool,
        runsLiveRuntime: Bool,
        providesLiveProConsole: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool,
        implementsEmergencyStopShutdownRestore: Bool,
        runsGraphifyUpdate: Bool,
        modifiesFigma: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let requiredTrueFlags = [
            ("isDeterministicSimulation", isDeterministicSimulation),
            ("sharesBacktestPaperSimulationSemantics", sharesBacktestPaperSimulationSemantics),
            ("linksL1PaperRuntime", linksL1PaperRuntime),
            ("linksL15ScenarioReplay", linksL15ScenarioReplay),
            ("exposesReadModelOnlyParityEvidence", exposesReadModelOnlyParityEvidence)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: flag.0,
                expected: "true",
                actual: "false"
            )
        }

        let forbiddenFlags = [
            ("implementsMatchingRuntime", implementsMatchingRuntime),
            ("implementsOrderExecutionRuntime", implementsOrderExecutionRuntime),
            ("implementsPortfolioProjectionRuntime", implementsPortfolioProjectionRuntime),
            ("implementsUI", implementsUI),
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
            ("readsRealAccountBrokerPositionMarginLeverage", readsRealAccountBrokerPositionMarginLeverage),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveProConsole", providesLiveProConsole),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton),
            ("implementsEmergencyStopShutdownRestore", implementsEmergencyStopShutdownRestore),
            ("runsGraphifyUpdate", runsGraphifyUpdate),
            ("modifiesFigma", modifiesFigma),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(capability.0)
        }
    }
}
