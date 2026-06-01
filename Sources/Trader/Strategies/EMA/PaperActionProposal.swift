import Foundation

/// MTP-193 将 paper/live-neutral proposal source 迁入 `Sources/Trader/Strategies/EMA/`。
/// proposal 仍只表达 strategy-derived paper intent，不能升级为 order command、OMS order 或 broker request。
/// Paper action proposal 类型把本地 strategy signal 转成 paper-only action intent。
///
/// 该文件只定义可验证的提案模型、数量 / notional 假设和 deterministic fixture；它不定义订单、
/// 不提交真实交易、不连接 broker、不读取 signed endpoint，也不更新 portfolio projection。

/// PaperActionProposalSide 表达 Paper 提案的本地动作方向。
///
/// v1 只有 `buy` 和 `hold`：`long` 研究信号映射为 buy intent，`flat` 映射为 hold intent。
/// 这里没有 sell、short、margin、leverage 或任何真实订单 side。
public enum PaperActionProposalSide: String, Codable, Equatable, Sendable {
    case buy
    case hold

    public init(signalDirection: SignalDirection) {
        switch signalDirection {
        case .long:
            self = .buy
        case .flat:
            self = .hold
        }
    }
}

/// PaperActionProposalAuthorization 固定声明提案只允许本地 Paper intent。
///
/// 该授权值刻意只有一个 case，Codable 解码无法恢复真实订单、broker action 或 Live fallback。
public enum PaperActionProposalAuthorization: String, Codable, Equatable, Sendable {
    case paperIntentOnly

    public var allowsRealOrder: Bool {
        false
    }

    public var allowsBrokerAction: Bool {
        false
    }
}

/// PaperActionProposalSizingAssumption 保存 proposal fixture 使用的数量和参考价格假设。
///
/// 输入字段只服务本地 Paper proposal 估算：quantity 必须为正数，referencePrice 必须为正数，
/// liquidityRole 只用于复用 MTP-27 fixed cost evidence。它不是交易所费率表、账户规则、
/// order sizing engine 或 broker 下单参数。
public struct PaperActionProposalSizingAssumption: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let quantity: Quantity
    public let referencePrice: Price
    public let liquidityRole: ExecutionCostLiquidityRole
    public let executionCostAssumptions: ExecutionCostAssumptions

    public init(
        assumptionID: Identifier,
        quantity: Quantity,
        referencePrice: Price,
        liquidityRole: ExecutionCostLiquidityRole,
        executionCostAssumptions: ExecutionCostAssumptions = .deterministicFixture
    ) throws {
        guard quantity.rawValue > 0 else {
            throw CoreError.invalidPaperActionProposalQuantity(quantity.rawValue)
        }
        self.assumptionID = assumptionID
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.liquidityRole = liquidityRole
        self.executionCostAssumptions = executionCostAssumptions
    }

    /// MTP-32 deterministic fixture 用于 XCTest 和 PR evidence，不能解释为真实 sizing 规则。
    public static let deterministicFixture: PaperActionProposalSizingAssumption = {
        do {
            return try PaperActionProposalSizingAssumption(
                assumptionID: try Identifier("mtp-32-paper-action-sizing"),
                quantity: try Quantity(0.5, field: "paperActionProposal.quantity"),
                referencePrice: try Price(100, field: "paperActionProposal.referencePrice"),
                liquidityRole: .maker,
                executionCostAssumptions: .deterministicFixture
            )
        } catch {
            preconditionFailure("Invalid deterministic paper action proposal sizing fixture: \(error)")
        }
    }()
}

/// PaperActionProposal 是 strategy signal 派生的 paper-only action intent。
///
/// 输入是本地策略信号和 sizing assumption；输出保留 symbol、timeframe、side、paper quantity、
/// notional、fixed cost evidence 和 proposedAt。模型固定 `executionMode == .paper`，并通过
/// `executionAuthorization` 与 `isExecutableAsRealOrder` 明确禁止真实订单、broker action、
/// signed endpoint、account endpoint 或 Live trading。
public struct PaperActionProposal: Codable, Equatable, Sendable {
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let signal: StrategySignalEvent
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let side: PaperActionProposalSide
    public let sizingAssumptionID: Identifier
    public let quantity: Quantity
    public let referencePrice: Price
    public let notionalAmount: Double
    public let costEstimate: ExecutionCostEstimate
    public let executionMode: ExecutionMode
    public let executionAuthorization: PaperActionProposalAuthorization
    public let proposedAt: Date

