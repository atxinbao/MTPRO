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
    case readModelOnlyBlockedEvidence = "read-model-only blocked evidence"
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

/// LiveExecutionControlBlockedGate 固定 MTP-79 需要解释的 execution-control gate。
///
/// 这些 gate 只是 read-model-only blocked evidence 的分类键。它们不能被解释为当前
/// submit / cancel / replace 命令、execution report parser、broker fill fact、reconciliation
/// runtime、incident command 或 Dashboard 操作入口。
public enum LiveExecutionControlBlockedGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit = "submit"
    case cancel = "cancel"
    case replace = "replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case reconciliation = "reconciliation"
    case incidentFallback = "incident fallback"
}

/// LiveExecutionControlBlockedReason 描述 MTP-79 blocked evidence 可以输出的阻断原因。
///
/// reason 只用于 deterministic snapshot、Report / Dashboard / Event Timeline 的后续只读展示，
/// 不携带 adapter request、database schema、runtime object、真实账户状态或交易命令参数。
public enum LiveExecutionControlBlockedReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecisionMissing = "human live decision missing"
    case credentialEndpointBoundaryUnsatisfied = "credential endpoint boundary unsatisfied"
    case signedCommandRequestForbidden = "signed command request forbidden"
    case brokerExecutionAdapterForbidden = "broker execution adapter forbidden"
    case liveRiskOperationsAuditMissing = "live risk operations audit missing"
    case accountEndpointForbidden = "account endpoint forbidden"
    case listenKeyUserDataStreamForbidden = "listenKey user data stream forbidden"
    case executionReportImplementationForbidden = "execution report implementation forbidden"
    case brokerFillImplementationForbidden = "broker fill implementation forbidden"
    case realOrderStateMachineForbidden = "real order state machine forbidden"
    case paperRealCommandIsolationRequired = "paper / real command isolation required"
    case reconciliationRuntimeForbidden = "reconciliation runtime forbidden"
    case brokerPositionSyncForbidden = "broker position sync forbidden"
    case incidentFallbackAutomationForbidden = "incident fallback automation forbidden"
    case readModelOnlyBoundaryRequired = "read model only boundary required"
}

/// LiveExecutionControlBlockedEvidenceItem 是单个 gate 的只读阻断证据。
///
/// item 只能说明某个 gate 仍被哪些合同和 future gate 阻断。所有执行、命令发射、
/// adapter/schema/runtime 读取和真实交易授权旗标都必须为 false，避免 blocked evidence
/// 反向变成 execution runtime 或 UI command surface。
public struct LiveExecutionControlBlockedEvidenceItem: Codable, Equatable, Sendable {
    public let gate: LiveExecutionControlBlockedGate
    public let blockedReasons: [LiveExecutionControlBlockedReason]
    public let sourceAnchors: [String]
    public let isBlocked: Bool
    public let canExecute: Bool
    public let emitsCommand: Bool
    public let exposesSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let authorizesLiveExecution: Bool

    public var readModelOnlyBoundaryHeld: Bool {
        isBlocked
            && canExecute == false
            && emitsCommand == false
            && exposesSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && authorizesLiveExecution == false
    }

    public init(
        gate: LiveExecutionControlBlockedGate,
        blockedReasons: [LiveExecutionControlBlockedReason],
        sourceAnchors: [String],
        isBlocked: Bool = true,
        canExecute: Bool = false,
        emitsCommand: Bool = false,
        exposesSchema: Bool = false,
        readsAdapter: Bool = false,
        invokesRuntimeControl: Bool = false,
        authorizesLiveExecution: Bool = false
    ) {
        self.gate = gate
        self.blockedReasons = blockedReasons
        self.sourceAnchors = sourceAnchors
        self.isBlocked = isBlocked
        self.canExecute = canExecute
        self.emitsCommand = emitsCommand
        self.exposesSchema = exposesSchema
        self.readsAdapter = readsAdapter
        self.invokesRuntimeControl = invokesRuntimeControl
        self.authorizesLiveExecution = authorizesLiveExecution
    }
}

