import DomainModel
import Foundation

/// L4LiveProductionAcceptanceDomain 固定 GH-452 验收矩阵必须覆盖的领域。
///
/// 这些领域只用于 L4 合同、validation matrix 和后续 GitHub fallback queue issue 的边界引用。
/// 它们不创建 runtime、不连接 broker、不读取 secret，也不代表当前可以提交、取消或替换真实订单。
public enum L4LiveProductionAcceptanceDomain: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case command = "command"
    case risk = "risk"
    case execution = "execution"
    case audit = "audit"
    case rollback = "rollback"
    case credential = "credential"
    case privateStream = "private stream"
    case dashboardCommandSurface = "dashboard command surface"
    case productionCutover = "production cutover"
}

/// L4LiveProductionCommandGate 描述 L4 命令进入实现前必须满足的门禁。
///
/// Gate 只表达合同要求和验收顺序；当前 GH-452 不实现 credential store、signed endpoint、
/// private stream、ExecutionClient adapter、OMS、RiskEngine runtime、Live PRO Console 或生产切换。
public enum L4LiveProductionCommandGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case githubFallbackQueueWIP1 = "GitHub fallback queue WIP=1"
    case sandboxGate = "sandbox gate"
    case productionDisabledByDefault = "production disabled by default"
    case commandAuthorization = "command authorization"
    case credentialEnvironmentGate = "credential / environment gate"
    case signedEndpointBoundary = "signed endpoint boundary"
    case privateStreamBoundary = "private stream boundary"
    case executionClientVenueAdapterContract = "ExecutionClient venue adapter contract"
    case omsLifecycleStateMachine = "OMS lifecycle state machine"
    case riskEnginePreTradeGate = "RiskEngine pre-trade gate"
    case killSwitchIncidentStopGate = "kill switch / incident stop gate"
    case auditTrailEvidence = "audit trail evidence"
    case rollbackEvidence = "rollback evidence"
    case noDefaultRealTradingPolicy = "no-default-real-trading policy"
}

/// L4LiveProductionForbiddenCapability 枚举 GH-452 仍必须保持关闭的能力。
///
/// 这些值允许进入 deterministic tests、PR evidence 和后续 issue 合同；不得变成当前
/// Swift command、network request、broker adapter、Dashboard control 或 production cutover shortcut。
public enum L4LiveProductionForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionBrokerEndpoint = "production broker endpoint"
    case credentialValuePrint = "credential value print"
    case unguardedSignedEndpoint = "unguarded signed endpoint"
    case unguardedPrivateStream = "unguarded private stream"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case directDashboardBrokerCommand = "direct Dashboard broker command"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case executionReportProductionIngestion = "execution report production ingestion"
    case brokerFillProductionIngestion = "broker fill production ingestion"
    case reconciliationProductionRuntime = "reconciliation production runtime"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
    case parallelActiveIssue = "parallel active issue"
}

/// L4LiveProductionAcceptanceMatrixEntry 是单个 L4 验收域的可审计矩阵行。
///
/// 每一行必须说明验收域、依赖的 gate、后续 issue anchor 和当前禁止能力。该结构只保存
/// contract evidence，不执行命令、不访问网络、不保存 credential，也不修改任何 broker / OMS 状态。
public struct L4LiveProductionAcceptanceMatrixEntry: Codable, Equatable, Sendable {
    public let domain: L4LiveProductionAcceptanceDomain
    public let requiredGates: [L4LiveProductionCommandGate]
    public let issueAnchors: [String]
    public let forbiddenCapabilities: [L4LiveProductionForbiddenCapability]

    public init(
        domain: L4LiveProductionAcceptanceDomain,
        requiredGates: [L4LiveProductionCommandGate],
        issueAnchors: [String],
        forbiddenCapabilities: [L4LiveProductionForbiddenCapability]
    ) throws {
        guard requiredGates.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredGates",
                expected: "non-empty L4 command gates",
                actual: "empty"
            )
        }
        guard issueAnchors.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueAnchors",
                expected: "non-empty GitHub issue anchors",
                actual: "empty"
            )
        }
        guard forbiddenCapabilities.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: "non-empty forbidden capability list",
                actual: "empty"
            )
        }

        self.domain = domain
        self.requiredGates = requiredGates
        self.issueAnchors = issueAnchors
        self.forbiddenCapabilities = forbiddenCapabilities
    }
}

