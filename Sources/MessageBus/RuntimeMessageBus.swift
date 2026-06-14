import Crypto
import DomainModel
import Foundation

/// RuntimeMessageBusError 描述 v0.5.0 typed runtime MessageBus 的本地合同错误。
///
/// 这些错误只覆盖 envelope identity、sequence、checksum 和 actor-local replay 合同；
/// 不表达 broker、signed endpoint、account endpoint、OMS production runtime 或真实订单动作。
public enum RuntimeMessageBusError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidSequence(Int)
    case nonContiguousSequence(expected: Int, actual: Int)
    case payloadTypeMismatch(expected: RuntimeEventPayloadType, actual: RuntimeEventPayloadType)
    case checksumMismatch(expected: String, actual: String)
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case let .invalidSequence(value):
            "Runtime event sequence must be positive: \(value)"
        case let .nonContiguousSequence(expected, actual):
            "Runtime event sequence must be contiguous: expected \(expected), actual \(actual)"
        case let .payloadTypeMismatch(expected, actual):
            "Runtime event payload type mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .checksumMismatch(expected, actual):
            "Runtime event checksum mismatch: expected \(expected), actual \(actual)"
        case let .forbiddenProductionCapability(capability):
            "Runtime MessageBus forbidden production capability: \(capability)"
        }
    }
}

/// RuntimeEventSourceModule 固定 v0.5.0 runtime event envelope 允许的 source module。
///
/// MessageBus 只记录 module identity，不反向依赖 DataEngine、Trader、RiskEngine、
/// ExecutionEngine、ExecutionClient、Portfolio 或 Dashboard implementation。
public enum RuntimeEventSourceModule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngine = "DataEngine"
    case traderStrategy = "TraderStrategy"
    case riskEngine = "RiskEngine"
    case oms = "OMS"
    case executionClient = "ExecutionClient"
    case portfolio = "Portfolio"
    case dashboard = "Dashboard"
}

public typealias ReleaseV050RuntimeSourceModule = RuntimeEventSourceModule

/// RuntimeEventPayloadType 固定 GH-730 的 typed event family 名称。
public enum RuntimeEventPayloadType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngineMarketEvent = "DataEngineMarketEvent"
    case strategyIntentEvent = "StrategyIntentEvent"
    case riskDecisionEvent = "RiskDecisionEvent"
    case omsLifecycleEvent = "OMSLifecycleEvent"
    case executionClientDryRunEvent = "ExecutionClientDryRunEvent"
    case portfolioProjectionEvent = "PortfolioProjectionEvent"
    case dashboardReadModelEvent = "DashboardReadModelEvent"

    public var sourceModule: RuntimeEventSourceModule {
        switch self {
        case .dataEngineMarketEvent:
            .dataEngine
        case .strategyIntentEvent:
            .traderStrategy
        case .riskDecisionEvent:
            .riskEngine
        case .omsLifecycleEvent:
            .oms
        case .executionClientDryRunEvent:
            .executionClient
        case .portfolioProjectionEvent:
            .portfolio
        case .dashboardReadModelEvent:
            .dashboard
        }
    }
}

public typealias ReleaseV050RuntimeEventPayloadType = RuntimeEventPayloadType

/// DataEngineMarketEvent 是 DataEngine -> MessageBus 的 market event payload family。
///
/// Payload 只携带 instrument、price、quantity 和 quality tag；它不是 exchange websocket
/// frame，也不包含 endpoint、credential、account 或 order command。
public struct DataEngineMarketEvent: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let price: ReleaseV050FixedPointValue
    public let quantity: ReleaseV050FixedPointValue
    public let qualityTag: String

    public init(
        instrument: InstrumentIdentity,
        price: ReleaseV050FixedPointValue,
        quantity: ReleaseV050FixedPointValue,
        qualityTag: String
    ) throws {
        guard price.semantic == .price else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .dataEngineMarketEvent, actual: .portfolioProjectionEvent)
        }
        guard quantity.semantic == .quantity else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .dataEngineMarketEvent, actual: .strategyIntentEvent)
        }
        self.instrument = instrument
        self.price = price
        self.quantity = quantity
        self.qualityTag = try FoundationTargetID(qualityTag, field: "runtimeMarketQualityTag").rawValue
    }
}

