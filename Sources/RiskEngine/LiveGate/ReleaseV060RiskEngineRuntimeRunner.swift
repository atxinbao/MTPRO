import DomainModel
import Foundation
import MessageBus

/// ReleaseV060RiskEngineRuntimeRunnerError 描述 GH-761 RiskEngine runtime runner 的本地合同错误。
///
/// 错误只覆盖同一 run journal 中 StrategyIntentEvent 的消费、RiskDecisionEvent 的追加、
/// policy gate evidence 和 downstream suppression evidence；不表达 ExecutionClient、OMS、
/// broker、endpoint、secret 或真实订单能力。
public enum ReleaseV060RiskEngineRuntimeRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyJournal
    case missingStrategyIntentRecords
    case invalidRecordedAtStride(TimeInterval)
    case nonContiguousSequence(expected: Int, actual: Int)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case streamIDMismatch(expected: MessageBusJournalStreamID, actual: MessageBusJournalStreamID)
    case correlationIDMismatch(expected: Identifier, actual: Identifier)
    case replayMismatch
    case policyBoundaryMismatch(String)
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case .emptyJournal:
            "Release v0.6.0 RiskEngine runner requires an upstream local run journal"
        case .missingStrategyIntentRecords:
            "Release v0.6.0 RiskEngine runner requires StrategyIntentEvent records"
        case let .invalidRecordedAtStride(value):
            "Release v0.6.0 RiskEngine runner recordedAt stride must be positive: \(value)"
        case let .nonContiguousSequence(expected, actual):
            "Release v0.6.0 RiskEngine runner sequence mismatch: expected \(expected), actual \(actual)"
        case let .runIDMismatch(expected, actual):
            "Release v0.6.0 RiskEngine runner runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .streamIDMismatch(expected, actual):
            "Release v0.6.0 RiskEngine runner streamID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .correlationIDMismatch(expected, actual):
            "Release v0.6.0 RiskEngine runner correlationID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case .replayMismatch:
            "Release v0.6.0 RiskEngine runner replayed risk decisions do not match emissions"
        case let .policyBoundaryMismatch(reason):
            "Release v0.6.0 RiskEngine runner policy boundary mismatch: \(reason)"
        case let .forbiddenProductionCapability(capability):
            "Release v0.6.0 RiskEngine runner rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV060RiskEngineRuntimeDecisionScenario 固定 GH-761 deterministic policy scenario。
///
/// Scenario 只用于本地 dry-run policy coverage：allow、reject、kill switch blocked 和
/// no-trade blocked。它不是 production approval，也不是 broker routing config。
public enum ReleaseV060RiskEngineRuntimeDecisionScenario: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allow = "allow"
    case reject = "reject"
    case killSwitchBlocked = "kill-switch-blocked"
    case noTradeBlocked = "no-trade-blocked"
}

/// ReleaseV060RiskEngineRuntimeDecisionEmission 记录单条 RiskDecisionEvent 输出。
///
/// Emission 复用 v0.5 RiskEngine policy evaluation 类型，证明 GH-761 只是在 v0.6.0
/// 同一 run journal 上追加 typed risk decision，不新增 OMS lifecycle、ExecutionClient request
/// 或 broker command。
public struct ReleaseV060RiskEngineRuntimeDecisionEmission: Codable, Equatable, Sendable {
    public let scenario: ReleaseV060RiskEngineRuntimeDecisionScenario
    public let request: ReleaseV050RiskEngineRuntimeEvaluationRequest
    public let policyEvaluation: ReleaseV050RiskEngineRuntimePolicyEvaluation
    public let decisionEvent: RiskDecisionEvent
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let downstreamOMSLifecycleCreated: Bool
    public let executionClientRequestCreated: Bool
    public let submitPathCreated: Bool
    public let brokerCommandCreated: Bool

