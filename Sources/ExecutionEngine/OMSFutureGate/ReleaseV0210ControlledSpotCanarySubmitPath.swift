import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0210ControlledSpotCanarySubmitOutcome 固定 GH-1280 的受控 Spot canary
/// submit path 判定结果。
///
/// `authorized` 只表示单笔 Binance Spot canary submit request evidence 已在本地生成并通过
/// idempotency、audit event、redaction 和 strict scope 检查。它不表示已经触发网络请求，也不授权
/// production cutover。
public enum ReleaseV0210ControlledSpotCanarySubmitOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case authorized = "authorized"
    case rejected = "rejected"
}

/// ReleaseV0210ControlledSpotCanarySubmitRejectReason 是 GH-1280 的 fail-closed 拒绝原因。
///
/// 任一前置 gate、operator submit approval、idempotency key、audit event、redacted request
/// 或 symbol / size scope 条件失败，都必须在可执行 submit request evidence 生成前被阻断。
public enum ReleaseV0210ControlledSpotCanarySubmitRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamPreTradeRejected = "upstream pre-trade rejected"
    case explicitSubmitApprovalMissing = "explicit submit approval missing"
    case idempotencyKeyMissing = "idempotency key missing"
    case auditEventMissing = "audit event missing"
    case redactedRequestEvidenceMissing = "redacted request evidence missing"
    case strictSymbolScopeViolated = "strict symbol scope violated"
    case strictSizeScopeViolated = "strict size scope violated"
}

