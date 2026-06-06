import DomainModel
import Foundation

/// MTP-114 partial fill / latency / fee / slippage parity 只定义本地 deterministic parity evidence。
///
/// 本文件消费 MTP-113 market / limit simulated execution 输入，复用 MTP-112 deterministic
/// matching、MTP-111 shared order semantics 和 MTP-27 fixed execution cost assumptions，输出
/// partial / full fill、latency 和 fee / slippage 的模拟证据。它不是撮合 runtime，不读取真实流动性，
/// 不接 signed endpoint / account endpoint / listenKey / broker，不生成 execution report、broker fill、
/// reconciliation、portfolio projection、live command、order form 或交易按钮。

/// PartialFillLatencyFeeSlippageParityRule 固定 MTP-114 的 deterministic parity 规则。
///
/// 规则只允许使用本地 MTP-113 execution input、固定 simulated liquidity cap、固定 latency assumption
/// 和 MTP-27 execution cost assumptions；不得引入 wall clock、randomness、真实费率表或动态滑点模型。
public enum PartialFillLatencyFeeSlippageParityRule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case consumesMarketLimitSimulatedExecution = "consumes MTP-113 market / limit simulated execution"
    case capsFillByDeterministicLiquidity = "caps fill quantity by deterministic simulated liquidity"
    case distinguishesPartialAndFullFill = "distinguishes partial fill and full fill"
    case partialFillKeepsRemainingQuantity = "partial fill keeps remaining quantity"
    case latencyUsesReplaySequenceOffset = "latency uses replay sequence offset"
    case reusesFixedExecutionCostAssumptions = "reuses MTP-27 fixed execution cost assumptions"
    case backtestPaperCostParityMustMatch = "backtest and paper cost parity must match"
    case emitsSimulatedExchangeReportEvidenceOnly = "emits simulated exchange report evidence only"
    case noRealFeeScheduleBrokerReconciliation = "no real fee schedule / broker fill / reconciliation"
}

/// PartialFillLatencyFeeSlippageForbiddenCapability 枚举 MTP-114 必须持续禁止的能力面。
///
/// 这些能力只作为边界校验证据存在。任何初始化或 Codable 解码试图打开这些能力都必须失败，
/// 避免 fee / slippage parity 被误解释为真实交易所费率表、真实成交质量或 live readiness。
public enum PartialFillLatencyFeeSlippageForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realFeeSchedule = "real fee schedule"
    case dynamicSlippageModel = "dynamic slippage model"
    case realLiquidityConsumption = "real liquidity consumption"
    case executionCostOptimization = "execution cost optimization"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case brokerIntegration = "broker integration"
    case brokerFill = "broker fill"
    case executionReport = "execution report"
    case reconciliation = "reconciliation"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case portfolioProjectionRuntime = "portfolio projection runtime"
    case liveCommand = "live command"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case wallClockTime = "wall clock time"
    case randomness = "randomness"
    case requiredNetworkValidation = "required network validation"
}