    public var emissionHeld: Bool {
        request.requestHeld
            && policyEvaluation.evaluationHeld
            && envelope.envelopeHeld
            && envelope.sourceModule == .riskEngine
            && envelope.payloadType == .riskDecisionEvent
            && envelope.payload == .riskDecision(decisionEvent)
            && envelope.runID == request.intentInput.runID
            && envelope.streamID == request.intentInput.streamID
            && envelope.correlationID == request.intentInput.correlationID
            && decisionEvent.sourceIntentID == request.intentInput.intent.strategyID
            && decisionEvent.decision == policyEvaluation.decision
            && decisionEvent.reason == policyEvaluation.reason.rawValue
            && downstreamSuppressionHeld
    }

    public var downstreamSuppressionHeld: Bool {
        downstreamOMSLifecycleCreated == false
            && executionClientRequestCreated == false
            && submitPathCreated == false
            && brokerCommandCreated == false
    }

    public init(
        scenario: ReleaseV060RiskEngineRuntimeDecisionScenario,
        request: ReleaseV050RiskEngineRuntimeEvaluationRequest,
        policyEvaluation: ReleaseV050RiskEngineRuntimePolicyEvaluation,
        decisionEvent: RiskDecisionEvent,
        envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>,
        downstreamOMSLifecycleCreated: Bool = false,
        executionClientRequestCreated: Bool = false,
        submitPathCreated: Bool = false,
        brokerCommandCreated: Bool = false
    ) throws {
        self.scenario = scenario
        self.request = request
        self.policyEvaluation = policyEvaluation
        self.decisionEvent = decisionEvent
        self.envelope = envelope
        self.downstreamOMSLifecycleCreated = downstreamOMSLifecycleCreated
        self.executionClientRequestCreated = executionClientRequestCreated
        self.submitPathCreated = submitPathCreated
        self.brokerCommandCreated = brokerCommandCreated

        guard emissionHeld else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.policyBoundaryMismatch("riskDecisionEmissionDrift")
        }
    }
}

