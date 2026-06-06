import DataEngine
import DomainModel
import Foundation

/// MTP-112 scenario replay deterministic matching 只定义本地 deterministic matching model。
///
/// 本文件消费 MTP-106 scenario replay evidence 和 MTP-111 shared backtest-paper order input，
/// 输出 simulated exchange event 值对象。它不是撮合 runtime，不读写网络 / 文件 / 数据库，不连接
/// broker / exchange adapter，不实现 signed endpoint、account endpoint、listenKey、OMS、真实订单命令、
/// execution report、broker fill、reconciliation、Live PRO Console、live command 或交易按钮。

/// ScenarioReplayMatchingOrderingRule 固定 MTP-112 matching model 的排序和 tie-break 规则。
///
/// 规则全部来自本地 scenario identity、replay window、cursor、fixture record 和 shared order input，
/// 禁止使用 wall clock、randomness、真实 order book、broker feed 或外部网络状态。
public enum ScenarioReplayMatchingOrderingRule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case scenarioIdentityFirst = "scenario identity first"
    case datasetFixtureVersionMustMatch = "dataset and fixture version must match"
    case replayWindowLocksMarketState = "replay window locks market state"
    case cursorSequenceSelectsRecord = "cursor sequence selects fixture record"
    case fixtureRecordOrderAscending = "fixture record order ascending"
    case sharedOrderInputTieBreak = "shared order input tie-break"
    case noWallClockOrRandomness = "no wall clock or randomness"
    case appendOnlySimulatedEventOutput = "append-only simulated event output"
}

/// ScenarioReplayMatchingOutputKind 限定 MTP-112 当前可输出的 simulated exchange event kind。
///
/// 当前 issue 只建立 matched event 的最小闭环；market / limit order execution、partial fill、
/// latency、fee / slippage 和 portfolio parity 仍归属后续 MTP-113 至 MTP-116。
public enum ScenarioReplayMatchingOutputKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case simulatedExchangeOrderMatched = "simulated exchange order matched"
}

