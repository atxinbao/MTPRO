import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0210ControlledCanaryCancelRollbackOutcome 固定 GH-1281 的受控
/// Binance Spot canary cancel / rollback guard 判定结果。
///
/// `authorized` 只表示本地已经生成单笔 canary cancel request evidence 和 status rollback
/// guard evidence；它不表示已经触发网络 cancel，也不授权 production cutover。
public enum ReleaseV0210ControlledCanaryCancelRollbackOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case authorized = "authorized"
    case rejected = "rejected"
}

/// ReleaseV0210ControlledCanaryCancelRollbackRejectReason 是 GH-1281 的 fail-closed
/// 拒绝原因集合。
///
/// 任一前置 submit gate、operator cancel approval、redacted canary order reference、audit
/// event、redacted cancel request、status rollback evidence 或 strict single-order scope
/// 缺失时，都必须在 cancel request evidence 生成前阻断。
public enum ReleaseV0210ControlledCanaryCancelRollbackRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamSubmitRejected = "upstream submit rejected"
    case explicitCancelApprovalMissing = "explicit cancel approval missing"
    case canaryOrderReferenceMissing = "canary order reference missing"
    case auditEventMissing = "audit event missing"
    case redactedCancelRequestEvidenceMissing = "redacted cancel request evidence missing"
    case statusRollbackEvidenceMissing = "status rollback evidence missing"
    case bulkCancelRequested = "bulk cancel requested"
    case strictSymbolScopeViolated = "strict symbol scope violated"
    case cancelWindowExpired = "cancel window expired"
}

