import DomainModel
import Foundation
import MessageBus
import TraderStrategies

/// ReleaseV060StrategyRuntimeRunnerError 描述 GH-760 strategy runtime runner 的本地合同错误。
///
/// 错误只覆盖 DataEngine market event 输入、EMA / RSI strategy intent 输出和同一 run 的
/// RuntimeMessageBus / local journal compatible sequence；不表达 ExecutionClient、broker、
/// OMS、endpoint、secret 或真实订单能力。
public enum ReleaseV060StrategyRuntimeRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyMarketEvents
    case missingStrategyInput(String)
    case invalidRecordedAtStride(TimeInterval)
    case nonDataEngineMarketPayload(RuntimeEventPayloadType)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case streamIDMismatch(expected: MessageBusJournalStreamID, actual: MessageBusJournalStreamID)
    case correlationIDMismatch(expected: Identifier, actual: Identifier)
    case replayMismatch
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case .emptyMarketEvents:
            "Release v0.6.0 strategy runtime runner requires DataEngine market events"
        case let .missingStrategyInput(strategy):
            "Release v0.6.0 strategy runtime runner missing \(strategy) market input"
        case let .invalidRecordedAtStride(value):
            "Release v0.6.0 strategy runtime runner recordedAt stride must be positive: \(value)"
        case let .nonDataEngineMarketPayload(payloadType):
            "Release v0.6.0 strategy runtime runner expected DataEngineMarketEvent, actual \(payloadType.rawValue)"
        case let .runIDMismatch(expected, actual):
            "Release v0.6.0 strategy runtime runner runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .streamIDMismatch(expected, actual):
            "Release v0.6.0 strategy runtime runner streamID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .correlationIDMismatch(expected, actual):
            "Release v0.6.0 strategy runtime runner correlationID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case .replayMismatch:
            "Release v0.6.0 strategy runtime runner replayed strategy intents do not match emissions"
        case let .forbiddenProductionCapability(capability):
            "Release v0.6.0 strategy runtime runner rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV060StrategyRuntimeKind 固定 v0.6.0 active strategy 集合。
///
/// 当前 runner 只允许 EMA 和 RSI；新增 active concrete strategy 必须另走 release queue。
public enum ReleaseV060StrategyRuntimeKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema = "EMA"
    case rsi = "RSI"
}

/// ReleaseV060StrategyRuntimeMarketInput 是 GH-760 从 DataEngine journal replay 出来的输入。
///
/// 输入只保存 typed DataEngineMarketEvent envelope 和 payload，不 import DataEngine target，
/// 也不获得 endpoint、secret、broker payload 或 order command 能力。
public struct ReleaseV060StrategyRuntimeMarketInput: Codable, Equatable, Sendable {
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let marketEvent: DataEngineMarketEvent

    public var runID: Identifier { envelope.runID }
    public var streamID: MessageBusJournalStreamID { envelope.streamID }
    public var correlationID: Identifier { envelope.correlationID }

    public var inputHeld: Bool {
        envelope.envelopeHeld
            && envelope.sourceModule == .dataEngine
            && envelope.payloadType == .dataEngineMarketEvent
            && envelope.payload == .dataEngineMarket(marketEvent)
            && marketEvent.instrument.venue.rawValue == "binance"
            && marketEvent.price.semantic == .price
            && marketEvent.quantity.semantic == .quantity
    }

    public init(envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>) throws {
        guard envelope.payloadType == .dataEngineMarketEvent else {
            throw ReleaseV060StrategyRuntimeRunnerError.nonDataEngineMarketPayload(envelope.payloadType)
        }
        guard case let .dataEngineMarket(marketEvent) = envelope.payload else {
            throw ReleaseV060StrategyRuntimeRunnerError.nonDataEngineMarketPayload(envelope.payloadType)
        }
        guard envelope.sourceModule == .dataEngine else {
            throw RuntimeMessageBusError.payloadTypeMismatch(
                expected: .dataEngineMarketEvent,
                actual: envelope.payloadType
            )
        }
        self.envelope = envelope
        self.marketEvent = marketEvent
    }
}

