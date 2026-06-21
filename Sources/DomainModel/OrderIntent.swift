import Foundation

/// OrderIntentSide 是 v0.14.0 Strategy Signal 进入执行前链路时允许表达的方向。
///
/// 该方向只描述候选订单意图，不等同于交易所订单 side，也不会绕过 RiskEngine、
/// ExecutionEngine、OMS 或后续 testnet gate。
public enum OrderIntentSide: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case buy
    case sell
}

/// OrderIntentStrategyKind 限定 v0.14.0 只允许 EMA / RSI 作为 active strategy source。
public enum OrderIntentStrategyKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema = "EMA"
    case rsi = "RSI"
}

/// OrderIntentTimeInForce 描述订单意图希望下游执行层评估的时间策略。
///
/// 这里的 time-in-force 仍只是 intent policy input；它不创建交易所订单，也不授权
/// submit / cancel / replace。
public enum OrderIntentTimeInForce: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case goodTillCanceled
    case immediateOrCancel
    case fillOrKill
}

/// OrderIntentPolicy 固定 v0.14.0 OrderIntent 的执行前约束。
///
/// `requiresRiskEngineApproval` 必须为 true；`testnetOnly` 表示后续 issue 只能在显式
/// testnet gate 内消费该 intent；`authorizesProductionTrading` 和
/// `authorizesDirectExecution` 必须保持 false。
public struct OrderIntentPolicy: Codable, Equatable, Sendable {
    public let timeInForce: OrderIntentTimeInForce
    public let requiresRiskEngineApproval: Bool
    public let testnetOnly: Bool
    public let authorizesProductionTrading: Bool
    public let authorizesDirectExecution: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        timeInForce: OrderIntentTimeInForce,
        requiresRiskEngineApproval: Bool = true,
        testnetOnly: Bool = true,
        authorizesProductionTrading: Bool = false,
        authorizesDirectExecution: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard requiresRiskEngineApproval else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent policy must require RiskEngine approval before execution"
            )
        }
        guard testnetOnly else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent policy must remain testnet-only for v0.14.0"
            )
        }
        guard authorizesProductionTrading == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must not authorize production trading"
            )
        }
        guard authorizesDirectExecution == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must not authorize direct ExecutionClient or broker execution"
            )
        }
        guard productionTradingEnabledByDefault == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "production trading must remain disabled by default"
            )
        }

        self.timeInForce = timeInForce
        self.requiresRiskEngineApproval = requiresRiskEngineApproval
        self.testnetOnly = testnetOnly
        self.authorizesProductionTrading = authorizesProductionTrading
        self.authorizesDirectExecution = authorizesDirectExecution
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }
}

/// OrderIntentCorrelationMetadata 记录 Strategy Signal 到 OrderIntent 的追踪键。
///
/// correlationID、strategySignalID、sourceMessageID 和 strategyRunID 必须由上游生成；
/// sourceSequence 用于保持本地事件顺序。该 metadata 不包含 broker order id、
/// account endpoint payload、listenKey 或真实订单状态。
public struct OrderIntentCorrelationMetadata: Codable, Equatable, Sendable {
    public let correlationID: Identifier
    public let strategySignalID: Identifier
    public let sourceMessageID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int

    public init(
        correlationID: Identifier,
        strategySignalID: Identifier,
        sourceMessageID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int
    ) throws {
        guard sourceSequence > 0 else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent correlation sourceSequence must be positive"
            )
        }

        self.correlationID = correlationID
        self.strategySignalID = strategySignalID
        self.sourceMessageID = sourceMessageID
        self.strategyRunID = strategyRunID
        self.sourceSequence = sourceSequence
    }
}

