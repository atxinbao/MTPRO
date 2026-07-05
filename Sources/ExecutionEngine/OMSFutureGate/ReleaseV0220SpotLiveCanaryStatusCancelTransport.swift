import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportAction 固定 GH-1314 的
/// Binance Spot approved canary order status query / cancel transport 动作集合。
public enum ReleaseV0220SpotLiveCanaryStatusCancelTransportAction:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case statusQuery = "status query"
    case cancel = "cancel"
}

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportOutcome 固定 GH-1314 的
/// status / cancel transport 判定结果。
public enum ReleaseV0220SpotLiveCanaryStatusCancelTransportOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case completed = "completed"
    case rejected = "rejected"
}

/// ReleaseV0220SpotLiveCanaryStatusCancelRetryClassification 描述 GH-1314 的
/// retry / idempotency 判定结果。
public enum ReleaseV0220SpotLiveCanaryStatusCancelRetryClassification:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case firstAttempt = "first attempt"
    case idempotentDuplicateRetry = "idempotent duplicate retry"
    case unsafeDuplicateRejected = "unsafe duplicate rejected"
    case ambiguousStateRequiresReconciliation = "ambiguous state requires reconciliation"
}

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportRejectReason 是 GH-1314 的
/// fail-closed 分类。
public enum ReleaseV0220SpotLiveCanaryStatusCancelTransportRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamSubmitTransportMissing = "upstream submit transport missing"
    case approvedRunMismatch = "approved run mismatch"
    case approvedClientOrderMismatch = "approved client order mismatch"
    case approvedExchangeOrderMismatch = "approved exchange order mismatch"
    case endpointScopeViolated = "endpoint scope violated"
    case cancelTargetOutsideApprovedOrder = "cancel target outside approved order"
    case idempotencyKeyMissing = "idempotency key missing"
    case duplicateRetryNotIdempotent = "duplicate retry not idempotent"
    case statusEvidenceMissing = "status evidence missing"
    case cancelEvidenceMissing = "cancel evidence missing"
    case ambiguousExchangeStateRequiresReconciliation = "ambiguous exchange state requires reconciliation"
    case rawStatusPayloadPersisted = "raw status payload persisted"
    case rawCancelPayloadPersisted = "raw cancel payload persisted"
    case rawCredentialValuePersisted = "raw credential value persisted"
    case signaturePersisted = "signature persisted"
    case futuresExecutionEnabled = "futures execution enabled"
    case okxActiveImplementationEnabled = "okx active implementation enabled"
    case dashboardTradingCommandEnabled = "dashboard trading command enabled"
    case productionCutoverAuthorized = "production cutover authorized"
}

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy 描述 GH-1314 的
/// status query / cancel transport 输入约束。
///
/// Policy 只保存 approved order identity、idempotency key、retry 分类和脱敏 evidence handle。
/// 它不保存 raw status payload、raw cancel payload、credential value、signature 或 account payload。
public struct ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy:
    Codable, Equatable, Sendable
{
    public let policyID: Identifier
    public let action: ReleaseV0220SpotLiveCanaryStatusCancelTransportAction
    public let approvedRunID: Identifier
    public let requestedRunID: Identifier
    public let approvedClientOrderID: Identifier
    public let requestedClientOrderID: Identifier
    public let approvedExchangeOrderID: Identifier
    public let requestedExchangeOrderID: Identifier
    public let idempotencyKey: Identifier
    public let duplicateRetryAttempt: Bool
    public let idempotencyKeyMatchesPriorAttempt: Bool
    public let statusEvidenceStored: Bool
    public let cancelEvidenceStored: Bool
    public let ambiguousExchangeStateObserved: Bool
    public let rawStatusPayloadPersisted: Bool
    public let rawCancelPayloadPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let signaturePersisted: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var approvedTargetHeld: Bool {
        approvedRunID == requestedRunID
            && approvedClientOrderID == requestedClientOrderID
            && approvedExchangeOrderID == requestedExchangeOrderID
    }

    public var idempotencyHeld: Bool {
        idempotencyKey.rawValue.isEmpty == false
            && (duplicateRetryAttempt == false || idempotencyKeyMatchesPriorAttempt)
    }

    public var evidenceHeld: Bool {
        switch action {
        case .statusQuery:
            return statusEvidenceStored
        case .cancel:
            return statusEvidenceStored && cancelEvidenceStored
        }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawStatusPayloadPersisted == false
            && rawCancelPayloadPersisted == false
            && rawCredentialValuePersisted == false
            && signaturePersisted == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1314-v0220-status-cancel-transport-policy"),
        action: ReleaseV0220SpotLiveCanaryStatusCancelTransportAction,
        approvedRunID: Identifier = Self.requiredRunID,
        requestedRunID: Identifier = Self.requiredRunID,
        approvedClientOrderID: Identifier = Self.requiredClientOrderID,
        requestedClientOrderID: Identifier = Self.requiredClientOrderID,
        approvedExchangeOrderID: Identifier = Self.requiredExchangeOrderID,
        requestedExchangeOrderID: Identifier = Self.requiredExchangeOrderID,
        idempotencyKey: Identifier = Self.requiredIdempotencyKey,
        duplicateRetryAttempt: Bool = false,
        idempotencyKeyMatchesPriorAttempt: Bool = true,
        statusEvidenceStored: Bool = true,
        cancelEvidenceStored: Bool = true,
        ambiguousExchangeStateObserved: Bool = false,
        rawStatusPayloadPersisted: Bool = false,
        rawCancelPayloadPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        signaturePersisted: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawStatusPayloadPersisted: rawStatusPayloadPersisted,
            rawCancelPayloadPersisted: rawCancelPayloadPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            signaturePersisted: signaturePersisted,
            futuresExecutionEnabled: futuresExecutionEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingCommandEnabled: dashboardTradingCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.policyID = policyID
        self.action = action
        self.approvedRunID = approvedRunID
        self.requestedRunID = requestedRunID
        self.approvedClientOrderID = approvedClientOrderID
        self.requestedClientOrderID = requestedClientOrderID
        self.approvedExchangeOrderID = approvedExchangeOrderID
        self.requestedExchangeOrderID = requestedExchangeOrderID
        self.idempotencyKey = idempotencyKey
        self.duplicateRetryAttempt = duplicateRetryAttempt
        self.idempotencyKeyMatchesPriorAttempt = idempotencyKeyMatchesPriorAttempt
        self.statusEvidenceStored = statusEvidenceStored
        self.cancelEvidenceStored = cancelEvidenceStored
        self.ambiguousExchangeStateObserved = ambiguousExchangeStateObserved
        self.rawStatusPayloadPersisted = rawStatusPayloadPersisted
        self.rawCancelPayloadPersisted = rawCancelPayloadPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.signaturePersisted = signaturePersisted
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func statusQueryFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(action: .statusQuery)
    }

    public static func cancelFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(action: .cancel)
    }

    public static func idempotentDuplicateCancelFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(
            action: .cancel,
            duplicateRetryAttempt: true,
            idempotencyKeyMatchesPriorAttempt: true
        )
    }

    public static func targetMismatchFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(
            action: .cancel,
            requestedClientOrderID: Identifier.constant(
                "gh-1314-unapproved-client-order",
                field: "releaseV0220.statusCancelTransport.requestedClientOrderID"
            )
        )
    }

    public static func unsafeDuplicateFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(
            action: .cancel,
            duplicateRetryAttempt: true,
            idempotencyKeyMatchesPriorAttempt: false
        )
    }

    public static func ambiguousStatusFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(
            action: .statusQuery,
            ambiguousExchangeStateObserved: true
        )
    }

    public static func missingCancelEvidenceFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy(
            action: .cancel,
            cancelEvidenceStored: false
        )
    }

    public static let requiredRunID = Identifier.constant(
        "gh-1314-approved-run",
        field: "releaseV0220.statusCancelTransport.runID"
    )
    public static let requiredClientOrderID = Identifier.constant(
        "gh-1313-client-order-redacted",
        field: "releaseV0220.statusCancelTransport.clientOrderID"
    )
    public static let requiredExchangeOrderID = Identifier.constant(
        "gh-1313-exchange-order-redacted",
        field: "releaseV0220.statusCancelTransport.exchangeOrderID"
    )
    public static let requiredIdempotencyKey = Identifier.constant(
        "gh-1314-status-cancel-idempotency-key",
        field: "releaseV0220.statusCancelTransport.idempotencyKey"
    )
}

