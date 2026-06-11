import DomainModel
import Foundation
import MessageBus

/// ReleaseV020ProductAwareOMSOrderSourceKind 标记 #583 OMS 输入来自 Spot 还是 USDⓈ-M Perpetual。
///
/// 该枚举只区分 release v0.2.0 允许的两个 product type，不扩展到 margin、COIN-M、
/// options 或非 Binance venue。
public enum ReleaseV020ProductAwareOMSOrderSourceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spot
    case perpetual
}

/// ReleaseV020ProductAwareOMSOrderState 是 #583 product-aware OMS 的本地订单状态。
///
/// 状态机只生成 deterministic event log / replay evidence；它不是 production OMS runtime，
/// 不写真实订单存储，也不授权 ExecutionClient、broker 或真实 submit / cancel / replace。
public enum ReleaseV020ProductAwareOMSOrderState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case new
    case accepted
    case submitted
    case partiallyFilled
    case filled
    case cancelled
    case rejected
}

/// ReleaseV020ProductAwareOMSTransitionTrigger 描述 #583 append-only OMS transition 的触发原因。
public enum ReleaseV020ProductAwareOMSTransitionTrigger: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case orderIntentAccepted = "order intent accepted"
    case submitPrepared = "submit prepared"
    case partialFillObserved = "partial fill observed"
    case fillObserved = "fill observed"
    case cancelObserved = "cancel observed"
    case localRejectObserved = "local reject observed"
}

/// ReleaseV020ProductAwareOMSPath 覆盖 #583 需要的 Spot / Perp lifecycle evidence path。
public enum ReleaseV020ProductAwareOMSPath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spotFilled = "spot-filled"
    case spotRejected = "spot-rejected"
    case perpetualFilled = "perpetual-filled"
    case perpetualCancelled = "perpetual-cancelled"

    public var productType: ProductType {
        switch self {
        case .spotFilled, .spotRejected:
            .spot
        case .perpetualFilled, .perpetualCancelled:
            .usdsPerpetual
        }
    }

    public var terminalState: ReleaseV020ProductAwareOMSOrderState {
        switch self {
        case .spotFilled, .perpetualFilled:
            .filled
        case .spotRejected:
            .rejected
        case .perpetualCancelled:
            .cancelled
        }
    }
}

/// ReleaseV020ProductAwareOMSOrderIntentSnapshot 是 #583 接收 #581/#582 order intent 的统一快照。
///
/// Snapshot 只复制执行前 evidence 的必要字段，让 OMS 状态机保持 product-aware，同时不重新打开
/// RiskEngine、ExecutionClient、broker gateway 或真实订单能力。
public struct ReleaseV020ProductAwareOMSOrderIntentSnapshot: Codable, Equatable, Sendable {
    public let sourceKind: ReleaseV020ProductAwareOMSOrderSourceKind
    public let sourceOrderIntentID: Identifier
    public let sourceInputID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let sourceProductAwareIntentID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let action: String
    public let side: String
    public let quantity: Quantity
    public let referencePrice: Price
    public let notional: Double
    public let reduceOnly: Bool
    public let createdAt: Date
    public let sourceValidationAnchors: [String]
    public let sourceBoundaryHeld: Bool
    public let requiresOMSBeforeExecution: Bool
    public let requiresEventStoreBeforeExecution: Bool
    public let requiresKillSwitchBeforeExecution: Bool
    public let requiresNoTradeGateBeforeExecution: Bool
    public let productionTradingEnabledByDefault: Bool
    public let authorizesTradingExecution: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let executesLeverageAction: Bool
    public let executesMarginAction: Bool
    public let submitsRealOrder: Bool

