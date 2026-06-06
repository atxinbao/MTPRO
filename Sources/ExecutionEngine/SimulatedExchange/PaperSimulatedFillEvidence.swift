import DomainModel
import ExecutionEngine
import Foundation
import MessageBus

/// Paper simulated fill evidence 是本地 paper runtime 的模拟成交、fee 和 slippage 证据模型。
///
/// MTP-40 最初只把 allowed `PaperOrderIntent` 转成 full simulated fill。MTP-100 在同一
/// Core 边界内继续加入 market snapshot、MTP-99 accepted-local precondition、partial / full
/// completion、fill price assumption、fee / slippage deterministic impact，以及通过 MTP-97
/// `PaperRuntimeMessageBusRouting` 写入 append-only `.paper` stream 的 replay evidence。这里仍不
/// 读取真实成交回报、不连接 broker、不调用 signed endpoint、不更新真实账户，也不代表 execution report。

/// PaperSimulatedFillCompletion 区分 deterministic full fill 与 partial fill。
///
/// `full` 必须等于 order intent quantity；`partial` 必须小于 order intent quantity，并显式留下
/// remaining quantity。该枚举只是 paper evidence，不表达真实撮合、真实成交质量或 broker partial fill。
public enum PaperSimulatedFillCompletion: String, Codable, Equatable, Sendable {
    case full
    case partial
}

/// PaperSimulatedFillPriceSource 固定 MTP-100 允许的 fill price assumption。
///
/// 价格只能来自本地 order reference 或传入的 deterministic market snapshot。它不查询盘口、不读取
/// exchange account tier、不做动态滑点优化，也不代表真实成交价格。
public enum PaperSimulatedFillPriceSource: String, Codable, Equatable, Sendable {
    case orderReference
    case marketLastPrice
    case bestBid
    case bestAsk
}

/// PaperSimulatedFillMarketSnapshot 是 simulated fill model 的 market-side 输入。
///
/// snapshot 只保存本地 fixture / replay 可以提供的 bid、ask、last price；它不是 Adapter payload，
/// 不包含 signed endpoint、account endpoint、listenKey、broker execution report 或真实成交回报。
public struct PaperSimulatedFillMarketSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let bidPrice: Price
    public let askPrice: Price
    public let lastPrice: Price
    public let observedAt: Date
    public let sourceAnchor: String
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let connectsBroker: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool

    public var paperOnlyBoundaryHeld: Bool {
        usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && connectsBroker == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
    }

    public init(
        snapshotID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        bidPrice: Price,
        askPrice: Price,
        lastPrice: Price,
        observedAt: Date,
        sourceAnchor: String,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        connectsBroker: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false
    ) throws {
        guard bidPrice.rawValue <= askPrice.rawValue else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "marketSnapshot.bidAsk",
                expected: "bid <= ask",
                actual: "\(bidPrice.rawValue) > \(askPrice.rawValue)"
            )
        }
        guard sourceAnchor.isEmpty == false else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "marketSnapshot.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
        try Self.validateForbiddenCapabilities(
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            connectsBroker: connectsBroker,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill
        )

        self.snapshotID = snapshotID
        self.symbol = symbol
        self.timeframe = timeframe
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.lastPrice = lastPrice
        self.observedAt = observedAt
        self.sourceAnchor = sourceAnchor
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.connectsBroker = connectsBroker
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            snapshotID: try container.decode(Identifier.self, forKey: .snapshotID),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            bidPrice: try container.decode(Price.self, forKey: .bidPrice),
            askPrice: try container.decode(Price.self, forKey: .askPrice),
            lastPrice: try container.decode(Price.self, forKey: .lastPrice),
            observedAt: try container.decode(Date.self, forKey: .observedAt),
            sourceAnchor: try container.decode(String.self, forKey: .sourceAnchor),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill)
        )
    }

    public func price(for source: PaperSimulatedFillPriceSource, orderReferencePrice: Price) -> Price {
        switch source {
        case .orderReference:
            orderReferencePrice
        case .marketLastPrice:
            lastPrice
        case .bestBid:
            bidPrice
        case .bestAsk:
            askPrice
        }
    }

    public static let deterministicFixture: PaperSimulatedFillMarketSnapshot = {
        do {
            return try PaperSimulatedFillMarketSnapshot(
                snapshotID: try Identifier("mtp-100-simulated-fill-market-snapshot"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                bidPrice: try Price(99.75, field: "paperSimulatedFill.marketSnapshot.bidPrice"),
                askPrice: try Price(100.25, field: "paperSimulatedFill.marketSnapshot.askPrice"),
                lastPrice: try Price(100, field: "paperSimulatedFill.marketSnapshot.lastPrice"),
                observedAt: Date(timeIntervalSince1970: 6_000),
                sourceAnchor: "MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT"
            )
        } catch {
            preconditionFailure("Invalid deterministic MTP-100 market snapshot fixture: \(error)")
        }
    }()

    private static func validateForbiddenCapabilities(
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        connectsBroker: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("connectsBroker", connectsBroker),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperSimulatedFillForbiddenCapability("marketSnapshot.\(forbidden.0)")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case snapshotID
        case symbol
        case timeframe
        case bidPrice
        case askPrice
        case lastPrice
        case observedAt
        case sourceAnchor
        case usesSignedEndpoint
        case callsAccountEndpoint
        case connectsBroker
        case consumesExecutionReport
        case recordsBrokerFill
    }
}

