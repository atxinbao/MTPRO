import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowCredentialReferenceState 描述 GH-1242 的 credential reference readiness 状态。
///
/// 状态只表达 credential reference 是否可识别以及缺失时是否 fail closed。它不包含 credential value，
/// 不触发 secret provider 读取，也不授权 signed endpoint、private stream、order 或 production cutover。
public enum ReleaseV0200ProductionShadowCredentialReferenceState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case referencePresent = "reference present"
    case missingReference = "missing reference"
    case invalidReference = "invalid reference"
}

/// ReleaseV0200ProductionShadowCredentialReferenceFailureClass 固定 GH-1242 的 fail-closed 分类。
public enum ReleaseV0200ProductionShadowCredentialReferenceFailureClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case requiredReferenceMissing = "required credential reference missing"
    case namespaceMismatch = "credential namespace mismatch"
    case secretValueAccessAttempted = "secret value access attempted"
    case rawCredentialMaterialPresent = "raw credential material present"
}

/// ReleaseV0200ProductionShadowCredentialReadinessRequirement 固定 #1242 的验收要求。
public enum ReleaseV0200ProductionShadowCredentialReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamEndpointAllowlistHeld = "upstream endpoint allowlist held"
    case binanceSpotProductionShadowOnly = "Binance Spot production-shadow only"
    case credentialIdentityReferenceRequired = "credential identity reference required"
    case missingReferenceFailsClosed = "missing reference fails closed"
    case invalidReferenceFailsClosed = "invalid reference fails closed"
    case redactedAuditEvidenceRequired = "redacted audit evidence required"
    case noSecretValueRead = "no secret value read"
    case noRawCredentialMaterialStored = "no raw credential material stored"
    case noEndpointConnection = "no endpoint connection"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0200ProductionShadowCredentialForbiddenCapability 枚举 #1242 必须继续拒绝的能力。
public enum ReleaseV0200ProductionShadowCredentialForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionSecretValueRead = "production secret value read"
    case rawCredentialMaterialStored = "raw credential material stored"
    case secretProviderAutoRead = "secret provider auto-read"
    case apiKeyLogged = "API key logged"
    case secretKeyLogged = "secret key logged"
    case listenKeyLogged = "listenKey logged"
    case signedAccountEndpointRuntime = "signed account endpoint runtime"
    case privateStreamRuntime = "private stream runtime"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case spotCanary = "Spot canary"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case dashboardTradingButton = "Dashboard trading button"
    case orderForm = "order form"
    case liveCommand = "live command"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence 表达 credential reference 的本地审计证据。
///
/// Evidence 只能保存 profile identity、namespace、redacted reference 和 fail-closed 分类。`redactedReferenceSummary`
/// 必须是脱敏摘要；任何 secret value 读取、raw credential material、endpoint connection 或非 append-only
/// audit trail 都会直接失败。
public struct ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence: Codable, Equatable, Sendable {
    public let auditEvidenceID: Identifier
    public let state: ReleaseV0200ProductionShadowCredentialReferenceState
    public let failureClass: ReleaseV0200ProductionShadowCredentialReferenceFailureClass?
    public let profileID: String
    public let namespaceKey: String
    public let redactedEvidenceReference: String
    public let redactedReferenceSummary: String
    public let secretValueRead: Bool
    public let rawCredentialMaterialPresent: Bool
    public let endpointConnectionOpened: Bool
    public let auditTrailAppendOnly: Bool

    public var evidenceHeld: Bool {
        state == .referencePresent
            && failureClass == nil
            && profileID == Self.requiredProfileID
            && namespaceKey == Self.requiredNamespaceKey
            && redactedEvidenceReference == Self.requiredRedactedEvidenceReference
            && Self.isRedactedSummary(redactedReferenceSummary)
            && secretValueRead == false
            && rawCredentialMaterialPresent == false
            && endpointConnectionOpened == false
            && auditTrailAppendOnly
    }

    public var failClosedEvidenceHeld: Bool {
        state != .referencePresent
            && failureClass != nil
            && profileID == Self.requiredProfileID
            && namespaceKey == Self.requiredNamespaceKey
            && redactedEvidenceReference == Self.requiredRedactedEvidenceReference
            && Self.isRedactedSummary(redactedReferenceSummary)
            && secretValueRead == false
            && rawCredentialMaterialPresent == false
            && endpointConnectionOpened == false
            && auditTrailAppendOnly
    }

