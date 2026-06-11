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

/// ProposalArbitrationStatus 描述 EMA / RSI proposal 仲裁结果。
public enum ProposalArbitrationStatus: String, Codable, Equatable, Sendable {
    case forwardToRisk
    case blocked
}

/// ProposalArbitrationBlocker 描述 GH-577 默认阻断原因。
public enum ProposalArbitrationBlocker: String, Codable, Equatable, Sendable {
    case emptyCandidates
    case instrumentMismatch
    case conflictBlockedByDefault
    case spotShortBlocked
    case perpetualShortGateClosed
    case missingPreRiskOrderIntent
}

/// StrategyProposalArbitrationCandidate 是 ProposalArbitrator 的中性输入。
///
/// 正常路径可从 `StrategyIntentMessage` 构造；测试和防御路径也允许直接构造 candidate，
/// 以便 RiskEngine 在 spot short 这类非法组合到达时阻断，而不是依赖上游一定提前拒绝。
public struct StrategyProposalArbitrationCandidate: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let productAwareOrderIntent: ProductAwareOrderIntent?
    public let emittedAt: Date
    public let sourceSequence: Int

    public init(
        strategyID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        productAwareOrderIntent: ProductAwareOrderIntent?,
        emittedAt: Date,
        sourceSequence: Int
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        self.strategyID = strategyID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.productAwareOrderIntent = productAwareOrderIntent
        self.emittedAt = emittedAt
        self.sourceSequence = sourceSequence
    }

    public init(
        message: StrategyIntentMessage,
        sourceSequence: Int
    ) throws {
        try self.init(
            strategyID: message.strategyID,
            instrument: message.instrument,
            targetExposure: message.targetExposure,
            productAwareOrderIntent: message.productAwareOrderIntent,
            emittedAt: message.emittedAt,
            sourceSequence: sourceSequence
        )
    }
}

/// ProposalArbitrationDecision 是 GH-577 EMA / RSI proposal 仲裁输出。
///
/// Decision 只说明是否可把一致 proposal 交给后续 RiskEngine；它不调用 RiskEngine runtime，
/// 不连接 ExecutionEngine / OMS / ExecutionClient / broker，也不授权 production trading。
public struct ProposalArbitrationDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let instrument: InstrumentIdentity?
    public let targetExposure: TargetExposureIntent?
    public let candidateStrategyIDs: [Identifier]
    public let sourceSequences: [Int]
    public let status: ProposalArbitrationStatus
    public let blocker: ProposalArbitrationBlocker?
    public let forwardedOrderIntent: ProductAwareOrderIntent?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let touchesExecutionEngine: Bool
    public let touchesExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let authorizesLiveTrading: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        decisionID: Identifier,
        instrument: InstrumentIdentity?,
        targetExposure: TargetExposureIntent?,
        candidateStrategyIDs: [Identifier],
        sourceSequences: [Int],
        status: ProposalArbitrationStatus,
        blocker: ProposalArbitrationBlocker?,
        forwardedOrderIntent: ProductAwareOrderIntent?,
        evaluatedAt: Date,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        touchesExecutionEngine: Bool = false,
        touchesExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        authorizesLiveTrading: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        if status == .forwardToRisk, blocker != nil {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "proposalArbitration.blocker",
                expected: "nil for forwardToRisk",
                actual: blocker?.rawValue ?? "nil"
            )
        }
        if status == .blocked, blocker == nil {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "proposalArbitration.blocker",
                expected: "present for blocked",
                actual: "nil"
            )
        }
        if status == .forwardToRisk {
            guard let forwardedOrderIntent, forwardedOrderIntent.isPreRiskGateIntent else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "proposalArbitration.forwardedOrderIntent",
                    expected: "pre-risk order intent",
                    actual: "nil or execution-authorizing intent"
                )
            }
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("touchesExecutionEngine", touchesExecutionEngine),
            ("touchesExecutionClient", touchesExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(forbidden.0)
        }

        self.decisionID = decisionID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.candidateStrategyIDs = candidateStrategyIDs
        self.sourceSequences = sourceSequences
        self.status = status
        self.blocker = blocker
        self.forwardedOrderIntent = forwardedOrderIntent
        self.evaluatedAt = evaluatedAt
        self.validationAnchors = validationAnchors
        self.touchesExecutionEngine = touchesExecutionEngine
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.authorizesLiveTrading = authorizesLiveTrading
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    public var forwardsToRisk: Bool {
        status == .forwardToRisk
            && forwardedOrderIntent?.isPreRiskGateIntent == true
            && boundaryHeld
    }

    public var isBlocked: Bool {
        status == .blocked
    }

    public var boundaryHeld: Bool {
        touchesExecutionEngine == false
            && touchesExecutionClient == false
            && touchesBrokerGateway == false
            && authorizesLiveTrading == false
            && productionTradingEnabledByDefault == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-577-PROPOSAL-ARBITRATOR-EMA-RSI",
        "GH-577-CONFLICT-BLOCKED-BY-DEFAULT",
        "GH-577-SPOT-SHORT-BLOCKED",
        "GH-577-PERP-SHORT-FORWARDED-TO-RISK",
        "TVM-RELEASE-V020-PROPOSAL-ARBITRATOR"
    ]
}