/// PaperSimulatedFillAssumption 保存 deterministic 模拟成交假设。
///
/// assumption 同时固定 fill completion、filled quantity、fill price、fill price source、maker / taker
/// liquidity role 和 MTP-27 execution cost assumptions。fee / slippage 仍只来自固定 bps fixture；
/// 不引入交易所费率表、动态滑点模型或执行成本优化器。
public struct PaperSimulatedFillAssumption: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let completion: PaperSimulatedFillCompletion
    public let filledQuantity: Quantity
    public let fillPrice: Price
    public let fillPriceSource: PaperSimulatedFillPriceSource
    public let liquidityRole: ExecutionCostLiquidityRole
    public let executionCostAssumptions: ExecutionCostAssumptions

    public init(
        assumptionID: Identifier,
        filledQuantity: Quantity,
        fillPrice: Price,
        liquidityRole: ExecutionCostLiquidityRole,
        executionCostAssumptions: ExecutionCostAssumptions = .deterministicFixture,
        completion: PaperSimulatedFillCompletion = .full,
        fillPriceSource: PaperSimulatedFillPriceSource = .orderReference
    ) throws {
        guard filledQuantity.rawValue > 0 else {
            throw CoreError.invalidPaperSimulatedFillQuantity(filledQuantity.rawValue)
        }

        self.assumptionID = assumptionID
        self.completion = completion
        self.filledQuantity = filledQuantity
        self.fillPrice = fillPrice
        self.fillPriceSource = fillPriceSource
        self.liquidityRole = liquidityRole
        self.executionCostAssumptions = executionCostAssumptions
    }

    /// MTP-40 / MTP-100 deterministic fixture 固定为 full simulated fill，不代表真实撮合价格或成交回报。
    public static let deterministicFixture: PaperSimulatedFillAssumption = {
        do {
            return try PaperSimulatedFillAssumption(
                assumptionID: try Identifier("mtp-40-simulated-fill-assumption"),
                filledQuantity: try Quantity(0.5, field: "paperSimulatedFill.filledQuantity"),
                fillPrice: try Price(100, field: "paperSimulatedFill.fillPrice"),
                liquidityRole: .maker,
                executionCostAssumptions: .deterministicFixture,
                completion: .full,
                fillPriceSource: .orderReference
            )
        } catch {
            preconditionFailure("Invalid deterministic simulated fill fixture: \(error)")
        }
    }()

    /// MTP-100 partial fixture 使用 deterministic best-ask price 和 taker fee assumption。
    ///
    /// 该 fixture 只证明 partial fill 的 cost impact 可重复计算，不代表真实 taker execution。
    public static let deterministicPartialFixture: PaperSimulatedFillAssumption = {
        do {
            return try PaperSimulatedFillAssumption(
                assumptionID: try Identifier("mtp-100-partial-simulated-fill-assumption"),
                filledQuantity: try Quantity(0.25, field: "paperSimulatedFill.partial.filledQuantity"),
                fillPrice: try Price(100.25, field: "paperSimulatedFill.partial.fillPrice"),
                liquidityRole: .taker,
                executionCostAssumptions: .deterministicFixture,
                completion: .partial,
                fillPriceSource: .bestAsk
            )
        } catch {
            preconditionFailure("Invalid deterministic partial simulated fill fixture: \(error)")
        }
    }()
}

