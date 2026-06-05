import DomainModel
import Foundation
import MessageBus

/// MTP-202 将 proposal-to-risk binding 从旧 `Sources/Trader/StrategyBindings/`
/// 迁入 `Sources/Trader/Coordination/RiskBinding/`。
/// Trader Coordination 在这里仍只是 strategy / risk / portfolio coordination evidence，
/// 不是 live coordinator、ExecutionClient gateway 或 broker gateway。
/// Paper action risk link 把 MTP-32 的 paper-only proposal 接到本地风险观察证据。
///
/// 该文件只定义 strategy signal -> paper action proposal -> risk blocker 的最小本地链路。
/// 它不是 EMA、OrderBookImbalance 或未来具体策略的 implementation landing path；当前 active 具体策略必须继续位于
/// `Sources/Trader/Strategies/<strategy>/`。
/// 它不是完整风险引擎、订单管理系统、broker 拒单回退或真实交易执行入口，也不会调用
/// Binance signed endpoint、account endpoint、order submit / cancel / replace 或 Live execution。

/// TraderCoordinationRiskBindingContractRole 固定 `Sources/Trader/Coordination/RiskBinding/` 的允许职责。
///
/// MTP-202 只允许该目录表达 generic binding protocol / coordination adapter contract。任何具体策略
/// lifecycle、signal、proposal、quoter、hedger 或 strategy-specific business rule 都必须放在
/// `Sources/Trader/Strategies/<strategy>/`，不能放入 Trader Coordination RiskBinding。
public enum TraderCoordinationRiskBindingContractRole: String, Codable, Equatable, Sendable {
    case genericBindingProtocol = "generic_binding_protocol"
    case coordinationAdapterContract = "coordination_adapter_contract"
}

/// TraderCoordinationRiskBindingBoundaryEvidence 是 MTP-202 的本地边界证据。
///
/// 该 evidence 只描述目录职责和禁止能力，用于 XCTest 与 automation readiness 机械检查。
/// 它不创建 Trader runtime、strategy scheduler、ExecutionClient path、broker command、OMS command
/// 或 Live command，也不改变现有 `PaperActionProposalRiskLink` 的 deterministic paper-only 行为。
public struct TraderCoordinationRiskBindingBoundaryEvidence: Codable, Equatable, Sendable {
    public let coordinationRiskBindingRoot: String
    public let concreteStrategyRoots: [String]
    public let contractRoles: [TraderCoordinationRiskBindingContractRole]
    public let compatibilityTargetName: String
    public let carriesConcreteStrategyImplementation: Bool
    public let allowsDirectExecutionClientPath: Bool
    public let allowsBrokerCommandPath: Bool
    public let allowsOMSCommandPath: Bool
    public let allowsLiveCommandPath: Bool

    public init(
        coordinationRiskBindingRoot: String,
        concreteStrategyRoots: [String],
        contractRoles: [TraderCoordinationRiskBindingContractRole],
        compatibilityTargetName: String,
        carriesConcreteStrategyImplementation: Bool,
        allowsDirectExecutionClientPath: Bool,
        allowsBrokerCommandPath: Bool,
        allowsOMSCommandPath: Bool,
        allowsLiveCommandPath: Bool
    ) {
        self.coordinationRiskBindingRoot = coordinationRiskBindingRoot
        self.concreteStrategyRoots = concreteStrategyRoots
        self.contractRoles = contractRoles
        self.compatibilityTargetName = compatibilityTargetName
        self.carriesConcreteStrategyImplementation = carriesConcreteStrategyImplementation
        self.allowsDirectExecutionClientPath = allowsDirectExecutionClientPath
        self.allowsBrokerCommandPath = allowsBrokerCommandPath
        self.allowsOMSCommandPath = allowsOMSCommandPath
        self.allowsLiveCommandPath = allowsLiveCommandPath
    }

    /// 证明 Trader Coordination RiskBinding 只保留通用 binding / adapter contract，不持有具体策略实现。
    public var isGenericBindingProtocolAndAdapterOnly: Bool {
        contractRoles == [.genericBindingProtocol, .coordinationAdapterContract]
            && carriesConcreteStrategyImplementation == false
    }

    /// 证明当前 active 具体策略 root 仍在 Trader-owned Strategies 下，而不是 RiskBinding 或旧 peer-level path。
    public var concreteStrategiesRemainTraderOwned: Bool {
        concreteStrategyRoots.allSatisfy { root in
            root.hasPrefix("Sources/Trader/Strategies/")
                && root.contains("/Coordination/RiskBinding/") == false
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

/// TraderCoordinationRiskBindingBoundaryFixture 提供 MTP-202 deterministic boundary fixture。
///
/// Fixture 只服务本地测试和 PR evidence，固定 EMA 是唯一 current active concrete strategy root，
/// 同时证明 `Trader/Coordination/RiskBinding` 只是 binding protocol / coordination adapter contract。
public enum TraderCoordinationRiskBindingBoundaryFixture {
    public static let deterministic = TraderCoordinationRiskBindingBoundaryEvidence(
        coordinationRiskBindingRoot: "Sources/Trader/Coordination/RiskBinding/",
        concreteStrategyRoots: [
            "Sources/Trader/Strategies/EMA/"
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

/// PaperActionProposalRiskLink 是 MTP-33 的最小本地编排函数，也是 MTP-202 允许的 coordination adapter。
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
