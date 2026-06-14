import DomainModel
import Foundation
import MessageBus

/// ReleaseV050RiskEngineRuntimeRunnerError 描述 GH-734 runtime runner 的合同错误。
///
/// 错误只覆盖 typed StrategyIntentEvent 消费、RiskDecisionEvent 产出、policy evidence
/// 和本地 replay 边界；不表达真实 broker、ExecutionClient、OMS 或生产订单能力。
public enum ReleaseV050RiskEngineRuntimeRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRequests
    case invalidRecordedAtStride(TimeInterval)
    case nonStrategyIntentPayload(RuntimeEventPayloadType)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case streamIDMismatch(expected: MessageBusJournalStreamID, actual: MessageBusJournalStreamID)
    case correlationIDMismatch(expected: Identifier, actual: Identifier)
    case policyBoundaryMismatch(String)
    case replayMismatch
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case .emptyRequests:
            "Release v0.5.0 RiskEngine runner requires at least one strategy intent request"
        case let .invalidRecordedAtStride(value):
            "Release v0.5.0 RiskEngine runner recordedAt stride must be positive: \(value)"
        case let .nonStrategyIntentPayload(payloadType):
            "Release v0.5.0 RiskEngine runner expected StrategyIntentEvent payload, actual \(payloadType.rawValue)"
        case let .runIDMismatch(expected, actual):
            "Release v0.5.0 RiskEngine runner runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .streamIDMismatch(expected, actual):
            "Release v0.5.0 RiskEngine runner streamID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .correlationIDMismatch(expected, actual):
            "Release v0.5.0 RiskEngine runner correlationID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .policyBoundaryMismatch(reason):
            "Release v0.5.0 RiskEngine runner policy boundary mismatch: \(reason)"
        case .replayMismatch:
            "Release v0.5.0 RiskEngine runner replayed risk decisions do not match emitted decisions"
        case let .forbiddenProductionCapability(capability):
            "Release v0.5.0 RiskEngine runner rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV050RiskEngineRuntimeDecisionReason 固定 GH-734 runtime risk decision reason vocabulary。
public enum ReleaseV050RiskEngineRuntimeDecisionReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRunAllowed = "dry-run-allowed"
    case targetQuantityLimitExceeded = "target-quantity-limit-exceeded"
    case notionalLimitExceeded = "notional-limit-exceeded"
    case aggregateExposureLimitExceeded = "aggregate-exposure-limit-exceeded"
    case killSwitchActive = "kill-switch-active"
    case noTradeActive = "no-trade-active"
}

/// ReleaseV050RiskEngineRuntimePolicyCheck 记录单条 intent 已通过或触发的 policy gate。
public enum ReleaseV050RiskEngineRuntimePolicyCheck: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case typedStrategyIntent
    case targetQuantityLimit
    case notionalLimit
    case aggregateExposureLimit
    case killSwitch
    case noTrade
    case productionBoundary
}

/// ReleaseV050RiskEngineRuntimeIntentInput 是 RiskEngine 消费的 typed StrategyIntentEvent envelope。
///
/// 输入只依赖 MessageBus 的 typed envelope，不 import Trader target，也不获得 ExecutionEngine、
/// OMS、ExecutionClient、broker gateway 或 order command 能力。
public struct ReleaseV050RiskEngineRuntimeIntentInput: Codable, Equatable, Sendable {
    public let intentEnvelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let intent: StrategyIntentEvent

    public var runID: Identifier { intentEnvelope.runID }
    public var streamID: MessageBusJournalStreamID { intentEnvelope.streamID }
    public var correlationID: Identifier { intentEnvelope.correlationID }

    public var inputHeld: Bool {
        intentEnvelope.envelopeHeld
            && intentEnvelope.sourceModule == .traderStrategy
            && intentEnvelope.payloadType == .strategyIntentEvent
            && intentEnvelope.payload == .strategyIntent(intent)
            && intent.targetQuantity.semantic == .quantity
            && intent.strategyID.rawValue.isEmpty == false
            && intent.instrument.venue.rawValue == "binance"
    }

    public init(intentEnvelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>) throws {
        guard intentEnvelope.payloadType == .strategyIntentEvent else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.nonStrategyIntentPayload(intentEnvelope.payloadType)
        }
        guard case let .strategyIntent(intent) = intentEnvelope.payload else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.nonStrategyIntentPayload(intentEnvelope.payloadType)
        }
        guard intentEnvelope.sourceModule == .traderStrategy else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .strategyIntentEvent, actual: intentEnvelope.payloadType)
        }
        self.intentEnvelope = intentEnvelope
        self.intent = intent
    }
}

