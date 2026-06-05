import DomainModel
import Foundation
import MessageBus

/// MTP-98 的 Paper Pre-trade RiskEngine runtime path 只处理本地 paper proposal。
///
/// 本文件把既有 `PaperActionProposal`、paper account snapshot、`PortfolioExposureSnapshot` 和
/// deterministic paper risk rules 组合成 accepted / rejected paper risk decision，并复用 MTP-97
/// `PaperRuntimeMessageBusRouting` 写入 append-only `MessageBus`。它不是 live risk engine，不读取真实
/// 账户、broker position、margin、leverage，也不实现 real pre-trade allow / reject、circuit breaker、
/// stop trading、emergency stop、live command UI 或交易按钮。

/// PaperPreTradeRiskDecisionOutcome 是 MTP-98 用户语义中的 accepted / rejected 决策结果。
///
/// 它只映射到既有 paper-only `PaperActionProposalRiskDecisionStatus`，其中 `accepted` 等同于本地
/// paper proposal 在 deterministic rules 下通过，`rejected` 等同于本地 paper blocker 生效。两者都
/// 不能升级为 future live risk decision 或真实 broker 拒单。
public enum PaperPreTradeRiskDecisionOutcome: String, Codable, Equatable, Sendable {
    case accepted
    case rejected

    public init(status: PaperActionProposalRiskDecisionStatus) {
        switch status {
        case .allowed:
            self = .accepted
        case .blocked:
            self = .rejected
        }
    }

    public var riskDecisionStatus: PaperActionProposalRiskDecisionStatus {
        switch self {
        case .accepted:
            .allowed
        case .rejected:
            .blocked
        }
    }
}

/// PaperPreTradeRiskAccountSnapshot 是 MTP-98 风控输入侧的本地 sandbox 账户快照。
///
/// 该快照只表达 paper session 内可用的本地模拟资金，不是 MTP-101 的完整 account projection v2，
/// 也不读取真实 account endpoint、broker position、margin 或 leverage。所有 live / broker flags
/// 必须保持 false，Codable 解码也不能绕过该边界。
public struct PaperPreTradeRiskAccountSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let sessionID: Identifier
    public let currency: String
    public let availablePaperBalance: Double
    public let sourceAnchor: String
    public let observedAt: Date
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool

    public var paperOnlyBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
    }

    public init(
        snapshotID: Identifier,
        sessionID: Identifier,
        currency: String = "USDT",
        availablePaperBalance: Double,
        sourceAnchor: String,
        observedAt: Date,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false
    ) throws {
        guard currency.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "currency",
                expected: "non-empty paper account currency",
                actual: "empty"
            )
        }
        guard availablePaperBalance.isFinite && availablePaperBalance >= 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "availablePaperBalance",
                expected: "finite non-negative paper balance",
                actual: "\(availablePaperBalance)"
            )
        }
        try Self.validateSourceAnchor(sourceAnchor)
        try Self.validateForbiddenCapabilities(
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            usesMargin: usesMargin,
            usesLeverage: usesLeverage
        )

        self.snapshotID = snapshotID
        self.sessionID = sessionID
        self.currency = currency
        self.availablePaperBalance = availablePaperBalance
        self.sourceAnchor = sourceAnchor
        self.observedAt = observedAt
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            snapshotID: try container.decode(Identifier.self, forKey: .snapshotID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            currency: try container.decode(String.self, forKey: .currency),
            availablePaperBalance: try container.decode(Double.self, forKey: .availablePaperBalance),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            observedAt: try container.decode(Date.self, forKey: .observedAt),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage)
        )
    }

    private static func validateSourceAnchor(_ sourceAnchor: String) throws {
        guard sourceAnchor.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
    }

    private static func validateForbiddenCapabilities(
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        usesMargin: Bool,
        usesLeverage: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(forbidden.0)
        }
    }
}

/// PaperPreTradeRiskRuleKind 固定 MTP-98 第一版 paper pre-trade rules。
///
/// 这些 rules 只检查本地 proposal quantity/notional、paper exposure 和 paper available balance。它们
/// 不包含真实账户 equity、broker position、margin、leverage、真实 PnL、熔断或禁交易状态。
public enum PaperPreTradeRiskRuleKind: String, Codable, CaseIterable, Equatable, Sendable {
    case maxPaperQuantity
    case maxPaperNotional
    case maxPaperGrossExposure
    case availablePaperBalance
}