/// StrategyIntentEvent 是 Trader / Strategy -> MessageBus 的 strategy intent payload family。
public struct StrategyIntentEvent: Codable, Equatable, Sendable {
    public let strategyID: Identifier
    public let instrument: InstrumentIdentity
    public let intentSide: String
    public let targetQuantity: ReleaseV050FixedPointValue

    public init(
        strategyID: Identifier,
        instrument: InstrumentIdentity,
        intentSide: String,
        targetQuantity: ReleaseV050FixedPointValue
    ) throws {
        guard targetQuantity.semantic == .quantity else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .strategyIntentEvent, actual: .dataEngineMarketEvent)
        }
        self.strategyID = strategyID
        self.instrument = instrument
        self.intentSide = try FoundationTargetID(intentSide, field: "runtimeStrategyIntentSide").rawValue
        self.targetQuantity = targetQuantity
    }
}

/// RuntimeRiskDecision 固定 RiskEngine runtime runner 的 dry-run decision vocabulary。
public enum RuntimeRiskDecision: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allowed
    case rejected
    case blocked
}

/// RiskDecisionEvent 是 RiskEngine -> MessageBus 的 decision payload family。
public struct RiskDecisionEvent: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let sourceIntentID: Identifier
    public let decision: RuntimeRiskDecision
    public let reason: String

    public init(
        decisionID: Identifier,
        sourceIntentID: Identifier,
        decision: RuntimeRiskDecision,
        reason: String
    ) throws {
        self.decisionID = decisionID
        self.sourceIntentID = sourceIntentID
        self.decision = decision
        self.reason = try FoundationTargetID(reason, field: "runtimeRiskDecisionReason").rawValue
    }
}

/// RuntimeOMSState 固定 local dry-run OMS lifecycle event vocabulary。
public enum RuntimeOMSState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case created
    case riskApproved
    case accepted
    case acceptedByOMS
    case simulatedSubmitted
    case simulatedPartiallyFilled
    case simulatedFilled
    case simulatedRejected
    case simulatedCancelled
    case canceled
    case replaced
    case rejected
}

/// OMSLifecycleEvent 是 OMS local lifecycle -> MessageBus 的 state payload family。
public struct OMSLifecycleEvent: Codable, Equatable, Sendable {
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let state: RuntimeOMSState

    public init(
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        state: RuntimeOMSState
    ) {
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.state = state
    }
}

/// RuntimeDryRunCommandKind 固定 ExecutionClient dry-run command vocabulary。
public enum RuntimeDryRunCommandKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// ExecutionClientDryRunEvent 是 ExecutionClient dry-run adapter -> MessageBus 的 payload family。
public struct ExecutionClientDryRunEvent: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let sourceOMSOrderID: Identifier
    public let commandKind: RuntimeDryRunCommandKind
    public let acceptedByDryRunAdapter: Bool

    public init(
        requestID: Identifier,
        sourceOMSOrderID: Identifier,
        commandKind: RuntimeDryRunCommandKind,
        acceptedByDryRunAdapter: Bool
    ) {
        self.requestID = requestID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.commandKind = commandKind
        self.acceptedByDryRunAdapter = acceptedByDryRunAdapter
    }
}

/// PortfolioProjectionEvent 是 Portfolio projection -> MessageBus 的 read-model payload family。
public struct PortfolioProjectionEvent: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let instrument: InstrumentIdentity
    public let notionalExposure: ReleaseV050FixedPointValue

    public init(
        projectionID: Identifier,
        instrument: InstrumentIdentity,
        notionalExposure: ReleaseV050FixedPointValue
    ) throws {
        guard notionalExposure.semantic == .notional || notionalExposure.semantic == .exposure else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .portfolioProjectionEvent, actual: .dataEngineMarketEvent)
        }
        self.projectionID = projectionID
        self.instrument = instrument
        self.notionalExposure = notionalExposure
    }
}

