import DomainModel
import Foundation

/// L4LiveRiskPreTradeCommandKind 固定 GH-464 风控 gate 需要覆盖的 command kind。
///
/// 这些 command kind 只用于 RiskEngine pre-trade allow / reject evidence。RiskEngine 不调用
/// ExecutionClient，不生成 request envelope，不提交真实订单，也不实现 broker command。
public enum L4LiveRiskPreTradeCommandKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit = "submit"
    case cancel = "cancel"
    case replace = "replace"
}

/// L4LiveRiskPreTradeDecisionOutcome 描述 GH-464 风控 gate 的 deterministic decision。
///
/// `allow` 只表示 sandbox command proposal 通过本地 gate；它不是 production trading approval。
/// `incidentStop` 只记录 incident stop evidence，不执行 kill switch 或 shutdown command。
public enum L4LiveRiskPreTradeDecisionOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allow
    case reject
    case blocked
    case incidentStop = "incident stop"
}

/// L4LiveRiskPreTradeRejectReason 固定 GH-464 可审计的拒绝 / 阻断原因。
///
/// Reason 只服务 deterministic evidence；它不读取真实账户、不消费 broker position，也不代表交易所拒单。
public enum L4LiveRiskPreTradeRejectReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none
    case notionalLimitExceeded = "notional limit exceeded"
    case accountReadModelMissing = "account read model missing"
    case positionReadModelMissing = "position read model missing"
    case balanceReadModelMissing = "balance read model missing"
    case marginReadModelMissing = "margin read model missing"
    case riskGateBypassRejected = "risk gate bypass rejected"
    case incidentStopActive = "incident stop active"
    case productionRiskDisabled = "production risk disabled"
}

/// L4LiveRiskPreTradeForbiddenCapability 枚举 GH-464 必须继续关闭的能力。
///
/// GH-464 可以运行本地 deterministic 风控 gate，但不能打开 production enablement、读取 secret、调用
/// broker / ExecutionClient、提交订单、执行 reconciliation 或暴露 Live command surface。
public enum L4LiveRiskPreTradeForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionRiskEnabled = "production risk enabled"
    case productionTradingEnabled = "production trading enabled"
    case readsSecret = "reads secret"
    case readsRawAccountPayload = "reads raw account payload"
    case readsBrokerState = "reads broker state"
    case callsExecutionClient = "calls ExecutionClient"
    case touchesBrokerGateway = "touches broker gateway"
    case submitsRealOrder = "submits real order"
    case bypassesOMS = "bypasses OMS"
    case mutatesPortfolio = "mutates Portfolio"
    case performsReconciliation = "performs reconciliation"
    case exposesLiveCommandSurface = "exposes Live command surface"
}