/// L4LiveProductionCommandContract 是 GH-452 的 L4 顶层命令合同 fixture。
///
/// 合同固定 read-only evidence 到 guarded command 的转换规则、sandbox / production gate、
/// command authorization、evidence identity、rollback evidence 和 no-default-real-trading policy。
/// 所有 production、secret、signed endpoint、private stream、ExecutionClient、OMS、RiskEngine runtime、
/// Live PRO Console 和 order form 旗标必须保持关闭；后续 GH-453 至 GH-472 只能逐项解锁自己的 scope。
public struct L4LiveProductionCommandContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let canonicalQueueRange: String
    public let maturitySlice: String
    public let commandGates: [L4LiveProductionCommandGate]
    public let acceptanceMatrix: [L4LiveProductionAcceptanceMatrixEntry]
    public let forbiddenCapabilities: [L4LiveProductionForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let sandboxGateRequiredBeforeCommand: Bool
    public let commandAuthorizationRequired: Bool
    public let riskGateRequiredBeforeExecution: Bool
    public let omsGateRequiredBeforeExecutionClient: Bool
    public let auditTrailRequired: Bool
    public let rollbackEvidenceRequired: Bool
    public let noDefaultRealTradingPolicyRequired: Bool
    public let readsCredentialValue: Bool
    public let printsCredentialValue: Bool
    public let connectsProductionEndpoint: Bool
    public let usesSignedEndpoint: Bool
    public let opensPrivateStream: Bool
    public let implementsExecutionClientAdapter: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let exposesLiveProConsoleCommandSurface: Bool
    public let exposesOrderForm: Bool

    public var contractHeld: Bool {
        commandGates == Self.requiredCommandGates
            && acceptanceMatrix == Self.requiredAcceptanceMatrix
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && sandboxGateRequiredBeforeCommand
            && commandAuthorizationRequired
            && riskGateRequiredBeforeExecution
            && omsGateRequiredBeforeExecutionClient
            && auditTrailRequired
            && rollbackEvidenceRequired
            && noDefaultRealTradingPolicyRequired
            && readsCredentialValue == false
            && printsCredentialValue == false
            && connectsProductionEndpoint == false
            && usesSignedEndpoint == false
            && opensPrivateStream == false
            && implementsExecutionClientAdapter == false
            && implementsOMS == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && exposesLiveProConsoleCommandSurface == false
            && exposesOrderForm == false
    }

    public var acceptanceMatrixCoverageHeld: Bool {
        Set(acceptanceMatrix.map(\.domain)) == Set(L4LiveProductionAcceptanceDomain.allCases)
            && acceptanceMatrix.allSatisfy { $0.requiredGates.isEmpty == false }
            && acceptanceMatrix.allSatisfy { $0.issueAnchors.isEmpty == false }
            && acceptanceMatrix.allSatisfy { $0.forbiddenCapabilities.isEmpty == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-452-l4-live-production-command-contract"),
        issueID: Identifier = Identifier.constant("GH-452"),
        canonicalQueueRange: String = "GH-452..GH-472",
        maturitySlice: String = "MTPRO L4 Live Production / Trading Commands v1",
        commandGates: [L4LiveProductionCommandGate] = Self.requiredCommandGates,
        acceptanceMatrix: [L4LiveProductionAcceptanceMatrixEntry] = Self.requiredAcceptanceMatrix,
        forbiddenCapabilities: [L4LiveProductionForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        sandboxGateRequiredBeforeCommand: Bool = true,
        commandAuthorizationRequired: Bool = true,
        riskGateRequiredBeforeExecution: Bool = true,
        omsGateRequiredBeforeExecutionClient: Bool = true,
        auditTrailRequired: Bool = true,
        rollbackEvidenceRequired: Bool = true,
        noDefaultRealTradingPolicyRequired: Bool = true,
        readsCredentialValue: Bool = false,
        printsCredentialValue: Bool = false,
        connectsProductionEndpoint: Bool = false,
        usesSignedEndpoint: Bool = false,
        opensPrivateStream: Bool = false,
        implementsExecutionClientAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveProConsoleCommandSurface: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        try Self.validate(
            commandGates: commandGates,
            acceptanceMatrix: acceptanceMatrix,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            sandboxGateRequiredBeforeCommand: sandboxGateRequiredBeforeCommand,
            commandAuthorizationRequired: commandAuthorizationRequired,
            riskGateRequiredBeforeExecution: riskGateRequiredBeforeExecution,
            omsGateRequiredBeforeExecutionClient: omsGateRequiredBeforeExecutionClient,
            auditTrailRequired: auditTrailRequired,
            rollbackEvidenceRequired: rollbackEvidenceRequired,
            noDefaultRealTradingPolicyRequired: noDefaultRealTradingPolicyRequired,
            readsCredentialValue: readsCredentialValue,
            printsCredentialValue: printsCredentialValue,
            connectsProductionEndpoint: connectsProductionEndpoint,
            usesSignedEndpoint: usesSignedEndpoint,
            opensPrivateStream: opensPrivateStream,
            implementsExecutionClientAdapter: implementsExecutionClientAdapter,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            exposesLiveProConsoleCommandSurface: exposesLiveProConsoleCommandSurface,
            exposesOrderForm: exposesOrderForm
        )

        self.contractID = contractID
        self.issueID = issueID
        self.canonicalQueueRange = canonicalQueueRange
        self.maturitySlice = maturitySlice
        self.commandGates = commandGates
        self.acceptanceMatrix = acceptanceMatrix
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.sandboxGateRequiredBeforeCommand = sandboxGateRequiredBeforeCommand
        self.commandAuthorizationRequired = commandAuthorizationRequired
        self.riskGateRequiredBeforeExecution = riskGateRequiredBeforeExecution
        self.omsGateRequiredBeforeExecutionClient = omsGateRequiredBeforeExecutionClient
        self.auditTrailRequired = auditTrailRequired
        self.rollbackEvidenceRequired = rollbackEvidenceRequired
        self.noDefaultRealTradingPolicyRequired = noDefaultRealTradingPolicyRequired
        self.readsCredentialValue = readsCredentialValue
        self.printsCredentialValue = printsCredentialValue
        self.connectsProductionEndpoint = connectsProductionEndpoint
        self.usesSignedEndpoint = usesSignedEndpoint
        self.opensPrivateStream = opensPrivateStream
        self.implementsExecutionClientAdapter = implementsExecutionClientAdapter
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.exposesLiveProConsoleCommandSurface = exposesLiveProConsoleCommandSurface
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> L4LiveProductionCommandContract {
        try L4LiveProductionCommandContract()
    }

    public static let requiredCommandGates: [L4LiveProductionCommandGate] =
        L4LiveProductionCommandGate.allCases

    public static let requiredForbiddenCapabilities: [L4LiveProductionForbiddenCapability] =
        L4LiveProductionForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT",
        "GH-452-READONLY-TO-GUARDED-COMMAND-RULE",
        "GH-452-SANDBOX-PRODUCTION-GATE",
        "GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY",
        "GH-452-ACCEPTANCE-MATRIX",
        "GH-452-NO-DEFAULT-REAL-TRADING-POLICY",
        "TVM-L4-LIVE-PRODUCTION-COMMANDS"
    ]

    public static let requiredValidationCommands: [String] = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredAcceptanceMatrix: [L4LiveProductionAcceptanceMatrixEntry] = {
        do {
            return try [
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .command,
                    requiredGates: [.githubFallbackQueueWIP1, .sandboxGate, .commandAuthorization],
                    issueAnchors: ["GH-452", "GH-459", "GH-469"],
                    forbiddenCapabilities: [.realSubmitCancelReplace, .directDashboardBrokerCommand, .parallelActiveIssue]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .risk,
                    requiredGates: [.riskEnginePreTradeGate, .killSwitchIncidentStopGate],
                    issueAnchors: ["GH-464", "GH-465", "GH-470"],
                    forbiddenCapabilities: [.riskEngineBypass, .productionTradingEnabledByDefault]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .execution,
                    requiredGates: [
                        .executionClientVenueAdapterContract,
                        .omsLifecycleStateMachine,
                        .signedEndpointBoundary
                    ],
                    issueAnchors: ["GH-458", "GH-459", "GH-460", "GH-461", "GH-462", "GH-463"],
                    forbiddenCapabilities: [
                        .unguardedSignedEndpoint,
                        .omsBypass,
                        .executionReportProductionIngestion,
                        .brokerFillProductionIngestion
                    ]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .audit,
                    requiredGates: [.auditTrailEvidence, .killSwitchIncidentStopGate],
                    issueAnchors: ["GH-465", "GH-467", "GH-472"],
                    forbiddenCapabilities: [.liveProConsoleCommandSurface, .productionBrokerEndpoint]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .rollback,
                    requiredGates: [.rollbackEvidence, .killSwitchIncidentStopGate],
                    issueAnchors: ["GH-465", "GH-466", "GH-467", "GH-470"],
                    forbiddenCapabilities: [.reconciliationProductionRuntime, .productionTradingEnabledByDefault]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .credential,
                    requiredGates: [.credentialEnvironmentGate, .productionDisabledByDefault],
                    issueAnchors: ["GH-453", "GH-454", "GH-455"],
                    forbiddenCapabilities: [.credentialValuePrint, .productionBrokerEndpoint]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .privateStream,
                    requiredGates: [.privateStreamBoundary, .signedEndpointBoundary],
                    issueAnchors: ["GH-454", "GH-456", "GH-457"],
                    forbiddenCapabilities: [.unguardedPrivateStream, .unguardedSignedEndpoint]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .dashboardCommandSurface,
                    requiredGates: [.commandAuthorization, .riskEnginePreTradeGate, .auditTrailEvidence],
                    issueAnchors: ["GH-468", "GH-469"],
                    forbiddenCapabilities: [.directDashboardBrokerCommand, .liveProConsoleCommandSurface, .orderForm]
                ),
                L4LiveProductionAcceptanceMatrixEntry(
                    domain: .productionCutover,
                    requiredGates: [.productionDisabledByDefault, .noDefaultRealTradingPolicy, .rollbackEvidence],
                    issueAnchors: ["GH-470", "GH-471", "GH-472"],
                    forbiddenCapabilities: [.productionTradingEnabledByDefault, .productionBrokerEndpoint]
                )
            ]
        } catch {
            preconditionFailure("GH-452 L4 acceptance matrix fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        commandGates: [L4LiveProductionCommandGate],
        acceptanceMatrix: [L4LiveProductionAcceptanceMatrixEntry],
        forbiddenCapabilities: [L4LiveProductionForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard commandGates == Self.requiredCommandGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandGates",
                expected: Self.requiredCommandGates.map(\.rawValue).joined(separator: ","),
                actual: commandGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard acceptanceMatrix == Self.requiredAcceptanceMatrix else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "acceptanceMatrix",
                expected: "GH-452 required acceptance matrix",
                actual: "\(acceptanceMatrix.map(\.domain.rawValue))"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        sandboxGateRequiredBeforeCommand: Bool,
        commandAuthorizationRequired: Bool,
        riskGateRequiredBeforeExecution: Bool,
        omsGateRequiredBeforeExecutionClient: Bool,
        auditTrailRequired: Bool,
        rollbackEvidenceRequired: Bool,
        noDefaultRealTradingPolicyRequired: Bool,
        readsCredentialValue: Bool,
        printsCredentialValue: Bool,
        connectsProductionEndpoint: Bool,
        usesSignedEndpoint: Bool,
        opensPrivateStream: Bool,
        implementsExecutionClientAdapter: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        exposesLiveProConsoleCommandSurface: Bool,
        exposesOrderForm: Bool
    ) throws {
        for requiredGate in [
            ("sandboxGateRequiredBeforeCommand", sandboxGateRequiredBeforeCommand),
            ("commandAuthorizationRequired", commandAuthorizationRequired),
            ("riskGateRequiredBeforeExecution", riskGateRequiredBeforeExecution),
            ("omsGateRequiredBeforeExecutionClient", omsGateRequiredBeforeExecutionClient),
            ("auditTrailRequired", auditTrailRequired),
            ("rollbackEvidenceRequired", rollbackEvidenceRequired),
            ("noDefaultRealTradingPolicyRequired", noDefaultRealTradingPolicyRequired)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredGate.0,
                expected: "true",
                actual: "false"
            )
        }

        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("readsCredentialValue", readsCredentialValue),
            ("printsCredentialValue", printsCredentialValue),
            ("connectsProductionEndpoint", connectsProductionEndpoint),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("opensPrivateStream", opensPrivateStream),
            ("implementsExecutionClientAdapter", implementsExecutionClientAdapter),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveProConsoleCommandSurface", exposesLiveProConsoleCommandSurface),
            ("exposesOrderForm", exposesOrderForm)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }
    }
}