/// PaperPreTradeRiskRule 是 Paper RiskEngine 的 deterministic rule 输入。
///
/// `limit` 的含义由 `kind` 决定：quantity/notional/exposure rule 使用最大允许值；available balance
/// rule 使用 proposal 后必须保留的最小 paper balance。`blockerReason` 仍使用 paper-only
/// `RiskBlockerReason`，不得写成 broker rejection 或 live risk decision。
public struct PaperPreTradeRiskRule: Codable, Equatable, Sendable {
    public let ruleID: Identifier
    public let kind: PaperPreTradeRiskRuleKind
    public let limit: Double
    public let blockerReason: RiskBlockerReason
    public let sourceAnchor: String

    public init(
        ruleID: Identifier,
        kind: PaperPreTradeRiskRuleKind,
        limit: Double,
        blockerReason: RiskBlockerReason,
        sourceAnchor: String
    ) throws {
        guard limit.isFinite && limit >= 0 else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "rule.limit",
                expected: "finite non-negative limit",
                actual: "\(limit)"
            )
        }
        guard sourceAnchor.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "rule.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        self.ruleID = ruleID
        self.kind = kind
        self.limit = limit
        self.blockerReason = blockerReason
        self.sourceAnchor = sourceAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            ruleID: try container.decode(Identifier.self, forKey: .ruleID),
            kind: try container.decode(PaperPreTradeRiskRuleKind.self, forKey: .kind),
            limit: try container.decode(Double.self, forKey: .limit),
            blockerReason: try container.decode(RiskBlockerReason.self, forKey: .blockerReason),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor)
        )
    }

    public func evaluate(
        proposal: PaperActionProposal,
        accountSnapshot: PaperPreTradeRiskAccountSnapshot,
        paperExposure: PortfolioExposureSnapshot
    ) throws -> PaperPreTradeRiskRuleEvaluation {
        let observedValue: Double
        let passed: Bool

        switch kind {
        case .maxPaperQuantity:
            observedValue = proposal.quantity.rawValue
            passed = observedValue <= limit
        case .maxPaperNotional:
            observedValue = proposal.notionalAmount
            passed = observedValue <= limit
        case .maxPaperGrossExposure:
            observedValue = paperExposure.grossExposureNotional + proposal.notionalAmount
            passed = observedValue <= limit
        case .availablePaperBalance:
            observedValue = accountSnapshot.availablePaperBalance
                - proposal.notionalAmount
                - proposal.costEstimate.totalCostAmount
            passed = observedValue >= limit
        }

        return PaperPreTradeRiskRuleEvaluation(
            ruleID: ruleID,
            kind: kind,
            observedValue: observedValue,
            limit: limit,
            passed: passed,
            blockerReason: blockerReason,
            sourceAnchor: sourceAnchor
        )
    }
}

/// PaperPreTradeRiskRuleEvaluation 是单条 paper risk rule 的 deterministic 评估证据。
///
/// 它只保存输入规则、观测值和 pass/fail 结果，供 MTP-98 decision 记录 first blocker reason 和
/// source anchor；它不读取 Runtime object、Persistence schema 或 broker state。
public struct PaperPreTradeRiskRuleEvaluation: Codable, Equatable, Sendable {
    public let ruleID: Identifier
    public let kind: PaperPreTradeRiskRuleKind
    public let observedValue: Double
    public let limit: Double
    public let passed: Bool
    public let blockerReason: RiskBlockerReason
    public let sourceAnchor: String

    public var rejected: Bool {
        passed == false
    }
}

/// PaperPreTradeRiskEngineInput 聚合 MTP-98 Paper RiskEngine 所需的全部 paper-only 输入。
///
/// `sourceProposalSequence` 指向 proposal 进入 append-only Event Log 的 sequence，`riskProfileID`
/// 仍是本地 paper risk profile。该输入显式包含 paper account snapshot 与 paper exposure，但不把它们
/// 升级为真实账户余额、broker position、margin、leverage 或 future live risk decision。
public struct PaperPreTradeRiskEngineInput: Codable, Equatable, Sendable {
    public let proposal: PaperActionProposal
    public let accountSnapshot: PaperPreTradeRiskAccountSnapshot
    public let paperExposure: PortfolioExposureSnapshot
    public let riskProfileID: Identifier
    public let riskRules: [PaperPreTradeRiskRule]
    public let sourceProposalSequence: Int
    public let evaluatedAt: Date
    public let sourceAnchors: [String]