/// ScenarioReplayDeterministicMatchingContract 是 MTP-112 的 matching model 合同 fixture。
///
/// Contract 固定输入来源、ordering rules、output kinds、validation anchors 和 forbidden capabilities。
/// `implementsMatchingRuntime` 必须保持 false；当前文件只提供 deterministic value model。
public struct ScenarioReplayDeterministicMatchingContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let orderingRules: [ScenarioReplayMatchingOrderingRule]
    public let outputKinds: [ScenarioReplayMatchingOutputKind]
    public let forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability]
    public let validationAnchors: [String]
    public let consumesScenarioReplayWindow: Bool
    public let consumesScenarioReplayCursor: Bool
    public let consumesDatasetVersion: Bool
    public let consumesLocalMarketState: Bool
    public let consumesSharedOrderInput: Bool
    public let emitsSimulatedExchangeEvent: Bool
    public let implementsMatchingRuntime: Bool
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
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var contractBoundaryHeld: Bool {
        orderingRules == Self.requiredOrderingRules
            && outputKinds == Self.requiredOutputKinds
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && consumesScenarioReplayWindow
            && consumesScenarioReplayCursor
            && consumesDatasetVersion
            && consumesLocalMarketState
            && consumesSharedOrderInput
            && emitsSimulatedExchangeEvent
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        implementsMatchingRuntime == false
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
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-112-scenario-replay-deterministic-matching"),
        issueID: Identifier = try! Identifier("MTP-112"),
        orderingRules: [ScenarioReplayMatchingOrderingRule] = Self.requiredOrderingRules,
        outputKinds: [ScenarioReplayMatchingOutputKind] = Self.requiredOutputKinds,
        forbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        consumesScenarioReplayWindow: Bool = true,
        consumesScenarioReplayCursor: Bool = true,
        consumesDatasetVersion: Bool = true,
        consumesLocalMarketState: Bool = true,
        consumesSharedOrderInput: Bool = true,
        emitsSimulatedExchangeEvent: Bool = true,
        implementsMatchingRuntime: Bool = false,
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
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validateList(
            field: "scenarioReplayMatchingContract.orderingRules",
            expected: Self.requiredOrderingRules.map(\.rawValue),
            actual: orderingRules.map(\.rawValue)
        )
        try Self.validateList(
            field: "scenarioReplayMatchingContract.outputKinds",
            expected: Self.requiredOutputKinds.map(\.rawValue),
            actual: outputKinds.map(\.rawValue)
        )
        try Self.validateList(
            field: "scenarioReplayMatchingContract.forbiddenCapabilities",
            expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
            actual: forbiddenCapabilities.map(\.rawValue)
        )
        try Self.validateList(
            field: "scenarioReplayMatchingContract.validationAnchors",
            expected: Self.requiredValidationAnchors,
            actual: validationAnchors
        )
        try Self.validateRequiredTrueFlags(
            consumesScenarioReplayWindow: consumesScenarioReplayWindow,
            consumesScenarioReplayCursor: consumesScenarioReplayCursor,
            consumesDatasetVersion: consumesDatasetVersion,
            consumesLocalMarketState: consumesLocalMarketState,
            consumesSharedOrderInput: consumesSharedOrderInput,
            emitsSimulatedExchangeEvent: emitsSimulatedExchangeEvent
        )
        try Self.validateForbiddenFlags(
            prefix: nil,
            implementsMatchingRuntime: implementsMatchingRuntime,
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
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.orderingRules = orderingRules
        self.outputKinds = outputKinds
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.consumesScenarioReplayWindow = consumesScenarioReplayWindow
        self.consumesScenarioReplayCursor = consumesScenarioReplayCursor
        self.consumesDatasetVersion = consumesDatasetVersion
        self.consumesLocalMarketState = consumesLocalMarketState
        self.consumesSharedOrderInput = consumesSharedOrderInput
        self.emitsSimulatedExchangeEvent = emitsSimulatedExchangeEvent
        self.implementsMatchingRuntime = implementsMatchingRuntime
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
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            orderingRules: try container.decode([ScenarioReplayMatchingOrderingRule].self, forKey: .orderingRules),
            outputKinds: try container.decode([ScenarioReplayMatchingOutputKind].self, forKey: .outputKinds),
            forbiddenCapabilities: try container.decode(
                [SimulatedExchangeBacktestParityForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            consumesScenarioReplayWindow: try container.decode(Bool.self, forKey: .consumesScenarioReplayWindow),
            consumesScenarioReplayCursor: try container.decode(Bool.self, forKey: .consumesScenarioReplayCursor),
            consumesDatasetVersion: try container.decode(Bool.self, forKey: .consumesDatasetVersion),
            consumesLocalMarketState: try container.decode(Bool.self, forKey: .consumesLocalMarketState),
            consumesSharedOrderInput: try container.decode(Bool.self, forKey: .consumesSharedOrderInput),
            emitsSimulatedExchangeEvent: try container.decode(Bool.self, forKey: .emitsSimulatedExchangeEvent),
            implementsMatchingRuntime: try container.decode(Bool.self, forKey: .implementsMatchingRuntime),
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

    public static let requiredOrderingRules: [ScenarioReplayMatchingOrderingRule] =
        ScenarioReplayMatchingOrderingRule.allCases

    public static let requiredOutputKinds: [ScenarioReplayMatchingOutputKind] =
        ScenarioReplayMatchingOutputKind.allCases

    public static let requiredForbiddenCapabilities: [SimulatedExchangeBacktestParityForbiddenCapability] =
        SimulatedExchangeBacktestParityForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "MTP-112-SCENARIO-REPLAY-MATCHING-INPUT",
        "MTP-112-DETERMINISTIC-MATCHING-ORDERING",
        "MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT",
        "MTP-112-REPEATABLE-MATCHING-OUTPUT",
        "MTP-112-NO-NETWORK-BROKER-LIVE",
        "MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: ScenarioReplayDeterministicMatchingContract = {
        do {
            return try ScenarioReplayDeterministicMatchingContract()
        } catch {
            preconditionFailure("MTP-112 scenario replay deterministic matching contract must be valid: \(error)")
        }
    }()

    private static func validateRequiredTrueFlags(
        consumesScenarioReplayWindow: Bool,
        consumesScenarioReplayCursor: Bool,
        consumesDatasetVersion: Bool,
        consumesLocalMarketState: Bool,
        consumesSharedOrderInput: Bool,
        emitsSimulatedExchangeEvent: Bool
    ) throws {
        let requiredTrueFlags = [
            ("consumesScenarioReplayWindow", consumesScenarioReplayWindow),
            ("consumesScenarioReplayCursor", consumesScenarioReplayCursor),
            ("consumesDatasetVersion", consumesDatasetVersion),
            ("consumesLocalMarketState", consumesLocalMarketState),
            ("consumesSharedOrderInput", consumesSharedOrderInput),
            ("emitsSimulatedExchangeEvent", emitsSimulatedExchangeEvent)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingContract.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
    }

    fileprivate static func validateList(field: String, expected: [String], actual: [String]) throws {
        guard expected == actual else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: field,
                expected: expected.joined(separator: ","),
                actual: actual.joined(separator: ",")
            )
        }
    }

    fileprivate static func validateForbiddenFlags(
        prefix: String?,
        implementsMatchingRuntime: Bool = false,
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
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let forbiddenFlags = [
            ("implementsMatchingRuntime", implementsMatchingRuntime),
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
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            let field = prefix.map { "\($0).\(capability.0)" } ?? capability.0
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(field)
        }
    }
}

/// ScenarioReplayMatchingMarketState 是 MTP-112 的 local market state 输入。
///
/// Market state 只能由 MTP-106 replay window / cursor 和 MTP-105 deterministic fixture record 组成。
/// Cursor sequence 必须精确选择同一条 fixture record，防止用环境状态或真实行情覆盖本地 replay。
public struct ScenarioReplayMatchingMarketState: Codable, Equatable, Sendable {
    public let replayWindow: ScenarioReplayWindow
    public let cursor: ScenarioReplayCursor
    public let record: ScenarioFixtureRecord
    public let sourceAnchor: String

    public var marketStateBoundaryHeld: Bool {
        cursor.nextRecordSequence == record.sequence
            && cursor.windowIdentity == replayWindow.deterministicWindowIdentity
            && replayWindow.firstRecordSequence <= record.sequence
            && record.sequence <= replayWindow.lastRecordSequence
            && record.bar.symbol == replayWindow.symbol
            && record.bar.timeframe == replayWindow.timeframe
    }

    public init(
        replayWindow: ScenarioReplayWindow = try! ScenarioReplayWindow(),
        cursor: ScenarioReplayCursor = try! ScenarioReplayCursor(nextRecordSequence: 2),
        record: ScenarioFixtureRecord = DeterministicScenarioFixture.deterministicRecords[1],
        sourceAnchor: String = "MTP-112-SCENARIO-REPLAY-MATCHING-INPUT"
    ) throws {
        try Self.validate(
            replayWindow: replayWindow,
            cursor: cursor,
            record: record,
            sourceAnchor: sourceAnchor
        )

        self.replayWindow = replayWindow
        self.cursor = cursor
        self.record = record
        self.sourceAnchor = sourceAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            replayWindow: try container.decode(ScenarioReplayWindow.self, forKey: .replayWindow),
            cursor: try container.decode(ScenarioReplayCursor.self, forKey: .cursor),
            record: try container.decode(ScenarioFixtureRecord.self, forKey: .record),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor)
        )
    }

    private static func validate(
        replayWindow: ScenarioReplayWindow,
        cursor: ScenarioReplayCursor,
        record: ScenarioFixtureRecord,
        sourceAnchor: String
    ) throws {
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingMarketState.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        guard cursor.windowIdentity == replayWindow.deterministicWindowIdentity else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingMarketState.cursorWindowIdentity",
                expected: replayWindow.deterministicWindowIdentity,
                actual: cursor.windowIdentity
            )
        }
        guard cursor.nextRecordSequence == record.sequence else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingMarketState.cursorRecordSequence",
                expected: String(cursor.nextRecordSequence),
                actual: String(record.sequence)
            )
        }
        guard replayWindow.firstRecordSequence <= record.sequence,
              record.sequence <= replayWindow.lastRecordSequence else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingMarketState.recordSequence",
                expected: "\(replayWindow.firstRecordSequence)...\(replayWindow.lastRecordSequence)",
                actual: String(record.sequence)
            )
        }
        guard record.bar.symbol == replayWindow.symbol,
              record.bar.timeframe == replayWindow.timeframe else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingMarketState.symbolTimeframe",
                expected: "\(replayWindow.symbol.rawValue)/\(replayWindow.timeframe.rawValue)",
                actual: "\(record.bar.symbol.rawValue)/\(record.bar.timeframe.rawValue)"
            )
        }
    }
}

