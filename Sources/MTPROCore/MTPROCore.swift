import Foundation

public enum MTPROCoreError: Error, Equatable, Sendable, CustomStringConvertible {
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

public struct MTPROSymbol: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let supportedRawValues = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"]

    public let rawValue: String

    public init(rawValue: String) throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard Self.supportedRawValues.contains(normalized) else {
            throw MTPROCoreError.unsupportedSymbol(rawValue)
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

public enum MTPROTimeframe: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"

    public static var supportedRawValues: [String] {
        allCases.map(\.rawValue)
    }

    public init(contractValue: String) throws {
        guard let timeframe = Self(rawValue: contractValue) else {
            throw MTPROCoreError.unsupportedTimeframe(contractValue)
        }
        self = timeframe
    }
}

public enum MTPROExecutionMode: String, Codable, CaseIterable, Equatable, Sendable {
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
            throw MTPROCoreError.liveExecutionForbidden(contractValue)
        default:
            throw MTPROCoreError.unsupportedExecutionMode(contractValue)
        }
    }
}

public struct MTPRODateRange: Codable, Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start < end else {
            throw MTPROCoreError.invalidDateRange
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

public struct MTPROIdentifier: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String, field: String = "identifier") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw MTPROCoreError.emptyIdentifier(field)
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

public struct MTPROPrice: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "price") throws {
        guard rawValue.isFinite, rawValue > 0 else {
            throw MTPROCoreError.invalidPrice(field, rawValue)
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

public struct MTPROQuantity: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "quantity") throws {
        guard rawValue.isFinite, rawValue >= 0 else {
            throw MTPROCoreError.invalidQuantity(field, rawValue)
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

public struct MTPROMarketBar: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let interval: MTPRODateRange
    public let open: MTPROPrice
    public let high: MTPROPrice
    public let low: MTPROPrice
    public let close: MTPROPrice
    public let volume: MTPROQuantity

    public init(
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        interval: MTPRODateRange,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) throws {
        self.symbol = symbol
        self.timeframe = timeframe
        self.interval = interval
        self.open = try MTPROPrice(open, field: "open")
        self.high = try MTPROPrice(high, field: "high")
        self.low = try MTPROPrice(low, field: "low")
        self.close = try MTPROPrice(close, field: "close")
        self.volume = try MTPROQuantity(volume, field: "volume")
    }
}

public struct MTPROTradeTick: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let tradedAt: Date
    public let price: MTPROPrice
    public let quantity: MTPROQuantity
    public let makerSide: MTPROBookSide

    public init(
        symbol: MTPROSymbol,
        tradedAt: Date,
        price: Double,
        quantity: Double,
        makerSide: MTPROBookSide
    ) throws {
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.price = try MTPROPrice(price)
        self.quantity = try MTPROQuantity(quantity)
        self.makerSide = makerSide
    }
}

public enum MTPROBookSide: String, Codable, Equatable, Sendable {
    case bid
    case ask
}

public struct MTPROOrderBookLevel: Codable, Equatable, Sendable {
    public let price: MTPROPrice
    public let quantity: MTPROQuantity

    public init(price: Double, quantity: Double) throws {
        self.price = try MTPROPrice(price)
        self.quantity = try MTPROQuantity(quantity)
    }
}

public struct MTPROBestBidAsk: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bid: MTPROOrderBookLevel
    public let ask: MTPROOrderBookLevel

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bid: MTPROOrderBookLevel,
        ask: MTPROOrderBookLevel
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bid = bid
        self.ask = ask
    }
}

public struct MTPROOrderBookSnapshot: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bids: [MTPROOrderBookLevel]
    public let asks: [MTPROOrderBookLevel]

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bids: [MTPROOrderBookLevel],
        asks: [MTPROOrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bids = bids
        self.asks = asks
    }
}

public struct MTPROOrderBookDelta: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bidUpdates: [MTPROOrderBookLevel]
    public let askUpdates: [MTPROOrderBookLevel]

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bidUpdates: [MTPROOrderBookLevel],
        askUpdates: [MTPROOrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bidUpdates = bidUpdates
        self.askUpdates = askUpdates
    }
}

public enum MTPROOrderBookReadModelSource: String, Codable, Equatable, Sendable {
    case snapshot
    case deltaApplied
}

