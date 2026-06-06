import DomainModel
import Foundation
import MessageBus

/// Core command / query 合同描述模块内部用例输入，不提供 HTTP API、signed endpoint 或 live order command。

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
