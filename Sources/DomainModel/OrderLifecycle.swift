import Foundation

/// OrderLifecycleState 是 v0.14.0 testnet / dry-run 执行证据允许出现的本地订单状态。
///
/// 这些状态只服务 Strategy Signal -> OrderIntent -> Risk Check -> ExecutionEngine / OMS
/// evidence chain；它们不是交易所真实订单状态，也不授权 production submit / cancel / replace。
public enum OrderLifecycleState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case created
    case riskAccepted
    case riskRejected
    case submittedTestnet
    case submittedDryRun
    case accepted
    case partiallyFilled
    case filled
    case cancelRequested
    case cancelled
    case replaceRequested
    case replaced
    case rejected
    case expired
    case failedClosed
}

/// OrderLifecycleContractError 是订单生命周期状态机的局部 fail-closed 错误。
///
/// 它不写入 `DomainModelContractError` 基础枚举，避免 v0.14.0 的局部状态机语义污染
/// symbol、timeframe、date range 等 foundation contract。
public enum OrderLifecycleContractError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidTransition(String)

    public var description: String {
        switch self {
        case let .invalidTransition(value):
            "Order lifecycle transition is invalid: \(value)"
        }
    }
}

/// OrderLifecycleTransition 记录一次已通过本地状态机校验的状态迁移。
///
/// `testnetScoped` 必须为 true；`authorizesProductionTrading` 与
/// `touchesProductionBrokerEndpoint` 必须为 false，确保该证据不能升级为真实交易命令。
public struct OrderLifecycleTransition: Codable, Equatable, Sendable {
    public let from: OrderLifecycleState
    public let to: OrderLifecycleState
    public let reason: String
    public let testnetScoped: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionBrokerEndpoint: Bool

    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case reason
        case testnetScoped
        case authorizesProductionTrading
        case touchesProductionBrokerEndpoint
    }

    public init(
        from: OrderLifecycleState,
        to: OrderLifecycleState,
        reason: String,
        testnetScoped: Bool = true,
        authorizesProductionTrading: Bool = false,
        touchesProductionBrokerEndpoint: Bool = false
    ) throws {
        guard reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle transition reason must not be empty"
            )
        }
        guard testnetScoped else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle transition must remain explicitly testnet / dry-run scoped"
            )
        }
        guard authorizesProductionTrading == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle transition must not authorize production trading"
            )
        }
        guard touchesProductionBrokerEndpoint == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle transition must not touch production broker endpoint"
            )
        }
        guard OrderLifecycleStateMachine.canTransition(from: from, to: to) else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle invalid transition: \(from.rawValue) -> \(to.rawValue)"
            )
        }

        self.from = from
        self.to = to
        self.reason = reason
        self.testnetScoped = testnetScoped
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionBrokerEndpoint = touchesProductionBrokerEndpoint
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            from: try container.decode(OrderLifecycleState.self, forKey: .from),
            to: try container.decode(OrderLifecycleState.self, forKey: .to),
            reason: try container.decode(String.self, forKey: .reason),
            testnetScoped: try container.decode(Bool.self, forKey: .testnetScoped),
            authorizesProductionTrading: try container.decode(Bool.self, forKey: .authorizesProductionTrading),
            touchesProductionBrokerEndpoint: try container.decode(Bool.self, forKey: .touchesProductionBrokerEndpoint)
        )
    }

    public var boundaryHeld: Bool {
        testnetScoped
            && authorizesProductionTrading == false
            && touchesProductionBrokerEndpoint == false
    }
}

/// OrderLifecycleStateMachine 定义 v0.14.0 本地订单生命周期的唯一 transition contract。
///
/// 状态机只表达 Binance Spot / USDⓈ-M Perpetual、EMA / RSI 的 testnet / dry-run
/// evidence path。非法迁移会抛出 `OrderLifecycleContractError.invalidTransition`，以 fail-closed 方式阻断
/// 后续 submit / cancel / replace 语义。
public struct OrderLifecycleStateMachine: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let testnetOnly: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionBrokerEndpoint: Bool

    public init(
        productionTradingEnabledByDefault: Bool = false,
        testnetOnly: Bool = true,
        authorizesProductionTrading: Bool = false,
        touchesProductionBrokerEndpoint: Bool = false
    ) throws {
        guard productionTradingEnabledByDefault == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle must keep production trading disabled by default"
            )
        }
        guard testnetOnly else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle must remain testnet / dry-run only for v0.14.0"
            )
        }
        guard authorizesProductionTrading == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle must not authorize production trading"
            )
        }
        guard touchesProductionBrokerEndpoint == false else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle must not touch production broker endpoint"
            )
        }

        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.testnetOnly = testnetOnly
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionBrokerEndpoint = touchesProductionBrokerEndpoint
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && testnetOnly
            && authorizesProductionTrading == false
            && touchesProductionBrokerEndpoint == false
            && Self.lifecycleVenueID == OrderIntent.activeVenueID
            && Self.lifecycleProductTypes == OrderIntent.activeProductTypes
            && Self.lifecycleStrategies == OrderIntent.activeStrategies
    }

    public func transition(
        from: OrderLifecycleState,
        to: OrderLifecycleState,
        reason: String
    ) throws -> OrderLifecycleTransition {
        guard boundaryHeld else {
            throw OrderLifecycleContractError.invalidTransition(
                "OrderLifecycle boundary must hold before transition"
            )
        }

        return try OrderLifecycleTransition(
            from: from,
            to: to,
            reason: reason
        )
    }

    public static func canTransition(from: OrderLifecycleState, to: OrderLifecycleState) -> Bool {
        validTransitions[from, default: []].contains(to)
    }

    public static let lifecycleVenue = OrderIntent.activeVenue

    public static let lifecycleVenueID = OrderIntent.activeVenueID

    public static let lifecycleProductTypes = OrderIntent.activeProductTypes

    public static let lifecycleStrategies = OrderIntent.activeStrategies

    public static let requiredValidationAnchors = [
        "GH-1026-ORDER-LIFECYCLE-STATE-MACHINE",
        "GH-1026-ORDER-LIFECYCLE-INVALID-TRANSITION-FAIL-CLOSED",
        "GH-1026-ORDER-LIFECYCLE-TESTNET-DRYRUN-BOUNDARY",
        "TVM-RELEASE-V0140-ORDER-LIFECYCLE-STATE-MACHINE"
    ]

    public static let terminalStates: Set<OrderLifecycleState> = [
        .filled,
        .cancelled,
        .rejected,
        .expired,
        .failedClosed
    ]

    public static let validTransitions: [OrderLifecycleState: Set<OrderLifecycleState>] = [
        .created: [.riskAccepted, .riskRejected, .failedClosed],
        .riskAccepted: [.submittedTestnet, .submittedDryRun, .failedClosed],
        .riskRejected: [.failedClosed],
        .submittedTestnet: [.accepted, .rejected, .expired, .failedClosed],
        .submittedDryRun: [.accepted, .rejected, .expired, .failedClosed],
        .accepted: [.partiallyFilled, .filled, .cancelRequested, .replaceRequested, .rejected, .expired, .failedClosed],
        .partiallyFilled: [.filled, .cancelRequested, .replaceRequested, .expired, .failedClosed],
        .filled: [],
        .cancelRequested: [.cancelled, .failedClosed],
        .cancelled: [],
        .replaceRequested: [.replaced, .failedClosed],
        .replaced: [.accepted, .partiallyFilled, .filled, .cancelRequested, .replaceRequested, .expired, .failedClosed],
        .rejected: [],
        .expired: [],
        .failedClosed: []
    ]
}