private extension ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy {
    static func validateForbiddenFlags(
        rawStatusPayloadPersisted: Bool,
        rawCancelPayloadPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        signaturePersisted: Bool,
        futuresExecutionEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingCommandEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawStatusPayloadPersisted", rawStatusPayloadPersisted),
            ("rawCancelPayloadPersisted", rawCancelPayloadPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("signaturePersisted", signaturePersisted),
            ("futuresExecutionEnabled", futuresExecutionEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingCommandEnabled", dashboardTradingCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.statusCancelTransport.\(field)"
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation 是 GH-1314 的
/// status / cancel transport 判定。
public struct ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation:
    Codable, Equatable, Sendable
{
    public let observationID: Identifier
    public let policy: ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy
    public let upstreamSubmitTransportHeld: Bool
    public let endpointFamilyReference: String
    public let orderPath: String
    public let method: String
    public let redactedStatusEvidenceEnvelope: String
    public let redactedCancelEvidenceEnvelope: String
    public let outcome: ReleaseV0220SpotLiveCanaryStatusCancelTransportOutcome
    public let retryClassification: ReleaseV0220SpotLiveCanaryStatusCancelRetryClassification
    public let rejectReasons: [ReleaseV0220SpotLiveCanaryStatusCancelTransportRejectReason]
    public let requiresReconciliation: Bool
    public let statusQueryTransportCreated: Bool
    public let cancelTransportCreated: Bool

    public var acceptedObservationHeld: Bool {
        rejectReasons.isEmpty
            && outcome == .completed
            && upstreamSubmitTransportHeld
            && endpointHeld
            && redactedEvidenceHeld
            && policy.approvedTargetHeld
            && policy.idempotencyHeld
            && policy.evidenceHeld
            && policy.forbiddenCapabilitiesClosed
            && requiresReconciliation == false
            && actionTransportHeld
    }

    public var idempotentRetryObservationHeld: Bool {
        acceptedObservationHeld
            && policy.duplicateRetryAttempt
            && retryClassification == .idempotentDuplicateRetry
    }

    public var failClosedObservationHeld: Bool {
        rejectReasons.isEmpty == false
            && outcome == .rejected
            && statusQueryTransportCreated == false
            && cancelTransportCreated == false
            && policy.forbiddenCapabilitiesClosed
    }

    public var endpointHeld: Bool {
        endpointFamilyReference == Self.requiredEndpointFamilyReference
            && orderPath == Self.requiredOrderPath
            && method == requiredMethod
    }

    public var redactedEvidenceHeld: Bool {
        redactedStatusEvidenceEnvelope.hasPrefix(Self.requiredRedactedStatusPrefix)
            && redactedStatusEvidenceEnvelope.contains("<redacted>")
            && redactedStatusEvidenceEnvelope.lowercased().contains("signature=") == false
            && redactedStatusEvidenceEnvelope.lowercased().contains("secret") == false
            && (policy.action == .statusQuery || redactedCancelEvidenceHeld)
    }

    public var redactedCancelEvidenceHeld: Bool {
        redactedCancelEvidenceEnvelope.hasPrefix(Self.requiredRedactedCancelPrefix)
            && redactedCancelEvidenceEnvelope.contains("<redacted>")
            && redactedCancelEvidenceEnvelope.lowercased().contains("signature=") == false
            && redactedCancelEvidenceEnvelope.lowercased().contains("secret") == false
    }

    public var actionTransportHeld: Bool {
        switch policy.action {
        case .statusQuery:
            return statusQueryTransportCreated && cancelTransportCreated == false
        case .cancel:
            return statusQueryTransportCreated && cancelTransportCreated
        }
    }

    public var requiredMethod: String {
        switch policy.action {
        case .statusQuery:
            return "GET"
        case .cancel:
            return "DELETE"
        }
    }

    public init(
        observationID: Identifier? = nil,
        policy: ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy,
        upstreamSubmitTransportHeld: Bool = true,
        endpointFamilyReference: String = Self.requiredEndpointFamilyReference,
        orderPath: String = Self.requiredOrderPath,
        method: String? = nil,
        redactedStatusEvidenceEnvelope: String = Self.requiredRedactedStatusEvidenceEnvelope,
        redactedCancelEvidenceEnvelope: String = Self.requiredRedactedCancelEvidenceEnvelope
    ) {
        let resolvedMethod = method ?? (policy.action == .statusQuery ? "GET" : "DELETE")
        let reasons = Self.expectedRejectReasons(
            policy: policy,
            upstreamSubmitTransportHeld: upstreamSubmitTransportHeld,
            endpointFamilyReference: endpointFamilyReference,
            orderPath: orderPath,
            method: resolvedMethod,
            redactedStatusEvidenceEnvelope: redactedStatusEvidenceEnvelope,
            redactedCancelEvidenceEnvelope: redactedCancelEvidenceEnvelope
        )
        let accepted = reasons.isEmpty
        self.observationID = observationID
            ?? Self.deterministicID(policy: policy, outcome: accepted ? .completed : .rejected)
        self.policy = policy
        self.upstreamSubmitTransportHeld = upstreamSubmitTransportHeld
        self.endpointFamilyReference = endpointFamilyReference
        self.orderPath = orderPath
        self.method = resolvedMethod
        self.redactedStatusEvidenceEnvelope = redactedStatusEvidenceEnvelope
        self.redactedCancelEvidenceEnvelope = redactedCancelEvidenceEnvelope
        self.outcome = accepted ? .completed : .rejected
        self.retryClassification = Self.retryClassification(policy: policy, accepted: accepted)
        self.rejectReasons = reasons
        self.requiresReconciliation = policy.ambiguousExchangeStateObserved
        self.statusQueryTransportCreated = accepted
        self.cancelTransportCreated = accepted && policy.action == .cancel
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy,
        upstreamSubmitTransportHeld: Bool,
        endpointFamilyReference: String,
        orderPath: String,
        method: String,
        redactedStatusEvidenceEnvelope: String,
        redactedCancelEvidenceEnvelope: String
    ) -> [ReleaseV0220SpotLiveCanaryStatusCancelTransportRejectReason] {
        var reasons: [ReleaseV0220SpotLiveCanaryStatusCancelTransportRejectReason] = []
        if upstreamSubmitTransportHeld == false {
            reasons.append(.upstreamSubmitTransportMissing)
        }
        if policy.approvedRunID != policy.requestedRunID {
            reasons.append(.approvedRunMismatch)
        }
        if policy.approvedClientOrderID != policy.requestedClientOrderID {
            reasons.append(.approvedClientOrderMismatch)
        }
        if policy.approvedExchangeOrderID != policy.requestedExchangeOrderID {
            reasons.append(.approvedExchangeOrderMismatch)
        }
        if endpointFamilyReference != Self.requiredEndpointFamilyReference
            || orderPath != Self.requiredOrderPath
            || method != (policy.action == .statusQuery ? "GET" : "DELETE")
        {
            reasons.append(.endpointScopeViolated)
        }
        if policy.action == .cancel && policy.approvedTargetHeld == false {
            reasons.append(.cancelTargetOutsideApprovedOrder)
        }
        if policy.idempotencyKey.rawValue.isEmpty {
            reasons.append(.idempotencyKeyMissing)
        }
        if policy.duplicateRetryAttempt && policy.idempotencyKeyMatchesPriorAttempt == false {
            reasons.append(.duplicateRetryNotIdempotent)
        }
        if policy.statusEvidenceStored == false
            || redactedStatusEvidenceEnvelope.hasPrefix(Self.requiredRedactedStatusPrefix) == false
            || redactedStatusEvidenceEnvelope.contains("<redacted>") == false
        {
            reasons.append(.statusEvidenceMissing)
        }
        if policy.action == .cancel
            && (policy.cancelEvidenceStored == false
                || redactedCancelEvidenceEnvelope.hasPrefix(Self.requiredRedactedCancelPrefix) == false
                || redactedCancelEvidenceEnvelope.contains("<redacted>") == false)
        {
            reasons.append(.cancelEvidenceMissing)
        }
        if policy.ambiguousExchangeStateObserved {
            reasons.append(.ambiguousExchangeStateRequiresReconciliation)
        }
        if policy.rawStatusPayloadPersisted {
            reasons.append(.rawStatusPayloadPersisted)
        }
        if policy.rawCancelPayloadPersisted {
            reasons.append(.rawCancelPayloadPersisted)
        }
        if policy.rawCredentialValuePersisted {
            reasons.append(.rawCredentialValuePersisted)
        }
        if policy.signaturePersisted {
            reasons.append(.signaturePersisted)
        }
        if policy.futuresExecutionEnabled {
            reasons.append(.futuresExecutionEnabled)
        }
        if policy.okxActiveImplementationEnabled {
            reasons.append(.okxActiveImplementationEnabled)
        }
        if policy.dashboardTradingCommandEnabled {
            reasons.append(.dashboardTradingCommandEnabled)
        }
        if policy.productionCutoverAuthorized {
            reasons.append(.productionCutoverAuthorized)
        }
        return reasons
    }

    public static func retryClassification(
        policy: ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy,
        accepted: Bool
    ) -> ReleaseV0220SpotLiveCanaryStatusCancelRetryClassification {
        if policy.ambiguousExchangeStateObserved {
            return .ambiguousStateRequiresReconciliation
        }
        if policy.duplicateRetryAttempt && policy.idempotencyKeyMatchesPriorAttempt == false {
            return .unsafeDuplicateRejected
        }
        if accepted && policy.duplicateRetryAttempt {
            return .idempotentDuplicateRetry
        }
        return .firstAttempt
    }

    public static func deterministicID(
        policy: ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy,
        outcome: ReleaseV0220SpotLiveCanaryStatusCancelTransportOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1314-v0220-status-cancel-transport-observation",
                policy.policyID.rawValue,
                policy.action.rawValue,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0220.statusCancelTransport.observationID"
        )
    }

    public static let requiredEndpointFamilyReference = "https://api.binance.com"
    public static let requiredOrderPath = "/api/v3/order"
    public static let requiredRedactedStatusPrefix = "redacted-order-status:gh-1314"
    public static let requiredRedactedCancelPrefix = "redacted-order-cancel:gh-1314"
    public static let requiredRedactedStatusEvidenceEnvelope =
        "redacted-order-status:gh-1314 runID=<redacted> orderId=<redacted> clientOrderId=<redacted> status=<redacted> endpoint=<redacted>"
    public static let requiredRedactedCancelEvidenceEnvelope =
        "redacted-order-cancel:gh-1314 runID=<redacted> orderId=<redacted> clientOrderId=<redacted> cancelAck=<redacted> endpoint=<redacted>"
}

/// ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence 是 GH-1314 的
/// approved Binance Spot canary order status / cancel transport evidence。
public struct ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamSubmitTransport: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence
    public let acceptedStatusObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let acceptedCancelObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let idempotentCancelRetryObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let targetMismatchObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let unsafeDuplicateRetryObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let ambiguousStateObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let missingCancelEvidenceObservation: ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let cancelApprovedCanaryOrderOnly: Bool
    public let idempotencyKeysPersisted: Bool
    public let retryClassificationPersisted: Bool
    public let redactedTransportEvidenceRequired: Bool
    public let ambiguousStateRequiresReconciliation: Bool
    public let unknownExchangeStateFailsClosed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1314"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1313"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1315", "GH-1316"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && namespaceHeld
            && upstreamSubmitTransport.evidenceHeld
            && observationsHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiredControlsHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var observationsHeld: Bool {
        acceptedStatusObservation.acceptedObservationHeld
            && acceptedStatusObservation.policy.action == .statusQuery
            && acceptedCancelObservation.acceptedObservationHeld
            && acceptedCancelObservation.policy.action == .cancel
            && idempotentCancelRetryObservation.idempotentRetryObservationHeld
            && targetMismatchObservation.rejectReasons.contains(.approvedClientOrderMismatch)
            && targetMismatchObservation.rejectReasons.contains(.cancelTargetOutsideApprovedOrder)
            && unsafeDuplicateRetryObservation.rejectReasons == [.duplicateRetryNotIdempotent]
            && unsafeDuplicateRetryObservation.retryClassification == .unsafeDuplicateRejected
            && ambiguousStateObservation.rejectReasons == [.ambiguousExchangeStateRequiresReconciliation]
            && ambiguousStateObservation.requiresReconciliation
            && missingCancelEvidenceObservation.rejectReasons == [.cancelEvidenceMissing]
            && [
                targetMismatchObservation,
                unsafeDuplicateRetryObservation,
                ambiguousStateObservation,
                missingCancelEvidenceObservation
            ].allSatisfy(\.failClosedObservationHeld)
    }

    public var requiredControlsHeld: Bool {
        cancelApprovedCanaryOrderOnly
            && idempotencyKeysPersisted
            && retryClassificationPersisted
            && redactedTransportEvidenceRequired
            && ambiguousStateRequiresReconciliation
            && unknownExchangeStateFailsClosed
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1314-release-v0.22.0-status-cancel-transport-evidence"),
        issueID: Identifier = Identifier.constant("GH-1314"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1313")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1315"), Identifier.constant("GH-1316")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamSubmitTransport: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        cancelApprovedCanaryOrderOnly: Bool = true,
        idempotencyKeysPersisted: Bool = true,
        retryClassificationPersisted: Bool = true,
        redactedTransportEvidenceRequired: Bool = true,
        ambiguousStateRequiresReconciliation: Bool = true,
        unknownExchangeStateFailsClosed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamSubmitTransport = try upstreamSubmitTransport
            ?? ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence.deterministicFixture()
        self.acceptedStatusObservation = ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
            policy: try .statusQueryFixture()
        )
        self.acceptedCancelObservation = ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
            policy: try .cancelFixture()
        )
        self.idempotentCancelRetryObservation =
            ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
                policy: try .idempotentDuplicateCancelFixture()
            )
        self.targetMismatchObservation = ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
            policy: try .targetMismatchFixture()
        )
        self.unsafeDuplicateRetryObservation =
            ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
                policy: try .unsafeDuplicateFixture()
            )
        self.ambiguousStateObservation = ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
            policy: try .ambiguousStatusFixture()
        )
        self.missingCancelEvidenceObservation =
            ReleaseV0220SpotLiveCanaryStatusCancelTransportObservation(
                policy: try .missingCancelEvidenceFixture()
            )
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.cancelApprovedCanaryOrderOnly = cancelApprovedCanaryOrderOnly
        self.idempotencyKeysPersisted = idempotencyKeysPersisted
        self.retryClassificationPersisted = retryClassificationPersisted
        self.redactedTransportEvidenceRequired = redactedTransportEvidenceRequired
        self.ambiguousStateRequiresReconciliation = ambiguousStateRequiresReconciliation
        self.unknownExchangeStateFailsClosed = unknownExchangeStateFailsClosed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.statusCancelTransport",
                expected: "approved Binance Spot canary status/cancel transport evidence",
                actual: "invalid status/cancel transport evidence"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence
    {
        try ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-1314-VERIFY-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT",
        "TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT",
        "V0220-006-BLOCKED-BY-GH1313",
        "V0220-006-STATUS-QUERY-BY-EXCHANGE-AND-CLIENT-ID",
        "V0220-006-CANCEL-APPROVED-CANARY-ORDER-ONLY",
        "V0220-006-IDEMPOTENCY-KEY-RETRY-CLASSIFICATION",
        "V0220-006-REDACTED-STATUS-CANCEL-EVIDENCE",
        "V0220-006-AMBIGUOUS-STATE-REQUIRES-RECONCILIATION",
        "V0220-006-UNKNOWN-STATE-FAILS-CLOSED",
        "V0220-006-NO-FUTURES-OKX",
        "V0220-006-NO-DASHBOARD-TRADING-CONTROLS",
        "V0220-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1314ReleaseV0220LiveOrderStatusCancelTransport",
        "bash checks/verify-v0.22.0-status-cancel-transport.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