/// LiveExecutionControlBlockedEvidence 是 MTP-79 的 read-model-only blocked evidence fixture。
///
/// 该 read model 汇总 submit / cancel / replace / execution report / broker fill /
/// reconciliation / incident fallback 为什么仍被阻断，并输出稳定 snapshot 供 MTP-80 以后接入
/// Dashboard、Report 和 Event Timeline。它不暴露 persistence schema，不读取 adapter，不调用 Runtime
/// control，不提供 command surface，不读取 secret，不接 signed/account/listenKey，不连接 broker，
/// 不实现 `LiveExecutionAdapter`、real order state machine、OMS 或真实订单行为。
public struct LiveExecutionControlBlockedEvidence: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedItems: [LiveExecutionControlBlockedEvidenceItem]
    public let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isReadModelOnly: Bool
    public let reportConsumesReadModelOnly: Bool
    public let dashboardConsumesViewModelOnly: Bool
    public let eventTimelineConsumesReadModelOnly: Bool
    public let exposesPersistenceSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let providesCommandSurface: Bool
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
    public let exposesOrderForm: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var blockedEvidenceBoundaryHeld: Bool {
        blockedItems == Self.requiredBlockedItems
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && allExecutionControlGatesBlocked
            && appSurfaceReadModelOnlyBoundaryHeld
            && forbiddenImplementationBoundaryHeld
            && requiredValidationDependsOnNetwork == false
    }

    public var allExecutionControlGatesBlocked: Bool {
        blockedItems.map(\.gate) == LiveExecutionControlBlockedGate.allCases
            && blockedItems.allSatisfy(\.readModelOnlyBoundaryHeld)
    }

    public var appSurfaceReadModelOnlyBoundaryHeld: Bool {
        isReadModelOnly
            && reportConsumesReadModelOnly
            && dashboardConsumesViewModelOnly
            && eventTimelineConsumesReadModelOnly
            && exposesPersistenceSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && providesCommandSurface == false
            && exposesOrderForm == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public var forbiddenImplementationBoundaryHeld: Bool {
        readsAPIKey == false
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
    }

    public var deterministicSnapshot: [String] {
        blockedItems.map { item in
            let status = item.isBlocked ? "blocked" : "unblocked"
            let reasons = item.blockedReasons.map(\.rawValue).joined(separator: ";")
            return "\(item.gate.rawValue)|\(status)|\(reasons)"
        }
    }

    public func item(for gate: LiveExecutionControlBlockedGate) -> LiveExecutionControlBlockedEvidenceItem? {
        blockedItems.first { $0.gate == gate }
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-79-live-execution-control-blocked-evidence"),
        issueID: Identifier = try! Identifier("MTP-79"),
        blockedItems: [LiveExecutionControlBlockedEvidenceItem] = Self.requiredBlockedItems,
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isReadModelOnly: Bool = true,
        reportConsumesReadModelOnly: Bool = true,
        dashboardConsumesViewModelOnly: Bool = true,
        eventTimelineConsumesReadModelOnly: Bool = true,
        exposesPersistenceSchema: Bool = false,
        readsAdapter: Bool = false,
        invokesRuntimeControl: Bool = false,
        providesCommandSurface: Bool = false,
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
        exposesOrderForm: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            blockedItems: blockedItems,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            reportConsumesReadModelOnly: reportConsumesReadModelOnly,
            dashboardConsumesViewModelOnly: dashboardConsumesViewModelOnly,
            eventTimelineConsumesReadModelOnly: eventTimelineConsumesReadModelOnly,
            exposesPersistenceSchema: exposesPersistenceSchema,
            readsAdapter: readsAdapter,
            invokesRuntimeControl: invokesRuntimeControl,
            providesCommandSurface: providesCommandSurface,
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
            exposesOrderForm: exposesOrderForm,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.blockedItems = blockedItems
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isReadModelOnly = isReadModelOnly
        self.reportConsumesReadModelOnly = reportConsumesReadModelOnly
        self.dashboardConsumesViewModelOnly = dashboardConsumesViewModelOnly
        self.eventTimelineConsumesReadModelOnly = eventTimelineConsumesReadModelOnly
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.readsAdapter = readsAdapter
        self.invokesRuntimeControl = invokesRuntimeControl
        self.providesCommandSurface = providesCommandSurface
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
            blockedItems: try container.decode(
                [LiveExecutionControlBlockedEvidenceItem].self,
                forKey: .blockedItems
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveExecutionControlEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            reportConsumesReadModelOnly: try container.decode(Bool.self, forKey: .reportConsumesReadModelOnly),
            dashboardConsumesViewModelOnly: try container.decode(Bool.self, forKey: .dashboardConsumesViewModelOnly),
            eventTimelineConsumesReadModelOnly: try container.decode(
                Bool.self,
                forKey: .eventTimelineConsumesReadModelOnly
            ),
            exposesPersistenceSchema: try container.decode(Bool.self, forKey: .exposesPersistenceSchema),
            readsAdapter: try container.decode(Bool.self, forKey: .readsAdapter),
            invokesRuntimeControl: try container.decode(Bool.self, forKey: .invokesRuntimeControl),
            providesCommandSurface: try container.decode(Bool.self, forKey: .providesCommandSurface),
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
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredBlockedItems: [LiveExecutionControlBlockedEvidenceItem] = [
        LiveExecutionControlBlockedEvidenceItem(
            gate: .submit,
            blockedReasons: [
                .humanLiveDecisionMissing,
                .credentialEndpointBoundaryUnsatisfied,
                .signedCommandRequestForbidden,
                .brokerExecutionAdapterForbidden,
                .liveRiskOperationsAuditMissing
            ],
            sourceAnchors: [
                "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
                "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .cancel,
            blockedReasons: [
                .humanLiveDecisionMissing,
                .credentialEndpointBoundaryUnsatisfied,
                .signedCommandRequestForbidden,
                .brokerExecutionAdapterForbidden,
                .liveRiskOperationsAuditMissing
            ],
            sourceAnchors: [
                "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
                "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .replace,
            blockedReasons: [
                .humanLiveDecisionMissing,
                .credentialEndpointBoundaryUnsatisfied,
                .signedCommandRequestForbidden,
                .brokerExecutionAdapterForbidden,
                .liveRiskOperationsAuditMissing
            ],
            sourceAnchors: [
                "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
                "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .executionReport,
            blockedReasons: [
                .accountEndpointForbidden,
                .listenKeyUserDataStreamForbidden,
                .executionReportImplementationForbidden,
                .readModelOnlyBoundaryRequired
            ],
            sourceAnchors: [
                "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
                "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .brokerFill,
            blockedReasons: [
                .brokerExecutionAdapterForbidden,
                .brokerFillImplementationForbidden,
                .realOrderStateMachineForbidden,
                .paperRealCommandIsolationRequired
            ],
            sourceAnchors: [
                "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
                "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .reconciliation,
            blockedReasons: [
                .accountEndpointForbidden,
                .reconciliationRuntimeForbidden,
                .brokerPositionSyncForbidden,
                .readModelOnlyBoundaryRequired
            ],
            sourceAnchors: [
                "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
                "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT"
            ]
        ),
        LiveExecutionControlBlockedEvidenceItem(
            gate: .incidentFallback,
            blockedReasons: [
                .incidentFallbackAutomationForbidden,
                .liveRiskOperationsAuditMissing,
                .readModelOnlyBoundaryRequired
            ],
            sourceAnchors: [
                "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
                "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY"
            ]
        )
    ]

    public static let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperRealIsolationEvidence,
        .readModelOnlyBlockedEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
        "MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS",
        "MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT",
        "MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
        "MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
        "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
        "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
        "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
        "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
        "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT",
        "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let deterministicFixture: LiveExecutionControlBlockedEvidence = {
        do {
            return try LiveExecutionControlBlockedEvidence()
        } catch {
            preconditionFailure("MTP-79 execution-control blocked evidence fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        blockedItems: [LiveExecutionControlBlockedEvidenceItem],
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        if let invalid = blockedItems.first(where: { $0.readModelOnlyBoundaryHeld == false }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability("\(invalid.gate.rawValue).readModelOnlyBoundaryHeld")
        }
        guard blockedItems == Self.requiredBlockedItems else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedItems",
                expected: Self.requiredBlockedItems.map(\.gate.rawValue).joined(separator: ","),
                actual: blockedItems.map(\.gate.rawValue).joined(separator: ",")
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
        isReadModelOnly: Bool,
        reportConsumesReadModelOnly: Bool,
        dashboardConsumesViewModelOnly: Bool,
        eventTimelineConsumesReadModelOnly: Bool,
        exposesPersistenceSchema: Bool,
        readsAdapter: Bool,
        invokesRuntimeControl: Bool,
        providesCommandSurface: Bool,
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
        exposesOrderForm: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isReadModelOnly")
        }
        guard reportConsumesReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("reportConsumesReadModelOnly")
        }
        guard dashboardConsumesViewModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardConsumesViewModelOnly")
        }
        guard eventTimelineConsumesReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("eventTimelineConsumesReadModelOnly")
        }

        let forbiddenFlags = [
            ("exposesPersistenceSchema", exposesPersistenceSchema),
            ("readsAdapter", readsAdapter),
            ("invokesRuntimeControl", invokesRuntimeControl),
            ("providesCommandSurface", providesCommandSurface),
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

/// LiveExecutionReportBrokerFillReconciliationFutureGate 固定 MTP-77 的执行回报、broker fill 和对账未来门槛。
///
/// 这些 gate 只描述后续 Project Definition 前必须补齐的合同、账户读取边界、风险 / 运维 /
/// 审计 handoff 条件；当前阶段不得把它们解释为 execution report parser、broker fill fact、
/// reconciliation runtime、account sync 或 broker position sync。
public enum LiveExecutionReportBrokerFillReconciliationFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live execution decision"
    case credentialEndpointBoundarySatisfied = "credential endpoint boundary satisfied"
    case adapterCapabilityIsolationSatisfied = "adapter capability isolation satisfied"
    case realOrderLifecycleBoundarySatisfied = "real order lifecycle boundary satisfied"
    case submitCancelReplaceBoundarySatisfied = "submit / cancel / replace boundary satisfied"
    case executionReportSchemaContractDefined = "future execution report schema contract defined"
    case brokerFillFactContractDefined = "future broker fill fact contract defined"
    case reconciliationContractDefined = "future reconciliation contract defined"
    case accountStateReadBoundaryDefined = "future account state read boundary defined"
    case liveRiskOperationsAuditHandoffDefined = "future live risk / operations / audit handoff defined"
}

/// LiveExecutionReportBrokerFillReconciliationForbiddenCapability 枚举 MTP-77 必须阻断的执行回报 / 成交 / 对账能力面。
///
/// 这些值只能进入 deterministic forbidden tests、合同文档和 PR evidence。它们不能出现在当前
/// adapter、Runtime、Event Log fact、read model、账户同步、broker position sync 或 paper evidence
/// 升级路径中。
public enum LiveExecutionReportBrokerFillReconciliationForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
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
    case executionReportParser = "execution report parser"
    case executionReportIngestion = "execution report ingestion"
    case brokerFillRecorder = "broker fill recorder"
    case brokerFillEventFact = "broker fill event fact"
    case reconciliationService = "reconciliation service"
    case accountSync = "account sync"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionSync = "broker position sync"
    case simulatedFillToBrokerFillUpgrade = "simulated fill to broker fill upgrade"
    case simulatedFillToExecutionReportUpgrade = "simulated fill to execution report upgrade"
    case paperPortfolioToBrokerPositionUpgrade = "paper portfolio to broker position upgrade"
    case simulatedFillAccountUpdate = "simulated fill account update"
    case currentBrokerFillReadModel = "current broker fill read model"
    case liveCommandSurface = "live command surface"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
}

/// LiveExecutionReportBrokerFillReconciliationBoundary 是 MTP-77 的 future gate / blocked evidence fixture。
///
/// 该 fixture 只定义 execution report、broker fill 和 reconciliation 的 future gates、forbidden
/// capability tests 与 blocked evidence anchors。所有真实执行回报解析、broker fill 记录、账户对账、
/// 真实账户余额读取、broker position sync、Event Log 真实成交 fact 和 simulated-fill-to-live
/// 升级路径都必须保持关闭。
public struct LiveExecutionReportBrokerFillReconciliationBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveExecutionControlTerm]
    public let futureGates: [LiveExecutionReportBrokerFillReconciliationFutureGate]
    public let forbiddenCapabilities: [LiveExecutionReportBrokerFillReconciliationForbiddenCapability]
    public let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isFutureGateOnly: Bool
    public let isBlockedEvidenceOnly: Bool
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
    public let parsesExecutionReport: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let storesBrokerFillFact: Bool
    public let performsReconciliation: Bool
    public let implementsReconciliationRuntime: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let mapsSimulatedFillToBrokerFill: Bool
    public let mapsSimulatedFillToExecutionReport: Bool
    public let mapsPaperPortfolioToBrokerPosition: Bool
    public let updatesRealAccountFromSimulatedFill: Bool
    public let exposesBrokerFillAsCurrentReadModel: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var reportFillReconciliationBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && isFutureGateOnly
            && isBlockedEvidenceOnly
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
            && parsesExecutionReport == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && storesBrokerFillFact == false
            && performsReconciliation == false
            && implementsReconciliationRuntime == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && mapsSimulatedFillToBrokerFill == false
            && mapsSimulatedFillToExecutionReport == false
            && mapsPaperPortfolioToBrokerPosition == false
            && updatesRealAccountFromSimulatedFill == false
            && exposesBrokerFillAsCurrentReadModel == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public var reportFillReconciliationImplementationBlocked: Bool {
        consumesExecutionReport == false
            && parsesExecutionReport == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && storesBrokerFillFact == false
            && performsReconciliation == false
            && implementsReconciliationRuntime == false
    }

    public var simulatedFillIsolationBoundaryHeld: Bool {
        mapsSimulatedFillToBrokerFill == false
            && mapsSimulatedFillToExecutionReport == false
            && updatesRealAccountFromSimulatedFill == false
    }

    public var reconciliationBlockedEvidenceBoundaryHeld: Bool {
        isBlockedEvidenceOnly
            && performsReconciliation == false
            && implementsReconciliationRuntime == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && mapsPaperPortfolioToBrokerPosition == false
    }

    public func forbidsCapability(_ capability: LiveExecutionReportBrokerFillReconciliationForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-77-execution-report-broker-fill-reconciliation-boundary"),
        issueID: Identifier = try! Identifier("MTP-77"),
        terms: [LiveExecutionControlTerm] = Self.requiredTerms,
        futureGates: [LiveExecutionReportBrokerFillReconciliationFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveExecutionReportBrokerFillReconciliationForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isFutureGateOnly: Bool = true,
        isBlockedEvidenceOnly: Bool = true,
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
        parsesExecutionReport: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        storesBrokerFillFact: Bool = false,
        performsReconciliation: Bool = false,
        implementsReconciliationRuntime: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        mapsSimulatedFillToBrokerFill: Bool = false,
        mapsSimulatedFillToExecutionReport: Bool = false,
        mapsPaperPortfolioToBrokerPosition: Bool = false,
        updatesRealAccountFromSimulatedFill: Bool = false,
        exposesBrokerFillAsCurrentReadModel: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureGateOnly: isFutureGateOnly,
            isBlockedEvidenceOnly: isBlockedEvidenceOnly,
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
            parsesExecutionReport: parsesExecutionReport,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            storesBrokerFillFact: storesBrokerFillFact,
            performsReconciliation: performsReconciliation,
            implementsReconciliationRuntime: implementsReconciliationRuntime,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            mapsSimulatedFillToBrokerFill: mapsSimulatedFillToBrokerFill,
            mapsSimulatedFillToExecutionReport: mapsSimulatedFillToExecutionReport,
            mapsPaperPortfolioToBrokerPosition: mapsPaperPortfolioToBrokerPosition,
            updatesRealAccountFromSimulatedFill: updatesRealAccountFromSimulatedFill,
            exposesBrokerFillAsCurrentReadModel: exposesBrokerFillAsCurrentReadModel,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isFutureGateOnly = isFutureGateOnly
        self.isBlockedEvidenceOnly = isBlockedEvidenceOnly
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
        self.parsesExecutionReport = parsesExecutionReport
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.storesBrokerFillFact = storesBrokerFillFact
        self.performsReconciliation = performsReconciliation
        self.implementsReconciliationRuntime = implementsReconciliationRuntime
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.mapsSimulatedFillToBrokerFill = mapsSimulatedFillToBrokerFill
        self.mapsSimulatedFillToExecutionReport = mapsSimulatedFillToExecutionReport
        self.mapsPaperPortfolioToBrokerPosition = mapsPaperPortfolioToBrokerPosition
        self.updatesRealAccountFromSimulatedFill = updatesRealAccountFromSimulatedFill
        self.exposesBrokerFillAsCurrentReadModel = exposesBrokerFillAsCurrentReadModel
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
            futureGates: try container.decode(
                [LiveExecutionReportBrokerFillReconciliationFutureGate].self,
                forKey: .futureGates
            ),
            forbiddenCapabilities: try container.decode(
                [LiveExecutionReportBrokerFillReconciliationForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveExecutionControlEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            isBlockedEvidenceOnly: try container.decode(Bool.self, forKey: .isBlockedEvidenceOnly),
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
            parsesExecutionReport: try container.decode(Bool.self, forKey: .parsesExecutionReport),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            storesBrokerFillFact: try container.decode(Bool.self, forKey: .storesBrokerFillFact),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            implementsReconciliationRuntime: try container.decode(
                Bool.self,
                forKey: .implementsReconciliationRuntime
            ),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            mapsSimulatedFillToBrokerFill: try container.decode(
                Bool.self,
                forKey: .mapsSimulatedFillToBrokerFill
            ),
            mapsSimulatedFillToExecutionReport: try container.decode(
                Bool.self,
                forKey: .mapsSimulatedFillToExecutionReport
            ),
            mapsPaperPortfolioToBrokerPosition: try container.decode(
                Bool.self,
                forKey: .mapsPaperPortfolioToBrokerPosition
            ),
            updatesRealAccountFromSimulatedFill: try container.decode(
                Bool.self,
                forKey: .updatesRealAccountFromSimulatedFill
            ),
            exposesBrokerFillAsCurrentReadModel: try container.decode(
                Bool.self,
                forKey: .exposesBrokerFillAsCurrentReadModel
            ),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerms: [LiveExecutionControlTerm] = [
        .executionReport,
        .brokerFill,
        .orderReconciliation
    ]

    public static let requiredFutureGates: [LiveExecutionReportBrokerFillReconciliationFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityIsolationSatisfied,
        .realOrderLifecycleBoundarySatisfied,
        .submitCancelReplaceBoundarySatisfied,
        .executionReportSchemaContractDefined,
        .brokerFillFactContractDefined,
        .reconciliationContractDefined,
        .accountStateReadBoundaryDefined,
        .liveRiskOperationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveExecutionReportBrokerFillReconciliationForbiddenCapability] =
        LiveExecutionReportBrokerFillReconciliationForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperRealIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
        "MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS",
        "MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT",
        "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
        "MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
        "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
        "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
        "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
        "TVM-PAPER-ORDER-LIFECYCLE",
        "TVM-PAPER-SIMULATED-FILL",
        "TVM-PAPER-EXECUTION-WORKFLOW"
    ]

    public static let deterministicFixture: LiveExecutionReportBrokerFillReconciliationBoundary = {
        do {
            return try LiveExecutionReportBrokerFillReconciliationBoundary()
        } catch {
            preconditionFailure("MTP-77 execution report / broker fill / reconciliation fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveExecutionControlTerm],
        futureGates: [LiveExecutionReportBrokerFillReconciliationFutureGate],
        forbiddenCapabilities: [LiveExecutionReportBrokerFillReconciliationForbiddenCapability],
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
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
        isBlockedEvidenceOnly: Bool,
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
        parsesExecutionReport: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        storesBrokerFillFact: Bool,
        performsReconciliation: Bool,
        implementsReconciliationRuntime: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        mapsSimulatedFillToBrokerFill: Bool,
        mapsSimulatedFillToExecutionReport: Bool,
        mapsPaperPortfolioToBrokerPosition: Bool,
        updatesRealAccountFromSimulatedFill: Bool,
        exposesBrokerFillAsCurrentReadModel: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }
        guard isBlockedEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isBlockedEvidenceOnly")
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
            ("parsesExecutionReport", parsesExecutionReport),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("storesBrokerFillFact", storesBrokerFillFact),
            ("performsReconciliation", performsReconciliation),
            ("implementsReconciliationRuntime", implementsReconciliationRuntime),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("mapsSimulatedFillToBrokerFill", mapsSimulatedFillToBrokerFill),
            ("mapsSimulatedFillToExecutionReport", mapsSimulatedFillToExecutionReport),
            ("mapsPaperPortfolioToBrokerPosition", mapsPaperPortfolioToBrokerPosition),
            ("updatesRealAccountFromSimulatedFill", updatesRealAccountFromSimulatedFill),
            ("exposesBrokerFillAsCurrentReadModel", exposesBrokerFillAsCurrentReadModel),
            ("exposesOrderLevelCommandUI", exposesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LivePaperRealCommandIsolationEvidenceSource 固定 MTP-78 允许引用的 paper-only / read-model evidence 来源。
///
/// 这些来源只能作为隔离合同、验证矩阵和 PR evidence 的输入。它们不能被解释为真实订单命令、
/// broker request、execution report、broker fill、account update 或 Dashboard command surface。
public enum LivePaperRealCommandIsolationEvidenceSource: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case paperOrderIntent = "paper order intent"
    case paperExecutionDecision = "paper execution decision"
    case simulatedFillEvidence = "simulated fill evidence"
    case paperPortfolioProjection = "paper portfolio projection"
    case reportReadModel = "report read model"
    case dashboardViewModel = "dashboard ViewModel"
    case eventTimelineReadModel = "event timeline read model"
}

/// LivePaperRealCommandIsolationForbiddenCapability 枚举 MTP-78 必须阻断的 paper-to-real 升级面。
///
/// 这些值只用于 deterministic forbidden capability tests 和合同文档。当前阶段不得新增真实
/// order command、signed command request、broker fill、reconciliation、order form 或交易按钮。
public enum LivePaperRealCommandIsolationForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realOrderCommand = "real order command"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case signedCommandRequest = "signed command request"
    case executionReportIngestion = "execution report ingestion"
    case brokerFillEventFact = "broker fill event fact"
    case reconciliationRuntime = "reconciliation runtime"
    case realAccountState = "real account state"
    case brokerPositionSync = "broker position sync"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realOrderStateMachine = "real order state machine"
    case oms = "OMS"
    case paperOrderIntentToRealCommandUpgrade = "paper order intent to real command upgrade"
    case paperExecutionDecisionToRealCommandUpgrade = "paper execution decision to real command upgrade"
    case simulatedFillToRealCommandUpgrade = "simulated fill to real command upgrade"
    case simulatedFillToExecutionReportUpgrade = "simulated fill to execution report upgrade"
    case simulatedFillToBrokerFillUpgrade = "simulated fill to broker fill upgrade"
    case paperPortfolioToBrokerPositionUpgrade = "paper portfolio to broker position upgrade"
    case reportCommandSurface = "report command surface"
    case dashboardCommandSurface = "dashboard command surface"
    case eventTimelineCommandSurface = "event timeline command surface"
    case orderForm = "order form"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case networkValidationDependency = "network validation dependency"
}

/// LivePaperRealCommandIsolationBoundary 是 MTP-78 的 paper / future real command 隔离合同。
///
/// 该 fixture 把既有 paper order intent、paper execution decision、simulated fill、paper
/// portfolio projection 和 App read-model surface 固定为不可升级证据。它只引用 MTP-75 /
/// MTP-76 / MTP-77 已建立的 future gates，不实现真实命令、adapter、订单状态机、执行回报、
/// broker fill、对账、账户读取、order form、order-level command UI 或交易按钮。
public struct LivePaperRealCommandIsolationBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let evidenceSources: [LivePaperRealCommandIsolationEvidenceSource]
    public let forbiddenCapabilities: [LivePaperRealCommandIsolationForbiddenCapability]
    public let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isIsolationContractOnly: Bool
    public let reportConsumesReadModelOnly: Bool
    public let dashboardConsumesViewModelOnly: Bool
    public let eventTimelineConsumesReadModelOnly: Bool
    public let createsRealOrderCommand: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let sendsSignedCommandRequest: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsRealOrderStateMachine: Bool
    public let implementsOMS: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let mapsPaperOrderIntentToRealCommand: Bool
    public let mapsPaperExecutionDecisionToRealCommand: Bool
    public let mapsSimulatedFillToRealCommand: Bool
    public let mapsSimulatedFillToExecutionReport: Bool
    public let mapsSimulatedFillToBrokerFill: Bool
    public let mapsPaperPortfolioToBrokerPosition: Bool
    public let reportProvidesCommandSurface: Bool
    public let dashboardProvidesCommandSurface: Bool
    public let eventTimelineProvidesCommandSurface: Bool
    public let exposesOrderForm: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var isolationBoundaryHeld: Bool {
        evidenceSources == Self.requiredEvidenceSources
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && isIsolationContractOnly
            && appSurfaceReadModelOnlyBoundaryHeld
            && paperEvidenceCannotUpgradeToRealCommand
            && futureRealCommandCapabilitiesBlocked
            && requiredValidationDependsOnNetwork == false
    }

    public var paperEvidenceCannotUpgradeToRealCommand: Bool {
        mapsPaperOrderIntentToRealCommand == false
            && mapsPaperExecutionDecisionToRealCommand == false
            && mapsSimulatedFillToRealCommand == false
            && mapsSimulatedFillToExecutionReport == false
            && mapsSimulatedFillToBrokerFill == false
            && mapsPaperPortfolioToBrokerPosition == false
    }

    public var futureRealCommandCapabilitiesBlocked: Bool {
        createsRealOrderCommand == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && sendsSignedCommandRequest == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && implementsLiveExecutionAdapter == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
    }

    public var appSurfaceReadModelOnlyBoundaryHeld: Bool {
        reportConsumesReadModelOnly
            && dashboardConsumesViewModelOnly
            && eventTimelineConsumesReadModelOnly
            && reportProvidesCommandSurface == false
            && dashboardProvidesCommandSurface == false
            && eventTimelineProvidesCommandSurface == false
            && exposesOrderForm == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public func forbidsCapability(_ capability: LivePaperRealCommandIsolationForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-78-paper-real-command-isolation-boundary"),
        issueID: Identifier = try! Identifier("MTP-78"),
        evidenceSources: [LivePaperRealCommandIsolationEvidenceSource] = Self.requiredEvidenceSources,
        forbiddenCapabilities: [LivePaperRealCommandIsolationForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isIsolationContractOnly: Bool = true,
        reportConsumesReadModelOnly: Bool = true,
        dashboardConsumesViewModelOnly: Bool = true,
        eventTimelineConsumesReadModelOnly: Bool = true,
        createsRealOrderCommand: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        sendsSignedCommandRequest: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        implementsOMS: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        mapsPaperOrderIntentToRealCommand: Bool = false,
        mapsPaperExecutionDecisionToRealCommand: Bool = false,
        mapsSimulatedFillToRealCommand: Bool = false,
        mapsSimulatedFillToExecutionReport: Bool = false,
        mapsSimulatedFillToBrokerFill: Bool = false,
        mapsPaperPortfolioToBrokerPosition: Bool = false,
        reportProvidesCommandSurface: Bool = false,
        dashboardProvidesCommandSurface: Bool = false,
        eventTimelineProvidesCommandSurface: Bool = false,
        exposesOrderForm: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            evidenceSources: evidenceSources,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isIsolationContractOnly: isIsolationContractOnly,
            reportConsumesReadModelOnly: reportConsumesReadModelOnly,
            dashboardConsumesViewModelOnly: dashboardConsumesViewModelOnly,
            eventTimelineConsumesReadModelOnly: eventTimelineConsumesReadModelOnly,
            createsRealOrderCommand: createsRealOrderCommand,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            sendsSignedCommandRequest: sendsSignedCommandRequest,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            implementsOMS: implementsOMS,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            mapsPaperOrderIntentToRealCommand: mapsPaperOrderIntentToRealCommand,
            mapsPaperExecutionDecisionToRealCommand: mapsPaperExecutionDecisionToRealCommand,
            mapsSimulatedFillToRealCommand: mapsSimulatedFillToRealCommand,
            mapsSimulatedFillToExecutionReport: mapsSimulatedFillToExecutionReport,
            mapsSimulatedFillToBrokerFill: mapsSimulatedFillToBrokerFill,
            mapsPaperPortfolioToBrokerPosition: mapsPaperPortfolioToBrokerPosition,
            reportProvidesCommandSurface: reportProvidesCommandSurface,
            dashboardProvidesCommandSurface: dashboardProvidesCommandSurface,
            eventTimelineProvidesCommandSurface: eventTimelineProvidesCommandSurface,
            exposesOrderForm: exposesOrderForm,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.evidenceSources = evidenceSources
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isIsolationContractOnly = isIsolationContractOnly
        self.reportConsumesReadModelOnly = reportConsumesReadModelOnly
        self.dashboardConsumesViewModelOnly = dashboardConsumesViewModelOnly
        self.eventTimelineConsumesReadModelOnly = eventTimelineConsumesReadModelOnly
        self.createsRealOrderCommand = createsRealOrderCommand
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.sendsSignedCommandRequest = sendsSignedCommandRequest
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.implementsOMS = implementsOMS
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.mapsPaperOrderIntentToRealCommand = mapsPaperOrderIntentToRealCommand
        self.mapsPaperExecutionDecisionToRealCommand = mapsPaperExecutionDecisionToRealCommand
        self.mapsSimulatedFillToRealCommand = mapsSimulatedFillToRealCommand
        self.mapsSimulatedFillToExecutionReport = mapsSimulatedFillToExecutionReport
        self.mapsSimulatedFillToBrokerFill = mapsSimulatedFillToBrokerFill
        self.mapsPaperPortfolioToBrokerPosition = mapsPaperPortfolioToBrokerPosition
        self.reportProvidesCommandSurface = reportProvidesCommandSurface
        self.dashboardProvidesCommandSurface = dashboardProvidesCommandSurface
        self.eventTimelineProvidesCommandSurface = eventTimelineProvidesCommandSurface
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
            evidenceSources: try container.decode(
                [LivePaperRealCommandIsolationEvidenceSource].self,
                forKey: .evidenceSources
            ),
            forbiddenCapabilities: try container.decode(
                [LivePaperRealCommandIsolationForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveExecutionControlEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isIsolationContractOnly: try container.decode(Bool.self, forKey: .isIsolationContractOnly),
            reportConsumesReadModelOnly: try container.decode(Bool.self, forKey: .reportConsumesReadModelOnly),
            dashboardConsumesViewModelOnly: try container.decode(Bool.self, forKey: .dashboardConsumesViewModelOnly),
            eventTimelineConsumesReadModelOnly: try container.decode(
                Bool.self,
                forKey: .eventTimelineConsumesReadModelOnly
            ),
            createsRealOrderCommand: try container.decode(Bool.self, forKey: .createsRealOrderCommand),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            sendsSignedCommandRequest: try container.decode(Bool.self, forKey: .sendsSignedCommandRequest),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            mapsPaperOrderIntentToRealCommand: try container.decode(
                Bool.self,
                forKey: .mapsPaperOrderIntentToRealCommand
            ),
            mapsPaperExecutionDecisionToRealCommand: try container.decode(
                Bool.self,
                forKey: .mapsPaperExecutionDecisionToRealCommand
            ),
            mapsSimulatedFillToRealCommand: try container.decode(Bool.self, forKey: .mapsSimulatedFillToRealCommand),
            mapsSimulatedFillToExecutionReport: try container.decode(
                Bool.self,
                forKey: .mapsSimulatedFillToExecutionReport
            ),
            mapsSimulatedFillToBrokerFill: try container.decode(
                Bool.self,
                forKey: .mapsSimulatedFillToBrokerFill
            ),
            mapsPaperPortfolioToBrokerPosition: try container.decode(
                Bool.self,
                forKey: .mapsPaperPortfolioToBrokerPosition
            ),
            reportProvidesCommandSurface: try container.decode(Bool.self, forKey: .reportProvidesCommandSurface),
            dashboardProvidesCommandSurface: try container.decode(
                Bool.self,
                forKey: .dashboardProvidesCommandSurface
            ),
            eventTimelineProvidesCommandSurface: try container.decode(
                Bool.self,
                forKey: .eventTimelineProvidesCommandSurface
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

    public static let requiredEvidenceSources: [LivePaperRealCommandIsolationEvidenceSource] =
        LivePaperRealCommandIsolationEvidenceSource.allCases

    public static let requiredForbiddenCapabilities: [LivePaperRealCommandIsolationForbiddenCapability] =
        LivePaperRealCommandIsolationForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveExecutionControlEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperRealIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT",
        "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE",
        "MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY",
        "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
        "MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION",
        "TVM-LIVE-EXECUTION-CONTROL"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-75-PAPER-REAL-COMMAND-ISOLATION",
        "MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE",
        "MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT",
        "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
        "TVM-PAPER-ORDER-LIFECYCLE",
        "TVM-PAPER-EXECUTION-DECISION",
        "TVM-PAPER-SIMULATED-FILL",
        "TVM-PAPER-EXECUTION-WORKFLOW",
        "TVM-REPORT-EVIDENCE",
        "TVM-PAPER-WORKFLOW-CONTROL-SHELL"
    ]

    public static let deterministicFixture: LivePaperRealCommandIsolationBoundary = {
        do {
            return try LivePaperRealCommandIsolationBoundary()
        } catch {
            preconditionFailure("MTP-78 paper / real command isolation fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        evidenceSources: [LivePaperRealCommandIsolationEvidenceSource],
        forbiddenCapabilities: [LivePaperRealCommandIsolationForbiddenCapability],
        allowedEvidenceKinds: [LiveExecutionControlEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard evidenceSources == Self.requiredEvidenceSources else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidenceSources",
                expected: Self.requiredEvidenceSources.map(\.rawValue).joined(separator: ","),
                actual: evidenceSources.map(\.rawValue).joined(separator: ",")
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
        isIsolationContractOnly: Bool,
        reportConsumesReadModelOnly: Bool,
        dashboardConsumesViewModelOnly: Bool,
        eventTimelineConsumesReadModelOnly: Bool,
        createsRealOrderCommand: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        sendsSignedCommandRequest: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsRealOrderStateMachine: Bool,
        implementsOMS: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        mapsPaperOrderIntentToRealCommand: Bool,
        mapsPaperExecutionDecisionToRealCommand: Bool,
        mapsSimulatedFillToRealCommand: Bool,
        mapsSimulatedFillToExecutionReport: Bool,
        mapsSimulatedFillToBrokerFill: Bool,
        mapsPaperPortfolioToBrokerPosition: Bool,
        reportProvidesCommandSurface: Bool,
        dashboardProvidesCommandSurface: Bool,
        eventTimelineProvidesCommandSurface: Bool,
        exposesOrderForm: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isIsolationContractOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isIsolationContractOnly")
        }
        guard reportConsumesReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("reportConsumesReadModelOnly")
        }
        guard dashboardConsumesViewModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardConsumesViewModelOnly")
        }
        guard eventTimelineConsumesReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("eventTimelineConsumesReadModelOnly")
        }

        let forbiddenFlags = [
            ("createsRealOrderCommand", createsRealOrderCommand),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("sendsSignedCommandRequest", sendsSignedCommandRequest),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("implementsOMS", implementsOMS),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("mapsPaperOrderIntentToRealCommand", mapsPaperOrderIntentToRealCommand),
            ("mapsPaperExecutionDecisionToRealCommand", mapsPaperExecutionDecisionToRealCommand),
            ("mapsSimulatedFillToRealCommand", mapsSimulatedFillToRealCommand),
            ("mapsSimulatedFillToExecutionReport", mapsSimulatedFillToExecutionReport),
            ("mapsSimulatedFillToBrokerFill", mapsSimulatedFillToBrokerFill),
            ("mapsPaperPortfolioToBrokerPosition", mapsPaperPortfolioToBrokerPosition),
            ("reportProvidesCommandSurface", reportProvidesCommandSurface),
            ("dashboardProvidesCommandSurface", dashboardProvidesCommandSurface),
            ("eventTimelineProvidesCommandSurface", eventTimelineProvidesCommandSurface),
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