/// ReleaseV060StrategyRuntimeEmission 记录单个 EMA / RSI strategy intent 输出。
///
/// Emission 保留 strategy intent message、typed StrategyIntentEvent 和 runtime envelope。
/// `sourceMarketEventID` 是策略输入因果锚点；journal envelope 的 causationID 仍按 append-only
/// chain 串联，确保后续 local run journal 可以直接 replay。
public struct ReleaseV060StrategyRuntimeEmission: Codable, Equatable, Sendable {
    public let strategy: ReleaseV060StrategyRuntimeKind
    public let sourceMarketInput: ReleaseV060StrategyRuntimeMarketInput
    public let intentMessage: StrategyIntentMessage
    public let intentEvent: StrategyIntentEvent
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let sourceMarketEventID: Identifier

    public var emissionHeld: Bool {
        sourceMarketInput.inputHeld
            && sourceMarketEventID == sourceMarketInput.envelope.eventID
            && intentMessage.strategyID == intentEvent.strategyID
            && intentMessage.instrument == intentEvent.instrument
            && intentMessage.targetExposure.rawValue == intentEvent.intentSide
            && intentEvent.targetQuantity.semantic == .quantity
            && envelope.envelopeHeld
            && envelope.runID == sourceMarketInput.runID
            && envelope.streamID == sourceMarketInput.streamID
            && envelope.correlationID == sourceMarketInput.correlationID
            && envelope.sourceModule == .traderStrategy
            && envelope.payloadType == .strategyIntentEvent
            && envelope.payload == .strategyIntent(intentEvent)
    }

    public init(
        strategy: ReleaseV060StrategyRuntimeKind,
        sourceMarketInput: ReleaseV060StrategyRuntimeMarketInput,
        intentMessage: StrategyIntentMessage,
        intentEvent: StrategyIntentEvent,
        envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    ) {
        self.strategy = strategy
        self.sourceMarketInput = sourceMarketInput
        self.intentMessage = intentMessage
        self.intentEvent = intentEvent
        self.envelope = envelope
        self.sourceMarketEventID = sourceMarketInput.envelope.eventID
    }
}

/// ReleaseV060StrategyRuntimeRunnerResult 汇总 GH-760 本地 strategy runtime runner 证据。
public struct ReleaseV060StrategyRuntimeRunnerResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let marketInputs: [ReleaseV060StrategyRuntimeMarketInput]
    public let emissions: [ReleaseV060StrategyRuntimeEmission]
    public let replayedStrategyIntentEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let activeStrategyKinds: [ReleaseV060StrategyRuntimeKind]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let directExecutionClientAccessEnabled: Bool
    public let directBrokerAccessEnabled: Bool
    public let omsBypassEnabled: Bool
    public let commandGatewayBypassAllowed: Bool
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let unsupportedStrategyEnabled: Bool

    public var intentEvents: [StrategyIntentEvent] {
        emissions.map(\.intentEvent)
    }

    public var strategyIntentEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        emissions.map(\.envelope)
    }

    public var inputEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        marketInputs.map(\.envelope)
    }

    public var resultHeld: Bool {
        issueID.rawValue == "GH-760"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-759"]
            && previousIssueID.rawValue == "GH-759"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-761", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && activeStrategyKinds == ReleaseV060StrategyRuntimeRunnerContract.requiredActiveStrategies
            && marketConsumptionHeld
            && strategyCoverageHeld
            && journalCompatibilityHeld
            && forbiddenRuntimeHeld
            && validationAnchors == ReleaseV060StrategyRuntimeRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060StrategyRuntimeRunnerContract.requiredValidationCommands
    }

    public var marketConsumptionHeld: Bool {
        marketInputs.isEmpty == false
            && marketInputs.allSatisfy(\.inputHeld)
            && Set(marketInputs.map(\.runID)) == [runID]
            && Set(marketInputs.map(\.streamID)) == [streamID]
            && Set(marketInputs.map(\.correlationID)) == [correlationID]
    }

    public var strategyCoverageHeld: Bool {
        emissions.count == 2
            && emissions.allSatisfy(\.emissionHeld)
            && emissions.map(\.strategy) == activeStrategyKinds
            && Set(intentEvents.map(\.instrument.productType)) == [.spot, .usdsPerpetual]
            && intentEvents.allSatisfy { $0.instrument.venue.rawValue == "binance" }
            && Set(intentEvents.map(\.strategyID.rawValue)) == [
                "gh-760-v060-ema-instance",
                "gh-760-v060-rsi-instance"
            ]
    }

    public var journalCompatibilityHeld: Bool {
        journalCompatibleEnvelopes == inputEnvelopes + strategyIntentEnvelopes
            && replayedStrategyIntentEnvelopes == strategyIntentEnvelopes
            && journalCompatibleEnvelopes.map(\.sequence) == Array(1...journalCompatibleEnvelopes.count)
            && journalCompatibleEnvelopes.dropFirst().compactMap(\.causationID)
                == journalCompatibleEnvelopes.dropLast().map(\.eventID)
            && journalCompatibleEnvelopes.allSatisfy(\.envelopeHeld)
            && strategyIntentEnvelopes.first?.causationID == inputEnvelopes.last?.eventID
    }

    public var forbiddenRuntimeHeld: Bool {
        directExecutionClientAccessEnabled == false
            && directBrokerAccessEnabled == false
            && omsBypassEnabled == false
            && commandGatewayBypassAllowed == false
            && networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && unsupportedStrategyEnabled == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-760"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-759")],
        previousIssueID: Identifier = Identifier.constant("GH-759"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-761"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        marketInputs: [ReleaseV060StrategyRuntimeMarketInput],
        emissions: [ReleaseV060StrategyRuntimeEmission],
        replayedStrategyIntentEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        journalCompatibleEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        activeStrategyKinds: [ReleaseV060StrategyRuntimeKind] = ReleaseV060StrategyRuntimeRunnerContract.requiredActiveStrategies,
        validationAnchors: [String] = ReleaseV060StrategyRuntimeRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060StrategyRuntimeRunnerContract.requiredValidationCommands,
        directExecutionClientAccessEnabled: Bool = false,
        directBrokerAccessEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        unsupportedStrategyEnabled: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.streamID = streamID
        self.correlationID = correlationID
        self.marketInputs = marketInputs
        self.emissions = emissions
        self.replayedStrategyIntentEnvelopes = replayedStrategyIntentEnvelopes
        self.journalCompatibleEnvelopes = journalCompatibleEnvelopes
        self.activeStrategyKinds = activeStrategyKinds
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.directExecutionClientAccessEnabled = directExecutionClientAccessEnabled
        self.directBrokerAccessEnabled = directBrokerAccessEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.unsupportedStrategyEnabled = unsupportedStrategyEnabled

        guard resultHeld else {
            throw ReleaseV060StrategyRuntimeRunnerError.forbiddenProductionCapability("resultContractDrift")
        }
    }
}

