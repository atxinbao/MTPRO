import Foundation

/// MTP-201 将 order-book imbalance evidence 从 `Sources/Trader/Strategies/OrderBookImbalance/`
/// 退休到 `Sources/Core/Research/`。
///
/// 这里保留的类型只服务历史 research / parity / persistence evidence，不再属于当前 active concrete
/// strategy source layout。当前 active concrete strategy 只有 EMA；订单簿失衡研究只消费本地订单簿
/// 读模型并输出研究样本，禁止 futures、margin 和真实交易能力。

/// OrderBookImbalanceBias 表达订单簿失衡倾向，ask dominance 只作为研究偏向而非做空授权。
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

/// OrderBookImbalanceSignalSample 保存失衡研究的信号和可投影指标。
///
/// 样本显式携带 `inputSource`，让验证证据能追溯信号来自原始 snapshot
/// 还是 delta 应用后的本地读模型。该样本只用于研究和投影，不授权真实订单、
/// signed endpoint、futures margin 或 broker action。
public struct OrderBookImbalanceSignalSample: Codable, Equatable, Sendable {
    public let signal: StrategySignalEvent
    public let sourceObservedAt: Date
    public let depth: Int
    public let inputSource: OrderBookReadModelSource
    public let bidNotional: Double
    public let askNotional: Double
    public let imbalanceRatio: Double
    public let bias: OrderBookImbalanceBias

    public init(
        signal: StrategySignalEvent,
        sourceObservedAt: Date,
        depth: Int,
        inputSource: OrderBookReadModelSource,
        bidNotional: Double,
        askNotional: Double,
        imbalanceRatio: Double,
        bias: OrderBookImbalanceBias
    ) {
        self.signal = signal
        self.sourceObservedAt = sourceObservedAt
        self.depth = depth
        self.inputSource = inputSource
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
            inputSource: input.source,
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
