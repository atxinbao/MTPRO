import DomainModel
import Foundation

/// ReleaseV0220SpotLiveCanaryTransportMode 固定 v0.22.0 Binance Spot
/// live canary transport completion queue 的能力边界。
///
/// GH-1309 只定义合同。后续 issue 才能逐步推进 explicit approval、one-shot run lock、
/// credential read、signed preflight、submit、status / cancel、OMS、reconciliation 和 read-only
/// surfaces。本 issue 不读取 secret、不连接 endpoint、不提交订单、不创建 release。
public enum ReleaseV0220SpotLiveCanaryTransportMode:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case contractOnly = "contract-only"
    case operatorApprovalSession = "operator-approval-session"
    case oneShotRunLock = "one-shot-run-lock"
    case credentialSecretMaterialRead = "credential-secret-material-read"
    case signedAccountRuntimePreflight = "signed-account-runtime-preflight"
    case liveSpotOrderSubmitTransport = "live-spot-order-submit-transport"
    case liveSpotOrderStatusQuery = "live-spot-order-status-query"
    case liveSpotOrderCancelTransport = "live-spot-order-cancel-transport"
    case omsAckStatusCancelEvidence = "oms-ack-status-cancel-evidence"
    case reconciliationEvidence = "reconciliation-evidence"
    case failureRollbackKillNoTradeDrill = "failure-rollback-kill-no-trade-drill"
    case dashboardCLIReadOnlyCanarySurface = "dashboard-cli-read-only-canary-surface"
    case releaseValidationSuite = "release-validation-suite"
    case stageAuditReleaseDocs = "stage-audit-release-docs"
}

/// ReleaseV0220SpotLiveCanaryTransportPreflightRequirement 列出 v0.22.0
/// queue 启动和后续每个真实 transport issue 必须遵守的前置 gate。
public enum ReleaseV0220SpotLiveCanaryTransportPreflightRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case previousV0211PatchClosed = "previous v0.21.1 patch queue closed"
    case blockingIssue1308Done = "blocking issue GH-1308 done"
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case currentIssueContractRead = "current issue contract is read before work"
    case mainFastForwardClean = "main fast-forwarded and worktree clean"
    case binanceSpotOnly = "Binance Spot only"
    case operatorApprovalRequired = "explicit operator approval required"
    case oneShotRunLockRequired = "one-shot run lock required"
    case credentialRedactionAuditRequired = "credential redaction audit required"
    case signedPreflightRequiredBeforeOrder = "signed preflight required before order"
    case smallNotionalAllowlistRequired = "small-notional symbol allowlist required"
    case riskKillNoTradeRequired = "RiskEngine / kill switch / no-trade gates required"
    case omsReconciliationRequired = "OMS event log and reconciliation required"
    case noProductionCutover = "no production cutover authorization"
    case verifyV0220ContractScript = "verify-v0.22.0-live-canary-transport-contract command exists"
}

/// ReleaseV0220SpotLiveCanaryTransportForbiddenCapability 枚举 v0.22.0
/// live canary transport completion 合同仍拒绝的能力。
public enum ReleaseV0220SpotLiveCanaryTransportForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case productionCutoverAuthorization = "production cutover authorization"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case secretReadWithoutApproval = "secret read without approval"
    case secretValueLogging = "secret value logging"
    case broadProductionBrokerConnection = "broad production broker connection"
    case futuresExecution = "Futures execution"
    case okxActiveImplementation = "OKX active implementation"
    case unboundedNotionalOrExposure = "unbounded notional or exposure"
    case operatorApprovalBypass = "operator approval bypass"
    case oneShotRunLockBypass = "one-shot run lock bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case killSwitchBypass = "kill switch bypass"
    case noTradeBypass = "no-trade bypass"
    case omsBypass = "OMS bypass"
    case reconciliationBypass = "reconciliation bypass"
    case dashboardDefaultTradingButton = "Dashboard default trading button"
    case dashboardOrderFormByDefault = "Dashboard order form by default"
    case repeatedAutomationLoop = "repeated automation loop"
    case bulkOrderSubmission = "bulk order submission"
    case tagOrReleasePublication = "tag or GitHub Release publication"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV0220SpotLiveCanaryTransportCompletionContract 是 GH-1309 的 v0.22.0