/// OrderIntent 是 v0.14.0 Strategy Signal -> RiskEngine -> ExecutionEngine 链路的规范订单意图。
///
/// 它只表达 Binance Spot / USDⓈ-M Perpetual、EMA / RSI、数量、方向、time-in-force
/// 和 correlation metadata。该类型不是 production order，不直接调用 ExecutionClient、
/// broker、OMS、signed endpoint 或 private stream；任何后续 testnet submit / cancel /
/// replace 都必须先经过独立 issue 的 RiskEngine / ExecutionEngine gate。
public struct OrderIntent: Codable, Equatable, Sendable {
    public let intentID: Identifier
    public let instrument: InstrumentIdentity
    public let side: OrderIntentSide
    public let quantity: Quantity
    public let strategy: OrderIntentStrategyKind
    public let policy: OrderIntentPolicy
    public let correlation: OrderIntentCorrelationMetadata
    public let createdAt: Date
    public let representsProductionOrder: Bool
    public let bypassesRiskEngine: Bool
    public let touchesBrokerEndpoint: Bool

    public init(
        intentID: Identifier,
        instrument: InstrumentIdentity,
        side: OrderIntentSide,
        quantity: Quantity,
        strategy: OrderIntentStrategyKind,
        policy: OrderIntentPolicy,
        correlation: OrderIntentCorrelationMetadata,
        createdAt: Date,
        representsProductionOrder: Bool = false,
        bypassesRiskEngine: Bool = false,
        touchesBrokerEndpoint: Bool = false
    ) throws {
        guard instrument.venue.rawValue == Self.activeVenueID.rawValue else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent venue must be Binance for v0.14.0: \(instrument.venue.rawValue)"
            )
        }
        guard Self.activeProductTypes.contains(instrument.productType) else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent product type is outside v0.14.0 boundary: \(instrument.productType.rawValue)"
            )
        }
        guard quantity.rawValue > 0 else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent quantity must be positive"
            )
        }
        guard policy.requiresRiskEngineApproval else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must require RiskEngine approval"
            )
        }
        guard representsProductionOrder == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must not represent a production order"
            )
        }
        guard bypassesRiskEngine == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must not bypass RiskEngine"
            )
        }
        guard touchesBrokerEndpoint == false else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent must not touch broker or production endpoint"
            )
        }
        guard intentID == Self.deterministicID(
            instrument: instrument,
            side: side,
            quantity: quantity,
            strategy: strategy,
            policy: policy,
            correlation: correlation
        ) else {
            throw DomainModelContractError.invalidOrderIntent(
                "OrderIntent intentID must be deterministic from instrument, side, quantity, strategy, policy and correlation"
            )
        }

        self.intentID = intentID
        self.instrument = instrument
        self.side = side
        self.quantity = quantity
        self.strategy = strategy
        self.policy = policy
        self.correlation = correlation
        self.createdAt = createdAt
        self.representsProductionOrder = representsProductionOrder
        self.bypassesRiskEngine = bypassesRiskEngine
        self.touchesBrokerEndpoint = touchesBrokerEndpoint
    }

    public var isPreRiskEngineIntent: Bool {
        policy.requiresRiskEngineApproval
            && policy.authorizesProductionTrading == false
            && policy.authorizesDirectExecution == false
            && policy.productionTradingEnabledByDefault == false
            && representsProductionOrder == false
            && bypassesRiskEngine == false
            && touchesBrokerEndpoint == false
    }

    public static let activeVenue = "Binance"

    public static let activeVenueID = Identifier.constant("binance", field: "orderIntent.venue")

    public static let activeProductTypes: Set<ProductType> = [.spot, .usdsPerpetual]

    public static let activeStrategies: Set<OrderIntentStrategyKind> = [.ema, .rsi]

    public static func deterministicID(
        instrument: InstrumentIdentity,
        side: OrderIntentSide,
        quantity: Quantity,
        strategy: OrderIntentStrategyKind,
        policy: OrderIntentPolicy,
        correlation: OrderIntentCorrelationMetadata
    ) -> Identifier {
        let quantityText = String(format: "%.8f", locale: Locale(identifier: "en_US_POSIX"), quantity.rawValue)
        return .constant(
            [
                "order-intent",
                instrument.rawValue,
                side.rawValue,
                quantityText,
                strategy.rawValue,
                policy.timeInForce.rawValue,
                correlation.correlationID.rawValue,
                correlation.strategySignalID.rawValue,
                correlation.sourceMessageID.rawValue,
                correlation.strategyRunID.rawValue,
                String(correlation.sourceSequence)
            ].joined(separator: ":"),
            field: "orderIntent.intentID"
        )
    }
}