    public init(
        proposal: PaperActionProposal,
        accountSnapshot: PaperPreTradeRiskAccountSnapshot,
        paperExposure: PortfolioExposureSnapshot,
        riskProfileID: Identifier,
        riskRules: [PaperPreTradeRiskRule],
        sourceProposalSequence: Int,
        evaluatedAt: Date,
        sourceAnchors: [String] = [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH"
        ]
    ) throws {
        guard proposal.executionMode == .paper else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "proposal.executionMode",
                expected: ExecutionMode.paper.rawValue,
                actual: proposal.executionMode.rawValue
            )
        }
        guard accountSnapshot.sessionID == proposal.sessionID else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "accountSnapshot.sessionID",
                expected: proposal.sessionID.rawValue,
                actual: accountSnapshot.sessionID.rawValue
            )
        }
        guard accountSnapshot.paperOnlyBoundaryHeld else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "accountSnapshot.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard paperExposure.source == .paperProjection else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "paperExposure.source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: paperExposure.source.rawValue
            )
        }
        guard paperExposure.symbol == proposal.symbol else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "paperExposure.symbol",
                expected: proposal.symbol.rawValue,
                actual: paperExposure.symbol.rawValue
            )
        }
        guard paperExposure.timeframe == proposal.timeframe else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "paperExposure.timeframe",
                expected: proposal.timeframe.rawValue,
                actual: paperExposure.timeframe.rawValue
            )
        }
        guard riskRules.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "riskRules",
                expected: "at least one deterministic paper risk rule",
                actual: "empty"
            )
        }
        guard sourceProposalSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceProposalSequence)
        }
        guard sourceAnchors.contains("MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH") else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "sourceAnchors",
                expected: "MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH",
                actual: sourceAnchors.joined(separator: ",")
            )
        }

        self.proposal = proposal
        self.accountSnapshot = accountSnapshot
        self.paperExposure = paperExposure
        self.riskProfileID = riskProfileID
        self.riskRules = riskRules
        self.sourceProposalSequence = sourceProposalSequence
        self.evaluatedAt = evaluatedAt
        self.sourceAnchors = sourceAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            proposal: try container.decode(PaperActionProposal.self, forKey: .proposal),
            accountSnapshot: try container.decode(PaperPreTradeRiskAccountSnapshot.self, forKey: .accountSnapshot),
            paperExposure: try container.decode(PortfolioExposureSnapshot.self, forKey: .paperExposure),
            riskProfileID: try container.decode(Identifier.self, forKey: .riskProfileID),
            riskRules: try container.decode([PaperPreTradeRiskRule].self, forKey: .riskRules),
            sourceProposalSequence: try container.decode(Int.self, forKey: .sourceProposalSequence),
            evaluatedAt: try container.decode(Date.self, forKey: .evaluatedAt),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors)
        )
    }
}

