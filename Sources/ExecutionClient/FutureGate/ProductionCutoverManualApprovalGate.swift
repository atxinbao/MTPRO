import DomainModel
import Foundation

/// ProductionCutoverManualApprovalCheckpoint 固定 GH-506 人工确认 gate 的检查点。
///
/// 这些 checkpoint 只用于 cutover readiness evidence。它们不实现审批系统、不暴露 live command UI，
/// 也不把 sandbox command、配置默认值或环境变量升级为 production command。
public enum ProductionCutoverManualApprovalCheckpoint: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialSecretPolicy = "credential / secret policy"
    case environmentIsolation = "environment isolation"
    case brokerVenueCapabilityMatrix = "broker / venue capability matrix"
    case operatorIdentity = "operator identity"
    case operatorConfirmationChecklist = "operator confirmation checklist"
    case productionCommandBlocked = "production command blocked"
    case futureCutoverIssue = "future dedicated cutover issue"
}

/// ProductionCutoverManualApprovalForbiddenCapability 枚举 GH-506 必须拒绝的绕过路径。
public enum ProductionCutoverManualApprovalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case configDefaultApproval = "config default approval"
    case environmentVariableApproval = "environment variable approval"
    case uiApprovalBypass = "UI approval bypass"
    case scriptApprovalBypass = "script approval bypass"
    case sandboxCommandPromotesProductionCommand = "sandbox command promotes production command"
    case productionCommandWithoutApproval = "production command without approval"
    case liveCommandSurface = "live command surface"
    case tradingButton = "trading button"
    case orderForm = "order form"
    case brokerConnection = "broker connection"
    case secretRead = "secret read"
    case productionApprovalSystem = "production approval system"
    case productionOMS = "production OMS"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// ProductionCutoverManualApprovalEvidence 是 GH-506 的 operator confirmation checklist row。
///
/// Row 只能说明 cutover 前必须人工确认的证据和 blocked reason。当前阶段不得把 approval 标记为已授予，
/// 不得通过 config、env、UI、脚本或 sandbox command 生成 production command。
public struct ProductionCutoverManualApprovalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let checkpoint: ProductionCutoverManualApprovalCheckpoint
    public let expectedEvidence: String
    public let blockedReason: String
    public let requiresManualApproval: Bool
    public let approvalGranted: Bool
    public let allowsConfigDefaultApproval: Bool
    public let allowsEnvironmentVariableApproval: Bool
    public let allowsUIApprovalBypass: Bool
    public let allowsScriptApprovalBypass: Bool
    public let sandboxCommandPromotesProductionCommand: Bool

    public init(
        evidenceID: Identifier,
        checkpoint: ProductionCutoverManualApprovalCheckpoint,
        expectedEvidence: String,
        blockedReason: String,
        requiresManualApproval: Bool = true,
        approvalGranted: Bool = false,
        allowsConfigDefaultApproval: Bool = false,
        allowsEnvironmentVariableApproval: Bool = false,
        allowsUIApprovalBypass: Bool = false,
        allowsScriptApprovalBypass: Bool = false,
        sandboxCommandPromotesProductionCommand: Bool = false
    ) throws {
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty manual approval evidence",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty manual approval blocked reason",
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
        for (field, value) in [
            ("approvalGranted", approvalGranted),
            ("allowsConfigDefaultApproval", allowsConfigDefaultApproval),
            ("allowsEnvironmentVariableApproval", allowsEnvironmentVariableApproval),
            ("allowsUIApprovalBypass", allowsUIApprovalBypass),
            ("allowsScriptApprovalBypass", allowsScriptApprovalBypass),
            ("sandboxCommandPromotesProductionCommand", sandboxCommandPromotesProductionCommand)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }

        self.evidenceID = evidenceID
        self.checkpoint = checkpoint
        self.expectedEvidence = expectedEvidence
        self.blockedReason = blockedReason
        self.requiresManualApproval = requiresManualApproval
        self.approvalGranted = approvalGranted
        self.allowsConfigDefaultApproval = allowsConfigDefaultApproval
        self.allowsEnvironmentVariableApproval = allowsEnvironmentVariableApproval
        self.allowsUIApprovalBypass = allowsUIApprovalBypass
        self.allowsScriptApprovalBypass = allowsScriptApprovalBypass
        self.sandboxCommandPromotesProductionCommand = sandboxCommandPromotesProductionCommand
    }
}

