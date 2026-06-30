import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowSignedAccountReadinessState 描述 GH-1244 signed account read-only readiness 的本地状态。
///
/// 这些状态只用于表达未来只读 account snapshot 的 contract readiness。它们不生成 signature、
/// 不读取 production secret、不触达 `/api/v3/account`，也不授权 submit / cancel / replace。
public enum ReleaseV0200ProductionShadowSignedAccountReadinessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractReady = "contract-ready"
    case credentialReferenceMissing = "credential-reference-missing"
    case credentialReferenceInvalid = "credential-reference-invalid"
    case secretValueAccessBlocked = "secret-value-access-blocked"
    case accountPayloadAccessBlocked = "account-payload-access-blocked"
}

/// ReleaseV0200ProductionShadowSignedAccountFailureClass 固定 GH-1244 的 fail-closed 分类。
public enum ReleaseV0200ProductionShadowSignedAccountFailureClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case requiredCredentialReferenceMissing = "required credential reference missing"
    case credentialNamespaceMismatch = "credential namespace mismatch"
    case secretValueAccessAttempted = "secret value access attempted"
    case accountPayloadAccessAttempted = "account payload access attempted"
}

/// ReleaseV0200ProductionShadowSignedAccountReadinessRequirement 固定 #1244 的验收要求。
public enum ReleaseV0200ProductionShadowSignedAccountReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamCredentialReferenceReadinessHeld = "upstream credential reference readiness held"
    case upstreamPublicMarketProbeHeld = "upstream public market read-only probe held"
    case binanceSpotProductionShadowOnly = "Binance Spot production-shadow only"
    case signedAccountReadOnlyIntentRecorded = "signed account read-only intent recorded"
    case credentialReferenceRequired = "credential reference required"
    case missingCredentialFailsClosed = "missing credential reference fails closed"
    case invalidCredentialFailsClosed = "invalid credential reference fails closed"
    case redactedEvidenceRequired = "redacted evidence required"
    case noSecretValueRead = "no secret value read"
    case noRawAccountPayloadStored = "no raw account payload stored"
    case orderEndpointsForbidden = "order endpoints forbidden"
    case noEndpointConnection = "no endpoint connection"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0200ProductionShadowSignedAccountForbiddenCapability 枚举 #1244 必须继续拒绝的能力。
public enum ReleaseV0200ProductionShadowSignedAccountForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionSecretValueRead = "production secret value read"
    case rawCredentialMaterialStored = "raw credential material stored"
    case signedRequestMaterialGenerated = "signed request material generated"
    case rawAccountPayloadStored = "raw account payload stored"
    case accountEndpointTouched = "account endpoint touched"
    case orderEndpointTouched = "order endpoint touched"
    case listenKeyRuntime = "listenKey runtime"
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

/// ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent 表达 `/api/v3/account` 的未来只读意图。
///
/// Intent 只保存 endpoint path 和 redacted contract summary。它不携带 timestamp、recvWindow、
/// signature、API key、secret value、listenKey、account payload 或 order payload。
public struct ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent: Codable, Equatable, Sendable {
    public let intentID: Identifier
    public let endpointFamilyReference: String
    public let path: String
    public let method: String
    public let redactedIntentSummary: String
    public let signingMaterialGenerated: Bool
    public let secretValueRead: Bool
    public let endpointConnectionOpened: Bool
    public let accountPayloadAccessed: Bool
    public let orderEndpointTouched: Bool

    public var intentHeld: Bool {
        endpointFamilyReference == Self.requiredEndpointFamilyReference
            && path == Self.requiredAccountPath
            && method == "GET"
            && Self.isRedactedIntentSummary(redactedIntentSummary)
            && signingMaterialGenerated == false
            && secretValueRead == false
            && endpointConnectionOpened == false
            && accountPayloadAccessed == false
            && orderEndpointTouched == false
    }