/// ReleaseV0210ControlledSpotCanarySubmitPolicy 描述 GH-1280 单笔受控 canary submit
/// request 的本地输入。
///
/// Policy 只保存可审计的红acted evidence handle 和固定 scope，不保存 raw request payload、
/// credential value、API key、secret、signature 或 endpoint response。
public struct ReleaseV0210ControlledSpotCanarySubmitPolicy:
    Codable, Equatable, Sendable
{
    public let policyID: Identifier
    public let explicitSubmitApprovalGranted: Bool
    public let idempotencyKey: String
    public let auditEventID: Identifier?
    public let redactedRequestDigest: String
    public let redactedRequestEvidenceStored: Bool
    public let requestedSymbol: String
    public let requestedOrderType: ReleaseV0210SpotCanaryHardLimitOrderType
    public let requestedNotionalMinorUnits: Int
    public let requestedQuantityBaseMinorUnits: Int
    public let requestedOrderCountInWindow: Int
    public let singleApprovedOrderOnly: Bool
    public let repeatedAutomatedTradingLoopEnabled: Bool
    public let rawRequestPayloadPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var strictSymbolScopeHeld: Bool {
        requestedSymbol == ReleaseV0210SpotCanaryHardLimitPolicy.requiredAllowedSymbols[0]
    }

    public var strictSizeScopeHeld: Bool {
        requestedOrderType == .limit
            && requestedNotionalMinorUnits <= ReleaseV0210SpotCanaryHardLimitPolicy.requiredMaxNotionalMinorUnits
            && requestedQuantityBaseMinorUnits <= ReleaseV0210SpotCanaryHardLimitPolicy.requiredMaxQuantityBaseMinorUnits
            && requestedOrderCountInWindow == ReleaseV0210SpotCanaryHardLimitPolicy.requiredMaxOrderCountInWindow
    }

    public var idempotencyHeld: Bool {
        idempotencyKey.isEmpty == false
    }

    public var auditEvidenceHeld: Bool {
        auditEventID != nil
            && redactedRequestDigest.hasPrefix(Self.requiredRedactedRequestDigestPrefix)
            && redactedRequestEvidenceStored
    }

    public var forbiddenCapabilitiesClosed: Bool {
        repeatedAutomatedTradingLoopEnabled == false
            && rawRequestPayloadPersisted == false
            && rawCredentialValuePersisted == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && productionCutoverAuthorized == false
    }

    public var policyHeld: Bool {
        singleApprovedOrderOnly
            && auditEvidenceHeld
            && forbiddenCapabilitiesClosed
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1280-v0210-controlled-spot-canary-submit-policy"),
        explicitSubmitApprovalGranted: Bool = true,
        idempotencyKey: String = Self.requiredIdempotencyKey,
        auditEventID: Identifier? = Identifier.constant("gh-1280-v0210-controlled-spot-canary-submit-audit-event"),
        redactedRequestDigest: String = Self.requiredRedactedRequestDigest,
        redactedRequestEvidenceStored: Bool = true,
        requestedSymbol: String = "BTCUSDT",
        requestedOrderType: ReleaseV0210SpotCanaryHardLimitOrderType = .limit,
        requestedNotionalMinorUnits: Int = 500,
        requestedQuantityBaseMinorUnits: Int = 50_000,
        requestedOrderCountInWindow: Int = 1,
        singleApprovedOrderOnly: Bool = true,
        repeatedAutomatedTradingLoopEnabled: Bool = false,
        rawRequestPayloadPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            repeatedAutomatedTradingLoopEnabled: repeatedAutomatedTradingLoopEnabled,
            rawRequestPayloadPersisted: rawRequestPayloadPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.policyID = policyID
        self.explicitSubmitApprovalGranted = explicitSubmitApprovalGranted
        self.idempotencyKey = idempotencyKey
        self.auditEventID = auditEventID
        self.redactedRequestDigest = redactedRequestDigest
        self.redactedRequestEvidenceStored = redactedRequestEvidenceStored
        self.requestedSymbol = requestedSymbol
        self.requestedOrderType = requestedOrderType
        self.requestedNotionalMinorUnits = requestedNotionalMinorUnits
        self.requestedQuantityBaseMinorUnits = requestedQuantityBaseMinorUnits
        self.requestedOrderCountInWindow = requestedOrderCountInWindow
        self.singleApprovedOrderOnly = singleApprovedOrderOnly
        self.repeatedAutomatedTradingLoopEnabled = repeatedAutomatedTradingLoopEnabled
        self.rawRequestPayloadPersisted = rawRequestPayloadPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy()
    }

    public static func approvalMissingFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy(explicitSubmitApprovalGranted: false)
    }

    public static func idempotencyMissingFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy(idempotencyKey: "")
    }

    public static func redactedRequestMissingFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy(redactedRequestEvidenceStored: false)
    }

    public static func symbolRejectedFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy(requestedSymbol: "ETHUSDT")
    }

    public static func sizeRejectedFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPolicy
    {
        try ReleaseV0210ControlledSpotCanarySubmitPolicy(requestedNotionalMinorUnits: 1_001)
    }

    public static let requiredIdempotencyKey =
        "gh-1280-v0210-btcusdt-limit-500-50000-single-submit"
    public static let requiredRedactedRequestDigestPrefix = "sha256:gh-1280-redacted-submit-request"
    public static let requiredRedactedRequestDigest =
        "sha256:gh-1280-redacted-submit-request:BTCUSDT:LIMIT:500:50000"
}

private extension ReleaseV0210ControlledSpotCanarySubmitPolicy {
    static func validateForbiddenFlags(
        repeatedAutomatedTradingLoopEnabled: Bool,
        rawRequestPayloadPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("repeatedAutomatedTradingLoopEnabled", repeatedAutomatedTradingLoopEnabled),
            ("rawRequestPayloadPersisted", rawRequestPayloadPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledSubmit.\(field)"
            )
        }
    }
}

