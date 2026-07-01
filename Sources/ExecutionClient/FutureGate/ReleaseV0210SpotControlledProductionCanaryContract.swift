import DomainModel
import Foundation

/// ReleaseV0210SpotControlledCanaryMode 固定 v0.21.0 Binance Spot controlled
/// production canary 后续 issue 允许逐步证明的能力面。
///
/// GH-1273 只定义合同。后续 issue 才能在 Human approval、credential audit、read-only
/// preflight、risk / kill switch / no-trade、hard limits 和 reconciliation gates 下推进
/// 小额度 Spot canary；本 issue 不读取 secret、不连接 endpoint、不实现 submit / cancel。
public enum ReleaseV0210SpotControlledCanaryMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractOnly = "contract-only"
    case failClosedEnvironmentProfile = "fail-closed-environment-profile"
    case explicitCredentialSecretReadApproval = "explicit-credential-secret-read-approval"
    case signedAccountReadOnlyPreflight = "signed-account-read-only-preflight"
    case publicMarketReachabilityPreflight = "public-market-reachability-preflight"
    case hardLimitPreTradeGate = "hard-limit-pre-trade-gate"
    case riskKillNoTradeGate = "risk-kill-no-trade-gate"
    case guardedSpotCanarySubmit = "guarded-spot-canary-submit"
    case guardedSpotCanaryCancel = "guarded-spot-canary-cancel"
    case omsEventLogReconciliationEvidence = "oms-event-log-reconciliation-evidence"
    case dashboardCLIReadOnlyCanaryStatusSurface = "dashboard-cli-read-only-canary-status-surface"
    case incidentRollbackOperatorRunbook = "incident-rollback-operator-runbook"
    case releaseValidationSuite = "release-validation-suite"
    case stageAuditReleaseDocs = "stage-audit-release-docs"
}

/// ReleaseV0210SpotControlledCanaryPreflightRequirement 列出 v0.21.0 GitHub
/// fallback queue 启动前必须满足的 gate。
public enum ReleaseV0210SpotControlledCanaryPreflightRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case previousV0201PatchClosed = "previous v0.20.1 patch queue closed"
    case blockingIssue1272Done = "blocking issue GH-1272 done"
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case currentIssueContractRead = "current issue contract is read before work"
    case mainFastForwardClean = "main fast-forwarded and worktree clean"
    case binanceSpotOnly = "Binance Spot only"
    case humanApprovalRequired = "explicit Human operator approval required"
    case productionTradingDefaultOff = "production trading disabled by default"
    case symbolAllowlistRequired = "symbol allowlist required"
    case sizeCapsRequired = "notional and exposure size caps required"
    case riskKillNoTradeGateRequired = "RiskEngine / kill switch / no-trade gates required"
    case noProductionCutover = "no production cutover authorization"
    case verifyV0210ContractScript = "verify-v0.21.0-controlled-canary-contract command exists"
}

/// ReleaseV0210SpotControlledCanaryForbiddenCapability 枚举 v0.21.0 顶层合同仍然拒绝的能力。
///
/// v0.21.0 可以在后续 issue 中授权受控 Spot canary，但所有真实生产能力都必须保持
/// default-off、显式审批、可回滚，并且绝不等同于 production cutover。
public enum ReleaseV0210SpotControlledCanaryForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case productionCutoverAuthorization = "production cutover authorization"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case automaticSecretRead = "automatic secret read"
    case secretValueLogging = "secret value logging"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionBrokerConnectionOutsideCanaryGate = "production broker connection outside canary gate"
    case futuresExecution = "Futures execution"
    case okxActiveImplementation = "OKX active implementation"
    case unboundedNotionalOrExposure = "unbounded notional or exposure"
    case riskEngineBypass = "RiskEngine bypass"
    case killSwitchBypass = "kill switch bypass"
    case noTradeBypass = "no-trade bypass"
    case dashboardDefaultTradingButton = "Dashboard default trading button"
    case dashboardOrderFormByDefault = "Dashboard order form by default"
    case orderCommandWithoutCanaryGate = "order command without canary gate"
    case tagOrReleasePublication = "tag or GitHub Release publication"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV0210SpotControlledProductionCanaryContract 是 GH-1273 的 v0.21.0 顶层合同。
