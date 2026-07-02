import DomainModel
import Foundation

/// ReleaseV0210SpotCanaryCredentialApprovalState 固定 GH-1275 的 credential
/// secret-read approval 状态。
///
/// `approvedForScopedSecretRead` 只表示 Human operator 已批准后续 canary gate
/// 可以读取 Binance Spot canary credential secret；本 issue 仍不读取 secret value、
/// 不连接 endpoint、不提交 / 取消 / 替换订单，也不授权 production cutover。
public enum ReleaseV0210SpotCanaryCredentialApprovalState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case awaitingOperatorApproval = "awaiting-operator-approval"
    case approvedForScopedSecretRead = "approved-for-scoped-secret-read"
    case rejectedByOperator = "rejected-by-operator"
    case failClosedMissingOperatorApproval = "fail-closed-missing-operator-approval"
}

/// ReleaseV0210SpotCanaryCredentialApprovalFailureClass 固定 GH-1275 的
/// fail-closed 分类。
public enum ReleaseV0210SpotCanaryCredentialApprovalFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missingOperatorApprovalEvidence = "missing operator approval evidence"
    case approvalRejected = "approval rejected"
    case redactionEvidenceMissing = "redaction evidence missing"
    case secretValueAccessAttemptedByThisIssue = "secret value access attempted by this issue"
    case endpointOrOrderCapabilityAttempted = "endpoint or order capability attempted"
}

/// ReleaseV0210SpotCanaryCredentialApprovalRequirement 固定 GH-1275 的验收要求。
public enum ReleaseV0210SpotCanaryCredentialApprovalRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamEnvironmentProfileHeld = "upstream environment profile held"
    case binanceSpotProductionLiveOnly = "Binance Spot productionLive only"
    case explicitOperatorApprovalEvidenceRequired = "explicit operator approval evidence required"
    case approvalEvidenceMustBeRedacted = "approval evidence must be redacted"
    case scopedCredentialSecretReadApproval = "scoped credential secret-read approval"
    case missingApprovalFailsClosed = "missing approval fails closed"
    case noAutomaticSecretDiscovery = "no automatic secret discovery"
    case noFallbackSecretProvider = "no fallback secret provider"
    case noSecretValueLogging = "no secret value logging"
    case noSecretValueReadByThisIssue = "no secret value read by this issue"
    case noEndpointConnection = "no endpoint connection"
    case noOrderSubmission = "no order submission"
    case downstreamReadOnlyPreflightRequired = "downstream read-only preflight required"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability 枚举 GH-1275 仍然拒绝的能力。
public enum ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case automaticSecretRead = "automatic secret read"
    case fallbackSecretDiscovery = "fallback secret discovery"
    case secretValueReadByThisIssue = "secret value read by this issue"
    case secretValueLogged = "secret value logged"
    case rawCredentialMaterialStored = "raw credential material stored"
    case apiKeyLogged = "API key logged"
    case secretKeyLogged = "secret key logged"
    case listenKeyLogged = "listenKey logged"
    case productionEndpointConnection = "production endpoint connection"
    case signedAccountEndpointRuntime = "signed account endpoint runtime"
    case privateStreamRuntime = "private stream runtime"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case dashboardTradingButton = "Dashboard trading button"
    case orderForm = "order form"
    case liveCommand = "live command"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence 表达 GH-1275 的脱敏审批审计证据。
///
/// Evidence 只能保存 approval identity、profile identity、namespace、redacted
/// credential reference 和 append-only audit 摘要；不得保存 API key / secret key /
/// listenKey，不得触发 secret provider，不得连接 endpoint 或 broker。
public struct ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence: Codable, Equatable, Sendable {
    public let auditEvidenceID: Identifier
    public let state: ReleaseV0210SpotCanaryCredentialApprovalState
    public let failureClass: ReleaseV0210SpotCanaryCredentialApprovalFailureClass?
    public let approvalEvidenceID: String
    public let profileID: String
    public let namespaceKey: String
    public let redactedCredentialReference: String
    public let redactedAuditSummary: String
    public let secretValueReadByThisIssue: Bool
    public let rawCredentialMaterialPresent: Bool
    public let secretValueLogged: Bool
    public let automaticSecretDiscoveryAttempted: Bool
    public let fallbackSecretProviderUsed: Bool
    public let endpointConnectionOpened: Bool
    public let auditTrailAppendOnly: Bool

