import Foundation

/// Paper simulated fill evidence 是 MTP-40 的本地模拟成交证据模型。
///
/// 该文件只把 MTP-39 的 allowed `PaperOrderIntent` 转成可测试的 simulated fill evidence，
/// 并复用 MTP-27 的固定 fee / slippage 假设。它不写 event log、不更新 portfolio projection、
/// 不执行撮合、不读取真实成交回报、不连接 broker、不调用 signed endpoint，也不代表真实账户更新。

/// PaperSimulatedFillAssumption 保存 deterministic 模拟成交假设。
///
/// `filledQuantity` 和 `fillPrice` 必须与上游 paper order intent 完全一致，避免在本 issue
/// 引入部分成交、价格改善、动态滑点或执行成本优化语义；fee / slippage 只由既有
/// `ExecutionCostAssumptions` 固定计算。
public struct PaperSimulatedFillAssumption: Codable, Equatable, Sendable {
    public let assumptionID: Identifier
    public let filledQuantity: Quantity
    public let fillPrice: Price
    public let liquidityRole: ExecutionCostLiquidityRole
    public let executionCostAssumptions: ExecutionCostAssumptions

    public init(
        assumptionID: Identifier,
        filledQuantity: Quantity,
        fillPrice: Price,
        liquidityRole: ExecutionCostLiquidityRole,
        executionCostAssumptions: ExecutionCostAssumptions = .deterministicFixture
    ) throws {
        guard filledQuantity.rawValue > 0 else {
            throw CoreError.invalidPaperSimulatedFillQuantity(filledQuantity.rawValue)
        }

        self.assumptionID = assumptionID
        self.filledQuantity = filledQuantity
        self.fillPrice = fillPrice
        self.liquidityRole = liquidityRole
        self.executionCostAssumptions = executionCostAssumptions
    }

    /// MTP-40 deterministic fixture 固定为全量本地模拟成交，不代表真实撮合价格或成交回报。
    public static let deterministicFixture: PaperSimulatedFillAssumption = {
        do {
            return try PaperSimulatedFillAssumption(
                assumptionID: try Identifier("mtp-40-simulated-fill-assumption"),
                filledQuantity: try Quantity(0.5, field: "paperSimulatedFill.filledQuantity"),
                fillPrice: try Price(100, field: "paperSimulatedFill.fillPrice"),
                liquidityRole: .maker,
                executionCostAssumptions: .deterministicFixture
            )
        } catch {
            preconditionFailure("Invalid deterministic simulated fill fixture: \(error)")
        }
    }()
}

