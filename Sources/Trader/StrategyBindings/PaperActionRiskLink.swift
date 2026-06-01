import Foundation

/// MTP-187 将 proposal-to-risk binding 放入 `Sources/Trader/StrategyBindings/`。
/// MTP-195 将该目录重新收口为 generic binding protocol / coordination adapter contract。
/// Trader 在这里仍只是 strategy / risk / portfolio coordination evidence，不是 live coordinator 或 broker gateway。
/// Paper action risk link 把 MTP-32 的 paper-only proposal 接到本地风险观察证据。
///
/// 该文件只定义 strategy signal -> paper action proposal -> risk blocker 的最小本地链路。
/// 它不是 EMA、OrderBookImbalance 或未来具体策略的 implementation landing path；具体策略必须继续位于
/// `Sources/Trader/Strategies/<strategy>/`。
/// 它不是完整风险引擎、订单管理系统、broker 拒单回退或真实交易执行入口，也不会调用
/// Binance signed endpoint、account endpoint、order submit / cancel / replace 或 Live execution。

/// TraderStrategyBindingsContractRole 固定 `Sources/Trader/StrategyBindings/` 的允许职责。
///
/// MTP-195 只允许该目录表达通用绑定协议和 Trader coordination adapter contract。任何具体策略
/// lifecycle、signal、proposal、quoter、hedger 或 strategy-specific business rule 都必须放在
/// `Sources/Trader/Strategies/<strategy>/`，不能放入 StrategyBindings。
public enum TraderStrategyBindingsContractRole: String, Codable, Equatable, Sendable {
    case genericBindingProtocol = "generic_binding_protocol"
    case coordinationAdapterContract = "coordination_adapter_contract"
}

/// TraderStrategyBindingsBoundaryEvidence 是 MTP-195 的本地边界证据。
///
/// 该 evidence 只描述目录职责和禁止能力，用于 XCTest 与 automation readiness 机械检查。
/// 它不创建 Trader runtime、strategy scheduler、ExecutionClient path、broker command、OMS command
/// 或 Live command，也不改变现有 `PaperActionProposalRiskLink` 的 deterministic paper-only 行为。
public struct TraderStrategyBindingsBoundaryEvidence: Codable, Equatable, Sendable {
    public let strategyBindingsRoot: String
    public let concreteStrategyRoots: [String]
    public let contractRoles: [TraderStrategyBindingsContractRole]
    public let compatibilityTargetName: String
    public let carriesConcreteStrategyImplementation: Bool
    public let allowsDirectExecutionClientPath: Bool
    public let allowsBrokerCommandPath: Bool
    public let allowsOMSCommandPath: Bool
    public let allowsLiveCommandPath: Bool

    public init(
        strategyBindingsRoot: String,
        concreteStrategyRoots: [String],
        contractRoles: [TraderStrategyBindingsContractRole],
        compatibilityTargetName: String,
        carriesConcreteStrategyImplementation: Bool,
        allowsDirectExecutionClientPath: Bool,
        allowsBrokerCommandPath: Bool,
        allowsOMSCommandPath: Bool,
        allowsLiveCommandPath: Bool
    ) {
        self.strategyBindingsRoot = strategyBindingsRoot
        self.concreteStrategyRoots = concreteStrategyRoots
        self.contractRoles = contractRoles
        self.compatibilityTargetName = compatibilityTargetName
        self.carriesConcreteStrategyImplementation = carriesConcreteStrategyImplementation
        self.allowsDirectExecutionClientPath = allowsDirectExecutionClientPath
        self.allowsBrokerCommandPath = allowsBrokerCommandPath
        self.allowsOMSCommandPath = allowsOMSCommandPath
        self.allowsLiveCommandPath = allowsLiveCommandPath
    }

    /// 证明 StrategyBindings 只保留通用 binding / adapter contract，不持有具体策略实现。
    public var isGenericBindingProtocolAndAdapterOnly: Bool {
        contractRoles == [.genericBindingProtocol, .coordinationAdapterContract]
            && carriesConcreteStrategyImplementation == false
    }

    /// 证明当前具体策略 root 仍在 Trader-owned Strategies 下，而不是 StrategyBindings 或旧 peer-level path。
    public var concreteStrategiesRemainTraderOwned: Bool {
        concreteStrategyRoots.allSatisfy { root in
            root.hasPrefix("Sources/Trader/Strategies/")
                && root.contains("/StrategyBindings/") == false
                && root.hasPrefix("Sources/Strategies/") == false
        }
    }

    /// 证明该 binding contract 没有任何 direct execution / broker / OMS / live command 能力。
    public var forbidsExecutionAndLiveCommandPaths: Bool {
        allowsDirectExecutionClientPath == false
            && allowsBrokerCommandPath == false
            && allowsOMSCommandPath == false
            && allowsLiveCommandPath == false
    }
}

/// TraderStrategyBindingsBoundaryFixture 提供 MTP-195 deterministic boundary fixture。
///
/// Fixture 只服务本地测试和 PR evidence，固定 EMA 与 OrderBookImbalance 的 current concrete
/// strategy root，同时证明 `StrategyBindings` 只是 binding protocol / coordination adapter contract。
public enum TraderStrategyBindingsBoundaryFixture {
    public static let deterministic = TraderStrategyBindingsBoundaryEvidence(
        strategyBindingsRoot: "Sources/Trader/StrategyBindings/",
        concreteStrategyRoots: [
            "Sources/Trader/Strategies/EMA/",
            "Sources/Trader/Strategies/OrderBookImbalance/"
        ],
        contractRoles: [.genericBindingProtocol, .coordinationAdapterContract],
        compatibilityTargetName: "Core",
        carriesConcreteStrategyImplementation: false,
        allowsDirectExecutionClientPath: false,
        allowsBrokerCommandPath: false,
        allowsOMSCommandPath: false,
        allowsLiveCommandPath: false
    )
}

