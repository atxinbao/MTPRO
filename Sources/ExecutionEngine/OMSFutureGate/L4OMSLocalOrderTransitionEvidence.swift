import DomainModel
import ExecutionClient
import Foundation

/// L4OMSLocalOrderStateRecord 是 GH-462 的 local-only order state 记录。
///
/// Record 只表达 sandbox lifecycle evidence 中的本地状态快照；它不写 production order store，不代表
/// broker order state，不驱动 Portfolio mutation，也不会暴露给 Live command surface。
public struct L4OMSLocalOrderStateRecord: Codable, Equatable, Sendable {
    public let recordID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let orderID: Identifier
    public let state: L4OMSOrderLifecycleState
    public let sequence: Int
    public let sourceEvidenceID: Identifier
    public let localOnly: Bool
    public let writesRealOrderStateStore: Bool
    public let touchesBrokerGateway: Bool
    public let mutatesPortfolio: Bool

    public var recordBoundaryHeld: Bool {
        issueID.rawValue == "GH-462"
            && upstreamIssueID.rawValue == "GH-461"
            && sequence > 0
            && localOnly
            && writesRealOrderStateStore == false
            && touchesBrokerGateway == false
            && mutatesPortfolio == false
    }

    public init(
        recordID: Identifier,
        issueID: Identifier = Identifier.constant("GH-462"),
        upstreamIssueID: Identifier = Identifier.constant("GH-461"),
        orderID: Identifier,
        state: L4OMSOrderLifecycleState,
        sequence: Int,
        sourceEvidenceID: Identifier,
        localOnly: Bool = true,
        writesRealOrderStateStore: Bool = false,
        touchesBrokerGateway: Bool = false,
        mutatesPortfolio: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-462" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-462",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-461",
                actual: upstreamIssueID.rawValue
            )
        }
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "positive local order state sequence",
                actual: "\(sequence)"
            )
        }
        guard localOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("localOnly")
        }
        for forbiddenFlag in [
            ("writesRealOrderStateStore", writesRealOrderStateStore),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("mutatesPortfolio", mutatesPortfolio)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.recordID = recordID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.orderID = orderID
        self.state = state
        self.sequence = sequence
        self.sourceEvidenceID = sourceEvidenceID
        self.localOnly = localOnly
        self.writesRealOrderStateStore = writesRealOrderStateStore
        self.touchesBrokerGateway = touchesBrokerGateway
        self.mutatesPortfolio = mutatesPortfolio
    }
}

/// L4OMSLocalOrderTransitionRecord 是 GH-462 的单条 local transition evidence。
///
/// Transition 只验证 GH-461 合同允许的 sandbox state change，并可引用 GH-460 parsed report event。
/// 它不提交订单、不调用 broker、不执行 reconciliation，也不把状态写入 production store。
public struct L4OMSLocalOrderTransitionRecord: Codable, Equatable, Sendable {
    public let transitionID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let fromRecord: L4OMSLocalOrderStateRecord
    public let toRecord: L4OMSLocalOrderStateRecord
    public let trigger: L4OMSOrderLifecycleTrigger
    public let sourceEvidence: String
    public let sandboxReportEvent: L4ExecutionClientSandboxParsedReportEvent?
    public let allowedByContract: Bool
    public let deterministicEvidence: Bool
    public let submitsRealOrder: Bool
    public let consumesProductionBrokerReport: Bool
    public let writesRealOrderStateStore: Bool
    public let performsReconciliation: Bool
    public let touchesLiveCommandSurface: Bool

