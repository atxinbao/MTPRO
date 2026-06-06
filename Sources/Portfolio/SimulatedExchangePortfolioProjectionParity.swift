import DomainModel
import Foundation
import MessageBus

/// MTP-187 将 simulated exchange portfolio parity 放入 `Sources/Portfolio/`。
/// 该 parity 只服务 paper / simulated projection evidence，不代表 Portfolio runtime 或 broker reconciliation。
/// MTP-115 simulated exchange -> portfolio projection parity 固定模拟成交事件到组合投影的边界。
///
/// 本文件只消费 MTP-114 的 deterministic simulated exchange parity event / report evidence 和
/// MTP-107 的 report input version identity，输出 backtest 与 paper 两侧一致的模拟 account、
/// position、cash、PnL 和 exposure projection。它不读取真实账户、不同步 broker position、
/// 不处理 margin / leverage，不执行 broker reconciliation，也不实现 Live PRO Console、live command 或交易按钮。

/// SimulatedExchangePortfolioProjectionMode 区分 backtest / paper 两个 parity 观察口径。
///
/// 两个 mode 必须从同一 simulated exchange event 派生相同数值；mode 只服务 report / replay evidence
/// 标签，不代表两套运行时或真实账户状态。
public enum SimulatedExchangePortfolioProjectionMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case backtest = "backtest portfolio projection"
    case paper = "paper portfolio projection"
}

/// SimulatedExchangePortfolioProjectionRule 固定 MTP-115 的投影规则。
///
/// 规则只描述 deterministic simulated event -> portfolio projection 的可验证路径，不表达真实账户资产、
/// broker 仓位、margin、leverage 或 reconciliation。
public enum SimulatedExchangePortfolioProjectionRule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case consumesSimulatedExchangeParityEvent = "consumes simulated exchange parity event"
    case derivesBacktestAndPaperFromSameEvent = "derives backtest and paper projections from the same event"
    case computesPositionCashPnLExposure = "computes position cash PnL exposure"
    case bindsReportInputVersion = "binds report input version"
    case preservesReplayEvidenceIdentity = "preserves replay evidence identity"
    case noRealAccountBrokerMarginLeverage = "no real account broker margin leverage"
}

/// SimulatedExchangePortfolioProjectionForbiddenCapability 枚举 MTP-115 必须持续拒绝的能力。
///
/// 这些 flags 让初始化和 Codable 解码都无法把模拟组合投影偷渡成真实 account / broker / live 能力。
public enum SimulatedExchangePortfolioProjectionForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realAccountBalanceRead = "real account balance read"
    case brokerPositionRead = "broker position read"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case brokerReconciliation = "broker reconciliation"
    case realAccountBalanceSync = "real account balance sync"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case brokerIntegration = "broker integration"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case liveRuntime = "live runtime"
    case liveCommand = "live command"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case databaseSchemaExposure = "database schema exposure"
    case runtimeObjectRead = "runtime object read"
    case requiredNetworkValidation = "required network validation"
}

