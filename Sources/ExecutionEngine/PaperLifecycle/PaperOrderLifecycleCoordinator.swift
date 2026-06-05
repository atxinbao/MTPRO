import DomainModel
import Foundation

/// MTP-99 的 paper-only lifecycle coordinator 只管理本地 order lifecycle transition。
///
/// 本文件刻意使用 `Local` / `Simulated` 命名，说明这些状态只属于本地 paper runtime，不是 OMS、
/// broker router、真实订单状态机、交易所 accepted / filled，也不会触发真实 submit / cancel /
/// replace。所有 transition 都以 `PaperEvent.orderLocalLifecycleTransitionRecorded` 形式写入
/// append-only `MessageBus`，再由 replay 重建 route evidence。

/// PaperOrderLocalLifecycleState 是 MTP-99 的本地 paper order lifecycle 状态集合。
///
/// 这些状态只表示本地 coordinator 对 paper proposal / risk decision 的解释：`acceptedLocal` 只是
/// simulated fill 的前置条件，不是 exchange accepted；`cancelledLocal` 只能由 session close /
/// reset、本地 expiry 或 deterministic local rule 产生，不是用户单笔撤单或 broker cancel。
public enum PaperOrderLocalLifecycleState: String, Codable, CaseIterable, Equatable, Sendable {
    case proposed
    case submittedLocal
    case acceptedLocal
    case rejectedByPaperRisk
    case cancelledLocal
    case expiredLocal
    case failedLocal

    public var isTerminal: Bool {
        switch self {
        case .rejectedByPaperRisk, .cancelledLocal, .expiredLocal, .failedLocal:
            true
        case .proposed, .submittedLocal, .acceptedLocal:
            false
        }
    }
}

/// PaperOrderLocalLifecycleTrigger 固定每次 local transition 的来源。
///
/// trigger 名称全部是 paper / local / deterministic 语义，不包含 real submit、real cancel、broker
/// acknowledgement、execution report 或 reconciliation。`cancelledLocal` 的 trigger 只能来自
/// session close / reset、本地 expiry 或 deterministic local rule。
public enum PaperOrderLocalLifecycleTrigger: String, Codable, CaseIterable, Equatable, Sendable {
    case paperProposalRecorded
    case submittedLocal
    case acceptedLocal
    case rejectedByPaperRisk
    case sessionClose
    case sessionReset
    case localExpiry
    case deterministicLocalRule

    public var canCancelLocally: Bool {
        switch self {
        case .sessionClose, .sessionReset, .localExpiry, .deterministicLocalRule:
            true
        case .paperProposalRecorded, .submittedLocal, .acceptedLocal, .rejectedByPaperRisk:
            false
        }
    }
}

/// PaperOrderSimulatedFillReadiness 表达 accepted local 是否满足 simulated fill 前置条件。
///
/// 它不表示真实成交准备、不表示 broker fill 等待，也不会授权 execution report 或 reconciliation。
public enum PaperOrderSimulatedFillReadiness: String, Codable, Equatable, Sendable {
    case waitingForAcceptedLocal
    case readyForSimulatedFill
}