/// DashboardReadModelEvent 是 Dashboard / CLI observer 消费的 read-model payload family。
public struct DashboardReadModelEvent: Codable, Equatable, Sendable {
    public let readModelID: Identifier
    public let sourceProjectionID: Identifier
    public let statusSummary: String

    public init(
        readModelID: Identifier,
        sourceProjectionID: Identifier,
        statusSummary: String
    ) throws {
        self.readModelID = readModelID
        self.sourceProjectionID = sourceProjectionID
        self.statusSummary = try FoundationTargetID(statusSummary, field: "runtimeDashboardStatusSummary").rawValue
    }
}

/// RuntimeEventPayload 是 GH-730 的 typed event family union。
public enum RuntimeEventPayload: Codable, Equatable, Sendable {
    case dataEngineMarket(DataEngineMarketEvent)
    case strategyIntent(StrategyIntentEvent)
    case riskDecision(RiskDecisionEvent)
    case omsLifecycle(OMSLifecycleEvent)
    case executionClientDryRun(ExecutionClientDryRunEvent)
    case portfolioProjection(PortfolioProjectionEvent)
    case dashboardReadModel(DashboardReadModelEvent)

    public var payloadType: RuntimeEventPayloadType {
        switch self {
        case .dataEngineMarket:
            .dataEngineMarketEvent
        case .strategyIntent:
            .strategyIntentEvent
        case .riskDecision:
            .riskDecisionEvent
        case .omsLifecycle:
            .omsLifecycleEvent
        case .executionClientDryRun:
            .executionClientDryRunEvent
        case .portfolioProjection:
            .portfolioProjectionEvent
        case .dashboardReadModel:
            .dashboardReadModelEvent
        }
    }

    public var sourceModule: RuntimeEventSourceModule {
        payloadType.sourceModule
    }

    public var runtimePayloadType: RuntimeEventPayloadType {
        payloadType
    }

    public var runtimeSourceModule: RuntimeEventSourceModule {
        sourceModule
    }
}

public typealias ReleaseV050RuntimeEventPayload = RuntimeEventPayload

