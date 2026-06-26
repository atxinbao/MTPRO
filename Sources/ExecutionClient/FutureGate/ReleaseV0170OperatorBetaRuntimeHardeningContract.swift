import DomainModel
import Foundation

/// ReleaseV0170OperatorBetaHardeningMode 固定 GH-1139 允许后续 v0.17.0 issue 逐步强化的 operator beta 能力面。
///
/// 这些 mode 只服务 v0.16.0 / v0.16.1 之后的 Binance Spot Testnet operator beta artifact
/// 和 status runtime hardening。GH-1139 本身只定义合同，不读取 credential value、不连接网络、
/// 不提交 testnet order，也不授权 production cutover。
public enum ReleaseV0170OperatorBetaHardeningMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractOnly = "contract-only"
    case artifactBundleIngestReplayValidator = "artifact-bundle-ingest-replay-validator"
    case signedStatusRetryTimeoutFailureModel = "signed-status-retry-timeout-failure-model"
    case operatorRunResumeFromArtifactStore = "operator-run-resume-from-artifact-store"
    case cancelStatusReconciliationRecovery = "cancel-status-reconciliation-recovery"
    case dashboardArtifactValidationErrorSurface = "dashboard-artifact-validation-error-surface"
    case cliArtifactVerifyCommand = "cli-artifact-verify-command"
    case manualWorkflowArtifactTransferValidation = "manual-workflow-artifact-transfer-validation"
    case betaSafetyPolicyProfileEvidence = "beta-safety-policy-profile-evidence"
    case stageAuditReleaseDocs = "stage-audit-release-docs"
}

/// ReleaseV0170OperatorBetaPreflightRequirement 列出 v0.17.0 GitHub fallback queue 执行前必须满足的 gate。
///
/// v0.17.0 必须在 #1138 / v0.16.1 patch queue 完成后才可启动，并继续保持 WIP=1。
public enum ReleaseV0170OperatorBetaPreflightRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case previousV0161QueueClosed = "previous v0.16.1 patch queue closed"
    case blockingIssue1138Done = "blocking issue GH-1138 done"
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case currentIssueContractRead = "current issue contract is read before work"
    case mainFastForwardClean = "main fast-forwarded and worktree clean"
    case binanceSpotTestnetOnly = "Binance Spot Testnet only"
    case explicitOperatorConfirmationRequired = "explicit operator confirmation required"
    case redactedArtifactEvidenceRequired = "redacted artifact evidence required"
    case artifactReplayBeforeRuntimeTrust = "artifact replay before runtime trust"
    case statusRuntimeHardeningOnly = "status runtime hardening only"
    case productionDisabledByDefault = "production disabled by default"
    case verifyV0170ContractScript = "verify-v0.17.0-operator-beta-runtime-hardening-contract command exists"
}

/// ReleaseV0170OperatorBetaForbiddenCapability 枚举 v0.17.0 顶层合同仍然拒绝的能力。
public enum ReleaseV0170OperatorBetaForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretRead = "production secret read"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionOrderSubmitCancelReplace = "production submit / cancel / replace"
    case productionOMS = "production OMS"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case livePROConsoleCommand = "Live PRO Console command"
    case nonBinanceVenue = "non-Binance venue"
    case nonSpotProductType = "non-spot product type"
    case rawSecretPersistence = "raw secret persistence"
    case rawBrokerPayloadPersistence = "raw broker payload persistence"
    case testnetCredentialValueReadByThisIssue = "testnet credential value read by GH-1139"
    case testnetNetworkConnectionByThisIssue = "testnet network connection by GH-1139"
    case testnetOrderSubmissionByThisIssue = "testnet order submission by GH-1139"
    case tagOrReleasePublication = "tag or GitHub Release publication"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV0170OperatorBetaRuntimeHardeningContract 是 GH-1139 的 v0.17.0 顶层合同。
