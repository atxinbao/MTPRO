import Foundation

/// Paper order intent / lifecycle 是 MTP-39 的本地 paper-only 订单意图模型。
///
/// 输入只能来自 MTP-33 的 `PaperActionProposalRiskDecision`；输出只记录 proposal、
/// risk result、paper-only 授权和本地 lifecycle state。该模型不是 OMS、订单路由、
/// 模拟成交器或 broker adapter，不提交、取消、替换真实订单，也不调用 signed endpoint、
/// account endpoint、外部执行场所或 Live execution。

/// PaperOrderLifecycleState 表达本地 paper order intent 的最小生命周期状态。
///
/// `intentCreated` 只表示 allowed risk decision 已被记录为本地 paper order intent；
/// `rejectedByRisk` 只表示 blocked risk decision 被保留为本地拒绝证据。两个状态都不是
/// 真实交易所订单状态，也不会触发 simulated fill、cancel / replace 或 broker action。
public enum PaperOrderLifecycleState: String, Codable, CaseIterable, Equatable, Sendable {
    case intentCreated
    case rejectedByRisk

    public init(riskDecisionStatus: PaperActionProposalRiskDecisionStatus) {
        switch riskDecisionStatus {
        case .allowed:
            self = .intentCreated
        case .blocked:
            self = .rejectedByRisk
        }
    }
}

/// PaperOrderIntent 是 proposal / risk result 派生的 paper-only 订单意图快照。
///
/// 字段保留 order、proposal、risk decision、symbol / timeframe、side、quantity、notional
/// 和 source sequence，供后续 issue 在同一 workflow boundary 内消费。所有能力旗标固定为
/// `false`，Codable 解码会拒绝任何试图恢复真实订单、broker action、signed endpoint、
/// simulated fill 或 Live trading 的 payload。
public struct PaperOrderIntent: Codable, Equatable, Sendable {
    public let orderID: Identifier
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let riskDecisionID: Identifier
    public let riskDecisionStatus: PaperActionProposalRiskDecisionStatus
    public let blockerEvidenceID: Identifier?
    public let lifecycleState: PaperOrderLifecycleState
    public let riskProfileID: Identifier
    public let side: PaperActionProposalSide
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let quantity: Quantity
    public let referencePrice: Price
    public let notionalAmount: Double
    public let executionMode: ExecutionMode
    public let proposalAuthorization: PaperActionProposalAuthorization
    public let workflowStage: PaperExecutionWorkflowStage
    public let eventStream: EventStreamID
    public let evidenceKind: PaperExecutionWorkflowEvidenceKind
    public let sourceRiskDecisionSequence: Int
    public let createdAt: Date
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesBrokerAction: Bool
    public let representsRealOrder: Bool
    public let representsSimulatedFill: Bool

    public var isExecutableAsRealOrder: Bool {
        false
    }

    public var paperOnlyBoundaryHeld: Bool {
        executionMode == .paper
            && proposalAuthorization == .paperIntentOnly
            && workflowStage == .paperOrder
            && eventStream == .paper
            && evidenceKind == .paperOrder
            && authorizesTradingExecution == false
            && authorizesLiveTrading == false
            && touchesSignedEndpoint == false
            && touchesBrokerAction == false
            && representsRealOrder == false
            && representsSimulatedFill == false
            && isExecutableAsRealOrder == false
    }

