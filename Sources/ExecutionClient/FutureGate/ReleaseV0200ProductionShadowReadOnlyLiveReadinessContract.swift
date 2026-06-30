import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowReadinessMode 固定 v0.20.0 Binance Spot production-shadow
/// / read-only live readiness 允许推进的能力面。
///
/// GH-1239 只定义合同。后续 issue 可在该合同下逐步增加环境 profile、endpoint
/// allowlist、credential reference readiness、只读 probe、redaction policy、no-order guard
/// 和 Dashboard / CLI 只读 evidence；本 issue 不读取 secret、不连接 endpoint、不实现订单路径。
public enum ReleaseV0200ProductionShadowReadinessMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractOnly = "contract-only"
    case productionShadowEnvironmentProfile = "production-shadow-environment-profile"
    case productionReadOnlyEndpointAllowlist = "production-read-only-endpoint-allowlist"
    case credentialReferenceReadiness = "credential-reference-readiness"
    case publicMarketReadOnlyProbe = "public-market-read-only-probe"
    case signedAccountReadinessProbeContract = "signed-account-readiness-probe-contract"
    case accountSnapshotRedactionArtifactPolicy = "account-snapshot-redaction-artifact-policy"
    case noOrderCapabilityGuard = "no-order-capability-guard"
    case riskKillSwitchNoTradeReadinessEvidence = "risk-kill-switch-no-trade-readiness-evidence"
    case dashboardCLIReadOnlyLiveReadinessSurface = "dashboard-cli-read-only-live-readiness-surface"
    case releaseValidationSuite = "release-validation-suite"
    case stageAuditReleaseDocs = "stage-audit-release-docs"
}

/// ReleaseV0200ProductionShadowPreflightRequirement 列出 v0.20.0 GitHub fallback queue
/// 执行前必须满足的 gate。
///
/// v0.20.0 必须在 v0.19.1 patch queue 完成后启动，且继续保持 WIP=1。该 release
/// 只做 Binance Spot production-shadow / read-only live readiness，不开启 Spot canary。
public enum ReleaseV0200ProductionShadowPreflightRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case previousV0191QueueClosed = "previous v0.19.1 patch queue closed"
    case blockingIssues1232Through1237Done = "blocking issues GH-1232..GH-1237 done"
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case currentIssueContractRead = "current issue contract is read before work"
    case mainFastForwardClean = "main fast-forwarded and worktree clean"
    case binanceSpotOnly = "Binance Spot only"
    case productionShadowReadOnlyOnly = "production-shadow read-only only"
    case noOrderSubmitCancelReplace = "no order submit / cancel / replace"
    case spotCanaryDeferredToV0210 = "Spot controlled canary deferred to v0.21.0"
    case failClosedEvidenceRequired = "readiness evidence fails closed"
    case verifyV0200ContractScript = "verify-v0.20.0-production-shadow-readiness-contract command exists"
}

/// ReleaseV0200ProductionShadowForbiddenCapability 枚举 v0.20.0 顶层合同仍然拒绝的能力。
public enum ReleaseV0200ProductionShadowForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretValueRead = "production secret value read"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case spotCanaryByThisRelease = "Spot canary by v0.20.0"
    case futuresExecution = "Futures execution"
    case okxActiveImplementation = "OKX active implementation"
    case signedEndpointRuntimeByThisIssue = "signed endpoint runtime by GH-1239"
    case accountEndpointRuntimeByThisIssue = "account endpoint runtime by GH-1239"
    case privateStreamRuntimeByThisIssue = "private stream runtime by GH-1239"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case liveCommand = "live command"
    case tagOrReleasePublication = "tag or GitHub Release publication"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract 是 GH-1239 的 v0.20.0 顶层合同。
