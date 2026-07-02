import DomainModel
import Foundation

/// ReleaseV0210SpotCanaryHardLimitOrderType 固定 GH-1278 允许进入
/// Binance Spot canary hard limit pre-trade gate 的订单类型。
///
/// v0.21.0 只允许小额度 Spot canary 的限价意图通过 hard-limit eligibility。
/// 本类型不实现 submit / cancel / replace，也不触达 broker endpoint。
public enum ReleaseV0210SpotCanaryHardLimitOrderType:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case limit = "LIMIT"
    case market = "MARKET"
    case stopLoss = "STOP_LOSS"
}

/// ReleaseV0210SpotCanaryHardLimitDecisionOutcome 表达 hard limit gate 的本地判定结果。
public enum ReleaseV0210SpotCanaryHardLimitDecisionOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case accepted = "accepted"
    case rejected = "rejected"
}

/// ReleaseV0210SpotCanaryHardLimitRejectReason 固定 GH-1278 的 fail-closed 拒绝原因。
///
/// 任何 symbol、notional、quantity、order type、order count 或 time window 漂移都
/// 必须在产生 canary order artifact 之前被拒绝。
public enum ReleaseV0210SpotCanaryHardLimitRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case symbolNotAllowed = "symbol not allowed"
    case notionalLimitExceeded = "notional limit exceeded"
    case quantityLimitExceeded = "quantity limit exceeded"
    case orderTypeNotAllowed = "order type not allowed"
    case orderCountLimitExceeded = "order count limit exceeded"
    case timeWindowClosed = "time window closed"
}

