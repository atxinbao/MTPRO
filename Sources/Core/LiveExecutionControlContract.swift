import Foundation

/// LiveExecutionControlTerm 定义 MTP-75 允许命名的 Future Live Execution 术语。
///
/// 这些术语只服务合同、验证矩阵和后续 gate 讨论；它们不构成当前可调用命令、adapter、
/// runtime workflow、UI command surface 或真实交易授权。
public enum LiveExecutionControlTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case executionControl = "execution control"
    case realOrderCommand = "real order command"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case orderReconciliation = "order reconciliation"
    case incidentFallback = "incident fallback"
    case paperOrderIntent = "paper order intent"
    case paperExecutionDecision = "paper execution decision"
    case simulatedFillEvidence = "simulated fill evidence"
}

/// FutureRealOrderCommandTaxonomyTerm 固定 MTP-75 的真实订单命令分类。
///
/// `submit` / `cancel` / `replace` 等值只是 taxonomy label，不能被解释成 Swift command、
/// HTTP request、broker SDK action、OMS transition 或 Dashboard 操作入口。
public enum FutureRealOrderCommandTaxonomyTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit = "submit"
    case cancel = "cancel"
    case replace = "replace"
    case executionReport = "execution report"
    case reconciliation = "reconciliation"
    case incidentFallback = "incident fallback"
}

/// LiveExecutionControlFutureGate 描述 Future Live Execution Control 进入实现前必须补齐的 gate。
///
/// Gate 只表达后续 Project Definition 前的必要条件；当前 MTP-75 不实现 secret、signed
/// endpoint、broker adapter、real order lifecycle、risk、operations 或 audit 能力。
public enum LiveExecutionControlFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live decision"
    case credentialEndpointBoundarySatisfied = "credential endpoint boundary satisfied"
    case adapterCapabilityIsolationSatisfied = "adapter capability isolation satisfied"
    case realOrderLifecycleBoundarySatisfied = "real order lifecycle boundary satisfied"
    case submitCancelReplaceContract = "submit / cancel / replace contract"
    case executionReportContract = "execution report contract"
    case brokerFillContract = "broker fill contract"
    case reconciliationContract = "reconciliation contract"
    case incidentFallbackContract = "incident fallback contract"
    case liveRiskOperationsAuditEvidence = "live risk / operations / audit evidence"
}

/// LiveExecutionControlForbiddenCapability 枚举 MTP-75 必须保持禁止的能力面。
///
/// 这些值可以进入 deterministic forbidden tests 和 PR evidence，但不能出现在当前可执行
/// API、UI、adapter、runtime、paper evidence 升级路径或网络请求中。
public enum LiveExecutionControlForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realOrderStateMachine = "real order state machine"
    case oms = "OMS"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case executionReportImplementation = "execution report implementation"
    case brokerFillImplementation = "broker fill implementation"
    case reconciliationImplementation = "reconciliation implementation"
    case incidentFallbackAutomation = "incident fallback automation"
    case paperOrderIntentUpgrade = "paper order intent upgrade"
    case paperExecutionDecisionUpgrade = "paper execution decision upgrade"
    case simulatedFillUpgrade = "simulated fill upgrade"
    case liveCommandSurface = "live command surface"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
}

/// LiveExecutionControlEvidenceKind 限定 MTP-75 当前可以输出的非执行证据。
///
/// Evidence 只用于合同、validation anchor、deterministic tests 和 PR 审计；automation
/// readiness 的最终机械收口保留给本 Project 的最后一个 issue。
public enum LiveExecutionControlEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case validationMatrixCandidate = "validation matrix candidate"
    case validationPlanAnchor = "validation plan anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case paperRealIsolationEvidence = "paper / real command isolation evidence"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveExecutionControlTerminologyBoundary 是 MTP-75 的 Future-only terminology / taxonomy fixture。