/// ScenarioReplayDeterministicMatchingInput 聚合 MTP-112 deterministic matching 所需输入。
///
/// 输入必须同时绑定 scenario replay evidence、local market state 和 MTP-111 shared order input。
/// 所有 forbidden flags 只能为 false，Codable 解码同样执行校验，避免恢复网络或 live capability。
public struct ScenarioReplayDeterministicMatchingInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let sharedOrderInput: BacktestPaperSharedOrderInput
    public let marketState: ScenarioReplayMatchingMarketState
    public let checksumEvidence: ScenarioReplayChecksumEvidence
    public let freshnessEvidence: ScenarioReplayFreshnessEvidence
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
    public let providesTradingButton: Bool

    public var matchingInputBoundaryHeld: Bool {
        sharedOrderInput.sharedFieldBoundaryHeld
            && marketState.marketStateBoundaryHeld
            && checksumEvidence.checksumMatchedCanonicalPreimage
            && checksumEvidence.parityEvidenceStable
            && freshnessEvidence.status == .fresh
            && freshnessEvidence.isLocalFixtureFreshnessOnly
            && validationAnchors == ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var deterministicInputIdentity: String {
        [
            sharedOrderInput.scenarioID.rawValue,
            sharedOrderInput.datasetVersion.rawValue,
            sharedOrderInput.fixtureVersion.rawValue,
            marketState.replayWindow.windowDescription,
            "cursor=\(marketState.cursor.nextRecordSequence)",
            "record=\(marketState.record.sequence)",
            "order=\(sharedOrderInput.orderID.rawValue)"
        ].joined(separator: "|")
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
            && providesTradingButton == false
    }

    public init(
        inputID: Identifier = try! Identifier("mtp-112-deterministic-matching-input"),
        sharedOrderInput: BacktestPaperSharedOrderInput = .deterministicFixture,
        marketState: ScenarioReplayMatchingMarketState = try! ScenarioReplayMatchingMarketState(),
        checksumEvidence: ScenarioReplayChecksumEvidence = try! ScenarioReplayChecksumEvidence(),
        freshnessEvidence: ScenarioReplayFreshnessEvidence = try! ScenarioReplayFreshnessEvidence(),
        validationAnchors: [String] = ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors,
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
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            sharedOrderInput: sharedOrderInput,
            marketState: marketState,
            checksumEvidence: checksumEvidence,
            freshnessEvidence: freshnessEvidence,
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
            providesTradingButton: providesTradingButton
        )

        self.inputID = inputID
        self.sharedOrderInput = sharedOrderInput
        self.marketState = marketState
        self.checksumEvidence = checksumEvidence
        self.freshnessEvidence = freshnessEvidence
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
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            inputID: try container.decode(Identifier.self, forKey: .inputID),
            sharedOrderInput: try container.decode(BacktestPaperSharedOrderInput.self, forKey: .sharedOrderInput),
            marketState: try container.decode(ScenarioReplayMatchingMarketState.self, forKey: .marketState),
            checksumEvidence: try container.decode(ScenarioReplayChecksumEvidence.self, forKey: .checksumEvidence),
            freshnessEvidence: try container.decode(ScenarioReplayFreshnessEvidence.self, forKey: .freshnessEvidence),
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
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    public static let deterministicFixture: ScenarioReplayDeterministicMatchingInput = {
        do {
            return try ScenarioReplayDeterministicMatchingInput()
        } catch {
            preconditionFailure("MTP-112 deterministic matching input must be valid: \(error)")
        }
    }()

    private static func validate(
        sharedOrderInput: BacktestPaperSharedOrderInput,
        marketState: ScenarioReplayMatchingMarketState,
        checksumEvidence: ScenarioReplayChecksumEvidence,
        freshnessEvidence: ScenarioReplayFreshnessEvidence,
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
        providesTradingButton: Bool
    ) throws {
        guard sharedOrderInput.sharedFieldBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingInput.sharedOrderInput",
                expected: "shared field boundary held",
                actual: "false"
            )
        }
        guard marketState.marketStateBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingInput.marketState",
                expected: "market state boundary held",
                actual: "false"
            )
        }
        guard sharedOrderInput.scenarioID == marketState.replayWindow.scenarioID,
              sharedOrderInput.datasetVersion == marketState.replayWindow.datasetVersion,
              sharedOrderInput.fixtureVersion == marketState.replayWindow.fixtureVersion,
              sharedOrderInput.symbol == marketState.replayWindow.symbol,
              sharedOrderInput.timeframe == marketState.replayWindow.timeframe else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingInput.scenarioIdentity",
                expected: marketState.replayWindow.deterministicWindowIdentity,
                actual: [
                    sharedOrderInput.scenarioID.rawValue,
                    sharedOrderInput.datasetVersion.rawValue,
                    sharedOrderInput.fixtureVersion.rawValue,
                    sharedOrderInput.symbol.rawValue,
                    sharedOrderInput.timeframe.rawValue
                ].joined(separator: "|")
            )
        }
        guard checksumEvidence == (try ScenarioReplayChecksumEvidence()) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingInput.checksumEvidence",
                expected: try ScenarioReplayChecksumEvidence().checksum,
                actual: checksumEvidence.checksum
            )
        }
        guard freshnessEvidence == (try ScenarioReplayFreshnessEvidence()) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingInput.freshnessEvidence",
                expected: try ScenarioReplayFreshnessEvidence().freshnessSummary,
                actual: freshnessEvidence.freshnessSummary
            )
        }
        try ScenarioReplayDeterministicMatchingContract.validateList(
            field: "scenarioReplayMatchingInput.validationAnchors",
            expected: ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try ScenarioReplayDeterministicMatchingContract.validateForbiddenFlags(
            prefix: "scenarioReplayMatchingInput",
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
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }
}

