import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// ReleaseV040ExecutionOMSDryRunLifecycleState 固定 GH-700 覆盖的本地 OMS dry-run 状态。
///
/// 这些状态只描述 rehearsal evidence，不是 production OMS runtime state，也不授权真实 broker
/// submit / cancel / replace。
public enum ReleaseV040ExecutionOMSDryRunLifecycleState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case created
    case accepted
    case submittedDryRun = "submitted-dry-run"
    case filledSimulated = "filled-simulated"
    case cancelled
    case rejected
}

/// ReleaseV040ExecutionOMSDryRunLifecycleTrigger 描述 GH-700 本地状态迁移触发源。
public enum ReleaseV040ExecutionOMSDryRunLifecycleTrigger: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskApproved = "risk-approved"
    case riskRejected = "risk-rejected"
    case dryRunSubmitted = "dry-run-submitted"
    case simulatedFillObserved = "simulated-fill-observed"
    case cancelRequested = "cancel-requested"
}

/// ReleaseV040ExecutionOMSDryRunLifecyclePath 是 GH-700 必须覆盖的 deterministic lifecycle path。
public enum ReleaseV040ExecutionOMSDryRunLifecyclePath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case acceptedSubmittedFilled = "accepted-submitted-filled"
    case acceptedSubmittedCancelled = "accepted-submitted-cancelled"
    case riskRejected = "risk-rejected"

    public var requiresAllowedRiskDecision: Bool {
        self != .riskRejected
    }
}

/// ReleaseV040ExecutionOMSDryRunOrderIntent 是 RiskEngine allow decision 进入 ExecutionEngine 的本地意图。
///
/// 该类型只保存 #699 allow decision 中已经过 pre-trade gate 的 `ProductAwareOrderIntent`，
/// 不生成 ExecutionClient request，不触碰 broker gateway，也不提交真实订单。
public struct ReleaseV040ExecutionOMSDryRunOrderIntent: Codable, Equatable, Sendable {
    public let orderIntentID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let sourceRiskDecisionID: Identifier
    public let sourceRiskEnvelopeID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let productAwareOrderIntent: ProductAwareOrderIntent
    public let createdAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let authorizesExecutionClientCall: Bool
    public let submitsRealOrder: Bool

    public var runID: Identifier { runContext.runID }

    public var boundaryHeld: Bool {
        runContext.mode == .dryRun
            && runContext.boundaryHeld
            && productAwareOrderIntent.isPreRiskGateIntent
            && productionTradingEnabledByDefault == false
            && authorizesExecutionClientCall == false
            && submitsRealOrder == false
    }

    public init(
        orderIntentID: Identifier,
        sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        createdAt: Date,
        productionTradingEnabledByDefault: Bool = false,
        authorizesExecutionClientCall: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sourceRiskDecision.executionEligible else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.sourceRiskDecision",
                expected: "execution-eligible allow decision",
                actual: sourceRiskDecision.status.rawValue
            )
        }
        guard let productAwareOrderIntent = sourceRiskDecision.input.intentMessage.productAwareOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.productAwareOrderIntent",
                expected: "risk-approved product-aware order intent",
                actual: "nil"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(authorizesExecutionClientCall, "authorizesExecutionClientCall")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")

        self.orderIntentID = orderIntentID
        self.runContext = sourceRiskDecision.runContext
        self.sourceRiskDecisionID = sourceRiskDecision.decisionID
        self.sourceRiskEnvelopeID = sourceRiskDecision.riskEnvelope.evidenceID
        self.instrument = sourceRiskDecision.input.intentMessage.instrument
        self.targetExposure = sourceRiskDecision.input.intentMessage.targetExposure
        self.productAwareOrderIntent = productAwareOrderIntent
        self.createdAt = createdAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.authorizesExecutionClientCall = authorizesExecutionClientCall
        self.submitsRealOrder = submitsRealOrder
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040OMSOrderIntent.\(field)")
        }
    }
}