/// ReleaseV050RiskEngineRuntimePolicy 是 GH-734 的 deterministic runtime policy snapshot。
///
/// Policy 覆盖 notional / exposure limit、kill switch、no-trade 和禁止生产能力的边界。
/// 它不读取真实账户、不连接 endpoint、不调用 ExecutionEngine / OMS / broker。
public struct ReleaseV050RiskEngineRuntimePolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let maxTargetQuantityMinorUnits: Int64
    public let maxProjectedNotionalMinorUnits: Int64
    public let maxAggregateExposureMinorUnits: Int64
    public let currentAggregateExposureMinorUnits: Int64
    public let deterministicReferencePriceMinorUnits: Int64
    public let killSwitchActive: Bool
    public let noTradeActive: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool

    public var boundaryHeld: Bool {
        maxTargetQuantityMinorUnits > 0
            && maxProjectedNotionalMinorUnits > 0
            && maxAggregateExposureMinorUnits > 0
            && currentAggregateExposureMinorUnits >= 0
            && deterministicReferencePriceMinorUnits > 0
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
    }

    public init(
        policyID: Identifier,
        maxTargetQuantityMinorUnits: Int64,
        maxProjectedNotionalMinorUnits: Int64,
        maxAggregateExposureMinorUnits: Int64,
        currentAggregateExposureMinorUnits: Int64 = 0,
        deterministicReferencePriceMinorUnits: Int64,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false
    ) throws {
        guard maxTargetQuantityMinorUnits > 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("maxTargetQuantityMinorUnits must be positive")
        }
        guard maxProjectedNotionalMinorUnits > 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("maxProjectedNotionalMinorUnits must be positive")
        }
        guard maxAggregateExposureMinorUnits > 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("maxAggregateExposureMinorUnits must be positive")
        }
        guard currentAggregateExposureMinorUnits >= 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("currentAggregateExposureMinorUnits must be non-negative")
        }
        guard deterministicReferencePriceMinorUnits > 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("deterministicReferencePriceMinorUnits must be positive")
        }
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            executionClientAccessEnabled: executionClientAccessEnabled,
            brokerGatewayAccessEnabled: brokerGatewayAccessEnabled
        )

        self.policyID = policyID
        self.maxTargetQuantityMinorUnits = maxTargetQuantityMinorUnits
        self.maxProjectedNotionalMinorUnits = maxProjectedNotionalMinorUnits
        self.maxAggregateExposureMinorUnits = maxAggregateExposureMinorUnits
        self.currentAggregateExposureMinorUnits = currentAggregateExposureMinorUnits
        self.deterministicReferencePriceMinorUnits = deterministicReferencePriceMinorUnits
        self.killSwitchActive = killSwitchActive
        self.noTradeActive = noTradeActive
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
    }

    public func evaluate(
        input: ReleaseV050RiskEngineRuntimeIntentInput
    ) throws -> ReleaseV050RiskEngineRuntimePolicyEvaluation {
        guard boundaryHeld else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("policy boundary is not held")
        }

        let targetQuantityMinorUnits = input.intent.targetQuantity.minorUnits
        let projectedNotionalMinorUnits = try Self.checkedProduct(
            targetQuantityMinorUnits,
            deterministicReferencePriceMinorUnits
        )
        let projectedAggregateExposureMinorUnits = try Self.checkedSum(
            currentAggregateExposureMinorUnits,
            targetQuantityMinorUnits
        )

        let decisionReason: (RuntimeRiskDecision, ReleaseV050RiskEngineRuntimeDecisionReason)
        let passedPolicyChecks: [ReleaseV050RiskEngineRuntimePolicyCheck]
        if killSwitchActive {
            decisionReason = (.blocked, .killSwitchActive)
            passedPolicyChecks = [.typedStrategyIntent, .productionBoundary]
        } else if noTradeActive {
            decisionReason = (.blocked, .noTradeActive)
            passedPolicyChecks = [.typedStrategyIntent, .productionBoundary, .killSwitch]
        } else if targetQuantityMinorUnits > maxTargetQuantityMinorUnits {
            decisionReason = (.rejected, .targetQuantityLimitExceeded)
            passedPolicyChecks = [.typedStrategyIntent, .productionBoundary, .killSwitch, .noTrade]
        } else if projectedNotionalMinorUnits > maxProjectedNotionalMinorUnits {
            decisionReason = (.rejected, .notionalLimitExceeded)
            passedPolicyChecks = [
                .typedStrategyIntent,
                .productionBoundary,
                .killSwitch,
                .noTrade,
                .targetQuantityLimit
            ]
        } else if projectedAggregateExposureMinorUnits > maxAggregateExposureMinorUnits {
            decisionReason = (.rejected, .aggregateExposureLimitExceeded)
            passedPolicyChecks = [
                .typedStrategyIntent,
                .productionBoundary,
                .killSwitch,
                .noTrade,
                .targetQuantityLimit,
                .notionalLimit
            ]
        } else {
            decisionReason = (.allowed, .dryRunAllowed)
            passedPolicyChecks = ReleaseV050RiskEngineRuntimePolicyCheck.allCases
        }

        return ReleaseV050RiskEngineRuntimePolicyEvaluation(
            policyID: policyID,
            decision: decisionReason.0,
            reason: decisionReason.1,
            targetQuantityMinorUnits: targetQuantityMinorUnits,
            projectedNotionalMinorUnits: projectedNotionalMinorUnits,
            projectedAggregateExposureMinorUnits: projectedAggregateExposureMinorUnits,
            passedPolicyChecks: passedPolicyChecks
        )
    }

    private static func checkedProduct(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        guard result.overflow == false else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("projected notional overflow")
        }
        return result.partialValue
    }

    private static func checkedSum(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
        let result = lhs.addingReportingOverflow(rhs)
        guard result.overflow == false else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("aggregate exposure overflow")
        }
        return result.partialValue
    }

    private static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        executionClientAccessEnabled: Bool,
        brokerGatewayAccessEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("executionClientAccessEnabled", executionClientAccessEnabled),
            ("brokerGatewayAccessEnabled", brokerGatewayAccessEnabled)
        ]
        for (field, value) in forbiddenFlags where value {
            throw ReleaseV050RiskEngineRuntimeRunnerError.forbiddenProductionCapability(field)
        }
    }
}