    public init(spotOrderIntent: ReleaseV020SpotExecutionAlgorithmOrderIntent) throws {
        try self.init(
            sourceKind: .spot,
            sourceOrderIntentID: spotOrderIntent.orderIntentID,
            sourceInputID: spotOrderIntent.sourceInputID,
            sourceRiskDecisionID: spotOrderIntent.sourceRiskDecisionID,
            sourceProductAwareIntentID: spotOrderIntent.sourceProductAwareIntentID,
            instrument: spotOrderIntent.instrument,
            targetExposure: spotOrderIntent.targetExposure,
            action: "spot.\(spotOrderIntent.side.rawValue)",
            side: spotOrderIntent.side.rawValue,
            quantity: spotOrderIntent.quantity,
            referencePrice: spotOrderIntent.referencePrice,
            notional: spotOrderIntent.notional,
            reduceOnly: false,
            createdAt: spotOrderIntent.createdAt,
            sourceValidationAnchors: spotOrderIntent.validationAnchors,
            sourceBoundaryHeld: spotOrderIntent.boundaryHeld,
            requiresOMSBeforeExecution: spotOrderIntent.requiresOMSBeforeExecution,
            requiresEventStoreBeforeExecution: spotOrderIntent.requiresEventStoreBeforeExecution,
            requiresKillSwitchBeforeExecution: spotOrderIntent.requiresKillSwitchBeforeExecution,
            requiresNoTradeGateBeforeExecution: spotOrderIntent.requiresNoTradeGateBeforeExecution,
            productionTradingEnabledByDefault: spotOrderIntent.productionTradingEnabledByDefault,
            authorizesTradingExecution: spotOrderIntent.authorizesTradingExecution,
            callsExecutionClient: spotOrderIntent.callsExecutionClient,
            touchesBrokerGateway: spotOrderIntent.touchesBrokerGateway,
            executesLeverageAction: false,
            executesMarginAction: false,
            submitsRealOrder: spotOrderIntent.submitsRealOrder
        )
    }

    public init(perpetualOrderIntent: ReleaseV020PerpetualExecutionAlgorithmOrderIntent) throws {
        try self.init(
            sourceKind: .perpetual,
            sourceOrderIntentID: perpetualOrderIntent.orderIntentID,
            sourceInputID: perpetualOrderIntent.sourceInputID,
            sourceRiskDecisionID: perpetualOrderIntent.sourceRiskDecisionID,
            sourceProductAwareIntentID: perpetualOrderIntent.sourceProductAwareIntentID,
            instrument: perpetualOrderIntent.instrument,
            targetExposure: perpetualOrderIntent.targetExposure,
            action: perpetualOrderIntent.action.rawValue,
            side: perpetualOrderIntent.side.rawValue,
            quantity: perpetualOrderIntent.quantity,
            referencePrice: perpetualOrderIntent.referencePrice,
            notional: perpetualOrderIntent.notional,
            reduceOnly: perpetualOrderIntent.reduceOnly,
            createdAt: perpetualOrderIntent.createdAt,
            sourceValidationAnchors: perpetualOrderIntent.validationAnchors,
            sourceBoundaryHeld: perpetualOrderIntent.boundaryHeld,
            requiresOMSBeforeExecution: perpetualOrderIntent.requiresOMSBeforeExecution,
            requiresEventStoreBeforeExecution: perpetualOrderIntent.requiresEventStoreBeforeExecution,
            requiresKillSwitchBeforeExecution: perpetualOrderIntent.requiresKillSwitchBeforeExecution,
            requiresNoTradeGateBeforeExecution: perpetualOrderIntent.requiresNoTradeGateBeforeExecution,
            productionTradingEnabledByDefault: perpetualOrderIntent.productionTradingEnabledByDefault,
            authorizesTradingExecution: perpetualOrderIntent.authorizesTradingExecution,
            callsExecutionClient: perpetualOrderIntent.callsExecutionClient,
            touchesBrokerGateway: perpetualOrderIntent.touchesBrokerGateway,
            executesLeverageAction: perpetualOrderIntent.executesLeverageAction,
            executesMarginAction: perpetualOrderIntent.executesMarginAction,
            submitsRealOrder: perpetualOrderIntent.submitsRealOrder
        )
    }