/// RuntimeEventEnvelope 是 v0.5.0 typed runtime MessageBus 的通用事件外壳。
///
/// Envelope 显式携带 eventID、runID、sequence、streamID、correlationID、
/// causationID、sourceModule、payloadType、payload、recordedAt 和 checksum。
/// 它只用于本地 runtime foundation / dry-run / testnet-guarded evidence，不授权
/// production command、broker connection、signed endpoint 或真实订单。
public struct RuntimeEventEnvelope<Payload: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let runID: Identifier
    public let sequence: Int
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let causationID: Identifier?
    public let sourceModule: RuntimeEventSourceModule
    public let payloadType: RuntimeEventPayloadType
    public let payload: Payload
    public let recordedAt: Date
    public let checksum: String

    public init(
        eventID: Identifier,
        runID: Identifier,
        sequence: Int,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        causationID: Identifier?,
        sourceModule: RuntimeEventSourceModule,
        payloadType: RuntimeEventPayloadType,
        payload: Payload,
        recordedAt: Date,
        checksum: String? = nil
    ) throws {
        guard sequence > 0 else {
            throw RuntimeMessageBusError.invalidSequence(sequence)
        }
        guard sourceModule == payloadType.sourceModule else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: payloadType, actual: payloadType)
        }

        let resolvedChecksum = try Self.computeChecksum(
            eventID: eventID,
            runID: runID,
            sequence: sequence,
            streamID: streamID,
            correlationID: correlationID,
            causationID: causationID,
            sourceModule: sourceModule,
            payloadType: payloadType,
            payload: payload,
            recordedAt: recordedAt
        )
        if let checksum, checksum != resolvedChecksum {
            throw RuntimeMessageBusError.checksumMismatch(expected: resolvedChecksum, actual: checksum)
        }

        self.eventID = eventID
        self.runID = runID
        self.sequence = sequence
        self.streamID = streamID
        self.correlationID = correlationID
        self.causationID = causationID
        self.sourceModule = sourceModule
        self.payloadType = payloadType
        self.payload = payload
        self.recordedAt = recordedAt
        self.checksum = resolvedChecksum
    }

    public var envelopeHeld: Bool {
        guard let expectedChecksum = try? Self.computeChecksum(
            eventID: eventID,
            runID: runID,
            sequence: sequence,
            streamID: streamID,
            correlationID: correlationID,
            causationID: causationID,
            sourceModule: sourceModule,
            payloadType: payloadType,
            payload: payload,
            recordedAt: recordedAt
        ) else {
            return false
        }

        return sequence > 0
            && sourceModule == payloadType.sourceModule
            && checksum == expectedChecksum
    }

    public var correlationAndCausationHeld: Bool {
        correlationID.rawValue.isEmpty == false
            && (causationID?.rawValue.isEmpty ?? false) == false
    }

    public static func computeChecksum(
        eventID: Identifier,
        runID: Identifier,
        sequence: Int,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        causationID: Identifier?,
        sourceModule: RuntimeEventSourceModule,
        payloadType: RuntimeEventPayloadType,
        payload: Payload,
        recordedAt: Date
    ) throws -> String {
        let input = RuntimeEventChecksumInput(
            eventID: eventID.rawValue,
            runID: runID.rawValue,
            sequence: sequence,
            streamID: streamID.rawValue,
            correlationID: correlationID.rawValue,
            causationID: causationID?.rawValue,
            sourceModule: sourceModule.rawValue,
            payloadType: payloadType.rawValue,
            payload: payload,
            recordedAt: recordedAt
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try RuntimeEventChecksum.sha256Hex(encoder.encode(input))
    }

    public static func makeChecksum(
        eventID: Identifier,
        runID: Identifier,
        sequence: Int,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        causationID: Identifier?,
        sourceModule: RuntimeEventSourceModule,
        payloadType: RuntimeEventPayloadType,
        payload: Payload,
        recordedAt: Date
    ) throws -> String {
        try computeChecksum(
            eventID: eventID,
            runID: runID,
            sequence: sequence,
            streamID: streamID,
            correlationID: correlationID,
            causationID: causationID,
            sourceModule: sourceModule,
            payloadType: payloadType,
            payload: payload,
            recordedAt: recordedAt
        )
    }
}