/// PaperSimulatedFillEvidence 记录 paper-only simulated fill 的可追溯快照。
///
/// 输入只能是 allowed paper order intent + MTP-99 accepted-local precondition + deterministic market
/// snapshot + fill assumption；输出只表达本地模拟成交、fee/slippage cost impact 和 workflow evidence。
/// 所有真实交易能力、broker fill、execution report、real account update 和 Live fallback 旗标都必须关闭。
public struct PaperSimulatedFillEvidence: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let orderID: Identifier
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let riskDecisionID: Identifier
    public let riskProfileID: Identifier
    public let marketSnapshotID: Identifier
    public let orderLifecycleState: PaperOrderLifecycleState
    public let localLifecycleState: PaperOrderLocalLifecycleState?
    public let riskDecisionStatus: PaperActionProposalRiskDecisionStatus
    public let side: PaperActionProposalSide
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let fillCompletion: PaperSimulatedFillCompletion
    public let filledQuantity: Quantity
    public let remainingQuantity: Quantity
    public let fillPrice: Price
    public let fillPriceSource: PaperSimulatedFillPriceSource
    public let orderIntentQuantity: Quantity
    public let orderIntentReferencePrice: Price
    public let grossNotional: Double
    public let feeAssumptionID: Identifier
    public let slippageAssumptionID: Identifier
    public let fillPriceAssumptionID: Identifier
    public let costImpactAmount: Double
    public let costEstimate: ExecutionCostEstimate
    public let executionMode: ExecutionMode
    public let proposalAuthorization: PaperActionProposalAuthorization
    public let workflowStage: PaperExecutionWorkflowStage
    public let eventStream: EventStreamID
    public let evidenceKind: PaperExecutionWorkflowEvidenceKind
    public let sourceOrderIntentSequence: Int
    public let sourceRiskDecisionSequence: Int
    public let sourceLifecycleSequence: Int?
    public let filledAt: Date
    public let isSimulatedFillEvidence: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesBrokerAction: Bool
    public let representsRealOrder: Bool
    public let representsRealFill: Bool
    public let representsBrokerFill: Bool
    public let consumesExecutionReport: Bool
    public let performsReconciliation: Bool
    public let updatesRealAccountBalance: Bool

    public var isExecutableAsRealOrder: Bool {
        false
    }

    public var paperOnlyBoundaryHeld: Bool {
        isSimulatedFillEvidence
            && executionMode == .paper
            && proposalAuthorization == .paperIntentOnly
            && workflowStage == .simulatedFill
            && eventStream == .paper
            && evidenceKind == .simulatedFill
            && authorizesTradingExecution == false
            && authorizesLiveTrading == false
            && touchesSignedEndpoint == false
            && touchesBrokerAction == false
            && representsRealOrder == false
            && representsRealFill == false
            && representsBrokerFill == false
            && consumesExecutionReport == false
            && performsReconciliation == false
            && updatesRealAccountBalance == false
            && isExecutableAsRealOrder == false
    }

    public init(
        fillID: Identifier,
        orderIntent: PaperOrderIntent,
        assumption: PaperSimulatedFillAssumption,
        sourceOrderIntentSequence: Int,
        filledAt: Date
    ) throws {
        try self.init(
            fillID: fillID,
            orderIntent: orderIntent,
            optionalLifecyclePrecondition: nil,
            marketSnapshot: .deterministicFixture,
            assumption: assumption,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            filledAt: filledAt
        )
    }

    public init(
        fillID: Identifier,
        orderIntent: PaperOrderIntent,
        lifecyclePrecondition: PaperOrderSimulatedFillPrecondition,
        marketSnapshot: PaperSimulatedFillMarketSnapshot,
        assumption: PaperSimulatedFillAssumption,
        sourceOrderIntentSequence: Int,
        filledAt: Date
    ) throws {
        try self.init(
            fillID: fillID,
            orderIntent: orderIntent,
            optionalLifecyclePrecondition: lifecyclePrecondition,
            marketSnapshot: marketSnapshot,
            assumption: assumption,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            filledAt: filledAt
        )
    }

    private init(
        fillID: Identifier,
        orderIntent: PaperOrderIntent,
        optionalLifecyclePrecondition lifecyclePrecondition: PaperOrderSimulatedFillPrecondition?,
        marketSnapshot: PaperSimulatedFillMarketSnapshot,
        assumption: PaperSimulatedFillAssumption,
        sourceOrderIntentSequence: Int,
        filledAt: Date
    ) throws {
        let expectedFillPrice = marketSnapshot.price(
            for: assumption.fillPriceSource,
            orderReferencePrice: orderIntent.referencePrice
        )
        guard assumption.fillPrice == expectedFillPrice else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "fillPrice",
                expected: "\(expectedFillPrice.rawValue)",
                actual: "\(assumption.fillPrice.rawValue)"
            )
        }
        let remainingQuantity = try Quantity(
            orderIntent.quantity.rawValue - assumption.filledQuantity.rawValue,
            field: "paperSimulatedFill.remainingQuantity"
        )
        let costEstimate = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: orderIntent.symbol,
                timeframe: orderIntent.timeframe,
                executionMode: .paper,
                referencePrice: assumption.fillPrice,
                quantity: assumption.filledQuantity,
                liquidityRole: assumption.liquidityRole
            ),
            assumptions: assumption.executionCostAssumptions
        )

        try self.init(
            fillID: fillID,
            orderID: orderIntent.orderID,
            proposalID: orderIntent.proposalID,
            sessionID: orderIntent.sessionID,
            riskDecisionID: orderIntent.riskDecisionID,
            riskProfileID: orderIntent.riskProfileID,
            marketSnapshotID: marketSnapshot.snapshotID,
            orderLifecycleState: orderIntent.lifecycleState,
            localLifecycleState: lifecyclePrecondition?.localState,
            riskDecisionStatus: orderIntent.riskDecisionStatus,
            side: orderIntent.side,
            symbol: orderIntent.symbol,
            timeframe: orderIntent.timeframe,
            fillCompletion: assumption.completion,
            filledQuantity: assumption.filledQuantity,
            remainingQuantity: remainingQuantity,
            fillPrice: assumption.fillPrice,
            fillPriceSource: assumption.fillPriceSource,
            grossNotional: costEstimate.grossNotional,
            feeAssumptionID: assumption.executionCostAssumptions.assumptionID,
            slippageAssumptionID: assumption.executionCostAssumptions.assumptionID,
            fillPriceAssumptionID: assumption.assumptionID,
            costImpactAmount: costEstimate.totalCostAmount,
            costEstimate: costEstimate,
            executionMode: orderIntent.executionMode,
            proposalAuthorization: orderIntent.proposalAuthorization,
            workflowStage: .simulatedFill,
            eventStream: .paper,
            evidenceKind: .simulatedFill,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            sourceRiskDecisionSequence: orderIntent.sourceRiskDecisionSequence,
            sourceLifecycleSequence: lifecyclePrecondition?.sourceLifecycleSequence,
            filledAt: filledAt,
            isSimulatedFillEvidence: true,
            authorizesTradingExecution: false,
            authorizesLiveTrading: false,
            touchesSignedEndpoint: false,
            touchesBrokerAction: false,
            representsRealOrder: false,
            representsRealFill: false,
            representsBrokerFill: false,
            consumesExecutionReport: false,
            performsReconciliation: false,
            updatesRealAccountBalance: false,
            orderIntentQuantity: orderIntent.quantity,
            orderIntentReferencePrice: orderIntent.referencePrice
        )

        try validateModelInputs(
            orderIntent: orderIntent,
            lifecyclePrecondition: lifecyclePrecondition,
            marketSnapshot: marketSnapshot
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            fillID: try container.decode(Identifier.self, forKey: .fillID),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            proposalID: try container.decode(Identifier.self, forKey: .proposalID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            riskDecisionID: try container.decode(Identifier.self, forKey: .riskDecisionID),
            riskProfileID: try container.decode(Identifier.self, forKey: .riskProfileID),
            marketSnapshotID: try container.decode(Identifier.self, forKey: .marketSnapshotID),
            orderLifecycleState: try container.decode(PaperOrderLifecycleState.self, forKey: .orderLifecycleState),
            localLifecycleState: try container.decodeIfPresent(
                PaperOrderLocalLifecycleState.self,
                forKey: .localLifecycleState
            ),
            riskDecisionStatus: try container.decode(
                PaperActionProposalRiskDecisionStatus.self,
                forKey: .riskDecisionStatus
            ),
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            fillCompletion: try container.decode(PaperSimulatedFillCompletion.self, forKey: .fillCompletion),
            filledQuantity: try container.decode(Quantity.self, forKey: .filledQuantity),
            remainingQuantity: try container.decode(Quantity.self, forKey: .remainingQuantity),
            fillPrice: try container.decode(Price.self, forKey: .fillPrice),
            fillPriceSource: try container.decode(PaperSimulatedFillPriceSource.self, forKey: .fillPriceSource),
            grossNotional: try container.decode(Double.self, forKey: .grossNotional),
            feeAssumptionID: try container.decode(Identifier.self, forKey: .feeAssumptionID),
            slippageAssumptionID: try container.decode(Identifier.self, forKey: .slippageAssumptionID),
            fillPriceAssumptionID: try container.decode(Identifier.self, forKey: .fillPriceAssumptionID),
            costImpactAmount: try container.decode(Double.self, forKey: .costImpactAmount),
            costEstimate: try container.decode(ExecutionCostEstimate.self, forKey: .costEstimate),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            proposalAuthorization: try container.decode(
                PaperActionProposalAuthorization.self,
                forKey: .proposalAuthorization
            ),
            workflowStage: try container.decode(PaperExecutionWorkflowStage.self, forKey: .workflowStage),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            evidenceKind: try container.decode(PaperExecutionWorkflowEvidenceKind.self, forKey: .evidenceKind),
            sourceOrderIntentSequence: try container.decode(Int.self, forKey: .sourceOrderIntentSequence),
            sourceRiskDecisionSequence: try container.decode(Int.self, forKey: .sourceRiskDecisionSequence),
            sourceLifecycleSequence: try container.decodeIfPresent(Int.self, forKey: .sourceLifecycleSequence),
            filledAt: try container.decode(Date.self, forKey: .filledAt),
            isSimulatedFillEvidence: try container.decode(Bool.self, forKey: .isSimulatedFillEvidence),
            authorizesTradingExecution: try container.decode(
                Bool.self,
                forKey: .authorizesTradingExecution
            ),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            touchesSignedEndpoint: try container.decode(Bool.self, forKey: .touchesSignedEndpoint),
            touchesBrokerAction: try container.decode(Bool.self, forKey: .touchesBrokerAction),
            representsRealOrder: try container.decode(Bool.self, forKey: .representsRealOrder),
            representsRealFill: try container.decode(Bool.self, forKey: .representsRealFill),
            representsBrokerFill: try container.decode(Bool.self, forKey: .representsBrokerFill),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            updatesRealAccountBalance: try container.decode(Bool.self, forKey: .updatesRealAccountBalance),
            orderIntentQuantity: try container.decode(Quantity.self, forKey: .orderIntentQuantity),
            orderIntentReferencePrice: try container.decode(Price.self, forKey: .orderIntentReferencePrice)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fillID, forKey: .fillID)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(proposalID, forKey: .proposalID)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(riskDecisionID, forKey: .riskDecisionID)
        try container.encode(riskProfileID, forKey: .riskProfileID)
        try container.encode(marketSnapshotID, forKey: .marketSnapshotID)
        try container.encode(orderLifecycleState, forKey: .orderLifecycleState)
        try container.encodeIfPresent(localLifecycleState, forKey: .localLifecycleState)
        try container.encode(riskDecisionStatus, forKey: .riskDecisionStatus)
        try container.encode(side, forKey: .side)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(fillCompletion, forKey: .fillCompletion)
        try container.encode(filledQuantity, forKey: .filledQuantity)
        try container.encode(remainingQuantity, forKey: .remainingQuantity)
        try container.encode(fillPrice, forKey: .fillPrice)
        try container.encode(fillPriceSource, forKey: .fillPriceSource)
        try container.encode(orderIntentQuantity, forKey: .orderIntentQuantity)
        try container.encode(orderIntentReferencePrice, forKey: .orderIntentReferencePrice)
        try container.encode(grossNotional, forKey: .grossNotional)
        try container.encode(feeAssumptionID, forKey: .feeAssumptionID)
        try container.encode(slippageAssumptionID, forKey: .slippageAssumptionID)
        try container.encode(fillPriceAssumptionID, forKey: .fillPriceAssumptionID)
        try container.encode(costImpactAmount, forKey: .costImpactAmount)
        try container.encode(costEstimate, forKey: .costEstimate)
        try container.encode(executionMode, forKey: .executionMode)
        try container.encode(proposalAuthorization, forKey: .proposalAuthorization)
        try container.encode(workflowStage, forKey: .workflowStage)
        try container.encode(eventStream, forKey: .eventStream)
        try container.encode(evidenceKind, forKey: .evidenceKind)
        try container.encode(sourceOrderIntentSequence, forKey: .sourceOrderIntentSequence)
        try container.encode(sourceRiskDecisionSequence, forKey: .sourceRiskDecisionSequence)
        try container.encodeIfPresent(sourceLifecycleSequence, forKey: .sourceLifecycleSequence)
        try container.encode(filledAt, forKey: .filledAt)
        try container.encode(isSimulatedFillEvidence, forKey: .isSimulatedFillEvidence)
        try container.encode(authorizesTradingExecution, forKey: .authorizesTradingExecution)
        try container.encode(authorizesLiveTrading, forKey: .authorizesLiveTrading)
        try container.encode(touchesSignedEndpoint, forKey: .touchesSignedEndpoint)
        try container.encode(touchesBrokerAction, forKey: .touchesBrokerAction)
        try container.encode(representsRealOrder, forKey: .representsRealOrder)
        try container.encode(representsRealFill, forKey: .representsRealFill)
        try container.encode(representsBrokerFill, forKey: .representsBrokerFill)
        try container.encode(consumesExecutionReport, forKey: .consumesExecutionReport)
        try container.encode(performsReconciliation, forKey: .performsReconciliation)
        try container.encode(updatesRealAccountBalance, forKey: .updatesRealAccountBalance)
    }

    private init(
        fillID: Identifier,
        orderID: Identifier,
        proposalID: Identifier,
        sessionID: Identifier,
        riskDecisionID: Identifier,
        riskProfileID: Identifier,
        marketSnapshotID: Identifier,
        orderLifecycleState: PaperOrderLifecycleState,
        localLifecycleState: PaperOrderLocalLifecycleState?,
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        side: PaperActionProposalSide,
        symbol: Symbol,
        timeframe: Timeframe,
        fillCompletion: PaperSimulatedFillCompletion,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        fillPrice: Price,
        fillPriceSource: PaperSimulatedFillPriceSource,
        grossNotional: Double,
        feeAssumptionID: Identifier,
        slippageAssumptionID: Identifier,
        fillPriceAssumptionID: Identifier,
        costImpactAmount: Double,
        costEstimate: ExecutionCostEstimate,
        executionMode: ExecutionMode,
        proposalAuthorization: PaperActionProposalAuthorization,
        workflowStage: PaperExecutionWorkflowStage,
        eventStream: EventStreamID,
        evidenceKind: PaperExecutionWorkflowEvidenceKind,
        sourceOrderIntentSequence: Int,
        sourceRiskDecisionSequence: Int,
        sourceLifecycleSequence: Int?,
        filledAt: Date,
        isSimulatedFillEvidence: Bool,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsRealFill: Bool,
        representsBrokerFill: Bool,
        consumesExecutionReport: Bool,
        performsReconciliation: Bool,
        updatesRealAccountBalance: Bool,
        orderIntentQuantity: Quantity,
        orderIntentReferencePrice: Price
    ) throws {
        guard orderLifecycleState == .intentCreated else {
            throw CoreError.paperSimulatedFillRequiresOrderIntentCreated(orderLifecycleState.rawValue)
        }
        guard riskDecisionStatus == .allowed else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "riskDecisionStatus",
                expected: PaperActionProposalRiskDecisionStatus.allowed.rawValue,
                actual: riskDecisionStatus.rawValue
            )
        }
        guard executionMode == .paper else {
            throw CoreError.paperSimulatedFillRequiresPaperMode(executionMode)
        }
        guard proposalAuthorization == .paperIntentOnly else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "proposalAuthorization",
                expected: PaperActionProposalAuthorization.paperIntentOnly.rawValue,
                actual: "\(proposalAuthorization)"
            )
        }
        guard workflowStage == .simulatedFill else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "workflowStage",
                expected: PaperExecutionWorkflowStage.simulatedFill.rawValue,
                actual: workflowStage.rawValue
            )
        }
        guard eventStream == .paper else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        guard evidenceKind == .simulatedFill else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "evidenceKind",
                expected: PaperExecutionWorkflowEvidenceKind.simulatedFill.rawValue,
                actual: evidenceKind.rawValue
            )
        }
        guard sourceOrderIntentSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceOrderIntentSequence)
        }
        guard sourceRiskDecisionSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceRiskDecisionSequence)
        }
        if let sourceLifecycleSequence, sourceLifecycleSequence <= 0 {
            throw CoreError.invalidEventSequence(sourceLifecycleSequence)
        }
        try Self.validateFillAssumption(
            fillCompletion: fillCompletion,
            filledQuantity: filledQuantity,
            remainingQuantity: remainingQuantity,
            fillPrice: fillPrice,
            orderIntentQuantity: orderIntentQuantity,
            orderIntentReferencePrice: orderIntentReferencePrice
        )
        try Self.validateCostEvidence(
            symbol: symbol,
            timeframe: timeframe,
            filledQuantity: filledQuantity,
            fillPrice: fillPrice,
            grossNotional: grossNotional,
            feeAssumptionID: feeAssumptionID,
            slippageAssumptionID: slippageAssumptionID,
            costImpactAmount: costImpactAmount,
            costEstimate: costEstimate
        )
        try Self.validateForbiddenCapabilities(
            isSimulatedFillEvidence: isSimulatedFillEvidence,
            authorizesTradingExecution: authorizesTradingExecution,
            authorizesLiveTrading: authorizesLiveTrading,
            touchesSignedEndpoint: touchesSignedEndpoint,
            touchesBrokerAction: touchesBrokerAction,
            representsRealOrder: representsRealOrder,
            representsRealFill: representsRealFill,
            representsBrokerFill: representsBrokerFill,
            consumesExecutionReport: consumesExecutionReport,
            performsReconciliation: performsReconciliation,
            updatesRealAccountBalance: updatesRealAccountBalance
        )

        self.fillID = fillID
        self.orderID = orderID
        self.proposalID = proposalID
        self.sessionID = sessionID
        self.riskDecisionID = riskDecisionID
        self.riskProfileID = riskProfileID
        self.marketSnapshotID = marketSnapshotID
        self.orderLifecycleState = orderLifecycleState
        self.localLifecycleState = localLifecycleState
        self.riskDecisionStatus = riskDecisionStatus
        self.side = side
        self.symbol = symbol
        self.timeframe = timeframe
        self.fillCompletion = fillCompletion
        self.filledQuantity = filledQuantity
        self.remainingQuantity = remainingQuantity
        self.fillPrice = fillPrice
        self.fillPriceSource = fillPriceSource
        self.orderIntentQuantity = orderIntentQuantity
        self.orderIntentReferencePrice = orderIntentReferencePrice
        self.grossNotional = grossNotional
        self.feeAssumptionID = feeAssumptionID
        self.slippageAssumptionID = slippageAssumptionID
        self.fillPriceAssumptionID = fillPriceAssumptionID
        self.costImpactAmount = costImpactAmount
        self.costEstimate = costEstimate
        self.executionMode = executionMode
        self.proposalAuthorization = proposalAuthorization
        self.workflowStage = workflowStage
        self.eventStream = eventStream
        self.evidenceKind = evidenceKind
        self.sourceOrderIntentSequence = sourceOrderIntentSequence
        self.sourceRiskDecisionSequence = sourceRiskDecisionSequence
        self.sourceLifecycleSequence = sourceLifecycleSequence
        self.filledAt = filledAt
        self.isSimulatedFillEvidence = isSimulatedFillEvidence
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesBrokerAction = touchesBrokerAction
        self.representsRealOrder = representsRealOrder
        self.representsRealFill = representsRealFill
        self.representsBrokerFill = representsBrokerFill
        self.consumesExecutionReport = consumesExecutionReport
        self.performsReconciliation = performsReconciliation
        self.updatesRealAccountBalance = updatesRealAccountBalance
    }

    private func validateModelInputs(
        orderIntent: PaperOrderIntent,
        lifecyclePrecondition: PaperOrderSimulatedFillPrecondition?,
        marketSnapshot: PaperSimulatedFillMarketSnapshot
    ) throws {
        guard orderID == orderIntent.orderID else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "orderID",
                expected: orderIntent.orderID.rawValue,
                actual: orderID.rawValue
            )
        }
        guard marketSnapshot.paperOnlyBoundaryHeld else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "marketSnapshot.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        try Self.validateField("marketSnapshot.symbol", expected: orderIntent.symbol.rawValue, actual: marketSnapshot.symbol.rawValue)
        try Self.validateField(
            "marketSnapshot.timeframe",
            expected: orderIntent.timeframe.rawValue,
            actual: marketSnapshot.timeframe.rawValue
        )
        if let lifecyclePrecondition {
            guard lifecyclePrecondition.ready else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "lifecyclePrecondition.ready",
                    expected: "true",
                    actual: "false"
                )
            }
            guard lifecyclePrecondition.orderID == orderIntent.orderID else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "lifecyclePrecondition.orderID",
                    expected: orderIntent.orderID.rawValue,
                    actual: lifecyclePrecondition.orderID.rawValue
                )
            }
        }
    }

    private static func validateFillAssumption(
        fillCompletion: PaperSimulatedFillCompletion,
        filledQuantity: Quantity,
        remainingQuantity: Quantity,
        fillPrice: Price,
        orderIntentQuantity: Quantity,
        orderIntentReferencePrice: Price
    ) throws {
        guard filledQuantity.rawValue <= orderIntentQuantity.rawValue else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "filledQuantity",
                expected: "<= \(orderIntentQuantity.rawValue)",
                actual: "\(filledQuantity.rawValue)"
            )
        }
        switch fillCompletion {
        case .full:
            guard filledQuantity.rawValue == orderIntentQuantity.rawValue else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "filledQuantity",
                    expected: "\(orderIntentQuantity.rawValue)",
                    actual: "\(filledQuantity.rawValue)"
                )
            }
            guard remainingQuantity.rawValue == 0 else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "remainingQuantity",
                    expected: "0.0",
                    actual: "\(remainingQuantity.rawValue)"
                )
            }
        case .partial:
            guard filledQuantity.rawValue < orderIntentQuantity.rawValue else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "partialFill.filledQuantity",
                    expected: "< \(orderIntentQuantity.rawValue)",
                    actual: "\(filledQuantity.rawValue)"
                )
            }
            guard remainingQuantity.rawValue > 0 else {
                throw CoreError.paperSimulatedFillMismatch(
                    field: "partialFill.remainingQuantity",
                    expected: "> 0",
                    actual: "\(remainingQuantity.rawValue)"
                )
            }
        }
        let expectedRemaining = orderIntentQuantity.rawValue - filledQuantity.rawValue
        guard remainingQuantity.rawValue == expectedRemaining else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "remainingQuantity",
                expected: "\(expectedRemaining)",
                actual: "\(remainingQuantity.rawValue)"
            )
        }
        guard fillPrice.rawValue > 0 else {
            throw CoreError.invalidPrice("paperSimulatedFill.fillPrice", fillPrice.rawValue)
        }
        guard orderIntentReferencePrice.rawValue > 0 else {
            throw CoreError.invalidPrice("paperSimulatedFill.orderIntentReferencePrice", orderIntentReferencePrice.rawValue)
        }
    }

    private static func validateCostEvidence(
        symbol: Symbol,
        timeframe: Timeframe,
        filledQuantity: Quantity,
        fillPrice: Price,
        grossNotional: Double,
        feeAssumptionID: Identifier,
        slippageAssumptionID: Identifier,
        costImpactAmount: Double,
        costEstimate: ExecutionCostEstimate
    ) throws {
        guard costEstimate.executionMode == .paper else {
            throw CoreError.paperSimulatedFillRequiresPaperMode(costEstimate.executionMode)
        }
        try validateField("symbol", expected: symbol.rawValue, actual: costEstimate.symbol.rawValue)
        try validateField("timeframe", expected: timeframe.rawValue, actual: costEstimate.timeframe.rawValue)
        try validateField("filledQuantity", expected: filledQuantity.rawValue, actual: costEstimate.quantity.rawValue)
        try validateField("fillPrice", expected: fillPrice.rawValue, actual: costEstimate.referencePrice.rawValue)
        try validateField("grossNotional", expected: grossNotional, actual: costEstimate.grossNotional)
        try validateField(
            "grossNotionalFormula",
            expected: filledQuantity.rawValue * fillPrice.rawValue,
            actual: grossNotional
        )
        try validateField(
            "feeAssumptionID",
            expected: costEstimate.assumptionID.rawValue,
            actual: feeAssumptionID.rawValue
        )
        try validateField(
            "slippageAssumptionID",
            expected: costEstimate.assumptionID.rawValue,
            actual: slippageAssumptionID.rawValue
        )
        try validateField("costImpactAmount", expected: costEstimate.totalCostAmount, actual: costImpactAmount)
    }

    private static func validateForbiddenCapabilities(
        isSimulatedFillEvidence: Bool,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsRealFill: Bool,
        representsBrokerFill: Bool,
        consumesExecutionReport: Bool,
        performsReconciliation: Bool,
        updatesRealAccountBalance: Bool
    ) throws {
        guard isSimulatedFillEvidence else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "isSimulatedFillEvidence",
                expected: "true",
                actual: "false"
            )
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("touchesSignedEndpoint", touchesSignedEndpoint),
            ("touchesBrokerAction", touchesBrokerAction),
            ("representsRealOrder", representsRealOrder),
            ("representsRealFill", representsRealFill),
            ("representsBrokerFill", representsBrokerFill),
            ("consumesExecutionReport", consumesExecutionReport),
            ("performsReconciliation", performsReconciliation),
            ("updatesRealAccountBalance", updatesRealAccountBalance)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperSimulatedFillForbiddenCapability(forbidden.0)
        }
    }

    private static func validateField(_ field: String, expected: String, actual: String) throws {
        guard expected == actual else {
            throw CoreError.paperSimulatedFillMismatch(field: field, expected: expected, actual: actual)
        }
    }

    private static func validateField(_ field: String, expected: Double, actual: Double) throws {
        guard expected == actual else {
            throw CoreError.paperSimulatedFillMismatch(
                field: field,
                expected: "\(expected)",
                actual: "\(actual)"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case fillID
        case orderID
        case proposalID
        case sessionID
        case riskDecisionID
        case riskProfileID
        case marketSnapshotID
        case orderLifecycleState
        case localLifecycleState
        case riskDecisionStatus
        case side
        case symbol
        case timeframe
        case fillCompletion
        case filledQuantity
        case remainingQuantity
        case fillPrice
        case fillPriceSource
        case grossNotional
        case feeAssumptionID
        case slippageAssumptionID
        case fillPriceAssumptionID
        case costImpactAmount
        case costEstimate
        case executionMode
        case proposalAuthorization
        case workflowStage
        case eventStream
        case evidenceKind
        case sourceOrderIntentSequence
        case sourceRiskDecisionSequence
        case sourceLifecycleSequence
        case filledAt
        case isSimulatedFillEvidence
        case authorizesTradingExecution
        case authorizesLiveTrading
        case touchesSignedEndpoint
        case touchesBrokerAction
        case representsRealOrder
        case representsRealFill
        case representsBrokerFill
        case consumesExecutionReport
        case performsReconciliation
        case updatesRealAccountBalance
        case orderIntentQuantity
        case orderIntentReferencePrice
    }
}

/// PaperSimulatedFillPublication 保存 simulated fill facts 写入 Event Log 后的证据。
///
/// route evidence 和 replay evidence 必须完全一致，才能证明 partial / full fill 不是内存态假象，
/// 而是已经进入 append-only `.paper` facts source，可被后续 MTP-101 projection 消费。
public struct PaperSimulatedFillPublication: Codable, Equatable, Sendable {
    public let fills: [PaperSimulatedFillEvidence]
    public let routeEvidence: [PaperRuntimeRouteEvidence]
    public let replayEvidence: [PaperRuntimeRouteEvidence]
    public let replayedFills: [PaperSimulatedFillEvidence]

    public var replayMatchesRouteEvidence: Bool {
        replayEvidence == routeEvidence
    }

    public var coversPartialAndFullFills: Bool {
        Set(fills.map(\.fillCompletion)) == Set([.partial, .full])
            && replayedFills == fills
    }

    public init(
        fills: [PaperSimulatedFillEvidence],
        routeEvidence: [PaperRuntimeRouteEvidence],
        replayEvidence: [PaperRuntimeRouteEvidence],
        replayedFills: [PaperSimulatedFillEvidence]
    ) throws {
        guard fills.isEmpty == false else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "fills",
                expected: "at least one simulated fill",
                actual: "empty"
            )
        }
        guard fills.allSatisfy(\.paperOnlyBoundaryHeld) else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "fills.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard routeEvidence.count == fills.count else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "routeEvidence.count",
                expected: "\(fills.count)",
                actual: "\(routeEvidence.count)"
            )
        }
        guard replayEvidence == routeEvidence else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "replayEvidence",
                expected: "same as route evidence",
                actual: "drift"
            )
        }
        guard replayedFills == fills else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "replayedFills",
                expected: fills.map(\.fillID.rawValue).joined(separator: ","),
                actual: replayedFills.map(\.fillID.rawValue).joined(separator: ",")
            )
        }
        guard routeEvidence.allSatisfy({
            $0.source == .simulatedFillEvent
                && $0.payloadKind == .simulatedFillRecorded
                && $0.stream == .paper
        }) else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "routeEvidence",
                expected: "simulatedFillEvent/simulatedFillRecorded/.paper",
                actual: routeEvidence.map(\.payloadKind.rawValue).joined(separator: ",")
            )
        }

        self.fills = fills
        self.routeEvidence = routeEvidence
        self.replayEvidence = replayEvidence
        self.replayedFills = replayedFills
    }
}

