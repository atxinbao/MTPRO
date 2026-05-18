import Foundation

/// Core 错误边界集中描述合同校验失败，避免 unsupported market data、Live 执行和非法事件进入运行时。

/// CoreError 集中表达 Core 模块的合同校验失败，用于阻止非法 symbol、timeframe、Live 执行和不合法事件进入运行时。
public enum CoreError: Error, Equatable, Sendable, CustomStringConvertible {
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
    case invalidExecutionCostAssumption(field: String, value: Double)
    case invalidExecutionCostRoundingDecimalPlaces(Int)
    case riskEvaluationRequiresPaperMode(ExecutionMode)

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
        case let .invalidExecutionCostAssumption(field, value):
            "Execution cost assumption must be finite and non-negative for \(field): \(value)"
        case let .invalidExecutionCostRoundingDecimalPlaces(value):
            "Execution cost rounding decimal places must be within 0...8: \(value)"
        case let .riskEvaluationRequiresPaperMode(value):
            "Risk evaluation requires paper mode: \(value.rawValue)"
        }
    }
}
