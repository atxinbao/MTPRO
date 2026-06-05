import DomainModel
import Foundation

/// Paper execution decision 是 MTP-41 的本地 paper-only 决策链路。
///
/// 该文件只把已经存在的 `PaperActionProposalRiskDecision`、`PaperOrderIntent` 和
/// `PaperSimulatedFillEvidence` 组合成可追溯 evidence chain。它不是 execution engine、
/// OMS、撮合器或 broker adapter；blocked risk decision 只保留阻断证据，绝不生成 paper order、
/// simulated fill、真实订单、signed endpoint 调用或 broker action。

/// PaperExecutionDecisionStatus 表达本地 paper execution decision 的允许 / 阻断结果。
///
/// 状态必须与上游 risk decision 完全一致：allowed 才能继续生成本地 paper order intent 和
/// simulated fill evidence；blocked 只能保留 risk blocker evidence，不能生成订单。
public enum PaperExecutionDecisionStatus: String, Codable, Equatable, Sendable {
    case allowed
    case blocked

    public init(riskDecisionStatus: PaperActionProposalRiskDecisionStatus) {
        switch riskDecisionStatus {
        case .allowed:
            self = .allowed
        case .blocked:
            self = .blocked
        }
    }
}

/// PaperExecutionDecision 保存 proposal -> risk -> order -> fill 的本地决策证据。
///
/// 输入是 MTP-33 的 risk decision。allowed 路径会生成 MTP-39 `PaperOrderIntent`
/// 和 MTP-40 `PaperSimulatedFillEvidence`；blocked 路径必须保持 `paperOrderIntent == nil`
/// 且 `simulatedFillEvidence == nil`。所有 capability flag 固定为 `false`，Codable 解码也会
/// 拒绝把该 evidence 伪造成真实交易执行、Live fallback、signed endpoint 或 broker action。
public struct PaperExecutionDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let riskDecision: PaperActionProposalRiskDecision
    public let status: PaperExecutionDecisionStatus
    public let paperOrderIntent: PaperOrderIntent?
    public let simulatedFillAssumption: PaperSimulatedFillAssumption?
    public let simulatedFillEvidence: PaperSimulatedFillEvidence?
    public let sourceOrderIntentSequence: Int?
    public let decidedAt: Date
    public let executionMode: ExecutionMode
    public let proposalAuthorization: PaperActionProposalAuthorization
    public let workflowStage: PaperExecutionWorkflowStage
    public let eventStream: EventStreamID
    public let evidenceKind: PaperExecutionWorkflowEvidenceKind
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesBrokerAction: Bool
    public let representsRealOrder: Bool
    public let representsRealFill: Bool
    public let representsBrokerFill: Bool
    public let updatesRealAccountBalance: Bool

    public var proposalID: Identifier {
        riskDecision.proposal.proposalID
    }

    public var sessionID: Identifier {
        riskDecision.proposal.sessionID
    }

    public var riskDecisionID: Identifier {
        riskDecision.decisionID
    }

    public var riskProfileID: Identifier {
        riskDecision.riskQuery.riskProfileID
    }

    public var blockerEvidenceID: Identifier? {
        riskDecision.blockerEvidence?.evidenceID
    }

    public var sourceRiskDecisionSequence: Int {
        riskDecision.sourceSequence
    }

    public var generatedPaperOrderIntent: Bool {
        paperOrderIntent != nil
    }

    public var generatedSimulatedFillEvidence: Bool {
        simulatedFillEvidence != nil
    }

    public var isAllowed: Bool {
        status == .allowed
    }

    public var isBlocked: Bool {
        status == .blocked
    }

    public var isExecutableAsRealOrder: Bool {
        false
    }

    public var paperOnlyBoundaryHeld: Bool {
        riskDecision.paperOnlyContextIsConsistent
            && executionMode == .paper
            && proposalAuthorization == .paperIntentOnly
            && workflowStage == .paperExecutionDecision
            && eventStream == .paper
            && evidenceKind == .paperExecutionDecision
            && (paperOrderIntent?.paperOnlyBoundaryHeld ?? true)
            && (simulatedFillEvidence?.paperOnlyBoundaryHeld ?? true)
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
        decisionID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        orderID: Identifier? = nil,
        fillID: Identifier? = nil,
        simulatedFillAssumption: PaperSimulatedFillAssumption? = nil,
        sourceOrderIntentSequence: Int? = nil,
        decidedAt: Date
    ) throws {
        let status = PaperExecutionDecisionStatus(riskDecisionStatus: riskDecision.status)
        let paperOrderIntent: PaperOrderIntent?
        let simulatedFillEvidence: PaperSimulatedFillEvidence?

        switch status {
        case .allowed:
            guard let orderID else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "orderID",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let fillID else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "fillID",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let simulatedFillAssumption else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillAssumption",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let sourceOrderIntentSequence else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }

            let orderIntent = try PaperOrderIntent(
                orderID: orderID,
                riskDecision: riskDecision,
                createdAt: decidedAt
            )
            paperOrderIntent = orderIntent
            simulatedFillEvidence = try PaperSimulatedFillEvidence(
                fillID: fillID,
                orderIntent: orderIntent,
                assumption: simulatedFillAssumption,
                sourceOrderIntentSequence: sourceOrderIntentSequence,
                filledAt: decidedAt
            )
        case .blocked:
            if orderID != nil {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "orderID",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            if fillID != nil {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "fillID",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            if simulatedFillAssumption != nil {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillAssumption",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            if sourceOrderIntentSequence != nil {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            paperOrderIntent = nil
            simulatedFillEvidence = nil
        }

        try self.init(
            decisionID: decisionID,
            riskDecision: riskDecision,
            status: status,
            paperOrderIntent: paperOrderIntent,
            simulatedFillAssumption: simulatedFillAssumption,
            simulatedFillEvidence: simulatedFillEvidence,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            decidedAt: decidedAt,
            executionMode: riskDecision.proposal.executionMode,
            proposalAuthorization: riskDecision.proposal.executionAuthorization,
            workflowStage: .paperExecutionDecision,
            eventStream: .paper,
            evidenceKind: .paperExecutionDecision,
            authorizesTradingExecution: false,
            authorizesLiveTrading: false,
            touchesSignedEndpoint: false,
            touchesBrokerAction: false,
            representsRealOrder: false,
            representsRealFill: false,
            representsBrokerFill: false,
            updatesRealAccountBalance: false
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decisionID: try container.decode(Identifier.self, forKey: .decisionID),
            riskDecision: try container.decode(PaperActionProposalRiskDecision.self, forKey: .riskDecision),
            status: try container.decode(PaperExecutionDecisionStatus.self, forKey: .status),
            paperOrderIntent: try container.decodeIfPresent(PaperOrderIntent.self, forKey: .paperOrderIntent),
            simulatedFillAssumption: try container.decodeIfPresent(
                PaperSimulatedFillAssumption.self,
                forKey: .simulatedFillAssumption
            ),
            simulatedFillEvidence: try container.decodeIfPresent(
                PaperSimulatedFillEvidence.self,
                forKey: .simulatedFillEvidence
            ),
            sourceOrderIntentSequence: try container.decodeIfPresent(
                Int.self,
                forKey: .sourceOrderIntentSequence
            ),
            decidedAt: try container.decode(Date.self, forKey: .decidedAt),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            proposalAuthorization: try container.decode(
                PaperActionProposalAuthorization.self,
                forKey: .proposalAuthorization
            ),
            workflowStage: try container.decode(PaperExecutionWorkflowStage.self, forKey: .workflowStage),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            evidenceKind: try container.decode(PaperExecutionWorkflowEvidenceKind.self, forKey: .evidenceKind),
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
            updatesRealAccountBalance: try container.decode(Bool.self, forKey: .updatesRealAccountBalance)
        )
    }

    private init(
        decisionID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        status: PaperExecutionDecisionStatus,
        paperOrderIntent: PaperOrderIntent?,
        simulatedFillAssumption: PaperSimulatedFillAssumption?,
        simulatedFillEvidence: PaperSimulatedFillEvidence?,
        sourceOrderIntentSequence: Int?,
        decidedAt: Date,
        executionMode: ExecutionMode,
        proposalAuthorization: PaperActionProposalAuthorization,
        workflowStage: PaperExecutionWorkflowStage,
        eventStream: EventStreamID,
        evidenceKind: PaperExecutionWorkflowEvidenceKind,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsRealFill: Bool,
        representsBrokerFill: Bool,
        updatesRealAccountBalance: Bool
    ) throws {
        guard riskDecision.sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(riskDecision.sourceSequence)
        }
        guard riskDecision.paperOnlyContextIsConsistent else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "riskDecision.paperOnlyContextIsConsistent",
                expected: "true",
                actual: "false"
            )
        }
        guard executionMode == .paper else {
            throw CoreError.paperExecutionDecisionRequiresPaperMode(executionMode)
        }
        guard proposalAuthorization == .paperIntentOnly else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "proposalAuthorization",
                expected: PaperActionProposalAuthorization.paperIntentOnly.rawValue,
                actual: "\(proposalAuthorization)"
            )
        }
        guard workflowStage == .paperExecutionDecision else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "workflowStage",
                expected: PaperExecutionWorkflowStage.paperExecutionDecision.rawValue,
                actual: workflowStage.rawValue
            )
        }
        guard eventStream == .paper else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        guard evidenceKind == .paperExecutionDecision else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "evidenceKind",
                expected: PaperExecutionWorkflowEvidenceKind.paperExecutionDecision.rawValue,
                actual: evidenceKind.rawValue
            )
        }
        try Self.validateStatus(status: status, riskDecision: riskDecision)
        try Self.validateArtifacts(
            status: status,
            riskDecision: riskDecision,
            paperOrderIntent: paperOrderIntent,
            simulatedFillAssumption: simulatedFillAssumption,
            simulatedFillEvidence: simulatedFillEvidence,
            sourceOrderIntentSequence: sourceOrderIntentSequence
        )
        try Self.validateForbiddenCapabilities(
            authorizesTradingExecution: authorizesTradingExecution,
            authorizesLiveTrading: authorizesLiveTrading,
            touchesSignedEndpoint: touchesSignedEndpoint,
            touchesBrokerAction: touchesBrokerAction,
            representsRealOrder: representsRealOrder,
            representsRealFill: representsRealFill,
            representsBrokerFill: representsBrokerFill,
            updatesRealAccountBalance: updatesRealAccountBalance
        )

        self.decisionID = decisionID
        self.riskDecision = riskDecision
        self.status = status
        self.paperOrderIntent = paperOrderIntent
        self.simulatedFillAssumption = simulatedFillAssumption
        self.simulatedFillEvidence = simulatedFillEvidence
        self.sourceOrderIntentSequence = sourceOrderIntentSequence
        self.decidedAt = decidedAt
        self.executionMode = executionMode
        self.proposalAuthorization = proposalAuthorization
        self.workflowStage = workflowStage
        self.eventStream = eventStream
        self.evidenceKind = evidenceKind
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesBrokerAction = touchesBrokerAction
        self.representsRealOrder = representsRealOrder
        self.representsRealFill = representsRealFill
        self.representsBrokerFill = representsBrokerFill
        self.updatesRealAccountBalance = updatesRealAccountBalance
    }

    private static func validateStatus(
        status: PaperExecutionDecisionStatus,
        riskDecision: PaperActionProposalRiskDecision
    ) throws {
        let expected = PaperExecutionDecisionStatus(riskDecisionStatus: riskDecision.status)
        guard status == expected else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "status",
                expected: expected.rawValue,
                actual: status.rawValue
            )
        }
    }

    private static func validateArtifacts(
        status: PaperExecutionDecisionStatus,
        riskDecision: PaperActionProposalRiskDecision,
        paperOrderIntent: PaperOrderIntent?,
        simulatedFillAssumption: PaperSimulatedFillAssumption?,
        simulatedFillEvidence: PaperSimulatedFillEvidence?,
        sourceOrderIntentSequence: Int?
    ) throws {
        switch status {
        case .allowed:
            guard riskDecision.blockerEvidence == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "riskDecision.blockerEvidence",
                    expected: "nil for allowed decision",
                    actual: "present"
                )
            }
            guard let paperOrderIntent else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "paperOrderIntent",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let simulatedFillAssumption else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillAssumption",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let simulatedFillEvidence else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillEvidence",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard let sourceOrderIntentSequence else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            }
            guard sourceOrderIntentSequence > 0 else {
                throw CoreError.invalidEventSequence(sourceOrderIntentSequence)
            }
            try validateOrderIntent(paperOrderIntent, riskDecision: riskDecision)
            try validateSimulatedFill(
                simulatedFillEvidence,
                orderIntent: paperOrderIntent,
                assumption: simulatedFillAssumption,
                sourceOrderIntentSequence: sourceOrderIntentSequence,
                sourceRiskDecisionSequence: riskDecision.sourceSequence
            )
        case .blocked:
            guard riskDecision.blockerEvidence != nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "riskDecision.blockerEvidence",
                    expected: "present for blocked decision",
                    actual: "nil"
                )
            }
            guard paperOrderIntent == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "paperOrderIntent",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            guard simulatedFillAssumption == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillAssumption",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            guard simulatedFillEvidence == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillEvidence",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
            guard sourceOrderIntentSequence == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            }
        }
    }

    private static func validateOrderIntent(
        _ orderIntent: PaperOrderIntent,
        riskDecision: PaperActionProposalRiskDecision
    ) throws {
        try validateField("paperOrderIntent.proposalID", expected: riskDecision.proposal.proposalID, actual: orderIntent.proposalID)
        try validateField("paperOrderIntent.sessionID", expected: riskDecision.proposal.sessionID, actual: orderIntent.sessionID)
        try validateField("paperOrderIntent.riskDecisionID", expected: riskDecision.decisionID, actual: orderIntent.riskDecisionID)
        try validateField("paperOrderIntent.riskProfileID", expected: riskDecision.riskQuery.riskProfileID, actual: orderIntent.riskProfileID)
        guard orderIntent.riskDecisionStatus == .allowed else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "paperOrderIntent.riskDecisionStatus",
                expected: PaperActionProposalRiskDecisionStatus.allowed.rawValue,
                actual: orderIntent.riskDecisionStatus.rawValue
            )
        }
        guard orderIntent.lifecycleState == .intentCreated else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "paperOrderIntent.lifecycleState",
                expected: PaperOrderLifecycleState.intentCreated.rawValue,
                actual: orderIntent.lifecycleState.rawValue
            )
        }
        try validateField("paperOrderIntent.sourceRiskDecisionSequence", expected: riskDecision.sourceSequence, actual: orderIntent.sourceRiskDecisionSequence)
        guard orderIntent.paperOnlyBoundaryHeld else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "paperOrderIntent.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
    }

    private static func validateSimulatedFill(
        _ fillEvidence: PaperSimulatedFillEvidence,
        orderIntent: PaperOrderIntent,
        assumption: PaperSimulatedFillAssumption,
        sourceOrderIntentSequence: Int,
        sourceRiskDecisionSequence: Int
    ) throws {
        try validateField("simulatedFillEvidence.orderID", expected: orderIntent.orderID, actual: fillEvidence.orderID)
        try validateField("simulatedFillEvidence.proposalID", expected: orderIntent.proposalID, actual: fillEvidence.proposalID)
        try validateField("simulatedFillEvidence.sessionID", expected: orderIntent.sessionID, actual: fillEvidence.sessionID)
        try validateField("simulatedFillEvidence.riskDecisionID", expected: orderIntent.riskDecisionID, actual: fillEvidence.riskDecisionID)
        try validateField("simulatedFillEvidence.sourceOrderIntentSequence", expected: sourceOrderIntentSequence, actual: fillEvidence.sourceOrderIntentSequence)
        try validateField("simulatedFillEvidence.sourceRiskDecisionSequence", expected: sourceRiskDecisionSequence, actual: fillEvidence.sourceRiskDecisionSequence)
        try validateField("simulatedFillEvidence.filledQuantity", expected: assumption.filledQuantity.rawValue, actual: fillEvidence.filledQuantity.rawValue)
        try validateField("simulatedFillEvidence.fillPrice", expected: assumption.fillPrice.rawValue, actual: fillEvidence.fillPrice.rawValue)
        try validateField(
            "simulatedFillEvidence.costAssumptionID",
            expected: assumption.executionCostAssumptions.assumptionID,
            actual: fillEvidence.costEstimate.assumptionID
        )
        guard fillEvidence.paperOnlyBoundaryHeld else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "simulatedFillEvidence.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
    }

    private static func validateForbiddenCapabilities(
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesBrokerAction: Bool,
        representsRealOrder: Bool,
        representsRealFill: Bool,
        representsBrokerFill: Bool,
        updatesRealAccountBalance: Bool
    ) throws {
        guard authorizesTradingExecution == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("authorizesTradingExecution")
        }
        guard authorizesLiveTrading == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("authorizesLiveTrading")
        }
        guard touchesSignedEndpoint == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("touchesSignedEndpoint")
        }
        guard touchesBrokerAction == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("touchesBrokerAction")
        }
        guard representsRealOrder == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("representsRealOrder")
        }
        guard representsRealFill == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("representsRealFill")
        }
        guard representsBrokerFill == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("representsBrokerFill")
        }
        guard updatesRealAccountBalance == false else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("updatesRealAccountBalance")
        }
    }

    private static func validateField(_ field: String, expected: Identifier, actual: Identifier) throws {
        guard expected == actual else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: field,
                expected: expected.rawValue,
                actual: actual.rawValue
            )
        }
    }

    private static func validateField(_ field: String, expected: Int, actual: Int) throws {
        guard expected == actual else {
            throw CoreError.paperExecutionDecisionMismatch(field: field, expected: "\(expected)", actual: "\(actual)")
        }
    }

    private static func validateField(_ field: String, expected: Double, actual: Double) throws {
        guard expected == actual else {
            throw CoreError.paperExecutionDecisionMismatch(field: field, expected: "\(expected)", actual: "\(actual)")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case decisionID
        case riskDecision
        case status
        case paperOrderIntent
        case simulatedFillAssumption
        case simulatedFillEvidence
        case sourceOrderIntentSequence
        case decidedAt
        case executionMode
        case proposalAuthorization
        case workflowStage
        case eventStream
        case evidenceKind
        case authorizesTradingExecution
        case authorizesLiveTrading
        case touchesSignedEndpoint
        case touchesBrokerAction
        case representsRealOrder
        case representsRealFill
        case representsBrokerFill
        case updatesRealAccountBalance
    }
}

