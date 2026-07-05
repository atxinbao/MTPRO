import DomainModel
import Foundation

/// ReleaseV0220SpotLiveCanaryCredentialSecretReadState 固定 GH-1311 的
/// credential secret material read 状态。
///
/// `redactedAuditPersisted` 表示已经在有效 operator approval + one-shot run lock
/// 之后读取过临时 secret material，并且只留下脱敏审计证据。该状态不表示已经连接
/// signed endpoint、不表示已经提交 / 查询 / 取消订单，也不授权 production cutover。
public enum ReleaseV0220SpotLiveCanaryCredentialSecretReadState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case blockedMissingApproval = "blocked-missing-approval"
    case blockedConsumedApproval = "blocked-consumed-approval"
    case blockedMismatchedScope = "blocked-mismatched-scope"
    case blockedMissingSecretMaterial = "blocked-missing-secret-material"
    case redactedAuditPersisted = "redacted-audit-persisted"
}

/// ReleaseV0220SpotLiveCanaryCredentialSecretReadFailureClass 固定 GH-1311
/// 的 fail-closed 分类。
public enum ReleaseV0220SpotLiveCanaryCredentialSecretReadFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missingApproval = "missing approval"
    case consumedApproval = "consumed approval"
    case mismatchedScope = "mismatched scope"
    case missingSecretMaterial = "missing secret material"
    case redactionEvidenceMissing = "redaction evidence missing"
    case rawSecretPersistenceAttempted = "raw secret persistence attempted"
    case endpointOrOrderCapabilityAttempted = "endpoint or order capability attempted"
}

/// ReleaseV0220SpotLiveCanaryCredentialSecretReadRequirement 固定 GH-1311
/// 的验收要求。
public enum ReleaseV0220SpotLiveCanaryCredentialSecretReadRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamLiveCanaryTransportContractHeld = "upstream live canary transport contract held"
    case upstreamOperatorApprovalRunLockHeld = "upstream operator approval run lock held"
    case binanceSpotOnly = "Binance Spot only"
    case productionLiveEnvironmentOnly = "productionLive environment only"
    case explicitOperatorApprovalRequired = "explicit operator approval required"
    case oneShotRunLockRequired = "one-shot run lock required"
    case scopeBoundSecretRead = "scope-bound credential secret material read"
    case ephemeralSecretMaterialOnly = "ephemeral secret material only"
    case redactedCredentialReferenceOnly = "redacted credential reference only"
    case redactedAuditEvidenceRequired = "redacted audit evidence required"
    case rawSecretNeverPersisted = "raw secret never persisted"
    case missingApprovalFailsClosed = "missing approval fails closed"
    case consumedApprovalFailsClosed = "consumed approval fails closed"
    case mismatchedScopeFailsClosed = "mismatched scope fails closed"
    case noAutomaticSecretDiscovery = "no automatic secret discovery"
    case noFallbackSecretProvider = "no fallback secret provider"
    case downstreamSignedAccountPreflightRequired = "downstream signed account preflight required"
    case noEndpointConnection = "no endpoint connection"
    case noOrderSubmission = "no order submission"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0220SpotLiveCanaryCredentialSecretReadForbiddenCapability 枚举
/// GH-1311 仍然拒绝的能力。
public enum ReleaseV0220SpotLiveCanaryCredentialSecretReadForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case secretReadWithoutApproval = "secret read without approval"
    case approvalReuse = "approval reuse"
    case crossScopeSecretRead = "cross-scope secret read"
    case rawSecretMaterialStored = "raw secret material stored"
    case apiKeyLogged = "API key logged"
    case secretKeyLogged = "secret key logged"
    case signatureLogged = "signature logged"
    case listenKeyLogged = "listenKey logged"
    case automaticSecretDiscovery = "automatic secret discovery"
    case fallbackSecretProvider = "fallback secret provider"
    case signedEndpointRuntime = "signed endpoint runtime"
    case accountEndpointRuntime = "account endpoint runtime"
    case privateStreamRuntime = "private stream runtime"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case futuresExecution = "Futures execution"
    case okxActiveImplementation = "OKX active implementation"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence 是 GH-1311