/// L4LiveRiskPreTradeReadModelInput 是 GH-464 允许接入的 APB / margin read-model 输入。
///
/// Input 只引用 GH-457 read-model identity、account / position / balance / margin component 和 canonical
/// values。它不携带 raw account payload、broker state、schema、Runtime object 或 Adapter request。
public struct L4LiveRiskPreTradeReadModelInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let upstreamIssueID: Identifier
    public let readModelID: Identifier
    public let accountValue: String
    public let positionValue: String
    public let balanceValue: String
    public let marginValue: String
    public let availableBalance: Double
    public let marginCapacity: Double
    public let components: [String]
    public let readModelOnly: Bool
    public let rawAccountPayloadExposed: Bool
    public let brokerStateExposed: Bool
    public let runtimeObjectExposed: Bool
    public let adapterRequestExposed: Bool

    public var inputBoundaryHeld: Bool {
        upstreamIssueID.rawValue == "GH-457"
            && Set(components) == Self.requiredComponents
            && readModelOnly
            && rawAccountPayloadExposed == false
            && brokerStateExposed == false
            && runtimeObjectExposed == false
            && adapterRequestExposed == false
    }

    public init(
        inputID: Identifier = Identifier.constant("gh-464-live-risk-apb-margin-read-model-input"),
        upstreamIssueID: Identifier = Identifier.constant("GH-457"),
        readModelID: Identifier = Identifier.constant("gh-457-live-account-read-model"),
        accountValue: String,
        positionValue: String,
        balanceValue: String,
        marginValue: String,
        availableBalance: Double,
        marginCapacity: Double,
        components: [String] = Array(Self.requiredComponents).sorted(),
        readModelOnly: Bool = true,
        rawAccountPayloadExposed: Bool = false,
        brokerStateExposed: Bool = false,
        runtimeObjectExposed: Bool = false,
        adapterRequestExposed: Bool = false
    ) throws {
        guard upstreamIssueID.rawValue == "GH-457" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-457",
                actual: upstreamIssueID.rawValue
            )
        }
        for requiredField in [
            ("accountValue", accountValue),
            ("positionValue", positionValue),
            ("balanceValue", balanceValue),
            ("marginValue", marginValue)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty GH-464 APB / margin read-model value",
                actual: "empty"
            )
        }
        guard availableBalance.isFinite && availableBalance >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "availableBalance",
                expected: "finite non-negative available balance",
                actual: "\(availableBalance)"
            )
        }
        guard marginCapacity.isFinite && marginCapacity >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "marginCapacity",
                expected: "finite non-negative margin capacity",
                actual: "\(marginCapacity)"
            )
        }
        guard Set(components) == Self.requiredComponents else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "components",
                expected: Self.requiredComponents.sorted().joined(separator: ","),
                actual: components.sorted().joined(separator: ",")
            )
        }
        guard readModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelOnly")
        }
        for forbiddenFlag in [
            ("rawAccountPayloadExposed", rawAccountPayloadExposed),
            ("brokerStateExposed", brokerStateExposed),
            ("runtimeObjectExposed", runtimeObjectExposed),
            ("adapterRequestExposed", adapterRequestExposed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.inputID = inputID
        self.upstreamIssueID = upstreamIssueID
        self.readModelID = readModelID
        self.accountValue = accountValue
        self.positionValue = positionValue
        self.balanceValue = balanceValue
        self.marginValue = marginValue
        self.availableBalance = availableBalance
        self.marginCapacity = marginCapacity
        self.components = components
        self.readModelOnly = readModelOnly
        self.rawAccountPayloadExposed = rawAccountPayloadExposed
        self.brokerStateExposed = brokerStateExposed
        self.runtimeObjectExposed = runtimeObjectExposed
        self.adapterRequestExposed = adapterRequestExposed
    }

    public static let requiredComponents: Set<String> = [
        "account",
        "position",
        "balance",
        "margin"
    ]

    public static func deterministicFixture() throws -> L4LiveRiskPreTradeReadModelInput {
        try L4LiveRiskPreTradeReadModelInput(
            accountValue: "live account read model: sandbox fixture account",
            positionValue: "live position read model: BTCUSDT flat fixture position",
            balanceValue: "live balance read model: 100000.00 USDT sandbox balance",
            marginValue: "live margin read model: 50000.00 USDT sandbox margin capacity",
            availableBalance: 100_000,
            marginCapacity: 50_000
        )
    }
}

/// L4LiveRiskOrderProposalInput 是 GH-464 进入 RiskEngine gate 的 order proposal。
///
/// Proposal 只包含 symbol、quantity、limit price、command kind 和 OMS contract identity。它不包含
/// secret、signed request、broker payload 或 ExecutionClient request。
public struct L4LiveRiskOrderProposalInput: Codable, Equatable, Sendable {
    public let proposalID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: L4LiveRiskPreTradeCommandKind
    public let omsContractIssueID: Identifier
    public let symbol: String
    public let quantity: Double
    public let limitPrice: Double
    public let reason: String
    public let riskGateBypassed: Bool
    public let omsBypassed: Bool
    public let productionTradingRequested: Bool

    public var notional: Double {
        quantity * limitPrice
    }

    public var proposalBoundaryHeld: Bool {
        issueID.rawValue == "GH-464"
            && upstreamIssueID.rawValue == "GH-461"
            && omsContractIssueID.rawValue == "GH-461"
            && symbol.isEmpty == false
            && quantity > 0
            && limitPrice > 0
            && reason.isEmpty == false
            && riskGateBypassed == false
            && omsBypassed == false
            && productionTradingRequested == false
    }

