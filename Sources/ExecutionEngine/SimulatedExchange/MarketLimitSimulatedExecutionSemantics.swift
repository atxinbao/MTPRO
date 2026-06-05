import DomainModel
import Foundation

/// MTP-113 market / limit order simulated execution semantics 定义基础订单类型的本地模拟执行语义。
///
/// 本文件只消费 MTP-112 deterministic matching output 和 MTP-111 shared order semantics，输出
/// market / limit 的 full fill、reject、expire evidence。它不是订单执行 runtime，不调度订单，
/// 不连接 signed endpoint、account endpoint、listenKey、broker / exchange adapter、OMS、
/// LiveExecutionAdapter，不生成 execution report、broker fill、reconciliation、live command 或交易按钮。

/// MarketLimitSimulatedOrderType 固定 MTP-113 当前允许的基础模拟订单类型。
///
/// `market` 只能使用 deterministic matching output 的 matched price 立即 full fill；
/// `limit` 只能使用显式 limit price 与 deterministic matched price 比较，不实现 stop / OCO / advanced order。
public enum MarketLimitSimulatedOrderType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case market = "market order simulated execution"
    case limit = "limit order simulated execution"
}

/// MarketLimitSimulatedExecutionOutcome 固定 MTP-113 最小模拟执行结果。
///
/// `fullFill`、`rejected` 和 `expired` 只表达 paper-only / simulated evidence。partial fill、latency、
/// fee / slippage parity 和 portfolio projection parity 分别属于后续 MTP-114 / MTP-115。
public enum MarketLimitSimulatedExecutionOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fullFill = "full fill simulated"
    case rejected = "rejected simulated"
    case expired = "expired simulated"
}

/// MarketLimitSimulatedExecutionRule 描述 market / limit semantics 的 deterministic 规则。
///
/// 这些规则只依赖本地 scenario replay matching output、shared order input、limit price 和 append-only
/// simulated event 输出，不使用 wall clock、randomness、真实 order book、broker routing 或 live runtime。
public enum MarketLimitSimulatedExecutionRule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case marketConsumesDeterministicMatchPrice = "market order consumes deterministic match price"
    case marketFullFillsAcceptedOrder = "market order full fills accepted simulated order"
    case limitRequiresExplicitLimitPrice = "limit order requires explicit limit price"
    case buyLimitFillsAtOrBelowLimit = "buy limit fills at or below limit price"
    case buyLimitExpiresAboveLimit = "buy limit expires above limit price"
    case rejectedStateStopsBeforeFill = "rejected simulated state stops before fill"
    case holdSideRejectsAsNonExecutable = "hold side rejects as non-executable simulated order"
    case noPartialFillBeforeMTP114 = "no partial fill before MTP-114"
    case noRealOrderCommandUpgrade = "no real order command upgrade"
}

/// MarketLimitSimulatedExecutionRejectReason 固定 MTP-113 可解释的 reject reason。
///
/// reject reason 只用于本地 simulated evidence，不等于 broker rejection、exchange rejection、
/// real order state machine failure 或 production incident。
public enum MarketLimitSimulatedExecutionRejectReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case rejectedSharedOrderState = "rejected shared order state"
    case nonExecutableHoldSide = "non-executable hold side"
}

