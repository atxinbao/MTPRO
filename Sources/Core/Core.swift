import Foundation

public enum CoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case unsupportedSymbol(String)
    case unsupportedTimeframe(String)
    case unsupportedExecutionMode(String)
    case liveExecutionForbidden(String)
    case invalidDateRange
    case invalidSequenceRange
    case invalidEventSequence(Int)
    case invalidPrice(String, Double)
    case invalidQuantity(String, Double)
    case paperSessionRequiresPaperMode
    case emptyIdentifier(String)
    case invalidEMAPeriod(String, Int)
    case invalidEMAPeriodOrder(shortPeriod: Int, longPeriod: Int)
    case invalidOrderBookDepth(String, Int)
    case invalidImbalanceThreshold(Double)
    case insufficientOrderBookDepth(required: Int, bidLevels: Int, askLevels: Int)
    case insufficientOrderBookLiquidity
    case insufficientMarketData(required: Int, actual: Int)
    case marketDataMismatch(field: String, expected: String, actual: String)

    public var description: String {
        switch self {
        case let .unsupportedSymbol(value):
            "Unsupported symbol: \(value)"
        case let .unsupportedTimeframe(value):
            "Unsupported timeframe: \(value)"
        case let .unsupportedExecutionMode(value):
            "Unsupported execution mode: \(value)"
        case let .liveExecutionForbidden(value):
            "Live execution is forbidden: \(value)"
        case .invalidDateRange:
            "Date range must have start before end"
        case .invalidSequenceRange:
            "Event sequence range is invalid"
        case let .invalidEventSequence(value):
            "Event sequence must be positive: \(value)"
        case let .invalidPrice(field, value):
            "Price must be finite and positive for \(field): \(value)"
        case let .invalidQuantity(field, value):
            "Quantity must be finite and non-negative for \(field): \(value)"
        case .paperSessionRequiresPaperMode:
            "Paper session command requires paper mode"
        case let .emptyIdentifier(field):
            "Identifier must not be empty: \(field)"
        case let .invalidEMAPeriod(field, value):
            "EMA period must be positive for \(field): \(value)"
        case let .invalidEMAPeriodOrder(shortPeriod, longPeriod):
            "EMA short period must be smaller than long period: \(shortPeriod) >= \(longPeriod)"
        case let .invalidOrderBookDepth(field, value):
            "Order book depth must be positive for \(field): \(value)"
        case let .invalidImbalanceThreshold(value):
            "Order book imbalance threshold must be finite and within 0...1: \(value)"
        case let .insufficientOrderBookDepth(required, bidLevels, askLevels):
            "Order book depth is insufficient: required \(required), bids \(bidLevels), asks \(askLevels)"
        case .insufficientOrderBookLiquidity:
            "Order book liquidity is insufficient for imbalance calculation"
        case let .insufficientMarketData(required, actual):
            "Market data is insufficient: required \(required), actual \(actual)"
        case let .marketDataMismatch(field, expected, actual):
            "Market data mismatch for \(field): expected \(expected), actual \(actual)"
        }
    }
}

public struct Symbol: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let supportedRawValues = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"]

    public let rawValue: String

    public init(rawValue: String) throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard Self.supportedRawValues.contains(normalized) else {
            throw CoreError.unsupportedSymbol(rawValue)
        }
        self.rawValue = normalized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

public enum Timeframe: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"

    public static var supportedRawValues: [String] {
        allCases.map(\.rawValue)
    }

    public init(contractValue: String) throws {
        guard let timeframe = Self(rawValue: contractValue) else {
            throw CoreError.unsupportedTimeframe(contractValue)
        }
        self = timeframe
    }
}

public enum ExecutionMode: String, Codable, CaseIterable, Equatable, Sendable {
    case backtest
    case paper

    public init(contractValue: String) throws {
        let normalized = contractValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case Self.backtest.rawValue:
            self = .backtest
        case Self.paper.rawValue:
            self = .paper
        case "live", "broker", "real", "production":
            throw CoreError.liveExecutionForbidden(contractValue)
        default:
            throw CoreError.unsupportedExecutionMode(contractValue)
        }
    }
}

public struct DateRange: Codable, Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start < end else {
            throw CoreError.invalidDateRange
        }
        self.start = start
        self.end = end
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(Date.self, forKey: .start)
        let end = try container.decode(Date.self, forKey: .end)
        try self.init(start: start, end: end)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }

    private enum CodingKeys: String, CodingKey {
        case start
        case end
    }
}

