import DomainModel
import Foundation

/// ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState 固定 GH-1276 的
/// Binance Spot signed account read-only runtime preflight 状态。
///
/// `preflightReady` 只表示已消费 GH-1275 的审批证据，并生成脱敏的只读账号
/// preflight evidence；它不授权 order endpoint、submit / cancel / replace、
/// private stream、broker connection 或 production cutover。
public enum ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case preflightReady = "preflight-ready"
    case credentialApprovalMissing = "credential-approval-missing"
    case redactionEvidenceMissing = "redaction-evidence-missing"
    case rawAccountPayloadBlocked = "raw-account-payload-blocked"
    case orderEndpointBlocked = "order-endpoint-blocked"
}

/// ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass 固定
/// GH-1276 的 fail-closed 分类。
public enum ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case requiredCredentialApprovalMissing = "required credential approval missing"
    case redactionEvidenceMissing = "redaction evidence missing"
    case rawAccountPayloadAttempted = "raw account payload attempted"
    case orderEndpointAttempted = "order endpoint attempted"
}

/// ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement 固定
/// GH-1276 的验收要求。
public enum ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamCredentialApprovalHeld = "upstream credential approval held"
    case binanceSpotProductionLiveOnly = "Binance Spot productionLive only"
    case signedAccountReadOnlyPreflight = "signed account read-only preflight"
    case accountEndpointReadOnlyOnly = "account endpoint read-only only"
    case redactedStatusEvidenceRequired = "redacted status evidence required"
    case rawAccountPayloadForbidden = "raw account payload forbidden"
    case missingApprovalFailsClosed = "missing approval fails closed"
    case orderEndpointFailsClosed = "order endpoint fails closed"
    case noSubmitCancelReplace = "no submit / cancel / replace"
    case noPrivateStreamRuntime = "no private stream runtime"
    case noProductionCutover = "no production cutover"
    case downstreamSnapshotRedactionRequired = "downstream snapshot redaction required"
}

/// ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability
/// 枚举 GH-1276 必须继续拒绝的能力。
public enum ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case credentialSecretValuePersisted = "credential secret value persisted"
    case credentialSecretValueLogged = "credential secret value logged"
    case rawCredentialMaterialStored = "raw credential material stored"
    case rawAccountPayloadStored = "raw account payload stored"
    case orderEndpointTouched = "order endpoint touched"
    case submitCancelReplaceEnabled = "submit / cancel / replace enabled"
    case privateStreamRuntime = "private stream runtime"
    case listenKeyRuntime = "listenKey runtime"
    case productionBrokerConnection = "production broker connection"
    case dashboardTradingButton = "Dashboard trading button"
    case orderForm = "order form"
    case liveCommand = "live command"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation 表达
/// GH-1276 的脱敏账号只读 preflight observation。
///
/// Observation 只保存 endpoint identity、read-only method、redacted status
/// summary 和 fail-closed flags。它不得保存 API key / secret key / listenKey、
/// raw account payload、order payload 或 broker response。
public struct ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation: Codable, Equatable, Sendable {
    public let observationID: Identifier
    public let state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState
    public let failureClass: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass?
    public let endpointFamilyReference: String
    public let accountPath: String
    public let method: String
    public let redactedCredentialReference: String
    public let redactedStatusSummary: String
    public let credentialSecretReadApproved: Bool
    public let accountPayloadRedacted: Bool
    public let credentialSecretValuePersisted: Bool
    public let credentialSecretValueLogged: Bool
    public let rawCredentialMaterialStored: Bool
    public let rawAccountPayloadStored: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceAttempted: Bool
    public let appendOnlyEvidence: Bool

    public var observationHeld: Bool {
        state == .preflightReady
            && failureClass == nil
            && endpointHeld
            && credentialSecretReadApproved
            && accountPayloadRedacted
            && Self.isRedactedStatusSummary(redactedStatusSummary, state: state)
            && forbiddenBoundaryHeld
            && appendOnlyEvidence
    }

    public var failClosedObservationHeld: Bool {
        state != .preflightReady
            && failureClass != nil
            && endpointHeld
            && Self.isRedactedStatusSummary(redactedStatusSummary, state: state)
            && forbiddenBoundaryHeld
            && appendOnlyEvidence
    }

    public var endpointHeld: Bool {
        endpointFamilyReference == Self.requiredEndpointFamilyReference
            && accountPath == Self.requiredAccountPath
            && method == "GET"
            && redactedCredentialReference ==
                ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.requiredRedactedCredentialReference
    }