/// MarketLimitSimulatedExecutionContract 是 MTP-113 的 market / limit semantics fixture。
///
/// Contract 固定基础订单类型、执行结果、规则、validation anchors 和 forbidden capability baseline。
/// 它只定义 value semantics，不实现 order execution runtime、matching runtime、portfolio runtime 或 UI。
public struct MarketLimitSimulatedExecutionContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let orderTypes: [MarketLimitSimulatedOrderType]
    public let outcomes: [MarketLimitSimulatedExecutionOutcome]
    public let executionRules: [MarketLimitSimulatedExecutionRule]
    public let forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability]
    public let validationAnchors: [String]
    public let consumesDeterministicMatchingOutput: Bool
    public let consumesSharedOrderSemantics: Bool
    public let definesMarketOrderSemantics: Bool
    public let definesLimitOrderSemantics: Bool
    public let definesFullFillRejectExpire: Bool
    public let emitsAppendOnlySimulatedOrderEvent: Bool
    public let implementsOrderExecutionRuntime: Bool
    public let implementsMatchingRuntime: Bool
    public let implementsPortfolioProjectionRuntime: Bool
    public let implementsAdvancedOrderTypes: Bool
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let readsRealAccountBrokerPositionMarginLeverage: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveProConsole: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var contractBoundaryHeld: Bool {
        orderTypes == Self.requiredOrderTypes
            && outcomes == Self.requiredOutcomes
            && executionRules == Self.requiredExecutionRules
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && consumesDeterministicMatchingOutput
            && consumesSharedOrderSemantics
            && definesMarketOrderSemantics
            && definesLimitOrderSemantics
            && definesFullFillRejectExpire
            && emitsAppendOnlySimulatedOrderEvent
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        implementsOrderExecutionRuntime == false
            && implementsMatchingRuntime == false
            && implementsPortfolioProjectionRuntime == false
            && implementsAdvancedOrderTypes == false
            && usesWallClockTime == false
            && usesRandomness == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && readsRealAccountBrokerPositionMarginLeverage == false
            && runsLiveRuntime == false
            && providesLiveProConsole == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-113-market-limit-simulated-execution-semantics"),
        issueID: Identifier = try! Identifier("MTP-113"),
        orderTypes: [MarketLimitSimulatedOrderType] = Self.requiredOrderTypes,
        outcomes: [MarketLimitSimulatedExecutionOutcome] = Self.requiredOutcomes,
        executionRules: [MarketLimitSimulatedExecutionRule] = Self.requiredExecutionRules,
        forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        consumesDeterministicMatchingOutput: Bool = true,
        consumesSharedOrderSemantics: Bool = true,
        definesMarketOrderSemantics: Bool = true,
        definesLimitOrderSemantics: Bool = true,
        definesFullFillRejectExpire: Bool = true,
        emitsAppendOnlySimulatedOrderEvent: Bool = true,
        implementsOrderExecutionRuntime: Bool = false,
        implementsMatchingRuntime: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        implementsAdvancedOrderTypes: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountBrokerPositionMarginLeverage: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validateList(
            field: "marketLimitSimulatedExecutionContract.orderTypes",
            expected: Self.requiredOrderTypes.map(\.rawValue),
            actual: orderTypes.map(\.rawValue)
        )
        try Self.validateList(
            field: "marketLimitSimulatedExecutionContract.outcomes",
            expected: Self.requiredOutcomes.map(\.rawValue),
            actual: outcomes.map(\.rawValue)
        )
        try Self.validateList(
            field: "marketLimitSimulatedExecutionContract.executionRules",
            expected: Self.requiredExecutionRules.map(\.rawValue),
            actual: executionRules.map(\.rawValue)
        )
        try Self.validateList(
            field: "marketLimitSimulatedExecutionContract.forbiddenCapabilities",
            expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
            actual: forbiddenCapabilities.map(\.rawValue)
        )
        try Self.validateList(
            field: "marketLimitSimulatedExecutionContract.validationAnchors",
            expected: Self.requiredValidationAnchors,
            actual: validationAnchors
        )
        try Self.validateRequiredTrueFlags(
            consumesDeterministicMatchingOutput: consumesDeterministicMatchingOutput,
            consumesSharedOrderSemantics: consumesSharedOrderSemantics,
            definesMarketOrderSemantics: definesMarketOrderSemantics,
            definesLimitOrderSemantics: definesLimitOrderSemantics,
            definesFullFillRejectExpire: definesFullFillRejectExpire,
            emitsAppendOnlySimulatedOrderEvent: emitsAppendOnlySimulatedOrderEvent
        )
        try Self.validateForbiddenFlags(
            prefix: nil,
            implementsOrderExecutionRuntime: implementsOrderExecutionRuntime,
            implementsMatchingRuntime: implementsMatchingRuntime,
            implementsPortfolioProjectionRuntime: implementsPortfolioProjectionRuntime,
            implementsAdvancedOrderTypes: implementsAdvancedOrderTypes,
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountBrokerPositionMarginLeverage: readsRealAccountBrokerPositionMarginLeverage,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveProConsole: providesLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.orderTypes = orderTypes
        self.outcomes = outcomes
        self.executionRules = executionRules
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.consumesDeterministicMatchingOutput = consumesDeterministicMatchingOutput
        self.consumesSharedOrderSemantics = consumesSharedOrderSemantics
        self.definesMarketOrderSemantics = definesMarketOrderSemantics
        self.definesLimitOrderSemantics = definesLimitOrderSemantics
        self.definesFullFillRejectExpire = definesFullFillRejectExpire
        self.emitsAppendOnlySimulatedOrderEvent = emitsAppendOnlySimulatedOrderEvent
        self.implementsOrderExecutionRuntime = implementsOrderExecutionRuntime
        self.implementsMatchingRuntime = implementsMatchingRuntime
        self.implementsPortfolioProjectionRuntime = implementsPortfolioProjectionRuntime
        self.implementsAdvancedOrderTypes = implementsAdvancedOrderTypes
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.readsRealAccountBrokerPositionMarginLeverage = readsRealAccountBrokerPositionMarginLeverage
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveProConsole = providesLiveProConsole
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            orderTypes: try container.decode([MarketLimitSimulatedOrderType].self, forKey: .orderTypes),
            outcomes: try container.decode([MarketLimitSimulatedExecutionOutcome].self, forKey: .outcomes),
            executionRules: try container.decode(
                [MarketLimitSimulatedExecutionRule].self,
                forKey: .executionRules
            ),
            forbiddenCapabilities: try container.decode(
                [SimulatedExchangeBacktestParityForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            consumesDeterministicMatchingOutput: try container.decode(
                Bool.self,
                forKey: .consumesDeterministicMatchingOutput
            ),
            consumesSharedOrderSemantics: try container.decode(Bool.self, forKey: .consumesSharedOrderSemantics),
            definesMarketOrderSemantics: try container.decode(Bool.self, forKey: .definesMarketOrderSemantics),
            definesLimitOrderSemantics: try container.decode(Bool.self, forKey: .definesLimitOrderSemantics),
            definesFullFillRejectExpire: try container.decode(Bool.self, forKey: .definesFullFillRejectExpire),
            emitsAppendOnlySimulatedOrderEvent: try container.decode(
                Bool.self,
                forKey: .emitsAppendOnlySimulatedOrderEvent
            ),
            implementsOrderExecutionRuntime: try container.decode(Bool.self, forKey: .implementsOrderExecutionRuntime),
            implementsMatchingRuntime: try container.decode(Bool.self, forKey: .implementsMatchingRuntime),
            implementsPortfolioProjectionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPortfolioProjectionRuntime
            ),
            implementsAdvancedOrderTypes: try container.decode(Bool.self, forKey: .implementsAdvancedOrderTypes),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            readsRealAccountBrokerPositionMarginLeverage: try container.decode(
                Bool.self,
                forKey: .readsRealAccountBrokerPositionMarginLeverage
            ),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveProConsole: try container.decode(Bool.self, forKey: .providesLiveProConsole),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: SimulatedExchangeBacktestParityForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredOrderTypes: [MarketLimitSimulatedOrderType] =
        MarketLimitSimulatedOrderType.allCases

    public static let requiredOutcomes: [MarketLimitSimulatedExecutionOutcome] =
        MarketLimitSimulatedExecutionOutcome.allCases

    public static let requiredExecutionRules: [MarketLimitSimulatedExecutionRule] =
        MarketLimitSimulatedExecutionRule.allCases

    public static let requiredForbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] =
        SimulatedExchangeBacktestParityForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "MTP-113-MARKET-ORDER-SIMULATED-EXECUTION",
        "MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION",
        "MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS",
        "MTP-113-DETERMINISTIC-EXECUTION-REPLAY",
        "MTP-113-NO-REAL-ORDER-LIVE-COMMAND",
        "MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: MarketLimitSimulatedExecutionContract = {
        do {
            return try MarketLimitSimulatedExecutionContract()
        } catch {
            preconditionFailure("MTP-113 market / limit simulated execution contract must be valid: \(error)")
        }
    }()

    fileprivate static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    private static func validateRequiredTrueFlags(
        consumesDeterministicMatchingOutput: Bool,
        consumesSharedOrderSemantics: Bool,
        definesMarketOrderSemantics: Bool,
        definesLimitOrderSemantics: Bool,
        definesFullFillRejectExpire: Bool,
        emitsAppendOnlySimulatedOrderEvent: Bool
    ) throws {
        let requiredTrueFlags = [
            ("consumesDeterministicMatchingOutput", consumesDeterministicMatchingOutput),
            ("consumesSharedOrderSemantics", consumesSharedOrderSemantics),
            ("definesMarketOrderSemantics", definesMarketOrderSemantics),
            ("definesLimitOrderSemantics", definesLimitOrderSemantics),
            ("definesFullFillRejectExpire", definesFullFillRejectExpire),
            ("emitsAppendOnlySimulatedOrderEvent", emitsAppendOnlySimulatedOrderEvent)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionContract.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
    }

    fileprivate static func validateForbiddenFlags(
        prefix: String?,
        implementsOrderExecutionRuntime: Bool = false,
        implementsMatchingRuntime: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        implementsAdvancedOrderTypes: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountBrokerPositionMarginLeverage: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let forbiddenFlags = [
            ("implementsOrderExecutionRuntime", implementsOrderExecutionRuntime),
            ("implementsMatchingRuntime", implementsMatchingRuntime),
            ("implementsPortfolioProjectionRuntime", implementsPortfolioProjectionRuntime),
            ("implementsAdvancedOrderTypes", implementsAdvancedOrderTypes),
            ("usesWallClockTime", usesWallClockTime),
            ("usesRandomness", usesRandomness),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("runsReconciliation", runsReconciliation),
            ("readsRealAccountBrokerPositionMarginLeverage", readsRealAccountBrokerPositionMarginLeverage),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveProConsole", providesLiveProConsole),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            let field = prefix.map { "\($0).\(capability.0)" } ?? capability.0
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(field)
        }
    }
}

/// MarketLimitSimulatedExecutionInput 聚合 MTP-113 执行语义所需的本地 deterministic 输入。
///
/// 输入必须复用 MTP-112 matching input 和 MTP-111 shared order input。market order 不能带 limit price；
/// limit order 必须带 limit price。initial state 只允许 accepted / rejected simulated，防止把本值对象
/// 扩展成完整订单状态机。
public struct MarketLimitSimulatedExecutionInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let orderType: MarketLimitSimulatedOrderType
    public let matchingInput: ScenarioReplayDeterministicMatchingInput
    public let limitPrice: Price?
    public let initialState: BacktestPaperSharedOrderState
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let readsRealAccountBrokerPositionMarginLeverage: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveProConsole: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var executionInputBoundaryHeld: Bool {
        matchingInput.matchingInputBoundaryHeld
            && MarketLimitSimulatedExecutionContract.requiredOrderTypes.contains(orderType)
            && validationAnchors == MarketLimitSimulatedExecutionContract.requiredValidationAnchors
            && orderTypeLimitPriceBoundaryHeld
            && (initialState == .acceptedSimulated || initialState == .rejectedSimulated)
            && forbiddenCapabilityBoundaryHeld
    }

    public var deterministicInputIdentity: String {
        [
            matchingInput.deterministicInputIdentity,
            "orderType=\(orderType.rawValue)",
            "limit=\(limitPrice.map { Self.scaledInteger($0.rawValue) }.map(String.init) ?? "none")",
            "initialState=\(initialState.rawValue)"
        ].joined(separator: "|")
    }

    private var orderTypeLimitPriceBoundaryHeld: Bool {
        switch orderType {
        case .market:
            limitPrice == nil
        case .limit:
            limitPrice != nil
        }
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && usesWallClockTime == false
            && usesRandomness == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && readsRealAccountBrokerPositionMarginLeverage == false
            && runsLiveRuntime == false
            && providesLiveProConsole == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public init(
        inputID: Identifier = try! Identifier("mtp-113-market-limit-simulated-execution-input"),
        orderType: MarketLimitSimulatedOrderType,
        matchingInput: ScenarioReplayDeterministicMatchingInput = .deterministicFixture,
        limitPrice: Price? = nil,
        initialState: BacktestPaperSharedOrderState = .acceptedSimulated,
        validationAnchors: [String] = MarketLimitSimulatedExecutionContract.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountBrokerPositionMarginLeverage: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            orderType: orderType,
            matchingInput: matchingInput,
            limitPrice: limitPrice,
            initialState: initialState,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountBrokerPositionMarginLeverage: readsRealAccountBrokerPositionMarginLeverage,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveProConsole: providesLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.inputID = inputID
        self.orderType = orderType
        self.matchingInput = matchingInput
        self.limitPrice = limitPrice
        self.initialState = initialState
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.readsRealAccountBrokerPositionMarginLeverage = readsRealAccountBrokerPositionMarginLeverage
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveProConsole = providesLiveProConsole
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            inputID: try container.decode(Identifier.self, forKey: .inputID),
            orderType: try container.decode(MarketLimitSimulatedOrderType.self, forKey: .orderType),
            matchingInput: try container.decode(ScenarioReplayDeterministicMatchingInput.self, forKey: .matchingInput),
            limitPrice: try container.decodeIfPresent(Price.self, forKey: .limitPrice),
            initialState: try container.decode(BacktestPaperSharedOrderState.self, forKey: .initialState),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            readsRealAccountBrokerPositionMarginLeverage: try container.decode(
                Bool.self,
                forKey: .readsRealAccountBrokerPositionMarginLeverage
            ),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveProConsole: try container.decode(Bool.self, forKey: .providesLiveProConsole),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    public static let deterministicMarketFixture: MarketLimitSimulatedExecutionInput = {
        do {
            return try MarketLimitSimulatedExecutionInput(orderType: .market)
        } catch {
            preconditionFailure("MTP-113 deterministic market execution input must be valid: \(error)")
        }
    }()

    public static let deterministicLimitFillFixture: MarketLimitSimulatedExecutionInput = {
        do {
            return try MarketLimitSimulatedExecutionInput(
                orderType: .limit,
                limitPrice: try Price(42_150, field: "marketLimitSimulatedExecution.limitPrice")
            )
        } catch {
            preconditionFailure("MTP-113 deterministic limit fill input must be valid: \(error)")
        }
    }()

    public static let deterministicLimitExpireFixture: MarketLimitSimulatedExecutionInput = {
        do {
            return try MarketLimitSimulatedExecutionInput(
                orderType: .limit,
                limitPrice: try Price(42_100, field: "marketLimitSimulatedExecution.limitPrice")
            )
        } catch {
            preconditionFailure("MTP-113 deterministic limit expire input must be valid: \(error)")
        }
    }()

    public static let deterministicRejectedFixture: MarketLimitSimulatedExecutionInput = {
        do {
            return try MarketLimitSimulatedExecutionInput(orderType: .market, initialState: .rejectedSimulated)
        } catch {
            preconditionFailure("MTP-113 deterministic rejected input must be valid: \(error)")
        }
    }()

    private static func validate(
        orderType: MarketLimitSimulatedOrderType,
        matchingInput: ScenarioReplayDeterministicMatchingInput,
        limitPrice: Price?,
        initialState: BacktestPaperSharedOrderState,
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        usesWallClockTime: Bool,
        usesRandomness: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        readsRealAccountBrokerPositionMarginLeverage: Bool,
        runsLiveRuntime: Bool,
        providesLiveProConsole: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard matchingInput.matchingInputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionInput.matchingInput",
                expected: "matching input boundary held",
                actual: "false"
            )
        }
        switch orderType {
        case .market:
            guard limitPrice == nil else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionInput.limitPrice",
                    expected: "nil for market order",
                    actual: "non-nil"
                )
            }
        case .limit:
            guard limitPrice != nil else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionInput.limitPrice",
                    expected: "non-nil for limit order",
                    actual: "nil"
                )
            }
        }
        guard initialState == .acceptedSimulated || initialState == .rejectedSimulated else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionInput.initialState",
                expected: "accepted simulated or rejected simulated",
                actual: initialState.rawValue
            )
        }
        try MarketLimitSimulatedExecutionContract.validateList(
            field: "marketLimitSimulatedExecutionInput.validationAnchors",
            expected: MarketLimitSimulatedExecutionContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try MarketLimitSimulatedExecutionContract.validateForbiddenFlags(
            prefix: "marketLimitSimulatedExecutionInput",
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountBrokerPositionMarginLeverage: readsRealAccountBrokerPositionMarginLeverage,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveProConsole: providesLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }

    private static func scaledInteger(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }
}