/// PaperOrderLocalLifecycleTransition 是单个 local lifecycle fact。
///
/// transition 绑定 order / proposal / session / risk decision、from/to state、trigger、source sequence 和
/// validation anchors。所有 forbidden capability flags 必须保持 `false`，Codable 解码也不能把它升级
/// 成 OMS、broker adapter、真实订单状态机、真实 cancel command 或 order-level UI command。
public struct PaperOrderLocalLifecycleTransition: Codable, Equatable, Sendable {
    public let transitionID: Identifier
    public let issueID: Identifier
    public let orderID: Identifier
    public let riskDecision: PaperActionProposalRiskDecision
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let riskDecisionID: Identifier
    public let riskDecisionStatus: PaperActionProposalRiskDecisionStatus
    public let blockerEvidenceID: Identifier?
    public let fromState: PaperOrderLocalLifecycleState?
    public let toState: PaperOrderLocalLifecycleState
    public let trigger: PaperOrderLocalLifecycleTrigger
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let side: PaperActionProposalSide
    public let quantity: Quantity
    public let referencePrice: Price
    public let sourceRiskDecisionSequence: Int
    public let sourceLifecycleSequence: Int?
    public let occurredAt: Date
    public let eventStream: EventStreamID
    public let validationAnchors: [String]
    public let implementsOMS: Bool
    public let connectsBroker: Bool
    public let implementsRealOrderStateMachine: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let providesRealCancelCommand: Bool
    public let providesOrderLevelCommandUI: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var paperOnlyBoundaryHeld: Bool {
        eventStream == .paper
            && implementsOMS == false
            && connectsBroker == false
            && implementsRealOrderStateMachine == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && providesRealCancelCommand == false
            && providesOrderLevelCommandUI == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public var isSimulatedFillPrecondition: Bool {
        riskDecisionStatus == .allowed && toState == .acceptedLocal
    }

    public init(
        transitionID: Identifier,
        issueID: Identifier = try! Identifier("MTP-99"),
        orderID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        fromState: PaperOrderLocalLifecycleState?,
        toState: PaperOrderLocalLifecycleState,
        trigger: PaperOrderLocalLifecycleTrigger,
        sourceLifecycleSequence: Int? = nil,
        occurredAt: Date,
        eventStream: EventStreamID = .paper,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        implementsOMS: Bool = false,
        connectsBroker: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        providesRealCancelCommand: Bool = false,
        providesOrderLevelCommandUI: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            issueID: issueID,
            riskDecision: riskDecision,
            fromState: fromState,
            toState: toState,
            trigger: trigger,
            sourceLifecycleSequence: sourceLifecycleSequence,
            eventStream: eventStream,
            validationAnchors: validationAnchors,
            implementsOMS: implementsOMS,
            connectsBroker: connectsBroker,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            providesRealCancelCommand: providesRealCancelCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )

        self.transitionID = transitionID
        self.issueID = issueID
        self.orderID = orderID
        self.riskDecision = riskDecision
        self.proposalID = riskDecision.proposal.proposalID
        self.sessionID = riskDecision.proposal.sessionID
        self.riskDecisionID = riskDecision.decisionID
        self.riskDecisionStatus = riskDecision.status
        self.blockerEvidenceID = riskDecision.blockerEvidence?.evidenceID
        self.fromState = fromState
        self.toState = toState
        self.trigger = trigger
        self.symbol = riskDecision.proposal.symbol
        self.timeframe = riskDecision.proposal.timeframe
        self.side = riskDecision.proposal.side
        self.quantity = riskDecision.proposal.quantity
        self.referencePrice = riskDecision.proposal.referencePrice
        self.sourceRiskDecisionSequence = riskDecision.sourceSequence
        self.sourceLifecycleSequence = sourceLifecycleSequence
        self.occurredAt = occurredAt
        self.eventStream = eventStream
        self.validationAnchors = validationAnchors
        self.implementsOMS = implementsOMS
        self.connectsBroker = connectsBroker
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.providesRealCancelCommand = providesRealCancelCommand
        self.providesOrderLevelCommandUI = providesOrderLevelCommandUI
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let riskDecision = try container.decode(PaperActionProposalRiskDecision.self, forKey: .riskDecision)
        try self.init(
            transitionID: try container.decode(Identifier.self, forKey: .transitionID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            riskDecision: riskDecision,
            fromState: try container.decodeIfPresent(PaperOrderLocalLifecycleState.self, forKey: .fromState),
            toState: try container.decode(PaperOrderLocalLifecycleState.self, forKey: .toState),
            trigger: try container.decode(PaperOrderLocalLifecycleTrigger.self, forKey: .trigger),
            sourceLifecycleSequence: try container.decodeIfPresent(Int.self, forKey: .sourceLifecycleSequence),
            occurredAt: try container.decode(Date.self, forKey: .occurredAt),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsRealOrderStateMachine: try container.decode(Bool.self, forKey: .implementsRealOrderStateMachine),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            providesRealCancelCommand: try container.decode(Bool.self, forKey: .providesRealCancelCommand),
            providesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .providesOrderLevelCommandUI),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transitionID, forKey: .transitionID)
        try container.encode(issueID, forKey: .issueID)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(riskDecision, forKey: .riskDecision)
        try container.encode(proposalID, forKey: .proposalID)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(riskDecisionID, forKey: .riskDecisionID)
        try container.encode(riskDecisionStatus, forKey: .riskDecisionStatus)
        try container.encodeIfPresent(blockerEvidenceID, forKey: .blockerEvidenceID)
        try container.encodeIfPresent(fromState, forKey: .fromState)
        try container.encode(toState, forKey: .toState)
        try container.encode(trigger, forKey: .trigger)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(side, forKey: .side)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(referencePrice, forKey: .referencePrice)
        try container.encode(sourceRiskDecisionSequence, forKey: .sourceRiskDecisionSequence)
        try container.encodeIfPresent(sourceLifecycleSequence, forKey: .sourceLifecycleSequence)
        try container.encode(occurredAt, forKey: .occurredAt)
        try container.encode(eventStream, forKey: .eventStream)
        try container.encode(validationAnchors, forKey: .validationAnchors)
        try container.encode(implementsOMS, forKey: .implementsOMS)
        try container.encode(connectsBroker, forKey: .connectsBroker)
        try container.encode(implementsRealOrderStateMachine, forKey: .implementsRealOrderStateMachine)
        try container.encode(submitsRealOrder, forKey: .submitsRealOrder)
        try container.encode(cancelsRealOrder, forKey: .cancelsRealOrder)
        try container.encode(replacesRealOrder, forKey: .replacesRealOrder)
        try container.encode(consumesExecutionReport, forKey: .consumesExecutionReport)
        try container.encode(recordsBrokerFill, forKey: .recordsBrokerFill)
        try container.encode(performsReconciliation, forKey: .performsReconciliation)
        try container.encode(providesRealCancelCommand, forKey: .providesRealCancelCommand)
        try container.encode(providesOrderLevelCommandUI, forKey: .providesOrderLevelCommandUI)
        try container.encode(providesLiveCommand, forKey: .providesLiveCommand)
        try container.encode(providesTradingButton, forKey: .providesTradingButton)
    }