/// ReleaseV0210SpotCanaryHardLimitPolicy 固定 GH-1278 的 Binance Spot canary
/// hard limits。
///
/// Policy 使用 deterministic fixed-point integer limits，避免在 hard limit gate 中引入
/// 浮点舍入或 venue adapter 依赖。它只描述 eligibility，不授权真实下单。
public struct ReleaseV0210SpotCanaryHardLimitPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let allowedSymbols: [String]
    public let allowedOrderTypes: [ReleaseV0210SpotCanaryHardLimitOrderType]
    public let maxNotionalMinorUnits: Int
    public let maxQuantityBaseMinorUnits: Int
    public let maxOrderCountInWindow: Int
    public let windowSeconds: Int
    public let notionalMinorUnitScale: Int
    public let quantityBaseMinorUnitScale: Int
    public let quoteAsset: String
    public let baseAsset: String

    public var policyHeld: Bool {
        allowedSymbols == Self.requiredAllowedSymbols
            && allowedOrderTypes == Self.requiredAllowedOrderTypes
            && maxNotionalMinorUnits == Self.requiredMaxNotionalMinorUnits
            && maxQuantityBaseMinorUnits == Self.requiredMaxQuantityBaseMinorUnits
            && maxOrderCountInWindow == Self.requiredMaxOrderCountInWindow
            && windowSeconds == Self.requiredWindowSeconds
            && notionalMinorUnitScale == Self.requiredNotionalMinorUnitScale
            && quantityBaseMinorUnitScale == Self.requiredQuantityBaseMinorUnitScale
            && quoteAsset == "USDT"
            && baseAsset == "BTC"
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1278-v0210-binance-spot-canary-hard-limit-policy"),
        allowedSymbols: [String] = Self.requiredAllowedSymbols,
        allowedOrderTypes: [ReleaseV0210SpotCanaryHardLimitOrderType] = Self.requiredAllowedOrderTypes,
        maxNotionalMinorUnits: Int = Self.requiredMaxNotionalMinorUnits,
        maxQuantityBaseMinorUnits: Int = Self.requiredMaxQuantityBaseMinorUnits,
        maxOrderCountInWindow: Int = Self.requiredMaxOrderCountInWindow,
        windowSeconds: Int = Self.requiredWindowSeconds,
        notionalMinorUnitScale: Int = Self.requiredNotionalMinorUnitScale,
        quantityBaseMinorUnitScale: Int = Self.requiredQuantityBaseMinorUnitScale,
        quoteAsset: String = "USDT",
        baseAsset: String = "BTC"
    ) throws {
        let policy = Self(
            uncheckedPolicyID: policyID,
            allowedSymbols: allowedSymbols,
            allowedOrderTypes: allowedOrderTypes,
            maxNotionalMinorUnits: maxNotionalMinorUnits,
            maxQuantityBaseMinorUnits: maxQuantityBaseMinorUnits,
            maxOrderCountInWindow: maxOrderCountInWindow,
            windowSeconds: windowSeconds,
            notionalMinorUnitScale: notionalMinorUnitScale,
            quantityBaseMinorUnitScale: quantityBaseMinorUnitScale,
            quoteAsset: quoteAsset,
            baseAsset: baseAsset
        )
        guard policy.policyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryHardLimits.policy",
                expected: Self.requiredPolicySummary,
                actual: policy.policySummary
            )
        }
        self = policy
    }

    private init(
        uncheckedPolicyID policyID: Identifier,
        allowedSymbols: [String],
        allowedOrderTypes: [ReleaseV0210SpotCanaryHardLimitOrderType],
        maxNotionalMinorUnits: Int,
        maxQuantityBaseMinorUnits: Int,
        maxOrderCountInWindow: Int,
        windowSeconds: Int,
        notionalMinorUnitScale: Int,
        quantityBaseMinorUnitScale: Int,
        quoteAsset: String,
        baseAsset: String
    ) {
        self.policyID = policyID
        self.allowedSymbols = allowedSymbols
        self.allowedOrderTypes = allowedOrderTypes
        self.maxNotionalMinorUnits = maxNotionalMinorUnits
        self.maxQuantityBaseMinorUnits = maxQuantityBaseMinorUnits
        self.maxOrderCountInWindow = maxOrderCountInWindow
        self.windowSeconds = windowSeconds
        self.notionalMinorUnitScale = notionalMinorUnitScale
        self.quantityBaseMinorUnitScale = quantityBaseMinorUnitScale
        self.quoteAsset = quoteAsset
        self.baseAsset = baseAsset
    }

    public func evaluate(
        candidate: ReleaseV0210SpotCanaryHardLimitOrderCandidate,
        upstreamEvidence: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence
    ) throws -> ReleaseV0210SpotCanaryHardLimitDecision {
        try ReleaseV0210SpotCanaryHardLimitDecision(
            policy: self,
            candidate: candidate,
            upstreamSnapshotEvidence: upstreamEvidence
        )
    }

    public static func deterministicFixture() throws -> ReleaseV0210SpotCanaryHardLimitPolicy {
        try ReleaseV0210SpotCanaryHardLimitPolicy()
    }

    public static let requiredAllowedSymbols = ["BTCUSDT"]
    public static let requiredAllowedOrderTypes = [ReleaseV0210SpotCanaryHardLimitOrderType.limit]
    public static let requiredMaxNotionalMinorUnits = 1_000
    public static let requiredMaxQuantityBaseMinorUnits = 100_000
    public static let requiredMaxOrderCountInWindow = 1
    public static let requiredWindowSeconds = 300
    public static let requiredNotionalMinorUnitScale = 2
    public static let requiredQuantityBaseMinorUnitScale = 8
    public static let requiredPolicySummary =
        "symbol=BTCUSDT; orderType=LIMIT; maxNotionalMinorUnits=1000; maxQuantityBaseMinorUnits=100000; maxOrderCountInWindow=1; windowSeconds=300"

    public var policySummary: String {
        [
            "symbol=\(allowedSymbols.joined(separator: ","))",
            "orderType=\(allowedOrderTypes.map(\.rawValue).joined(separator: ","))",
            "maxNotionalMinorUnits=\(maxNotionalMinorUnits)",
            "maxQuantityBaseMinorUnits=\(maxQuantityBaseMinorUnits)",
            "maxOrderCountInWindow=\(maxOrderCountInWindow)",
            "windowSeconds=\(windowSeconds)"
        ].joined(separator: "; ")
    }
}