    public init(
        intentID: Identifier = Identifier.constant("gh-1244-v0200-signed-account-readonly-intent"),
        endpointFamilyReference: String = Self.requiredEndpointFamilyReference,
        path: String = Self.requiredAccountPath,
        method: String = "GET",
        redactedIntentSummary: String = Self.requiredRedactedIntentSummary,
        signingMaterialGenerated: Bool = false,
        secretValueRead: Bool = false,
        endpointConnectionOpened: Bool = false,
        accountPayloadAccessed: Bool = false,
        orderEndpointTouched: Bool = false
    ) throws {
        try Self.validate(
            endpointFamilyReference: endpointFamilyReference,
            path: path,
            method: method,
            redactedIntentSummary: redactedIntentSummary,
            signingMaterialGenerated: signingMaterialGenerated,
            secretValueRead: secretValueRead,
            endpointConnectionOpened: endpointConnectionOpened,
            accountPayloadAccessed: accountPayloadAccessed,
            orderEndpointTouched: orderEndpointTouched
        )
        self.intentID = intentID
        self.endpointFamilyReference = endpointFamilyReference
        self.path = path
        self.method = method
        self.redactedIntentSummary = redactedIntentSummary
        self.signingMaterialGenerated = signingMaterialGenerated
        self.secretValueRead = secretValueRead
        self.endpointConnectionOpened = endpointConnectionOpened
        self.accountPayloadAccessed = accountPayloadAccessed
        self.orderEndpointTouched = orderEndpointTouched
    }

    public static let requiredEndpointFamilyReference = "https://api.binance.com"
    public static let requiredAccountPath = "/api/v3/account"
    public static let requiredRedactedIntentSummary =
        "signed-account-readiness=<redacted>; endpoint=/api/v3/account; mode=read-only; payload=<not-accessed>"
}

private extension ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent {
    static func validate(
        endpointFamilyReference: String,
        path: String,
        method: String,
        redactedIntentSummary: String,
        signingMaterialGenerated: Bool,
        secretValueRead: Bool,
        endpointConnectionOpened: Bool,
        accountPayloadAccessed: Bool,
        orderEndpointTouched: Bool
    ) throws {
        let endpointFamily = try ReleaseV0190VenueEndpointFamilyRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("endpointFamilyReference", endpointFamilyReference == endpointFamily.reference, endpointFamily.reference, endpointFamilyReference),
            ("path", path == requiredAccountPath, requiredAccountPath, path),
            ("method", method == "GET", "GET", method)
        ]
        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.intent.\(field)",
                expected: expected,
                actual: actual
            )
        }
        guard isRedactedIntentSummary(redactedIntentSummary) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.signedAccountReadiness.intent.unredactedSummary"
            )
        }
        for (field, value) in [
            ("signingMaterialGenerated", signingMaterialGenerated),
            ("secretValueRead", secretValueRead),
            ("endpointConnectionOpened", endpointConnectionOpened),
            ("accountPayloadAccessed", accountPayloadAccessed),
            ("orderEndpointTouched", orderEndpointTouched)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.signedAccountReadiness.intent.\(field)"
            )
        }
    }

    static func isRedactedIntentSummary(_ summary: String) -> Bool {
        summary.contains("signed-account-readiness=<redacted>")
            && summary.contains("endpoint=/api/v3/account")
            && summary.contains("mode=read-only")
            && summary.contains("payload=<not-accessed>")
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
            && summary.localizedCaseInsensitiveContains("order payload") == false
    }
}