/// ReleaseV040ExecutionOMSDryRunLifecycleEvent 是单个本地 OMS transition evidence。
///
/// 每个 event 同时携带 ExecutionEngine envelope 和 OMS envelope，二者共享同一 runID，并通过
/// upstreamEvidenceID / causationID 串回 #699 RiskEngine decision evidence。
public struct ReleaseV040ExecutionOMSDryRunLifecycleEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let sourceRiskEnvelopeID: Identifier
    public let fromState: ReleaseV040ExecutionOMSDryRunLifecycleState
    public let trigger: ReleaseV040ExecutionOMSDryRunLifecycleTrigger
    public let toState: ReleaseV040ExecutionOMSDryRunLifecycleState
    public let sequence: Int
    public let causationID: Identifier
    public let recordedAt: Date
    public let executionEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let omsEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var runID: Identifier { runContext.runID }

    public var eventHeld: Bool {
        runContext.mode == .dryRun
            && runContext.boundaryHeld
            && Self.isAllowed(from: fromState, trigger: trigger, to: toState)
            && causationID == sourceRiskEnvelopeID
            && executionEnvelope.runID == runID
            && omsEnvelope.runID == runID
            && executionEnvelope.module == .executionEngine
            && omsEnvelope.module == .oms
            && executionEnvelope.sourceIssueID.rawValue == "GH-700"
            && omsEnvelope.sourceIssueID.rawValue == "GH-700"
            && executionEnvelope.upstreamEvidenceID == sourceRiskEnvelopeID
            && omsEnvelope.upstreamEvidenceID == executionEnvelope.evidenceID
            && executionEnvelope.validationAnchor == ReleaseV040ExecutionOMSDryRunLifecycleEvidence.validationAnchor
            && omsEnvelope.validationAnchor == ReleaseV040ExecutionOMSDryRunLifecycleEvidence.validationAnchor
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    public init(
        eventID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        sourceRiskEnvelopeID: Identifier,
        fromState: ReleaseV040ExecutionOMSDryRunLifecycleState,
        trigger: ReleaseV040ExecutionOMSDryRunLifecycleTrigger,
        toState: ReleaseV040ExecutionOMSDryRunLifecycleState,
        sequence: Int,
        recordedAt: Date,
        executionEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        omsEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        guard Self.isAllowed(from: fromState, trigger: trigger, to: toState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.transition",
                expected: "legal dry-run OMS transition",
                actual: "\(fromState.rawValue)->\(trigger.rawValue)->\(toState.rawValue)"
            )
        }
        guard executionEnvelope.module == .executionEngine, omsEnvelope.module == .oms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.envelope.module",
                expected: "ExecutionEngine->OMS",
                actual: "\(executionEnvelope.module.rawValue)->\(omsEnvelope.module.rawValue)"
            )
        }
        guard executionEnvelope.runID == runContext.runID, omsEnvelope.runID == runContext.runID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard executionEnvelope.sourceIssueID.rawValue == "GH-700",
              omsEnvelope.sourceIssueID.rawValue == "GH-700" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIssueID",
                expected: "GH-700",
                actual: "\(executionEnvelope.sourceIssueID.rawValue)/\(omsEnvelope.sourceIssueID.rawValue)"
            )
        }
        guard executionEnvelope.upstreamEvidenceID == sourceRiskEnvelopeID,
              omsEnvelope.upstreamEvidenceID == executionEnvelope.evidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "causationID",
                expected: sourceRiskEnvelopeID.rawValue,
                actual: "\(executionEnvelope.upstreamEvidenceID?.rawValue ?? "nil")/\(omsEnvelope.upstreamEvidenceID?.rawValue ?? "nil")"
            )
        }
        try Self.validateForbiddenFlags(
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.eventID = eventID
        self.runContext = runContext
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.sourceRiskEnvelopeID = sourceRiskEnvelopeID
        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sequence = sequence
        self.causationID = sourceRiskEnvelopeID
        self.recordedAt = recordedAt
        self.executionEnvelope = executionEnvelope
        self.omsEnvelope = omsEnvelope
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public static func isAllowed(
        from: ReleaseV040ExecutionOMSDryRunLifecycleState,
        trigger: ReleaseV040ExecutionOMSDryRunLifecycleTrigger,
        to: ReleaseV040ExecutionOMSDryRunLifecycleState
    ) -> Bool {
        switch (from, trigger, to) {
        case (.created, .riskApproved, .accepted),
             (.accepted, .dryRunSubmitted, .submittedDryRun),
             (.submittedDryRun, .simulatedFillObserved, .filledSimulated),
             (.submittedDryRun, .cancelRequested, .cancelled),
             (.created, .riskRejected, .rejected):
            true
        default:
            false
        }
    }

    private static func validateForbiddenFlags(
        callsExecutionClient: Bool,
        touchesBrokerGateway: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040OMSEvent.\(field)")
        }
    }
}

