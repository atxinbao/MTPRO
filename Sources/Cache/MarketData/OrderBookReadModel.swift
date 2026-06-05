import DomainModel
import Foundation

/// MTP-186 将 order book read model 迁入 `Sources/Cache/MarketData/`。
///
/// 该 read model 是 public market data snapshot / delta 的 runtime-derived state，不是订单簿
/// 交易指令、broker depth stream、private stream 或 UI command surface。输出只允许作为本地
/// strategy / report read input，不能升级为 executable order、signed request 或真实 broker action。

/// OrderBookReadModelSource 标记订单簿读模型来自原始 snapshot 还是 delta 应用结果。
public enum OrderBookReadModelSource: String, Codable, Equatable, Sendable {
    case snapshot
    case deltaApplied
}

/// 订单簿读模型输入由只读 snapshot / delta 构建，供研究信号使用，不代表可交易状态。
public struct OrderBookReadModelInput: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let observedAt: Date
    public let bids: [OrderBookLevel]
    public let asks: [OrderBookLevel]
    public let source: OrderBookReadModelSource

    public init(
        symbol: Symbol,
        observedAt: Date,
        bids: [OrderBookLevel],
        asks: [OrderBookLevel],
        source: OrderBookReadModelSource
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bids = Self.sortedBids(Self.nonZero(levels: bids))
        self.asks = Self.sortedAsks(Self.nonZero(levels: asks))
        self.source = source
    }

    public init(snapshot: OrderBookSnapshot) {
        self.init(
            symbol: snapshot.symbol,
            observedAt: snapshot.observedAt,
            bids: snapshot.bids,
            asks: snapshot.asks,
            source: .snapshot
        )
    }

    public func applying(_ delta: OrderBookDelta) throws -> OrderBookReadModelInput {
        guard delta.symbol == symbol else {
            throw CoreError.marketDataMismatch(
                field: "orderBookDelta.symbol",
                expected: symbol.rawValue,
                actual: delta.symbol.rawValue
            )
        }

        let bids = Self.applying(delta.bidUpdates, to: bids)
        let asks = Self.applying(delta.askUpdates, to: asks)

        return OrderBookReadModelInput(
            symbol: symbol,
            observedAt: delta.observedAt,
            bids: bids,
            asks: asks,
            source: .deltaApplied
        )
    }

    private static func applying(
        _ updates: [OrderBookLevel],
        to levels: [OrderBookLevel]
    ) -> [OrderBookLevel] {
        var levelsByPrice: [Double: OrderBookLevel] = [:]
        for level in levels {
            levelsByPrice[level.price.rawValue] = level
        }

        for update in updates {
            if update.quantity.rawValue == 0 {
                levelsByPrice.removeValue(forKey: update.price.rawValue)
            } else {
                levelsByPrice[update.price.rawValue] = update
            }
        }

        return Array(levelsByPrice.values)
    }

    private static func nonZero(levels: [OrderBookLevel]) -> [OrderBookLevel] {
        levels.filter { $0.quantity.rawValue > 0 }
    }

    private static func sortedBids(_ levels: [OrderBookLevel]) -> [OrderBookLevel] {
        levels.sorted { left, right in
            left.price.rawValue > right.price.rawValue
        }
    }

    private static func sortedAsks(_ levels: [OrderBookLevel]) -> [OrderBookLevel] {
        levels.sorted { left, right in
            left.price.rawValue < right.price.rawValue
        }
    }
}