    public static let requiredValidationAnchors: [String] = [
        "TVM-PAPER-RUNTIME-KERNEL",
        "MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR",
        "MTP-99-LOCAL-ORDER-LIFECYCLE-STATES",
        "MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS",
        "MTP-99-SIMULATED-FILL-PRECONDITION",
        "MTP-99-NO-OMS-BROKER-REAL-CANCEL",
        "MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION"
    ]

    private static func validate(
        issueID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        fromState: PaperOrderLocalLifecycleState?,
        toState: PaperOrderLocalLifecycleState,
        trigger: PaperOrderLocalLifecycleTrigger,
        sourceLifecycleSequence: Int?,
        eventStream: EventStreamID,
        validationAnchors: [String],
        implementsOMS: Bool,
        connectsBroker: Bool,
        implementsRealOrderStateMachine: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        providesRealCancelCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        guard issueID.rawValue == "MTP-99" else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "issueID",
                expected: "MTP-99",
                actual: issueID.rawValue
            )
        }
        guard riskDecision.paperOnlyContextIsConsistent else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "riskDecision.paperOnlyContextIsConsistent",
                expected: "true",
                actual: "false"
            )
        }
        guard eventStream == .paper else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        guard validationAnchors == requiredValidationAnchors else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "validationAnchors",
                expected: requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        if let sourceLifecycleSequence, sourceLifecycleSequence <= 0 {
            throw CoreError.invalidEventSequence(sourceLifecycleSequence)
        }
        try validateTransition(
            riskDecisionStatus: riskDecision.status,
            blockerEvidenceID: riskDecision.blockerEvidence?.evidenceID,
            fromState: fromState,
            toState: toState,
            trigger: trigger
        )
        try validateForbiddenCapabilities(
            implementsOMS: implementsOMS,
            connectsBroker: connectsBroker,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            providesRealCancelCommand: providesRealCancelCommand,
            providesOrderLevelCommandUI: providesOrderLevelCommandUI,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )
    }

    private static func validateTransition(
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        blockerEvidenceID: Identifier?,
        fromState: PaperOrderLocalLifecycleState?,
        toState: PaperOrderLocalLifecycleState,
        trigger: PaperOrderLocalLifecycleTrigger
    ) throws {
        let allowed: Bool
        switch (fromState, toState, trigger) {
        case (nil, .proposed, .paperProposalRecorded):
            allowed = true
        case (.proposed?, .submittedLocal, .submittedLocal):
            allowed = riskDecisionStatus == .allowed
        case (.submittedLocal?, .acceptedLocal, .acceptedLocal):
            allowed = riskDecisionStatus == .allowed
        case (.proposed?, .rejectedByPaperRisk, .rejectedByPaperRisk):
            allowed = riskDecisionStatus == .blocked && blockerEvidenceID != nil
        case (.proposed?, .cancelledLocal, let trigger),
             (.submittedLocal?, .cancelledLocal, let trigger),
             (.acceptedLocal?, .cancelledLocal, let trigger):
            allowed = trigger.canCancelLocally
        case (.proposed?, .expiredLocal, .localExpiry),
             (.submittedLocal?, .expiredLocal, .localExpiry):
            allowed = true
        case (.proposed?, .failedLocal, .deterministicLocalRule),
             (.submittedLocal?, .failedLocal, .deterministicLocalRule),
             (.acceptedLocal?, .failedLocal, .deterministicLocalRule):
            allowed = true
        default:
            allowed = false
        }

        guard allowed else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "transition",
                expected: "valid MTP-99 local paper lifecycle transition",
                actual: "\(fromState?.rawValue ?? "nil")->\(toState.rawValue):\(trigger.rawValue)"
            )
        }
    }

    private static func validateForbiddenCapabilities(
        implementsOMS: Bool,
        connectsBroker: Bool,
        implementsRealOrderStateMachine: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        providesRealCancelCommand: Bool,
        providesOrderLevelCommandUI: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("implementsOMS", implementsOMS),
            ("connectsBroker", connectsBroker),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("providesRealCancelCommand", providesRealCancelCommand),
            ("providesOrderLevelCommandUI", providesOrderLevelCommandUI),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperOrderLocalLifecycleForbiddenCapability(forbidden.0)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case transitionID
        case issueID
        case orderID
        case riskDecision
        case proposalID
        case sessionID
        case riskDecisionID
        case riskDecisionStatus
        case blockerEvidenceID
        case fromState
        case toState
        case trigger
        case symbol
        case timeframe
        case side
        case quantity
        case referencePrice
        case sourceRiskDecisionSequence
        case sourceLifecycleSequence
        case occurredAt
        case eventStream
        case validationAnchors
        case implementsOMS
        case connectsBroker
        case implementsRealOrderStateMachine
        case submitsRealOrder
        case cancelsRealOrder
        case replacesRealOrder
        case consumesExecutionReport
        case recordsBrokerFill
        case performsReconciliation
        case providesRealCancelCommand
        case providesOrderLevelCommandUI
        case providesLiveCommand
        case providesTradingButton
    }
}

