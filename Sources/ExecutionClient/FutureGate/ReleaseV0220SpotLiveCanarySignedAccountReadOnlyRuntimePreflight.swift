import DomainModel
import Foundation

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState 固定 GH-1312
/// 的 Binance Spot signed account read-only preflight 状态。
///
/// `ready` 只表示 GH-1311 的临时 secret material read 已经完成，并产生了
/// signed account read-only preflight 的脱敏 freshness/status evidence。它不表示
/// submit / cancel / replace、Futures / OKX、Dashboard trading command 或
/// production cutover 已开启。
public enum ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case ready = "ready"
    case blockedMissingSecretRead = "blocked-missing-secret-read"
    case blockedEndpoint = "blocked-endpoint"
    case blockedAuth = "blocked-auth"
    case blockedTimestamp = "blocked-timestamp"
    case blockedPermission = "blocked-permission"
    case blockedStaleResponse = "blocked-stale-response"
    case blockedRawPayload = "blocked-raw-payload"
    case blockedOrderCapability = "blocked-order-capability"
}

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass 固定
/// GH-1312 的 fail-closed 分类。
public enum ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missingCredentialSecretRead = "missing credential secret read"
    case endpointRejected = "endpoint rejected"
    case authenticationRejected = "authentication rejected"
    case timestampRejected = "timestamp rejected"
    case permissionRejected = "permission rejected"
    case staleResponse = "stale response"
    case rawAccountPayloadAttempted = "raw account payload attempted"
    case orderCapabilityAttempted = "order capability attempted"
}

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement 固定
/// GH-1312 的验收要求。
public enum ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamCredentialSecretMaterialReadHeld = "upstream credential secret material read held"
    case approvedCanarySessionOnly = "approved canary session only"
    case binanceSpotOnly = "Binance Spot only"
    case productionLiveEnvironmentOnly = "productionLive environment only"
    case signedAccountReadOnlyEndpointOnly = "signed account read-only endpoint only"
    case redactedFreshnessStatusEvidenceRequired = "redacted freshness/status evidence required"
    case rawAccountPayloadNeverPersisted = "raw account payload never persisted"
    case endpointFailureBlocksSubmit = "endpoint failure blocks submit"
    case authFailureBlocksSubmit = "auth failure blocks submit"
    case timestampFailureBlocksSubmit = "timestamp failure blocks submit"
    case permissionFailureBlocksSubmit = "permission failure blocks submit"
    case staleResponseBlocksSubmit = "stale response blocks submit"
    case downstreamSubmitBlockedUntilPreflightReady = "downstream submit blocked until preflight ready"
    case noFuturesOrOKX = "no Futures or OKX"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability
/// 枚举 GH-1312 仍然拒绝的能力。
public enum ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case unsignedOrUnapprovedPreflight = "unsigned or unapproved preflight"
    case nonAccountEndpointRuntime = "non-account endpoint runtime"
    case orderEndpointRuntime = "order endpoint runtime"
    case rawCredentialMaterialStored = "raw credential material stored"
    case rawAccountPayloadStored = "raw account payload stored"
    case submitCancelReplace = "submit / cancel / replace"
    case privateStreamRuntime = "private stream runtime"
    case listenKeyRuntime = "listenKey runtime"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case productionBrokerConnection = "production broker connection"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation 是
