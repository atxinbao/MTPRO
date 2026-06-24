import DomainModel
import Foundation

/// ReleaseV0160OperatorBetaMode 固定 GH-1101 允许后续 v0.16.0 issue 逐步实现的 operator beta 模式。
///
/// 这些 mode 只适用于 Binance Spot Testnet。GH-1101 本身只定义合同和队列边界，
/// 不执行网络请求、不读取 credential value、不提交 testnet order，也不授权 production cutover。
public enum ReleaseV0160OperatorBetaMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractOnly = "contract-only"
    case operatorRunModel = "operator-run-model"
    case spotTestnetSubmit = "spot-testnet-submit"
    case spotTestnetCancel = "spot-testnet-cancel"
    case spotTestnetStatusQuery = "spot-testnet-status-query"
    case localArtifactStore = "local-artifact-store"
    case omsReconciliation = "oms-reconciliation"
    case dashboardReadOnlyReview = "dashboard-read-only-review"
    case failureRecovery = "failure-recovery"
    case manualRedactedEvidence = "manual-redacted-evidence"
    case auditRunbookReleaseDocs = "audit-runbook-release-docs"
}

/// ReleaseV0160OperatorBetaPreflightRequirement 列出 v0.16.0 issue 执行前的 Parent Codex queue gate。
///
/// 它把 #1100 / v0.15.1 closeout 作为硬依赖，并继续要求 GitHub fallback queue 的 WIP=1。
public enum ReleaseV0160OperatorBetaPreflightRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case previousV0151QueueClosed = "previous v0.15.1 queue closed"
    case blockingIssue1100Done = "blocking issue GH-1100 done"
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case currentIssueContractRead = "current issue contract is read before work"
    case mainFastForwardClean = "main fast-forwarded and worktree clean"
    case binanceSpotTestnetOnly = "Binance Spot Testnet only"
    case explicitOperatorConfirmationRequired = "explicit operator confirmation required"
    case redactedEvidenceRequired = "redacted evidence required"
    case credentialValueNotPersisted = "credential value not persisted"
    case productionDisabledByDefault = "production disabled by default"
    case verifyV0160ContractScript = "verify-v0.16.0-operator-beta-contract command exists"
}

/// ReleaseV0160OperatorBetaForbiddenCapability 枚举 v0.16.0 operator beta 仍必须拒绝的生产能力。
public enum ReleaseV0160OperatorBetaForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
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
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV0160OperatorBetaContract 是 GH-1101 的 v0.16.0 顶层 operator beta 合同。
///
/// 合同只定义 Binance Spot Testnet operator execution beta 的允许模式、队列顺序、
/// validation anchors 和 production 禁区。它不实现 submit / cancel / status runtime，
/// 不读取真实 credential value，不连接 testnet 或 production endpoint，不发送任何订单。
public struct ReleaseV0160OperatorBetaContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedModes: [ReleaseV0160OperatorBetaMode]
    public let preflightRequirements: [ReleaseV0160OperatorBetaPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0160OperatorBetaForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let v0151CloseoutRequired: Bool
    public let explicitOperatorConfirmationRequired: Bool
    public let redactedEvidenceRequired: Bool
    public let testnetCredentialValueReadEnabledByThisIssue: Bool
    public let testnetNetworkConnectionEnabledByThisIssue: Bool
    public let testnetOrderSubmissionImplementedByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-1101"
            && blockedByIssueID.rawValue == "GH-1100"
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-1101..GH-1112"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.16.0"
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
            && startsNextMilestone == false
    }

    public var preflightBoundaryHeld: Bool {
        v0151CloseoutRequired
            && explicitOperatorConfirmationRequired
            && redactedEvidenceRequired
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
        contractID: Identifier = Identifier.constant("gh-1101-release-v0.16.0-operator-beta-contract"),
        issueID: Identifier = Identifier.constant("GH-1101"),
        blockedByIssueID: Identifier = Identifier.constant("GH-1100"),
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-1101..GH-1112",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.16.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedModes: [ReleaseV0160OperatorBetaMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV0160OperatorBetaPreflightRequirement] = Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV0160OperatorBetaForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        v0151CloseoutRequired: Bool = true,
        explicitOperatorConfirmationRequired: Bool = true,
        redactedEvidenceRequired: Bool = true,
        testnetCredentialValueReadEnabledByThisIssue: Bool = false,
        testnetNetworkConnectionEnabledByThisIssue: Bool = false,
        testnetOrderSubmissionImplementedByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
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
            v0151CloseoutRequired: v0151CloseoutRequired,
            explicitOperatorConfirmationRequired: explicitOperatorConfirmationRequired,
            redactedEvidenceRequired: redactedEvidenceRequired
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
        self.v0151CloseoutRequired = v0151CloseoutRequired
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.redactedEvidenceRequired = redactedEvidenceRequired
        self.testnetCredentialValueReadEnabledByThisIssue = testnetCredentialValueReadEnabledByThisIssue
        self.testnetNetworkConnectionEnabledByThisIssue = testnetNetworkConnectionEnabledByThisIssue
        self.testnetOrderSubmissionImplementedByThisIssue = testnetOrderSubmissionImplementedByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV0160OperatorBetaContract {
        try ReleaseV0160OperatorBetaContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot"]
    public static let requiredAllowedModes = ReleaseV0160OperatorBetaMode.allCases
    public static let requiredPreflightRequirements = ReleaseV0160OperatorBetaPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0160OperatorBetaForbiddenCapability.allCases
    public static let requiredDownstreamIssueIDs = (1102...1112).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT",
        "TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT",
        "V0160-001-V0151-PREFLIGHT-GATE",
        "V0160-001-BINANCE-SPOT-TESTNET-ONLY",
        "V0160-001-OPERATOR-CONFIRMATION-REQUIRED",
        "V0160-001-REDACTED-EVIDENCE-REQUIRED",
        "V0160-001-QUEUE-ORDER",
        "V0160-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1101ReleaseV0160OperatorBetaContractBlocksProductionCutover",
        "bash checks/verify-v0.16.0-operator-beta-contract.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0160OperatorBetaContract {
    static func validateRequired(
        blockedByIssueID: Identifier,
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedModes: [ReleaseV0160OperatorBetaMode],
        preflightRequirements: [ReleaseV0160OperatorBetaPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0160OperatorBetaForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("blockedByIssueID", blockedByIssueID.rawValue == "GH-1100", "GH-1100", blockedByIssueID.rawValue),
            (
                "downstreamIssueIDs",
                downstreamIssueIDs.map(\.rawValue) == requiredDownstreamIssueIDs.map(\.rawValue),
                requiredDownstreamIssueIDs.map(\.rawValue).joined(separator: ","),
                downstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            ("canonicalQueueRange", canonicalQueueRange == "GH-1101..GH-1112", "GH-1101..GH-1112", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.16.0", "v0.16.0", releaseVersion),
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
        v0151CloseoutRequired: Bool,
        explicitOperatorConfirmationRequired: Bool,
        redactedEvidenceRequired: Bool
    ) throws {
        for (field, value) in [
            ("v0151CloseoutRequired", v0151CloseoutRequired),
            ("explicitOperatorConfirmationRequired", explicitOperatorConfirmationRequired),
            ("redactedEvidenceRequired", redactedEvidenceRequired)
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
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
