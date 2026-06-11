import Cache
import DomainModel
import Foundation
import MessageBus

/// GH-398 的 RiskEngine 真实 target 所有权锚点。
///
/// 该类型只验证 RiskEngine 能在不依赖 `Core`、`ExecutionEngine`、`ExecutionClient`
/// 或 broker gateway 的情况下消费 strategy proposal、portfolio exposure 和 paper risk policy。
/// 旧的 MessageBus publish / replay runtime 面仍留在 `Core` 兼容壳，等待后续 Core envelope
/// retirement；这里不实现 Trader runtime、Strategy runtime、Live runtime、OMS 或真实订单能力。
public struct RiskEnginePreTradeOwnershipDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let proposalID: Identifier
    public let riskProfileID: Identifier
    public let sourceSequence: Int
    public let status: PaperActionProposalRiskDecisionStatus
    public let blockerReason: RiskBlockerReason?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let touchesExecutionEngine: Bool
    public let touchesExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let authorizesLiveTrading: Bool

    public var isAllowed: Bool {
        status == .allowed
    }

    public var isBlocked: Bool {
        status == .blocked
    }

    public var boundaryHeld: Bool {
        touchesExecutionEngine == false
            && touchesExecutionClient == false
            && touchesBrokerGateway == false
            && authorizesLiveTrading == false
            && validationAnchors.contains("GH-398-RISKENGINE-REAL-TARGET-OWNERSHIP")
    }

    public init(
        decisionID: Identifier,
        proposalID: Identifier,
        riskProfileID: Identifier,
        sourceSequence: Int,
        status: PaperActionProposalRiskDecisionStatus,
        blockerReason: RiskBlockerReason?,
        evaluatedAt: Date,
        validationAnchors: [String] = ["GH-398-RISKENGINE-REAL-TARGET-OWNERSHIP"],
        touchesExecutionEngine: Bool = false,
        touchesExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        authorizesLiveTrading: Bool = false
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        if status == .allowed, blockerReason != nil {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "blockerReason",
                expected: "nil for allowed decision",
                actual: blockerReason?.rawValue ?? "nil"
            )
        }
        if status == .blocked, blockerReason == nil {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "blockerReason",
                expected: "present for blocked decision",
                actual: "nil"
            )
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("touchesExecutionEngine", touchesExecutionEngine),
            ("touchesExecutionClient", touchesExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("authorizesLiveTrading", authorizesLiveTrading)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(forbidden.0)
        }

        self.decisionID = decisionID
        self.proposalID = proposalID
        self.riskProfileID = riskProfileID
        self.sourceSequence = sourceSequence
        self.status = status
        self.blockerReason = blockerReason
        self.evaluatedAt = evaluatedAt
        self.validationAnchors = validationAnchors
        self.touchesExecutionEngine = touchesExecutionEngine
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.authorizesLiveTrading = authorizesLiveTrading
    }
}

/// GH-398 的纯 RiskEngine pre-trade evaluator。
///
/// 输入来自 MessageBus 的 neutral proposal / risk / portfolio contracts；输出仍是本地
/// read-model-only / paper-only decision evidence。它不发布 MessageBus event，不驱动
/// ExecutionEngine，也不把 blocked / allowed 结果升级成真实下单许可。
public enum RiskEnginePreTradeOwnershipEvaluator {
    public static func evaluate(
        decisionID: Identifier,
        proposal: PaperActionProposal,
        portfolioExposure: PortfolioExposureSnapshot,
        riskProfileID: Identifier,
        maxPaperNotional: Double,
        sourceSequence: Int,
        evaluatedAt: Date
    ) throws -> RiskEnginePreTradeOwnershipDecision {
        guard portfolioExposure.source == .paperProjection else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "portfolioExposure.source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: portfolioExposure.source.rawValue
            )
        }
        guard maxPaperNotional.isFinite && maxPaperNotional >= 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "maxPaperNotional",
                expected: "finite non-negative paper notional",
                actual: "\(maxPaperNotional)"
            )
        }

        let projectedNotional = portfolioExposure.grossExposureNotional + proposal.notionalAmount
        let isAllowed = projectedNotional <= maxPaperNotional
        return try RiskEnginePreTradeOwnershipDecision(
            decisionID: decisionID,
            proposalID: proposal.proposalID,
            riskProfileID: riskProfileID,
            sourceSequence: sourceSequence,
            status: isAllowed ? .allowed : .blocked,
            blockerReason: isAllowed ? nil : .maxPaperNotionalExceeded,
            evaluatedAt: evaluatedAt
        )
    }
}

/// PerpetualFundingRiskReadModel 是 GH-575 的 Perp funding 风控读模型输入。
///
/// 它只消费 `Cache.PerpetualFundingRateReadModel` 的 public market evidence，用于后续
/// RiskEngine gate 判断 funding input 是否 fresh。它不读取账户保证金、不执行 leverage /
/// margin action、不连接 ExecutionEngine / ExecutionClient / broker，也不授权真实交易。
public struct PerpetualFundingRiskReadModel: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let fundingRate: Double
    public let nextFundingTime: Date
    public let freshness: PerpetualMarketDataFreshnessEvidence
    public let sourceAnchor: String
    public let touchesExecutionEngine: Bool
    public let touchesExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let authorizesLiveTrading: Bool
    public let validationAnchors: [String]

    public init(
        fundingReadModel: PerpetualFundingRateReadModel,
        sourceAnchor: String = "GH-575-PERP-FUNDING-RISK-READ-MODEL",
        touchesExecutionEngine: Bool = false,
        touchesExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        authorizesLiveTrading: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceAnchor.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "sourceAnchor",
                expected: "non-empty GH-575 source anchor",
                actual: "empty"
            )
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("touchesExecutionEngine", touchesExecutionEngine),
            ("touchesExecutionClient", touchesExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("authorizesLiveTrading", authorizesLiveTrading)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(forbidden.0)
        }

        self.instrument = fundingReadModel.instrument
        self.fundingRate = fundingReadModel.fundingRate
        self.nextFundingTime = fundingReadModel.nextFundingTime
        self.freshness = fundingReadModel.freshness
        self.sourceAnchor = sourceAnchor
        self.touchesExecutionEngine = touchesExecutionEngine
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.authorizesLiveTrading = authorizesLiveTrading
        self.validationAnchors = validationAnchors
    }

    public var riskReadModelReady: Bool {
        freshness.status == .fresh
            && boundaryHeld
    }

    public var staleFundingEvidenceSupported: Bool {
        freshness.status == .stale
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        instrument.productType == .usdsPerpetual
            && sourceAnchor == "GH-575-PERP-FUNDING-RISK-READ-MODEL"
            && touchesExecutionEngine == false
            && touchesExecutionClient == false
            && touchesBrokerGateway == false
            && authorizesLiveTrading == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-575-PERP-MARK-FUNDING-OI-READ-MODEL",
        "GH-575-PERP-FUNDING-RISK-READ-MODEL",
        "GH-575-STALE-MARK-FUNDING-EVIDENCE",
        "TVM-RELEASE-V020-PERP-MARK-FUNDING-OI-READ-MODEL"
    ]
}