/// GH-1312 的 signed account read-only preflight observation。
///
/// Observation 只能保存 endpoint identity、method、脱敏 credential reference、
/// freshness/status summary 和 fail-closed 分类。它不得保存 raw account payload、
/// signature、listenKey、API key / secret key 或订单 payload。
public struct ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation:
    Codable, Equatable, Sendable
{
    public let observationID: Identifier
    public let state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState
    public let failureClass: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass?
    public let endpointFamilyReference: String
    public let accountPath: String
    public let method: String
    public let redactedCredentialReference: String
    public let redactedFreshnessStatusSummary: String
    public let observedAtEpochSeconds: Int
    public let staleAfterSeconds: Int
    public let accountPayloadRedacted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let signaturePersisted: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceAttempted: Bool
    public let appendOnlyEvidence: Bool

    public var readyObservationHeld: Bool {
        state == .ready
            && failureClass == nil
            && endpointHeld
            && accountPayloadRedacted
            && Self.isRedactedFreshnessStatusSummary(redactedFreshnessStatusSummary, state: state)
            && observedAtEpochSeconds > 0
            && staleAfterSeconds == Self.requiredStaleAfterSeconds
            && forbiddenBoundaryHeld
            && appendOnlyEvidence
    }

    public var failClosedObservationHeld: Bool {
        state != .ready
            && failureClass != nil
            && endpointHeld
            && Self.isRedactedFreshnessStatusSummary(redactedFreshnessStatusSummary, state: state)
            && forbiddenBoundaryHeld
            && appendOnlyEvidence
    }

    public var endpointHeld: Bool {
        endpointFamilyReference == Self.requiredEndpointFamilyReference
            && accountPath == Self.requiredAccountPath
            && method == "GET"
            && redactedCredentialReference ==
                ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence.requiredRedactedCredentialReference
    }

    public var forbiddenBoundaryHeld: Bool {
        rawAccountPayloadPersisted == false
            && signaturePersisted == false
            && orderEndpointTouched == false
            && submitCancelReplaceAttempted == false
    }

    public init(
        observationID: Identifier? = nil,
        state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState = .ready,
        failureClass: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass? = nil,
        endpointFamilyReference: String = Self.requiredEndpointFamilyReference,
        accountPath: String = Self.requiredAccountPath,
        method: String = "GET",
        redactedCredentialReference: String =
            ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence.requiredRedactedCredentialReference,
        redactedFreshnessStatusSummary: String? = nil,
        observedAtEpochSeconds: Int = Self.requiredObservedAtEpochSeconds,
        staleAfterSeconds: Int = Self.requiredStaleAfterSeconds,
        accountPayloadRedacted: Bool = true,
        rawAccountPayloadPersisted: Bool = false,
        signaturePersisted: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceAttempted: Bool = false,
        appendOnlyEvidence: Bool = true
    ) throws {
        let resolvedSummary = redactedFreshnessStatusSummary
            ?? Self.defaultRedactedFreshnessStatusSummary(state: state)
        let resolvedID = observationID ?? Self.deterministicID(state: state, failureClass: failureClass)
        try Self.validate(
            state: state,
            failureClass: failureClass,
            endpointFamilyReference: endpointFamilyReference,
            accountPath: accountPath,
            method: method,
            redactedCredentialReference: redactedCredentialReference,
            redactedFreshnessStatusSummary: resolvedSummary,
            observedAtEpochSeconds: observedAtEpochSeconds,
            staleAfterSeconds: staleAfterSeconds,
            accountPayloadRedacted: accountPayloadRedacted,
            rawAccountPayloadPersisted: rawAccountPayloadPersisted,
            signaturePersisted: signaturePersisted,
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
        self.redactedFreshnessStatusSummary = resolvedSummary
        self.observedAtEpochSeconds = observedAtEpochSeconds
        self.staleAfterSeconds = staleAfterSeconds
        self.accountPayloadRedacted = accountPayloadRedacted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.signaturePersisted = signaturePersisted
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceAttempted = submitCancelReplaceAttempted
        self.appendOnlyEvidence = appendOnlyEvidence
    }

    public static func readyFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation()
    }

    public static func missingSecretReadFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedMissingSecretRead,
            failureClass: .missingCredentialSecretRead
        )
    }

    public static func endpointFailureFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedEndpoint,
            failureClass: .endpointRejected
        )
    }

    public static func authFailureFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedAuth,
            failureClass: .authenticationRejected
        )
    }

    public static func timestampFailureFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedTimestamp,
            failureClass: .timestampRejected
        )
    }

    public static func permissionFailureFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedPermission,
            failureClass: .permissionRejected
        )
    }

    public static func staleResponseFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation(
            state: .blockedStaleResponse,
            failureClass: .staleResponse
        )
    }

    public static let requiredEndpointFamilyReference = "https://api.binance.com"
    public static let requiredAccountPath = "/api/v3/account"
    public static let requiredObservedAtEpochSeconds = 1_765_248_000
    public static let requiredStaleAfterSeconds = 30
    public static let requiredSummaryPrefix = "signed-account-readonly-preflight=<redacted>"
    public static let requiredFreshnessMarker = "freshness=<redacted>"
    public static let requiredStatusMarker = "status=<redacted>"
    public static let requiredPayloadMarker = "payload=<redacted>"

    public static func defaultRedactedFreshnessStatusSummary(
        state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState
    ) -> String {
        [
            requiredSummaryPrefix,
            "endpoint=/api/v3/account",
            "method=GET",
            "state=\(state.rawValue)",
            requiredFreshnessMarker,
            requiredStatusMarker,
            requiredPayloadMarker
        ].joined(separator: "; ")
    }

    public static func deterministicID(
        state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState,
        failureClass: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass?
    ) -> Identifier {
        .constant(
            [
                "gh-1312-v0220-signed-account-readonly-preflight-observation",
                state.rawValue,
                failureClass?.rawValue ?? "none"
            ].joined(separator: ":")
        )
    }
}

