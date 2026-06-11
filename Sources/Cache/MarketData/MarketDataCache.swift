import DomainModel
import Foundation
import MessageBus

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

/// ProductAwareMarketDataSeriesKey 用 instrument + timeframe 区分同一 symbol 的 Spot / Perp 序列。
public struct ProductAwareMarketDataSeriesKey: Codable, Equatable, Hashable, Sendable {
    public let instrument: InstrumentIdentity
    public let timeframe: Timeframe

    public init(instrument: InstrumentIdentity, timeframe: Timeframe) {
        self.instrument = instrument
        self.timeframe = timeframe
    }
}

/// ProductAwareStrategyStateKey 用 instrument + strategyID 区分相同策略在不同产品上的状态。
public struct ProductAwareStrategyStateKey: Codable, Equatable, Hashable, Sendable {
    public let instrument: InstrumentIdentity
    public let strategyID: Identifier

    public init(instrument: InstrumentIdentity, strategyID: Identifier) {
        self.instrument = instrument
        self.strategyID = strategyID
    }
}

/// ProductAwareOrderStateKey 用 instrument + orderIntentID 区分 pre-risk order intent read state。
public struct ProductAwareOrderStateKey: Codable, Equatable, Hashable, Sendable {
    public let instrument: InstrumentIdentity
    public let orderIntentID: Identifier

    public init(instrument: InstrumentIdentity, orderIntentID: Identifier) {
        self.instrument = instrument
        self.orderIntentID = orderIntentID
    }
}

/// ProductAwarePositionStateKey 用 instrument + positionID 区分本地 position read state。
public struct ProductAwarePositionStateKey: Codable, Equatable, Hashable, Sendable {
    public let instrument: InstrumentIdentity
    public let positionID: Identifier

    public init(instrument: InstrumentIdentity, positionID: Identifier) {
        self.instrument = instrument
        self.positionID = positionID
    }
}

/// ProductAwareMarketDataCacheSnapshot 是 release v0.2.0 的产品感知行情投影。
///
/// 旧 `MarketDataCacheSnapshot` 继续保留 symbol-based compatibility surface；该 snapshot
/// 专门给 Spot / USDⓈ-M Perpetual 同 symbol 并存使用，所有 key 都必须包含 `InstrumentIdentity`。
public struct ProductAwareMarketDataCacheSnapshot: Codable, Equatable, Sendable {
    public let barsBySeries: [ProductAwareMarketDataSeriesKey: [MarketBar]]
    public let tradesByInstrument: [InstrumentIdentity: [TradeTick]]
    public let bestBidAskByInstrument: [InstrumentIdentity: BestBidAsk]
    public let orderBookSnapshotsByInstrument: [InstrumentIdentity: OrderBookSnapshot]
    public let orderBookDeltasByInstrument: [InstrumentIdentity: [OrderBookDelta]]

    public init(
        barsBySeries: [ProductAwareMarketDataSeriesKey: [MarketBar]] = [:],
        tradesByInstrument: [InstrumentIdentity: [TradeTick]] = [:],
        bestBidAskByInstrument: [InstrumentIdentity: BestBidAsk] = [:],
        orderBookSnapshotsByInstrument: [InstrumentIdentity: OrderBookSnapshot] = [:],
        orderBookDeltasByInstrument: [InstrumentIdentity: [OrderBookDelta]] = [:]
    ) {
        self.barsBySeries = barsBySeries
        self.tradesByInstrument = tradesByInstrument
        self.bestBidAskByInstrument = bestBidAskByInstrument
        self.orderBookSnapshotsByInstrument = orderBookSnapshotsByInstrument
        self.orderBookDeltasByInstrument = orderBookDeltasByInstrument
    }

    public var marketEventCount: Int {
        barsBySeries.values.reduce(0) { $0 + $1.count }
            + tradesByInstrument.values.reduce(0) { $0 + $1.count }
            + bestBidAskByInstrument.count
            + orderBookSnapshotsByInstrument.count
            + orderBookDeltasByInstrument.values.reduce(0) { $0 + $1.count }
    }