    public var isExecutableAsRealOrder: Bool {
        false
    }

    public init(
        proposalID: Identifier,
        sessionID: Identifier,
        signal: StrategySignalEvent,
        sizingAssumption: PaperActionProposalSizingAssumption,
        proposedAt: Date
    ) throws {
        let side = PaperActionProposalSide(signalDirection: signal.direction)
        let proposalQuantity = try Self.quantity(
            for: side,
            sizingAssumption: sizingAssumption
        )
        let costEstimate = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: signal.symbol,
                timeframe: signal.timeframe,
                executionMode: .paper,
                referencePrice: sizingAssumption.referencePrice,
                quantity: proposalQuantity,
                liquidityRole: sizingAssumption.liquidityRole
            ),
            assumptions: sizingAssumption.executionCostAssumptions
        )

        try self.init(
            proposalID: proposalID,
            sessionID: sessionID,
            signal: signal,
            symbol: signal.symbol,
            timeframe: signal.timeframe,
            side: side,
            sizingAssumptionID: sizingAssumption.assumptionID,
            quantity: proposalQuantity,
            referencePrice: sizingAssumption.referencePrice,
            notionalAmount: costEstimate.grossNotional,
            costEstimate: costEstimate,
            executionMode: .paper,
            executionAuthorization: .paperIntentOnly,
            proposedAt: proposedAt
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            proposalID: try container.decode(Identifier.self, forKey: .proposalID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            signal: try container.decode(StrategySignalEvent.self, forKey: .signal),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            sizingAssumptionID: try container.decode(Identifier.self, forKey: .sizingAssumptionID),
            quantity: try container.decode(Quantity.self, forKey: .quantity),
            referencePrice: try container.decode(Price.self, forKey: .referencePrice),
            notionalAmount: try container.decode(Double.self, forKey: .notionalAmount),
            costEstimate: try container.decode(ExecutionCostEstimate.self, forKey: .costEstimate),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            executionAuthorization: try container.decode(
                PaperActionProposalAuthorization.self,
                forKey: .executionAuthorization
            ),
            proposedAt: try container.decode(Date.self, forKey: .proposedAt)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(proposalID, forKey: .proposalID)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(signal, forKey: .signal)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(side, forKey: .side)
        try container.encode(sizingAssumptionID, forKey: .sizingAssumptionID)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(referencePrice, forKey: .referencePrice)
        try container.encode(notionalAmount, forKey: .notionalAmount)
        try container.encode(costEstimate, forKey: .costEstimate)
        try container.encode(executionMode, forKey: .executionMode)
        try container.encode(executionAuthorization, forKey: .executionAuthorization)
        try container.encode(proposedAt, forKey: .proposedAt)
    }

    private init(
        proposalID: Identifier,
        sessionID: Identifier,
        signal: StrategySignalEvent,
        symbol: Symbol,
        timeframe: Timeframe,
        side: PaperActionProposalSide,
        sizingAssumptionID: Identifier,
        quantity: Quantity,
        referencePrice: Price,
        notionalAmount: Double,
        costEstimate: ExecutionCostEstimate,
        executionMode: ExecutionMode,
        executionAuthorization: PaperActionProposalAuthorization,
        proposedAt: Date
    ) throws {
        guard executionMode == .paper else {
            throw CoreError.paperActionProposalRequiresPaperMode(executionMode)
        }
        try Self.validateSignalMapping(signal: signal, symbol: symbol, timeframe: timeframe, side: side)
        try Self.validateCostEvidence(
            symbol: symbol,
            timeframe: timeframe,
            quantity: quantity,
            referencePrice: referencePrice,
            notionalAmount: notionalAmount,
            costEstimate: costEstimate
        )

        self.proposalID = proposalID
        self.sessionID = sessionID
        self.signal = signal
        self.symbol = symbol
        self.timeframe = timeframe
        self.side = side
        self.sizingAssumptionID = sizingAssumptionID
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notionalAmount = notionalAmount
        self.costEstimate = costEstimate
        self.executionMode = executionMode
        self.executionAuthorization = executionAuthorization
        self.proposedAt = proposedAt
    }

    private static func quantity(
        for side: PaperActionProposalSide,
        sizingAssumption: PaperActionProposalSizingAssumption
    ) throws -> Quantity {
        switch side {
        case .buy:
            sizingAssumption.quantity
        case .hold:
            try Quantity(0, field: "paperActionProposal.quantity")
        }
    }

    private static func validateSignalMapping(
        signal: StrategySignalEvent,
        symbol: Symbol,
        timeframe: Timeframe,
        side: PaperActionProposalSide
    ) throws {
        guard signal.symbol == symbol else {
            throw CoreError.paperActionProposalSignalMismatch(
                field: "symbol",
                expected: signal.symbol.rawValue,
                actual: symbol.rawValue
            )
        }
        guard signal.timeframe == timeframe else {
            throw CoreError.paperActionProposalSignalMismatch(
                field: "timeframe",
                expected: signal.timeframe.rawValue,
                actual: timeframe.rawValue
            )
        }
        let expectedSide = PaperActionProposalSide(signalDirection: signal.direction)
        guard side == expectedSide else {
            throw CoreError.paperActionProposalSignalMismatch(
                field: "side",
                expected: expectedSide.rawValue,
                actual: side.rawValue
            )
        }
    }

    private static func validateCostEvidence(
        symbol: Symbol,
        timeframe: Timeframe,
        quantity: Quantity,
        referencePrice: Price,
        notionalAmount: Double,
        costEstimate: ExecutionCostEstimate
    ) throws {
        guard costEstimate.executionMode == .paper else {
            throw CoreError.paperActionProposalRequiresPaperMode(costEstimate.executionMode)
        }
        try validateCostField("symbol", expected: symbol.rawValue, actual: costEstimate.symbol.rawValue)
        try validateCostField("timeframe", expected: timeframe.rawValue, actual: costEstimate.timeframe.rawValue)
        try validateCostField("quantity", expected: quantity.rawValue, actual: costEstimate.quantity.rawValue)
        try validateCostField(
            "referencePrice",
            expected: referencePrice.rawValue,
            actual: costEstimate.referencePrice.rawValue
        )
        try validateCostField("notionalAmount", expected: notionalAmount, actual: costEstimate.grossNotional)
    }

    private static func validateCostField(
        _ field: String,
        expected: String,
        actual: String
    ) throws {
        guard expected == actual else {
            throw CoreError.paperActionProposalCostEvidenceMismatch(
                field: field,
                expected: expected,
                actual: actual
            )
        }
    }

    private static func validateCostField(
        _ field: String,
        expected: Double,
        actual: Double
    ) throws {
        guard expected == actual else {
            throw CoreError.paperActionProposalCostEvidenceMismatch(
                field: field,
                expected: "\(expected)",
                actual: "\(actual)"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case proposalID
        case sessionID
        case signal
        case symbol
        case timeframe
        case side
        case sizingAssumptionID
        case quantity
        case referencePrice
        case notionalAmount
        case costEstimate
        case executionMode
        case executionAuthorization
        case proposedAt
    }
}

/// PaperActionProposalFixture 生成 MTP-32 本地确定性 proposal evidence。
///
/// Fixture 固定 strategy signal、session、proposal、时间戳、quantity、reference price 和
/// MTP-27 cost assumptions，只用于测试和 PR evidence；不得当作真实 sizing engine、
/// OMS、broker order 或 portfolio update。
public enum PaperActionProposalFixture {
    public static func deterministicLong() throws -> PaperActionProposal {
        try PaperActionProposal(
            proposalID: try Identifier("paper-action-proposal-long"),
            sessionID: try Identifier("paper-session-fixture"),
            signal: StrategySignalEvent(
                strategyID: try Identifier("ema-cross"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                direction: .long,
                generatedAt: Date(timeIntervalSince1970: 1_600)
            ),
            sizingAssumption: .deterministicFixture,
            proposedAt: Date(timeIntervalSince1970: 1_620)
        )
    }

    public static func deterministicFlat() throws -> PaperActionProposal {
        try PaperActionProposal(
            proposalID: try Identifier("paper-action-proposal-flat"),
            sessionID: try Identifier("paper-session-fixture"),
            signal: StrategySignalEvent(
                strategyID: try Identifier("ema-cross"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                direction: .flat,
                generatedAt: Date(timeIntervalSince1970: 1_680)
            ),
            sizingAssumption: .deterministicFixture,
            proposedAt: Date(timeIntervalSince1970: 1_700)
        )
    }
}
