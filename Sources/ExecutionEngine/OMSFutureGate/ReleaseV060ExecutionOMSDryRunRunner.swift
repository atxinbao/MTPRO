import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// ReleaseV060ExecutionOMSDryRunRunnerError 描述 GH-762 ExecutionEngine / OMS dry-run runner 错误。
///
/// 错误只覆盖 allowed RiskDecisionEvent 消费、OMS lifecycle / dry-run execution evidence
/// 生成和 rejected / blocked no-submit suppression；不表达 production OMS、真实 broker、
/// endpoint、secret 或真实订单能力。
public enum ReleaseV060ExecutionOMSDryRunRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
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
            "Release v0.6.0 Execution/OMS dry-run runner requires at least one allowed risk decision"
        case let .invalidRecordedAtStride(value):
            "Release v0.6.0 Execution/OMS recordedAt stride must be positive: \(value)"
        case let .nonRiskDecisionPayload(payloadType):
            "Release v0.6.0 Execution/OMS expected RiskDecisionEvent payload, actual \(payloadType.rawValue)"
        case let .rejectedOrBlockedDecisionCannotCreateLifecycle(decision):
            "Release v0.6.0 Execution/OMS rejects lifecycle creation from risk decision: \(decision.rawValue)"
        case let .runIDMismatch(expected, actual):
            "Release v0.6.0 Execution/OMS runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .streamIDMismatch(expected, actual):
            "Release v0.6.0 Execution/OMS streamID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .correlationIDMismatch(expected, actual):
            "Release v0.6.0 Execution/OMS correlationID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case .replayMismatch:
            "Release v0.6.0 Execution/OMS replayed events do not match emitted events"
        case let .forbiddenProductionCapability(capability):
            "Release v0.6.0 Execution/OMS rejected forbidden production capability: \(capability)"
        case let .contractDrift(reason):
            "Release v0.6.0 Execution/OMS contract drift: \(reason)"
        }
    }
}

/// ReleaseV060ExecutionOMSDryRunLifecycleRequest 是 GH-762 消费的 allowed risk decision 请求。
///
/// 请求只保存 RiskEngine 产出的 typed envelope 和 deterministic dry-run outcome；它不持有
/// broker session、ExecutionClient implementation、endpoint 或 order command credential。
public struct ReleaseV060ExecutionOMSDryRunLifecycleRequest: Codable, Equatable, Sendable {
    public let riskEmission: ReleaseV060RiskEngineRuntimeDecisionEmission
    public let outcome: ReleaseV050ExecutionOMSDryRunOutcome

    public var riskDecision: RiskDecisionEvent {
        riskEmission.decisionEvent
    }

    public var riskEnvelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload> {
        riskEmission.envelope
    }

    public var runID: Identifier { riskEnvelope.runID }
    public var streamID: MessageBusJournalStreamID { riskEnvelope.streamID }
    public var correlationID: Identifier { riskEnvelope.correlationID }

    public var requestHeld: Bool {
        riskEmission.emissionHeld
            && riskEnvelope.payloadType == .riskDecisionEvent
            && riskEnvelope.sourceModule == .riskEngine
            && riskEnvelope.payload == .riskDecision(riskDecision)
            && riskDecision.decision == .allowed
    }

    public init(
        riskEmission: ReleaseV060RiskEngineRuntimeDecisionEmission,
        outcome: ReleaseV050ExecutionOMSDryRunOutcome
    ) throws {
        guard riskEmission.envelope.payloadType == .riskDecisionEvent else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.nonRiskDecisionPayload(riskEmission.envelope.payloadType)
        }
        guard riskEmission.decisionEvent.decision == .allowed else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.rejectedOrBlockedDecisionCannotCreateLifecycle(
                riskEmission.decisionEvent.decision
            )
        }
        self.riskEmission = riskEmission
        self.outcome = outcome
    }
}