    public init(
        orderID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        createdAt: Date
    ) throws {
        try self.init(
            orderID: orderID,
            proposalID: riskDecision.proposal.proposalID,
            sessionID: riskDecision.proposal.sessionID,
            riskDecisionID: riskDecision.decisionID,
            riskDecisionStatus: riskDecision.status,
            blockerEvidenceID: riskDecision.blockerEvidence?.evidenceID,
            lifecycleState: PaperOrderLifecycleState(riskDecisionStatus: riskDecision.status),
            riskProfileID: riskDecision.riskQuery.riskProfileID,
            side: riskDecision.proposal.side,
            symbol: riskDecision.proposal.symbol,
            timeframe: riskDecision.proposal.timeframe,
            quantity: riskDecision.proposal.quantity,
            referencePrice: riskDecision.proposal.referencePrice,
            notionalAmount: riskDecision.proposal.notionalAmount,
            executionMode: riskDecision.proposal.executionMode,
            proposalAuthorization: riskDecision.proposal.executionAuthorization,
            workflowStage: .paperOrder,
            eventStream: .paper,
            evidenceKind: .paperOrder,
            sourceRiskDecisionSequence: riskDecision.sourceSequence,
            createdAt: createdAt,
            authorizesTradingExecution: false,
            authorizesLiveTrading: false,
            touchesSignedEndpoint: false,
            touchesBrokerAction: false,
            representsRealOrder: false,
            representsSimulatedFill: false
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            proposalID: try container.decode(Identifier.self, forKey: .proposalID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            riskDecisionID: try container.decode(Identifier.self, forKey: .riskDecisionID),
            riskDecisionStatus: try container.decode(
                PaperActionProposalRiskDecisionStatus.self,
                forKey: .riskDecisionStatus
            ),
            blockerEvidenceID: try container.decodeIfPresent(Identifier.self, forKey: .blockerEvidenceID),
            lifecycleState: try container.decode(PaperOrderLifecycleState.self, forKey: .lifecycleState),
            riskProfileID: try container.decode(Identifier.self, forKey: .riskProfileID),
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            symbol: try container.decode(Symbol.self, forKey: .symbol),
            timeframe: try container.decode(Timeframe.self, forKey: .timeframe),
            quantity: try container.decode(Quantity.self, forKey: .quantity),
            referencePrice: try container.decode(Price.self, forKey: .referencePrice),
            notionalAmount: try container.decode(Double.self, forKey: .notionalAmount),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            proposalAuthorization: try container.decode(
                PaperActionProposalAuthorization.self,
                forKey: .proposalAuthorization
            ),
            workflowStage: try container.decode(PaperExecutionWorkflowStage.self, forKey: .workflowStage),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            evidenceKind: try container.decode(PaperExecutionWorkflowEvidenceKind.self, forKey: .evidenceKind),
            sourceRiskDecisionSequence: try container.decode(Int.self, forKey: .sourceRiskDecisionSequence),
            createdAt: try container.decode(Date.self, forKey: .createdAt),
            authorizesTradingExecution: try container.decode(
                Bool.self,
                forKey: .authorizesTradingExecution
            ),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            touchesSignedEndpoint: try container.decode(Bool.self, forKey: .touchesSignedEndpoint),
            touchesBrokerAction: try container.decode(Bool.self, forKey: .touchesBrokerAction),
            representsRealOrder: try container.decode(Bool.self, forKey: .representsRealOrder),
            representsSimulatedFill: try container.decode(Bool.self, forKey: .representsSimulatedFill)
        )
    }

    private init(
        orderID: Identifier,
        proposalID: Identifier,
        sessionID: Identifier,
        riskDecisionID: Identifier,
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        blockerEvidenceID: Identifier?,
        lifecycleState: PaperOrderLifecycleState,
        riskProfileID: Identifier,
        side: PaperActionProposalSide,
        symbol: Symbol,
        timeframe: Timeframe,
        quantity: Quantity,
        referencePrice: Price,
        notionalAmount: Double,
        executionMode: ExecutionMode,
        proposalAuthorization: PaperActionProposalAuthorization,
        workflowStage: PaperExecutionWorkflowStage,
        eventStream: EventStreamID,
        evidenceKind: PaperExecutionWorkflowEvidenceKind,
        sourceRiskDecisionSequence: Int,
        createdAt: Date,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsSimulatedFill: Bool
    ) throws {
        guard executionMode == .paper else {
            throw CoreError.paperOrderIntentRequiresPaperMode(executionMode)
        }
        guard proposalAuthorization == .paperIntentOnly else {
            throw CoreError.paperOrderIntentMismatch(
                field: "proposalAuthorization",
                expected: PaperActionProposalAuthorization.paperIntentOnly.rawValue,
                actual: "\(proposalAuthorization)"
            )
        }
        guard workflowStage == .paperOrder else {
            throw CoreError.paperOrderIntentMismatch(
                field: "workflowStage",
                expected: PaperExecutionWorkflowStage.paperOrder.rawValue,
                actual: workflowStage.rawValue
            )
        }
        guard eventStream == .paper else {
            throw CoreError.paperOrderIntentMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        guard evidenceKind == .paperOrder else {
            throw CoreError.paperOrderIntentMismatch(
                field: "evidenceKind",
                expected: PaperExecutionWorkflowEvidenceKind.paperOrder.rawValue,
                actual: evidenceKind.rawValue
            )
        }
        guard sourceRiskDecisionSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceRiskDecisionSequence)
        }
        try Self.validateLifecycleState(
            riskDecisionStatus: riskDecisionStatus,
            blockerEvidenceID: blockerEvidenceID,
            lifecycleState: lifecycleState
        )
        try Self.validateNotional(quantity: quantity, referencePrice: referencePrice, notionalAmount: notionalAmount)
        try Self.validateForbiddenCapabilities(
            authorizesTradingExecution: authorizesTradingExecution,
            authorizesLiveTrading: authorizesLiveTrading,
            touchesSignedEndpoint: touchesSignedEndpoint,
            touchesBrokerAction: touchesBrokerAction,
            representsRealOrder: representsRealOrder,
            representsSimulatedFill: representsSimulatedFill
        )

        self.orderID = orderID
        self.proposalID = proposalID
        self.sessionID = sessionID
        self.riskDecisionID = riskDecisionID
        self.riskDecisionStatus = riskDecisionStatus
        self.blockerEvidenceID = blockerEvidenceID
        self.lifecycleState = lifecycleState
        self.riskProfileID = riskProfileID
        self.side = side
        self.symbol = symbol
        self.timeframe = timeframe
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notionalAmount = notionalAmount
        self.executionMode = executionMode
        self.proposalAuthorization = proposalAuthorization
        self.workflowStage = workflowStage
        self.eventStream = eventStream
        self.evidenceKind = evidenceKind
        self.sourceRiskDecisionSequence = sourceRiskDecisionSequence
        self.createdAt = createdAt
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesBrokerAction = touchesBrokerAction
        self.representsRealOrder = representsRealOrder
        self.representsSimulatedFill = representsSimulatedFill
    }