/// 订单簿读模型输入由只读 snapshot / delta 构建，供研究信号使用，不代表可交易状态。
public struct MTPROOrderBookReadModelInput: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bids: [MTPROOrderBookLevel]
    public let asks: [MTPROOrderBookLevel]
    public let source: MTPROOrderBookReadModelSource

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bids: [MTPROOrderBookLevel],
        asks: [MTPROOrderBookLevel],
        source: MTPROOrderBookReadModelSource
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bids = Self.sortedBids(Self.nonZero(levels: bids))
        self.asks = Self.sortedAsks(Self.nonZero(levels: asks))
        self.source = source
    }

    public init(snapshot: MTPROOrderBookSnapshot) {
        self.init(
            symbol: snapshot.symbol,
            observedAt: snapshot.observedAt,
            bids: snapshot.bids,
            asks: snapshot.asks,
            source: .snapshot
        )
    }

    public func applying(_ delta: MTPROOrderBookDelta) throws -> MTPROOrderBookReadModelInput {
        guard delta.symbol == symbol else {
            throw MTPROCoreError.marketDataMismatch(
                field: "orderBookDelta.symbol",
                expected: symbol.rawValue,
                actual: delta.symbol.rawValue
            )
        }

        let bids = Self.applying(delta.bidUpdates, to: bids)
        let asks = Self.applying(delta.askUpdates, to: asks)

        return MTPROOrderBookReadModelInput(
            symbol: symbol,
            observedAt: delta.observedAt,
            bids: bids,
            asks: asks,
            source: .deltaApplied
        )
    }

    private static func applying(
        _ updates: [MTPROOrderBookLevel],
        to levels: [MTPROOrderBookLevel]
    ) -> [MTPROOrderBookLevel] {
        var levelsByPrice: [Double: MTPROOrderBookLevel] = [:]
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

    private static func nonZero(levels: [MTPROOrderBookLevel]) -> [MTPROOrderBookLevel] {
        levels.filter { $0.quantity.rawValue > 0 }
    }

    private static func sortedBids(_ levels: [MTPROOrderBookLevel]) -> [MTPROOrderBookLevel] {
        levels.sorted { left, right in
            left.price.rawValue > right.price.rawValue
        }
    }

    private static func sortedAsks(_ levels: [MTPROOrderBookLevel]) -> [MTPROOrderBookLevel] {
        levels.sorted { left, right in
            left.price.rawValue < right.price.rawValue
        }
    }
}

public enum MTPROMarketEvent: Codable, Equatable, Sendable {
    case bar(MTPROMarketBar)
    case trade(MTPROTradeTick)
    case bestBidAsk(MTPROBestBidAsk)
    case orderBookSnapshot(MTPROOrderBookSnapshot)
    case orderBookDelta(MTPROOrderBookDelta)

    public var symbol: MTPROSymbol {
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

public enum MTPROSignalDirection: String, Codable, Equatable, Sendable {
    case long
    case flat
}

public struct MTPROStrategySignalEvent: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let direction: MTPROSignalDirection
    public let generatedAt: Date

    public init(
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        direction: MTPROSignalDirection,
        generatedAt: Date
    ) {
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.direction = direction
        self.generatedAt = generatedAt
    }
}

public enum MTPROOrderBookImbalanceBias: String, Codable, Equatable, Sendable {
    case bidDominant
    case neutral
    case askDominant
}

/// 订单簿失衡策略配置只描述本地研究信号，不包含 futures、margin 或真实订单动作。
public struct MTPROOrderBookImbalanceStrategyConfiguration: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let depth: Int
    public let signalThreshold: Double

