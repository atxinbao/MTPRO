import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// ReleaseV050ExecutionOMSDryRunLifecycleError 描述 GH-735 ExecutionEngine / OMS dry-run lifecycle 的合同错误。
///
/// 错误只覆盖 RiskDecisionEvent 消费、OMS lifecycle event 生成、Execution dry-run event 生成
/// 和 run scoped replay 合同；它不表达真实 broker gateway、production OMS 或真实订单能力。
public enum ReleaseV050ExecutionOMSDryRunLifecycleError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyLifecycleRequests
    case invalidRecordedAtStride(TimeInterval)
    case nonRiskDecisionPayload(RuntimeEventPayloadType)
    case rejectedOrBlockedDecisionCannotCreateLifecycle(RuntimeRiskDecision)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case streamIDMismatch(expected: MessageBusJournalStreamID, actual: MessageBusJournalStreamID)
    case correlationIDMismatch(expected: Identifier, actual: Identifier)
    case replayMismatch
    case forbiddenProductionCapability(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case .emptyLifecycleRequests:
            "Release v0.5.0 Execution/OMS dry-run lifecycle requires at least one allowed risk decision request"
        case let .invalidRecordedAtStride(value):
            "Release v0.5.0 Execution/OMS recordedAt stride must be positive: \(value)"
        case let .nonRiskDecisionPayload(payloadType):
            "Release v0.5.0 Execution/OMS expected RiskDecisionEvent payload, actual \(payloadType.rawValue)"
        case let .rejectedOrBlockedDecisionCannotCreateLifecycle(decision):
            "Release v0.5.0 Execution/OMS rejects lifecycle creation from risk decision: \(decision.rawValue)"
        case let .runIDMismatch(expected, actual):
            "Release v0.5.0 Execution/OMS runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .streamIDMismatch(expected, actual):
            "Release v0.5.0 Execution/OMS streamID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .correlationIDMismatch(expected, actual):
            "Release v0.5.0 Execution/OMS correlationID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case .replayMismatch:
            "Release v0.5.0 Execution/OMS replayed events do not match emitted lifecycle events"
        case let .forbiddenProductionCapability(capability):
            "Release v0.5.0 Execution/OMS rejected forbidden production capability: \(capability)"
        case let .contractDrift(reason):
            "Release v0.5.0 Execution/OMS contract drift: \(reason)"
        }
    }
}

/// ReleaseV050ExecutionOMSDryRunOutcome 固定 GH-735 的 deterministic dry-run outcome 覆盖。
public enum ReleaseV050ExecutionOMSDryRunOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case simulatedFilled
    case simulatedRejected
    case simulatedCancelled

    public var omsStates: [RuntimeOMSState] {
        switch self {
        case .simulatedFilled:
            [.created, .riskApproved, .acceptedByOMS, .simulatedSubmitted, .simulatedPartiallyFilled, .simulatedFilled]
        case .simulatedRejected:
            [.created, .riskApproved, .acceptedByOMS, .simulatedRejected]
        case .simulatedCancelled:
            [.created, .riskApproved, .acceptedByOMS, .simulatedSubmitted, .simulatedCancelled]
        }
    }
}

/// ReleaseV050ExecutionOMSDryRunLifecycleRequest 是 ExecutionEngine/OMS 消费的 allowed RiskDecisionEvent 请求。
///
/// 请求只持有 RiskEngine 产出的 typed envelope，不读取 account endpoint、不调用 ExecutionClient
/// implementation、不构造真实订单命令。
public struct ReleaseV050ExecutionOMSDryRunLifecycleRequest: Codable, Equatable, Sendable {
    public let riskEmission: ReleaseV050RiskEngineRuntimeDecisionEmission
    public let outcome: ReleaseV050ExecutionOMSDryRunOutcome

    public var riskDecision: RiskDecisionEvent {
        riskEmission.decisionEvent
    }

    public var riskEnvelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload> {
        riskEmission.envelope
    }

