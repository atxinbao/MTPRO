import DomainModel
import Foundation
import MessageBus

/// GH-529 将 release v0.1.0 的 RiskEngine pre-trade gate 固定为 proposal -> risk decision evidence。
///
/// Gate 只消费 #528 生成的 neutral `PaperActionProposal` / `RiskEvaluationQuery`，输出 approve /
/// reject / blocked 证据。它不调用 ExecutionClient、不提交订单、不连接 broker 或 OMS、不读取
/// production secret，也不授权 production trading。
/// `GH-529-RISKENGINE-LIVE-PRETRADE-GATE`
/// `TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE`
public struct ReleaseV010RiskPreTradeGateRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let limits: ReleaseV010RiskPreTradeLimits
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let submitsRealOrder: Bool
    public let exposesLiveCommandSurface: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        runtimeID: Identifier,
        releaseVenue: String = Self.requiredReleaseVenue,
        activeConcreteStrategy: String = Self.requiredActiveConcreteStrategy,
        limits: ReleaseV010RiskPreTradeLimits = .deterministicFixture,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        submitsRealOrder: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.runtimeID = runtimeID
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.limits = limits
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.bypassesOMS = bypassesOMS
        self.submitsRealOrder = submitsRealOrder
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    /// 对单个 EMA proposal 运行 pre-trade gate，并输出可审计 decision evidence。
    ///
    /// `approved` 只表示 RiskEngine 本地 gate 通过，不表示 ExecutionEngine / OMS / broker 已获授权。
    public func evaluate(_ input: ReleaseV010RiskPreTradeInput) throws -> ReleaseV010RiskPreTradeDecisionEvidence {
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "input",
                expected: "GH-529 risk input boundary held",
                actual: "mismatch"
            )
        }

        let outcome: ReleaseV010RiskPreTradeDecisionOutcome
        let reasons: [ReleaseV010RiskPreTradeRejectReason]
        if input.noTradeGuardActive {
            outcome = .blocked
            reasons = [.noTradeGuardActive]
        } else if input.proposal.quantity.rawValue > limits.maxProposalQuantity.rawValue {
            outcome = .rejected
            reasons = [.quantityLimitExceeded]
        } else if input.proposal.notionalAmount > limits.maxProposalNotional {
            outcome = .rejected
            reasons = [.notionalLimitExceeded]
        } else if input.availableBalance < input.proposal.notionalAmount {
            outcome = .rejected
            reasons = [.availableBalanceExceeded]
        } else {
            outcome = .approved
            reasons = [.none]
        }

        return try ReleaseV010RiskPreTradeDecisionEvidence(
            decisionID: Identifier("\(runtimeID.rawValue)-\(outcome.rawValue)-\(input.sourceSequence)"),
            input: input,
            outcome: outcome,
            rejectReasons: reasons,
            validationAnchors: validationAnchors,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            bypassesOMS: bypassesOMS,
            submitsRealOrder: submitsRealOrder,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            nonEMAStrategyEnabled: nonEMAStrategyEnabled
        )
    }

    /// 生成 approve / reject / blocked 三类 deterministic evidence，证明所有 proposal 都先经过 RiskEngine。
    public func deterministicEvidence(
        approvedInput: ReleaseV010RiskPreTradeInput
    ) throws -> ReleaseV010RiskPreTradeGateEvidence {
        let approved = try evaluate(approvedInput)
        let rejected = try evaluate(try approvedInput.replacing(
            sourceSequence: approvedInput.sourceSequence + 1,
            availableBalance: 1
        ))
        let blocked = try evaluate(try approvedInput.replacing(
            sourceSequence: approvedInput.sourceSequence + 2,
            noTradeGuardActive: true
        ))
        return try ReleaseV010RiskPreTradeGateEvidence(
            evidenceID: Identifier("\(runtimeID.rawValue)-evidence"),
            decisions: [approved, rejected, blocked],
            validationAnchors: validationAnchors
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010RiskPreTradeGateRuntime {
        try ReleaseV010RiskPreTradeGateRuntime(
            runtimeID: Identifier("gh-529-riskengine-pretrade-gate")
        )
    }

    public static let requiredReleaseVenue = "Binance"
    public static let requiredActiveConcreteStrategy = "EMA"
    public static let requiredValidationAnchors = [
        "GH-529-RISKENGINE-LIVE-PRETRADE-GATE",
        "GH-529-EMA-PROPOSAL-RISK-DECISION",
        "GH-529-NO-TRADE-GUARD",
        "TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE"
    ]

    private func validate() throws {
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.nonBinanceVenue")
        }
        guard activeConcreteStrategy == Self.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.nonEMAStrategy")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV010RiskPreTrade.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try forbid(callsExecutionClient, "callsExecutionClient")
        try forbid(touchesBrokerGateway, "touchesBrokerGateway")
        try forbid(bypassesOMS, "bypassesOMS")
        try forbid(submitsRealOrder, "submitsRealOrder")
        try forbid(exposesLiveCommandSurface, "exposesLiveCommandSurface")
        try forbid(nonBinanceVenueEnabled, "nonBinanceVenueEnabled")
        try forbid(nonEMAStrategyEnabled, "nonEMAStrategyEnabled")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.\(field)")
        }
    }
}

