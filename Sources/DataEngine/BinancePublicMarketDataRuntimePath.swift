import Cache
import DataClient
import DomainModel
import Foundation
import MessageBus

/// BinancePublicMarketDataRuntimePathError 描述 release v0.1.0 public market data path 的本地合同错误。
///
/// 这些错误只覆盖 DataClient -> DataEngine -> Cache 的只读公开行情链路，不代表 Binance
/// account、signed endpoint、private stream、broker 或订单执行状态。
public enum BinancePublicMarketDataRuntimePathError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidRecordedAtStride(TimeInterval)
    case noMarketEventsLoaded
    case invalidSpotInstrument(field: String, expected: String, actual: String)

    public var description: String {
        switch self {
        case let .invalidRecordedAtStride(value):
            "Binance public market data runtime path recordedAt stride must be positive: \(value)"
        case .noMarketEventsLoaded:
            "Binance public market data runtime path requires at least one public market event"
        case let .invalidSpotInstrument(field, expected, actual):
            "Binance Spot public market data runtime path \(field) mismatch: expected \(expected), actual \(actual)"
        }
    }
}

/// BinancePublicMarketDataRuntimePlan 描述一次 Binance public 行情进入 DataEngine / Cache 的输入范围。
///
/// plan 只包含 public endpoint 所需的 symbol、timeframe、时间范围和 limit。它不携带 API key、
/// secret、account endpoint、listenKey、broker venue 或 order command；required validation
/// 应通过 mock transport 运行，真实 Binance public 网络只能作为人工可选 smoke。
public struct BinancePublicMarketDataRuntimePlan: Equatable, Sendable {
    public let sourceID: FoundationTargetID
    public let instrument: InstrumentIdentity
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let range: DateRange
    public let datasetVersion: String
    public let klineLimit: Int
    public let recentTradeLimit: Int
    public let depthSnapshotLimit: BinanceDepthSnapshotLimit
    public let bestBidAskObservedAt: Date
    public let depthSnapshotObservedAt: Date
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        sourceID: FoundationTargetID,
        instrument: InstrumentIdentity,
        symbol: Symbol,
        timeframe: Timeframe,
        range: DateRange,
        datasetVersion: String,
        klineLimit: Int,
        recentTradeLimit: Int,
        depthSnapshotLimit: BinanceDepthSnapshotLimit,
        bestBidAskObservedAt: Date,
        depthSnapshotObservedAt: Date,
        firstRecordedAt: Date,
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw BinancePublicMarketDataRuntimePathError.invalidRecordedAtStride(recordedAtStride)
        }
        try Self.validateSpotInstrument(instrument, symbol: symbol)
        self.sourceID = sourceID
        self.instrument = instrument
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
        self.datasetVersion = datasetVersion
        self.klineLimit = klineLimit
        self.recentTradeLimit = recentTradeLimit
        self.depthSnapshotLimit = depthSnapshotLimit
        self.bestBidAskObservedAt = bestBidAskObservedAt
        self.depthSnapshotObservedAt = depthSnapshotObservedAt
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public init(
        sourceID: FoundationTargetID,
        symbol: Symbol,
        timeframe: Timeframe,
        range: DateRange,
        datasetVersion: String,
        klineLimit: Int,
        recentTradeLimit: Int,
        depthSnapshotLimit: BinanceDepthSnapshotLimit,
        bestBidAskObservedAt: Date,
        depthSnapshotObservedAt: Date,
        firstRecordedAt: Date,
        recordedAtStride: TimeInterval = 1
    ) throws {
        try self.init(
            sourceID: sourceID,
            instrument: InstrumentIdentity.binance(productType: .spot, symbol: symbol),
            symbol: symbol,
            timeframe: timeframe,
            range: range,
            datasetVersion: datasetVersion,
            klineLimit: klineLimit,
            recentTradeLimit: recentTradeLimit,
            depthSnapshotLimit: depthSnapshotLimit,
            bestBidAskObservedAt: bestBidAskObservedAt,
            depthSnapshotObservedAt: depthSnapshotObservedAt,
            firstRecordedAt: firstRecordedAt,
            recordedAtStride: recordedAtStride
        )
    }

    /// DataClient source identity 固定为 Binance public read-only input，不表达私有账户或订单能力。
    public func dataSource() throws -> DataClientReadOnlyMarketDataSource {
        try DataClientReadOnlyMarketDataSource(
            sourceID: sourceID,
            venue: .binance,
            symbol: symbol,
            timeframe: timeframe,
            datasetVersion: datasetVersion
        )
    }

    /// 构造本 issue 覆盖的全部 public request contract，用于验证没有 signed / account / order path。
    public func publicRequestContracts() throws -> [BinancePublicRequestContract] {
        try [
            BinancePublicMarketDataContract.request(
                for: .klines(
                    symbol: symbol,
                    timeframe: timeframe,
                    range: range,
                    limit: klineLimit
                )
            ),
            BinancePublicMarketDataContract.request(
                for: .recentTrades(symbol: symbol, limit: recentTradeLimit)
            ),
            BinancePublicMarketDataContract.request(for: .bestBidAsk(symbol: symbol)),
            BinancePublicMarketDataContract.request(
                for: .depthSnapshot(symbol: symbol, limit: depthSnapshotLimit)
            ),
            BinancePublicMarketDataContract.request(for: .depthDelta(symbol: symbol))
        ]
    }

    /// 按事件位置生成确定性 recordedAt，保证 replay / cache projection 可重复验证。
    public func recordedAt(forEventAt index: Int) -> Date {
        firstRecordedAt.addingTimeInterval(TimeInterval(index) * recordedAtStride)
    }

    fileprivate static func validateSpotInstrument(_ instrument: InstrumentIdentity, symbol: Symbol) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw BinancePublicMarketDataRuntimePathError.invalidSpotInstrument(
                field: "instrument.venue",
                expected: "binance",
                actual: instrument.venue.rawValue
            )
        }
        guard instrument.productType == .spot else {
            throw BinancePublicMarketDataRuntimePathError.invalidSpotInstrument(
                field: "instrument.productType",
                expected: ProductType.spot.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard instrument.symbol == symbol else {
            throw BinancePublicMarketDataRuntimePathError.invalidSpotInstrument(
                field: "instrument.symbol",
                expected: symbol.rawValue,
                actual: instrument.symbol.rawValue
            )
        }
    }
}