    public init(
        proposalID: Identifier,
        issueID: Identifier = Identifier.constant("GH-464"),
        upstreamIssueID: Identifier = Identifier.constant("GH-461"),
        commandKind: L4LiveRiskPreTradeCommandKind,
        omsContractIssueID: Identifier = Identifier.constant("GH-461"),
        symbol: String,
        quantity: Double,
        limitPrice: Double,
        reason: String,
        riskGateBypassed: Bool = false,
        omsBypassed: Bool = false,
        productionTradingRequested: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-464" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-464",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-461" && omsContractIssueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "omsContractIssueID",
                expected: "GH-461",
                actual: "\(upstreamIssueID.rawValue)/\(omsContractIssueID.rawValue)"
            )
        }
        guard symbol.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "symbol",
                expected: "non-empty symbol",
                actual: "empty"
            )
        }
        guard quantity.isFinite && quantity > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "quantity",
                expected: "finite positive quantity",
                actual: "\(quantity)"
            )
        }
        guard limitPrice.isFinite && limitPrice > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "limitPrice",
                expected: "finite positive limit price",
                actual: "\(limitPrice)"
            )
        }
        guard reason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reason",
                expected: "non-empty proposal reason",
                actual: "empty"
            )
        }
        for forbiddenFlag in [
            ("riskGateBypassed", riskGateBypassed),
            ("omsBypassed", omsBypassed),
            ("productionTradingRequested", productionTradingRequested)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.proposalID = proposalID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.omsContractIssueID = omsContractIssueID
        self.symbol = symbol
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.reason = reason
        self.riskGateBypassed = riskGateBypassed
        self.omsBypassed = omsBypassed
        self.productionTradingRequested = productionTradingRequested
    }
}

/// L4LiveRiskPreTradeDecisionEvidence 是 GH-464 单次 allow / reject / blocked / incident stop 证据。
///
/// Decision 只说明 RiskEngine gate 如何处理 sandbox command proposal。它不执行命令、不调用
/// ExecutionClient、不提交真实订单、不写 Portfolio，也不启动 incident stop runtime。
public struct L4LiveRiskPreTradeDecisionEvidence: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let issueID: Identifier
    public let proposal: L4LiveRiskOrderProposalInput
    public let readModelInput: L4LiveRiskPreTradeReadModelInput
    public let outcome: L4LiveRiskPreTradeDecisionOutcome
    public let rejectReasons: [L4LiveRiskPreTradeRejectReason]
    public let commandPathRequiresRiskEngine: Bool
    public let accountPositionBalanceMarginReadModelAttached: Bool
    public let decisionAuditable: Bool
    public let executesCommand: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let mutatesPortfolio: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var decisionBoundaryHeld: Bool {
        issueID.rawValue == "GH-464"
            && proposal.proposalBoundaryHeld
            && readModelInput.inputBoundaryHeld
            && rejectReasons.isEmpty == false
            && commandPathRequiresRiskEngine
            && accountPositionBalanceMarginReadModelAttached
            && decisionAuditable
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            executesCommand,
            callsExecutionClient,
            touchesBrokerGateway,
            mutatesPortfolio,
            performsReconciliation,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        decisionID: Identifier,
        issueID: Identifier = Identifier.constant("GH-464"),
        proposal: L4LiveRiskOrderProposalInput,
        readModelInput: L4LiveRiskPreTradeReadModelInput,
        outcome: L4LiveRiskPreTradeDecisionOutcome,
        rejectReasons: [L4LiveRiskPreTradeRejectReason],
        commandPathRequiresRiskEngine: Bool = true,
        accountPositionBalanceMarginReadModelAttached: Bool = true,
        decisionAuditable: Bool = true,
        executesCommand: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        mutatesPortfolio: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-464" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-464",
                actual: issueID.rawValue
            )
        }
        guard proposal.proposalBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposal",
                expected: "GH-464 proposal boundary held",
                actual: "mismatch"
            )
        }
        guard readModelInput.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "readModelInput",
                expected: "GH-457 APB / margin read-model boundary held",
                actual: "mismatch"
            )
        }
        guard rejectReasons.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "rejectReasons",
                expected: "non-empty audited reason list",
                actual: "empty"
            )
        }
        guard commandPathRequiresRiskEngine else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("commandPathRequiresRiskEngine")
        }
        guard accountPositionBalanceMarginReadModelAttached else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("accountPositionBalanceMarginReadModelAttached")
        }
        guard decisionAuditable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("decisionAuditable")
        }
        for forbiddenFlag in [
            ("executesCommand", executesCommand),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("mutatesPortfolio", mutatesPortfolio),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.decisionID = decisionID
        self.issueID = issueID
        self.proposal = proposal
        self.readModelInput = readModelInput
        self.outcome = outcome
        self.rejectReasons = rejectReasons
        self.commandPathRequiresRiskEngine = commandPathRequiresRiskEngine
        self.accountPositionBalanceMarginReadModelAttached = accountPositionBalanceMarginReadModelAttached
        self.decisionAuditable = decisionAuditable
        self.executesCommand = executesCommand
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.mutatesPortfolio = mutatesPortfolio
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }
}