/// ReleaseV060ExecutionOMSDryRunSuppression 证明 rejected / blocked risk decision 没有 submit path。
public struct ReleaseV060ExecutionOMSDryRunSuppression: Codable, Equatable, Sendable {
    public let sourceRiskDecisionID: Identifier
    public let sourceRiskDecision: RuntimeRiskDecision
    public let reason: String
    public let omsLifecycleCreated: Bool
    public let executionDryRunEventCreated: Bool
    public let submitPathCreated: Bool
    public let brokerCommandCreated: Bool

    public var suppressionHeld: Bool {
        sourceRiskDecision != .allowed
            && reason.isEmpty == false
            && omsLifecycleCreated == false
            && executionDryRunEventCreated == false
            && submitPathCreated == false
            && brokerCommandCreated == false
    }

    public init(decisionEvent: RiskDecisionEvent) throws {
        guard decisionEvent.decision != .allowed else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("allowedDecisionCannotBeSuppressed")
        }
        self.sourceRiskDecisionID = decisionEvent.decisionID
        self.sourceRiskDecision = decisionEvent.decision
        self.reason = decisionEvent.reason
        self.omsLifecycleCreated = false
        self.executionDryRunEventCreated = false
        self.submitPathCreated = false
        self.brokerCommandCreated = false
    }
}

/// ReleaseV060ExecutionOMSDryRunLifecyclePath 是一个 allowed decision 生成的 dry-run order path。
public struct ReleaseV060ExecutionOMSDryRunLifecyclePath: Codable, Equatable, Sendable {
    public let pathID: Identifier
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let outcome: ReleaseV050ExecutionOMSDryRunOutcome
    public let omsEvents: [OMSLifecycleEvent]
    public let executionDryRunEvents: [ExecutionClientDryRunEvent]
    public let generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let realSubmitEnabled: Bool
    public let realCancelEnabled: Bool
    public let realReplaceEnabled: Bool

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
            && realSubmitEnabled == false
            && realCancelEnabled == false
            && realReplaceEnabled == false
    }

    public var commandCoverageHeld: Bool {
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
        generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        realSubmitEnabled: Bool = false,
        realCancelEnabled: Bool = false,
        realReplaceEnabled: Bool = false
    ) throws {
        self.pathID = pathID
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.outcome = outcome
        self.omsEvents = omsEvents
        self.executionDryRunEvents = executionDryRunEvents
        self.generatedEnvelopes = generatedEnvelopes
        self.realSubmitEnabled = realSubmitEnabled
        self.realCancelEnabled = realCancelEnabled
        self.realReplaceEnabled = realReplaceEnabled

        guard pathHeld else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("lifecyclePathDrift")
        }
    }
}