    public init(
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        depth: Int,
        signalThreshold: Double
    ) throws {
        guard depth > 0 else {
            throw MTPROCoreError.invalidOrderBookDepth("depth", depth)
        }
        guard signalThreshold.isFinite, (0...1).contains(signalThreshold) else {
            throw MTPROCoreError.invalidImbalanceThreshold(signalThreshold)
        }
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.depth = depth
        self.signalThreshold = signalThreshold
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(MTPROIdentifier.self, forKey: .strategyID)
        let symbol = try container.decode(MTPROSymbol.self, forKey: .symbol)
        let timeframe = try container.decode(MTPROTimeframe.self, forKey: .timeframe)
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

public struct MTPROOrderBookImbalanceSignalSample: Codable, Equatable, Sendable {
    public let signal: MTPROStrategySignalEvent
    public let sourceObservedAt: Date
    public let depth: Int
    public let bidNotional: Double
    public let askNotional: Double
    public let imbalanceRatio: Double
    public let bias: MTPROOrderBookImbalanceBias

    public init(
        signal: MTPROStrategySignalEvent,
        sourceObservedAt: Date,
        depth: Int,
        bidNotional: Double,
        askNotional: Double,
        imbalanceRatio: Double,
        bias: MTPROOrderBookImbalanceBias
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
public struct MTPROOrderBookImbalanceStrategyContract: Equatable, Sendable {
    public let configuration: MTPROOrderBookImbalanceStrategyConfiguration

    public init(configuration: MTPROOrderBookImbalanceStrategyConfiguration) {
        self.configuration = configuration
    }

    public func evaluate(_ inputs: [MTPROOrderBookReadModelInput]) throws -> [MTPROOrderBookImbalanceSignalSample] {
        let sortedInputs = inputs.sorted { left, right in
            left.observedAt < right.observedAt
        }

        return try sortedInputs.map(sample)
    }

    private func sample(from input: MTPROOrderBookReadModelInput) throws -> MTPROOrderBookImbalanceSignalSample {
        guard input.symbol == configuration.symbol else {
            throw MTPROCoreError.marketDataMismatch(
                field: "orderBook.symbol",
                expected: configuration.symbol.rawValue,
                actual: input.symbol.rawValue
            )
        }

        let bids = Array(input.bids.prefix(configuration.depth))
        let asks = Array(input.asks.prefix(configuration.depth))
        guard bids.count == configuration.depth, asks.count == configuration.depth else {
            throw MTPROCoreError.insufficientOrderBookDepth(
                required: configuration.depth,
                bidLevels: bids.count,
                askLevels: asks.count
            )
        }

        let bidNotional = Self.notional(for: bids)
        let askNotional = Self.notional(for: asks)
        let totalNotional = bidNotional + askNotional
        guard totalNotional > 0 else {
            throw MTPROCoreError.insufficientOrderBookLiquidity
        }

        let ratio = (bidNotional - askNotional) / totalNotional
        let bias = Self.bias(ratio: ratio, threshold: configuration.signalThreshold)
        let direction: MTPROSignalDirection = bias == .bidDominant ? .long : .flat
        let signal = MTPROStrategySignalEvent(
            strategyID: configuration.strategyID,
            symbol: configuration.symbol,
            timeframe: configuration.timeframe,
            direction: direction,
            generatedAt: input.observedAt
        )

        return MTPROOrderBookImbalanceSignalSample(
            signal: signal,
            sourceObservedAt: input.observedAt,
            depth: configuration.depth,
            bidNotional: bidNotional,
            askNotional: askNotional,
            imbalanceRatio: ratio,
            bias: bias
        )
    }

    private static func notional(for levels: [MTPROOrderBookLevel]) -> Double {
        levels.reduce(0) { partialResult, level in
            partialResult + (level.price.rawValue * level.quantity.rawValue)
        }
    }

    private static func bias(ratio: Double, threshold: Double) -> MTPROOrderBookImbalanceBias {
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
public struct MTPROEMACrossStrategyConfiguration: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let shortPeriod: Int
    public let longPeriod: Int

    public init(
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        shortPeriod: Int,
        longPeriod: Int
    ) throws {
        guard shortPeriod > 0 else {
            throw MTPROCoreError.invalidEMAPeriod("shortPeriod", shortPeriod)
        }
        guard longPeriod > 0 else {
            throw MTPROCoreError.invalidEMAPeriod("longPeriod", longPeriod)
        }
        guard shortPeriod < longPeriod else {
            throw MTPROCoreError.invalidEMAPeriodOrder(shortPeriod: shortPeriod, longPeriod: longPeriod)
        }
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.shortPeriod = shortPeriod
        self.longPeriod = longPeriod
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(MTPROIdentifier.self, forKey: .strategyID)
        let symbol = try container.decode(MTPROSymbol.self, forKey: .symbol)
        let timeframe = try container.decode(MTPROTimeframe.self, forKey: .timeframe)
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

public struct MTPROEMACrossSignalSample: Codable, Equatable, Sendable {
    public let signal: MTPROStrategySignalEvent
    public let close: MTPROPrice
    public let shortEMA: MTPROPrice
    public let longEMA: MTPROPrice

    public init(
        signal: MTPROStrategySignalEvent,
        close: Double,
        shortEMA: Double,
        longEMA: Double
    ) throws {
        self.signal = signal
        self.close = try MTPROPrice(close, field: "ema.close")
        self.shortEMA = try MTPROPrice(shortEMA, field: "ema.short")
        self.longEMA = try MTPROPrice(longEMA, field: "ema.long")
    }
}

/// EMA 计算保持确定性；回测与 Paper 复用同一契约来避免语义分叉。
public struct MTPROEMACrossStrategyContract: Equatable, Sendable {
    public let configuration: MTPROEMACrossStrategyConfiguration

    public init(configuration: MTPROEMACrossStrategyConfiguration) {
        self.configuration = configuration
    }

    public func evaluate(_ bars: [MTPROMarketBar]) throws -> [MTPROEMACrossSignalSample] {
        guard bars.count >= configuration.longPeriod else {
            throw MTPROCoreError.insufficientMarketData(
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
        var samples: [MTPROEMACrossSignalSample] = []

        for (index, bar) in sortedBars.enumerated() {
            let close = bar.close.rawValue
            shortEMA = Self.nextEMA(close: close, previous: shortEMA, multiplier: shortMultiplier)
            longEMA = Self.nextEMA(close: close, previous: longEMA, multiplier: longMultiplier)

            guard index + 1 >= configuration.longPeriod, let shortEMA, let longEMA else {
                continue
            }

            let direction: MTPROSignalDirection = shortEMA > longEMA ? .long : .flat
            let signal = MTPROStrategySignalEvent(
                strategyID: configuration.strategyID,
                symbol: configuration.symbol,
                timeframe: configuration.timeframe,
                direction: direction,
                generatedAt: bar.interval.end
            )
            let sample = try MTPROEMACrossSignalSample(
                signal: signal,
                close: close,
                shortEMA: shortEMA,
                longEMA: longEMA
            )
            samples.append(sample)
        }

        return samples
    }

    private func validate(_ bars: [MTPROMarketBar]) throws {
        for bar in bars {
            guard bar.symbol == configuration.symbol else {
                throw MTPROCoreError.marketDataMismatch(
                    field: "symbol",
                    expected: configuration.symbol.rawValue,
                    actual: bar.symbol.rawValue
                )
            }
            guard bar.timeframe == configuration.timeframe else {
                throw MTPROCoreError.marketDataMismatch(
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
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let range: MTPRODateRange

    public init(symbol: MTPROSymbol, timeframe: MTPROTimeframe, range: MTPRODateRange) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
    }
}

public struct MTPROOrderBookImbalanceResearchCommand: Codable, Equatable, Sendable {
    public let researchID: MTPROIdentifier
    public let strategy: MTPROOrderBookImbalanceStrategyConfiguration
    public let marketData: MarketDataQuery

    public init(
        researchID: MTPROIdentifier,
        strategy: MTPROOrderBookImbalanceStrategyConfiguration,
        marketData: MarketDataQuery
    ) {
        self.researchID = researchID
        self.strategy = strategy
        self.marketData = marketData
    }

    public var strategyID: MTPROIdentifier {
        strategy.strategyID
    }
}

public struct MTPROOrderBookImbalanceResearchResult: Codable, Equatable, Sendable {
    public let researchID: MTPROIdentifier
    public let command: MTPROOrderBookImbalanceResearchCommand
    public let signalSamples: [MTPROOrderBookImbalanceSignalSample]
    public let completedAt: Date

    public init(
        researchID: MTPROIdentifier,
        command: MTPROOrderBookImbalanceResearchCommand,
        signalSamples: [MTPROOrderBookImbalanceSignalSample],
        completedAt: Date
    ) {
        self.researchID = researchID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public enum MTPROOrderBookImbalanceResearchEvent: Codable, Equatable, Sendable {
    case requested(MTPROOrderBookImbalanceResearchCommand)
    case signalGenerated(MTPROOrderBookImbalanceSignalSample)
    case completed(MTPROOrderBookImbalanceResearchResult)
}

public enum MTPROBacktestEvent: Codable, Equatable, Sendable {
    case requested(BacktestCommand)
    case signalGenerated(MTPROEMACrossSignalSample)
    case completed(MTPROBacktestResult)
}

public enum MTPROPaperEvent: Codable, Equatable, Sendable {
    case sessionRequested(PaperSessionCommand)
    case signalGenerated(MTPROEMACrossSignalSample)
    case sessionCompleted(MTPROPaperSessionResult)
}

public enum MTPRORiskEvent: Codable, Equatable, Sendable {
    case evaluationRequested(RiskEvaluationQuery)
    case rejected(MTPROIdentifier)
}

public enum MTPROPortfolioEvent: Codable, Equatable, Sendable {
    case projectionRequested(PortfolioQuery)
    case projectionUpdated(MTPROIdentifier)
}

public struct MTPROReplayEvent: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let replayedCount: Int

    public init(command: EventReplayCommand, replayedCount: Int) {
        self.command = command
        self.replayedCount = replayedCount
    }
}

public enum MTPRODomainEvent: Codable, Equatable, Sendable {
    case market(MTPROMarketEvent)
    case strategySignal(MTPROStrategySignalEvent)
    case orderBookImbalanceResearch(MTPROOrderBookImbalanceResearchEvent)
    case backtest(MTPROBacktestEvent)
    case paper(MTPROPaperEvent)
    case risk(MTPRORiskEvent)
    case portfolio(MTPROPortfolioEvent)
    case replay(MTPROReplayEvent)
}

public struct BacktestCommand: Codable, Equatable, Sendable {
    public let runID: MTPROIdentifier
    public let strategy: MTPROEMACrossStrategyConfiguration
    public let marketData: MarketDataQuery

    public init(
        runID: MTPROIdentifier,
        strategy: MTPROEMACrossStrategyConfiguration,
        marketData: MarketDataQuery
    ) {
        self.runID = runID
        self.strategy = strategy
        self.marketData = marketData
    }

    public var strategyID: MTPROIdentifier {
        strategy.strategyID
    }
}

public struct PaperSessionCommand: Codable, Equatable, Sendable {
    public let sessionID: MTPROIdentifier
    public let strategy: MTPROEMACrossStrategyConfiguration
    public let marketData: MarketDataQuery
    public let riskProfileID: MTPROIdentifier
    public let executionMode: MTPROExecutionMode

    public init(
        sessionID: MTPROIdentifier,
        strategy: MTPROEMACrossStrategyConfiguration,
        marketData: MarketDataQuery,
        riskProfileID: MTPROIdentifier,
        executionMode: MTPROExecutionMode
    ) throws {
        guard executionMode == .paper else {
            throw MTPROCoreError.paperSessionRequiresPaperMode
        }
        self.sessionID = sessionID
        self.strategy = strategy
        self.marketData = marketData
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
    }

    public var strategyID: MTPROIdentifier {
        strategy.strategyID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sessionID = try container.decode(MTPROIdentifier.self, forKey: .sessionID)
        let strategy = try container.decode(MTPROEMACrossStrategyConfiguration.self, forKey: .strategy)
        let marketData = try container.decode(MarketDataQuery.self, forKey: .marketData)
        let riskProfileID = try container.decode(MTPROIdentifier.self, forKey: .riskProfileID)
        let executionMode = try container.decode(MTPROExecutionMode.self, forKey: .executionMode)
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

public struct MTPROBacktestResult: Codable, Equatable, Sendable {
    public let runID: MTPROIdentifier
    public let command: BacktestCommand
    public let signalSamples: [MTPROEMACrossSignalSample]
    public let completedAt: Date

    public init(
        runID: MTPROIdentifier,
        command: BacktestCommand,
        signalSamples: [MTPROEMACrossSignalSample],
        completedAt: Date
    ) {
        self.runID = runID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public struct MTPROPaperSessionResult: Codable, Equatable, Sendable {
    public let sessionID: MTPROIdentifier
    public let command: PaperSessionCommand
    public let signalSamples: [MTPROEMACrossSignalSample]
    public let completedAt: Date

    public init(
        sessionID: MTPROIdentifier,
        command: PaperSessionCommand,
        signalSamples: [MTPROEMACrossSignalSample],
        completedAt: Date
    ) {
        self.sessionID = sessionID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

public struct MTPROBacktestRun: Codable, Equatable, Sendable {
    public let result: MTPROBacktestResult
    public let events: [MTPROBacktestEvent]

    public init(result: MTPROBacktestResult, events: [MTPROBacktestEvent]) {
        self.result = result
        self.events = events
    }
}

public struct MTPROPaperSessionRun: Codable, Equatable, Sendable {
    public let result: MTPROPaperSessionResult
    public let events: [MTPROPaperEvent]

    public init(result: MTPROPaperSessionResult, events: [MTPROPaperEvent]) {
        self.result = result
        self.events = events
    }
}

public struct MTPROOrderBookImbalanceResearchRun: Codable, Equatable, Sendable {
    public let result: MTPROOrderBookImbalanceResearchResult
    public let events: [MTPROOrderBookImbalanceResearchEvent]

    public init(
        result: MTPROOrderBookImbalanceResearchResult,
        events: [MTPROOrderBookImbalanceResearchEvent]
    ) {
        self.result = result
        self.events = events
    }
}

/// 回测事件流只基于本地 market bars 生成策略信号和完成事件。
public struct MTPROBacktestEventFlow: Equatable, Sendable {
    public init() {}

    public func run(
        _ command: BacktestCommand,
        bars: [MTPROMarketBar],
        completedAt: Date = Date()
    ) throws -> MTPROBacktestRun {
        try MTPROStrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try MTPROEMACrossStrategyContract(
            configuration: command.strategy
        ).evaluate(bars)
        let result = MTPROBacktestResult(
            runID: command.runID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.requested(command)]
            + signalSamples.map(MTPROBacktestEvent.signalGenerated)
            + [.completed(result)]

        return MTPROBacktestRun(result: result, events: events)
    }
}

/// Paper 会话事件流复用 EMA 契约，只模拟本地信号，不提交真实订单。
public struct MTPROPaperSessionEventFlow: Equatable, Sendable {
    public init() {}

    public func start(
        _ command: PaperSessionCommand,
        bars: [MTPROMarketBar],
        completedAt: Date = Date()
    ) throws -> MTPROPaperSessionRun {
        try MTPROStrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try MTPROEMACrossStrategyContract(
            configuration: command.strategy
        ).evaluate(bars)
        let result = MTPROPaperSessionResult(
            sessionID: command.sessionID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.sessionRequested(command)]
            + signalSamples.map(MTPROPaperEvent.signalGenerated)
            + [.sessionCompleted(result)]

        return MTPROPaperSessionRun(result: result, events: events)
    }
}

/// 订单簿失衡研究链路只生成本地研究事件，不创建订单或 broker action。
public struct MTPROOrderBookImbalanceResearchEventFlow: Equatable, Sendable {
    public init() {}

    public func run(
        _ command: MTPROOrderBookImbalanceResearchCommand,
        inputs: [MTPROOrderBookReadModelInput],
        completedAt: Date = Date()
    ) throws -> MTPROOrderBookImbalanceResearchRun {
        try MTPROStrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        let signalSamples = try MTPROOrderBookImbalanceStrategyContract(
            configuration: command.strategy
        ).evaluate(inputs)
        let result = MTPROOrderBookImbalanceResearchResult(
            researchID: command.researchID,
            command: command,
            signalSamples: signalSamples,
            completedAt: completedAt
        )
        let events = [.requested(command)]
            + signalSamples.map(MTPROOrderBookImbalanceResearchEvent.signalGenerated)
            + [.completed(result)]

        return MTPROOrderBookImbalanceResearchRun(result: result, events: events)
    }
}

public struct MTPROBacktestPaperParityResult: Codable, Equatable, Sendable {
    public let backtestRunID: MTPROIdentifier
    public let paperSessionID: MTPROIdentifier
    public let sameStrategy: Bool
    public let sameMarketData: Bool
    public let matchingSignalTimeline: Bool

    public init(
        backtestRunID: MTPROIdentifier,
        paperSessionID: MTPROIdentifier,
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

public enum MTPROBacktestPaperParity {
    public static func verify(
        backtest: MTPROBacktestResult,
        paper: MTPROPaperSessionResult
    ) -> MTPROBacktestPaperParityResult {
        MTPROBacktestPaperParityResult(
            backtestRunID: backtest.runID,
            paperSessionID: paper.sessionID,
            sameStrategy: backtest.command.strategy == paper.command.strategy,
            sameMarketData: backtest.command.marketData == paper.command.marketData,
            matchingSignalTimeline: backtest.signalSamples == paper.signalSamples
        )
    }
}

private enum MTPROStrategyMarketDataValidation {
    static func validate(
        strategy: MTPROEMACrossStrategyConfiguration,
        marketData: MarketDataQuery
    ) throws {
        guard strategy.symbol == marketData.symbol else {
            throw MTPROCoreError.marketDataMismatch(
                field: "marketData.symbol",
                expected: strategy.symbol.rawValue,
                actual: marketData.symbol.rawValue
            )
        }
        guard strategy.timeframe == marketData.timeframe else {
            throw MTPROCoreError.marketDataMismatch(
                field: "marketData.timeframe",
                expected: strategy.timeframe.rawValue,
                actual: marketData.timeframe.rawValue
            )
        }
    }

    static func validate(
        strategy: MTPROOrderBookImbalanceStrategyConfiguration,
        marketData: MarketDataQuery
    ) throws {
        guard strategy.symbol == marketData.symbol else {
            throw MTPROCoreError.marketDataMismatch(
                field: "marketData.symbol",
                expected: strategy.symbol.rawValue,
                actual: marketData.symbol.rawValue
            )
        }
        guard strategy.timeframe == marketData.timeframe else {
            throw MTPROCoreError.marketDataMismatch(
                field: "marketData.timeframe",
                expected: strategy.timeframe.rawValue,
                actual: marketData.timeframe.rawValue
            )
        }
    }
}

public struct RiskEvaluationQuery: Codable, Equatable, Sendable {
    public let paperOrderID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let proposedQuantity: Double

    public init(paperOrderID: MTPROIdentifier, symbol: MTPROSymbol, proposedQuantity: Double) {
        self.paperOrderID = paperOrderID
        self.symbol = symbol
        self.proposedQuantity = proposedQuantity
    }
}

public struct PortfolioQuery: Codable, Equatable, Sendable {
    public let portfolioID: MTPROIdentifier
    public let asOf: Date

    public init(portfolioID: MTPROIdentifier, asOf: Date) {
        self.portfolioID = portfolioID
        self.asOf = asOf
    }
}

public enum MTPROCommand: Codable, Equatable, Sendable {
    case runBacktest(BacktestCommand)
    case startPaperSession(PaperSessionCommand)
    case runOrderBookImbalanceResearch(MTPROOrderBookImbalanceResearchCommand)
    case replayEvents(EventReplayCommand)
}

public enum MTPROQuery: Codable, Equatable, Sendable {
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
    public let event: MTPRODomainEvent

    public init(
        id: UUID = UUID(),
        sequence: Int,
        stream: EventStreamID,
        recordedAt: Date,
        correlationID: UUID? = nil,
        causationID: UUID? = nil,
        event: MTPRODomainEvent
    ) throws {
        guard sequence > 0 else {
            throw MTPROCoreError.invalidEventSequence(sequence)
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
        let event = try container.decode(MTPRODomainEvent.self, forKey: .event)
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
            throw MTPROCoreError.invalidSequenceRange
        }
        if let upperBound, upperBound < 1 {
            throw MTPROCoreError.invalidSequenceRange
        }
        if let lowerBound, let upperBound, lowerBound > upperBound {
            throw MTPROCoreError.invalidSequenceRange
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
            throw MTPROCoreError.invalidSequenceRange
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func append(
        _ event: MTPRODomainEvent,
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
public struct MTPROMessageBus: Equatable, Sendable {
    private var eventLog: AppendOnlyEventLog

    public init(envelopes: [EventEnvelope] = []) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: envelopes)
    }

    public var envelopes: [EventEnvelope] {
        eventLog.envelopes
    }

    @discardableResult
    public mutating func publish(
        _ event: MTPRODomainEvent,
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
public struct MTPROMarketDataSeriesKey: Equatable, Hashable, Sendable {
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe

    public init(symbol: MTPROSymbol, timeframe: MTPROTimeframe) {
        self.symbol = symbol
        self.timeframe = timeframe
    }
}

/// Market data cache snapshot 是 read-only market event 的确定性投影结果。
public struct MTPROMarketDataCacheSnapshot: Equatable, Sendable {
    public let barsBySeries: [MTPROMarketDataSeriesKey: [MTPROMarketBar]]
    public let tradesBySymbol: [MTPROSymbol: [MTPROTradeTick]]
    public let bestBidAskBySymbol: [MTPROSymbol: MTPROBestBidAsk]
    public let orderBookSnapshotsBySymbol: [MTPROSymbol: MTPROOrderBookSnapshot]
    public let orderBookDeltasBySymbol: [MTPROSymbol: [MTPROOrderBookDelta]]

    public init(
        barsBySeries: [MTPROMarketDataSeriesKey: [MTPROMarketBar]] = [:],
        tradesBySymbol: [MTPROSymbol: [MTPROTradeTick]] = [:],
        bestBidAskBySymbol: [MTPROSymbol: MTPROBestBidAsk] = [:],
        orderBookSnapshotsBySymbol: [MTPROSymbol: MTPROOrderBookSnapshot] = [:],
        orderBookDeltasBySymbol: [MTPROSymbol: [MTPROOrderBookDelta]] = [:]
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

    public func applying(_ event: MTPROMarketEvent) -> MTPROMarketDataCacheSnapshot {
        var barsBySeries = barsBySeries
        var tradesBySymbol = tradesBySymbol
        var bestBidAskBySymbol = bestBidAskBySymbol
        var orderBookSnapshotsBySymbol = orderBookSnapshotsBySymbol
        var orderBookDeltasBySymbol = orderBookDeltasBySymbol

        switch event {
        case let .bar(bar):
            let key = MTPROMarketDataSeriesKey(symbol: bar.symbol, timeframe: bar.timeframe)
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

        return MTPROMarketDataCacheSnapshot(
            barsBySeries: barsBySeries,
            tradesBySymbol: tradesBySymbol,
            bestBidAskBySymbol: bestBidAskBySymbol,
            orderBookSnapshotsBySymbol: orderBookSnapshotsBySymbol,
            orderBookDeltasBySymbol: orderBookDeltasBySymbol
        )
    }
}

/// Cache 只接收 MTPROCore market event，不读取网络或数据库。
public struct MTPROMarketDataCache: Equatable, Sendable {
    public private(set) var snapshot: MTPROMarketDataCacheSnapshot

    public init(snapshot: MTPROMarketDataCacheSnapshot = MTPROMarketDataCacheSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func ingest(_ event: MTPROMarketEvent) -> MTPROMarketDataCacheSnapshot {
        snapshot = snapshot.applying(event)
        return snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> MTPROMarketDataCacheSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> MTPROMarketDataCacheSnapshot {
        envelopes.reduce(MTPROMarketDataCacheSnapshot()) { snapshot, envelope in
            guard case let .market(event) = envelope.event else {
                return snapshot
            }
            return snapshot.applying(event)
        }
    }
}

/// DataEngine 把只读行情事件同时写入 cache 和 MessageBus。
public struct MTPRODataEngine: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func ingest(
        _ event: MTPROMarketEvent,
        cache: inout MTPROMarketDataCache,
        messageBus: inout MTPROMessageBus,
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
public actor MTPROTradingKernel {
    private var messageBus: MTPROMessageBus
    private var cache: MTPROMarketDataCache
    private let dataEngine: MTPRODataEngine

    public init(
        messageBus: MTPROMessageBus,
        cache: MTPROMarketDataCache = MTPROMarketDataCache(),
        dataEngine: MTPRODataEngine = MTPRODataEngine()
    ) {
        self.messageBus = messageBus
        self.cache = cache
        self.dataEngine = dataEngine
    }

    public init() throws {
        self.messageBus = try MTPROMessageBus()
        self.cache = MTPROMarketDataCache()
        self.dataEngine = MTPRODataEngine()
    }

    @discardableResult
    public func ingestMarketEvent(
        _ event: MTPROMarketEvent,
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

    public func cacheSnapshot() -> MTPROMarketDataCacheSnapshot {
        cache.snapshot
    }

    @discardableResult
    public func rebuildCache(from command: EventReplayCommand) -> MTPROMarketDataCacheSnapshot {
        let replay = messageBus.replay(command)
        return cache.rebuild(from: replay.envelopes)
    }
}

public struct MTPROCoreBaseline: Equatable, Sendable {
    public let projectName: String
    public let coreMode: String
    public let executionMode: String
    public let primaryUniverse: [String]
    public let timeframes: [String]

    public init(
        projectName: String = "MTPRO",
        coreMode: String = "Swift-only actor core",
        executionMode: String = "paper-only",
        primaryUniverse: [String] = MTPROSymbol.supportedRawValues,
        timeframes: [String] = MTPROTimeframe.supportedRawValues
    ) {
        self.projectName = projectName
        self.coreMode = coreMode
        self.executionMode = executionMode
        self.primaryUniverse = primaryUniverse
        self.timeframes = timeframes
    }
}