/// MarketLimitSimulatedExecutionEvent 是 MTP-113 的 simulated execution event 值对象。
///
/// Event 只表达 full fill、reject 或 expire 的本地 simulated order evidence。它不会写 Event Log，
/// 不更新 portfolio，不代表 broker fill、execution report、真实成交或真实订单状态机。
public struct MarketLimitSimulatedExecutionEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let orderType: MarketLimitSimulatedOrderType
    public let outcome: MarketLimitSimulatedExecutionOutcome
    public let orderID: Identifier
    public let sharedOrderState: BacktestPaperSharedOrderState
    public let sharedOrderEventKind: BacktestPaperSharedOrderEventKind
    public let matchedPrice: Price?
    public let limitPrice: Price?
    public let orderQuantity: Quantity
    public let filledQuantity: Quantity
    public let remainingQuantity: Quantity
    public let rejectReason: MarketLimitSimulatedExecutionRejectReason?
    public let eventStream: EventStreamID
    public let sourceAnchor: String
    public let recordsBrokerFill: Bool
    public let ingestsExecutionReport: Bool
    public let runsReconciliation: Bool
    public let submitsRealOrder: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var simulatedExecutionEventBoundaryHeld: Bool {
        eventStream == .paper
            && sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && outcomeStateBoundaryHeld
            && noPartialFillBeforeMTP114
            && recordsBrokerFill == false
            && ingestsExecutionReport == false
            && runsReconciliation == false
            && submitsRealOrder == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    private var outcomeStateBoundaryHeld: Bool {
        switch outcome {
        case .fullFill:
            sharedOrderState == .filledSimulated
                && sharedOrderEventKind == .simulatedOrderFilled
                && matchedPrice != nil
                && rejectReason == nil
                && quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue)
                && quantitiesMatch(remainingQuantity.rawValue, 0)
        case .rejected:
            sharedOrderState == .rejectedSimulated
                && sharedOrderEventKind == .simulatedOrderRejected
                && rejectReason != nil
                && quantitiesMatch(filledQuantity.rawValue, 0)
                && quantitiesMatch(remainingQuantity.rawValue, orderQuantity.rawValue)
        case .expired:
            sharedOrderState == .expiredSimulated
                && sharedOrderEventKind == .simulatedOrderExpired
                && matchedPrice != nil
                && limitPrice != nil
                && rejectReason == nil
                && quantitiesMatch(filledQuantity.rawValue, 0)
                && quantitiesMatch(remainingQuantity.rawValue, orderQuantity.rawValue)
        }
    }

    private var noPartialFillBeforeMTP114: Bool {
        quantitiesMatch(filledQuantity.rawValue, 0)
            || quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue)
    }

    public init(
        eventID: Identifier,
        orderType: MarketLimitSimulatedOrderType,
        outcome: MarketLimitSimulatedExecutionOutcome,
        orderID: Identifier,
        sharedOrderState: BacktestPaperSharedOrderState,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind,
        matchedPrice: Price?,
        limitPrice: Price?,
        orderQuantity: Quantity,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        rejectReason: MarketLimitSimulatedExecutionRejectReason?,
        eventStream: EventStreamID = .paper,
        sourceAnchor: String,
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        submitsRealOrder: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            orderType: orderType,
            outcome: outcome,
            sharedOrderState: sharedOrderState,
            sharedOrderEventKind: sharedOrderEventKind,
            matchedPrice: matchedPrice,
            limitPrice: limitPrice,
            orderQuantity: orderQuantity,
            filledQuantity: filledQuantity,
            remainingQuantity: remainingQuantity,
            rejectReason: rejectReason,
            eventStream: eventStream,
            sourceAnchor: sourceAnchor,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            submitsRealOrder: submitsRealOrder,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.eventID = eventID
        self.orderType = orderType
        self.outcome = outcome
        self.orderID = orderID
        self.sharedOrderState = sharedOrderState
        self.sharedOrderEventKind = sharedOrderEventKind
        self.matchedPrice = matchedPrice
        self.limitPrice = limitPrice
        self.orderQuantity = orderQuantity
        self.filledQuantity = filledQuantity
        self.remainingQuantity = remainingQuantity
        self.rejectReason = rejectReason
        self.eventStream = eventStream
        self.sourceAnchor = sourceAnchor
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.submitsRealOrder = submitsRealOrder
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            eventID: try container.decode(Identifier.self, forKey: .eventID),
            orderType: try container.decode(MarketLimitSimulatedOrderType.self, forKey: .orderType),
            outcome: try container.decode(MarketLimitSimulatedExecutionOutcome.self, forKey: .outcome),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            sharedOrderState: try container.decode(BacktestPaperSharedOrderState.self, forKey: .sharedOrderState),
            sharedOrderEventKind: try container.decode(
                BacktestPaperSharedOrderEventKind.self,
                forKey: .sharedOrderEventKind
            ),
            matchedPrice: try container.decodeIfPresent(Price.self, forKey: .matchedPrice),
            limitPrice: try container.decodeIfPresent(Price.self, forKey: .limitPrice),
            orderQuantity: try container.decode(Quantity.self, forKey: .orderQuantity),
            filledQuantity: try container.decode(Quantity.self, forKey: .filledQuantity),
            remainingQuantity: try container.decode(Quantity.self, forKey: .remainingQuantity),
            rejectReason: try container.decodeIfPresent(
                MarketLimitSimulatedExecutionRejectReason.self,
                forKey: .rejectReason
            ),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    private static func validate(
        orderType: MarketLimitSimulatedOrderType,
        outcome: MarketLimitSimulatedExecutionOutcome,
        sharedOrderState: BacktestPaperSharedOrderState,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind,
        matchedPrice: Price?,
        limitPrice: Price?,
        orderQuantity: Quantity,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        rejectReason: MarketLimitSimulatedExecutionRejectReason?,
        eventStream: EventStreamID,
        sourceAnchor: String,
        recordsBrokerFill: Bool,
        ingestsExecutionReport: Bool,
        runsReconciliation: Bool,
        submitsRealOrder: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              eventStream == .paper else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionEvent.source",
                expected: "non-empty source anchor and paper event stream",
                actual: sourceAnchor
            )
        }
        switch outcome {
        case .fullFill:
            guard sharedOrderState == .filledSimulated,
                  sharedOrderEventKind == .simulatedOrderFilled,
                  matchedPrice != nil,
                  rejectReason == nil,
                  quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue),
                  quantitiesMatch(remainingQuantity.rawValue, 0) else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionEvent.fullFill",
                    expected: "filled simulated event with full order quantity",
                    actual: sharedOrderState.rawValue
                )
            }
        case .rejected:
            guard sharedOrderState == .rejectedSimulated,
                  sharedOrderEventKind == .simulatedOrderRejected,
                  rejectReason != nil,
                  quantitiesMatch(filledQuantity.rawValue, 0),
                  quantitiesMatch(remainingQuantity.rawValue, orderQuantity.rawValue) else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionEvent.rejected",
                    expected: "rejected simulated event with no fill",
                    actual: sharedOrderState.rawValue
                )
            }
        case .expired:
            guard orderType == .limit,
                  sharedOrderState == .expiredSimulated,
                  sharedOrderEventKind == .simulatedOrderExpired,
                  matchedPrice != nil,
                  limitPrice != nil,
                  rejectReason == nil,
                  quantitiesMatch(filledQuantity.rawValue, 0),
                  quantitiesMatch(remainingQuantity.rawValue, orderQuantity.rawValue) else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionEvent.expired",
                    expected: "limit expired simulated event with no fill",
                    actual: sharedOrderState.rawValue
                )
            }
        }
        guard quantitiesMatch(filledQuantity.rawValue, 0)
                || quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionEvent.partialFill",
                expected: "0 or full order quantity before MTP-114",
                actual: "\(filledQuantity.rawValue)"
            )
        }
        let forbiddenFlags = [
            ("recordsBrokerFill", recordsBrokerFill),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("runsReconciliation", runsReconciliation),
            ("submitsRealOrder", submitsRealOrder),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(
                "marketLimitSimulatedExecutionEvent.\(capability.0)"
            )
        }
    }

    private func quantitiesMatch(_ lhs: Double, _ rhs: Double) -> Bool {
        Self.quantitiesMatch(lhs, rhs)
    }

    private static func quantitiesMatch(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 0.000_000_001
    }
}

