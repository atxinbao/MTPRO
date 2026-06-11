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

/// PerpetualMarketDataReadModelError 描述 Perp market read model 的本地合同错误。
///
/// 这些错误只覆盖 Cache target 内的 public market read model，不表达账户、broker、
/// leverage action、margin action、ExecutionClient、OMS 或 production trading 状态。
public enum PerpetualMarketDataReadModelError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidInstrument(InstrumentIdentity)
    case invalidStaleAfter(TimeInterval)
    case invalidFundingRate(Double)

    public var description: String {
        switch self {
        case let .invalidInstrument(instrument):
            "Perpetual market data read model requires USD-M Perpetual instrument: \(instrument.rawValue)"
        case let .invalidStaleAfter(value):
            "Perpetual market data staleAfter must be positive: \(value)"
        case let .invalidFundingRate(value):
            "Perpetual funding rate must be finite: \(value)"
        }
    }
}

/// PerpetualMarketDataFreshnessStatus 标记 Perp market evidence 在本地 read model 中的新鲜度。
public enum PerpetualMarketDataFreshnessStatus: String, Codable, Equatable, Sendable {
    case fresh
    case stale
}

/// PerpetualMarketDataFreshnessEvidence 是 mark/funding evidence 的 stale 判断结果。
///
/// 它只描述 public market data 的 observation freshness，不读取 private stream、account
/// endpoint、broker position 或 production feed。
public struct PerpetualMarketDataFreshnessEvidence: Codable, Equatable, Sendable {
    public let observedAt: Date
    public let evaluatedAt: Date
    public let staleAfter: TimeInterval
    public let status: PerpetualMarketDataFreshnessStatus

    public init(
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws {
        guard staleAfter > 0 else {
            throw PerpetualMarketDataReadModelError.invalidStaleAfter(staleAfter)
        }
        self.observedAt = observedAt
        self.evaluatedAt = evaluatedAt
        self.staleAfter = staleAfter
        self.status = evaluatedAt.timeIntervalSince(observedAt) <= staleAfter ? .fresh : .stale
    }

    public var isFresh: Bool {
        status == .fresh
    }
}

/// PerpetualMarkPriceReadModel 保存 USDⓈ-M Perpetual mark / index price read model。
///
/// 该 read model 来自 public premium index evidence，不代表账户保证金、账户持仓、
/// liquidation price、broker state 或可执行交易授权。
public struct PerpetualMarkPriceReadModel: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let markPrice: Price
    public let indexPrice: Price
    public let freshness: PerpetualMarketDataFreshnessEvidence

