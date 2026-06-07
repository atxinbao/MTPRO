import DomainModel
import Foundation

/// ProductionCutoverEnvironmentScope 固定 GH-504 的环境分层。
///
/// 这些 scope 只用于 readiness evidence。它们不读取 secret、不连接 broker、不提交真实订单，
/// 也不允许 dry-run、shadow 或 sandbox command 隐式升级为 production command。
public enum ProductionCutoverEnvironmentScope: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case local = "local"
    case fixture = "fixture"
    case dryRun = "dry-run"
    case shadow = "shadow"
    case productionBlocked = "production blocked"
    case futureProduction = "future production"
}

/// ProductionCutoverEnvironmentGate 描述 GH-504 的 environment isolation gate。
///
/// Gate 只约束切换证据和默认 blocked 行为；它不是 production runtime、自动环境切换器、
/// broker connector、OMS、LiveExecutionAdapter 或真实订单命令。
public enum ProductionCutoverEnvironmentGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionNoDefaultTrading = "production no-default-trading"
    case sandboxDryRunProductionSeparation = "sandbox / dry-run / production separation"
    case explicitEnvironmentSwitchEvidence = "explicit environment switch evidence"
    case auditableEnvironmentSwitchEvidence = "auditable environment switch evidence"
    case manualApprovalRequiredBeforeProduction = "manual approval required before production"
    case noAutomaticBrokerConnection = "no automatic broker connection"
    case noDefaultSecretRead = "no default secret read"
    case noRealOrderSubmission = "no real order submission"
}

/// ProductionCutoverEnvironmentForbiddenCapability 枚举 GH-504 必须保持关闭的能力。
public enum ProductionCutoverEnvironmentForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionRuntime = "production runtime"
    case automaticEnvironmentSwitch = "automatic environment switch"
    case defaultSecretRead = "default secret read"
    case brokerConnection = "broker connection"
    case brokerAdapterImplementation = "broker adapter implementation"
    case omsImplementation = "OMS implementation"
    case liveExecutionAdapterImplementation = "LiveExecutionAdapter implementation"
    case sandboxCommandPromotesProductionCommand = "sandbox command promotes production command"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveCommandSurface = "live command surface"
    case tradingButton = "trading button"
    case orderForm = "order form"
}

/// ProductionCutoverEnvironmentSwitchEvidence 表达环境切换 readiness evidence。
///
/// Evidence 只描述 from/to scope、trigger 和 blocked reason。任何 automatic switch、secret read、
/// broker connection 或真实订单能力都会被拒绝。
public struct ProductionCutoverEnvironmentSwitchEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let fromScope: ProductionCutoverEnvironmentScope
    public let toScope: ProductionCutoverEnvironmentScope
    public let triggerIdentity: String
    public let blockedReason: String
    public let requiresManualApproval: Bool
    public let allowsAutomaticSwitch: Bool
    public let readsSecretValue: Bool
    public let connectsBroker: Bool
    public let submitsRealOrder: Bool

    public init(
        evidenceID: Identifier,
        fromScope: ProductionCutoverEnvironmentScope,
        toScope: ProductionCutoverEnvironmentScope,
        triggerIdentity: String,
        blockedReason: String,
        requiresManualApproval: Bool = true,
        allowsAutomaticSwitch: Bool = false,
        readsSecretValue: Bool = false,
        connectsBroker: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard triggerIdentity.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "triggerIdentity",
                expected: "non-empty environment switch trigger identity",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty environment blocked reason",
                actual: "empty"
            )
        }
        guard requiresManualApproval else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiresManualApproval",
                expected: "true",
                actual: "false"
            )
        }
        guard allowsAutomaticSwitch == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsAutomaticSwitch")
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsSecretValue")
        }
        guard connectsBroker == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("connectsBroker")
        }
        guard submitsRealOrder == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("submitsRealOrder")
        }

        self.evidenceID = evidenceID
        self.fromScope = fromScope
        self.toScope = toScope
        self.triggerIdentity = triggerIdentity
        self.blockedReason = blockedReason
        self.requiresManualApproval = requiresManualApproval
        self.allowsAutomaticSwitch = allowsAutomaticSwitch
        self.readsSecretValue = readsSecretValue
        self.connectsBroker = connectsBroker
        self.submitsRealOrder = submitsRealOrder
    }
}