    public var runID: Identifier {
        riskEnvelope.runID
    }

    public var streamID: MessageBusJournalStreamID {
        riskEnvelope.streamID
    }

    public var correlationID: Identifier {
        riskEnvelope.correlationID
    }

    public var requestHeld: Bool {
        riskEmission.emissionHeld
            && riskEnvelope.payloadType == .riskDecisionEvent
            && riskEnvelope.sourceModule == .riskEngine
            && riskEnvelope.payload == .riskDecision(riskDecision)
            && riskDecision.decision == .allowed
    }

    public init(
        riskEmission: ReleaseV050RiskEngineRuntimeDecisionEmission,
        outcome: ReleaseV050ExecutionOMSDryRunOutcome
    ) throws {
        guard riskEmission.envelope.payloadType == .riskDecisionEvent else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.nonRiskDecisionPayload(riskEmission.envelope.payloadType)
        }
        guard riskEmission.decisionEvent.decision == .allowed else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.rejectedOrBlockedDecisionCannotCreateLifecycle(
                riskEmission.decisionEvent.decision
            )
        }
        self.riskEmission = riskEmission
        self.outcome = outcome
    }
}

/// ReleaseV050ExecutionOMSDryRunSuppression 记录 rejected / blocked RiskDecisionEvent 没有产生 submit path。
public struct ReleaseV050ExecutionOMSDryRunSuppression: Codable, Equatable, Sendable {
    public let sourceRiskDecisionID: Identifier
    public let sourceRiskDecision: RuntimeRiskDecision
    public let reason: String
    public let omsLifecycleCreated: Bool
    public let executionDryRunEventCreated: Bool
    public let submitPathCreated: Bool

    public var suppressionHeld: Bool {
        sourceRiskDecision != .allowed
            && reason.isEmpty == false
            && omsLifecycleCreated == false
            && executionDryRunEventCreated == false
            && submitPathCreated == false
    }

    public init(decisionEvent: RiskDecisionEvent) throws {
        guard decisionEvent.decision != .allowed else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("allowedDecisionCannotBeSuppressed")
        }
        self.sourceRiskDecisionID = decisionEvent.decisionID
        self.sourceRiskDecision = decisionEvent.decision
        self.reason = decisionEvent.reason
        self.omsLifecycleCreated = false
        self.executionDryRunEventCreated = false
        self.submitPathCreated = false
    }
}