    private static func validateLifecycleState(
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        blockerEvidenceID: Identifier?,
        lifecycleState: PaperOrderLifecycleState
    ) throws {
        let expectedState = PaperOrderLifecycleState(riskDecisionStatus: riskDecisionStatus)
        guard lifecycleState == expectedState else {
            throw CoreError.paperOrderIntentMismatch(
                field: "lifecycleState",
                expected: expectedState.rawValue,
                actual: lifecycleState.rawValue
            )
        }
        switch (riskDecisionStatus, blockerEvidenceID) {
        case (.allowed, nil), (.blocked, .some):
            return
        case (.allowed, .some):
            throw CoreError.paperOrderIntentMismatch(
                field: "blockerEvidenceID",
                expected: "nil for allowed intent",
                actual: "present"
            )
        case (.blocked, nil):
            throw CoreError.paperOrderIntentMismatch(
                field: "blockerEvidenceID",
                expected: "present for risk rejected intent",
                actual: "nil"
            )
        }
    }

    private static func validateNotional(
        quantity: Quantity,
        referencePrice: Price,
        notionalAmount: Double
    ) throws {
        let expected = quantity.rawValue * referencePrice.rawValue
        guard notionalAmount == expected else {
            throw CoreError.paperOrderIntentMismatch(
                field: "notionalAmount",
                expected: "\(expected)",
                actual: "\(notionalAmount)"
            )
        }
    }

    private static func validateForbiddenCapabilities(
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsSimulatedFill: Bool
    ) throws {
        guard authorizesTradingExecution == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("authorizesTradingExecution")
        }
        guard authorizesLiveTrading == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("authorizesLiveTrading")
        }
        guard touchesSignedEndpoint == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("touchesSignedEndpoint")
        }
        guard touchesBrokerAction == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("touchesBrokerAction")
        }
        guard representsRealOrder == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("representsRealOrder")
        }
        guard representsSimulatedFill == false else {
            throw CoreError.paperOrderIntentForbiddenCapability("representsSimulatedFill")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case orderID
        case proposalID
        case sessionID
        case riskDecisionID
        case riskDecisionStatus
        case blockerEvidenceID
        case lifecycleState
        case riskProfileID
        case side
        case symbol
        case timeframe
        case quantity
        case referencePrice
        case notionalAmount
        case executionMode
        case proposalAuthorization
        case workflowStage
        case eventStream
        case evidenceKind
        case sourceRiskDecisionSequence
        case createdAt
        case authorizesTradingExecution
        case authorizesLiveTrading
        case touchesSignedEndpoint
        case touchesBrokerAction
        case representsRealOrder
        case representsSimulatedFill
    }
}

/// PaperOrderIntentFixture 生成 MTP-39 的 deterministic order intent / lifecycle evidence。
///
/// Fixture 只用于 XCTest 和 PR evidence，固定 order ID、risk decision、时间戳和 lifecycle state；
/// 它不代表真实订单编号、真实 broker order、simulated fill 或完整 OMS。
public enum PaperOrderIntentFixture {
    public static func deterministicAllowed() throws -> PaperOrderIntent {
        try PaperOrderIntent(
            orderID: try Identifier("paper-order-intent-allowed"),
            riskDecision: PaperActionProposalRiskFixture.deterministicAllowed(),
            createdAt: Date(timeIntervalSince1970: 2_500)
        )
    }

    public static func deterministicRiskRejected() throws -> PaperOrderIntent {
        try PaperOrderIntent(
            orderID: try Identifier("paper-order-intent-risk-rejected"),
            riskDecision: PaperActionProposalRiskFixture.deterministicBlocked(),
            createdAt: Date(timeIntervalSince1970: 2_560)
        )
    }
}
