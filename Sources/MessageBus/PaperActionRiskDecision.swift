import DomainModel
import Foundation

/// Paper action risk decision 是 proposal -> risk -> execution 链路上的中立消息合同。
///
/// 该类型归属于 MessageBus，而不是 Trader Coordination。Trader Coordination 可以生成它，
/// RiskEngine / ExecutionEngine / Portfolio 可以消费它；它本身不连接 broker、不提交订单、
/// 不提供 OMS，也不授权 Live command。
public enum PaperActionProposalRiskDecisionStatus: String, Codable, Equatable, Sendable {
    case allowed
    case blocked
}

/// PaperActionProposalRiskDecision 保存 proposal 和 risk blocker 的可追溯链路。
///
/// 输入是 `PaperActionProposal`、本地 risk query、source sequence 和评估时间；输出是允许 / 阻断
/// 状态、可选 blocker evidence 和只读风险事件视图。`sourceSequence` 用来关联产生 proposal 的
/// 本地 event log envelope，不代表 broker order sequence 或交易所回报序号。
public struct PaperActionProposalRiskDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let proposal: PaperActionProposal
    public let riskQuery: RiskEvaluationQuery
    public let sourceSequence: Int
    public let status: PaperActionProposalRiskDecisionStatus
    public let blockerEvidence: RiskBlockerEvidence?
    public let evaluatedAt: Date

    public var isAllowed: Bool {
        status == .allowed
    }

    public var isBlocked: Bool {
        status == .blocked
    }

    public var liveExecutionFallbackAvailable: Bool {
        false
    }

    public var brokerFallbackAvailable: Bool {
        false
    }

    public var paperOnlyContextIsConsistent: Bool {
        proposal.executionMode == .paper
            && riskQuery.executionMode == .paper
            && proposal.executionAuthorization == .paperIntentOnly
            && proposal.isExecutableAsRealOrder == false
            && proposal.executionAuthorization.allowsBrokerAction == false
            && proposal.executionAuthorization.allowsRealOrder == false
    }

    public var riskEvents: [RiskEvent] {
        var events: [RiskEvent] = [.evaluationRequested(riskQuery)]
        if let blockerEvidence {
            events.append(.blocked(blockerEvidence))
        }
        return events
    }

    public init(
        decisionID: Identifier,
        proposal: PaperActionProposal,
        riskQuery: RiskEvaluationQuery,
        sourceSequence: Int,
        status: PaperActionProposalRiskDecisionStatus,
        blockerEvidence: RiskBlockerEvidence?,
        evaluatedAt: Date
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        try Self.validateRiskQuery(proposal: proposal, riskQuery: riskQuery)
        try Self.validateBlocker(status: status, blockerEvidence: blockerEvidence, riskQuery: riskQuery)

        self.decisionID = decisionID
        self.proposal = proposal
        self.riskQuery = riskQuery
        self.sourceSequence = sourceSequence
        self.status = status
        self.blockerEvidence = blockerEvidence
        self.evaluatedAt = evaluatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decisionID: try container.decode(Identifier.self, forKey: .decisionID),
            proposal: try container.decode(PaperActionProposal.self, forKey: .proposal),
            riskQuery: try container.decode(RiskEvaluationQuery.self, forKey: .riskQuery),
            sourceSequence: try container.decode(Int.self, forKey: .sourceSequence),
            status: try container.decode(PaperActionProposalRiskDecisionStatus.self, forKey: .status),
            blockerEvidence: try container.decodeIfPresent(RiskBlockerEvidence.self, forKey: .blockerEvidence),
            evaluatedAt: try container.decode(Date.self, forKey: .evaluatedAt)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(decisionID, forKey: .decisionID)
        try container.encode(proposal, forKey: .proposal)
        try container.encode(riskQuery, forKey: .riskQuery)
        try container.encode(sourceSequence, forKey: .sourceSequence)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(blockerEvidence, forKey: .blockerEvidence)
        try container.encode(evaluatedAt, forKey: .evaluatedAt)
    }

    private static func validateRiskQuery(
        proposal: PaperActionProposal,
        riskQuery: RiskEvaluationQuery
    ) throws {
        try validateField(
            "paperOrderID",
            expected: proposal.proposalID.rawValue,
            actual: riskQuery.paperOrderID.rawValue
        )
        try validateField("symbol", expected: proposal.symbol.rawValue, actual: riskQuery.symbol.rawValue)
        try validateField("timeframe", expected: proposal.timeframe.rawValue, actual: riskQuery.timeframe.rawValue)
        try validateField(
            "proposedQuantity",
            expected: proposal.quantity.rawValue,
            actual: riskQuery.proposedQuantity.rawValue
        )
        try validateField("executionMode", expected: ExecutionMode.paper.rawValue, actual: riskQuery.executionMode.rawValue)
    }

    private static func validateBlocker(
        status: PaperActionProposalRiskDecisionStatus,
        blockerEvidence: RiskBlockerEvidence?,
        riskQuery: RiskEvaluationQuery
    ) throws {
        switch (status, blockerEvidence) {
        case (.allowed, nil):
            return
        case let (.blocked, evidence?):
            try validateField(
                "blocker.paperOrderID",
                expected: riskQuery.paperOrderID.rawValue,
                actual: evidence.paperOrderID.rawValue
            )
            try validateField("blocker.symbol", expected: riskQuery.symbol.rawValue, actual: evidence.symbol.rawValue)
            try validateField(
                "blocker.timeframe",
                expected: riskQuery.timeframe.rawValue,
                actual: evidence.timeframe.rawValue
            )
            try validateField(
                "blocker.proposedQuantity",
                expected: riskQuery.proposedQuantity.rawValue,
                actual: evidence.proposedQuantity.rawValue
            )
            try validateField(
                "blocker.riskProfileID",
                expected: riskQuery.riskProfileID.rawValue,
                actual: evidence.riskProfileID.rawValue
            )
            try validateField(
                "blocker.executionMode",
                expected: ExecutionMode.paper.rawValue,
                actual: evidence.executionMode.rawValue
            )
        case (.allowed, .some):
            throw CoreError.paperActionRiskDecisionMismatch(
                field: "blockerEvidence",
                expected: "nil for allowed decision",
                actual: "present"
            )
        case (.blocked, nil):
            throw CoreError.paperActionRiskDecisionMismatch(
                field: "blockerEvidence",
                expected: "present for blocked decision",
                actual: "nil"
            )
        }
    }

    private static func validateField(_ field: String, expected: String, actual: String) throws {
        guard expected == actual else {
            throw CoreError.paperActionRiskDecisionMismatch(field: field, expected: expected, actual: actual)
        }
    }

    private static func validateField(_ field: String, expected: Double, actual: Double) throws {
        guard expected == actual else {
            throw CoreError.paperActionRiskDecisionMismatch(
                field: field,
                expected: "\(expected)",
                actual: "\(actual)"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case decisionID
        case proposal
        case riskQuery
        case sourceSequence
        case status
        case blockerEvidence
        case evaluatedAt
    }
}