private extension ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation {
    static func validate(
        state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState,
        failureClass: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightFailureClass?,
        endpointFamilyReference: String,
        accountPath: String,
        method: String,
        redactedCredentialReference: String,
        redactedFreshnessStatusSummary: String,
        observedAtEpochSeconds: Int,
        staleAfterSeconds: Int,
        accountPayloadRedacted: Bool,
        rawAccountPayloadPersisted: Bool,
        signaturePersisted: Bool,
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
                redactedCredentialReference ==
                    ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence.requiredRedactedCredentialReference,
                ReleaseV0220SpotLiveCanaryCredentialSecretReadAuditEvidence.requiredRedactedCredentialReference,
                redactedCredentialReference
            )
        ]
        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.\(field)",
                expected: expected,
                actual: actual
            )
        }

        switch (state, failureClass) {
        case (.ready, nil):
            guard accountPayloadRedacted else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0220.signedAccountReadOnlyPreflight.observation.accountPayloadRedacted",
                    expected: "true",
                    actual: "false"
                )
            }
        case (.ready, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "nil when ready",
                actual: failureClass.rawValue
            )
        case (.blockedMissingSecretRead, .missingCredentialSecretRead?),
             (.blockedEndpoint, .endpointRejected?),
             (.blockedAuth, .authenticationRejected?),
             (.blockedTimestamp, .timestampRejected?),
             (.blockedPermission, .permissionRejected?),
             (.blockedStaleResponse, .staleResponse?),
             (.blockedRawPayload, .rawAccountPayloadAttempted?),
             (.blockedOrderCapability, .orderCapabilityAttempted?):
            break
        case (_, nil):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "fail-closed failure class",
                actual: "nil"
            )
        case (_, .some(let failureClass)):
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.failureClass",
                expected: "matching fail-closed failure class",
                actual: failureClass.rawValue
            )
        }

        guard observedAtEpochSeconds > 0, staleAfterSeconds == requiredStaleAfterSeconds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.freshness",
                expected: "positive observedAt and 30 second stale threshold",
                actual: "observedAt=\(observedAtEpochSeconds),staleAfter=\(staleAfterSeconds)"
            )
        }

        guard isRedactedFreshnessStatusSummary(redactedFreshnessStatusSummary, state: state) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.signedAccountReadOnlyPreflight.observation.unredactedFreshnessStatusSummary"
            )
        }

        for (field, value) in [
            ("rawAccountPayloadPersisted", rawAccountPayloadPersisted),
            ("signaturePersisted", signaturePersisted),
            ("orderEndpointTouched", orderEndpointTouched),
            ("submitCancelReplaceAttempted", submitCancelReplaceAttempted)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.signedAccountReadOnlyPreflight.observation.\(field)"
            )
        }

        guard appendOnlyEvidence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight.observation.appendOnlyEvidence",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func isRedactedFreshnessStatusSummary(
        _ summary: String,
        state: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightState
    ) -> Bool {
        let lowered = summary.lowercased()
        guard summary.contains(requiredSummaryPrefix),
              summary.contains("endpoint=/api/v3/account"),
              summary.contains("method=GET"),
              summary.contains("state=\(state.rawValue)"),
              summary.contains(requiredFreshnessMarker),
              summary.contains(requiredStatusMarker),
              summary.contains(requiredPayloadMarker)
        else {
            return false
        }
        for forbidden in [
            "api key",
            "secret key",
            "signature=",
            "listenkey",
            "raw payload",
            "balances=",
            "permissions=",
            "makercommission",
            "takercommission"
        ] where lowered.contains(forbidden) {
            return false
        }
        return true
    }
}

/// ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight 是 GH-1312
/// 的 Binance Spot signed account runtime preflight gate。
///
/// Gate 消费 GH-1311 的 redacted credential secret material read evidence，仅输出
/// signed account read-only freshness/status evidence。失败时必须阻断后续 submit path；
/// 成功时也只允许后续 issue 继续执行 explicit canary submit gate，不授权广义生产交易。
public struct ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight:
    Codable, Equatable, Sendable
{
    public let preflightID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let upstreamCredentialSecretMaterialReadPath:
        ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath
    public let readyObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let missingSecretReadObservation:
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let endpointFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let authFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let timestampFailureObservation:
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let permissionFailureObservation:
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let staleResponseObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation
    public let requirements: [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let signedAccountReadOnlyPreflightEnabledByThisIssue: Bool
    public let redactedFreshnessStatusEvidencePersisted: Bool
    public let failedPreflightBlocksSubmitPath: Bool
    public let rawAccountPayloadPersisted: Bool
    public let signaturePersisted: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let submitCancelReplaceEnabledByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var preflightHeld: Bool {
        issueID.rawValue == "GH-1312"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1311"]
            && downstreamIssueID.rawValue == "GH-1313"
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && upstreamCredentialSecretMaterialReadPath.readPathHeld
            && readyObservation.readyObservationHeld
            && failClosedEvidenceHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiredTrueFlagsHeld
            && forbiddenCapabilitiesClosed
    }

    public var failClosedEvidenceHeld: Bool {
        missingSecretReadObservation.state == .blockedMissingSecretRead
            && missingSecretReadObservation.failureClass == .missingCredentialSecretRead
            && endpointFailureObservation.state == .blockedEndpoint
            && endpointFailureObservation.failureClass == .endpointRejected
            && authFailureObservation.state == .blockedAuth
            && authFailureObservation.failureClass == .authenticationRejected
            && timestampFailureObservation.state == .blockedTimestamp
            && timestampFailureObservation.failureClass == .timestampRejected
            && permissionFailureObservation.state == .blockedPermission
            && permissionFailureObservation.failureClass == .permissionRejected
            && staleResponseObservation.state == .blockedStaleResponse
            && staleResponseObservation.failureClass == .staleResponse
            && missingSecretReadObservation.failClosedObservationHeld
            && endpointFailureObservation.failClosedObservationHeld
            && authFailureObservation.failClosedObservationHeld
            && timestampFailureObservation.failClosedObservationHeld
            && permissionFailureObservation.failClosedObservationHeld
            && staleResponseObservation.failClosedObservationHeld
    }

    public var requiredTrueFlagsHeld: Bool {
        signedAccountReadOnlyPreflightEnabledByThisIssue
            && redactedFreshnessStatusEvidencePersisted
            && failedPreflightBlocksSubmitPath
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawAccountPayloadPersisted == false
            && signaturePersisted == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && submitCancelReplaceEnabledByThisIssue == false
            && productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        preflightID: Identifier = Identifier.constant("gh-1312-v0220-signed-account-readonly-runtime-preflight"),
        issueID: Identifier = Identifier.constant("GH-1312"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1311")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1313"),
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        upstreamCredentialSecretMaterialReadPath: ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath? = nil,
        readyObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        missingSecretReadObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        endpointFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        authFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        timestampFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        permissionFailureObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        staleResponseObservation: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation? = nil,
        requirements: [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement] =
            Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        signedAccountReadOnlyPreflightEnabledByThisIssue: Bool = true,
        redactedFreshnessStatusEvidencePersisted: Bool = true,
        failedPreflightBlocksSubmitPath: Bool = true,
        rawAccountPayloadPersisted: Bool = false,
        signaturePersisted: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        submitCancelReplaceEnabledByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        self.preflightID = preflightID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.upstreamCredentialSecretMaterialReadPath = try upstreamCredentialSecretMaterialReadPath
            ?? ReleaseV0220SpotLiveCanaryCredentialSecretMaterialReadPath.redactedReadFixture()
        self.readyObservation = try readyObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.readyFixture()
        self.missingSecretReadObservation = try missingSecretReadObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.missingSecretReadFixture()
        self.endpointFailureObservation = try endpointFailureObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.endpointFailureFixture()
        self.authFailureObservation = try authFailureObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.authFailureFixture()
        self.timestampFailureObservation = try timestampFailureObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.timestampFailureFixture()
        self.permissionFailureObservation = try permissionFailureObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.permissionFailureFixture()
        self.staleResponseObservation = try staleResponseObservation
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightObservation.staleResponseFixture()
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.signedAccountReadOnlyPreflightEnabledByThisIssue = signedAccountReadOnlyPreflightEnabledByThisIssue
        self.redactedFreshnessStatusEvidencePersisted = redactedFreshnessStatusEvidencePersisted
        self.failedPreflightBlocksSubmitPath = failedPreflightBlocksSubmitPath
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.signaturePersisted = signaturePersisted
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.submitCancelReplaceEnabledByThisIssue = submitCancelReplaceEnabledByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease

        guard preflightHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.signedAccountReadOnlyPreflight",
                expected: "approved signed account read-only preflight with fail-closed evidence",
                actual: "invalid signed account read-only preflight evidence"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight
    {
        try ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight()
    }

    public static let requiredRequirements: [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement] =
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightRequirement.allCases
    public static let requiredForbiddenCapabilities:
        [ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability] =
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyPreflightForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "GH-1312-VERIFY-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT",
        "TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT",
        "V0220-004-BLOCKED-BY-GH1311",
        "V0220-004-APPROVED-CANARY-SESSION-ONLY",
        "V0220-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT",
        "V0220-004-REDACTED-FRESHNESS-STATUS-EVIDENCE",
        "V0220-004-RAW-ACCOUNT-PAYLOAD-NEVER-PERSISTED",
        "V0220-004-ENDPOINT-AUTH-TIMESTAMP-PERMISSION-STALE-FAIL-CLOSED",
        "V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT",
        "V0220-004-NO-FUTURES-OKX",
        "V0220-004-NO-ORDER-CUTOVER"
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1312ReleaseV0220SignedAccountRuntimePreflight",
        "bash checks/verify-v0.22.0-signed-account-runtime-preflight.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