/// ReleaseV010RiskPreTradeLimits 固定 release v0.1.0 pre-trade 本地限额。
///
/// 这些限额只用于本地 gate evidence，不代表真实 Binance 账户限额、broker margin 或 operator approval。
public struct ReleaseV010RiskPreTradeLimits: Codable, Equatable, Sendable {
    public let limitsID: Identifier
    public let maxProposalQuantity: Quantity
    public let maxProposalNotional: Double

    public init(
        limitsID: Identifier = Identifier.constant("gh-529-risk-limits"),
        maxProposalQuantity: Quantity,
        maxProposalNotional: Double
    ) throws {
        guard maxProposalNotional.isFinite && maxProposalNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "maxProposalNotional",
                expected: "finite positive notional",
                actual: "\(maxProposalNotional)"
            )
        }
        self.limitsID = limitsID
        self.maxProposalQuantity = maxProposalQuantity
        self.maxProposalNotional = maxProposalNotional
    }

    public static let deterministicFixture: ReleaseV010RiskPreTradeLimits = {
        do {
            return try ReleaseV010RiskPreTradeLimits(
                maxProposalQuantity: Quantity(1, field: "gh529.maxProposalQuantity"),
                maxProposalNotional: 50_000
            )
        } catch {
            preconditionFailure("Invalid deterministic GH-529 risk limits: \(error)")
        }
    }()
}

