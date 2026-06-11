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

/// ReleaseV020RiskStrategyKind 固定 #578 common RiskEngine 允许的策略种类。
///
/// RiskEngine 不依赖 TraderStrategies target，因此这里用本地 release enum 表达 allowlist。
/// 当前 release 只允许 EMA / RSI，未知策略必须在进入 CommandGateway / ExecutionEngine 前被阻断。
public enum ReleaseV020RiskStrategyKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema
    case rsi
}

/// ReleaseV020RiskEngineCommonGate 表达 #578 要覆盖的通用风控门。
public enum ReleaseV020RiskEngineCommonGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case strategyAllowlist
    case instrumentAllowlist
    case maxNotional
    case aggregateExposure
    case killSwitch
    case noTradeState
}

/// ReleaseV020RiskEngineCommonStatus 描述 common RiskEngine 对下一 gate 的输出。
public enum ReleaseV020RiskEngineCommonStatus: String, Codable, Equatable, Sendable {
    case forwardToCommandGateway
    case blocked
}

/// ReleaseV020RiskEngineCommonBlocker 描述 #578 common layer 的阻断原因。
public enum ReleaseV020RiskEngineCommonBlocker: String, Codable, Equatable, Hashable, Sendable {
    case arbitrationNotForwarded
    case strategyNotAllowed
    case instrumentNotAllowed
    case maxNotionalExceeded
    case aggregateExposureExceeded
    case killSwitchActive
    case noTradeStateActive
}

/// ReleaseV020RiskStrategyAllowlistEntry 保存 strategyID 与 release strategy kind 的显式 allowlist。
public struct ReleaseV020RiskStrategyAllowlistEntry: Codable, Equatable, Hashable, Sendable {
    public let strategyID: Identifier
    public let kind: ReleaseV020RiskStrategyKind

    public init(
        strategyID: Identifier,
        kind: ReleaseV020RiskStrategyKind
    ) {
        self.strategyID = strategyID
        self.kind = kind
    }
}

/// ReleaseV020RiskEngineCommonPolicy 是 #578 的本地 deterministic risk policy。
///
/// Policy 覆盖策略 allowlist、instrument allowlist、单笔 notional、aggregate exposure、
/// kill switch 和 no-trade。它只用于 release evidence，不读取 secret、不连接 broker、
/// 不调用 CommandGateway / ExecutionEngine / OMS，也不授权 production trading。
public struct ReleaseV020RiskEngineCommonPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let allowedStrategies: [ReleaseV020RiskStrategyAllowlistEntry]
    public let allowedInstruments: [InstrumentIdentity]
    public let maxNotional: Double
    public let maxAggregateExposure: Double
    public let killSwitchActive: Bool
    public let noTradeStateActive: Bool
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let bypassesCommandGateway: Bool
    public let touchesExecutionEngine: Bool
    public let touchesExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let submitsRealOrder: Bool

    public init(
        policyID: Identifier,
        allowedStrategies: [ReleaseV020RiskStrategyAllowlistEntry],
        allowedInstruments: [InstrumentIdentity],
        maxNotional: Double,
        maxAggregateExposure: Double,
        killSwitchActive: Bool = false,
        noTradeStateActive: Bool = false,
        validationAnchors: [String] = ReleaseV020RiskEngineCommonDecision.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        bypassesCommandGateway: Bool = false,
        touchesExecutionEngine: Bool = false,
        touchesExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard maxNotional.isFinite && maxNotional > 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.maxNotional",
                expected: "finite positive notional",
                actual: "\(maxNotional)"
            )
        }
        guard maxAggregateExposure.isFinite && maxAggregateExposure > 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.maxAggregateExposure",
                expected: "finite positive aggregate exposure",
                actual: "\(maxAggregateExposure)"
            )
        }
        guard Set(allowedStrategies.map(\.kind)) == Set(ReleaseV020RiskStrategyKind.allCases) else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.allowedStrategies",
                expected: "EMA and RSI allowlist entries",
                actual: allowedStrategies.map(\.kind.rawValue).joined(separator: ",")
            )
        }
        guard allowedInstruments.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.allowedInstruments",
                expected: "non-empty Binance Spot / USD-M Perp instruments",
                actual: "empty"
            )
        }
        if let forbiddenInstrument = allowedInstruments.first(where: {
            $0.venue.rawValue != "binance" || [.spot, .usdsPerpetual].contains($0.productType) == false
        }) {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.allowedInstruments",
                expected: "Binance Spot or USD-M Perp instrument",
                actual: forbiddenInstrument.rawValue
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(bypassesCommandGateway, "bypassesCommandGateway")
        try Self.forbid(touchesExecutionEngine, "touchesExecutionEngine")
        try Self.forbid(touchesExecutionClient, "touchesExecutionClient")
        try Self.forbid(touchesBrokerGateway, "touchesBrokerGateway")
        try Self.forbid(bypassesOMS, "bypassesOMS")
        try Self.forbid(bypassesEventStore, "bypassesEventStore")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")

        self.policyID = policyID
        self.allowedStrategies = allowedStrategies
        self.allowedInstruments = allowedInstruments
        self.maxNotional = maxNotional
        self.maxAggregateExposure = maxAggregateExposure
        self.killSwitchActive = killSwitchActive
        self.noTradeStateActive = noTradeStateActive
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.bypassesCommandGateway = bypassesCommandGateway
        self.touchesExecutionEngine = touchesExecutionEngine
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.bypassesOMS = bypassesOMS
        self.bypassesEventStore = bypassesEventStore
        self.submitsRealOrder = submitsRealOrder
    }

    public var boundaryHeld: Bool {
        validationAnchors == ReleaseV020RiskEngineCommonDecision.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && bypassesCommandGateway == false
            && touchesExecutionEngine == false
            && touchesExecutionClient == false
            && touchesBrokerGateway == false
            && bypassesOMS == false
            && bypassesEventStore == false
            && submitsRealOrder == false
    }

    public var allowedStrategyIDs: Set<Identifier> {
        Set(allowedStrategies.map(\.strategyID))
    }

    public var allowedInstrumentSet: Set<InstrumentIdentity> {
        Set(allowedInstruments)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability("releaseV020RiskEngineCommon.\(field)")
        }
    }
}