/// ReleaseV040ExecutionOMSDryRunLifecycleLog 是一条 order lifecycle 的 append-only evidence。
public struct ReleaseV040ExecutionOMSDryRunLifecycleLog: Codable, Equatable, Sendable {
    public let logID: Identifier
    public let path: ReleaseV040ExecutionOMSDryRunLifecyclePath
    public let orderID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let orderIntent: ReleaseV040ExecutionOMSDryRunOrderIntent?
    public let sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision
    public let events: [ReleaseV040ExecutionOMSDryRunLifecycleEvent]
    public let messageBusEnvelopes: [MessageBusJournalEnvelope]
    public let replayedMessageBusEnvelopes: [MessageBusJournalEnvelope]
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var finalState: ReleaseV040ExecutionOMSDryRunLifecycleState {
        events.last?.toState ?? .created
    }

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        events.flatMap { [$0.executionEnvelope, $0.omsEnvelope] }
    }

    public var replayRestoresFinalState: Bool {
        messageBusEnvelopes == replayedMessageBusEnvelopes
            && messageBusEnvelopes.count == events.count
            && finalState == events.last?.toState
    }

    public var logHeld: Bool {
        runContext.mode == .dryRun
            && events.allSatisfy(\.eventHeld)
            && replayRestoresFinalState
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        callsExecutionClient == false
            && touchesBrokerGateway == false
            && productionOMSRuntimeEnabledByDefault == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    public init(
        logID: Identifier,
        path: ReleaseV040ExecutionOMSDryRunLifecyclePath,
        orderID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        orderIntent: ReleaseV040ExecutionOMSDryRunOrderIntent?,
        sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        events: [ReleaseV040ExecutionOMSDryRunLifecycleEvent],
        messageBusEnvelopes: [MessageBusJournalEnvelope],
        replayedMessageBusEnvelopes: [MessageBusJournalEnvelope],
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard events.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.events",
                expected: "non-empty event set",
                actual: "empty"
            )
        }
        guard events.allSatisfy({ $0.runID == runContext.runID }),
              sourceRiskDecision.runID == runContext.runID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard messageBusEnvelopes == replayedMessageBusEnvelopes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.replay",
                expected: "append-only envelopes replay exactly",
                actual: "\(messageBusEnvelopes.count):\(replayedMessageBusEnvelopes.count)"
            )
        }
        if path.requiresAllowedRiskDecision {
            guard sourceRiskDecision.executionEligible, orderIntent?.boundaryHeld == true else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040OMS.orderIntent",
                    expected: "allow decision with local order intent",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
        } else {
            guard sourceRiskDecision.status == .reject, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040OMS.rejectedPath",
                    expected: "reject decision without order intent",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
        }
        try Self.validateForbiddenFlags(
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            productionOMSRuntimeEnabledByDefault: productionOMSRuntimeEnabledByDefault,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.logID = logID
        self.path = path
        self.orderID = orderID
        self.runContext = runContext
        self.orderIntent = orderIntent
        self.sourceRiskDecision = sourceRiskDecision
        self.events = events
        self.messageBusEnvelopes = messageBusEnvelopes
        self.replayedMessageBusEnvelopes = replayedMessageBusEnvelopes
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    private static func validateForbiddenFlags(
        callsExecutionClient: Bool,
        touchesBrokerGateway: Bool,
        productionOMSRuntimeEnabledByDefault: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040OMSLog.\(field)")
        }
    }
}