/// ReleaseV0200ProductionShadowSignedAccountReadinessEvidence 表达 signed account read-only readiness 的脱敏证据。
///
/// Evidence 只绑定 credential reference 和 account read-only intent。它不能保存 secret value、
/// signed request material、raw account payload，也不能证明真实 endpoint 已被触达。
public struct ReleaseV0200ProductionShadowSignedAccountReadinessEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let state: ReleaseV0200ProductionShadowSignedAccountReadinessState
    public let failureClass: ReleaseV0200ProductionShadowSignedAccountFailureClass?
    public let credentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence
    public let accountIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent
    public let redactedEvidenceSummary: String
    public let secretValueRead: Bool
    public let rawAccountPayloadStored: Bool
    public let signedRequestMaterialGenerated: Bool
    public let accountEndpointTouched: Bool
    public let orderEndpointTouched: Bool

    public var readinessEvidenceHeld: Bool {
        state == .contractReady
            && failureClass == nil
            && credentialEvidence.evidenceHeld
            && accountIntent.intentHeld
            && Self.isRedactedEvidenceSummary(redactedEvidenceSummary, state: state)
            && forbiddenBoundaryHeld
    }

    public var failClosedEvidenceHeld: Bool {
        state != .contractReady
            && failureClass != nil
            && credentialEvidence.failClosedEvidenceHeld
            && accountIntent.intentHeld
            && Self.isRedactedEvidenceSummary(redactedEvidenceSummary, state: state)
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        secretValueRead == false
            && rawAccountPayloadStored == false
            && signedRequestMaterialGenerated == false
            && accountEndpointTouched == false
            && orderEndpointTouched == false
    }

    public init(
        evidenceID: Identifier? = nil,
        state: ReleaseV0200ProductionShadowSignedAccountReadinessState,
        failureClass: ReleaseV0200ProductionShadowSignedAccountFailureClass? = nil,
        credentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence,
        accountIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent? = nil,
        redactedEvidenceSummary: String? = nil,
        secretValueRead: Bool = false,
        rawAccountPayloadStored: Bool = false,
        signedRequestMaterialGenerated: Bool = false,
        accountEndpointTouched: Bool = false,
        orderEndpointTouched: Bool = false
    ) throws {
        let resolvedIntent = try accountIntent ?? ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent()
        let resolvedSummary = redactedEvidenceSummary ?? Self.defaultRedactedEvidenceSummary(state: state)
        let resolvedID = evidenceID ?? Self.deterministicID(state: state, failureClass: failureClass)
        try Self.validate(
            state: state,
            failureClass: failureClass,
            credentialEvidence: credentialEvidence,
            accountIntent: resolvedIntent,
            redactedEvidenceSummary: resolvedSummary,
            secretValueRead: secretValueRead,
            rawAccountPayloadStored: rawAccountPayloadStored,
            signedRequestMaterialGenerated: signedRequestMaterialGenerated,
            accountEndpointTouched: accountEndpointTouched,
            orderEndpointTouched: orderEndpointTouched
        )
        self.evidenceID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.credentialEvidence = credentialEvidence
        self.accountIntent = resolvedIntent
        self.redactedEvidenceSummary = resolvedSummary
        self.secretValueRead = secretValueRead
        self.rawAccountPayloadStored = rawAccountPayloadStored
        self.signedRequestMaterialGenerated = signedRequestMaterialGenerated
        self.accountEndpointTouched = accountEndpointTouched
        self.orderEndpointTouched = orderEndpointTouched
    }

    public static func contractReadyFixture() throws -> ReleaseV0200ProductionShadowSignedAccountReadinessEvidence {
        try ReleaseV0200ProductionShadowSignedAccountReadinessEvidence(
            state: .contractReady,
            credentialEvidence: .presentFixture()
        )
    }

    public static func missingCredentialFixture() throws -> ReleaseV0200ProductionShadowSignedAccountReadinessEvidence {
        try ReleaseV0200ProductionShadowSignedAccountReadinessEvidence(
            state: .credentialReferenceMissing,
            failureClass: .requiredCredentialReferenceMissing,
            credentialEvidence: .missingFixture()
        )
    }

    public static func invalidCredentialFixture() throws -> ReleaseV0200ProductionShadowSignedAccountReadinessEvidence {
        try ReleaseV0200ProductionShadowSignedAccountReadinessEvidence(
            state: .credentialReferenceInvalid,
            failureClass: .credentialNamespaceMismatch,
            credentialEvidence: .invalidFixture()
        )
    }

    public static let requiredSummaryPrefix = "signed-account-readiness=<redacted>"
    public static let requiredPayloadMarker = "account-payload=<not-accessed>"
    public static let requiredSigningMarker = "signed-material=<not-generated>"

    public static func deterministicID(
        state: ReleaseV0200ProductionShadowSignedAccountReadinessState,
        failureClass: ReleaseV0200ProductionShadowSignedAccountFailureClass?
    ) -> Identifier {
        .constant(
            [
                "gh-1244-v0200-signed-account-readonly-evidence",
                state.rawValue,
                failureClass?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0200.signedAccountReadiness.evidenceID"
        )
    }
}