/// PaperOrderLocalLifecycleTrace 聚合一个 order 的 deterministic local lifecycle transitions。
///
/// trace 保证 transition 顺序连续、状态可以首尾相接，且每个 transition 都已经是可写入 `.paper`
/// stream 的 event fact。它不保存 Runtime actor、Persistence schema、adapter object 或 UI command。
public struct PaperOrderLocalLifecycleTrace: Codable, Equatable, Sendable {
    public let orderID: Identifier
    public let transitions: [PaperOrderLocalLifecycleTransition]

    public var states: [PaperOrderLocalLifecycleState] {
        transitions.map(\.toState)
    }

    public var currentState: PaperOrderLocalLifecycleState {
        transitions.last?.toState ?? .failedLocal
    }

    public var everyTransitionHasEventFact: Bool {
        transitions.isEmpty == false && transitions.allSatisfy { $0.eventStream == .paper && $0.paperOnlyBoundaryHeld }
    }

    public init(orderID: Identifier, transitions: [PaperOrderLocalLifecycleTransition]) throws {
        guard transitions.isEmpty == false else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "transitions",
                expected: "at least one local lifecycle transition",
                actual: "empty"
            )
        }
        guard transitions.allSatisfy({ $0.orderID == orderID }) else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "orderID",
                expected: orderID.rawValue,
                actual: transitions.map(\.orderID.rawValue).joined(separator: ",")
            )
        }
        for index in transitions.indices.dropFirst() {
            let previous = transitions[index - 1]
            let current = transitions[index]
            guard current.fromState == previous.toState else {
                throw CoreError.paperOrderLocalLifecycleMismatch(
                    field: "transition.fromState",
                    expected: previous.toState.rawValue,
                    actual: current.fromState?.rawValue ?? "nil"
                )
            }
        }
        self.orderID = orderID
        self.transitions = transitions
    }
}