/// RuntimeMessageBus 是 GH-730 的 actor-isolated typed runtime MessageBus。
///
/// Actor 负责 serial publish / replay / snapshot，保证 sequence 在 actor 内单调递增。
/// 它不执行网络调用、不读取 secret、不触发 ExecutionClient、不接 broker，也不发送真实订单。
public actor RuntimeMessageBus<Payload: Codable & Equatable & Sendable> {
    private var envelopes: [RuntimeEventEnvelope<Payload>]

    public init(envelopes: [RuntimeEventEnvelope<Payload>] = []) throws {
        for (index, envelope) in envelopes.enumerated() {
            let expected = index + 1
            guard envelope.sequence == expected else {
                throw RuntimeMessageBusError.nonContiguousSequence(expected: expected, actual: envelope.sequence)
            }
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public func publish(
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        causationID: Identifier?,
        sourceModule: RuntimeEventSourceModule,
        payloadType: RuntimeEventPayloadType,
        payload: Payload,
        recordedAt: Date,
        eventID: Identifier? = nil
    ) throws -> RuntimeEventEnvelope<Payload> {
        let sequence = envelopes.count + 1
        let resolvedEventID = eventID ?? Identifier.constant(
            "\(streamID.rawValue)-event-\(sequence)",
            field: "runtimeEventID"
        )
        let envelope = try RuntimeEventEnvelope(
            eventID: resolvedEventID,
            runID: runID,
            sequence: sequence,
            streamID: streamID,
            correlationID: correlationID,
            causationID: causationID,
            sourceModule: sourceModule,
            payloadType: payloadType,
            payload: payload,
            recordedAt: recordedAt
        )
        envelopes.append(envelope)
        return envelope
    }

    public func replay(
        runID: Identifier? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        payloadType: RuntimeEventPayloadType? = nil
    ) -> [RuntimeEventEnvelope<Payload>] {
        envelopes.filter { envelope in
            (runID == nil || envelope.runID == runID)
                && (streamID == nil || envelope.streamID == streamID)
                && (payloadType == nil || envelope.payloadType == payloadType)
        }
    }

    public func snapshot() -> [RuntimeEventEnvelope<Payload>] {
        envelopes
    }
}

/// ReleaseV050RuntimeMessageBusContract 固定 GH-730 的 typed runtime bus contract。
public struct ReleaseV050RuntimeMessageBusContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let validationAnchors: [String]
    public let requiredPayloadTypes: [RuntimeEventPayloadType]
    public let actorIsolationExpectation: String
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

    public var payloadTypes: [RuntimeEventPayloadType] {
        requiredPayloadTypes
    }

    public var sourceModules: [RuntimeEventSourceModule] {
        requiredPayloadTypes.map(\.sourceModule)
    }

    public var actorIsolationExpected: Bool {
        actorIsolationExpectation == Self.requiredActorIsolationExpectation
    }

    public var productionEndpointConnected: Bool {
        productionEndpointAutoConnectEnabled
    }

    public var productionSecretRead: Bool {
        productionSecretAutoReadEnabled
    }

    public var productionOrderSubmitted: Bool {
        productionOrderSubmissionEnabled
    }

    public var contractHeld: Bool {
        issueID.rawValue == "GH-730"
            && upstreamIssueID.rawValue == "GH-726"
            && previousIssueID.rawValue == "GH-729"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-732", "GH-734", "GH-739"]
            && validationAnchors == Self.requiredValidationAnchors
            && requiredPayloadTypes == RuntimeEventPayloadType.allCases
            && actorIsolationExpectation == Self.requiredActorIsolationExpectation
            && productionDefaultsClosed
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-730"),
        upstreamIssueID: Identifier = Identifier.constant("GH-726"),
        previousIssueID: Identifier = Identifier.constant("GH-729"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-731"),
            Identifier.constant("GH-732"),
            Identifier.constant("GH-734"),
            Identifier.constant("GH-739")
        ],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredPayloadTypes: [RuntimeEventPayloadType] = RuntimeEventPayloadType.allCases,
        actorIsolationExpectation: String = Self.requiredActorIsolationExpectation,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard downstreamIssueIDs.map(\.rawValue) == ["GH-731", "GH-732", "GH-734", "GH-739"] else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("unexpectedDownstreamIssueList")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("runtimeMessageBusValidationAnchorDrift")
        }
        guard requiredPayloadTypes == RuntimeEventPayloadType.allCases else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("runtimeMessageBusPayloadTypeDrift")
        }
        guard actorIsolationExpectation == Self.requiredActorIsolationExpectation else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("runtimeMessageBusActorIsolationDrift")
        }
        guard productionTradingEnabledByDefault == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionTradingEnabledByDefault")
        }
        guard productionSecretAutoReadEnabled == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionSecretAutoReadEnabled")
        }
        guard productionEndpointAutoConnectEnabled == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionEndpointAutoConnectEnabled")
        }
        guard productionBrokerConnectionEnabled == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionBrokerConnectionEnabled")
        }
        guard productionOrderSubmissionEnabled == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionOrderSubmissionEnabled")
        }
        guard productionCutoverAuthorized == false else {
            throw RuntimeMessageBusError.forbiddenProductionCapability("productionCutoverAuthorized")
        }

        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.validationAnchors = validationAnchors
        self.requiredPayloadTypes = requiredPayloadTypes
        self.actorIsolationExpectation = actorIsolationExpectation
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws -> ReleaseV050RuntimeMessageBusContract {
        try ReleaseV050RuntimeMessageBusContract()
    }

    public static func deterministicEnvelopes() async throws -> [RuntimeEventEnvelope<RuntimeEventPayload>] {
        let streamID = try MessageBusJournalStreamID("release-v050-runtime-messagebus")
        let runID = Identifier.constant("gh-730-v050-runtime-run")
        let correlationID = Identifier.constant("gh-730-v050-correlation")
        let bus = try RuntimeMessageBus<RuntimeEventPayload>()
        var causationID: Identifier?

        for (index, payload) in try deterministicPayloads().enumerated() {
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: Date(timeIntervalSince1970: 1_800_000_000 + TimeInterval(index)),
                eventID: Identifier.constant("gh-730-v050-event-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
        }

        return await bus.snapshot()
    }

    public static func deterministicPayloads() throws -> [RuntimeEventPayload] {
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: .constant("BTCUSDT"))
        return [
            try .dataEngineMarket(
                DataEngineMarketEvent(
                    instrument: instrument,
                    price: .price(minorUnits: 6_750_000, scale: 2),
                    quantity: .quantity(minorUnits: 15_000, scale: 6),
                    qualityTag: "validated"
                )
            ),
            try .strategyIntent(
                StrategyIntentEvent(
                    strategyID: .constant("gh-730-ema-strategy"),
                    instrument: instrument,
                    intentSide: "long",
                    targetQuantity: .quantity(minorUnits: 15_000, scale: 6)
                )
            ),
            try .riskDecision(
                RiskDecisionEvent(
                    decisionID: .constant("gh-730-risk-decision"),
                    sourceIntentID: .constant("gh-730-ema-strategy"),
                    decision: .allowed,
                    reason: "dry-run-allowed"
                )
            ),
            .omsLifecycle(
                OMSLifecycleEvent(
                    orderID: .constant("gh-730-oms-order"),
                    sourceRiskDecisionID: .constant("gh-730-risk-decision"),
                    state: .accepted
                )
            ),
            .executionClientDryRun(
                ExecutionClientDryRunEvent(
                    requestID: .constant("gh-730-dry-run-submit"),
                    sourceOMSOrderID: .constant("gh-730-oms-order"),
                    commandKind: .submit,
                    acceptedByDryRunAdapter: true
                )
            ),
            try .portfolioProjection(
                PortfolioProjectionEvent(
                    projectionID: .constant("gh-730-portfolio-projection"),
                    instrument: instrument,
                    notionalExposure: .notional(minorUnits: 1_012_500_000, scale: 8)
                )
            ),
            try .dashboardReadModel(
                DashboardReadModelEvent(
                    readModelID: .constant("gh-730-dashboard-read-model"),
                    sourceProjectionID: .constant("gh-730-portfolio-projection"),
                    statusSummary: "blocked-production-ready-dry-run"
                )
            )
        ]
    }

    public static let requiredActorIsolationExpectation = "RuntimeMessageBus actor serializes publish/replay/snapshot access"

    public static let requiredValidationAnchors = [
        "V050-05-TYPED-RUNTIME-MESSAGEBUS-ACTOR",
        "V050-05-RUNTIME-EVENT-ENVELOPE",
        "V050-05-TYPED-EVENT-FAMILIES",
        "V050-05-RUN-CORRELATION-CAUSATION-CHECKSUM",
        "TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS"
    ]
}

private struct RuntimeEventChecksumInput<Payload: Encodable>: Encodable {
    let eventID: String
    let runID: String
    let sequence: Int
    let streamID: String
    let correlationID: String
    let causationID: String?
    let sourceModule: String
    let payloadType: String
    let payload: Payload
    let recordedAt: Date
}

private enum RuntimeEventChecksum {
    static func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    static func fnv1aHex(_ data: Data) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return String(format: "%016llx", hash)
    }
}
