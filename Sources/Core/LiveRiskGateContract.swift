import Foundation

/// LiveRiskTerm 定义 MTP-82 允许命名的 Future Live Risk 术语。
///
/// 这些术语只服务合同、验证矩阵和后续 gate 讨论；它们不构成当前可调用风控引擎、
/// account / broker state reader、pre-trade allow / reject runtime、UI command 或真实交易授权。
public enum LiveRiskTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case livePreTradeRisk = "live pre-trade risk"
    case futureRiskDecision = "future risk decision"
    case riskGate = "risk gate"
    case riskBlockedEvidence = "risk blocked evidence"
    case exposureGate = "exposure gate"
    case orderNotionalGate = "order notional gate"
    case frequencyGate = "frequency gate"
    case lossGate = "loss gate"
    case circuitBreaker = "circuit breaker"
    case noTradeState = "no-trade state"
    case paperRiskBlocker = "paper risk blocker"
    case paperExposure = "paper exposure"
}

/// LiveFrequencyLossDrawdownFutureGate 固定 MTP-84 的 frequency / loss / drawdown 未来门槛。
///
/// 这些 gate 只描述 Future Live Risk 在后续 Project Definition 前必须补齐的频率窗口、
/// PnL / equity 来源、loss limit、drawdown limit 和审计条件；当前阶段不得把 gate
/// 解释为真实限频器、真实亏损阈值执行、真实回撤控制 runtime 或停机 / 熔断命令。
public enum LiveFrequencyLossDrawdownFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveRiskDecision = "Human independent Live risk decision"
    case liveTradingFoundationBoundarySatisfied = "Live trading foundation boundary satisfied"
    case liveExecutionControlBoundarySatisfied = "Live execution control boundary satisfied"
    case frequencyWindowPolicyDefined = "future frequency window policy defined"
    case orderEventSourceContractDefined = "future order event source contract defined"
    case pnlEquitySourceContractDefined = "future PnL / equity source contract defined"
    case lossLimitPolicyDefined = "future loss limit policy defined"
    case drawdownLimitPolicyDefined = "future drawdown limit policy defined"
    case paperRiskExposureIsolationDefined = "paper risk / exposure isolation defined"
    case operationsAuditHandoffDefined = "future operations / audit handoff defined"
}

/// LiveFrequencyLossDrawdownForbiddenCapability 枚举 MTP-84 必须阻断的能力面。
///
/// 这些值只用于 deterministic forbidden capability tests 和 PR evidence；它们不能出现在
/// 当前 API、adapter、Runtime、PnL reader、频率计数器、回撤控制、UI command 或网络请求中。
public enum LiveFrequencyLossDrawdownForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionSync = "broker position sync"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case realPnLRead = "real PnL read"
    case realAccountEquityRead = "real account equity read"
    case liveOrderFrequencyCounter = "live order frequency counter"
    case productionFrequencyThrottling = "production frequency throttling"
    case brokerSideThrottling = "broker-side throttling"
    case realLossLimitEvaluation = "real loss limit evaluation"
    case realDrawdownLimitEvaluation = "real drawdown limit evaluation"
    case drawdownCircuitBreakerRuntime = "drawdown circuit breaker runtime"
    case realPreTradeRiskEngine = "real pre-trade risk engine"
    case realPreTradeAllowRuntime = "real pre-trade allow runtime"
    case realPreTradeRejectRuntime = "real pre-trade reject runtime"
    case circuitBreakerCommand = "circuit breaker command"
    case stopTradingCommand = "stop trading command"
    case emergencyStopCommand = "emergency stop command"
    case liveOrderSubmit = "live order submit"
    case liveOrderCancel = "live order cancel"
    case liveOrderReplace = "live order replace"
    case paperRiskBlockerUpgrade = "paper risk blocker upgrade"
    case paperExposureUpgrade = "paper exposure upgrade"
    case riskCommandSurface = "risk command surface"
    case positionManagementCommand = "position management command"
    case orderForm = "order form"
    case tradingButton = "trading button"
}