/// PaperPreTradeRiskEngineDecision 是 MTP-98 的 accepted / rejected runtime 输出。
///
/// 该类型持有底层 `PaperActionProposalRiskDecision`，因此可以直接交给 MTP-97 routing 写入 `.risk`
/// stream。额外的 rule evaluations、source anchors 和 forbidden flags 用来证明本 runtime path 仍是
/// paper sandbox 风险阻断，不是 future live risk decision、真实账户风控或 broker rejection。
public struct PaperPreTradeRiskEngineDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let issueID: Identifier
    public let input: PaperPreTradeRiskEngineInput
    public let outcome: PaperPreTradeRiskDecisionOutcome
    public let riskDecision: PaperActionProposalRiskDecision
    public let ruleEvaluations: [PaperPreTradeRiskRuleEvaluation]
    public let rejectedRule: PaperPreTradeRiskRuleEvaluation?
    public let validationAnchors: [String]
    public let providesLiveRiskEngine: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let usesMargin: Bool
    public let usesLeverage: Bool
    public let runsRealPreTradeAllowReject: Bool
    public let runsCircuitBreakerCommand: Bool
    public let runsStopTradingCommand: Bool
    public let runsEmergencyStop: Bool
    public let providesLiveCommandUI: Bool
    public let providesTradingButton: Bool
    public let mapsPaperRiskToFutureLiveRiskDecision: Bool

    public var isAccepted: Bool {
        outcome == .accepted
    }

    public var isRejected: Bool {
        outcome == .rejected
    }

    public var paperOnlyBoundaryHeld: Bool {
        providesLiveRiskEngine == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && usesMargin == false
            && usesLeverage == false
            && runsRealPreTradeAllowReject == false
            && runsCircuitBreakerCommand == false
            && runsStopTradingCommand == false
            && runsEmergencyStop == false
            && providesLiveCommandUI == false
            && providesTradingButton == false
            && mapsPaperRiskToFutureLiveRiskDecision == false
            && riskDecision.paperOnlyContextIsConsistent
    }

    public init(
        decisionID: Identifier,
        issueID: Identifier,
        input: PaperPreTradeRiskEngineInput,
        outcome: PaperPreTradeRiskDecisionOutcome,
        riskDecision: PaperActionProposalRiskDecision,
        ruleEvaluations: [PaperPreTradeRiskRuleEvaluation],
        rejectedRule: PaperPreTradeRiskRuleEvaluation?,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        providesLiveRiskEngine: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        usesMargin: Bool = false,
        usesLeverage: Bool = false,
        runsRealPreTradeAllowReject: Bool = false,
        runsCircuitBreakerCommand: Bool = false,
        runsStopTradingCommand: Bool = false,
        runsEmergencyStop: Bool = false,
        providesLiveCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        mapsPaperRiskToFutureLiveRiskDecision: Bool = false
    ) throws {
        try Self.validate(
            input: input,
            outcome: outcome,
            riskDecision: riskDecision,
            ruleEvaluations: ruleEvaluations,
            rejectedRule: rejectedRule,
            validationAnchors: validationAnchors,
            providesLiveRiskEngine: providesLiveRiskEngine,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            usesMargin: usesMargin,
            usesLeverage: usesLeverage,
            runsRealPreTradeAllowReject: runsRealPreTradeAllowReject,
            runsCircuitBreakerCommand: runsCircuitBreakerCommand,
            runsStopTradingCommand: runsStopTradingCommand,
            runsEmergencyStop: runsEmergencyStop,
            providesLiveCommandUI: providesLiveCommandUI,
            providesTradingButton: providesTradingButton,
            mapsPaperRiskToFutureLiveRiskDecision: mapsPaperRiskToFutureLiveRiskDecision
        )

        self.decisionID = decisionID
        self.issueID = issueID
        self.input = input
        self.outcome = outcome
        self.riskDecision = riskDecision
        self.ruleEvaluations = ruleEvaluations
        self.rejectedRule = rejectedRule
        self.validationAnchors = validationAnchors
        self.providesLiveRiskEngine = providesLiveRiskEngine
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.usesMargin = usesMargin
        self.usesLeverage = usesLeverage
        self.runsRealPreTradeAllowReject = runsRealPreTradeAllowReject
        self.runsCircuitBreakerCommand = runsCircuitBreakerCommand
        self.runsStopTradingCommand = runsStopTradingCommand
        self.runsEmergencyStop = runsEmergencyStop
        self.providesLiveCommandUI = providesLiveCommandUI
        self.providesTradingButton = providesTradingButton
        self.mapsPaperRiskToFutureLiveRiskDecision = mapsPaperRiskToFutureLiveRiskDecision
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decisionID: try container.decode(Identifier.self, forKey: .decisionID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            input: try container.decode(PaperPreTradeRiskEngineInput.self, forKey: .input),
            outcome: try container.decode(PaperPreTradeRiskDecisionOutcome.self, forKey: .outcome),
            riskDecision: try container.decode(PaperActionProposalRiskDecision.self, forKey: .riskDecision),
            ruleEvaluations: try container.decode(
                [PaperPreTradeRiskRuleEvaluation].self,
                forKey: .ruleEvaluations
            ),
            rejectedRule: try container.decodeIfPresent(
                PaperPreTradeRiskRuleEvaluation.self,
                forKey: .rejectedRule
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            providesLiveRiskEngine: try container.decode(Bool.self, forKey: .providesLiveRiskEngine),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            usesMargin: try container.decode(Bool.self, forKey: .usesMargin),
            usesLeverage: try container.decode(Bool.self, forKey: .usesLeverage),
            runsRealPreTradeAllowReject: try container.decode(Bool.self, forKey: .runsRealPreTradeAllowReject),
            runsCircuitBreakerCommand: try container.decode(Bool.self, forKey: .runsCircuitBreakerCommand),
            runsStopTradingCommand: try container.decode(Bool.self, forKey: .runsStopTradingCommand),
            runsEmergencyStop: try container.decode(Bool.self, forKey: .runsEmergencyStop),
            providesLiveCommandUI: try container.decode(Bool.self, forKey: .providesLiveCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            mapsPaperRiskToFutureLiveRiskDecision: try container.decode(
                Bool.self,
                forKey: .mapsPaperRiskToFutureLiveRiskDecision
            )
        )
    }

    public static let requiredValidationAnchors: [String] = [
        "TVM-PAPER-RUNTIME-KERNEL",
        "MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH",
        "MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION",
        "MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY",
        "MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE",
        "MTP-98-PAPER-RISKENGINE-VALIDATION"
    ]

    private static func validate(
        input: PaperPreTradeRiskEngineInput,
        outcome: PaperPreTradeRiskDecisionOutcome,
        riskDecision: PaperActionProposalRiskDecision,
        ruleEvaluations: [PaperPreTradeRiskRuleEvaluation],
        rejectedRule: PaperPreTradeRiskRuleEvaluation?,
        validationAnchors: [String],
        providesLiveRiskEngine: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        usesMargin: Bool,
        usesLeverage: Bool,
        runsRealPreTradeAllowReject: Bool,
        runsCircuitBreakerCommand: Bool,
        runsStopTradingCommand: Bool,
        runsEmergencyStop: Bool,
        providesLiveCommandUI: Bool,
        providesTradingButton: Bool,
        mapsPaperRiskToFutureLiveRiskDecision: Bool
    ) throws {
        guard validationAnchors == requiredValidationAnchors else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "validationAnchors",
                expected: requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard ruleEvaluations.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "ruleEvaluations",
                expected: "at least one rule evaluation",
                actual: "empty"
            )
        }
        guard ruleEvaluations.count == input.riskRules.count else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "ruleEvaluations.count",
                expected: "\(input.riskRules.count)",
                actual: "\(ruleEvaluations.count)"
            )
        }
        for (evaluation, rule) in zip(ruleEvaluations, input.riskRules) {
            guard evaluation.ruleID == rule.ruleID && evaluation.kind == rule.kind else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "ruleEvaluations",
                    expected: input.riskRules.map(\.ruleID.rawValue).joined(separator: ","),
                    actual: ruleEvaluations.map(\.ruleID.rawValue).joined(separator: ",")
                )
            }
        }
        guard outcome.riskDecisionStatus == riskDecision.status else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "outcome",
                expected: riskDecision.status.rawValue,
                actual: outcome.rawValue
            )
        }
        guard riskDecision.proposal == input.proposal else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "riskDecision.proposal",
                expected: input.proposal.proposalID.rawValue,
                actual: riskDecision.proposal.proposalID.rawValue
            )
        }
        guard riskDecision.sourceSequence == input.sourceProposalSequence else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "riskDecision.sourceSequence",
                expected: "\(input.sourceProposalSequence)",
                actual: "\(riskDecision.sourceSequence)"
            )
        }
        guard riskDecision.riskQuery.riskProfileID == input.riskProfileID else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "riskDecision.riskProfileID",
                expected: input.riskProfileID.rawValue,
                actual: riskDecision.riskQuery.riskProfileID.rawValue
            )
        }

        let firstRejectedRule = ruleEvaluations.first(where: \.rejected)
        switch (outcome, firstRejectedRule, rejectedRule, riskDecision.blockerEvidence) {
        case (.accepted, nil, nil, nil):
            break
        case let (.rejected, failed?, rejected?, blocker?):
            guard failed == rejected else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "rejectedRule",
                    expected: failed.ruleID.rawValue,
                    actual: rejected.ruleID.rawValue
                )
            }
            guard blocker.reason == rejected.blockerReason else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "blocker.reason",
                    expected: rejected.blockerReason.rawValue,
                    actual: blocker.reason.rawValue
                )
            }
        case (.accepted, _, _, _):
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "rejectedRule/blockerEvidence",
                expected: "nil for accepted decision",
                actual: "present"
            )
        case (.rejected, nil, _, _):
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "ruleEvaluations",
                expected: "at least one rejected rule for rejected decision",
                actual: "all passed"
            )
        case (.rejected, _, nil, _):
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "rejectedRule",
                expected: "present for rejected decision",
                actual: "nil"
            )
        case (.rejected, _, _, nil):
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "blockerEvidence",
                expected: "present for rejected decision",
                actual: "nil"
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("providesLiveRiskEngine", providesLiveRiskEngine),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("usesMargin", usesMargin),
            ("usesLeverage", usesLeverage),
            ("runsRealPreTradeAllowReject", runsRealPreTradeAllowReject),
            ("runsCircuitBreakerCommand", runsCircuitBreakerCommand),
            ("runsStopTradingCommand", runsStopTradingCommand),
            ("runsEmergencyStop", runsEmergencyStop),
            ("providesLiveCommandUI", providesLiveCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("mapsPaperRiskToFutureLiveRiskDecision", mapsPaperRiskToFutureLiveRiskDecision)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperPreTradeRiskEngineForbiddenCapability(forbidden.0)
        }
    }
}

