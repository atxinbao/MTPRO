import DomainModel
import Foundation

/// ReleaseV0210SpotCanaryEnvironmentProfileMode 固定 GH-1274 允许表达的
/// Binance Spot canary environment profile 模式。
///
/// 这些模式只描述 production-live 身份、显式 operator opt-in evidence 需求和
/// fail-closed 默认行为；它们不是 secret provider、endpoint connection、signed
/// account runtime、order command 或 production cutover 授权。
public enum ReleaseV0210SpotCanaryEnvironmentProfileMode:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case explicitCanaryEnvironmentIntent = "explicit-canary-environment-intent"
    case binanceSpotOnly = "binance-spot-only"
    case productionLiveIdentityOnly = "production-live-identity-only"
    case defaultOffFailClosed = "default-off-fail-closed"
    case explicitOperatorOptInEvidenceRequired = "explicit-operator-opt-in-evidence-required"
    case noSecretEndpointOrOrderByThisIssue = "no-secret-endpoint-or-order-by-this-issue"
}

/// ReleaseV0210SpotCanaryActivationState 是 GH-1274 的 operator-visible activation 状态。
///
/// 所有状态都必须停留在 fail-closed profile 层。即使后续 Human operator opt-in
/// evidence 已记录，GH-1274 仍不打开 canary activation、endpoint connection 或 order path。
public enum ReleaseV0210SpotCanaryActivationState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case defaultOffAwaitingOperatorOptInEvidence = "default-off-awaiting-operator-opt-in-evidence"
    case blockedMissingOperatorOptInEvidence = "blocked-missing-operator-opt-in-evidence"
    case operatorOptInEvidenceRecordedStillFailClosed = "operator-opt-in-evidence-recorded-still-fail-closed"
}

/// ReleaseV0210SpotCanaryEnvironmentRequirement 固定 GH-1274 的验收要求。
public enum ReleaseV0210SpotCanaryEnvironmentRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamCanaryContractHeld = "upstream canary contract held"
    case binanceSpotOnly = "Binance Spot only"
    case productionLiveIdentityOnly = "production-live identity only"
    case explicitOperatorOptInEvidenceRequired = "explicit operator opt-in evidence required"
    case defaultFailClosed = "default fail-closed"
    case activationRequiresOperatorOptInEvidence = "activation requires operator opt-in evidence"
    case noSecretRead = "no secret read"
    case noEndpointConnection = "no endpoint connection"
    case noOrderSubmission = "no order submission"
    case downstreamCredentialAndPreflightGatesRequired = "downstream credential and preflight gates required"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0210SpotCanaryEnvironmentForbiddenCapability 枚举 GH-1274 仍然拒绝的能力。
public enum ReleaseV0210SpotCanaryEnvironmentForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case activationWithoutOperatorOptInEvidence = "activation without operator opt-in evidence"
    case canaryActivationEnabledByThisIssue = "canary activation enabled by this issue"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretRead = "production secret read"
    case productionSecretValueStored = "production secret value stored"
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