    public init(
        sourceKind: ReleaseV020ProductAwareOMSOrderSourceKind,
        sourceOrderIntentID: Identifier,
        sourceInputID: Identifier,
        sourceRiskDecisionID: Identifier,
        sourceProductAwareIntentID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        action: String,
        side: String,
        quantity: Quantity,
        referencePrice: Price,
        notional: Double,
        reduceOnly: Bool,
        createdAt: Date,
        sourceValidationAnchors: [String],
        sourceBoundaryHeld: Bool,
        requiresOMSBeforeExecution: Bool = true,
        requiresEventStoreBeforeExecution: Bool = true,
        requiresKillSwitchBeforeExecution: Bool = true,
        requiresNoTradeGateBeforeExecution: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        authorizesTradingExecution: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        executesLeverageAction: Bool = false,
        executesMarginAction: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard instrument.productType == sourceKind.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.instrumentProductType",
                expected: sourceKind.productType.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.sourceBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.quantity",
                expected: "positive quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard abs(notional - quantity.rawValue * referencePrice.rawValue) < 0.000_000_1 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.notional",
                expected: "quantity * referencePrice",
                actual: "\(notional)"
            )
        }
        for requiredGate in [
            ("requiresOMSBeforeExecution", requiresOMSBeforeExecution),
            ("requiresEventStoreBeforeExecution", requiresEventStoreBeforeExecution),
            ("requiresKillSwitchBeforeExecution", requiresKillSwitchBeforeExecution),
            ("requiresNoTradeGateBeforeExecution", requiresNoTradeGateBeforeExecution)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.\(requiredGate.0)"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("executesLeverageAction", executesLeverageAction),
            ("executesMarginAction", executesMarginAction),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.\(forbiddenFlag.0)"
            )
        }

        self.sourceKind = sourceKind
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceInputID = sourceInputID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.sourceProductAwareIntentID = sourceProductAwareIntentID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.action = action
        self.side = side
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.notional = notional
        self.reduceOnly = reduceOnly
        self.createdAt = createdAt
        self.sourceValidationAnchors = sourceValidationAnchors
        self.sourceBoundaryHeld = sourceBoundaryHeld
        self.requiresOMSBeforeExecution = requiresOMSBeforeExecution
        self.requiresEventStoreBeforeExecution = requiresEventStoreBeforeExecution
        self.requiresKillSwitchBeforeExecution = requiresKillSwitchBeforeExecution
        self.requiresNoTradeGateBeforeExecution = requiresNoTradeGateBeforeExecution
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.authorizesTradingExecution = authorizesTradingExecution
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.executesLeverageAction = executesLeverageAction
        self.executesMarginAction = executesMarginAction
        self.submitsRealOrder = submitsRealOrder
    }

    public var snapshotBoundaryHeld: Bool {
        instrument.productType == sourceKind.productType
            && sourceBoundaryHeld
            && quantity.rawValue > 0
            && abs(notional - quantity.rawValue * referencePrice.rawValue) < 0.000_000_1
            && requiresOMSBeforeExecution
            && requiresEventStoreBeforeExecution
            && requiresKillSwitchBeforeExecution
            && requiresNoTradeGateBeforeExecution
            && productionTradingEnabledByDefault == false
            && authorizesTradingExecution == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && executesLeverageAction == false
            && executesMarginAction == false
            && submitsRealOrder == false
    }
}