/// PaperActionProposalRiskPolicy 是 MTP-33 本地 deterministic 风险门槛。
///
/// 输入只包含 risk profile、最大 paper quantity 和阻断原因，用于测试 proposal 是否应该生成
/// `RiskBlockerEvidence`。它不读取账户余额、保证金、杠杆、broker position 或交易所风控规则。
public struct PaperActionProposalRiskPolicy: Codable, Equatable, Sendable {
    public let riskProfileID: Identifier
    public let maxPaperQuantity: Quantity
    public let blockerReason: RiskBlockerReason

    public init(
        riskProfileID: Identifier,
        maxPaperQuantity: Quantity,
        blockerReason: RiskBlockerReason = .maxPaperQuantityExceeded
    ) {
        self.riskProfileID = riskProfileID
        self.maxPaperQuantity = maxPaperQuantity
        self.blockerReason = blockerReason
    }

    /// deterministicAllowingFixture 只服务 XCTest 和 PR evidence，不代表真实风险阈值。
    public static let deterministicAllowingFixture: PaperActionProposalRiskPolicy = {
        do {
            return PaperActionProposalRiskPolicy(
                riskProfileID: try Identifier("paper-risk"),
                maxPaperQuantity: try Quantity(1, field: "paperActionRiskPolicy.maxPaperQuantity")
            )
        } catch {
            preconditionFailure("Invalid deterministic allowing risk policy fixture: \(error)")
        }
    }()

    /// deterministicBlockingFixture 用于固定 oversized proposal 被阻断的本地证据。
    public static let deterministicBlockingFixture: PaperActionProposalRiskPolicy = {
        do {
            return PaperActionProposalRiskPolicy(
                riskProfileID: try Identifier("paper-risk"),
                maxPaperQuantity: try Quantity(0.25, field: "paperActionRiskPolicy.maxPaperQuantity")
            )
        } catch {
            preconditionFailure("Invalid deterministic blocking risk policy fixture: \(error)")
        }
    }()

    /// 比较 proposal paper quantity 与本地上限，输出是否需要生成 blocker evidence。
    ///
    /// 这里只做 deterministic 数量门槛判断，不访问账户、仓位、margin 或 broker 风控服务。
    public func blocks(_ proposal: PaperActionProposal) -> Bool {
        proposal.quantity.rawValue > maxPaperQuantity.rawValue
    }
}

/// PaperActionProposalRiskDecisionStatus 表达本地 risk link 的结果。
///
/// allowed 只说明 proposal 在当前 deterministic policy 下没有生成 blocker；blocked 才携带
/// `RiskBlockerEvidence`。两个状态都保持 paper-only，不授权真实订单。
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

/// PaperActionProposalRiskLink 是 MTP-33 的最小本地编排函数，也是 MTP-195 允许的 coordination adapter。
///
/// 它把 proposal 转成 `RiskEvaluationQuery`，再根据 deterministic policy 决定是否生成
/// `RiskBlockerEvidence`。该函数没有网络、副作用、数据库写入或 broker fallback，也不承载具体
/// strategy lifecycle、signal、proposal implementation 或 strategy-specific business rule。
public enum PaperActionProposalRiskLink {
    public static func evaluate(
        decisionID: Identifier,
        proposal: PaperActionProposal,
        policy: PaperActionProposalRiskPolicy,
        sourceSequence: Int,
        evaluatedAt: Date
    ) throws -> PaperActionProposalRiskDecision {
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: proposal.proposalID,
            symbol: proposal.symbol,
            timeframe: proposal.timeframe,
            proposedQuantity: proposal.quantity,
            riskProfileID: policy.riskProfileID,
            executionMode: proposal.executionMode
        )
        let blockerEvidence: RiskBlockerEvidence? = policy.blocks(proposal)
            ? RiskBlockerEvidence(
                evidenceID: try Identifier("risk-blocker-\(proposal.proposalID.rawValue)"),
                query: riskQuery,
                reason: policy.blockerReason,
                generatedAt: evaluatedAt
            )
            : nil

        return try PaperActionProposalRiskDecision(
            decisionID: decisionID,
            proposal: proposal,
            riskQuery: riskQuery,
            sourceSequence: sourceSequence,
            status: blockerEvidence == nil ? .allowed : .blocked,
            blockerEvidence: blockerEvidence,
            evaluatedAt: evaluatedAt
        )
    }
}

/// PaperActionProposalRiskFixture 生成 MTP-33 的允许 / 阻断 deterministic evidence。
///
/// Fixture 只用于本地测试和 PR evidence，证明 proposal 与 risk blocker 可以追溯串联；
/// 它不代表真实风控配置、真实 broker 拒单、订单执行或 portfolio update。
public enum PaperActionProposalRiskFixture {
    public static func deterministicAllowed() throws -> PaperActionProposalRiskDecision {
        try PaperActionProposalRiskLink.evaluate(
            decisionID: try Identifier("paper-action-risk-allowed"),
            proposal: PaperActionProposalFixture.deterministicLong(),
            policy: .deterministicAllowingFixture,
            sourceSequence: 7,
            evaluatedAt: Date(timeIntervalSince1970: 1_800)
        )
    }

    public static func deterministicBlocked() throws -> PaperActionProposalRiskDecision {
        try PaperActionProposalRiskLink.evaluate(
            decisionID: try Identifier("paper-action-risk-blocked"),
            proposal: PaperActionProposalFixture.deterministicLong(),
            policy: .deterministicBlockingFixture,
            sourceSequence: 8,
            evaluatedAt: Date(timeIntervalSince1970: 1_860)
        )
    }
}