/// ReleaseV050RiskEngineRuntimePolicyEvaluation 是单条 intent 的 policy 计算结果。
public struct ReleaseV050RiskEngineRuntimePolicyEvaluation: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let decision: RuntimeRiskDecision
    public let reason: ReleaseV050RiskEngineRuntimeDecisionReason
    public let targetQuantityMinorUnits: Int64
    public let projectedNotionalMinorUnits: Int64
    public let projectedAggregateExposureMinorUnits: Int64
    public let passedPolicyChecks: [ReleaseV050RiskEngineRuntimePolicyCheck]

    public var evaluationHeld: Bool {
        targetQuantityMinorUnits > 0
            && projectedNotionalMinorUnits > 0
            && projectedAggregateExposureMinorUnits > 0
            && passedPolicyChecks.isEmpty == false
            && statusReasonPairHeld
    }

    private var statusReasonPairHeld: Bool {
        switch decision {
        case .allowed:
            reason == .dryRunAllowed
        case .rejected:
            [.targetQuantityLimitExceeded, .notionalLimitExceeded, .aggregateExposureLimitExceeded].contains(reason)
        case .blocked:
            [.killSwitchActive, .noTradeActive].contains(reason)
        }
    }
}

/// ReleaseV050RiskEngineRuntimeEvaluationRequest 绑定 typed intent 和当时的 policy snapshot。
public struct ReleaseV050RiskEngineRuntimeEvaluationRequest: Codable, Equatable, Sendable {
    public let intentInput: ReleaseV050RiskEngineRuntimeIntentInput
    public let policy: ReleaseV050RiskEngineRuntimePolicy

    public var requestHeld: Bool {
        intentInput.inputHeld && policy.boundaryHeld
    }

    public init(
        intentInput: ReleaseV050RiskEngineRuntimeIntentInput,
        policy: ReleaseV050RiskEngineRuntimePolicy
    ) {
        self.intentInput = intentInput
        self.policy = policy
    }
}

/// ReleaseV050RiskEngineRuntimeDecisionEmission 是一次 RiskEngine decision publish 的证据。
public struct ReleaseV050RiskEngineRuntimeDecisionEmission: Codable, Equatable, Sendable {
    public let request: ReleaseV050RiskEngineRuntimeEvaluationRequest
    public let policyEvaluation: ReleaseV050RiskEngineRuntimePolicyEvaluation
    public let decisionEvent: RiskDecisionEvent
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>