/// BinanceSpotProductAwareMarketDataEvent 是 release v0.2.0 的 Spot 行情事件 wrapper。
///
/// wrapper 把原始 public `MarketEvent` 与 Binance Spot `InstrumentIdentity` 绑定起来，让
/// DataEngine / MessageBus / Cache evidence 不再只靠 symbol 区分产品类型。它不包含
/// signed endpoint、account payload、listenKey、broker order 或 production trading 授权。
public struct BinanceSpotProductAwareMarketDataEvent: Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let marketEvent: MarketEvent

    public init(
        instrument: InstrumentIdentity,
        marketEvent: MarketEvent
    ) throws {
        try BinancePublicMarketDataRuntimePlan.validateSpotInstrument(
            instrument,
            symbol: marketEvent.symbol
        )
        self.instrument = instrument
        self.marketEvent = marketEvent
    }

    public var productType: ProductType {
        instrument.productType
    }

    public var symbol: Symbol {
        instrument.symbol
    }
}

/// BinancePublicMarketDataRuntimePathResult 是 GH-524 的 DataClient -> DataEngine -> Cache 证据。
///
/// result 同时保留原始 MarketEvent、MessageBus replay、实时 cache snapshot 和 replay 重建
/// cache snapshot。两份 cache snapshot 必须一致，证明 public 行情已通过 DataEngine
/// 中立事实流进入 Cache read model，而不是只在 DataClient decoder 中停留。
public struct BinancePublicMarketDataRuntimePathResult: Equatable, Sendable {
    public let source: DataClientReadOnlyMarketDataSource
    public let instrument: InstrumentIdentity
    public let publicRequestContracts: [BinancePublicRequestContract]
    public let marketEvents: [MarketEvent]
    public let productAwareEvents: [BinanceSpotProductAwareMarketDataEvent]
    public let eventEnvelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let cacheSnapshot: MarketDataCacheSnapshot
    public let replayedCacheSnapshot: MarketDataCacheSnapshot
    public let validationAnchors: [String]

