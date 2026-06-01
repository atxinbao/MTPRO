import Foundation

/// 只读市场数据模型承载 Binance public data 的本地表示，不包含网络请求、账户信息或交易动作。

/// MarketBar 表示只读 kline bar，包含 symbol、timeframe、时间区间、OHLC 和成交量。
public struct MarketBar: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let interval: DateRange
    public let open: Price
    public let high: Price
    public let low: Price
    public let close: Price
    public let volume: Quantity

    public init(
        symbol: Symbol,
        timeframe: Timeframe,
        interval: DateRange,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) throws {
        self.symbol = symbol
        self.timeframe = timeframe
        self.interval = interval
        self.open = try Price(open, field: "open")
        self.high = try Price(high, field: "high")
        self.low = try Price(low, field: "low")
        self.close = try Price(close, field: "close")
        self.volume = try Quantity(volume, field: "volume")
    }
}

/// TradeTick 表示只读近期成交，不包含账户、订单或 broker 状态。
public struct TradeTick: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let tradedAt: Date
    public let price: Price
    public let quantity: Quantity
    public let makerSide: BookSide

    public init(
        symbol: Symbol,
        tradedAt: Date,
        price: Double,
        quantity: Double,
        makerSide: BookSide
    ) throws {
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.price = try Price(price)
        self.quantity = try Quantity(quantity)
        self.makerSide = makerSide
    }
}

/// BookSide 标记成交或订单簿侧别，只用于 public market data 语义。
public enum BookSide: String, Codable, Equatable, Sendable {
    case bid
    case ask
}

/// OrderBookLevel 表示单档订单簿价格和数量，零数量用于 delta 删除。
public struct OrderBookLevel: Codable, Equatable, Sendable {
    public let price: Price
    public let quantity: Quantity

    public init(price: Double, quantity: Double) throws {
        self.price = try Price(price)
        self.quantity = try Quantity(quantity)
    }
}

/// BestBidAsk 表示 public best bid / ask 快照，是只读行情观察面。
public struct BestBidAsk: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let observedAt: Date
    public let bid: OrderBookLevel
    public let ask: OrderBookLevel

    public init(
        symbol: Symbol,
        observedAt: Date,
        bid: OrderBookLevel,
        ask: OrderBookLevel
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bid = bid
        self.ask = ask
    }
}

/// OrderBookSnapshot 表示有限深度 public snapshot，不包含账户私有深度或可交易授权。
public struct OrderBookSnapshot: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let observedAt: Date
    public let bids: [OrderBookLevel]
    public let asks: [OrderBookLevel]

    public init(
        symbol: Symbol,
        observedAt: Date,
        bids: [OrderBookLevel],
        asks: [OrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bids = bids
        self.asks = asks
    }
}

/// OrderBookDelta 表示 public depth 增量更新，只能应用到相同 symbol 的读模型。
public struct OrderBookDelta: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let observedAt: Date
    public let bidUpdates: [OrderBookLevel]
    public let askUpdates: [OrderBookLevel]

    public init(
        symbol: Symbol,
        observedAt: Date,
        bidUpdates: [OrderBookLevel],
        askUpdates: [OrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bidUpdates = bidUpdates
        self.askUpdates = askUpdates
    }
}


/// MarketEvent 聚合 Core 支持的只读行情事件，统一向 cache、event log 和 projection 输出。
public enum MarketEvent: Codable, Equatable, Sendable {
    case bar(MarketBar)
    case trade(TradeTick)
    case bestBidAsk(BestBidAsk)
    case orderBookSnapshot(OrderBookSnapshot)
    case orderBookDelta(OrderBookDelta)

    public var symbol: Symbol {
        switch self {
        case let .bar(bar):
            bar.symbol
        case let .trade(trade):
            trade.symbol
        case let .bestBidAsk(bestBidAsk):
            bestBidAsk.symbol
        case let .orderBookSnapshot(snapshot):
            snapshot.symbol
        case let .orderBookDelta(delta):
            delta.symbol
        }
    }
}