/// ReleaseV020RiskEngineCommonInput 是 #577 仲裁结果进入 #578 common RiskEngine 的输入。
public struct ReleaseV020RiskEngineCommonInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let arbitrationDecision: ProposalArbitrationDecision
    public let currentAggregateExposure: Double
    public let evaluatedAt: Date
    public let sourceSequence: Int
    public let riskGateBypassed: Bool
    public let productionTradingRequested: Bool

    public init(
        inputID: Identifier,
        arbitrationDecision: ProposalArbitrationDecision,
        currentAggregateExposure: Double,
        evaluatedAt: Date,
        sourceSequence: Int,
        riskGateBypassed: Bool = false,
        productionTradingRequested: Bool = false
    ) throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard currentAggregateExposure.isFinite && currentAggregateExposure >= 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.currentAggregateExposure",
                expected: "finite non-negative aggregate exposure",
                actual: "\(currentAggregateExposure)"
            )
        }
        guard riskGateBypassed == false else {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(
                "releaseV020RiskEngineCommon.input.riskGateBypassed"
            )
        }
        guard productionTradingRequested == false else {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(
                "releaseV020RiskEngineCommon.input.productionTradingRequested"
            )
        }

        self.inputID = inputID
        self.arbitrationDecision = arbitrationDecision
        self.currentAggregateExposure = currentAggregateExposure
        self.evaluatedAt = evaluatedAt
        self.sourceSequence = sourceSequence
        self.riskGateBypassed = riskGateBypassed
        self.productionTradingRequested = productionTradingRequested
    }

    public var inputBoundaryHeld: Bool {
        sourceSequence > 0
            && currentAggregateExposure.isFinite
            && currentAggregateExposure >= 0
            && riskGateBypassed == false
            && productionTradingRequested == false
            && arbitrationDecision.boundaryHeld
    }

    public var proposedNotional: Double? {
        guard let intent = arbitrationDecision.forwardedOrderIntent else {
            return nil
        }
        return intent.quantity.rawValue * intent.referencePrice.rawValue
    }
}