    public init(
        source: DataClientReadOnlyMarketDataSource,
        instrument: InstrumentIdentity,
        publicRequestContracts: [BinancePublicRequestContract],
        marketEvents: [MarketEvent],
        productAwareEvents: [BinanceSpotProductAwareMarketDataEvent],
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        cacheSnapshot: MarketDataCacheSnapshot,
        replayedCacheSnapshot: MarketDataCacheSnapshot,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.source = source
        self.instrument = instrument
        self.publicRequestContracts = publicRequestContracts
        self.marketEvents = marketEvents
        self.productAwareEvents = productAwareEvents
        self.eventEnvelopes = eventEnvelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.cacheSnapshot = cacheSnapshot
        self.replayedCacheSnapshot = replayedCacheSnapshot
        self.validationAnchors = validationAnchors
    }

    public var requestedPublicPaths: [String] {
        publicRequestContracts.map(\.path)
    }

    public var cacheProjectionMatchesReplay: Bool {
        cacheSnapshot == replayedCacheSnapshot
            && cacheSnapshot.marketEventCount == marketEvents.count
            && replayedEnvelopes == eventEnvelopes
    }

    public var spotProductAwareEventsBoundaryHeld: Bool {
        productAwareEvents.count == marketEvents.count
            && productAwareEvents.allSatisfy { productAwareEvent in
                productAwareEvent.instrument == instrument
                    && productAwareEvent.productType == .spot
                    && productAwareEvent.marketEvent.symbol == instrument.symbol
            }
            && eventEnvelopes.allSatisfy { envelope in
                envelope.instrumentID == instrument
                    && envelope.productType == .spot
                    && envelope.payloadType.contains("binance.spot")
            }
    }

    public var publicMarketDataRuntimePathBoundaryHeld: Bool {
        source.publicReadOnlyBoundaryHeld
            && publicRequestBoundaryHeld
            && spotProductAwareEventsBoundaryHeld
            && cacheProjectionMatchesReplay
            && validationAnchors == Self.requiredValidationAnchors
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsPrivateWebSocketRuntime == false
            && routesBrokerOrExecutionCommand == false
            && enablesProductionTrading == false
    }

    public var publicRequestBoundaryHeld: Bool {
        publicRequestContracts.allSatisfy { contract in
            contract.isReadOnly
                && contract.requiresAPIKey == false
                && Self.forbiddenPublicRequestFragments.contains { fragment in
                    contract.path.lowercased().contains(fragment)
                        || contract.queryItems.contains { item in
                            item.name.lowercased().contains(fragment)
                                || item.value.lowercased().contains(fragment)
                        }
                } == false
        }
    }

    public var callsSignedEndpoint: Bool { false }
    public var callsAccountEndpoint: Bool { false }
    public var createsListenKey: Bool { false }
    public var connectsPrivateWebSocketRuntime: Bool { false }
    public var routesBrokerOrExecutionCommand: Bool { false }
    public var enablesProductionTrading: Bool { false }

    public static let requiredValidationAnchors = [
        "GH-524-BINANCE-PUBLIC-MARKET-DATA-RUNTIME-PATH",
        "GH-573-BINANCE-SPOT-PRODUCT-AWARE-DATAENGINE-CACHE-PATH",
        "TVM-RELEASE-V020-BINANCE-SPOT-DATAENGINE-CACHE-PATH",
        "TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH"
    ]

    private static let forbiddenPublicRequestFragments = [
        "apikey",
        "signature",
        "listenkey",
        "/api/v3/account",
        "/api/v3/order",
        "/api/v3/userdatastream",
        "/sapi/",
        "/fapi/",
        "/dapi/"
    ]
}

/// BinancePublicMarketDataRuntimePath 是 DataEngine target 拥有的只读 ingest / replay / cache 链路。
///
/// 它只调用 `DataClient.BinancePublicMarketDataClient` 的 public market data methods，
/// 再把生成的 `MarketEvent` 写入 `MessageBus` 并投影到 `Cache.MarketDataCache`。
/// 这里不读取 secret，不创建 signed request，不连接 private stream，不触发 broker / OMS / order command。
public struct BinancePublicMarketDataRuntimePath: Sendable {
    private let client: BinancePublicMarketDataClient