    public var transitionBoundaryHeld: Bool {
        issueID.rawValue == "GH-462"
            && upstreamIssueID.rawValue == "GH-461"
            && fromRecord.recordBoundaryHeld
            && toRecord.recordBoundaryHeld
            && toRecord.sequence > fromRecord.sequence
            && allowedByContract
            && deterministicEvidence
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            submitsRealOrder,
            consumesProductionBrokerReport,
            writesRealOrderStateStore,
            performsReconciliation,
            touchesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        transitionID: Identifier,
        issueID: Identifier = Identifier.constant("GH-462"),
        upstreamIssueID: Identifier = Identifier.constant("GH-461"),
        fromRecord: L4OMSLocalOrderStateRecord,
        toRecord: L4OMSLocalOrderStateRecord,
        trigger: L4OMSOrderLifecycleTrigger,
        sourceEvidence: String,
        sandboxReportEvent: L4ExecutionClientSandboxParsedReportEvent? = nil,
        contract: L4OMSOrderLifecycleContract,
        allowedByContract: Bool = true,
        deterministicEvidence: Bool = true,
        submitsRealOrder: Bool = false,
        consumesProductionBrokerReport: Bool = false,
        writesRealOrderStateStore: Bool = false,
        performsReconciliation: Bool = false,
        touchesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-462" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-462",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-461",
                actual: upstreamIssueID.rawValue
            )
        }
        guard fromRecord.recordBoundaryHeld && toRecord.recordBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordBoundary",
                expected: "from/to local state records held",
                actual: "mismatch"
            )
        }
        guard fromRecord.orderID == toRecord.orderID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "orderID",
                expected: fromRecord.orderID.rawValue,
                actual: toRecord.orderID.rawValue
            )
        }
        guard toRecord.sequence > fromRecord.sequence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "toRecord sequence greater than fromRecord sequence",
                actual: "\(fromRecord.sequence)->\(toRecord.sequence)"
            )
        }
        guard contract.isAllowedTransition(from: fromRecord.state, trigger: trigger, to: toRecord.state) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transition",
                expected: "GH-461 allowed transition",
                actual: "\(fromRecord.state.rawValue)|\(trigger.rawValue)|\(toRecord.state.rawValue)"
            )
        }
        guard sourceEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceEvidence",
                expected: "non-empty GH-462 transition evidence source",
                actual: "empty"
            )
        }
        try Self.validateReportEvent(sandboxReportEvent, trigger: trigger)
        guard allowedByContract else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowedByContract")
        }
        guard deterministicEvidence else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("deterministicEvidence")
        }
        for forbiddenFlag in [
            ("submitsRealOrder", submitsRealOrder),
            ("consumesProductionBrokerReport", consumesProductionBrokerReport),
            ("writesRealOrderStateStore", writesRealOrderStateStore),
            ("performsReconciliation", performsReconciliation),
            ("touchesLiveCommandSurface", touchesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.transitionID = transitionID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.fromRecord = fromRecord
        self.toRecord = toRecord
        self.trigger = trigger
        self.sourceEvidence = sourceEvidence
        self.sandboxReportEvent = sandboxReportEvent
        self.allowedByContract = allowedByContract
        self.deterministicEvidence = deterministicEvidence
        self.submitsRealOrder = submitsRealOrder
        self.consumesProductionBrokerReport = consumesProductionBrokerReport
        self.writesRealOrderStateStore = writesRealOrderStateStore
        self.performsReconciliation = performsReconciliation
        self.touchesLiveCommandSurface = touchesLiveCommandSurface
    }

    private static func validateReportEvent(
        _ event: L4ExecutionClientSandboxParsedReportEvent?,
        trigger: L4OMSOrderLifecycleTrigger
    ) throws {
        let expectedKind: L4ExecutionClientSandboxReportKind?
        switch trigger {
        case .sandboxSubmitAccepted:
            expectedKind = nil
        case .sandboxPartialFillReport:
            expectedKind = .partialFill
        case .sandboxFillReport:
            expectedKind = .fill
        case .sandboxCancelAcknowledgement:
            expectedKind = .cancelAcknowledgement
        case .sandboxRejectReport:
            expectedKind = .reject
        case .rollbackIncidentEvidence:
            expectedKind = nil
        }
        guard let expectedKind else {
            guard event == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "sandboxReportEvent",
                    expected: "nil for \(trigger.rawValue)",
                    actual: event?.reportKind.rawValue ?? "nil"
                )
            }
            return
        }
        guard let event else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxReportEvent",
                expected: expectedKind.rawValue,
                actual: "nil"
            )
        }
        guard event.parsedEventBoundaryHeld && event.reportKind == expectedKind else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxReportEvent",
                expected: expectedKind.rawValue,
                actual: event.reportKind.rawValue
            )
        }
    }
}