    public var evidenceHeld: Bool {
        state == .approvedForScopedSecretRead
            && failureClass == nil
            && approvalEvidenceID == Self.requiredApprovalEvidenceID
            && profileID == Self.requiredProfileID
            && namespaceKey == Self.requiredNamespaceKey
            && redactedCredentialReference == Self.requiredRedactedCredentialReference
            && Self.isRedactedSummary(redactedAuditSummary)
            && forbiddenEvidenceClosed
            && auditTrailAppendOnly
    }

    public var failClosedEvidenceHeld: Bool {
        state != .approvedForScopedSecretRead
            && failureClass != nil
            && approvalEvidenceID == Self.requiredApprovalEvidenceID
            && profileID == Self.requiredProfileID
            && namespaceKey == Self.requiredNamespaceKey
            && redactedCredentialReference == Self.requiredRedactedCredentialReference
            && Self.isRedactedSummary(redactedAuditSummary)
            && forbiddenEvidenceClosed
            && auditTrailAppendOnly
    }

    public var forbiddenEvidenceClosed: Bool {
        secretValueReadByThisIssue == false
            && rawCredentialMaterialPresent == false
            && secretValueLogged == false
            && automaticSecretDiscoveryAttempted == false
            && fallbackSecretProviderUsed == false
            && endpointConnectionOpened == false
    }

    public init(
        auditEvidenceID: Identifier? = nil,
        state: ReleaseV0210SpotCanaryCredentialApprovalState = .approvedForScopedSecretRead,
        failureClass: ReleaseV0210SpotCanaryCredentialApprovalFailureClass? = nil,
        approvalEvidenceID: String = Self.requiredApprovalEvidenceID,
        profileID: String = Self.requiredProfileID,
        namespaceKey: String = Self.requiredNamespaceKey,
        redactedCredentialReference: String = Self.requiredRedactedCredentialReference,
        redactedAuditSummary: String = Self.requiredRedactedAuditSummary,
        secretValueReadByThisIssue: Bool = false,
        rawCredentialMaterialPresent: Bool = false,
        secretValueLogged: Bool = false,
        automaticSecretDiscoveryAttempted: Bool = false,
        fallbackSecretProviderUsed: Bool = false,
        endpointConnectionOpened: Bool = false,
        auditTrailAppendOnly: Bool = true
    ) throws {
        let resolvedID = auditEvidenceID ?? Self.deterministicID(
            state: state,
            failureClass: failureClass,
            approvalEvidenceID: approvalEvidenceID,
            namespaceKey: namespaceKey
        )
        try Self.validate(
            state: state,
            failureClass: failureClass,
            approvalEvidenceID: approvalEvidenceID,
            profileID: profileID,
            namespaceKey: namespaceKey,
            redactedCredentialReference: redactedCredentialReference,
            redactedAuditSummary: redactedAuditSummary,
            secretValueReadByThisIssue: secretValueReadByThisIssue,
            rawCredentialMaterialPresent: rawCredentialMaterialPresent,
            secretValueLogged: secretValueLogged,
            automaticSecretDiscoveryAttempted: automaticSecretDiscoveryAttempted,
            fallbackSecretProviderUsed: fallbackSecretProviderUsed,
            endpointConnectionOpened: endpointConnectionOpened,
            auditTrailAppendOnly: auditTrailAppendOnly
        )

        self.auditEvidenceID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.approvalEvidenceID = approvalEvidenceID
        self.profileID = profileID
        self.namespaceKey = namespaceKey
        self.redactedCredentialReference = redactedCredentialReference
        self.redactedAuditSummary = redactedAuditSummary
        self.secretValueReadByThisIssue = secretValueReadByThisIssue
        self.rawCredentialMaterialPresent = rawCredentialMaterialPresent
        self.secretValueLogged = secretValueLogged
        self.automaticSecretDiscoveryAttempted = automaticSecretDiscoveryAttempted
        self.fallbackSecretProviderUsed = fallbackSecretProviderUsed
        self.endpointConnectionOpened = endpointConnectionOpened
        self.auditTrailAppendOnly = auditTrailAppendOnly
    }