/// ReleaseV020RiskEngineCommonDecision 是 #578 common layer 的可审计输出。
///
/// `forwardToCommandGateway` 只表示通用风控门通过并可进入下一 gate；它不绕过
/// CommandGateway，不触碰 ExecutionEngine / OMS / ExecutionClient / broker，也不授权真实订单。
public struct ReleaseV020RiskEngineCommonDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let inputID: Identifier
    public let instrument: InstrumentIdentity?
    public let status: ReleaseV020RiskEngineCommonStatus
    public let blocker: ReleaseV020RiskEngineCommonBlocker?
    public let passedGates: [ReleaseV020RiskEngineCommonGate]
    public let proposedNotional: Double?
    public let projectedAggregateExposure: Double?
    public let forwardedOrderIntent: ProductAwareOrderIntent?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let bypassesCommandGateway: Bool
    public let touchesExecutionEngine: Bool
    public let touchesExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let bypassesEventStore: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeState: Bool
    public let submitsRealOrder: Bool

    public init(
        decisionID: Identifier,
        inputID: Identifier,
        instrument: InstrumentIdentity?,
        status: ReleaseV020RiskEngineCommonStatus,
        blocker: ReleaseV020RiskEngineCommonBlocker?,
        passedGates: [ReleaseV020RiskEngineCommonGate],
        proposedNotional: Double?,
        projectedAggregateExposure: Double?,
        forwardedOrderIntent: ProductAwareOrderIntent?,
        evaluatedAt: Date,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        bypassesCommandGateway: Bool = false,
        touchesExecutionEngine: Bool = false,
        touchesExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        bypassesEventStore: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeState: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        if status == .forwardToCommandGateway {
            guard blocker == nil else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "releaseV020RiskEngineCommon.blocker",
                    expected: "nil for forwardToCommandGateway",
                    actual: blocker?.rawValue ?? "nil"
                )
            }
            guard Set(passedGates) == Set(ReleaseV020RiskEngineCommonGate.allCases) else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "releaseV020RiskEngineCommon.passedGates",
                    expected: ReleaseV020RiskEngineCommonGate.allCases.map(\.rawValue).joined(separator: ","),
                    actual: passedGates.map(\.rawValue).joined(separator: ",")
                )
            }
            guard let forwardedOrderIntent, forwardedOrderIntent.isPreRiskGateIntent else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "releaseV020RiskEngineCommon.forwardedOrderIntent",
                    expected: "pre-risk order intent for next gate",
                    actual: "nil or execution-authorizing intent"
                )
            }
        }
        if status == .blocked, blocker == nil {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "releaseV020RiskEngineCommon.blocker",
                expected: "present for blocked",
                actual: "nil"
            )
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("bypassesCommandGateway", bypassesCommandGateway),
            ("touchesExecutionEngine", touchesExecutionEngine),
            ("touchesExecutionClient", touchesExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("bypassesOMS", bypassesOMS),
            ("bypassesEventStore", bypassesEventStore),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("bypassesNoTradeState", bypassesNoTradeState),
            ("submitsRealOrder", submitsRealOrder)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability("releaseV020RiskEngineCommon.\(forbidden.0)")
        }

        self.decisionID = decisionID
        self.inputID = inputID
        self.instrument = instrument
        self.status = status
        self.blocker = blocker
        self.passedGates = passedGates
        self.proposedNotional = proposedNotional
        self.projectedAggregateExposure = projectedAggregateExposure
        self.forwardedOrderIntent = forwardedOrderIntent
        self.evaluatedAt = evaluatedAt
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.bypassesCommandGateway = bypassesCommandGateway
        self.touchesExecutionEngine = touchesExecutionEngine
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.bypassesOMS = bypassesOMS
        self.bypassesEventStore = bypassesEventStore
        self.bypassesKillSwitch = bypassesKillSwitch
        self.bypassesNoTradeState = bypassesNoTradeState
        self.submitsRealOrder = submitsRealOrder
    }

    public var forwardsToCommandGateway: Bool {
        status == .forwardToCommandGateway
            && forwardedOrderIntent?.isPreRiskGateIntent == true
            && boundaryHeld
    }

    public var isBlocked: Bool {
        status == .blocked
    }

    public var boundaryHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && bypassesCommandGateway == false
            && touchesExecutionEngine == false
            && touchesExecutionClient == false
            && touchesBrokerGateway == false
            && bypassesOMS == false
            && bypassesEventStore == false
            && bypassesKillSwitch == false
            && bypassesNoTradeState == false
            && submitsRealOrder == false
    }

    public static let requiredValidationAnchors = [
        "GH-578-RISKENGINE-COMMON-LAYER",
        "GH-578-STRATEGY-INSTRUMENT-ALLOWLIST",
        "GH-578-NOTIONAL-AGGREGATE-EXPOSURE-GATE",
        "GH-578-KILL-SWITCH-NO-TRADE-GATE",
        "TVM-RELEASE-V020-RISKENGINE-COMMON-LAYER"
    ]
}