/// SimulatedExchangePortfolioProjectionParityContract 是 MTP-115 的 Core 合同 fixture。
///
/// Contract 只固定输入输出边界、validation anchors 和 forbidden capability baseline；它不是
/// portfolio runtime、broker reconciliation service、App read model 或 Dashboard surface。
public struct SimulatedExchangePortfolioProjectionParityContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let rules: [SimulatedExchangePortfolioProjectionRule]
    public let projectionModes: [SimulatedExchangePortfolioProjectionMode]
    public let forbiddenCapabilities: [SimulatedExchangePortfolioProjectionForbiddenCapability]
    public let validationAnchors: [String]
    public let consumesSimulatedExchangeParityEvent: Bool
    public let derivesBacktestProjection: Bool
    public let derivesPaperProjection: Bool
    public let derivesPositionCashPnLExposure: Bool
    public let bindsReportInputVersion: Bool
    public let usesReplayEvidenceIdentity: Bool
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let runsBrokerReconciliation: Bool
    public let syncsRealAccountBalance: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let exposesDatabaseSchema: Bool
    public let readsRuntimeObject: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var contractBoundaryHeld: Bool {
        rules == Self.requiredRules
            && projectionModes == Self.requiredProjectionModes
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && consumesSimulatedExchangeParityEvent
            && derivesBacktestProjection
            && derivesPaperProjection
            && derivesPositionCashPnLExposure
            && bindsReportInputVersion
            && usesReplayEvidenceIdentity
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && readsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && runsBrokerReconciliation == false
            && syncsRealAccountBalance == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && exposesDatabaseSchema == false
            && readsRuntimeObject == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = Identifier.constant("mtp-115-simulated-exchange-portfolio-projection-parity"),
        issueID: Identifier = Identifier.constant("MTP-115"),
        rules: [SimulatedExchangePortfolioProjectionRule] = Self.requiredRules,
        projectionModes: [SimulatedExchangePortfolioProjectionMode] = Self.requiredProjectionModes,
        forbiddenCapabilities: [SimulatedExchangePortfolioProjectionForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        consumesSimulatedExchangeParityEvent: Bool = true,
        derivesBacktestProjection: Bool = true,
        derivesPaperProjection: Bool = true,
        derivesPositionCashPnLExposure: Bool = true,
        bindsReportInputVersion: Bool = true,
        usesReplayEvidenceIdentity: Bool = true,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsBrokerReconciliation: Bool = false,
        syncsRealAccountBalance: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        exposesDatabaseSchema: Bool = false,
        readsRuntimeObject: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validateList(field: "simulatedExchangePortfolioProjectionParityContract.rules",
                              expected: Self.requiredRules.map(\.rawValue),
                              actual: rules.map(\.rawValue))
        try Self.validateList(field: "simulatedExchangePortfolioProjectionParityContract.projectionModes",
                              expected: Self.requiredProjectionModes.map(\.rawValue),
                              actual: projectionModes.map(\.rawValue))
        try Self.validateList(field: "simulatedExchangePortfolioProjectionParityContract.forbiddenCapabilities",
                              expected: Self.requiredForbiddenCapabilities.map(\.rawValue),
                              actual: forbiddenCapabilities.map(\.rawValue))
        try Self.validateList(field: "simulatedExchangePortfolioProjectionParityContract.validationAnchors",
                              expected: Self.requiredValidationAnchors,
                              actual: validationAnchors)
        try Self.validateRequiredTrueFlags(
            consumesSimulatedExchangeParityEvent: consumesSimulatedExchangeParityEvent,
            derivesBacktestProjection: derivesBacktestProjection,
            derivesPaperProjection: derivesPaperProjection,
            derivesPositionCashPnLExposure: derivesPositionCashPnLExposure,
            bindsReportInputVersion: bindsReportInputVersion,
            usesReplayEvidenceIdentity: usesReplayEvidenceIdentity
        )
        try Self.validateForbiddenFlags(
            prefix: nil,
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            exposesDatabaseSchema: exposesDatabaseSchema,
            readsRuntimeObject: readsRuntimeObject,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.rules = rules
        self.projectionModes = projectionModes
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.consumesSimulatedExchangeParityEvent = consumesSimulatedExchangeParityEvent
        self.derivesBacktestProjection = derivesBacktestProjection
        self.derivesPaperProjection = derivesPaperProjection
        self.derivesPositionCashPnLExposure = derivesPositionCashPnLExposure
        self.bindsReportInputVersion = bindsReportInputVersion
        self.usesReplayEvidenceIdentity = usesReplayEvidenceIdentity
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.runsBrokerReconciliation = runsBrokerReconciliation
        self.syncsRealAccountBalance = syncsRealAccountBalance
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.readsRuntimeObject = readsRuntimeObject
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            rules: try container.decode([SimulatedExchangePortfolioProjectionRule].self, forKey: .rules),
            projectionModes: try container.decode([SimulatedExchangePortfolioProjectionMode].self, forKey: .projectionModes),
            forbiddenCapabilities: try container.decode(
                [SimulatedExchangePortfolioProjectionForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            consumesSimulatedExchangeParityEvent: try container.decode(
                Bool.self,
                forKey: .consumesSimulatedExchangeParityEvent
            ),
            derivesBacktestProjection: try container.decode(Bool.self, forKey: .derivesBacktestProjection),
            derivesPaperProjection: try container.decode(Bool.self, forKey: .derivesPaperProjection),
            derivesPositionCashPnLExposure: try container.decode(Bool.self, forKey: .derivesPositionCashPnLExposure),
            bindsReportInputVersion: try container.decode(Bool.self, forKey: .bindsReportInputVersion),
            usesReplayEvidenceIdentity: try container.decode(Bool.self, forKey: .usesReplayEvidenceIdentity),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            readsBrokerPosition: try container.decode(Bool.self, forKey: .readsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            runsBrokerReconciliation: try container.decode(Bool.self, forKey: .runsBrokerReconciliation),
            syncsRealAccountBalance: try container.decode(Bool.self, forKey: .syncsRealAccountBalance),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            readsRuntimeObject: try container.decode(Bool.self, forKey: .readsRuntimeObject),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: SimulatedExchangePortfolioProjectionForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredRules: [SimulatedExchangePortfolioProjectionRule] =
        SimulatedExchangePortfolioProjectionRule.allCases

    public static let requiredProjectionModes: [SimulatedExchangePortfolioProjectionMode] =
        SimulatedExchangePortfolioProjectionMode.allCases

    public static let requiredForbiddenCapabilities: [SimulatedExchangePortfolioProjectionForbiddenCapability] =
        SimulatedExchangePortfolioProjectionForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION",
        "MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY",
        "MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY",
        "MTP-115-REPORT-INPUT-REPLAY-EVIDENCE",
        "MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE",
        "MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION",
        "TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY"
    ]

    public static let deterministicFixture: SimulatedExchangePortfolioProjectionParityContract = {
        do {
            return try SimulatedExchangePortfolioProjectionParityContract()
        } catch {
            preconditionFailure("MTP-115 portfolio projection parity contract must be valid: \(error)")
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
        consumesSimulatedExchangeParityEvent: Bool,
        derivesBacktestProjection: Bool,
        derivesPaperProjection: Bool,
        derivesPositionCashPnLExposure: Bool,
        bindsReportInputVersion: Bool,
        usesReplayEvidenceIdentity: Bool
    ) throws {
        let flags = [
            ("consumesSimulatedExchangeParityEvent", consumesSimulatedExchangeParityEvent),
            ("derivesBacktestProjection", derivesBacktestProjection),
            ("derivesPaperProjection", derivesPaperProjection),
            ("derivesPositionCashPnLExposure", derivesPositionCashPnLExposure),
            ("bindsReportInputVersion", bindsReportInputVersion),
            ("usesReplayEvidenceIdentity", usesReplayEvidenceIdentity)
        ]
        if let flag = flags.first(where: { $0.1 == false }) {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionParityContract.\(flag.0)",
                expected: "true",
                actual: "false"
            )
        }
    }

    fileprivate static func validateForbiddenFlags(
        prefix: String?,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsBrokerReconciliation: Bool = false,
        syncsRealAccountBalance: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        exposesDatabaseSchema: Bool = false,
        readsRuntimeObject: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let flags = [
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("readsBrokerPosition", readsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("runsBrokerReconciliation", runsBrokerReconciliation),
            ("syncsRealAccountBalance", syncsRealAccountBalance),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("readsRuntimeObject", readsRuntimeObject),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]
        if let capability = flags.first(where: { $0.1 }) {
            let field = prefix.map { "\($0).\(capability.0)" } ?? capability.0
            throw CoreError.simulatedExchangeBacktestParityForbiddenCapability(field)
        }
    }
}

/// SimulatedExchangePortfolioProjectionParityInput 聚合 MTP-115 deterministic projection 输入。
///
/// 输入只能来自 MTP-114 report evidence 和 MTP-107 report input version。`sourceReplaySequence`
/// 默认绑定 MTP-114 latency output record，证明 projection 仍从 replay evidence 追溯，而不是直接读取
/// Runtime object、SQLite schema、真实账户或 broker state。
public struct SimulatedExchangePortfolioProjectionParityInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence
    public let reportInputVersion: ScenarioReportInputVersion
    public let accountID: Identifier
    public let portfolioID: Identifier
    public let startingCashBalance: Double
    public let sourceReplaySequence: Int
    public let projectedAt: Date
    public let validationAnchors: [String]
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let runsBrokerReconciliation: Bool
    public let syncsRealAccountBalance: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let exposesDatabaseSchema: Bool
    public let readsRuntimeObject: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var inputBoundaryHeld: Bool {
        sourceReportEvidence.reportEvidenceBoundaryHeld
            && reportInputVersion.reportInputBoundaryHeld
            && sourceReplaySequence == sourceReportEvidence.parityEvent.latencyOutputRecordSequence
            && validationAnchors == SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors
            && startingCashBalance.isFinite
            && startingCashBalance > 0
            && forbiddenCapabilityBoundaryHeld
    }

    public var deterministicInputIdentity: String {
        [
            sourceReportEvidence.deterministicResultIdentity,
            "reportInput=\(reportInputVersion.versionIdentity)",
            "startingCash=\(Self.scaledAmount(startingCashBalance))",
            "sourceReplaySequence=\(sourceReplaySequence)"
        ].joined(separator: "|")
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && readsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && runsBrokerReconciliation == false
            && syncsRealAccountBalance == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && exposesDatabaseSchema == false
            && readsRuntimeObject == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        inputID: Identifier = Identifier.constant("mtp-115-simulated-exchange-portfolio-projection-input"),
        sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence =
            try! PartialFillLatencyFeeSlippageParityModel.evaluate(.deterministicPartialFixture),
        reportInputVersion: ScenarioReportInputVersion = ScenarioReportInputVersion.constant(),
        accountID: Identifier = Identifier.constant("mtp-115-simulated-account"),
        portfolioID: Identifier = Identifier.constant("mtp-115-simulated-portfolio"),
        startingCashBalance: Double = 50_000,
        sourceReplaySequence: Int? = nil,
        projectedAt: Date = Date(timeIntervalSince1970: 1_704_067_680),
        validationAnchors: [String] = SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsBrokerReconciliation: Bool = false,
        syncsRealAccountBalance: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        exposesDatabaseSchema: Bool = false,
        readsRuntimeObject: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let resolvedSourceReplaySequence = sourceReplaySequence
            ?? sourceReportEvidence.parityEvent.latencyOutputRecordSequence
        try Self.validate(
            sourceReportEvidence: sourceReportEvidence,
            reportInputVersion: reportInputVersion,
            startingCashBalance: startingCashBalance,
            sourceReplaySequence: resolvedSourceReplaySequence,
            validationAnchors: validationAnchors,
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            exposesDatabaseSchema: exposesDatabaseSchema,
            readsRuntimeObject: readsRuntimeObject,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.inputID = inputID
        self.sourceReportEvidence = sourceReportEvidence
        self.reportInputVersion = reportInputVersion
        self.accountID = accountID
        self.portfolioID = portfolioID
        self.startingCashBalance = startingCashBalance
        self.sourceReplaySequence = resolvedSourceReplaySequence
        self.projectedAt = projectedAt
        self.validationAnchors = validationAnchors
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.runsBrokerReconciliation = runsBrokerReconciliation
        self.syncsRealAccountBalance = syncsRealAccountBalance
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.readsRuntimeObject = readsRuntimeObject
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            inputID: try container.decode(Identifier.self, forKey: .inputID),
            sourceReportEvidence: try container.decode(
                PartialFillLatencyFeeSlippageParityReportEvidence.self,
                forKey: .sourceReportEvidence
            ),
            reportInputVersion: try container.decode(ScenarioReportInputVersion.self, forKey: .reportInputVersion),
            accountID: try container.decode(Identifier.self, forKey: .accountID),
            portfolioID: try container.decode(Identifier.self, forKey: .portfolioID),
            startingCashBalance: try container.decode(Double.self, forKey: .startingCashBalance),
            sourceReplaySequence: try container.decode(Int.self, forKey: .sourceReplaySequence),
            projectedAt: try container.decode(Date.self, forKey: .projectedAt),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            readsBrokerPosition: try container.decode(Bool.self, forKey: .readsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            runsBrokerReconciliation: try container.decode(Bool.self, forKey: .runsBrokerReconciliation),
            syncsRealAccountBalance: try container.decode(Bool.self, forKey: .syncsRealAccountBalance),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            readsRuntimeObject: try container.decode(Bool.self, forKey: .readsRuntimeObject),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    private static func validate(
        sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence,
        reportInputVersion: ScenarioReportInputVersion,
        startingCashBalance: Double,
        sourceReplaySequence: Int,
        validationAnchors: [String],
        readsRealAccountBalance: Bool,
        readsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        runsBrokerReconciliation: Bool,
        syncsRealAccountBalance: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        exposesDatabaseSchema: Bool,
        readsRuntimeObject: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard sourceReportEvidence.reportEvidenceBoundaryHeld,
              reportInputVersion.reportInputBoundaryHeld,
              startingCashBalance.isFinite,
              startingCashBalance > 0,
              sourceReplaySequence == sourceReportEvidence.parityEvent.latencyOutputRecordSequence else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionParityInput",
                expected: "MTP-114 report evidence, report input version, positive cash, matching replay sequence",
                actual: "invalid"
            )
        }
        try SimulatedExchangePortfolioProjectionParityContract.validateList(
            field: "simulatedExchangePortfolioProjectionParityInput.validationAnchors",
            expected: SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try SimulatedExchangePortfolioProjectionParityContract.validateForbiddenFlags(
            prefix: "simulatedExchangePortfolioProjectionParityInput",
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            exposesDatabaseSchema: exposesDatabaseSchema,
            readsRuntimeObject: readsRuntimeObject,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }

    private static func scaledAmount(_ value: Double) -> Int {
        Int((value * 100_000_000).rounded())
    }
}

/// SimulatedExchangePortfolioProjectionSnapshot 是单侧模拟组合投影。
///
/// Snapshot 保存 account cash、position、PnL 和 exposure 的派生值。所有数值都来自同一个
/// simulated exchange parity event，不读取真实账户余额、broker position、margin 或 leverage。
public struct SimulatedExchangePortfolioProjectionSnapshot: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let mode: SimulatedExchangePortfolioProjectionMode
    public let accountID: Identifier
    public let portfolioID: Identifier
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let orderID: Identifier
    public let sourceEventID: Identifier
    public let sourceReportID: Identifier
    public let reportInputVersionIdentity: String
    public let sourceReplaySequence: Int
    public let netQuantity: Quantity
    public let averageEntryPrice: Price
    public let lastFillPrice: Price
    public let positionMarketValue: Double
    public let costBasisNotional: Double
    public let totalFeeAmount: Double
    public let totalSlippageAmount: Double
    public let totalCostImpactAmount: Double
    public let startingCashBalance: Double
    public let cashBalance: Double
    public let availableSimulatedCash: Double
    public let equity: Double
    public let grossExposureNotional: Double
    public let realizedSimulatedPnL: Double
    public let unrealizedSimulatedPnL: Double
    public let netSimulatedPnL: Double
    public let exposure: PortfolioExposureSnapshot
    public let projectedAt: Date
    public let sourceAnchor: String
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let runsBrokerReconciliation: Bool
    public let syncsRealAccountBalance: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool

    public var projectionBoundaryHeld: Bool {
        sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && reportInputVersionIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && sourceReplaySequence > 0
            && exposure.portfolioID == portfolioID
            && exposure.symbol == symbol
            && exposure.timeframe == timeframe
            && exposure.paperQuantity == netQuantity
            && exposure.referencePrice == lastFillPrice
            && exposure.source == .paperProjection
            && valuesAreFinite
            && forbiddenCapabilityBoundaryHeld
    }

    public var parityComparableIdentity: String {
        [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            symbol.rawValue,
            timeframe.rawValue,
            "order=\(orderID.rawValue)",
            "event=\(sourceEventID.rawValue)",
            "reportInput=\(reportInputVersionIdentity)",
            "sourceReplaySequence=\(sourceReplaySequence)",
            "quantity=\(Self.scaledQuantity(netQuantity.rawValue))",
            "price=\(Self.scaledQuantity(lastFillPrice.rawValue))",
            "cash=\(Self.scaledAmount(cashBalance))",
            "equity=\(Self.scaledAmount(equity))",
            "grossExposure=\(Self.scaledAmount(grossExposureNotional))",
            "netPnL=\(Self.scaledAmount(netSimulatedPnL))"
        ].joined(separator: "|")
    }

    private var valuesAreFinite: Bool {
        [
            positionMarketValue,
            costBasisNotional,
            totalFeeAmount,
            totalSlippageAmount,
            totalCostImpactAmount,
            startingCashBalance,
            cashBalance,
            availableSimulatedCash,
            equity,
            grossExposureNotional,
            realizedSimulatedPnL,
            unrealizedSimulatedPnL,
            netSimulatedPnL
        ].allSatisfy(\.isFinite)
            && positionMarketValue >= 0
            && costBasisNotional >= 0
            && totalFeeAmount >= 0
            && totalSlippageAmount >= 0
            && totalCostImpactAmount >= 0
            && startingCashBalance > 0
            && cashBalance >= 0
            && availableSimulatedCash >= 0
            && equity >= 0
            && grossExposureNotional >= 0
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && readsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && runsBrokerReconciliation == false
            && syncsRealAccountBalance == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public init(
        projectionID: Identifier,
        mode: SimulatedExchangePortfolioProjectionMode,
        accountID: Identifier,
        portfolioID: Identifier,
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        fixtureVersion: FixtureVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        orderID: Identifier,
        sourceEventID: Identifier,
        sourceReportID: Identifier,
        reportInputVersionIdentity: String,
        sourceReplaySequence: Int,
        netQuantity: Quantity,
        averageEntryPrice: Price,
        lastFillPrice: Price,
        positionMarketValue: Double,
        costBasisNotional: Double,
        totalFeeAmount: Double,
        totalSlippageAmount: Double,
        totalCostImpactAmount: Double,
        startingCashBalance: Double,
        cashBalance: Double,
        availableSimulatedCash: Double,
        equity: Double,
        grossExposureNotional: Double,
        realizedSimulatedPnL: Double,
        unrealizedSimulatedPnL: Double,
        netSimulatedPnL: Double,
        exposure: PortfolioExposureSnapshot,
        projectedAt: Date,
        sourceAnchor: String,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsBrokerReconciliation: Bool = false,
        syncsRealAccountBalance: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            reportInputVersionIdentity: reportInputVersionIdentity,
            sourceReplaySequence: sourceReplaySequence,
            exposure: exposure,
            portfolioID: portfolioID,
            symbol: symbol,
            timeframe: timeframe,
            netQuantity: netQuantity,
            lastFillPrice: lastFillPrice,
            positionMarketValue: positionMarketValue,
            costBasisNotional: costBasisNotional,
            totalFeeAmount: totalFeeAmount,
            totalSlippageAmount: totalSlippageAmount,
            totalCostImpactAmount: totalCostImpactAmount,
            startingCashBalance: startingCashBalance,
            cashBalance: cashBalance,
            availableSimulatedCash: availableSimulatedCash,
            equity: equity,
            grossExposureNotional: grossExposureNotional,
            realizedSimulatedPnL: realizedSimulatedPnL,
            unrealizedSimulatedPnL: unrealizedSimulatedPnL,
            netSimulatedPnL: netSimulatedPnL,
            sourceAnchor: sourceAnchor,
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )

        self.projectionID = projectionID
        self.mode = mode
        self.accountID = accountID
        self.portfolioID = portfolioID
        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.orderID = orderID
        self.sourceEventID = sourceEventID
        self.sourceReportID = sourceReportID
        self.reportInputVersionIdentity = reportInputVersionIdentity
        self.sourceReplaySequence = sourceReplaySequence
        self.netQuantity = netQuantity
        self.averageEntryPrice = averageEntryPrice
        self.lastFillPrice = lastFillPrice
        self.positionMarketValue = positionMarketValue
        self.costBasisNotional = costBasisNotional
        self.totalFeeAmount = totalFeeAmount
        self.totalSlippageAmount = totalSlippageAmount
        self.totalCostImpactAmount = totalCostImpactAmount
        self.startingCashBalance = startingCashBalance
        self.cashBalance = cashBalance
        self.availableSimulatedCash = availableSimulatedCash
        self.equity = equity
        self.grossExposureNotional = grossExposureNotional
        self.realizedSimulatedPnL = realizedSimulatedPnL
        self.unrealizedSimulatedPnL = unrealizedSimulatedPnL
        self.netSimulatedPnL = netSimulatedPnL
        self.exposure = exposure
        self.projectedAt = projectedAt
        self.sourceAnchor = sourceAnchor
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.runsBrokerReconciliation = runsBrokerReconciliation
        self.syncsRealAccountBalance = syncsRealAccountBalance
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            projectionID: try container.decode(Identifier.self, forKey: .projectionID),
            mode: try container.decode(SimulatedExchangePortfolioProjectionMode.self, forKey: .mode),
            accountID: try container.decode(Identifier.self, forKey: .accountID),
            portfolioID: try container.decode(Identifier.self, forKey: .portfolioID),
            scenarioID: try container.decode(ScenarioID.self, forKey: .scenarioID),
            datasetVersion: try container.decode(DatasetVersion.self, forKey: .datasetVersion),
            fixtureVersion: try container.decode(FixtureVersion.self, forKey: .fixtureVersion),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            sourceEventID: try container.decode(Identifier.self, forKey: .sourceEventID),
            sourceReportID: try container.decode(Identifier.self, forKey: .sourceReportID),
            reportInputVersionIdentity: try container.decode(String.self, forKey: .reportInputVersionIdentity),
            sourceReplaySequence: try container.decode(Int.self, forKey: .sourceReplaySequence),
            netQuantity: try container.decode(Quantity.self, forKey: .netQuantity),
            averageEntryPrice: try container.decode(Price.self, forKey: .averageEntryPrice),
            lastFillPrice: try container.decode(Price.self, forKey: .lastFillPrice),
            positionMarketValue: try container.decode(Double.self, forKey: .positionMarketValue),
            costBasisNotional: try container.decode(Double.self, forKey: .costBasisNotional),
            totalFeeAmount: try container.decode(Double.self, forKey: .totalFeeAmount),
            totalSlippageAmount: try container.decode(Double.self, forKey: .totalSlippageAmount),
            totalCostImpactAmount: try container.decode(Double.self, forKey: .totalCostImpactAmount),
            startingCashBalance: try container.decode(Double.self, forKey: .startingCashBalance),
            cashBalance: try container.decode(Double.self, forKey: .cashBalance),
            availableSimulatedCash: try container.decode(Double.self, forKey: .availableSimulatedCash),
            equity: try container.decode(Double.self, forKey: .equity),
            grossExposureNotional: try container.decode(Double.self, forKey: .grossExposureNotional),
            realizedSimulatedPnL: try container.decode(Double.self, forKey: .realizedSimulatedPnL),
            unrealizedSimulatedPnL: try container.decode(Double.self, forKey: .unrealizedSimulatedPnL),
            netSimulatedPnL: try container.decode(Double.self, forKey: .netSimulatedPnL),
            exposure: try container.decode(PortfolioExposureSnapshot.self, forKey: .exposure),
            projectedAt: try container.decode(Date.self, forKey: .projectedAt),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            readsBrokerPosition: try container.decode(Bool.self, forKey: .readsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            runsBrokerReconciliation: try container.decode(Bool.self, forKey: .runsBrokerReconciliation),
            syncsRealAccountBalance: try container.decode(Bool.self, forKey: .syncsRealAccountBalance),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    private static func validate(
        reportInputVersionIdentity: String,
        sourceReplaySequence: Int,
        exposure: PortfolioExposureSnapshot,
        portfolioID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        netQuantity: Quantity,
        lastFillPrice: Price,
        positionMarketValue: Double,
        costBasisNotional: Double,
        totalFeeAmount: Double,
        totalSlippageAmount: Double,
        totalCostImpactAmount: Double,
        startingCashBalance: Double,
        cashBalance: Double,
        availableSimulatedCash: Double,
        equity: Double,
        grossExposureNotional: Double,
        realizedSimulatedPnL: Double,
        unrealizedSimulatedPnL: Double,
        netSimulatedPnL: Double,
        sourceAnchor: String,
        readsRealAccountBalance: Bool,
        readsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        runsBrokerReconciliation: Bool,
        syncsRealAccountBalance: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool
    ) throws {
        guard reportInputVersionIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              sourceReplaySequence > 0,
              sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              exposure.portfolioID == portfolioID,
              exposure.symbol == symbol,
              exposure.timeframe == timeframe,
              exposure.paperQuantity == netQuantity,
              exposure.referencePrice == lastFillPrice,
              exposure.source == .paperProjection else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionSnapshot.source",
                expected: "report input, replay sequence, and simulated exposure identity",
                actual: "invalid"
            )
        }
        let finiteValues = [
            positionMarketValue,
            costBasisNotional,
            totalFeeAmount,
            totalSlippageAmount,
            totalCostImpactAmount,
            startingCashBalance,
            cashBalance,
            availableSimulatedCash,
            equity,
            grossExposureNotional,
            realizedSimulatedPnL,
            unrealizedSimulatedPnL,
            netSimulatedPnL
        ]
        guard finiteValues.allSatisfy(\.isFinite),
              positionMarketValue >= 0,
              costBasisNotional >= 0,
              totalFeeAmount >= 0,
              totalSlippageAmount >= 0,
              totalCostImpactAmount >= 0,
              startingCashBalance > 0,
              cashBalance >= 0,
              availableSimulatedCash >= 0,
              equity >= 0,
              grossExposureNotional >= 0 else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionSnapshot.values",
                expected: "finite simulated portfolio values with non-negative cash and exposure",
                actual: "invalid"
            )
        }
        try SimulatedExchangePortfolioProjectionParityContract.validateForbiddenFlags(
            prefix: "simulatedExchangePortfolioProjectionSnapshot",
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton
        )
    }

    private static func scaledQuantity(_ value: Double) -> Int {
        Int((value * 1_000_000).rounded())
    }

    private static func scaledAmount(_ value: Double) -> Int {
        Int((value * 100_000_000).rounded())
    }
}

/// SimulatedExchangePortfolioProjectionParityEvidence 汇总 MTP-115 的 backtest / paper parity 结果。
///
/// Evidence 证明两侧 projection 共享同一 source event、report input version 和 replay sequence，
/// 且 position、cash、PnL、exposure 数值完全一致。该 evidence 仍是 Core 层值对象，不是 App surface。
public struct SimulatedExchangePortfolioProjectionParityEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let inputIdentity: String
    public let sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence
    public let reportInputVersion: ScenarioReportInputVersion
    public let backtestProjection: SimulatedExchangePortfolioProjectionSnapshot
    public let paperProjection: SimulatedExchangePortfolioProjectionSnapshot
    public let rules: [SimulatedExchangePortfolioProjectionRule]
    public let validationAnchors: [String]
    public let readsRealAccountBalance: Bool
    public let readsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let runsBrokerReconciliation: Bool
    public let syncsRealAccountBalance: Bool
    public let providesLiveCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var parityEvidenceBoundaryHeld: Bool {
        inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && sourceReportEvidence.reportEvidenceBoundaryHeld
            && reportInputVersion.reportInputBoundaryHeld
            && backtestProjection.mode == .backtest
            && paperProjection.mode == .paper
            && backtestProjection.projectionBoundaryHeld
            && paperProjection.projectionBoundaryHeld
            && projectionParityHeld
            && rules == SimulatedExchangePortfolioProjectionParityContract.requiredRules
            && validationAnchors == SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var projectionParityHeld: Bool {
        backtestProjection.parityComparableIdentity == paperProjection.parityComparableIdentity
    }

    public var deterministicResultIdentity: String {
        [
            inputIdentity,
            "backtest=\(backtestProjection.parityComparableIdentity)",
            "paper=\(paperProjection.parityComparableIdentity)"
        ].joined(separator: "|")
    }

    private var forbiddenCapabilityBoundaryHeld: Bool {
        readsRealAccountBalance == false
            && readsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && runsBrokerReconciliation == false
            && syncsRealAccountBalance == false
            && providesLiveCommand == false
            && providesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        evidenceID: Identifier,
        inputIdentity: String,
        sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence,
        reportInputVersion: ScenarioReportInputVersion,
        backtestProjection: SimulatedExchangePortfolioProjectionSnapshot,
        paperProjection: SimulatedExchangePortfolioProjectionSnapshot,
        rules: [SimulatedExchangePortfolioProjectionRule] =
            SimulatedExchangePortfolioProjectionParityContract.requiredRules,
        validationAnchors: [String] = SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors,
        readsRealAccountBalance: Bool = false,
        readsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsBrokerReconciliation: Bool = false,
        syncsRealAccountBalance: Bool = false,
        providesLiveCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            inputIdentity: inputIdentity,
            sourceReportEvidence: sourceReportEvidence,
            reportInputVersion: reportInputVersion,
            backtestProjection: backtestProjection,
            paperProjection: paperProjection,
            rules: rules,
            validationAnchors: validationAnchors,
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.evidenceID = evidenceID
        self.inputIdentity = inputIdentity
        self.sourceReportEvidence = sourceReportEvidence
        self.reportInputVersion = reportInputVersion
        self.backtestProjection = backtestProjection
        self.paperProjection = paperProjection
        self.rules = rules
        self.validationAnchors = validationAnchors
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsBrokerPosition = readsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.runsBrokerReconciliation = runsBrokerReconciliation
        self.syncsRealAccountBalance = syncsRealAccountBalance
        self.providesLiveCommand = providesLiveCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            inputIdentity: try container.decode(String.self, forKey: .inputIdentity),
            sourceReportEvidence: try container.decode(
                PartialFillLatencyFeeSlippageParityReportEvidence.self,
                forKey: .sourceReportEvidence
            ),
            reportInputVersion: try container.decode(ScenarioReportInputVersion.self, forKey: .reportInputVersion),
            backtestProjection: try container.decode(
                SimulatedExchangePortfolioProjectionSnapshot.self,
                forKey: .backtestProjection
            ),
            paperProjection: try container.decode(
                SimulatedExchangePortfolioProjectionSnapshot.self,
                forKey: .paperProjection
            ),
            rules: try container.decode([SimulatedExchangePortfolioProjectionRule].self, forKey: .rules),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            readsBrokerPosition: try container.decode(Bool.self, forKey: .readsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            runsBrokerReconciliation: try container.decode(Bool.self, forKey: .runsBrokerReconciliation),
            syncsRealAccountBalance: try container.decode(Bool.self, forKey: .syncsRealAccountBalance),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    private static func validate(
        inputIdentity: String,
        sourceReportEvidence: PartialFillLatencyFeeSlippageParityReportEvidence,
        reportInputVersion: ScenarioReportInputVersion,
        backtestProjection: SimulatedExchangePortfolioProjectionSnapshot,
        paperProjection: SimulatedExchangePortfolioProjectionSnapshot,
        rules: [SimulatedExchangePortfolioProjectionRule],
        validationAnchors: [String],
        readsRealAccountBalance: Bool,
        readsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        runsBrokerReconciliation: Bool,
        syncsRealAccountBalance: Bool,
        providesLiveCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard inputIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              sourceReportEvidence.reportEvidenceBoundaryHeld,
              reportInputVersion.reportInputBoundaryHeld,
              backtestProjection.mode == .backtest,
              paperProjection.mode == .paper,
              backtestProjection.projectionBoundaryHeld,
              paperProjection.projectionBoundaryHeld,
              backtestProjection.parityComparableIdentity == paperProjection.parityComparableIdentity else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionParityEvidence",
                expected: "same source event, report input, replay sequence, and projection values",
                actual: "mismatch"
            )
        }
        try SimulatedExchangePortfolioProjectionParityContract.validateList(
            field: "simulatedExchangePortfolioProjectionParityEvidence.rules",
            expected: SimulatedExchangePortfolioProjectionParityContract.requiredRules.map(\.rawValue),
            actual: rules.map(\.rawValue)
        )
        try SimulatedExchangePortfolioProjectionParityContract.validateList(
            field: "simulatedExchangePortfolioProjectionParityEvidence.validationAnchors",
            expected: SimulatedExchangePortfolioProjectionParityContract.requiredValidationAnchors,
            actual: validationAnchors
        )
        try SimulatedExchangePortfolioProjectionParityContract.validateForbiddenFlags(
            prefix: "simulatedExchangePortfolioProjectionParityEvidence",
            readsRealAccountBalance: readsRealAccountBalance,
            readsBrokerPosition: readsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsBrokerReconciliation: runsBrokerReconciliation,
            syncsRealAccountBalance: syncsRealAccountBalance,
            providesLiveCommand: providesLiveCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )
    }
}

/// SimulatedExchangePortfolioProjectionParityModel 是 MTP-115 的纯函数 projection parity 入口。
///
/// `project` 只读取传入 deterministic evidence，并用同一 simulated exchange parity event 同时生成
/// backtest 与 paper projection。它不写 Event Log、不访问 persistence schema、不读取真实账户或 broker。
public enum SimulatedExchangePortfolioProjectionParityModel {
    public static func project(
        _ input: SimulatedExchangePortfolioProjectionParityInput
    ) throws -> SimulatedExchangePortfolioProjectionParityEvidence {
        guard input.inputBoundaryHeld else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionParityModel.input",
                expected: "input boundary held",
                actual: "false"
            )
        }

        let event = input.sourceReportEvidence.parityEvent
        let sharedOrder = input.sourceReportEvidence.sourceExecutionOutput.matchingOutput?
            .simulatedExchangeEvent
        guard let simulatedExchangeEvent = sharedOrder else {
            throw CoreError.simulatedExchangeBacktestParityContractMismatch(
                field: "simulatedExchangePortfolioProjectionParityModel.sourceEvent",
                expected: "MTP-112 simulated exchange event",
                actual: "nil"
            )
        }

        let backtestProjection = try makeProjection(
            mode: .backtest,
            input: input,
            simulatedExchangeEvent: simulatedExchangeEvent,
            event: event,
            costEstimate: event.backtestCostEstimate
        )
        let paperProjection = try makeProjection(
            mode: .paper,
            input: input,
            simulatedExchangeEvent: simulatedExchangeEvent,
            event: event,
            costEstimate: event.paperCostEstimate
        )

        return try SimulatedExchangePortfolioProjectionParityEvidence(
            evidenceID: try Identifier("mtp-115-simulated-exchange-portfolio-projection-parity"),
            inputIdentity: input.deterministicInputIdentity,
            sourceReportEvidence: input.sourceReportEvidence,
            reportInputVersion: input.reportInputVersion,
            backtestProjection: backtestProjection,
            paperProjection: paperProjection
        )
    }

    private static func makeProjection(
        mode: SimulatedExchangePortfolioProjectionMode,
        input: SimulatedExchangePortfolioProjectionParityInput,
        simulatedExchangeEvent: ScenarioReplaySimulatedExchangeEvent,
        event: PartialFillLatencyFeeSlippageParityEvent,
        costEstimate: ExecutionCostEstimate
    ) throws -> SimulatedExchangePortfolioProjectionSnapshot {
        let filledQuantity = event.filledQuantity
        let price = event.matchedPrice
        let positionMarketValue = filledQuantity.rawValue * price.rawValue
        let costBasisNotional = positionMarketValue
        let totalCostImpactAmount = costEstimate.totalCostAmount
        let cashBalance = input.startingCashBalance - costBasisNotional - totalCostImpactAmount
        let equity = cashBalance + positionMarketValue
        let unrealizedPnL = positionMarketValue - costBasisNotional - totalCostImpactAmount
        let exposure = PortfolioExposureSnapshot(
            portfolioID: input.portfolioID,
            symbol: input.reportInputVersion.symbol,
            timeframe: input.reportInputVersion.timeframe,
            paperQuantity: filledQuantity,
            referencePrice: price,
            source: .paperProjection,
            observedAt: input.projectedAt
        )

        return try SimulatedExchangePortfolioProjectionSnapshot(
            projectionID: try Identifier("mtp-115-\(modeID(mode))-portfolio-projection"),
            mode: mode,
            accountID: input.accountID,
            portfolioID: input.portfolioID,
            scenarioID: simulatedExchangeEvent.scenarioID,
            datasetVersion: simulatedExchangeEvent.datasetVersion,
            fixtureVersion: simulatedExchangeEvent.fixtureVersion,
            symbol: input.reportInputVersion.symbol,
            timeframe: input.reportInputVersion.timeframe,
            orderID: event.orderID,
            sourceEventID: event.eventID,
            sourceReportID: input.sourceReportEvidence.reportID,
            reportInputVersionIdentity: input.reportInputVersion.versionIdentity,
            sourceReplaySequence: input.sourceReplaySequence,
            netQuantity: filledQuantity,
            averageEntryPrice: price,
            lastFillPrice: price,
            positionMarketValue: positionMarketValue,
            costBasisNotional: costBasisNotional,
            totalFeeAmount: costEstimate.feeAmount,
            totalSlippageAmount: costEstimate.slippageAmount,
            totalCostImpactAmount: totalCostImpactAmount,
            startingCashBalance: input.startingCashBalance,
            cashBalance: cashBalance,
            availableSimulatedCash: cashBalance,
            equity: equity,
            grossExposureNotional: exposure.grossExposureNotional,
            realizedSimulatedPnL: 0,
            unrealizedSimulatedPnL: unrealizedPnL,
            netSimulatedPnL: unrealizedPnL,
            exposure: exposure,
            projectedAt: input.projectedAt,
            sourceAnchor: "MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION"
        )
    }

    private static func modeID(_ mode: SimulatedExchangePortfolioProjectionMode) -> String {
        switch mode {
        case .backtest:
            "backtest"
        case .paper:
            "paper"
        }
    }
}

/// SimulatedExchangePortfolioProjectionParityFixture 提供 MTP-115 deterministic tracer bullet。
public enum SimulatedExchangePortfolioProjectionParityFixture {
    public static func deterministicEvidence() throws -> SimulatedExchangePortfolioProjectionParityEvidence {
        try SimulatedExchangePortfolioProjectionParityModel.project(
            try SimulatedExchangePortfolioProjectionParityInput()
        )
    }
}