/// ReleaseV0210ControlledCanaryCancelRollbackPolicy 描述 GH-1281 受控 cancel /
/// status rollback 的本地输入。
///
/// Policy 只保存 redacted order reference、redacted cancel request digest 和 rollback evidence
/// handle，不保存 raw order id、raw cancel payload、credential value、signature 或 endpoint response。
public struct ReleaseV0210ControlledCanaryCancelRollbackPolicy:
    Codable, Equatable, Sendable
{
    public let policyID: Identifier
    public let explicitCancelApprovalGranted: Bool
    public let cancelIdempotencyKey: String
    public let canaryOrderReferenceDigest: String
    public let canaryOrderReferenceTracked: Bool
    public let auditEventID: Identifier?
    public let redactedCancelRequestDigest: String
    public let redactedCancelRequestEvidenceStored: Bool
    public let statusRollbackEvidenceDigest: String
    public let statusRollbackEvidenceStored: Bool
    public let requestedSymbol: String
    public let requestedCancelCount: Int
    public let cancelWindowSeconds: Int
    public let singleCanaryOrderOnly: Bool
    public let bulkCancelRequested: Bool
    public let rawOrderIDPersisted: Bool
    public let rawCancelPayloadPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var strictSymbolScopeHeld: Bool {
        requestedSymbol == ReleaseV0210SpotCanaryHardLimitPolicy.requiredAllowedSymbols[0]
    }

    public var singleOrderScopeHeld: Bool {
        requestedCancelCount == 1
            && singleCanaryOrderOnly
            && bulkCancelRequested == false
    }

    public var cancelWindowHeld: Bool {
        cancelWindowSeconds <= Self.requiredMaxCancelWindowSeconds
    }

    public var canaryOrderReferenceHeld: Bool {
        canaryOrderReferenceTracked
            && canaryOrderReferenceDigest.hasPrefix(Self.requiredCanaryOrderReferenceDigestPrefix)
    }

    public var cancelRequestEvidenceHeld: Bool {
        redactedCancelRequestEvidenceStored
            && redactedCancelRequestDigest.hasPrefix(Self.requiredRedactedCancelRequestDigestPrefix)
    }

    public var rollbackEvidenceHeld: Bool {
        statusRollbackEvidenceStored
            && statusRollbackEvidenceDigest.hasPrefix(Self.requiredStatusRollbackEvidenceDigestPrefix)
    }

    public var auditEvidenceHeld: Bool {
        auditEventID != nil
            && cancelRequestEvidenceHeld
            && rollbackEvidenceHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawOrderIDPersisted == false
            && rawCancelPayloadPersisted == false
            && rawCredentialValuePersisted == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && productionCutoverAuthorized == false
    }

    public var policyHeld: Bool {
        explicitCancelApprovalGranted
            && cancelIdempotencyKey.isEmpty == false
            && canaryOrderReferenceHeld
            && auditEvidenceHeld
            && strictSymbolScopeHeld
            && singleOrderScopeHeld
            && cancelWindowHeld
            && forbiddenCapabilitiesClosed
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1281-v0210-controlled-canary-cancel-rollback-policy"),
        explicitCancelApprovalGranted: Bool = true,
        cancelIdempotencyKey: String = Self.requiredCancelIdempotencyKey,
        canaryOrderReferenceDigest: String = Self.requiredCanaryOrderReferenceDigest,
        canaryOrderReferenceTracked: Bool = true,
        auditEventID: Identifier? = Identifier.constant("gh-1281-v0210-controlled-canary-cancel-audit-event"),
        redactedCancelRequestDigest: String = Self.requiredRedactedCancelRequestDigest,
        redactedCancelRequestEvidenceStored: Bool = true,
        statusRollbackEvidenceDigest: String = Self.requiredStatusRollbackEvidenceDigest,
        statusRollbackEvidenceStored: Bool = true,
        requestedSymbol: String = "BTCUSDT",
        requestedCancelCount: Int = 1,
        cancelWindowSeconds: Int = 300,
        singleCanaryOrderOnly: Bool = true,
        bulkCancelRequested: Bool = false,
        rawOrderIDPersisted: Bool = false,
        rawCancelPayloadPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawOrderIDPersisted: rawOrderIDPersisted,
            rawCancelPayloadPersisted: rawCancelPayloadPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.policyID = policyID
        self.explicitCancelApprovalGranted = explicitCancelApprovalGranted
        self.cancelIdempotencyKey = cancelIdempotencyKey
        self.canaryOrderReferenceDigest = canaryOrderReferenceDigest
        self.canaryOrderReferenceTracked = canaryOrderReferenceTracked
        self.auditEventID = auditEventID
        self.redactedCancelRequestDigest = redactedCancelRequestDigest
        self.redactedCancelRequestEvidenceStored = redactedCancelRequestEvidenceStored
        self.statusRollbackEvidenceDigest = statusRollbackEvidenceDigest
        self.statusRollbackEvidenceStored = statusRollbackEvidenceStored
        self.requestedSymbol = requestedSymbol
        self.requestedCancelCount = requestedCancelCount
        self.cancelWindowSeconds = cancelWindowSeconds
        self.singleCanaryOrderOnly = singleCanaryOrderOnly
        self.bulkCancelRequested = bulkCancelRequested
        self.rawOrderIDPersisted = rawOrderIDPersisted
        self.rawCancelPayloadPersisted = rawCancelPayloadPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy()
    }

    public static func approvalMissingFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(explicitCancelApprovalGranted: false)
    }

    public static func orderReferenceMissingFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(canaryOrderReferenceTracked: false)
    }

    public static func cancelRequestMissingFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(redactedCancelRequestEvidenceStored: false)
    }

    public static func rollbackMissingFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(statusRollbackEvidenceStored: false)
    }

    public static func bulkCancelFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(
            requestedCancelCount: 2,
            bulkCancelRequested: true
        )
    }

    public static func symbolRejectedFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(requestedSymbol: "ETHUSDT")
    }

    public static func cancelWindowExpiredFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackPolicy
    {
        try ReleaseV0210ControlledCanaryCancelRollbackPolicy(cancelWindowSeconds: 301)
    }

    public static let requiredCancelIdempotencyKey =
        "gh-1281-v0210-btcusdt-single-canary-cancel"
    public static let requiredCanaryOrderReferenceDigestPrefix =
        "sha256:gh-1281-redacted-canary-order-reference"
    public static let requiredCanaryOrderReferenceDigest =
        "sha256:gh-1281-redacted-canary-order-reference:BTCUSDT:single"
    public static let requiredRedactedCancelRequestDigestPrefix =
        "sha256:gh-1281-redacted-cancel-request"
    public static let requiredRedactedCancelRequestDigest =
        "sha256:gh-1281-redacted-cancel-request:BTCUSDT:single"
    public static let requiredStatusRollbackEvidenceDigestPrefix =
        "sha256:gh-1281-status-rollback-evidence"
    public static let requiredStatusRollbackEvidenceDigest =
        "sha256:gh-1281-status-rollback-evidence:BTCUSDT:single"
    public static let requiredMaxCancelWindowSeconds = 300
}