/// ReleaseV0210SpotCanaryEnvironmentProfile 是 GH-1274 的 Binance Spot canary
/// environment profile。
///
/// Profile 复用 v0.18.1 typed namespace 表达 `productionLive` 身份，但该身份只作为
/// operator-visible canary profile intent。GH-1274 不读取 production secret、不保存 raw
/// credential、不连接 production endpoint / broker endpoint、不实现 signed account 或
/// private stream runtime、不创建 submit / cancel / replace 能力，也不授权 production cutover。
public struct ReleaseV0210SpotCanaryEnvironmentProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamCanaryContractHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let profileModes: [ReleaseV0210SpotCanaryEnvironmentProfileMode]
    public let activationState: ReleaseV0210SpotCanaryActivationState
    public let requirements: [ReleaseV0210SpotCanaryEnvironmentRequirement]
    public let forbiddenCapabilities: [ReleaseV0210SpotCanaryEnvironmentForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let operatorOptInEvidenceID: String
    public let operatorOptInEvidenceRequired: Bool
    public let operatorOptInEvidencePresent: Bool
    public let operatorOptInEvidenceRedacted: Bool
    public let canaryActivationRequested: Bool
    public let canaryActivationEnabled: Bool
    public let defaultFailClosed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let credentialSecretReadEnabled: Bool
    public let productionSecretValueStored: Bool
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

    public var profileHeld: Bool {
        issueID.rawValue == "GH-1274"
            && upstreamIssueID.rawValue == "GH-1273"
            && downstreamIssueID.rawValue == "GH-1275"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && upstreamCanaryContractHeld
            && namespaceHeld
            && environmentIntentHeld
            && operatorOptInGateHeld
            && activationDefaultsClosed
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var environmentIntentHeld: Bool {
        profileModes == Self.requiredProfileModes
    }

    public var operatorOptInGateHeld: Bool {
        operatorOptInEvidenceID == Self.requiredOperatorOptInEvidenceID
            && operatorOptInEvidenceRequired
            && operatorOptInEvidenceRedacted
    }

    public var activationDefaultsClosed: Bool {
        defaultFailClosed
            && canaryActivationEnabled == false
            && (
                (operatorOptInEvidencePresent == false
                    && activationState != .operatorOptInEvidenceRecordedStillFailClosed)
                    || (operatorOptInEvidencePresent
                        && activationState == .operatorOptInEvidenceRecordedStillFailClosed)
            )
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && credentialSecretReadEnabled == false
            && productionSecretValueStored == false
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
        profileID: Identifier = Identifier.constant("gh-1274-release-v0.21.0-binance-spot-canary-environment-profile"),
        issueID: Identifier = Identifier.constant("GH-1274"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1273"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1275"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        upstreamCanaryContractHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        profileModes: [ReleaseV0210SpotCanaryEnvironmentProfileMode] = Self.requiredProfileModes,
        activationState: ReleaseV0210SpotCanaryActivationState = Self.requiredActivationState,
        requirements: [ReleaseV0210SpotCanaryEnvironmentRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0210SpotCanaryEnvironmentForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        operatorOptInEvidenceID: String = Self.requiredOperatorOptInEvidenceID,
        operatorOptInEvidenceRequired: Bool = true,
        operatorOptInEvidencePresent: Bool = false,
        operatorOptInEvidenceRedacted: Bool = true,
        canaryActivationRequested: Bool = false,
        canaryActivationEnabled: Bool = false,
        defaultFailClosed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        credentialSecretReadEnabled: Bool = false,
        productionSecretValueStored: Bool = false,
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
            profileModes: profileModes,
            activationState: activationState,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            operatorOptInEvidenceID: operatorOptInEvidenceID
        )
        try Self.validateRequiredTrueFlags(
            upstreamCanaryContractHeld: upstreamCanaryContractHeld,
            operatorOptInEvidenceRequired: operatorOptInEvidenceRequired,
            operatorOptInEvidenceRedacted: operatorOptInEvidenceRedacted,
            defaultFailClosed: defaultFailClosed
        )
        try Self.validateActivationGate(
            activationState: activationState,
            operatorOptInEvidencePresent: operatorOptInEvidencePresent,
            canaryActivationRequested: canaryActivationRequested,
            canaryActivationEnabled: canaryActivationEnabled
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            credentialSecretReadEnabled: credentialSecretReadEnabled,
            productionSecretValueStored: productionSecretValueStored,
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

        self.profileID = profileID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamCanaryContractHeld = upstreamCanaryContractHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.profileModes = profileModes
        self.activationState = activationState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.operatorOptInEvidenceID = operatorOptInEvidenceID
        self.operatorOptInEvidenceRequired = operatorOptInEvidenceRequired
        self.operatorOptInEvidencePresent = operatorOptInEvidencePresent
        self.operatorOptInEvidenceRedacted = operatorOptInEvidenceRedacted
        self.canaryActivationRequested = canaryActivationRequested
        self.canaryActivationEnabled = canaryActivationEnabled
        self.defaultFailClosed = defaultFailClosed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.credentialSecretReadEnabled = credentialSecretReadEnabled
        self.productionSecretValueStored = productionSecretValueStored
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

    public static func deterministicFixture() throws -> ReleaseV0210SpotCanaryEnvironmentProfile {
        _ = try ReleaseV0210SpotControlledProductionCanaryContract.deterministicFixture()
        return try ReleaseV0210SpotCanaryEnvironmentProfile()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredOperatorOptInEvidenceID =
        "pending-human-operator-opt-in-evidence:binance:spot:productionLive:v0.21.0"
    public static let requiredProfileModes = ReleaseV0210SpotCanaryEnvironmentProfileMode.allCases
    public static let requiredActivationState =
        ReleaseV0210SpotCanaryActivationState.defaultOffAwaitingOperatorOptInEvidence
    public static let requiredRequirements = ReleaseV0210SpotCanaryEnvironmentRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0210SpotCanaryEnvironmentForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE",
        "TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE",
        "V0210-002-BINANCE-SPOT-CANARY-PROFILE",
        "V0210-002-DEFAULT-OFF-FAIL-CLOSED",
        "V0210-002-OPERATOR-OPT-IN-EVIDENCE",
        "V0210-002-NO-SECRET-ENDPOINT-ORDER",
        "V0210-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1274ReleaseV0210SpotCanaryEnvironmentProfile",
        "bash checks/verify-v0.21.0-spot-canary-environment-profile.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanaryEnvironmentProfile {
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
        profileModes: [ReleaseV0210SpotCanaryEnvironmentProfileMode],
        activationState: ReleaseV0210SpotCanaryActivationState,
        requirements: [ReleaseV0210SpotCanaryEnvironmentRequirement],
        forbiddenCapabilities: [ReleaseV0210SpotCanaryEnvironmentForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String],
        operatorOptInEvidenceID: String
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1274", "GH-1274", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1273", "GH-1273", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1275", "GH-1275", downstreamIssueID.rawValue),
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
                "profileModes",
                profileModes == requiredProfileModes,
                requiredProfileModes.map(\.rawValue).joined(separator: ","),
                profileModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "activationState",
                activationState == requiredActivationState
                    || activationState == .blockedMissingOperatorOptInEvidence
                    || activationState == .operatorOptInEvidenceRecordedStillFailClosed,
                ReleaseV0210SpotCanaryActivationState.allCases.map(\.rawValue).joined(separator: ","),
                activationState.rawValue
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
            ),
            (
                "operatorOptInEvidenceID",
                operatorOptInEvidenceID == requiredOperatorOptInEvidenceID,
                requiredOperatorOptInEvidenceID,
                operatorOptInEvidenceID
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        upstreamCanaryContractHeld: Bool,
        operatorOptInEvidenceRequired: Bool,
        operatorOptInEvidenceRedacted: Bool,
        defaultFailClosed: Bool
    ) throws {
        for (field, value) in [
            ("upstreamCanaryContractHeld", upstreamCanaryContractHeld),
            ("operatorOptInEvidenceRequired", operatorOptInEvidenceRequired),
            ("operatorOptInEvidenceRedacted", operatorOptInEvidenceRedacted),
            ("defaultFailClosed", defaultFailClosed)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateActivationGate(
        activationState: ReleaseV0210SpotCanaryActivationState,
        operatorOptInEvidencePresent: Bool,
        canaryActivationRequested: Bool,
        canaryActivationEnabled: Bool
    ) throws {
        if canaryActivationRequested && operatorOptInEvidencePresent == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.environmentProfile.activationWithoutOperatorOptInEvidence"
            )
        }
        if canaryActivationEnabled {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.environmentProfile.canaryActivationEnabledByThisIssue"
            )
        }
        if operatorOptInEvidencePresent && activationState != .operatorOptInEvidenceRecordedStillFailClosed {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "activationState",
                expected: ReleaseV0210SpotCanaryActivationState.operatorOptInEvidenceRecordedStillFailClosed.rawValue,
                actual: activationState.rawValue
            )
        }
        if operatorOptInEvidencePresent == false && activationState == .operatorOptInEvidenceRecordedStillFailClosed {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "operatorOptInEvidencePresent",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        credentialSecretReadEnabled: Bool,
        productionSecretValueStored: Bool,
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
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("credentialSecretReadEnabled", credentialSecretReadEnabled),
            ("productionSecretValueStored", productionSecretValueStored),
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
