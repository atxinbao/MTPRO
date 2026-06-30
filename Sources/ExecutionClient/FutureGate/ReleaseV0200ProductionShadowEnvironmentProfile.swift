import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowEnvironmentProfileMode 固定 GH-1240 允许表达的环境 profile 模式。
///
/// 这些模式只描述 Binance Spot production-shadow 的只读 readiness 身份、endpoint 意图和
/// operator 可见状态；它们不是 endpoint connection、secret provider、order path 或 cutover 授权。
public enum ReleaseV0200ProductionShadowEnvironmentProfileMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case explicitProductionShadow = "explicit-production-shadow"
    case binanceSpotOnly = "binance-spot-only"
    case readOnlyReadiness = "read-only-readiness"
    case failClosedByDefault = "fail-closed-by-default"
    case operatorVisibleReadiness = "operator-visible-readiness"
}

/// ReleaseV0200ProductionShadowEndpointIntent 描述 GH-1240 的 endpoint 意图。
///
/// `readOnlyReferencePendingAllowlist` 只表示后续 #1241 可以定义只读 allowlist；当前 issue 不解析
/// endpoint URL、不打开 HTTP/WebSocket connection，也不允许 signed/account endpoint runtime。
public enum ReleaseV0200ProductionShadowEndpointIntent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case readOnlyReferencePendingAllowlist = "read-only-reference-pending-allowlist"
}

/// ReleaseV0200ProductionShadowOperatorReadinessState 是 operator 可见的 profile 状态。
///
/// 状态必须停留在等待 allowlist / credential reference / probe evidence 的 readiness 阶段，不能被解释为
/// production live ready、Spot canary ready 或 trading authorized。
public enum ReleaseV0200ProductionShadowOperatorReadinessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case profileRegisteredAwaitingReadOnlyEvidence = "profile-registered-awaiting-read-only-evidence"
}

/// ReleaseV0200ProductionShadowEnvironmentProfileRequirement 固定 #1240 的验收要求。
public enum ReleaseV0200ProductionShadowEnvironmentProfileRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamReadinessContractHeld = "upstream readiness contract held"
    case binanceSpotOnly = "Binance Spot only"
    case productionShadowEnvironmentOnly = "production-shadow environment only"
    case credentialProfileIdentityReferenceRequired = "credential profile identity reference required"
    case endpointIntentNoConnection = "endpoint intent without connection"
    case operatorVisibleReadinessStateRequired = "operator-visible readiness state required"
    case readOnlyFeatureGatesClosed = "read-only feature gates closed"
    case futuresOutOfScope = "Futures out of scope"
    case okxOutOfScope = "OKX out of scope"
    case productionCutoverDisabled = "production cutover disabled"
}

/// ReleaseV0200ProductionShadowEnvironmentForbiddenCapability 枚举 #1240 仍然拒绝的能力。
public enum ReleaseV0200ProductionShadowEnvironmentForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionLiveEnvironment = "production live environment"
    case nonBinanceVenue = "non-Binance venue"
    case nonSpotProduct = "non-Spot product"
    case productionSecretValueRead = "production secret value read"
    case productionSecretValueStored = "production secret value stored"
    case productionEndpointConnection = "production endpoint connection"
    case signedAccountEndpointRuntime = "signed account endpoint runtime"
    case privateStreamRuntime = "private stream runtime"
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

