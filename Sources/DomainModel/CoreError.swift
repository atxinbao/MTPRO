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
    case paperSessionLocalControlRequiresPaperMode(ExecutionMode)
    case paperSessionLocalControlForbiddenCapability(String)
    case paperSessionLocalControlMismatch(field: String, expected: String, actual: String)
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
    case invalidPaperSessionSignalCount(Int)
    case invalidPaperActionProposalQuantity(Double)
    case paperActionProposalRequiresPaperMode(ExecutionMode)
    case paperActionProposalSignalMismatch(field: String, expected: String, actual: String)
    case paperActionProposalCostEvidenceMismatch(field: String, expected: String, actual: String)
    case paperActionRiskDecisionMismatch(field: String, expected: String, actual: String)
    case paperPortfolioProjectionRequiresAllowedRiskDecision(String)
    case paperPortfolioProjectionRequiresPaperMode(ExecutionMode)
    case paperPortfolioProjectionForbiddenCapability(String)
    case paperPortfolioProjectionMismatch(field: String, expected: String, actual: String)
    case paperExecutionWorkflowForbiddenCapability(String)
    case paperExecutionWorkflowContractMismatch(field: String, expected: String, actual: String)
    case paperOrderIntentRequiresPaperMode(ExecutionMode)
    case paperOrderIntentForbiddenCapability(String)
    case paperOrderIntentMismatch(field: String, expected: String, actual: String)
    case invalidPaperSimulatedFillQuantity(Double)
    case paperSimulatedFillRequiresPaperMode(ExecutionMode)
    case paperSimulatedFillRequiresOrderIntentCreated(String)
    case paperSimulatedFillForbiddenCapability(String)
    case paperSimulatedFillMismatch(field: String, expected: String, actual: String)
    case paperExecutionDecisionRequiresPaperMode(ExecutionMode)
    case paperExecutionDecisionForbiddenCapability(String)
    case paperExecutionDecisionMismatch(field: String, expected: String, actual: String)
    case tradingClockContractMismatch(field: String, expected: String, actual: String)
    case paperRuntimeKernelForbiddenCapability(String)
    case paperRuntimeKernelContractMismatch(field: String, expected: String, actual: String)
    case paperRuntimeBusRoutingForbiddenCapability(String)
    case paperRuntimeBusRoutingMismatch(field: String, expected: String, actual: String)
    case paperPreTradeRiskEngineForbiddenCapability(String)
    case paperPreTradeRiskEngineMismatch(field: String, expected: String, actual: String)
    case paperOrderLocalLifecycleForbiddenCapability(String)
    case paperOrderLocalLifecycleMismatch(field: String, expected: String, actual: String)
    case dataCatalogScenarioReplayForbiddenCapability(String)
    case dataCatalogScenarioReplayContractMismatch(field: String, expected: String, actual: String)
    case simulatedExchangeBacktestParityForbiddenCapability(String)
    case simulatedExchangeBacktestParityContractMismatch(field: String, expected: String, actual: String)
    case workbenchBetaReadinessForbiddenCapability(String)
    case workbenchBetaReadinessContractMismatch(field: String, expected: String, actual: String)
    case traderAccountContextForbiddenCapability(String)
    case traderAccountContextMismatch(field: String, expected: String, actual: String)
    case liveTradingBoundaryForbiddenCapability(String)
    case liveTradingBoundaryContractMismatch(field: String, expected: String, actual: String)
    case liveMonitoringConsoleForbiddenCapability(String)
    case liveMonitoringConsoleContractMismatch(field: String, expected: String, actual: String)

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
        case let .paperSessionLocalControlRequiresPaperMode(value):
            "Paper session local control requires paper mode: \(value.rawValue)"
        case let .paperSessionLocalControlForbiddenCapability(field):
            "Paper session local control forbids capability: \(field)"
        case let .paperSessionLocalControlMismatch(field, expected, actual):
            "Paper session local control mismatch for \(field): expected \(expected), actual \(actual)"
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
        case let .invalidPaperSessionSignalCount(value):
            "Paper session signal count must be non-negative: \(value)"
        case let .invalidPaperActionProposalQuantity(value):
            "Paper action proposal quantity must be positive before signal-side mapping: \(value)"
        case let .paperActionProposalRequiresPaperMode(value):
            "Paper action proposal requires paper mode: \(value.rawValue)"
        case let .paperActionProposalSignalMismatch(field, expected, actual):
            "Paper action proposal signal mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperActionProposalCostEvidenceMismatch(field, expected, actual):
            "Paper action proposal cost evidence mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperActionRiskDecisionMismatch(field, expected, actual):
            "Paper action risk decision mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperPortfolioProjectionRequiresAllowedRiskDecision(value):
            "Paper portfolio projection requires allowed risk decision: \(value)"
        case let .paperPortfolioProjectionRequiresPaperMode(value):
            "Paper portfolio projection requires paper mode: \(value.rawValue)"
        case let .paperPortfolioProjectionForbiddenCapability(field):
            "Paper portfolio projection forbids capability: \(field)"
        case let .paperPortfolioProjectionMismatch(field, expected, actual):
            "Paper portfolio projection mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperExecutionWorkflowForbiddenCapability(field):
            "Paper execution workflow forbids capability: \(field)"
        case let .paperExecutionWorkflowContractMismatch(field, expected, actual):
            "Paper execution workflow contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperOrderIntentRequiresPaperMode(value):
            "Paper order intent requires paper mode: \(value.rawValue)"
        case let .paperOrderIntentForbiddenCapability(field):
            "Paper order intent forbids capability: \(field)"
        case let .paperOrderIntentMismatch(field, expected, actual):
            "Paper order intent mismatch for \(field): expected \(expected), actual \(actual)"
        case let .invalidPaperSimulatedFillQuantity(value):
            "Paper simulated fill quantity must be positive: \(value)"
        case let .paperSimulatedFillRequiresPaperMode(value):
            "Paper simulated fill requires paper mode: \(value.rawValue)"
        case let .paperSimulatedFillRequiresOrderIntentCreated(value):
            "Paper simulated fill requires intentCreated order lifecycle state: \(value)"
        case let .paperSimulatedFillForbiddenCapability(field):
            "Paper simulated fill forbids capability: \(field)"
        case let .paperSimulatedFillMismatch(field, expected, actual):
            "Paper simulated fill mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperExecutionDecisionRequiresPaperMode(value):
            "Paper execution decision requires paper mode: \(value.rawValue)"
        case let .paperExecutionDecisionForbiddenCapability(field):
            "Paper execution decision forbids capability: \(field)"
        case let .paperExecutionDecisionMismatch(field, expected, actual):
            "Paper execution decision mismatch for \(field): expected \(expected), actual \(actual)"
        case let .tradingClockContractMismatch(field, expected, actual):
            "Trading clock contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperRuntimeKernelForbiddenCapability(field):
            "Paper runtime kernel forbids capability: \(field)"
        case let .paperRuntimeKernelContractMismatch(field, expected, actual):
            "Paper runtime kernel contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperRuntimeBusRoutingForbiddenCapability(field):
            "Paper runtime bus routing forbids capability: \(field)"
        case let .paperRuntimeBusRoutingMismatch(field, expected, actual):
            "Paper runtime bus routing mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperPreTradeRiskEngineForbiddenCapability(field):
            "Paper pre-trade risk engine forbids capability: \(field)"
        case let .paperPreTradeRiskEngineMismatch(field, expected, actual):
            "Paper pre-trade risk engine mismatch for \(field): expected \(expected), actual \(actual)"
        case let .paperOrderLocalLifecycleForbiddenCapability(field):
            "Paper order local lifecycle forbids capability: \(field)"
        case let .paperOrderLocalLifecycleMismatch(field, expected, actual):
            "Paper order local lifecycle mismatch for \(field): expected \(expected), actual \(actual)"
        case let .dataCatalogScenarioReplayForbiddenCapability(field):
            "Data catalog scenario replay forbids capability: \(field)"
        case let .dataCatalogScenarioReplayContractMismatch(field, expected, actual):
            "Data catalog scenario replay contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .simulatedExchangeBacktestParityForbiddenCapability(field):
            "Simulated exchange backtest parity forbids capability: \(field)"
        case let .simulatedExchangeBacktestParityContractMismatch(field, expected, actual):
            "Simulated exchange backtest parity contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .workbenchBetaReadinessForbiddenCapability(field):
            "Workbench beta readiness forbids capability: \(field)"
        case let .workbenchBetaReadinessContractMismatch(field, expected, actual):
            "Workbench beta readiness contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .traderAccountContextForbiddenCapability(field):
            "Trader account context forbids capability: \(field)"
        case let .traderAccountContextMismatch(field, expected, actual):
            "Trader account context mismatch for \(field): expected \(expected), actual \(actual)"
        case let .liveTradingBoundaryForbiddenCapability(field):
            "Live trading boundary forbids capability: \(field)"
        case let .liveTradingBoundaryContractMismatch(field, expected, actual):
            "Live trading boundary contract mismatch for \(field): expected \(expected), actual \(actual)"
        case let .liveMonitoringConsoleForbiddenCapability(field):
            "Live monitoring console forbids capability: \(field)"
        case let .liveMonitoringConsoleContractMismatch(field, expected, actual):
            "Live monitoring console contract mismatch for \(field): expected \(expected), actual \(actual)"
        }
    }
}