/// ReleaseV020ProductAwareOMSTransition 是 #583 本地 OMS append-only event log 的单条 transition。
public struct ReleaseV020ProductAwareOMSTransition: Codable, Equatable, Sendable {
    public let transitionID: Identifier
    public let orderID: Identifier
    public let sourceOrderIntentID: Identifier
    public let instrument: InstrumentIdentity
    public let fromState: ReleaseV020ProductAwareOMSOrderState
    public let trigger: ReleaseV020ProductAwareOMSTransitionTrigger
    public let toState: ReleaseV020ProductAwareOMSOrderState
    public let sequence: Int
    public let validationAnchors: [String]
    public let appendOnlyAuditEvent: Bool
    public let eventStoreWriteRequired: Bool
    public let writesProductionOrderStore: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public init(
        transitionID: Identifier,
        orderID: Identifier,
        sourceOrderIntentID: Identifier,
        instrument: InstrumentIdentity,
        fromState: ReleaseV020ProductAwareOMSOrderState,
        trigger: ReleaseV020ProductAwareOMSTransitionTrigger,
        toState: ReleaseV020ProductAwareOMSOrderState,
        sequence: Int,
        validationAnchors: [String] = ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors,
        appendOnlyAuditEvent: Bool = true,
        eventStoreWriteRequired: Bool = true,
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
                field: "releaseV020ProductAwareOMS.transition",
                expected: Self.allowedTransitionDescriptions.sorted().joined(separator: ","),
                actual: "\(fromState.rawValue)|\(trigger.rawValue)|\(toState.rawValue)"
            )
        }
        guard ProductType.allCases.contains(instrument.productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.instrumentProductType",
                expected: ProductType.supportedRawValues.joined(separator: ","),
                actual: instrument.productType.rawValue
            )
        }
        guard validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.validationAnchors",
                expected: ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("appendOnlyAuditEvent", appendOnlyAuditEvent),
            ("eventStoreWriteRequired", eventStoreWriteRequired)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.\(requiredFlag.0)"
            )
        }
        for forbiddenFlag in [
            ("writesProductionOrderStore", writesProductionOrderStore),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.\(forbiddenFlag.0)"
            )
        }

        self.transitionID = transitionID
        self.orderID = orderID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.instrument = instrument
        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sequence = sequence
        self.validationAnchors = validationAnchors
        self.appendOnlyAuditEvent = appendOnlyAuditEvent
        self.eventStoreWriteRequired = eventStoreWriteRequired
        self.writesProductionOrderStore = writesProductionOrderStore
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
    }

    public var transitionBoundaryHeld: Bool {
        sequence > 0
            && Self.allowedTransition(from: fromState, trigger: trigger, to: toState)
            && validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors
            && appendOnlyAuditEvent
            && eventStoreWriteRequired
            && writesProductionOrderStore == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }

    public static func allowedTransition(
        from fromState: ReleaseV020ProductAwareOMSOrderState,
        trigger: ReleaseV020ProductAwareOMSTransitionTrigger,
        to toState: ReleaseV020ProductAwareOMSOrderState
    ) -> Bool {
        allowedTransitionDescriptions.contains("\(fromState.rawValue)|\(trigger.rawValue)|\(toState.rawValue)")
    }

    public static let allowedTransitionDescriptions: Set<String> = [
        "new|order intent accepted|accepted",
        "accepted|submit prepared|submitted",
        "submitted|partial fill observed|partiallyFilled",
        "partiallyFilled|fill observed|filled",
        "submitted|fill observed|filled",
        "submitted|cancel observed|cancelled",
        "accepted|local reject observed|rejected",
        "submitted|local reject observed|rejected"
    ]
}

/// ReleaseV020ProductAwareOMSEventLog 汇总单个 product-aware order lifecycle path。
public struct ReleaseV020ProductAwareOMSEventLog: Codable, Equatable, Sendable {
    public let eventLogID: Identifier
    public let path: ReleaseV020ProductAwareOMSPath
    public let orderID: Identifier
    public let orderIntent: ReleaseV020ProductAwareOMSOrderIntentSnapshot
    public let transitions: [ReleaseV020ProductAwareOMSTransition]
    public let eventStream: EventStreamID
    public let validationAnchors: [String]
    public let appendOnlyAuditEvidence: Bool
    public let deterministicEvidence: Bool
    public let productionOrderStoreWritten: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public init(
        eventLogID: Identifier,
        path: ReleaseV020ProductAwareOMSPath,
        orderID: Identifier,
        orderIntent: ReleaseV020ProductAwareOMSOrderIntentSnapshot,
        transitions: [ReleaseV020ProductAwareOMSTransition],
        eventStream: EventStreamID = ReleaseV020ProductAwareOMSStateMachine.requiredEventStream,
        validationAnchors: [String] = ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors,
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
        self.transitions = transitions
        self.eventStream = eventStream
        self.validationAnchors = validationAnchors
        self.appendOnlyAuditEvidence = appendOnlyAuditEvidence
        self.deterministicEvidence = deterministicEvidence
        self.productionOrderStoreWritten = productionOrderStoreWritten
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder

        try validate()
    }

    public var terminalState: ReleaseV020ProductAwareOMSOrderState? {
        transitions.last?.toState
    }

    public var statesCovered: Set<ReleaseV020ProductAwareOMSOrderState> {
        Set(transitions.flatMap { [$0.fromState, $0.toState] })
    }