    public var forbiddenBoundaryHeld: Bool {
        credentialSecretValuePersisted == false
            && credentialSecretValueLogged == false
            && rawCredentialMaterialStored == false
            && rawAccountPayloadStored == false
            && orderEndpointTouched == false
            && submitCancelReplaceAttempted == false
    }

    public init(
        observationID: Identifier? = nil,
        state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState = .preflightReady,
        failureClass: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass? = nil,
        endpointFamilyReference: String = Self.requiredEndpointFamilyReference,
        accountPath: String = Self.requiredAccountPath,
        method: String = "GET",
        redactedCredentialReference: String =
            ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.requiredRedactedCredentialReference,
        redactedStatusSummary: String? = nil,
        credentialSecretReadApproved: Bool = true,
        accountPayloadRedacted: Bool = true,
        credentialSecretValuePersisted: Bool = false,
        credentialSecretValueLogged: Bool = false,
        rawCredentialMaterialStored: Bool = false,
        rawAccountPayloadStored: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceAttempted: Bool = false,
        appendOnlyEvidence: Bool = true
    ) throws {
        let resolvedSummary = redactedStatusSummary ?? Self.defaultRedactedStatusSummary(state: state)
        let resolvedID = observationID ?? Self.deterministicID(state: state, failureClass: failureClass)
        try Self.validate(
            state: state,
            failureClass: failureClass,
            endpointFamilyReference: endpointFamilyReference,
            accountPath: accountPath,
            method: method,
            redactedCredentialReference: redactedCredentialReference,
            redactedStatusSummary: resolvedSummary,
            credentialSecretReadApproved: credentialSecretReadApproved,
            accountPayloadRedacted: accountPayloadRedacted,
            credentialSecretValuePersisted: credentialSecretValuePersisted,
            credentialSecretValueLogged: credentialSecretValueLogged,
            rawCredentialMaterialStored: rawCredentialMaterialStored,
            rawAccountPayloadStored: rawAccountPayloadStored,
            orderEndpointTouched: orderEndpointTouched,
            submitCancelReplaceAttempted: submitCancelReplaceAttempted,
            appendOnlyEvidence: appendOnlyEvidence
        )
        self.observationID = resolvedID
        self.state = state
        self.failureClass = failureClass
        self.endpointFamilyReference = endpointFamilyReference
        self.accountPath = accountPath
        self.method = method
        self.redactedCredentialReference = redactedCredentialReference
        self.redactedStatusSummary = resolvedSummary
        self.credentialSecretReadApproved = credentialSecretReadApproved
        self.accountPayloadRedacted = accountPayloadRedacted
        self.credentialSecretValuePersisted = credentialSecretValuePersisted
        self.credentialSecretValueLogged = credentialSecretValueLogged
        self.rawCredentialMaterialStored = rawCredentialMaterialStored
        self.rawAccountPayloadStored = rawAccountPayloadStored
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceAttempted = submitCancelReplaceAttempted
        self.appendOnlyEvidence = appendOnlyEvidence
    }

    public static func readyFixture() throws
        -> ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation()
    }

    public static func missingApprovalFixture() throws
        -> ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation(
            state: .credentialApprovalMissing,
            failureClass: .requiredCredentialApprovalMissing,
            credentialSecretReadApproved: false
        )
    }

    public static func orderEndpointBlockedFixture() throws
        -> ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation(
            state: .orderEndpointBlocked,
            failureClass: .orderEndpointAttempted
        )
    }

    public static let requiredEndpointFamilyReference = "https://api.binance.com"
    public static let requiredAccountPath = "/api/v3/account"
    public static let requiredSummaryPrefix = "signed-account-preflight=<redacted>"
    public static let requiredAccountMarker = "account=<redacted>"
    public static let requiredPayloadMarker = "payload=<redacted>"

    public static func defaultRedactedStatusSummary(
        state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState
    ) -> String {
        "\(requiredSummaryPrefix); endpoint=/api/v3/account; method=GET; state=\(state.rawValue); \(requiredAccountMarker); \(requiredPayloadMarker)"
    }

    public static func deterministicID(
        state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState,
        failureClass: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass?
    ) -> Identifier {
        .constant(
            [
                "gh-1276-v0210-signed-account-readonly-preflight-observation",
                state.rawValue,
                failureClass?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0210.signedAccountReadOnlyPreflight.observationID"
        )
    }
}