public struct Identifier: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String, field: String = "identifier") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CoreError.emptyIdentifier(field)
        }
        self.rawValue = trimmed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

public struct Price: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "price") throws {
        guard rawValue.isFinite, rawValue > 0 else {
            throw CoreError.invalidPrice(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct Quantity: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "quantity") throws {
        guard rawValue.isFinite, rawValue >= 0 else {
            throw CoreError.invalidQuantity(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

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

public enum BookSide: String, Codable, Equatable, Sendable {
    case bid
    case ask
}

public struct OrderBookLevel: Codable, Equatable, Sendable {
    public let price: Price
    public let quantity: Quantity

    public init(price: Double, quantity: Double) throws {
        self.price = try Price(price)
        self.quantity = try Quantity(quantity)
    }
}

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

public enum SignalDirection: String, Codable, Equatable, Sendable {
    case long
    case flat
}

public struct StrategySignalEvent: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let direction: SignalDirection
    public let generatedAt: Date

    public init(
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        direction: SignalDirection,
        generatedAt: Date
    ) {
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.direction = direction
        self.generatedAt = generatedAt
    }
}

public enum OrderBookImbalanceBias: String, Codable, Equatable, Sendable {
    case bidDominant
    case neutral
    case askDominant
}

/// 订单簿失衡策略配置只描述本地研究信号，不包含 futures、margin 或真实订单动作。
public struct OrderBookImbalanceStrategyConfiguration: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let depth: Int
    public let signalThreshold: Double

    public init(
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        depth: Int,
        signalThreshold: Double
    ) throws {
        guard depth > 0 else {
            throw CoreError.invalidOrderBookDepth("depth", depth)
        }
        guard signalThreshold.isFinite, (0...1).contains(signalThreshold) else {
            throw CoreError.invalidImbalanceThreshold(signalThreshold)
        }
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.depth = depth
        self.signalThreshold = signalThreshold
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(Identifier.self, forKey: .strategyID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let depth = try container.decode(Int.self, forKey: .depth)
        let signalThreshold = try container.decode(Double.self, forKey: .signalThreshold)
        try self.init(
            strategyID: strategyID,
            symbol: symbol,
            timeframe: timeframe,
            depth: depth,
            signalThreshold: signalThreshold
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(strategyID, forKey: .strategyID)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(depth, forKey: .depth)
        try container.encode(signalThreshold, forKey: .signalThreshold)
    }

    private enum CodingKeys: String, CodingKey {
        case strategyID
        case symbol
        case timeframe
        case depth
        case signalThreshold
    }
}

public struct OrderBookImbalanceSignalSample: Codable, Equatable, Sendable {
    public let signal: StrategySignalEvent
    public let sourceObservedAt: Date
    public let depth: Int
    public let bidNotional: Double
    public let askNotional: Double
    public let imbalanceRatio: Double
    public let bias: OrderBookImbalanceBias

    public init(
        signal: StrategySignalEvent,
        sourceObservedAt: Date,
        depth: Int,
        bidNotional: Double,
        askNotional: Double,
        imbalanceRatio: Double,
        bias: OrderBookImbalanceBias
    ) {
        self.signal = signal
        self.sourceObservedAt = sourceObservedAt
        self.depth = depth
        self.bidNotional = bidNotional
        self.askNotional = askNotional
        self.imbalanceRatio = imbalanceRatio
        self.bias = bias
    }
}

/// 失衡计算只消费本地订单簿读模型输入，输出研究信号和可投影指标。
public struct OrderBookImbalanceStrategyContract: Equatable, Sendable {
    public let configuration: OrderBookImbalanceStrategyConfiguration

    public init(configuration: OrderBookImbalanceStrategyConfiguration) {
        self.configuration = configuration
    }

    public func evaluate(_ inputs: [OrderBookReadModelInput]) throws -> [OrderBookImbalanceSignalSample] {
        let sortedInputs = inputs.sorted { left, right in
            left.observedAt < right.observedAt
        }

        return try sortedInputs.map(sample)
    }

    private func sample(from input: OrderBookReadModelInput) throws -> OrderBookImbalanceSignalSample {
        guard input.symbol == configuration.symbol else {
            throw CoreError.marketDataMismatch(
                field: "orderBook.symbol",
                expected: configuration.symbol.rawValue,
                actual: input.symbol.rawValue
            )
        }

        let bids = Array(input.bids.prefix(configuration.depth))
        let asks = Array(input.asks.prefix(configuration.depth))
        guard bids.count == configuration.depth, asks.count == configuration.depth else {
            throw CoreError.insufficientOrderBookDepth(
                required: configuration.depth,
                bidLevels: bids.count,
                askLevels: asks.count
            )
        }

        let bidNotional = Self.notional(for: bids)
        let askNotional = Self.notional(for: asks)
        let totalNotional = bidNotional + askNotional
        guard totalNotional > 0 else {
            throw CoreError.insufficientOrderBookLiquidity
        }

        let ratio = (bidNotional - askNotional) / totalNotional
        let bias = Self.bias(ratio: ratio, threshold: configuration.signalThreshold)
        let direction: SignalDirection = bias == .bidDominant ? .long : .flat
        let signal = StrategySignalEvent(
            strategyID: configuration.strategyID,
            symbol: configuration.symbol,
            timeframe: configuration.timeframe,
            direction: direction,
            generatedAt: input.observedAt
        )

        return OrderBookImbalanceSignalSample(
            signal: signal,
            sourceObservedAt: input.observedAt,
            depth: configuration.depth,
            bidNotional: bidNotional,
            askNotional: askNotional,
            imbalanceRatio: ratio,
            bias: bias
        )
    }

    private static func notional(for levels: [OrderBookLevel]) -> Double {
        levels.reduce(0) { partialResult, level in
            partialResult + (level.price.rawValue * level.quantity.rawValue)
        }
    }

    private static func bias(ratio: Double, threshold: Double) -> OrderBookImbalanceBias {
        if ratio >= threshold {
            return .bidDominant
        }
        if ratio <= -threshold {
            return .askDominant
        }
        return .neutral
    }
}

/// EMA 交叉策略配置只描述本地研究契约，不包含 broker 或 Live action。
public struct EMACrossStrategyConfiguration: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let shortPeriod: Int
    public let longPeriod: Int

    public init(
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        shortPeriod: Int,
        longPeriod: Int
    ) throws {
        guard shortPeriod > 0 else {
            throw CoreError.invalidEMAPeriod("shortPeriod", shortPeriod)
        }
        guard longPeriod > 0 else {
            throw CoreError.invalidEMAPeriod("longPeriod", longPeriod)
        }
        guard shortPeriod < longPeriod else {
            throw CoreError.invalidEMAPeriodOrder(shortPeriod: shortPeriod, longPeriod: longPeriod)
        }
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.shortPeriod = shortPeriod
        self.longPeriod = longPeriod
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(Identifier.self, forKey: .strategyID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let shortPeriod = try container.decode(Int.self, forKey: .shortPeriod)
        let longPeriod = try container.decode(Int.self, forKey: .longPeriod)
        try self.init(
            strategyID: strategyID,
            symbol: symbol,
            timeframe: timeframe,
            shortPeriod: shortPeriod,
            longPeriod: longPeriod
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(strategyID, forKey: .strategyID)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(shortPeriod, forKey: .shortPeriod)
        try container.encode(longPeriod, forKey: .longPeriod)
    }

    private enum CodingKeys: String, CodingKey {
        case strategyID
        case symbol
        case timeframe
        case shortPeriod
        case longPeriod
    }
}

public struct EMACrossSignalSample: Codable, Equatable, Sendable {
    public let signal: StrategySignalEvent
    public let close: Price
    public let shortEMA: Price
    public let longEMA: Price

    public init(
        signal: StrategySignalEvent,
        close: Double,
        shortEMA: Double,
        longEMA: Double
    ) throws {
        self.signal = signal
        self.close = try Price(close, field: "ema.close")
        self.shortEMA = try Price(shortEMA, field: "ema.short")
        self.longEMA = try Price(longEMA, field: "ema.long")
    }
}

/// EMA 计算保持确定性；回测与 Paper 复用同一契约来避免语义分叉。
public struct EMACrossStrategyContract: Equatable, Sendable {
    public let configuration: EMACrossStrategyConfiguration

    public init(configuration: EMACrossStrategyConfiguration) {
        self.configuration = configuration
    }

    public func evaluate(_ bars: [MarketBar]) throws -> [EMACrossSignalSample] {
        guard bars.count >= configuration.longPeriod else {
            throw CoreError.insufficientMarketData(
                required: configuration.longPeriod,
                actual: bars.count
            )
        }

        let sortedBars = bars.sorted { left, right in
            left.interval.start < right.interval.start
        }
        try validate(sortedBars)

        let shortMultiplier = Self.multiplier(for: configuration.shortPeriod)
        let longMultiplier = Self.multiplier(for: configuration.longPeriod)
        var shortEMA: Double?
        var longEMA: Double?
        var samples: [EMACrossSignalSample] = []

        for (index, bar) in sortedBars.enumerated() {
            let close = bar.close.rawValue
            shortEMA = Self.nextEMA(close: close, previous: shortEMA, multiplier: shortMultiplier)
            longEMA = Self.nextEMA(close: close, previous: longEMA, multiplier: longMultiplier)

            guard index + 1 >= configuration.longPeriod, let shortEMA, let longEMA else {
                continue
            }

            let direction: SignalDirection = shortEMA > longEMA ? .long : .flat
            let signal = StrategySignalEvent(
                strategyID: configuration.strategyID,
                symbol: configuration.symbol,
                timeframe: configuration.timeframe,
                direction: direction,
                generatedAt: bar.interval.end
            )
            let sample = try EMACrossSignalSample(
                signal: signal,
                close: close,
                shortEMA: shortEMA,
                longEMA: longEMA
            )
            samples.append(sample)
        }

        return samples
    }

    private func validate(_ bars: [MarketBar]) throws {
        for bar in bars {
            guard bar.symbol == configuration.symbol else {
                throw CoreError.marketDataMismatch(
                    field: "symbol",
                    expected: configuration.symbol.rawValue,
                    actual: bar.symbol.rawValue
                )
            }
            guard bar.timeframe == configuration.timeframe else {
                throw CoreError.marketDataMismatch(
                    field: "timeframe",
                    expected: configuration.timeframe.rawValue,
                    actual: bar.timeframe.rawValue
                )
            }
        }
    }

    private static func multiplier(for period: Int) -> Double {
        2 / (Double(period) + 1)
    }

    private static func nextEMA(close: Double, previous: Double?, multiplier: Double) -> Double {
        guard let previous else {
            return close
        }
        return (close * multiplier) + (previous * (1 - multiplier))
    }
}

public struct MarketDataQuery: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let range: DateRange

    public init(symbol: Symbol, timeframe: Timeframe, range: DateRange) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
    }
}

public struct OrderBookImbalanceResearchCommand: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let strategy: OrderBookImbalanceStrategyConfiguration
    public let marketData: MarketDataQuery

    public init(
        researchID: Identifier,
        strategy: OrderBookImbalanceStrategyConfiguration,
        marketData: MarketDataQuery
    ) {
        self.researchID = researchID
        self.strategy = strategy
        self.marketData = marketData
    }

    public var strategyID: Identifier {
        strategy.strategyID
    }
}

public struct OrderBookImbalanceResearchResult: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let command: OrderBookImbalanceResearchCommand
    public let signalSamples: [OrderBookImbalanceSignalSample]
    public let completedAt: Date

    public init(
        researchID: Identifier,
        command: OrderBookImbalanceResearchCommand,
        signalSamples: [OrderBookImbalanceSignalSample],
        completedAt: Date
    ) {
        self.researchID = researchID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public enum OrderBookImbalanceResearchEvent: Codable, Equatable, Sendable {
    case requested(OrderBookImbalanceResearchCommand)
    case signalGenerated(OrderBookImbalanceSignalSample)
    case completed(OrderBookImbalanceResearchResult)
}

public enum BacktestEvent: Codable, Equatable, Sendable {
    case requested(BacktestCommand)
    case signalGenerated(EMACrossSignalSample)
    case completed(BacktestResult)
}

public enum PaperEvent: Codable, Equatable, Sendable {
    case sessionRequested(PaperSessionCommand)
    case signalGenerated(EMACrossSignalSample)
    case sessionCompleted(PaperSessionResult)
}

public enum RiskEvent: Codable, Equatable, Sendable {
    case evaluationRequested(RiskEvaluationQuery)
    case rejected(Identifier)
}

public enum PortfolioEvent: Codable, Equatable, Sendable {
    case projectionRequested(PortfolioQuery)
    case projectionUpdated(Identifier)
}

public struct ReplayEvent: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let replayedCount: Int

    public init(command: EventReplayCommand, replayedCount: Int) {
        self.command = command
        self.replayedCount = replayedCount
    }
}

public enum DomainEvent: Codable, Equatable, Sendable {
    case market(MarketEvent)
    case strategySignal(StrategySignalEvent)
    case orderBookImbalanceResearch(OrderBookImbalanceResearchEvent)
    case backtest(BacktestEvent)
    case paper(PaperEvent)
    case risk(RiskEvent)
    case portfolio(PortfolioEvent)
    case replay(ReplayEvent)
}

public struct BacktestCommand: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let strategy: EMACrossStrategyConfiguration
    public let marketData: MarketDataQuery

    public init(
        runID: Identifier,
        strategy: EMACrossStrategyConfiguration,
        marketData: MarketDataQuery
    ) {
        self.runID = runID
        self.strategy = strategy
        self.marketData = marketData
    }

    public var strategyID: Identifier {
        strategy.strategyID
    }
}

public struct PaperSessionCommand: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let strategy: EMACrossStrategyConfiguration
    public let marketData: MarketDataQuery
    public let riskProfileID: Identifier
    public let executionMode: ExecutionMode

    public init(
        sessionID: Identifier,
        strategy: EMACrossStrategyConfiguration,
        marketData: MarketDataQuery,
        riskProfileID: Identifier,
        executionMode: ExecutionMode
    ) throws {
        guard executionMode == .paper else {
            throw CoreError.paperSessionRequiresPaperMode
        }
        self.sessionID = sessionID
        self.strategy = strategy
        self.marketData = marketData
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
    }

    public var strategyID: Identifier {
        strategy.strategyID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sessionID = try container.decode(Identifier.self, forKey: .sessionID)
        let strategy = try container.decode(EMACrossStrategyConfiguration.self, forKey: .strategy)
        let marketData = try container.decode(MarketDataQuery.self, forKey: .marketData)
        let riskProfileID = try container.decode(Identifier.self, forKey: .riskProfileID)
        let executionMode = try container.decode(ExecutionMode.self, forKey: .executionMode)
        try self.init(
            sessionID: sessionID,
            strategy: strategy,
            marketData: marketData,
            riskProfileID: riskProfileID,
            executionMode: executionMode
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(strategy, forKey: .strategy)
        try container.encode(marketData, forKey: .marketData)
        try container.encode(riskProfileID, forKey: .riskProfileID)
        try container.encode(executionMode, forKey: .executionMode)
    }

    private enum CodingKeys: String, CodingKey {
        case sessionID
        case strategy
        case marketData
        case riskProfileID
        case executionMode
    }
}

public struct BacktestResult: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let command: BacktestCommand
    public let signalSamples: [EMACrossSignalSample]
    public let completedAt: Date

    public init(
        runID: Identifier,
        command: BacktestCommand,
        signalSamples: [EMACrossSignalSample],
        completedAt: Date
    ) {
        self.runID = runID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public struct PaperSessionResult: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let command: PaperSessionCommand
    public let signalSamples: [EMACrossSignalSample]
    public let completedAt: Date

    public init(
        sessionID: Identifier,
        command: PaperSessionCommand,
        signalSamples: [EMACrossSignalSample],
        completedAt: Date
    ) {
        self.sessionID = sessionID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public struct BacktestRun: Codable, Equatable, Sendable {
    public let result: BacktestResult
    public let events: [BacktestEvent]

    public init(result: BacktestResult, events: [BacktestEvent]) {
        self.result = result
        self.events = events
    }
}

public struct PaperSessionRun: Codable, Equatable, Sendable {
    public let result: PaperSessionResult
    public let events: [PaperEvent]

    public init(result: PaperSessionResult, events: [PaperEvent]) {
        self.result = result
        self.events = events
    }
}

public struct OrderBookImbalanceResearchRun: Codable, Equatable, Sendable {
    public let result: OrderBookImbalanceResearchResult
    public let events: [OrderBookImbalanceResearchEvent]

    public init(
        result: OrderBookImbalanceResearchResult,
        events: [OrderBookImbalanceResearchEvent]
    ) {
        self.result = result
        self.events = events
    }
}

/// 回测事件流只基于本地 market bars 生成策略信号和完成事件。
public struct BacktestEventFlow: Equatable, Sendable {
    public init() {}

    public func run(
        _ command: BacktestCommand,
        bars: [MarketBar],
        completedAt: Date = Date()
    ) throws -> BacktestRun {
        try StrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try EMACrossStrategyContract(
            configuration: command.strategy
        ).evaluate(bars)
        let result = BacktestResult(
            runID: command.runID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.requested(command)]
            + signalSamples.map(BacktestEvent.signalGenerated)
            + [.completed(result)]

        return BacktestRun(result: result, events: events)
    }
}

/// Paper 会话事件流复用 EMA 契约，只模拟本地信号，不提交真实订单。
public struct PaperSessionEventFlow: Equatable, Sendable {
    public init() {}

    public func start(
        _ command: PaperSessionCommand,
        bars: [MarketBar],
        completedAt: Date = Date()
    ) throws -> PaperSessionRun {
        try StrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try EMACrossStrategyContract(
            configuration: command.strategy
        ).evaluate(bars)
        let result = PaperSessionResult(
            sessionID: command.sessionID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.sessionRequested(command)]
            + signalSamples.map(PaperEvent.signalGenerated)
            + [.sessionCompleted(result)]

        return PaperSessionRun(result: result, events: events)
    }
}

/// 订单簿失衡研究链路只生成本地研究事件，不创建订单或 broker action。
public struct OrderBookImbalanceResearchEventFlow: Equatable, Sendable {
    public init() {}

    public func run(
        _ command: OrderBookImbalanceResearchCommand,
        inputs: [OrderBookReadModelInput],
        completedAt: Date = Date()
    ) throws -> OrderBookImbalanceResearchRun {
        try StrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try OrderBookImbalanceStrategyContract(
            configuration: command.strategy
        ).evaluate(inputs)
        let result = OrderBookImbalanceResearchResult(
            researchID: command.researchID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.requested(command)]
            + signalSamples.map(OrderBookImbalanceResearchEvent.signalGenerated)
            + [.completed(result)]

        return OrderBookImbalanceResearchRun(result: result, events: events)
    }
}

public struct BacktestPaperParityResult: Codable, Equatable, Sendable {
    public let backtestRunID: Identifier
    public let paperSessionID: Identifier
    public let sameStrategy: Bool
    public let sameMarketData: Bool
    public let matchingSignalTimeline: Bool

    public init(
        backtestRunID: Identifier,
        paperSessionID: Identifier,
        sameStrategy: Bool,
        sameMarketData: Bool,
        matchingSignalTimeline: Bool
    ) {
        self.backtestRunID = backtestRunID
        self.paperSessionID = paperSessionID
        self.sameStrategy = sameStrategy
        self.sameMarketData = sameMarketData
        self.matchingSignalTimeline = matchingSignalTimeline
    }

    public var isConsistent: Bool {
        sameStrategy && sameMarketData && matchingSignalTimeline
    }
}

public enum BacktestPaperParity {
    public static func verify(
        backtest: BacktestResult,
        paper: PaperSessionResult
    ) -> BacktestPaperParityResult {
        BacktestPaperParityResult(
            backtestRunID: backtest.runID,
            paperSessionID: paper.sessionID,
            sameStrategy: backtest.command.strategy == paper.command.strategy,
            sameMarketData: backtest.command.marketData == paper.command.marketData,
            matchingSignalTimeline: backtest.signalSamples == paper.signalSamples
        )
    }
}

private enum StrategyMarketDataValidation {
    static func validate(
        strategy: EMACrossStrategyConfiguration,
        marketData: MarketDataQuery
    ) throws {
        guard strategy.symbol == marketData.symbol else {
            throw CoreError.marketDataMismatch(
                field: "marketData.symbol",
                expected: strategy.symbol.rawValue,
                actual: marketData.symbol.rawValue
            )
        }
        guard strategy.timeframe == marketData.timeframe else {
            throw CoreError.marketDataMismatch(
                field: "marketData.timeframe",
                expected: strategy.timeframe.rawValue,
                actual: marketData.timeframe.rawValue
            )
        }
    }

    static func validate(
        strategy: OrderBookImbalanceStrategyConfiguration,
        marketData: MarketDataQuery
    ) throws {
        guard strategy.symbol == marketData.symbol else {
            throw CoreError.marketDataMismatch(
                field: "marketData.symbol",
                expected: strategy.symbol.rawValue,
                actual: marketData.symbol.rawValue
            )
        }
        guard strategy.timeframe == marketData.timeframe else {
            throw CoreError.marketDataMismatch(
                field: "marketData.timeframe",
                expected: strategy.timeframe.rawValue,
                actual: marketData.timeframe.rawValue
            )
        }
    }
}

public struct RiskEvaluationQuery: Codable, Equatable, Sendable {
    public let paperOrderID: Identifier
    public let symbol: Symbol
    public let proposedQuantity: Double

    public init(paperOrderID: Identifier, symbol: Symbol, proposedQuantity: Double) {
        self.paperOrderID = paperOrderID
        self.symbol = symbol
        self.proposedQuantity = proposedQuantity
    }
}

public struct PortfolioQuery: Codable, Equatable, Sendable {
    public let portfolioID: Identifier
    public let asOf: Date

    public init(portfolioID: Identifier, asOf: Date) {
        self.portfolioID = portfolioID
        self.asOf = asOf
    }
}

public enum Command: Codable, Equatable, Sendable {
    case runBacktest(BacktestCommand)
    case startPaperSession(PaperSessionCommand)
    case runOrderBookImbalanceResearch(OrderBookImbalanceResearchCommand)
    case replayEvents(EventReplayCommand)
}

public enum Query: Codable, Equatable, Sendable {
    case marketData(MarketDataQuery)
    case riskEvaluation(RiskEvaluationQuery)
    case portfolio(PortfolioQuery)
}

public struct EventStreamID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let market = EventStreamID(rawValue: "market")
    public static let strategy = EventStreamID(rawValue: "strategy")
    public static let backtest = EventStreamID(rawValue: "backtest")
    public static let paper = EventStreamID(rawValue: "paper")
    public static let risk = EventStreamID(rawValue: "risk")
    public static let portfolio = EventStreamID(rawValue: "portfolio")
    public static let replay = EventStreamID(rawValue: "replay")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
}

public struct EventEnvelope: Codable, Equatable, Sendable {
    public let id: UUID
    public let sequence: Int
    public let stream: EventStreamID
    public let recordedAt: Date
    public let correlationID: UUID?
    public let causationID: UUID?
    public let event: DomainEvent

    public init(
        id: UUID = UUID(),
        sequence: Int,
        stream: EventStreamID,
        recordedAt: Date,
        correlationID: UUID? = nil,
        causationID: UUID? = nil,
        event: DomainEvent
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        self.id = id
        self.sequence = sequence
        self.stream = stream
        self.recordedAt = recordedAt
        self.correlationID = correlationID
        self.causationID = causationID
        self.event = event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let sequence = try container.decode(Int.self, forKey: .sequence)
        let stream = try container.decode(EventStreamID.self, forKey: .stream)
        let recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        let correlationID = try container.decodeIfPresent(UUID.self, forKey: .correlationID)
        let causationID = try container.decodeIfPresent(UUID.self, forKey: .causationID)
        let event = try container.decode(DomainEvent.self, forKey: .event)
        try self.init(
            id: id,
            sequence: sequence,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(stream, forKey: .stream)
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encodeIfPresent(correlationID, forKey: .correlationID)
        try container.encodeIfPresent(causationID, forKey: .causationID)
        try container.encode(event, forKey: .event)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case sequence
        case stream
        case recordedAt
        case correlationID
        case causationID
        case event
    }
}

public struct EventSequenceRange: Codable, Equatable, Sendable {
    public let lowerBound: Int?
    public let upperBound: Int?

    public init(lowerBound: Int? = nil, upperBound: Int? = nil) throws {
        if let lowerBound, lowerBound < 1 {
            throw CoreError.invalidSequenceRange
        }
        if let upperBound, upperBound < 1 {
            throw CoreError.invalidSequenceRange
        }
        if let lowerBound, let upperBound, lowerBound > upperBound {
            throw CoreError.invalidSequenceRange
        }
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lowerBound = try container.decodeIfPresent(Int.self, forKey: .lowerBound)
        let upperBound = try container.decodeIfPresent(Int.self, forKey: .upperBound)
        try self.init(lowerBound: lowerBound, upperBound: upperBound)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lowerBound, forKey: .lowerBound)
        try container.encodeIfPresent(upperBound, forKey: .upperBound)
    }

    public func contains(_ sequence: Int) -> Bool {
        if let lowerBound, sequence < lowerBound {
            return false
        }
        if let upperBound, sequence > upperBound {
            return false
        }
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
    }
}

public struct EventReplayCommand: Codable, Equatable, Sendable {
    public let range: EventSequenceRange
    public let streams: Set<EventStreamID>

    public init(range: EventSequenceRange, streams: Set<EventStreamID> = []) {
        self.range = range
        self.streams = streams
    }
}

public struct EventReplayResult: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let envelopes: [EventEnvelope]

    public init(command: EventReplayCommand, envelopes: [EventEnvelope]) {
        self.command = command
        self.envelopes = envelopes
    }
}

public struct AppendOnlyEventLog: Equatable, Sendable {
    public private(set) var envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) throws {
        let sequences = envelopes.map(\.sequence)
        let expectedSequences = sequences.indices.map { $0 + 1 }
        guard sequences == expectedSequences else {
            throw CoreError.invalidSequenceRange
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func append(
        _ event: DomainEvent,
        stream: EventStreamID,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        let envelope = try EventEnvelope(
            sequence: envelopes.count + 1,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
        envelopes.append(envelope)
        return envelope
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        let matchedEnvelopes = envelopes.filter { envelope in
            command.range.contains(envelope.sequence)
                && (command.streams.isEmpty || command.streams.contains(envelope.stream))
        }
        return EventReplayResult(command: command, envelopes: matchedEnvelopes)
    }
}

/// MessageBus 只负责把领域事件写入只追加事件流并按命令重放。
public struct MessageBus: Equatable, Sendable {
    private var eventLog: AppendOnlyEventLog

    public init(envelopes: [EventEnvelope] = []) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: envelopes)
    }

    public var envelopes: [EventEnvelope] {
        eventLog.envelopes
    }

    @discardableResult
    public mutating func publish(
        _ event: DomainEvent,
        stream: EventStreamID,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        try eventLog.append(
            event,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        eventLog.replay(command)
    }
}

/// Cache series key 使用 symbol + timeframe 区分 kline 序列。
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

/// DataEngine 把只读行情事件同时写入 cache 和 MessageBus。
public struct DataEngine: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func ingest(
        _ event: MarketEvent,
        cache: inout MarketDataCache,
        messageBus: inout MessageBus,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        let envelope = try messageBus.publish(
            .market(event),
            stream: .market,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
        cache.ingest(event)
        return envelope
    }
}

/// TradingKernel actor 是当前 issue 的最小运行时边界，不包含策略、数据库或 Live 执行。
public actor TradingKernel {
    private var messageBus: MessageBus
    private var cache: MarketDataCache
    private let dataEngine: DataEngine

    public init(
        messageBus: MessageBus,
        cache: MarketDataCache = MarketDataCache(),
        dataEngine: DataEngine = DataEngine()
    ) {
        self.messageBus = messageBus
        self.cache = cache
        self.dataEngine = dataEngine
    }

    public init() throws {
        self.messageBus = try MessageBus()
        self.cache = MarketDataCache()
        self.dataEngine = DataEngine()
    }

    @discardableResult
    public func ingestMarketEvent(
        _ event: MarketEvent,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        try dataEngine.ingest(
            event,
            cache: &cache,
            messageBus: &messageBus,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        messageBus.replay(command)
    }

    public func eventStream() -> [EventEnvelope] {
        messageBus.envelopes
    }

    public func cacheSnapshot() -> MarketDataCacheSnapshot {
        cache.snapshot
    }

    @discardableResult
    public func rebuildCache(from command: EventReplayCommand) -> MarketDataCacheSnapshot {
        let replay = messageBus.replay(command)
        return cache.rebuild(from: replay.envelopes)
    }
}

public struct CoreBaseline: Equatable, Sendable {
    public let projectName: String
    public let coreMode: String
    public let executionMode: String
    public let primaryUniverse: [String]
    public let timeframes: [String]

    public init(
        projectName: String = "MTPRO",
        coreMode: String = "Swift-only actor core",
        executionMode: String = "paper-only",
        primaryUniverse: [String] = Symbol.supportedRawValues,
        timeframes: [String] = Timeframe.supportedRawValues
    ) {
        self.projectName = projectName
        self.coreMode = coreMode
        self.executionMode = executionMode
        self.primaryUniverse = primaryUniverse
        self.timeframes = timeframes
    }
}