/// ReleaseV010RiskPreTradeInput 是 #528 EMA proposal 进入 RiskEngine gate 的中立输入。
///
/// 输入要求 proposal 与 risk query 完全匹配，证明 Trader / Strategy 没有绕过 RiskEngine。
public struct ReleaseV010RiskPreTradeInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let proposal: PaperActionProposal
    public let riskQuery: RiskEvaluationQuery
    public let sourceSequence: Int
    public let availableBalance: Double
    public let noTradeGuardActive: Bool
    public let riskGateBypassed: Bool
    public let productionTradingRequested: Bool

    public init(
        inputID: Identifier,
        proposal: PaperActionProposal,
        riskQuery: RiskEvaluationQuery,
        sourceSequence: Int,
        availableBalance: Double,
        noTradeGuardActive: Bool = false,
        riskGateBypassed: Bool = false,
        productionTradingRequested: Bool = false
    ) throws {
        self.inputID = inputID
        self.proposal = proposal
        self.riskQuery = riskQuery
        self.sourceSequence = sourceSequence
        self.availableBalance = availableBalance
        self.noTradeGuardActive = noTradeGuardActive
        self.riskGateBypassed = riskGateBypassed
        self.productionTradingRequested = productionTradingRequested

        try validate()
    }

    public var riskQueryMatchesProposal: Bool {
        riskQuery.paperOrderID == proposal.proposalID
            && riskQuery.symbol == proposal.symbol
            && riskQuery.timeframe == proposal.timeframe
            && riskQuery.proposedQuantity == proposal.quantity
            && riskQuery.executionMode == proposal.executionMode
    }

    public var inputBoundaryHeld: Bool {
        sourceSequence > 0
            && availableBalance.isFinite
            && availableBalance >= 0
            && proposal.executionMode == .paper
            && proposal.executionAuthorization == .paperIntentOnly
            && proposal.isExecutableAsRealOrder == false
            && riskQueryMatchesProposal
            && riskGateBypassed == false
            && productionTradingRequested == false
    }

    public func replacing(
        sourceSequence: Int? = nil,
        availableBalance: Double? = nil,
        noTradeGuardActive: Bool? = nil
    ) throws -> ReleaseV010RiskPreTradeInput {
        try ReleaseV010RiskPreTradeInput(
            inputID: Identifier("\(inputID.rawValue)-variant-\(sourceSequence ?? self.sourceSequence)"),
            proposal: proposal,
            riskQuery: riskQuery,
            sourceSequence: sourceSequence ?? self.sourceSequence,
            availableBalance: availableBalance ?? self.availableBalance,
            noTradeGuardActive: noTradeGuardActive ?? self.noTradeGuardActive,
            riskGateBypassed: riskGateBypassed,
            productionTradingRequested: productionTradingRequested
        )
    }

    private func validate() throws {
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard availableBalance.isFinite && availableBalance >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "availableBalance",
                expected: "finite non-negative balance",
                actual: "\(availableBalance)"
            )
        }
        guard proposal.executionMode == .paper else {
            throw CoreError.riskEvaluationRequiresPaperMode(proposal.executionMode)
        }
        guard proposal.executionAuthorization == .paperIntentOnly && proposal.isExecutableAsRealOrder == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.executableProposal")
        }
        guard riskQueryMatchesProposal else {
            throw CoreError.paperActionRiskDecisionMismatch(
                field: "riskQuery",
                expected: "proposal-compatible risk query",
                actual: "mismatched"
            )
        }
        try forbid(riskGateBypassed, "riskGateBypassed")
        try forbid(productionTradingRequested, "productionTradingRequested")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.input.\(field)")
        }
    }
}

public enum ReleaseV010RiskPreTradeDecisionOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case approved
    case rejected
    case blocked
}

public enum ReleaseV010RiskPreTradeRejectReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none
    case quantityLimitExceeded = "quantity limit exceeded"
    case notionalLimitExceeded = "notional limit exceeded"
    case availableBalanceExceeded = "available balance exceeded"
    case noTradeGuardActive = "no-trade guard active"
}

/// ReleaseV010RiskPreTradeDecisionEvidence 保存 approve / reject / blocked 的可审计证据。
///
/// Decision 不授权 order submission；后续 ExecutionEngine / OMS / kill switch 仍必须独立 gate。
public struct ReleaseV010RiskPreTradeDecisionEvidence: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let input: ReleaseV010RiskPreTradeInput
    public let outcome: ReleaseV010RiskPreTradeDecisionOutcome
    public let rejectReasons: [ReleaseV010RiskPreTradeRejectReason]
    public let validationAnchors: [String]
    public let decisionAuditable: Bool
    public let allProposalsRequireRiskEngine: Bool
    public let authorizesExecutionCommand: Bool
    public let productionTradingEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let bypassesOMS: Bool
    public let submitsRealOrder: Bool
    public let exposesLiveCommandSurface: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        decisionID: Identifier,
        input: ReleaseV010RiskPreTradeInput,
        outcome: ReleaseV010RiskPreTradeDecisionOutcome,
        rejectReasons: [ReleaseV010RiskPreTradeRejectReason],
        validationAnchors: [String] = ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors,
        decisionAuditable: Bool = true,
        allProposalsRequireRiskEngine: Bool = true,
        authorizesExecutionCommand: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        bypassesOMS: Bool = false,
        submitsRealOrder: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.decisionID = decisionID
        self.input = input
        self.outcome = outcome
        self.rejectReasons = rejectReasons
        self.validationAnchors = validationAnchors
        self.decisionAuditable = decisionAuditable
        self.allProposalsRequireRiskEngine = allProposalsRequireRiskEngine
        self.authorizesExecutionCommand = authorizesExecutionCommand
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.bypassesOMS = bypassesOMS
        self.submitsRealOrder = submitsRealOrder
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    public var decisionBoundaryHeld: Bool {
        input.inputBoundaryHeld
            && validationAnchors == ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors
            && decisionAuditable
            && allProposalsRequireRiskEngine
            && reasonsMatchOutcome
            && allForbiddenFlagsRemainClosed
    }

    private var reasonsMatchOutcome: Bool {
        switch outcome {
        case .approved:
            rejectReasons == [.none]
        case .rejected:
            rejectReasons.isEmpty == false && rejectReasons.contains(.none) == false
        case .blocked:
            rejectReasons.contains(.noTradeGuardActive)
        }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            authorizesExecutionCommand,
            productionTradingEnabledByDefault,
            callsExecutionClient,
            touchesBrokerGateway,
            bypassesOMS,
            submitsRealOrder,
            exposesLiveCommandSurface,
            nonBinanceVenueEnabled,
            nonEMAStrategyEnabled
        ].allSatisfy { $0 == false }
    }

    private func validate() throws {
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "input",
                expected: "GH-529 input boundary held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard decisionAuditable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.decisionAuditable")
        }
        guard allProposalsRequireRiskEngine else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.allProposalsRequireRiskEngine")
        }
        guard reasonsMatchOutcome else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "rejectReasons",
                expected: "outcome-compatible audited reasons",
                actual: rejectReasons.map(\.rawValue).joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("authorizesExecutionCommand", authorizesExecutionCommand),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("bypassesOMS", bypassesOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("nonEMAStrategyEnabled", nonEMAStrategyEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.\(forbiddenFlag.0)")
        }
    }
}