    public var emissionHeld: Bool {
        request.requestHeld
            && policyEvaluation.evaluationHeld
            && envelope.envelopeHeld
            && envelope.sourceModule == .riskEngine
            && envelope.payloadType == .riskDecisionEvent
            && envelope.payload == .riskDecision(decisionEvent)
            && decisionEvent.sourceIntentID == request.intentInput.intent.strategyID
            && decisionEvent.decision == policyEvaluation.decision
            && decisionEvent.reason == policyEvaluation.reason.rawValue
            && envelope.runID == request.intentInput.runID
            && envelope.streamID == request.intentInput.streamID
            && envelope.correlationID == request.intentInput.correlationID
    }
}

/// ReleaseV050RiskEngineRuntimeRunnerEvidence 汇总 GH-734 RiskEngine runtime runner 证据。
public struct ReleaseV050RiskEngineRuntimeRunnerEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let requests: [ReleaseV050RiskEngineRuntimeEvaluationRequest]
    public let emissions: [ReleaseV050RiskEngineRuntimeDecisionEmission]
    public let replayedDecisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionEvents: [RiskDecisionEvent] {
        emissions.map(\.decisionEvent)
    }

    public var decisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        emissions.map(\.envelope)
    }

    public var intentEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        requests.map(\.intentInput.intentEnvelope)
    }

    public var policyEvaluations: [ReleaseV050RiskEngineRuntimePolicyEvaluation] {
        emissions.map(\.policyEvaluation)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-734"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-729", "GH-730", "GH-731", "GH-732"]
            && previousIssueID.rawValue == "GH-733"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-735", "GH-736", "GH-739"]
            && requests.isEmpty == false
            && requests.allSatisfy(\.requestHeld)
            && emissions.allSatisfy(\.emissionHeld)
            && decisionEnvelopes == replayedDecisionEnvelopes
            && journalCompatibleEnvelopes == intentEnvelopes + decisionEnvelopes
            && journalCompatibleEnvelopes.allSatisfy(\.envelopeHeld)
            && journalCompatibleEnvelopes.map(\.sequence) == Array(1...journalCompatibleEnvelopes.count)
            && journalCompatibleEnvelopes.dropFirst().compactMap(\.causationID) == journalCompatibleEnvelopes.dropLast().map(\.eventID)
            && outcomeCoverageHeld
            && downstreamBoundaryHeld
            && validationAnchors == ReleaseV050RiskEngineRuntimeRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV050RiskEngineRuntimeRunnerContract.requiredValidationCommands
    }

    public var outcomeCoverageHeld: Bool {
        policyEvaluations.map(\.decision) == [.allowed, .rejected, .blocked, .blocked]
            && policyEvaluations.map(\.reason) == [.dryRunAllowed, .notionalLimitExceeded, .killSwitchActive, .noTradeActive]
            && Set(decisionEvents.map(\.sourceIntentID)) == Set(requests.map(\.intentInput.intent.strategyID))
    }

    public var downstreamBoundaryHeld: Bool {
        executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-734-v050-riskengine-runtime-runner-evidence"),
        issueID: Identifier = Identifier.constant("GH-734"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-729"),
            Identifier.constant("GH-730"),
            Identifier.constant("GH-731"),
            Identifier.constant("GH-732")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-733"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-735"),
            Identifier.constant("GH-736"),
            Identifier.constant("GH-739")
        ],
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        requests: [ReleaseV050RiskEngineRuntimeEvaluationRequest],
        emissions: [ReleaseV050RiskEngineRuntimeDecisionEmission],
        replayedDecisionEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        validationAnchors: [String] = ReleaseV050RiskEngineRuntimeRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV050RiskEngineRuntimeRunnerContract.requiredValidationCommands,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionBrokerConnected: Bool = false,
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
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("riskEngineRuntimeRunnerEvidenceDrift")
        }
    }
}