/// ReleaseV060ExecutionOMSDryRunRunnerResult 汇总 GH-762 dry-run lifecycle 证据。
public struct ReleaseV060ExecutionOMSDryRunRunnerResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    public let lifecycleRequests: [ReleaseV060ExecutionOMSDryRunLifecycleRequest]
    public let lifecyclePaths: [ReleaseV060ExecutionOMSDryRunLifecyclePath]
    public let suppressedRiskDecisions: [ReleaseV060ExecutionOMSDryRunSuppression]
    public let replayedOMSEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let replayedExecutionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let supportedLifecycleStates: [RuntimeOMSState]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionOMSAuthorized: Bool
    public let realOrderCommandsAvailable: Bool
    public let brokerGatewayConnected: Bool
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
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

    public var resultHeld: Bool {
        issueID.rawValue == "GH-762"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-761"]
            && previousIssueID.rawValue == "GH-761"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-763", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && sourceRiskResult.resultHeld
            && lifecycleRequests.isEmpty == false
            && lifecycleRequests.allSatisfy(\.requestHeld)
            && lifecyclePaths.map(\.outcome) == ReleaseV050ExecutionOMSDryRunOutcome.allCases
            && lifecyclePaths.allSatisfy(\.pathHeld)
            && suppressedRiskDecisions.isEmpty == false
            && suppressedRiskDecisions.allSatisfy(\.suppressionHeld)
            && replayedOMSEnvelopes == omsEnvelopes
            && replayedExecutionDryRunEnvelopes == executionDryRunEnvelopes
            && journalCompatibleEnvelopes == sourceRiskResult.journalCompatibleEnvelopes + generatedEnvelopes
            && journalCompatibleEnvelopes.map(\.sequence) == Array(1...journalCompatibleEnvelopes.count)
            && journalCompatibleEnvelopes.dropFirst().compactMap(\.causationID)
                == journalCompatibleEnvelopes.dropLast().map(\.eventID)
            && lifecycleStateCoverageHeld
            && rejectedBlockedNoSubmitHeld
            && boundaryHeld
            && validationAnchors == ReleaseV060ExecutionOMSDryRunRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060ExecutionOMSDryRunRunnerContract.requiredValidationCommands
    }

    public var lifecycleStateCoverageHeld: Bool {
        supportedLifecycleStates == ReleaseV060ExecutionOMSDryRunRunnerContract.requiredLifecycleStates
            && Set(omsStates).isSuperset(of: Set(supportedLifecycleStates))
    }

    public var rejectedBlockedNoSubmitHeld: Bool {
        let suppressedIDs = Set(suppressedRiskDecisions.map(\.sourceRiskDecisionID))
        let nonAllowedIDs = Set(
            sourceRiskResult.decisionEvents
                .filter { $0.decision != .allowed }
                .map(\.decisionID)
        )
        let lifecycleSourceIDs = Set(lifecyclePaths.map(\.sourceRiskDecisionID))
        return suppressedIDs == nonAllowedIDs
            && lifecycleSourceIDs.isDisjoint(with: nonAllowedIDs)
            && executionDryRunEvents.allSatisfy { $0.commandKind != .replace }
            && lifecyclePaths.allSatisfy { $0.realSubmitEnabled == false && $0.realCancelEnabled == false && $0.realReplaceEnabled == false }
    }

    public var boundaryHeld: Bool {
        productionOMSAuthorized == false
            && realOrderCommandsAvailable == false
            && brokerGatewayConnected == false
            && networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-762"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-761")],
        previousIssueID: Identifier = Identifier.constant("GH-761"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-763"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult,
        lifecycleRequests: [ReleaseV060ExecutionOMSDryRunLifecycleRequest],
        lifecyclePaths: [ReleaseV060ExecutionOMSDryRunLifecyclePath],
        suppressedRiskDecisions: [ReleaseV060ExecutionOMSDryRunSuppression],
        replayedOMSEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        replayedExecutionDryRunEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        supportedLifecycleStates: [RuntimeOMSState] = ReleaseV060ExecutionOMSDryRunRunnerContract.requiredLifecycleStates,
        validationAnchors: [String] = ReleaseV060ExecutionOMSDryRunRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060ExecutionOMSDryRunRunnerContract.requiredValidationCommands,
        productionOMSAuthorized: Bool = false,
        realOrderCommandsAvailable: Bool = false,
        brokerGatewayConnected: Bool = false,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.streamID = streamID
        self.correlationID = correlationID
        self.sourceRiskResult = sourceRiskResult
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
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard resultHeld else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("executionOMSDryRunRunnerResultDrift")
        }
    }
}