/// ReleaseV060StrategyRuntimeRunner 执行 GH-760 本地 EMA / RSI strategy runtime runner。
///
/// Runner 只消费 typed DataEngineMarketEvent envelope，并把 EMA / RSI 输出转为
/// StrategyIntentEvent envelope。输出仍是 intent-only，必须继续交给 RiskEngine / ExecutionEngine /
/// OMS 后续 gate；本 runner 不拥有任何执行、broker 或生产连接能力。
public struct ReleaseV060StrategyRuntimeRunner: Sendable {
    public let firstIntentRecordedAt: Date
    public let recordedAtStride: TimeInterval
    public let eventIDPrefix: String

    public init(
        firstIntentRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_760),
        recordedAtStride: TimeInterval = 1,
        eventIDPrefix: String = "gh-760-v060-strategy-intent-event"
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV060StrategyRuntimeRunnerError.invalidRecordedAtStride(recordedAtStride)
        }
        self.firstIntentRecordedAt = firstIntentRecordedAt
        self.recordedAtStride = recordedAtStride
        self.eventIDPrefix = try FoundationTargetID(eventIDPrefix, field: "releaseV060StrategyEventIDPrefix").rawValue
    }

    public func run(
        dataEngineEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) async throws -> ReleaseV060StrategyRuntimeRunnerResult {
        let marketInputs = try dataEngineEnvelopes.map(ReleaseV060StrategyRuntimeMarketInput.init)
        guard marketInputs.isEmpty == false else {
            throw ReleaseV060StrategyRuntimeRunnerError.emptyMarketEvents
        }
        try validateMarketInputs(marketInputs)

        let runID = marketInputs[0].runID
        let streamID = marketInputs[0].streamID
        let correlationID = marketInputs[0].correlationID
        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>(envelopes: dataEngineEnvelopes)
        var causationID = dataEngineEnvelopes.last?.eventID
        var emissions: [ReleaseV060StrategyRuntimeEmission] = []

        for (index, plan) in try strategyPlans(from: marketInputs).enumerated() {
            let intentMessage = try strategyIntentMessage(for: plan, sourceSequence: index + 1)
            let intentEvent = try StrategyIntentEvent(
                strategyID: intentMessage.strategyID,
                instrument: intentMessage.instrument,
                intentSide: intentMessage.targetExposure.rawValue,
                targetQuantity: plan.input.marketEvent.quantity
            )
            let payload = ReleaseV050RuntimeEventPayload.strategyIntent(intentEvent)
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: firstIntentRecordedAt.addingTimeInterval(TimeInterval(index) * recordedAtStride),
                eventID: Identifier.constant("\(eventIDPrefix)-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
            emissions.append(
                ReleaseV060StrategyRuntimeEmission(
                    strategy: plan.strategy,
                    sourceMarketInput: plan.input,
                    intentMessage: intentMessage,
                    intentEvent: intentEvent,
                    envelope: envelope
                )
            )
        }

        let replayed = await bus.replay(runID: runID, streamID: streamID, payloadType: .strategyIntentEvent)
        guard replayed == emissions.map(\.envelope) else {
            throw ReleaseV060StrategyRuntimeRunnerError.replayMismatch
        }

        return try ReleaseV060StrategyRuntimeRunnerResult(
            runID: runID,
            streamID: streamID,
            correlationID: correlationID,
            marketInputs: marketInputs,
            emissions: emissions,
            replayedStrategyIntentEnvelopes: replayed,
            journalCompatibleEnvelopes: await bus.snapshot()
        )
    }

    public static func deterministicEvidence(
        dataEngineEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    ) async throws -> ReleaseV060StrategyRuntimeRunnerResult {
        let runner = try ReleaseV060StrategyRuntimeRunner()
        return try await runner.run(dataEngineEnvelopes: dataEngineEnvelopes)
    }

    private struct StrategyPlan {
        let strategy: ReleaseV060StrategyRuntimeKind
        let input: ReleaseV060StrategyRuntimeMarketInput
    }

    private func strategyPlans(
        from inputs: [ReleaseV060StrategyRuntimeMarketInput]
    ) throws -> [StrategyPlan] {
        guard let emaInput = inputs.first(where: { $0.marketEvent.instrument.productType == .spot }) else {
            throw ReleaseV060StrategyRuntimeRunnerError.missingStrategyInput("EMA")
        }
        guard let rsiInput = inputs.first(where: { $0.marketEvent.instrument.productType == .usdsPerpetual }) else {
            throw ReleaseV060StrategyRuntimeRunnerError.missingStrategyInput("RSI")
        }
        return [
            StrategyPlan(strategy: .ema, input: emaInput),
            StrategyPlan(strategy: .rsi, input: rsiInput)
        ]
    }

    private func strategyIntentMessage(
        for plan: StrategyPlan,
        sourceSequence: Int
    ) throws -> StrategyIntentMessage {
        let quantity = try Quantity(
            fixedPointDouble(plan.input.marketEvent.quantity),
            field: "releaseV060StrategyRuntime.quantity"
        )
        switch plan.strategy {
        case .ema:
            let runtime = try EMAProposalRuntime(
                runtimeID: Identifier.constant("gh-760-v060-ema-runtime"),
                configuration: EMACrossStrategyConfiguration(
                    strategyID: Identifier.constant("gh-760-v060-ema-instance"),
                    symbol: plan.input.marketEvent.instrument.symbol,
                    timeframe: .oneMinute,
                    shortPeriod: 2,
                    longPeriod: 3
                )
            )
            return try runtime.generateTargetExposureIntent(
                from: marketBars(for: plan.input.marketEvent, closes: emaCloses(from: plan.input.marketEvent.price)),
                instrument: plan.input.marketEvent.instrument,
                sourceSequence: sourceSequence,
                quantity: quantity,
                emittedAt: firstIntentRecordedAt
            )
        case .rsi:
            let emitter = try RSITargetExposureIntentEmitter(
                emitterID: Identifier.constant("gh-760-v060-rsi-runtime"),
                configuration: RSIStrategyConfiguration(
                    strategyID: Identifier.constant("gh-760-v060-rsi-instance"),
                    symbol: plan.input.marketEvent.instrument.symbol,
                    timeframe: .oneMinute,
                    period: 3,
                    perpetualShortEnabled: true
                )
            )
            return try emitter.generateTargetExposureIntent(
                from: marketBars(for: plan.input.marketEvent, closes: rsiCloses(from: plan.input.marketEvent.price)),
                instrument: plan.input.marketEvent.instrument,
                sourceSequence: sourceSequence,
                quantity: quantity,
                emittedAt: firstIntentRecordedAt.addingTimeInterval(recordedAtStride)
            )
        }
    }

    private func validateMarketInputs(_ inputs: [ReleaseV060StrategyRuntimeMarketInput]) throws {
        let runID = inputs[0].runID
        let streamID = inputs[0].streamID
        let correlationID = inputs[0].correlationID
        for input in inputs {
            guard input.inputHeld else {
                throw ReleaseV060StrategyRuntimeRunnerError.nonDataEngineMarketPayload(input.envelope.payloadType)
            }
            guard input.runID == runID else {
                throw ReleaseV060StrategyRuntimeRunnerError.runIDMismatch(expected: runID, actual: input.runID)
            }
            guard input.streamID == streamID else {
                throw ReleaseV060StrategyRuntimeRunnerError.streamIDMismatch(expected: streamID, actual: input.streamID)
            }
            guard input.correlationID == correlationID else {
                throw ReleaseV060StrategyRuntimeRunnerError.correlationIDMismatch(
                    expected: correlationID,
                    actual: input.correlationID
                )
            }
        }
    }

    private func marketBars(
        for event: DataEngineMarketEvent,
        closes: [Double]
    ) throws -> [MarketBar] {
        let volume = max(fixedPointDouble(event.quantity), 0.000001)
        return try closes.enumerated().map { index, close in
            let start = Date(timeIntervalSince1970: 1_800_000_700 + Double(index * 60))
            return try MarketBar(
                symbol: event.instrument.symbol,
                timeframe: .oneMinute,
                interval: DateRange(start: start, end: start.addingTimeInterval(60)),
                open: close * 0.999,
                high: close * 1.002,
                low: close * 0.998,
                close: close,
                volume: volume
            )
        }
    }

    private func emaCloses(from price: ReleaseV050FixedPointValue) -> [Double] {
        let base = fixedPointDouble(price)
        return [0.98, 0.99, 1.0, 1.012, 1.025].map { base * $0 }
    }

    private func rsiCloses(from price: ReleaseV050FixedPointValue) -> [Double] {
        let base = fixedPointDouble(price)
        return [1.0, 1.01, 1.02, 1.03].map { base * $0 }
    }

    private func fixedPointDouble(_ value: ReleaseV050FixedPointValue) -> Double {
        Double(value.minorUnits) / pow(10, Double(value.scale))
    }
}