/// ReleaseV040ExecutionOMSDryRunLifecycleEvidence 汇总 GH-700 的 ExecutionEngine / OMS evidence。
public struct ReleaseV040ExecutionOMSDryRunLifecycleEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let upstreamRiskEvidenceID: Identifier
    public let lifecycleLogs: [ReleaseV040ExecutionOMSDryRunLifecycleLog]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let riskEngineBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        lifecycleLogs.flatMap(\.unifiedEnvelopes)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-700"
            && upstreamIssueID.rawValue == "GH-699"
            && downstreamIssueID.rawValue == "GH-701"
            && runContext.mode == .dryRun
            && lifecycleCoverageHeld
            && replayCoverageHeld
            && runScopedEnvelopeHeld
            && boundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var lifecycleCoverageHeld: Bool {
        Set(lifecycleLogs.flatMap { log in log.events.flatMap { [$0.fromState, $0.toState] } })
            == Set(ReleaseV040ExecutionOMSDryRunLifecycleState.allCases)
            && lifecycleLogs.contains { $0.path == .acceptedSubmittedFilled && $0.finalState == .filledSimulated }
            && lifecycleLogs.contains { $0.path == .acceptedSubmittedCancelled && $0.finalState == .cancelled }
            && lifecycleLogs.contains { $0.path == .riskRejected && $0.finalState == .rejected }
    }

    public var replayCoverageHeld: Bool {
        lifecycleLogs.allSatisfy(\.logHeld)
            && lifecycleLogs.allSatisfy(\.replayRestoresFinalState)
    }

    public var runScopedEnvelopeHeld: Bool {
        lifecycleLogs.allSatisfy { $0.runContext.runID == runContext.runID }
            && lifecycleLogs.flatMap(\.events).allSatisfy(\.eventHeld)
            && unifiedEnvelopes.allSatisfy { $0.runID == runContext.runID }
            && unifiedEnvelopes.map(\.module).chunkedPairsAllEqual(to: (.executionEngine, .oms))
            && unifiedEnvelopes.map(\.sequence) == Array(1...unifiedEnvelopes.count)
    }

    public var boundaryHeld: Bool {
        callsExecutionClient == false
            && touchesBrokerGateway == false
            && productionOMSRuntimeEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && riskEngineBypassAllowed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-700-v040-execution-oms-dryrun-lifecycle"),
        issueID: Identifier = Identifier.constant("GH-700"),
        upstreamIssueID: Identifier = Identifier.constant("GH-699"),
        downstreamIssueID: Identifier = Identifier.constant("GH-701"),
        runContext: ReleaseV040RehearsalRunContext,
        upstreamRiskEvidenceID: Identifier,
        lifecycleLogs: [ReleaseV040ExecutionOMSDryRunLifecycleLog],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        riskEngineBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-700" else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "issueID", expected: "GH-700", actual: issueID.rawValue)
        }
        guard upstreamIssueID.rawValue == "GH-699" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-699",
                actual: upstreamIssueID.rawValue
            )
        }
        guard downstreamIssueID.rawValue == "GH-701" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "downstreamIssueID",
                expected: "GH-701",
                actual: downstreamIssueID.rawValue
            )
        }
        guard lifecycleLogs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "lifecycleLogs",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard lifecycleLogs.allSatisfy({ $0.runContext.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        try Self.validateForbiddenFlags(
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            productionOMSRuntimeEnabledByDefault: productionOMSRuntimeEnabledByDefault,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            riskEngineBypassAllowed: riskEngineBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.runContext = runContext
        self.upstreamRiskEvidenceID = upstreamRiskEvidenceID
        self.lifecycleLogs = lifecycleLogs
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.riskEngineBypassAllowed = riskEngineBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            upstreamIssueID: try container.decode(Identifier.self, forKey: .upstreamIssueID),
            downstreamIssueID: try container.decode(Identifier.self, forKey: .downstreamIssueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            upstreamRiskEvidenceID: try container.decode(Identifier.self, forKey: .upstreamRiskEvidenceID),
            lifecycleLogs: try container.decode([ReleaseV040ExecutionOMSDryRunLifecycleLog].self, forKey: .lifecycleLogs),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            callsExecutionClient: try container.decode(Bool.self, forKey: .callsExecutionClient),
            touchesBrokerGateway: try container.decode(Bool.self, forKey: .touchesBrokerGateway),
            productionOMSRuntimeEnabledByDefault: try container.decode(Bool.self, forKey: .productionOMSRuntimeEnabledByDefault),
            productionTradingEnabledByDefault: try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionSecretAutoReadEnabled: try container.decode(Bool.self, forKey: .productionSecretAutoReadEnabled),
            productionBrokerConnected: try container.decode(Bool.self, forKey: .productionBrokerConnected),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized),
            riskEngineBypassAllowed: try container.decode(Bool.self, forKey: .riskEngineBypassAllowed),
            startsNextMilestone: try container.decode(Bool.self, forKey: .startsNextMilestone)
        )
    }

    public static let validationAnchor = "TVM-RELEASE-V040-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE"

    public static let requiredValidationAnchors = [
        "V040-07-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE",
        "V040-07-RISK-APPROVED-INTENT-TO-LOCAL-ORDER",
        "V040-07-RUN-SCOPED-OMS-STATE-REPLAY",
        "V040-07-NO-PRODUCTION-BROKER-CALL",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH700ExecutionOMSDryRunLifecycleConsumesRiskApprovedDecisionAndReplaysRunScopedEvents",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private enum CodingKeys: String, CodingKey {
        case evidenceID
        case issueID
        case upstreamIssueID
        case downstreamIssueID
        case runContext
        case upstreamRiskEvidenceID
        case lifecycleLogs
        case validationAnchors
        case requiredValidationCommands
        case callsExecutionClient
        case touchesBrokerGateway
        case productionOMSRuntimeEnabledByDefault
        case productionTradingEnabledByDefault
        case productionEndpointConnected
        case productionSecretAutoReadEnabled
        case productionBrokerConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case riskEngineBypassAllowed
        case startsNextMilestone
    }
}