    public var productAwareBoundaryHeld: Bool {
        let barKeysMatch = barsBySeries.allSatisfy { key, bars in
            bars.allSatisfy { $0.symbol == key.instrument.symbol }
        }
        let tradeKeysMatch = tradesByInstrument.allSatisfy { instrument, trades in
            trades.allSatisfy { $0.symbol == instrument.symbol }
        }
        let bestBidAskKeysMatch = bestBidAskByInstrument.allSatisfy { instrument, bestBidAsk in
            bestBidAsk.symbol == instrument.symbol
        }
        let snapshotKeysMatch = orderBookSnapshotsByInstrument.allSatisfy { instrument, snapshot in
            snapshot.symbol == instrument.symbol
        }
        let deltaKeysMatch = orderBookDeltasByInstrument.allSatisfy { instrument, deltas in
            deltas.allSatisfy { $0.symbol == instrument.symbol }
        }
        return barKeysMatch
            && tradeKeysMatch
            && bestBidAskKeysMatch
            && snapshotKeysMatch
            && deltaKeysMatch
    }

    public func applying(
        _ event: MarketEvent,
        instrument: InstrumentIdentity
    ) throws -> ProductAwareMarketDataCacheSnapshot {
        try Self.validate(event, matches: instrument)

        var barsBySeries = barsBySeries
        var tradesByInstrument = tradesByInstrument
        var bestBidAskByInstrument = bestBidAskByInstrument
        var orderBookSnapshotsByInstrument = orderBookSnapshotsByInstrument
        var orderBookDeltasByInstrument = orderBookDeltasByInstrument

        switch event {
        case let .bar(bar):
            let key = ProductAwareMarketDataSeriesKey(
                instrument: instrument,
                timeframe: bar.timeframe
            )
            barsBySeries[key, default: []].append(bar)
        case let .trade(trade):
            tradesByInstrument[instrument, default: []].append(trade)
        case let .bestBidAsk(bestBidAsk):
            bestBidAskByInstrument[instrument] = bestBidAsk
        case let .orderBookSnapshot(snapshot):
            orderBookSnapshotsByInstrument[instrument] = snapshot
        case let .orderBookDelta(delta):
            orderBookDeltasByInstrument[instrument, default: []].append(delta)
        }

        return ProductAwareMarketDataCacheSnapshot(
            barsBySeries: barsBySeries,
            tradesByInstrument: tradesByInstrument,
            bestBidAskByInstrument: bestBidAskByInstrument,
            orderBookSnapshotsByInstrument: orderBookSnapshotsByInstrument,
            orderBookDeltasByInstrument: orderBookDeltasByInstrument
        )
    }

    private static func validate(
        _ event: MarketEvent,
        matches instrument: InstrumentIdentity
    ) throws {
        guard event.symbol == instrument.symbol else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwareCache.instrument.symbol",
                expected: instrument.symbol.rawValue,
                actual: event.symbol.rawValue
            )
        }
    }
}

