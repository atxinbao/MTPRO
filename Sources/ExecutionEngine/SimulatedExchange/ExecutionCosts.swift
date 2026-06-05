import DomainModel
import Foundation

/// Execution cost 类型只服务 Backtest / Paper parity evidence。
///
/// 这里的 fee / slippage 是固定假设和 deterministic fixture，不是交易所费率表、动态滑点模型、
/// execution optimizer、真实 broker action，也不会提交、取消或替换任何订单。

/// ExecutionCostLiquidityRole 描述最小费用假设中的 maker / taker 角色。
///
/// 该角色只用于选择固定 fee bps，不读取交易所账户等级、不查询真实成交、不触发 signed endpoint。
public enum ExecutionCostLiquidityRole: String, Codable, CaseIterable, Equatable, Sendable {
    case maker
    case taker
}

/// ExecutionCostAssumptions 保存 MTP-27 固定 fee / slippage 假设。
///
/// 输入字段是可审计的 assumption ID、maker fee bps、taker fee bps、固定 slippage bps
/// 和金额四舍五入位数。它刻意不包含交易所费率表、symbol-specific tier、动态盘口滑点、
/// 账户等级、优化器或任何真实执行能力。
public struct ExecutionCostAssumptions: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let makerFeeRateBps: Double
    public let takerFeeRateBps: Double
    public let slippageRateBps: Double
    public let roundingDecimalPlaces: Int

    public init(
        assumptionID: Identifier,
        makerFeeRateBps: Double,
        takerFeeRateBps: Double,
        slippageRateBps: Double,
        roundingDecimalPlaces: Int
    ) throws {
        try Self.validateRate(makerFeeRateBps, field: "makerFeeRateBps")
        try Self.validateRate(takerFeeRateBps, field: "takerFeeRateBps")
        try Self.validateRate(slippageRateBps, field: "slippageRateBps")
        guard (0...8).contains(roundingDecimalPlaces) else {
            throw CoreError.invalidExecutionCostRoundingDecimalPlaces(roundingDecimalPlaces)
        }

        self.assumptionID = assumptionID
        self.makerFeeRateBps = makerFeeRateBps
        self.takerFeeRateBps = takerFeeRateBps
        self.slippageRateBps = slippageRateBps
        self.roundingDecimalPlaces = roundingDecimalPlaces
    }

    /// MTP-27 deterministic fixture 用于本地测试和 PR evidence，不能被解释为 Binance 实际费率。
    public static let deterministicFixture: ExecutionCostAssumptions = {
        do {
            return try ExecutionCostAssumptions(
                assumptionID: try Identifier("mtp-27-fixed-cost-assumptions"),
                makerFeeRateBps: 2,
                takerFeeRateBps: 5,
                slippageRateBps: 1.5,
                roundingDecimalPlaces: 8
            )
        } catch {
            preconditionFailure("Invalid deterministic execution cost fixture: \(error)")
        }
    }()

    public func feeRateBps(for liquidityRole: ExecutionCostLiquidityRole) -> Double {
        switch liquidityRole {
        case .maker:
            makerFeeRateBps
        case .taker:
            takerFeeRateBps
        }
    }

    private static func validateRate(_ value: Double, field: String) throws {
        guard value.isFinite, value >= 0 else {
            throw CoreError.invalidExecutionCostAssumption(field: field, value: value)
        }
    }
}

/// ExecutionCostEstimateRequest 是最小成本计算输入。
///
/// 它只接受已通过 Core 校验的 symbol、timeframe、Backtest / Paper execution mode、
/// 参考价格、数量和 maker / taker 角色。它不包含 order side、venue、account、真实成交 ID、
/// broker order ID 或任何能够触发真实交易的字段。
public struct ExecutionCostEstimateRequest: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let executionMode: ExecutionMode
    public let referencePrice: Price
    public let quantity: Quantity
    public let liquidityRole: ExecutionCostLiquidityRole

    public init(
        symbol: Symbol,
        timeframe: Timeframe,
        executionMode: ExecutionMode,
        referencePrice: Price,
        quantity: Quantity,
        liquidityRole: ExecutionCostLiquidityRole
    ) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.executionMode = executionMode
        self.referencePrice = referencePrice
        self.quantity = quantity
        self.liquidityRole = liquidityRole
    }
}

/// ExecutionCostEstimate 是最小计算输出。
///
/// 输出字段只表达 gross notional、固定 fee、固定 slippage 和 total cost，用于 Backtest / Paper
/// parity evidence。结果不代表真实成交价格、账户余额、保证金、杠杆、broker fill 或 Live 状态。
public struct ExecutionCostEstimate: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let executionMode: ExecutionMode
    public let liquidityRole: ExecutionCostLiquidityRole
    public let referencePrice: Price
    public let quantity: Quantity
    public let grossNotional: Double
    public let feeRateBps: Double
    public let feeAmount: Double
    public let slippageRateBps: Double
    public let slippageAmount: Double
    public let totalCostAmount: Double
    public let roundingDecimalPlaces: Int

    public init(
        assumptionID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        executionMode: ExecutionMode,
        liquidityRole: ExecutionCostLiquidityRole,
        referencePrice: Price,
        quantity: Quantity,
        grossNotional: Double,
        feeRateBps: Double,
        feeAmount: Double,
        slippageRateBps: Double,
        slippageAmount: Double,
        totalCostAmount: Double,
        roundingDecimalPlaces: Int
    ) {
        self.assumptionID = assumptionID
        self.symbol = symbol
        self.timeframe = timeframe
        self.executionMode = executionMode
        self.liquidityRole = liquidityRole
        self.referencePrice = referencePrice
        self.quantity = quantity
        self.grossNotional = grossNotional
        self.feeRateBps = feeRateBps
        self.feeAmount = feeAmount
        self.slippageRateBps = slippageRateBps
        self.slippageAmount = slippageAmount
        self.totalCostAmount = totalCostAmount
        self.roundingDecimalPlaces = roundingDecimalPlaces
    }
}