    public init(
        auditEvidenceID: Identifier? = nil,
        state: ReleaseV0200ProductionShadowCredentialReferenceState,
        failureClass: ReleaseV0200ProductionShadowCredentialReferenceFailureClass? = nil,
        profileID: String = Self.requiredProfileID,
        namespaceKey: String = Self.requiredNamespaceKey,
        redactedEvidenceReference: String = Self.requiredRedactedEvidenceReference,
        redactedReferenceSummary: String = Self.requiredRedactedReferenceSummary,
        secretValueRead: Bool = false,
        rawCredentialMaterialPresent: Bool = false,
        endpointConnectionOpened: Bool = false,
        auditTrailAppendOnly: Bool = true
    ) throws {
        let resolvedID = auditEvidenceID ?? Self.deterministicID(
            state: state,
            failureClass: failureClass,
            profileID: profileID,
            namespaceKey: namespaceKey
        )
        try Self.validate(
            state: state,
            failureClass: failureClass,
            profileID: profileID,
            namespaceKey: namespaceKey,
            redactedEvidenceReference: redactedEvidenceReference,
            redactedReferenceSummary: redactedReferenceSummary,
            secretValueRead: secretValueRead,
            rawCredentialMaterialPresent: rawCredentialMaterialPresent,
            endpointConnectionOpened: endpointConnectionOpened,
            auditTrailAppendOnly: auditTrailAppendOnly
        )
        self.auditEvidenceID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.profileID = profileID
        self.namespaceKey = namespaceKey
        self.redactedEvidenceReference = redactedEvidenceReference
        self.redactedReferenceSummary = redactedReferenceSummary
        self.secretValueRead = secretValueRead
        self.rawCredentialMaterialPresent = rawCredentialMaterialPresent
        self.endpointConnectionOpened = endpointConnectionOpened
        self.auditTrailAppendOnly = auditTrailAppendOnly
    }

    public static func presentFixture() throws -> ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence {
        try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence(state: .referencePresent)
    }

    public static func missingFixture() throws -> ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence {
        try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence(
            state: .missingReference,
            failureClass: .requiredReferenceMissing,
            redactedReferenceSummary: "credential-reference=<redacted>; state=missing; action=fail-closed"
        )
    }

    public static func invalidFixture() throws -> ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence {
        try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence(
            state: .invalidReference,
            failureClass: .namespaceMismatch,
            redactedReferenceSummary: "credential-reference=<redacted>; state=invalid; action=fail-closed"
        )
    }

    public static let requiredProfileID = "binance-spot-productionShadow-credential-profile-ref"
    public static let requiredRedactedEvidenceReference = "redacted-credential-profile:binance:spot:productionShadow"
    public static let requiredRedactedReferenceSummary =
        "credential-reference=<redacted>; state=present; action=identity-only"

    public static var requiredNamespaceKey: String {
        do {
            let entry = try ReleaseV0190VenueCredentialProfileRegistry.entry(
                venueID: .binance,
                productKind: .spot,
                tradingEnvironment: .productionShadow
            )
            return entry.namespaceKey
        } catch {
            preconditionFailure("GH-1242 deterministic credential namespace must be constructible: \(error)")
        }
    }

    public static func deterministicID(
        state: ReleaseV0200ProductionShadowCredentialReferenceState,
        failureClass: ReleaseV0200ProductionShadowCredentialReferenceFailureClass?,
        profileID: String,
        namespaceKey: String
    ) -> Identifier {
        .constant(
            [
                "gh-1242-v0200-credential-reference-audit",
                state.rawValue,
                failureClass?.rawValue ?? "none",
                profileID,
                namespaceKey
            ].joined(separator: ":"),
            field: "releaseV0200.credentialReference.auditEvidenceID"
        )
    }
}