/// ProductAwareStrategyState 保存 strategy output 的产品感知 read state。
///
/// 该状态只保存进入 RiskEngine 前的中性 intent evidence，不授权 ExecutionEngine、OMS、
/// ExecutionClient、broker command 或 production trading。
public struct ProductAwareStrategyState: Codable, Equatable, Sendable {
    public let key: ProductAwareStrategyStateKey
    public let targetExposure: TargetExposureIntent
    public let productAwareOrderIntent: ProductAwareOrderIntent?
    public let emittedAt: Date
    public let sourceSequence: Int
    public let requiresRiskGateBeforeExecution: Bool
    public let authorizesTradingExecution: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        message: StrategyIntentMessage,
        sourceSequence: Int
    ) throws {
        try Self.validateSourceSequence(sourceSequence)
        self.key = ProductAwareStrategyStateKey(
            instrument: message.instrument,
            strategyID: message.strategyID
        )
        self.targetExposure = message.targetExposure
        self.productAwareOrderIntent = message.productAwareOrderIntent
        self.emittedAt = message.emittedAt
        self.sourceSequence = sourceSequence
        self.requiresRiskGateBeforeExecution = message.productAwareOrderIntent?.requiresRiskGateBeforeExecution ?? true
        self.authorizesTradingExecution = message.productAwareOrderIntent?.authorizesTradingExecution ?? false
        self.productionTradingEnabledByDefault = message.productAwareOrderIntent?.productionTradingEnabledByDefault ?? false
        guard isPreRiskOnlyState else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwareStrategyState.boundary",
                expected: "pre-risk only strategy state",
                actual: "execution-authorizing strategy state"
            )
        }
    }

    public var isPreRiskOnlyState: Bool {
        requiresRiskGateBeforeExecution
            && authorizesTradingExecution == false
            && productionTradingEnabledByDefault == false
    }

    private static func validateSourceSequence(_ sourceSequence: Int) throws {
        guard sourceSequence > 0 else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwareStrategyState.sourceSequence",
                expected: "positive sequence",
                actual: "\(sourceSequence)"
            )
        }
    }
}

/// ProductAwareOrderState 保存 product-aware order intent 的只读状态。
///
/// 这里的 order state 仍处于 pre-risk / pre-execution 阶段，不是 OMS order、broker order
/// 或真实 submit / cancel / replace command。
public struct ProductAwareOrderState: Codable, Equatable, Sendable {
    public let key: ProductAwareOrderStateKey
    public let targetExposure: TargetExposureIntent
    public let quantity: Quantity
    public let referencePrice: Price
    public let createdAt: Date
    public let sourceSequence: Int
    public let requiresRiskGateBeforeExecution: Bool
    public let authorizesTradingExecution: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        orderIntent: ProductAwareOrderIntent,
        sourceSequence: Int
    ) throws {
        try Self.validateSourceSequence(sourceSequence)
        guard orderIntent.isPreRiskGateIntent else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwareOrderState.boundary",
                expected: "pre-risk order intent",
                actual: "execution-authorizing order state"
            )
        }
        self.key = ProductAwareOrderStateKey(
            instrument: orderIntent.instrument,
            orderIntentID: orderIntent.intentID
        )
        self.targetExposure = orderIntent.targetExposure
        self.quantity = orderIntent.quantity
        self.referencePrice = orderIntent.referencePrice
        self.createdAt = orderIntent.createdAt
        self.sourceSequence = sourceSequence
        self.requiresRiskGateBeforeExecution = orderIntent.requiresRiskGateBeforeExecution
        self.authorizesTradingExecution = orderIntent.authorizesTradingExecution
        self.productionTradingEnabledByDefault = orderIntent.productionTradingEnabledByDefault
    }

    public var isPreRiskOnlyState: Bool {
        requiresRiskGateBeforeExecution
            && authorizesTradingExecution == false
            && productionTradingEnabledByDefault == false
    }

    private static func validateSourceSequence(_ sourceSequence: Int) throws {
        guard sourceSequence > 0 else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwareOrderState.sourceSequence",
                expected: "positive sequence",
                actual: "\(sourceSequence)"
            )
        }
    }
}

/// ProductAwarePositionState 保存 product-aware 本地 position read state。
///
/// 该状态不代表 broker position、margin position、leverage state 或真实账户持仓；后续
/// reconciliation/portfolio issue 可在自己的 scope 内消费它，但不能把它当作 broker sync。
public struct ProductAwarePositionState: Codable, Equatable, Sendable {
    public let key: ProductAwarePositionStateKey
    public let portfolioID: Identifier
    public let netQuantity: Quantity
    public let averageEntryPrice: Price
    public let updatedAt: Date
    public let sourceSequence: Int
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let representsBrokerPosition: Bool

