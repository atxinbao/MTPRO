import DomainModel
import Foundation
import MessageBus

/// ReleaseV040DataEngineMessageBusPayloadType 固定 GH-697 DataEngine -> MessageBus 的 payload 标签。
///
/// Payload 标签只描述本地 rehearsal market event，不携带 adapter request、HTTP path、secret、
/// broker payload、account payload 或 order command。
public enum ReleaseV040DataEngineMessageBusPayloadType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case binanceSpotMarketEvent = "dataengine.release-v0.4.0.binance.spot.market-event"
    case binanceUSDMPerpetualMarketEvent = "dataengine.release-v0.4.0.binance.usdm-perpetual.market-event"
}

/// ReleaseV040DataEngineMessageBusEmission 是单个 market event 进入 unified run 的 evidence。
///
/// 每个 emission 同时持有 DataEngine envelope、MessageBus envelope 和真实 MessageBus journal envelope。
/// 三者必须共享同一 `RehearsalRunContext.runID`，从而证明 market event 已进入 unified run，
/// 而不是停留在 DataEngine 的孤立 evidence surface。
public struct ReleaseV040DataEngineMessageBusEmission: Codable, Equatable, Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let instrument: InstrumentIdentity
    public let marketEvent: MarketEvent
    public let payloadType: ReleaseV040DataEngineMessageBusPayloadType
    public let dataEngineEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let messageBusEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let journalEnvelope: MessageBusJournalEnvelope

    public var runID: Identifier { runContext.runID }

    public var boundaryHeld: Bool {
        runContext.boundaryHeld
            && dataEngineEnvelope.runID == runID
            && dataEngineEnvelope.module == .dataEngine
            && messageBusEnvelope.runID == runID
            && messageBusEnvelope.module == .messageBus
            && messageBusEnvelope.upstreamEvidenceID == dataEngineEnvelope.evidenceID
            && journalEnvelope.instrumentID == instrument
            && journalEnvelope.productType == instrument.productType
            && journalEnvelope.payloadType == payloadType.rawValue
            && marketEvent.symbol == instrument.symbol
            && instrument.venue.rawValue == "binance"
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType)
    }

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        instrument: InstrumentIdentity,
        marketEvent: MarketEvent,
        payloadType: ReleaseV040DataEngineMessageBusPayloadType,
        dataEngineEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        messageBusEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        journalEnvelope: MessageBusJournalEnvelope
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonBinanceVenue")
        }
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedProductType")
        }
        guard marketEvent.symbol == instrument.symbol else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "marketEvent.symbol",
                expected: instrument.symbol.rawValue,
                actual: marketEvent.symbol.rawValue
            )
        }
        guard journalEnvelope.instrumentID == instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "journalEnvelope.instrumentID",
                expected: instrument.rawValue,
                actual: journalEnvelope.instrumentID?.rawValue ?? "nil"
            )
        }
        guard journalEnvelope.payloadType == payloadType.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "journalEnvelope.payloadType",
                expected: payloadType.rawValue,
                actual: journalEnvelope.payloadType
            )
        }
        guard dataEngineEnvelope.runID == runContext.runID, messageBusEnvelope.runID == runContext.runID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard dataEngineEnvelope.module == .dataEngine else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "dataEngineEnvelope.module",
                expected: ReleaseV040UnifiedEvidenceModule.dataEngine.rawValue,
                actual: dataEngineEnvelope.module.rawValue
            )
        }
        guard messageBusEnvelope.module == .messageBus else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "messageBusEnvelope.module",
                expected: ReleaseV040UnifiedEvidenceModule.messageBus.rawValue,
                actual: messageBusEnvelope.module.rawValue
            )
        }
        guard messageBusEnvelope.upstreamEvidenceID == dataEngineEnvelope.evidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "messageBusEnvelope.upstreamEvidenceID",
                expected: dataEngineEnvelope.evidenceID.rawValue,
                actual: messageBusEnvelope.upstreamEvidenceID?.rawValue ?? "nil"
            )
        }

        self.runContext = runContext
        self.instrument = instrument
        self.marketEvent = marketEvent
        self.payloadType = payloadType
        self.dataEngineEnvelope = dataEngineEnvelope
        self.messageBusEnvelope = messageBusEnvelope
        self.journalEnvelope = journalEnvelope
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            instrument: try container.decode(InstrumentIdentity.self, forKey: .instrument),
            marketEvent: try container.decode(MarketEvent.self, forKey: .marketEvent),
            payloadType: try container.decode(ReleaseV040DataEngineMessageBusPayloadType.self, forKey: .payloadType),
            dataEngineEnvelope: try container.decode(ReleaseV040UnifiedEvidenceEnvelope.self, forKey: .dataEngineEnvelope),
            messageBusEnvelope: try container.decode(ReleaseV040UnifiedEvidenceEnvelope.self, forKey: .messageBusEnvelope),
            journalEnvelope: try container.decode(MessageBusJournalEnvelope.self, forKey: .journalEnvelope)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case runContext
        case instrument
        case marketEvent
        case payloadType
        case dataEngineEnvelope
        case messageBusEnvelope
        case journalEnvelope
    }
}