#if !MTPRO_RISKENGINE_REAL_TARGET
/// PaperPreTradeRiskEnginePublication 保存 MTP-98 写入 Event Log 后的 replay evidence。
///
/// `routeEvidence` 来自 MTP-97 EventBus publish，`replayEvidence` 来自同一 `MessageBus` replay 后重建。
/// 二者必须一致，才能证明 rejected paper risk decision 已进入 append-only facts source 并可 replay。
public struct PaperPreTradeRiskEnginePublication: Codable, Equatable, Sendable {
    public let decision: PaperPreTradeRiskEngineDecision
    public let routeEvidence: [PaperRuntimeRouteEvidence]
    public let replayEvidence: [PaperRuntimeRouteEvidence]

    public var replayMatchesRouteEvidence: Bool {
        replayEvidence == routeEvidence
    }

    public var rejectedDecisionEnteredReplay: Bool {
        decision.isRejected
            && replayEvidence.contains { $0.payloadKind == .paperRiskBlocked && $0.stream == .risk }
    }

    public init(
        decision: PaperPreTradeRiskEngineDecision,
        routeEvidence: [PaperRuntimeRouteEvidence],
        replayEvidence: [PaperRuntimeRouteEvidence]
    ) throws {
        guard routeEvidence.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "routeEvidence",
                expected: "at least one paper risk route evidence",
                actual: "empty"
            )
        }
        guard replayEvidence == routeEvidence else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "replayEvidence",
                expected: "same as route evidence",
                actual: "drift"
            )
        }
        if decision.isRejected {
            guard replayEvidence.contains(where: { $0.payloadKind == .paperRiskBlocked && $0.stream == .risk }) else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "replayEvidence",
                    expected: "paperRiskBlocked evidence for rejected decision",
                    actual: replayEvidence.map(\.payloadKind.rawValue).joined(separator: ",")
                )
            }
        }

        self.decision = decision
        self.routeEvidence = routeEvidence
        self.replayEvidence = replayEvidence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decision: try container.decode(PaperPreTradeRiskEngineDecision.self, forKey: .decision),
            routeEvidence: try container.decode([PaperRuntimeRouteEvidence].self, forKey: .routeEvidence),
            replayEvidence: try container.decode([PaperRuntimeRouteEvidence].self, forKey: .replayEvidence)
        )
    }
}