/// L4OMSLocalOrderIllegalTransitionRejection 是 GH-462 的非法转换拒绝记录。
///
/// Rejection 只证明非法转换不会产生 state mutation；它不执行 rollback、不重试订单、不触发 broker
/// cancel，也不执行 reconciliation。
public struct L4OMSLocalOrderIllegalTransitionRejection: Codable, Equatable, Sendable {
    public let rejectionID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let illegalEvidence: L4OMSIllegalTransitionEvidence
    public let rejectedWithoutMutation: Bool
    public let rollbackEvidenceRecorded: Bool
    public let incidentEvidenceRecorded: Bool
    public let submitsRealOrder: Bool
    public let performsReconciliation: Bool

    public var rejectionBoundaryHeld: Bool {
        issueID.rawValue == "GH-462"
            && upstreamIssueID.rawValue == "GH-461"
            && rejectedWithoutMutation
            && rollbackEvidenceRecorded
            && incidentEvidenceRecorded
            && submitsRealOrder == false
            && performsReconciliation == false
    }

    public init(
        rejectionID: Identifier,
        issueID: Identifier = Identifier.constant("GH-462"),
        upstreamIssueID: Identifier = Identifier.constant("GH-461"),
        illegalEvidence: L4OMSIllegalTransitionEvidence,
        rejectedWithoutMutation: Bool = true,
        rollbackEvidenceRecorded: Bool = true,
        incidentEvidenceRecorded: Bool = true,
        submitsRealOrder: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-462" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-462",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-461",
                actual: upstreamIssueID.rawValue
            )
        }
        for requiredFlag in [
            ("rejectedWithoutMutation", rejectedWithoutMutation),
            ("rollbackEvidenceRecorded", rollbackEvidenceRecorded),
            ("incidentEvidenceRecorded", incidentEvidenceRecorded)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("submitsRealOrder", submitsRealOrder),
            ("performsReconciliation", performsReconciliation)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.rejectionID = rejectionID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.illegalEvidence = illegalEvidence
        self.rejectedWithoutMutation = rejectedWithoutMutation
        self.rollbackEvidenceRecorded = rollbackEvidenceRecorded
        self.incidentEvidenceRecorded = incidentEvidenceRecorded
        self.submitsRealOrder = submitsRealOrder
        self.performsReconciliation = performsReconciliation
    }
}