/// ReleaseV0210ControlledSpotCanarySubmitDecision 是 GH-1280 的单笔受控 submit path
/// 判定。
///
/// Decision 必须消费 GH-1279 pre-trade evidence，并在前序 accepted、submit approval、
/// idempotency、audit event、redacted request 和 strict scope 全部成立时，才生成本地
/// submit request evidence。该 evidence 不包含 raw payload，也不直接执行网络提交。
public struct ReleaseV0210ControlledSpotCanarySubmitDecision:
    Codable, Equatable, Sendable
{
    public let decisionID: Identifier
    public let policy: ReleaseV0210ControlledSpotCanarySubmitPolicy
    public let upstreamPreTradeEvidenceID: Identifier
    public let upstreamPreTradeDecisionID: Identifier
    public let upstreamPreTradeOutcome: ReleaseV0210SpotCanaryPreTradePathOutcome
    public let outcome: ReleaseV0210ControlledSpotCanarySubmitOutcome
    public let rejectReasons: [ReleaseV0210ControlledSpotCanarySubmitRejectReason]
    public let canarySubmitAuthorized: Bool
    public let controlledSubmitRequestCreated: Bool
    public let idempotencyKey: String
    public let auditEventID: Identifier?
    public let redactedRequestDigest: String
    public let strictSymbolScopeHeld: Bool
    public let strictSizeScopeHeld: Bool
    public let singleApprovedOrderOnly: Bool
    public let forwardsToCancelRollbackGuard: Bool
    public let networkSubmitAttempted: Bool
    public let repeatedAutomatedTradingLoopEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardDefaultTradingButtonEnabled: Bool
    public let cancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionHeld: Bool {
        rejectReasons == Self.expectedRejectReasons(
            policy: policy,
            upstreamPreTradeDecision: upstreamPreTradeDecisionProxy
        )
            && acceptedOrRejectedStateHeld
            && policy.forbiddenCapabilitiesClosed
            && forbiddenCapabilitiesClosed
    }

    public var acceptedOrRejectedStateHeld: Bool {
        if rejectReasons.isEmpty {
            return outcome == .authorized
                && canarySubmitAuthorized
                && controlledSubmitRequestCreated
                && idempotencyKey.isEmpty == false
                && auditEventID != nil
                && redactedRequestDigest.hasPrefix(
                    ReleaseV0210ControlledSpotCanarySubmitPolicy.requiredRedactedRequestDigestPrefix
                )
                && strictSymbolScopeHeld
                && strictSizeScopeHeld
                && singleApprovedOrderOnly
                && forwardsToCancelRollbackGuard
        }

        return outcome == .rejected
            && canarySubmitAuthorized == false
            && controlledSubmitRequestCreated == false
            && forwardsToCancelRollbackGuard == false
    }

    public var forbiddenCapabilitiesClosed: Bool {
        networkSubmitAttempted == false
            && repeatedAutomatedTradingLoopEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardDefaultTradingButtonEnabled == false
            && cancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    private var upstreamPreTradeDecisionProxy: ReleaseV0210SpotCanaryPreTradePathDecisionProxy {
        ReleaseV0210SpotCanaryPreTradePathDecisionProxy(outcome: upstreamPreTradeOutcome)
    }

    public init(
        decisionID: Identifier? = nil,
        policy: ReleaseV0210ControlledSpotCanarySubmitPolicy,
        upstreamPreTradeEvidence: ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence,
        upstreamPreTradeDecision: ReleaseV0210SpotCanaryPreTradePathDecision? = nil,
        networkSubmitAttempted: Bool = false,
        repeatedAutomatedTradingLoopEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardDefaultTradingButtonEnabled: Bool = false,
        cancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamPreTradeEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledSubmit.upstreamPreTradeEvidence",
                expected: "GH-1279 pre-trade evidence held",
                actual: upstreamPreTradeEvidence.issueID.rawValue
            )
        }

        try Self.validateForbiddenFlags(
            networkSubmitAttempted: networkSubmitAttempted,
            repeatedAutomatedTradingLoopEnabled: repeatedAutomatedTradingLoopEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardDefaultTradingButtonEnabled: dashboardDefaultTradingButtonEnabled,
            cancelReplaceEnabled: cancelReplaceEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        let resolvedPreTradeDecision = upstreamPreTradeDecision
            ?? upstreamPreTradeEvidence.acceptedDecision
        let reasons = Self.expectedRejectReasons(
            policy: policy,
            upstreamPreTradeDecision: resolvedPreTradeDecision
        )
        let resolvedOutcome: ReleaseV0210ControlledSpotCanarySubmitOutcome =
            reasons.isEmpty ? .authorized : .rejected
        let authorized = reasons.isEmpty

        self.decisionID = decisionID
            ?? Self.deterministicID(
                policy: policy,
                upstreamPreTradeDecision: resolvedPreTradeDecision,
                outcome: resolvedOutcome
            )
        self.policy = policy
        self.upstreamPreTradeEvidenceID = upstreamPreTradeEvidence.evidenceID
        self.upstreamPreTradeDecisionID = resolvedPreTradeDecision.decisionID
        self.upstreamPreTradeOutcome = resolvedPreTradeDecision.outcome
        self.outcome = resolvedOutcome
        self.rejectReasons = reasons
        self.canarySubmitAuthorized = authorized
        self.controlledSubmitRequestCreated = authorized
        self.idempotencyKey = policy.idempotencyKey
        self.auditEventID = policy.auditEventID
        self.redactedRequestDigest = policy.redactedRequestDigest
        self.strictSymbolScopeHeld = policy.strictSymbolScopeHeld
        self.strictSizeScopeHeld = policy.strictSizeScopeHeld
        self.singleApprovedOrderOnly = policy.singleApprovedOrderOnly
        self.forwardsToCancelRollbackGuard = authorized
        self.networkSubmitAttempted = networkSubmitAttempted
        self.repeatedAutomatedTradingLoopEnabled = repeatedAutomatedTradingLoopEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardDefaultTradingButtonEnabled = dashboardDefaultTradingButtonEnabled
        self.cancelReplaceEnabled = cancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0210ControlledSpotCanarySubmitPolicy,
        upstreamPreTradeDecision: ReleaseV0210SpotCanaryPreTradePathDecision
    ) -> [ReleaseV0210ControlledSpotCanarySubmitRejectReason] {
        expectedRejectReasons(
            policy: policy,
            upstreamPreTradeDecision: ReleaseV0210SpotCanaryPreTradePathDecisionProxy(
                outcome: upstreamPreTradeDecision.outcome
            )
        )
    }

    private static func expectedRejectReasons(
        policy: ReleaseV0210ControlledSpotCanarySubmitPolicy,
        upstreamPreTradeDecision: ReleaseV0210SpotCanaryPreTradePathDecisionProxy
    ) -> [ReleaseV0210ControlledSpotCanarySubmitRejectReason] {
        var reasons: [ReleaseV0210ControlledSpotCanarySubmitRejectReason] = []
        if upstreamPreTradeDecision.outcome != .accepted {
            reasons.append(.upstreamPreTradeRejected)
        }
        if policy.explicitSubmitApprovalGranted == false {
            reasons.append(.explicitSubmitApprovalMissing)
        }
        if policy.idempotencyHeld == false {
            reasons.append(.idempotencyKeyMissing)
        }
        if policy.auditEventID == nil {
            reasons.append(.auditEventMissing)
        }
        if policy.redactedRequestEvidenceStored == false {
            reasons.append(.redactedRequestEvidenceMissing)
        }
        if policy.strictSymbolScopeHeld == false {
            reasons.append(.strictSymbolScopeViolated)
        }
        if policy.strictSizeScopeHeld == false {
            reasons.append(.strictSizeScopeViolated)
        }
        return reasons
    }

    public static func deterministicID(
        policy: ReleaseV0210ControlledSpotCanarySubmitPolicy,
        upstreamPreTradeDecision: ReleaseV0210SpotCanaryPreTradePathDecision,
        outcome: ReleaseV0210ControlledSpotCanarySubmitOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1280-v0210-controlled-spot-canary-submit-decision",
                upstreamPreTradeDecision.decisionID.rawValue,
                policy.idempotencyKey.isEmpty ? "missing-idempotency" : policy.idempotencyKey,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.controlledSubmit.decisionID"
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT",
        "TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT",
        "V0210-008-CONTROLLED-SPOT-CANARY-SUBMIT",
        "V0210-008-IDEMPOTENCY-KEY",
        "V0210-008-AUDIT-EVENT",
        "V0210-008-REDACTED-REQUEST-EVIDENCE",
        "V0210-008-STRICT-SYMBOL-SIZE-SCOPE",
        "V0210-008-SINGLE-APPROVED-ORDER",
        "V0210-008-NO-REPEATED-AUTOMATION-LOOP",
        "V0210-008-NO-PRODUCTION-CUTOVER"
    ]
}