/// ReleaseV060StrategyRuntimeRunnerContract 固定 GH-760 issue-level 验收合同。
public struct ReleaseV060StrategyRuntimeRunnerContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let activeStrategyKinds: [ReleaseV060StrategyRuntimeKind]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-760"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-759"]
            && previousIssueID.rawValue == "GH-759"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-761", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && activeStrategyKinds == Self.requiredActiveStrategies
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
        issueID: Identifier = Identifier.constant("GH-760"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-759")],
        previousIssueID: Identifier = Identifier.constant("GH-759"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-761"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        activeStrategyKinds: [ReleaseV060StrategyRuntimeKind] = Self.requiredActiveStrategies,
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
        self.activeStrategyKinds = activeStrategyKinds
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV060StrategyRuntimeRunnerError.forbiddenProductionCapability("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060StrategyRuntimeRunnerContract {
        try ReleaseV060StrategyRuntimeRunnerContract()
    }

    public static let requiredActiveStrategies: [ReleaseV060StrategyRuntimeKind] = [.ema, .rsi]

    public static let requiredValidationAnchors = [
        "V060-006-STRATEGY-RUNTIME-RUNNER",
        "V060-006-EMA-RSI-INTENT-EVENTS",
        "V060-006-DATAENGINE-CAUSAL-LINK",
        "V060-006-SAME-RUN-JOURNAL-SEQUENCE",
        "V060-006-NO-STRATEGY-EXECUTION-PATH",
        "TVM-RELEASE-V060-STRATEGY-RUNTIME-RUNNER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH760StrategyRuntimeRunnerConsumesDataEngineJournalAndEmitsEMARSIIntentEvents",
        "bash checks/verify-v0.6.0-strategy-runtime-runner.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