/// PaperSimulatedFillEventLogBoundary 把 simulated fill evidence 写入 append-only MessageBus。
///
/// 该边界只复用 MTP-97 的 routing，不启动 Runtime actor，不新建 broker-like bus，不消费 execution
/// report，也不做 portfolio projection；MTP-101 只能从 replay 后的 fill evidence 推导账户和持仓。
public struct PaperSimulatedFillEventLogBoundary: Equatable, Sendable {
    public let routing: PaperRuntimeMessageBusRouting

    public init(routing: PaperRuntimeMessageBusRouting = PaperRuntimeMessageBusRouting()) {
        self.routing = routing
    }

    @discardableResult
    public func publish(
        _ fills: [PaperSimulatedFillEvidence],
        to messageBus: inout MessageBus,
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> PaperSimulatedFillPublication {
        let firstNewSequence = messageBus.envelopes.count + 1
        let inputs = fills.map(PaperRuntimeRouteInput.simulatedFillEvent)
        let routeEvidence = try routing.publish(
            inputs,
            to: &messageBus,
            clock: clock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: firstNewSequence, upperBound: messageBus.envelopes.count),
                streams: [.paper]
            )
        )
        let replayEvidence = try PaperRuntimeMessageBusRouting.replayEvidence(from: replay)
        let replayedFills = try PaperSimulatedFillReplayPath.simulatedFills(from: replay)
        return try PaperSimulatedFillPublication(
            fills: fills,
            routeEvidence: routeEvidence,
            replayEvidence: replayEvidence,
            replayedFills: replayedFills
        )
    }
}

