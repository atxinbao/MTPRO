import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// GH-530 将 release v0.1.0 的 ExecutionEngine order lifecycle 固定为本地 OMS 状态机证据。
///
/// State machine 只消费 GH-529 RiskEngine decision evidence，输出 deterministic OMS event log /
/// audit evidence。它不调用 ExecutionClient、不连接 broker、不提交 / 撤销 / 替换真实订单，也不授权
/// production OMS runtime。
/// `GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE`
/// `TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE`
public struct ReleaseV010ExecutionOMSStateMachine: Codable, Equatable, Sendable {
    public let stateMachineID: Identifier
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public init(
        stateMachineID: Identifier,
        releaseVenue: String = Self.requiredReleaseVenue,
        activeConcreteStrategy: String = Self.requiredActiveConcreteStrategy,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.stateMachineID = stateMachineID
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    /// 从 approved risk decision 创建本地 order intent。
    ///
    /// Intent 只是 ExecutionEngine / OMS 的本地审计输入，不是 ExecutionClient request。
    public func makeOrderIntent(
        from riskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        orderIntentID: Identifier
    ) throws -> ReleaseV010OMSOrderIntent {
        try ReleaseV010OMSOrderIntent(
            orderIntentID: orderIntentID,
            sourceRiskDecision: riskDecision,
            validationAnchors: validationAnchors
        )
    }

    /// 为给定 risk decision 和路径生成 append-only OMS event log evidence。
    public func eventLog(
        for riskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        path: ReleaseV010OMSPath,
        sourceSequenceBase: Int
    ) throws -> ReleaseV010OMSEventLog {
        let orderID = try Identifier("\(stateMachineID.rawValue)-\(path.rawValue)-order")
        let intent: ReleaseV010OMSOrderIntent?
        if path.requiresApprovedRiskDecision {
            intent = try makeOrderIntent(
                from: riskDecision,
                orderIntentID: try Identifier("\(orderID.rawValue)-intent")
            )
        } else {
            guard riskDecision.outcome != .approved else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "riskDecision.outcome",
                    expected: "rejected or blocked for rejection path",
                    actual: riskDecision.outcome.rawValue
                )
            }
            intent = nil
        }