    public var eventLogBoundaryHeld: Bool {
        transitions.isEmpty == false
            && orderIntent.snapshotBoundaryHeld
            && orderIntent.instrument.productType == path.productType
            && terminalState == path.terminalState
            && transitions.allSatisfy(\.transitionBoundaryHeld)
            && transitions.map(\.orderID).allSatisfy { $0 == orderID }
            && transitions.map(\.sourceOrderIntentID).allSatisfy { $0 == orderIntent.sourceOrderIntentID }
            && transitions.map(\.instrument).allSatisfy { $0 == orderIntent.instrument }
            && transitions.first?.fromState == .new
            && sequencesAreStrictlyIncreasing
            && validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors
            && eventStream == ReleaseV020ProductAwareOMSStateMachine.requiredEventStream
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

    private func validate() throws {
        guard eventLogBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.eventLogBoundary",
                expected: "GH-583 event log boundary held",
                actual: "mismatch"
            )
        }
    }
}

/// ReleaseV020ProductAwareOMSReplayResult 是 #583 从 event log replay 恢复订单状态的证据。
public struct ReleaseV020ProductAwareOMSReplayResult: Codable, Equatable, Sendable {
    public let replayID: Identifier
    public let sourceEventLogID: Identifier
    public let orderID: Identifier
    public let sourceOrderIntentID: Identifier
    public let instrument: InstrumentIdentity
    public let restoredState: ReleaseV020ProductAwareOMSOrderState
    public let restoredFromTransitionCount: Int
    public let restoredSequence: Int
    public let replayedAt: Date
    public let validationAnchors: [String]
    public let deterministicReplay: Bool
    public let writesProductionOrderStore: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public init(
        replayID: Identifier,
        sourceEventLog: ReleaseV020ProductAwareOMSEventLog,
        replayedAt: Date,
        validationAnchors: [String] = ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors,
        deterministicReplay: Bool = true,
        writesProductionOrderStore: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sourceEventLog.eventLogBoundaryHeld, let terminalState = sourceEventLog.terminalState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.replaySourceEventLog",
                expected: "event log boundary held with terminal state",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.replayValidationAnchors",
                expected: ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard deterministicReplay else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV020ProductAwareOMS.deterministicReplay")
        }
        for forbiddenFlag in [
            ("writesProductionOrderStore", writesProductionOrderStore),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.replay.\(forbiddenFlag.0)"
            )
        }

        self.replayID = replayID
        self.sourceEventLogID = sourceEventLog.eventLogID
        self.orderID = sourceEventLog.orderID
        self.sourceOrderIntentID = sourceEventLog.orderIntent.sourceOrderIntentID
        self.instrument = sourceEventLog.orderIntent.instrument
        self.restoredState = terminalState
        self.restoredFromTransitionCount = sourceEventLog.transitions.count
        self.restoredSequence = sourceEventLog.transitions.map(\.sequence).max() ?? 0
        self.replayedAt = replayedAt
        self.validationAnchors = validationAnchors
        self.deterministicReplay = deterministicReplay
        self.writesProductionOrderStore = writesProductionOrderStore
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
    }

    public var replayBoundaryHeld: Bool {
        restoredFromTransitionCount > 0
            && restoredSequence > 0
            && validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors
            && deterministicReplay
            && writesProductionOrderStore == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }
}

