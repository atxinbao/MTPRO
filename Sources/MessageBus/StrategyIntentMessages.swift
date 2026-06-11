import DomainModel
import Foundation

/// StrategyIntentMessage 是策略层向执行前链路发布的中性意图消息。
///
/// MessageBus 只负责承载 target exposure 与可选 product-aware order intent evidence；
/// 它不提交订单、不调用 ExecutionClient、不连接 broker、不读 production secret，也不绕过 RiskEngine。
public struct StrategyIntentMessage: Codable, Equatable, Sendable {
    public let messageID: Identifier
    public let strategyID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let productAwareOrderIntent: ProductAwareOrderIntent?
    public let emittedAt: Date

    public init(
        messageID: Identifier,
        strategyID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        productAwareOrderIntent: ProductAwareOrderIntent?,
        emittedAt: Date
    ) throws {
        if targetExposure.requiresOrderIntent {
            guard let productAwareOrderIntent else {
                throw DomainModelContractError.invalidTargetExposureIntent(
                    "\(targetExposure.rawValue) requires product-aware order intent"
                )
            }
            guard productAwareOrderIntent.instrument == instrument else {
                throw DomainModelContractError.invalidTargetExposureIntent(
                    "message instrument must match order intent instrument"
                )
            }
            guard productAwareOrderIntent.targetExposure == targetExposure else {
                throw DomainModelContractError.invalidTargetExposureIntent(
                    "message target exposure must match order intent target exposure"
                )
            }
        } else {
            guard productAwareOrderIntent == nil else {
                throw DomainModelContractError.invalidTargetExposureIntent(
                    "hold message must not carry product-aware order intent"
                )
            }
        }

        self.messageID = messageID
        self.strategyID = strategyID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.productAwareOrderIntent = productAwareOrderIntent
        self.emittedAt = emittedAt
    }
}