/// MarketLimitSimulatedExecutionOutput 保存 MTP-113 pure semantics 的 deterministic output。
///
/// Output 可以引用 MTP-112 matching output；reject evidence 在进入 fill 之前停止，因此 matching output
/// 可为空。该值对象只用于 replayable evidence，不写入 portfolio、不暴露 UI command、不代表真实订单执行。
public struct MarketLimitSimulatedExecutionOutput: Codable, Equatable, Sendable {
    public let outputID: Identifier
    public let inputIdentity: String
    public let matchingOutput: ScenarioReplayDeterministicMatchingOutput?
    public let executionEvent: MarketLimitSimulatedExecutionEvent
    public let executionRules: [MarketLimitSimulatedExecutionRule]
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var executionOutputBoundaryHeld: Bool {
        inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && executionEvent.simulatedExecutionEventBoundaryHeld
            && executionRules == MarketLimitSimulatedExecutionContract.requiredExecutionRules
            && validationAnchors == MarketLimitSimulatedExecutionContract.requiredValidationAnchors
            && matchingOutputBoundaryHeld
            && requiredValidationDependsOnNetwork == false
            && usesWallClockTime == false
            && usesRandomness == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public var deterministicResultIdentity: String {
        [
            inputIdentity,
            "outcome=\(executionEvent.outcome.rawValue)",
            "matchedPrice=\(executionEvent.matchedPrice.map { Self.scaledInteger($0.rawValue) }.map(String.init) ?? "none")",
            "filled=\(Self.scaledInteger(executionEvent.filledQuantity.rawValue))",
            "remaining=\(Self.scaledInteger(executionEvent.remainingQuantity.rawValue))"
        ].joined(separator: "|")
    }

    private var matchingOutputBoundaryHeld: Bool {
        switch executionEvent.outcome {
        case .fullFill, .expired:
            matchingOutput?.matchingOutputBoundaryHeld == true
        case .rejected:
            matchingOutput == nil
        }
    }

    public init(
        outputID: Identifier,
        inputIdentity: String,
        matchingOutput: ScenarioReplayDeterministicMatchingOutput?,
        executionEvent: MarketLimitSimulatedExecutionEvent,
        executionRules: [MarketLimitSimulatedExecutionRule] =
            MarketLimitSimulatedExecutionContract.requiredExecutionRules,
        validationAnchors: [String] = MarketLimitSimulatedExecutionContract.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            inputIdentity: inputIdentity,
            matchingOutput: matchingOutput,
            executionEvent: executionEvent,
            executionRules: executionRules,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.outputID = outputID
        self.inputIdentity = inputIdentity
        self.matchingOutput = matchingOutput
        self.executionEvent = executionEvent
        self.executionRules = executionRules
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            outputID: try container.decode(Identifier.self, forKey: .outputID),
            inputIdentity: try container.decode(String.self, forKey: .inputIdentity),
            matchingOutput: try container.decodeIfPresent(
                ScenarioReplayDeterministicMatchingOutput.self,
                forKey: .matchingOutput
            ),
            executionEvent: try container.decode(
                MarketLimitSimulatedExecutionEvent.self,
                forKey: .executionEvent
            ),
            executionRules: try container.decode([MarketLimitSimulatedExecutionRule].self, forKey: .executionRules),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    private static func validate(
        inputIdentity: String,
        matchingOutput: ScenarioReplayDeterministicMatchingOutput?,
        executionEvent: MarketLimitSimulatedExecutionEvent,
        executionRules: [MarketLimitSimulatedExecutionRule],
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        usesWallClockTime: Bool,
        usesRandomness: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              executionEvent.simulatedExecutionEventBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionOutput",
                expected: "non-empty input identity and simulated event boundary held",
                actual: inputIdentity
            )
        }
        switch executionEvent.outcome {
        case .fullFill, .expired:
            guard matchingOutput?.matchingOutputBoundaryHeld == true else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionOutput.matchingOutput",
                    expected: "present matching output for fill or expire",
                    actual: "nil or invalid"
                )
            }
        case .rejected:
            guard matchingOutput == nil else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionOutput.matchingOutput",
                    expected: "nil for rejected simulated output",
                    actual: "present"
                )
            }
        }
        try MarketLimitSimulatedExecutionContract.validateList(
            field: "marketLimitSimulatedExecutionOutput.executionRules",
            expected: MarketLimitSimulatedExecutionContract.requiredExecutionRules.map(\.rawValue),
            actual: executionRules.map(\.rawValue)
        )
        try MarketLimitSimulatedExecutionContract.validateList(
            field: "marketLimitSimulatedExecutionOutput.validationAnchors",
            expected: MarketLimitSimulatedExecutionContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try MarketLimitSimulatedExecutionContract.validateForbiddenFlags(
            prefix: "marketLimitSimulatedExecutionOutput",
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }

    private static func scaledInteger(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }
}

