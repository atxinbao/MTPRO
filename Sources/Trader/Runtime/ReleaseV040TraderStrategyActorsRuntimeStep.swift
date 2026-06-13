import DomainModel
import Foundation
import MessageBus
import TraderStrategies

/// ReleaseV040TraderStrategyMarketInput 是 GH-698 Trader actor 消费的中性 market event 输入。
///
/// 输入只依赖 MessageBus journal envelope 与本地 `MarketBar`，不 import DataEngine target。
/// `upstreamEvidenceID` 由上游 DataEngine -> MessageBus step 提供，用来保留因果链；
/// Trader 不能反向依赖 DataEngine implementation，也不能读取 endpoint、secret 或 broker payload。
public struct ReleaseV040TraderStrategyMarketInput: Codable, Equatable, Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let upstreamEvidenceID: Identifier
    public let strategy: ReleaseV040RehearsalStrategyKind
    public let upstreamMarketEnvelope: MessageBusJournalEnvelope
    public let instrument: InstrumentIdentity
    public let marketBar: MarketBar

    public var runID: Identifier { runContext.runID }

    public var boundaryHeld: Bool {
        runContext.mode == .dryRun
            && runContext.boundaryHeld
            && ReleaseV040RehearsalRunContext.requiredStrategies.contains(strategy)
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType)
            && instrument.venue.rawValue == "binance"
            && upstreamMarketEnvelope.instrumentID == instrument
            && upstreamMarketEnvelope.payloadType.hasPrefix("dataengine.release-v0.4.0.binance")
            && marketBar.symbol == instrument.symbol
    }

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        upstreamEvidenceID: Identifier,
        strategy: ReleaseV040RehearsalStrategyKind,
        upstreamMarketEnvelope: MessageBusJournalEnvelope,
        instrument: InstrumentIdentity,
        marketBar: MarketBar
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard ReleaseV040RehearsalRunContext.requiredStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedStrategy")
        }
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedProductType")
        }
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonBinanceVenue")
        }
        guard upstreamMarketEnvelope.instrumentID == instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamMarketEnvelope.instrumentID",
                expected: instrument.rawValue,
                actual: upstreamMarketEnvelope.instrumentID?.rawValue ?? "nil"
            )
        }
        guard upstreamMarketEnvelope.payloadType.hasPrefix("dataengine.release-v0.4.0.binance") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamMarketEnvelope.payloadType",
                expected: "dataengine.release-v0.4.0.binance.*",
                actual: upstreamMarketEnvelope.payloadType
            )
        }
        guard marketBar.symbol == instrument.symbol else {
            throw CoreError.marketDataMismatch(
                field: "marketBar.symbol",
                expected: instrument.symbol.rawValue,
                actual: marketBar.symbol.rawValue
            )
        }

        self.runContext = runContext
        self.upstreamEvidenceID = upstreamEvidenceID
        self.strategy = strategy
        self.upstreamMarketEnvelope = upstreamMarketEnvelope
        self.instrument = instrument
        self.marketBar = marketBar
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            upstreamEvidenceID: try container.decode(Identifier.self, forKey: .upstreamEvidenceID),
            strategy: try container.decode(ReleaseV040RehearsalStrategyKind.self, forKey: .strategy),
            upstreamMarketEnvelope: try container.decode(MessageBusJournalEnvelope.self, forKey: .upstreamMarketEnvelope),
            instrument: try container.decode(InstrumentIdentity.self, forKey: .instrument),
            marketBar: try container.decode(MarketBar.self, forKey: .marketBar)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case runContext
        case upstreamEvidenceID
        case strategy
        case upstreamMarketEnvelope
        case instrument
        case marketBar
    }
}