    public static func approvedFixture() throws -> ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence {
        try ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence()
    }

    public static func missingApprovalFixture() throws -> ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence {
        try ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence(
            state: .failClosedMissingOperatorApproval,
            failureClass: .missingOperatorApprovalEvidence,
            redactedAuditSummary: "credential-approval=<redacted>; state=missing-operator-approval; action=fail-closed"
        )
    }

    public static func rejectedFixture() throws -> ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence {
        try ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence(
            state: .rejectedByOperator,
            failureClass: .approvalRejected,
            redactedAuditSummary: "credential-approval=<redacted>; state=rejected; action=fail-closed"
        )
    }

    public static let requiredApprovalEvidenceID =
        "human-operator-approval-evidence:binance:spot:productionLive:v0.21.0:credential-secret-read"
    public static let requiredProfileID =
        "gh-1274-release-v0.21.0-binance-spot-canary-environment-profile"
    public static let requiredNamespaceKey =
        "binance/spot/productionLive/canary/credential-secret-read-approval"
    public static let requiredRedactedCredentialReference =
        "redacted-credential-reference:binance:spot:productionLive:v0.21.0:canary"
    public static let requiredRedactedAuditSummary =
        "credential-approval=<redacted>; state=approved; scope=binance-spot-canary-secret-read"

    public static func deterministicID(
        state: ReleaseV0210SpotCanaryCredentialApprovalState,
        failureClass: ReleaseV0210SpotCanaryCredentialApprovalFailureClass?,
        approvalEvidenceID: String,
        namespaceKey: String
    ) -> Identifier {
        .constant(
            [
                "gh-1275-v0210-credential-secret-read-approval",
                state.rawValue,
                failureClass?.rawValue ?? "none",
                approvalEvidenceID,
                namespaceKey
            ].joined(separator: ":"),
            field: "releaseV0210.credentialSecretReadApproval.auditEvidenceID"
        )
    }
}

private extension ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence {
    static func validate(
        state: ReleaseV0210SpotCanaryCredentialApprovalState,
        failureClass: ReleaseV0210SpotCanaryCredentialApprovalFailureClass?,
        approvalEvidenceID: String,
        profileID: String,
        namespaceKey: String,
        redactedCredentialReference: String,
        redactedAuditSummary: String,
        secretValueReadByThisIssue: Bool,
        rawCredentialMaterialPresent: Bool,
        secretValueLogged: Bool,
        automaticSecretDiscoveryAttempted: Bool,
        fallbackSecretProviderUsed: Bool,
        endpointConnectionOpened: Bool,
        auditTrailAppendOnly: Bool
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "approvalEvidenceID",
                approvalEvidenceID == requiredApprovalEvidenceID,
                requiredApprovalEvidenceID,
                approvalEvidenceID
            ),
            ("profileID", profileID == requiredProfileID, requiredProfileID, profileID),
            ("namespaceKey", namespaceKey == requiredNamespaceKey, requiredNamespaceKey, namespaceKey),
            (
                "redactedCredentialReference",
                redactedCredentialReference == requiredRedactedCredentialReference,
                requiredRedactedCredentialReference,
                redactedCredentialReference
            )
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.\(field)",
                expected: expected,
                actual: actual
            )
        }

        switch (state, failureClass) {
        case (.approvedForScopedSecretRead, nil):
            break
        case (.approvedForScopedSecretRead, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.failureClass",
                expected: "nil when approved",
                actual: failureClass.rawValue
            )
        case (.awaitingOperatorApproval, .missingOperatorApprovalEvidence?),
             (.failClosedMissingOperatorApproval, .missingOperatorApprovalEvidence?),
             (.rejectedByOperator, .approvalRejected?):
            break
        case (.awaitingOperatorApproval, nil), (.failClosedMissingOperatorApproval, nil), (.rejectedByOperator, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (.awaitingOperatorApproval, .some(let failureClass)),
             (.failClosedMissingOperatorApproval, .some(let failureClass)),
             (.rejectedByOperator, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.failureClass",
                expected: "state-specific fail-closed failure class",
                actual: failureClass.rawValue
            )
        }

        guard isRedactedSummary(redactedAuditSummary) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.redactedAuditSummary",
                expected: "redacted summary without secret material",
                actual: redactedAuditSummary
            )
        }

        let forbiddenFlags = [
            ("secretValueReadByThisIssue", secretValueReadByThisIssue),
            ("rawCredentialMaterialPresent", rawCredentialMaterialPresent),
            ("secretValueLogged", secretValueLogged),
            ("automaticSecretDiscoveryAttempted", automaticSecretDiscoveryAttempted),
            ("fallbackSecretProviderUsed", fallbackSecretProviderUsed),
            ("endpointConnectionOpened", endpointConnectionOpened)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.credentialSecretReadApproval.audit.\(field)"
            )
        }

        guard auditTrailAppendOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.credentialSecretReadApproval.audit.auditTrailAppendOnly",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func isRedactedSummary(_ value: String) -> Bool {
        let lowered = value.lowercased()
        guard value.contains("<redacted>") else {
            return false
        }
        for forbidden in ["api key:", "secret key:", "listenkey", "secret=", "signature="] where lowered.contains(forbidden) {
            return false
        }
        return (lowered.contains("credential-approval") && lowered.contains("action=") == false)
            || lowered.contains("action=fail-closed")
    }
}

/// ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath 是 GH-1275 的
/// credential secret-read approval contract。
///
/// 该类型只记录 Human operator approval、脱敏审计和 fail-closed 行为。它不会读取、
/// 保存或输出任何 secret value；也不会打开 Binance endpoint、signed account runtime、
/// broker connection、order command、Dashboard trading button 或 production cutover。
public struct ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath: Codable, Equatable, Sendable {
    public let approvalPathID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamEnvironmentProfileHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let approvalState: ReleaseV0210SpotCanaryCredentialApprovalState
    public let requirements: [ReleaseV0210SpotCanaryCredentialApprovalRequirement]
    public let forbiddenCapabilities: [ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let auditEvidence: ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence
    public let operatorApprovalRequired: Bool
    public let operatorApprovalEvidencePresent: Bool
    public let operatorApprovalEvidenceRedacted: Bool
    public let credentialSecretReadApproved: Bool
    public let credentialSecretReadExecutedByThisIssue: Bool
    public let secretValueLogged: Bool
    public let rawCredentialMaterialStored: Bool
    public let automaticSecretDiscoveryEnabled: Bool
    public let fallbackSecretProviderEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let signedAccountEndpointRuntimeEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var approvalPathHeld: Bool {
        issueID.rawValue == "GH-1275"
            && upstreamIssueID.rawValue == "GH-1274"
            && downstreamIssueID.rawValue == "GH-1276"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && upstreamEnvironmentProfileHeld
            && namespaceHeld
            && approvalEvidenceHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenCapabilitiesClosed
    }

    public var failClosedPathHeld: Bool {
        issueID.rawValue == "GH-1275"
            && upstreamIssueID.rawValue == "GH-1274"
            && downstreamIssueID.rawValue == "GH-1276"
            && upstreamEnvironmentProfileHeld
            && namespaceHeld
            && operatorApprovalRequired
            && operatorApprovalEvidencePresent == false
            && credentialSecretReadApproved == false
            && auditEvidence.failClosedEvidenceHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var approvalEvidenceHeld: Bool {
        approvalState == .approvedForScopedSecretRead
            && operatorApprovalRequired
            && operatorApprovalEvidencePresent
            && operatorApprovalEvidenceRedacted
            && credentialSecretReadApproved
            && credentialSecretReadExecutedByThisIssue == false
            && auditEvidence.evidenceHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        credentialSecretReadExecutedByThisIssue == false
            && secretValueLogged == false
            && rawCredentialMaterialStored == false
            && automaticSecretDiscoveryEnabled == false
            && fallbackSecretProviderEnabled == false
            && productionEndpointConnectionEnabled == false
            && signedAccountEndpointRuntimeEnabled == false
            && privateStreamRuntimeEnabled == false
            && productionBrokerConnectionEnabled == false
            && orderSubmitCancelReplaceEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        approvalPathID: Identifier = Identifier.constant("gh-1275-release-v0.21.0-binance-spot-canary-credential-secret-read-approval-path"),
        issueID: Identifier = Identifier.constant("GH-1275"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1274"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1276"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        upstreamEnvironmentProfileHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        approvalState: ReleaseV0210SpotCanaryCredentialApprovalState = .approvedForScopedSecretRead,
        requirements: [ReleaseV0210SpotCanaryCredentialApprovalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        auditEvidence: ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence? = nil,
        operatorApprovalRequired: Bool = true,
        operatorApprovalEvidencePresent: Bool = true,
        operatorApprovalEvidenceRedacted: Bool = true,
        credentialSecretReadApproved: Bool = true,
        credentialSecretReadExecutedByThisIssue: Bool = false,
        secretValueLogged: Bool = false,
        rawCredentialMaterialStored: Bool = false,
        automaticSecretDiscoveryEnabled: Bool = false,
        fallbackSecretProviderEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        signedAccountEndpointRuntimeEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueID: upstreamIssueID,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamEnvironmentProfileHeld: upstreamEnvironmentProfileHeld,
            operatorApprovalRequired: operatorApprovalRequired,
            operatorApprovalEvidenceRedacted: operatorApprovalEvidenceRedacted
        )
        let resolvedAuditEvidence = try auditEvidence
            ?? ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.approvedFixture()

        try Self.validateApprovalGate(
            approvalState: approvalState,
            auditEvidence: resolvedAuditEvidence,
            operatorApprovalEvidencePresent: operatorApprovalEvidencePresent,
            credentialSecretReadApproved: credentialSecretReadApproved,
            credentialSecretReadExecutedByThisIssue: credentialSecretReadExecutedByThisIssue
        )
        try Self.validateForbiddenFlags(
            secretValueLogged: secretValueLogged,
            rawCredentialMaterialStored: rawCredentialMaterialStored,
            automaticSecretDiscoveryEnabled: automaticSecretDiscoveryEnabled,
            fallbackSecretProviderEnabled: fallbackSecretProviderEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            signedAccountEndpointRuntimeEnabled: signedAccountEndpointRuntimeEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.approvalPathID = approvalPathID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamEnvironmentProfileHeld = upstreamEnvironmentProfileHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.approvalState = approvalState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.auditEvidence = resolvedAuditEvidence
        self.operatorApprovalRequired = operatorApprovalRequired
        self.operatorApprovalEvidencePresent = operatorApprovalEvidencePresent
        self.operatorApprovalEvidenceRedacted = operatorApprovalEvidenceRedacted
        self.credentialSecretReadApproved = credentialSecretReadApproved
        self.credentialSecretReadExecutedByThisIssue = credentialSecretReadExecutedByThisIssue
        self.secretValueLogged = secretValueLogged
        self.rawCredentialMaterialStored = rawCredentialMaterialStored
        self.automaticSecretDiscoveryEnabled = automaticSecretDiscoveryEnabled
        self.fallbackSecretProviderEnabled = fallbackSecretProviderEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.signedAccountEndpointRuntimeEnabled = signedAccountEndpointRuntimeEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws -> ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath {
        _ = try ReleaseV0210SpotCanaryEnvironmentProfile.deterministicFixture()
        return try ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath()
    }

    public static func failClosedMissingApprovalFixture() throws -> ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath {
        _ = try ReleaseV0210SpotCanaryEnvironmentProfile.deterministicFixture()
        return try ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath(
            approvalState: .failClosedMissingOperatorApproval,
            auditEvidence: try ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.missingApprovalFixture(),
            operatorApprovalEvidencePresent: false,
            credentialSecretReadApproved: false
        )
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredRequirements = ReleaseV0210SpotCanaryCredentialApprovalRequirement.allCases
    public static let requiredForbiddenCapabilities =
        ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL",
        "TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL",
        "V0210-003-CREDENTIAL-SECRET-READ-APPROVAL",
        "V0210-003-EXPLICIT-OPERATOR-APPROVAL",
        "V0210-003-REDACTED-AUDIT-EVIDENCE",
        "V0210-003-NO-AUTOMATIC-SECRET-DISCOVERY",
        "V0210-003-NO-SECRET-LOGGING",
        "V0210-003-NO-ENDPOINT-ORDER-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1275ReleaseV0210CredentialSecretReadApprovalPath",
        "bash checks/verify-v0.21.0-credential-secret-read-approval.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueID: Identifier,
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        requirements: [ReleaseV0210SpotCanaryCredentialApprovalRequirement],
        forbiddenCapabilities: [ReleaseV0210SpotCanaryCredentialApprovalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1275", "GH-1275", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1274", "GH-1274", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1276", "GH-1276", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            (
                "projectName",
                projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            (
                "tradingEnvironment",
                tradingEnvironment == .productionLive,
                ReleaseV0181TradingEnvironment.productionLive.rawValue,
                tradingEnvironment.rawValue
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
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
        upstreamEnvironmentProfileHeld: Bool,
        operatorApprovalRequired: Bool,
        operatorApprovalEvidenceRedacted: Bool
    ) throws {
        for (field, value) in [
            ("upstreamEnvironmentProfileHeld", upstreamEnvironmentProfileHeld),
            ("operatorApprovalRequired", operatorApprovalRequired),
            ("operatorApprovalEvidenceRedacted", operatorApprovalEvidenceRedacted)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateApprovalGate(
        approvalState: ReleaseV0210SpotCanaryCredentialApprovalState,
        auditEvidence: ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence,
        operatorApprovalEvidencePresent: Bool,
        credentialSecretReadApproved: Bool,
        credentialSecretReadExecutedByThisIssue: Bool
    ) throws {
        if credentialSecretReadExecutedByThisIssue {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.credentialSecretReadApproval.secretReadExecutedByThisIssue"
            )
        }

        if credentialSecretReadApproved {
            guard approvalState == .approvedForScopedSecretRead else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.credentialSecretReadApproval.approvalState",
                    expected: ReleaseV0210SpotCanaryCredentialApprovalState.approvedForScopedSecretRead.rawValue,
                    actual: approvalState.rawValue
                )
            }
            guard operatorApprovalEvidencePresent else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.credentialSecretReadApproval.operatorApprovalEvidencePresent",
                    expected: "true",
                    actual: "false"
                )
            }
            guard auditEvidence.evidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.credentialSecretReadApproval.auditEvidence",
                    expected: "approved redacted audit evidence",
                    actual: auditEvidence.state.rawValue
                )
            }
        } else {
            guard operatorApprovalEvidencePresent == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.credentialSecretReadApproval.operatorApprovalEvidencePresent",
                    expected: "false when credential read is not approved",
                    actual: "true"
                )
            }
            guard auditEvidence.failClosedEvidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.credentialSecretReadApproval.auditEvidence",
                    expected: "fail-closed redacted audit evidence",
                    actual: auditEvidence.state.rawValue
                )
            }
        }
    }

    static func validateForbiddenFlags(
        secretValueLogged: Bool,
        rawCredentialMaterialStored: Bool,
        automaticSecretDiscoveryEnabled: Bool,
        fallbackSecretProviderEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        signedAccountEndpointRuntimeEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        let forbiddenFlags = [
            ("secretValueLogged", secretValueLogged),
            ("rawCredentialMaterialStored", rawCredentialMaterialStored),
            ("automaticSecretDiscoveryEnabled", automaticSecretDiscoveryEnabled),
            ("fallbackSecretProviderEnabled", fallbackSecretProviderEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("signedAccountEndpointRuntimeEnabled", signedAccountEndpointRuntimeEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