/// L4LiveRiskPreTradeGateEvidence 汇总 GH-464 deterministic allow / reject / blocked / incident evidence。
///
/// Evidence 证明所有 sandbox command path 必须经过 RiskEngine gate，并保留可审计拒绝原因。它不授权
/// production trading，不调用 ExecutionClient，不实现 kill switch、reconciliation 或 UI command。
public struct L4LiveRiskPreTradeGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let decisions: [L4LiveRiskPreTradeDecisionEvidence]
    public let forbiddenCapabilities: [L4LiveRiskPreTradeForbiddenCapability]
    public let validationAnchors: [String]
    public let allSandboxCommandsPassRiskEngine: Bool
    public let riskRejectReasonsAuditable: Bool
    public let commandBlockedWithoutRiskGate: Bool
    public let productionEnablementClosed: Bool
    public let callsExecutionClient: Bool
    public let mutatesPortfolio: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var gateEvidenceHeld: Bool {
        issueID.rawValue == "GH-464"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-457", "GH-461"]
            && Set(decisions.map(\.outcome)) == Set(L4LiveRiskPreTradeDecisionOutcome.allCases)
            && decisions.allSatisfy(\.decisionBoundaryHeld)
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && allSandboxCommandsPassRiskEngine
            && riskRejectReasonsAuditable
            && commandBlockedWithoutRiskGate
            && productionEnablementClosed
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            callsExecutionClient,
            mutatesPortfolio,
            performsReconciliation,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-464-live-risk-pre-trade-gate-evidence"),
        issueID: Identifier = Identifier.constant("GH-464"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-457"),
            Identifier.constant("GH-461")
        ],
        decisions: [L4LiveRiskPreTradeDecisionEvidence],
        forbiddenCapabilities: [L4LiveRiskPreTradeForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        allSandboxCommandsPassRiskEngine: Bool = true,
        riskRejectReasonsAuditable: Bool = true,
        commandBlockedWithoutRiskGate: Bool = true,
        productionEnablementClosed: Bool = true,
        callsExecutionClient: Bool = false,
        mutatesPortfolio: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-464" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-464",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-457", "GH-461"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-457,GH-461",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard Set(decisions.map(\.outcome)) == Set(L4LiveRiskPreTradeDecisionOutcome.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions.outcome",
                expected: L4LiveRiskPreTradeDecisionOutcome.allCases.map(\.rawValue).joined(separator: ","),
                actual: decisions.map { $0.outcome.rawValue }.joined(separator: ",")
            )
        }
        guard decisions.allSatisfy(\.decisionBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions",
                expected: "all GH-464 decisions held",
                actual: "mismatch"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("allSandboxCommandsPassRiskEngine", allSandboxCommandsPassRiskEngine),
            ("riskRejectReasonsAuditable", riskRejectReasonsAuditable),
            ("commandBlockedWithoutRiskGate", commandBlockedWithoutRiskGate),
            ("productionEnablementClosed", productionEnablementClosed)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("callsExecutionClient", callsExecutionClient),
            ("mutatesPortfolio", mutatesPortfolio),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.decisions = decisions
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.allSandboxCommandsPassRiskEngine = allSandboxCommandsPassRiskEngine
        self.riskRejectReasonsAuditable = riskRejectReasonsAuditable
        self.commandBlockedWithoutRiskGate = commandBlockedWithoutRiskGate
        self.productionEnablementClosed = productionEnablementClosed
        self.callsExecutionClient = callsExecutionClient
        self.mutatesPortfolio = mutatesPortfolio
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredForbiddenCapabilities = L4LiveRiskPreTradeForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-464-LIVE-RISKENGINE-PRE-TRADE-GATE",
        "GH-464-ORDER-PROPOSAL-RISK-INPUT",
        "GH-464-APB-MARGIN-READ-MODEL-GATE",
        "GH-464-ALLOW-REJECT-BLOCKED-INCIDENT-EVIDENCE",
        "GH-464-COMMAND-PATH-RISKENGINE-REQUIRED",
        "TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE"
    ]
}

