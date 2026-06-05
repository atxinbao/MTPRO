import DomainModel
import Foundation

/// MTP-111 shared backtest-paper order semantics 只定义 backtest 与 paper runtime 共用的订单语义合同。
///
/// 该文件把 `PaperOrderIntent`、MTP-99 本地 lifecycle、MTP-100 simulated fill completion 和
/// L1.5 scenario replay identity 对齐到一个 paper-only / simulated value contract。它不实现撮合、
/// 订单执行 runtime、portfolio projection、OMS、真实 submit / cancel / replace、execution report、
/// broker fill、reconciliation、signed/account/listenKey、LiveExecutionAdapter、live command 或交易按钮。

/// BacktestPaperSharedOrderInputSource 固定 MTP-111 允许的订单输入来源。
///
/// `paperOrderIntent` 表示已有 paper runtime intent；`backtestReplayOrderInput` 表示回测重放使用同一组
/// paper-only / simulated 字段。二者都不是 real order command、broker request 或 UI order form。
public enum BacktestPaperSharedOrderInputSource: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case paperOrderIntent = "paper order intent"
    case backtestReplayOrderInput = "backtest replay order input"
}

/// BacktestPaperSharedOrderField 固定 paper order intent 与 backtest order input 必须共享的字段。
///
/// 字段只服务 deterministic simulation：scenario / dataset / fixture identity 负责 replay 输入身份，
/// order / proposal / session / symbol / timeframe / side / quantity / reference price 负责订单语义身份。
public enum BacktestPaperSharedOrderField: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case inputID = "input id"
    case orderID = "order id"
    case sourcePaperOrderIntentID = "source paper order intent id"
    case proposalID = "proposal id"
    case sessionID = "session id"
    case scenarioID = "scenario id"
    case datasetVersion = "dataset version"
    case fixtureVersion = "fixture version"
    case symbol = "symbol"
    case timeframe = "timeframe"
    case side = "side"
    case quantity = "quantity"
    case referencePrice = "reference price"
    case notionalAmount = "notional amount"
    case sourceRiskDecisionSequence = "source risk decision sequence"
    case sourceReplaySequence = "source replay sequence"
    case recordedAt = "recorded at"
}

/// BacktestPaperSharedOrderState 是 MTP-111 的 shared simulated order state taxonomy。
///
/// 状态名称全部带 simulated / local 语义。`cancelledLocalOnly` 和 `failedLocalOnly` 只为了对齐
/// paper lifecycle replay，不表示真实用户撤单、broker cancel、exchange reject 或 production failure。
public enum BacktestPaperSharedOrderState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case intentRecorded = "intent recorded"
    case submittedSimulated = "submitted simulated"
    case acceptedSimulated = "accepted simulated"
    case rejectedSimulated = "rejected simulated"
    case expiredSimulated = "expired simulated"
    case cancelledLocalOnly = "cancelled local only"
    case failedLocalOnly = "failed local only"
    case filledSimulated = "filled simulated"
    case partiallyFilledSimulated = "partially filled simulated"

    public var isTerminal: Bool {
        switch self {
        case .rejectedSimulated,
             .expiredSimulated,
             .cancelledLocalOnly,
             .failedLocalOnly,
             .filledSimulated:
            true
        case .intentRecorded,
             .submittedSimulated,
             .acceptedSimulated,
             .partiallyFilledSimulated:
            false
        }
    }
}

/// BacktestPaperSharedOrderEventKind 定义 shared order state 对应的 simulated event 名称。
///
/// event kind 只表示 Event Log / Replay 可记录的 simulated fact，不代表 broker acknowledgement、
/// execution report、真实 fill、OMS state transition 或可点击的 order-level command。
public enum BacktestPaperSharedOrderEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case orderIntentRecorded = "order intent recorded"
    case simulatedOrderSubmitted = "simulated order submitted"
    case simulatedOrderAccepted = "simulated order accepted"
    case simulatedOrderRejected = "simulated order rejected"
    case simulatedOrderExpired = "simulated order expired"
    case simulatedOrderCancelledLocal = "simulated order cancelled local"
    case simulatedOrderFailedLocal = "simulated order failed local"
    case simulatedOrderFilled = "simulated order filled"
    case simulatedOrderPartiallyFilled = "simulated order partially filled"
}