/// PaperOrderSimulatedFillPrecondition 说明 simulated fill 只能接在 accepted local 之后。
///
/// 该前置条件不生成 fill、不计算 fee / slippage，也不读取 market snapshot；MTP-100 才能消费它继续
/// 构建 simulated fill / fee / slippage deterministic model。
public struct PaperOrderSimulatedFillPrecondition: Codable, Equatable, Sendable {
    public let orderID: Identifier
    public let sourceLifecycleSequence: Int
    public let localState: PaperOrderLocalLifecycleState
    public let readiness: PaperOrderSimulatedFillReadiness
    public let acceptedAt: Date
    public let validationAnchors: [String]
    public let recordsBrokerFill: Bool
    public let consumesExecutionReport: Bool
    public let performsReconciliation: Bool

    public var ready: Bool {
        localState == .acceptedLocal && readiness == .readyForSimulatedFill
    }

    public init(
        orderID: Identifier,
        sourceLifecycleSequence: Int,
        localState: PaperOrderLocalLifecycleState,
        readiness: PaperOrderSimulatedFillReadiness,
        acceptedAt: Date,
        validationAnchors: [String] = [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-99-SIMULATED-FILL-PRECONDITION",
            "MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION"
        ],
        recordsBrokerFill: Bool = false,
        consumesExecutionReport: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        guard sourceLifecycleSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceLifecycleSequence)
        }
        guard localState == .acceptedLocal && readiness == .readyForSimulatedFill else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "simulatedFillPrecondition",
                expected: "acceptedLocal readyForSimulatedFill",
                actual: "\(localState.rawValue) \(readiness.rawValue)"
            )
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("recordsBrokerFill", recordsBrokerFill),
            ("consumesExecutionReport", consumesExecutionReport),
            ("performsReconciliation", performsReconciliation)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperOrderLocalLifecycleForbiddenCapability(forbidden.0)
        }
        self.orderID = orderID
        self.sourceLifecycleSequence = sourceLifecycleSequence
        self.localState = localState
        self.readiness = readiness
        self.acceptedAt = acceptedAt
        self.validationAnchors = validationAnchors
        self.recordsBrokerFill = recordsBrokerFill
        self.consumesExecutionReport = consumesExecutionReport
        self.performsReconciliation = performsReconciliation
    }
}

/// PaperOrderLocalLifecyclePublication 保存 local lifecycle transitions 写入 Event Log 后的证据。
///
/// `routeEvidence` 来自 MTP-97 routing，`replayEvidence` 来自同一 `MessageBus` replay 后重建；两者必须
/// 完全一致，才能证明每个 local lifecycle transition 都已经进入 append-only facts source。
public struct PaperOrderLocalLifecyclePublication: Codable, Equatable, Sendable {
    public let trace: PaperOrderLocalLifecycleTrace
    public let routeEvidence: [PaperRuntimeRouteEvidence]
    public let replayEvidence: [PaperRuntimeRouteEvidence]

    public var replayMatchesRouteEvidence: Bool {
        replayEvidence == routeEvidence
    }