private extension ReleaseV0200ProductionShadowSignedAccountReadinessEvidence {
    static func validate(
        state: ReleaseV0200ProductionShadowSignedAccountReadinessState,
        failureClass: ReleaseV0200ProductionShadowSignedAccountFailureClass?,
        credentialEvidence: ReleaseV0200ProductionShadowCredentialReferenceAuditEvidence,
        accountIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent,
        redactedEvidenceSummary: String,
        secretValueRead: Bool,
        rawAccountPayloadStored: Bool,
        signedRequestMaterialGenerated: Bool,
        accountEndpointTouched: Bool,
        orderEndpointTouched: Bool
    ) throws {
        guard accountIntent.intentHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.accountIntent",
                expected: "read-only signed account intent without endpoint touch",
                actual: accountIntent.path
            )
        }
        switch (state, failureClass) {
        case (.contractReady, nil):
            guard credentialEvidence.evidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0200.signedAccountReadiness.credentialEvidence",
                    expected: "present redacted credential reference evidence",
                    actual: credentialEvidence.state.rawValue
                )
            }
        case (.contractReady, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.failureClass",
                expected: "nil when contract is ready",
                actual: failureClass.rawValue
            )
        case (.credentialReferenceMissing, .requiredCredentialReferenceMissing?):
            guard credentialEvidence.failClosedEvidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0200.signedAccountReadiness.credentialEvidence",
                    expected: "missing credential fail-closed evidence",
                    actual: credentialEvidence.state.rawValue
                )
            }
        case (.credentialReferenceInvalid, .credentialNamespaceMismatch?):
            guard credentialEvidence.failClosedEvidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0200.signedAccountReadiness.credentialEvidence",
                    expected: "invalid credential fail-closed evidence",
                    actual: credentialEvidence.state.rawValue
                )
            }
        case (.secretValueAccessBlocked, .secretValueAccessAttempted?),
             (.accountPayloadAccessBlocked, .accountPayloadAccessAttempted?):
            guard credentialEvidence.failClosedEvidenceHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0200.signedAccountReadiness.credentialEvidence",
                    expected: "fail-closed credential evidence for blocked access",
                    actual: credentialEvidence.state.rawValue
                )
            }
        case (_, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (_, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }
        guard isRedactedEvidenceSummary(redactedEvidenceSummary, state: state) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.signedAccountReadiness.unredactedEvidenceSummary"
            )
        }
        for (field, value) in [
            ("secretValueRead", secretValueRead),
            ("rawAccountPayloadStored", rawAccountPayloadStored),
            ("signedRequestMaterialGenerated", signedRequestMaterialGenerated),
            ("accountEndpointTouched", accountEndpointTouched),
            ("orderEndpointTouched", orderEndpointTouched)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.signedAccountReadiness.\(field)"
            )
        }
    }

    static func defaultRedactedEvidenceSummary(
        state: ReleaseV0200ProductionShadowSignedAccountReadinessState
    ) -> String {
        "\(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredSummaryPrefix); state=\(state.rawValue); \(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredPayloadMarker); \(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredSigningMarker)"
    }

    static func isRedactedEvidenceSummary(
        _ summary: String,
        state: ReleaseV0200ProductionShadowSignedAccountReadinessState
    ) -> Bool {
        summary.contains(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredSummaryPrefix)
            && summary.contains("state=\(state.rawValue)")
            && summary.contains(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredPayloadMarker)
            && summary.contains(ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.requiredSigningMarker)
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
            && summary.localizedCaseInsensitiveContains("raw payload") == false
    }
}

/// ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness 是 GH-1244 的 signed account read-only readiness contract。
///
/// Contract 绑定 #1242 credential reference readiness 和 #1243 public market probe。它只证明
/// Binance Spot production-shadow signed account read-only readiness 的本地合同、脱敏 evidence 和 fail-closed
/// 行为已经固定；它不读取 production secret value、不生成 signed request、不触达 `/api/v3/account`、
/// 不保存 account payload、不触达 order endpoint，也不创建 tag 或授权 production cutover。
public struct ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness: Codable, Equatable, Sendable {
    public let readinessID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamCredentialReferenceReadinessHeld: Bool
    public let upstreamPublicMarketProbeHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let endpointFamilyReference: String
    public let accountReadOnlyIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent
    public let readyEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence
    public let missingCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence
    public let invalidCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence
    public let requirements: [ReleaseV0200ProductionShadowSignedAccountReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowSignedAccountForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let rawCredentialMaterialStored: Bool
    public let signedRequestMaterialGenerated: Bool
    public let rawAccountPayloadStored: Bool
    public let accountEndpointTouched: Bool
    public let orderEndpointTouched: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
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
        issueID.rawValue == "GH-1244"
            && upstreamIssueID.rawValue == "GH-1243"
            && downstreamIssueID.rawValue == "GH-1245"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamCredentialReferenceReadinessHeld
            && upstreamPublicMarketProbeHeld
            && namespaceHeld
            && endpointFamilyReference == ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent.requiredEndpointFamilyReference
            && accountReadOnlyIntent.intentHeld
            && readyEvidence.readinessEvidenceHeld
            && missingCredentialEvidence.failClosedEvidenceHeld
            && invalidCredentialEvidence.failClosedEvidenceHeld
            && requirements == ReleaseV0200ProductionShadowSignedAccountReadinessRequirement.allCases
            && forbiddenCapabilities == ReleaseV0200ProductionShadowSignedAccountForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionShadow
    }

