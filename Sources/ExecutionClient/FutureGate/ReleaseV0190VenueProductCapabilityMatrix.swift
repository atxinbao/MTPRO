import DomainModel
import Foundation

// GH-1207 static contract boundary:
// capabilityMatrixPairs=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// capabilities=submit,cancel,status,position,reconcile,reduceOnly,leverage,marginType
// capabilityStates=active,placeholder,forbidden,futureGated
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// productionCutoverAuthorized=false
// GH-1207-VERIFY-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX
// TVM-RELEASE-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX
// V0190-002-CAPABILITY-MATRIX
// V0190-002-SUBMIT-CANCEL-STATUS-POSITION-RECONCILE
// V0190-002-REDUCE-ONLY-LEVERAGE-MARGIN-TYPE
// V0190-002-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED
// V0190-002-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
// V0190-002-FUTURE-CAPABILITIES-NOT-ACTIVE
// V0190-002-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueProductCapability 是 v0.19.0 venue/product capability matrix 的能力键。
///
/// 这些能力只描述 registry / adapter contract，不能被解释为 production trading 授权。
public enum ReleaseV0190VenueProductCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case status
    case position
    case reconcile
    case reduceOnly
    case leverage
    case marginType
}

/// ReleaseV0190VenueProductCapabilityState 明确能力是否可用。
///
/// `futureGated` 和 `placeholder` 都不是 active，调用方必须通过 `requireActive`
/// 显式验证，避免 future capability 被误当成可执行 runtime capability。
public enum ReleaseV0190VenueProductCapabilityState: String, Codable, Equatable, Hashable, Sendable {
    case active
    case placeholder
    case forbidden
    case futureGated
}

/// ReleaseV0190VenueProductCapabilityDecision 记录单个能力的状态和失败原因。
///
/// reason 是面向 operator / audit 的可读证据，用于解释为什么能力不能执行。
public struct ReleaseV0190VenueProductCapabilityDecision: Equatable, Hashable, Sendable {
    public let capability: ReleaseV0190VenueProductCapability
    public let state: ReleaseV0190VenueProductCapabilityState
    public let reason: String

    public var isActive: Bool {
        state == .active
    }

    public init(
        capability: ReleaseV0190VenueProductCapability,
        state: ReleaseV0190VenueProductCapabilityState,
        reason: String
    ) {
        self.capability = capability
        self.state = state
        self.reason = reason
    }
}

/// ReleaseV0190VenueProductCapabilityProfile 是某个 venue/product pair 的完整能力表。
///
/// 每个 profile 必须覆盖全部 capability，缺失项会 fail closed。
public struct ReleaseV0190VenueProductCapabilityProfile: Equatable, Sendable {
    public let pair: ReleaseV0181VenueProductPair
    public let decisions: [ReleaseV0190VenueProductCapabilityDecision]

    public init(
        pair: ReleaseV0181VenueProductPair,
        decisions: [ReleaseV0190VenueProductCapabilityDecision]
    ) {
        self.pair = pair
        self.decisions = decisions
    }

    public func decision(
        for capability: ReleaseV0190VenueProductCapability
    ) throws -> ReleaseV0190VenueProductCapabilityDecision {
        guard let decision = decisions.first(where: { $0.capability == capability }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.capabilityMatrix.\(pair.venueID.rawValue).\(pair.productKind.rawValue)",
                expected: "all capabilities must be explicitly classified",
                actual: "missing \(capability.rawValue)"
            )
        }
        return decision
    }
}

/// ReleaseV0190VenueProductCapabilityMatrix 固定 v0.19.0 的 venue/product capability matrix。
///
/// Matrix 覆盖 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap。OKX 能力
/// 仍然是 placeholder / future-gated contract，不实现 OKX runtime，不连接 endpoint。
public enum ReleaseV0190VenueProductCapabilityMatrix {
    public static let productionTradingEnabledByDefault = false
    public static let okxRuntimeImplemented = false