/// ExecutionCostCalculator 执行固定成本估算，不连接任何外部系统。
public enum ExecutionCostCalculator {
    /// 使用固定 bps 假设计算 fee / slippage evidence。
    ///
    /// 计算公式：
    /// - gross notional = reference price * quantity
    /// - fee amount = gross notional * selected fee bps / 10000
    /// - slippage amount = gross notional * fixed slippage bps / 10000
    /// - total cost = fee amount + slippage amount
    ///
    /// 所有金额按 assumptions.roundingDecimalPlaces 统一四舍五入，避免 Backtest / Paper
    /// 使用不同舍入规则产生 parity 假阳性。
    public static func estimate(
        _ request: ExecutionCostEstimateRequest,
        assumptions: ExecutionCostAssumptions = .deterministicFixture
    ) -> ExecutionCostEstimate {
        let feeRateBps = assumptions.feeRateBps(for: request.liquidityRole)
        let grossNotional = rounded(
            request.referencePrice.rawValue * request.quantity.rawValue,
            decimalPlaces: assumptions.roundingDecimalPlaces
        )
        let feeAmount = rounded(
            grossNotional * feeRateBps / 10_000,
            decimalPlaces: assumptions.roundingDecimalPlaces
        )
        let slippageAmount = rounded(
            grossNotional * assumptions.slippageRateBps / 10_000,
            decimalPlaces: assumptions.roundingDecimalPlaces
        )
        let totalCostAmount = rounded(
            feeAmount + slippageAmount,
            decimalPlaces: assumptions.roundingDecimalPlaces
        )

        return ExecutionCostEstimate(
            assumptionID: assumptions.assumptionID,
            symbol: request.symbol,
            timeframe: request.timeframe,
            executionMode: request.executionMode,
            liquidityRole: request.liquidityRole,
            referencePrice: request.referencePrice,
            quantity: request.quantity,
            grossNotional: grossNotional,
            feeRateBps: feeRateBps,
            feeAmount: feeAmount,
            slippageRateBps: assumptions.slippageRateBps,
            slippageAmount: slippageAmount,
            totalCostAmount: totalCostAmount,
            roundingDecimalPlaces: assumptions.roundingDecimalPlaces
        )
    }

    private static func rounded(_ value: Double, decimalPlaces: Int) -> Double {
        var source = Decimal(value)
        var result = Decimal()
        NSDecimalRound(&result, &source, decimalPlaces, .plain)
        return NSDecimalNumber(decimal: result).doubleValue
    }
}

/// ExecutionCostParityResult 保存 Backtest / Paper 成本 evidence 的一致性检查。
///
/// 该结果只比较同一固定假设和同一输入下的成本估算，不表示真实订单或 broker fill 已发生。
public struct ExecutionCostParityResult: Codable, Equatable, Sendable {
    public let sameAssumptionID: Bool
    public let sameCostInput: Bool
    public let matchingCostBreakdown: Bool
    public let backtestModeIsBacktest: Bool
    public let paperModeIsPaper: Bool

    public init(
        sameAssumptionID: Bool,
        sameCostInput: Bool,
        matchingCostBreakdown: Bool,
        backtestModeIsBacktest: Bool,
        paperModeIsPaper: Bool
    ) {
        self.sameAssumptionID = sameAssumptionID
        self.sameCostInput = sameCostInput
        self.matchingCostBreakdown = matchingCostBreakdown
        self.backtestModeIsBacktest = backtestModeIsBacktest
        self.paperModeIsPaper = paperModeIsPaper
    }

    public var isConsistent: Bool {
        sameAssumptionID
            && sameCostInput
            && matchingCostBreakdown
            && backtestModeIsBacktest
            && paperModeIsPaper
    }
}

/// ExecutionCostParity 比较 Backtest 与 Paper 的 fixed cost evidence。
public enum ExecutionCostParity {
    public static func verify(
        backtest: ExecutionCostEstimate,
        paper: ExecutionCostEstimate
    ) -> ExecutionCostParityResult {
        ExecutionCostParityResult(
            sameAssumptionID: backtest.assumptionID == paper.assumptionID,
            sameCostInput: backtest.symbol == paper.symbol
                && backtest.timeframe == paper.timeframe
                && backtest.liquidityRole == paper.liquidityRole
                && backtest.referencePrice == paper.referencePrice
                && backtest.quantity == paper.quantity,
            matchingCostBreakdown: backtest.grossNotional == paper.grossNotional
                && backtest.feeRateBps == paper.feeRateBps
                && backtest.feeAmount == paper.feeAmount
                && backtest.slippageRateBps == paper.slippageRateBps
                && backtest.slippageAmount == paper.slippageAmount
                && backtest.totalCostAmount == paper.totalCostAmount
                && backtest.roundingDecimalPlaces == paper.roundingDecimalPlaces,
            backtestModeIsBacktest: backtest.executionMode == .backtest,
            paperModeIsPaper: paper.executionMode == .paper
        )
    }
}