    public var failClosedEvidenceHeld: Bool {
        missingCredentialEvidence.state == .credentialReferenceMissing
            && missingCredentialEvidence.failureClass == .requiredCredentialReferenceMissing
            && invalidCredentialEvidence.state == .credentialReferenceInvalid
            && invalidCredentialEvidence.failureClass == .credentialNamespaceMismatch
            && missingCredentialEvidence.failClosedEvidenceHeld
            && invalidCredentialEvidence.failClosedEvidenceHeld
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && rawCredentialMaterialStored == false
            && signedRequestMaterialGenerated == false
            && rawAccountPayloadStored == false
            && accountEndpointTouched == false
            && orderEndpointTouched == false
            && listenKeyRuntimeEnabled == false
            && privateStreamRuntimeEnabled == false
            && productionEndpointConnectionEnabled == false
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
        readinessID: Identifier = Identifier.constant("gh-1244-release-v0.20.0-binance-spot-production-shadow-signed-account-readonly-readiness"),
        issueID: Identifier = Identifier.constant("GH-1244"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1243"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1245"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamCredentialReferenceReadinessHeld: Bool = true,
        upstreamPublicMarketProbeHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionShadow,
        endpointFamilyReference: String = ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent.requiredEndpointFamilyReference,
        accountReadOnlyIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent? = nil,
        readyEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence? = nil,
        missingCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence? = nil,
        invalidCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence? = nil,
        requirements: [ReleaseV0200ProductionShadowSignedAccountReadinessRequirement] =
            ReleaseV0200ProductionShadowSignedAccountReadinessRequirement.allCases,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowSignedAccountForbiddenCapability] =
            ReleaseV0200ProductionShadowSignedAccountForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        rawCredentialMaterialStored: Bool = false,
        signedRequestMaterialGenerated: Bool = false,
        rawAccountPayloadStored: Bool = false,
        accountEndpointTouched: Bool = false,
        orderEndpointTouched: Bool = false,
        listenKeyRuntimeEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
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
        let resolvedIntent = try accountReadOnlyIntent ?? ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent()
        let resolvedReadyEvidence = try readyEvidence ?? ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.contractReadyFixture()
        let resolvedMissingEvidence = try missingCredentialEvidence
            ?? ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.missingCredentialFixture()
        let resolvedInvalidEvidence = try invalidCredentialEvidence
            ?? ReleaseV0200ProductionShadowSignedAccountReadinessEvidence.invalidCredentialFixture()
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
            endpointFamilyReference: endpointFamilyReference,
            accountReadOnlyIntent: resolvedIntent,
            readyEvidence: resolvedReadyEvidence,
            missingCredentialEvidence: resolvedMissingEvidence,
            invalidCredentialEvidence: resolvedInvalidEvidence,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrue(
            upstreamCredentialReferenceReadinessHeld: upstreamCredentialReferenceReadinessHeld,
            upstreamPublicMarketProbeHeld: upstreamPublicMarketProbeHeld
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            rawCredentialMaterialStored: rawCredentialMaterialStored,
            signedRequestMaterialGenerated: signedRequestMaterialGenerated,
            rawAccountPayloadStored: rawAccountPayloadStored,
            accountEndpointTouched: accountEndpointTouched,
            orderEndpointTouched: orderEndpointTouched,
            listenKeyRuntimeEnabled: listenKeyRuntimeEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
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
        self.upstreamCredentialReferenceReadinessHeld = upstreamCredentialReferenceReadinessHeld
        self.upstreamPublicMarketProbeHeld = upstreamPublicMarketProbeHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.endpointFamilyReference = endpointFamilyReference
        self.accountReadOnlyIntent = resolvedIntent
        self.readyEvidence = resolvedReadyEvidence
        self.missingCredentialEvidence = resolvedMissingEvidence
        self.invalidCredentialEvidence = resolvedInvalidEvidence
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.rawCredentialMaterialStored = rawCredentialMaterialStored
        self.signedRequestMaterialGenerated = signedRequestMaterialGenerated
        self.rawAccountPayloadStored = rawAccountPayloadStored
        self.accountEndpointTouched = accountEndpointTouched
        self.orderEndpointTouched = orderEndpointTouched
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
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

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness {
        _ = try ReleaseV0200ProductionShadowCredentialReferenceReadiness.deterministicFixture()
        _ = try ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe.deterministicFixture()
        return try ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness()
    }

    public static let requiredValidationAnchors = [
        "GH-1244-VERIFY-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS",
        "TVM-RELEASE-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS",
        "V0200-006-BINANCE-SPOT-PRODUCTION-SHADOW-SIGNED-ACCOUNT-READINESS",
        "V0200-006-ACCOUNT-ENDPOINT-INTENT-ONLY",
        "V0200-006-CREDENTIAL-REFERENCE-BOUND",
        "V0200-006-REDACTED-ACCOUNT-PAYLOAD-EVIDENCE",
        "V0200-006-NO-SECRET-VALUE-READ",
        "V0200-006-NO-ORDER-ENDPOINT",
        "V0200-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1244ReleaseV0200SignedAccountReadOnlyReadiness",
        "bash checks/verify-v0.20.0-signed-account-readonly-readiness.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness {
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
        endpointFamilyReference: String,
        accountReadOnlyIntent: ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent,
        readyEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence,
        missingCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence,
        invalidCredentialEvidence: ReleaseV0200ProductionShadowSignedAccountReadinessEvidence,
        requirements: [ReleaseV0200ProductionShadowSignedAccountReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowSignedAccountForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1244", "GH-1244", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1243", "GH-1243", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1245", "GH-1245", downstreamIssueID.rawValue),
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
            (
                "endpointFamilyReference",
                endpointFamilyReference == ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent.requiredEndpointFamilyReference,
                ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent.requiredEndpointFamilyReference,
                endpointFamilyReference
            ),
            ("accountReadOnlyIntent", accountReadOnlyIntent.intentHeld, "read-only account endpoint intent", accountReadOnlyIntent.path),
            ("readyEvidence", readyEvidence.readinessEvidenceHeld, "ready redacted evidence", readyEvidence.state.rawValue),
            (
                "missingCredentialEvidence",
                missingCredentialEvidence.failClosedEvidenceHeld,
                "missing credential fail-closed evidence",
                missingCredentialEvidence.state.rawValue
            ),
            (
                "invalidCredentialEvidence",
                invalidCredentialEvidence.failClosedEvidenceHeld,
                "invalid credential fail-closed evidence",
                invalidCredentialEvidence.state.rawValue
            ),
            (
                "requirements",
                requirements == ReleaseV0200ProductionShadowSignedAccountReadinessRequirement.allCases,
                ReleaseV0200ProductionShadowSignedAccountReadinessRequirement.allCases.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ReleaseV0200ProductionShadowSignedAccountForbiddenCapability.allCases,
                ReleaseV0200ProductionShadowSignedAccountForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == Self.requiredValidationAnchors,
                Self.requiredValidationAnchors.joined(separator: ","),
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
                field: "releaseV0200.signedAccountReadiness.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrue(
        upstreamCredentialReferenceReadinessHeld: Bool,
        upstreamPublicMarketProbeHeld: Bool
    ) throws {
        let checks = [
            ("upstreamCredentialReferenceReadinessHeld", upstreamCredentialReferenceReadinessHeld),
            ("upstreamPublicMarketProbeHeld", upstreamPublicMarketProbeHeld)
        ]
        for (field, value) in checks where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.signedAccountReadiness.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        rawCredentialMaterialStored: Bool,
        signedRequestMaterialGenerated: Bool,
        rawAccountPayloadStored: Bool,
        accountEndpointTouched: Bool,
        orderEndpointTouched: Bool,
        listenKeyRuntimeEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
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
            ("signedRequestMaterialGenerated", signedRequestMaterialGenerated),
            ("rawAccountPayloadStored", rawAccountPayloadStored),
            ("accountEndpointTouched", accountEndpointTouched),
            ("orderEndpointTouched", orderEndpointTouched),
            ("listenKeyRuntimeEnabled", listenKeyRuntimeEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
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
                "releaseV0200.signedAccountReadiness.\(field)"
            )
        }
    }
}