/// PaperSimulatedFillReplayPath 从 replay result 提取 simulated fill facts。
///
/// replay 输入必须保持 append-only sequence 升序唯一；输出只包含 `.paper.simulatedFillRecorded`
/// facts，供 MTP-100 测试和后续 MTP-101 projection 作为稳定输入。
public enum PaperSimulatedFillReplayPath {
    public static func simulatedFills(from replay: EventReplayResult) throws -> [PaperSimulatedFillEvidence] {
        try validateReplayOrder(replay.envelopes)
        return replay.envelopes.compactMap { envelope in
            if case let .paper(.simulatedFillRecorded(fill)) = envelope.event {
                return fill
            }
            return nil
        }
    }

    private static func validateReplayOrder(_ envelopes: [EventEnvelope]) throws {
        let sequences = envelopes.map(\.sequence)
        let sortedUnique = Array(Set(sequences)).sorted()
        guard sequences == sortedUnique else {
            throw CoreError.invalidSequenceRange
        }
    }
}

/// PaperSimulatedFillFixture 生成 deterministic simulated fill / fee / slippage evidence。
///
/// Fixture 覆盖旧 full-fill evidence、MTP-100 accepted-local precondition full fill、partial fill 和
/// Event Log / Replay publication。它只用于 XCTest 和 PR evidence；不是真实成交编号、broker fill、
/// 撮合结果、execution report、reconciliation 或 account update。
public enum PaperSimulatedFillFixture {
    public static let validationAnchors: [String] = [
        "TVM-PAPER-RUNTIME-KERNEL",
        "MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT",
        "MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE",
        "MTP-100-FEE-SLIPPAGE-COST-IMPACT",
        "MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY",
        "MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION",
        "MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION"
    ]
    public static let correlationID = deterministicUUID("11111111-1111-4111-8111-111111111100")
    public static let rootCausationID = deterministicUUID("22222222-2222-4222-8222-222222222100")
    public static let envelopeIDs: [UUID] = [
        deterministicUUID("10000000-0000-4000-8000-000000000001"),
        deterministicUUID("10000000-0000-4000-8000-000000000002")
    ]