    public var everyTransitionHasEventFact: Bool {
        routeEvidence.count == trace.transitions.count
            && routeEvidence.allSatisfy {
                $0.source == .paperLifecycleEvent
                    && $0.payloadKind == .paperOrderLocalLifecycleTransition
                    && $0.stream == .paper
            }
            && replayEvidence == routeEvidence
    }

    public init(
        trace: PaperOrderLocalLifecycleTrace,
        routeEvidence: [PaperRuntimeRouteEvidence],
        replayEvidence: [PaperRuntimeRouteEvidence]
    ) throws {
        guard trace.everyTransitionHasEventFact else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "trace.everyTransitionHasEventFact",
                expected: "true",
                actual: "false"
            )
        }
        guard routeEvidence.count == trace.transitions.count else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "routeEvidence.count",
                expected: "\(trace.transitions.count)",
                actual: "\(routeEvidence.count)"
            )
        }
        guard replayEvidence == routeEvidence else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "replayEvidence",
                expected: "same as route evidence",
                actual: "drift"
            )
        }
        self.trace = trace
        self.routeEvidence = routeEvidence
        self.replayEvidence = replayEvidence
    }
}

/// PaperOrderLocalLifecycleCoordinator 管理 MTP-99 的本地 lifecycle transition 和发布。
///
/// coordinator 是纯 Core value orchestration：它消费 MTP-98 paper risk decision，生成 local lifecycle
/// facts，并复用 MTP-97 bus routing 写入 MessageBus。它不是 OMS，不持有订单簿，不连接 broker，不提供
/// single-order cancel command，也不实现真实 submit / cancel / replace。
public struct PaperOrderLocalLifecycleCoordinator: Equatable, Sendable {
    public let routing: PaperRuntimeMessageBusRouting

    public init(routing: PaperRuntimeMessageBusRouting = PaperRuntimeMessageBusRouting()) {
        self.routing = routing
    }