/// ReleaseV040ExecutionOMSDryRunLifecycle 生成 GH-700 本地 ExecutionEngine / OMS evidence。
public struct ReleaseV040ExecutionOMSDryRunLifecycle: Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        self.runContext = runContext
        self.sourceID = try sourceID ?? FoundationTargetID("gh-700-execution-oms-dryrun-source")
        self.streamID = try streamID ?? MessageBusJournalStreamID("execution.release-v0.4.0.oms-dryrun")
    }

    public func run(
        riskEvidence: ReleaseV040RiskEnginePreTradeRehearsalGateEvidence,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_705_001_300)
    ) throws -> ReleaseV040ExecutionOMSDryRunLifecycleEvidence {
        guard riskEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040OMS.riskEvidence",
                expected: "held GH-699 RiskEngine pre-trade evidence",
                actual: riskEvidence.issueID.rawValue
            )
        }
        guard riskEvidence.runContext.runID == runContext.runID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: riskEvidence.runContext.runID.rawValue
            )
        }

        let acceptedFilled = try lifecycleLog(
            path: .acceptedSubmittedFilled,
            sourceRiskDecision: riskEvidence.allowDecision,
            sequenceBase: 0,
            recordedAt: firstRecordedAt
        )
        let acceptedCancelled = try lifecycleLog(
            path: .acceptedSubmittedCancelled,
            sourceRiskDecision: riskEvidence.allowDecision,
            sequenceBase: 3,
            recordedAt: firstRecordedAt.addingTimeInterval(10)
        )
        let riskRejected = try lifecycleLog(
            path: .riskRejected,
            sourceRiskDecision: riskEvidence.rejectDecision,
            sequenceBase: 6,
            recordedAt: firstRecordedAt.addingTimeInterval(20)
        )

        return try ReleaseV040ExecutionOMSDryRunLifecycleEvidence(
            runContext: runContext,
            upstreamRiskEvidenceID: riskEvidence.evidenceID,
            lifecycleLogs: [acceptedFilled, acceptedCancelled, riskRejected]
        )
    }

    public func lifecycleLog(
        path: ReleaseV040ExecutionOMSDryRunLifecyclePath,
        sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        sequenceBase: Int,
        recordedAt: Date
    ) throws -> ReleaseV040ExecutionOMSDryRunLifecycleLog {
        guard sequenceBase >= 0 else {
            throw CoreError.invalidEventSequence(sequenceBase)
        }
        let orderID = Identifier.constant("gh-700-\(path.rawValue)-order")
        let orderIntent: ReleaseV040ExecutionOMSDryRunOrderIntent?
        if path.requiresAllowedRiskDecision {
            orderIntent = try ReleaseV040ExecutionOMSDryRunOrderIntent(
                orderIntentID: Identifier.constant("\(orderID.rawValue)-intent"),
                sourceRiskDecision: sourceRiskDecision,
                createdAt: recordedAt
            )
        } else {
            guard sourceRiskDecision.status == .reject else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040OMS.riskRejectedPath",
                    expected: "reject risk decision",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
            orderIntent = nil
        }
        let events = try transitions(
            orderID: orderID,
            sourceRiskDecision: sourceRiskDecision,
            path: path,
            sequenceBase: sequenceBase,
            recordedAt: recordedAt
        )
        let (messageBusEnvelopes, replayedMessageBusEnvelopes) = try replayEvidence(
            path: path,
            orderID: orderID,
            sourceRiskDecision: sourceRiskDecision,
            events: events
        )

        return try ReleaseV040ExecutionOMSDryRunLifecycleLog(
            logID: Identifier.constant("\(orderID.rawValue)-lifecycle-log"),
            path: path,
            orderID: orderID,
            runContext: runContext,
            orderIntent: orderIntent,
            sourceRiskDecision: sourceRiskDecision,
            events: events,
            messageBusEnvelopes: messageBusEnvelopes,
            replayedMessageBusEnvelopes: replayedMessageBusEnvelopes
        )
    }

    private func transitions(
        orderID: Identifier,
        sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        path: ReleaseV040ExecutionOMSDryRunLifecyclePath,
        sequenceBase: Int,
        recordedAt: Date
    ) throws -> [ReleaseV040ExecutionOMSDryRunLifecycleEvent] {
        switch path {
        case .acceptedSubmittedFilled:
            return try [
                event(orderID, sourceRiskDecision, .created, .riskApproved, .accepted, sequenceBase + 1, recordedAt),
                event(
                    orderID,
                    sourceRiskDecision,
                    .accepted,
                    .dryRunSubmitted,
                    .submittedDryRun,
                    sequenceBase + 2,
                    recordedAt.addingTimeInterval(1)
                ),
                event(
                    orderID,
                    sourceRiskDecision,
                    .submittedDryRun,
                    .simulatedFillObserved,
                    .filledSimulated,
                    sequenceBase + 3,
                    recordedAt.addingTimeInterval(2)
                )
            ]
        case .acceptedSubmittedCancelled:
            return try [
                event(orderID, sourceRiskDecision, .created, .riskApproved, .accepted, sequenceBase + 1, recordedAt),
                event(
                    orderID,
                    sourceRiskDecision,
                    .accepted,
                    .dryRunSubmitted,
                    .submittedDryRun,
                    sequenceBase + 2,
                    recordedAt.addingTimeInterval(1)
                ),
                event(
                    orderID,
                    sourceRiskDecision,
                    .submittedDryRun,
                    .cancelRequested,
                    .cancelled,
                    sequenceBase + 3,
                    recordedAt.addingTimeInterval(2)
                )
            ]
        case .riskRejected:
            return try [
                event(orderID, sourceRiskDecision, .created, .riskRejected, .rejected, sequenceBase + 1, recordedAt)
            ]
        }
    }

    private func event(
        _ orderID: Identifier,
        _ sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        _ fromState: ReleaseV040ExecutionOMSDryRunLifecycleState,
        _ trigger: ReleaseV040ExecutionOMSDryRunLifecycleTrigger,
        _ toState: ReleaseV040ExecutionOMSDryRunLifecycleState,
        _ sequence: Int,
        _ recordedAt: Date
    ) throws -> ReleaseV040ExecutionOMSDryRunLifecycleEvent {
        let eventID = Identifier.constant("gh-700-\(orderID.rawValue)-event-\(sequence)-\(toState.rawValue)")
        let executionEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("\(eventID.rawValue)-execution-envelope"),
            runContext: runContext,
            module: .executionEngine,
            sourceIssueID: Identifier.constant("GH-700"),
            evidenceID: eventID,
            upstreamEvidenceID: sourceRiskDecision.riskEnvelope.evidenceID,
            validationAnchor: ReleaseV040ExecutionOMSDryRunLifecycleEvidence.validationAnchor,
            sequence: (sequence * 2) - 1
        )
        let omsEvidenceID = Identifier.constant("\(eventID.rawValue)-oms")
        let omsEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("\(eventID.rawValue)-oms-envelope"),
            runContext: runContext,
            module: .oms,
            sourceIssueID: Identifier.constant("GH-700"),
            evidenceID: omsEvidenceID,
            upstreamEvidenceID: executionEnvelope.evidenceID,
            validationAnchor: ReleaseV040ExecutionOMSDryRunLifecycleEvidence.validationAnchor,
            sequence: sequence * 2
        )
        return try ReleaseV040ExecutionOMSDryRunLifecycleEvent(
            eventID: eventID,
            runContext: runContext,
            orderID: orderID,
            sourceRiskDecisionID: sourceRiskDecision.decisionID,
            sourceRiskEnvelopeID: sourceRiskDecision.riskEnvelope.evidenceID,
            fromState: fromState,
            trigger: trigger,
            toState: toState,
            sequence: sequence,
            recordedAt: recordedAt,
            executionEnvelope: executionEnvelope,
            omsEnvelope: omsEnvelope
        )
    }

    private func replayEvidence(
        path: ReleaseV040ExecutionOMSDryRunLifecyclePath,
        orderID: Identifier,
        sourceRiskDecision: ReleaseV040RiskEnginePreTradeDecision,
        events: [ReleaseV040ExecutionOMSDryRunLifecycleEvent]
    ) throws -> ([MessageBusJournalEnvelope], [MessageBusJournalEnvelope]) {
        var journal = try MessageBusAppendOnlyJournal()
        var envelopes: [MessageBusJournalEnvelope] = []
        for event in events {
            let payloadType = "execution.release-v0.4.0.oms.\(path.rawValue).\(event.toState.rawValue).\(orderID.rawValue)"
            let envelope = try journal.append(
                stream: streamID,
                sourceID: sourceID,
                payloadType: payloadType,
                instrumentID: sourceRiskDecision.input.intentMessage.instrument,
                recordedAt: event.recordedAt
            )
            envelopes.append(envelope)
        }
        return (envelopes, journal.replay(stream: streamID))
    }
}

private extension ReleaseV040ExecutionOMSDryRunLifecycleEvidence {
    static func validateForbiddenFlags(
        callsExecutionClient: Bool,
        touchesBrokerGateway: Bool,
        productionOMSRuntimeEnabledByDefault: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        riskEngineBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("riskEngineBypassAllowed", riskEngineBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}

private extension Array where Element == ReleaseV040UnifiedEvidenceModule {
    func chunkedPairsAllEqual(to expected: (ReleaseV040UnifiedEvidenceModule, ReleaseV040UnifiedEvidenceModule)) -> Bool {
        guard count.isMultiple(of: 2) else { return false }
        return stride(from: 0, to: count, by: 2).allSatisfy { index in
            self[index] == expected.0 && self[index + 1] == expected.1
        }
    }
}