/// ReleaseV040TraderStrategyActorEmission 是单个 EMA / RSI actor 输出的 intent evidence。
///
/// emission 同时记录 Trader unified envelope 与 MessageBus intent journal envelope。策略输出仍是
/// `StrategyIntentMessage`，不是 broker command、OMS order、ExecutionClient request 或 live command。
public struct ReleaseV040TraderStrategyActorEmission: Codable, Equatable, Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let strategy: ReleaseV040RehearsalStrategyKind
    public let consumedInputs: [ReleaseV040TraderStrategyMarketInput]
    public let intentMessage: StrategyIntentMessage
    public let payloadType: String
    public let traderEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let messageBusEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let intentJournalEnvelope: MessageBusJournalEnvelope

    public var runID: Identifier { runContext.runID }

    public var boundaryHeld: Bool {
        consumedInputs.isEmpty == false
            && consumedInputs.allSatisfy(\.boundaryHeld)
            && consumedInputs.allSatisfy { $0.runID == runID }
            && intentMessage.instrument == consumedInputs.last?.instrument
            && payloadType.hasPrefix("trader.release-v0.4.0.binance")
            && payloadType.contains(strategy.rawValue.lowercased())
            && traderEnvelope.runID == runID
            && traderEnvelope.module == .trader
            && traderEnvelope.sourceIssueID.rawValue == "GH-698"
            && traderEnvelope.upstreamEvidenceID == consumedInputs.last?.upstreamEvidenceID
            && messageBusEnvelope.runID == runID
            && messageBusEnvelope.module == .messageBus
            && messageBusEnvelope.sourceIssueID.rawValue == "GH-698"
            && messageBusEnvelope.upstreamEvidenceID == traderEnvelope.evidenceID
            && intentJournalEnvelope.instrumentID == intentMessage.instrument
            && intentJournalEnvelope.payloadType == payloadType
    }

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        strategy: ReleaseV040RehearsalStrategyKind,
        consumedInputs: [ReleaseV040TraderStrategyMarketInput],
        intentMessage: StrategyIntentMessage,
        payloadType: String,
        traderEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        messageBusEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        intentJournalEnvelope: MessageBusJournalEnvelope
    ) throws {
        guard consumedInputs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "consumedInputs",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard consumedInputs.allSatisfy({ $0.strategy == strategy }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "input.strategy",
                expected: strategy.rawValue,
                actual: "mixed"
            )
        }
        guard consumedInputs.allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "input.runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard intentMessage.instrument == consumedInputs.last?.instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "intentMessage.instrument",
                expected: consumedInputs.last?.instrument.rawValue ?? "nil",
                actual: intentMessage.instrument.rawValue
            )
        }
        guard payloadType.hasPrefix("trader.release-v0.4.0.binance"),
              payloadType.contains(strategy.rawValue.lowercased()) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "payloadType",
                expected: "trader.release-v0.4.0.binance.*.\(strategy.rawValue.lowercased()).*",
                actual: payloadType
            )
        }
        guard traderEnvelope.module == .trader else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "traderEnvelope.module",
                expected: ReleaseV040UnifiedEvidenceModule.trader.rawValue,
                actual: traderEnvelope.module.rawValue
            )
        }
        guard messageBusEnvelope.module == .messageBus else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "messageBusEnvelope.module",
                expected: ReleaseV040UnifiedEvidenceModule.messageBus.rawValue,
                actual: messageBusEnvelope.module.rawValue
            )
        }
        guard traderEnvelope.sourceIssueID.rawValue == "GH-698",
              messageBusEnvelope.sourceIssueID.rawValue == "GH-698" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIssueID",
                expected: "GH-698",
                actual: "\(traderEnvelope.sourceIssueID.rawValue),\(messageBusEnvelope.sourceIssueID.rawValue)"
            )
        }
        guard traderEnvelope.upstreamEvidenceID == consumedInputs.last?.upstreamEvidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "traderEnvelope.upstreamEvidenceID",
                expected: consumedInputs.last?.upstreamEvidenceID.rawValue ?? "nil",
                actual: traderEnvelope.upstreamEvidenceID?.rawValue ?? "nil"
            )
        }
        guard messageBusEnvelope.upstreamEvidenceID == traderEnvelope.evidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "messageBusEnvelope.upstreamEvidenceID",
                expected: traderEnvelope.evidenceID.rawValue,
                actual: messageBusEnvelope.upstreamEvidenceID?.rawValue ?? "nil"
            )
        }
        guard intentJournalEnvelope.instrumentID == intentMessage.instrument,
              intentJournalEnvelope.payloadType == payloadType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "intentJournalEnvelope",
                expected: payloadType,
                actual: intentJournalEnvelope.payloadType
            )
        }

        self.runContext = runContext
        self.strategy = strategy
        self.consumedInputs = consumedInputs
        self.intentMessage = intentMessage
        self.payloadType = payloadType
        self.traderEnvelope = traderEnvelope
        self.messageBusEnvelope = messageBusEnvelope
        self.intentJournalEnvelope = intentJournalEnvelope
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            strategy: try container.decode(ReleaseV040RehearsalStrategyKind.self, forKey: .strategy),
            consumedInputs: try container.decode([ReleaseV040TraderStrategyMarketInput].self, forKey: .consumedInputs),
            intentMessage: try container.decode(StrategyIntentMessage.self, forKey: .intentMessage),
            payloadType: try container.decode(String.self, forKey: .payloadType),
            traderEnvelope: try container.decode(ReleaseV040UnifiedEvidenceEnvelope.self, forKey: .traderEnvelope),
            messageBusEnvelope: try container.decode(ReleaseV040UnifiedEvidenceEnvelope.self, forKey: .messageBusEnvelope),
            intentJournalEnvelope: try container.decode(MessageBusJournalEnvelope.self, forKey: .intentJournalEnvelope)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case runContext
        case strategy
        case consumedInputs
        case intentMessage
        case payloadType
        case traderEnvelope
        case messageBusEnvelope
        case intentJournalEnvelope
    }
}