/// ReleaseV060ExecutionOMSDryRunRunner 执行 GH-762 本地 ExecutionEngine / OMS dry-run runner。
///
/// Runner 只从 #761 的 allowed RiskDecisionEvent 创建 local dry-run lifecycle。Rejected / blocked
/// risk decision 只生成 suppression evidence，不会创建 OMS submit lifecycle、ExecutionClient
/// request 或真实 broker command。
public struct ReleaseV060ExecutionOMSDryRunRunner: Sendable {
    public let firstLifecycleRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        firstLifecycleRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_762),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.invalidRecordedAtStride(recordedAtStride)
        }
        self.firstLifecycleRecordedAt = firstLifecycleRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public func run(
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult,
        lifecycleRequests: [ReleaseV060ExecutionOMSDryRunLifecycleRequest]
    ) async throws -> ReleaseV060ExecutionOMSDryRunRunnerResult {
        guard lifecycleRequests.isEmpty == false else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.emptyLifecycleRequests
        }
        for request in lifecycleRequests {
            try validate(request: request, sourceRiskResult: sourceRiskResult)
        }

        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>(
            envelopes: sourceRiskResult.journalCompatibleEnvelopes
        )
        var causationID = sourceRiskResult.journalCompatibleEnvelopes.last?.eventID
        var lifecyclePaths: [ReleaseV060ExecutionOMSDryRunLifecyclePath] = []
        var emittedEventIndex = 0

        for (pathIndex, request) in lifecycleRequests.enumerated() {
            var generatedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] = []
            var omsEvents: [OMSLifecycleEvent] = []
            var executionEvents: [ExecutionClientDryRunEvent] = []
            let orderID = Identifier.constant("gh-762-v060-dry-run-order-\(pathIndex + 1)")

            func publishOMS(state: RuntimeOMSState) async throws {
                let event = OMSLifecycleEvent(
                    orderID: orderID,
                    sourceRiskDecisionID: request.riskDecision.decisionID,
                    state: state
                )
                let payload = ReleaseV050RuntimeEventPayload.omsLifecycle(event)
                let envelope = try await bus.publish(
                    runID: sourceRiskResult.runID,
                    streamID: sourceRiskResult.streamID,
                    correlationID: sourceRiskResult.correlationID,
                    causationID: causationID,
                    sourceModule: payload.sourceModule,
                    payloadType: payload.payloadType,
                    payload: payload,
                    recordedAt: recordedAt(at: emittedEventIndex),
                    eventID: Identifier.constant(
                        "gh-762-v060-oms-\(pathIndex + 1)-\(state.rawValue)",
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
                        "gh-762-v060-execution-\(pathIndex + 1)-\(commandKind.rawValue)",
                        field: "runtimeExecutionDryRunRequestID"
                    ),
                    sourceOMSOrderID: orderID,
                    commandKind: commandKind,
                    acceptedByDryRunAdapter: accepted
                )
                let payload = ReleaseV050RuntimeEventPayload.executionClientDryRun(event)
                let envelope = try await bus.publish(
                    runID: sourceRiskResult.runID,
                    streamID: sourceRiskResult.streamID,
                    correlationID: sourceRiskResult.correlationID,
                    causationID: causationID,
                    sourceModule: payload.sourceModule,
                    payloadType: payload.payloadType,
                    payload: payload,
                    recordedAt: recordedAt(at: emittedEventIndex),
                    eventID: Identifier.constant(
                        "gh-762-v060-execution-\(pathIndex + 1)-\(commandKind.rawValue)",
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
                try ReleaseV060ExecutionOMSDryRunLifecyclePath(
                    pathID: Identifier.constant("gh-762-v060-lifecycle-path-\(pathIndex + 1)"),
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
            runID: sourceRiskResult.runID,
            streamID: sourceRiskResult.streamID,
            payloadType: .omsLifecycleEvent
        )
        let replayedExecutionDryRun = await bus.replay(
            runID: sourceRiskResult.runID,
            streamID: sourceRiskResult.streamID,
            payloadType: .executionClientDryRunEvent
        )
        let generatedEnvelopes = lifecyclePaths.flatMap(\.generatedEnvelopes)
        guard replayedOMS == generatedEnvelopes.filter({ $0.payloadType == .omsLifecycleEvent }),
              replayedExecutionDryRun == generatedEnvelopes.filter({ $0.payloadType == .executionClientDryRunEvent }) else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.replayMismatch
        }

        let suppressions = try sourceRiskResult.decisionEvents
            .filter { $0.decision != .allowed }
            .map(ReleaseV060ExecutionOMSDryRunSuppression.init(decisionEvent:))

        return try ReleaseV060ExecutionOMSDryRunRunnerResult(
            runID: sourceRiskResult.runID,
            streamID: sourceRiskResult.streamID,
            correlationID: sourceRiskResult.correlationID,
            sourceRiskResult: sourceRiskResult,
            lifecycleRequests: lifecycleRequests,
            lifecyclePaths: lifecyclePaths,
            suppressedRiskDecisions: suppressions,
            replayedOMSEnvelopes: replayedOMS,
            replayedExecutionDryRunEnvelopes: replayedExecutionDryRun,
            journalCompatibleEnvelopes: await bus.snapshot()
        )
    }

    public static func deterministicEvidence(
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    ) async throws -> ReleaseV060ExecutionOMSDryRunRunnerResult {
        let runner = try ReleaseV060ExecutionOMSDryRunRunner()
        return try await runner.run(
            sourceRiskResult: sourceRiskResult,
            lifecycleRequests: deterministicRequests(sourceRiskResult: sourceRiskResult)
        )
    }

    public static func deterministicRequests(
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    ) throws -> [ReleaseV060ExecutionOMSDryRunLifecycleRequest] {
        guard let allowedEmission = sourceRiskResult.emissions.first(where: { $0.decisionEvent.decision == .allowed }) else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("missingAllowedRiskDecision")
        }
        return try ReleaseV050ExecutionOMSDryRunOutcome.allCases.map {
            try ReleaseV060ExecutionOMSDryRunLifecycleRequest(riskEmission: allowedEmission, outcome: $0)
        }
    }

    private func validate(
        request: ReleaseV060ExecutionOMSDryRunLifecycleRequest,
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    ) throws {
        guard request.runID == sourceRiskResult.runID else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.runIDMismatch(
                expected: sourceRiskResult.runID,
                actual: request.runID
            )
        }
        guard request.streamID == sourceRiskResult.streamID else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.streamIDMismatch(
                expected: sourceRiskResult.streamID,
                actual: request.streamID
            )
        }
        guard request.correlationID == sourceRiskResult.correlationID else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.correlationIDMismatch(
                expected: sourceRiskResult.correlationID,
                actual: request.correlationID
            )
        }
        guard request.requestHeld else {
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("lifecycleRequestBoundaryDrift")
        }
    }

    private func recordedAt(at emittedEventIndex: Int) -> Date {
        firstLifecycleRecordedAt.addingTimeInterval(TimeInterval(emittedEventIndex) * recordedAtStride)
    }
}