        return try ReleaseV010OMSEventLog(
            eventLogID: try Identifier("\(orderID.rawValue)-event-log"),
            path: path,
            orderID: orderID,
            orderIntent: intent,
            sourceRiskDecision: riskDecision,
            transitions: try transitions(
                orderID: orderID,
                riskDecision: riskDecision,
                path: path,
                sourceSequenceBase: sourceSequenceBase
            ),
            validationAnchors: validationAnchors
        )
    }

    /// 生成 release v0.1.0 GH-530 的 deterministic full-state coverage evidence。
    public func deterministicEvidence(
        from riskGateEvidence: ReleaseV010RiskPreTradeGateEvidence
    ) throws -> ReleaseV010ExecutionOMSStateMachineEvidence {
        let approved = try riskGateEvidence.decision(.approved)
        let rejectedOrBlocked = try riskGateEvidence.decision(.blocked)
        let logs = try [
            eventLog(for: approved, path: .acceptedFilled, sourceSequenceBase: 100),
            eventLog(for: approved, path: .acceptedCanceled, sourceSequenceBase: 200),
            eventLog(for: approved, path: .acceptedReplacedFilled, sourceSequenceBase: 300),
            eventLog(for: rejectedOrBlocked, path: .riskRejected, sourceSequenceBase: 400)
        ]
        return try ReleaseV010ExecutionOMSStateMachineEvidence(
            evidenceID: try Identifier("\(stateMachineID.rawValue)-evidence"),
            riskGateEvidenceID: riskGateEvidence.evidenceID,
            eventLogs: logs,
            validationAnchors: validationAnchors,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionOMSRuntimeEnabledByDefault: productionOMSRuntimeEnabledByDefault,
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            performsReconciliation: performsReconciliation,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            nonEMAStrategyEnabled: nonEMAStrategyEnabled
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010ExecutionOMSStateMachine {
        try ReleaseV010ExecutionOMSStateMachine(
            stateMachineID: try Identifier("gh-530-executionengine-oms-state-machine")
        )
    }

    public static let requiredReleaseVenue = "Binance"
    public static let requiredActiveConcreteStrategy = "EMA"
    public static let requiredValidationAnchors = [
        "GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE",
        "GH-530-RISK-APPROVED-ORDER-INTENT",
        "GH-530-OMS-EVENT-LOG-AUDIT-EVIDENCE",
        "GH-530-NO-PRODUCTION-OMS-RUNTIME",
        "TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE"
    ]

    private func transitions(
        orderID: Identifier,
        riskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        path: ReleaseV010OMSPath,
        sourceSequenceBase: Int
    ) throws -> [ReleaseV010OMSStateTransition] {
        guard sourceSequenceBase > 0 else {
            throw CoreError.invalidEventSequence(sourceSequenceBase)
        }
        switch path {
        case .acceptedFilled:
            return try [
                transition(orderID, riskDecision, .new, .riskApproved, .accepted, sourceSequenceBase + 1),
                transition(orderID, riskDecision, .accepted, .fillObserved, .filled, sourceSequenceBase + 2)
            ]
        case .acceptedCanceled:
            return try [
                transition(orderID, riskDecision, .new, .riskApproved, .accepted, sourceSequenceBase + 1),
                transition(orderID, riskDecision, .accepted, .cancelRequested, .canceled, sourceSequenceBase + 2)
            ]
        case .acceptedReplacedFilled:
            return try [
                transition(orderID, riskDecision, .new, .riskApproved, .accepted, sourceSequenceBase + 1),
                transition(orderID, riskDecision, .accepted, .replaceRequested, .replaced, sourceSequenceBase + 2),
                transition(orderID, riskDecision, .replaced, .fillObserved, .filled, sourceSequenceBase + 3)
            ]
        case .riskRejected:
            return try [
                transition(orderID, riskDecision, .new, .riskRejected, .rejected, sourceSequenceBase + 1)
            ]
        }
    }

    private func transition(
        _ orderID: Identifier,
        _ riskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        _ from: ReleaseV010OMSOrderLifecycleState,
        _ trigger: ReleaseV010OMSStateTransitionTrigger,
        _ to: ReleaseV010OMSOrderLifecycleState,
        _ sequence: Int
    ) throws -> ReleaseV010OMSStateTransition {
        try ReleaseV010OMSStateTransition(
            transitionID: try Identifier("\(orderID.rawValue)-\(sequence)-\(to.rawValue)"),
            orderID: orderID,
            sourceRiskDecisionID: riskDecision.decisionID,
            fromState: from,
            trigger: trigger,
            toState: to,
            sequence: sequence,
            validationAnchors: validationAnchors
        )
    }

    private func validate() throws {
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.nonBinanceVenue")
        }
        guard activeConcreteStrategy == Self.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.nonEMAStrategy")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV010OMS.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("nonEMAStrategyEnabled", nonEMAStrategyEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.\(forbiddenFlag.0)")
        }
    }
}

public enum ReleaseV010OMSOrderLifecycleState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case new
    case accepted
    case rejected
    case canceled
    case replaced
    case filled
}

public enum ReleaseV010OMSStateTransitionTrigger: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskApproved = "risk approved"
    case riskRejected = "risk rejected or blocked"
    case cancelRequested = "cancel requested"
    case replaceRequested = "replace requested"
    case fillObserved = "fill observed"
}

public enum ReleaseV010OMSPath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case acceptedFilled = "accepted-filled"
    case acceptedCanceled = "accepted-canceled"
    case acceptedReplacedFilled = "accepted-replaced-filled"
    case riskRejected = "risk-rejected"

    public var requiresApprovedRiskDecision: Bool {
        self != .riskRejected
    }
}