/// ScenarioReplaySimulatedExchangeEvent 是 MTP-112 的 matching output event。
///
/// Event 只表达本地 simulated exchange matching result，可作为后续 append-only fact 的候选值。
/// 它不是 broker fill、execution report、真实成交、account update 或 reconciliation 输入。
public struct ScenarioReplaySimulatedExchangeEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let eventKind: ScenarioReplayMatchingOutputKind
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let replayWindowDescription: String
    public let cursorRecordSequence: Int
    public let matchedRecordSequence: Int
    public let orderID: Identifier
    public let sharedOrderState: BacktestPaperSharedOrderState
    public let sharedOrderEventKind: BacktestPaperSharedOrderEventKind
    public let matchedPrice: Price
    public let matchedQuantity: Quantity
    public let eventStream: EventStreamID
    public let sourceAnchor: String
    public let recordsBrokerFill: Bool
    public let ingestsExecutionReport: Bool
    public let runsReconciliation: Bool
    public let submitsRealOrder: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var simulatedEventBoundaryHeld: Bool {
        eventKind == .simulatedExchangeOrderMatched
            && sharedOrderState == .filledSimulated
            && sharedOrderEventKind == .simulatedOrderFilled
            && cursorRecordSequence == matchedRecordSequence
            && eventStream == .paper
            && recordsBrokerFill == false
            && ingestsExecutionReport == false
            && runsReconciliation == false
            && submitsRealOrder == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public init(
        eventID: Identifier = try! Identifier("mtp-112-simulated-exchange-order-matched"),
        input: ScenarioReplayDeterministicMatchingInput,
        eventKind: ScenarioReplayMatchingOutputKind = .simulatedExchangeOrderMatched,
        sharedOrderState: BacktestPaperSharedOrderState = .filledSimulated,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind = .simulatedOrderFilled,
        matchedPrice: Price,
        matchedQuantity: Quantity,
        eventStream: EventStreamID = .paper,
        sourceAnchor: String = "MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT",
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        submitsRealOrder: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            eventKind: eventKind,
            cursorRecordSequence: input.marketState.cursor.nextRecordSequence,
            matchedRecordSequence: input.marketState.record.sequence,
            sharedOrderState: sharedOrderState,
            sharedOrderEventKind: sharedOrderEventKind,
            matchedQuantity: matchedQuantity,
            eventStream: eventStream,
            sourceAnchor: sourceAnchor,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            submitsRealOrder: submitsRealOrder,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )

        self.eventID = eventID
        self.eventKind = eventKind
        self.scenarioID = input.sharedOrderInput.scenarioID
        self.datasetVersion = input.sharedOrderInput.datasetVersion
        self.fixtureVersion = input.sharedOrderInput.fixtureVersion
        self.replayWindowDescription = input.marketState.replayWindow.windowDescription
        self.cursorRecordSequence = input.marketState.cursor.nextRecordSequence
        self.matchedRecordSequence = input.marketState.record.sequence
        self.orderID = input.sharedOrderInput.orderID
        self.sharedOrderState = sharedOrderState
        self.sharedOrderEventKind = sharedOrderEventKind
        self.matchedPrice = matchedPrice
        self.matchedQuantity = matchedQuantity
        self.eventStream = eventStream
        self.sourceAnchor = sourceAnchor
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.submitsRealOrder = submitsRealOrder
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let eventKind = try container.decode(ScenarioReplayMatchingOutputKind.self, forKey: .eventKind)
        let cursorRecordSequence = try container.decode(Int.self, forKey: .cursorRecordSequence)
        let matchedRecordSequence = try container.decode(Int.self, forKey: .matchedRecordSequence)
        let sharedOrderState = try container.decode(BacktestPaperSharedOrderState.self, forKey: .sharedOrderState)
        let sharedOrderEventKind = try container.decode(
            BacktestPaperSharedOrderEventKind.self,
            forKey: .sharedOrderEventKind
        )
        let matchedQuantity = try container.decode(Quantity.self, forKey: .matchedQuantity)
        let eventStream = try container.decode(EventStreamID.self, forKey: .eventStream)
        let sourceAnchor = try container.decode(String.self, forKey: .sourceAnchor)
        let recordsBrokerFill = try container.decode(Bool.self, forKey: .recordsBrokerFill)
        let ingestsExecutionReport = try container.decode(Bool.self, forKey: .ingestsExecutionReport)
        let runsReconciliation = try container.decode(Bool.self, forKey: .runsReconciliation)
        let submitsRealOrder = try container.decode(Bool.self, forKey: .submitsRealOrder)
        let providesLiveCommand = try container.decode(Bool.self, forKey: .providesLiveCommand)
        let providesTradingButton = try container.decode(Bool.self, forKey: .providesTradingButton)
        try Self.validate(
            eventKind: eventKind,
            cursorRecordSequence: cursorRecordSequence,
            matchedRecordSequence: matchedRecordSequence,
            sharedOrderState: sharedOrderState,
            sharedOrderEventKind: sharedOrderEventKind,
            matchedQuantity: matchedQuantity,
            eventStream: eventStream,
            sourceAnchor: sourceAnchor,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            submitsRealOrder: submitsRealOrder,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )

        self.eventID = try container.decode(Identifier.self, forKey: .eventID)
        self.eventKind = eventKind
        self.scenarioID = try container.decode(ScenarioID.self, forKey: .scenarioID)
        self.datasetVersion = try container.decode(DatasetVersion.self, forKey: .datasetVersion)
        self.fixtureVersion = try container.decode(FixtureVersion.self, forKey: .fixtureVersion)
        self.replayWindowDescription = try container.decode(String.self, forKey: .replayWindowDescription)
        self.cursorRecordSequence = cursorRecordSequence
        self.matchedRecordSequence = matchedRecordSequence
        self.orderID = try container.decode(Identifier.self, forKey: .orderID)
        self.sharedOrderState = sharedOrderState
        self.sharedOrderEventKind = sharedOrderEventKind
        self.matchedPrice = try container.decode(Price.self, forKey: .matchedPrice)
        self.matchedQuantity = matchedQuantity
        self.eventStream = eventStream
        self.sourceAnchor = sourceAnchor
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.submitsRealOrder = submitsRealOrder
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    private static func validate(
        eventKind: ScenarioReplayMatchingOutputKind,
        cursorRecordSequence: Int,
        matchedRecordSequence: Int,
        sharedOrderState: BacktestPaperSharedOrderState,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind,
        matchedQuantity: Quantity,
        eventStream: EventStreamID,
        sourceAnchor: String,
        recordsBrokerFill: Bool,
        ingestsExecutionReport: Bool,
        runsReconciliation: Bool,
        submitsRealOrder: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        guard eventKind == .simulatedExchangeOrderMatched,
              sharedOrderState == .filledSimulated,
              sharedOrderEventKind == .simulatedOrderFilled,
              cursorRecordSequence == matchedRecordSequence,
              matchedQuantity.rawValue > 0,
              eventStream == .paper,
              sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplaySimulatedExchangeEvent",
                expected: "matched simulated paper event",
                actual: eventKind.rawValue
            )
        }
        let forbiddenFlags = [
            ("recordsBrokerFill", recordsBrokerFill),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("runsReconciliation", runsReconciliation),
            ("submitsRealOrder", submitsRealOrder),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(
                "scenarioReplaySimulatedExchangeEvent.\(capability.0)"
            )
        }
    }
}

