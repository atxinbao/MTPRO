import Foundation

/// Core command / query 合同描述模块内部用例输入，不提供 HTTP API、signed endpoint 或 live order command。

/// MarketDataQuery 描述只读行情查询范围，是策略研究、回测和 Paper command 的共同输入。
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

/// OrderBookImbalanceResearchCommand 请求本地订单簿失衡研究，不代表可交易命令。
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

/// BacktestCommand 请求本地回测运行，输入必须与 EMA 策略配置一致。
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

/// PaperSessionCommand 请求本地 Paper 会话，只允许 paper executionMode，禁止 live 执行。
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

/// RiskEvaluationQuery 描述 Paper 风险观察输入，不连接真实 broker 或账户。
///
/// 输入只允许 `.paper` execution mode，并保留 symbol / timeframe、proposed quantity
/// 和 risk profile，让后续 risk blocker evidence 能证明阻断来自本地 Paper 语境。
public struct RiskEvaluationQuery: Codable, Equatable, Sendable {
    public let paperOrderID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let proposedQuantity: Quantity
    public let riskProfileID: Identifier
    public let executionMode: ExecutionMode

    public init(
        paperOrderID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        proposedQuantity: Quantity,
        riskProfileID: Identifier,
        executionMode: ExecutionMode
    ) throws {
        guard executionMode == .paper else {
            throw CoreError.riskEvaluationRequiresPaperMode(executionMode)
        }
        self.paperOrderID = paperOrderID
        self.symbol = symbol
        self.timeframe = timeframe
        self.proposedQuantity = proposedQuantity
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paperOrderID = try container.decode(Identifier.self, forKey: .paperOrderID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let proposedQuantity = try container.decode(Quantity.self, forKey: .proposedQuantity)
        let riskProfileID = try container.decode(Identifier.self, forKey: .riskProfileID)
        let executionMode = try container.decode(ExecutionMode.self, forKey: .executionMode)
        try self.init(
            paperOrderID: paperOrderID,
            symbol: symbol,
            timeframe: timeframe,
            proposedQuantity: proposedQuantity,
            riskProfileID: riskProfileID,
            executionMode: executionMode
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paperOrderID, forKey: .paperOrderID)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(proposedQuantity, forKey: .proposedQuantity)
        try container.encode(riskProfileID, forKey: .riskProfileID)
        try container.encode(executionMode, forKey: .executionMode)
    }

    private enum CodingKeys: String, CodingKey {
        case paperOrderID
        case symbol
        case timeframe
        case proposedQuantity
        case riskProfileID
        case executionMode
    }
}

/// PortfolioQuery 描述本地组合投影查询输入，不读取真实账户资产。
public struct PortfolioQuery: Codable, Equatable, Sendable {
    public let portfolioID: Identifier
    public let asOf: Date

    public init(portfolioID: Identifier, asOf: Date) {
        self.portfolioID = portfolioID
        self.asOf = asOf
    }
}

/// Command 聚合 Core 内部 use case 命令，不包含 live order、account 或 signed endpoint command。
public enum Command: Codable, Equatable, Sendable {
    case runBacktest(BacktestCommand)
    case startPaperSession(PaperSessionCommand)
    case controlPaperSession(PaperSessionLocalControlCommand)
    case runOrderBookImbalanceResearch(OrderBookImbalanceResearchCommand)
    case replayEvents(EventReplayCommand)
}

/// Query 聚合 Core 内部查询入口，只返回稳定合同输入而非 runtime object。
public enum Query: Codable, Equatable, Sendable {
    case marketData(MarketDataQuery)
    case riskEvaluation(RiskEvaluationQuery)
    case portfolio(PortfolioQuery)
}
