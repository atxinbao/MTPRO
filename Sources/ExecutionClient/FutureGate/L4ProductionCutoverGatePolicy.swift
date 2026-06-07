import DomainModel
import Foundation

/// L4ProductionCutoverPrerequisite 固定 GH-471 production cutover 只能作为 future gate 的前置条件。
///
/// 这些前置条件只用于合同、PR evidence 和 stage audit input，不会读取 credential、
/// 连接 production endpoint、启用 broker gateway 或提交真实订单。
public enum L4ProductionCutoverPrerequisite: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandboxValidationMatrixClosed = "sandbox validation matrix closed"
    case humanProjectApproval = "human project approval"
    case manualProductionConfirmation = "manual production confirmation"
    case credentialIsolation = "credential isolation"
    case environmentIsolation = "environment isolation"
    case incidentStopReady = "incident stop ready"
    case rollbackPlanReady = "rollback plan ready"
    case auditTrailReady = "audit trail ready"
    case reconciliationEvidenceReady = "reconciliation evidence ready"
    case stageAuditInputReady = "stage audit input ready"
    case noDefaultRealTradingPolicy = "no-default-real-trading policy"
}

/// L4ProductionCutoverAcceptanceCriterion 描述 future production cutover 的人工验收条件。
///
/// `requiresHumanAcceptance` 必须保持 true，表示本合同不能由本地验证、CI 或 hidden flag
/// 自动打开 production trading。`evidenceAnchor` 只能是 issue / 文档锚点，不能是 secret value。
public struct L4ProductionCutoverAcceptanceCriterion: Codable, Equatable, Sendable {
    public let name: String
    public let evidenceAnchor: String
    public let upstreamIssueAnchors: [String]
    public let requiresHumanAcceptance: Bool
    public let allowsAutomationOnlyCutover: Bool

    public init(
        name: String,
        evidenceAnchor: String,
        upstreamIssueAnchors: [String],
        requiresHumanAcceptance: Bool = true,
        allowsAutomationOnlyCutover: Bool = false
    ) throws {
        guard name.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "name",
                expected: "non-empty production cutover acceptance criterion",
                actual: "empty"
            )
        }
        guard evidenceAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidenceAnchor",
                expected: "non-empty evidence anchor",
                actual: "empty"
            )
        }
        guard upstreamIssueAnchors.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueAnchors",
                expected: "non-empty upstream issue anchors",
                actual: "empty"
            )
        }
        guard requiresHumanAcceptance else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("requiresHumanAcceptance.false")
        }
        guard allowsAutomationOnlyCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsAutomationOnlyCutover")
        }

        self.name = name
        self.evidenceAnchor = evidenceAnchor
        self.upstreamIssueAnchors = upstreamIssueAnchors
        self.requiresHumanAcceptance = requiresHumanAcceptance
        self.allowsAutomationOnlyCutover = allowsAutomationOnlyCutover
    }
}

/// L4ProductionCutoverForbiddenCapability 枚举 GH-471 仍必须保持关闭的 production 能力。
///
/// 这些 forbidden flags 是 no-default-real-trading policy 的机械证据；它们不能变成
/// 环境变量捷径、Dashboard 控件、broker adapter、signed request 或真实订单 lifecycle。
public enum L4ProductionCutoverForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case automaticProductionCutover = "automatic production cutover"
    case automationOnlyCutover = "automation-only cutover"
    case secretValueRead = "secret value read"
    case secretStorage = "secret storage"
    case signedEndpointCall = "signed endpoint call"
    case productionEndpointConnection = "production endpoint connection"
    case brokerGatewayEnablement = "broker gateway enablement"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case dashboardCommandBypass = "Dashboard command bypass"
    case liveProConsoleProductionCommand = "Live PRO Console production command"
    case orderForm = "order form"
    case tradingButton = "trading button"
    case missingIncidentStopGate = "missing incident stop gate"
    case missingRollbackEvidence = "missing rollback evidence"
    case stageAuditBypass = "stage audit bypass"
}