/// ReleaseV040TraderStrategyActorsRuntimeStepEvidence 汇总 GH-698 Trader EMA / RSI actor 输出。
public struct ReleaseV040TraderStrategyActorsRuntimeStepEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let consumedMarketInputs: [ReleaseV040TraderStrategyMarketInput]
    public let emissions: [ReleaseV040TraderStrategyActorEmission]
    public let replayedIntentEnvelopes: [MessageBusJournalEnvelope]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let directExecutionClientAccessEnabled: Bool
    public let directBrokerAccessEnabled: Bool
    public let commandGatewayBypassAllowed: Bool
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let unsupportedStrategyEnabled: Bool

    public var runID: Identifier { runContext.runID }

    public var intentMessages: [StrategyIntentMessage] {
        emissions.map(\.intentMessage)
    }

    public var intentJournalEnvelopes: [MessageBusJournalEnvelope] {
        emissions.map(\.intentJournalEnvelope)
    }

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        emissions.flatMap { [$0.traderEnvelope, $0.messageBusEnvelope] }
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-698"
            && upstreamIssueID.rawValue == "GH-697"
            && downstreamIssueID.rawValue == "GH-699"
            && runContext.mode == .dryRun
            && messageBusMarketConsumptionHeld
            && strategyCoverageHeld
            && runScopedIntentHeld
            && noDirectExecutionPathHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var messageBusMarketConsumptionHeld: Bool {
        consumedMarketInputs.isEmpty == false
            && consumedMarketInputs.allSatisfy(\.boundaryHeld)
            && consumedMarketInputs.allSatisfy { $0.runID == runID }
            && consumedMarketInputs.allSatisfy {
                $0.upstreamMarketEnvelope.payloadType.hasPrefix("dataengine.release-v0.4.0.binance")
            }
    }

    public var strategyCoverageHeld: Bool {
        Set(emissions.map(\.strategy)) == Set(ReleaseV040RehearsalRunContext.requiredStrategies)
            && Set(intentMessages.map(\.instrument.productType)) == Set(ReleaseV040RehearsalRunContext.requiredProductTypes)
            && intentMessages.allSatisfy { $0.instrument.venue.rawValue == "binance" }
    }

    public var runScopedIntentHeld: Bool {
        emissions.allSatisfy(\.boundaryHeld)
            && emissions.allSatisfy { $0.runID == runID }
            && unifiedEnvelopes.allSatisfy { $0.runID == runID }
            && unifiedEnvelopes.map(\.sequence) == Array(1...unifiedEnvelopes.count)
            && intentJournalEnvelopes == replayedIntentEnvelopes
    }

    public var noDirectExecutionPathHeld: Bool {
        directExecutionClientAccessEnabled == false
            && directBrokerAccessEnabled == false
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
        evidenceID: Identifier = Identifier.constant("gh-698-v040-trader-strategy-actors-runtime-step"),
        issueID: Identifier = Identifier.constant("GH-698"),
        upstreamIssueID: Identifier = Identifier.constant("GH-697"),
        downstreamIssueID: Identifier = Identifier.constant("GH-699"),
        runContext: ReleaseV040RehearsalRunContext,
        consumedMarketInputs: [ReleaseV040TraderStrategyMarketInput],
        emissions: [ReleaseV040TraderStrategyActorEmission],
        replayedIntentEnvelopes: [MessageBusJournalEnvelope],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        directExecutionClientAccessEnabled: Bool = false,
        directBrokerAccessEnabled: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        unsupportedStrategyEnabled: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-698" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-698",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-697" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-697",
                actual: upstreamIssueID.rawValue
            )
        }
        guard downstreamIssueID.rawValue == "GH-699" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "downstreamIssueID",
                expected: "GH-699",
                actual: downstreamIssueID.rawValue
            )
        }
        guard consumedMarketInputs.isEmpty == false, emissions.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evidence",
                expected: "non-empty inputs and emissions",
                actual: "empty"
            )
        }
        guard consumedMarketInputs.allSatisfy({ $0.runID == runContext.runID }),
              emissions.allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard replayedIntentEnvelopes == emissions.map(\.intentJournalEnvelope) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedIntentEnvelopes",
                expected: "intentJournalEnvelopes",
                actual: "drift"
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
            directExecutionClientAccessEnabled: directExecutionClientAccessEnabled,
            directBrokerAccessEnabled: directBrokerAccessEnabled,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            networkCallsPerformed: networkCallsPerformed,
            secretReadsPerformed: secretReadsPerformed,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            unsupportedStrategyEnabled: unsupportedStrategyEnabled
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.runContext = runContext
        self.consumedMarketInputs = consumedMarketInputs
        self.emissions = emissions
        self.replayedIntentEnvelopes = replayedIntentEnvelopes
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.directExecutionClientAccessEnabled = directExecutionClientAccessEnabled
        self.directBrokerAccessEnabled = directBrokerAccessEnabled
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.unsupportedStrategyEnabled = unsupportedStrategyEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            upstreamIssueID: try container.decode(Identifier.self, forKey: .upstreamIssueID),
            downstreamIssueID: try container.decode(Identifier.self, forKey: .downstreamIssueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            consumedMarketInputs: try container.decode([ReleaseV040TraderStrategyMarketInput].self, forKey: .consumedMarketInputs),
            emissions: try container.decode([ReleaseV040TraderStrategyActorEmission].self, forKey: .emissions),
            replayedIntentEnvelopes: try container.decode([MessageBusJournalEnvelope].self, forKey: .replayedIntentEnvelopes),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            directExecutionClientAccessEnabled: try container.decode(Bool.self, forKey: .directExecutionClientAccessEnabled),
            directBrokerAccessEnabled: try container.decode(Bool.self, forKey: .directBrokerAccessEnabled),
            commandGatewayBypassAllowed: try container.decode(Bool.self, forKey: .commandGatewayBypassAllowed),
            networkCallsPerformed: try container.decode(Bool.self, forKey: .networkCallsPerformed),
            secretReadsPerformed: try container.decode(Bool.self, forKey: .secretReadsPerformed),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionBrokerConnected: try container.decode(Bool.self, forKey: .productionBrokerConnected),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized),
            unsupportedStrategyEnabled: try container.decode(Bool.self, forKey: .unsupportedStrategyEnabled)
        )
    }

    public static let validationAnchor = "TVM-RELEASE-V040-TRADER-STRATEGY-ACTORS-RUNTIME-STEP"

    public static let requiredValidationAnchors = [
        "V040-05-TRADER-STRATEGY-ACTORS-RUNTIME-STEP",
        "V040-05-EMA-RSI-RUN-SCOPED-INTENTS",
        "V040-05-MESSAGEBUS-MARKET-CONSUMPTION",
        "V040-05-NO-STRATEGY-EXECUTIONCLIENT-PATH",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH698TraderStrategyActorsConsumeMessageBusMarketEventsAndEmitRunScopedIntents",
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
        case consumedMarketInputs
        case emissions
        case replayedIntentEnvelopes
        case validationAnchors
        case requiredValidationCommands
        case directExecutionClientAccessEnabled
        case directBrokerAccessEnabled
        case commandGatewayBypassAllowed
        case networkCallsPerformed
        case secretReadsPerformed
        case productionEndpointConnected
        case productionBrokerConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case unsupportedStrategyEnabled
    }
}