/// PaperSimulatedFillEvidence 记录 paper-only simulated fill 的最小可追溯快照。
///
/// 输入只能是 `intentCreated` 的本地 paper order intent；输出只表达本地模拟成交 evidence、
/// fixed cost evidence 和 workflow stage。所有真实交易能力、真实 fill、broker fill、
/// account update 和 Live fallback 旗标都必须保持关闭，Codable 解码也会拒绝绕过。
public struct PaperSimulatedFillEvidence: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let orderID: Identifier
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let riskDecisionID: Identifier
    public let riskProfileID: Identifier
    public let orderLifecycleState: PaperOrderLifecycleState
    public let riskDecisionStatus: PaperActionProposalRiskDecisionStatus
    public let side: PaperActionProposalSide
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let filledQuantity: Quantity
    public let fillPrice: Price
    public let orderIntentQuantity: Quantity
    public let orderIntentReferencePrice: Price
    public let grossNotional: Double
    public let costEstimate: ExecutionCostEstimate
    public let executionMode: ExecutionMode
    public let proposalAuthorization: PaperActionProposalAuthorization
    public let workflowStage: PaperExecutionWorkflowStage
    public let eventStream: EventStreamID
    public let evidenceKind: PaperExecutionWorkflowEvidenceKind
    public let sourceOrderIntentSequence: Int
    public let sourceRiskDecisionSequence: Int
    public let filledAt: Date
    public let isSimulatedFillEvidence: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesBrokerAction: Bool
    public let representsRealOrder: Bool
    public let representsRealFill: Bool
    public let representsBrokerFill: Bool
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
            orderLifecycleState: orderIntent.lifecycleState,
            riskDecisionStatus: orderIntent.riskDecisionStatus,
            side: orderIntent.side,
            symbol: orderIntent.symbol,
            timeframe: orderIntent.timeframe,
            filledQuantity: assumption.filledQuantity,
            fillPrice: assumption.fillPrice,
            grossNotional: costEstimate.grossNotional,
            costEstimate: costEstimate,
            executionMode: orderIntent.executionMode,
            proposalAuthorization: orderIntent.proposalAuthorization,
            workflowStage: .simulatedFill,
            eventStream: .paper,
            evidenceKind: .simulatedFill,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            sourceRiskDecisionSequence: orderIntent.sourceRiskDecisionSequence,
            filledAt: filledAt,
            isSimulatedFillEvidence: true,
            authorizesTradingExecution: false,
            authorizesLiveTrading: false,
            touchesSignedEndpoint: false,
            touchesBrokerAction: false,
            representsRealOrder: false,
            representsRealFill: false,
            representsBrokerFill: false,
            updatesRealAccountBalance: false,
            orderIntentQuantity: orderIntent.quantity,
            orderIntentReferencePrice: orderIntent.referencePrice
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
            orderLifecycleState: try container.decode(PaperOrderLifecycleState.self, forKey: .orderLifecycleState),
            riskDecisionStatus: try container.decode(
                PaperActionProposalRiskDecisionStatus.self,
                forKey: .riskDecisionStatus
            ),
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            filledQuantity: try container.decode(Quantity.self, forKey: .filledQuantity),
            fillPrice: try container.decode(Price.self, forKey: .fillPrice),
            grossNotional: try container.decode(Double.self, forKey: .grossNotional),
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
        try container.encode(orderLifecycleState, forKey: .orderLifecycleState)
        try container.encode(riskDecisionStatus, forKey: .riskDecisionStatus)
        try container.encode(side, forKey: .side)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(filledQuantity, forKey: .filledQuantity)
        try container.encode(fillPrice, forKey: .fillPrice)
        try container.encode(orderIntentQuantity, forKey: .orderIntentQuantity)
        try container.encode(orderIntentReferencePrice, forKey: .orderIntentReferencePrice)
        try container.encode(grossNotional, forKey: .grossNotional)
        try container.encode(costEstimate, forKey: .costEstimate)
        try container.encode(executionMode, forKey: .executionMode)
        try container.encode(proposalAuthorization, forKey: .proposalAuthorization)
        try container.encode(workflowStage, forKey: .workflowStage)
        try container.encode(eventStream, forKey: .eventStream)
        try container.encode(evidenceKind, forKey: .evidenceKind)
        try container.encode(sourceOrderIntentSequence, forKey: .sourceOrderIntentSequence)
        try container.encode(sourceRiskDecisionSequence, forKey: .sourceRiskDecisionSequence)
        try container.encode(filledAt, forKey: .filledAt)
        try container.encode(isSimulatedFillEvidence, forKey: .isSimulatedFillEvidence)
        try container.encode(authorizesTradingExecution, forKey: .authorizesTradingExecution)
        try container.encode(authorizesLiveTrading, forKey: .authorizesLiveTrading)
        try container.encode(touchesSignedEndpoint, forKey: .touchesSignedEndpoint)
        try container.encode(touchesBrokerAction, forKey: .touchesBrokerAction)
        try container.encode(representsRealOrder, forKey: .representsRealOrder)
        try container.encode(representsRealFill, forKey: .representsRealFill)
        try container.encode(representsBrokerFill, forKey: .representsBrokerFill)
        try container.encode(updatesRealAccountBalance, forKey: .updatesRealAccountBalance)
    }

    private init(
        fillID: Identifier,
        orderID: Identifier,
        proposalID: Identifier,
        sessionID: Identifier,
        riskDecisionID: Identifier,
        riskProfileID: Identifier,
        orderLifecycleState: PaperOrderLifecycleState,
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        side: PaperActionProposalSide,
        symbol: Symbol,
        timeframe: Timeframe,
        filledQuantity: Quantity,
        fillPrice: Price,
        grossNotional: Double,
        costEstimate: ExecutionCostEstimate,
        executionMode: ExecutionMode,
        proposalAuthorization: PaperActionProposalAuthorization,
        workflowStage: PaperExecutionWorkflowStage,
        eventStream: EventStreamID,
        evidenceKind: PaperExecutionWorkflowEvidenceKind,
        sourceOrderIntentSequence: Int,
        sourceRiskDecisionSequence: Int,
        filledAt: Date,
        isSimulatedFillEvidence: Bool,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsRealFill: Bool,
        representsBrokerFill: Bool,
        updatesRealAccountBalance: Bool,
        orderIntentQuantity: Quantity,
        orderIntentReferencePrice: Price
    ) throws {
        guard orderLifecycleState == .intentCreated else {
            throw CoreError.paperSimulatedFillRequiresOrderIntentCreated(orderLifecycleState)
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
        try Self.validateFillAssumption(
            filledQuantity: filledQuantity,
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
            updatesRealAccountBalance: updatesRealAccountBalance
        )

        self.fillID = fillID
        self.orderID = orderID
        self.proposalID = proposalID
        self.sessionID = sessionID
        self.riskDecisionID = riskDecisionID
        self.riskProfileID = riskProfileID
        self.orderLifecycleState = orderLifecycleState
        self.riskDecisionStatus = riskDecisionStatus
        self.side = side
        self.symbol = symbol
        self.timeframe = timeframe
        self.filledQuantity = filledQuantity
        self.fillPrice = fillPrice
        self.orderIntentQuantity = orderIntentQuantity
        self.orderIntentReferencePrice = orderIntentReferencePrice
        self.grossNotional = grossNotional
        self.costEstimate = costEstimate
        self.executionMode = executionMode
        self.proposalAuthorization = proposalAuthorization
        self.workflowStage = workflowStage
        self.eventStream = eventStream
        self.evidenceKind = evidenceKind
        self.sourceOrderIntentSequence = sourceOrderIntentSequence
        self.sourceRiskDecisionSequence = sourceRiskDecisionSequence
        self.filledAt = filledAt
        self.isSimulatedFillEvidence = isSimulatedFillEvidence
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesBrokerAction = touchesBrokerAction
        self.representsRealOrder = representsRealOrder
        self.representsRealFill = representsRealFill
        self.representsBrokerFill = representsBrokerFill
        self.updatesRealAccountBalance = updatesRealAccountBalance
    }

    private static func validateFillAssumption(
        filledQuantity: Quantity,
        fillPrice: Price,
        orderIntentQuantity: Quantity,
        orderIntentReferencePrice: Price
    ) throws {
        guard filledQuantity.rawValue == orderIntentQuantity.rawValue else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "filledQuantity",
                expected: "\(orderIntentQuantity.rawValue)",
                actual: "\(filledQuantity.rawValue)"
            )
        }
        guard fillPrice.rawValue == orderIntentReferencePrice.rawValue else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "fillPrice",
                expected: "\(orderIntentReferencePrice.rawValue)",
                actual: "\(fillPrice.rawValue)"
            )
        }
    }

    private static func validateCostEvidence(
        symbol: Symbol,
        timeframe: Timeframe,
        filledQuantity: Quantity,
        fillPrice: Price,
        grossNotional: Double,
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
        updatesRealAccountBalance: Bool
    ) throws {
        guard isSimulatedFillEvidence else {
            throw CoreError.paperSimulatedFillMismatch(
                field: "isSimulatedFillEvidence",
                expected: "true",
                actual: "false"
            )
        }
        guard authorizesTradingExecution == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("authorizesTradingExecution")
        }
        guard authorizesLiveTrading == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("authorizesLiveTrading")
        }
        guard touchesSignedEndpoint == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("touchesSignedEndpoint")
        }
        guard touchesBrokerAction == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("touchesBrokerAction")
        }
        guard representsRealOrder == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("representsRealOrder")
        }
        guard representsRealFill == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("representsRealFill")
        }
        guard representsBrokerFill == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("representsBrokerFill")
        }
        guard updatesRealAccountBalance == false else {
            throw CoreError.paperSimulatedFillForbiddenCapability("updatesRealAccountBalance")
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
        case orderLifecycleState
        case riskDecisionStatus
        case side
        case symbol
        case timeframe
        case filledQuantity
        case fillPrice
        case grossNotional
        case costEstimate
        case executionMode
        case proposalAuthorization
        case workflowStage
        case eventStream
        case evidenceKind
        case sourceOrderIntentSequence
        case sourceRiskDecisionSequence
        case filledAt
        case isSimulatedFillEvidence
        case authorizesTradingExecution
        case authorizesLiveTrading
        case touchesSignedEndpoint
        case touchesBrokerAction
        case representsRealOrder
        case representsRealFill
        case representsBrokerFill
        case updatesRealAccountBalance
        case orderIntentQuantity
        case orderIntentReferencePrice
    }
}

/// PaperSimulatedFillFixture 生成 MTP-40 deterministic simulated fill evidence。
///
/// Fixture 固定 fill ID、上游 allowed order intent、成交假设、source sequence 和 timestamp，
/// 只用于 XCTest 和 PR evidence；它不是真实成交编号、broker fill、撮合结果或 account update。
public enum PaperSimulatedFillFixture {
    public static func deterministicAllowed() throws -> PaperSimulatedFillEvidence {
        try PaperSimulatedFillEvidence(
            fillID: try Identifier("paper-simulated-fill-allowed"),
            orderIntent: PaperOrderIntentFixture.deterministicAllowed(),
            assumption: .deterministicFixture,
            sourceOrderIntentSequence: 9,
            filledAt: Date(timeIntervalSince1970: 2_700)
        )
    }
}