/// PaperPreTradeRiskEngineRuntimePath 是 MTP-98 的本地 runtime path 编排入口。
///
/// `evaluate` 只做纯 Core 判定；`evaluateAndPublish` 额外复用 MTP-97 routing 写入 `MessageBus` 并
/// replay。该路径不启动 actor、不访问 Persistence schema、不读取 Adapter 或 broker，也不提供 UI command。
public struct PaperPreTradeRiskEngineRuntimePath: Equatable, Sendable {
    public let routing: PaperRuntimeMessageBusRouting

    public init(routing: PaperRuntimeMessageBusRouting = PaperRuntimeMessageBusRouting()) {
        self.routing = routing
    }

    public func evaluate(
        decisionID: Identifier,
        input: PaperPreTradeRiskEngineInput
    ) throws -> PaperPreTradeRiskEngineDecision {
        let evaluations = try input.riskRules.map {
            try $0.evaluate(
                proposal: input.proposal,
                accountSnapshot: input.accountSnapshot,
                paperExposure: input.paperExposure
            )
        }
        let rejectedRule = evaluations.first(where: \.rejected)
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: input.proposal.proposalID,
            symbol: input.proposal.symbol,
            timeframe: input.proposal.timeframe,
            proposedQuantity: input.proposal.quantity,
            riskProfileID: input.riskProfileID,
            executionMode: input.proposal.executionMode
        )
        let blockerEvidence = try rejectedRule.map {
            RiskBlockerEvidence(
                evidenceID: try Identifier("paper-pretrade-risk-blocker-\(input.proposal.proposalID.rawValue)"),
                query: riskQuery,
                reason: $0.blockerReason,
                generatedAt: input.evaluatedAt
            )
        }
        let status: PaperActionProposalRiskDecisionStatus = rejectedRule == nil ? .allowed : .blocked
        let riskDecision = try PaperActionProposalRiskDecision(
            decisionID: decisionID,
            proposal: input.proposal,
            riskQuery: riskQuery,
            sourceSequence: input.sourceProposalSequence,
            status: status,
            blockerEvidence: blockerEvidence,
            evaluatedAt: input.evaluatedAt
        )