private extension ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence {
    static func validate(
        state: ReleaseV0200ProductionShadowCredentialReferenceState,
        failureClass: ReleaseV0200ProductionShadowCredentialReferenceFailureClass?,
        profileID: String,
        namespaceKey: String,
        redactedEvidenceReference: String,
        redactedReferenceSummary: String,
        secretValueRead: Bool,
        rawCredentialMaterialPresent: Bool,
        endpointConnectionOpened: Bool,
        auditTrailAppendOnly: Bool
    ) throws {
        let credentialEntry = try ReleaseV0190VenueCredentialProfileRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("profileID", profileID == credentialEntry.profileID.rawValue, credentialEntry.profileID.rawValue, profileID),
            ("namespaceKey", namespaceKey == credentialEntry.namespaceKey, credentialEntry.namespaceKey, namespaceKey),
            (
                "redactedEvidenceReference",
                redactedEvidenceReference == credentialEntry.redactedEvidenceReference,
                credentialEntry.redactedEvidenceReference,
                redactedEvidenceReference
            )
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceAudit.\(field)",
                expected: expected,
                actual: actual
            )
        }
        switch (state, failureClass) {
        case (.referencePresent, nil):
            break
        case (.referencePresent, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceAudit.failureClass",
                expected: "nil when reference is present",
                actual: failureClass.rawValue
            )
        case (.missingReference, .requiredReferenceMissing?),
             (.invalidReference, .namespaceMismatch?):
            break
        case (.missingReference, nil), (.invalidReference, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceAudit.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (.missingReference, .some(let failureClass)), (.invalidReference, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceAudit.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }
        guard isRedactedSummary(redactedReferenceSummary) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.credentialReferenceAudit.unredactedSummary"
            )
        }
        for (field, value) in [
            ("secretValueRead", secretValueRead),
            ("rawCredentialMaterialPresent", rawCredentialMaterialPresent),
            ("endpointConnectionOpened", endpointConnectionOpened)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.credentialReferenceAudit.\(field)"
            )
        }
        guard auditTrailAppendOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceAudit.auditTrail",
                expected: "append-only audit evidence",
                actual: "auditTrailAppendOnly=false"
            )
        }
    }

    static func isRedactedSummary(_ summary: String) -> Bool {
        summary.contains("<redacted>")
            && summary.contains("credential-reference=")
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
    }
}