    public init(client: BinancePublicMarketDataClient) {
        self.client = client
    }

    public func run(_ plan: BinancePublicMarketDataRuntimePlan) async throws -> BinancePublicMarketDataRuntimePathResult {
        let source = try plan.dataSource()
        let publicRequestContracts = try plan.publicRequestContracts()
        let marketEvents = try await loadMarketEvents(for: plan)
        guard marketEvents.isEmpty == false else {
            throw BinancePublicMarketDataRuntimePathError.noMarketEventsLoaded
        }
        let productAwareEvents = try marketEvents.map { event in
            try BinanceSpotProductAwareMarketDataEvent(
                instrument: plan.instrument,
                marketEvent: event
            )
        }

        let journalStream = try MessageBusJournalStreamID("dataengine.binance-public-market")
        var journal = try MessageBusAppendOnlyJournal()
        var cache = MarketDataCache()
        var envelopes: [MessageBusJournalEnvelope] = []
        for (index, productAwareEvent) in productAwareEvents.enumerated() {
            let envelope = try journal.append(
                stream: journalStream,
                sourceID: plan.sourceID,
                payloadType: payloadType(for: productAwareEvent),
                instrumentID: productAwareEvent.instrument,
                recordedAt: plan.recordedAt(forEventAt: index)
            )
            envelopes.append(envelope)
            cache.ingest(productAwareEvent.marketEvent)
        }

        let replayedEnvelopes = journal.replay(stream: journalStream)
        let replayedCache = MarketDataCache.project(marketEvents)

        return BinancePublicMarketDataRuntimePathResult(
            source: source,
            instrument: plan.instrument,
            publicRequestContracts: publicRequestContracts,
            marketEvents: marketEvents,
            productAwareEvents: productAwareEvents,
            eventEnvelopes: envelopes,
            replayedEnvelopes: replayedEnvelopes,
            cacheSnapshot: cache.snapshot,
            replayedCacheSnapshot: replayedCache
        )
    }

    private func loadMarketEvents(for plan: BinancePublicMarketDataRuntimePlan) async throws -> [MarketEvent] {
        let bars = try await client.klines(
            symbol: plan.symbol,
            timeframe: plan.timeframe,
            range: plan.range,
            limit: plan.klineLimit
        )
        let trades = try await client.recentTrades(
            symbol: plan.symbol,
            limit: plan.recentTradeLimit
        )
        let bestBidAsk = try await client.bestBidAsk(
            symbol: plan.symbol,
            observedAt: plan.bestBidAskObservedAt
        )
        let depthSnapshot = try await client.depthSnapshot(
            symbol: plan.symbol,
            limit: plan.depthSnapshotLimit,
            observedAt: plan.depthSnapshotObservedAt
        )
        let depthDelta = try await client.depthDelta(symbol: plan.symbol)

        return bars.map(MarketEvent.bar)
            + trades.map(MarketEvent.trade)
            + [
                .bestBidAsk(bestBidAsk),
                .orderBookSnapshot(depthSnapshot),
                .orderBookDelta(depthDelta)
            ]
    }

    private func payloadType(for productAwareEvent: BinanceSpotProductAwareMarketDataEvent) -> String {
        let prefix = "dataengine.binance.\(productAwareEvent.productType.rawValue)"
        switch productAwareEvent.marketEvent {
        case let .bar(bar):
            return "\(prefix).market.bar.\(bar.symbol.rawValue).\(bar.timeframe.rawValue)"
        case let .trade(trade):
            return "\(prefix).market.trade.\(trade.symbol.rawValue)"
        case let .bestBidAsk(bestBidAsk):
            return "\(prefix).market.best-bid-ask.\(bestBidAsk.symbol.rawValue)"
        case let .orderBookSnapshot(snapshot):
            return "\(prefix).market.order-book-snapshot.\(snapshot.symbol.rawValue)"
        case let .orderBookDelta(delta):
            return "\(prefix).market.order-book-delta.\(delta.symbol.rawValue)"
        }
    }
}
