import Cache
import DomainModel
import Foundation

/// 研究事件流把 command 转换为本地事件序列，复用策略合同并保持 Backtest / Paper parity。

/// BacktestEventFlow 只基于本地 market bars 生成策略信号和完成事件。
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
        try StrategyMarketDataValidation.validateBars(
            bars,
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
        startedAt: Date = Date(),
        updatedAt: Date? = nil,
        completedAt: Date = Date()
    ) throws -> PaperSessionRun {
        try StrategyMarketDataValidation.validate(
            strategy: command.strategy,
            marketData: command.marketData
        )
        try StrategyMarketDataValidation.validateBars(
            bars,
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
        let lifecycleUpdatedAt = updatedAt
            ?? signalSamples.last?.signal.generatedAt
            ?? startedAt
        let events = [
            .sessionStarted(
                PaperSessionStarted(
                    command: command,
                    startedAt: startedAt
                )
            )
        ]
            + signalSamples.map(PaperEvent.signalGenerated)
            + [
                .sessionUpdated(
                    try PaperSessionUpdated(
                        command: command,
                        signalCount: signalSamples.count,
                        updatedAt: lifecycleUpdatedAt
                    )
                ),
                .sessionClosed(
                    PaperSessionClosed(result: result)
                )
            ]

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

/// BacktestPaperParityResult 保存回测与 Paper 一致性检查结果，用于验证同策略同数据的信号时间线。
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

/// BacktestPaperParity 比较 Backtest 与 Paper 的策略、行情查询和信号时间线，确保语义一致。
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

/// OrderBookImbalanceResearchParityResult 保存订单簿失衡研究链路的一致性与 bias 证据。
///
/// 该结果只比较本地策略 contract 与 research event flow 的输出，确认 snapshot / delta
/// 输入来源、signal timeline 和 ask dominance research-only 语义一致；它不代表 Paper、
/// Live、signed endpoint、margin 或真实 broker action 的执行授权。
public struct OrderBookImbalanceResearchParityResult: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let sameResearchID: Bool
    public let sameStrategy: Bool
    public let sameMarketData: Bool
    public let matchingSignalSamples: Bool
    public let coveredInputSources: [OrderBookReadModelSource]
    public let askDominanceRemainsResearchOnly: Bool

    public init(
        researchID: Identifier,
        sameResearchID: Bool,
        sameStrategy: Bool,
        sameMarketData: Bool,
        matchingSignalSamples: Bool,
        coveredInputSources: [OrderBookReadModelSource],
        askDominanceRemainsResearchOnly: Bool
    ) {
        self.researchID = researchID
        self.sameResearchID = sameResearchID
        self.sameStrategy = sameStrategy
        self.sameMarketData = sameMarketData
        self.matchingSignalSamples = matchingSignalSamples
        self.coveredInputSources = coveredInputSources
        self.askDominanceRemainsResearchOnly = askDominanceRemainsResearchOnly
    }

    public var isConsistent: Bool {
        sameResearchID
            && sameStrategy
            && sameMarketData
            && matchingSignalSamples
            && askDominanceRemainsResearchOnly
    }
}

/// OrderBookImbalanceResearchParity 生成本地研究 parity evidence，不触发任何交易执行。
public enum OrderBookImbalanceResearchParity {
    public static func verify(
        command: OrderBookImbalanceResearchCommand,
        inputs: [OrderBookReadModelInput],
        run: OrderBookImbalanceResearchRun
    ) throws -> OrderBookImbalanceResearchParityResult {
        let directSamples = try OrderBookImbalanceStrategyContract(
            configuration: command.strategy
        ).evaluate(inputs)
        let coveredSources = uniqueInputSources(from: directSamples)
        let askDominanceRemainsResearchOnly = run.result.signalSamples.allSatisfy { sample in
            sample.bias != .askDominant || sample.signal.direction == .flat
        }

        return OrderBookImbalanceResearchParityResult(
            researchID: command.researchID,
            sameResearchID: command.researchID == run.result.researchID,
            sameStrategy: command.strategy == run.result.command.strategy,
            sameMarketData: command.marketData == run.result.command.marketData,
            matchingSignalSamples: directSamples == run.result.signalSamples,
            coveredInputSources: coveredSources,
            askDominanceRemainsResearchOnly: askDominanceRemainsResearchOnly
        )
    }

    private static func uniqueInputSources(
        from samples: [OrderBookImbalanceSignalSample]
    ) -> [OrderBookReadModelSource] {
        samples.reduce(into: []) { partialResult, sample in
            guard partialResult.contains(sample.inputSource) == false else {
                return
            }
            partialResult.append(sample.inputSource)
        }
    }
}

private enum StrategyMarketDataValidation {
    /// Backtest / Paper 的 `MarketDataQuery` 必须完整覆盖本次 EMA 计算使用的 bar 区间。
    /// 这个校验防止同一组实际行情被错误地标记为不同查询窗口下的一致结果；它只检查本地 fixture
    /// 的时间边界，不连接 Binance、broker、signed endpoint，也不产生任何交易动作。
    static func validateBars(
        _ bars: [MarketBar],
        marketData: MarketDataQuery
    ) throws {
        guard
            let firstStart = bars.map(\.interval.start).min(),
            let lastEnd = bars.map(\.interval.end).max()
        else {
            return
        }

        guard firstStart >= marketData.range.start, lastEnd <= marketData.range.end else {
            throw CoreError.marketDataMismatch(
                field: "marketData.range",
                expected: rangeDescription(marketData.range),
                actual: rangeDescription(start: firstStart, end: lastEnd)
            )
        }
    }

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

    private static func rangeDescription(_ range: DateRange) -> String {
        rangeDescription(start: range.start, end: range.end)
    }

    private static func rangeDescription(start: Date, end: Date) -> String {
        "\(timestampDescription(start))...\(timestampDescription(end))"
    }

    private static func timestampDescription(_ date: Date) -> String {
        String(format: "%.0f", date.timeIntervalSince1970)
    }
}