        return try PaperPreTradeRiskEngineDecision(
            decisionID: decisionID,
            issueID: try Identifier("MTP-98"),
            input: input,
            outcome: PaperPreTradeRiskDecisionOutcome(status: status),
            riskDecision: riskDecision,
            ruleEvaluations: evaluations,
            rejectedRule: rejectedRule
        )
    }

    public func evaluateAndPublish(
        decisionID: Identifier,
        input: PaperPreTradeRiskEngineInput,
        to messageBus: inout MessageBus,
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> PaperPreTradeRiskEnginePublication {
        let decision = try evaluate(decisionID: decisionID, input: input)
        let firstNewSequence = messageBus.envelopes.count + 1
        let routeEvidence = try routing.publish(
            [.paperRiskDecision(decision.riskDecision)],
            to: &messageBus,
            clock: clock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: firstNewSequence, upperBound: messageBus.envelopes.count),
                streams: [.risk]
            )
        )
        let replayEvidence = try PaperRuntimeMessageBusRouting.replayEvidence(from: replay)
        return try PaperPreTradeRiskEnginePublication(
            decision: decision,
            routeEvidence: routeEvidence,
            replayEvidence: replayEvidence
        )
    }
}

/// PaperPreTradeRiskEngineFixture 提供 MTP-98 accepted / rejected deterministic tracer bullets。
///
/// Fixture 同时覆盖 account snapshot、paper exposure、risk rules、decision 和 Event Log / Replay
/// publication。它只服务 tests / PR evidence，不代表真实账户、真实风控配置或 production runtime。
public enum PaperPreTradeRiskEngineFixture {
    public static let correlationID = deterministicUUID("11111111-1111-4111-8111-111111111198")
    public static let rootCausationID = deterministicUUID("22222222-2222-4222-8222-222222222198")
    public static let acceptedEnvelopeIDs: [UUID] = [
        deterministicUUID("98000000-0000-4000-8000-000000000001")
    ]
    public static let rejectedEnvelopeIDs: [UUID] = [
        deterministicUUID("98000000-0000-4000-8000-000000000101"),
        deterministicUUID("98000000-0000-4000-8000-000000000102")
    ]