/// ReleaseV050RiskEngineRuntimeRunner 执行 GH-734 local runtime risk evaluation。
///
/// Runner 从 typed StrategyIntentEvent envelope 生成 RiskDecisionEvent envelope。输出只表示
/// dry-run / rehearsal decision，不授权真实订单，不绕过后续 ExecutionEngine / OMS gate。
public struct ReleaseV050RiskEngineRuntimeRunner: Sendable {
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let firstDecisionRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        runID: Identifier = Identifier.constant("gh-734-v050-riskengine-runtime-run"),
        streamID: MessageBusJournalStreamID? = nil,
        correlationID: Identifier = Identifier.constant("gh-734-v050-riskengine-correlation"),
        firstDecisionRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_834),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.invalidRecordedAtStride(recordedAtStride)
        }
        self.runID = runID
        self.streamID = try streamID ?? MessageBusJournalStreamID("release-v050-riskengine-runtime-runner")
        self.correlationID = correlationID
        self.firstDecisionRecordedAt = firstDecisionRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public func run(
        requests: [ReleaseV050RiskEngineRuntimeEvaluationRequest]
    ) async throws -> ReleaseV050RiskEngineRuntimeRunnerEvidence {
        guard requests.isEmpty == false else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.emptyRequests
        }
        for request in requests {
            try validateRequest(request)
        }

        let inputEnvelopes = requests.map(\.intentInput.intentEnvelope)
        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>(envelopes: inputEnvelopes)
        var emissions: [ReleaseV050RiskEngineRuntimeDecisionEmission] = []
        var causationID = inputEnvelopes.last?.eventID

        for (index, request) in requests.enumerated() {
            let policyEvaluation = try request.policy.evaluate(input: request.intentInput)
            let decisionEvent = try RiskDecisionEvent(
                decisionID: Identifier.constant("gh-734-v050-risk-decision-\(index + 1)"),
                sourceIntentID: request.intentInput.intent.strategyID,
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
                eventID: Identifier.constant("gh-734-v050-risk-decision-event-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
            emissions.append(
                ReleaseV050RiskEngineRuntimeDecisionEmission(
                    request: request,
                    policyEvaluation: policyEvaluation,
                    decisionEvent: decisionEvent,
                    envelope: envelope
                )
            )
        }

        let replayedDecisionEnvelopes = await bus.replay(
            runID: runID,
            streamID: streamID,
            payloadType: .riskDecisionEvent
        )
        guard replayedDecisionEnvelopes == emissions.map(\.envelope) else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.replayMismatch
        }

        return try ReleaseV050RiskEngineRuntimeRunnerEvidence(
            runID: runID,
            streamID: streamID,
            correlationID: correlationID,
            requests: requests,
            emissions: emissions,
            replayedDecisionEnvelopes: replayedDecisionEnvelopes,
            journalCompatibleEnvelopes: await bus.snapshot()
        )
    }

    public static func deterministicEvidence() async throws -> ReleaseV050RiskEngineRuntimeRunnerEvidence {
        let runner = try ReleaseV050RiskEngineRuntimeRunner()
        return try await runner.run(requests: deterministicRequests())
    }

    public static func deterministicRequests() async throws -> [ReleaseV050RiskEngineRuntimeEvaluationRequest] {
        let runner = try ReleaseV050RiskEngineRuntimeRunner()
        let intentInputs = try await deterministicIntentInputs(
            runID: runner.runID,
            streamID: runner.streamID,
            correlationID: runner.correlationID
        )
        let policies = try deterministicPolicies()
        return zip(intentInputs, policies).map {
            ReleaseV050RiskEngineRuntimeEvaluationRequest(intentInput: $0.0, policy: $0.1)
        }
    }

    public static func deterministicIntentInputs(
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier
    ) async throws -> [ReleaseV050RiskEngineRuntimeIntentInput] {
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: .constant("BTCUSDT"))
        let intents = try [
            StrategyIntentEvent(
                strategyID: .constant("gh-734-ema-allowed"),
                instrument: instrument,
                intentSide: "long",
                targetQuantity: .quantity(minorUnits: 10_000, scale: 6)
            ),
            StrategyIntentEvent(
                strategyID: .constant("gh-734-rsi-notional-reject"),
                instrument: instrument,
                intentSide: "long",
                targetQuantity: .quantity(minorUnits: 70_000, scale: 6)
            ),
            StrategyIntentEvent(
                strategyID: .constant("gh-734-ema-kill-switch"),
                instrument: instrument,
                intentSide: "long",
                targetQuantity: .quantity(minorUnits: 10_000, scale: 6)
            ),
            StrategyIntentEvent(
                strategyID: .constant("gh-734-rsi-no-trade"),
                instrument: instrument,
                intentSide: "long",
                targetQuantity: .quantity(minorUnits: 10_000, scale: 6)
            )
        ]
        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>()
        var causationID: Identifier?
        var inputs: [ReleaseV050RiskEngineRuntimeIntentInput] = []
        for (index, intent) in intents.enumerated() {
            let payload = ReleaseV050RuntimeEventPayload.strategyIntent(intent)
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: Date(timeIntervalSince1970: 1_800_000_734 + TimeInterval(index)),
                eventID: Identifier.constant("gh-734-v050-strategy-intent-event-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
            inputs.append(try ReleaseV050RiskEngineRuntimeIntentInput(intentEnvelope: envelope))
        }
        return inputs
    }

    public static func deterministicPolicies() throws -> [ReleaseV050RiskEngineRuntimePolicy] {
        try [
            policy(policyID: "gh-734-policy-allow"),
            policy(policyID: "gh-734-policy-notional-reject"),
            policy(policyID: "gh-734-policy-kill-switch", killSwitchActive: true),
            policy(policyID: "gh-734-policy-no-trade", noTradeActive: true)
        ]
    }

    private static func policy(
        policyID: String,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false
    ) throws -> ReleaseV050RiskEngineRuntimePolicy {
        try ReleaseV050RiskEngineRuntimePolicy(
            policyID: .constant(policyID),
            maxTargetQuantityMinorUnits: 100_000,
            maxProjectedNotionalMinorUnits: 400_000_000_000,
            maxAggregateExposureMinorUnits: 120_000,
            deterministicReferencePriceMinorUnits: 6_750_000,
            killSwitchActive: killSwitchActive,
            noTradeActive: noTradeActive
        )
    }

    private func validateRequest(_ request: ReleaseV050RiskEngineRuntimeEvaluationRequest) throws {
        guard request.intentInput.runID == runID else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.runIDMismatch(expected: runID, actual: request.intentInput.runID)
        }
        guard request.intentInput.streamID == streamID else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.streamIDMismatch(expected: streamID, actual: request.intentInput.streamID)
        }
        guard request.intentInput.correlationID == correlationID else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.correlationIDMismatch(
                expected: correlationID,
                actual: request.intentInput.correlationID
            )
        }
        guard request.requestHeld else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("request boundary is not held")
        }
    }
}