/// ReleaseV010OMSOrderIntent 是 RiskEngine approved decision 进入 ExecutionEngine 的本地意图。
///
/// 它只记录 paper proposal 的 order lifecycle 输入，不是 ExecutionClient request，也不能被发送到 broker。
public struct ReleaseV010OMSOrderIntent: Codable, Equatable, Sendable {
    public let orderIntentID: Identifier
    public let sourceRiskDecision: ReleaseV010RiskPreTradeDecisionEvidence
    public let proposalID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let side: PaperActionProposalSide
    public let quantity: Quantity
    public let referencePrice: Price
    public let notionalAmount: Double
    public let validationAnchors: [String]
    public let localLifecycleOnly: Bool
    public let routedThroughRiskEngine: Bool
    public let routedToExecutionClient: Bool
    public let submitsRealOrder: Bool

    public var intentBoundaryHeld: Bool {
        sourceRiskDecision.decisionBoundaryHeld
            && sourceRiskDecision.outcome == .approved
            && sourceRiskDecision.authorizesExecutionCommand == false
            && sourceRiskDecision.submitsRealOrder == false
            && validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors
            && localLifecycleOnly
            && routedThroughRiskEngine
            && routedToExecutionClient == false
            && submitsRealOrder == false
    }

    public init(
        orderIntentID: Identifier,
        sourceRiskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        validationAnchors: [String] = ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors,
        localLifecycleOnly: Bool = true,
        routedThroughRiskEngine: Bool = true,
        routedToExecutionClient: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sourceRiskDecision.decisionBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceRiskDecision",
                expected: "GH-529 decision boundary held",
                actual: "mismatch"
            )
        }
        guard sourceRiskDecision.outcome == .approved else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceRiskDecision.outcome",
                expected: ReleaseV010RiskPreTradeDecisionOutcome.approved.rawValue,
                actual: sourceRiskDecision.outcome.rawValue
            )
        }
        guard validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("localLifecycleOnly", localLifecycleOnly),
            ("routedThroughRiskEngine", routedThroughRiskEngine)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.\(requiredFlag.0)")
        }
        for forbiddenFlag in [
            ("routedToExecutionClient", routedToExecutionClient),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.\(forbiddenFlag.0)")
        }

        let proposal = sourceRiskDecision.input.proposal
        self.orderIntentID = orderIntentID
        self.sourceRiskDecision = sourceRiskDecision
        self.proposalID = proposal.proposalID
        self.symbol = proposal.symbol
        self.timeframe = proposal.timeframe
        self.side = proposal.side
        self.quantity = proposal.quantity
        self.referencePrice = proposal.referencePrice
        self.notionalAmount = proposal.notionalAmount
        self.validationAnchors = validationAnchors
        self.localLifecycleOnly = localLifecycleOnly
        self.routedThroughRiskEngine = routedThroughRiskEngine
        self.routedToExecutionClient = routedToExecutionClient
        self.submitsRealOrder = submitsRealOrder
    }
}

/// ReleaseV010OMSStateTransition 是本地 OMS append-only event log 的单条状态变更。
public struct ReleaseV010OMSStateTransition: Codable, Equatable, Sendable {
    public let transitionID: Identifier
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let fromState: ReleaseV010OMSOrderLifecycleState
    public let trigger: ReleaseV010OMSStateTransitionTrigger
    public let toState: ReleaseV010OMSOrderLifecycleState
    public let sequence: Int
    public let validationAnchors: [String]
    public let appendOnlyAuditEvent: Bool
    public let writesProductionOrderStore: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public var transitionBoundaryHeld: Bool {
        sequence > 0
            && Self.allowedTransition(from: fromState, trigger: trigger, to: toState)
            && validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors
            && appendOnlyAuditEvent
            && writesProductionOrderStore == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }

    public init(
        transitionID: Identifier,
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        fromState: ReleaseV010OMSOrderLifecycleState,
        trigger: ReleaseV010OMSStateTransitionTrigger,
        toState: ReleaseV010OMSOrderLifecycleState,
        sequence: Int,
        validationAnchors: [String] = ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors,
        appendOnlyAuditEvent: Bool = true,
        writesProductionOrderStore: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        guard Self.allowedTransition(from: fromState, trigger: trigger, to: toState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "omsTransition",
                expected: Self.allowedTransitionDescriptions.sorted().joined(separator: ","),
                actual: "\(fromState.rawValue)|\(trigger.rawValue)|\(toState.rawValue)"
            )
        }
        guard validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard appendOnlyAuditEvent else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.appendOnlyAuditEvent")
        }
        for forbiddenFlag in [
            ("writesProductionOrderStore", writesProductionOrderStore),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010OMS.\(forbiddenFlag.0)")
        }

        self.transitionID = transitionID
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sequence = sequence
        self.validationAnchors = validationAnchors
        self.appendOnlyAuditEvent = appendOnlyAuditEvent
        self.writesProductionOrderStore = writesProductionOrderStore
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
    }

    public static func allowedTransition(
        from fromState: ReleaseV010OMSOrderLifecycleState,
        trigger: ReleaseV010OMSStateTransitionTrigger,
        to toState: ReleaseV010OMSOrderLifecycleState
    ) -> Bool {
        allowedTransitionDescriptions.contains("\(fromState.rawValue)|\(trigger.rawValue)|\(toState.rawValue)")
    }

    public static let allowedTransitionDescriptions: Set<String> = [
        "new|risk approved|accepted",
        "new|risk rejected or blocked|rejected",
        "accepted|cancel requested|canceled",
        "accepted|replace requested|replaced",
        "accepted|fill observed|filled",
        "replaced|fill observed|filled"
    ]
}

/// ReleaseV010OMSEventLog 汇总单个本地 order path 的 append-only transition evidence。
public struct ReleaseV010OMSEventLog: Codable, Equatable, Sendable {
    public let eventLogID: Identifier
    public let path: ReleaseV010OMSPath
    public let orderID: Identifier
    public let orderIntent: ReleaseV010OMSOrderIntent?
    public let sourceRiskDecision: ReleaseV010RiskPreTradeDecisionEvidence
    public let transitions: [ReleaseV010OMSStateTransition]
    public let validationAnchors: [String]
    public let eventStream: EventStreamID
    public let appendOnlyAuditEvidence: Bool
    public let deterministicEvidence: Bool
    public let productionOrderStoreWritten: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public var terminalState: ReleaseV010OMSOrderLifecycleState? {
        transitions.last?.toState
    }

    public var statesCovered: Set<ReleaseV010OMSOrderLifecycleState> {
        Set(transitions.flatMap { [$0.fromState, $0.toState] })
    }

    public var eventLogBoundaryHeld: Bool {
        transitions.isEmpty == false
            && transitions.allSatisfy(\.transitionBoundaryHeld)
            && transitions.map(\.orderID).allSatisfy { $0 == orderID }
            && sequencesAreStrictlyIncreasing
            && riskBoundaryMatchesPath
            && validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors
            && eventStream == .paper
            && appendOnlyAuditEvidence
            && deterministicEvidence
            && productionOrderStoreWritten == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }

    private var sequencesAreStrictlyIncreasing: Bool {
        transitions.map(\.sequence) == transitions.map(\.sequence).sorted()
            && Set(transitions.map(\.sequence)).count == transitions.count
    }

    private var riskBoundaryMatchesPath: Bool {
        if path.requiresApprovedRiskDecision {
            return sourceRiskDecision.outcome == .approved
                && orderIntent?.intentBoundaryHeld == true
                && transitions.first?.fromState == .new
                && transitions.first?.toState == .accepted
        }
        return sourceRiskDecision.outcome != .approved
            && orderIntent == nil
            && transitions.count == 1
            && terminalState == .rejected
    }