///
/// 合同只定义 Binance Spot controlled production canary 的 release boundary、queue order、
/// validation anchors、human approval、symbol allowlist、size caps、risk / kill switch /
/// no-trade gate 和 production 禁区。GH-1273 本身不读取 secret、不连接 endpoint、不产生
/// submit / cancel；后续 issue 必须逐项证明 gate 后才可触达受控 canary。
public struct ReleaseV0210SpotControlledProductionCanaryContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedModes: [ReleaseV0210SpotControlledCanaryMode]
    public let preflightRequirements: [ReleaseV0210SpotControlledCanaryPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0210SpotControlledCanaryForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let v0201CloseoutRequired: Bool
    public let controlledSpotCanaryScopeDefined: Bool
    public let explicitHumanApprovalRequired: Bool
    public let symbolAllowlistRequired: Bool
    public let notionalSizeCapsRequired: Bool
    public let riskKillSwitchNoTradeGateRequired: Bool
    public let canaryEvidenceMustBeAuditable: Bool
    public let credentialSecretReadImplementedByThisIssue: Bool
    public let productionEndpointConnectionImplementedByThisIssue: Bool
    public let signedAccountEndpointRuntimeImplementedByThisIssue: Bool
    public let canarySubmitCancelImplementedByThisIssue: Bool
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
        issueID.rawValue == "GH-1273"
            && blockedByIssueIDs.map(\.rawValue) == Self.requiredBlockedByIssueIDs.map(\.rawValue)
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-1273..GH-1286"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.21.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedModes == Self.requiredAllowedModes
            && preflightRequirements == Self.requiredPreflightRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && controlledCanaryBoundaryHeld
            && implementationDeferredByThisIssue
            && productionDefaultsClosed
            && createsTagOrRelease == false
            && startsNextMilestone == false
    }

    public var controlledCanaryBoundaryHeld: Bool {
        v0201CloseoutRequired
            && controlledSpotCanaryScopeDefined
            && explicitHumanApprovalRequired
            && symbolAllowlistRequired
            && notionalSizeCapsRequired
            && riskKillSwitchNoTradeGateRequired
            && canaryEvidenceMustBeAuditable
    }

    public var implementationDeferredByThisIssue: Bool {
        credentialSecretReadImplementedByThisIssue == false
            && productionEndpointConnectionImplementedByThisIssue == false
            && signedAccountEndpointRuntimeImplementedByThisIssue == false
            && canarySubmitCancelImplementedByThisIssue == false
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
        contractID: Identifier = Identifier.constant("gh-1273-release-v0.21.0-binance-spot-controlled-production-canary-contract"),
        issueID: Identifier = Identifier.constant("GH-1273"),
        blockedByIssueIDs: [Identifier] = Self.requiredBlockedByIssueIDs,
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-1273..GH-1286",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedModes: [ReleaseV0210SpotControlledCanaryMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV0210SpotControlledCanaryPreflightRequirement] =
            Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV0210SpotControlledCanaryForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        v0201CloseoutRequired: Bool = true,
        controlledSpotCanaryScopeDefined: Bool = true,
        explicitHumanApprovalRequired: Bool = true,
        symbolAllowlistRequired: Bool = true,
        notionalSizeCapsRequired: Bool = true,
        riskKillSwitchNoTradeGateRequired: Bool = true,
        canaryEvidenceMustBeAuditable: Bool = true,
        credentialSecretReadImplementedByThisIssue: Bool = false,
        productionEndpointConnectionImplementedByThisIssue: Bool = false,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool = false,
        canarySubmitCancelImplementedByThisIssue: Bool = false,
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
            v0201CloseoutRequired: v0201CloseoutRequired,
            controlledSpotCanaryScopeDefined: controlledSpotCanaryScopeDefined,
            explicitHumanApprovalRequired: explicitHumanApprovalRequired,
            symbolAllowlistRequired: symbolAllowlistRequired,
            notionalSizeCapsRequired: notionalSizeCapsRequired,
            riskKillSwitchNoTradeGateRequired: riskKillSwitchNoTradeGateRequired,
            canaryEvidenceMustBeAuditable: canaryEvidenceMustBeAuditable
        )
        try Self.validateForbiddenFlags(
            credentialSecretReadImplementedByThisIssue: credentialSecretReadImplementedByThisIssue,
            productionEndpointConnectionImplementedByThisIssue: productionEndpointConnectionImplementedByThisIssue,
            signedAccountEndpointRuntimeImplementedByThisIssue: signedAccountEndpointRuntimeImplementedByThisIssue,
            canarySubmitCancelImplementedByThisIssue: canarySubmitCancelImplementedByThisIssue,
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
        self.v0201CloseoutRequired = v0201CloseoutRequired
        self.controlledSpotCanaryScopeDefined = controlledSpotCanaryScopeDefined
        self.explicitHumanApprovalRequired = explicitHumanApprovalRequired
        self.symbolAllowlistRequired = symbolAllowlistRequired
        self.notionalSizeCapsRequired = notionalSizeCapsRequired
        self.riskKillSwitchNoTradeGateRequired = riskKillSwitchNoTradeGateRequired
        self.canaryEvidenceMustBeAuditable = canaryEvidenceMustBeAuditable
        self.credentialSecretReadImplementedByThisIssue = credentialSecretReadImplementedByThisIssue
        self.productionEndpointConnectionImplementedByThisIssue = productionEndpointConnectionImplementedByThisIssue
        self.signedAccountEndpointRuntimeImplementedByThisIssue = signedAccountEndpointRuntimeImplementedByThisIssue
        self.canarySubmitCancelImplementedByThisIssue = canarySubmitCancelImplementedByThisIssue
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

    public static func deterministicFixture() throws -> ReleaseV0210SpotControlledProductionCanaryContract {
        try ReleaseV0210SpotControlledProductionCanaryContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.21.0 Binance Spot Controlled Production Canary"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot"]
    public static let requiredAllowedModes = ReleaseV0210SpotControlledCanaryMode.allCases
    public static let requiredPreflightRequirements = ReleaseV0210SpotControlledCanaryPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0210SpotControlledCanaryForbiddenCapability.allCases
    public static let requiredBlockedByIssueIDs = [Identifier.constant("GH-1272")]
    public static let requiredDownstreamIssueIDs = (1274...1286).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT",
        "TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT",
        "V0210-001-V0201-PREFLIGHT-GATE",
        "V0210-001-BINANCE-SPOT-CONTROLLED-CANARY",
        "V0210-001-HUMAN-APPROVAL-REQUIRED",
        "V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS",
        "V0210-001-RISK-KILL-NO-TRADE-GATES",
        "V0210-001-QUEUE-ORDER",
        "V0210-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1273ReleaseV0210SpotControlledProductionCanaryContract",
        "bash checks/verify-v0.21.0-controlled-canary-contract.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotControlledProductionCanaryContract {
    static func validateRequired(
        blockedByIssueIDs: [Identifier],
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedModes: [ReleaseV0210SpotControlledCanaryMode],
        preflightRequirements: [ReleaseV0210SpotControlledCanaryPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0210SpotControlledCanaryForbiddenCapability],
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
            ("canonicalQueueRange", canonicalQueueRange == "GH-1273..GH-1286", "GH-1273..GH-1286", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
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
        v0201CloseoutRequired: Bool,
        controlledSpotCanaryScopeDefined: Bool,
        explicitHumanApprovalRequired: Bool,
        symbolAllowlistRequired: Bool,
        notionalSizeCapsRequired: Bool,
        riskKillSwitchNoTradeGateRequired: Bool,
        canaryEvidenceMustBeAuditable: Bool
    ) throws {
        for (field, value) in [
            ("v0201CloseoutRequired", v0201CloseoutRequired),
            ("controlledSpotCanaryScopeDefined", controlledSpotCanaryScopeDefined),
            ("explicitHumanApprovalRequired", explicitHumanApprovalRequired),
            ("symbolAllowlistRequired", symbolAllowlistRequired),
            ("notionalSizeCapsRequired", notionalSizeCapsRequired),
            ("riskKillSwitchNoTradeGateRequired", riskKillSwitchNoTradeGateRequired),
            ("canaryEvidenceMustBeAuditable", canaryEvidenceMustBeAuditable)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        credentialSecretReadImplementedByThisIssue: Bool,
        productionEndpointConnectionImplementedByThisIssue: Bool,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool,
        canarySubmitCancelImplementedByThisIssue: Bool,
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
            ("productionEndpointConnectionImplementedByThisIssue", productionEndpointConnectionImplementedByThisIssue),
            ("signedAccountEndpointRuntimeImplementedByThisIssue", signedAccountEndpointRuntimeImplementedByThisIssue),
            ("canarySubmitCancelImplementedByThisIssue", canarySubmitCancelImplementedByThisIssue),
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
