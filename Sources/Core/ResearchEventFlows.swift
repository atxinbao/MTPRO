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