private extension ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation {
    static func validate(
        state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState,
        failureClass: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightFailureClass?,
        endpointFamilyReference: String,
        accountPath: String,
        method: String,
        redactedCredentialReference: String,
        redactedStatusSummary: String,
        credentialSecretReadApproved: Bool,
        accountPayloadRedacted: Bool,
        credentialSecretValuePersisted: Bool,
        credentialSecretValueLogged: Bool,
        rawCredentialMaterialStored: Bool,
        rawAccountPayloadStored: Bool,
        orderEndpointTouched: Bool,
        submitCancelReplaceAttempted: Bool,
        appendOnlyEvidence: Bool
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("endpointFamilyReference", endpointFamilyReference == requiredEndpointFamilyReference, requiredEndpointFamilyReference, endpointFamilyReference),
            ("accountPath", accountPath == requiredAccountPath, requiredAccountPath, accountPath),
            ("method", method == "GET", "GET", method),
            (
                "redactedCredentialReference",
                redactedCredentialReference == ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.requiredRedactedCredentialReference,
                ReleaseV0210SpotCanaryCredentialApprovalAuditEvidence.requiredRedactedCredentialReference,
                redactedCredentialReference
            )
        ]
        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.observation.\(field)",
                expected: expected,
                actual: actual
            )
        }

        switch (state, failureClass) {
        case (.preflightReady, nil):
            guard credentialSecretReadApproved && accountPayloadRedacted else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0210.signedAccountReadOnlyPreflight.observation.readyFlags",
                    expected: "approved credential read and redacted account payload",
                    actual: "approved=\(credentialSecretReadApproved),redacted=\(accountPayloadRedacted)"
                )
            }
        case (.preflightReady, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "nil when preflight ready",
                actual: failureClass.rawValue
            )
        case (.credentialApprovalMissing, .requiredCredentialApprovalMissing?),
             (.redactionEvidenceMissing, .redactionEvidenceMissing?),
             (.rawAccountPayloadBlocked, .rawAccountPayloadAttempted?),
             (.orderEndpointBlocked, .orderEndpointAttempted?):
            break
        case (_, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (_, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }

        guard isRedactedStatusSummary(redactedStatusSummary, state: state) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.signedAccountReadOnlyPreflight.observation.unredactedStatusSummary"
            )
        }

        let forbiddenFlags = [
            ("credentialSecretValuePersisted", credentialSecretValuePersisted),
            ("credentialSecretValueLogged", credentialSecretValueLogged),
            ("rawCredentialMaterialStored", rawCredentialMaterialStored),
            ("rawAccountPayloadStored", rawAccountPayloadStored),
            ("orderEndpointTouched", orderEndpointTouched),
            ("submitCancelReplaceAttempted", submitCancelReplaceAttempted)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.signedAccountReadOnlyPreflight.observation.\(field)"
            )
        }

        guard appendOnlyEvidence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.observation.appendOnlyEvidence",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func isRedactedStatusSummary(
        _ summary: String,
        state: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightState
    ) -> Bool {
        let lowered = summary.lowercased()
        guard summary.contains(ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.requiredSummaryPrefix),
              summary.contains("endpoint=/api/v3/account"),
              summary.contains("method=GET"),
              summary.contains("state=\(state.rawValue)"),
              summary.contains(ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.requiredAccountMarker),
              summary.contains(ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.requiredPayloadMarker)
        else {
            return false
        }

        for forbidden in ["api key", "secret key", "listenkey", "signature=", "order payload", "raw payload"] where
            lowered.contains(forbidden)
        {
            return false
        }
        return true
    }
}

/// ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight 是 GH-1276 的
/// Binance Spot signed account read-only runtime preflight gate。
///
/// Gate 只消费 GH-1275 已脱敏的 credential approval evidence，并输出只读账号
/// preflight status。它不保存 credential value、不保存 raw account payload、不触达
/// order endpoint、不启用 submit / cancel / replace、不授权 production cutover。
public struct ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight: Codable, Equatable, Sendable {
    public let preflightID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamCredentialApprovalPath: ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let readOnlyObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    public let missingApprovalObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    public let orderEndpointBlockedObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation
    public let requirements: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let credentialApprovalConsumed: Bool
    public let signedAccountReadOnlyPreflightEnabled: Bool
    public let redactedReadinessEvidenceCaptured: Bool
    public let credentialSecretValuePersisted: Bool
    public let credentialSecretValueLogged: Bool
    public let rawCredentialMaterialStored: Bool
    public let rawAccountPayloadStored: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var preflightHeld: Bool {
        issueID.rawValue == "GH-1276"
            && upstreamIssueID.rawValue == "GH-1275"
            && downstreamIssueID.rawValue == "GH-1277"
            && canonicalQueueRange == ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && upstreamCredentialApprovalPath.approvalPathHeld
            && namespaceHeld
            && readOnlyObservation.observationHeld
            && missingApprovalObservation.failClosedObservationHeld
            && orderEndpointBlockedObservation.failClosedObservationHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && enabledReadOnlyPreflightHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var enabledReadOnlyPreflightHeld: Bool {
        credentialApprovalConsumed
            && signedAccountReadOnlyPreflightEnabled
            && redactedReadinessEvidenceCaptured
            && upstreamCredentialApprovalPath.approvalEvidenceHeld
    }

    public var failClosedEvidenceHeld: Bool {
        missingApprovalObservation.state == .credentialApprovalMissing
            && missingApprovalObservation.failureClass == .requiredCredentialApprovalMissing
            && orderEndpointBlockedObservation.state == .orderEndpointBlocked
            && orderEndpointBlockedObservation.failureClass == .orderEndpointAttempted
            && missingApprovalObservation.failClosedObservationHeld
            && orderEndpointBlockedObservation.failClosedObservationHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && credentialSecretValuePersisted == false
            && credentialSecretValueLogged == false
            && rawCredentialMaterialStored == false
            && rawAccountPayloadStored == false
            && orderEndpointTouched == false
            && submitCancelReplaceEnabled == false
            && privateStreamRuntimeEnabled == false
            && listenKeyRuntimeEnabled == false
            && productionBrokerConnectionEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        preflightID: Identifier = Identifier.constant("gh-1276-release-v0.21.0-binance-spot-signed-account-readonly-runtime-preflight"),
        issueID: Identifier = Identifier.constant("GH-1276"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1275"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1277"),
        canonicalQueueRange: String =
            ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        upstreamCredentialApprovalPath: ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath? = nil,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        readOnlyObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation? = nil,
        missingApprovalObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation? = nil,
        orderEndpointBlockedObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation? = nil,
        requirements: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        credentialApprovalConsumed: Bool = true,
        signedAccountReadOnlyPreflightEnabled: Bool = true,
        redactedReadinessEvidenceCaptured: Bool = true,
        credentialSecretValuePersisted: Bool = false,
        credentialSecretValueLogged: Bool = false,
        rawCredentialMaterialStored: Bool = false,
        rawAccountPayloadStored: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        listenKeyRuntimeEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedApproval = try upstreamCredentialApprovalPath
            ?? ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.deterministicFixture()
        let resolvedReadOnlyObservation = try readOnlyObservation
            ?? ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.readyFixture()
        let resolvedMissingApprovalObservation = try missingApprovalObservation
            ?? ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.missingApprovalFixture()
        let resolvedOrderEndpointBlockedObservation = try orderEndpointBlockedObservation
            ?? ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation.orderEndpointBlockedFixture()

        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueID: upstreamIssueID,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamCredentialApprovalPath: resolvedApproval,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            readOnlyObservation: resolvedReadOnlyObservation,
            missingApprovalObservation: resolvedMissingApprovalObservation,
            orderEndpointBlockedObservation: resolvedOrderEndpointBlockedObservation,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            credentialApprovalConsumed: credentialApprovalConsumed,
            signedAccountReadOnlyPreflightEnabled: signedAccountReadOnlyPreflightEnabled,
            redactedReadinessEvidenceCaptured: redactedReadinessEvidenceCaptured
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            credentialSecretValuePersisted: credentialSecretValuePersisted,
            credentialSecretValueLogged: credentialSecretValueLogged,
            rawCredentialMaterialStored: rawCredentialMaterialStored,
            rawAccountPayloadStored: rawAccountPayloadStored,
            orderEndpointTouched: orderEndpointTouched,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            listenKeyRuntimeEnabled: listenKeyRuntimeEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.preflightID = preflightID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamCredentialApprovalPath = resolvedApproval
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.readOnlyObservation = resolvedReadOnlyObservation
        self.missingApprovalObservation = resolvedMissingApprovalObservation
        self.orderEndpointBlockedObservation = resolvedOrderEndpointBlockedObservation
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.credentialApprovalConsumed = credentialApprovalConsumed
        self.signedAccountReadOnlyPreflightEnabled = signedAccountReadOnlyPreflightEnabled
        self.redactedReadinessEvidenceCaptured = redactedReadinessEvidenceCaptured
        self.credentialSecretValuePersisted = credentialSecretValuePersisted
        self.credentialSecretValueLogged = credentialSecretValueLogged
        self.rawCredentialMaterialStored = rawCredentialMaterialStored
        self.rawAccountPayloadStored = rawAccountPayloadStored
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight
    {
        try ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight()
    }

    public static let requiredRequirements =
        ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities =
        ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability.allCases
    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors = [
        "GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT",
        "TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT",
        "V0210-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT",
        "V0210-004-CONSUMES-CREDENTIAL-APPROVAL",
        "V0210-004-REDACTED-ACCOUNT-STATUS-EVIDENCE",
        "V0210-004-NO-RAW-ACCOUNT-PAYLOAD",
        "V0210-004-NO-ORDER-ENDPOINT",
        "V0210-004-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1276ReleaseV0210SignedAccountReadOnlyRuntimePreflight",
        "bash checks/verify-v0.21.0-signed-account-readonly-preflight.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanarySignedAccountReadOnlyRuntimePreflight {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueID: Identifier,
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamCredentialApprovalPath: ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        readOnlyObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation,
        missingApprovalObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation,
        orderEndpointBlockedObservation: ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightObservation,
        requirements: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightRequirement],
        forbiddenCapabilities: [ReleaseV0210SpotCanarySignedAccountReadOnlyPreflightForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1276", "GH-1276", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1275", "GH-1275", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1277", "GH-1277", downstreamIssueID.rawValue),
            (
                "canonicalQueueRange",
                canonicalQueueRange == ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.requiredCanonicalQueueRange,
                ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath.requiredCanonicalQueueRange,
                canonicalQueueRange
            ),
            (
                "projectName",
                projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            (
                "upstreamCredentialApprovalPath",
                upstreamCredentialApprovalPath.approvalPathHeld,
                "GH-1275 approval path held",
                upstreamCredentialApprovalPath.issueID.rawValue
            ),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            (
                "tradingEnvironment",
                tradingEnvironment == .productionLive,
                ReleaseV0181TradingEnvironment.productionLive.rawValue,
                tradingEnvironment.rawValue
            ),
            (
                "readOnlyObservation",
                readOnlyObservation.observationHeld,
                "redacted read-only account preflight observation",
                readOnlyObservation.state.rawValue
            ),
            (
                "missingApprovalObservation",
                missingApprovalObservation.failClosedObservationHeld,
                "missing approval fail-closed observation",
                missingApprovalObservation.state.rawValue
            ),
            (
                "orderEndpointBlockedObservation",
                orderEndpointBlockedObservation.failClosedObservationHeld,
                "order endpoint fail-closed observation",
                orderEndpointBlockedObservation.state.rawValue
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

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        credentialApprovalConsumed: Bool,
        signedAccountReadOnlyPreflightEnabled: Bool,
        redactedReadinessEvidenceCaptured: Bool
    ) throws {
        for (field, value) in [
            ("credentialApprovalConsumed", credentialApprovalConsumed),
            ("signedAccountReadOnlyPreflightEnabled", signedAccountReadOnlyPreflightEnabled),
            ("redactedReadinessEvidenceCaptured", redactedReadinessEvidenceCaptured)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.signedAccountReadOnlyPreflight.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        credentialSecretValuePersisted: Bool,
        credentialSecretValueLogged: Bool,
        rawCredentialMaterialStored: Bool,
        rawAccountPayloadStored: Bool,
        orderEndpointTouched: Bool,
        submitCancelReplaceEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        listenKeyRuntimeEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
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
            ("credentialSecretValuePersisted", credentialSecretValuePersisted),
            ("credentialSecretValueLogged", credentialSecretValueLogged),
            ("rawCredentialMaterialStored", rawCredentialMaterialStored),
            ("rawAccountPayloadStored", rawAccountPayloadStored),
            ("orderEndpointTouched", orderEndpointTouched),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("listenKeyRuntimeEnabled", listenKeyRuntimeEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.signedAccountReadOnlyPreflight.\(field)"
            )
        }
    }
}
