import Foundation

/// 市场数据 cache 是只读 market event 的确定性投影，供 replay 和后续 read model 使用。

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

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> MarketDataCacheSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> MarketDataCacheSnapshot {
        envelopes.reduce(MarketDataCacheSnapshot()) { snapshot, envelope in
            guard case let .market(event) = envelope.event else {
                return snapshot
            }
            return snapshot.applying(event)
        }
    }
}