/// ReleaseV060RiskEngineRuntimeRunnerResult 汇总 GH-761 本地 RiskEngine runner 证据。
public struct ReleaseV060RiskEngineRuntimeRunnerResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let upstreamJournalEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let intentInputs: [ReleaseV050RiskEngineRuntimeIntentInput]
    public let requests: [ReleaseV050RiskEngineRuntimeEvaluationRequest]
    public let emissions: [ReleaseV060RiskEngineRuntimeDecisionEmission]
    public let replayedDecisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionEvents: [RiskDecisionEvent] {
        emissions.map(\.decisionEvent)
    }

    public var riskDecisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        emissions.map(\.envelope)
    }

    public var policyEvaluations: [ReleaseV050RiskEngineRuntimePolicyEvaluation] {
        emissions.map(\.policyEvaluation)
    }

    public var resultHeld: Bool {
        issueID.rawValue == "GH-761"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-760"]
            && previousIssueID.rawValue == "GH-760"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-762", "GH-763", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && strategyIntentConsumptionHeld
            && outcomeCoverageHeld
            && journalCompatibilityHeld
            && downstreamSuppressionHeld
            && forbiddenRuntimeHeld
            && validationAnchors == ReleaseV060RiskEngineRuntimeRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060RiskEngineRuntimeRunnerContract.requiredValidationCommands
    }

    public var strategyIntentConsumptionHeld: Bool {
        intentInputs.isEmpty == false
            && intentInputs.allSatisfy(\.inputHeld)
            && Set(intentInputs.map(\.runID)) == [runID]
            && Set(intentInputs.map(\.streamID)) == [streamID]
            && Set(intentInputs.map(\.correlationID)) == [correlationID]
            && Set(requests.map(\.intentInput.intent.strategyID)) == Set(intentInputs.map(\.intent.strategyID))
            && requests.allSatisfy(\.requestHeld)
    }

    public var outcomeCoverageHeld: Bool {
        emissions.map(\.scenario) == [.allow, .reject, .killSwitchBlocked, .noTradeBlocked]
            && policyEvaluations.map(\.decision) == [.allowed, .rejected, .blocked, .blocked]
            && policyEvaluations.map(\.reason) == [
                .dryRunAllowed,
                .notionalLimitExceeded,
                .killSwitchActive,
                .noTradeActive
            ]
            && Set(decisionEvents.map(\.sourceIntentID)) == Set(intentInputs.map(\.intent.strategyID))
    }

    public var journalCompatibilityHeld: Bool {
        journalCompatibleEnvelopes == upstreamJournalEnvelopes + riskDecisionEnvelopes
            && replayedDecisionEnvelopes == riskDecisionEnvelopes
            && journalCompatibleEnvelopes.map(\.sequence) == Array(1...journalCompatibleEnvelopes.count)
            && journalCompatibleEnvelopes.dropFirst().compactMap(\.causationID)
                == journalCompatibleEnvelopes.dropLast().map(\.eventID)
            && riskDecisionEnvelopes.first?.causationID == upstreamJournalEnvelopes.last?.eventID
            && journalCompatibleEnvelopes.allSatisfy(\.envelopeHeld)
    }

    public var downstreamSuppressionHeld: Bool {
        emissions.allSatisfy(\.downstreamSuppressionHeld)
            && emissions.filter { $0.policyEvaluation.decision != .allowed }.allSatisfy {
                $0.downstreamOMSLifecycleCreated == false
                    && $0.executionClientRequestCreated == false
                    && $0.submitPathCreated == false
                    && $0.brokerCommandCreated == false
            }
    }

    public var forbiddenRuntimeHeld: Bool {
        executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionTradingEnabledByDefault == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-761"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-760")],
        previousIssueID: Identifier = Identifier.constant("GH-760"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-762"),
            Identifier.constant("GH-763"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        upstreamJournalEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        intentInputs: [ReleaseV050RiskEngineRuntimeIntentInput],
        requests: [ReleaseV050RiskEngineRuntimeEvaluationRequest],
        emissions: [ReleaseV060RiskEngineRuntimeDecisionEmission],
        replayedDecisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        validationAnchors: [String] = ReleaseV060RiskEngineRuntimeRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060RiskEngineRuntimeRunnerContract.requiredValidationCommands,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
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
        self.upstreamJournalEnvelopes = upstreamJournalEnvelopes
        self.intentInputs = intentInputs
        self.requests = requests
        self.emissions = emissions
        self.replayedDecisionEnvelopes = replayedDecisionEnvelopes
        self.journalCompatibleEnvelopes = journalCompatibleEnvelopes
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard resultHeld else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.policyBoundaryMismatch("riskEngineRuntimeRunnerResultDrift")
        }
    }
}

/// ReleaseV060RiskEngineRuntimeRunner 执行 GH-761 本地 RiskEngine runtime runner。
///
/// Runner 只消费已经由 #760 生成的 StrategyIntentEvent envelope，并在同一个 run journal
/// 继续追加 RiskDecisionEvent。Allow / reject / blocked 都只是 dry-run 本地风控证据，
/// 不创建 OMS lifecycle、不访问 ExecutionClient、不连接 broker，也不发送真实订单。
public struct ReleaseV060RiskEngineRuntimeRunner: Sendable {
    public let firstDecisionRecordedAt: Date
    public let recordedAtStride: TimeInterval
    public let eventIDPrefix: String