/// L4OMSLocalOrderTransitionEvidence 汇总 GH-462 的 local transition evidence。
///
/// Evidence 必须覆盖 fill、cancel 和 reject 三条 deterministic sandbox lifecycle，且非法转换全部被拒绝。
/// 它不依赖真实 broker，不写 production state store，不更新 Portfolio，也不实现 reconciliation。
public struct L4OMSLocalOrderTransitionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let lifecycleContract: L4OMSOrderLifecycleContract
    public let stateRecords: [L4OMSLocalOrderStateRecord]
    public let transitions: [L4OMSLocalOrderTransitionRecord]
    public let illegalRejections: [L4OMSLocalOrderIllegalTransitionRejection]
    public let validationAnchors: [String]
    public let fillEvidenceComplete: Bool
    public let cancelEvidenceComplete: Bool
    public let rejectEvidenceComplete: Bool
    public let deterministicSandboxOnly: Bool
    public let brokerIndependent: Bool
    public let writesRealOrderStateStore: Bool
    public let mutatesPortfolio: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var transitionEvidenceHeld: Bool {
        issueID.rawValue == "GH-462"
            && upstreamIssueID.rawValue == "GH-461"
            && lifecycleContract.contractHeld
            && stateRecords.allSatisfy(\.recordBoundaryHeld)
            && transitions.allSatisfy(\.transitionBoundaryHeld)
            && illegalRejections.allSatisfy(\.rejectionBoundaryHeld)
            && Set(transitions.map(\.trigger)).isSuperset(of: Self.requiredTransitionTriggers)
            && Set(stateRecords.map(\.state)).isSuperset(of: Self.requiredTerminalStates)
            && illegalRejections.count == lifecycleContract.illegalTransitionEvidence.count
            && validationAnchors == Self.requiredValidationAnchors
            && fillEvidenceComplete
            && cancelEvidenceComplete
            && rejectEvidenceComplete
            && deterministicSandboxOnly
            && brokerIndependent
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            writesRealOrderStateStore,
            mutatesPortfolio,
            performsReconciliation,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-462-oms-local-order-transition-evidence"),
        issueID: Identifier = Identifier.constant("GH-462"),
        upstreamIssueID: Identifier = Identifier.constant("GH-461"),
        lifecycleContract: L4OMSOrderLifecycleContract,
        stateRecords: [L4OMSLocalOrderStateRecord],
        transitions: [L4OMSLocalOrderTransitionRecord],
        illegalRejections: [L4OMSLocalOrderIllegalTransitionRejection],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        fillEvidenceComplete: Bool = true,
        cancelEvidenceComplete: Bool = true,
        rejectEvidenceComplete: Bool = true,
        deterministicSandboxOnly: Bool = true,
        brokerIndependent: Bool = true,
        writesRealOrderStateStore: Bool = false,
        mutatesPortfolio: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-462" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-462",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-461",
                actual: upstreamIssueID.rawValue
            )
        }
        guard lifecycleContract.contractHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lifecycleContract",
                expected: "GH-461 lifecycle contract held",
                actual: "mismatch"
            )
        }
        guard stateRecords.allSatisfy(\.recordBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "stateRecords",
                expected: "all local state records held",
                actual: "mismatch"
            )
        }
        guard transitions.allSatisfy(\.transitionBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transitions",
                expected: "all local transitions held",
                actual: "mismatch"
            )
        }
        guard illegalRejections.allSatisfy(\.rejectionBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "illegalRejections",
                expected: "all illegal transition rejections held",
                actual: "mismatch"
            )
        }
        guard Set(transitions.map(\.trigger)).isSuperset(of: Self.requiredTransitionTriggers) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transitionTriggers",
                expected: Self.requiredTransitionTriggers.map(\.rawValue).sorted().joined(separator: ","),
                actual: Set(transitions.map(\.trigger)).map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard Set(stateRecords.map(\.state)).isSuperset(of: Self.requiredTerminalStates) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terminalStates",
                expected: Self.requiredTerminalStates.map(\.rawValue).sorted().joined(separator: ","),
                actual: Set(stateRecords.map(\.state)).map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard illegalRejections.count == lifecycleContract.illegalTransitionEvidence.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "illegalRejections",
                expected: "\(lifecycleContract.illegalTransitionEvidence.count)",
                actual: "\(illegalRejections.count)"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("fillEvidenceComplete", fillEvidenceComplete),
            ("cancelEvidenceComplete", cancelEvidenceComplete),
            ("rejectEvidenceComplete", rejectEvidenceComplete),
            ("deterministicSandboxOnly", deterministicSandboxOnly),
            ("brokerIndependent", brokerIndependent)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("writesRealOrderStateStore", writesRealOrderStateStore),
            ("mutatesPortfolio", mutatesPortfolio),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.lifecycleContract = lifecycleContract
        self.stateRecords = stateRecords
        self.transitions = transitions
        self.illegalRejections = illegalRejections
        self.validationAnchors = validationAnchors
        self.fillEvidenceComplete = fillEvidenceComplete
        self.cancelEvidenceComplete = cancelEvidenceComplete
        self.rejectEvidenceComplete = rejectEvidenceComplete
        self.deterministicSandboxOnly = deterministicSandboxOnly
        self.brokerIndependent = brokerIndependent
        self.writesRealOrderStateStore = writesRealOrderStateStore
        self.mutatesPortfolio = mutatesPortfolio
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredTransitionTriggers: Set<L4OMSOrderLifecycleTrigger> = [
        .sandboxSubmitAccepted,
        .sandboxPartialFillReport,
        .sandboxFillReport,
        .sandboxCancelAcknowledgement,
        .sandboxRejectReport
    ]

    public static let requiredTerminalStates: Set<L4OMSOrderLifecycleState> = [
        .filled,
        .cancelled,
        .rejected
    ]

    public static let requiredValidationAnchors = [
        "GH-462-OMS-LOCAL-ORDER-STATE-RECORD",
        "GH-462-DETERMINISTIC-TRANSITION-EVIDENCE",
        "GH-462-SANDBOX-FILL-CANCEL-REJECT-EVIDENCE",
        "GH-462-ILLEGAL-TRANSITION-REJECTION",
        "GH-462-BROKER-INDEPENDENT-LOCAL-STATE",
        "TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE"
    ]
}