/// PaperExecutionDecisionLink 是 MTP-41 的本地串联函数。
///
/// 该函数无网络、副作用或数据库写入；它只消费已校验 risk decision，并按 allowed / blocked
/// 规则组合本地 evidence，避免调用任何真实交易、broker 或 signed endpoint 能力。
public enum PaperExecutionDecisionLink {
    public static func decide(
        decisionID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        orderID: Identifier? = nil,
        fillID: Identifier? = nil,
        simulatedFillAssumption: PaperSimulatedFillAssumption? = nil,
        sourceOrderIntentSequence: Int? = nil,
        decidedAt: Date
    ) throws -> PaperExecutionDecision {
        try PaperExecutionDecision(
            decisionID: decisionID,
            riskDecision: riskDecision,
            orderID: orderID,
            fillID: fillID,
            simulatedFillAssumption: simulatedFillAssumption,
            sourceOrderIntentSequence: sourceOrderIntentSequence,
            decidedAt: decidedAt
        )
    }
}

/// PaperExecutionDecisionFixture 生成 MTP-41 deterministic decision flow evidence。
///
/// Fixture 固定 allowed / blocked 两条路径，用于 XCTest 和 PR evidence；它不代表真实订单编号、
/// broker order、execution report、account update 或 Live fallback。
public enum PaperExecutionDecisionFixture {
    public static func deterministicAllowed() throws -> PaperExecutionDecision {
        try PaperExecutionDecisionLink.decide(
            decisionID: try Identifier("paper-execution-decision-allowed"),
            riskDecision: PaperActionProposalRiskFixture.deterministicAllowed(),
            orderID: try Identifier("paper-execution-order-allowed"),
            fillID: try Identifier("paper-execution-fill-allowed"),
            simulatedFillAssumption: .deterministicFixture,
            sourceOrderIntentSequence: 9,
            decidedAt: Date(timeIntervalSince1970: 2_900)
        )
    }

    public static func deterministicBlocked() throws -> PaperExecutionDecision {
        try PaperExecutionDecisionLink.decide(
            decisionID: try Identifier("paper-execution-decision-blocked"),
            riskDecision: PaperActionProposalRiskFixture.deterministicBlocked(),
            decidedAt: Date(timeIntervalSince1970: 2_960)
        )
    }
}