/// ReleaseV0210SpotCanaryHardLimitOrderCandidate 是 GH-1278 的本地 canary
/// order eligibility 输入。
///
/// Candidate 不是 broker order，不包含 endpoint、signature、credential value、account id
/// 或 raw order payload；它只用于 hard-limit pre-trade gate 的本地判断。
public struct ReleaseV0210SpotCanaryHardLimitOrderCandidate: Codable, Equatable, Sendable {
    public let candidateID: Identifier
    public let symbol: String
    public let orderType: ReleaseV0210SpotCanaryHardLimitOrderType
    public let notionalMinorUnits: Int
    public let quantityBaseMinorUnits: Int
    public let orderCountInWindow: Int
    public let windowStartedAtUnixSeconds: Int
    public let requestedAtUnixSeconds: Int

    public var ageWithinWindowSeconds: Int {
        requestedAtUnixSeconds - windowStartedAtUnixSeconds
    }

    public init(
        candidateID: Identifier? = nil,
        symbol: String = "BTCUSDT",
        orderType: ReleaseV0210SpotCanaryHardLimitOrderType = .limit,
        notionalMinorUnits: Int = 500,
        quantityBaseMinorUnits: Int = 50_000,
        orderCountInWindow: Int = 1,
        windowStartedAtUnixSeconds: Int = 1_772_582_400,
        requestedAtUnixSeconds: Int = 1_772_582_460
    ) {
        let resolvedID = candidateID
            ?? Self.deterministicID(
                symbol: symbol,
                orderType: orderType,
                notionalMinorUnits: notionalMinorUnits,
                quantityBaseMinorUnits: quantityBaseMinorUnits,
                orderCountInWindow: orderCountInWindow,
                requestedAtUnixSeconds: requestedAtUnixSeconds
            )
        self.candidateID = resolvedID
        self.symbol = symbol
        self.orderType = orderType
        self.notionalMinorUnits = notionalMinorUnits
        self.quantityBaseMinorUnits = quantityBaseMinorUnits
        self.orderCountInWindow = orderCountInWindow
        self.windowStartedAtUnixSeconds = windowStartedAtUnixSeconds
        self.requestedAtUnixSeconds = requestedAtUnixSeconds
    }

    public static func acceptedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate()
    }

    public static func symbolRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(symbol: "ETHUSDT")
    }

    public static func notionalRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(notionalMinorUnits: 1_001)
    }

    public static func quantityRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(quantityBaseMinorUnits: 100_001)
    }

    public static func orderTypeRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(orderType: .market)
    }

    public static func orderCountRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(orderCountInWindow: 2)
    }

    public static func timeWindowRejectedFixture() -> ReleaseV0210SpotCanaryHardLimitOrderCandidate {
        ReleaseV0210SpotCanaryHardLimitOrderCandidate(requestedAtUnixSeconds: 1_772_582_701)
    }

    public static func deterministicID(
        symbol: String,
        orderType: ReleaseV0210SpotCanaryHardLimitOrderType,
        notionalMinorUnits: Int,
        quantityBaseMinorUnits: Int,
        orderCountInWindow: Int,
        requestedAtUnixSeconds: Int
    ) -> Identifier {
        .constant(
            [
                "gh-1278-v0210-canary-hard-limit-candidate",
                symbol,
                orderType.rawValue,
                "\(notionalMinorUnits)",
                "\(quantityBaseMinorUnits)",
                "\(orderCountInWindow)",
                "\(requestedAtUnixSeconds)"
            ].joined(separator: ":"),
            field: "releaseV0210.canaryHardLimits.candidateID"
        )
    }
}