/// BacktestPaperLifecycleReplayAlignmentRule 固定 paper lifecycle 与 backtest replay 的对齐规则。
///
/// 这些规则只描述状态映射和 append-only replay 约束，不启动 matching、execution、portfolio 或 UI。
public enum BacktestPaperLifecycleReplayAlignmentRule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case paperIntentCreatesBacktestReplayInput = "paper intent creates backtest replay input"
    case submittedLocalMapsToSimulatedSubmitted = "submitted local maps to simulated submitted"
    case acceptedLocalMapsToSimulatedAccepted = "accepted local maps to simulated accepted"
    case rejectedByPaperRiskMapsToSimulatedRejected = "rejected by paper risk maps to simulated rejected"
    case expiredLocalMapsToSimulatedExpired = "expired local maps to simulated expired"
    case localCancelRemainsLocalOnly = "local cancel remains local only"
    case failedLocalRemainsLocalOnly = "failed local remains local only"
    case fullSimulatedFillMapsToSimulatedFilled = "full simulated fill maps to simulated filled"
    case partialSimulatedFillMapsToPartiallyFilled = "partial simulated fill maps to partially filled"
    case scenarioIdentityMustMatchReplayInput = "scenario identity must match replay input"
    case appendOnlyReplayOnly = "append-only replay only"
    case noRealOrderCommandUpgrade = "no real order command upgrade"
}

/// BacktestPaperSharedOrderForbiddenCapability 枚举 MTP-111 必须持续禁止的能力面。
///
/// 当前 issue 只能把这些能力作为 forbidden capability evidence；初始化和 Codable 解码都不能恢复它们。
public enum BacktestPaperSharedOrderForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case matchingRuntime = "matching runtime"
    case orderExecutionRuntime = "order execution runtime"
    case portfolioProjectionRuntime = "portfolio projection runtime"
    case realOrderCommand = "real order command"
    case realOrderLifecycle = "real order lifecycle"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case secretRead = "secret read"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case brokerIntegration = "broker integration"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case reconciliation = "reconciliation"
    case realAccountBrokerPositionMarginLeverageRead = "real account / broker position / margin / leverage read"
    case liveRuntime = "live runtime"
    case liveProConsole = "Live PRO Console"
    case liveCommand = "live command"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case emergencyStopShutdownRestore = "emergency stop / shutdown / restore"
}