/// ReleaseV050RiskEngineRuntimeRunnerContract 固定 GH-734 issue-level 验收合同。
public struct ReleaseV050RiskEngineRuntimeRunnerContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public var contractHeld: Bool {
        issueID.rawValue == "GH-734"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-729", "GH-730", "GH-731", "GH-732"]
            && previousIssueID.rawValue == "GH-733"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-735", "GH-736", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == Self.requiredProjectName
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-734-release-v0.5.0-riskengine-runtime-runner"),
        issueID: Identifier = Identifier.constant("GH-734"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-729"),
            Identifier.constant("GH-730"),
            Identifier.constant("GH-731"),
            Identifier.constant("GH-732")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-733"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-735"),
            Identifier.constant("GH-736"),
            Identifier.constant("GH-739")
        ],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = Self.requiredProjectName,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-729", "GH-730", "GH-731", "GH-732"] else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("unexpectedUpstreamIssueList")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("validationAnchorDrift")
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("validationCommandDrift")
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where forbiddenFlag.1 {
            throw ReleaseV050RiskEngineRuntimeRunnerError.forbiddenProductionCapability(forbiddenFlag.0)
        }

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV050RiskEngineRuntimeRunnerError.policyBoundaryMismatch("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV050RiskEngineRuntimeRunnerContract {
        try ReleaseV050RiskEngineRuntimeRunnerContract()
    }

    public static let requiredProjectName = "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"

    public static let requiredValidationAnchors = [
        "V050-09-RISKENGINE-RUNTIME-RUNNER",
        "V050-09-STRATEGY-INTENT-TO-RISK-DECISION",
        "V050-09-NOTIONAL-EXPOSURE-POLICY-EVIDENCE",
        "V050-09-KILL-SWITCH-NO-TRADE-BLOCKS",
        "V050-09-RUN-JOURNAL-REPLAYABLE-RISK-DECISIONS",
        "TVM-RELEASE-V050-RISKENGINE-RUNTIME-RUNNER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH734RiskEngineRuntimeRunnerConsumesStrategyIntentAndEmitsReplayableDecisions",
        "bash checks/verify-v0.5.0-riskengine.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