/// ProposalArbitrator 对 EMA / RSI product-aware proposal 做进入 RiskEngine 前的仲裁。
///
/// 它只输出 `forwardToRisk` / `blocked` evidence；所有真实风控、命令网关、执行引擎、
/// OMS、ExecutionClient、broker 和 production trading 授权仍必须由后续 gate 单独处理。
public enum ProposalArbitrator {
    public static func arbitrate(
        decisionID: Identifier,
        candidates: [StrategyProposalArbitrationCandidate],
        evaluatedAt: Date,
        allowPerpetualShort: Bool = true
    ) throws -> ProposalArbitrationDecision {
        guard candidates.isEmpty == false else {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .emptyCandidates,
                evaluatedAt: evaluatedAt
            )
        }

        let instrument = candidates[0].instrument
        guard candidates.allSatisfy({ $0.instrument == instrument }) else {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .instrumentMismatch,
                evaluatedAt: evaluatedAt
            )
        }

        if candidates.contains(where: { $0.targetExposure == .targetShort && $0.instrument.productType == .spot }) {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .spotShortBlocked,
                evaluatedAt: evaluatedAt
            )
        }

        if candidates.contains(where: { $0.targetExposure == .targetShort })
            && instrument.productType == .usdsPerpetual
            && allowPerpetualShort == false {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .perpetualShortGateClosed,
                evaluatedAt: evaluatedAt
            )
        }

        let targetExposures = Set(candidates.map(\.targetExposure))
        guard targetExposures.count == 1, let targetExposure = targetExposures.first else {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .conflictBlockedByDefault,
                evaluatedAt: evaluatedAt
            )
        }

        guard let forwardedOrderIntent = candidates.compactMap(\.productAwareOrderIntent).first,
              forwardedOrderIntent.instrument == instrument,
              forwardedOrderIntent.targetExposure == targetExposure,
              forwardedOrderIntent.isPreRiskGateIntent else {
            return try blocked(
                decisionID: decisionID,
                candidates: candidates,
                blocker: .missingPreRiskOrderIntent,
                evaluatedAt: evaluatedAt
            )
        }

        return try ProposalArbitrationDecision(
            decisionID: decisionID,
            instrument: instrument,
            targetExposure: targetExposure,
            candidateStrategyIDs: candidates.map(\.strategyID),
            sourceSequences: candidates.map(\.sourceSequence),
            status: .forwardToRisk,
            blocker: nil,
            forwardedOrderIntent: forwardedOrderIntent,
            evaluatedAt: evaluatedAt
        )
    }

    private static func blocked(
        decisionID: Identifier,
        candidates: [StrategyProposalArbitrationCandidate],
        blocker: ProposalArbitrationBlocker,
        evaluatedAt: Date
    ) throws -> ProposalArbitrationDecision {
        try ProposalArbitrationDecision(
            decisionID: decisionID,
            instrument: candidates.first?.instrument,
            targetExposure: nil,
            candidateStrategyIDs: candidates.map(\.strategyID),
            sourceSequences: candidates.map(\.sourceSequence),
            status: .blocked,
            blocker: blocker,
            forwardedOrderIntent: nil,
            evaluatedAt: evaluatedAt
        )
    }
}