    public static let allProfiles: [ReleaseV0190VenueProductCapabilityProfile] = [
        profile(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
            active: [.submit, .cancel, .status, .position, .reconcile],
            placeholder: [],
            futureGated: [],
            forbidden: [.reduceOnly, .leverage, .marginType],
            reasonPrefix: "Binance Spot"
        ),
        profile(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures),
            active: [.submit, .cancel, .status, .position, .reconcile, .reduceOnly, .leverage, .marginType],
            placeholder: [],
            futureGated: [],
            forbidden: [],
            reasonPrefix: "Binance USDⓈ-M Futures"
        ),
        profile(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot),
            active: [],
            placeholder: [.status, .position],
            futureGated: [.submit, .cancel, .reconcile],
            forbidden: [.reduceOnly, .leverage, .marginType],
            reasonPrefix: "OKX Spot"
        ),
        profile(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap),
            active: [],
            placeholder: [.status, .position],
            futureGated: [.submit, .cancel, .reconcile, .reduceOnly, .leverage, .marginType],
            forbidden: [],
            reasonPrefix: "OKX Swap"
        )
    ]

    public static func profile(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> ReleaseV0190VenueProductCapabilityProfile {
        guard ReleaseV0190VenueProductTargetRegistry.supportsPair(
            venueID: venueID,
            productKind: productKind
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.capabilityMatrix.pair",
                expected: "binance/spot,binance/usdmFutures,okx/spot,okx/swap",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)"
            )
        }

        guard let profile = allProfiles.first(where: {
            $0.pair == ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
        }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.capabilityMatrix.profile",
                expected: "profile for every supported pair",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)"
            )
        }
        return profile
    }

    public static func decision(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        capability: ReleaseV0190VenueProductCapability
    ) throws -> ReleaseV0190VenueProductCapabilityDecision {
        if tradingEnvironment == .productionLive {
            return ReleaseV0190VenueProductCapabilityDecision(
                capability: capability,
                state: .forbidden,
                reason: "productionLive is disabled by default for v0.19.0; no production cutover is authorized"
            )
        }

        return try profile(venueID: venueID, productKind: productKind).decision(for: capability)
    }

    public static func requireActive(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        capability: ReleaseV0190VenueProductCapability
    ) throws -> ReleaseV0190VenueProductCapabilityDecision {
        let decision = try decision(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            capability: capability
        )
        guard decision.isActive else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.capabilityMatrix.\(capability.rawValue)",
                expected: "active",
                actual: "\(decision.state.rawValue): \(decision.reason)"
            )
        }
        return decision
    }

    private static func profile(
        pair: ReleaseV0181VenueProductPair,
        active: Set<ReleaseV0190VenueProductCapability>,
        placeholder: Set<ReleaseV0190VenueProductCapability>,
        futureGated: Set<ReleaseV0190VenueProductCapability>,
        forbidden: Set<ReleaseV0190VenueProductCapability>,
        reasonPrefix: String
    ) -> ReleaseV0190VenueProductCapabilityProfile {
        let decisions = ReleaseV0190VenueProductCapability.allCases.map { capability in
            decision(
                capability: capability,
                active: active,
                placeholder: placeholder,
                futureGated: futureGated,
                forbidden: forbidden,
                reasonPrefix: reasonPrefix
            )
        }
        return ReleaseV0190VenueProductCapabilityProfile(
            pair: pair,
            decisions: decisions
        )
    }

    private static func decision(
        capability: ReleaseV0190VenueProductCapability,
        active: Set<ReleaseV0190VenueProductCapability>,
        placeholder: Set<ReleaseV0190VenueProductCapability>,
        futureGated: Set<ReleaseV0190VenueProductCapability>,
        forbidden: Set<ReleaseV0190VenueProductCapability>,
        reasonPrefix: String
    ) -> ReleaseV0190VenueProductCapabilityDecision {
        if active.contains(capability) {
            return ReleaseV0190VenueProductCapabilityDecision(
                capability: capability,
                state: .active,
                reason: "\(reasonPrefix) capability is active for non-production v0.19.0 contract checks"
            )
        }
        if placeholder.contains(capability) {
            return ReleaseV0190VenueProductCapabilityDecision(
                capability: capability,
                state: .placeholder,
                reason: "\(reasonPrefix) capability is registry placeholder evidence only; no runtime adapter is implemented"
            )
        }
        if futureGated.contains(capability) {
            return ReleaseV0190VenueProductCapabilityDecision(
                capability: capability,
                state: .futureGated,
                reason: "\(reasonPrefix) capability requires a later explicitly authorized adapter issue"
            )
        }
        if forbidden.contains(capability) {
            return ReleaseV0190VenueProductCapabilityDecision(
                capability: capability,
                state: .forbidden,
                reason: "\(reasonPrefix) does not support \(capability.rawValue) in the v0.19.0 matrix"
            )
        }
        return ReleaseV0190VenueProductCapabilityDecision(
            capability: capability,
            state: .forbidden,
            reason: "\(reasonPrefix) omitted \(capability.rawValue); matrix fails closed"
        )
    }
}