/// ReleaseV010RiskPreTradeGateEvidence 汇总 GH-529 的 approve / reject / blocked evidence。
public struct ReleaseV010RiskPreTradeGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let decisions: [ReleaseV010RiskPreTradeDecisionEvidence]
    public let validationAnchors: [String]
    public let allProposalsRequireRiskEngine: Bool
    public let blockedRejectedEvidenceAuditable: Bool
    public let noTradeGuardCovered: Bool
    public let productionTradingEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let submitsRealOrder: Bool

    public init(
        evidenceID: Identifier,
        decisions: [ReleaseV010RiskPreTradeDecisionEvidence],
        validationAnchors: [String] = ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors,
        allProposalsRequireRiskEngine: Bool = true,
        blockedRejectedEvidenceAuditable: Bool = true,
        noTradeGuardCovered: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.decisions = decisions
        self.validationAnchors = validationAnchors
        self.allProposalsRequireRiskEngine = allProposalsRequireRiskEngine
        self.blockedRejectedEvidenceAuditable = blockedRejectedEvidenceAuditable
        self.noTradeGuardCovered = noTradeGuardCovered
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.submitsRealOrder = submitsRealOrder

        try validate()
    }

    public var evidenceBoundaryHeld: Bool {
        Set(decisions.map(\.outcome)) == Set(ReleaseV010RiskPreTradeDecisionOutcome.allCases)
            && decisions.allSatisfy(\.decisionBoundaryHeld)
            && validationAnchors == ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors
            && allProposalsRequireRiskEngine
            && blockedRejectedEvidenceAuditable
            && noTradeGuardCovered
            && productionTradingEnabledByDefault == false
            && callsExecutionClient == false
            && submitsRealOrder == false
    }

    private func validate() throws {
        guard Set(decisions.map(\.outcome)) == Set(ReleaseV010RiskPreTradeDecisionOutcome.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions.outcome",
                expected: ReleaseV010RiskPreTradeDecisionOutcome.allCases.map(\.rawValue).joined(separator: ","),
                actual: decisions.map { $0.outcome.rawValue }.joined(separator: ",")
            )
        }
        guard decisions.allSatisfy(\.decisionBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions",
                expected: "all GH-529 decisions held",
                actual: "mismatch"
            )
        }
        for requiredFlag in [
            ("allProposalsRequireRiskEngine", allProposalsRequireRiskEngine),
            ("blockedRejectedEvidenceAuditable", blockedRejectedEvidenceAuditable),
            ("noTradeGuardCovered", noTradeGuardCovered)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.\(requiredFlag.0)")
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("callsExecutionClient", callsExecutionClient),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010RiskPreTrade.\(forbiddenFlag.0)")
        }
    }
}