/// ReleaseV060ExecutionOMSDryRunRunnerContract 固定 GH-762 issue-level 验收合同。
public struct ReleaseV060ExecutionOMSDryRunRunnerContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
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
        issueID.rawValue == "GH-762"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-761"]
            && previousIssueID.rawValue == "GH-761"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-763", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
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
        issueID: Identifier = Identifier.constant("GH-762"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-761")],
        previousIssueID: Identifier = Identifier.constant("GH-761"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-763"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
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
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
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
            throw ReleaseV060ExecutionOMSDryRunRunnerError.contractDrift("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060ExecutionOMSDryRunRunnerContract {
        try ReleaseV060ExecutionOMSDryRunRunnerContract()
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
        "V060-008-EXECUTION-OMS-DRY-RUN-RUNNER",
        "V060-008-ALLOWED-RISK-TO-OMS-LIFECYCLE",
        "V060-008-REJECTED-BLOCKED-NO-SUBMIT",
        "V060-008-SIMULATED-SUBMIT-NOT-REAL",
        "V060-008-SAME-RUN-JOURNAL-OMS-SEQUENCE",
        "V060-008-NO-PRODUCTION-OMS-BROKER-PATH",
        "TVM-RELEASE-V060-EXECUTION-OMS-DRY-RUN-RUNNER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH762ExecutionOMSDryRunRunnerConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmit",
        "bash checks/verify-v0.6.0-execution-oms-dry-run-runner.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