///
/// 该 fixture 只把 execution-control、real order command taxonomy、future gates 和 forbidden
/// capability baseline 固定为可测试合同。所有真实交易、secret、signed/account/listenKey、
/// broker adapter、real order state machine、OMS、submit / cancel / replace、execution report、
/// reconciliation、incident fallback automation、UI command 和 paper-to-real upgrade 旗标必须保持关闭。
public struct LiveExecutionControlTerminologyBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveExecutionControlTerm]
    public let commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm]
    public let futureGates: [LiveExecutionControlFutureGate]
    public let forbiddenCapabilities: [LiveExecutionControlForbiddenCapability]
    public let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind]
    public let validationAnchors: [String]
    public let paperIsolationSourceAnchors: [String]
    public let isFutureOnlyTerminology: Bool
    public let providesExecutableCommandSurface: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsRealOrderStateMachine: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let executesIncidentFallback: Bool
    public let upgradesPaperOrderIntent: Bool
    public let upgradesPaperExecutionDecision: Bool
    public let upgradesSimulatedFillToBrokerFill: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var terminologyBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && commandTaxonomy == Self.requiredCommandTaxonomy
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors
            && isFutureOnlyTerminology
            && providesExecutableCommandSurface == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && executesIncidentFallback == false
            && upgradesPaperOrderIntent == false
            && upgradesPaperExecutionDecision == false
            && upgradesSimulatedFillToBrokerFill == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public var paperRealIsolationBoundaryHeld: Bool {
        paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors
            && upgradesPaperOrderIntent == false
            && upgradesPaperExecutionDecision == false
            && upgradesSimulatedFillToBrokerFill == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-75-live-execution-control-terminology"),
        issueID: Identifier = try! Identifier("MTP-75"),
        terms: [LiveExecutionControlTerm] = Self.requiredTerms,
        commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm] = Self.requiredCommandTaxonomy,
        futureGates: [LiveExecutionControlFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveExecutionControlForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        paperIsolationSourceAnchors: [String] = Self.requiredPaperIsolationSourceAnchors,
        isFutureOnlyTerminology: Bool = true,
        providesExecutableCommandSurface: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        executesIncidentFallback: Bool = false,
        upgradesPaperOrderIntent: Bool = false,
        upgradesPaperExecutionDecision: Bool = false,
        upgradesSimulatedFillToBrokerFill: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            commandTaxonomy: commandTaxonomy,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            paperIsolationSourceAnchors: paperIsolationSourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureOnlyTerminology: isFutureOnlyTerminology,
            providesExecutableCommandSurface: providesExecutableCommandSurface,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            executesIncidentFallback: executesIncidentFallback,
            upgradesPaperOrderIntent: upgradesPaperOrderIntent,
            upgradesPaperExecutionDecision: upgradesPaperExecutionDecision,
            upgradesSimulatedFillToBrokerFill: upgradesSimulatedFillToBrokerFill,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.commandTaxonomy = commandTaxonomy
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.paperIsolationSourceAnchors = paperIsolationSourceAnchors
        self.isFutureOnlyTerminology = isFutureOnlyTerminology
        self.providesExecutableCommandSurface = providesExecutableCommandSurface
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.executesIncidentFallback = executesIncidentFallback
        self.upgradesPaperOrderIntent = upgradesPaperOrderIntent
        self.upgradesPaperExecutionDecision = upgradesPaperExecutionDecision
        self.upgradesSimulatedFillToBrokerFill = upgradesSimulatedFillToBrokerFill
        self.exposesOrderLevelCommandUI = exposesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveExecutionControlTerm].self, forKey: .terms),
            commandTaxonomy: try container.decode(
                [FutureRealOrderCommandTaxonomyTerm].self,
                forKey: .commandTaxonomy
            ),
            futureGates: try container.decode([LiveExecutionControlFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveExecutionControlForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveExecutionControlEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            paperIsolationSourceAnchors: try container.decode([String].self, forKey: .paperIsolationSourceAnchors),
            isFutureOnlyTerminology: try container.decode(Bool.self, forKey: .isFutureOnlyTerminology),
            providesExecutableCommandSurface: try container.decode(
                Bool.self,
                forKey: .providesExecutableCommandSurface
            ),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .implementsLiveExecutionAdapter
            ),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            executesIncidentFallback: try container.decode(Bool.self, forKey: .executesIncidentFallback),
            upgradesPaperOrderIntent: try container.decode(Bool.self, forKey: .upgradesPaperOrderIntent),
            upgradesPaperExecutionDecision: try container.decode(
                Bool.self,
                forKey: .upgradesPaperExecutionDecision
            ),
            upgradesSimulatedFillToBrokerFill: try container.decode(
                Bool.self,
                forKey: .upgradesSimulatedFillToBrokerFill
            ),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerms: [LiveExecutionControlTerm] = LiveExecutionControlTerm.allCases

    public static let requiredCommandTaxonomy: [FutureRealOrderCommandTaxonomyTerm] =
        FutureRealOrderCommandTaxonomyTerm.allCases

    public static let requiredFutureGates: [LiveExecutionControlFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityIsolationSatisfied,
        .realOrderLifecycleBoundarySatisfied,
        .submitCancelReplaceContract,
        .executionReportContract,
        .brokerFillContract,
        .reconciliationContract,
        .incidentFallbackContract,
        .liveRiskOperationsAuditEvidence
    ]

    public static let requiredForbiddenCapabilities: [LiveExecutionControlForbiddenCapability] =
        LiveExecutionControlForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperRealIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY",
        "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
        "MTP-75-PAPER-REAL-COMMAND-ISOLATION",
        "MTP-75-NO-EXECUTABLE-COMMAND-SURFACE",
        "MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let requiredPaperIsolationSourceAnchors: [String] = [
        "TVM-PAPER-ORDER-LIFECYCLE",
        "TVM-PAPER-EXECUTION-DECISION",
        "TVM-PAPER-SIMULATED-FILL",
        "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
        "MTP-75-PAPER-REAL-COMMAND-ISOLATION"
    ]

    public static let deterministicFixture: LiveExecutionControlTerminologyBoundary = {
        do {
            return try LiveExecutionControlTerminologyBoundary()
        } catch {
            preconditionFailure("MTP-75 Live execution control terminology fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveExecutionControlTerm],
        commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm],
        futureGates: [LiveExecutionControlFutureGate],
        forbiddenCapabilities: [LiveExecutionControlForbiddenCapability],
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind],
        validationAnchors: [String],
        paperIsolationSourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard commandTaxonomy == Self.requiredCommandTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandTaxonomy",
                expected: Self.requiredCommandTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: commandTaxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "paperIsolationSourceAnchors",
                expected: Self.requiredPaperIsolationSourceAnchors.joined(separator: ","),
                actual: paperIsolationSourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureOnlyTerminology: Bool,
        providesExecutableCommandSurface: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsRealOrderStateMachine: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        executesIncidentFallback: Bool,
        upgradesPaperOrderIntent: Bool,
        upgradesPaperExecutionDecision: Bool,
        upgradesSimulatedFillToBrokerFill: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureOnlyTerminology else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureOnlyTerminology")
        }

        let forbiddenFlags = [
            ("providesExecutableCommandSurface", providesExecutableCommandSurface),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("executesIncidentFallback", executesIncidentFallback),
            ("upgradesPaperOrderIntent", upgradesPaperOrderIntent),
            ("upgradesPaperExecutionDecision", upgradesPaperExecutionDecision),
            ("upgradesSimulatedFillToBrokerFill", upgradesSimulatedFillToBrokerFill),
            ("exposesOrderLevelCommandUI", exposesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveSubmitCancelReplaceFutureGate 固定 MTP-76 的 submit / cancel / replace 未来门槛。
///
/// 这些 gate 只描述真实订单提交、撤销、替换在后续 Project Definition 前必须具备的
/// 合同、风控、执行回报、对账和运维审计条件；当前阶段不得把 gate 解释为可调用命令。
public enum LiveSubmitCancelReplaceFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live execution decision"
    case credentialEndpointBoundarySatisfied = "credential endpoint boundary satisfied"
    case adapterCapabilityIsolationSatisfied = "adapter capability isolation satisfied"
    case realOrderLifecycleBoundarySatisfied = "real order lifecycle boundary satisfied"
    case submitCommandContractDefined = "future submit command contract defined"
    case cancelCommandContractDefined = "future cancel command contract defined"
    case replaceCommandContractDefined = "future replace command contract defined"
    case liveRiskGateDefined = "future live risk gate defined"
    case executionReportReconciliationGateDefined = "future execution report / reconciliation gate defined"
    case operationsAuditHandoffDefined = "future operations / audit handoff defined"
}

/// LiveSubmitCancelReplaceForbiddenCapability 枚举 MTP-76 必须阻断的命令能力面。
///
/// 这些值用于 deterministic forbidden capability tests 和 PR evidence；它们不能出现在
/// 当前 API、adapter、Runtime、UI、paper evidence 升级路径、网络请求或 broker action 中。
public enum LiveSubmitCancelReplaceForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realOrderStateMachine = "real order state machine"
    case oms = "OMS"
    case submitCommandAPI = "submit command API"
    case cancelCommandAPI = "cancel command API"
    case replaceCommandAPI = "replace command API"
    case signedSubmitRequest = "signed submit request"
    case signedCancelRequest = "signed cancel request"
    case signedReplaceRequest = "signed replace request"
    case brokerSubmitAction = "broker submit action"
    case brokerCancelAction = "broker cancel action"
    case brokerReplaceAction = "broker replace action"
    case paperOrderIntentToSubmitUpgrade = "paper order intent to real submit upgrade"
    case paperOrderIntentToCancelUpgrade = "paper order intent to real cancel upgrade"
    case paperOrderIntentToReplaceUpgrade = "paper order intent to real replace upgrade"
    case paperExecutionDecisionUpgrade = "paper execution decision upgrade"
    case simulatedFillUpgrade = "simulated fill upgrade"
    case orderForm = "order form"
    case orderLevelCommandUI = "order-level command UI"
    case liveCommandSurface = "live command surface"
    case tradingButton = "trading button"
}