/// PartialFillLatencyFeeSlippageParityContract 是 MTP-114 的 parity 合同 fixture。
///
/// Contract 固定 partial / full fill、latency、fee / slippage parity 的规则、validation anchors
/// 和 forbidden capabilities。它只描述 deterministic simulated exchange event / report evidence，
/// 不实现 runtime、portfolio projection、真实 broker 对账或 UI surface。
public struct PartialFillLatencyFeeSlippageParityContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let rules: [PartialFillLatencyFeeSlippageParityRule]
    public let fillCompletions: [PaperSimulatedFillCompletion]
    public let forbiddenCapabilities: [PartialFillLatencyFeeSlippageForbiddenCapability]
    public let validationAnchors: [String]
    public let consumesMarketLimitSimulatedExecution: Bool
    public let definesPartialAndFullFill: Bool
    public let definesLatencyModel: Bool
    public let reusesFixedExecutionCostAssumptions: Bool
    public let emitsSimulatedExchangeReportEvidenceOnly: Bool
    public let usesRealFeeSchedule: Bool
    public let usesDynamicSlippageModel: Bool
    public let consumesRealLiquidity: Bool
    public let optimizesExecutionCost: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let recordsBrokerFill: Bool
    public let ingestsExecutionReport: Bool
    public let runsReconciliation: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let implementsPortfolioProjectionRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var contractBoundaryHeld: Bool {
        rules == Self.requiredRules
            && fillCompletions == Self.requiredFillCompletions
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && consumesMarketLimitSimulatedExecution
            && definesPartialAndFullFill
            && definesLatencyModel
            && reusesFixedExecutionCostAssumptions
            && emitsSimulatedExchangeReportEvidenceOnly
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        allForbiddenFlagsRemainFalse
    }

    private var allForbiddenFlagsRemainFalse: Bool {
        usesRealFeeSchedule == false
            && usesDynamicSlippageModel == false
            && consumesRealLiquidity == false
            && optimizesExecutionCost == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && recordsBrokerFill == false
            && ingestsExecutionReport == false
            && runsReconciliation == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && implementsPortfolioProjectionRuntime == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && usesWallClockTime == false
            && usesRandomness == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = Identifier.constant("mtp-114-partial-fill-latency-fee-slippage-parity"),
        issueID: Identifier = Identifier.constant("MTP-114"),
        rules: [PartialFillLatencyFeeSlippageParityRule] = Self.requiredRules,
        fillCompletions: [PaperSimulatedFillCompletion] = Self.requiredFillCompletions,
        forbiddenCapabilities: [PartialFillLatencyFeeSlippageForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        consumesMarketLimitSimulatedExecution: Bool = true,
        definesPartialAndFullFill: Bool = true,
        definesLatencyModel: Bool = true,
        reusesFixedExecutionCostAssumptions: Bool = true,
        emitsSimulatedExchangeReportEvidenceOnly: Bool = true,
        usesRealFeeSchedule: Bool = false,
        usesDynamicSlippageModel: Bool = false,
        consumesRealLiquidity: Bool = false,
        optimizesExecutionCost: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validateList(
            field: "partialFillLatencyFeeSlippageParityContract.rules",
            expected: Self.requiredRules.map(\.rawValue),
            actual: rules.map(\.rawValue)
        )
        try Self.validateList(
            field: "partialFillLatencyFeeSlippageParityContract.fillCompletions",
            expected: Self.requiredFillCompletions.map(\.rawValue),
            actual: fillCompletions.map(\.rawValue)
        )
        try Self.validateList(
            field: "partialFillLatencyFeeSlippageParityContract.forbiddenCapabilities",
            expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
            actual: forbiddenCapabilities.map(\.rawValue)
        )
        try Self.validateList(
            field: "partialFillLatencyFeeSlippageParityContract.validationAnchors",
            expected: Self.requiredValidationAnchors,
            actual: validationAnchors
        )
        try Self.validateRequiredTrueFlags(
            consumesMarketLimitSimulatedExecution: consumesMarketLimitSimulatedExecution,
            definesPartialAndFullFill: definesPartialAndFullFill,
            definesLatencyModel: definesLatencyModel,
            reusesFixedExecutionCostAssumptions: reusesFixedExecutionCostAssumptions,
            emitsSimulatedExchangeReportEvidenceOnly: emitsSimulatedExchangeReportEvidenceOnly
        )
        try Self.validateForbiddenFlags(
            prefix: nil,
            usesRealFeeSchedule: usesRealFeeSchedule,
            usesDynamicSlippageModel: usesDynamicSlippageModel,
            consumesRealLiquidity: consumesRealLiquidity,
            optimizesExecutionCost: optimizesExecutionCost,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            implementsPortfolioProjectionRuntime: implementsPortfolioProjectionRuntime,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.rules = rules
        self.fillCompletions = fillCompletions
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.consumesMarketLimitSimulatedExecution = consumesMarketLimitSimulatedExecution
        self.definesPartialAndFullFill = definesPartialAndFullFill
        self.definesLatencyModel = definesLatencyModel
        self.reusesFixedExecutionCostAssumptions = reusesFixedExecutionCostAssumptions
        self.emitsSimulatedExchangeReportEvidenceOnly = emitsSimulatedExchangeReportEvidenceOnly
        self.usesRealFeeSchedule = usesRealFeeSchedule
        self.usesDynamicSlippageModel = usesDynamicSlippageModel
        self.consumesRealLiquidity = consumesRealLiquidity
        self.optimizesExecutionCost = optimizesExecutionCost
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.implementsPortfolioProjectionRuntime = implementsPortfolioProjectionRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            rules: try container.decode([PartialFillLatencyFeeSlippageParityRule].self, forKey: .rules),
            fillCompletions: try container.decode([PaperSimulatedFillCompletion].self, forKey: .fillCompletions),
            forbiddenCapabilities: try container.decode(
                [PartialFillLatencyFeeSlippageForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            consumesMarketLimitSimulatedExecution: try container.decode(
                Bool.self,
                forKey: .consumesMarketLimitSimulatedExecution
            ),
            definesPartialAndFullFill: try container.decode(Bool.self, forKey: .definesPartialAndFullFill),
            definesLatencyModel: try container.decode(Bool.self, forKey: .definesLatencyModel),
            reusesFixedExecutionCostAssumptions: try container.decode(
                Bool.self,
                forKey: .reusesFixedExecutionCostAssumptions
            ),
            emitsSimulatedExchangeReportEvidenceOnly: try container.decode(
                Bool.self,
                forKey: .emitsSimulatedExchangeReportEvidenceOnly
            ),
            usesRealFeeSchedule: try container.decode(Bool.self, forKey: .usesRealFeeSchedule),
            usesDynamicSlippageModel: try container.decode(Bool.self, forKey: .usesDynamicSlippageModel),
            consumesRealLiquidity: try container.decode(Bool.self, forKey: .consumesRealLiquidity),
            optimizesExecutionCost: try container.decode(Bool.self, forKey: .optimizesExecutionCost),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            implementsPortfolioProjectionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPortfolioProjectionRuntime
            ),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: PartialFillLatencyFeeSlippageForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredRules: [PartialFillLatencyFeeSlippageParityRule] =
        PartialFillLatencyFeeSlippageParityRule.allCases

    public static let requiredFillCompletions: [PaperSimulatedFillCompletion] = [.full, .partial]

    public static let requiredForbiddenCapabilities: [PartialFillLatencyFeeSlippageForbiddenCapability] =
        PartialFillLatencyFeeSlippageForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "MTP-114-PARTIAL-FULL-FILL-PARITY",
        "MTP-114-DETERMINISTIC-LATENCY-MODEL",
        "MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS",
        "MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE",
        "MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION",
        "MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: PartialFillLatencyFeeSlippageParityContract = {
        do {
            return try PartialFillLatencyFeeSlippageParityContract()
        } catch {
            preconditionFailure("MTP-114 partial fill latency fee slippage contract must be valid: \(error)")
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
        consumesMarketLimitSimulatedExecution: Bool,
        definesPartialAndFullFill: Bool,
        definesLatencyModel: Bool,
        reusesFixedExecutionCostAssumptions: Bool,
        emitsSimulatedExchangeReportEvidenceOnly: Bool
    ) throws {
        let requiredTrueFlags = [
            ("consumesMarketLimitSimulatedExecution", consumesMarketLimitSimulatedExecution),
            ("definesPartialAndFullFill", definesPartialAndFullFill),
            ("definesLatencyModel", definesLatencyModel),
            ("reusesFixedExecutionCostAssumptions", reusesFixedExecutionCostAssumptions),
            ("emitsSimulatedExchangeReportEvidenceOnly", emitsSimulatedExchangeReportEvidenceOnly)
        ]
        if let flag = requiredTrueFlags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityContract.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
    }

    fileprivate static func validateForbiddenFlags(
        prefix: String?,
        usesRealFeeSchedule: Bool = false,
        usesDynamicSlippageModel: Bool = false,
        consumesRealLiquidity: Bool = false,
        optimizesExecutionCost: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let forbiddenFlags = [
            ("usesRealFeeSchedule", usesRealFeeSchedule),
            ("usesDynamicSlippageModel", usesDynamicSlippageModel),
            ("consumesRealLiquidity", consumesRealLiquidity),
            ("optimizesExecutionCost", optimizesExecutionCost),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("recordsBrokerFill", recordsBrokerFill),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("runsReconciliation", runsReconciliation),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("implementsPortfolioProjectionRuntime", implementsPortfolioProjectionRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("usesWallClockTime", usesWallClockTime),
            ("usesRandomness", usesRandomness),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]
        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            let field = prefix.map { "\($0).\(capability.0)" } ?? capability.0
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(field)
        }
    }
}

/// PartialFillLatencyFeeSlippageLatencyAssumption 固定 MTP-114 deterministic latency input / output。
///
/// latency 只由 replay record sequence 和固定 tick offset 推导。它不读取 wall clock，不衡量真实网络，
/// 不代表 exchange latency、broker SLA、production telemetry 或自动优化信号。
public struct PartialFillLatencyFeeSlippageLatencyAssumption: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let sourceRecordSequence: Int
    public let fixedDelayTicks: Int
    public let fixedDelayMilliseconds: Double
    public let outputRecordSequence: Int
    public let sourceAnchor: String
    public let usesWallClockTime: Bool
    public let usesRandomness: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var latencyBoundaryHeld: Bool {
        sourceRecordSequence > 0
            && fixedDelayTicks > 0
            && fixedDelayMilliseconds.isFinite
            && fixedDelayMilliseconds >= 0
            && outputRecordSequence == sourceRecordSequence + fixedDelayTicks
            && sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && usesWallClockTime == false
            && usesRandomness == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        assumptionID: Identifier = Identifier.constant("mtp-114-deterministic-latency-assumption"),
        sourceRecordSequence: Int = 2,
        fixedDelayTicks: Int = 1,
        fixedDelayMilliseconds: Double = 250,
        outputRecordSequence: Int = 3,
        sourceAnchor: String = "MTP-114-DETERMINISTIC-LATENCY-MODEL",
        usesWallClockTime: Bool = false,
        usesRandomness: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard sourceRecordSequence > 0,
              fixedDelayTicks > 0,
              fixedDelayMilliseconds.isFinite,
              fixedDelayMilliseconds >= 0,
              outputRecordSequence == sourceRecordSequence + fixedDelayTicks,
              sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageLatencyAssumption",
                expected: "positive deterministic sequence offset and non-empty source anchor",
                actual: "\(sourceRecordSequence)->\(outputRecordSequence)"
            )
        }
        try PartialFillLatencyFeeSlippageParityContract.validateForbiddenFlags(
            prefix: "partialFillLatencyFeeSlippageLatencyAssumption",
            usesWallClockTime: usesWallClockTime,
            usesRandomness: usesRandomness,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.assumptionID = assumptionID
        self.sourceRecordSequence = sourceRecordSequence
        self.fixedDelayTicks = fixedDelayTicks
        self.fixedDelayMilliseconds = fixedDelayMilliseconds
        self.outputRecordSequence = outputRecordSequence
        self.sourceAnchor = sourceAnchor
        self.usesWallClockTime = usesWallClockTime
        self.usesRandomness = usesRandomness
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            assumptionID: try container.decode(Identifier.self, forKey: .assumptionID),
            sourceRecordSequence: try container.decode(Int.self, forKey: .sourceRecordSequence),
            fixedDelayTicks: try container.decode(Int.self, forKey: .fixedDelayTicks),
            fixedDelayMilliseconds: try container.decode(Double.self, forKey: .fixedDelayMilliseconds),
            outputRecordSequence: try container.decode(Int.self, forKey: .outputRecordSequence),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            usesWallClockTime: try container.decode(Bool.self, forKey: .usesWallClockTime),
            usesRandomness: try container.decode(Bool.self, forKey: .usesRandomness),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let deterministicFixture: PartialFillLatencyFeeSlippageLatencyAssumption = {
        do {
            return try PartialFillLatencyFeeSlippageLatencyAssumption()
        } catch {
            preconditionFailure("MTP-114 deterministic latency fixture must be valid: \(error)")
        }
    }()
}

/// PartialFillLatencyFeeSlippageParityInput 聚合 MTP-114 parity 所需的本地 deterministic 输入。
///
/// 输入必须复用 MTP-113 execution input、显式 deterministic simulated liquidity、固定 latency
/// assumption 和 MTP-27 fixed cost assumptions。`availableSimulatedLiquidity` 是 fixture cap，不是
/// 真实盘口深度、真实流动性消耗、broker quote 或 account / margin 约束。
public struct PartialFillLatencyFeeSlippageParityInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let marketLimitExecutionInput: MarketLimitSimulatedExecutionInput
    public let availableSimulatedLiquidity: Quantity
    public let latencyAssumption: PartialFillLatencyFeeSlippageLatencyAssumption
    public let liquidityRole: ExecutionCostLiquidityRole
    public let costAssumptions: ExecutionCostAssumptions
    public let validationAnchors: [String]
    public let usesRealFeeSchedule: Bool
    public let usesDynamicSlippageModel: Bool
    public let consumesRealLiquidity: Bool
    public let optimizesExecutionCost: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let recordsBrokerFill: Bool
    public let ingestsExecutionReport: Bool
    public let runsReconciliation: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsPortfolioProjectionRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var parityInputBoundaryHeld: Bool {
        marketLimitExecutionInput.executionInputBoundaryHeld
            && availableSimulatedLiquidity.rawValue > 0
            && availableSimulatedLiquidity.rawValue <= marketLimitExecutionInput.matchingInput.sharedOrderInput.quantity.rawValue
            && latencyAssumption.latencyBoundaryHeld
            && costAssumptions == .deterministicFixture
            && validationAnchors == PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var deterministicInputIdentity: String {
        [
            marketLimitExecutionInput.deterministicInputIdentity,
            "availableLiquidity=\(Self.scaledQuantity(availableSimulatedLiquidity.rawValue))",
            "latencyAssumption=\(latencyAssumption.assumptionID.rawValue)",
            "latencySource=\(latencyAssumption.sourceRecordSequence)",
            "latencyOutput=\(latencyAssumption.outputRecordSequence)",
            "liquidityRole=\(liquidityRole.rawValue)",
            "costAssumption=\(costAssumptions.assumptionID.rawValue)"
        ].joined(separator: "|")
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        usesRealFeeSchedule == false
            && usesDynamicSlippageModel == false
            && consumesRealLiquidity == false
            && optimizesExecutionCost == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && recordsBrokerFill == false
            && ingestsExecutionReport == false
            && runsReconciliation == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsPortfolioProjectionRuntime == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        inputID: Identifier = Identifier.constant("mtp-114-partial-fill-latency-fee-slippage-input"),
        marketLimitExecutionInput: MarketLimitSimulatedExecutionInput = .deterministicMarketFixture,
        availableSimulatedLiquidity: Quantity,
        latencyAssumption: PartialFillLatencyFeeSlippageLatencyAssumption = .deterministicFixture,
        liquidityRole: ExecutionCostLiquidityRole = .taker,
        costAssumptions: ExecutionCostAssumptions = .deterministicFixture,
        validationAnchors: [String] = PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors,
        usesRealFeeSchedule: Bool = false,
        usesDynamicSlippageModel: Bool = false,
        consumesRealLiquidity: Bool = false,
        optimizesExecutionCost: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsPortfolioProjectionRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard marketLimitExecutionInput.executionInputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityInput.marketLimitExecutionInput",
                expected: "MTP-113 execution input boundary held",
                actual: "false"
            )
        }
        let orderQuantity = marketLimitExecutionInput.matchingInput.sharedOrderInput.quantity.rawValue
        guard availableSimulatedLiquidity.rawValue > 0,
              availableSimulatedLiquidity.rawValue <= orderQuantity else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityInput.availableSimulatedLiquidity",
                expected: "0 < liquidity <= order quantity \(orderQuantity)",
                actual: "\(availableSimulatedLiquidity.rawValue)"
            )
        }
        guard latencyAssumption.latencyBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityInput.latencyAssumption",
                expected: "deterministic latency boundary held",
                actual: "false"
            )
        }
        guard costAssumptions == .deterministicFixture else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityInput.costAssumptions",
                expected: ExecutionCostAssumptions.deterministicFixture.assumptionID.rawValue,
                actual: costAssumptions.assumptionID.rawValue
            )
        }
        try PartialFillLatencyFeeSlippageParityContract.validateList(
            field: "partialFillLatencyFeeSlippageParityInput.validationAnchors",
            expected: PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try PartialFillLatencyFeeSlippageParityContract.validateForbiddenFlags(
            prefix: "partialFillLatencyFeeSlippageParityInput",
            usesRealFeeSchedule: usesRealFeeSchedule,
            usesDynamicSlippageModel: usesDynamicSlippageModel,
            consumesRealLiquidity: consumesRealLiquidity,
            optimizesExecutionCost: optimizesExecutionCost,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsPortfolioProjectionRuntime: implementsPortfolioProjectionRuntime,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.inputID = inputID
        self.marketLimitExecutionInput = marketLimitExecutionInput
        self.availableSimulatedLiquidity = availableSimulatedLiquidity
        self.latencyAssumption = latencyAssumption
        self.liquidityRole = liquidityRole
        self.costAssumptions = costAssumptions
        self.validationAnchors = validationAnchors
        self.usesRealFeeSchedule = usesRealFeeSchedule
        self.usesDynamicSlippageModel = usesDynamicSlippageModel
        self.consumesRealLiquidity = consumesRealLiquidity
        self.optimizesExecutionCost = optimizesExecutionCost
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsPortfolioProjectionRuntime = implementsPortfolioProjectionRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            inputID: try container.decode(Identifier.self, forKey: .inputID),
            marketLimitExecutionInput: try container.decode(
                MarketLimitSimulatedExecutionInput.self,
                forKey: .marketLimitExecutionInput
            ),
            availableSimulatedLiquidity: try container.decode(Quantity.self, forKey: .availableSimulatedLiquidity),
            latencyAssumption: try container.decode(
                PartialFillLatencyFeeSlippageLatencyAssumption.self,
                forKey: .latencyAssumption
            ),
            liquidityRole: try container.decode(ExecutionCostLiquidityRole.self, forKey: .liquidityRole),
            costAssumptions: try container.decode(ExecutionCostAssumptions.self, forKey: .costAssumptions),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            usesRealFeeSchedule: try container.decode(Bool.self, forKey: .usesRealFeeSchedule),
            usesDynamicSlippageModel: try container.decode(Bool.self, forKey: .usesDynamicSlippageModel),
            consumesRealLiquidity: try container.decode(Bool.self, forKey: .consumesRealLiquidity),
            optimizesExecutionCost: try container.decode(Bool.self, forKey: .optimizesExecutionCost),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsPortfolioProjectionRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPortfolioProjectionRuntime
            ),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let deterministicPartialFixture: PartialFillLatencyFeeSlippageParityInput = {
        do {
            return try PartialFillLatencyFeeSlippageParityInput(
                availableSimulatedLiquidity: try Quantity(0.25, field: "partialFillLatencyFeeSlippage.availableLiquidity")
            )
        } catch {
            preconditionFailure("MTP-114 deterministic partial input must be valid: \(error)")
        }
    }()

    public static let deterministicFullFixture: PartialFillLatencyFeeSlippageParityInput = {
        do {
            return try PartialFillLatencyFeeSlippageParityInput(
                availableSimulatedLiquidity: try Quantity(0.5, field: "partialFillLatencyFeeSlippage.availableLiquidity")
            )
        } catch {
            preconditionFailure("MTP-114 deterministic full input must be valid: \(error)")
        }
    }()

    fileprivate static func scaledQuantity(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }
}