/// ReleaseV0210SpotCanaryHardLimitDecision 是 GH-1278 的 deterministic
/// pre-trade gate 判定。
public struct ReleaseV0210SpotCanaryHardLimitDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let policy: ReleaseV0210SpotCanaryHardLimitPolicy
    public let candidate: ReleaseV0210SpotCanaryHardLimitOrderCandidate
    public let upstreamSnapshotEvidenceID: Identifier
    public let outcome: ReleaseV0210SpotCanaryHardLimitDecisionOutcome
    public let rejectReasons: [ReleaseV0210SpotCanaryHardLimitRejectReason]
    public let canaryOrderCreationEligible: Bool
    public let forwardsToExecutionEngine: Bool
    public let adapterSubmitEligible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionHeld: Bool {
        policy.policyHeld
            && upstreamSnapshotEvidenceID.rawValue == "gh-1277-release-v0.21.0-live-account-snapshot-redaction-evidence"
            && rejectReasons == Self.expectedRejectReasons(policy: policy, candidate: candidate)
            && acceptedOrRejectedStateHeld
            && forwardsToExecutionEngine == false
            && adapterSubmitEligible == false
            && submitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public var acceptedOrRejectedStateHeld: Bool {
        if rejectReasons.isEmpty {
            return outcome == .accepted && canaryOrderCreationEligible
        }
        return outcome == .rejected && canaryOrderCreationEligible == false
    }

    public init(
        decisionID: Identifier? = nil,
        policy: ReleaseV0210SpotCanaryHardLimitPolicy,
        candidate: ReleaseV0210SpotCanaryHardLimitOrderCandidate,
        upstreamSnapshotEvidence: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence,
        forwardsToExecutionEngine: Bool = false,
        adapterSubmitEligible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamSnapshotEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryHardLimits.upstreamSnapshotEvidence",
                expected: "GH-1277 redacted live account snapshot evidence held",
                actual: upstreamSnapshotEvidence.issueID.rawValue
            )
        }
        for (field, value) in [
            ("forwardsToExecutionEngine", forwardsToExecutionEngine),
            ("adapterSubmitEligible", adapterSubmitEligible),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.canaryHardLimits.\(field)"
            )
        }
        let resolvedRejectReasons = Self.expectedRejectReasons(policy: policy, candidate: candidate)
        let resolvedOutcome: ReleaseV0210SpotCanaryHardLimitDecisionOutcome =
            resolvedRejectReasons.isEmpty ? .accepted : .rejected
        self.decisionID = decisionID
            ?? Self.deterministicID(candidate: candidate, outcome: resolvedOutcome)
        self.policy = policy
        self.candidate = candidate
        self.upstreamSnapshotEvidenceID = upstreamSnapshotEvidence.evidenceID
        self.outcome = resolvedOutcome
        self.rejectReasons = resolvedRejectReasons
        self.canaryOrderCreationEligible = resolvedRejectReasons.isEmpty
        self.forwardsToExecutionEngine = forwardsToExecutionEngine
        self.adapterSubmitEligible = adapterSubmitEligible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0210SpotCanaryHardLimitPolicy,
        candidate: ReleaseV0210SpotCanaryHardLimitOrderCandidate
    ) -> [ReleaseV0210SpotCanaryHardLimitRejectReason] {
        var reasons: [ReleaseV0210SpotCanaryHardLimitRejectReason] = []
        if policy.allowedSymbols.contains(candidate.symbol) == false {
            reasons.append(.symbolNotAllowed)
        }
        if candidate.notionalMinorUnits > policy.maxNotionalMinorUnits {
            reasons.append(.notionalLimitExceeded)
        }
        if candidate.quantityBaseMinorUnits > policy.maxQuantityBaseMinorUnits {
            reasons.append(.quantityLimitExceeded)
        }
        if policy.allowedOrderTypes.contains(candidate.orderType) == false {
            reasons.append(.orderTypeNotAllowed)
        }
        if candidate.orderCountInWindow > policy.maxOrderCountInWindow {
            reasons.append(.orderCountLimitExceeded)
        }
        if candidate.ageWithinWindowSeconds < 0 || candidate.ageWithinWindowSeconds > policy.windowSeconds {
            reasons.append(.timeWindowClosed)
        }
        return reasons
    }

    public static func deterministicID(
        candidate: ReleaseV0210SpotCanaryHardLimitOrderCandidate,
        outcome: ReleaseV0210SpotCanaryHardLimitDecisionOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1278-v0210-canary-hard-limit-decision",
                candidate.candidateID.rawValue,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.canaryHardLimits.decisionID"
        )
    }
}

/// ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence 是 GH-1278 的
/// canary symbol / notional / order type hard limits 证据。
///
/// Gate 消费 GH-1277 redacted live account snapshot artifact；只输出本地 hard-limit
/// eligibility 和 fail-closed rejection evidence。它不实现 order creation runtime、不连接
/// Binance endpoint、不提交 / 取消 / 替换订单，也不授权 production cutover。
public struct ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence:
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
    public let upstreamSnapshotEvidence: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence
    public let policy: ReleaseV0210SpotCanaryHardLimitPolicy
    public let acceptedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let symbolRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let notionalRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let quantityRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let orderTypeRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let orderCountRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let timeWindowRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let redactedLiveAccountSnapshotConsumed: Bool
    public let symbolAllowlistEnforced: Bool
    public let notionalCapEnforced: Bool
    public let quantityCapEnforced: Bool
    public let orderTypeAllowlistEnforced: Bool
    public let orderCountCapEnforced: Bool
    public let timeWindowLimitEnforced: Bool
    public let preTradeFailClosedBeforeOrderCreation: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let rawOrderPayloadPersisted: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1278"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1276", "GH-1277"]
            && downstreamIssueID.rawValue == "GH-1279"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamSnapshotEvidence.evidenceHeld
            && policy.policyHeld
            && acceptedDecision.decisionHeld
            && rejectionEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && hardLimitControlsHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var hardLimitControlsHeld: Bool {
        redactedLiveAccountSnapshotConsumed
            && symbolAllowlistEnforced
            && notionalCapEnforced
            && quantityCapEnforced
            && orderTypeAllowlistEnforced
            && orderCountCapEnforced
            && timeWindowLimitEnforced
            && preTradeFailClosedBeforeOrderCreation
    }

    public var rejectionEvidenceHeld: Bool {
        symbolRejectedDecision.rejectReasons == [.symbolNotAllowed]
            && notionalRejectedDecision.rejectReasons == [.notionalLimitExceeded]
            && quantityRejectedDecision.rejectReasons == [.quantityLimitExceeded]
            && orderTypeRejectedDecision.rejectReasons == [.orderTypeNotAllowed]
            && orderCountRejectedDecision.rejectReasons == [.orderCountLimitExceeded]
            && timeWindowRejectedDecision.rejectReasons == [.timeWindowClosed]
            && [
                symbolRejectedDecision,
                notionalRejectedDecision,
                quantityRejectedDecision,
                orderTypeRejectedDecision,
                orderCountRejectedDecision,
                timeWindowRejectedDecision
            ].allSatisfy { $0.decisionHeld && $0.outcome == .rejected && $0.canaryOrderCreationEligible == false }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && rawOrderPayloadPersisted == false
            && orderEndpointTouched == false
            && submitCancelReplaceEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1278-release-v0.21.0-canary-hard-limit-pre-trade-gate-evidence"),
        issueID: Identifier = Identifier.constant("GH-1278"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1276"), Identifier.constant("GH-1277")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1279"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamSnapshotEvidence: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence? = nil,
        policy: ReleaseV0210SpotCanaryHardLimitPolicy? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        redactedLiveAccountSnapshotConsumed: Bool = true,
        symbolAllowlistEnforced: Bool = true,
        notionalCapEnforced: Bool = true,
        quantityCapEnforced: Bool = true,
        orderTypeAllowlistEnforced: Bool = true,
        orderCountCapEnforced: Bool = true,
        timeWindowLimitEnforced: Bool = true,
        preTradeFailClosedBeforeOrderCreation: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        rawOrderPayloadPersisted: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedSnapshot = try upstreamSnapshotEvidence
            ?? ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence.deterministicFixture()
        let resolvedPolicy = try policy ?? ReleaseV0210SpotCanaryHardLimitPolicy()

        let accepted = try resolvedPolicy.evaluate(
            candidate: .acceptedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let symbolRejected = try resolvedPolicy.evaluate(
            candidate: .symbolRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let notionalRejected = try resolvedPolicy.evaluate(
            candidate: .notionalRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let quantityRejected = try resolvedPolicy.evaluate(
            candidate: .quantityRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let orderTypeRejected = try resolvedPolicy.evaluate(
            candidate: .orderTypeRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let orderCountRejected = try resolvedPolicy.evaluate(
            candidate: .orderCountRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
        )
        let timeWindowRejected = try resolvedPolicy.evaluate(
            candidate: .timeWindowRejectedFixture(),
            upstreamEvidence: resolvedSnapshot
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
            upstreamSnapshotEvidence: resolvedSnapshot,
            policy: resolvedPolicy,
            acceptedDecision: accepted,
            symbolRejectedDecision: symbolRejected,
            notionalRejectedDecision: notionalRejected,
            quantityRejectedDecision: quantityRejected,
            orderTypeRejectedDecision: orderTypeRejected,
            orderCountRejectedDecision: orderCountRejected,
            timeWindowRejectedDecision: timeWindowRejected,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            redactedLiveAccountSnapshotConsumed: redactedLiveAccountSnapshotConsumed,
            symbolAllowlistEnforced: symbolAllowlistEnforced,
            notionalCapEnforced: notionalCapEnforced,
            quantityCapEnforced: quantityCapEnforced,
            orderTypeAllowlistEnforced: orderTypeAllowlistEnforced,
            orderCountCapEnforced: orderCountCapEnforced,
            timeWindowLimitEnforced: timeWindowLimitEnforced,
            preTradeFailClosedBeforeOrderCreation: preTradeFailClosedBeforeOrderCreation
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            rawOrderPayloadPersisted: rawOrderPayloadPersisted,
            orderEndpointTouched: orderEndpointTouched,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
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
        self.upstreamSnapshotEvidence = resolvedSnapshot
        self.policy = resolvedPolicy
        self.acceptedDecision = accepted
        self.symbolRejectedDecision = symbolRejected
        self.notionalRejectedDecision = notionalRejected
        self.quantityRejectedDecision = quantityRejected
        self.orderTypeRejectedDecision = orderTypeRejected
        self.orderCountRejectedDecision = orderCountRejected
        self.timeWindowRejectedDecision = timeWindowRejected
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.redactedLiveAccountSnapshotConsumed = redactedLiveAccountSnapshotConsumed
        self.symbolAllowlistEnforced = symbolAllowlistEnforced
        self.notionalCapEnforced = notionalCapEnforced
        self.quantityCapEnforced = quantityCapEnforced
        self.orderTypeAllowlistEnforced = orderTypeAllowlistEnforced
        self.orderCountCapEnforced = orderCountCapEnforced
        self.timeWindowLimitEnforced = timeWindowLimitEnforced
        self.preTradeFailClosedBeforeOrderCreation = preTradeFailClosedBeforeOrderCreation
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.rawOrderPayloadPersisted = rawOrderPayloadPersisted
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence
    {
        try ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors = [
        "GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS",
        "TVM-RELEASE-V0210-CANARY-HARD-LIMITS",
        "V0210-006-CANARY-SYMBOL-ALLOWLIST",
        "V0210-006-NOTIONAL-QUANTITY-CAPS",
        "V0210-006-ORDER-TYPE-COUNT-WINDOW-LIMITS",
        "V0210-006-PRE-TRADE-FAIL-CLOSED",
        "V0210-006-NO-SUBMIT-CANCEL-REPLACE",
        "V0210-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1278ReleaseV0210CanaryHardLimitPreTradeGate",
        "bash checks/verify-v0.21.0-canary-hard-limits.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210SpotCanaryHardLimitPreTradeGateEvidence {
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
        upstreamSnapshotEvidence: ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence,
        policy: ReleaseV0210SpotCanaryHardLimitPolicy,
        acceptedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        symbolRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        notionalRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        quantityRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        orderTypeRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        orderCountRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        timeWindowRejectedDecision: ReleaseV0210SpotCanaryHardLimitDecision,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1278", "GH-1278", issueID.rawValue),
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-1276", "GH-1277"],
                "GH-1276,GH-1277",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1279", "GH-1279", downstreamIssueID.rawValue),
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
                "upstreamSnapshotEvidence",
                upstreamSnapshotEvidence.evidenceHeld,
                "GH-1277 redacted snapshot evidence held",
                upstreamSnapshotEvidence.issueID.rawValue
            ),
            ("policy", policy.policyHeld, ReleaseV0210SpotCanaryHardLimitPolicy.requiredPolicySummary, policy.policySummary),
            ("acceptedDecision", acceptedDecision.decisionHeld && acceptedDecision.outcome == .accepted, "accepted decision held", acceptedDecision.outcome.rawValue),
            ("symbolRejectedDecision", symbolRejectedDecision.rejectReasons == [.symbolNotAllowed], "symbol rejection", symbolRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("notionalRejectedDecision", notionalRejectedDecision.rejectReasons == [.notionalLimitExceeded], "notional rejection", notionalRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("quantityRejectedDecision", quantityRejectedDecision.rejectReasons == [.quantityLimitExceeded], "quantity rejection", quantityRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("orderTypeRejectedDecision", orderTypeRejectedDecision.rejectReasons == [.orderTypeNotAllowed], "order type rejection", orderTypeRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("orderCountRejectedDecision", orderCountRejectedDecision.rejectReasons == [.orderCountLimitExceeded], "order count rejection", orderCountRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("timeWindowRejectedDecision", timeWindowRejectedDecision.rejectReasons == [.timeWindowClosed], "time window rejection", timeWindowRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
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
                field: "releaseV0210.canaryHardLimits.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        redactedLiveAccountSnapshotConsumed: Bool,
        symbolAllowlistEnforced: Bool,
        notionalCapEnforced: Bool,
        quantityCapEnforced: Bool,
        orderTypeAllowlistEnforced: Bool,
        orderCountCapEnforced: Bool,
        timeWindowLimitEnforced: Bool,
        preTradeFailClosedBeforeOrderCreation: Bool
    ) throws {
        let trueFlags = [
            ("redactedLiveAccountSnapshotConsumed", redactedLiveAccountSnapshotConsumed),
            ("symbolAllowlistEnforced", symbolAllowlistEnforced),
            ("notionalCapEnforced", notionalCapEnforced),
            ("quantityCapEnforced", quantityCapEnforced),
            ("orderTypeAllowlistEnforced", orderTypeAllowlistEnforced),
            ("orderCountCapEnforced", orderCountCapEnforced),
            ("timeWindowLimitEnforced", timeWindowLimitEnforced),
            ("preTradeFailClosedBeforeOrderCreation", preTradeFailClosedBeforeOrderCreation)
        ]

        for (field, value) in trueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryHardLimits.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        rawOrderPayloadPersisted: Bool,
        orderEndpointTouched: Bool,
        submitCancelReplaceEnabled: Bool,
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
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("rawOrderPayloadPersisted", rawOrderPayloadPersisted),
            ("orderEndpointTouched", orderEndpointTouched),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
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
                "releaseV0210.canaryHardLimits.\(field)"
            )
        }
    }
}