private extension ReleaseV0210ControlledCanaryCancelRollbackPolicy {
    static func validateForbiddenFlags(
        rawOrderIDPersisted: Bool,
        rawCancelPayloadPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawOrderIDPersisted", rawOrderIDPersisted),
            ("rawCancelPayloadPersisted", rawCancelPayloadPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledCancel.\(field)"
            )
        }
    }
}

/// ReleaseV0210ControlledCanaryCancelRollbackDecision 是 GH-1281 的单笔 canary
/// cancel / rollback guard 判定。
///
/// Decision 必须消费 GH-1280 controlled submit evidence，并在前序 submit authorized、
/// cancel approval、redacted order reference、audit event、redacted cancel request、status rollback
/// evidence 和 strict single-order scope 全部成立时，才生成本地 cancel request evidence。
public struct ReleaseV0210ControlledCanaryCancelRollbackDecision:
    Codable, Equatable, Sendable
{
    public let decisionID: Identifier
    public let policy: ReleaseV0210ControlledCanaryCancelRollbackPolicy
    public let upstreamSubmitEvidenceID: Identifier
    public let upstreamSubmitDecisionID: Identifier
    public let upstreamSubmitOutcome: ReleaseV0210ControlledSpotCanarySubmitOutcome
    public let outcome: ReleaseV0210ControlledCanaryCancelRollbackOutcome
    public let rejectReasons: [ReleaseV0210ControlledCanaryCancelRollbackRejectReason]
    public let canaryCancelAuthorized: Bool
    public let controlledCancelRequestCreated: Bool
    public let statusRollbackGuardCreated: Bool
    public let cancelIdempotencyKey: String
    public let canaryOrderReferenceDigest: String
    public let auditEventID: Identifier?
    public let redactedCancelRequestDigest: String
    public let statusRollbackEvidenceDigest: String
    public let strictSymbolScopeHeld: Bool
    public let singleOrderScopeHeld: Bool
    public let cancelWindowHeld: Bool
    public let forwardsToStatusConfirmation: Bool
    public let networkCancelAttempted: Bool
    public let bulkCancelEnabled: Bool
    public let futuresCancelEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardDefaultTradingButtonEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionHeld: Bool {
        rejectReasons == Self.expectedRejectReasons(
            policy: policy,
            upstreamSubmitOutcome: upstreamSubmitOutcome
        )
            && acceptedOrRejectedStateHeld
            && policy.forbiddenCapabilitiesClosed
            && forbiddenCapabilitiesClosed
    }

    public var acceptedOrRejectedStateHeld: Bool {
        if rejectReasons.isEmpty {
            return outcome == .authorized
                && canaryCancelAuthorized
                && controlledCancelRequestCreated
                && statusRollbackGuardCreated
                && cancelIdempotencyKey.isEmpty == false
                && canaryOrderReferenceDigest.hasPrefix(
                    ReleaseV0210ControlledCanaryCancelRollbackPolicy.requiredCanaryOrderReferenceDigestPrefix
                )
                && auditEventID != nil
                && redactedCancelRequestDigest.hasPrefix(
                    ReleaseV0210ControlledCanaryCancelRollbackPolicy.requiredRedactedCancelRequestDigestPrefix
                )
                && statusRollbackEvidenceDigest.hasPrefix(
                    ReleaseV0210ControlledCanaryCancelRollbackPolicy.requiredStatusRollbackEvidenceDigestPrefix
                )
                && strictSymbolScopeHeld
                && singleOrderScopeHeld
                && cancelWindowHeld
                && forwardsToStatusConfirmation
        }

        return outcome == .rejected
            && canaryCancelAuthorized == false
            && controlledCancelRequestCreated == false
            && statusRollbackGuardCreated == false
            && forwardsToStatusConfirmation == false
    }

    public var forbiddenCapabilitiesClosed: Bool {
        networkCancelAttempted == false
            && bulkCancelEnabled == false
            && futuresCancelEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardDefaultTradingButtonEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        decisionID: Identifier? = nil,
        policy: ReleaseV0210ControlledCanaryCancelRollbackPolicy,
        upstreamSubmitEvidence: ReleaseV0210ControlledSpotCanarySubmitPathEvidence,
        upstreamSubmitDecision: ReleaseV0210ControlledSpotCanarySubmitDecision? = nil,
        networkCancelAttempted: Bool = false,
        bulkCancelEnabled: Bool = false,
        futuresCancelEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardDefaultTradingButtonEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamSubmitEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledCancel.upstreamSubmitEvidence",
                expected: "GH-1280 submit evidence held",
                actual: upstreamSubmitEvidence.issueID.rawValue
            )
        }

        try Self.validateForbiddenFlags(
            networkCancelAttempted: networkCancelAttempted,
            bulkCancelEnabled: bulkCancelEnabled,
            futuresCancelEnabled: futuresCancelEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardDefaultTradingButtonEnabled: dashboardDefaultTradingButtonEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        let resolvedSubmitDecision = upstreamSubmitDecision
            ?? upstreamSubmitEvidence.acceptedDecision
        let reasons = Self.expectedRejectReasons(
            policy: policy,
            upstreamSubmitOutcome: resolvedSubmitDecision.outcome
        )
        let resolvedOutcome: ReleaseV0210ControlledCanaryCancelRollbackOutcome =
            reasons.isEmpty ? .authorized : .rejected
        let authorized = reasons.isEmpty

        self.decisionID = decisionID
            ?? Self.deterministicID(
                policy: policy,
                upstreamSubmitDecision: resolvedSubmitDecision,
                outcome: resolvedOutcome
            )
        self.policy = policy
        self.upstreamSubmitEvidenceID = upstreamSubmitEvidence.evidenceID
        self.upstreamSubmitDecisionID = resolvedSubmitDecision.decisionID
        self.upstreamSubmitOutcome = resolvedSubmitDecision.outcome
        self.outcome = resolvedOutcome
        self.rejectReasons = reasons
        self.canaryCancelAuthorized = authorized
        self.controlledCancelRequestCreated = authorized
        self.statusRollbackGuardCreated = authorized
        self.cancelIdempotencyKey = policy.cancelIdempotencyKey
        self.canaryOrderReferenceDigest = policy.canaryOrderReferenceDigest
        self.auditEventID = policy.auditEventID
        self.redactedCancelRequestDigest = policy.redactedCancelRequestDigest
        self.statusRollbackEvidenceDigest = policy.statusRollbackEvidenceDigest
        self.strictSymbolScopeHeld = policy.strictSymbolScopeHeld
        self.singleOrderScopeHeld = policy.singleOrderScopeHeld
        self.cancelWindowHeld = policy.cancelWindowHeld
        self.forwardsToStatusConfirmation = authorized
        self.networkCancelAttempted = networkCancelAttempted
        self.bulkCancelEnabled = bulkCancelEnabled
        self.futuresCancelEnabled = futuresCancelEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardDefaultTradingButtonEnabled = dashboardDefaultTradingButtonEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0210ControlledCanaryCancelRollbackPolicy,
        upstreamSubmitOutcome: ReleaseV0210ControlledSpotCanarySubmitOutcome
    ) -> [ReleaseV0210ControlledCanaryCancelRollbackRejectReason] {
        var reasons: [ReleaseV0210ControlledCanaryCancelRollbackRejectReason] = []
        if upstreamSubmitOutcome != .authorized {
            reasons.append(.upstreamSubmitRejected)
        }
        if policy.explicitCancelApprovalGranted == false {
            reasons.append(.explicitCancelApprovalMissing)
        }
        if policy.canaryOrderReferenceHeld == false {
            reasons.append(.canaryOrderReferenceMissing)
        }
        if policy.auditEventID == nil {
            reasons.append(.auditEventMissing)
        }
        if policy.cancelRequestEvidenceHeld == false {
            reasons.append(.redactedCancelRequestEvidenceMissing)
        }
        if policy.rollbackEvidenceHeld == false {
            reasons.append(.statusRollbackEvidenceMissing)
        }
        if policy.singleOrderScopeHeld == false {
            reasons.append(.bulkCancelRequested)
        }
        if policy.strictSymbolScopeHeld == false {
            reasons.append(.strictSymbolScopeViolated)
        }
        if policy.cancelWindowHeld == false {
            reasons.append(.cancelWindowExpired)
        }
        return reasons
    }

    public static func deterministicID(
        policy: ReleaseV0210ControlledCanaryCancelRollbackPolicy,
        upstreamSubmitDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        outcome: ReleaseV0210ControlledCanaryCancelRollbackOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1281-v0210-controlled-canary-cancel-rollback-decision",
                upstreamSubmitDecision.decisionID.rawValue,
                policy.cancelIdempotencyKey.isEmpty ? "missing-cancel-idempotency" : policy.cancelIdempotencyKey,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.controlledCancel.decisionID"
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK",
        "TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK",
        "V0210-009-CONTROLLED-CANARY-CANCEL",
        "V0210-009-STATUS-ROLLBACK-GUARD",
        "V0210-009-AUDIT-EVIDENCE",
        "V0210-009-REDACTED-CANCEL-EVIDENCE",
        "V0210-009-SINGLE-CANARY-ORDER",
        "V0210-009-NO-BULK-CANCEL",
        "V0210-009-NO-FUTURES-CANCEL",
        "V0210-009-NO-PRODUCTION-CUTOVER"
    ]
}