/// PartialFillLatencyFeeSlippageParityEvent 是 MTP-114 的 simulated exchange parity event。
///
/// Event 只保存 partial / full fill、latency 和 fee / slippage cost parity 的本地证据。它不会写入
/// Event Log，不更新 portfolio，不代表 broker partial fill、execution report、真实成交成本或对账结果。
public struct PartialFillLatencyFeeSlippageParityEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let sourceExecutionEventID: Identifier
    public let orderID: Identifier
    public let orderType: MarketLimitSimulatedOrderType
    public let fillCompletion: PaperSimulatedFillCompletion
    public let sharedOrderState: BacktestPaperSharedOrderState
    public let sharedOrderEventKind: BacktestPaperSharedOrderEventKind
    public let matchedPrice: Price
    public let orderQuantity: Quantity
    public let availableSimulatedLiquidity: Quantity
    public let filledQuantity: Quantity
    public let remainingQuantity: Quantity
    public let latencyAssumptionID: Identifier
    public let latencyInputRecordSequence: Int
    public let latencyOutputRecordSequence: Int
    public let latencyMilliseconds: Double
    public let backtestCostEstimate: ExecutionCostEstimate
    public let paperCostEstimate: ExecutionCostEstimate
    public let costParityResult: ExecutionCostParityResult
    public let eventStream: EventStreamID
    public let sourceAnchor: String
    public let usesRealFeeSchedule: Bool
    public let usesDynamicSlippageModel: Bool
    public let consumesRealLiquidity: Bool
    public let recordsBrokerFill: Bool
    public let ingestsExecutionReport: Bool
    public let runsReconciliation: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var parityEventBoundaryHeld: Bool {
        eventStream == .paper
            && sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && fillCompletionBoundaryHeld
            && latencyInputRecordSequence > 0
            && latencyOutputRecordSequence > latencyInputRecordSequence
            && latencyMilliseconds.isFinite
            && latencyMilliseconds >= 0
            && costParityResult.isConsistent
            && backtestCostEstimate.executionMode == .backtest
            && paperCostEstimate.executionMode == .paper
            && quantitiesMatch(backtestCostEstimate.quantity.rawValue, filledQuantity.rawValue)
            && quantitiesMatch(paperCostEstimate.quantity.rawValue, filledQuantity.rawValue)
            && backtestCostEstimate.referencePrice == matchedPrice
            && paperCostEstimate.referencePrice == matchedPrice
            && forbiddenCapabilityBoundaryHeld
    }

    private var fillCompletionBoundaryHeld: Bool {
        switch fillCompletion {
        case .full:
            return sharedOrderState == .filledSimulated
                && sharedOrderEventKind == .simulatedOrderFilled
                && quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue)
                && quantitiesMatch(remainingQuantity.rawValue, 0)
        case .partial:
            return sharedOrderState == .partiallyFilledSimulated
                && sharedOrderEventKind == .simulatedOrderPartiallyFilled
                && filledQuantity.rawValue > 0
                && filledQuantity.rawValue < orderQuantity.rawValue
                && quantitiesMatch(filledQuantity.rawValue + remainingQuantity.rawValue, orderQuantity.rawValue)
                && remainingQuantity.rawValue > 0
        }
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        usesRealFeeSchedule == false
            && usesDynamicSlippageModel == false
            && consumesRealLiquidity == false
            && recordsBrokerFill == false
            && ingestsExecutionReport == false
            && runsReconciliation == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public init(
        eventID: Identifier,
        sourceExecutionEventID: Identifier,
        orderID: Identifier,
        orderType: MarketLimitSimulatedOrderType,
        fillCompletion: PaperSimulatedFillCompletion,
        sharedOrderState: BacktestPaperSharedOrderState,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind,
        matchedPrice: Price,
        orderQuantity: Quantity,
        availableSimulatedLiquidity: Quantity,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        latencyAssumptionID: Identifier,
        latencyInputRecordSequence: Int,
        latencyOutputRecordSequence: Int,
        latencyMilliseconds: Double,
        backtestCostEstimate: ExecutionCostEstimate,
        paperCostEstimate: ExecutionCostEstimate,
        costParityResult: ExecutionCostParityResult,
        eventStream: EventStreamID = .paper,
        sourceAnchor: String,
        usesRealFeeSchedule: Bool = false,
        usesDynamicSlippageModel: Bool = false,
        consumesRealLiquidity: Bool = false,
        recordsBrokerFill: Bool = false,
        ingestsExecutionReport: Bool = false,
        runsReconciliation: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            fillCompletion: fillCompletion,
            sharedOrderState: sharedOrderState,
            sharedOrderEventKind: sharedOrderEventKind,
            matchedPrice: matchedPrice,
            orderQuantity: orderQuantity,
            availableSimulatedLiquidity: availableSimulatedLiquidity,
            filledQuantity: filledQuantity,
            remainingQuantity: remainingQuantity,
            latencyInputRecordSequence: latencyInputRecordSequence,
            latencyOutputRecordSequence: latencyOutputRecordSequence,
            latencyMilliseconds: latencyMilliseconds,
            backtestCostEstimate: backtestCostEstimate,
            paperCostEstimate: paperCostEstimate,
            costParityResult: costParityResult,
            eventStream: eventStream,
            sourceAnchor: sourceAnchor,
            usesRealFeeSchedule: usesRealFeeSchedule,
            usesDynamicSlippageModel: usesDynamicSlippageModel,
            consumesRealLiquidity: consumesRealLiquidity,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.eventID = eventID
        self.sourceExecutionEventID = sourceExecutionEventID
        self.orderID = orderID
        self.orderType = orderType
        self.fillCompletion = fillCompletion
        self.sharedOrderState = sharedOrderState
        self.sharedOrderEventKind = sharedOrderEventKind
        self.matchedPrice = matchedPrice
        self.orderQuantity = orderQuantity
        self.availableSimulatedLiquidity = availableSimulatedLiquidity
        self.filledQuantity = filledQuantity
        self.remainingQuantity = remainingQuantity
        self.latencyAssumptionID = latencyAssumptionID
        self.latencyInputRecordSequence = latencyInputRecordSequence
        self.latencyOutputRecordSequence = latencyOutputRecordSequence
        self.latencyMilliseconds = latencyMilliseconds
        self.backtestCostEstimate = backtestCostEstimate
        self.paperCostEstimate = paperCostEstimate
        self.costParityResult = costParityResult
        self.eventStream = eventStream
        self.sourceAnchor = sourceAnchor
        self.usesRealFeeSchedule = usesRealFeeSchedule
        self.usesDynamicSlippageModel = usesDynamicSlippageModel
        self.consumesRealLiquidity = consumesRealLiquidity
        self.recordsBrokerFill = recordsBrokerFill
        self.ingestsExecutionReport = ingestsExecutionReport
        self.runsReconciliation = runsReconciliation
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            eventID: try container.decode(Identifier.self, forKey: .eventID),
            sourceExecutionEventID: try container.decode(Identifier.self, forKey: .sourceExecutionEventID),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            orderType: try container.decode(MarketLimitSimulatedOrderType.self, forKey: .orderType),
            fillCompletion: try container.decode(PaperSimulatedFillCompletion.self, forKey: .fillCompletion),
            sharedOrderState: try container.decode(BacktestPaperSharedOrderState.self, forKey: .sharedOrderState),
            sharedOrderEventKind: try container.decode(
                BacktestPaperSharedOrderEventKind.self,
                forKey: .sharedOrderEventKind
            ),
            matchedPrice: try container.decode(Price.self, forKey: .matchedPrice),
            orderQuantity: try container.decode(Quantity.self, forKey: .orderQuantity),
            availableSimulatedLiquidity: try container.decode(Quantity.self, forKey: .availableSimulatedLiquidity),
            filledQuantity: try container.decode(Quantity.self, forKey: .filledQuantity),
            remainingQuantity: try container.decode(Quantity.self, forKey: .remainingQuantity),
            latencyAssumptionID: try container.decode(Identifier.self, forKey: .latencyAssumptionID),
            latencyInputRecordSequence: try container.decode(Int.self, forKey: .latencyInputRecordSequence),
            latencyOutputRecordSequence: try container.decode(Int.self, forKey: .latencyOutputRecordSequence),
            latencyMilliseconds: try container.decode(Double.self, forKey: .latencyMilliseconds),
            backtestCostEstimate: try container.decode(ExecutionCostEstimate.self, forKey: .backtestCostEstimate),
            paperCostEstimate: try container.decode(ExecutionCostEstimate.self, forKey: .paperCostEstimate),
            costParityResult: try container.decode(ExecutionCostParityResult.self, forKey: .costParityResult),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            usesRealFeeSchedule: try container.decode(Bool.self, forKey: .usesRealFeeSchedule),
            usesDynamicSlippageModel: try container.decode(Bool.self, forKey: .usesDynamicSlippageModel),
            consumesRealLiquidity: try container.decode(Bool.self, forKey: .consumesRealLiquidity),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    private static func validate(
        fillCompletion: PaperSimulatedFillCompletion,
        sharedOrderState: BacktestPaperSharedOrderState,
        sharedOrderEventKind: BacktestPaperSharedOrderEventKind,
        matchedPrice: Price,
        orderQuantity: Quantity,
        availableSimulatedLiquidity: Quantity,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        latencyInputRecordSequence: Int,
        latencyOutputRecordSequence: Int,
        latencyMilliseconds: Double,
        backtestCostEstimate: ExecutionCostEstimate,
        paperCostEstimate: ExecutionCostEstimate,
        costParityResult: ExecutionCostParityResult,
        eventStream: EventStreamID,
        sourceAnchor: String,
        usesRealFeeSchedule: Bool,
        usesDynamicSlippageModel: Bool,
        consumesRealLiquidity: Bool,
        recordsBrokerFill: Bool,
        ingestsExecutionReport: Bool,
        runsReconciliation: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard eventStream == .paper,
              sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              availableSimulatedLiquidity.rawValue > 0,
              filledQuantity.rawValue > 0,
              filledQuantity.rawValue <= availableSimulatedLiquidity.rawValue,
              quantitiesMatch(filledQuantity.rawValue + remainingQuantity.rawValue, orderQuantity.rawValue) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityEvent.fillQuantities",
                expected: "paper event with positive filled quantity and quantity conservation",
                actual: "\(filledQuantity.rawValue)/\(remainingQuantity.rawValue)"
            )
        }
        switch fillCompletion {
        case .full:
            guard sharedOrderState == .filledSimulated,
                  sharedOrderEventKind == .simulatedOrderFilled,
                  quantitiesMatch(filledQuantity.rawValue, orderQuantity.rawValue),
                  quantitiesMatch(remainingQuantity.rawValue, 0) else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "partialFillLatencyFeeSlippageParityEvent.fullFill",
                    expected: "filled simulated event with no remaining quantity",
                    actual: sharedOrderState.rawValue
                )
            }
        case .partial:
            guard sharedOrderState == .partiallyFilledSimulated,
                  sharedOrderEventKind == .simulatedOrderPartiallyFilled,
                  filledQuantity.rawValue < orderQuantity.rawValue,
                  remainingQuantity.rawValue > 0 else {
                throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                    field: "partialFillLatencyFeeSlippageParityEvent.partialFill",
                    expected: "partially filled simulated event with remaining quantity",
                    actual: sharedOrderState.rawValue
                )
            }
        }
        guard latencyInputRecordSequence > 0,
              latencyOutputRecordSequence > latencyInputRecordSequence,
              latencyMilliseconds.isFinite,
              latencyMilliseconds >= 0 else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityEvent.latency",
                expected: "deterministic positive sequence offset",
                actual: "\(latencyInputRecordSequence)->\(latencyOutputRecordSequence)"
            )
        }
        guard costParityResult.isConsistent,
              backtestCostEstimate.executionMode == .backtest,
              paperCostEstimate.executionMode == .paper,
              backtestCostEstimate.referencePrice == matchedPrice,
              paperCostEstimate.referencePrice == matchedPrice,
              quantitiesMatch(backtestCostEstimate.quantity.rawValue, filledQuantity.rawValue),
              quantitiesMatch(paperCostEstimate.quantity.rawValue, filledQuantity.rawValue) else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityEvent.costParity",
                expected: "matching backtest / paper fee and slippage cost evidence",
                actual: "\(costParityResult)"
            )
        }
        try PartialFillLatencyFeeSlippageParityContract.validateForbiddenFlags(
            prefix: "partialFillLatencyFeeSlippageParityEvent",
            usesRealFeeSchedule: usesRealFeeSchedule,
            usesDynamicSlippageModel: usesDynamicSlippageModel,
            consumesRealLiquidity: consumesRealLiquidity,
            recordsBrokerFill: recordsBrokerFill,
            ingestsExecutionReport: ingestsExecutionReport,
            runsReconciliation: runsReconciliation,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )
    }

    private func quantitiesMatch(_ lhs: Double, _ rhs: Double) -> Bool {
        Self.quantitiesMatch(lhs, rhs)
    }

    private static func quantitiesMatch(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 0.000_000_001
    }
}