    public func acceptedLocalTrace(
        orderID: Identifier,
        decision: PaperPreTradeRiskEngineDecision,
        startedAt: Date
    ) throws -> PaperOrderLocalLifecycleTrace {
        guard decision.isAccepted else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "decision.outcome",
                expected: PaperPreTradeRiskDecisionOutcome.accepted.rawValue,
                actual: decision.outcome.rawValue
            )
        }
        let riskDecision = decision.riskDecision
        let transitions = try [
            transition(
                idSuffix: "proposed",
                orderID: orderID,
                riskDecision: riskDecision,
                fromState: nil,
                toState: .proposed,
                trigger: .paperProposalRecorded,
                sourceLifecycleSequence: nil,
                occurredAt: startedAt
            ),
            transition(
                idSuffix: "submitted-local",
                orderID: orderID,
                riskDecision: riskDecision,
                fromState: .proposed,
                toState: .submittedLocal,
                trigger: .submittedLocal,
                sourceLifecycleSequence: 1,
                occurredAt: startedAt.addingTimeInterval(1)
            ),
            transition(
                idSuffix: "accepted-local",
                orderID: orderID,
                riskDecision: riskDecision,
                fromState: .submittedLocal,
                toState: .acceptedLocal,
                trigger: .acceptedLocal,
                sourceLifecycleSequence: 2,
                occurredAt: startedAt.addingTimeInterval(2)
            )
        ]
        return try PaperOrderLocalLifecycleTrace(orderID: orderID, transitions: transitions)
    }

    public func rejectedByPaperRiskTrace(
        orderID: Identifier,
        decision: PaperPreTradeRiskEngineDecision,
        startedAt: Date
    ) throws -> PaperOrderLocalLifecycleTrace {
        guard decision.isRejected else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "decision.outcome",
                expected: PaperPreTradeRiskDecisionOutcome.rejected.rawValue,
                actual: decision.outcome.rawValue
            )
        }
        let riskDecision = decision.riskDecision
        let transitions = try [
            transition(
                idSuffix: "proposed",
                orderID: orderID,
                riskDecision: riskDecision,
                fromState: nil,
                toState: .proposed,
                trigger: .paperProposalRecorded,
                sourceLifecycleSequence: nil,
                occurredAt: startedAt
            ),
            transition(
                idSuffix: "rejected-by-paper-risk",
                orderID: orderID,
                riskDecision: riskDecision,
                fromState: .proposed,
                toState: .rejectedByPaperRisk,
                trigger: .rejectedByPaperRisk,
                sourceLifecycleSequence: 1,
                occurredAt: startedAt.addingTimeInterval(1)
            )
        ]
        return try PaperOrderLocalLifecycleTrace(orderID: orderID, transitions: transitions)
    }

    public func cancelLocally(
        orderID: Identifier,
        decision: PaperPreTradeRiskEngineDecision,
        fromState: PaperOrderLocalLifecycleState,
        trigger: PaperOrderLocalLifecycleTrigger,
        sourceLifecycleSequence: Int,
        occurredAt: Date
    ) throws -> PaperOrderLocalLifecycleTransition {
        guard trigger.canCancelLocally else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: "cancelledLocal.trigger",
                expected: "sessionClose/sessionReset/localExpiry/deterministicLocalRule",
                actual: trigger.rawValue
            )
        }
        return try transition(
            idSuffix: "cancelled-local-\(trigger.rawValue)",
            orderID: orderID,
            riskDecision: decision.riskDecision,
            fromState: fromState,
            toState: .cancelledLocal,
            trigger: trigger,
            sourceLifecycleSequence: sourceLifecycleSequence,
            occurredAt: occurredAt
        )
    }

    public func expireLocally(
        orderID: Identifier,
        decision: PaperPreTradeRiskEngineDecision,
        fromState: PaperOrderLocalLifecycleState,
        sourceLifecycleSequence: Int,
        occurredAt: Date
    ) throws -> PaperOrderLocalLifecycleTransition {
        try transition(
            idSuffix: "expired-local",
            orderID: orderID,
            riskDecision: decision.riskDecision,
            fromState: fromState,
            toState: .expiredLocal,
            trigger: .localExpiry,
            sourceLifecycleSequence: sourceLifecycleSequence,
            occurredAt: occurredAt
        )
    }

    public func failLocally(
        orderID: Identifier,
        decision: PaperPreTradeRiskEngineDecision,
        fromState: PaperOrderLocalLifecycleState,
        sourceLifecycleSequence: Int,
        occurredAt: Date
    ) throws -> PaperOrderLocalLifecycleTransition {
        try transition(
            idSuffix: "failed-local",
            orderID: orderID,
            riskDecision: decision.riskDecision,
            fromState: fromState,
            toState: .failedLocal,
            trigger: .deterministicLocalRule,
            sourceLifecycleSequence: sourceLifecycleSequence,
            occurredAt: occurredAt
        )
    }

    public func simulatedFillPrecondition(
        from trace: PaperOrderLocalLifecycleTrace,
        sourceLifecycleSequence: Int
    ) throws -> PaperOrderSimulatedFillPrecondition {
        let accepted = try trace.transitions.last(where: \.isSimulatedFillPrecondition).unwrap(
            field: "acceptedLocalTransition",
            expected: "accepted local transition before simulated fill"
        )
        return try PaperOrderSimulatedFillPrecondition(
            orderID: trace.orderID,
            sourceLifecycleSequence: sourceLifecycleSequence,
            localState: accepted.toState,
            readiness: .readyForSimulatedFill,
            acceptedAt: accepted.occurredAt
        )
    }

    @discardableResult
    public func publish(
        _ trace: PaperOrderLocalLifecycleTrace,
        to messageBus: inout MessageBus,
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> PaperOrderLocalLifecyclePublication {
        let firstNewSequence = messageBus.envelopes.count + 1
        let inputs = trace.transitions.map {
            PaperRuntimeRouteInput.paperLifecycleEvent(.orderLocalLifecycleTransitionRecorded($0))
        }
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
        return try PaperOrderLocalLifecyclePublication(
            trace: trace,
            routeEvidence: routeEvidence,
            replayEvidence: replayEvidence
        )
    }

    private func transition(
        idSuffix: String,
        orderID: Identifier,
        riskDecision: PaperActionProposalRiskDecision,
        fromState: PaperOrderLocalLifecycleState?,
        toState: PaperOrderLocalLifecycleState,
        trigger: PaperOrderLocalLifecycleTrigger,
        sourceLifecycleSequence: Int?,
        occurredAt: Date
    ) throws -> PaperOrderLocalLifecycleTransition {
        try PaperOrderLocalLifecycleTransition(
            transitionID: try Identifier("\(orderID.rawValue)-\(idSuffix)"),
            orderID: orderID,
            riskDecision: riskDecision,
            fromState: fromState,
            toState: toState,
            trigger: trigger,
            sourceLifecycleSequence: sourceLifecycleSequence,
            occurredAt: occurredAt
        )
    }
}