///
/// 合同只定义 operator beta artifact / status runtime hardening 的 release boundary、queue order、
/// validation anchors 和 production 禁区。后续 issue 可以在该合同下强化 artifact ingest、status retry、
/// resume、reconciliation、Dashboard / CLI evidence 和 beta safety profile；GH-1139 本身不实现这些 runtime。
public struct ReleaseV0170OperatorBetaRuntimeHardeningContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedModes: [ReleaseV0170OperatorBetaHardeningMode]
    public let preflightRequirements: [ReleaseV0170OperatorBetaPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0170OperatorBetaForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let v0161CloseoutRequired: Bool
    public let explicitOperatorConfirmationRequired: Bool
    public let redactedArtifactEvidenceRequired: Bool
    public let artifactReplayValidationRequired: Bool
    public let statusRuntimeHardeningScopeOnly: Bool
    public let testnetCredentialValueReadEnabledByThisIssue: Bool
    public let testnetNetworkConnectionEnabledByThisIssue: Bool
    public let testnetOrderSubmissionImplementedByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-1139"
            && blockedByIssueID.rawValue == "GH-1138"
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-1139..GH-1148"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.17.0"
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
        v0161CloseoutRequired
            && explicitOperatorConfirmationRequired
            && redactedArtifactEvidenceRequired
            && artifactReplayValidationRequired
            && statusRuntimeHardeningScopeOnly
    }

    public var implementationDeferredByThisIssue: Bool {
        testnetCredentialValueReadEnabledByThisIssue == false
            && testnetNetworkConnectionEnabledByThisIssue == false
            && testnetOrderSubmissionImplementedByThisIssue == false
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
        contractID: Identifier = Identifier.constant("gh-1139-release-v0.17.0-operator-beta-runtime-hardening-contract"),
        issueID: Identifier = Identifier.constant("GH-1139"),
        blockedByIssueID: Identifier = Identifier.constant("GH-1138"),
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-1139..GH-1148",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.17.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedModes: [ReleaseV0170OperatorBetaHardeningMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV0170OperatorBetaPreflightRequirement] = Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV0170OperatorBetaForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        v0161CloseoutRequired: Bool = true,
        explicitOperatorConfirmationRequired: Bool = true,
        redactedArtifactEvidenceRequired: Bool = true,
        artifactReplayValidationRequired: Bool = true,
        statusRuntimeHardeningScopeOnly: Bool = true,
        testnetCredentialValueReadEnabledByThisIssue: Bool = false,
        testnetNetworkConnectionEnabledByThisIssue: Bool = false,
        testnetOrderSubmissionImplementedByThisIssue: Bool = false,
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
            blockedByIssueID: blockedByIssueID,
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
            v0161CloseoutRequired: v0161CloseoutRequired,
            explicitOperatorConfirmationRequired: explicitOperatorConfirmationRequired,
            redactedArtifactEvidenceRequired: redactedArtifactEvidenceRequired,
            artifactReplayValidationRequired: artifactReplayValidationRequired,
            statusRuntimeHardeningScopeOnly: statusRuntimeHardeningScopeOnly
        )
        try Self.validateForbiddenFlags(
            testnetCredentialValueReadEnabledByThisIssue: testnetCredentialValueReadEnabledByThisIssue,
            testnetNetworkConnectionEnabledByThisIssue: testnetNetworkConnectionEnabledByThisIssue,
            testnetOrderSubmissionImplementedByThisIssue: testnetOrderSubmissionImplementedByThisIssue,
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
        self.blockedByIssueID = blockedByIssueID
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
        self.v0161CloseoutRequired = v0161CloseoutRequired
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.redactedArtifactEvidenceRequired = redactedArtifactEvidenceRequired
        self.artifactReplayValidationRequired = artifactReplayValidationRequired
        self.statusRuntimeHardeningScopeOnly = statusRuntimeHardeningScopeOnly
        self.testnetCredentialValueReadEnabledByThisIssue = testnetCredentialValueReadEnabledByThisIssue
        self.testnetNetworkConnectionEnabledByThisIssue = testnetNetworkConnectionEnabledByThisIssue
        self.testnetOrderSubmissionImplementedByThisIssue = testnetOrderSubmissionImplementedByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV0170OperatorBetaRuntimeHardeningContract {
        try ReleaseV0170OperatorBetaRuntimeHardeningContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot"]
    public static let requiredAllowedModes = ReleaseV0170OperatorBetaHardeningMode.allCases
    public static let requiredPreflightRequirements = ReleaseV0170OperatorBetaPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0170OperatorBetaForbiddenCapability.allCases
    public static let requiredDownstreamIssueIDs = (1140...1148).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT",
        "TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT",
        "V0170-001-V0161-PREFLIGHT-GATE",
        "V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE",
        "V0170-001-BINANCE-SPOT-TESTNET-ONLY",
        "V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED",
        "V0170-001-QUEUE-ORDER",
        "V0170-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1139ReleaseV0170OperatorBetaRuntimeHardeningContract",
        "bash checks/verify-v0.17.0-operator-beta-runtime-hardening-contract.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0170OperatorBetaRuntimeHardeningContract {
    static func validateRequired(
        blockedByIssueID: Identifier,
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedModes: [ReleaseV0170OperatorBetaHardeningMode],
        preflightRequirements: [ReleaseV0170OperatorBetaPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0170OperatorBetaForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("blockedByIssueID", blockedByIssueID.rawValue == "GH-1138", "GH-1138", blockedByIssueID.rawValue),
            (
                "downstreamIssueIDs",
                downstreamIssueIDs.map(\.rawValue) == requiredDownstreamIssueIDs.map(\.rawValue),
                requiredDownstreamIssueIDs.map(\.rawValue).joined(separator: ","),
                downstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            ("canonicalQueueRange", canonicalQueueRange == "GH-1139..GH-1148", "GH-1139..GH-1148", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.17.0", "v0.17.0", releaseVersion),
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
        v0161CloseoutRequired: Bool,
        explicitOperatorConfirmationRequired: Bool,
        redactedArtifactEvidenceRequired: Bool,
        artifactReplayValidationRequired: Bool,
        statusRuntimeHardeningScopeOnly: Bool
    ) throws {
        for (field, value) in [
            ("v0161CloseoutRequired", v0161CloseoutRequired),
            ("explicitOperatorConfirmationRequired", explicitOperatorConfirmationRequired),
            ("redactedArtifactEvidenceRequired", redactedArtifactEvidenceRequired),
            ("artifactReplayValidationRequired", artifactReplayValidationRequired),
            ("statusRuntimeHardeningScopeOnly", statusRuntimeHardeningScopeOnly)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        testnetCredentialValueReadEnabledByThisIssue: Bool,
        testnetNetworkConnectionEnabledByThisIssue: Bool,
        testnetOrderSubmissionImplementedByThisIssue: Bool,
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
            ("testnetCredentialValueReadEnabledByThisIssue", testnetCredentialValueReadEnabledByThisIssue),
            ("testnetNetworkConnectionEnabledByThisIssue", testnetNetworkConnectionEnabledByThisIssue),
            ("testnetOrderSubmissionImplementedByThisIssue", testnetOrderSubmissionImplementedByThisIssue),
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