/// ReleaseV020RiskEngineCommonLayer 执行 #578 的通用风控门。
public enum ReleaseV020RiskEngineCommonLayer {
    public static func evaluate(
        decisionID: Identifier,
        input: ReleaseV020RiskEngineCommonInput,
        policy: ReleaseV020RiskEngineCommonPolicy
    ) throws -> ReleaseV020RiskEngineCommonDecision {
        guard input.inputBoundaryHeld, policy.boundaryHeld else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .arbitrationNotForwarded,
                passedGates: []
            )
        }
        guard input.arbitrationDecision.forwardsToRisk else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .arbitrationNotForwarded,
                passedGates: []
            )
        }
        guard policy.killSwitchActive == false else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .killSwitchActive,
                passedGates: [.strategyAllowlist, .instrumentAllowlist, .maxNotional, .aggregateExposure]
            )
        }
        guard policy.noTradeStateActive == false else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .noTradeStateActive,
                passedGates: [.strategyAllowlist, .instrumentAllowlist, .maxNotional, .aggregateExposure, .killSwitch]
            )
        }
        guard Set(input.arbitrationDecision.candidateStrategyIDs).isSubset(of: policy.allowedStrategyIDs) else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .strategyNotAllowed,
                passedGates: []
            )
        }
        guard let instrument = input.arbitrationDecision.instrument,
              policy.allowedInstrumentSet.contains(instrument) else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .instrumentNotAllowed,
                passedGates: [.strategyAllowlist]
            )
        }
        guard let proposedNotional = input.proposedNotional else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .arbitrationNotForwarded,
                passedGates: [.strategyAllowlist, .instrumentAllowlist]
            )
        }
        guard proposedNotional <= policy.maxNotional else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .maxNotionalExceeded,
                passedGates: [.strategyAllowlist, .instrumentAllowlist]
            )
        }

        let projectedAggregateExposure = input.currentAggregateExposure + proposedNotional
        guard projectedAggregateExposure <= policy.maxAggregateExposure else {
            return try blocked(
                decisionID: decisionID,
                input: input,
                policy: policy,
                blocker: .aggregateExposureExceeded,
                passedGates: [.strategyAllowlist, .instrumentAllowlist, .maxNotional]
            )
        }

        return try ReleaseV020RiskEngineCommonDecision(
            decisionID: decisionID,
            inputID: input.inputID,
            instrument: instrument,
            status: .forwardToCommandGateway,
            blocker: nil,
            passedGates: ReleaseV020RiskEngineCommonGate.allCases,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: projectedAggregateExposure,
            forwardedOrderIntent: input.arbitrationDecision.forwardedOrderIntent,
            evaluatedAt: input.evaluatedAt,
            validationAnchors: policy.validationAnchors
        )
    }

    private static func blocked(
        decisionID: Identifier,
        input: ReleaseV020RiskEngineCommonInput,
        policy: ReleaseV020RiskEngineCommonPolicy,
        blocker: ReleaseV020RiskEngineCommonBlocker,
        passedGates: [ReleaseV020RiskEngineCommonGate]
    ) throws -> ReleaseV020RiskEngineCommonDecision {
        let proposedNotional = input.proposedNotional
        return try ReleaseV020RiskEngineCommonDecision(
            decisionID: decisionID,
            inputID: input.inputID,
            instrument: input.arbitrationDecision.instrument,
            status: .blocked,
            blocker: blocker,
            passedGates: passedGates,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: proposedNotional.map { input.currentAggregateExposure + $0 },
            forwardedOrderIntent: nil,
            evaluatedAt: input.evaluatedAt,
            validationAnchors: policy.validationAnchors
        )
    }
}
