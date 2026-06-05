import DomainModel
import Foundation

/// Risk / Portfolio 的中立消息合同。
///
/// 这些类型归属于 MessageBus，因为它们是 strategy、risk、portfolio 与 execution 之间传递的
/// query / evidence payload。它们不读取真实账户、不连接 broker，也不授权 live order command。
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
        try self.init(
            paperOrderID: try container.decode(Identifier.self, forKey: .paperOrderID),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            proposedQuantity: try container.decode(Quantity.self, forKey: .proposedQuantity),
            riskProfileID: try container.decode(Identifier.self, forKey: .riskProfileID),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode)
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

/// RiskBlockerReason 是最小风险阻断原因枚举。
///
/// 这些原因只服务 Paper readiness evidence，不代表完整风险引擎、实时风控、保证金、
/// 杠杆或真实 broker 拒单原因。
public enum RiskBlockerReason: String, Codable, CaseIterable, Equatable, Sendable {
    case maxPaperQuantityExceeded
    case maxPaperNotionalExceeded
    case missingPaperSessionProjection
    case paperOnlyExecutionBoundary
}

/// RiskBlockerEvidence 记录 Paper 风险阻断的可审计证据。
///
/// evidence 绑定 proposed paper action context、risk profile、阻断原因和生成时间；
/// 它只证明本地 Paper 路径被阻断，不包含 broker order、账户状态、signed endpoint
/// 或 Live execution fallback。
public struct RiskBlockerEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let paperOrderID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let proposedQuantity: Quantity
    public let riskProfileID: Identifier
    public let executionMode: ExecutionMode
    public let reason: RiskBlockerReason
    public let generatedAt: Date

    public init(
        evidenceID: Identifier,
        query: RiskEvaluationQuery,
        reason: RiskBlockerReason,
        generatedAt: Date
    ) {
        self.evidenceID = evidenceID
        self.paperOrderID = query.paperOrderID
        self.symbol = query.symbol
        self.timeframe = query.timeframe
        self.proposedQuantity = query.proposedQuantity
        self.riskProfileID = query.riskProfileID
        self.executionMode = query.executionMode
        self.reason = reason
        self.generatedAt = generatedAt
    }
}

/// PortfolioExposureSource 标记组合 exposure 的本地来源。
///
/// v1 只允许从 Paper projection 派生 exposure evidence，不读取 account endpoint、
/// broker balance、margin、leverage 或真实持仓。
public enum PortfolioExposureSource: String, Codable, Equatable, Sendable {
    case paperProjection
}

/// PortfolioExposureSnapshot 是最小 portfolio-level 只读 exposure 指标。
///
/// 输入是本地 Paper projection 的 symbol / timeframe / quantity 和参考价格；输出只计算
/// gross exposure notional，供 read model 展示和验证，不代表真实账户余额、保证金、
/// 杠杆仓位、broker fill 或 Live execution。
public struct PortfolioExposureSnapshot: Codable, Equatable, Sendable {
    public let portfolioID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let paperQuantity: Quantity
    public let referencePrice: Price
    public let grossExposureNotional: Double
    public let source: PortfolioExposureSource
    public let observedAt: Date

    public init(
        portfolioID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        paperQuantity: Quantity,
        referencePrice: Price,
        source: PortfolioExposureSource,
        observedAt: Date
    ) {
        self.portfolioID = portfolioID
        self.symbol = symbol
        self.timeframe = timeframe
        self.paperQuantity = paperQuantity
        self.referencePrice = referencePrice
        self.grossExposureNotional = paperQuantity.rawValue * referencePrice.rawValue
        self.source = source
        self.observedAt = observedAt
    }
}

/// RiskEvent 表示风险评估观察事件，当前覆盖 Paper 风险请求和阻断 evidence。
public enum RiskEvent: Codable, Equatable, Sendable {
    case evaluationRequested(RiskEvaluationQuery)
    case blocked(RiskBlockerEvidence)
}
