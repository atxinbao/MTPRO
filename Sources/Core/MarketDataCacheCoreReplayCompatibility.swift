import Cache
import DomainModel

/// GH-396 保留旧 `Core` 调用方的 EventEnvelope replay helper。
///
/// `MarketDataCache` 的纯 read-model implementation 已迁入 `Cache` target；这里仅桥接仍在
/// Core compatibility envelope 内的旧 `EventEnvelope` / `DomainEvent` 类型，不新增 runtime、
/// broker、signed endpoint、account payload 或 live trading 能力。
public extension MarketDataCache {
    @discardableResult
    mutating func rebuild(from envelopes: [EventEnvelope]) -> MarketDataCacheSnapshot {
        self = MarketDataCache(snapshot: Self.project(envelopes))
        return snapshot
    }

    static func project(_ envelopes: [EventEnvelope]) -> MarketDataCacheSnapshot {
        envelopes.reduce(MarketDataCacheSnapshot()) { snapshot, envelope in
            guard case let .market(event) = envelope.event else {
                return snapshot
            }
            return snapshot.applying(event)
        }
    }
}
