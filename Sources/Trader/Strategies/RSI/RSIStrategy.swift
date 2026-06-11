import DomainModel
import Foundation
import MessageBus

/// GH-568 在 Trader-owned strategy root 下新增 RSI active source。
///
/// 该文件只定义 RSI 研究信号 contract，证明 RSI 能作为 `TraderStrategies` target 的 active
/// source 编译。它不创建 strategy runtime、不生成 order intent、不调用 RiskEngine / ExecutionEngine /
/// ExecutionClient / broker，也不授权 production trading。
/// `GH-568-RSI-ACTIVE-SOURCE-COMPILES`
/// `TVM-RELEASE-V020-TRADERSTRATEGIES-EMA-RSI-ROOT`
public struct RSIStrategyConfiguration: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let period: Int
    public let oversoldThreshold: Double
    public let overboughtThreshold: Double

    public init(
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        period: Int,
        oversoldThreshold: Double = 30,
        overboughtThreshold: Double = 70
    ) throws {
        guard period > 1 else {
            throw CoreError.traderAccountContextMismatch(
                field: "rsi.period",
                expected: ">1",
                actual: "\(period)"
            )
        }
        guard oversoldThreshold.isFinite,
              overboughtThreshold.isFinite,
              oversoldThreshold > 0,
              overboughtThreshold < 100,
              oversoldThreshold < overboughtThreshold else {
            throw CoreError.traderAccountContextMismatch(
                field: "rsi.thresholds",
                expected: "0 < oversold < overbought < 100",
                actual: "\(oversoldThreshold),\(overboughtThreshold)"
            )
        }
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.period = period
        self.oversoldThreshold = oversoldThreshold
        self.overboughtThreshold = overboughtThreshold
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(Identifier.self, forKey: .strategyID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let period = try container.decode(Int.self, forKey: .period)
        let oversoldThreshold = try container.decode(Double.self, forKey: .oversoldThreshold)
        let overboughtThreshold = try container.decode(Double.self, forKey: .overboughtThreshold)
        try self.init(
            strategyID: strategyID,
            symbol: symbol,
            timeframe: timeframe,
            period: period,
            oversoldThreshold: oversoldThreshold,
            overboughtThreshold: overboughtThreshold
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(strategyID, forKey: .strategyID)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(period, forKey: .period)
        try container.encode(oversoldThreshold, forKey: .oversoldThreshold)
        try container.encode(overboughtThreshold, forKey: .overboughtThreshold)
    }

    private enum CodingKeys: String, CodingKey {
        case strategyID
        case symbol
        case timeframe
        case period
        case oversoldThreshold
        case overboughtThreshold
    }
}

/// RSISignalSample 只保存本地 RSI value 和 strategy signal，不代表订单或 broker action。
public struct RSISignalSample: Codable, Equatable, Sendable {
    public let signal: StrategySignalEvent
    public let close: Price
    public let rsiValue: Double

    public init(
        signal: StrategySignalEvent,
        close: Double,
        rsiValue: Double
    ) throws {
        guard rsiValue.isFinite, rsiValue >= 0, rsiValue <= 100 else {
            throw CoreError.traderAccountContextMismatch(
                field: "rsi.value",
                expected: "0...100",
                actual: "\(rsiValue)"
            )
        }
        self.signal = signal
        self.close = try Price(close, field: "rsi.close")
        self.rsiValue = rsiValue
    }
}

/// RSIStrategyContract 使用本地 close 序列计算 deterministic RSI evidence。
///
/// 当前 `SignalDirection` 仍只有 long / flat，因此 RSI overbought 只归为 flat，不表达 short、
/// margin、leverage 或任何可执行交易命令。
public struct RSIStrategyContract: Equatable, Sendable {
    public let configuration: RSIStrategyConfiguration

    public init(configuration: RSIStrategyConfiguration) {
        self.configuration = configuration
    }

    public func evaluate(_ bars: [MarketBar]) throws -> [RSISignalSample] {
        let requiredBars = configuration.period + 1
        guard bars.count >= requiredBars else {
            throw CoreError.insufficientMarketData(required: requiredBars, actual: bars.count)
        }

        let sortedBars = bars.sorted { left, right in
            left.interval.start < right.interval.start
        }
        try validate(sortedBars)

        var gains: [Double] = []
        var losses: [Double] = []
        var samples: [RSISignalSample] = []

        for index in 1..<sortedBars.count {
            let previousClose = sortedBars[index - 1].close.rawValue
            let currentClose = sortedBars[index].close.rawValue
            let delta = currentClose - previousClose
            gains.append(max(delta, 0))
            losses.append(max(-delta, 0))

            guard gains.count >= configuration.period else {
                continue
            }

            let recentGains = gains.suffix(configuration.period)
            let recentLosses = losses.suffix(configuration.period)
            let averageGain = recentGains.reduce(0, +) / Double(configuration.period)
            let averageLoss = recentLosses.reduce(0, +) / Double(configuration.period)
            let rsi = Self.rsi(averageGain: averageGain, averageLoss: averageLoss)
            let direction: SignalDirection = rsi <= configuration.oversoldThreshold ? .long : .flat
            let signal = StrategySignalEvent(
                strategyID: configuration.strategyID,
                symbol: configuration.symbol,
                timeframe: configuration.timeframe,
                direction: direction,
                generatedAt: sortedBars[index].interval.end
            )
            let sample = try RSISignalSample(signal: signal, close: currentClose, rsiValue: rsi)
            samples.append(sample)
        }

        return samples
    }

    private func validate(_ bars: [MarketBar]) throws {
        for bar in bars {
            guard bar.symbol == configuration.symbol else {
                throw CoreError.marketDataMismatch(
                    field: "rsi.symbol",
                    expected: configuration.symbol.rawValue,
                    actual: bar.symbol.rawValue
                )
            }
            guard bar.timeframe == configuration.timeframe else {
                throw CoreError.marketDataMismatch(
                    field: "rsi.timeframe",
                    expected: configuration.timeframe.rawValue,
                    actual: bar.timeframe.rawValue
                )
            }
        }
    }

    private static func rsi(averageGain: Double, averageLoss: Double) -> Double {
        guard averageLoss > 0 else {
            return 100
        }
        let relativeStrength = averageGain / averageLoss
        return 100 - (100 / (1 + relativeStrength))
    }
}