    public init(
        firstDecisionRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_761),
        recordedAtStride: TimeInterval = 1,
        eventIDPrefix: String = "gh-761-v060-risk-decision-event"
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.invalidRecordedAtStride(recordedAtStride)
        }
        self.firstDecisionRecordedAt = firstDecisionRecordedAt
        self.recordedAtStride = recordedAtStride
        self.eventIDPrefix = try FoundationTargetID(eventIDPrefix, field: "releaseV060RiskDecisionEventIDPrefix").rawValue
    }

    public func run(
        upstreamJournalEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) async throws -> ReleaseV060RiskEngineRuntimeRunnerResult {
        try validateUpstreamJournal(upstreamJournalEnvelopes)
        let runID = upstreamJournalEnvelopes[0].runID
        let streamID = upstreamJournalEnvelopes[0].streamID
        let correlationID = upstreamJournalEnvelopes[0].correlationID
        let intentInputs = try upstreamJournalEnvelopes
            .filter { $0.payloadType == .strategyIntentEvent }
            .map(ReleaseV050RiskEngineRuntimeIntentInput.init)
        guard intentInputs.isEmpty == false else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.missingStrategyIntentRecords
        }

        let requests = try deterministicRequests(from: intentInputs)
        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>(envelopes: upstreamJournalEnvelopes)
        var emissions: [ReleaseV060RiskEngineRuntimeDecisionEmission] = []
        var causationID = upstreamJournalEnvelopes.last?.eventID

        for (index, plan) in requests.enumerated() {
            let policyEvaluation = try plan.request.policy.evaluate(input: plan.request.intentInput)
            let decisionEvent = try RiskDecisionEvent(
                decisionID: Identifier.constant("gh-761-v060-risk-decision-\(index + 1)"),
                sourceIntentID: plan.request.intentInput.intent.strategyID,
                decision: policyEvaluation.decision,
                reason: policyEvaluation.reason.rawValue
            )
            let payload = ReleaseV050RuntimeEventPayload.riskDecision(decisionEvent)
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: firstDecisionRecordedAt.addingTimeInterval(TimeInterval(index) * recordedAtStride),
                eventID: Identifier.constant("\(eventIDPrefix)-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
            emissions.append(
                try ReleaseV060RiskEngineRuntimeDecisionEmission(
                    scenario: plan.scenario,
                    request: plan.request,
                    policyEvaluation: policyEvaluation,
                    decisionEvent: decisionEvent,
                    envelope: envelope
                )
            )
        }

        let replayed = await bus.replay(runID: runID, streamID: streamID, payloadType: .riskDecisionEvent)
        guard replayed == emissions.map(\.envelope) else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.replayMismatch
        }

        return try ReleaseV060RiskEngineRuntimeRunnerResult(
            runID: runID,
            streamID: streamID,
            correlationID: correlationID,
            upstreamJournalEnvelopes: upstreamJournalEnvelopes,
            intentInputs: intentInputs,
            requests: requests.map(\.request),
            emissions: emissions,
            replayedDecisionEnvelopes: replayed,
            journalCompatibleEnvelopes: await bus.snapshot()
        )
    }

    public static func deterministicEvidence(
        upstreamJournalEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) async throws -> ReleaseV060RiskEngineRuntimeRunnerResult {
        let runner = try ReleaseV060RiskEngineRuntimeRunner()
        return try await runner.run(upstreamJournalEnvelopes: upstreamJournalEnvelopes)
    }

    private struct EvaluationPlan {
        let scenario: ReleaseV060RiskEngineRuntimeDecisionScenario
        let request: ReleaseV050RiskEngineRuntimeEvaluationRequest
    }

    private func deterministicRequests(
        from inputs: [ReleaseV050RiskEngineRuntimeIntentInput]
    ) throws -> [EvaluationPlan] {
        guard let firstInput = inputs.first else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.missingStrategyIntentRecords
        }
        let secondInput = inputs.dropFirst().first ?? firstInput
        return try [
            EvaluationPlan(scenario: .allow, request: request(input: firstInput, policyID: "gh-761-policy-allow")),
            EvaluationPlan(
                scenario: .reject,
                request: request(input: secondInput, policyID: "gh-761-policy-notional-reject", maxProjectedNotionalMinorUnits: 1)
            ),
            EvaluationPlan(
                scenario: .killSwitchBlocked,
                request: request(input: firstInput, policyID: "gh-761-policy-kill-switch", killSwitchActive: true)
            ),
            EvaluationPlan(
                scenario: .noTradeBlocked,
                request: request(input: secondInput, policyID: "gh-761-policy-no-trade", noTradeActive: true)
            )
        ]
    }

    private func request(
        input: ReleaseV050RiskEngineRuntimeIntentInput,
        policyID: String,
        maxProjectedNotionalMinorUnits: Int64 = Int64.max / 4,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false
    ) throws -> ReleaseV050RiskEngineRuntimeEvaluationRequest {
        let policy = try ReleaseV050RiskEngineRuntimePolicy(
            policyID: Identifier.constant(policyID),
            maxTargetQuantityMinorUnits: Int64.max / 4,
            maxProjectedNotionalMinorUnits: maxProjectedNotionalMinorUnits,
            maxAggregateExposureMinorUnits: Int64.max / 4,
            deterministicReferencePriceMinorUnits: 1,
            killSwitchActive: killSwitchActive,
            noTradeActive: noTradeActive
        )
        return ReleaseV050RiskEngineRuntimeEvaluationRequest(intentInput: input, policy: policy)
    }

    private func validateUpstreamJournal(
        _ envelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) throws {
        guard envelopes.isEmpty == false else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.emptyJournal
        }
        let runID = envelopes[0].runID
        let streamID = envelopes[0].streamID
        let correlationID = envelopes[0].correlationID
        for (index, envelope) in envelopes.enumerated() {
            let expectedSequence = index + 1
            guard envelope.sequence == expectedSequence else {
                throw ReleaseV060RiskEngineRuntimeRunnerError.nonContiguousSequence(
                    expected: expectedSequence,
                    actual: envelope.sequence
                )
            }
            guard envelope.runID == runID else {
                throw ReleaseV060RiskEngineRuntimeRunnerError.runIDMismatch(expected: runID, actual: envelope.runID)
            }
            guard envelope.streamID == streamID else {
                throw ReleaseV060RiskEngineRuntimeRunnerError.streamIDMismatch(expected: streamID, actual: envelope.streamID)
            }
            guard envelope.correlationID == correlationID else {
                throw ReleaseV060RiskEngineRuntimeRunnerError.correlationIDMismatch(
                    expected: correlationID,
                    actual: envelope.correlationID
                )
            }
            guard envelope.envelopeHeld else {
                throw ReleaseV060RiskEngineRuntimeRunnerError.policyBoundaryMismatch("upstream envelope boundary is not held")
            }
        }
    }
}