/// ReleaseV040DataEngineMessageBusRuntimeStepEvidence 汇总 GH-697 的 DataEngine -> MessageBus 输出。
public struct ReleaseV040DataEngineMessageBusRuntimeStepEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let streamID: MessageBusJournalStreamID
    public let emissions: [ReleaseV040DataEngineMessageBusEmission]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var journalEnvelopes: [MessageBusJournalEnvelope] {
        emissions.map(\.journalEnvelope)
    }

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        emissions.flatMap { [$0.dataEngineEnvelope, $0.messageBusEnvelope] }
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-697"
            && upstreamIssueID.rawValue == "GH-696"
            && runContext.mode == .dryRun
            && productIdentityCoverageHeld
            && runScopedMessageBusHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenRuntimeHeld
    }

    public var productIdentityCoverageHeld: Bool {
        let productTypes = Set(emissions.map(\.instrument.productType))
        return productTypes == Set(ReleaseV040RehearsalRunContext.requiredProductTypes)
            && emissions.allSatisfy { $0.instrument.venue.rawValue == "binance" }
            && emissions.allSatisfy { $0.marketEvent.symbol == $0.instrument.symbol }
    }

    public var runScopedMessageBusHeld: Bool {
        emissions.isEmpty == false
            && emissions.allSatisfy(\.boundaryHeld)
            && emissions.allSatisfy { $0.runID == runContext.runID }
            && replayedEnvelopes == journalEnvelopes
            && journalEnvelopes.allSatisfy { $0.stream == streamID }
            && unifiedEnvelopes.allSatisfy { $0.runID == runContext.runID }
            && unifiedEnvelopes.map(\.sequence) == Array(1...unifiedEnvelopes.count)
    }

    public var forbiddenRuntimeHeld: Bool {
        networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-697-v040-dataengine-messagebus-runtime-step"),
        issueID: Identifier = Identifier.constant("GH-697"),
        upstreamIssueID: Identifier = Identifier.constant("GH-696"),
        runContext: ReleaseV040RehearsalRunContext,
        streamID: MessageBusJournalStreamID,
        emissions: [ReleaseV040DataEngineMessageBusEmission],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-697" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-697",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-696" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-696",
                actual: upstreamIssueID.rawValue
            )
        }
        guard emissions.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "emissions",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard replayedEnvelopes == emissions.map(\.journalEnvelope) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedEnvelopes",
                expected: "journalEnvelopes",
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
            networkCallsPerformed: networkCallsPerformed,
            secretReadsPerformed: secretReadsPerformed,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.runContext = runContext
        self.streamID = streamID
        self.emissions = emissions
        self.replayedEnvelopes = replayedEnvelopes
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            upstreamIssueID: try container.decode(Identifier.self, forKey: .upstreamIssueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            streamID: try container.decode(MessageBusJournalStreamID.self, forKey: .streamID),
            emissions: try container.decode([ReleaseV040DataEngineMessageBusEmission].self, forKey: .emissions),
            replayedEnvelopes: try container.decode([MessageBusJournalEnvelope].self, forKey: .replayedEnvelopes),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            networkCallsPerformed: try container.decode(Bool.self, forKey: .networkCallsPerformed),
            secretReadsPerformed: try container.decode(Bool.self, forKey: .secretReadsPerformed),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionBrokerConnected: try container.decode(Bool.self, forKey: .productionBrokerConnected),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        )
    }

    public static let validationAnchor = "TVM-RELEASE-V040-DATAENGINE-MESSAGEBUS-RUNTIME-STEP"

    public static let requiredValidationAnchors = [
        "V040-04-DATAENGINE-MESSAGEBUS-RUNTIME-STEP",
        "V040-04-RUN-SCOPED-MARKET-EVENTS",
        "V040-04-BINANCE-SPOT-PERP-PRODUCT-IDENTITY",
        "V040-04-FORBIDDEN-NETWORK-SECRET-PRODUCTION",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH697DataEngineRuntimeStepPublishesRunScopedMarketEventsIntoMessageBus",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private enum CodingKeys: String, CodingKey {
        case evidenceID
        case issueID
        case upstreamIssueID
        case runContext
        case streamID
        case emissions
        case replayedEnvelopes
        case validationAnchors
        case requiredValidationCommands
        case networkCallsPerformed
        case secretReadsPerformed
        case productionEndpointConnected
        case productionBrokerConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }
}