/// 顶层合同。
///
/// 该合同把 v0.22.0 限定为 Binance Spot 一次性 live canary transport completion：
/// approval -> credential read -> signed preflight -> submit -> status / cancel -> OMS ->
/// reconciliation -> read-only surfaces。GH-1309 只定义边界和验证锚点，不实现任何真实
/// transport，也不授权 production cutover。
public struct ReleaseV0220SpotLiveCanaryTransportCompletionContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedModes: [ReleaseV0220SpotLiveCanaryTransportMode]
    public let preflightRequirements: [ReleaseV0220SpotLiveCanaryTransportPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryTransportForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let v0211CloseoutRequired: Bool
    public let liveCanaryTransportScopeDefined: Bool
    public let explicitOperatorApprovalRequired: Bool
    public let oneShotRunLockRequired: Bool
    public let credentialSecretReadRequiresApproval: Bool
    public let signedAccountPreflightRequired: Bool
    public let smallNotionalAllowlistRequired: Bool
    public let riskKillSwitchNoTradeGateRequired: Bool
    public let omsEventLogRequired: Bool
    public let reconciliationRequired: Bool
    public let canaryEvidenceMustBeAuditable: Bool
    public let credentialSecretReadImplementedByThisIssue: Bool
    public let signedAccountEndpointRuntimeImplementedByThisIssue: Bool
    public let liveOrderSubmitImplementedByThisIssue: Bool
    public let liveOrderStatusCancelImplementedByThisIssue: Bool
    public let dashboardCommandSurfaceImplementedByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let automaticProductionSecretReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let futuresInScope: Bool
    public let okxInScope: Bool
    public let createsTagOrRelease: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-1309"
            && blockedByIssueIDs.map(\.rawValue) == Self.requiredBlockedByIssueIDs.map(\.rawValue)
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-1309..GH-1320"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.22.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedModes == Self.requiredAllowedModes
            && preflightRequirements == Self.requiredPreflightRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && liveCanaryTransportBoundaryHeld
            && implementationDeferredByThisIssue
            && productionDefaultsClosed
            && createsTagOrRelease == false
            && startsNextMilestone == false
    }

    public var liveCanaryTransportBoundaryHeld: Bool {
        v0211CloseoutRequired
            && liveCanaryTransportScopeDefined
            && explicitOperatorApprovalRequired
            && oneShotRunLockRequired
            && credentialSecretReadRequiresApproval
            && signedAccountPreflightRequired
            && smallNotionalAllowlistRequired
            && riskKillSwitchNoTradeGateRequired
            && omsEventLogRequired
            && reconciliationRequired
            && canaryEvidenceMustBeAuditable
    }

    public var implementationDeferredByThisIssue: Bool {
        credentialSecretReadImplementedByThisIssue == false
            && signedAccountEndpointRuntimeImplementedByThisIssue == false
            && liveOrderSubmitImplementedByThisIssue == false
            && liveOrderStatusCancelImplementedByThisIssue == false
            && dashboardCommandSurfaceImplementedByThisIssue == false
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && automaticProductionSecretReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabledByDefault == false
            && productionCutoverAuthorized == false
            && futuresInScope == false
            && okxInScope == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-1309-release-v0.22.0-binance-spot-live-canary-transport-completion-contract"),
        issueID: Identifier = Identifier.constant("GH-1309"),
        blockedByIssueIDs: [Identifier] = Self.requiredBlockedByIssueIDs,
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-1309..GH-1320",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.22.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedModes: [ReleaseV0220SpotLiveCanaryTransportMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV0220SpotLiveCanaryTransportPreflightRequirement] =
            Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryTransportForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        v0211CloseoutRequired: Bool = true,
        liveCanaryTransportScopeDefined: Bool = true,
        explicitOperatorApprovalRequired: Bool = true,
        oneShotRunLockRequired: Bool = true,
        credentialSecretReadRequiresApproval: Bool = true,
        signedAccountPreflightRequired: Bool = true,
        smallNotionalAllowlistRequired: Bool = true,
        riskKillSwitchNoTradeGateRequired: Bool = true,
        omsEventLogRequired: Bool = true,
        reconciliationRequired: Bool = true,
        canaryEvidenceMustBeAuditable: Bool = true,
        credentialSecretReadImplementedByThisIssue: Bool = false,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool = false,
        liveOrderSubmitImplementedByThisIssue: Bool = false,
        liveOrderStatusCancelImplementedByThisIssue: Bool = false,
        dashboardCommandSurfaceImplementedByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        automaticProductionSecretReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        futuresInScope: Bool = false,
        okxInScope: Bool = false,
        createsTagOrRelease: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            blockedByIssueIDs: blockedByIssueIDs,
            downstreamIssueIDs: downstreamIssueIDs,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            allowedVenue: allowedVenue,
            allowedProductTypes: allowedProductTypes,
            allowedModes: allowedModes,
            preflightRequirements: preflightRequirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            v0211CloseoutRequired: v0211CloseoutRequired,
            liveCanaryTransportScopeDefined: liveCanaryTransportScopeDefined,
            explicitOperatorApprovalRequired: explicitOperatorApprovalRequired,
            oneShotRunLockRequired: oneShotRunLockRequired,
            credentialSecretReadRequiresApproval: credentialSecretReadRequiresApproval,
            signedAccountPreflightRequired: signedAccountPreflightRequired,
            smallNotionalAllowlistRequired: smallNotionalAllowlistRequired,
            riskKillSwitchNoTradeGateRequired: riskKillSwitchNoTradeGateRequired,
            omsEventLogRequired: omsEventLogRequired,
            reconciliationRequired: reconciliationRequired,
            canaryEvidenceMustBeAuditable: canaryEvidenceMustBeAuditable
        )
        try Self.validateForbiddenFlags(
            credentialSecretReadImplementedByThisIssue: credentialSecretReadImplementedByThisIssue,
            signedAccountEndpointRuntimeImplementedByThisIssue: signedAccountEndpointRuntimeImplementedByThisIssue,
            liveOrderSubmitImplementedByThisIssue: liveOrderSubmitImplementedByThisIssue,
            liveOrderStatusCancelImplementedByThisIssue: liveOrderStatusCancelImplementedByThisIssue,
            dashboardCommandSurfaceImplementedByThisIssue: dashboardCommandSurfaceImplementedByThisIssue,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            automaticProductionSecretReadEnabled: automaticProductionSecretReadEnabled,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionBrokerConnectionEnabledByDefault: productionBrokerConnectionEnabledByDefault,
            productionCutoverAuthorized: productionCutoverAuthorized,
            futuresInScope: futuresInScope,
            okxInScope: okxInScope,
            createsTagOrRelease: createsTagOrRelease,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.allowedModes = allowedModes
        self.preflightRequirements = preflightRequirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.v0211CloseoutRequired = v0211CloseoutRequired
        self.liveCanaryTransportScopeDefined = liveCanaryTransportScopeDefined
        self.explicitOperatorApprovalRequired = explicitOperatorApprovalRequired
        self.oneShotRunLockRequired = oneShotRunLockRequired
        self.credentialSecretReadRequiresApproval = credentialSecretReadRequiresApproval
        self.signedAccountPreflightRequired = signedAccountPreflightRequired
        self.smallNotionalAllowlistRequired = smallNotionalAllowlistRequired
        self.riskKillSwitchNoTradeGateRequired = riskKillSwitchNoTradeGateRequired
        self.omsEventLogRequired = omsEventLogRequired
        self.reconciliationRequired = reconciliationRequired
        self.canaryEvidenceMustBeAuditable = canaryEvidenceMustBeAuditable
        self.credentialSecretReadImplementedByThisIssue = credentialSecretReadImplementedByThisIssue
        self.signedAccountEndpointRuntimeImplementedByThisIssue = signedAccountEndpointRuntimeImplementedByThisIssue
        self.liveOrderSubmitImplementedByThisIssue = liveOrderSubmitImplementedByThisIssue
        self.liveOrderStatusCancelImplementedByThisIssue = liveOrderStatusCancelImplementedByThisIssue
        self.dashboardCommandSurfaceImplementedByThisIssue = dashboardCommandSurfaceImplementedByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.automaticProductionSecretReadEnabled = automaticProductionSecretReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabledByDefault = productionBrokerConnectionEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.futuresInScope = futuresInScope
        self.okxInScope = okxInScope
        self.createsTagOrRelease = createsTagOrRelease
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV0220SpotLiveCanaryTransportCompletionContract {
        try ReleaseV0220SpotLiveCanaryTransportCompletionContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.22.0 Binance Spot Live Canary Transport Completion"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot"]
    public static let requiredAllowedModes = ReleaseV0220SpotLiveCanaryTransportMode.allCases
    public static let requiredPreflightRequirements =
        ReleaseV0220SpotLiveCanaryTransportPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities =
        ReleaseV0220SpotLiveCanaryTransportForbiddenCapability.allCases
    public static let requiredBlockedByIssueIDs = [Identifier.constant("GH-1308")]
    public static let requiredDownstreamIssueIDs = (1310...1320).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "GH-1309-VERIFY-V0220-LIVE-CANARY-TRANSPORT-CONTRACT",
        "TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT",
        "V0220-001-V0211-PREFLIGHT-GATE",
        "V0220-001-BINANCE-SPOT-LIVE-CANARY-TRANSPORT",
        "V0220-001-OPERATOR-APPROVAL-REQUIRED",
        "V0220-001-ONE-SHOT-RUN-LOCK",
        "V0220-001-RISK-KILL-NO-TRADE-OMS-RECONCILIATION",
        "V0220-001-QUEUE-ORDER",
        "V0220-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1309ReleaseV0220SpotLiveCanaryTransportCompletionContract",
        "bash checks/verify-v0.22.0-live-canary-transport-contract.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0220SpotLiveCanaryTransportCompletionContract {
    static func validateRequired(
        blockedByIssueIDs: [Identifier],
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedModes: [ReleaseV0220SpotLiveCanaryTransportMode],
        preflightRequirements: [ReleaseV0220SpotLiveCanaryTransportPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryTransportForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "blockedByIssueIDs",
                blockedByIssueIDs.map(\.rawValue) == requiredBlockedByIssueIDs.map(\.rawValue),
                requiredBlockedByIssueIDs.map(\.rawValue).joined(separator: ","),
                blockedByIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "downstreamIssueIDs",
                downstreamIssueIDs.map(\.rawValue) == requiredDownstreamIssueIDs.map(\.rawValue),
                requiredDownstreamIssueIDs.map(\.rawValue).joined(separator: ","),
                downstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            ("canonicalQueueRange", canonicalQueueRange == "GH-1309..GH-1320", "GH-1309..GH-1320", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.22.0", "v0.22.0", releaseVersion),
            ("allowedVenue", allowedVenue == requiredAllowedVenue, requiredAllowedVenue, allowedVenue),
            (
                "allowedProductTypes",
                allowedProductTypes == requiredAllowedProductTypes,
                requiredAllowedProductTypes.joined(separator: ","),
                allowedProductTypes.joined(separator: ",")
            ),
            (
                "allowedModes",
                allowedModes == requiredAllowedModes,
                requiredAllowedModes.map(\.rawValue).joined(separator: ","),
                allowedModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "preflightRequirements",
                preflightRequirements == requiredPreflightRequirements,
                requiredPreflightRequirements.map(\.rawValue).joined(separator: ","),
                preflightRequirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
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
        v0211CloseoutRequired: Bool,
        liveCanaryTransportScopeDefined: Bool,
        explicitOperatorApprovalRequired: Bool,
        oneShotRunLockRequired: Bool,
        credentialSecretReadRequiresApproval: Bool,
        signedAccountPreflightRequired: Bool,
        smallNotionalAllowlistRequired: Bool,
        riskKillSwitchNoTradeGateRequired: Bool,
        omsEventLogRequired: Bool,
        reconciliationRequired: Bool,
        canaryEvidenceMustBeAuditable: Bool
    ) throws {
        for (field, value) in [
            ("v0211CloseoutRequired", v0211CloseoutRequired),
            ("liveCanaryTransportScopeDefined", liveCanaryTransportScopeDefined),
            ("explicitOperatorApprovalRequired", explicitOperatorApprovalRequired),
            ("oneShotRunLockRequired", oneShotRunLockRequired),
            ("credentialSecretReadRequiresApproval", credentialSecretReadRequiresApproval),
            ("signedAccountPreflightRequired", signedAccountPreflightRequired),
            ("smallNotionalAllowlistRequired", smallNotionalAllowlistRequired),
            ("riskKillSwitchNoTradeGateRequired", riskKillSwitchNoTradeGateRequired),
            ("omsEventLogRequired", omsEventLogRequired),
            ("reconciliationRequired", reconciliationRequired),
            ("canaryEvidenceMustBeAuditable", canaryEvidenceMustBeAuditable)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        credentialSecretReadImplementedByThisIssue: Bool,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool,
        liveOrderSubmitImplementedByThisIssue: Bool,
        liveOrderStatusCancelImplementedByThisIssue: Bool,
        dashboardCommandSurfaceImplementedByThisIssue: Bool,
        productionTradingEnabledByDefault: Bool,
        automaticProductionSecretReadEnabled: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionBrokerConnectionEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        futuresInScope: Bool,
        okxInScope: Bool,
        createsTagOrRelease: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("credentialSecretReadImplementedByThisIssue", credentialSecretReadImplementedByThisIssue),
            ("signedAccountEndpointRuntimeImplementedByThisIssue", signedAccountEndpointRuntimeImplementedByThisIssue),
            ("liveOrderSubmitImplementedByThisIssue", liveOrderSubmitImplementedByThisIssue),
            ("liveOrderStatusCancelImplementedByThisIssue", liveOrderStatusCancelImplementedByThisIssue),
            ("dashboardCommandSurfaceImplementedByThisIssue", dashboardCommandSurfaceImplementedByThisIssue),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("automaticProductionSecretReadEnabled", automaticProductionSecretReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionBrokerConnectionEnabledByDefault", productionBrokerConnectionEnabledByDefault),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("futuresInScope", futuresInScope),
            ("okxInScope", okxInScope),
            ("createsTagOrRelease", createsTagOrRelease),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
