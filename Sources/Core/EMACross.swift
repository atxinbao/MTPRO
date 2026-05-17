import Foundation

/// EMA 交叉策略只消费本地 kline 序列并生成确定性信号，供回测和 Paper 复用。

/// EMACrossStrategyConfiguration 描述 EMA 交叉研究配置，限定 symbol、timeframe 和 period 不变量。
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

/// EMACrossSignalSample 保存 EMA 信号、close、shortEMA 和 longEMA，供 parity 与 projection 使用。
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