/// L4ProductionCutoverGatePolicy 是 GH-471 的 production cutover / no-default-real-trading 合同。
///
/// 合同只定义从 sandbox 进入 future production 的人工与技术门槛：sandbox matrix 已关闭、
/// human acceptance、环境隔离、credential handling、incident stop readiness、rollback evidence
/// 和 Stage Audit input。当前 issue 不执行 production cutover，不读取 secret，不连接 broker，
/// 不实现 order form、trading button 或真实 submit / cancel / replace。
public struct L4ProductionCutoverGatePolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let maturitySlice: String
    public let prerequisites: [L4ProductionCutoverPrerequisite]
    public let acceptanceCriteria: [L4ProductionCutoverAcceptanceCriterion]
    public let forbiddenCapabilities: [L4ProductionCutoverForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionCutoverIsFutureGate: Bool
    public let humanAcceptanceRequired: Bool
    public let sandboxValidationMatrixClosureRequired: Bool
    public let stageAuditInputRequiredBeforeCutover: Bool
    public let noDefaultRealTradingPolicyRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let automaticProductionCutoverEnabled: Bool
    public let automationOnlyCutoverAllowed: Bool
    public let readsCredentialValue: Bool
    public let storesSecret: Bool
    public let callsSignedEndpoint: Bool
    public let connectsProductionEndpoint: Bool
    public let enablesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let exposesDashboardCommandBypass: Bool
    public let exposesLiveProConsoleProductionCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesTradingButton: Bool

    public var policyHeld: Bool {
        upstreamIssueID.rawValue == "GH-470"
            && downstreamIssueID.rawValue == "GH-472"
            && canonicalQueueRange == "GH-452..GH-472"
            && prerequisites == Self.requiredPrerequisites
            && acceptanceCriteria == Self.requiredAcceptanceCriteria
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionCutoverIsFutureGate
            && humanAcceptanceRequired
            && sandboxValidationMatrixClosureRequired
            && stageAuditInputRequiredBeforeCutover
            && noDefaultRealTradingPolicyRequired
            && allForbiddenFlagsRemainClosed
    }

    public var acceptanceCriteriaCoverageHeld: Bool {
        Set(acceptanceCriteria.map(\.evidenceAnchor)) == Set(Self.requiredAcceptanceCriteria.map(\.evidenceAnchor))
            && acceptanceCriteria.allSatisfy(\.requiresHumanAcceptance)
            && acceptanceCriteria.allSatisfy { $0.allowsAutomationOnlyCutover == false }
            && acceptanceCriteria.allSatisfy { $0.upstreamIssueAnchors.contains("GH-470") }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionTradingEnabledByDefault,
            automaticProductionCutoverEnabled,
            automationOnlyCutoverAllowed,
            readsCredentialValue,
            storesSecret,
            callsSignedEndpoint,
            connectsProductionEndpoint,
            enablesBrokerGateway,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            exposesDashboardCommandBypass,
            exposesLiveProConsoleProductionCommand,
            exposesOrderForm,
            exposesTradingButton
        ].allSatisfy { $0 == false }
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-471-l4-production-cutover-gate-policy"),
        issueID: Identifier = Identifier.constant("GH-471"),
        upstreamIssueID: Identifier = Identifier.constant("GH-470"),
        downstreamIssueID: Identifier = Identifier.constant("GH-472"),
        canonicalQueueRange: String = "GH-452..GH-472",
        maturitySlice: String = "MTPRO L4 Live Production / Trading Commands v1",
        prerequisites: [L4ProductionCutoverPrerequisite] = Self.requiredPrerequisites,
        acceptanceCriteria: [L4ProductionCutoverAcceptanceCriterion] = Self.requiredAcceptanceCriteria,
        forbiddenCapabilities: [L4ProductionCutoverForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionCutoverIsFutureGate: Bool = true,
        humanAcceptanceRequired: Bool = true,
        sandboxValidationMatrixClosureRequired: Bool = true,
        stageAuditInputRequiredBeforeCutover: Bool = true,
        noDefaultRealTradingPolicyRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        automaticProductionCutoverEnabled: Bool = false,
        automationOnlyCutoverAllowed: Bool = false,
        readsCredentialValue: Bool = false,
        storesSecret: Bool = false,
        callsSignedEndpoint: Bool = false,
        connectsProductionEndpoint: Bool = false,
        enablesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        exposesDashboardCommandBypass: Bool = false,
        exposesLiveProConsoleProductionCommand: Bool = false,
        exposesOrderForm: Bool = false,
        exposesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            prerequisites: prerequisites,
            acceptanceCriteria: acceptanceCriteria,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            productionCutoverIsFutureGate: productionCutoverIsFutureGate,
            humanAcceptanceRequired: humanAcceptanceRequired,
            sandboxValidationMatrixClosureRequired: sandboxValidationMatrixClosureRequired,
            stageAuditInputRequiredBeforeCutover: stageAuditInputRequiredBeforeCutover,
            noDefaultRealTradingPolicyRequired: noDefaultRealTradingPolicyRequired
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            automaticProductionCutoverEnabled: automaticProductionCutoverEnabled,
            automationOnlyCutoverAllowed: automationOnlyCutoverAllowed,
            readsCredentialValue: readsCredentialValue,
            storesSecret: storesSecret,
            callsSignedEndpoint: callsSignedEndpoint,
            connectsProductionEndpoint: connectsProductionEndpoint,
            enablesBrokerGateway: enablesBrokerGateway,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            exposesDashboardCommandBypass: exposesDashboardCommandBypass,
            exposesLiveProConsoleProductionCommand: exposesLiveProConsoleProductionCommand,
            exposesOrderForm: exposesOrderForm,
            exposesTradingButton: exposesTradingButton
        )

        self.policyID = policyID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.maturitySlice = maturitySlice
        self.prerequisites = prerequisites
        self.acceptanceCriteria = acceptanceCriteria
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionCutoverIsFutureGate = productionCutoverIsFutureGate
        self.humanAcceptanceRequired = humanAcceptanceRequired
        self.sandboxValidationMatrixClosureRequired = sandboxValidationMatrixClosureRequired
        self.stageAuditInputRequiredBeforeCutover = stageAuditInputRequiredBeforeCutover
        self.noDefaultRealTradingPolicyRequired = noDefaultRealTradingPolicyRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.automaticProductionCutoverEnabled = automaticProductionCutoverEnabled
        self.automationOnlyCutoverAllowed = automationOnlyCutoverAllowed
        self.readsCredentialValue = readsCredentialValue
        self.storesSecret = storesSecret
        self.callsSignedEndpoint = callsSignedEndpoint
        self.connectsProductionEndpoint = connectsProductionEndpoint
        self.enablesBrokerGateway = enablesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.exposesDashboardCommandBypass = exposesDashboardCommandBypass
        self.exposesLiveProConsoleProductionCommand = exposesLiveProConsoleProductionCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesTradingButton = exposesTradingButton
    }

    public static func deterministicFixture() throws -> L4ProductionCutoverGatePolicy {
        try L4ProductionCutoverGatePolicy()
    }

    public static let requiredPrerequisites: [L4ProductionCutoverPrerequisite] =
        L4ProductionCutoverPrerequisite.allCases

    public static let requiredForbiddenCapabilities: [L4ProductionCutoverForbiddenCapability] =
        L4ProductionCutoverForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "GH-471-PRODUCTION-CUTOVER-FUTURE-GATE",
        "GH-471-NO-DEFAULT-REAL-TRADING-POLICY",
        "GH-471-HUMAN-ACCEPTANCE-CRITERIA",
        "GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES",
        "GH-471-NON-AUTHORIZATION",
        "TVM-L4-PRODUCTION-CUTOVER-GATE"
    ]

    public static let requiredValidationCommands: [String] = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredAcceptanceCriteria: [L4ProductionCutoverAcceptanceCriterion] = {
        do {
            return try [
                L4ProductionCutoverAcceptanceCriterion(
                    name: "sandbox matrix closure",
                    evidenceAnchor: "GH-470-SANDBOX-VALIDATION-MATRIX-CLOSEOUT",
                    upstreamIssueAnchors: ["GH-470"]
                ),
                L4ProductionCutoverAcceptanceCriterion(
                    name: "manual production approval",
                    evidenceAnchor: "GH-471-HUMAN-ACCEPTANCE-CRITERIA",
                    upstreamIssueAnchors: ["GH-470", "GH-471"]
                ),
                L4ProductionCutoverAcceptanceCriterion(
                    name: "credential and environment isolation",
                    evidenceAnchor: "GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES",
                    upstreamIssueAnchors: ["GH-453", "GH-454", "GH-470", "GH-471"]
                ),
                L4ProductionCutoverAcceptanceCriterion(
                    name: "incident stop and rollback readiness",
                    evidenceAnchor: "GH-471-NO-DEFAULT-REAL-TRADING-POLICY",
                    upstreamIssueAnchors: ["GH-465", "GH-466", "GH-467", "GH-470", "GH-471"]
                ),
                L4ProductionCutoverAcceptanceCriterion(
                    name: "stage audit input handoff",
                    evidenceAnchor: "GH-472-STAGE-AUDIT-INPUT-REQUIRED",
                    upstreamIssueAnchors: ["GH-470", "GH-471", "GH-472"]
                )
            ]
        } catch {
            preconditionFailure("GH-471 production cutover acceptance fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        prerequisites: [L4ProductionCutoverPrerequisite],
        acceptanceCriteria: [L4ProductionCutoverAcceptanceCriterion],
        forbiddenCapabilities: [L4ProductionCutoverForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard prerequisites == Self.requiredPrerequisites else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "prerequisites",
                expected: Self.requiredPrerequisites.map(\.rawValue).joined(separator: ","),
                actual: prerequisites.map(\.rawValue).joined(separator: ",")
            )
        }
        guard acceptanceCriteria == Self.requiredAcceptanceCriteria else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "acceptanceCriteria",
                expected: "GH-471 required human acceptance criteria",
                actual: "\(acceptanceCriteria.map(\.name))"
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

    private static func validateRequiredFlags(
        productionCutoverIsFutureGate: Bool,
        humanAcceptanceRequired: Bool,
        sandboxValidationMatrixClosureRequired: Bool,
        stageAuditInputRequiredBeforeCutover: Bool,
        noDefaultRealTradingPolicyRequired: Bool
    ) throws {
        for requiredFlag in [
            ("productionCutoverIsFutureGate", productionCutoverIsFutureGate),
            ("humanAcceptanceRequired", humanAcceptanceRequired),
            ("sandboxValidationMatrixClosureRequired", sandboxValidationMatrixClosureRequired),
            ("stageAuditInputRequiredBeforeCutover", stageAuditInputRequiredBeforeCutover),
            ("noDefaultRealTradingPolicyRequired", noDefaultRealTradingPolicyRequired)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
    }

    private static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        automaticProductionCutoverEnabled: Bool,
        automationOnlyCutoverAllowed: Bool,
        readsCredentialValue: Bool,
        storesSecret: Bool,
        callsSignedEndpoint: Bool,
        connectsProductionEndpoint: Bool,
        enablesBrokerGateway: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        exposesDashboardCommandBypass: Bool,
        exposesLiveProConsoleProductionCommand: Bool,
        exposesOrderForm: Bool,
        exposesTradingButton: Bool
    ) throws {
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("automaticProductionCutoverEnabled", automaticProductionCutoverEnabled),
            ("automationOnlyCutoverAllowed", automationOnlyCutoverAllowed),
            ("readsCredentialValue", readsCredentialValue),
            ("storesSecret", storesSecret),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("connectsProductionEndpoint", connectsProductionEndpoint),
            ("enablesBrokerGateway", enablesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("exposesDashboardCommandBypass", exposesDashboardCommandBypass),
            ("exposesLiveProConsoleProductionCommand", exposesLiveProConsoleProductionCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("exposesTradingButton", exposesTradingButton)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }
    }
}