/// ReleaseV050ExecutionOMSDryRunLifecyclePath 是单个 allowed risk decision 产生的 dry-run order path。
public struct ReleaseV050ExecutionOMSDryRunLifecyclePath: Codable, Equatable, Sendable {
    public let pathID: Identifier
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let outcome: ReleaseV050ExecutionOMSDryRunOutcome
    public let omsEvents: [OMSLifecycleEvent]
    public let executionDryRunEvents: [ExecutionClientDryRunEvent]
    public let generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]

    public var omsStates: [RuntimeOMSState] {
        omsEvents.map(\.state)
    }

    public var omsEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        generatedEnvelopes.filter { $0.payloadType == .omsLifecycleEvent }
    }

    public var executionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        generatedEnvelopes.filter { $0.payloadType == .executionClientDryRunEvent }
    }

    public var pathHeld: Bool {
        pathID.rawValue.isEmpty == false
            && orderID.rawValue.isEmpty == false
            && sourceRiskDecisionID.rawValue.isEmpty == false
            && omsStates == outcome.omsStates
            && omsEvents.allSatisfy { $0.orderID == orderID && $0.sourceRiskDecisionID == sourceRiskDecisionID }
            && executionDryRunEvents.allSatisfy { $0.sourceOMSOrderID == orderID }
            && generatedEnvelopes.isEmpty == false
            && generatedEnvelopes.allSatisfy(\.envelopeHeld)
            && generatedEnvelopes.dropFirst().compactMap(\.causationID) == generatedEnvelopes.dropLast().map(\.eventID)
            && omsEnvelopes.map(\.sourceModule) == Array(repeating: .oms, count: omsEnvelopes.count)
            && executionDryRunEnvelopes.map(\.sourceModule) == Array(
                repeating: .executionClient,
                count: executionDryRunEnvelopes.count
            )
            && commandCoverageHeld
    }

    private var commandCoverageHeld: Bool {
        switch outcome {
        case .simulatedFilled:
            return executionDryRunEvents.map(\.commandKind) == [.submit]
                && executionDryRunEvents.allSatisfy(\.acceptedByDryRunAdapter)
        case .simulatedRejected:
            return executionDryRunEvents.map(\.commandKind) == [.submit]
                && executionDryRunEvents.map(\.acceptedByDryRunAdapter) == [false]
        case .simulatedCancelled:
            return executionDryRunEvents.map(\.commandKind) == [.submit, .cancel]
                && executionDryRunEvents.allSatisfy(\.acceptedByDryRunAdapter)
        }
    }

    public init(
        pathID: Identifier,
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        outcome: ReleaseV050ExecutionOMSDryRunOutcome,
        omsEvents: [OMSLifecycleEvent],
        executionDryRunEvents: [ExecutionClientDryRunEvent],
        generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) throws {
        self.pathID = pathID
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.outcome = outcome
        self.omsEvents = omsEvents
        self.executionDryRunEvents = executionDryRunEvents
        self.generatedEnvelopes = generatedEnvelopes

        guard pathHeld else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("lifecyclePathDrift")
        }
    }
}