/// LiveFrequencyLossDrawdownGateBoundary 是 MTP-84 的 frequency / loss / drawdown gate fixture。
///
/// 该 fixture 只定义 frequency gate、loss / drawdown gate、future gate 条件、forbidden
/// capability tests 和 paper risk / exposure 隔离证据。所有真实下单频率计数、生产限频、
/// 真实 PnL / equity 读取、真实亏损 / 回撤阈值执行、回撤熔断、停机命令、交易命令和
/// paper-to-live risk upgrade 路径都必须保持关闭。
public struct LiveFrequencyLossDrawdownGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveRiskTerm]
    public let futureGates: [LiveFrequencyLossDrawdownFutureGate]
    public let forbiddenCapabilities: [LiveFrequencyLossDrawdownForbiddenCapability]
    public let allowedEvidenceKinds: [LiveRiskEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isFutureGateOnly: Bool
    public let providesLiveRiskEngine: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let readsRealPnL: Bool
    public let readsRealAccountEquity: Bool
    public let countsLiveOrderFrequency: Bool
    public let enforcesFrequencyThrottle: Bool
    public let evaluatesRealLossLimit: Bool
    public let evaluatesRealDrawdownLimit: Bool
    public let runsDrawdownCircuitBreaker: Bool
    public let evaluatesRealPreTradeAllow: Bool
    public let evaluatesRealPreTradeReject: Bool
    public let authorizesLiveTrading: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let runsCircuitBreakerCommand: Bool
    public let runsStopTradingCommand: Bool
    public let runsEmergencyStopCommand: Bool
    public let mapsPaperRiskBlockerToFrequencyLossDrawdownGate: Bool
    public let mapsPaperExposureToLossDrawdownGate: Bool
    public let providesRiskCommandSurface: Bool
    public let providesPositionManagementCommand: Bool
    public let exposesOrderForm: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var frequencyLossDrawdownBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && allForbiddenFlagsRemainFalse
    }

    public var frequencyRuntimeBoundaryHeld: Bool {
        countsLiveOrderFrequency == false
            && enforcesFrequencyThrottle == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && submitsRealOrder == false
    }

    public var lossDrawdownRuntimeBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
            && readsMargin == false
            && readsLeverage == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && runsDrawdownCircuitBreaker == false
    }

    public var paperRiskExposureIsolationBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors
            && mapsPaperRiskBlockerToFrequencyLossDrawdownGate == false
            && mapsPaperExposureToLossDrawdownGate == false
            && readsRealAccountBalance == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
    }

    public var allPreTradeDecisionsBlocked: Bool {
        providesLiveRiskEngine == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isFutureGateOnly
            && providesLiveRiskEngine == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
            && countsLiveOrderFrequency == false
            && enforcesFrequencyThrottle == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && runsDrawdownCircuitBreaker == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && runsCircuitBreakerCommand == false
            && runsStopTradingCommand == false
            && runsEmergencyStopCommand == false
            && mapsPaperRiskBlockerToFrequencyLossDrawdownGate == false
            && mapsPaperExposureToLossDrawdownGate == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public func forbidsCapability(_ capability: LiveFrequencyLossDrawdownForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-84-frequency-loss-drawdown-boundary"),
        issueID: Identifier = try! Identifier("MTP-84"),
        terms: [LiveRiskTerm] = Self.requiredTerms,
        futureGates: [LiveFrequencyLossDrawdownFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveFrequencyLossDrawdownForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveRiskEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isFutureGateOnly: Bool = true,
        providesLiveRiskEngine: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        readsRealPnL: Bool = false,
        readsRealAccountEquity: Bool = false,
        countsLiveOrderFrequency: Bool = false,
        enforcesFrequencyThrottle: Bool = false,
        evaluatesRealLossLimit: Bool = false,
        evaluatesRealDrawdownLimit: Bool = false,
        runsDrawdownCircuitBreaker: Bool = false,
        evaluatesRealPreTradeAllow: Bool = false,
        evaluatesRealPreTradeReject: Bool = false,
        authorizesLiveTrading: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        runsCircuitBreakerCommand: Bool = false,
        runsStopTradingCommand: Bool = false,
        runsEmergencyStopCommand: Bool = false,
        mapsPaperRiskBlockerToFrequencyLossDrawdownGate: Bool = false,
        mapsPaperExposureToLossDrawdownGate: Bool = false,
        providesRiskCommandSurface: Bool = false,
        providesPositionManagementCommand: Bool = false,
        exposesOrderForm: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureGateOnly: isFutureGateOnly,
            providesLiveRiskEngine: providesLiveRiskEngine,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            readsRealPnL: readsRealPnL,
            readsRealAccountEquity: readsRealAccountEquity,
            countsLiveOrderFrequency: countsLiveOrderFrequency,
            enforcesFrequencyThrottle: enforcesFrequencyThrottle,
            evaluatesRealLossLimit: evaluatesRealLossLimit,
            evaluatesRealDrawdownLimit: evaluatesRealDrawdownLimit,
            runsDrawdownCircuitBreaker: runsDrawdownCircuitBreaker,
            evaluatesRealPreTradeAllow: evaluatesRealPreTradeAllow,
            evaluatesRealPreTradeReject: evaluatesRealPreTradeReject,
            authorizesLiveTrading: authorizesLiveTrading,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            runsCircuitBreakerCommand: runsCircuitBreakerCommand,
            runsStopTradingCommand: runsStopTradingCommand,
            runsEmergencyStopCommand: runsEmergencyStopCommand,
            mapsPaperRiskBlockerToFrequencyLossDrawdownGate: mapsPaperRiskBlockerToFrequencyLossDrawdownGate,
            mapsPaperExposureToLossDrawdownGate: mapsPaperExposureToLossDrawdownGate,
            providesRiskCommandSurface: providesRiskCommandSurface,
            providesPositionManagementCommand: providesPositionManagementCommand,
            exposesOrderForm: exposesOrderForm,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isFutureGateOnly = isFutureGateOnly
        self.providesLiveRiskEngine = providesLiveRiskEngine
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.readsRealPnL = readsRealPnL
        self.readsRealAccountEquity = readsRealAccountEquity
        self.countsLiveOrderFrequency = countsLiveOrderFrequency
        self.enforcesFrequencyThrottle = enforcesFrequencyThrottle
        self.evaluatesRealLossLimit = evaluatesRealLossLimit
        self.evaluatesRealDrawdownLimit = evaluatesRealDrawdownLimit
        self.runsDrawdownCircuitBreaker = runsDrawdownCircuitBreaker
        self.evaluatesRealPreTradeAllow = evaluatesRealPreTradeAllow
        self.evaluatesRealPreTradeReject = evaluatesRealPreTradeReject
        self.authorizesLiveTrading = authorizesLiveTrading
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.runsCircuitBreakerCommand = runsCircuitBreakerCommand
        self.runsStopTradingCommand = runsStopTradingCommand
        self.runsEmergencyStopCommand = runsEmergencyStopCommand
        self.mapsPaperRiskBlockerToFrequencyLossDrawdownGate = mapsPaperRiskBlockerToFrequencyLossDrawdownGate
        self.mapsPaperExposureToLossDrawdownGate = mapsPaperExposureToLossDrawdownGate
        self.providesRiskCommandSurface = providesRiskCommandSurface
        self.providesPositionManagementCommand = providesPositionManagementCommand
        self.exposesOrderForm = exposesOrderForm
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveRiskTerm].self, forKey: .terms),
            futureGates: try container.decode(
                [LiveFrequencyLossDrawdownFutureGate].self,
                forKey: .futureGates
            ),
            forbiddenCapabilities: try container.decode(
                [LiveFrequencyLossDrawdownForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode([LiveRiskEvidenceKind].self, forKey: .allowedEvidenceKinds),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            providesLiveRiskEngine: try container.decode(Bool.self, forKey: .providesLiveRiskEngine),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            readsRealPnL: try container.decode(Bool.self, forKey: .readsRealPnL),
            readsRealAccountEquity: try container.decode(Bool.self, forKey: .readsRealAccountEquity),
            countsLiveOrderFrequency: try container.decode(Bool.self, forKey: .countsLiveOrderFrequency),
            enforcesFrequencyThrottle: try container.decode(Bool.self, forKey: .enforcesFrequencyThrottle),
            evaluatesRealLossLimit: try container.decode(Bool.self, forKey: .evaluatesRealLossLimit),
            evaluatesRealDrawdownLimit: try container.decode(Bool.self, forKey: .evaluatesRealDrawdownLimit),
            runsDrawdownCircuitBreaker: try container.decode(Bool.self, forKey: .runsDrawdownCircuitBreaker),
            evaluatesRealPreTradeAllow: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeAllow),
            evaluatesRealPreTradeReject: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeReject),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            runsCircuitBreakerCommand: try container.decode(Bool.self, forKey: .runsCircuitBreakerCommand),
            runsStopTradingCommand: try container.decode(Bool.self, forKey: .runsStopTradingCommand),
            runsEmergencyStopCommand: try container.decode(Bool.self, forKey: .runsEmergencyStopCommand),
            mapsPaperRiskBlockerToFrequencyLossDrawdownGate: try container.decode(
                Bool.self,
                forKey: .mapsPaperRiskBlockerToFrequencyLossDrawdownGate
            ),
            mapsPaperExposureToLossDrawdownGate: try container.decode(
                Bool.self,
                forKey: .mapsPaperExposureToLossDrawdownGate
            ),
            providesRiskCommandSurface: try container.decode(Bool.self, forKey: .providesRiskCommandSurface),
            providesPositionManagementCommand: try container.decode(
                Bool.self,
                forKey: .providesPositionManagementCommand
            ),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerms: [LiveRiskTerm] = [
        .frequencyGate,
        .lossGate
    ]

    public static let requiredFutureGates: [LiveFrequencyLossDrawdownFutureGate] = [
        .humanLiveRiskDecision,
        .liveTradingFoundationBoundarySatisfied,
        .liveExecutionControlBoundarySatisfied,
        .frequencyWindowPolicyDefined,
        .orderEventSourceContractDefined,
        .pnlEquitySourceContractDefined,
        .lossLimitPolicyDefined,
        .drawdownLimitPolicyDefined,
        .paperRiskExposureIsolationDefined,
        .operationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveFrequencyLossDrawdownForbiddenCapability] =
        LiveFrequencyLossDrawdownForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveRiskEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperLiveRiskIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
        "MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS",
        "MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT",
        "MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE",
        "MTP-84-LIVE-RISK-GATE-VALIDATION",
        "TVM-LIVE-RISK-GATE"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-82-LIVE-RISK-TERMINOLOGY",
        "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
        "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
        "TVM-RISK-BLOCKER",
        "TVM-PORTFOLIO-EXPOSURE",
        "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
    ]

    public static let deterministicFixture: LiveFrequencyLossDrawdownGateBoundary = {
        do {
            return try LiveFrequencyLossDrawdownGateBoundary()
        } catch {
            preconditionFailure("MTP-84 frequency / loss / drawdown fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveRiskTerm],
        futureGates: [LiveFrequencyLossDrawdownFutureGate],
        forbiddenCapabilities: [LiveFrequencyLossDrawdownForbiddenCapability],
        allowedEvidenceKinds: [LiveRiskEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureGateOnly: Bool,
        providesLiveRiskEngine: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        readsRealPnL: Bool,
        readsRealAccountEquity: Bool,
        countsLiveOrderFrequency: Bool,
        enforcesFrequencyThrottle: Bool,
        evaluatesRealLossLimit: Bool,
        evaluatesRealDrawdownLimit: Bool,
        runsDrawdownCircuitBreaker: Bool,
        evaluatesRealPreTradeAllow: Bool,
        evaluatesRealPreTradeReject: Bool,
        authorizesLiveTrading: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        runsCircuitBreakerCommand: Bool,
        runsStopTradingCommand: Bool,
        runsEmergencyStopCommand: Bool,
        mapsPaperRiskBlockerToFrequencyLossDrawdownGate: Bool,
        mapsPaperExposureToLossDrawdownGate: Bool,
        providesRiskCommandSurface: Bool,
        providesPositionManagementCommand: Bool,
        exposesOrderForm: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }

        let forbiddenFlags = [
            ("providesLiveRiskEngine", providesLiveRiskEngine),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("readsRealPnL", readsRealPnL),
            ("readsRealAccountEquity", readsRealAccountEquity),
            ("countsLiveOrderFrequency", countsLiveOrderFrequency),
            ("enforcesFrequencyThrottle", enforcesFrequencyThrottle),
            ("evaluatesRealLossLimit", evaluatesRealLossLimit),
            ("evaluatesRealDrawdownLimit", evaluatesRealDrawdownLimit),
            ("runsDrawdownCircuitBreaker", runsDrawdownCircuitBreaker),
            ("evaluatesRealPreTradeAllow", evaluatesRealPreTradeAllow),
            ("evaluatesRealPreTradeReject", evaluatesRealPreTradeReject),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("runsCircuitBreakerCommand", runsCircuitBreakerCommand),
            ("runsStopTradingCommand", runsStopTradingCommand),
            ("runsEmergencyStopCommand", runsEmergencyStopCommand),
            ("mapsPaperRiskBlockerToFrequencyLossDrawdownGate", mapsPaperRiskBlockerToFrequencyLossDrawdownGate),
            ("mapsPaperExposureToLossDrawdownGate", mapsPaperExposureToLossDrawdownGate),
            ("providesRiskCommandSurface", providesRiskCommandSurface),
            ("providesPositionManagementCommand", providesPositionManagementCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// FutureRiskDecisionTaxonomyTerm 固定 MTP-82 的 future risk decision 分类。
///
/// `allowed`、`blocked`、`degraded` 和 `no-trade` 只是 Future taxonomy label，不能被解释为
/// 当前 Swift runtime decision、broker reject、account-derived state 或 Dashboard 交易控制。
public enum FutureRiskDecisionTaxonomyTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allowed
    case blocked
    case degraded
    case noTrade = "no-trade"
}

/// LiveRiskGateFutureGate 描述 Future Live Risk 进入实现前必须补齐的 gate。
///
/// Gate 只表达后续 Project Definition 前的必要条件；当前 MTP-82 不实现账户读取、仓位同步、
/// margin / leverage、真实 pre-trade 允许 / 拒绝、熔断 runtime、禁交易状态 runtime 或交易按钮。
public enum LiveRiskGateFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveRiskDecision = "Human independent Live risk decision"
    case liveTradingFoundationBoundarySatisfied = "Live trading foundation boundary satisfied"
    case liveExecutionControlBoundarySatisfied = "Live execution control boundary satisfied"
    case exposureGateContractDefined = "exposure gate contract defined"
    case orderNotionalGateContractDefined = "order notional gate contract defined"
    case frequencyGateContractDefined = "frequency gate contract defined"
    case lossDrawdownGateContractDefined = "loss / drawdown gate contract defined"
    case circuitBreakerContractDefined = "circuit breaker contract defined"
    case noTradeStateContractDefined = "no-trade state contract defined"
    case paperLiveRiskIsolationContractDefined = "paper / live risk isolation contract defined"
    case readModelOnlyBlockedEvidenceDefined = "read-model-only risk blocked evidence defined"
    case operationsAuditHandoffDefined = "operations / audit handoff defined"
}

/// LiveRiskForbiddenCapability 枚举 MTP-82 必须保持禁止的能力面。
///
/// 这些值可以进入 deterministic forbidden tests 和 PR evidence，但不能出现在当前可执行 API、
/// adapter、runtime、account reader、paper evidence 升级路径、UI command 或网络请求中。
public enum LiveRiskForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionSync = "broker position sync"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case realPreTradeRiskEngine = "real pre-trade risk engine"
    case realPreTradeAllowRuntime = "real pre-trade allow runtime"
    case realPreTradeRejectRuntime = "real pre-trade reject runtime"
    case circuitBreakerRuntime = "circuit breaker runtime"
    case noTradeStateRuntime = "no-trade state runtime"
    case liveOrderCommand = "live order command"
    case riskCommandSurface = "risk command surface"
    case positionManagementCommand = "position management command"
    case orderForm = "order form"
    case tradingButton = "trading button"
    case paperRiskBlockerUpgrade = "paper risk blocker upgrade"
    case paperExposureUpgrade = "paper exposure upgrade"
}

/// LiveRiskEvidenceKind 限定 MTP-82 当前可以输出的非执行证据。
///
/// Evidence 只用于合同、validation anchor、deterministic tests 和 PR 审计；Dashboard / Report
/// 展示面、blocked evidence read model 和 automation readiness 阶段收口保留给后续 issue。
public enum LiveRiskEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case validationMatrixCandidate = "validation matrix candidate"
    case validationPlanAnchor = "validation plan anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case paperLiveRiskIsolationEvidence = "paper / live risk isolation evidence"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveRiskTerminologyBoundary 是 MTP-82 的 Future-only terminology / taxonomy fixture。
///
/// 该 fixture 只把 live pre-trade risk、future risk decision taxonomy、future gates 和
/// forbidden capability baseline 固定为可测试合同。所有真实账户、broker position、margin、
/// leverage、signed/account/listenKey、broker adapter、pre-trade allow / reject runtime、
/// circuit breaker / no-trade runtime、UI command 和 paper-to-live-risk upgrade 旗标必须保持关闭。
public struct LiveRiskTerminologyBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveRiskTerm]
    public let decisionTaxonomy: [FutureRiskDecisionTaxonomyTerm]
    public let futureGates: [LiveRiskGateFutureGate]
    public let forbiddenCapabilities: [LiveRiskForbiddenCapability]
    public let allowedEvidenceKinds: [LiveRiskEvidenceKind]
    public let validationAnchors: [String]
    public let paperIsolationSourceAnchors: [String]
    public let isFutureOnlyTerminology: Bool
    public let providesLiveRiskEngine: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let computesLiveExposureFromAccountState: Bool
    public let evaluatesRealPreTradeAllow: Bool
    public let evaluatesRealPreTradeReject: Bool
    public let runsCircuitBreaker: Bool
    public let entersNoTradeState: Bool
    public let authorizesLiveTrading: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let providesRiskCommandSurface: Bool
    public let providesPositionManagementCommand: Bool
    public let exposesOrderForm: Bool
    public let providesTradingButton: Bool
    public let mapsPaperRiskBlockerToFutureRiskDecision: Bool
    public let mapsPaperExposureToRealAccountState: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var terminologyBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && decisionTaxonomy == Self.requiredDecisionTaxonomy
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors
            && allForbiddenFlagsRemainFalse
    }

    public var futureRiskDecisionTaxonomyBoundaryHeld: Bool {
        decisionTaxonomy == Self.requiredDecisionTaxonomy
            && isFutureOnlyTerminology
            && providesLiveRiskEngine == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
    }

    public var paperLiveRiskIsolationBoundaryHeld: Bool {
        paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors
            && mapsPaperRiskBlockerToFutureRiskDecision == false
            && mapsPaperExposureToRealAccountState == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && computesLiveExposureFromAccountState == false
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isFutureOnlyTerminology
            && providesLiveRiskEngine == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && computesLiveExposureFromAccountState == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && runsCircuitBreaker == false
            && entersNoTradeState == false
            && authorizesLiveTrading == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
            && mapsPaperRiskBlockerToFutureRiskDecision == false
            && mapsPaperExposureToRealAccountState == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-82-live-risk-terminology-boundary"),
        issueID: Identifier = try! Identifier("MTP-82"),
        terms: [LiveRiskTerm] = Self.requiredTerms,
        decisionTaxonomy: [FutureRiskDecisionTaxonomyTerm] = Self.requiredDecisionTaxonomy,
        futureGates: [LiveRiskGateFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveRiskForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveRiskEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        paperIsolationSourceAnchors: [String] = Self.requiredPaperIsolationSourceAnchors,
        isFutureOnlyTerminology: Bool = true,
        providesLiveRiskEngine: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        computesLiveExposureFromAccountState: Bool = false,
        evaluatesRealPreTradeAllow: Bool = false,
        evaluatesRealPreTradeReject: Bool = false,
        runsCircuitBreaker: Bool = false,
        entersNoTradeState: Bool = false,
        authorizesLiveTrading: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        providesRiskCommandSurface: Bool = false,
        providesPositionManagementCommand: Bool = false,
        exposesOrderForm: Bool = false,
        providesTradingButton: Bool = false,
        mapsPaperRiskBlockerToFutureRiskDecision: Bool = false,
        mapsPaperExposureToRealAccountState: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            decisionTaxonomy: decisionTaxonomy,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            paperIsolationSourceAnchors: paperIsolationSourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureOnlyTerminology: isFutureOnlyTerminology,
            providesLiveRiskEngine: providesLiveRiskEngine,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            computesLiveExposureFromAccountState: computesLiveExposureFromAccountState,
            evaluatesRealPreTradeAllow: evaluatesRealPreTradeAllow,
            evaluatesRealPreTradeReject: evaluatesRealPreTradeReject,
            runsCircuitBreaker: runsCircuitBreaker,
            entersNoTradeState: entersNoTradeState,
            authorizesLiveTrading: authorizesLiveTrading,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            providesRiskCommandSurface: providesRiskCommandSurface,
            providesPositionManagementCommand: providesPositionManagementCommand,
            exposesOrderForm: exposesOrderForm,
            providesTradingButton: providesTradingButton,
            mapsPaperRiskBlockerToFutureRiskDecision: mapsPaperRiskBlockerToFutureRiskDecision,
            mapsPaperExposureToRealAccountState: mapsPaperExposureToRealAccountState,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.decisionTaxonomy = decisionTaxonomy
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.paperIsolationSourceAnchors = paperIsolationSourceAnchors
        self.isFutureOnlyTerminology = isFutureOnlyTerminology
        self.providesLiveRiskEngine = providesLiveRiskEngine
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.computesLiveExposureFromAccountState = computesLiveExposureFromAccountState
        self.evaluatesRealPreTradeAllow = evaluatesRealPreTradeAllow
        self.evaluatesRealPreTradeReject = evaluatesRealPreTradeReject
        self.runsCircuitBreaker = runsCircuitBreaker
        self.entersNoTradeState = entersNoTradeState
        self.authorizesLiveTrading = authorizesLiveTrading
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.providesRiskCommandSurface = providesRiskCommandSurface
        self.providesPositionManagementCommand = providesPositionManagementCommand
        self.exposesOrderForm = exposesOrderForm
        self.providesTradingButton = providesTradingButton
        self.mapsPaperRiskBlockerToFutureRiskDecision = mapsPaperRiskBlockerToFutureRiskDecision
        self.mapsPaperExposureToRealAccountState = mapsPaperExposureToRealAccountState
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveRiskTerm].self, forKey: .terms),
            decisionTaxonomy: try container.decode(
                [FutureRiskDecisionTaxonomyTerm].self,
                forKey: .decisionTaxonomy
            ),
            futureGates: try container.decode([LiveRiskGateFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveRiskForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode([LiveRiskEvidenceKind].self, forKey: .allowedEvidenceKinds),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            paperIsolationSourceAnchors: try container.decode([String].self, forKey: .paperIsolationSourceAnchors),
            isFutureOnlyTerminology: try container.decode(Bool.self, forKey: .isFutureOnlyTerminology),
            providesLiveRiskEngine: try container.decode(Bool.self, forKey: .providesLiveRiskEngine),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            computesLiveExposureFromAccountState: try container.decode(
                Bool.self,
                forKey: .computesLiveExposureFromAccountState
            ),
            evaluatesRealPreTradeAllow: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeAllow),
            evaluatesRealPreTradeReject: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeReject),
            runsCircuitBreaker: try container.decode(Bool.self, forKey: .runsCircuitBreaker),
            entersNoTradeState: try container.decode(Bool.self, forKey: .entersNoTradeState),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            providesRiskCommandSurface: try container.decode(Bool.self, forKey: .providesRiskCommandSurface),
            providesPositionManagementCommand: try container.decode(
                Bool.self,
                forKey: .providesPositionManagementCommand
            ),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            mapsPaperRiskBlockerToFutureRiskDecision: try container.decode(
                Bool.self,
                forKey: .mapsPaperRiskBlockerToFutureRiskDecision
            ),
            mapsPaperExposureToRealAccountState: try container.decode(
                Bool.self,
                forKey: .mapsPaperExposureToRealAccountState
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: LiveRiskForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredTerms: [LiveRiskTerm] = LiveRiskTerm.allCases

    public static let requiredDecisionTaxonomy: [FutureRiskDecisionTaxonomyTerm] =
        FutureRiskDecisionTaxonomyTerm.allCases

    public static let requiredFutureGates: [LiveRiskGateFutureGate] = [
        .humanLiveRiskDecision,
        .liveTradingFoundationBoundarySatisfied,
        .liveExecutionControlBoundarySatisfied,
        .exposureGateContractDefined,
        .orderNotionalGateContractDefined,
        .frequencyGateContractDefined,
        .lossDrawdownGateContractDefined,
        .circuitBreakerContractDefined,
        .noTradeStateContractDefined,
        .paperLiveRiskIsolationContractDefined,
        .readModelOnlyBlockedEvidenceDefined,
        .operationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveRiskForbiddenCapability] =
        LiveRiskForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveRiskEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperLiveRiskIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-82-LIVE-RISK-TERMINOLOGY",
        "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
        "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION",
        "MTP-82-NO-LIVE-RISK-RUNTIME",
        "MTP-82-LIVE-RISK-GATE-VALIDATION",
        "TVM-LIVE-RISK-GATE"
    ]

    public static let requiredPaperIsolationSourceAnchors: [String] = [
        "TVM-RISK-BLOCKER",
        "TVM-PORTFOLIO-EXPOSURE",
        "TVM-PAPER-EXECUTION-DECISION",
        "TVM-PAPER-SIMULATED-FILL",
        "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE",
        "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION"
    ]

    public static let deterministicFixture: LiveRiskTerminologyBoundary = {
        do {
            return try LiveRiskTerminologyBoundary()
        } catch {
            preconditionFailure("MTP-82 Live risk terminology fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveRiskTerm],
        decisionTaxonomy: [FutureRiskDecisionTaxonomyTerm],
        futureGates: [LiveRiskGateFutureGate],
        forbiddenCapabilities: [LiveRiskForbiddenCapability],
        allowedEvidenceKinds: [LiveRiskEvidenceKind],
        validationAnchors: [String],
        paperIsolationSourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard decisionTaxonomy == Self.requiredDecisionTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisionTaxonomy",
                expected: Self.requiredDecisionTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: decisionTaxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard paperIsolationSourceAnchors == Self.requiredPaperIsolationSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "paperIsolationSourceAnchors",
                expected: Self.requiredPaperIsolationSourceAnchors.joined(separator: ","),
                actual: paperIsolationSourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureOnlyTerminology: Bool,
        providesLiveRiskEngine: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        computesLiveExposureFromAccountState: Bool,
        evaluatesRealPreTradeAllow: Bool,
        evaluatesRealPreTradeReject: Bool,
        runsCircuitBreaker: Bool,
        entersNoTradeState: Bool,
        authorizesLiveTrading: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        providesRiskCommandSurface: Bool,
        providesPositionManagementCommand: Bool,
        exposesOrderForm: Bool,
        providesTradingButton: Bool,
        mapsPaperRiskBlockerToFutureRiskDecision: Bool,
        mapsPaperExposureToRealAccountState: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureOnlyTerminology else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureOnlyTerminology")
        }

        let forbiddenFlags = [
            ("providesLiveRiskEngine", providesLiveRiskEngine),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("computesLiveExposureFromAccountState", computesLiveExposureFromAccountState),
            ("evaluatesRealPreTradeAllow", evaluatesRealPreTradeAllow),
            ("evaluatesRealPreTradeReject", evaluatesRealPreTradeReject),
            ("runsCircuitBreaker", runsCircuitBreaker),
            ("entersNoTradeState", entersNoTradeState),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("providesRiskCommandSurface", providesRiskCommandSurface),
            ("providesPositionManagementCommand", providesPositionManagementCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("providesTradingButton", providesTradingButton),
            ("mapsPaperRiskBlockerToFutureRiskDecision", mapsPaperRiskBlockerToFutureRiskDecision),
            ("mapsPaperExposureToRealAccountState", mapsPaperExposureToRealAccountState),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveExposureOrderNotionalFutureGate 固定 MTP-83 的 exposure / order notional 未来门槛。
///
/// 这些 gate 只描述 Future Live Risk 在后续 Project Definition 前必须补齐的合同、
/// 账户来源、仓位来源、额度策略和审计条件；当前阶段不得把 gate 解释为真实账户读取、
/// broker position sync、margin / leverage 读取或 real pre-trade allow / reject runtime。
public enum LiveExposureOrderNotionalFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveRiskDecision = "Human independent Live risk decision"
    case liveTradingFoundationBoundarySatisfied = "Live trading foundation boundary satisfied"
    case liveExecutionControlBoundarySatisfied = "Live execution control boundary satisfied"
    case accountStateSourceContractDefined = "future account state source contract defined"
    case brokerPositionSourceContractDefined = "future broker position source contract defined"
    case marginLeverageSourceContractDefined = "future margin / leverage source contract defined"
    case exposureLimitPolicyDefined = "future exposure limit policy defined"
    case orderNotionalLimitPolicyDefined = "future order notional limit policy defined"
    case paperExposureIsolationDefined = "paper exposure isolation defined"
    case operationsAuditHandoffDefined = "future operations / audit handoff defined"
}

/// LiveExposureOrderNotionalForbiddenCapability 枚举 MTP-83 必须阻断的能力面。
///
/// 这些值用于 deterministic forbidden capability tests 和 PR evidence；它们不能出现在
/// 当前 API、adapter、Runtime、账户读取、paper exposure 升级路径、UI command 或网络请求中。
public enum LiveExposureOrderNotionalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionSync = "broker position sync"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case realAccountExposureCalculation = "real account exposure calculation"
    case realOrderNotionalLimitEvaluation = "real order notional limit evaluation"
    case realPreTradeRiskEngine = "real pre-trade risk engine"
    case realPreTradeAllowRuntime = "real pre-trade allow runtime"
    case realPreTradeRejectRuntime = "real pre-trade reject runtime"
    case liveOrderSubmit = "live order submit"
    case liveOrderCancel = "live order cancel"
    case liveOrderReplace = "live order replace"
    case paperExposureUpgrade = "paper exposure upgrade"
    case paperRiskBlockerUpgrade = "paper risk blocker upgrade"
    case riskCommandSurface = "risk command surface"
    case positionManagementCommand = "position management command"
    case orderForm = "order form"
    case tradingButton = "trading button"
}

/// LiveExposureOrderNotionalGateBoundary 是 MTP-83 的 exposure / order notional gate fixture。
///
/// 该 fixture 只定义 exposure gate、order notional gate、future gate 条件、forbidden
/// capability tests 和 paper exposure 隔离证据。所有真实账户余额、broker position、margin、
/// leverage、账户派生 exposure、真实订单金额 allow / reject、真实风控引擎、交易命令和
/// paper-to-live exposure 升级路径都必须保持关闭。
public struct LiveExposureOrderNotionalGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveRiskTerm]
    public let futureGates: [LiveExposureOrderNotionalFutureGate]
    public let forbiddenCapabilities: [LiveExposureOrderNotionalForbiddenCapability]
    public let allowedEvidenceKinds: [LiveRiskEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isFutureGateOnly: Bool
    public let providesLiveRiskEngine: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let computesLiveExposureFromAccountState: Bool
    public let evaluatesRealOrderNotionalLimit: Bool
    public let evaluatesRealPreTradeAllow: Bool
    public let evaluatesRealPreTradeReject: Bool
    public let authorizesLiveTrading: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let mapsPaperExposureToLiveExposureGate: Bool
    public let mapsPaperRiskBlockerToFutureRiskDecision: Bool
    public let providesRiskCommandSurface: Bool
    public let providesPositionManagementCommand: Bool
    public let exposesOrderForm: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var exposureOrderNotionalBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && allForbiddenFlagsRemainFalse
    }

    public var accountPositionMarginLeverageBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && computesLiveExposureFromAccountState == false
            && evaluatesRealOrderNotionalLimit == false
            && callsAccountEndpoint == false
            && createsListenKey == false
    }

    public var paperExposureIsolationBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors
            && mapsPaperExposureToLiveExposureGate == false
            && mapsPaperRiskBlockerToFutureRiskDecision == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && computesLiveExposureFromAccountState == false
    }

    public var allPreTradeDecisionsBlocked: Bool {
        providesLiveRiskEngine == false
            && evaluatesRealOrderNotionalLimit == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isFutureGateOnly
            && providesLiveRiskEngine == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && computesLiveExposureFromAccountState == false
            && evaluatesRealOrderNotionalLimit == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && mapsPaperExposureToLiveExposureGate == false
            && mapsPaperRiskBlockerToFutureRiskDecision == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public func forbidsCapability(_ capability: LiveExposureOrderNotionalForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-83-exposure-order-notional-boundary"),
        issueID: Identifier = try! Identifier("MTP-83"),
        terms: [LiveRiskTerm] = Self.requiredTerms,
        futureGates: [LiveExposureOrderNotionalFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveExposureOrderNotionalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveRiskEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isFutureGateOnly: Bool = true,
        providesLiveRiskEngine: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        computesLiveExposureFromAccountState: Bool = false,
        evaluatesRealOrderNotionalLimit: Bool = false,
        evaluatesRealPreTradeAllow: Bool = false,
        evaluatesRealPreTradeReject: Bool = false,
        authorizesLiveTrading: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        mapsPaperExposureToLiveExposureGate: Bool = false,
        mapsPaperRiskBlockerToFutureRiskDecision: Bool = false,
        providesRiskCommandSurface: Bool = false,
        providesPositionManagementCommand: Bool = false,
        exposesOrderForm: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureGateOnly: isFutureGateOnly,
            providesLiveRiskEngine: providesLiveRiskEngine,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            computesLiveExposureFromAccountState: computesLiveExposureFromAccountState,
            evaluatesRealOrderNotionalLimit: evaluatesRealOrderNotionalLimit,
            evaluatesRealPreTradeAllow: evaluatesRealPreTradeAllow,
            evaluatesRealPreTradeReject: evaluatesRealPreTradeReject,
            authorizesLiveTrading: authorizesLiveTrading,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            mapsPaperExposureToLiveExposureGate: mapsPaperExposureToLiveExposureGate,
            mapsPaperRiskBlockerToFutureRiskDecision: mapsPaperRiskBlockerToFutureRiskDecision,
            providesRiskCommandSurface: providesRiskCommandSurface,
            providesPositionManagementCommand: providesPositionManagementCommand,
            exposesOrderForm: exposesOrderForm,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isFutureGateOnly = isFutureGateOnly
        self.providesLiveRiskEngine = providesLiveRiskEngine
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.computesLiveExposureFromAccountState = computesLiveExposureFromAccountState
        self.evaluatesRealOrderNotionalLimit = evaluatesRealOrderNotionalLimit
        self.evaluatesRealPreTradeAllow = evaluatesRealPreTradeAllow
        self.evaluatesRealPreTradeReject = evaluatesRealPreTradeReject
        self.authorizesLiveTrading = authorizesLiveTrading
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.mapsPaperExposureToLiveExposureGate = mapsPaperExposureToLiveExposureGate
        self.mapsPaperRiskBlockerToFutureRiskDecision = mapsPaperRiskBlockerToFutureRiskDecision
        self.providesRiskCommandSurface = providesRiskCommandSurface
        self.providesPositionManagementCommand = providesPositionManagementCommand
        self.exposesOrderForm = exposesOrderForm
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveRiskTerm].self, forKey: .terms),
            futureGates: try container.decode(
                [LiveExposureOrderNotionalFutureGate].self,
                forKey: .futureGates
            ),
            forbiddenCapabilities: try container.decode(
                [LiveExposureOrderNotionalForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode([LiveRiskEvidenceKind].self, forKey: .allowedEvidenceKinds),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            providesLiveRiskEngine: try container.decode(Bool.self, forKey: .providesLiveRiskEngine),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            computesLiveExposureFromAccountState: try container.decode(
                Bool.self,
                forKey: .computesLiveExposureFromAccountState
            ),
            evaluatesRealOrderNotionalLimit: try container.decode(
                Bool.self,
                forKey: .evaluatesRealOrderNotionalLimit
            ),
            evaluatesRealPreTradeAllow: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeAllow),
            evaluatesRealPreTradeReject: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeReject),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            mapsPaperExposureToLiveExposureGate: try container.decode(
                Bool.self,
                forKey: .mapsPaperExposureToLiveExposureGate
            ),
            mapsPaperRiskBlockerToFutureRiskDecision: try container.decode(
                Bool.self,
                forKey: .mapsPaperRiskBlockerToFutureRiskDecision
            ),
            providesRiskCommandSurface: try container.decode(Bool.self, forKey: .providesRiskCommandSurface),
            providesPositionManagementCommand: try container.decode(
                Bool.self,
                forKey: .providesPositionManagementCommand
            ),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerms: [LiveRiskTerm] = [
        .exposureGate,
        .orderNotionalGate
    ]

    public static let requiredFutureGates: [LiveExposureOrderNotionalFutureGate] = [
        .humanLiveRiskDecision,
        .liveTradingFoundationBoundarySatisfied,
        .liveExecutionControlBoundarySatisfied,
        .accountStateSourceContractDefined,
        .brokerPositionSourceContractDefined,
        .marginLeverageSourceContractDefined,
        .exposureLimitPolicyDefined,
        .orderNotionalLimitPolicyDefined,
        .paperExposureIsolationDefined,
        .operationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveExposureOrderNotionalForbiddenCapability] =
        LiveExposureOrderNotionalForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveRiskEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperLiveRiskIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
        "MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS",
        "MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT",
        "MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE",
        "MTP-83-LIVE-RISK-GATE-VALIDATION",
        "TVM-LIVE-RISK-GATE"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-82-LIVE-RISK-TERMINOLOGY",
        "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
        "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION",
        "TVM-PORTFOLIO-EXPOSURE",
        "TVM-RISK-BLOCKER",
        "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
    ]

    public static let deterministicFixture: LiveExposureOrderNotionalGateBoundary = {
        do {
            return try LiveExposureOrderNotionalGateBoundary()
        } catch {
            preconditionFailure("MTP-83 exposure / order notional fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveRiskTerm],
        futureGates: [LiveExposureOrderNotionalFutureGate],
        forbiddenCapabilities: [LiveExposureOrderNotionalForbiddenCapability],
        allowedEvidenceKinds: [LiveRiskEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureGateOnly: Bool,
        providesLiveRiskEngine: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        computesLiveExposureFromAccountState: Bool,
        evaluatesRealOrderNotionalLimit: Bool,
        evaluatesRealPreTradeAllow: Bool,
        evaluatesRealPreTradeReject: Bool,
        authorizesLiveTrading: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        mapsPaperExposureToLiveExposureGate: Bool,
        mapsPaperRiskBlockerToFutureRiskDecision: Bool,
        providesRiskCommandSurface: Bool,
        providesPositionManagementCommand: Bool,
        exposesOrderForm: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }

        let forbiddenFlags = [
            ("providesLiveRiskEngine", providesLiveRiskEngine),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("computesLiveExposureFromAccountState", computesLiveExposureFromAccountState),
            ("evaluatesRealOrderNotionalLimit", evaluatesRealOrderNotionalLimit),
            ("evaluatesRealPreTradeAllow", evaluatesRealPreTradeAllow),
            ("evaluatesRealPreTradeReject", evaluatesRealPreTradeReject),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("mapsPaperExposureToLiveExposureGate", mapsPaperExposureToLiveExposureGate),
            ("mapsPaperRiskBlockerToFutureRiskDecision", mapsPaperRiskBlockerToFutureRiskDecision),
            ("providesRiskCommandSurface", providesRiskCommandSurface),
            ("providesPositionManagementCommand", providesPositionManagementCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveCircuitBreakerNoTradeFutureGate 固定 MTP-85 的 circuit breaker / no-trade state 未来门槛。
///
/// 这些 gate 只描述 Future Live Risk 在后续 Project Definition 前必须补齐的熔断策略、
/// 禁交易状态策略、触发来源合同、状态迁移策略和审计交接条件；当前阶段不得把 gate
/// 解释为真实熔断 runtime、全局交易锁、停机命令、自动恢复命令或 UI 交易控制。
public enum LiveCircuitBreakerNoTradeFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveRiskDecision = "Human independent Live risk decision"
    case liveTradingFoundationBoundarySatisfied = "Live trading foundation boundary satisfied"
    case liveExecutionControlBoundarySatisfied = "Live execution control boundary satisfied"
    case exposureOrderNotionalBoundarySatisfied = "exposure / order notional boundary satisfied"
    case frequencyLossDrawdownBoundarySatisfied = "frequency / loss / drawdown boundary satisfied"
    case circuitBreakerPolicyDefined = "future circuit breaker policy defined"
    case circuitBreakerTriggerSourceContractDefined = "future circuit breaker trigger source contract defined"
    case noTradeStatePolicyDefined = "future no-trade state policy defined"
    case noTradeStateTransitionPolicyDefined = "future no-trade state transition policy defined"
    case operationsAuditHandoffDefined = "future operations / audit handoff defined"
}

/// LiveCircuitBreakerNoTradeForbiddenCapability 枚举 MTP-85 必须阻断的能力面。
///
/// 这些值只用于 deterministic forbidden capability tests 和 PR evidence；它们不能出现在
/// 当前 API、adapter、Runtime、熔断服务、禁交易状态机、停机 / 恢复命令、UI command 或网络请求中。
public enum LiveCircuitBreakerNoTradeForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionSync = "broker position sync"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case realPnLRead = "real PnL read"
    case realAccountEquityRead = "real account equity read"
    case realLossLimitEvaluation = "real loss limit evaluation"
    case realDrawdownLimitEvaluation = "real drawdown limit evaluation"
    case realPreTradeRiskEngine = "real pre-trade risk engine"
    case realPreTradeAllowRuntime = "real pre-trade allow runtime"
    case realPreTradeRejectRuntime = "real pre-trade reject runtime"
    case circuitBreakerRuntime = "circuit breaker runtime"
    case noTradeStateRuntime = "no-trade state runtime"
    case noTradeStateTransitionRuntime = "no-trade state transition runtime"
    case globalTradingLockRuntime = "global trading lock runtime"
    case brokerSessionStateMutation = "broker session state mutation"
    case circuitBreakerCommand = "circuit breaker command"
    case stopTradingCommand = "stop trading command"
    case emergencyStopCommand = "emergency stop command"
    case automaticRecoveryCommand = "automatic recovery command"
    case productionShutdownControl = "production shutdown control"
    case liveOrderSubmit = "live order submit"
    case liveOrderCancel = "live order cancel"
    case liveOrderReplace = "live order replace"
    case paperRiskBlockerUpgrade = "paper risk blocker upgrade"
    case paperExposureUpgrade = "paper exposure upgrade"
    case riskCommandSurface = "risk command surface"
    case positionManagementCommand = "position management command"
    case orderForm = "order form"
    case tradingButton = "trading button"
}

/// LiveCircuitBreakerNoTradeGateBoundary 是 MTP-85 的 circuit breaker / no-trade state gate fixture。
///
/// 该 fixture 只定义 circuit breaker gate、no-trade state gate、future gate 条件、forbidden
/// capability tests 和 paper risk / exposure 不升级证据。所有真实熔断服务、禁交易状态 runtime、
/// 全局交易锁、broker session 变更、停机 / 恢复命令、交易命令和 UI 控制都必须保持关闭。
public struct LiveCircuitBreakerNoTradeGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveRiskTerm]
    public let futureGates: [LiveCircuitBreakerNoTradeFutureGate]
    public let forbiddenCapabilities: [LiveCircuitBreakerNoTradeForbiddenCapability]
    public let allowedEvidenceKinds: [LiveRiskEvidenceKind]
    public let validationAnchors: [String]
    public let sourceAnchors: [String]
    public let isFutureGateOnly: Bool
    public let providesLiveRiskEngine: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let readsRealPnL: Bool
    public let readsRealAccountEquity: Bool
    public let evaluatesRealLossLimit: Bool
    public let evaluatesRealDrawdownLimit: Bool
    public let evaluatesRealPreTradeAllow: Bool
    public let evaluatesRealPreTradeReject: Bool
    public let runsCircuitBreakerRuntime: Bool
    public let entersNoTradeStateRuntime: Bool
    public let mutatesNoTradeState: Bool
    public let runsGlobalTradingLock: Bool
    public let mutatesBrokerSessionState: Bool
    public let runsCircuitBreakerCommand: Bool
    public let runsStopTradingCommand: Bool
    public let runsEmergencyStopCommand: Bool
    public let runsAutomaticRecoveryCommand: Bool
    public let controlsProductionShutdown: Bool
    public let authorizesLiveTrading: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let mapsPaperRiskBlockerToCircuitBreakerNoTradeGate: Bool
    public let mapsPaperExposureToCircuitBreakerNoTradeGate: Bool
    public let providesRiskCommandSurface: Bool
    public let providesPositionManagementCommand: Bool
    public let exposesOrderForm: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var circuitBreakerNoTradeBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && sourceAnchors == Self.requiredSourceAnchors
            && allForbiddenFlagsRemainFalse
    }

    public var circuitBreakerRuntimeBoundaryHeld: Bool {
        runsCircuitBreakerRuntime == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && runsCircuitBreakerCommand == false
            && runsStopTradingCommand == false
            && runsEmergencyStopCommand == false
    }

    public var noTradeStateRuntimeBoundaryHeld: Bool {
        entersNoTradeStateRuntime == false
            && mutatesNoTradeState == false
            && runsGlobalTradingLock == false
            && mutatesBrokerSessionState == false
            && authorizesLiveTrading == false
    }

    public var operationsCommandBoundaryHeld: Bool {
        runsAutomaticRecoveryCommand == false
            && controlsProductionShutdown == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
    }

    public var paperRiskExposureIsolationBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors
            && mapsPaperRiskBlockerToCircuitBreakerNoTradeGate == false
            && mapsPaperExposureToCircuitBreakerNoTradeGate == false
            && readsRealAccountBalance == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
    }

    public var allPreTradeDecisionsBlocked: Bool {
        providesLiveRiskEngine == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && authorizesLiveTrading == false
            && submitsRealOrder == false
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        isFutureGateOnly
            && providesLiveRiskEngine == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && runsCircuitBreakerRuntime == false
            && entersNoTradeStateRuntime == false
            && mutatesNoTradeState == false
            && runsGlobalTradingLock == false
            && mutatesBrokerSessionState == false
            && runsCircuitBreakerCommand == false
            && runsStopTradingCommand == false
            && runsEmergencyStopCommand == false
            && runsAutomaticRecoveryCommand == false
            && controlsProductionShutdown == false
            && authorizesLiveTrading == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && mapsPaperRiskBlockerToCircuitBreakerNoTradeGate == false
            && mapsPaperExposureToCircuitBreakerNoTradeGate == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public func forbidsCapability(_ capability: LiveCircuitBreakerNoTradeForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-85-circuit-breaker-no-trade-boundary"),
        issueID: Identifier = try! Identifier("MTP-85"),
        terms: [LiveRiskTerm] = Self.requiredTerms,
        futureGates: [LiveCircuitBreakerNoTradeFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveCircuitBreakerNoTradeForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveRiskEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        isFutureGateOnly: Bool = true,
        providesLiveRiskEngine: Bool = false,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        readsRealAccountBalance: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        readsRealPnL: Bool = false,
        readsRealAccountEquity: Bool = false,
        evaluatesRealLossLimit: Bool = false,
        evaluatesRealDrawdownLimit: Bool = false,
        evaluatesRealPreTradeAllow: Bool = false,
        evaluatesRealPreTradeReject: Bool = false,
        runsCircuitBreakerRuntime: Bool = false,
        entersNoTradeStateRuntime: Bool = false,
        mutatesNoTradeState: Bool = false,
        runsGlobalTradingLock: Bool = false,
        mutatesBrokerSessionState: Bool = false,
        runsCircuitBreakerCommand: Bool = false,
        runsStopTradingCommand: Bool = false,
        runsEmergencyStopCommand: Bool = false,
        runsAutomaticRecoveryCommand: Bool = false,
        controlsProductionShutdown: Bool = false,
        authorizesLiveTrading: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        mapsPaperRiskBlockerToCircuitBreakerNoTradeGate: Bool = false,
        mapsPaperExposureToCircuitBreakerNoTradeGate: Bool = false,
        providesRiskCommandSurface: Bool = false,
        providesPositionManagementCommand: Bool = false,
        exposesOrderForm: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            sourceAnchors: sourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureGateOnly: isFutureGateOnly,
            providesLiveRiskEngine: providesLiveRiskEngine,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            readsRealAccountBalance: readsRealAccountBalance,
            syncsBrokerPosition: syncsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            readsRealPnL: readsRealPnL,
            readsRealAccountEquity: readsRealAccountEquity,
            evaluatesRealLossLimit: evaluatesRealLossLimit,
            evaluatesRealDrawdownLimit: evaluatesRealDrawdownLimit,
            evaluatesRealPreTradeAllow: evaluatesRealPreTradeAllow,
            evaluatesRealPreTradeReject: evaluatesRealPreTradeReject,
            runsCircuitBreakerRuntime: runsCircuitBreakerRuntime,
            entersNoTradeStateRuntime: entersNoTradeStateRuntime,
            mutatesNoTradeState: mutatesNoTradeState,
            runsGlobalTradingLock: runsGlobalTradingLock,
            mutatesBrokerSessionState: mutatesBrokerSessionState,
            runsCircuitBreakerCommand: runsCircuitBreakerCommand,
            runsStopTradingCommand: runsStopTradingCommand,
            runsEmergencyStopCommand: runsEmergencyStopCommand,
            runsAutomaticRecoveryCommand: runsAutomaticRecoveryCommand,
            controlsProductionShutdown: controlsProductionShutdown,
            authorizesLiveTrading: authorizesLiveTrading,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            mapsPaperRiskBlockerToCircuitBreakerNoTradeGate: mapsPaperRiskBlockerToCircuitBreakerNoTradeGate,
            mapsPaperExposureToCircuitBreakerNoTradeGate: mapsPaperExposureToCircuitBreakerNoTradeGate,
            providesRiskCommandSurface: providesRiskCommandSurface,
            providesPositionManagementCommand: providesPositionManagementCommand,
            exposesOrderForm: exposesOrderForm,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.sourceAnchors = sourceAnchors
        self.isFutureGateOnly = isFutureGateOnly
        self.providesLiveRiskEngine = providesLiveRiskEngine
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.readsRealPnL = readsRealPnL
        self.readsRealAccountEquity = readsRealAccountEquity
        self.evaluatesRealLossLimit = evaluatesRealLossLimit
        self.evaluatesRealDrawdownLimit = evaluatesRealDrawdownLimit
        self.evaluatesRealPreTradeAllow = evaluatesRealPreTradeAllow
        self.evaluatesRealPreTradeReject = evaluatesRealPreTradeReject
        self.runsCircuitBreakerRuntime = runsCircuitBreakerRuntime
        self.entersNoTradeStateRuntime = entersNoTradeStateRuntime
        self.mutatesNoTradeState = mutatesNoTradeState
        self.runsGlobalTradingLock = runsGlobalTradingLock
        self.mutatesBrokerSessionState = mutatesBrokerSessionState
        self.runsCircuitBreakerCommand = runsCircuitBreakerCommand
        self.runsStopTradingCommand = runsStopTradingCommand
        self.runsEmergencyStopCommand = runsEmergencyStopCommand
        self.runsAutomaticRecoveryCommand = runsAutomaticRecoveryCommand
        self.controlsProductionShutdown = controlsProductionShutdown
        self.authorizesLiveTrading = authorizesLiveTrading
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.mapsPaperRiskBlockerToCircuitBreakerNoTradeGate = mapsPaperRiskBlockerToCircuitBreakerNoTradeGate
        self.mapsPaperExposureToCircuitBreakerNoTradeGate = mapsPaperExposureToCircuitBreakerNoTradeGate
        self.providesRiskCommandSurface = providesRiskCommandSurface
        self.providesPositionManagementCommand = providesPositionManagementCommand
        self.exposesOrderForm = exposesOrderForm
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveRiskTerm].self, forKey: .terms),
            futureGates: try container.decode(
                [LiveCircuitBreakerNoTradeFutureGate].self,
                forKey: .futureGates
            ),
            forbiddenCapabilities: try container.decode(
                [LiveCircuitBreakerNoTradeForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode([LiveRiskEvidenceKind].self, forKey: .allowedEvidenceKinds),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            providesLiveRiskEngine: try container.decode(Bool.self, forKey: .providesLiveRiskEngine),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            readsRealPnL: try container.decode(Bool.self, forKey: .readsRealPnL),
            readsRealAccountEquity: try container.decode(Bool.self, forKey: .readsRealAccountEquity),
            evaluatesRealLossLimit: try container.decode(Bool.self, forKey: .evaluatesRealLossLimit),
            evaluatesRealDrawdownLimit: try container.decode(Bool.self, forKey: .evaluatesRealDrawdownLimit),
            evaluatesRealPreTradeAllow: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeAllow),
            evaluatesRealPreTradeReject: try container.decode(Bool.self, forKey: .evaluatesRealPreTradeReject),
            runsCircuitBreakerRuntime: try container.decode(Bool.self, forKey: .runsCircuitBreakerRuntime),
            entersNoTradeStateRuntime: try container.decode(Bool.self, forKey: .entersNoTradeStateRuntime),
            mutatesNoTradeState: try container.decode(Bool.self, forKey: .mutatesNoTradeState),
            runsGlobalTradingLock: try container.decode(Bool.self, forKey: .runsGlobalTradingLock),
            mutatesBrokerSessionState: try container.decode(Bool.self, forKey: .mutatesBrokerSessionState),
            runsCircuitBreakerCommand: try container.decode(Bool.self, forKey: .runsCircuitBreakerCommand),
            runsStopTradingCommand: try container.decode(Bool.self, forKey: .runsStopTradingCommand),
            runsEmergencyStopCommand: try container.decode(Bool.self, forKey: .runsEmergencyStopCommand),
            runsAutomaticRecoveryCommand: try container.decode(Bool.self, forKey: .runsAutomaticRecoveryCommand),
            controlsProductionShutdown: try container.decode(Bool.self, forKey: .controlsProductionShutdown),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            mapsPaperRiskBlockerToCircuitBreakerNoTradeGate: try container.decode(
                Bool.self,
                forKey: .mapsPaperRiskBlockerToCircuitBreakerNoTradeGate
            ),
            mapsPaperExposureToCircuitBreakerNoTradeGate: try container.decode(
                Bool.self,
                forKey: .mapsPaperExposureToCircuitBreakerNoTradeGate
            ),
            providesRiskCommandSurface: try container.decode(Bool.self, forKey: .providesRiskCommandSurface),
            providesPositionManagementCommand: try container.decode(
                Bool.self,
                forKey: .providesPositionManagementCommand
            ),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerms: [LiveRiskTerm] = [
        .circuitBreaker,
        .noTradeState
    ]

    public static let requiredFutureGates: [LiveCircuitBreakerNoTradeFutureGate] = [
        .humanLiveRiskDecision,
        .liveTradingFoundationBoundarySatisfied,
        .liveExecutionControlBoundarySatisfied,
        .exposureOrderNotionalBoundarySatisfied,
        .frequencyLossDrawdownBoundarySatisfied,
        .circuitBreakerPolicyDefined,
        .circuitBreakerTriggerSourceContractDefined,
        .noTradeStatePolicyDefined,
        .noTradeStateTransitionPolicyDefined,
        .operationsAuditHandoffDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveCircuitBreakerNoTradeForbiddenCapability] =
        LiveCircuitBreakerNoTradeForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveRiskEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .paperLiveRiskIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES",
        "MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS",
        "MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME",
        "MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE",
        "MTP-85-LIVE-RISK-GATE-VALIDATION",
        "TVM-LIVE-RISK-GATE"
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-82-LIVE-RISK-TERMINOLOGY",
        "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
        "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
        "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
        "TVM-RISK-BLOCKER",
        "TVM-PORTFOLIO-EXPOSURE",
        "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
    ]

    public static let deterministicFixture: LiveCircuitBreakerNoTradeGateBoundary = {
        do {
            return try LiveCircuitBreakerNoTradeGateBoundary()
        } catch {
            preconditionFailure("MTP-85 circuit breaker / no-trade fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveRiskTerm],
        futureGates: [LiveCircuitBreakerNoTradeFutureGate],
        forbiddenCapabilities: [LiveCircuitBreakerNoTradeForbiddenCapability],
        allowedEvidenceKinds: [LiveRiskEvidenceKind],
        validationAnchors: [String],
        sourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureGateOnly: Bool,
        providesLiveRiskEngine: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        readsRealPnL: Bool,
        readsRealAccountEquity: Bool,
        evaluatesRealLossLimit: Bool,
        evaluatesRealDrawdownLimit: Bool,
        evaluatesRealPreTradeAllow: Bool,
        evaluatesRealPreTradeReject: Bool,
        runsCircuitBreakerRuntime: Bool,
        entersNoTradeStateRuntime: Bool,
        mutatesNoTradeState: Bool,
        runsGlobalTradingLock: Bool,
        mutatesBrokerSessionState: Bool,
        runsCircuitBreakerCommand: Bool,
        runsStopTradingCommand: Bool,
        runsEmergencyStopCommand: Bool,
        runsAutomaticRecoveryCommand: Bool,
        controlsProductionShutdown: Bool,
        authorizesLiveTrading: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        mapsPaperRiskBlockerToCircuitBreakerNoTradeGate: Bool,
        mapsPaperExposureToCircuitBreakerNoTradeGate: Bool,
        providesRiskCommandSurface: Bool,
        providesPositionManagementCommand: Bool,
        exposesOrderForm: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }

        let forbiddenFlags = [
            ("providesLiveRiskEngine", providesLiveRiskEngine),
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("readsRealPnL", readsRealPnL),
            ("readsRealAccountEquity", readsRealAccountEquity),
            ("evaluatesRealLossLimit", evaluatesRealLossLimit),
            ("evaluatesRealDrawdownLimit", evaluatesRealDrawdownLimit),
            ("evaluatesRealPreTradeAllow", evaluatesRealPreTradeAllow),
            ("evaluatesRealPreTradeReject", evaluatesRealPreTradeReject),
            ("runsCircuitBreakerRuntime", runsCircuitBreakerRuntime),
            ("entersNoTradeStateRuntime", entersNoTradeStateRuntime),
            ("mutatesNoTradeState", mutatesNoTradeState),
            ("runsGlobalTradingLock", runsGlobalTradingLock),
            ("mutatesBrokerSessionState", mutatesBrokerSessionState),
            ("runsCircuitBreakerCommand", runsCircuitBreakerCommand),
            ("runsStopTradingCommand", runsStopTradingCommand),
            ("runsEmergencyStopCommand", runsEmergencyStopCommand),
            ("runsAutomaticRecoveryCommand", runsAutomaticRecoveryCommand),
            ("controlsProductionShutdown", controlsProductionShutdown),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            (
                "mapsPaperRiskBlockerToCircuitBreakerNoTradeGate",
                mapsPaperRiskBlockerToCircuitBreakerNoTradeGate
            ),
            ("mapsPaperExposureToCircuitBreakerNoTradeGate", mapsPaperExposureToCircuitBreakerNoTradeGate),
            ("providesRiskCommandSurface", providesRiskCommandSurface),
            ("providesPositionManagementCommand", providesPositionManagementCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