/// ReleaseV0200ProductionShadowCredentialReferenceReadiness 是 GH-1242 的 credential reference readiness evidence。
///
/// Readiness 绑定 #1241 endpoint allowlist 和 v0.19.0 credential profile registry，只证明 Binance Spot
/// production-shadow credential reference 可以被 identity-only 识别，缺失或无效 reference 会 fail closed 并留下
/// 脱敏审计证据。它不读取 production secret value、不保存 raw credential、不连接 endpoint / broker、不实现
/// signed account / private stream runtime、不发送订单，也不创建 tag 或授权 production cutover。
public struct ReleaseV0200ProductionShadowCredentialReferenceReadiness: Codable, Equatable, Sendable {
    public let readinessID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamEndpointAllowlistHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let credentialProfileID: String
    public let credentialProfileState: ReleaseV0190VenueCredentialProfileState
    public let credentialNamespaceKey: String
    public let credentialRedactedEvidenceReference: String
    public let presentCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
    public let missingCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
    public let invalidCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
    public let requirements: [ReleaseV0200ProductionShadowCredentialReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowCredentialForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let rawCredentialMaterialStored: Bool
    public let secretProviderAutoReadEnabled: Bool
    public let apiKeyLogged: Bool
    public let secretKeyLogged: Bool
    public let listenKeyLogged: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let signedAccountEndpointRuntimeEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var readinessHeld: Bool {
        issueID.rawValue == "GH-1242"
            && upstreamIssueID.rawValue == "GH-1241"
            && downstreamIssueID.rawValue == "GH-1243"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamEndpointAllowlistHeld
            && namespaceHeld
            && credentialReferenceHeld
            && presentCredentialEvidence.evidenceHeld
            && missingCredentialEvidence.failClosedEvidenceHeld
            && invalidCredentialEvidence.failClosedEvidenceHeld
            && requirements == ReleaseV0200ProductionShadowCredentialReadinessRequirement.allCases
            && forbiddenCapabilities == ReleaseV0200ProductionShadowCredentialForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionShadow
    }

    public var credentialReferenceHeld: Bool {
        credentialProfileID == ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredProfileID
            && credentialProfileState == .productionShadow
            && credentialNamespaceKey == ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredNamespaceKey
            && credentialRedactedEvidenceReference
                == ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredRedactedEvidenceReference
    }

    public var auditableFailureHeld: Bool {
        missingCredentialEvidence.state == .missingReference
            && missingCredentialEvidence.failureClass == .requiredReferenceMissing
            && invalidCredentialEvidence.state == .invalidReference
            && invalidCredentialEvidence.failureClass == .namespaceMismatch
            && missingCredentialEvidence.failClosedEvidenceHeld
            && invalidCredentialEvidence.failClosedEvidenceHeld
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && rawCredentialMaterialStored == false
            && secretProviderAutoReadEnabled == false
            && apiKeyLogged == false
            && secretKeyLogged == false
            && listenKeyLogged == false
            && productionEndpointConnectionEnabled == false
            && signedAccountEndpointRuntimeEnabled == false
            && privateStreamRuntimeEnabled == false
            && productionBrokerConnectionEnabled == false
            && orderSubmitCancelReplaceEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        readinessID: Identifier = Identifier.constant("gh-1242-release-v0.20.0-binance-spot-production-shadow-credential-reference-readiness"),
        issueID: Identifier = Identifier.constant("GH-1242"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1241"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1243"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamEndpointAllowlistHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionShadow,
        credentialProfileID: String = ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredProfileID,
        credentialProfileState: ReleaseV0190VenueCredentialProfileState = .productionShadow,
        credentialNamespaceKey: String = ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredNamespaceKey,
        credentialRedactedEvidenceReference: String =
            ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.requiredRedactedEvidenceReference,
        presentCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence? = nil,
        missingCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence? = nil,
        invalidCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence? = nil,
        requirements: [ReleaseV0200ProductionShadowCredentialReadinessRequirement] =
            ReleaseV0200ProductionShadowCredentialReadinessRequirement.allCases,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowCredentialForbiddenCapability] =
            ReleaseV0200ProductionShadowCredentialForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        rawCredentialMaterialStored: Bool = false,
        secretProviderAutoReadEnabled: Bool = false,
        apiKeyLogged: Bool = false,
        secretKeyLogged: Bool = false,
        listenKeyLogged: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        signedAccountEndpointRuntimeEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedPresentEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
        if let presentCredentialEvidence {
            resolvedPresentEvidence = presentCredentialEvidence
        } else {
            resolvedPresentEvidence = try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.presentFixture()
        }
        let resolvedMissingEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
        if let missingCredentialEvidence {
            resolvedMissingEvidence = missingCredentialEvidence
        } else {
            resolvedMissingEvidence = try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.missingFixture()
        }
        let resolvedInvalidEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
        if let invalidCredentialEvidence {
            resolvedInvalidEvidence = invalidCredentialEvidence
        } else {
            resolvedInvalidEvidence = try ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence.invalidFixture()
        }
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
            credentialProfileID: credentialProfileID,
            credentialProfileState: credentialProfileState,
            credentialNamespaceKey: credentialNamespaceKey,
            credentialRedactedEvidenceReference: credentialRedactedEvidenceReference,
            presentCredentialEvidence: resolvedPresentEvidence,
            missingCredentialEvidence: resolvedMissingEvidence,
            invalidCredentialEvidence: resolvedInvalidEvidence,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrue(upstreamEndpointAllowlistHeld: upstreamEndpointAllowlistHeld)
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            rawCredentialMaterialStored: rawCredentialMaterialStored,
            secretProviderAutoReadEnabled: secretProviderAutoReadEnabled,
            apiKeyLogged: apiKeyLogged,
            secretKeyLogged: secretKeyLogged,
            listenKeyLogged: listenKeyLogged,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            signedAccountEndpointRuntimeEnabled: signedAccountEndpointRuntimeEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.readinessID = readinessID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamEndpointAllowlistHeld = upstreamEndpointAllowlistHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.credentialProfileID = credentialProfileID
        self.credentialProfileState = credentialProfileState
        self.credentialNamespaceKey = credentialNamespaceKey
        self.credentialRedactedEvidenceReference = credentialRedactedEvidenceReference
        self.presentCredentialEvidence = resolvedPresentEvidence
        self.missingCredentialEvidence = resolvedMissingEvidence
        self.invalidCredentialEvidence = resolvedInvalidEvidence
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.rawCredentialMaterialStored = rawCredentialMaterialStored
        self.secretProviderAutoReadEnabled = secretProviderAutoReadEnabled
        self.apiKeyLogged = apiKeyLogged
        self.secretKeyLogged = secretKeyLogged
        self.listenKeyLogged = listenKeyLogged
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.signedAccountEndpointRuntimeEnabled = signedAccountEndpointRuntimeEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowCredentialReferenceReadiness {
        _ = try ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist.deterministicFixture()
        return try ReleaseV0200ProductionShadowCredentialReferenceReadiness()
    }

    public static let requiredValidationAnchors = [
        "GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS",
        "TVM-RELEASE-V0200-CREDENTIAL-REFERENCE-READINESS",
        "V0200-004-BINANCE-SPOT-PRODUCTION-SHADOW-CREDENTIAL-READINESS",
        "V0200-004-CREDENTIAL-IDENTITY-ONLY",
        "V0200-004-MISSING-REFERENCE-FAILS-CLOSED",
        "V0200-004-REDACTED-AUDIT-EVIDENCE",
        "V0200-004-NO-SECRET-VALUE-READ",
        "V0200-004-NO-ENDPOINT-CONNECTION",
        "V0200-004-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1242ReleaseV0200CredentialReferenceReadiness",
        "bash checks/verify-v0.20.0-credential-reference-readiness.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowCredentialReferenceReadiness {
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
        credentialProfileID: String,
        credentialProfileState: ReleaseV0190VenueCredentialProfileState,
        credentialNamespaceKey: String,
        credentialRedactedEvidenceReference: String,
        presentCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence,
        missingCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence,
        invalidCredentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence,
        requirements: [ReleaseV0200ProductionShadowCredentialReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowCredentialForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let entry = try ReleaseV0190VenueCredentialProfileRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1242", "GH-1242", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1241", "GH-1241", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1243", "GH-1243", downstreamIssueID.rawValue),
            (
                "canonicalQueueRange",
                canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                canonicalQueueRange
            ),
            (
                "projectName",
                projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.20.0", "v0.20.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            (
                "tradingEnvironment",
                tradingEnvironment == .productionShadow,
                ReleaseV0181TradingEnvironment.productionShadow.rawValue,
                tradingEnvironment.rawValue
            ),
            ("credentialProfileID", credentialProfileID == entry.profileID.rawValue, entry.profileID.rawValue, credentialProfileID),
            (
                "credentialProfileState",
                credentialProfileState == .productionShadow,
                ReleaseV0190VenueCredentialProfileState.productionShadow.rawValue,
                credentialProfileState.rawValue
            ),
            ("credentialNamespaceKey", credentialNamespaceKey == entry.namespaceKey, entry.namespaceKey, credentialNamespaceKey),
            (
                "credentialRedactedEvidenceReference",
                credentialRedactedEvidenceReference == entry.redactedEvidenceReference,
                entry.redactedEvidenceReference,
                credentialRedactedEvidenceReference
            ),
            (
                "presentCredentialEvidence",
                presentCredentialEvidence.evidenceHeld,
                "present identity-only evidence",
                presentCredentialEvidence.state.rawValue
            ),
            (
                "missingCredentialEvidence",
                missingCredentialEvidence.failClosedEvidenceHeld,
                "missing reference fail-closed evidence",
                missingCredentialEvidence.state.rawValue
            ),
            (
                "invalidCredentialEvidence",
                invalidCredentialEvidence.failClosedEvidenceHeld,
                "invalid reference fail-closed evidence",
                invalidCredentialEvidence.state.rawValue
            ),
            (
                "requirements",
                requirements == ReleaseV0200ProductionShadowCredentialReadinessRequirement.allCases,
                String(describing: ReleaseV0200ProductionShadowCredentialReadinessRequirement.allCases),
                String(describing: requirements)
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ReleaseV0200ProductionShadowCredentialForbiddenCapability.allCases,
                String(describing: ReleaseV0200ProductionShadowCredentialForbiddenCapability.allCases),
                String(describing: forbiddenCapabilities)
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

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceReadiness.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrue(upstreamEndpointAllowlistHeld: Bool) throws {
        guard upstreamEndpointAllowlistHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.credentialReferenceReadiness.upstreamEndpointAllowlistHeld",
                expected: "GH-1241 endpoint allowlist held",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        rawCredentialMaterialStored: Bool,
        secretProviderAutoReadEnabled: Bool,
        apiKeyLogged: Bool,
        secretKeyLogged: Bool,
        listenKeyLogged: Bool,
        productionEndpointConnectionEnabled: Bool,
        signedAccountEndpointRuntimeEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("rawCredentialMaterialStored", rawCredentialMaterialStored),
            ("secretProviderAutoReadEnabled", secretProviderAutoReadEnabled),
            ("apiKeyLogged", apiKeyLogged),
            ("secretKeyLogged", secretKeyLogged),
            ("listenKeyLogged", listenKeyLogged),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("signedAccountEndpointRuntimeEnabled", signedAccountEndpointRuntimeEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.credentialReferenceReadiness.\(field)"
            )
        }
    }
}
