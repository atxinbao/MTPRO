import DomainModel
import Foundation

/// MTP-186 将 market data cache 迁入 `Sources/Cache/MarketData/`。
/// GH-396 起该 implementation 由 `Cache` target 拥有；`Core` 仅 re-export Cache 作为
/// compatibility envelope，不能继续作为 primary owner。
///
/// 这里的 Cache 只保存可由 MessageBus / Event Log replay 重建的 runtime-derived read state；
/// 它不是 durable store、SQLite / DuckDB schema owner、真实账户 cache 或 broker state mirror。
/// 所有输入必须来自本地 `MarketEvent` / `EventEnvelope`，不得触发 signed endpoint、account
/// endpoint、listenKey、private stream、broker adapter 或任何 live trading side effect。

/// MarketDataSeriesKey 使用 symbol + timeframe 区分 kline 序列。
public struct MarketDataSeriesKey: Equatable, Hashable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe

    public init(symbol: Symbol, timeframe: Timeframe) {
        self.symbol = symbol
        self.timeframe = timeframe
    }
}

/// Market data cache snapshot 是 read-only market event 的确定性投影结果。
public struct MarketDataCacheSnapshot: Equatable, Sendable {
    public let barsBySeries: [MarketDataSeriesKey: [MarketBar]]
    public let tradesBySymbol: [Symbol: [TradeTick]]
    public let bestBidAskBySymbol: [Symbol: BestBidAsk]
    public let orderBookSnapshotsBySymbol: [Symbol: OrderBookSnapshot]
    public let orderBookDeltasBySymbol: [Symbol: [OrderBookDelta]]

    public init(
        barsBySeries: [MarketDataSeriesKey: [MarketBar]] = [:],
        tradesBySymbol: [Symbol: [TradeTick]] = [:],
        bestBidAskBySymbol: [Symbol: BestBidAsk] = [:],
        orderBookSnapshotsBySymbol: [Symbol: OrderBookSnapshot] = [:],
        orderBookDeltasBySymbol: [Symbol: [OrderBookDelta]] = [:]
    ) {
        self.barsBySeries = barsBySeries
        self.tradesBySymbol = tradesBySymbol
        self.bestBidAskBySymbol = bestBidAskBySymbol
        self.orderBookSnapshotsBySymbol = orderBookSnapshotsBySymbol
        self.orderBookDeltasBySymbol = orderBookDeltasBySymbol
    }

    public var marketEventCount: Int {
        barsBySeries.values.reduce(0) { $0 + $1.count }
            + tradesBySymbol.values.reduce(0) { $0 + $1.count }
            + bestBidAskBySymbol.count
            + orderBookSnapshotsBySymbol.count
            + orderBookDeltasBySymbol.values.reduce(0) { $0 + $1.count }
    }

    public func applying(_ event: MarketEvent) -> MarketDataCacheSnapshot {
        var barsBySeries = barsBySeries
        var tradesBySymbol = tradesBySymbol
        var bestBidAskBySymbol = bestBidAskBySymbol
        var orderBookSnapshotsBySymbol = orderBookSnapshotsBySymbol
        var orderBookDeltasBySymbol = orderBookDeltasBySymbol

        switch event {
        case let .bar(bar):
            let key = MarketDataSeriesKey(symbol: bar.symbol, timeframe: bar.timeframe)
            barsBySeries[key, default: []].append(bar)
        case let .trade(trade):
            tradesBySymbol[trade.symbol, default: []].append(trade)
        case let .bestBidAsk(bestBidAsk):
            bestBidAskBySymbol[bestBidAsk.symbol] = bestBidAsk
        case let .orderBookSnapshot(snapshot):
            orderBookSnapshotsBySymbol[snapshot.symbol] = snapshot
        case let .orderBookDelta(delta):
            orderBookDeltasBySymbol[delta.symbol, default: []].append(delta)
        }

        return MarketDataCacheSnapshot(
            barsBySeries: barsBySeries,
            tradesBySymbol: tradesBySymbol,
            bestBidAskBySymbol: bestBidAskBySymbol,
            orderBookSnapshotsBySymbol: orderBookSnapshotsBySymbol,
            orderBookDeltasBySymbol: orderBookDeltasBySymbol
        )
    }
}

/// Cache 只接收 Core market event，不读取网络或数据库。
public struct MarketDataCache: Equatable, Sendable {
    public private(set) var snapshot: MarketDataCacheSnapshot

    public init(snapshot: MarketDataCacheSnapshot = MarketDataCacheSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func ingest(_ event: MarketEvent) -> MarketDataCacheSnapshot {
        snapshot = snapshot.applying(event)
        return snapshot
    }

    /// 批量投影 public market events，供 DataEngine target 的 release runtime path 复用。
    ///
    /// 该方法只消费本地 `MarketEvent`，不读取数据库、网络、账户 payload 或 broker state。
    @discardableResult
    public mutating func ingest(contentsOf events: [MarketEvent]) -> MarketDataCacheSnapshot {
        for event in events {
            ingest(event)
        }
        return snapshot
    }

    /// 从 public market events 生成确定性 snapshot，不依赖 Core compatibility envelope。
    public static func project(_ events: [MarketEvent]) -> MarketDataCacheSnapshot {
        var cache = MarketDataCache()
        return cache.ingest(contentsOf: events)
    }

}