private struct ReleaseV0210SpotCanaryPreTradePathDecisionProxy {
    let outcome: ReleaseV0210SpotCanaryPreTradePathOutcome
}

private extension ReleaseV0210ControlledSpotCanarySubmitDecision {
    static func validateForbiddenFlags(
        networkSubmitAttempted: Bool,
        repeatedAutomatedTradingLoopEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardDefaultTradingButtonEnabled: Bool,
        cancelReplaceEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("networkSubmitAttempted", networkSubmitAttempted),
            ("repeatedAutomatedTradingLoopEnabled", repeatedAutomatedTradingLoopEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardDefaultTradingButtonEnabled", dashboardDefaultTradingButtonEnabled),
            ("cancelReplaceEnabled", cancelReplaceEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledSubmit.\(field)"
            )
        }
    }
}

/// ReleaseV0210ControlledSpotCanarySubmitPathEvidence 是 GH-1280 的受控 Spot canary
/// submit path 证据。
///
/// Evidence 只证明：前序 GH-1279 gate 通过后，系统可以生成单笔、幂等、脱敏、带 audit event
/// 的 Binance Spot canary submit request evidence。它不默认启用生产交易，不直接连接生产 endpoint，
/// 不读取 secret value，不发送真实订单。
public struct ReleaseV0210ControlledSpotCanarySubmitPathEvidence:
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
    public let upstreamPreTradeEvidence: ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence
    public let acceptedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let upstreamRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let approvalRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let idempotencyRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let redactionRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let symbolRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let sizeRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let allPreviousGatesRequired: Bool
    public let explicitSubmitApprovalRequired: Bool
    public let idempotencyKeyRequired: Bool
    public let auditEventRequired: Bool
    public let redactedRequestEvidenceRequired: Bool
    public let strictSymbolSizeScopeRequired: Bool
    public let singleApprovedOrderOnlyRequired: Bool
    public let failClosedForEveryRejection: Bool
    public let repeatedAutomatedTradingLoopEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardDefaultTradingButtonEnabled: Bool
    public let cancelReplaceEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let networkSubmitAttempted: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1280"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1279"]
            && downstreamIssueID.rawValue == "GH-1281"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamPreTradeEvidence.evidenceHeld
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
        allPreviousGatesRequired
            && explicitSubmitApprovalRequired
            && idempotencyKeyRequired
            && auditEventRequired
            && redactedRequestEvidenceRequired
            && strictSymbolSizeScopeRequired
            && singleApprovedOrderOnlyRequired
            && failClosedForEveryRejection
    }

    public var decisionEvidenceHeld: Bool {
        acceptedDecision.decisionHeld
            && acceptedDecision.outcome == .authorized
            && acceptedDecision.canarySubmitAuthorized
            && acceptedDecision.controlledSubmitRequestCreated
            && upstreamRejectedDecision.rejectReasons == [.upstreamPreTradeRejected]
            && approvalRejectedDecision.rejectReasons == [.explicitSubmitApprovalMissing]
            && idempotencyRejectedDecision.rejectReasons == [.idempotencyKeyMissing]
            && redactionRejectedDecision.rejectReasons == [.redactedRequestEvidenceMissing]
            && symbolRejectedDecision.rejectReasons == [.strictSymbolScopeViolated]
            && sizeRejectedDecision.rejectReasons == [.strictSizeScopeViolated]
            && [
                upstreamRejectedDecision,
                approvalRejectedDecision,
                idempotencyRejectedDecision,
                redactionRejectedDecision,
                symbolRejectedDecision,
                sizeRejectedDecision
            ].allSatisfy {
                $0.decisionHeld
                    && $0.outcome == .rejected
                    && $0.canarySubmitAuthorized == false
                    && $0.controlledSubmitRequestCreated == false
            }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        repeatedAutomatedTradingLoopEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardDefaultTradingButtonEnabled == false
            && cancelReplaceEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && networkSubmitAttempted == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1280-release-v0.21.0-controlled-spot-canary-submit-path-evidence"),
        issueID: Identifier = Identifier.constant("GH-1280"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1279")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1281"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamPreTradeEvidence: ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        allPreviousGatesRequired: Bool = true,
        explicitSubmitApprovalRequired: Bool = true,
        idempotencyKeyRequired: Bool = true,
        auditEventRequired: Bool = true,
        redactedRequestEvidenceRequired: Bool = true,
        strictSymbolSizeScopeRequired: Bool = true,
        singleApprovedOrderOnlyRequired: Bool = true,
        failClosedForEveryRejection: Bool = true,
        repeatedAutomatedTradingLoopEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardDefaultTradingButtonEnabled: Bool = false,
        cancelReplaceEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        networkSubmitAttempted: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedPreTradeEvidence = try upstreamPreTradeEvidence
            ?? ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence.deterministicFixture()
        let accepted = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .deterministicFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
        )
        let upstreamRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .deterministicFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence,
            upstreamPreTradeDecision: resolvedPreTradeEvidence.riskRejectedDecision
        )
        let approvalRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .approvalMissingFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
        )
        let idempotencyRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .idempotencyMissingFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
        )
        let redactionRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .redactedRequestMissingFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
        )
        let symbolRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .symbolRejectedFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
        )
        let sizeRejected = try ReleaseV0210ControlledSpotCanarySubmitDecision(
            policy: .sizeRejectedFixture(),
            upstreamPreTradeEvidence: resolvedPreTradeEvidence
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
            upstreamPreTradeEvidence: resolvedPreTradeEvidence,
            acceptedDecision: accepted,
            upstreamRejectedDecision: upstreamRejected,
            approvalRejectedDecision: approvalRejected,
            idempotencyRejectedDecision: idempotencyRejected,
            redactionRejectedDecision: redactionRejected,
            symbolRejectedDecision: symbolRejected,
            sizeRejectedDecision: sizeRejected,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            allPreviousGatesRequired: allPreviousGatesRequired,
            explicitSubmitApprovalRequired: explicitSubmitApprovalRequired,
            idempotencyKeyRequired: idempotencyKeyRequired,
            auditEventRequired: auditEventRequired,
            redactedRequestEvidenceRequired: redactedRequestEvidenceRequired,
            strictSymbolSizeScopeRequired: strictSymbolSizeScopeRequired,
            singleApprovedOrderOnlyRequired: singleApprovedOrderOnlyRequired,
            failClosedForEveryRejection: failClosedForEveryRejection
        )
        try Self.validateForbiddenFlags(
            repeatedAutomatedTradingLoopEnabled: repeatedAutomatedTradingLoopEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardDefaultTradingButtonEnabled: dashboardDefaultTradingButtonEnabled,
            cancelReplaceEnabled: cancelReplaceEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            networkSubmitAttempted: networkSubmitAttempted,
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
        self.upstreamPreTradeEvidence = resolvedPreTradeEvidence
        self.acceptedDecision = accepted
        self.upstreamRejectedDecision = upstreamRejected
        self.approvalRejectedDecision = approvalRejected
        self.idempotencyRejectedDecision = idempotencyRejected
        self.redactionRejectedDecision = redactionRejected
        self.symbolRejectedDecision = symbolRejected
        self.sizeRejectedDecision = sizeRejected
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.allPreviousGatesRequired = allPreviousGatesRequired
        self.explicitSubmitApprovalRequired = explicitSubmitApprovalRequired
        self.idempotencyKeyRequired = idempotencyKeyRequired
        self.auditEventRequired = auditEventRequired
        self.redactedRequestEvidenceRequired = redactedRequestEvidenceRequired
        self.strictSymbolSizeScopeRequired = strictSymbolSizeScopeRequired
        self.singleApprovedOrderOnlyRequired = singleApprovedOrderOnlyRequired
        self.failClosedForEveryRejection = failClosedForEveryRejection
        self.repeatedAutomatedTradingLoopEnabled = repeatedAutomatedTradingLoopEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardDefaultTradingButtonEnabled = dashboardDefaultTradingButtonEnabled
        self.cancelReplaceEnabled = cancelReplaceEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.networkSubmitAttempted = networkSubmitAttempted
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210ControlledSpotCanarySubmitPathEvidence
    {
        try ReleaseV0210ControlledSpotCanarySubmitPathEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors =
        ReleaseV0210ControlledSpotCanarySubmitDecision.requiredValidationAnchors

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1280ReleaseV0210ControlledSpotCanarySubmitPath",
        "bash checks/verify-v0.21.0-controlled-spot-canary-submit.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210ControlledSpotCanarySubmitPathEvidence {
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
        upstreamPreTradeEvidence: ReleaseV0210SpotCanaryRiskKillNoTradePreTradeGateEvidence,
        acceptedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        upstreamRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        approvalRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        idempotencyRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        redactionRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        symbolRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        sizeRejectedDecision: ReleaseV0210ControlledSpotCanarySubmitDecision,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1280", "GH-1280", issueID.rawValue),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-1279"], "GH-1279", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1281", "GH-1281", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            ("tradingEnvironment", tradingEnvironment == .productionLive, ReleaseV0181TradingEnvironment.productionLive.rawValue, tradingEnvironment.rawValue),
            ("upstreamPreTradeEvidence", upstreamPreTradeEvidence.evidenceHeld, "GH-1279 pre-trade evidence held", upstreamPreTradeEvidence.issueID.rawValue),
            ("acceptedDecision", acceptedDecision.decisionHeld && acceptedDecision.outcome == .authorized, "authorized submit decision", acceptedDecision.outcome.rawValue),
            ("upstreamRejectedDecision", upstreamRejectedDecision.rejectReasons == [.upstreamPreTradeRejected], "upstream pre-trade rejection", upstreamRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("approvalRejectedDecision", approvalRejectedDecision.rejectReasons == [.explicitSubmitApprovalMissing], "approval rejection", approvalRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("idempotencyRejectedDecision", idempotencyRejectedDecision.rejectReasons == [.idempotencyKeyMissing], "idempotency rejection", idempotencyRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("redactionRejectedDecision", redactionRejectedDecision.rejectReasons == [.redactedRequestEvidenceMissing], "redaction rejection", redactionRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("symbolRejectedDecision", symbolRejectedDecision.rejectReasons == [.strictSymbolScopeViolated], "symbol rejection", symbolRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("sizeRejectedDecision", sizeRejectedDecision.rejectReasons == [.strictSizeScopeViolated], "size rejection", sizeRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledSubmit.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        allPreviousGatesRequired: Bool,
        explicitSubmitApprovalRequired: Bool,
        idempotencyKeyRequired: Bool,
        auditEventRequired: Bool,
        redactedRequestEvidenceRequired: Bool,
        strictSymbolSizeScopeRequired: Bool,
        singleApprovedOrderOnlyRequired: Bool,
        failClosedForEveryRejection: Bool
    ) throws {
        for (field, value) in [
            ("allPreviousGatesRequired", allPreviousGatesRequired),
            ("explicitSubmitApprovalRequired", explicitSubmitApprovalRequired),
            ("idempotencyKeyRequired", idempotencyKeyRequired),
            ("auditEventRequired", auditEventRequired),
            ("redactedRequestEvidenceRequired", redactedRequestEvidenceRequired),
            ("strictSymbolSizeScopeRequired", strictSymbolSizeScopeRequired),
            ("singleApprovedOrderOnlyRequired", singleApprovedOrderOnlyRequired),
            ("failClosedForEveryRejection", failClosedForEveryRejection)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.controlledSubmit.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        repeatedAutomatedTradingLoopEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardDefaultTradingButtonEnabled: Bool,
        cancelReplaceEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        networkSubmitAttempted: Bool,
        createsTagOrRelease: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("repeatedAutomatedTradingLoopEnabled", repeatedAutomatedTradingLoopEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardDefaultTradingButtonEnabled", dashboardDefaultTradingButtonEnabled),
            ("cancelReplaceEnabled", cancelReplaceEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("networkSubmitAttempted", networkSubmitAttempted),
            ("createsTagOrRelease", createsTagOrRelease),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.controlledSubmit.\(field)"
            )
        }
    }
}