/// PaperOrderLocalLifecycleCoordinatorFixture 提供 MTP-99 deterministic tracer bullets。
///
/// fixture 覆盖 accepted local path、rejected by paper risk path、Event Log / Replay publication 和
/// simulated fill precondition。它只用于 tests / PR evidence，不代表真实订单执行、broker order 或 OMS。
public enum PaperOrderLocalLifecycleCoordinatorFixture {
    public static let orderID = try! Identifier("mtp-99-paper-order-local")
    public static let rejectedOrderID = try! Identifier("mtp-99-paper-order-rejected-local")
    public static let correlationID = deterministicUUID("11111111-1111-4111-8111-111111111199")
    public static let rootCausationID = deterministicUUID("22222222-2222-4222-8222-222222222199")
    public static let acceptedEnvelopeIDs: [UUID] = [
        deterministicUUID("99000000-0000-4000-8000-000000000001"),
        deterministicUUID("99000000-0000-4000-8000-000000000002"),
        deterministicUUID("99000000-0000-4000-8000-000000000003")
    ]
    public static let rejectedEnvelopeIDs: [UUID] = [
        deterministicUUID("99000000-0000-4000-8000-000000000101"),
        deterministicUUID("99000000-0000-4000-8000-000000000102")
    ]

    public static let deterministicClock: TradingClock = {
        do {
            return try TradingClock(
                clockID: try Identifier("mtp-99-paper-order-local-lifecycle-clock"),
                issueID: try Identifier("MTP-99"),
                ticks: [
                    TradingClockTick(
                        sequence: 1,
                        instant: Date(timeIntervalSince1970: 5_000),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 5_001),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 3,
                        instant: Date(timeIntervalSince1970: 5_002),
                        source: .deterministicFixture
                    )
                ],
                validationAnchors: [
                    "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
                    "MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS",
                    "MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION"
                ]
            )
        } catch {
            preconditionFailure("Invalid MTP-99 lifecycle clock fixture: \(error)")
        }
    }()

    public static func acceptedTrace() throws -> PaperOrderLocalLifecycleTrace {
        try PaperOrderLocalLifecycleCoordinator().acceptedLocalTrace(
            orderID: orderID,
            decision: PaperPreTradeRiskEngineFixture.acceptedDecision(),
            startedAt: Date(timeIntervalSince1970: 5_010)
        )
    }

    public static func rejectedTrace() throws -> PaperOrderLocalLifecycleTrace {
        try PaperOrderLocalLifecycleCoordinator().rejectedByPaperRiskTrace(
            orderID: rejectedOrderID,
            decision: PaperPreTradeRiskEngineFixture.rejectedDecision(),
            startedAt: Date(timeIntervalSince1970: 5_020)
        )
    }

    public static func publishedAcceptedTrace() throws -> (MessageBus, PaperOrderLocalLifecyclePublication) {
        var messageBus = try MessageBus()
        let publication = try PaperOrderLocalLifecycleCoordinator().publish(
            acceptedTrace(),
            to: &messageBus,
            clock: deterministicClock,
            envelopeIDs: acceptedEnvelopeIDs,
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

private extension Optional {
    func unwrap(field: String, expected: String) throws -> Wrapped {
        guard let value = self else {
            throw CoreError.paperOrderLocalLifecycleMismatch(
                field: field,
                expected: expected,
                actual: "nil"
            )
        }
        return value
    }
}