/// L4LiveRiskPreTradeGateRuntime 是 GH-464 的本地 deterministic risk gate。
///
/// Runtime 只消费 GH-457 APB / margin read-model input 和 GH-461 OMS identity，输出 allow / reject /
/// blocked / incident stop evidence。它不读取真实账户、不调用 ExecutionClient、不执行真实交易。
public struct L4LiveRiskPreTradeGateRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let maxOrderNotional: Double
    public let productionRiskEnabled: Bool
    public let productionTradingEnabled: Bool
    public let readsSecret: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let mutatesPortfolio: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var runtimeBoundaryHeld: Bool {
        maxOrderNotional.isFinite
            && maxOrderNotional > 0
            && productionRiskEnabled == false
            && productionTradingEnabled == false
            && readsSecret == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && mutatesPortfolio == false
            && performsReconciliation == false
            && exposesLiveCommandSurface == false
    }

    public init(
        runtimeID: Identifier = Identifier.constant("gh-464-live-risk-pre-trade-gate-runtime"),
        maxOrderNotional: Double = 25_000,
        productionRiskEnabled: Bool = false,
        productionTradingEnabled: Bool = false,
        readsSecret: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        mutatesPortfolio: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard maxOrderNotional.isFinite && maxOrderNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "maxOrderNotional",
                expected: "finite positive max order notional",
                actual: "\(maxOrderNotional)"
            )
        }
        for forbiddenFlag in [
            ("productionRiskEnabled", productionRiskEnabled),
            ("productionTradingEnabled", productionTradingEnabled),
            ("readsSecret", readsSecret),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("mutatesPortfolio", mutatesPortfolio),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.runtimeID = runtimeID
        self.maxOrderNotional = maxOrderNotional
        self.productionRiskEnabled = productionRiskEnabled
        self.productionTradingEnabled = productionTradingEnabled
        self.readsSecret = readsSecret
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.mutatesPortfolio = mutatesPortfolio
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static func deterministicFixture() throws -> L4LiveRiskPreTradeGateRuntime {
        try L4LiveRiskPreTradeGateRuntime()
    }

    public func evaluate(
        proposal: L4LiveRiskOrderProposalInput,
        readModelInput: L4LiveRiskPreTradeReadModelInput,
        incidentStopActive: Bool = false,
        riskGateAvailable: Bool = true
    ) throws -> L4LiveRiskPreTradeDecisionEvidence {
        guard runtimeBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runtimeBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard proposal.proposalBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposal",
                expected: "GH-464 proposal boundary held",
                actual: "mismatch"
            )
        }
        guard readModelInput.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "readModelInput",
                expected: "GH-457 APB / margin read-model boundary held",
                actual: "mismatch"
            )
        }

        let outcome: L4LiveRiskPreTradeDecisionOutcome
        let reasons: [L4LiveRiskPreTradeRejectReason]
        if riskGateAvailable == false {
            outcome = .blocked
            reasons = [.accountReadModelMissing, .riskGateBypassRejected]
        } else if incidentStopActive {
            outcome = .incidentStop
            reasons = [.incidentStopActive]
        } else if proposal.notional > maxOrderNotional || proposal.notional > readModelInput.marginCapacity {
            outcome = .reject
            reasons = [.notionalLimitExceeded]
        } else {
            outcome = .allow
            reasons = [.none]
        }
        return try L4LiveRiskPreTradeDecisionEvidence(
            decisionID: Identifier.constant("gh-464-\(outcome.rawValue)-decision"),
            proposal: proposal,
            readModelInput: readModelInput,
            outcome: outcome,
            rejectReasons: reasons
        )
    }

    public func deterministicEvidence() throws -> L4LiveRiskPreTradeGateEvidence {
        let readModelInput = try L4LiveRiskPreTradeReadModelInput.deterministicFixture()
        let allow = try evaluate(
            proposal: proposal(kind: .submit, quantity: 0.10, price: 42_120.70, suffix: "allow"),
            readModelInput: readModelInput
        )
        let reject = try evaluate(
            proposal: proposal(kind: .replace, quantity: 1.00, price: 42_120.70, suffix: "reject"),
            readModelInput: readModelInput
        )
        let blocked = try evaluate(
            proposal: proposal(kind: .cancel, quantity: 0.10, price: 42_120.70, suffix: "blocked"),
            readModelInput: readModelInput,
            riskGateAvailable: false
        )
        let incident = try evaluate(
            proposal: proposal(kind: .submit, quantity: 0.10, price: 42_120.70, suffix: "incident"),
            readModelInput: readModelInput,
            incidentStopActive: true
        )
        return try L4LiveRiskPreTradeGateEvidence(
            decisions: [allow, reject, blocked, incident]
        )
    }

    private func proposal(
        kind: L4LiveRiskPreTradeCommandKind,
        quantity: Double,
        price: Double,
        suffix: String
    ) throws -> L4LiveRiskOrderProposalInput {
        try L4LiveRiskOrderProposalInput(
            proposalID: Identifier.constant("gh-464-\(suffix)-\(kind.rawValue)-proposal"),
            commandKind: kind,
            symbol: "BTCUSDT",
            quantity: quantity,
            limitPrice: price,
            reason: "GH-464 deterministic \(suffix) \(kind.rawValue) risk proposal"
        )
    }
}