    public init(
        positionID: Identifier,
        portfolioID: Identifier,
        instrument: InstrumentIdentity,
        netQuantity: Double,
        averageEntryPrice: Double,
        updatedAt: Date,
        sourceSequence: Int,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        representsBrokerPosition: Bool = false
    ) throws {
        try Self.validateSourceSequence(sourceSequence)
        let forbiddenFlags = [
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("representsBrokerPosition", representsBrokerPosition)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CacheContractError.marketDataMismatch(
                field: "productAwarePositionState.\(forbidden.0)",
                expected: "false",
                actual: "true"
            )
        }
        self.key = ProductAwarePositionStateKey(
            instrument: instrument,
            positionID: positionID
        )
        self.portfolioID = portfolioID
        self.netQuantity = try Quantity(netQuantity, field: "productAwarePosition.netQuantity")
        self.averageEntryPrice = try Price(averageEntryPrice, field: "productAwarePosition.averageEntryPrice")
        self.updatedAt = updatedAt
        self.sourceSequence = sourceSequence
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.representsBrokerPosition = representsBrokerPosition
    }

    public var localReadModelBoundaryHeld: Bool {
        syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
            && representsBrokerPosition == false
    }

    private static func validateSourceSequence(_ sourceSequence: Int) throws {
        guard sourceSequence > 0 else {
            throw CacheContractError.marketDataMismatch(
                field: "productAwarePositionState.sourceSequence",
                expected: "positive sequence",
                actual: "\(sourceSequence)"
            )
        }
    }
}

/// ProductAwareCacheReplayFact 是 Cache target 可直接 replay 的本地事实。
///
/// 它只承载已经规范化的 read-model facts，不包含 raw exchange payload、private account
/// payload、broker response、secret、endpoint 或 live command。
public enum ProductAwareCacheReplayFact: Codable, Equatable, Sendable {
    case marketEvent(instrument: InstrumentIdentity, event: MarketEvent)
    case strategyIntent(message: StrategyIntentMessage, sourceSequence: Int)
    case orderIntent(intent: ProductAwareOrderIntent, sourceSequence: Int)
    case positionState(ProductAwarePositionState)
}

/// ProductAwareCacheSnapshot 汇总 release v0.2.0 Cache 的 product-aware read-model state。
public struct ProductAwareCacheSnapshot: Codable, Equatable, Sendable {
    public let marketData: ProductAwareMarketDataCacheSnapshot
    public let strategyStatesByKey: [ProductAwareStrategyStateKey: ProductAwareStrategyState]
    public let orderStatesByKey: [ProductAwareOrderStateKey: ProductAwareOrderState]
    public let positionStatesByKey: [ProductAwarePositionStateKey: ProductAwarePositionState]

    public init(
        marketData: ProductAwareMarketDataCacheSnapshot = ProductAwareMarketDataCacheSnapshot(),
        strategyStatesByKey: [ProductAwareStrategyStateKey: ProductAwareStrategyState] = [:],
        orderStatesByKey: [ProductAwareOrderStateKey: ProductAwareOrderState] = [:],
        positionStatesByKey: [ProductAwarePositionStateKey: ProductAwarePositionState] = [:]
    ) {
        self.marketData = marketData
        self.strategyStatesByKey = strategyStatesByKey
        self.orderStatesByKey = orderStatesByKey
        self.positionStatesByKey = positionStatesByKey
    }

    public var evidenceCount: Int {
        marketData.marketEventCount
            + strategyStatesByKey.count
            + orderStatesByKey.count
            + positionStatesByKey.count
    }

    public var productAwareBoundaryHeld: Bool {
        marketData.productAwareBoundaryHeld
            && strategyStatesByKey.allSatisfy { key, state in
                key == state.key && state.isPreRiskOnlyState
            }
            && orderStatesByKey.allSatisfy { key, state in
                key == state.key && state.isPreRiskOnlyState
            }
            && positionStatesByKey.allSatisfy { key, state in
                key == state.key && state.localReadModelBoundaryHeld
            }
    }
}