/// ReleaseV020ProductAwareOMSStateMachineEvidence 是 #583 的完整 deterministic evidence。
public struct ReleaseV020ProductAwareOMSStateMachineEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let eventLogs: [ReleaseV020ProductAwareOMSEventLog]
    public let replayResults: [ReleaseV020ProductAwareOMSReplayResult]
    public let validationAnchors: [String]
    public let spotLifecyclePasses: Bool
    public let perpetualLifecyclePasses: Bool
    public let illegalTransitionGuarded: Bool
    public let replayRestoresOrderState: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let nonBinanceVenueEnabled: Bool
    public let unsupportedProductTypeEnabled: Bool
    public let nonEMARSIStrategyEnabled: Bool

    public init(
        evidenceID: Identifier,
        eventLogs: [ReleaseV020ProductAwareOMSEventLog],
        replayResults: [ReleaseV020ProductAwareOMSReplayResult],
        validationAnchors: [String] = ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors,
        spotLifecyclePasses: Bool = true,
        perpetualLifecyclePasses: Bool = true,
        illegalTransitionGuarded: Bool = true,
        replayRestoresOrderState: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        unsupportedProductTypeEnabled: Bool = false,
        nonEMARSIStrategyEnabled: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.eventLogs = eventLogs
        self.replayResults = replayResults
        self.validationAnchors = validationAnchors
        self.spotLifecyclePasses = spotLifecyclePasses
        self.perpetualLifecyclePasses = perpetualLifecyclePasses
        self.illegalTransitionGuarded = illegalTransitionGuarded
        self.replayRestoresOrderState = replayRestoresOrderState
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.unsupportedProductTypeEnabled = unsupportedProductTypeEnabled
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled

        try validate()
    }

    public var statesCovered: Set<ReleaseV020ProductAwareOMSOrderState> {
        Set(eventLogs.flatMap(\.statesCovered))
    }

    public var productTypesCovered: Set<ProductType> {
        Set(eventLogs.map(\.orderIntent.instrument.productType))
    }

    public var evidenceBoundaryHeld: Bool {
        eventLogs.count == ReleaseV020ProductAwareOMSPath.allCases.count
            && Set(eventLogs.map(\.path)) == Set(ReleaseV020ProductAwareOMSPath.allCases)
            && eventLogs.allSatisfy(\.eventLogBoundaryHeld)
            && replayResults.count == eventLogs.count
            && replayResults.allSatisfy(\.replayBoundaryHeld)
            && Set(replayResults.map(\.sourceEventLogID)) == Set(eventLogs.map(\.eventLogID))
            && zip(eventLogs.sortedForReplay, replayResults.sortedForReplay).allSatisfy { log, replay in
                log.terminalState == replay.restoredState
                    && log.orderID == replay.orderID
                    && log.orderIntent.sourceOrderIntentID == replay.sourceOrderIntentID
            }
            && statesCovered == Set(ReleaseV020ProductAwareOMSOrderState.allCases)
            && productTypesCovered == Set(ProductType.allCases)
            && validationAnchors == ReleaseV020ProductAwareOMSStateMachine.requiredValidationAnchors
            && spotLifecyclePasses
            && perpetualLifecyclePasses
            && illegalTransitionGuarded
            && replayRestoresOrderState
            && forbiddenFlagsRemainClosed
    }

    private var forbiddenFlagsRemainClosed: Bool {
        [
            productionTradingEnabledByDefault,
            productionOMSRuntimeEnabledByDefault,
            callsExecutionClient,
            touchesBrokerGateway,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            nonBinanceVenueEnabled,
            unsupportedProductTypeEnabled,
            nonEMARSIStrategyEnabled
        ].allSatisfy { $0 == false }
    }

    private func validate() throws {
        guard evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.evidenceBoundary",
                expected: "GH-583 product-aware OMS evidence boundary held",
                actual: "mismatch"
            )
        }
    }
}

/// ReleaseV020ProductAwareOMSReplay 提供 #583 本地 replay 恢复入口。
public enum ReleaseV020ProductAwareOMSReplay {
    public static func restore(
        replayID: Identifier,
        eventLog: ReleaseV020ProductAwareOMSEventLog,
        replayedAt: Date
    ) throws -> ReleaseV020ProductAwareOMSReplayResult {
        try ReleaseV020ProductAwareOMSReplayResult(
            replayID: replayID,
            sourceEventLog: eventLog,
            replayedAt: replayedAt
        )
    }
}

/// ReleaseV020ProductAwareOMSStateMachine 是 #583 的 product-aware 本地 OMS 状态机。
public struct ReleaseV020ProductAwareOMSStateMachine: Codable, Equatable, Sendable {
    public let stateMachineID: Identifier
    public let releaseVenue: Identifier
    public let releaseProductTypes: [ProductType]
    public let releaseStrategyKinds: [String]
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let nonBinanceVenueEnabled: Bool
    public let unsupportedProductTypeEnabled: Bool
    public let nonEMARSIStrategyEnabled: Bool

    public init(
        stateMachineID: Identifier,
        releaseVenue: Identifier = Self.requiredReleaseVenue,
        releaseProductTypes: [ProductType] = Self.requiredReleaseProductTypes,
        releaseStrategyKinds: [String] = Self.requiredReleaseStrategyKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        unsupportedProductTypeEnabled: Bool = false,
        nonEMARSIStrategyEnabled: Bool = false
    ) throws {
        self.stateMachineID = stateMachineID
        self.releaseVenue = releaseVenue
        self.releaseProductTypes = releaseProductTypes
        self.releaseStrategyKinds = releaseStrategyKinds
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.unsupportedProductTypeEnabled = unsupportedProductTypeEnabled
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled

        try validate()
    }

