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
    public let perpetualShortEnabled: Bool

    public init(
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        period: Int,
        oversoldThreshold: Double = 30,
        overboughtThreshold: Double = 70,
        perpetualShortEnabled: Bool = false
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
        self.perpetualShortEnabled = perpetualShortEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(Identifier.self, forKey: .strategyID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let period = try container.decode(Int.self, forKey: .period)
        let oversoldThreshold = try container.decode(Double.self, forKey: .oversoldThreshold)
        let overboughtThreshold = try container.decode(Double.self, forKey: .overboughtThreshold)
        let perpetualShortEnabled = try container.decodeIfPresent(
            Bool.self,
            forKey: .perpetualShortEnabled
        ) ?? false
        try self.init(
            strategyID: strategyID,
            symbol: symbol,
            timeframe: timeframe,
            period: period,
            oversoldThreshold: oversoldThreshold,
            overboughtThreshold: overboughtThreshold,
            perpetualShortEnabled: perpetualShortEnabled
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
        try container.encode(perpetualShortEnabled, forKey: .perpetualShortEnabled)
    }

    private enum CodingKeys: String, CodingKey {
        case strategyID
        case symbol
        case timeframe
        case period
        case oversoldThreshold
        case overboughtThreshold
        case perpetualShortEnabled
    }
}

/// RSISignalSample 保存本地 RSI value、strategy signal 和 spot-safe target exposure evidence。
///
/// sample 本身不带 instrument，因此 overbought 默认表达 `targetFlat`；只有
/// `RSITargetExposureIntentEmitter` 在 USDⓈ-M Perpetual 且 short gate 显式打开时，才会把
/// overbought 映射为 `targetShort` pre-risk-gate intent。Spot 永远不能从 RSI 输出 targetShort。
public struct RSISignalSample: Codable, Equatable, Sendable {
    public let signal: StrategySignalEvent
    public let targetExposure: TargetExposureIntent
    public let close: Price
    public let rsiValue: Double

    public init(
        signal: StrategySignalEvent,
        targetExposure: TargetExposureIntent,
        close: Double,
        rsiValue: Double
    ) throws {
        guard targetExposure != .targetShort else {
            throw DomainModelContractError.invalidTargetExposureIntent(
                "RSI sample must remain spot-safe; targetShort is product-aware emitter only"
            )
        }
        guard rsiValue.isFinite, rsiValue >= 0, rsiValue <= 100 else {
            throw CoreError.traderAccountContextMismatch(
                field: "rsi.value",
                expected: "0...100",
                actual: "\(rsiValue)"
            )
        }
        self.signal = signal
        self.targetExposure = targetExposure
        self.close = try Price(close, field: "rsi.close")
        self.rsiValue = rsiValue
    }

    /// RSI sample 不输出 direct order side；后续仍必须经 RiskEngine / ExecutionEngine / OMS gate。
    public var emitsDirectOrderSide: Bool {
        false
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
            let targetExposure = Self.spotSafeTargetExposure(
                rsi: rsi,
                oversoldThreshold: configuration.oversoldThreshold,
                overboughtThreshold: configuration.overboughtThreshold
            )
            let direction: SignalDirection = targetExposure == .targetLong ? .long : .flat
            let signal = StrategySignalEvent(
                strategyID: configuration.strategyID,
                symbol: configuration.symbol,
                timeframe: configuration.timeframe,
                direction: direction,
                generatedAt: sortedBars[index].interval.end
            )
            let sample = try RSISignalSample(
                signal: signal,
                targetExposure: targetExposure,
                close: currentClose,
                rsiValue: rsi
            )
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

    private static func spotSafeTargetExposure(
        rsi: Double,
        oversoldThreshold: Double,
        overboughtThreshold: Double
    ) -> TargetExposureIntent {
        if rsi <= oversoldThreshold {
            return .targetLong
        }
        if rsi >= overboughtThreshold {
            return .targetFlat
        }
        return .hold
    }
}

/// RSITargetExposureIntentEmitter 把 RSI sample 转成 RiskEngine 可消费的 strategy intent evidence。
///
/// 该 emitter 只生成 `StrategyIntentMessage` 和可选 `ProductAwareOrderIntent` 作为 pre-risk-gate
/// evidence。它不调用 CommandGateway、RiskEngine、ExecutionEngine、OMS、ExecutionClient、broker，
/// 不读取 secret，也不授权 production trading。Spot overbought 始终只能输出 `targetFlat`；
/// USDⓈ-M Perpetual 只有在 `perpetualShortEnabled == true` 时才允许输出 `targetShort`。
public struct RSITargetExposureIntentEmitter: Equatable, Sendable {
    public let emitterID: Identifier
    public let configuration: RSIStrategyConfiguration

    public init(
        emitterID: Identifier,
        configuration: RSIStrategyConfiguration
    ) {
        self.emitterID = emitterID
        self.configuration = configuration
    }

    public func generateTargetExposureIntent(
        from sample: RSISignalSample,
        instrument: InstrumentIdentity,
        sourceSequence: Int,
        quantity: Quantity,
        emittedAt: Date
    ) throws -> StrategyIntentMessage {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        try validate(sample: sample)
        try validate(instrument: instrument)

        let targetExposure = targetExposure(for: sample, instrument: instrument)
        let productAwareOrderIntent: ProductAwareOrderIntent?
        if targetExposure.requiresOrderIntent {
            productAwareOrderIntent = try ProductAwareOrderIntent(
                intentID: Identifier(
                    "\(emitterID.rawValue)-product-aware-intent-\(sourceSequence)-\(instrument.productType.rawValue)"
                ),
                instrument: instrument,
                targetExposure: targetExposure,
                quantity: quantity,
                referencePrice: sample.close,
                createdAt: emittedAt
            )
        } else {
            productAwareOrderIntent = nil
        }

        return try StrategyIntentMessage(
            messageID: Identifier(
                "\(emitterID.rawValue)-target-exposure-\(sourceSequence)-\(instrument.productType.rawValue)"
            ),
            strategyID: configuration.strategyID,
            instrument: instrument,
            targetExposure: targetExposure,
            productAwareOrderIntent: productAwareOrderIntent,
            emittedAt: emittedAt
        )
    }

    public func generateTargetExposureIntent(
        from bars: [MarketBar],
        instrument: InstrumentIdentity,
        sourceSequence: Int,
        quantity: Quantity,
        emittedAt: Date
    ) throws -> StrategyIntentMessage {
        let samples = try RSIStrategyContract(configuration: configuration).evaluate(bars)
        guard let latestSample = samples.last else {
            throw CoreError.insufficientMarketData(required: configuration.period + 1, actual: bars.count)
        }
        return try generateTargetExposureIntent(
            from: latestSample,
            instrument: instrument,
            sourceSequence: sourceSequence,
            quantity: quantity,
            emittedAt: emittedAt
        )
    }

    /// GH-570 deterministic fixture 只用于本地测试和 release evidence。
    public static func deterministicFixture(perpetualShortEnabled: Bool = false) throws -> Self {
        try Self(
            emitterID: Identifier("gh-570-rsi-target-exposure-emitter"),
            configuration: RSIStrategyConfiguration(
                strategyID: Identifier("gh-570-rsi-instance"),
                symbol: Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                period: 3,
                perpetualShortEnabled: perpetualShortEnabled
            )
        )
    }

    private func targetExposure(
        for sample: RSISignalSample,
        instrument: InstrumentIdentity
    ) -> TargetExposureIntent {
        if sample.rsiValue <= configuration.oversoldThreshold {
            return .targetLong
        }
        if sample.rsiValue >= configuration.overboughtThreshold {
            if instrument.productType == .usdsPerpetual && configuration.perpetualShortEnabled {
                return .targetShort
            }
            return .targetFlat
        }
        return .hold
    }

    private func validate(sample: RSISignalSample) throws {
        guard sample.signal.strategyID == configuration.strategyID else {
            throw CoreError.traderAccountContextMismatch(
                field: "rsiTargetExposureEmitter.strategyID",
                expected: configuration.strategyID.rawValue,
                actual: sample.signal.strategyID.rawValue
            )
        }
        guard sample.signal.symbol == configuration.symbol else {
            throw CoreError.marketDataMismatch(
                field: "rsiTargetExposureEmitter.symbol",
                expected: configuration.symbol.rawValue,
                actual: sample.signal.symbol.rawValue
            )
        }
        guard sample.signal.timeframe == configuration.timeframe else {
            throw CoreError.marketDataMismatch(
                field: "rsiTargetExposureEmitter.timeframe",
                expected: configuration.timeframe.rawValue,
                actual: sample.signal.timeframe.rawValue
            )
        }
        guard sample.emitsDirectOrderSide == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "rsiTargetExposureEmitter.directOrderSide"
            )
        }
    }

    private func validate(instrument: InstrumentIdentity) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "rsiTargetExposureEmitter.nonBinanceInstrument"
            )
        }
        guard instrument.symbol == configuration.symbol else {
            throw CoreError.marketDataMismatch(
                field: "rsiTargetExposureEmitter.instrument.symbol",
                expected: configuration.symbol.rawValue,
                actual: instrument.symbol.rawValue
            )
        }
    }
}
