import DomainModel
import Foundation

/// MTP-193 将 strategy signal shared language 迁入 `Sources/Trader/Strategies/EMA/`。
/// 该信号仍只是 read-model / proposal input，不是 Trader 指令、ExecutionClient request 或 broker command。
/// 策略信号模型只表达本地研究方向和生成时间，不代表真实订单或 broker action。

/// SignalDirection 只表达研究信号方向，第一版不包含 short、margin 或真实订单方向。
public enum SignalDirection: String, Codable, Equatable, Sendable {
    case long
    case flat
}

/// StrategySignalEvent 表示策略在本地研究链路生成的信号事实，不触发交易执行。
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