/// ProductionCutoverManualApprovalGate 是 GH-506 的 manual approval / operator confirmation gate。
///
/// Gate 只定义 future production cutover 前必须人工确认的证据链。它不实现生产审批系统，不读取真实
/// secret，不连接 broker，不开放 trading button / order form，也不提交、撤销或替换真实订单。
public struct ProductionCutoverManualApprovalGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let projectName: String
    public let canonicalQueueRange: String
    public let checkpoints: [ProductionCutoverManualApprovalCheckpoint]
    public let forbiddenCapabilities: [ProductionCutoverManualApprovalForbiddenCapability]
    public let checklistEvidence: [ProductionCutoverManualApprovalEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialPolicyGateRequired: Bool
    public let environmentIsolationGateRequired: Bool
    public let brokerVenueCapabilityMatrixRequired: Bool
    public let manualApprovalRequired: Bool
    public let operatorConfirmationRequired: Bool
    public let futureDedicatedCutoverIssueRequired: Bool
    public let productionCommandBlockedByDefault: Bool
    public let approvalGranted: Bool
    public let allowsConfigDefaultApproval: Bool
    public let allowsEnvironmentVariableApproval: Bool
    public let allowsUIApprovalBypass: Bool
    public let allowsScriptApprovalBypass: Bool
    public let sandboxCommandPromotesProductionCommand: Bool
    public let exposesLiveCommandSurface: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool
    public let readsSecretValue: Bool
    public let connectsBroker: Bool
    public let implementsProductionApprovalSystem: Bool
    public let implementsProductionOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-506"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-503", "GH-504", "GH-505"]
            && projectName == ProductionCutoverCredentialSecretPolicyGate.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && checkpoints == ProductionCutoverManualApprovalCheckpoint.allCases
            && forbiddenCapabilities == ProductionCutoverManualApprovalForbiddenCapability.allCases
            && checklistEvidence == Self.requiredChecklistEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands
            && credentialPolicyGateRequired
            && environmentIsolationGateRequired
            && brokerVenueCapabilityMatrixRequired
            && manualApprovalRequired
            && operatorConfirmationRequired
            && futureDedicatedCutoverIssueRequired
            && productionCommandBlockedByDefault
            && allForbiddenFlagsRemainClosed
    }

    public var checklistCoverageHeld: Bool {
        Set(checklistEvidence.map(\.checkpoint)) == Set(ProductionCutoverManualApprovalCheckpoint.allCases)
            && checklistEvidence.allSatisfy(\.requiresManualApproval)
            && checklistEvidence.allSatisfy { $0.approvalGranted == false }
            && checklistEvidence.allSatisfy { $0.sandboxCommandPromotesProductionCommand == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            approvalGranted,
            allowsConfigDefaultApproval,
            allowsEnvironmentVariableApproval,
            allowsUIApprovalBypass,
            allowsScriptApprovalBypass,
            sandboxCommandPromotesProductionCommand,
            exposesLiveCommandSurface,
            exposesTradingButton,
            exposesOrderForm,
            readsSecretValue,
            connectsBroker,
            implementsProductionApprovalSystem,
            implementsProductionOMS,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder
        ].allSatisfy { $0 == false }
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-506-production-cutover-manual-approval-gate"),
        issueID: Identifier = Identifier.constant("GH-506"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-503"),
            Identifier.constant("GH-504"),
            Identifier.constant("GH-505")
        ],
        projectName: String = ProductionCutoverCredentialSecretPolicyGate.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        checkpoints: [ProductionCutoverManualApprovalCheckpoint] = ProductionCutoverManualApprovalCheckpoint.allCases,
        forbiddenCapabilities: [ProductionCutoverManualApprovalForbiddenCapability] =
            ProductionCutoverManualApprovalForbiddenCapability.allCases,
        checklistEvidence: [ProductionCutoverManualApprovalEvidence] = Self.requiredChecklistEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
        credentialPolicyGateRequired: Bool = true,
        environmentIsolationGateRequired: Bool = true,
        brokerVenueCapabilityMatrixRequired: Bool = true,
        manualApprovalRequired: Bool = true,
        operatorConfirmationRequired: Bool = true,
        futureDedicatedCutoverIssueRequired: Bool = true,
        productionCommandBlockedByDefault: Bool = true,
        approvalGranted: Bool = false,
        allowsConfigDefaultApproval: Bool = false,
        allowsEnvironmentVariableApproval: Bool = false,
        allowsUIApprovalBypass: Bool = false,
        allowsScriptApprovalBypass: Bool = false,
        sandboxCommandPromotesProductionCommand: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false,
        readsSecretValue: Bool = false,
        connectsBroker: Bool = false,
        implementsProductionApprovalSystem: Bool = false,
        implementsProductionOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            checkpoints: checkpoints,
            forbiddenCapabilities: forbiddenCapabilities,
            checklistEvidence: checklistEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            credentialPolicyGateRequired: credentialPolicyGateRequired,
            environmentIsolationGateRequired: environmentIsolationGateRequired,
            brokerVenueCapabilityMatrixRequired: brokerVenueCapabilityMatrixRequired,
            manualApprovalRequired: manualApprovalRequired,
            operatorConfirmationRequired: operatorConfirmationRequired,
            futureDedicatedCutoverIssueRequired: futureDedicatedCutoverIssueRequired,
            productionCommandBlockedByDefault: productionCommandBlockedByDefault
        )
        try Self.validateForbiddenFlags(
            approvalGranted: approvalGranted,
            allowsConfigDefaultApproval: allowsConfigDefaultApproval,
            allowsEnvironmentVariableApproval: allowsEnvironmentVariableApproval,
            allowsUIApprovalBypass: allowsUIApprovalBypass,
            allowsScriptApprovalBypass: allowsScriptApprovalBypass,
            sandboxCommandPromotesProductionCommand: sandboxCommandPromotesProductionCommand,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm,
            readsSecretValue: readsSecretValue,
            connectsBroker: connectsBroker,
            implementsProductionApprovalSystem: implementsProductionApprovalSystem,
            implementsProductionOMS: implementsProductionOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.checkpoints = checkpoints
        self.forbiddenCapabilities = forbiddenCapabilities
        self.checklistEvidence = checklistEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialPolicyGateRequired = credentialPolicyGateRequired
        self.environmentIsolationGateRequired = environmentIsolationGateRequired
        self.brokerVenueCapabilityMatrixRequired = brokerVenueCapabilityMatrixRequired
        self.manualApprovalRequired = manualApprovalRequired
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.futureDedicatedCutoverIssueRequired = futureDedicatedCutoverIssueRequired
        self.productionCommandBlockedByDefault = productionCommandBlockedByDefault
        self.approvalGranted = approvalGranted
        self.allowsConfigDefaultApproval = allowsConfigDefaultApproval
        self.allowsEnvironmentVariableApproval = allowsEnvironmentVariableApproval
        self.allowsUIApprovalBypass = allowsUIApprovalBypass
        self.allowsScriptApprovalBypass = allowsScriptApprovalBypass
        self.sandboxCommandPromotesProductionCommand = sandboxCommandPromotesProductionCommand
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
        self.readsSecretValue = readsSecretValue
        self.connectsBroker = connectsBroker
        self.implementsProductionApprovalSystem = implementsProductionApprovalSystem
        self.implementsProductionOMS = implementsProductionOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public static func deterministicFixture() throws -> ProductionCutoverManualApprovalGate {
        try ProductionCutoverManualApprovalGate()
    }

    public static let requiredValidationAnchors = [
        "GH-506-MANUAL-APPROVAL-OPERATOR-CONFIRMATION-GATE",
        "GH-506-OPERATOR-CONFIRMATION-CHECKLIST",
        "GH-506-BINDS-GH503-GH504-GH505",
        "GH-506-PRODUCTION-COMMAND-BLOCKED-UNTIL-FUTURE-CUTOVER",
        "GH-506-NO-APPROVAL-BYPASS"
    ]

    public static let requiredChecklistEvidence: [ProductionCutoverManualApprovalEvidence] = {
        do {
            return [
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-credential-secret-policy-confirmation"),
                    checkpoint: .credentialSecretPolicy,
                    expectedEvidence: "operator confirms GH-503 no-default-secret-read evidence",
                    blockedReason: "production cutover blocked until credential policy is manually acknowledged"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-environment-isolation-confirmation"),
                    checkpoint: .environmentIsolation,
                    expectedEvidence: "operator confirms GH-504 no-default-production-trading evidence",
                    blockedReason: "production cutover blocked until environment isolation is manually acknowledged"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-broker-venue-matrix-confirmation"),
                    checkpoint: .brokerVenueCapabilityMatrix,
                    expectedEvidence: "operator confirms GH-505 broker venue matrix evidence",
                    blockedReason: "production cutover blocked until broker venue capability matrix is manually acknowledged"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-operator-identity-confirmation"),
                    checkpoint: .operatorIdentity,
                    expectedEvidence: "operator identity is explicit and auditable",
                    blockedReason: "production cutover blocked until operator identity evidence exists"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-checklist-confirmation"),
                    checkpoint: .operatorConfirmationChecklist,
                    expectedEvidence: "operator checklist remains required and not auto-confirmed",
                    blockedReason: "production cutover blocked until checklist is manually confirmed"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-production-command-blocked-confirmation"),
                    checkpoint: .productionCommandBlocked,
                    expectedEvidence: "production command remains blocked by default",
                    blockedReason: "production command blocked until a future dedicated cutover issue authorizes it"
                ),
                try ProductionCutoverManualApprovalEvidence(
                    evidenceID: Identifier.constant("gh-506-future-cutover-issue-confirmation"),
                    checkpoint: .futureCutoverIssue,
                    expectedEvidence: "future dedicated cutover issue is required before production enablement",
                    blockedReason: "production cutover cannot be approved inside GH-506"
                )
            ]
        } catch {
            preconditionFailure("GH-506 deterministic manual approval evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverManualApprovalGate {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        checkpoints: [ProductionCutoverManualApprovalCheckpoint],
        forbiddenCapabilities: [ProductionCutoverManualApprovalForbiddenCapability],
        checklistEvidence: [ProductionCutoverManualApprovalEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-503", "GH-504", "GH-505"],
                "GH-503,GH-504,GH-505",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "checkpoints",
                checkpoints == ProductionCutoverManualApprovalCheckpoint.allCases,
                ProductionCutoverManualApprovalCheckpoint.allCases.map(\.rawValue).joined(separator: ","),
                checkpoints.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ProductionCutoverManualApprovalForbiddenCapability.allCases,
                ProductionCutoverManualApprovalForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "checklistEvidence",
                checklistEvidence == requiredChecklistEvidence,
                "GH-506 required manual approval checklist evidence",
                checklistEvidence.map(\.checkpoint.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
                ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredFlags(
        credentialPolicyGateRequired: Bool,
        environmentIsolationGateRequired: Bool,
        brokerVenueCapabilityMatrixRequired: Bool,
        manualApprovalRequired: Bool,
        operatorConfirmationRequired: Bool,
        futureDedicatedCutoverIssueRequired: Bool,
        productionCommandBlockedByDefault: Bool
    ) throws {
        for (field, value) in [
            ("credentialPolicyGateRequired", credentialPolicyGateRequired),
            ("environmentIsolationGateRequired", environmentIsolationGateRequired),
            ("brokerVenueCapabilityMatrixRequired", brokerVenueCapabilityMatrixRequired),
            ("manualApprovalRequired", manualApprovalRequired),
            ("operatorConfirmationRequired", operatorConfirmationRequired),
            ("futureDedicatedCutoverIssueRequired", futureDedicatedCutoverIssueRequired),
            ("productionCommandBlockedByDefault", productionCommandBlockedByDefault)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        approvalGranted: Bool,
        allowsConfigDefaultApproval: Bool,
        allowsEnvironmentVariableApproval: Bool,
        allowsUIApprovalBypass: Bool,
        allowsScriptApprovalBypass: Bool,
        sandboxCommandPromotesProductionCommand: Bool,
        exposesLiveCommandSurface: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool,
        readsSecretValue: Bool,
        connectsBroker: Bool,
        implementsProductionApprovalSystem: Bool,
        implementsProductionOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("approvalGranted", approvalGranted),
            ("allowsConfigDefaultApproval", allowsConfigDefaultApproval),
            ("allowsEnvironmentVariableApproval", allowsEnvironmentVariableApproval),
            ("allowsUIApprovalBypass", allowsUIApprovalBypass),
            ("allowsScriptApprovalBypass", allowsScriptApprovalBypass),
            ("sandboxCommandPromotesProductionCommand", sandboxCommandPromotesProductionCommand),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm),
            ("readsSecretValue", readsSecretValue),
            ("connectsBroker", connectsBroker),
            ("implementsProductionApprovalSystem", implementsProductionApprovalSystem),
            ("implementsProductionOMS", implementsProductionOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