/// ReleaseV050ExecutionOMSDryRunLifecycleEvidence 汇总 GH-735 的 ExecutionEngine / OMS dry-run 证据。
public struct ReleaseV050ExecutionOMSDryRunLifecycleEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let sourceRiskEvidence: ReleaseV050RiskEngineRuntimeRunnerEvidence
    public let lifecycleRequests: [ReleaseV050ExecutionOMSDryRunLifecycleRequest]
    public let lifecyclePaths: [ReleaseV050ExecutionOMSDryRunLifecyclePath]
    public let suppressedRiskDecisions: [ReleaseV050ExecutionOMSDryRunSuppression]
    public let replayedOMSEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let replayedExecutionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let supportedLifecycleStates: [RuntimeOMSState]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionOMSAuthorized: Bool
    public let realOrderCommandsAvailable: Bool
    public let brokerGatewayConnected: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        lifecyclePaths.flatMap(\.generatedEnvelopes)
    }

    public var omsEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        generatedEnvelopes.filter { $0.payloadType == .omsLifecycleEvent }
    }

    public var executionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        generatedEnvelopes.filter { $0.payloadType == .executionClientDryRunEvent }
    }

    public var omsStates: [RuntimeOMSState] {
        lifecyclePaths.flatMap(\.omsStates)
    }

    public var executionDryRunEvents: [ExecutionClientDryRunEvent] {
        lifecyclePaths.flatMap(\.executionDryRunEvents)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-735"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-734"]
            && previousIssueID.rawValue == "GH-734"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-736", "GH-737", "GH-739"]
            && sourceRiskEvidence.evidenceHeld
            && lifecycleRequests.isEmpty == false
            && lifecycleRequests.allSatisfy(\.requestHeld)
            && lifecyclePaths.map(\.outcome) == ReleaseV050ExecutionOMSDryRunOutcome.allCases
            && lifecyclePaths.allSatisfy(\.pathHeld)
            && suppressedRiskDecisions.isEmpty == false
            && suppressedRiskDecisions.allSatisfy(\.suppressionHeld)
            && replayedOMSEnvelopes == generatedEnvelopes.filter { $0.payloadType == .omsLifecycleEvent }
            && replayedExecutionDryRunEnvelopes == generatedEnvelopes.filter { $0.payloadType == .executionClientDryRunEvent }
            && journalCompatibleEnvelopes == sourceRiskEvidence.journalCompatibleEnvelopes + generatedEnvelopes
            && journalCompatibleEnvelopes.map(\.sequence) == Array(1...journalCompatibleEnvelopes.count)
            && journalCompatibleEnvelopes.dropFirst().compactMap(\.causationID) == journalCompatibleEnvelopes.dropLast().map(\.eventID)
            && lifecycleStateCoverageHeld
            && rejectedBlockedNoSubmitHeld
            && boundaryHeld
            && validationAnchors == ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredValidationCommands
    }

    public var lifecycleStateCoverageHeld: Bool {
        supportedLifecycleStates == ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredLifecycleStates
            && Set(omsStates).isSuperset(of: Set(supportedLifecycleStates))
    }

    public var rejectedBlockedNoSubmitHeld: Bool {
        let suppressedIDs = Set(suppressedRiskDecisions.map(\.sourceRiskDecisionID))
        let nonAllowedIDs = Set(
            sourceRiskEvidence.decisionEvents
                .filter { $0.decision != .allowed }
                .map(\.decisionID)
        )
        let lifecycleSourceIDs = Set(lifecyclePaths.map(\.sourceRiskDecisionID))
        return suppressedIDs == nonAllowedIDs
            && lifecycleSourceIDs.isDisjoint(with: nonAllowedIDs)
            && executionDryRunEvents.allSatisfy { $0.commandKind == .submit || $0.commandKind == .cancel }
    }

    public var boundaryHeld: Bool {
        productionOMSAuthorized == false
            && realOrderCommandsAvailable == false
            && brokerGatewayConnected == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-735-v050-execution-oms-dry-run-lifecycle-evidence"),
        issueID: Identifier = Identifier.constant("GH-735"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-731"), Identifier.constant("GH-734")],
        previousIssueID: Identifier = Identifier.constant("GH-734"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-736"),
            Identifier.constant("GH-737"),
            Identifier.constant("GH-739")
        ],
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        sourceRiskEvidence: ReleaseV050RiskEngineRuntimeRunnerEvidence,
        lifecycleRequests: [ReleaseV050ExecutionOMSDryRunLifecycleRequest],
        lifecyclePaths: [ReleaseV050ExecutionOMSDryRunLifecyclePath],
        suppressedRiskDecisions: [ReleaseV050ExecutionOMSDryRunSuppression],
        replayedOMSEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        replayedExecutionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        supportedLifecycleStates: [RuntimeOMSState] = ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredLifecycleStates,
        validationAnchors: [String] = ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV050ExecutionOMSDryRunLifecycleContract.requiredValidationCommands,
        productionOMSAuthorized: Bool = false,
        realOrderCommandsAvailable: Bool = false,
        brokerGatewayConnected: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.runID = runID
        self.streamID = streamID
        self.correlationID = correlationID
        self.sourceRiskEvidence = sourceRiskEvidence
        self.lifecycleRequests = lifecycleRequests
        self.lifecyclePaths = lifecyclePaths
        self.suppressedRiskDecisions = suppressedRiskDecisions
        self.replayedOMSEnvelopes = replayedOMSEnvelopes
        self.replayedExecutionDryRunEnvelopes = replayedExecutionDryRunEnvelopes
        self.journalCompatibleEnvelopes = journalCompatibleEnvelopes
        self.supportedLifecycleStates = supportedLifecycleStates
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionOMSAuthorized = productionOMSAuthorized
        self.realOrderCommandsAvailable = realOrderCommandsAvailable
        self.brokerGatewayConnected = brokerGatewayConnected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("executionOMSDryRunLifecycleEvidenceDrift")
        }
    }
}