/// LiveSubmitCancelReplaceCommandBoundary 是 MTP-76 的 submit / cancel / replace gate fixture。
///
/// 该 fixture 只定义 future gates、forbidden capability tests 和 paper intent 隔离证据。
/// 所有真实 submit / cancel / replace、签名请求、broker action、真实订单状态机、OMS、
/// UI command surface 和 paper-to-real 升级路径都必须保持关闭。
public struct LiveSubmitCancelReplaceCommandBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm]
    public let futureGates: [LiveSubmitCancelReplaceFutureGate]
    public let forbiddenCapabilities: [LiveSubmitCancelReplaceForbiddenCapability]
    public let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isFutureGateOnly: Bool
    public let providesExecutableCommandSurface: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsRealOrderStateMachine: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let sendsSignedSubmitRequest: Bool
    public let sendsSignedCancelRequest: Bool
    public let sendsSignedReplaceRequest: Bool
    public let mapsPaperOrderIntentToSubmit: Bool
    public let mapsPaperOrderIntentToCancel: Bool
    public let mapsPaperOrderIntentToReplace: Bool
    public let upgradesPaperExecutionDecision: Bool
    public let upgradesSimulatedFillToBrokerFill: Bool
    public let exposesOrderForm: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var submitCancelReplaceBoundaryHeld: Bool {
        commandTaxonomy == Self.requiredCommandTaxonomy
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && isFutureGateOnly
            && providesExecutableCommandSurface == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && sendsSignedSubmitRequest == false
            && sendsSignedCancelRequest == false
            && sendsSignedReplaceRequest == false
            && mapsPaperOrderIntentToSubmit == false
            && mapsPaperOrderIntentToCancel == false
            && mapsPaperOrderIntentToReplace == false
            && upgradesPaperExecutionDecision == false
            && upgradesSimulatedFillToBrokerFill == false
            && exposesOrderForm == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public var allRealOrderCommandsBlocked: Bool {
        submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && sendsSignedSubmitRequest == false
            && sendsSignedCancelRequest == false
            && sendsSignedReplaceRequest == false
    }

    public var paperIntentUpgradeBoundaryHeld: Bool {
        mapsPaperOrderIntentToSubmit == false
            && mapsPaperOrderIntentToCancel == false
            && mapsPaperOrderIntentToReplace == false
            && upgradesPaperExecutionDecision == false
            && upgradesSimulatedFillToBrokerFill == false
    }

    public func forbidsCapability(_ capability: LiveSubmitCancelReplaceForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-76-submit-cancel-replace-boundary"),
        issueID: Identifier = try! Identifier("MTP-76"),
        commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm] = Self.requiredCommandTaxonomy,
        futureGates: [LiveSubmitCancelReplaceFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveSubmitCancelReplaceForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isFutureGateOnly: Bool = true,
        providesExecutableCommandSurface: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        sendsSignedSubmitRequest: Bool = false,
        sendsSignedCancelRequest: Bool = false,
        sendsSignedReplaceRequest: Bool = false,
        mapsPaperOrderIntentToSubmit: Bool = false,
        mapsPaperOrderIntentToCancel: Bool = false,
        mapsPaperOrderIntentToReplace: Bool = false,
        upgradesPaperExecutionDecision: Bool = false,
        upgradesSimulatedFillToBrokerFill: Bool = false,
        exposesOrderForm: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            commandTaxonomy: commandTaxonomy,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureGateOnly: isFutureGateOnly,
            providesExecutableCommandSurface: providesExecutableCommandSurface,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            sendsSignedSubmitRequest: sendsSignedSubmitRequest,
            sendsSignedCancelRequest: sendsSignedCancelRequest,
            sendsSignedReplaceRequest: sendsSignedReplaceRequest,
            mapsPaperOrderIntentToSubmit: mapsPaperOrderIntentToSubmit,
            mapsPaperOrderIntentToCancel: mapsPaperOrderIntentToCancel,
            mapsPaperOrderIntentToReplace: mapsPaperOrderIntentToReplace,
            upgradesPaperExecutionDecision: upgradesPaperExecutionDecision,
            upgradesSimulatedFillToBrokerFill: upgradesSimulatedFillToBrokerFill,
            exposesOrderForm: exposesOrderForm,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.commandTaxonomy = commandTaxonomy
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isFutureGateOnly = isFutureGateOnly
        self.providesExecutableCommandSurface = providesExecutableCommandSurface
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.sendsSignedSubmitRequest = sendsSignedSubmitRequest
        self.sendsSignedCancelRequest = sendsSignedCancelRequest
        self.sendsSignedReplaceRequest = sendsSignedReplaceRequest
        self.mapsPaperOrderIntentToSubmit = mapsPaperOrderIntentToSubmit
        self.mapsPaperOrderIntentToCancel = mapsPaperOrderIntentToCancel
        self.mapsPaperOrderIntentToReplace = mapsPaperOrderIntentToReplace
        self.upgradesPaperExecutionDecision = upgradesPaperExecutionDecision
        self.upgradesSimulatedFillToBrokerFill = upgradesSimulatedFillToBrokerFill
        self.exposesOrderForm = exposesOrderForm
        self.exposesOrderLevelCommandUI = exposesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            commandTaxonomy: try container.decode(
                [FutureRealOrderCommandTaxonomyTerm].self,
                forKey: .commandTaxonomy
            ),
            futureGates: try container.decode([LiveSubmitCancelReplaceFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveSubmitCancelReplaceForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveExecutionControlEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            providesExecutableCommandSurface: try container.decode(
                Bool.self,
                forKey: .providesExecutableCommandSurface
            ),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .implementsLiveExecutionAdapter
            ),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            sendsSignedSubmitRequest: try container.decode(Bool.self, forKey: .sendsSignedSubmitRequest),
            sendsSignedCancelRequest: try container.decode(Bool.self, forKey: .sendsSignedCancelRequest),
            sendsSignedReplaceRequest: try container.decode(Bool.self, forKey: .sendsSignedReplaceRequest),
            mapsPaperOrderIntentToSubmit: try container.decode(Bool.self, forKey: .mapsPaperOrderIntentToSubmit),
            mapsPaperOrderIntentToCancel: try container.decode(Bool.self, forKey: .mapsPaperOrderIntentToCancel),
            mapsPaperOrderIntentToReplace: try container.decode(
                Bool.self,
                forKey: .mapsPaperOrderIntentToReplace
            ),
            upgradesPaperExecutionDecision: try container.decode(
                Bool.self,
                forKey: .upgradesPaperExecutionDecision
            ),
            upgradesSimulatedFillToBrokerFill: try container.decode(
                Bool.self,
                forKey: .upgradesSimulatedFillToBrokerFill
            ),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredCommandTaxonomy: [FutureRealOrderCommandTaxonomyTerm] = [
        .submit,
        .cancel,
        .replace
    ]

    public static let requiredFutureGates: [LiveSubmitCancelReplaceFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityIsolationSatisfied,
        .realOrderLifecycleBoundarySatisfied,
        .submitCommandContractDefined,
        .cancelCommandContractDefined,
        .replaceCommandContractDefined,
        .liveRiskGateDefined,
        .executionReportReconciliationGateDefined,
        .operationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveSubmitCancelReplaceForbiddenCapability] =
        LiveSubmitCancelReplaceForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperRealIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
        "MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS",
        "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
        "MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE",
        "MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
        "MTP-75-NO-EXECUTABLE-COMMAND-SURFACE",
        "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
        "TVM-PAPER-ORDER-LIFECYCLE",
        "TVM-PAPER-EXECUTION-DECISION",
        "TVM-PAPER-SIMULATED-FILL"
    ]

    public static let deterministicFixture: LiveSubmitCancelReplaceCommandBoundary = {
        do {
            return try LiveSubmitCancelReplaceCommandBoundary()
        } catch {
            preconditionFailure("MTP-76 submit / cancel / replace fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        commandTaxonomy: [FutureRealOrderCommandTaxonomyTerm],
        futureGates: [LiveSubmitCancelReplaceFutureGate],
        forbiddenCapabilities: [LiveSubmitCancelReplaceForbiddenCapability],
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard commandTaxonomy == Self.requiredCommandTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandTaxonomy",
                expected: Self.requiredCommandTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: commandTaxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureGateOnly: Bool,
        providesExecutableCommandSurface: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsRealOrderStateMachine: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        sendsSignedSubmitRequest: Bool,
        sendsSignedCancelRequest: Bool,
        sendsSignedReplaceRequest: Bool,
        mapsPaperOrderIntentToSubmit: Bool,
        mapsPaperOrderIntentToCancel: Bool,
        mapsPaperOrderIntentToReplace: Bool,
        upgradesPaperExecutionDecision: Bool,
        upgradesSimulatedFillToBrokerFill: Bool,
        exposesOrderForm: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }

        let forbiddenFlags = [
            ("providesExecutableCommandSurface", providesExecutableCommandSurface),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("sendsSignedSubmitRequest", sendsSignedSubmitRequest),
            ("sendsSignedCancelRequest", sendsSignedCancelRequest),
            ("sendsSignedReplaceRequest", sendsSignedReplaceRequest),
            ("mapsPaperOrderIntentToSubmit", mapsPaperOrderIntentToSubmit),
            ("mapsPaperOrderIntentToCancel", mapsPaperOrderIntentToCancel),
            ("mapsPaperOrderIntentToReplace", mapsPaperOrderIntentToReplace),
            ("upgradesPaperExecutionDecision", upgradesPaperExecutionDecision),
            ("upgradesSimulatedFillToBrokerFill", upgradesSimulatedFillToBrokerFill),
            ("exposesOrderForm", exposesOrderForm),
            ("exposesOrderLevelCommandUI", exposesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