    public func eventLog(
        path: ReleaseV020ProductAwareOMSPath,
        orderIntent: ReleaseV020ProductAwareOMSOrderIntentSnapshot,
        sourceSequenceBase: Int
    ) throws -> ReleaseV020ProductAwareOMSEventLog {
        guard sourceSequenceBase > 0 else {
            throw CoreError.invalidEventSequence(sourceSequenceBase)
        }
        guard orderIntent.instrument.productType == path.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.pathProductType",
                expected: path.productType.rawValue,
                actual: orderIntent.instrument.productType.rawValue
            )
        }
        let orderID = Identifier.constant("\(stateMachineID.rawValue)-\(path.rawValue)-order")
        return try ReleaseV020ProductAwareOMSEventLog(
            eventLogID: Identifier.constant("\(orderID.rawValue)-event-log"),
            path: path,
            orderID: orderID,
            orderIntent: orderIntent,
            transitions: transitions(
                orderID: orderID,
                orderIntent: orderIntent,
                path: path,
                sourceSequenceBase: sourceSequenceBase
            )
        )
    }

    public func deterministicEvidence(
        evidenceID: Identifier,
        spotOrderIntent: ReleaseV020SpotExecutionAlgorithmOrderIntent,
        perpetualOrderIntent: ReleaseV020PerpetualExecutionAlgorithmOrderIntent,
        replayedAt: Date
    ) throws -> ReleaseV020ProductAwareOMSStateMachineEvidence {
        let spotSnapshot = try ReleaseV020ProductAwareOMSOrderIntentSnapshot(spotOrderIntent: spotOrderIntent)
        let perpetualSnapshot = try ReleaseV020ProductAwareOMSOrderIntentSnapshot(
            perpetualOrderIntent: perpetualOrderIntent
        )
        let logs = try [
            eventLog(path: .spotFilled, orderIntent: spotSnapshot, sourceSequenceBase: 100),
            eventLog(path: .spotRejected, orderIntent: spotSnapshot, sourceSequenceBase: 200),
            eventLog(path: .perpetualFilled, orderIntent: perpetualSnapshot, sourceSequenceBase: 300),
            eventLog(path: .perpetualCancelled, orderIntent: perpetualSnapshot, sourceSequenceBase: 400)
        ]
        let replayResults = try logs.map { log in
            try ReleaseV020ProductAwareOMSReplay.restore(
                replayID: Identifier.constant("\(log.eventLogID.rawValue)-replay"),
                eventLog: log,
                replayedAt: replayedAt
            )
        }
        return try ReleaseV020ProductAwareOMSStateMachineEvidence(
            evidenceID: evidenceID,
            eventLogs: logs,
            replayResults: replayResults,
            validationAnchors: validationAnchors,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionOMSRuntimeEnabledByDefault: productionOMSRuntimeEnabledByDefault,
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            unsupportedProductTypeEnabled: unsupportedProductTypeEnabled,
            nonEMARSIStrategyEnabled: nonEMARSIStrategyEnabled
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020ProductAwareOMSStateMachine {
        try ReleaseV020ProductAwareOMSStateMachine(
            stateMachineID: Identifier.constant("gh-583-product-aware-oms-state-machine")
        )
    }

    public static let requiredReleaseVenue = Identifier.constant("binance", field: "releaseV020ProductAwareOMS.venue")
    public static let requiredReleaseProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredReleaseStrategyKinds = ["EMA", "RSI"]
    public static let requiredEventStream = EventStreamID(rawValue: "execution-oms-local")
    public static let requiredValidationAnchors = [
        "GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE",
        "GH-583-SPOT-LIFECYCLE",
        "GH-583-PERP-LIFECYCLE",
        "GH-583-ILLEGAL-TRANSITION-REJECTED",
        "GH-583-REPLAY-RESTORES-ORDER-STATE",
        "TVM-RELEASE-V020-PRODUCT-AWARE-OMS-STATE-MACHINE"
    ]

    private func transitions(
        orderID: Identifier,
        orderIntent: ReleaseV020ProductAwareOMSOrderIntentSnapshot,
        path: ReleaseV020ProductAwareOMSPath,
        sourceSequenceBase: Int
    ) throws -> [ReleaseV020ProductAwareOMSTransition] {
        switch path {
        case .spotFilled, .perpetualFilled:
            return try [
                transition(orderID, orderIntent, .new, .orderIntentAccepted, .accepted, sourceSequenceBase + 1),
                transition(orderID, orderIntent, .accepted, .submitPrepared, .submitted, sourceSequenceBase + 2),
                transition(
                    orderID,
                    orderIntent,
                    .submitted,
                    .partialFillObserved,
                    .partiallyFilled,
                    sourceSequenceBase + 3
                ),
                transition(orderID, orderIntent, .partiallyFilled, .fillObserved, .filled, sourceSequenceBase + 4)
            ]
        case .spotRejected:
            return try [
                transition(orderID, orderIntent, .new, .orderIntentAccepted, .accepted, sourceSequenceBase + 1),
                transition(orderID, orderIntent, .accepted, .localRejectObserved, .rejected, sourceSequenceBase + 2)
            ]
        case .perpetualCancelled:
            return try [
                transition(orderID, orderIntent, .new, .orderIntentAccepted, .accepted, sourceSequenceBase + 1),
                transition(orderID, orderIntent, .accepted, .submitPrepared, .submitted, sourceSequenceBase + 2),
                transition(orderID, orderIntent, .submitted, .cancelObserved, .cancelled, sourceSequenceBase + 3)
            ]
        }
    }

    private func transition(
        _ orderID: Identifier,
        _ orderIntent: ReleaseV020ProductAwareOMSOrderIntentSnapshot,
        _ from: ReleaseV020ProductAwareOMSOrderState,
        _ trigger: ReleaseV020ProductAwareOMSTransitionTrigger,
        _ to: ReleaseV020ProductAwareOMSOrderState,
        _ sequence: Int
    ) throws -> ReleaseV020ProductAwareOMSTransition {
        try ReleaseV020ProductAwareOMSTransition(
            transitionID: Identifier.constant("\(orderID.rawValue)-\(sequence)-\(to.rawValue)"),
            orderID: orderID,
            sourceOrderIntentID: orderIntent.sourceOrderIntentID,
            instrument: orderIntent.instrument,
            fromState: from,
            trigger: trigger,
            toState: to,
            sequence: sequence,
            validationAnchors: validationAnchors
        )
    }

    private func validate() throws {
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV020ProductAwareOMS.nonBinanceVenue")
        }
        guard releaseProductTypes == Self.requiredReleaseProductTypes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.releaseProductTypes",
                expected: Self.requiredReleaseProductTypes.map(\.rawValue).joined(separator: ","),
                actual: releaseProductTypes.map(\.rawValue).joined(separator: ",")
            )
        }
        guard releaseStrategyKinds == Self.requiredReleaseStrategyKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.releaseStrategyKinds",
                expected: Self.requiredReleaseStrategyKinds.joined(separator: ","),
                actual: releaseStrategyKinds.joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareOMS.validationAnchors",
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
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("unsupportedProductTypeEnabled", unsupportedProductTypeEnabled),
            ("nonEMARSIStrategyEnabled", nonEMARSIStrategyEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareOMS.\(forbiddenFlag.0)"
            )
        }
    }
}

private extension ReleaseV020ProductAwareOMSOrderSourceKind {
    var productType: ProductType {
        switch self {
        case .spot:
            .spot
        case .perpetual:
            .usdsPerpetual
        }
    }
}

private extension Array where Element == ReleaseV020ProductAwareOMSEventLog {
    var sortedForReplay: [ReleaseV020ProductAwareOMSEventLog] {
        sorted { $0.eventLogID.rawValue < $1.eventLogID.rawValue }
    }
}

private extension Array where Element == ReleaseV020ProductAwareOMSReplayResult {
    var sortedForReplay: [ReleaseV020ProductAwareOMSReplayResult] {
        sorted { $0.sourceEventLogID.rawValue < $1.sourceEventLogID.rawValue }
    }
}