/// PartialFillLatencyFeeSlippageParityReportEvidence 保存 MTP-114 的可重放 report evidence。
///
/// Report evidence 只汇总 source MTP-113 execution output、partial / full fill event、规则和 anchors。
/// 它不是 App read model、Dashboard surface、portfolio projection、broker reconciliation 或真实执行报告。
public struct PartialFillLatencyFeeSlippageParityReportEvidence: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let inputIdentity: String
    public let sourceExecutionOutput: MarketLimitSimulatedExecutionOutput
    public let parityEvent: PartialFillLatencyFeeSlippageParityEvent
    public let rules: [PartialFillLatencyFeeSlippageParityRule]
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var reportEvidenceBoundaryHeld: Bool {
        inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && sourceExecutionOutput.executionOutputBoundaryHeld
            && sourceExecutionOutput.executionEvent.outcome == .fullFill
            && parityEvent.parityEventBoundaryHeld
            && rules == PartialFillLatencyFeeSlippageParityContract.requiredRules
            && validationAnchors == PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors
            && requiredValidationDependsOnNetwork == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public var deterministicResultIdentity: String {
        [
            inputIdentity,
            "fill=\(parityEvent.fillCompletion.rawValue)",
            "latencyMs=\(Self.scaledAmount(parityEvent.latencyMilliseconds))",
            "latencyRecord=\(parityEvent.latencyOutputRecordSequence)",
            "filled=\(Self.scaledQuantity(parityEvent.filledQuantity.rawValue))",
            "remaining=\(Self.scaledQuantity(parityEvent.remainingQuantity.rawValue))",
            "fee=\(Self.scaledAmount(parityEvent.backtestCostEstimate.feeAmount))",
            "slippage=\(Self.scaledAmount(parityEvent.backtestCostEstimate.slippageAmount))",
            "totalCost=\(Self.scaledAmount(parityEvent.backtestCostEstimate.totalCostAmount))"
        ].joined(separator: "|")
    }

    public init(
        reportID: Identifier,
        inputIdentity: String,
        sourceExecutionOutput: MarketLimitSimulatedExecutionOutput,
        parityEvent: PartialFillLatencyFeeSlippageParityEvent,
        rules: [PartialFillLatencyFeeSlippageParityRule] = PartialFillLatencyFeeSlippageParityContract.requiredRules,
        validationAnchors: [String] = PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            inputIdentity: inputIdentity,
            sourceExecutionOutput: sourceExecutionOutput,
            parityEvent: parityEvent,
            rules: rules,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.reportID = reportID
        self.inputIdentity = inputIdentity
        self.sourceExecutionOutput = sourceExecutionOutput
        self.parityEvent = parityEvent
        self.rules = rules
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            reportID: try container.decode(Identifier.self, forKey: .reportID),
            inputIdentity: try container.decode(String.self, forKey: .inputIdentity),
            sourceExecutionOutput: try container.decode(
                MarketLimitSimulatedExecutionOutput.self,
                forKey: .sourceExecutionOutput
            ),
            parityEvent: try container.decode(PartialFillLatencyFeeSlippageParityEvent.self, forKey: .parityEvent),
            rules: try container.decode([PartialFillLatencyFeeSlippageParityRule].self, forKey: .rules),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    /// MTP-114 partial-fill deterministic evidence helper.
    ///
    /// 该入口不放宽 partial fill / cost parity / forbidden command 校验；它只把稳定 fixture
    /// 的构造失败集中到一个带 MTP 定位的 failure path，避免默认参数散落裸 `try!`。
    public static let deterministicPartialFixture: PartialFillLatencyFeeSlippageParityReportEvidence = {
        do {
            return try PartialFillLatencyFeeSlippageParityModel.evaluate(.deterministicPartialFixture)
        } catch {
            preconditionFailure("MTP-114 deterministic partial report evidence must be valid: \(error)")
        }
    }()

    /// MTP-114 full-fill deterministic evidence helper.
    ///
    /// 该入口不放宽 full fill / cost parity / forbidden command 校验；它只为 Dashboard /
    /// Report read model 提供明确命名的 deterministic evidence constructor。
    public static let deterministicFullFixture: PartialFillLatencyFeeSlippageParityReportEvidence = {
        do {
            return try PartialFillLatencyFeeSlippageParityModel.evaluate(.deterministicFullFixture)
        } catch {
            preconditionFailure("MTP-114 deterministic full report evidence must be valid: \(error)")
        }
    }()

    private static func validate(
        inputIdentity: String,
        sourceExecutionOutput: MarketLimitSimulatedExecutionOutput,
        parityEvent: PartialFillLatencyFeeSlippageParityEvent,
        rules: [PartialFillLatencyFeeSlippageParityRule],
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              sourceExecutionOutput.executionOutputBoundaryHeld,
              sourceExecutionOutput.executionEvent.outcome == .fullFill,
              parityEvent.parityEventBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityReportEvidence",
                expected: "source full-fill execution output and parity event boundary held",
                actual: inputIdentity
            )
        }
        try PartialFillLatencyFeeSlippageParityContract.validateList(
            field: "partialFillLatencyFeeSlippageParityReportEvidence.rules",
            expected: PartialFillLatencyFeeSlippageParityContract.requiredRules.map(\.rawValue),
            actual: rules.map(\.rawValue)
        )
        try PartialFillLatencyFeeSlippageParityContract.validateList(
            field: "partialFillLatencyFeeSlippageParityReportEvidence.validationAnchors",
            expected: PartialFillLatencyFeeSlippageParityContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try PartialFillLatencyFeeSlippageParityContract.validateForbiddenFlags(
            prefix: "partialFillLatencyFeeSlippageParityReportEvidence",
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }

    private static func scaledQuantity(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }

    private static func scaledAmount(_ value: Double) -> Int {
        Int((value * 100_000_000).rounded())
    }
}

/// PartialFillLatencyFeeSlippageParityModel 是 MTP-114 的纯函数 parity evidence 入口。
///
/// `evaluate` 只读取传入 deterministic input。它先复用 MTP-113 生成 source execution output，
/// 再用 fixture liquidity cap 决定 partial / full fill，用固定 latency assumption 生成延迟证据，
/// 最后用 MTP-27 fixed assumptions 计算 Backtest / Paper 两侧完全一致的 fee / slippage evidence。
public enum PartialFillLatencyFeeSlippageParityModel {
    public static func evaluate(
        _ input: PartialFillLatencyFeeSlippageParityInput
    ) throws -> PartialFillLatencyFeeSlippageParityReportEvidence {
        guard input.parityInputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityModel.input",
                expected: "parity input boundary held",
                actual: "false"
            )
        }

        let sourceOutput = try MarketLimitSimulatedExecutionModel.execute(input.marketLimitExecutionInput)
        guard sourceOutput.executionEvent.outcome == .fullFill,
              let matchingOutput = sourceOutput.matchingOutput,
              let matchedPrice = sourceOutput.executionEvent.matchedPrice else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityModel.sourceExecutionOutput",
                expected: "MTP-113 full fill output with deterministic matching output",
                actual: sourceOutput.executionEvent.outcome.rawValue
            )
        }
        guard input.latencyAssumption.sourceRecordSequence
                == matchingOutput.simulatedExchangeEvent.matchedRecordSequence else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "partialFillLatencyFeeSlippageParityModel.latencySource",
                expected: "\(matchingOutput.simulatedExchangeEvent.matchedRecordSequence)",
                actual: "\(input.latencyAssumption.sourceRecordSequence)"
            )
        }

        let sharedOrder = input.marketLimitExecutionInput.matchingInput.sharedOrderInput
        let orderQuantity = sourceOutput.executionEvent.orderQuantity
        let filledRaw = min(orderQuantity.rawValue, input.availableSimulatedLiquidity.rawValue)
        let remainingRaw = orderQuantity.rawValue - filledRaw
        let filledQuantity = try Quantity(filledRaw, field: "partialFillLatencyFeeSlippage.filledQuantity")
        let remainingQuantity = try Quantity(remainingRaw, field: "partialFillLatencyFeeSlippage.remainingQuantity")
        let completion: PaperSimulatedFillCompletion = quantitiesMatch(remainingRaw, 0) ? .full : .partial
        let sharedState: BacktestPaperSharedOrderState =
            completion == .full ? .filledSimulated : .partiallyFilledSimulated
        let eventKind: BacktestPaperSharedOrderEventKind =
            completion == .full ? .simulatedOrderFilled : .simulatedOrderPartiallyFilled

        let backtestCost = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: sharedOrder.symbol,
                timeframe: sharedOrder.timeframe,
                executionMode: .backtest,
                referencePrice: matchedPrice,
                quantity: filledQuantity,
                liquidityRole: input.liquidityRole
            ),
            assumptions: input.costAssumptions
        )
        let paperCost = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: sharedOrder.symbol,
                timeframe: sharedOrder.timeframe,
                executionMode: .paper,
                referencePrice: matchedPrice,
                quantity: filledQuantity,
                liquidityRole: input.liquidityRole
            ),
            assumptions: input.costAssumptions
        )
        let costParity = ExecutionCostParity.verify(backtest: backtestCost, paper: paperCost)

        let event = try PartialFillLatencyFeeSlippageParityEvent(
            eventID: try Identifier(eventIDPrefix(completion: completion, orderType: sourceOutput.executionEvent.orderType)),
            sourceExecutionEventID: sourceOutput.executionEvent.eventID,
            orderID: sourceOutput.executionEvent.orderID,
            orderType: sourceOutput.executionEvent.orderType,
            fillCompletion: completion,
            sharedOrderState: sharedState,
            sharedOrderEventKind: eventKind,
            matchedPrice: matchedPrice,
            orderQuantity: orderQuantity,
            availableSimulatedLiquidity: input.availableSimulatedLiquidity,
            filledQuantity: filledQuantity,
            remainingQuantity: remainingQuantity,
            latencyAssumptionID: input.latencyAssumption.assumptionID,
            latencyInputRecordSequence: input.latencyAssumption.sourceRecordSequence,
            latencyOutputRecordSequence: input.latencyAssumption.outputRecordSequence,
            latencyMilliseconds: input.latencyAssumption.fixedDelayMilliseconds,
            backtestCostEstimate: backtestCost,
            paperCostEstimate: paperCost,
            costParityResult: costParity,
            sourceAnchor: "MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE"
        )
        return try PartialFillLatencyFeeSlippageParityReportEvidence(
            reportID: try Identifier(eventIDPrefix(completion: completion, orderType: sourceOutput.executionEvent.orderType) + "-report"),
            inputIdentity: input.deterministicInputIdentity,
            sourceExecutionOutput: sourceOutput,
            parityEvent: event
        )
    }

    private static func eventIDPrefix(
        completion: PaperSimulatedFillCompletion,
        orderType: MarketLimitSimulatedOrderType
    ) -> String {
        let orderPrefix: String
        switch orderType {
        case .market:
            orderPrefix = "market"
        case .limit:
            orderPrefix = "limit"
        }
        switch completion {
        case .full:
            return "mtp-114-\(orderPrefix)-full-fill-latency-cost"
        case .partial:
            return "mtp-114-\(orderPrefix)-partial-fill-latency-cost"
        }
    }

    private static func quantitiesMatch(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) < 0.000_000_001
    }
}