/// BacktestPaperSharedOrderSemanticsContract 是 MTP-111 的 shared order semantics fixture。
///
/// Fixture 只固定输入来源、共享字段、simulated state / event taxonomy、lifecycle replay alignment、
/// source docs anchors、validation anchors 和 forbidden capability baseline。它不持有订单簿、不撮合、
/// 不生成成交、不更新组合，也不读写文件、网络、数据库 schema 或 Runtime object。
public struct BacktestPaperSharedOrderSemanticsContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let inputSources: [BacktestPaperSharedOrderInputSource]
    public let sharedFields: [BacktestPaperSharedOrderField]
    public let orderStates: [BacktestPaperSharedOrderState]
    public let simulatedEventKinds: [BacktestPaperSharedOrderEventKind]
    public let alignmentRules: [BacktestPaperLifecycleReplayAlignmentRule]
    public let forbiddenCapabilities: [BacktestPaperSharedOrderForbiddenCapability]
    public let sourceDocumentAnchors: [String]
    public let validationAnchors: [String]
    public let sharesPaperOrderIntentFields: Bool
    public let alignsBacktestReplayInput: Bool
    public let alignsPaperRuntimeLifecycle: Bool
    public let alignsSimulatedFillCompletion: Bool
    public let emitsSimulatedEventsOnly: Bool
    public let keepsOrderEventsAppendOnlyReplayFacts: Bool
    public let implementsMatchingRuntime: Bool
    public let implementsOrderExecutionRuntime: Bool
    public let implementsPortfolioProjectionRuntime: Bool
    public let representsRealOrderCommand: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let readsRealAccountBrokerPositionMarginLeverage: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveProConsole: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let implementsEmergencyStopShutdownRestore: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var sharedOrderSemanticsBoundaryHeld: Bool {
        inputSources == Self.requiredInputSources
            && sharedFields == Self.requiredSharedFields
            && orderStates == Self.requiredOrderStates
            && simulatedEventKinds == Self.requiredSimulatedEventKinds
            && alignmentRules == Self.requiredAlignmentRules
            && sourceDocumentAnchors == Self.requiredSourceDocumentAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && sharedFieldBoundaryHeld
            && lifecycleReplayAlignmentHeld
            && forbiddenCapabilityBoundaryHeld
    }

    public var sharedFieldBoundaryHeld: Bool {
        sharesPaperOrderIntentFields
            && alignsBacktestReplayInput
            && emitsSimulatedEventsOnly
    }

    public var lifecycleReplayAlignmentHeld: Bool {
        alignsPaperRuntimeLifecycle
            && alignsSimulatedFillCompletion
            && keepsOrderEventsAppendOnlyReplayFacts
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allForbiddenFlagsRemainFalse
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        implementsMatchingRuntime == false
            && implementsOrderExecutionRuntime == false
            && implementsPortfolioProjectionRuntime == false
            && representsRealOrderCommand == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && readsRealAccountBrokerPositionMarginLeverage == false
            && runsLiveRuntime == false
            && providesLiveProConsole == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && implementsEmergencyStopShutdownRestore == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-111-shared-backtest-paper-order-semantics"),
        issueID: Identifier = try! Identifier("MTP-111"),
        inputSources: [BacktestPaperSharedOrderInputSource] = Self.requiredInputSources,
        sharedFields: [BacktestPaperSharedOrderField] = Self.requiredSharedFields,
        orderStates: [BacktestPaperSharedOrderState] = Self.requiredOrderStates,
        simulatedEventKinds: [BacktestPaperSharedOrderEventKind] = Self.requiredSimulatedEventKinds,
        alignmentRules: [BacktestPaperLifecycleReplayAlignmentRule] = Self.requiredAlignmentRules,
        forbiddenCapabilities: [BacktestPaperSharedOrderForbiddenCapability] = Self.requiredForbiddenCapabilities,
        sourceDocumentAnchors: [String] = Self.requiredSourceDocumentAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        sharesPaperOrderIntentFields: Bool = true,
        alignsBacktestReplayInput: Bool = true,
        alignsPaperRuntimeLifecycle: Bool = true,
        alignsSimulatedFillCompletion: Bool = true,
        emitsSimulatedEventsOnly: Bool = true,
        keepsOrderEventsAppendOnlyReplayFacts: Bool = true,
        implementsMatchingRuntime: Bool = false,
        implementsOrderExecutionRuntime: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        representsRealOrderCommand: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountBrokerPositionMarginLeverage: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        implementsEmergencyStopShutdownRestore: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            inputSources: inputSources,
            sharedFields: sharedFields,
            orderStates: orderStates,
            simulatedEventKinds: simulatedEventKinds,
            alignmentRules: alignmentRules,
            forbiddenCapabilities: forbiddenCapabilities,
            sourceDocumentAnchors: sourceDocumentAnchors,
            validationAnchors: validationAnchors
        )
        try Self.validateBoundaryFlags(
            sharesPaperOrderIntentFields: sharesPaperOrderIntentFields,
            alignsBacktestReplayInput: alignsBacktestReplayInput,
            alignsPaperRuntimeLifecycle: alignsPaperRuntimeLifecycle,
            alignsSimulatedFillCompletion: alignsSimulatedFillCompletion,
            emitsSimulatedEventsOnly: emitsSimulatedEventsOnly,
            keepsOrderEventsAppendOnlyReplayFacts: keepsOrderEventsAppendOnlyReplayFacts,
            implementsMatchingRuntime: implementsMatchingRuntime,
            implementsOrderExecutionRuntime: implementsOrderExecutionRuntime,
            implementsPortfolioProjectionRuntime: implementsPortfolioProjectionRuntime,
            representsRealOrderCommand: representsRealOrderCommand,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountBrokerPositionMarginLeverage: readsRealAccountBrokerPositionMarginLeverage,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveProConsole: providesLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            implementsEmergencyStopShutdownRestore: implementsEmergencyStopShutdownRestore,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.inputSources = inputSources
        self.sharedFields = sharedFields
        self.orderStates = orderStates
        self.simulatedEventKinds = simulatedEventKinds
        self.alignmentRules = alignmentRules
        self.forbiddenCapabilities = forbiddenCapabilities
        self.sourceDocumentAnchors = sourceDocumentAnchors
        self.validationAnchors = validationAnchors
        self.sharesPaperOrderIntentFields = sharesPaperOrderIntentFields
        self.alignsBacktestReplayInput = alignsBacktestReplayInput
        self.alignsPaperRuntimeLifecycle = alignsPaperRuntimeLifecycle
        self.alignsSimulatedFillCompletion = alignsSimulatedFillCompletion
        self.emitsSimulatedEventsOnly = emitsSimulatedEventsOnly
        self.keepsOrderEventsAppendOnlyReplayFacts = keepsOrderEventsAppendOnlyReplayFacts
        self.implementsMatchingRuntime = implementsMatchingRuntime
        self.implementsOrderExecutionRuntime = implementsOrderExecutionRuntime
        self.implementsPortfolioProjectionRuntime = implementsPortfolioProjectionRuntime
        self.representsRealOrderCommand = representsRealOrderCommand
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.readsRealAccountBrokerPositionMarginLeverage = readsRealAccountBrokerPositionMarginLeverage
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveProConsole = providesLiveProConsole
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.implementsEmergencyStopShutdownRestore = implementsEmergencyStopShutdownRestore
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            inputSources: try container.decode([BacktestPaperSharedOrderInputSource].self, forKey: .inputSources),
            sharedFields: try container.decode([BacktestPaperSharedOrderField].self, forKey: .sharedFields),
            orderStates: try container.decode([BacktestPaperSharedOrderState].self, forKey: .orderStates),
            simulatedEventKinds: try container.decode(
                [BacktestPaperSharedOrderEventKind].self,
                forKey: .simulatedEventKinds
            ),
            alignmentRules: try container.decode(
                [BacktestPaperLifecycleReplayAlignmentRule].self,
                forKey: .alignmentRules
            ),
            forbiddenCapabilities: try container.decode(
                [BacktestPaperSharedOrderForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            sourceDocumentAnchors: try container.decode([String].self, forKey: .sourceDocumentAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            sharesPaperOrderIntentFields: try container.decode(Bool.self, forKey: .sharesPaperOrderIntentFields),
            alignsBacktestReplayInput: try container.decode(Bool.self, forKey: .alignsBacktestReplayInput),
            alignsPaperRuntimeLifecycle: try container.decode(Bool.self, forKey: .alignsPaperRuntimeLifecycle),
            alignsSimulatedFillCompletion: try container.decode(Bool.self, forKey: .alignsSimulatedFillCompletion),
            emitsSimulatedEventsOnly: try container.decode(Bool.self, forKey: .emitsSimulatedEventsOnly),
            keepsOrderEventsAppendOnlyReplayFacts: try container.decode(
                Bool.self,
                forKey: .keepsOrderEventsAppendOnlyReplayFacts
            ),
            implementsMatchingRuntime: try container.decode(Bool.self, forKey: .implementsMatchingRuntime),
            implementsOrderExecutionRuntime: try container.decode(Bool.self, forKey: .implementsOrderExecutionRuntime),
            implementsPortfolioProjectionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPortfolioProjectionRuntime
            ),
            representsRealOrderCommand: try container.decode(Bool.self, forKey: .representsRealOrderCommand),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
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
            implementsEmergencyStopShutdownRestore: try container.decode(
                Bool.self,
                forKey: .implementsEmergencyStopShutdownRestore
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: BacktestPaperSharedOrderForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static func sharedState(for orderIntentState: PaperOrderLifecycleState) -> BacktestPaperSharedOrderState {
        switch orderIntentState {
        case .intentCreated:
            .intentRecorded
        case .rejectedByRisk:
            .rejectedSimulated
        }
    }

    public static func sharedState(for lifecycleState: PaperOrderLocalLifecycleState) -> BacktestPaperSharedOrderState {
        switch lifecycleState {
        case .proposed:
            .intentRecorded
        case .submittedLocal:
            .submittedSimulated
        case .acceptedLocal:
            .acceptedSimulated
        case .rejectedByPaperRisk:
            .rejectedSimulated
        case .cancelledLocal:
            .cancelledLocalOnly
        case .expiredLocal:
            .expiredSimulated
        case .failedLocal:
            .failedLocalOnly
        }
    }

    public static func sharedState(for fillCompletion: PaperSimulatedFillCompletion) -> BacktestPaperSharedOrderState {
        switch fillCompletion {
        case .full:
            .filledSimulated
        case .partial:
            .partiallyFilledSimulated
        }
    }

    public static func simulatedEventKind(
        for state: BacktestPaperSharedOrderState
    ) -> BacktestPaperSharedOrderEventKind {
        switch state {
        case .intentRecorded:
            .orderIntentRecorded
        case .submittedSimulated:
            .simulatedOrderSubmitted
        case .acceptedSimulated:
            .simulatedOrderAccepted
        case .rejectedSimulated:
            .simulatedOrderRejected
        case .expiredSimulated:
            .simulatedOrderExpired
        case .cancelledLocalOnly:
            .simulatedOrderCancelledLocal
        case .failedLocalOnly:
            .simulatedOrderFailedLocal
        case .filledSimulated:
            .simulatedOrderFilled
        case .partiallyFilledSimulated:
            .simulatedOrderPartiallyFilled
        }
    }

    public static let requiredInputSources: [BacktestPaperSharedOrderInputSource] =
        BacktestPaperSharedOrderInputSource.allCases

    public static let requiredSharedFields: [BacktestPaperSharedOrderField] =
        BacktestPaperSharedOrderField.allCases

    public static let requiredOrderStates: [BacktestPaperSharedOrderState] =
        BacktestPaperSharedOrderState.allCases

    public static let requiredSimulatedEventKinds: [BacktestPaperSharedOrderEventKind] =
        BacktestPaperSharedOrderEventKind.allCases

    public static let requiredAlignmentRules: [BacktestPaperLifecycleReplayAlignmentRule] =
        BacktestPaperLifecycleReplayAlignmentRule.allCases

    public static let requiredForbiddenCapabilities: [BacktestPaperSharedOrderForbiddenCapability] =
        BacktestPaperSharedOrderForbiddenCapability.allCases

    public static let requiredSourceDocumentAnchors: [String] = [
        "docs/contracts/simulated-exchange-backtest-parity-contract.md",
        "docs/domain/context.md",
        "docs/planning/projects/mtpro-simulated-exchange-backtest-parity-v1-plan.md",
        "Sources/ExecutionEngine/PaperLifecycle/PaperOrderIntent.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift",
        "Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift",
        "Sources/Core/ScenarioManifest.swift",
        "Sources/Core/ScenarioFixture.swift",
        "docs/validation/latest-verification-summary.md"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS",
        "MTP-111-SIMULATED-ORDER-STATE-SEMANTICS",
        "MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT",
        "MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE",
        "MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: BacktestPaperSharedOrderSemanticsContract = {
        do {
            return try BacktestPaperSharedOrderSemanticsContract()
        } catch {
            preconditionFailure("MTP-111 shared order semantics contract fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        inputSources: [BacktestPaperSharedOrderInputSource],
        sharedFields: [BacktestPaperSharedOrderField],
        orderStates: [BacktestPaperSharedOrderState],
        simulatedEventKinds: [BacktestPaperSharedOrderEventKind],
        alignmentRules: [BacktestPaperLifecycleReplayAlignmentRule],
        forbiddenCapabilities: [BacktestPaperSharedOrderForbiddenCapability],
        sourceDocumentAnchors: [String],
        validationAnchors: [String]
    ) throws {
        try validateList(field: "inputSources", expected: Self.requiredInputSources.map(\.rawValue), actual: inputSources.map(\.rawValue))
        try validateList(field: "sharedFields", expected: Self.requiredSharedFields.map(\.rawValue), actual: sharedFields.map(\.rawValue))
        try validateList(field: "orderStates", expected: Self.requiredOrderStates.map(\.rawValue), actual: orderStates.map(\.rawValue))
        try validateList(
            field: "simulatedEventKinds",
            expected: Self.requiredSimulatedEventKinds.map(\.rawValue),
            actual: simulatedEventKinds.map(\.rawValue)
        )
        try validateList(
            field: "alignmentRules",
            expected: Self.requiredAlignmentRules.map(\.rawValue),
            actual: alignmentRules.map(\.rawValue)
        )
        try validateList(
            field: "forbiddenCapabilities",
            expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
            actual: forbiddenCapabilities.map(\.rawValue)
        )
        try validateList(field: "sourceDocumentAnchors", expected: Self.requiredSourceDocumentAnchors, actual: sourceDocumentAnchors)
        try validateList(field: "validationAnchors", expected: Self.requiredValidationAnchors, actual: validationAnchors)
    }

    private static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    private static func validateBoundaryFlags(
        sharesPaperOrderIntentFields: Bool,
        alignsBacktestReplayInput: Bool,
        alignsPaperRuntimeLifecycle: Bool,
        alignsSimulatedFillCompletion: Bool,
        emitsSimulatedEventsOnly: Bool,
        keepsOrderEventsAppendOnlyReplayFacts: Bool,
        implementsMatchingRuntime: Bool,
        implementsOrderExecutionRuntime: Bool,
        implementsPortfolioProjectionRuntime: Bool,
        representsRealOrderCommand: Bool,
        implementsRealOrderLifecycle: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        readsRealAccountBrokerPositionMarginLeverage: Bool,
        runsLiveRuntime: Bool,
        providesLiveProConsole: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        implementsEmergencyStopShutdownRestore: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let requiredTrueFlags = [
            ("sharesPaperOrderIntentFields", sharesPaperOrderIntentFields),
            ("alignsBacktestReplayInput", alignsBacktestReplayInput),
            ("alignsPaperRuntimeLifecycle", alignsPaperRuntimeLifecycle),
            ("alignsSimulatedFillCompletion", alignsSimulatedFillCompletion),
            ("emitsSimulatedEventsOnly", emitsSimulatedEventsOnly),
            ("keepsOrderEventsAppendOnlyReplayFacts", keepsOrderEventsAppendOnlyReplayFacts)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: flag.0,
                expected: "true",
                actual: "false"
            )
        }

        let forbiddenFlags = [
            ("implementsMatchingRuntime", implementsMatchingRuntime),
            ("implementsOrderExecutionRuntime", implementsOrderExecutionRuntime),
            ("implementsPortfolioProjectionRuntime", implementsPortfolioProjectionRuntime),
            ("representsRealOrderCommand", representsRealOrderCommand),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("runsReconciliation", runsReconciliation),
            ("readsRealAccountBrokerPositionMarginLeverage", readsRealAccountBrokerPositionMarginLeverage),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveProConsole", providesLiveProConsole),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("implementsEmergencyStopShutdownRestore", implementsEmergencyStopShutdownRestore),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(capability.0)
        }
    }
}

/// BacktestPaperSharedOrderInput 把 paper order intent 映射为 backtest replay 可消费的共享输入。
///
/// 该值对象只复制 paper intent、scenario id、dataset version、fixture version 和 replay sequence 等稳定字段。
/// 它不表达 order type、不撮合、不生成 fill、不提交真实订单，也不允许 Codable 解码恢复 live / broker 能力。
public struct BacktestPaperSharedOrderInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let source: BacktestPaperSharedOrderInputSource
    public let orderID: Identifier
    public let sourcePaperOrderIntentID: Identifier
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let side: PaperActionProposalSide
    public let quantity: Quantity
    public let referencePrice: Price
    public let notionalAmount: Double
    public let sourceRiskDecisionSequence: Int
    public let sourceReplaySequence: Int
    public let recordedAt: Date
    public let executionMode: ExecutionMode
    public let eventStream: EventStreamID
    public let validationAnchors: [String]
    public let representsRealOrderCommand: Bool
    public let authorizesRealSubmitCancelReplace: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var sharedFieldBoundaryHeld: Bool {
        BacktestPaperSharedOrderSemanticsContract.requiredInputSources.contains(source)
            && executionMode == .paper
            && eventStream == .paper
            && validationAnchors == BacktestPaperSharedOrderSemanticsContract.requiredValidationAnchors
            && representsRealOrderCommand == false
            && authorizesRealSubmitCancelReplace == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && ingestsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public static func fromPaperOrderIntent(
        inputID: Identifier,
        orderIntent: PaperOrderIntent,
        scenarioFixture: DeterministicScenarioFixture,
        source: BacktestPaperSharedOrderInputSource = .backtestReplayOrderInput,
        sourceReplaySequence: Int,
        recordedAt: Date,
        validationAnchors: [String] = BacktestPaperSharedOrderSemanticsContract.requiredValidationAnchors,
        representsRealOrderCommand: Bool = false,
        authorizesRealSubmitCancelReplace: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws -> BacktestPaperSharedOrderInput {
        try BacktestPaperSharedOrderInput(
            inputID: inputID,
            source: source,
            orderID: orderIntent.orderID,
            sourcePaperOrderIntentID: orderIntent.orderID,
            proposalID: orderIntent.proposalID,
            sessionID: orderIntent.sessionID,
            scenarioID: scenarioFixture.manifest.scenarioID,
            datasetVersion: scenarioFixture.manifest.datasetVersion,
            fixtureVersion: scenarioFixture.fixtureVersion,
            symbol: orderIntent.symbol,
            timeframe: orderIntent.timeframe,
            side: orderIntent.side,
            quantity: orderIntent.quantity,
            referencePrice: orderIntent.referencePrice,
            notionalAmount: orderIntent.notionalAmount,
            sourceRiskDecisionSequence: orderIntent.sourceRiskDecisionSequence,
            sourceReplaySequence: sourceReplaySequence,
            recordedAt: recordedAt,
            executionMode: orderIntent.executionMode,
            eventStream: orderIntent.eventStream,
            validationAnchors: validationAnchors,
            representsRealOrderCommand: representsRealOrderCommand,
            authorizesRealSubmitCancelReplace: authorizesRealSubmitCancelReplace,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            sourcePaperOrderBoundaryHeld: orderIntent.paperOnlyBoundaryHeld,
            scenarioFixtureBoundaryHeld: scenarioFixture.fixtureBoundaryHeld,
            scenarioSymbol: scenarioFixture.manifest.symbol,
            scenarioTimeframe: scenarioFixture.manifest.timeframe
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        try self.init(
            inputID: try container.decode(Identifier.self, forKey: .inputID),
            source: try container.decode(BacktestPaperSharedOrderInputSource.self, forKey: .source),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            sourcePaperOrderIntentID: try container.decode(Identifier.self, forKey: .sourcePaperOrderIntentID),
            proposalID: try container.decode(Identifier.self, forKey: .proposalID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            scenarioID: try container.decode(ScenarioID.self, forKey: .scenarioID),
            datasetVersion: try container.decode(DatasetVersion.self, forKey: .datasetVersion),
            fixtureVersion: try container.decode(FixtureVersion.self, forKey: .fixtureVersion),
            symbol: symbol,
            timeframe: timeframe,
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            quantity: try container.decode(Quantity.self, forKey: .quantity),
            referencePrice: try container.decode(Price.self, forKey: .referencePrice),
            notionalAmount: try container.decode(Double.self, forKey: .notionalAmount),
            sourceRiskDecisionSequence: try container.decode(Int.self, forKey: .sourceRiskDecisionSequence),
            sourceReplaySequence: try container.decode(Int.self, forKey: .sourceReplaySequence),
            recordedAt: try container.decode(Date.self, forKey: .recordedAt),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            representsRealOrderCommand: try container.decode(Bool.self, forKey: .representsRealOrderCommand),
            authorizesRealSubmitCancelReplace: try container.decode(
                Bool.self,
                forKey: .authorizesRealSubmitCancelReplace
            ),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            sourcePaperOrderBoundaryHeld: true,
            scenarioFixtureBoundaryHeld: true,
            scenarioSymbol: symbol,
            scenarioTimeframe: timeframe
        )
    }

    private init(
        inputID: Identifier,
        source: BacktestPaperSharedOrderInputSource,
        orderID: Identifier,
        sourcePaperOrderIntentID: Identifier,
        proposalID: Identifier,
        sessionID: Identifier,
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        fixtureVersion: FixtureVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        side: PaperActionProposalSide,
        quantity: Quantity,
        referencePrice: Price,
        notionalAmount: Double,
        sourceRiskDecisionSequence: Int,
        sourceReplaySequence: Int,
        recordedAt: Date,
        executionMode: ExecutionMode,
        eventStream: EventStreamID,
        validationAnchors: [String],
        representsRealOrderCommand: Bool,
        authorizesRealSubmitCancelReplace: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        sourcePaperOrderBoundaryHeld: Bool,
        scenarioFixtureBoundaryHeld: Bool,
        scenarioSymbol: Symbol,
        scenarioTimeframe: Timeframe
    ) throws {
        try Self.validate(
            source: source,
            symbol: symbol,
            timeframe: timeframe,
            notionalAmount: notionalAmount,
            quantity: quantity,
            referencePrice: referencePrice,
            sourceRiskDecisionSequence: sourceRiskDecisionSequence,
            sourceReplaySequence: sourceReplaySequence,
            executionMode: executionMode,
            eventStream: eventStream,
            validationAnchors: validationAnchors,
            sourcePaperOrderBoundaryHeld: sourcePaperOrderBoundaryHeld,
            scenarioFixtureBoundaryHeld: scenarioFixtureBoundaryHeld,
            scenarioSymbol: scenarioSymbol,
            scenarioTimeframe: scenarioTimeframe,
            representsRealOrderCommand: representsRealOrderCommand,
            authorizesRealSubmitCancelReplace: authorizesRealSubmitCancelReplace,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.inputID = inputID
        self.source = source
        self.orderID = orderID
        self.sourcePaperOrderIntentID = sourcePaperOrderIntentID
        self.proposalID = proposalID
        self.sessionID = sessionID
        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.side = side
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notionalAmount = notionalAmount
        self.sourceRiskDecisionSequence = sourceRiskDecisionSequence
        self.sourceReplaySequence = sourceReplaySequence
        self.recordedAt = recordedAt
        self.executionMode = executionMode
        self.eventStream = eventStream
        self.validationAnchors = validationAnchors
        self.representsRealOrderCommand = representsRealOrderCommand
        self.authorizesRealSubmitCancelReplace = authorizesRealSubmitCancelReplace
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public static let deterministicFixture: BacktestPaperSharedOrderInput = {
        do {
            return try BacktestPaperSharedOrderInput.fromPaperOrderIntent(
                inputID: try Identifier("mtp-111-shared-backtest-paper-order-input"),
                orderIntent: PaperOrderIntentFixture.deterministicAllowed(),
                scenarioFixture: .deterministicFixture,
                sourceReplaySequence: 4,
                recordedAt: Date(timeIntervalSince1970: 7_000)
            )
        } catch {
            preconditionFailure("MTP-111 shared order input fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        source: BacktestPaperSharedOrderInputSource,
        symbol: Symbol,
        timeframe: Timeframe,
        notionalAmount: Double,
        quantity: Quantity,
        referencePrice: Price,
        sourceRiskDecisionSequence: Int,
        sourceReplaySequence: Int,
        executionMode: ExecutionMode,
        eventStream: EventStreamID,
        validationAnchors: [String],
        sourcePaperOrderBoundaryHeld: Bool,
        scenarioFixtureBoundaryHeld: Bool,
        scenarioSymbol: Symbol,
        scenarioTimeframe: Timeframe,
        representsRealOrderCommand: Bool,
        authorizesRealSubmitCancelReplace: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard BacktestPaperSharedOrderSemanticsContract.requiredInputSources.contains(source) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sharedOrderInput.source",
                expected: BacktestPaperSharedOrderSemanticsContract.requiredInputSources.map(\.rawValue)
                    .joined(separator: ","),
                actual: source.rawValue
            )
        }
        guard sourcePaperOrderBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sourcePaperOrderBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard scenarioFixtureBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioFixtureBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard symbol == scenarioSymbol, timeframe == scenarioTimeframe else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioIdentity.symbolTimeframe",
                expected: "\(scenarioSymbol.rawValue)/\(scenarioTimeframe.rawValue)",
                actual: "\(symbol.rawValue)/\(timeframe.rawValue)"
            )
        }
        guard notionalAmount == quantity.rawValue * referencePrice.rawValue else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sharedOrderInput.notionalAmount",
                expected: "\(quantity.rawValue * referencePrice.rawValue)",
                actual: "\(notionalAmount)"
            )
        }
        guard sourceRiskDecisionSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceRiskDecisionSequence)
        }
        guard sourceReplaySequence > 0 else {
            throw CoreError.invalidEventSequence(sourceReplaySequence)
        }
        guard executionMode == .paper else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sharedOrderInput.executionMode",
                expected: ExecutionMode.paper.rawValue,
                actual: executionMode.rawValue
            )
        }
        guard eventStream == .paper else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sharedOrderInput.eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        guard validationAnchors == BacktestPaperSharedOrderSemanticsContract.requiredValidationAnchors else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "sharedOrderInput.validationAnchors",
                expected: BacktestPaperSharedOrderSemanticsContract.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        let forbiddenFlags = [
            ("representsRealOrderCommand", representsRealOrderCommand),
            ("authorizesRealSubmitCancelReplace", authorizesRealSubmitCancelReplace),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("runsReconciliation", runsReconciliation),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability("sharedOrderInput.\(capability.0)")
        }
    }
}