/// 的脱敏 secret-read 审计证据。
///
/// Evidence 只能保存 credential reference metadata、material class、redacted
/// audit summary 和 append-only audit identity。它不保存 API key、secret key、
/// signature、listenKey 或 endpoint response。
public struct ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence:
    Codable, Equatable, Sendable
{
    public let auditEvidenceID: Identifier
    public let credentialReferenceID: String
    public let approvalEvidenceID: String
    public let scopeID: Identifier
    public let materialClass: String
    public let redactedCredentialReference: String
    public let redactedMaterialFingerprint: String
    public let redactedAuditSummary: String
    public let secretMaterialRead: Bool
    public let rawSecretMaterialPersisted: Bool
    public let rawSecretMaterialLogged: Bool
    public let automaticSecretDiscoveryAttempted: Bool
    public let fallbackSecretProviderUsed: Bool
    public let endpointConnectionOpened: Bool
    public let orderCapabilityAttempted: Bool
    public let auditTrailAppendOnly: Bool

    public var evidenceHeld: Bool {
        credentialReferenceID == Self.requiredCredentialReferenceID
            && approvalEvidenceID == ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock.requiredApprovalEvidenceID
            && scopeID == ReleaseV0220SpotLiveCanaryApprovalScope.deterministicFixture().scopeID
            && materialClass == Self.requiredMaterialClass
            && redactedCredentialReference == Self.requiredRedactedCredentialReference
            && Self.isRedactedValue(redactedMaterialFingerprint)
            && Self.isRedactedSummary(redactedAuditSummary)
            && secretMaterialRead
            && forbiddenEvidenceClosed
            && auditTrailAppendOnly
    }

    public var forbiddenEvidenceClosed: Bool {
        rawSecretMaterialPersisted == false
            && rawSecretMaterialLogged == false
            && automaticSecretDiscoveryAttempted == false
            && fallbackSecretProviderUsed == false
            && endpointConnectionOpened == false
            && orderCapabilityAttempted == false
    }

    public init(
        auditEvidenceID: Identifier = Identifier.constant("gh-1311-v0220-credential-secret-material-read-audit"),
        credentialReferenceID: String = Self.requiredCredentialReferenceID,
        approvalEvidenceID: String = ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock.requiredApprovalEvidenceID,
        scopeID: Identifier = ReleaseV0220SpotLiveCanaryApprovalScope.deterministicFixture().scopeID,
        materialClass: String = Self.requiredMaterialClass,
        redactedCredentialReference: String = Self.requiredRedactedCredentialReference,
        redactedMaterialFingerprint: String = Self.requiredRedactedMaterialFingerprint,
        redactedAuditSummary: String = Self.requiredRedactedAuditSummary,
        secretMaterialRead: Bool = true,
        rawSecretMaterialPersisted: Bool = false,
        rawSecretMaterialLogged: Bool = false,
        automaticSecretDiscoveryAttempted: Bool = false,
        fallbackSecretProviderUsed: Bool = false,
        endpointConnectionOpened: Bool = false,
        orderCapabilityAttempted: Bool = false,
        auditTrailAppendOnly: Bool = true
    ) throws {
        self.auditEvidenceID = auditEvidenceID
        self.credentialReferenceID = credentialReferenceID
        self.approvalEvidenceID = approvalEvidenceID
        self.scopeID = scopeID
        self.materialClass = materialClass
        self.redactedCredentialReference = redactedCredentialReference
        self.redactedMaterialFingerprint = redactedMaterialFingerprint
        self.redactedAuditSummary = redactedAuditSummary
        self.secretMaterialRead = secretMaterialRead
        self.rawSecretMaterialPersisted = rawSecretMaterialPersisted
        self.rawSecretMaterialLogged = rawSecretMaterialLogged
        self.automaticSecretDiscoveryAttempted = automaticSecretDiscoveryAttempted
        self.fallbackSecretProviderUsed = fallbackSecretProviderUsed
        self.endpointConnectionOpened = endpointConnectionOpened
        self.orderCapabilityAttempted = orderCapabilityAttempted
        self.auditTrailAppendOnly = auditTrailAppendOnly

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.credentialSecretMaterialRead.auditEvidence",
                expected: "redacted secret-read audit evidence without raw material persistence",
                actual: "invalid or unsafe audit evidence"
            )
        }
    }

    public static let requiredCredentialReferenceID =
        "credential-reference:binance:spot:productionLive:v0.22.0:one-shot-live-canary"
    public static let requiredMaterialClass = "api-key-and-secret-material-present"
    public static let requiredRedactedCredentialReference =
        "credential-reference=<redacted>; venue=Binance; product=spot; environment=productionLive"
    public static let requiredRedactedMaterialFingerprint =
        "material-fingerprint=<redacted>; api-key-material-present; secret-material-present"
    public static let requiredRedactedAuditSummary =
        "secret-read=<redacted>; scope=binance-spot-productionLive-BTCUSDT-LIMIT; rawMaterialPersisted=false"

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence
    {
        try ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence()
    }

    public static func isRedactedValue(_ value: String) -> Bool {
        value.contains("<redacted>")
            && !containsForbiddenSecretMaterial(value)
    }

    public static func isRedactedSummary(_ value: String) -> Bool {
        value.contains("<redacted>")
            && value.contains("rawMaterialPersisted=false")
            && !containsForbiddenSecretMaterial(value)
    }

    public static func containsForbiddenSecretMaterial(_ value: String) -> Bool {
        let lowered = value.lowercased()
        return lowered.contains("api_key=")
            || lowered.contains("apikey=")
            || lowered.contains("secret=")
            || lowered.contains("secretkey=")
            || lowered.contains("signature=")
            || lowered.contains("listenkey=")
            || lowered.contains("x-mbx-apikey")
            || lowered.contains("raw-secret")
    }
}

/// ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath 是 GH-1311 的
/// ephemeral credential secret material read path。
///
/// Path 必须消费 GH-1310 的 approval session / one-shot run lock。Secret material
/// 只允许作为调用栈内的临时输入存在，返回值只包含脱敏审计证据和 credential reference
/// metadata。该类型不读环境变量、不自动发现 secret、不连接 Binance endpoint、不发送订单。
public struct ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath:
    Codable, Equatable, Sendable
{
    public let readPathID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let upstreamApprovalRunLock: ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock
    public let readState: ReleaseV0220SpotLiveCanaryCredentialSecretReadState
    public let failureClass: ReleaseV0220SpotLiveCanaryCredentialSecretReadFailureClass?
    public let requirements: [ReleaseV0220SpotLiveCanaryCredentialSecretReadRequirement]
    public let forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryCredentialSecretReadForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let auditEvidence: ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence?
    public let operatorApprovalRequired: Bool
    public let approvalRunLockHeld: Bool
    public let scopeMatched: Bool
    public let secretMaterialProvided: Bool
    public let secretMaterialReadByThisIssue: Bool
    public let rawSecretMaterialPersisted: Bool
    public let rawSecretMaterialLogged: Bool
    public let credentialReferenceMetadataPersisted: Bool
    public let redactedAuditEvidencePersisted: Bool
    public let automaticSecretDiscoveryEnabled: Bool
    public let fallbackSecretProviderEnabled: Bool
    public let signedEndpointRuntimeEnabledByThisIssue: Bool
    public let accountEndpointRuntimeEnabledByThisIssue: Bool
    public let liveOrderSubmitEnabledByThisIssue: Bool
    public let liveOrderStatusCancelEnabledByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByThisIssue: Bool
    public let productionBrokerConnectionEnabledByThisIssue: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var readPathHeld: Bool {
        issueID.rawValue == "GH-1311"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1310"]
            && downstreamIssueID.rawValue == "GH-1312"
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && upstreamApprovalRunLock.approvalSessionHeld
            && readState == .redactedAuditPersisted
            && failureClass == nil
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && auditEvidence?.evidenceHeld == true
            && readFlagsHeld
            && forbiddenCapabilitiesClosed
    }

    public var failClosedEvidenceHeld: Bool {
        readPathHeld == false
            && failureClass != nil
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenCapabilitiesClosed
    }

    public var readFlagsHeld: Bool {
        operatorApprovalRequired
            && approvalRunLockHeld
            && scopeMatched
            && secretMaterialProvided
            && secretMaterialReadByThisIssue
            && rawSecretMaterialPersisted == false
            && rawSecretMaterialLogged == false
            && credentialReferenceMetadataPersisted
            && redactedAuditEvidencePersisted
    }

    public var forbiddenCapabilitiesClosed: Bool {
        automaticSecretDiscoveryEnabled == false
            && fallbackSecretProviderEnabled == false
            && signedEndpointRuntimeEnabledByThisIssue == false
            && accountEndpointRuntimeEnabledByThisIssue == false
            && liveOrderSubmitEnabledByThisIssue == false
            && liveOrderStatusCancelEnabledByThisIssue == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnectionEnabledByThisIssue == false
            && productionBrokerConnectionEnabledByThisIssue == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingButtonEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        readPathID: Identifier = Identifier.constant("gh-1311-v0220-credential-secret-material-read-path"),
        issueID: Identifier = Identifier.constant("GH-1311"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1310")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1312"),
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        upstreamApprovalRunLock: ReleaseV0220SpotLiveCanaryOperatorApprovalRunLock,
        readState: ReleaseV0220SpotLiveCanaryCredentialSecretReadState = .redactedAuditPersisted,
        failureClass: ReleaseV0220SpotLiveCanaryCredentialSecretReadFailureClass? = nil,
        requirements: [ReleaseV0220SpotLiveCanaryCredentialSecretReadRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0220SpotLiveCanaryCredentialSecretReadForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        auditEvidence: ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence?,
        operatorApprovalRequired: Bool = true,
        approvalRunLockHeld: Bool = true,
        scopeMatched: Bool = true,
        secretMaterialProvided: Bool = true,
        secretMaterialReadByThisIssue: Bool = true,
        rawSecretMaterialPersisted: Bool = false,
        rawSecretMaterialLogged: Bool = false,
        credentialReferenceMetadataPersisted: Bool = true,
        redactedAuditEvidencePersisted: Bool = true,
        automaticSecretDiscoveryEnabled: Bool = false,
        fallbackSecretProviderEnabled: Bool = false,
        signedEndpointRuntimeEnabledByThisIssue: Bool = false,
        accountEndpointRuntimeEnabledByThisIssue: Bool = false,
        liveOrderSubmitEnabledByThisIssue: Bool = false,
        liveOrderStatusCancelEnabledByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnectionEnabledByThisIssue: Bool = false,
        productionBrokerConnectionEnabledByThisIssue: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        self.readPathID = readPathID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.upstreamApprovalRunLock = upstreamApprovalRunLock
        self.readState = readState
        self.failureClass = failureClass
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.auditEvidence = auditEvidence
        self.operatorApprovalRequired = operatorApprovalRequired
        self.approvalRunLockHeld = approvalRunLockHeld
        self.scopeMatched = scopeMatched
        self.secretMaterialProvided = secretMaterialProvided
        self.secretMaterialReadByThisIssue = secretMaterialReadByThisIssue
        self.rawSecretMaterialPersisted = rawSecretMaterialPersisted
        self.rawSecretMaterialLogged = rawSecretMaterialLogged
        self.credentialReferenceMetadataPersisted = credentialReferenceMetadataPersisted
        self.redactedAuditEvidencePersisted = redactedAuditEvidencePersisted
        self.automaticSecretDiscoveryEnabled = automaticSecretDiscoveryEnabled
        self.fallbackSecretProviderEnabled = fallbackSecretProviderEnabled
        self.signedEndpointRuntimeEnabledByThisIssue = signedEndpointRuntimeEnabledByThisIssue
        self.accountEndpointRuntimeEnabledByThisIssue = accountEndpointRuntimeEnabledByThisIssue
        self.liveOrderSubmitEnabledByThisIssue = liveOrderSubmitEnabledByThisIssue
        self.liveOrderStatusCancelEnabledByThisIssue = liveOrderStatusCancelEnabledByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnectionEnabledByThisIssue = productionEndpointConnectionEnabledByThisIssue
        self.productionBrokerConnectionEnabledByThisIssue = productionBrokerConnectionEnabledByThisIssue
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease

        guard readPathHeld || failClosedEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.credentialSecretMaterialRead.path",
                expected: "approved redacted secret-read path or classified fail-closed evidence",
                actual: "invalid credential secret material read evidence"
            )
        }
    }

    /// 构造 GH-1311 的确定性成功证据。调用方必须提供非空临时 secret material；
    /// 原始值仅用于本地输入校验，不会进入返回对象。
    public static func redactedReadFixture(
        apiKeyMaterial: String = "fixture-api-key-material",
        apiSecretMaterial: String = "fixture-api-secret-material"
    ) throws -> ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath {
        guard apiKeyMaterial.isEmpty == false, apiSecretMaterial.isEmpty == false else {
            return try missingSecretMaterialFixture()
        }

        return try ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath(
            upstreamApprovalRunLock: .deterministicFixture(),
            auditEvidence: .deterministicFixture()
        )
    }

    public static func missingApprovalFixture() throws
        -> ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath
    {
        try ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath(
            upstreamApprovalRunLock: .missingApprovalFixture(),
            readState: .blockedMissingApproval,
            failureClass: .missingApproval,
            auditEvidence: nil,
            approvalRunLockHeld: false,
            secretMaterialProvided: false,
            secretMaterialReadByThisIssue: false,
            credentialReferenceMetadataPersisted: false,
            redactedAuditEvidencePersisted: false
        )
    }

    public static func consumedApprovalFixture() throws
        -> ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath
    {
        try ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath(
            upstreamApprovalRunLock: .reusedApprovalFixture(),
            readState: .blockedConsumedApproval,
            failureClass: .consumedApproval,
            auditEvidence: nil,
            approvalRunLockHeld: false,
            secretMaterialReadByThisIssue: false,
            credentialReferenceMetadataPersisted: false,
            redactedAuditEvidencePersisted: false
        )
    }

    public static func mismatchedScopeFixture() throws
        -> ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath
    {
        try ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath(
            upstreamApprovalRunLock: .mismatchedScopeFixture(),
            readState: .blockedMismatchedScope,
            failureClass: .mismatchedScope,
            auditEvidence: nil,
            approvalRunLockHeld: false,
            scopeMatched: false,
            secretMaterialReadByThisIssue: false,
            credentialReferenceMetadataPersisted: false,
            redactedAuditEvidencePersisted: false
        )
    }

    public static func missingSecretMaterialFixture() throws
        -> ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath
    {
        try ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath(
            upstreamApprovalRunLock: .deterministicFixture(),
            readState: .blockedMissingSecretMaterial,
            failureClass: .missingSecretMaterial,
            auditEvidence: nil,
            secretMaterialProvided: false,
            secretMaterialReadByThisIssue: false,
            credentialReferenceMetadataPersisted: false,
            redactedAuditEvidencePersisted: false
        )
    }

    public static let requiredRequirements: [ReleaseV0220SpotLiveCanaryCredentialSecretReadRequirement] = [
        .upstreamLiveCanaryTransportContractHeld,
        .upstreamOperatorApprovalRunLockHeld,
        .binanceSpotOnly,
        .productionLiveEnvironmentOnly,
        .explicitOperatorApprovalRequired,
        .oneShotRunLockRequired,
        .scopeBoundSecretRead,
        .ephemeralSecretMaterialOnly,
        .redactedCredentialReferenceOnly,
        .redactedAuditEvidenceRequired,
        .rawSecretNeverPersisted,
        .missingApprovalFailsClosed,
        .consumedApprovalFailsClosed,
        .mismatchedScopeFailsClosed,
        .noAutomaticSecretDiscovery,
        .noFallbackSecretProvider,
        .downstreamSignedAccountPreflightRequired,
        .noEndpointConnection,
        .noOrderSubmission,
        .noProductionCutover
    ]

    public static let requiredForbiddenCapabilities:
        [ReleaseV0220SpotLiveCanaryCredentialSecretReadForbiddenCapability] = [
            .secretReadWithoutApproval,
            .approvalReuse,
            .crossScopeSecretRead,
            .rawSecretMaterialStored,
            .apiKeyLogged,
            .secretKeyLogged,
            .signatureLogged,
            .listenKeyLogged,
            .automaticSecretDiscovery,
            .fallbackSecretProvider,
            .signedEndpointRuntime,
            .accountEndpointRuntime,
            .privateStreamRuntime,
            .productionEndpointConnection,
            .productionBrokerConnection,
            .orderSubmitCancelReplace,
            .futuresExecution,
            .okxActiveImplementation,
            .dashboardTradingButton,
            .dashboardOrderForm,
            .productionCutoverAuthorization,
            .tagOrReleasePublication
        ]

    public static let requiredValidationAnchors = [
        "GH-1311-VERIFY-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION",
        "TVM-RELEASE-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION",
        "V0220-003-BLOCKED-BY-GH1310",
        "V0220-003-APPROVAL-BOUND-SECRET-READ",
        "V0220-003-EPHEMERAL-SECRET-MATERIAL-ONLY",
        "V0220-003-REDACTED-AUDIT-EVIDENCE",
        "V0220-003-RAW-SECRET-NEVER-PERSISTED",
        "V0220-003-MISSING-APPROVAL-FAILS-CLOSED",
        "V0220-003-NO-ENDPOINT-ORDER",
        "V0220-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1311ReleaseV0220CredentialSecretMaterialReadRedaction",
        "bash checks/verify-v0.22.0-credential-secret-material-read-redaction.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