/// ReleaseV050ExecutionOMSDryRunLifecycleRunner 执行 GH-735 本地 ExecutionEngine / OMS dry-run lifecycle。
///
/// Runner 只从 allowed RiskDecisionEvent 生成 OMSLifecycleEvent 和 ExecutionClientDryRunEvent。
/// rejected / blocked RiskDecisionEvent 会被记录为 no-submit suppression，不会创建真实订单路径。
public struct ReleaseV050ExecutionOMSDryRunLifecycleRunner: Sendable {
    public let firstLifecycleRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        firstLifecycleRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_935),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.invalidRecordedAtStride(recordedAtStride)
        }
        self.firstLifecycleRecordedAt = firstLifecycleRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public func run(
        sourceRiskEvidence: ReleaseV050RiskEngineRuntimeRunnerEvidence,
        lifecycleRequests: [ReleaseV050ExecutionOMSDryRunLifecycleRequest]
    ) async throws -> ReleaseV050ExecutionOMSDryRunLifecycleEvidence {
        guard lifecycleRequests.isEmpty == false else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.emptyLifecycleRequests
        }
        for request in lifecycleRequests {
            try validate(request: request, sourceRiskEvidence: sourceRiskEvidence)
        }

        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>(
            envelopes: sourceRiskEvidence.journalCompatibleEnvelopes
        )
        var causationID = sourceRiskEvidence.journalCompatibleEnvelopes.last?.eventID
        var lifecyclePaths: [ReleaseV050ExecutionOMSDryRunLifecyclePath] = []
        var emittedEventIndex = 0

        for (pathIndex, request) in lifecycleRequests.enumerated() {
            var generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] = []
            var omsEvents: [OMSLifecycleEvent] = []
            var executionEvents: [ExecutionClientDryRunEvent] = []
            let orderID = Identifier.constant("gh-735-v050-dry-run-order-\(pathIndex + 1)")

            func publishOMS(state: RuntimeOMSState) async throws {
                let event = OMSLifecycleEvent(
                    orderID: orderID,
                    sourceRiskDecisionID: request.riskDecision.decisionID,
                    state: state
                )
                let payload = ReleaseV050RuntimeEventPayload.omsLifecycle(event)
                let envelope = try await bus.publish(
                    runID: sourceRiskEvidence.runID,
                    streamID: sourceRiskEvidence.streamID,
                    correlationID: sourceRiskEvidence.correlationID,
                    causationID: causationID,
                    sourceModule: payload.sourceModule,
                    payloadType: payload.payloadType,
                    payload: payload,
                    recordedAt: recordedAt(at: emittedEventIndex),
                    eventID: Identifier.constant(
                        "gh-735-v050-oms-\(pathIndex + 1)-\(state.rawValue)",
                        field: "runtimeEventID"
                    )
                )
                emittedEventIndex += 1
                causationID = envelope.eventID
                omsEvents.append(event)
                generatedEnvelopes.append(envelope)
            }

            func publishExecution(commandKind: RuntimeDryRunCommandKind, accepted: Bool) async throws {
                let event = ExecutionClientDryRunEvent(
                    requestID: Identifier.constant(
                        "gh-735-v050-execution-\(pathIndex + 1)-\(commandKind.rawValue)",
                        field: "runtimeExecutionDryRunRequestID"
                    ),
                    sourceOMSOrderID: orderID,
                    commandKind: commandKind,
                    acceptedByDryRunAdapter: accepted
                )
                let payload = ReleaseV050RuntimeEventPayload.executionClientDryRun(event)
                let envelope = try await bus.publish(
                    runID: sourceRiskEvidence.runID,
                    streamID: sourceRiskEvidence.streamID,
                    correlationID: sourceRiskEvidence.correlationID,
                    causationID: causationID,
                    sourceModule: payload.sourceModule,
                    payloadType: payload.payloadType,
                    payload: payload,
                    recordedAt: recordedAt(at: emittedEventIndex),
                    eventID: Identifier.constant(
                        "gh-735-v050-execution-\(pathIndex + 1)-\(commandKind.rawValue)",
                        field: "runtimeEventID"
                    )
                )
                emittedEventIndex += 1
                causationID = envelope.eventID
                executionEvents.append(event)
                generatedEnvelopes.append(envelope)
            }

            for state in request.outcome.omsStates {
                switch state {
                case .simulatedSubmitted:
                    try await publishExecution(commandKind: .submit, accepted: true)
                    try await publishOMS(state: state)
                case .simulatedRejected:
                    try await publishExecution(commandKind: .submit, accepted: false)
                    try await publishOMS(state: state)
                case .simulatedCancelled:
                    try await publishExecution(commandKind: .cancel, accepted: true)
                    try await publishOMS(state: state)
                default:
                    try await publishOMS(state: state)
                }
            }

            lifecyclePaths.append(
                try ReleaseV050ExecutionOMSDryRunLifecyclePath(
                    pathID: Identifier.constant("gh-735-v050-lifecycle-path-\(pathIndex + 1)"),
                    orderID: orderID,
                    sourceRiskDecisionID: request.riskDecision.decisionID,
                    outcome: request.outcome,
                    omsEvents: omsEvents,
                    executionDryRunEvents: executionEvents,
                    generatedEnvelopes: generatedEnvelopes
                )
            )
        }

        let replayedOMS = await bus.replay(
            runID: sourceRiskEvidence.runID,
            streamID: sourceRiskEvidence.streamID,
            payloadType: .omsLifecycleEvent
        )
        let replayedExecutionDryRun = await bus.replay(
            runID: sourceRiskEvidence.runID,
            streamID: sourceRiskEvidence.streamID,
            payloadType: .executionClientDryRunEvent
        )
        let generatedEnvelopes = lifecyclePaths.flatMap(\.generatedEnvelopes)
        guard replayedOMS == generatedEnvelopes.filter({ $0.payloadType == .omsLifecycleEvent }),
              replayedExecutionDryRun == generatedEnvelopes.filter({ $0.payloadType == .executionClientDryRunEvent }) else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.replayMismatch
        }

        let suppressions = try sourceRiskEvidence.decisionEvents
            .filter { $0.decision != .allowed }
            .map(ReleaseV050ExecutionOMSDryRunSuppression.init(decisionEvent:))

        return try ReleaseV050ExecutionOMSDryRunLifecycleEvidence(
            runID: sourceRiskEvidence.runID,
            streamID: sourceRiskEvidence.streamID,
            correlationID: sourceRiskEvidence.correlationID,
            sourceRiskEvidence: sourceRiskEvidence,
            lifecycleRequests: lifecycleRequests,
            lifecyclePaths: lifecyclePaths,
            suppressedRiskDecisions: suppressions,
            replayedOMSEnvelopes: replayedOMS,
            replayedExecutionDryRunEnvelopes: replayedExecutionDryRun,
            journalCompatibleEnvelopes: await bus.snapshot()
        )
    }

    public static func deterministicEvidence() async throws -> ReleaseV050ExecutionOMSDryRunLifecycleEvidence {
        let riskEvidence = try await ReleaseV050RiskEngineRuntimeRunner.deterministicEvidence()
        let runner = try ReleaseV050ExecutionOMSDryRunLifecycleRunner()
        return try await runner.run(
            sourceRiskEvidence: riskEvidence,
            lifecycleRequests: deterministicRequests(sourceRiskEvidence: riskEvidence)
        )
    }

    public static func deterministicRequests(
        sourceRiskEvidence: ReleaseV050RiskEngineRuntimeRunnerEvidence
    ) throws -> [ReleaseV050ExecutionOMSDryRunLifecycleRequest] {
        guard let allowedEmission = sourceRiskEvidence.emissions.first(where: { $0.decisionEvent.decision == .allowed }) else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("missingAllowedRiskDecision")
        }
        return try ReleaseV050ExecutionOMSDryRunOutcome.allCases.map {
            try ReleaseV050ExecutionOMSDryRunLifecycleRequest(riskEmission: allowedEmission, outcome: $0)
        }
    }

    private func validate(
        request: ReleaseV050ExecutionOMSDryRunLifecycleRequest,
        sourceRiskEvidence: ReleaseV050RiskEngineRuntimeRunnerEvidence
    ) throws {
        guard request.runID == sourceRiskEvidence.runID else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.runIDMismatch(
                expected: sourceRiskEvidence.runID,
                actual: request.runID
            )
        }
        guard request.streamID == sourceRiskEvidence.streamID else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.streamIDMismatch(
                expected: sourceRiskEvidence.streamID,
                actual: request.streamID
            )
        }
        guard request.correlationID == sourceRiskEvidence.correlationID else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.correlationIDMismatch(
                expected: sourceRiskEvidence.correlationID,
                actual: request.correlationID
            )
        }
        guard request.requestHeld else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("lifecycleRequestBoundaryDrift")
        }
    }

    private func recordedAt(at emittedEventIndex: Int) -> Date {
        firstLifecycleRecordedAt.addingTimeInterval(TimeInterval(emittedEventIndex) * recordedAtStride)
    }
}