/// MarketLimitSimulatedExecutionModel 是 MTP-113 的纯函数执行语义入口。
///
/// `execute` 只读取传入 input：market order 使用 deterministic matched price full fill；
/// buy limit order 在 matched price 小于等于 limit price 时 full fill，否则 expire；rejected / hold 输入
/// 在 fill 前停止。函数不保存状态、不访问网络、不使用时间或随机数，也不代表真实交易所执行。
public enum MarketLimitSimulatedExecutionModel {
    public static func execute(
        _ input: MarketLimitSimulatedExecutionInput
    ) throws -> MarketLimitSimulatedExecutionOutput {
        guard input.executionInputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "marketLimitSimulatedExecutionModel.input",
                expected: "execution input boundary held",
                actual: "false"
            )
        }

        let orderQuantity = input.matchingInput.sharedOrderInput.quantity
        if input.initialState == .rejectedSimulated {
            return try rejectedOutput(
                input: input,
                orderQuantity: orderQuantity,
                rejectReason: .rejectedSharedOrderState
            )
        }
        if input.matchingInput.sharedOrderInput.side == .hold {
            return try rejectedOutput(
                input: input,
                orderQuantity: orderQuantity,
                rejectReason: .nonExecutableHoldSide
            )
        }

        let matchingOutput = try ScenarioReplayDeterministicMatchingModel.match(input.matchingInput)
        let matchedPrice = matchingOutput.simulatedExchangeEvent.matchedPrice
        switch input.orderType {
        case .market:
            return try fullFillOutput(input: input, matchingOutput: matchingOutput, matchedPrice: matchedPrice)
        case .limit:
            guard let limitPrice = input.limitPrice else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "marketLimitSimulatedExecutionModel.limitPrice",
                    expected: "non-nil limit price",
                    actual: "nil"
                )
            }
            if matchedPrice.rawValue <= limitPrice.rawValue {
                return try fullFillOutput(input: input, matchingOutput: matchingOutput, matchedPrice: matchedPrice)
            }
            return try expiredOutput(
                input: input,
                matchingOutput: matchingOutput,
                matchedPrice: matchedPrice,
                limitPrice: limitPrice
            )
        }
    }

    private static func fullFillOutput(
        input: MarketLimitSimulatedExecutionInput,
        matchingOutput: ScenarioReplayDeterministicMatchingOutput,
        matchedPrice: Price
    ) throws -> MarketLimitSimulatedExecutionOutput {
        let quantity = input.matchingInput.sharedOrderInput.quantity
        let event = try MarketLimitSimulatedExecutionEvent(
            eventID: try Identifier(eventIDPrefix(input: input) + "-full-fill"),
            orderType: input.orderType,
            outcome: .fullFill,
            orderID: input.matchingInput.sharedOrderInput.orderID,
            sharedOrderState: .filledSimulated,
            sharedOrderEventKind: .simulatedOrderFilled,
            matchedPrice: matchedPrice,
            limitPrice: input.limitPrice,
            orderQuantity: quantity,
            filledQuantity: quantity,
            remainingQuantity: try Quantity(0, field: "marketLimitSimulatedExecution.remainingQuantity"),
            rejectReason: nil,
            sourceAnchor: "MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS"
        )
        return try MarketLimitSimulatedExecutionOutput(
            outputID: try Identifier(eventIDPrefix(input: input) + "-output"),
            inputIdentity: input.deterministicInputIdentity,
            matchingOutput: matchingOutput,
            executionEvent: event
        )
    }

    private static func expiredOutput(
        input: MarketLimitSimulatedExecutionInput,
        matchingOutput: ScenarioReplayDeterministicMatchingOutput,
        matchedPrice: Price,
        limitPrice: Price
    ) throws -> MarketLimitSimulatedExecutionOutput {
        let quantity = input.matchingInput.sharedOrderInput.quantity
        let event = try MarketLimitSimulatedExecutionEvent(
            eventID: try Identifier("mtp-113-limit-expired"),
            orderType: .limit,
            outcome: .expired,
            orderID: input.matchingInput.sharedOrderInput.orderID,
            sharedOrderState: .expiredSimulated,
            sharedOrderEventKind: .simulatedOrderExpired,
            matchedPrice: matchedPrice,
            limitPrice: limitPrice,
            orderQuantity: quantity,
            filledQuantity: try Quantity(0, field: "marketLimitSimulatedExecution.filledQuantity"),
            remainingQuantity: quantity,
            rejectReason: nil,
            sourceAnchor: "MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS"
        )
        return try MarketLimitSimulatedExecutionOutput(
            outputID: try Identifier("mtp-113-limit-expired-output"),
            inputIdentity: input.deterministicInputIdentity,
            matchingOutput: matchingOutput,
            executionEvent: event
        )
    }

    private static func rejectedOutput(
        input: MarketLimitSimulatedExecutionInput,
        orderQuantity: Quantity,
        rejectReason: MarketLimitSimulatedExecutionRejectReason
    ) throws -> MarketLimitSimulatedExecutionOutput {
        let event = try MarketLimitSimulatedExecutionEvent(
            eventID: try Identifier(eventIDPrefix(input: input) + "-rejected"),
            orderType: input.orderType,
            outcome: .rejected,
            orderID: input.matchingInput.sharedOrderInput.orderID,
            sharedOrderState: .rejectedSimulated,
            sharedOrderEventKind: .simulatedOrderRejected,
            matchedPrice: nil,
            limitPrice: input.limitPrice,
            orderQuantity: orderQuantity,
            filledQuantity: try Quantity(0, field: "marketLimitSimulatedExecution.filledQuantity"),
            remainingQuantity: orderQuantity,
            rejectReason: rejectReason,
            sourceAnchor: "MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS"
        )
        return try MarketLimitSimulatedExecutionOutput(
            outputID: try Identifier(eventIDPrefix(input: input) + "-rejected-output"),
            inputIdentity: input.deterministicInputIdentity,
            matchingOutput: nil,
            executionEvent: event
        )
    }

    private static func eventIDPrefix(input: MarketLimitSimulatedExecutionInput) -> String {
        switch input.orderType {
        case .market:
            "mtp-113-market"
        case .limit:
            "mtp-113-limit"
        }
    }
}