///
/// 合同只定义 Binance Spot production-shadow / read-only live readiness 的 release boundary、
/// queue order、validation anchors、fail-closed 条件和 production 禁区。后续 issue 必须在
/// 该合同下逐步证明只读 readiness，不能把 readiness evidence 解释为 canary、order path
/// 或 production cutover 授权。
public struct ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedModes: [ReleaseV0200ProductionShadowReadinessMode]
    public let preflightRequirements: [ReleaseV0200ProductionShadowPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let v0191CloseoutRequired: Bool
    public let productionShadowReadOnlyOnly: Bool
    public let failClosedReadinessEvidenceRequired: Bool
    public let spotCanaryDeferredToV0210: Bool
    public let credentialSecretValueReadEnabledByThisIssue: Bool
    public let productionEndpointConnectionEnabledByThisIssue: Bool
    public let signedAccountEndpointRuntimeImplementedByThisIssue: Bool
    public let privateStreamRuntimeImplementedByThisIssue: Bool
    public let orderSubmitCancelReplaceImplementedByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-1239"
            && blockedByIssueIDs.map(\.rawValue) == Self.requiredBlockedByIssueIDs.map(\.rawValue)
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-1239..GH-1250"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.20.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedModes == Self.requiredAllowedModes
            && preflightRequirements == Self.requiredPreflightRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && preflightBoundaryHeld
            && implementationDeferredByThisIssue
            && productionDefaultsClosed
            && createsTagOrRelease == false
            && startsNextMilestone == false
    }

    public var preflightBoundaryHeld: Bool {
        v0191CloseoutRequired
            && productionShadowReadOnlyOnly
            && failClosedReadinessEvidenceRequired
            && spotCanaryDeferredToV0210
    }

    public var implementationDeferredByThisIssue: Bool {
        credentialSecretValueReadEnabledByThisIssue == false
            && productionEndpointConnectionEnabledByThisIssue == false
            && signedAccountEndpointRuntimeImplementedByThisIssue == false
            && privateStreamRuntimeImplementedByThisIssue == false
            && orderSubmitCancelReplaceImplementedByThisIssue == false
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-1239-release-v0.20.0-production-shadow-read-only-live-readiness-contract"),
        issueID: Identifier = Identifier.constant("GH-1239"),
        blockedByIssueIDs: [Identifier] = Self.requiredBlockedByIssueIDs,
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-1239..GH-1250",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedModes: [ReleaseV0200ProductionShadowReadinessMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV0200ProductionShadowPreflightRequirement] = Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        v0191CloseoutRequired: Bool = true,
        productionShadowReadOnlyOnly: Bool = true,
        failClosedReadinessEvidenceRequired: Bool = true,
        spotCanaryDeferredToV0210: Bool = true,
        credentialSecretValueReadEnabledByThisIssue: Bool = false,
        productionEndpointConnectionEnabledByThisIssue: Bool = false,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool = false,
        privateStreamRuntimeImplementedByThisIssue: Bool = false,
        orderSubmitCancelReplaceImplementedByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
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
            v0191CloseoutRequired: v0191CloseoutRequired,
            productionShadowReadOnlyOnly: productionShadowReadOnlyOnly,
            failClosedReadinessEvidenceRequired: failClosedReadinessEvidenceRequired,
            spotCanaryDeferredToV0210: spotCanaryDeferredToV0210
        )
        try Self.validateForbiddenFlags(
            credentialSecretValueReadEnabledByThisIssue: credentialSecretValueReadEnabledByThisIssue,
            productionEndpointConnectionEnabledByThisIssue: productionEndpointConnectionEnabledByThisIssue,
            signedAccountEndpointRuntimeImplementedByThisIssue: signedAccountEndpointRuntimeImplementedByThisIssue,
            privateStreamRuntimeImplementedByThisIssue: privateStreamRuntimeImplementedByThisIssue,
            orderSubmitCancelReplaceImplementedByThisIssue: orderSubmitCancelReplaceImplementedByThisIssue,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretReadEnabled: productionSecretReadEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionOrderSubmitCancelReplaceEnabled: productionOrderSubmitCancelReplaceEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
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
        self.v0191CloseoutRequired = v0191CloseoutRequired
        self.productionShadowReadOnlyOnly = productionShadowReadOnlyOnly
        self.failClosedReadinessEvidenceRequired = failClosedReadinessEvidenceRequired
        self.spotCanaryDeferredToV0210 = spotCanaryDeferredToV0210
        self.credentialSecretValueReadEnabledByThisIssue = credentialSecretValueReadEnabledByThisIssue
        self.productionEndpointConnectionEnabledByThisIssue = productionEndpointConnectionEnabledByThisIssue
        self.signedAccountEndpointRuntimeImplementedByThisIssue = signedAccountEndpointRuntimeImplementedByThisIssue
        self.privateStreamRuntimeImplementedByThisIssue = privateStreamRuntimeImplementedByThisIssue
        self.orderSubmitCancelReplaceImplementedByThisIssue = orderSubmitCancelReplaceImplementedByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract {
        try ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot"]
    public static let requiredAllowedModes = ReleaseV0200ProductionShadowReadinessMode.allCases
    public static let requiredPreflightRequirements = ReleaseV0200ProductionShadowPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0200ProductionShadowForbiddenCapability.allCases
    public static let requiredBlockedByIssueIDs = (1232...1237).map { Identifier.constant("GH-\($0)") }
    public static let requiredDownstreamIssueIDs = (1240...1250).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT",
        "TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT",
        "V0200-001-V0191-PREFLIGHT-GATE",
        "V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW",
        "V0200-001-READ-ONLY-LIVE-READINESS",
        "V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE",
        "V0200-001-SPOT-CANARY-DEFERRED-TO-V0210",
        "V0200-001-QUEUE-ORDER",
        "V0200-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1239ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract",
        "bash checks/verify-v0.20.0-production-shadow-readiness-contract.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract {
    static func validateRequired(
        blockedByIssueIDs: [Identifier],
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedModes: [ReleaseV0200ProductionShadowReadinessMode],
        preflightRequirements: [ReleaseV0200ProductionShadowPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowForbiddenCapability],
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
            ("canonicalQueueRange", canonicalQueueRange == "GH-1239..GH-1250", "GH-1239..GH-1250", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.20.0", "v0.20.0", releaseVersion),
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
        v0191CloseoutRequired: Bool,
        productionShadowReadOnlyOnly: Bool,
        failClosedReadinessEvidenceRequired: Bool,
        spotCanaryDeferredToV0210: Bool
    ) throws {
        for (field, value) in [
            ("v0191CloseoutRequired", v0191CloseoutRequired),
            ("productionShadowReadOnlyOnly", productionShadowReadOnlyOnly),
            ("failClosedReadinessEvidenceRequired", failClosedReadinessEvidenceRequired),
            ("spotCanaryDeferredToV0210", spotCanaryDeferredToV0210)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        credentialSecretValueReadEnabledByThisIssue: Bool,
        productionEndpointConnectionEnabledByThisIssue: Bool,
        signedAccountEndpointRuntimeImplementedByThisIssue: Bool,
        privateStreamRuntimeImplementedByThisIssue: Bool,
        orderSubmitCancelReplaceImplementedByThisIssue: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionOrderSubmitCancelReplaceEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("credentialSecretValueReadEnabledByThisIssue", credentialSecretValueReadEnabledByThisIssue),
            ("productionEndpointConnectionEnabledByThisIssue", productionEndpointConnectionEnabledByThisIssue),
            ("signedAccountEndpointRuntimeImplementedByThisIssue", signedAccountEndpointRuntimeImplementedByThisIssue),
            ("privateStreamRuntimeImplementedByThisIssue", privateStreamRuntimeImplementedByThisIssue),
            ("orderSubmitCancelReplaceImplementedByThisIssue", orderSubmitCancelReplaceImplementedByThisIssue),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabled", productionSecretReadEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionOrderSubmitCancelReplaceEnabled", productionOrderSubmitCancelReplaceEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