/// ReleaseV050ExecutionOMSDryRunLifecycleContract 固定 GH-735 issue-level 验收合同。
public struct ReleaseV050ExecutionOMSDryRunLifecycleContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let supportedLifecycleStates: [RuntimeOMSState]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionOMSAuthorized: Bool
    public let realOrderCommandsAvailable: Bool
    public let brokerGatewayConnected: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        contractID.rawValue == "release-v050-execution-oms-dry-run-lifecycle-contract"
            && issueID.rawValue == "GH-735"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-734"]
            && previousIssueID.rawValue == "GH-734"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-736", "GH-737", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"
            && supportedLifecycleStates == Self.requiredLifecycleStates
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var productionDefaultsClosed: Bool {
        productionOMSAuthorized == false
            && realOrderCommandsAvailable == false
            && brokerGatewayConnected == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("release-v050-execution-oms-dry-run-lifecycle-contract"),
        issueID: Identifier = Identifier.constant("GH-735"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-731"), Identifier.constant("GH-734")],
        previousIssueID: Identifier = Identifier.constant("GH-734"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-736"),
            Identifier.constant("GH-737"),
            Identifier.constant("GH-739")
        ],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge",
        supportedLifecycleStates: [RuntimeOMSState] = Self.requiredLifecycleStates,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionOMSAuthorized: Bool = false,
        realOrderCommandsAvailable: Bool = false,
        brokerGatewayConnected: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.supportedLifecycleStates = supportedLifecycleStates
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionOMSAuthorized = productionOMSAuthorized
        self.realOrderCommandsAvailable = realOrderCommandsAvailable
        self.brokerGatewayConnected = brokerGatewayConnected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV050ExecutionOMSDryRunLifecycleError.contractDrift("executionOMSDryRunLifecycleContractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV050ExecutionOMSDryRunLifecycleContract {
        try ReleaseV050ExecutionOMSDryRunLifecycleContract()
    }

    public static let requiredLifecycleStates: [RuntimeOMSState] = [
        .created,
        .riskApproved,
        .acceptedByOMS,
        .simulatedSubmitted,
        .simulatedPartiallyFilled,
        .simulatedFilled,
        .simulatedRejected,
        .simulatedCancelled
    ]

    public static let requiredValidationAnchors = [
        "V050-10-EXECUTION-OMS-DRY-RUN-LIFECYCLE",
        "V050-10-RISK-DECISION-TO-OMS-LIFECYCLE",
        "V050-10-DRY-RUN-EXECUTION-EVENTS",
        "V050-10-REJECTED-BLOCKED-RISK-NO-SUBMIT",
        "V050-10-RUN-JOURNAL-REPLAYABLE-OMS-EXECUTION",
        "TVM-RELEASE-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH735ExecutionOMSDryRunLifecycleConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmitPaths",
        "bash checks/verify-v0.5.0-execution-oms.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