/// ReleaseV0200ProductionShadowEnvironmentProfile 是 GH-1240 的 Binance Spot production-shadow 环境 profile。
///
/// Profile 复用 v0.18.1 typed namespace 和 v0.19.0 credential profile identity。它只保存环境身份、
/// endpoint intent、feature gate 和 operator-visible readiness state；它不会读取 secret value，
/// 不保存 raw credential，不连接 production endpoint / broker endpoint，不实现 signed account / private stream runtime，
/// 不创建 submit / cancel / replace 能力，也不授权 Spot canary 或 production cutover。
public struct ReleaseV0200ProductionShadowEnvironmentProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamReadinessContractHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let credentialProfileID: String
    public let credentialProfileState: ReleaseV0190VenueCredentialProfileState
    public let credentialRedactedEvidenceReference: String
    public let credentialIdentityOnly: Bool
    public let redactedEvidenceOnly: Bool
    public let profileModes: [ReleaseV0200ProductionShadowEnvironmentProfileMode]
    public let endpointIntent: ReleaseV0200ProductionShadowEndpointIntent
    public let operatorReadinessState: ReleaseV0200ProductionShadowOperatorReadinessState
    public let requirements: [ReleaseV0200ProductionShadowEnvironmentProfileRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowEnvironmentForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionSecretValueStored: Bool
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

    public var profileHeld: Bool {
        issueID.rawValue == "GH-1240"
            && upstreamIssueID.rawValue == "GH-1239"
            && downstreamIssueID.rawValue == "GH-1241"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamReadinessContractHeld
            && namespaceHeld
            && credentialReferenceHeld
            && endpointAndReadinessHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
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
        credentialProfileID == Self.requiredCredentialProfileID
            && credentialProfileState == .productionShadow
            && credentialRedactedEvidenceReference == Self.requiredCredentialRedactedEvidenceReference
            && credentialIdentityOnly
            && redactedEvidenceOnly
    }

    public var endpointAndReadinessHeld: Bool {
        profileModes == Self.requiredProfileModes
            && endpointIntent == Self.requiredEndpointIntent
            && operatorReadinessState == Self.requiredOperatorReadinessState
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionSecretValueStored == false
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
        profileID: Identifier = Identifier.constant("gh-1240-release-v0.20.0-binance-spot-production-shadow-environment-profile"),
        issueID: Identifier = Identifier.constant("GH-1240"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1239"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1241"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamReadinessContractHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionShadow,
        credentialProfileID: String = Self.requiredCredentialProfileID,
        credentialProfileState: ReleaseV0190VenueCredentialProfileState = .productionShadow,
        credentialRedactedEvidenceReference: String = Self.requiredCredentialRedactedEvidenceReference,
        credentialIdentityOnly: Bool = true,
        redactedEvidenceOnly: Bool = true,
        profileModes: [ReleaseV0200ProductionShadowEnvironmentProfileMode] = Self.requiredProfileModes,
        endpointIntent: ReleaseV0200ProductionShadowEndpointIntent = Self.requiredEndpointIntent,
        operatorReadinessState: ReleaseV0200ProductionShadowOperatorReadinessState = Self.requiredOperatorReadinessState,
        requirements: [ReleaseV0200ProductionShadowEnvironmentProfileRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowEnvironmentForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionSecretValueStored: Bool = false,
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
            credentialRedactedEvidenceReference: credentialRedactedEvidenceReference,
            profileModes: profileModes,
            endpointIntent: endpointIntent,
            operatorReadinessState: operatorReadinessState,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamReadinessContractHeld: upstreamReadinessContractHeld,
            credentialIdentityOnly: credentialIdentityOnly,
            redactedEvidenceOnly: redactedEvidenceOnly
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionSecretValueStored: productionSecretValueStored,
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

        self.profileID = profileID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamReadinessContractHeld = upstreamReadinessContractHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.credentialProfileID = credentialProfileID
        self.credentialProfileState = credentialProfileState
        self.credentialRedactedEvidenceReference = credentialRedactedEvidenceReference
        self.credentialIdentityOnly = credentialIdentityOnly
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.profileModes = profileModes
        self.endpointIntent = endpointIntent
        self.operatorReadinessState = operatorReadinessState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionSecretValueStored = productionSecretValueStored
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

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowEnvironmentProfile {
        _ = try ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.deterministicFixture()
        return try ReleaseV0200ProductionShadowEnvironmentProfile()
    }

    public static let requiredCanonicalQueueRange = "GH-1239..GH-1250"
    public static let requiredCredentialProfileID = "binance-spot-productionShadow-credential-profile-ref"
    public static let requiredCredentialRedactedEvidenceReference = "redacted-credential-profile:binance:spot:productionShadow"
    public static let requiredProfileModes = ReleaseV0200ProductionShadowEnvironmentProfileMode.allCases
    public static let requiredEndpointIntent = ReleaseV0200ProductionShadowEndpointIntent.readOnlyReferencePendingAllowlist
    public static let requiredOperatorReadinessState =
        ReleaseV0200ProductionShadowOperatorReadinessState.profileRegisteredAwaitingReadOnlyEvidence
    public static let requiredRequirements = ReleaseV0200ProductionShadowEnvironmentProfileRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0200ProductionShadowEnvironmentForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE",
        "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE",
        "V0200-002-BINANCE-SPOT-PRODUCTION-SHADOW-PROFILE",
        "V0200-002-CREDENTIAL-REFERENCE-NO-SECRET-VALUE",
        "V0200-002-ENDPOINT-INTENT-NO-CONNECTION",
        "V0200-002-OPERATOR-READINESS-STATE",
        "V0200-002-READ-ONLY-FAIL-CLOSED",
        "V0200-002-FUTURES-OKX-OUT-OF-SCOPE",
        "V0200-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1240ReleaseV0200ProductionShadowEnvironmentProfile",
        "bash checks/verify-v0.20.0-production-shadow-environment-profile.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowEnvironmentProfile {
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
        credentialRedactedEvidenceReference: String,
        profileModes: [ReleaseV0200ProductionShadowEnvironmentProfileMode],
        endpointIntent: ReleaseV0200ProductionShadowEndpointIntent,
        operatorReadinessState: ReleaseV0200ProductionShadowOperatorReadinessState,
        requirements: [ReleaseV0200ProductionShadowEnvironmentProfileRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowEnvironmentForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let credentialEntry = try ReleaseV0190VenueCredentialProfileRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1240", "GH-1240", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1239", "GH-1239", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1241", "GH-1241", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
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
                "credentialProfileID",
                credentialProfileID == credentialEntry.profileID.rawValue,
                credentialEntry.profileID.rawValue,
                credentialProfileID
            ),
            (
                "credentialProfileState",
                credentialProfileState == credentialEntry.state,
                credentialEntry.state.rawValue,
                credentialProfileState.rawValue
            ),
            (
                "credentialRedactedEvidenceReference",
                credentialRedactedEvidenceReference == credentialEntry.redactedEvidenceReference,
                credentialEntry.redactedEvidenceReference,
                credentialRedactedEvidenceReference
            ),
            (
                "profileModes",
                profileModes == requiredProfileModes,
                requiredProfileModes.map(\.rawValue).joined(separator: ","),
                profileModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "endpointIntent",
                endpointIntent == requiredEndpointIntent,
                requiredEndpointIntent.rawValue,
                endpointIntent.rawValue
            ),
            (
                "operatorReadinessState",
                operatorReadinessState == requiredOperatorReadinessState,
                requiredOperatorReadinessState.rawValue,
                operatorReadinessState.rawValue
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
        upstreamReadinessContractHeld: Bool,
        credentialIdentityOnly: Bool,
        redactedEvidenceOnly: Bool
    ) throws {
        for (field, value) in [
            ("upstreamReadinessContractHeld", upstreamReadinessContractHeld),
            ("credentialIdentityOnly", credentialIdentityOnly),
            ("redactedEvidenceOnly", redactedEvidenceOnly)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionSecretValueStored: Bool,
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
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionSecretValueStored", productionSecretValueStored),
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
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