/// ProductionCutoverEnvironmentIsolationGateContract 是 GH-504 的 environment isolation 合同。
///
/// 合同定义 local、fixture、dry-run、shadow、production-blocked 和 future-production 的隔离关系，
/// 并固定 production 默认 no-trading / blocked / dry-run。它不实现 production runtime、不连接
/// broker、不读取 secret、不暴露 Live command UI。
public struct ProductionCutoverEnvironmentIsolationGateContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let projectName: String
    public let canonicalQueueRange: String
    public let scopes: [ProductionCutoverEnvironmentScope]
    public let gates: [ProductionCutoverEnvironmentGate]
    public let forbiddenCapabilities: [ProductionCutoverEnvironmentForbiddenCapability]
    public let switchEvidence: [ProductionCutoverEnvironmentSwitchEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialPolicyGateRequired: Bool
    public let productionNoDefaultTradingRequired: Bool
    public let sandboxCommandProductionCommandIsolationRequired: Bool
    public let explicitAuditableEnvironmentSwitchRequired: Bool
    public let manualApprovalCannotBeBypassed: Bool
    public let productionBlockedDryRunDefault: Bool
    public let implementsProductionRuntime: Bool
    public let allowsAutomaticEnvironmentSwitch: Bool
    public let readsSecretValue: Bool
    public let connectsBroker: Bool
    public let implementsBrokerAdapter: Bool
    public let implementsOMS: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let sandboxCommandPromotesProductionCommand: Bool
    public let productionTradingEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let exposesLiveCommandSurface: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-504"
            && upstreamIssueID.rawValue == "GH-503"
            && projectName == ProductionCutoverCredentialSecretPolicyGate.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && scopes == Self.requiredScopes
            && gates == Self.requiredGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && switchEvidence == Self.requiredSwitchEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && credentialPolicyGateRequired
            && productionNoDefaultTradingRequired
            && sandboxCommandProductionCommandIsolationRequired
            && explicitAuditableEnvironmentSwitchRequired
            && manualApprovalCannotBeBypassed
            && productionBlockedDryRunDefault
            && allForbiddenFlagsRemainClosed
    }

    public var environmentCoverageHeld: Bool {
        Set(scopes) == Set(ProductionCutoverEnvironmentScope.allCases)
            && Set(switchEvidence.flatMap { [$0.fromScope, $0.toScope] }) == Set(ProductionCutoverEnvironmentScope.allCases)
            && switchEvidence.allSatisfy(\.requiresManualApproval)
            && switchEvidence.allSatisfy { $0.allowsAutomaticSwitch == false }
            && switchEvidence.allSatisfy { $0.connectsBroker == false }
            && switchEvidence.allSatisfy { $0.submitsRealOrder == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsProductionRuntime,
            allowsAutomaticEnvironmentSwitch,
            readsSecretValue,
            connectsBroker,
            implementsBrokerAdapter,
            implementsOMS,
            implementsLiveExecutionAdapter,
            sandboxCommandPromotesProductionCommand,
            productionTradingEnabledByDefault,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            exposesLiveCommandSurface,
            exposesTradingButton,
            exposesOrderForm
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-504-production-environment-isolation-gate"),
        issueID: Identifier = Identifier.constant("GH-504"),
        upstreamIssueID: Identifier = Identifier.constant("GH-503"),
        projectName: String = ProductionCutoverCredentialSecretPolicyGate.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        scopes: [ProductionCutoverEnvironmentScope] = Self.requiredScopes,
        gates: [ProductionCutoverEnvironmentGate] = Self.requiredGates,
        forbiddenCapabilities: [ProductionCutoverEnvironmentForbiddenCapability] = Self.requiredForbiddenCapabilities,
        switchEvidence: [ProductionCutoverEnvironmentSwitchEvidence] = Self.requiredSwitchEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        credentialPolicyGateRequired: Bool = true,
        productionNoDefaultTradingRequired: Bool = true,
        sandboxCommandProductionCommandIsolationRequired: Bool = true,
        explicitAuditableEnvironmentSwitchRequired: Bool = true,
        manualApprovalCannotBeBypassed: Bool = true,
        productionBlockedDryRunDefault: Bool = true,
        implementsProductionRuntime: Bool = false,
        allowsAutomaticEnvironmentSwitch: Bool = false,
        readsSecretValue: Bool = false,
        connectsBroker: Bool = false,
        implementsBrokerAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        sandboxCommandPromotesProductionCommand: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        try Self.validateRequired(
            scopes: scopes,
            gates: gates,
            forbiddenCapabilities: forbiddenCapabilities,
            switchEvidence: switchEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            credentialPolicyGateRequired: credentialPolicyGateRequired,
            productionNoDefaultTradingRequired: productionNoDefaultTradingRequired,
            sandboxCommandProductionCommandIsolationRequired: sandboxCommandProductionCommandIsolationRequired,
            explicitAuditableEnvironmentSwitchRequired: explicitAuditableEnvironmentSwitchRequired,
            manualApprovalCannotBeBypassed: manualApprovalCannotBeBypassed,
            productionBlockedDryRunDefault: productionBlockedDryRunDefault
        )
        try Self.validateForbiddenFlags(
            implementsProductionRuntime: implementsProductionRuntime,
            allowsAutomaticEnvironmentSwitch: allowsAutomaticEnvironmentSwitch,
            readsSecretValue: readsSecretValue,
            connectsBroker: connectsBroker,
            implementsBrokerAdapter: implementsBrokerAdapter,
            implementsOMS: implementsOMS,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            sandboxCommandPromotesProductionCommand: sandboxCommandPromotesProductionCommand,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.scopes = scopes
        self.gates = gates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.switchEvidence = switchEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialPolicyGateRequired = credentialPolicyGateRequired
        self.productionNoDefaultTradingRequired = productionNoDefaultTradingRequired
        self.sandboxCommandProductionCommandIsolationRequired = sandboxCommandProductionCommandIsolationRequired
        self.explicitAuditableEnvironmentSwitchRequired = explicitAuditableEnvironmentSwitchRequired
        self.manualApprovalCannotBeBypassed = manualApprovalCannotBeBypassed
        self.productionBlockedDryRunDefault = productionBlockedDryRunDefault
        self.implementsProductionRuntime = implementsProductionRuntime
        self.allowsAutomaticEnvironmentSwitch = allowsAutomaticEnvironmentSwitch
        self.readsSecretValue = readsSecretValue
        self.connectsBroker = connectsBroker
        self.implementsBrokerAdapter = implementsBrokerAdapter
        self.implementsOMS = implementsOMS
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.sandboxCommandPromotesProductionCommand = sandboxCommandPromotesProductionCommand
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> ProductionCutoverEnvironmentIsolationGateContract {
        try ProductionCutoverEnvironmentIsolationGateContract()
    }

    public static let requiredScopes = ProductionCutoverEnvironmentScope.allCases
    public static let requiredGates = ProductionCutoverEnvironmentGate.allCases
    public static let requiredForbiddenCapabilities = ProductionCutoverEnvironmentForbiddenCapability.allCases
    public static let requiredValidationCommands = ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands

    public static let requiredValidationAnchors = [
        "GH-504-PRODUCTION-ENVIRONMENT-ISOLATION-GATE",
        "GH-504-ENVIRONMENT-TAXONOMY",
        "GH-504-PRODUCTION-NO-DEFAULT-TRADING",
        "GH-504-SANDBOX-DRYRUN-PRODUCTION-COMMAND-ISOLATION",
        "GH-504-MANUAL-APPROVAL-SWITCH-EVIDENCE"
    ]

    public static let requiredSwitchEvidence: [ProductionCutoverEnvironmentSwitchEvidence] = {
        do {
            return [
                try ProductionCutoverEnvironmentSwitchEvidence(
                    evidenceID: Identifier.constant("gh-504-local-to-fixture"),
                    fromScope: .local,
                    toScope: .fixture,
                    triggerIdentity: "local deterministic fixture selection",
                    blockedReason: "fixture path cannot read secret or connect broker"
                ),
                try ProductionCutoverEnvironmentSwitchEvidence(
                    evidenceID: Identifier.constant("gh-504-fixture-to-dry-run"),
                    fromScope: .fixture,
                    toScope: .dryRun,
                    triggerIdentity: "dry-run evidence request",
                    blockedReason: "dry-run remains no-trading and broker-disconnected"
                ),
                try ProductionCutoverEnvironmentSwitchEvidence(
                    evidenceID: Identifier.constant("gh-504-dry-run-to-shadow"),
                    fromScope: .dryRun,
                    toScope: .shadow,
                    triggerIdentity: "shadow evidence request",
                    blockedReason: "shadow mode cannot submit, cancel or replace real orders"
                ),
                try ProductionCutoverEnvironmentSwitchEvidence(
                    evidenceID: Identifier.constant("gh-504-shadow-to-production-blocked"),
                    fromScope: .shadow,
                    toScope: .productionBlocked,
                    triggerIdentity: "production blocked evidence request",
                    blockedReason: "production remains blocked until manual cutover approval"
                ),
                try ProductionCutoverEnvironmentSwitchEvidence(
                    evidenceID: Identifier.constant("gh-504-production-blocked-to-future-production"),
                    fromScope: .productionBlocked,
                    toScope: .futureProduction,
                    triggerIdentity: "future production gate placeholder",
                    blockedReason: "future production is not executable in GH-504"
                )
            ]
        } catch {
            preconditionFailure("GH-504 deterministic environment switch evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverEnvironmentIsolationGateContract {
    static func validateRequired(
        scopes: [ProductionCutoverEnvironmentScope],
        gates: [ProductionCutoverEnvironmentGate],
        forbiddenCapabilities: [ProductionCutoverEnvironmentForbiddenCapability],
        switchEvidence: [ProductionCutoverEnvironmentSwitchEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "scopes",
                scopes == requiredScopes,
                requiredScopes.map(\.rawValue).joined(separator: ","),
                scopes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "gates",
                gates == requiredGates,
                requiredGates.map(\.rawValue).joined(separator: ","),
                gates.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "switchEvidence",
                switchEvidence == requiredSwitchEvidence,
                "GH-504 required environment switch evidence",
                switchEvidence.map(\.evidenceID.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        credentialPolicyGateRequired: Bool,
        productionNoDefaultTradingRequired: Bool,
        sandboxCommandProductionCommandIsolationRequired: Bool,
        explicitAuditableEnvironmentSwitchRequired: Bool,
        manualApprovalCannotBeBypassed: Bool,
        productionBlockedDryRunDefault: Bool
    ) throws {
        let requiredTrueFlags = [
            ("credentialPolicyGateRequired", credentialPolicyGateRequired),
            ("productionNoDefaultTradingRequired", productionNoDefaultTradingRequired),
            ("sandboxCommandProductionCommandIsolationRequired", sandboxCommandProductionCommandIsolationRequired),
            ("explicitAuditableEnvironmentSwitchRequired", explicitAuditableEnvironmentSwitchRequired),
            ("manualApprovalCannotBeBypassed", manualApprovalCannotBeBypassed),
            ("productionBlockedDryRunDefault", productionBlockedDryRunDefault)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        implementsProductionRuntime: Bool,
        allowsAutomaticEnvironmentSwitch: Bool,
        readsSecretValue: Bool,
        connectsBroker: Bool,
        implementsBrokerAdapter: Bool,
        implementsOMS: Bool,
        implementsLiveExecutionAdapter: Bool,
        sandboxCommandPromotesProductionCommand: Bool,
        productionTradingEnabledByDefault: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        exposesLiveCommandSurface: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsProductionRuntime", implementsProductionRuntime),
            ("allowsAutomaticEnvironmentSwitch", allowsAutomaticEnvironmentSwitch),
            ("readsSecretValue", readsSecretValue),
            ("connectsBroker", connectsBroker),
            ("implementsBrokerAdapter", implementsBrokerAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("sandboxCommandPromotesProductionCommand", sandboxCommandPromotesProductionCommand),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