/// ReleaseV040TraderStrategyActorsRuntimeStep 是 GH-698 的 Trader-owned EMA / RSI actor step。
///
/// Step 只消费 MessageBus market event evidence，并发布 strategy intent evidence。它不拥有
/// DataEngine implementation，不调用 RiskEngine / ExecutionEngine / OMS / ExecutionClient，
/// 不读取 secret，不连接 broker，也不授权 production trading。
public struct ReleaseV040TraderStrategyActorsRuntimeStep: Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_705_000_600),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard recordedAtStride > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordedAtStride",
                expected: "positive",
                actual: "\(recordedAtStride)"
            )
        }
        self.runContext = runContext
        self.sourceID = try sourceID ?? FoundationTargetID("gh-698-trader-strategy-actor-source")
        self.streamID = try streamID ?? MessageBusJournalStreamID("trader.release-v0.4.0.strategy-intent")
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public init(
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_705_000_600),
        recordedAtStride: TimeInterval = 1
    ) throws {
        try self.init(
            runContext: ReleaseV040RehearsalRunContext(
                runID: Identifier.constant("gh-698-v040-trader-strategy-actors-run")
            ),
            sourceID: sourceID,
            streamID: streamID,
            firstRecordedAt: firstRecordedAt,
            recordedAtStride: recordedAtStride
        )
    }

    public func run(
        marketInputs: [ReleaseV040TraderStrategyMarketInput],
        quantity: Quantity,
        emittedAt: Date = Date(timeIntervalSince1970: 1_705_000_900)
    ) throws -> ReleaseV040TraderStrategyActorsRuntimeStepEvidence {
        guard marketInputs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingMessageBusMarketInputs")
        }
        guard marketInputs.allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "marketInputs.runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }

        let emaInputs = sortedInputs(marketInputs, strategy: .ema)
        let rsiInputs = sortedInputs(marketInputs, strategy: .rsi)
        guard let emaInstrument = emaInputs.last?.instrument, let rsiInstrument = rsiInputs.last?.instrument else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingEMAOrRSIMarketInput")
        }

        let emaRuntime = try EMAProposalRuntime(
            runtimeID: Identifier.constant("gh-698-v040-ema-strategy-actor"),
            configuration: EMACrossStrategyConfiguration(
                strategyID: Identifier.constant("gh-698-v040-ema-instance"),
                symbol: emaInstrument.symbol,
                timeframe: emaInputs[0].marketBar.timeframe,
                shortPeriod: 2,
                longPeriod: 3
            )
        )
        let rsiEmitter = try RSITargetExposureIntentEmitter(
            emitterID: Identifier.constant("gh-698-v040-rsi-strategy-actor"),
            configuration: RSIStrategyConfiguration(
                strategyID: Identifier.constant("gh-698-v040-rsi-instance"),
                symbol: rsiInstrument.symbol,
                timeframe: rsiInputs[0].marketBar.timeframe,
                period: 3,
                perpetualShortEnabled: true
            )
        )

        let emaMessage = try emaRuntime.generateTargetExposureIntent(
            from: emaInputs.map(\.marketBar),
            instrument: emaInstrument,
            sourceSequence: 1,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let rsiMessage = try rsiEmitter.generateTargetExposureIntent(
            from: rsiInputs.map(\.marketBar),
            instrument: rsiInstrument,
            sourceSequence: 2,
            quantity: quantity,
            emittedAt: emittedAt.addingTimeInterval(1)
        )

        var journal = try MessageBusAppendOnlyJournal()
        var envelopeSequence = 1
        let emaEmission = try appendEmission(
            strategy: .ema,
            consumedInputs: emaInputs,
            intentMessage: emaMessage,
            journal: &journal,
            envelopeSequence: &envelopeSequence
        )
        let rsiEmission = try appendEmission(
            strategy: .rsi,
            consumedInputs: rsiInputs,
            intentMessage: rsiMessage,
            journal: &journal,
            envelopeSequence: &envelopeSequence
        )
        let emissions = [emaEmission, rsiEmission]

        return try ReleaseV040TraderStrategyActorsRuntimeStepEvidence(
            runContext: runContext,
            consumedMarketInputs: marketInputs,
            emissions: emissions,
            replayedIntentEnvelopes: journal.replay(stream: streamID)
        )
    }

    public static func deterministicEvidence() throws -> ReleaseV040TraderStrategyActorsRuntimeStepEvidence {
        let runContext = try ReleaseV040RehearsalRunContext(
            runID: Identifier.constant("gh-698-v040-trader-strategy-actors-run")
        )
        let step = try ReleaseV040TraderStrategyActorsRuntimeStep(runContext: runContext)
        return try step.run(
            marketInputs: deterministicMessageBusMarketInputs(runContext: runContext),
            quantity: Quantity(0.10, field: "gh698.quantity")
        )
    }

    public static func deterministicMessageBusMarketInputs(
        runContext: ReleaseV040RehearsalRunContext
    ) throws -> [ReleaseV040TraderStrategyMarketInput] {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let spotInstrument = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perpInstrument = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        var journal = try MessageBusAppendOnlyJournal()
        let sourceID = try FoundationTargetID("gh-697-dataengine-messagebus-source")
        let streamID = try MessageBusJournalStreamID("dataengine.release-v0.4.0.rehearsal-market")
        var inputs: [ReleaseV040TraderStrategyMarketInput] = []

        for (index, close) in [42_000.0, 42_080.0, 42_140.0, 42_220.0, 42_310.0].enumerated() {
            let bar = try marketBar(symbol: symbol, close: close, index: index)
            let envelope = try journal.append(
                stream: streamID,
                sourceID: sourceID,
                payloadType: "dataengine.release-v0.4.0.binance.spot.market-event",
                instrumentID: spotInstrument,
                recordedAt: bar.interval.end
            )
            inputs.append(
                try ReleaseV040TraderStrategyMarketInput(
                    runContext: runContext,
                    upstreamEvidenceID: Identifier.constant("gh-697-v040-spot-market-\(index + 1)-evidence"),
                    strategy: .ema,
                    upstreamMarketEnvelope: envelope,
                    instrument: spotInstrument,
                    marketBar: bar
                )
            )
        }

        for (index, close) in [43_000.0, 43_100.0, 43_220.0, 43_350.0].enumerated() {
            let bar = try marketBar(symbol: symbol, close: close, index: index + 10)
            let envelope = try journal.append(
                stream: streamID,
                sourceID: sourceID,
                payloadType: "dataengine.release-v0.4.0.binance.usdm-perpetual.market-event",
                instrumentID: perpInstrument,
                recordedAt: bar.interval.end
            )
            inputs.append(
                try ReleaseV040TraderStrategyMarketInput(
                    runContext: runContext,
                    upstreamEvidenceID: Identifier.constant("gh-697-v040-usdm-perpetual-market-\(index + 1)-evidence"),
                    strategy: .rsi,
                    upstreamMarketEnvelope: envelope,
                    instrument: perpInstrument,
                    marketBar: bar
                )
            )
        }

        return inputs
    }

    private func sortedInputs(
        _ inputs: [ReleaseV040TraderStrategyMarketInput],
        strategy: ReleaseV040RehearsalStrategyKind
    ) -> [ReleaseV040TraderStrategyMarketInput] {
        inputs
            .filter { $0.strategy == strategy }
            .sorted { left, right in left.marketBar.interval.start < right.marketBar.interval.start }
    }

    private func appendEmission(
        strategy: ReleaseV040RehearsalStrategyKind,
        consumedInputs: [ReleaseV040TraderStrategyMarketInput],
        intentMessage: StrategyIntentMessage,
        journal: inout MessageBusAppendOnlyJournal,
        envelopeSequence: inout Int
    ) throws -> ReleaseV040TraderStrategyActorEmission {
        guard let upstreamEvidenceID = consumedInputs.last?.upstreamEvidenceID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingUpstreamEvidenceID")
        }
        let payloadType = payloadType(strategy: strategy, message: intentMessage)
        let journalEnvelope = try journal.append(
            stream: streamID,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: intentMessage.instrument,
            recordedAt: firstRecordedAt.addingTimeInterval(TimeInterval(journal.envelopes.count) * recordedAtStride)
        )
        let normalized = "\(strategy.rawValue.lowercased())-\(intentMessage.instrument.productType.rawValue)"
        let traderEvidenceID = Identifier.constant("gh-698-v040-trader-\(normalized)-intent-evidence")
        let traderEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-698-v040-trader-\(normalized)-intent-envelope"),
            runContext: runContext,
            module: .trader,
            sourceIssueID: Identifier.constant("GH-698"),
            evidenceID: traderEvidenceID,
            upstreamEvidenceID: upstreamEvidenceID,
            validationAnchor: ReleaseV040TraderStrategyActorsRuntimeStepEvidence.validationAnchor,
            sequence: envelopeSequence
        )
        envelopeSequence += 1

        let messageBusEvidenceID = Identifier.constant("gh-698-v040-messagebus-\(normalized)-intent-evidence")
        let messageBusEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-698-v040-messagebus-\(normalized)-intent-envelope"),
            runContext: runContext,
            module: .messageBus,
            sourceIssueID: Identifier.constant("GH-698"),
            evidenceID: messageBusEvidenceID,
            upstreamEvidenceID: traderEvidenceID,
            validationAnchor: ReleaseV040TraderStrategyActorsRuntimeStepEvidence.validationAnchor,
            sequence: envelopeSequence
        )
        envelopeSequence += 1

        return try ReleaseV040TraderStrategyActorEmission(
            runContext: runContext,
            strategy: strategy,
            consumedInputs: consumedInputs,
            intentMessage: intentMessage,
            payloadType: payloadType,
            traderEnvelope: traderEnvelope,
            messageBusEnvelope: messageBusEnvelope,
            intentJournalEnvelope: journalEnvelope
        )
    }

    private func payloadType(
        strategy: ReleaseV040RehearsalStrategyKind,
        message: StrategyIntentMessage
    ) -> String {
        "trader.release-v0.4.0.binance.\(message.instrument.productType.rawValue).\(strategy.rawValue.lowercased()).target-exposure-intent.\(message.instrument.symbol.rawValue)"
    }

    private static func marketBar(
        symbol: Symbol,
        close: Double,
        index: Int
    ) throws -> MarketBar {
        let start = Date(timeIntervalSince1970: 1_705_000_000 + Double(index * 60))
        return try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: DateRange(start: start, end: start.addingTimeInterval(60)),
            open: close - 20,
            high: close + 30,
            low: close - 35,
            close: close,
            volume: 1 + Double(index)
        )
    }
}

private extension ReleaseV040TraderStrategyActorsRuntimeStepEvidence {
    static func validateForbiddenFlags(
        directExecutionClientAccessEnabled: Bool,
        directBrokerAccessEnabled: Bool,
        commandGatewayBypassAllowed: Bool,
        networkCallsPerformed: Bool,
        secretReadsPerformed: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        unsupportedStrategyEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("directExecutionClientAccessEnabled", directExecutionClientAccessEnabled),
            ("directBrokerAccessEnabled", directBrokerAccessEnabled),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("networkCallsPerformed", networkCallsPerformed),
            ("secretReadsPerformed", secretReadsPerformed),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("unsupportedStrategyEnabled", unsupportedStrategyEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