    public init(
        instrument: InstrumentIdentity,
        markPrice: Double,
        indexPrice: Double,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws {
        try Self.validateInstrument(instrument)
        self.instrument = instrument
        self.markPrice = try Price(markPrice, field: "perpetualMarkPrice.markPrice")
        self.indexPrice = try Price(indexPrice, field: "perpetualMarkPrice.indexPrice")
        self.freshness = try PerpetualMarketDataFreshnessEvidence(
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
    }

    private static func validateInstrument(_ instrument: InstrumentIdentity) throws {
        guard instrument.productType == .usdsPerpetual else {
            throw PerpetualMarketDataReadModelError.invalidInstrument(instrument)
        }
    }
}

/// PerpetualFundingRateReadModel 保存 USDⓈ-M Perpetual funding read model。
///
/// Funding rate 这里只是 public market risk input，不表达实际 funding debit / credit、
/// 账户余额变化、margin 调整或 broker reconciliation。
public struct PerpetualFundingRateReadModel: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let fundingRate: Double
    public let nextFundingTime: Date
    public let freshness: PerpetualMarketDataFreshnessEvidence

    public init(
        instrument: InstrumentIdentity,
        fundingRate: Double,
        nextFundingTime: Date,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws {
        guard fundingRate.isFinite else {
            throw PerpetualMarketDataReadModelError.invalidFundingRate(fundingRate)
        }
        guard instrument.productType == .usdsPerpetual else {
            throw PerpetualMarketDataReadModelError.invalidInstrument(instrument)
        }
        self.instrument = instrument
        self.fundingRate = fundingRate
        self.nextFundingTime = nextFundingTime
        self.freshness = try PerpetualMarketDataFreshnessEvidence(
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
    }
}

/// PerpetualOpenInterestReadModel 保存 USDⓈ-M Perpetual open interest read model。
///
/// Open interest 是市场级公开指标，不等于本账户仓位、broker position sync 或 portfolio exposure。
public struct PerpetualOpenInterestReadModel: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let openInterest: Quantity
    public let freshness: PerpetualMarketDataFreshnessEvidence

    public init(
        instrument: InstrumentIdentity,
        openInterest: Double,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws {
        guard instrument.productType == .usdsPerpetual else {
            throw PerpetualMarketDataReadModelError.invalidInstrument(instrument)
        }
        self.instrument = instrument
        self.openInterest = try Quantity(openInterest, field: "perpetualOpenInterest")
        self.freshness = try PerpetualMarketDataFreshnessEvidence(
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
    }
}

/// PerpetualMarketDataCacheSnapshot 汇总 Perp mark/funding/open-interest read model state。
public struct PerpetualMarketDataCacheSnapshot: Codable, Equatable, Sendable {
    public let markPricesByInstrument: [InstrumentIdentity: PerpetualMarkPriceReadModel]
    public let fundingRatesByInstrument: [InstrumentIdentity: PerpetualFundingRateReadModel]
    public let openInterestsByInstrument: [InstrumentIdentity: PerpetualOpenInterestReadModel]

    public init(
        markPricesByInstrument: [InstrumentIdentity: PerpetualMarkPriceReadModel] = [:],
        fundingRatesByInstrument: [InstrumentIdentity: PerpetualFundingRateReadModel] = [:],
        openInterestsByInstrument: [InstrumentIdentity: PerpetualOpenInterestReadModel] = [:]
    ) {
        self.markPricesByInstrument = markPricesByInstrument
        self.fundingRatesByInstrument = fundingRatesByInstrument
        self.openInterestsByInstrument = openInterestsByInstrument
    }

    public var evidenceCount: Int {
        markPricesByInstrument.count
            + fundingRatesByInstrument.count
            + openInterestsByInstrument.count
    }
}

/// PerpetualMarketDataCache 是 Cache target 的 Perp public read-model cache。
///
/// 它只接收调用方已经规范化的 public market evidence，不读取 Binance 网络、account endpoint、
/// private stream、broker payload 或 production Runtime object。
public struct PerpetualMarketDataCache: Equatable, Sendable {
    public private(set) var snapshot: PerpetualMarketDataCacheSnapshot

    public init(snapshot: PerpetualMarketDataCacheSnapshot = PerpetualMarketDataCacheSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func ingestMarkPrice(
        instrument: InstrumentIdentity,
        markPrice: Double,
        indexPrice: Double,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws -> PerpetualMarketDataCacheSnapshot {
        var markPrices = snapshot.markPricesByInstrument
        markPrices[instrument] = try PerpetualMarkPriceReadModel(
            instrument: instrument,
            markPrice: markPrice,
            indexPrice: indexPrice,
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
        snapshot = PerpetualMarketDataCacheSnapshot(
            markPricesByInstrument: markPrices,
            fundingRatesByInstrument: snapshot.fundingRatesByInstrument,
            openInterestsByInstrument: snapshot.openInterestsByInstrument
        )
        return snapshot
    }

    @discardableResult
    public mutating func ingestFundingRate(
        instrument: InstrumentIdentity,
        fundingRate: Double,
        nextFundingTime: Date,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws -> PerpetualMarketDataCacheSnapshot {
        var fundingRates = snapshot.fundingRatesByInstrument
        fundingRates[instrument] = try PerpetualFundingRateReadModel(
            instrument: instrument,
            fundingRate: fundingRate,
            nextFundingTime: nextFundingTime,
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
        snapshot = PerpetualMarketDataCacheSnapshot(
            markPricesByInstrument: snapshot.markPricesByInstrument,
            fundingRatesByInstrument: fundingRates,
            openInterestsByInstrument: snapshot.openInterestsByInstrument
        )
        return snapshot
    }

    @discardableResult
    public mutating func ingestOpenInterest(
        instrument: InstrumentIdentity,
        openInterest: Double,
        observedAt: Date,
        evaluatedAt: Date,
        staleAfter: TimeInterval
    ) throws -> PerpetualMarketDataCacheSnapshot {
        var openInterests = snapshot.openInterestsByInstrument
        openInterests[instrument] = try PerpetualOpenInterestReadModel(
            instrument: instrument,
            openInterest: openInterest,
            observedAt: observedAt,
            evaluatedAt: evaluatedAt,
            staleAfter: staleAfter
        )
        snapshot = PerpetualMarketDataCacheSnapshot(
            markPricesByInstrument: snapshot.markPricesByInstrument,
            fundingRatesByInstrument: snapshot.fundingRatesByInstrument,
            openInterestsByInstrument: openInterests
        )
        return snapshot
    }
}