/// ReleaseV040DataEngineMessageBusRuntimeStep 是 GH-697 的本地 dry-run DataEngine step。
public struct ReleaseV040DataEngineMessageBusRuntimeStep: Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_705_000_000),
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
        self.sourceID = try sourceID ?? FoundationTargetID("gh-697-dataengine-messagebus-source")
        self.streamID = try streamID ?? MessageBusJournalStreamID("dataengine.release-v0.4.0.rehearsal-market")
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public init(
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_705_000_000),
        recordedAtStride: TimeInterval = 1
    ) throws {
        try self.init(
            runContext: ReleaseV040RehearsalRunContext(
                runID: Identifier.constant("gh-697-v040-dataengine-messagebus-run")
            ),
            sourceID: sourceID,
            streamID: streamID,
            firstRecordedAt: firstRecordedAt,
            recordedAtStride: recordedAtStride
        )
    }

    public func run(
        spotEvents: [BinanceSpotProductAwareMarketDataEvent],
        usdmPerpetualEvents: [BinanceUSDMPerpetualProductAwareMarketDataEvent]
    ) throws -> ReleaseV040DataEngineMessageBusRuntimeStepEvidence {
        guard spotEvents.isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingSpotMarketEvent")
        }
        guard usdmPerpetualEvents.isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingUSDMPerpetualMarketEvent")
        }

        var journal = try MessageBusAppendOnlyJournal()
        var emissions: [ReleaseV040DataEngineMessageBusEmission] = []
        var envelopeSequence = 1
        var upstreamEvidenceID: Identifier?

        for event in spotEvents {
            let emission = try appendEmission(
                productAwareEvent: event,
                payloadType: .binanceSpotMarketEvent,
                journal: &journal,
                envelopeSequence: &envelopeSequence,
                upstreamEvidenceID: &upstreamEvidenceID
            )
            emissions.append(emission)
        }

        for event in usdmPerpetualEvents {
            guard let marketEvent = event.marketEvent else {
                throw CoreError.liveTradingBoundaryForbiddenCapability("nonMarketUSDMPerpetualEvidence")
            }
            let emission = try appendEmission(
                instrument: event.instrument,
                marketEvent: marketEvent,
                payloadType: .binanceUSDMPerpetualMarketEvent,
                journal: &journal,
                envelopeSequence: &envelopeSequence,
                upstreamEvidenceID: &upstreamEvidenceID
            )
            emissions.append(emission)
        }

        return try ReleaseV040DataEngineMessageBusRuntimeStepEvidence(
            runContext: runContext,
            streamID: streamID,
            emissions: emissions,
            replayedEnvelopes: journal.replay(stream: streamID)
        )
    }

    public static func deterministicEvidence() throws -> ReleaseV040DataEngineMessageBusRuntimeStepEvidence {
        let step = try ReleaseV040DataEngineMessageBusRuntimeStep()
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let interval = try DateRange(
            start: Date(timeIntervalSince1970: 1_705_000_000),
            end: Date(timeIntervalSince1970: 1_705_000_060)
        )
        let spotInstrument = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perpInstrument = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let spotBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 42_000,
            high: 42_120,
            low: 41_950,
            close: 42_050,
            volume: 12.5
        )
        let perpBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 42_005,
            high: 42_140,
            low: 41_970,
            close: 42_070,
            volume: 31.0
        )

        return try step.run(
            spotEvents: [
                BinanceSpotProductAwareMarketDataEvent(
                    instrument: spotInstrument,
                    marketEvent: .bar(spotBar)
                )
            ],
            usdmPerpetualEvents: [
                BinanceUSDMPerpetualProductAwareMarketDataEvent(
                    instrument: perpInstrument,
                    marketEvent: .bar(perpBar)
                )
            ]
        )
    }

    private func appendEmission(
        productAwareEvent: BinanceSpotProductAwareMarketDataEvent,
        payloadType: ReleaseV040DataEngineMessageBusPayloadType,
        journal: inout MessageBusAppendOnlyJournal,
        envelopeSequence: inout Int,
        upstreamEvidenceID: inout Identifier?
    ) throws -> ReleaseV040DataEngineMessageBusEmission {
        try appendEmission(
            instrument: productAwareEvent.instrument,
            marketEvent: productAwareEvent.marketEvent,
            payloadType: payloadType,
            journal: &journal,
            envelopeSequence: &envelopeSequence,
            upstreamEvidenceID: &upstreamEvidenceID
        )
    }

    private func appendEmission(
        instrument: InstrumentIdentity,
        marketEvent: MarketEvent,
        payloadType: ReleaseV040DataEngineMessageBusPayloadType,
        journal: inout MessageBusAppendOnlyJournal,
        envelopeSequence: inout Int,
        upstreamEvidenceID: inout Identifier?
    ) throws -> ReleaseV040DataEngineMessageBusEmission {
        let journalEnvelope = try journal.append(
            stream: streamID,
            sourceID: sourceID,
            payloadType: payloadType.rawValue,
            instrumentID: instrument,
            recordedAt: firstRecordedAt.addingTimeInterval(TimeInterval(journal.envelopes.count) * recordedAtStride)
        )
        let normalized = "\(instrument.productType.rawValue)-\(journalEnvelope.sequence)"
        let dataEngineEvidenceID = Identifier.constant("gh-697-v040-dataengine-\(normalized)-evidence")
        let dataEngineEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-697-v040-dataengine-\(normalized)-envelope"),
            runContext: runContext,
            module: .dataEngine,
            sourceIssueID: Identifier.constant("GH-697"),
            evidenceID: dataEngineEvidenceID,
            upstreamEvidenceID: upstreamEvidenceID,
            validationAnchor: ReleaseV040DataEngineMessageBusRuntimeStepEvidence.validationAnchor,
            sequence: envelopeSequence
        )
        envelopeSequence += 1

        let messageBusEvidenceID = Identifier.constant("gh-697-v040-messagebus-\(normalized)-evidence")
        let messageBusEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-697-v040-messagebus-\(normalized)-envelope"),
            runContext: runContext,
            module: .messageBus,
            sourceIssueID: Identifier.constant("GH-697"),
            evidenceID: messageBusEvidenceID,
            upstreamEvidenceID: dataEngineEvidenceID,
            validationAnchor: ReleaseV040DataEngineMessageBusRuntimeStepEvidence.validationAnchor,
            sequence: envelopeSequence
        )
        envelopeSequence += 1
        upstreamEvidenceID = messageBusEvidenceID

        return try ReleaseV040DataEngineMessageBusEmission(
            runContext: runContext,
            instrument: instrument,
            marketEvent: marketEvent,
            payloadType: payloadType,
            dataEngineEnvelope: dataEngineEnvelope,
            messageBusEnvelope: messageBusEnvelope,
            journalEnvelope: journalEnvelope
        )
    }
}

private extension ReleaseV040DataEngineMessageBusRuntimeStepEvidence {
    static func validateForbiddenFlags(
        networkCallsPerformed: Bool,
        secretReadsPerformed: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("networkCallsPerformed", networkCallsPerformed),
            ("secretReadsPerformed", secretReadsPerformed),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