/// ReleaseV060RiskEngineRuntimeRunnerContract 固定 GH-761 issue-level 验收合同。
public struct ReleaseV060RiskEngineRuntimeRunnerContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-761"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-760"]
            && previousIssueID.rawValue == "GH-760"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-762", "GH-763", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-761"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-760")],
        previousIssueID: Identifier = Identifier.constant("GH-760"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-762"),
            Identifier.constant("GH-763"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV060RiskEngineRuntimeRunnerError.policyBoundaryMismatch("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060RiskEngineRuntimeRunnerContract {
        try ReleaseV060RiskEngineRuntimeRunnerContract()
    }

    public static let requiredValidationAnchors = [
        "V060-007-RISKENGINE-RUNTIME-RUNNER",
        "V060-007-STRATEGY-INTENT-TO-RISK-DECISION",
        "V060-007-ALLOW-REJECT-BLOCKED-POLICY-EVIDENCE",
        "V060-007-KILL-SWITCH-NO-TRADE-BLOCKS-OMS",
        "V060-007-SAME-RUN-JOURNAL-RISK-SEQUENCE",
        "V060-007-NO-RISK-EXECUTION-PATH",
        "TVM-RELEASE-V060-RISKENGINE-RUNTIME-RUNNER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH761RiskEngineRuntimeRunnerConsumesStrategyIntentsAndEmitsAllowRejectBlockedDecisions",
        "bash checks/verify-v0.6.0-riskengine-runtime-runner.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