private extension ReleaseV0210ControlledCanaryCancelRollbackDecision {
    static func validateForbiddenFlags(
        networkCancelAttempted: Bool,
        bulkCancelEnabled: Bool,
        futuresCancelEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardDefaultTradingButtonEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("networkCancelAttempted", networkCancelAttempted),
            ("bulkCancelEnabled", bulkCancelEnabled),
            ("futuresCancelEnabled", futuresCancelEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardDefaultTradingButtonEnabled", dashboardDefaultTradingButtonEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledCancel.\(field)"
            )
        }
    }
}

/// ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence 是 GH-1281 的受控
/// canary cancel / rollback guard 证据。
///
/// Evidence 只证明：GH-1280 生成 submit request evidence 后，系统可以生成单笔、幂等、
/// 脱敏、带 audit event 的 cancel request evidence，并同步生成 status rollback guard。
/// 它不默认启用生产交易，不连接 production endpoint，不读取 secret value，不发送网络 cancel。
public struct ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamSubmitEvidence: ReleaseV0210ControlledSpotCanarySubmitPathEvidence
    public let acceptedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let upstreamRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let approvalRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let orderReferenceRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let cancelRequestRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let rollbackRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let bulkCancelRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let symbolRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let cancelWindowRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let upstreamSubmitGateRequired: Bool
    public let explicitCancelApprovalRequired: Bool
    public let canaryOrderReferenceRequired: Bool
    public let auditEventRequired: Bool
    public let redactedCancelRequestEvidenceRequired: Bool
    public let statusRollbackEvidenceRequired: Bool
    public let singleCanaryOrderOnlyRequired: Bool
    public let failClosedRollbackRequired: Bool
    public let bulkCancelEnabled: Bool
    public let futuresCancelEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardDefaultTradingButtonEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let networkCancelAttempted: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1281"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1280"]
            && downstreamIssueID.rawValue == "GH-1282"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamSubmitEvidence.evidenceHeld
            && decisionEvidenceHeld
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

    public var requiredControlsHeld: Bool {
        upstreamSubmitGateRequired
            && explicitCancelApprovalRequired
            && canaryOrderReferenceRequired
            && auditEventRequired
            && redactedCancelRequestEvidenceRequired
            && statusRollbackEvidenceRequired
            && singleCanaryOrderOnlyRequired
            && failClosedRollbackRequired
    }

    public var decisionEvidenceHeld: Bool {
        acceptedDecision.decisionHeld
            && acceptedDecision.outcome == .authorized
            && acceptedDecision.canaryCancelAuthorized
            && acceptedDecision.controlledCancelRequestCreated
            && acceptedDecision.statusRollbackGuardCreated
            && upstreamRejectedDecision.rejectReasons == [.upstreamSubmitRejected]
            && approvalRejectedDecision.rejectReasons == [.explicitCancelApprovalMissing]
            && orderReferenceRejectedDecision.rejectReasons == [.canaryOrderReferenceMissing]
            && cancelRequestRejectedDecision.rejectReasons == [.redactedCancelRequestEvidenceMissing]
            && rollbackRejectedDecision.rejectReasons == [.statusRollbackEvidenceMissing]
            && bulkCancelRejectedDecision.rejectReasons == [.bulkCancelRequested]
            && symbolRejectedDecision.rejectReasons == [.strictSymbolScopeViolated]
            && cancelWindowRejectedDecision.rejectReasons == [.cancelWindowExpired]
            && [
                upstreamRejectedDecision,
                approvalRejectedDecision,
                orderReferenceRejectedDecision,
                cancelRequestRejectedDecision,
                rollbackRejectedDecision,
                bulkCancelRejectedDecision,
                symbolRejectedDecision,
                cancelWindowRejectedDecision
            ].allSatisfy {
                $0.decisionHeld
                    && $0.outcome == .rejected
                    && $0.canaryCancelAuthorized == false
                    && $0.controlledCancelRequestCreated == false
                    && $0.statusRollbackGuardCreated == false
            }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        bulkCancelEnabled == false
            && futuresCancelEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardDefaultTradingButtonEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && networkCancelAttempted == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1281-release-v0.21.0-controlled-canary-cancel-rollback-evidence"),
        issueID: Identifier = Identifier.constant("GH-1281"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1280")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1282"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamSubmitEvidence: ReleaseV0210ControlledSpotCanarySubmitPathEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        upstreamSubmitGateRequired: Bool = true,
        explicitCancelApprovalRequired: Bool = true,
        canaryOrderReferenceRequired: Bool = true,
        auditEventRequired: Bool = true,
        redactedCancelRequestEvidenceRequired: Bool = true,
        statusRollbackEvidenceRequired: Bool = true,
        singleCanaryOrderOnlyRequired: Bool = true,
        failClosedRollbackRequired: Bool = true,
        bulkCancelEnabled: Bool = false,
        futuresCancelEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardDefaultTradingButtonEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        networkCancelAttempted: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedSubmitEvidence = try upstreamSubmitEvidence
            ?? ReleaseV0210ControlledSpotCanarySubmitPathEvidence.deterministicFixture()
        let accepted = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .deterministicFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let upstreamRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .deterministicFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence,
            upstreamSubmitDecision: resolvedSubmitEvidence.approvalRejectedDecision
        )
        let approvalRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .approvalMissingFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let orderReferenceRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .orderReferenceMissingFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let cancelRequestRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .cancelRequestMissingFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let rollbackRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .rollbackMissingFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let bulkCancelRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .bulkCancelFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let symbolRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .symbolRejectedFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )
        let cancelWindowRejected = try ReleaseV0210ControlledCanaryCancelRollbackDecision(
            policy: .cancelWindowExpiredFixture(),
            upstreamSubmitEvidence: resolvedSubmitEvidence
        )

        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueIDs: upstreamIssueIDs,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            upstreamSubmitEvidence: resolvedSubmitEvidence,
            acceptedDecision: accepted,
            upstreamRejectedDecision: upstreamRejected,
            approvalRejectedDecision: approvalRejected,
            orderReferenceRejectedDecision: orderReferenceRejected,
            cancelRequestRejectedDecision: cancelRequestRejected,
            rollbackRejectedDecision: rollbackRejected,
            bulkCancelRejectedDecision: bulkCancelRejected,
            symbolRejectedDecision: symbolRejected,
            cancelWindowRejectedDecision: cancelWindowRejected,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamSubmitGateRequired: upstreamSubmitGateRequired,
            explicitCancelApprovalRequired: explicitCancelApprovalRequired,
            canaryOrderReferenceRequired: canaryOrderReferenceRequired,
            auditEventRequired: auditEventRequired,
            redactedCancelRequestEvidenceRequired: redactedCancelRequestEvidenceRequired,
            statusRollbackEvidenceRequired: statusRollbackEvidenceRequired,
            singleCanaryOrderOnlyRequired: singleCanaryOrderOnlyRequired,
            failClosedRollbackRequired: failClosedRollbackRequired
        )
        try Self.validateForbiddenFlags(
            bulkCancelEnabled: bulkCancelEnabled,
            futuresCancelEnabled: futuresCancelEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardDefaultTradingButtonEnabled: dashboardDefaultTradingButtonEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            networkCancelAttempted: networkCancelAttempted,
            createsTagOrRelease: createsTagOrRelease,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamSubmitEvidence = resolvedSubmitEvidence
        self.acceptedDecision = accepted
        self.upstreamRejectedDecision = upstreamRejected
        self.approvalRejectedDecision = approvalRejected
        self.orderReferenceRejectedDecision = orderReferenceRejected
        self.cancelRequestRejectedDecision = cancelRequestRejected
        self.rollbackRejectedDecision = rollbackRejected
        self.bulkCancelRejectedDecision = bulkCancelRejected
        self.symbolRejectedDecision = symbolRejected
        self.cancelWindowRejectedDecision = cancelWindowRejected
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.upstreamSubmitGateRequired = upstreamSubmitGateRequired
        self.explicitCancelApprovalRequired = explicitCancelApprovalRequired
        self.canaryOrderReferenceRequired = canaryOrderReferenceRequired
        self.auditEventRequired = auditEventRequired
        self.redactedCancelRequestEvidenceRequired = redactedCancelRequestEvidenceRequired
        self.statusRollbackEvidenceRequired = statusRollbackEvidenceRequired
        self.singleCanaryOrderOnlyRequired = singleCanaryOrderOnlyRequired
        self.failClosedRollbackRequired = failClosedRollbackRequired
        self.bulkCancelEnabled = bulkCancelEnabled
        self.futuresCancelEnabled = futuresCancelEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardDefaultTradingButtonEnabled = dashboardDefaultTradingButtonEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.networkCancelAttempted = networkCancelAttempted
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence
    {
        try ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors =
        ReleaseV0210ControlledCanaryCancelRollbackDecision.requiredValidationAnchors

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1281ReleaseV0210ControlledCanaryCancelRollbackGuard",
        "bash checks/verify-v0.21.0-controlled-canary-cancel-rollback.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueIDs: [Identifier],
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        upstreamSubmitEvidence: ReleaseV0210ControlledSpotCanarySubmitPathEvidence,
        acceptedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        upstreamRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        approvalRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        orderReferenceRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        cancelRequestRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        rollbackRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        bulkCancelRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        symbolRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        cancelWindowRejectedDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1281", "GH-1281", issueID.rawValue),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-1280"], "GH-1280", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1282", "GH-1282", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            ("tradingEnvironment", tradingEnvironment == .productionLive, ReleaseV0181TradingEnvironment.productionLive.rawValue, tradingEnvironment.rawValue),
            ("upstreamSubmitEvidence", upstreamSubmitEvidence.evidenceHeld, "GH-1280 submit evidence held", upstreamSubmitEvidence.issueID.rawValue),
            ("acceptedDecision", acceptedDecision.decisionHeld && acceptedDecision.outcome == .authorized, "authorized cancel rollback decision", acceptedDecision.outcome.rawValue),
            ("upstreamRejectedDecision", upstreamRejectedDecision.rejectReasons == [.upstreamSubmitRejected], "upstream submit rejection", upstreamRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("approvalRejectedDecision", approvalRejectedDecision.rejectReasons == [.explicitCancelApprovalMissing], "cancel approval rejection", approvalRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("orderReferenceRejectedDecision", orderReferenceRejectedDecision.rejectReasons == [.canaryOrderReferenceMissing], "order reference rejection", orderReferenceRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("cancelRequestRejectedDecision", cancelRequestRejectedDecision.rejectReasons == [.redactedCancelRequestEvidenceMissing], "cancel request rejection", cancelRequestRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("rollbackRejectedDecision", rollbackRejectedDecision.rejectReasons == [.statusRollbackEvidenceMissing], "rollback rejection", rollbackRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("bulkCancelRejectedDecision", bulkCancelRejectedDecision.rejectReasons == [.bulkCancelRequested], "bulk cancel rejection", bulkCancelRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("symbolRejectedDecision", symbolRejectedDecision.rejectReasons == [.strictSymbolScopeViolated], "symbol rejection", symbolRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("cancelWindowRejectedDecision", cancelWindowRejectedDecision.rejectReasons == [.cancelWindowExpired], "cancel window rejection", cancelWindowRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledCancel.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        upstreamSubmitGateRequired: Bool,
        explicitCancelApprovalRequired: Bool,
        canaryOrderReferenceRequired: Bool,
        auditEventRequired: Bool,
        redactedCancelRequestEvidenceRequired: Bool,
        statusRollbackEvidenceRequired: Bool,
        singleCanaryOrderOnlyRequired: Bool,
        failClosedRollbackRequired: Bool
    ) throws {
        for (field, value) in [
            ("upstreamSubmitGateRequired", upstreamSubmitGateRequired),
            ("explicitCancelApprovalRequired", explicitCancelApprovalRequired),
            ("canaryOrderReferenceRequired", canaryOrderReferenceRequired),
            ("auditEventRequired", auditEventRequired),
            ("redactedCancelRequestEvidenceRequired", redactedCancelRequestEvidenceRequired),
            ("statusRollbackEvidenceRequired", statusRollbackEvidenceRequired),
            ("singleCanaryOrderOnlyRequired", singleCanaryOrderOnlyRequired),
            ("failClosedRollbackRequired", failClosedRollbackRequired)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledCancel.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        bulkCancelEnabled: Bool,
        futuresCancelEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardDefaultTradingButtonEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        networkCancelAttempted: Bool,
        createsTagOrRelease: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("bulkCancelEnabled", bulkCancelEnabled),
            ("futuresCancelEnabled", futuresCancelEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardDefaultTradingButtonEnabled", dashboardDefaultTradingButtonEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("networkCancelAttempted", networkCancelAttempted),
            ("createsTagOrRelease", createsTagOrRelease),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledCancel.\(field)"
            )
        }
    }
}