/// ScenarioReplayDeterministicMatchingOutput 是 MTP-112 的 deterministic matching 输出。
///
/// Output 保留 deterministic result identity，便于测试证明同一 scenario id / dataset version /
/// replay window / order input 可重复生成完全一致的 simulated exchange matching event。
public struct ScenarioReplayDeterministicMatchingOutput: Codable, Equatable, Sendable {
    public let outputID: Identifier
    public let inputIdentity: String
    public let simulatedExchangeEvent: ScenarioReplaySimulatedExchangeEvent
    public let orderingRules: [ScenarioReplayMatchingOrderingRule]
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var matchingOutputBoundaryHeld: Bool {
        simulatedExchangeEvent.simulatedEventBoundaryHeld
            && orderingRules == ScenarioReplayDeterministicMatchingContract.requiredOrderingRules
            && validationAnchors == ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors
            && requiredValidationDependsOnNetwork == false
            && usesWallClockTime == false
            && usesRandomness == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public var deterministicResultIdentity: String {
        [
            simulatedExchangeEvent.scenarioID.rawValue,
            simulatedExchangeEvent.datasetVersion.rawValue,
            simulatedExchangeEvent.fixtureVersion.rawValue,
            simulatedExchangeEvent.replayWindowDescription,
            "cursor=\(simulatedExchangeEvent.cursorRecordSequence)",
            "record=\(simulatedExchangeEvent.matchedRecordSequence)",
            "order=\(simulatedExchangeEvent.orderID.rawValue)",
            "price=\(Self.scaledInteger(simulatedExchangeEvent.matchedPrice.rawValue))",
            "quantity=\(Self.scaledInteger(simulatedExchangeEvent.matchedQuantity.rawValue))"
        ].joined(separator: "|")
    }

    public init(
        outputID: Identifier = try! Identifier("mtp-112-deterministic-matching-output"),
        inputIdentity: String,
        simulatedExchangeEvent: ScenarioReplaySimulatedExchangeEvent,
        orderingRules: [ScenarioReplayMatchingOrderingRule] =
            ScenarioReplayDeterministicMatchingContract.requiredOrderingRules,
        validationAnchors: [String] = ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            inputIdentity: inputIdentity,
            simulatedExchangeEvent: simulatedExchangeEvent,
            orderingRules: orderingRules,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )

        self.outputID = outputID
        self.inputIdentity = inputIdentity
        self.simulatedExchangeEvent = simulatedExchangeEvent
        self.orderingRules = orderingRules
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            outputID: try container.decode(Identifier.self, forKey: .outputID),
            inputIdentity: try container.decode(String.self, forKey: .inputIdentity),
            simulatedExchangeEvent: try container.decode(
                ScenarioReplaySimulatedExchangeEvent.self,
                forKey: .simulatedExchangeEvent
            ),
            orderingRules: try container.decode([ScenarioReplayMatchingOrderingRule].self, forKey: .orderingRules),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    fileprivate static func scaledInteger(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }

    private static func validate(
        inputIdentity: String,
        simulatedExchangeEvent: ScenarioReplaySimulatedExchangeEvent,
        orderingRules: [ScenarioReplayMatchingOrderingRule],
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        usesWallClockTime: Bool,
        usesRandomness: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        guard inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              simulatedExchangeEvent.simulatedEventBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayMatchingOutput",
                expected: "non-empty input identity and simulated event boundary held",
                actual: inputIdentity
            )
        }
        try ScenarioReplayDeterministicMatchingContract.validateList(
            field: "scenarioReplayMatchingOutput.orderingRules",
            expected: ScenarioReplayDeterministicMatchingContract.requiredOrderingRules.map(\.rawValue),
            actual: orderingRules.map(\.rawValue)
        )
        try ScenarioReplayDeterministicMatchingContract.validateList(
            field: "scenarioReplayMatchingOutput.validationAnchors",
            expected: ScenarioReplayDeterministicMatchingContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try ScenarioReplayDeterministicMatchingContract.validateForbiddenFlags(
            prefix: "scenarioReplayMatchingOutput",
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }
}

/// ScenarioReplayDeterministicMatchingModel 是 MTP-112 的纯函数 matching 入口。
///
/// `match` 只读取传入的 deterministic input，使用 selected fixture record 的 close price 和
/// shared order input quantity 生成 simulated exchange event。它不保存状态、不调度、不访问网络、
/// 不使用当前时间或随机数，也不代表真实交易所撮合。
public enum ScenarioReplayDeterministicMatchingModel {
    public static func match(
        _ input: ScenarioReplayDeterministicMatchingInput
    ) throws -> ScenarioReplayDeterministicMatchingOutput {
        guard input.matchingInputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "scenarioReplayDeterministicMatchingModel.input",
                expected: "matching input boundary held",
                actual: "false"
            )
        }

        let event = try ScenarioReplaySimulatedExchangeEvent(
            input: input,
            matchedPrice: input.marketState.record.bar.close,
            matchedQuantity: input.sharedOrderInput.quantity
        )
        return try ScenarioReplayDeterministicMatchingOutput(
            inputIdentity: input.deterministicInputIdentity,
            simulatedExchangeEvent: event
        )
    }
}