    public static let deterministicClock: TradingClock = {
        do {
            return try TradingClock(
                clockID: try Identifier("mtp-100-simulated-fill-clock"),
                issueID: try Identifier("MTP-100"),
                ticks: [
                    TradingClockTick(
                        sequence: 1,
                        instant: Date(timeIntervalSince1970: 6_020),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 6_021),
                        source: .deterministicFixture
                    )
                ],
                validationAnchors: [
                    "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
                    "MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION"
                ]
            )
        } catch {
            preconditionFailure("Invalid MTP-100 simulated fill clock fixture: \(error)")
        }
    }()

    public static func deterministicAllowed() throws -> PaperSimulatedFillEvidence {
        try PaperSimulatedFillEvidence(
            fillID: try Identifier("paper-simulated-fill-allowed"),
            orderIntent: PaperOrderIntentFixture.deterministicAllowed(),
            assumption: .deterministicFixture,
            sourceOrderIntentSequence: 9,
            filledAt: Date(timeIntervalSince1970: 2_700)
        )
    }

    public static func lifecycleOrderIntent() throws -> PaperOrderIntent {
        try PaperOrderIntent(
            orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
            riskDecision: PaperPreTradeRiskEngineFixture.acceptedDecision().riskDecision,
            createdAt: Date(timeIntervalSince1970: 6_010)
        )
    }

    public static func lifecyclePrecondition() throws -> PaperOrderSimulatedFillPrecondition {
        try PaperOrderLocalLifecycleCoordinator().simulatedFillPrecondition(
            from: PaperOrderLocalLifecycleCoordinatorFixture.acceptedTrace(),
            sourceLifecycleSequence: 3
        )
    }

    public static func deterministicFullFromLifecycle() throws -> PaperSimulatedFillEvidence {
        try PaperSimulatedFillEvidence(
            fillID: try Identifier("mtp-100-full-simulated-fill"),
            orderIntent: lifecycleOrderIntent(),
            lifecyclePrecondition: lifecyclePrecondition(),
            marketSnapshot: .deterministicFixture,
            assumption: .deterministicFixture,
            sourceOrderIntentSequence: 4,
            filledAt: Date(timeIntervalSince1970: 6_020)
        )
    }

    public static func deterministicPartialFromLifecycle() throws -> PaperSimulatedFillEvidence {
        try PaperSimulatedFillEvidence(
            fillID: try Identifier("mtp-100-partial-simulated-fill"),
            orderIntent: lifecycleOrderIntent(),
            lifecyclePrecondition: lifecyclePrecondition(),
            marketSnapshot: .deterministicFixture,
            assumption: .deterministicPartialFixture,
            sourceOrderIntentSequence: 4,
            filledAt: Date(timeIntervalSince1970: 6_021)
        )
    }

    public static func publishedPartialAndFullFills() throws -> (MessageBus, PaperSimulatedFillPublication) {
        var messageBus = try MessageBus()
        let publication = try PaperSimulatedFillEventLogBoundary().publish(
            [try deterministicFullFromLifecycle(), try deterministicPartialFromLifecycle()],
            to: &messageBus,
            clock: deterministicClock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        return (messageBus, publication)
    }

    private static func deterministicUUID(_ rawValue: String) -> UUID {
        guard let uuid = UUID(uuidString: rawValue) else {
            preconditionFailure("Invalid deterministic UUID: \(rawValue)")
        }
        return uuid
    }
}