    public init(
        eventLogID: Identifier,
        path: ReleaseV010OMSPath,
        orderID: Identifier,
        orderIntent: ReleaseV010OMSOrderIntent?,
        sourceRiskDecision: ReleaseV010RiskPreTradeDecisionEvidence,
        transitions: [ReleaseV010OMSStateTransition],
        validationAnchors: [String] = ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors,
        eventStream: EventStreamID = .paper,
        appendOnlyAuditEvidence: Bool = true,
        deterministicEvidence: Bool = true,
        productionOrderStoreWritten: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        self.eventLogID = eventLogID
        self.path = path
        self.orderID = orderID
        self.orderIntent = orderIntent
        self.sourceRiskDecision = sourceRiskDecision
        self.transitions = transitions
        self.validationAnchors = validationAnchors
        self.eventStream = eventStream
        self.appendOnlyAuditEvidence = appendOnlyAuditEvidence
        self.deterministicEvidence = deterministicEvidence
        self.productionOrderStoreWritten = productionOrderStoreWritten
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder

        try validate()
    }

    private func validate() throws {
        guard sourceRiskDecision.decisionBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceRiskDecision",
                expected: "GH-529 decision boundary held",
                actual: "mismatch"
            )
        }
        guard eventLogBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "eventLogBoundary",
                expected: "GH-530 event log boundary held",
                actual: "mismatch"
            )
        }
    }
}

/// ReleaseV010ExecutionOMSStateMachineEvidence 是 GH-530 的最终 deterministic evidence。
public struct ReleaseV010ExecutionOMSStateMachineEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let riskGateEvidenceID: Identifier
    public let eventLogs: [ReleaseV010OMSEventLog]
    public let validationAnchors: [String]
    public let riskApprovedRequiredBeforeExecutionPath: Bool
    public let stateMachineCoversAllRequiredStates: Bool
    public let eventLogAuditEvidenceComplete: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public var statesCovered: Set<ReleaseV010OMSOrderLifecycleState> {
        Set(eventLogs.flatMap(\.statesCovered))
    }

    public var evidenceBoundaryHeld: Bool {
        eventLogs.count == ReleaseV010OMSPath.allCases.count
            && eventLogs.allSatisfy(\.eventLogBoundaryHeld)
            && Set(eventLogs.map(\.path)) == Set(ReleaseV010OMSPath.allCases)
            && statesCovered == Set(ReleaseV010OMSOrderLifecycleState.allCases)
            && validationAnchors == ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors
            && riskApprovedRequiredBeforeExecutionPath
            && stateMachineCoversAllRequiredStates
            && eventLogAuditEvidenceComplete
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionTradingEnabledByDefault,
            productionOMSRuntimeEnabledByDefault,
            callsExecutionClient,
            touchesBrokerGateway,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            performsReconciliation,
            exposesLiveCommandSurface,
            nonBinanceVenueEnabled,
            nonEMAStrategyEnabled
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier,
        riskGateEvidenceID: Identifier,
        eventLogs: [ReleaseV010OMSEventLog],
        validationAnchors: [String] = ReleaseV010ExecutionOMSStateMachine.requiredValidationAnchors,
        riskApprovedRequiredBeforeExecutionPath: Bool = true,
        stateMachineCoversAllRequiredStates: Bool = true,
        eventLogAuditEvidenceComplete: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.riskGateEvidenceID = riskGateEvidenceID
        self.eventLogs = eventLogs
        self.validationAnchors = validationAnchors
        self.riskApprovedRequiredBeforeExecutionPath = riskApprovedRequiredBeforeExecutionPath
        self.stateMachineCoversAllRequiredStates = stateMachineCoversAllRequiredStates
        self.eventLogAuditEvidenceComplete = eventLogAuditEvidenceComplete
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    private func validate() throws {
        guard evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV010OMS.evidenceBoundary",
                expected: "risk-approved OMS evidence boundary held",
                actual: "mismatch"
            )
        }
    }
}

private extension ReleaseV010RiskPreTradeGateEvidence {
    func decision(_ outcome: ReleaseV010RiskPreTradeDecisionOutcome) throws -> ReleaseV010RiskPreTradeDecisionEvidence {
        guard let decision = decisions.first(where: { $0.outcome == outcome }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskGateEvidence.decisions",
                expected: outcome.rawValue,
                actual: decisions.map(\.outcome.rawValue).joined(separator: ",")
            )
        }
        return decision
    }
}
