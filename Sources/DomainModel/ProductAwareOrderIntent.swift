import Foundation

/// ProductAwareOrderIntent 是策略目标敞口进入执行前链路的产品感知订单意图。
///
/// 该模型保留 instrument productType，能在构造阶段阻断 Spot short；USDⓈ-M Perpetual
/// short 可以形成 pre-risk-gate intent，但仍必须经过 CommandGateway / RiskEngine /
/// ExecutionEngine / OMS / Event Store 后续 gate，不能直接变成 broker command。
public struct ProductAwareOrderIntent: Codable, Equatable, Sendable {
    public let intentID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let quantity: Quantity
    public let referencePrice: Price
    public let createdAt: Date
    public let requiresRiskGateBeforeExecution: Bool
    public let authorizesTradingExecution: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        intentID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        quantity: Quantity,
        referencePrice: Price,
        createdAt: Date,
        requiresRiskGateBeforeExecution: Bool = true,
        authorizesTradingExecution: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard targetExposure.isPreOrderAllowed(for: instrument.productType) else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "Spot targetShort is blocked before order creation: \(instrument.rawValue)"
            )
        }
        guard targetExposure.requiresOrderIntent else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "hold must remain a target exposure message and must not create order intent"
            )
        }
        guard quantity.rawValue > 0 else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "order intent quantity must be positive for \(targetExposure.rawValue)"
            )
        }
        guard requiresRiskGateBeforeExecution else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "product-aware intent must require risk gate before execution"
            )
        }
        guard authorizesTradingExecution == false else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "product-aware intent must not authorize trading execution"
            )
        }
        guard productionTradingEnabledByDefault == false else {
            throw DomainModelContractError.invalidProductAwareOrderIntent(
                "production trading must remain disabled by default"
            )
        }

        self.intentID = intentID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.createdAt = createdAt
        self.requiresRiskGateBeforeExecution = requiresRiskGateBeforeExecution
        self.authorizesTradingExecution = authorizesTradingExecution
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    /// 该 intent 是否只是进入 RiskEngine 前的候选意图。
    public var isPreRiskGateIntent: Bool {
        requiresRiskGateBeforeExecution
            && authorizesTradingExecution == false
            && productionTradingEnabledByDefault == false
    }
}