/// ProductAwareCache 是 release v0.2.0 的 product-aware Cache aggregate。
///
/// 它只接收本地 public market / strategy intent / pre-risk order intent / local position
/// facts，并能通过 replay facts 重建；它不是 durable store，不读取网络，也不代表 broker state。
public struct ProductAwareCache: Equatable, Sendable {
    public private(set) var snapshot: ProductAwareCacheSnapshot

    public init(snapshot: ProductAwareCacheSnapshot = ProductAwareCacheSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func ingestMarketEvent(
        _ event: MarketEvent,
        instrument: InstrumentIdentity
    ) throws -> ProductAwareCacheSnapshot {
        snapshot = ProductAwareCacheSnapshot(
            marketData: try snapshot.marketData.applying(event, instrument: instrument),
            strategyStatesByKey: snapshot.strategyStatesByKey,
            orderStatesByKey: snapshot.orderStatesByKey,
            positionStatesByKey: snapshot.positionStatesByKey
        )
        return snapshot
    }

    @discardableResult
    public mutating func ingestStrategyIntent(
        _ message: StrategyIntentMessage,
        sourceSequence: Int
    ) throws -> ProductAwareCacheSnapshot {
        var strategyStates = snapshot.strategyStatesByKey
        let state = try ProductAwareStrategyState(
            message: message,
            sourceSequence: sourceSequence
        )
        strategyStates[state.key] = state
        snapshot = ProductAwareCacheSnapshot(
            marketData: snapshot.marketData,
            strategyStatesByKey: strategyStates,
            orderStatesByKey: snapshot.orderStatesByKey,
            positionStatesByKey: snapshot.positionStatesByKey
        )
        return snapshot
    }

    @discardableResult
    public mutating func ingestOrderIntent(
        _ orderIntent: ProductAwareOrderIntent,
        sourceSequence: Int
    ) throws -> ProductAwareCacheSnapshot {
        var orderStates = snapshot.orderStatesByKey
        let state = try ProductAwareOrderState(
            orderIntent: orderIntent,
            sourceSequence: sourceSequence
        )
        orderStates[state.key] = state
        snapshot = ProductAwareCacheSnapshot(
            marketData: snapshot.marketData,
            strategyStatesByKey: snapshot.strategyStatesByKey,
            orderStatesByKey: orderStates,
            positionStatesByKey: snapshot.positionStatesByKey
        )
        return snapshot
    }

    @discardableResult
    public mutating func ingestPositionState(
        _ positionState: ProductAwarePositionState
    ) -> ProductAwareCacheSnapshot {
        var positionStates = snapshot.positionStatesByKey
        positionStates[positionState.key] = positionState
        snapshot = ProductAwareCacheSnapshot(
            marketData: snapshot.marketData,
            strategyStatesByKey: snapshot.strategyStatesByKey,
            orderStatesByKey: snapshot.orderStatesByKey,
            positionStatesByKey: positionStates
        )
        return snapshot
    }

    @discardableResult
    public mutating func replay(
        _ facts: [ProductAwareCacheReplayFact]
    ) throws -> ProductAwareCacheSnapshot {
        self = ProductAwareCache(snapshot: try Self.project(facts))
        return snapshot
    }

    public static func project(
        _ facts: [ProductAwareCacheReplayFact]
    ) throws -> ProductAwareCacheSnapshot {
        var cache = ProductAwareCache()
        for fact in facts {
            switch fact {
            case let .marketEvent(instrument, event):
                try cache.ingestMarketEvent(event, instrument: instrument)
            case let .strategyIntent(message, sourceSequence):
                try cache.ingestStrategyIntent(message, sourceSequence: sourceSequence)
            case let .orderIntent(intent, sourceSequence):
                try cache.ingestOrderIntent(intent, sourceSequence: sourceSequence)
            case let .positionState(positionState):
                cache.ingestPositionState(positionState)
            }
        }
        return cache.snapshot
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