    public static let deterministicClock: TradingClock = {
        do {
            return try TradingClock(
                clockID: try Identifier("mtp-98-paper-pretrade-riskengine-clock"),
                issueID: try Identifier("MTP-98"),
                ticks: [
                    TradingClockTick(
                        sequence: 1,
                        instant: Date(timeIntervalSince1970: 4_000),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 4_001),
                        source: .deterministicFixture
                    )
                ],
                validationAnchors: [
                    "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
                    "MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY",
                    "MTP-98-PAPER-RISKENGINE-VALIDATION"
                ]
            )
        } catch {
            preconditionFailure("Invalid MTP-98 risk engine clock fixture: \(error)")
        }
    }()

    public static func acceptedInput() throws -> PaperPreTradeRiskEngineInput {
        try input(riskRules: acceptedRules(), sourceProposalSequence: 11, evaluatedAt: Date(timeIntervalSince1970: 4_010))
    }

    public static func rejectedInput() throws -> PaperPreTradeRiskEngineInput {
        try input(riskRules: rejectedRules(), sourceProposalSequence: 12, evaluatedAt: Date(timeIntervalSince1970: 4_020))
    }

    public static func acceptedDecision() throws -> PaperPreTradeRiskEngineDecision {
        try PaperPreTradeRiskEngineRuntimePath().evaluate(
            decisionID: try Identifier("mtp-98-paper-risk-accepted"),
            input: acceptedInput()
        )
    }

    public static func rejectedDecision() throws -> PaperPreTradeRiskEngineDecision {
        try PaperPreTradeRiskEngineRuntimePath().evaluate(
            decisionID: try Identifier("mtp-98-paper-risk-rejected"),
            input: rejectedInput()
        )
    }

    public static func publishedRejectedDecision() throws -> (MessageBus, PaperPreTradeRiskEnginePublication) {
        var messageBus = try MessageBus()
        let publication = try PaperPreTradeRiskEngineRuntimePath().evaluateAndPublish(
            decisionID: try Identifier("mtp-98-paper-risk-rejected"),
            input: rejectedInput(),
            to: &messageBus,
            clock: deterministicClock,
            envelopeIDs: rejectedEnvelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        return (messageBus, publication)
    }

    private static func input(
        riskRules: [PaperPreTradeRiskRule],
        sourceProposalSequence: Int,
        evaluatedAt: Date
    ) throws -> PaperPreTradeRiskEngineInput {
        let proposal = try PaperActionProposalFixture.deterministicLong()
        return try PaperPreTradeRiskEngineInput(
            proposal: proposal,
            accountSnapshot: accountSnapshot(sessionID: proposal.sessionID),
            paperExposure: paperExposure(proposal: proposal),
            riskProfileID: try Identifier("paper-risk"),
            riskRules: riskRules,
            sourceProposalSequence: sourceProposalSequence,
            evaluatedAt: evaluatedAt
        )
    }

    private static func accountSnapshot(sessionID: Identifier) throws -> PaperPreTradeRiskAccountSnapshot {
        try PaperPreTradeRiskAccountSnapshot(
            snapshotID: try Identifier("mtp-98-paper-account-snapshot"),
            sessionID: sessionID,
            availablePaperBalance: 10_000,
            sourceAnchor: "MTP-98-PAPER-ACCOUNT-SNAPSHOT-PAPER-ONLY",
            observedAt: Date(timeIntervalSince1970: 4_000)
        )
    }

    private static func paperExposure(proposal: PaperActionProposal) throws -> PortfolioExposureSnapshot {
        PortfolioExposureSnapshot(
            portfolioID: try Identifier("mtp-98-paper-portfolio"),
            symbol: proposal.symbol,
            timeframe: proposal.timeframe,
            paperQuantity: try Quantity(0.1, field: "mtp98.paperExposure.paperQuantity"),
            referencePrice: proposal.referencePrice,
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 4_000)
        )
    }

    private static func acceptedRules() throws -> [PaperPreTradeRiskRule] {
        try [
            rule(id: "mtp-98-rule-max-quantity", kind: .maxPaperQuantity, limit: 1),
            rule(id: "mtp-98-rule-max-notional", kind: .maxPaperNotional, limit: 1_000),
            rule(id: "mtp-98-rule-max-exposure", kind: .maxPaperGrossExposure, limit: 5_000),
            rule(id: "mtp-98-rule-available-balance", kind: .availablePaperBalance, limit: 0)
        ]
    }

    private static func rejectedRules() throws -> [PaperPreTradeRiskRule] {
        try [
            rule(id: "mtp-98-rule-max-quantity", kind: .maxPaperQuantity, limit: 0.25),
            rule(id: "mtp-98-rule-max-notional", kind: .maxPaperNotional, limit: 1_000),
            rule(id: "mtp-98-rule-max-exposure", kind: .maxPaperGrossExposure, limit: 5_000),
            rule(id: "mtp-98-rule-available-balance", kind: .availablePaperBalance, limit: 0)
        ]
    }

    private static func rule(
        id: String,
        kind: PaperPreTradeRiskRuleKind,
        limit: Double
    ) throws -> PaperPreTradeRiskRule {
        try PaperPreTradeRiskRule(
            ruleID: try Identifier(id),
            kind: kind,
            limit: limit,
            blockerReason: .maxPaperQuantityExceeded,
            sourceAnchor: "MTP-98-PAPER-RISK-RULE-\(kind.rawValue)"
        )
    }

    private static func deterministicUUID(_ rawValue: String) -> UUID {
        guard let uuid = UUID(uuidString: rawValue) else {
            preconditionFailure("Invalid deterministic UUID: \(rawValue)")
        }
        return uuid
    }
}
#endif