/// L4OMSLocalOrderTransitionEvidenceBuilder 生成 GH-462 deterministic sandbox transition evidence。
///
/// Builder 只是测试和审计夹具入口，不是 OMS runtime。它不保存持久状态，不调用 ExecutionClient，不联网，
/// 不提交真实订单，也不执行 reconciliation。
public struct L4OMSLocalOrderTransitionEvidenceBuilder: Codable, Equatable, Sendable {
    public let builderID: Identifier
    public let lifecycleContract: L4OMSOrderLifecycleContract
    public let parserEvidence: L4ExecutionClientSandboxReportReplayEvidence
    public let productionRuntimeEnabled: Bool
    public let brokerGatewayTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        builderID: Identifier = Identifier.constant("gh-462-oms-local-order-transition-evidence-builder"),
        lifecycleContract: L4OMSOrderLifecycleContract? = nil,
        productionRuntimeEnabled: Bool = false,
        brokerGatewayTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedContract = try lifecycleContract ?? L4OMSOrderLifecycleContract.deterministicFixture()
        guard resolvedContract.contractHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lifecycleContract",
                expected: "GH-461 lifecycle contract held",
                actual: "mismatch"
            )
        }
        for forbiddenFlag in [
            ("productionRuntimeEnabled", productionRuntimeEnabled),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.builderID = builderID
        self.lifecycleContract = resolvedContract
        self.parserEvidence = resolvedContract.parserEvidence
        self.productionRuntimeEnabled = productionRuntimeEnabled
        self.brokerGatewayTouched = brokerGatewayTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public func deterministicEvidence() throws -> L4OMSLocalOrderTransitionEvidence {
        let fillOrderID = Identifier.constant("gh-462-local-order-fill-path")
        let cancelOrderID = Identifier.constant("gh-462-local-order-cancel-path")
        let rejectOrderID = Identifier.constant("gh-462-local-order-reject-path")

        let fillAccepted = try record(orderID: fillOrderID, state: .accepted, sequence: 1, suffix: "fill-accepted")
        let fillSubmitted = try record(orderID: fillOrderID, state: .submitted, sequence: 2, suffix: "fill-submitted")
        let fillPartial = try record(orderID: fillOrderID, state: .partiallyFilled, sequence: 3, suffix: "fill-partial")
        let fillFilled = try record(orderID: fillOrderID, state: .filled, sequence: 4, suffix: "fill-filled")

        let cancelAccepted = try record(orderID: cancelOrderID, state: .accepted, sequence: 5, suffix: "cancel-accepted")
        let cancelSubmitted = try record(orderID: cancelOrderID, state: .submitted, sequence: 6, suffix: "cancel-submitted")
        let cancelCancelled = try record(orderID: cancelOrderID, state: .cancelled, sequence: 7, suffix: "cancel-cancelled")

        let rejectAccepted = try record(orderID: rejectOrderID, state: .accepted, sequence: 8, suffix: "reject-accepted")
        let rejectRejected = try record(orderID: rejectOrderID, state: .rejected, sequence: 9, suffix: "reject-rejected")

        let partialEvent = try parserEvent(kind: .partialFill)
        let fillEvent = try parserEvent(kind: .fill)
        let cancelEvent = try parserEvent(kind: .cancelAcknowledgement)
        let rejectEvent = try parserEvent(kind: .reject)

        let transitions = try [
            transition(
                suffix: "fill-accepted-to-submitted",
                from: fillAccepted,
                to: fillSubmitted,
                trigger: .sandboxSubmitAccepted,
                sourceEvidence: "GH-459 sandbox submit accepted evidence"
            ),
            transition(
                suffix: "fill-submitted-to-partial",
                from: fillSubmitted,
                to: fillPartial,
                trigger: .sandboxPartialFillReport,
                sourceEvidence: "GH-460 partial fill parser event",
                event: partialEvent
            ),
            transition(
                suffix: "fill-partial-to-filled",
                from: fillPartial,
                to: fillFilled,
                trigger: .sandboxFillReport,
                sourceEvidence: "GH-460 fill parser event",
                event: fillEvent
            ),
            transition(
                suffix: "cancel-accepted-to-submitted",
                from: cancelAccepted,
                to: cancelSubmitted,
                trigger: .sandboxSubmitAccepted,
                sourceEvidence: "GH-459 sandbox submit accepted evidence"
            ),
            transition(
                suffix: "cancel-submitted-to-cancelled",
                from: cancelSubmitted,
                to: cancelCancelled,
                trigger: .sandboxCancelAcknowledgement,
                sourceEvidence: "GH-460 cancel acknowledgement parser event",
                event: cancelEvent
            ),
            transition(
                suffix: "reject-accepted-to-rejected",
                from: rejectAccepted,
                to: rejectRejected,
                trigger: .sandboxRejectReport,
                sourceEvidence: "GH-460 reject parser event",
                event: rejectEvent
            )
        ]

        let illegalRejections = try lifecycleContract.illegalTransitionEvidence.map {
            try L4OMSLocalOrderIllegalTransitionRejection(
                rejectionID: Identifier.constant("gh-462-\($0.evidenceID.rawValue)-rejection"),
                illegalEvidence: $0
            )
        }

        return try L4OMSLocalOrderTransitionEvidence(
            lifecycleContract: lifecycleContract,
            stateRecords: [
                fillAccepted,
                fillSubmitted,
                fillPartial,
                fillFilled,
                cancelAccepted,
                cancelSubmitted,
                cancelCancelled,
                rejectAccepted,
                rejectRejected
            ],
            transitions: transitions,
            illegalRejections: illegalRejections
        )
    }

    public static func deterministicFixture() throws -> L4OMSLocalOrderTransitionEvidenceBuilder {
        try L4OMSLocalOrderTransitionEvidenceBuilder()
    }

    private func parserEvent(
        kind: L4ExecutionClientSandboxReportKind
    ) throws -> L4ExecutionClientSandboxParsedReportEvent {
        guard let event = parserEvidence.parsedEvents.first(where: { $0.reportKind == kind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvent",
                expected: kind.rawValue,
                actual: "missing"
            )
        }
        return event
    }

    private func record(
        orderID: Identifier,
        state: L4OMSOrderLifecycleState,
        sequence: Int,
        suffix: String
    ) throws -> L4OMSLocalOrderStateRecord {
        try L4OMSLocalOrderStateRecord(
            recordID: Identifier.constant("gh-462-\(suffix)-state-record"),
            orderID: orderID,
            state: state,
            sequence: sequence,
            sourceEvidenceID: Identifier.constant("gh-462-\(suffix)-source-evidence")
        )
    }

    private func transition(
        suffix: String,
        from fromRecord: L4OMSLocalOrderStateRecord,
        to toRecord: L4OMSLocalOrderStateRecord,
        trigger: L4OMSOrderLifecycleTrigger,
        sourceEvidence: String,
        event: L4ExecutionClientSandboxParsedReportEvent? = nil
    ) throws -> L4OMSLocalOrderTransitionRecord {
        try L4OMSLocalOrderTransitionRecord(
            transitionID: Identifier.constant("gh-462-\(suffix)-transition"),
            fromRecord: fromRecord,
            toRecord: toRecord,
            trigger: trigger,
            sourceEvidence: sourceEvidence,
            sandboxReportEvent: event,
            contract: lifecycleContract
        )
    }
}
