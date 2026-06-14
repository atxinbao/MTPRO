import Cache
import DataClient
import DomainModel
import Foundation
import MessageBus

/// ReleaseV050DataEngineOperationalDryRunPathError 描述 GH-732 DataEngine dry-run path 的合同错误。
///
/// 错误只覆盖 public market input、typed MessageBus publish、product-aware Cache projection
/// 和 no-production boundary；不表达 signed endpoint、secret、broker、OMS 或真实订单能力。
public enum ReleaseV050DataEngineOperationalDryRunPathError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyInputs
    case invalidRecordedAtStride(TimeInterval)
    case unsupportedVenue(String)
    case unsupportedProductType(String)
    case sourceBoundaryMismatch(String)
    case instrumentCatalogMismatch(expected: String, actual: String)
    case marketEventInstrumentMismatch(expected: String, actual: String)
    case cacheReplayMismatch
    case replayMismatch
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case .emptyInputs:
            "Release v0.5.0 DataEngine dry-run path requires at least one public market input"
        case let .invalidRecordedAtStride(value):
            "Release v0.5.0 DataEngine dry-run recordedAt stride must be positive: \(value)"
        case let .unsupportedVenue(value):
            "Release v0.5.0 DataEngine dry-run only supports Binance venue: \(value)"
        case let .unsupportedProductType(value):
            "Release v0.5.0 DataEngine dry-run only supports Spot and USD-M Perpetual: \(value)"
        case let .sourceBoundaryMismatch(reason):
            "Release v0.5.0 DataEngine dry-run source boundary mismatch: \(reason)"
        case let .instrumentCatalogMismatch(expected, actual):
            "Release v0.5.0 DataEngine dry-run instrument catalog mismatch: expected \(expected), actual \(actual)"
        case let .marketEventInstrumentMismatch(expected, actual):
            "Release v0.5.0 DataEngine dry-run market event instrument mismatch: expected \(expected), actual \(actual)"
        case .cacheReplayMismatch:
            "Release v0.5.0 DataEngine dry-run cache replay does not match live projection"
        case .replayMismatch:
            "Release v0.5.0 DataEngine dry-run MessageBus replay does not match published envelopes"
        case let .forbiddenProductionCapability(capability):
            "Release v0.5.0 DataEngine dry-run rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV050DataEngineDryRunMarketInput 是 DataClient public market data 进入 DataEngine 的本地输入。
///
/// 输入显式绑定 DataClient source、InstrumentCatalog row、MarketEvent 和 fixed-point runtime
/// price / quantity。它不携带 URL、API key、secret、account payload、broker payload 或 order command。
public struct ReleaseV050DataEngineDryRunMarketInput: Codable, Equatable, Sendable {
    public let source: DataClientReadOnlyMarketDataSource
    public let catalogEntry: ReleaseV050InstrumentCatalogEntry
    public let marketEvent: MarketEvent
    public let runtimePrice: ReleaseV050FixedPointValue
    public let runtimeQuantity: ReleaseV050FixedPointValue
    public let qualityTag: String

    public var instrument: InstrumentIdentity {
        catalogEntry.instrument
    }

    public var productType: ProductType {
        instrument.productType
    }

    public init(
        source: DataClientReadOnlyMarketDataSource,
        catalogEntry: ReleaseV050InstrumentCatalogEntry,
        marketEvent: MarketEvent,
        runtimePrice: ReleaseV050FixedPointValue,
        runtimeQuantity: ReleaseV050FixedPointValue,
        qualityTag: String
    ) throws {
        guard source.publicReadOnlyBoundaryHeld else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.sourceBoundaryMismatch("DataClient source is not public read-only")
        }
        guard source.venue == .binance else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.unsupportedVenue(source.venue.rawValue)
        }
        guard catalogEntry.entryHeld else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.instrumentCatalogMismatch(
                expected: "held catalog entry",
                actual: catalogEntry.instrument.rawValue
            )
        }
        guard catalogEntry.instrument.venue.rawValue == "binance" else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.unsupportedVenue(catalogEntry.instrument.venue.rawValue)
        }
        guard ReleaseV050DataEngineOperationalDryRunPathContract.requiredProductTypes.contains(catalogEntry.instrument.productType) else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.unsupportedProductType(catalogEntry.instrument.productType.rawValue)
        }
        guard source.symbol == catalogEntry.instrument.symbol else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.instrumentCatalogMismatch(
                expected: source.symbol.rawValue,
                actual: catalogEntry.instrument.symbol.rawValue
            )
        }
        guard marketEvent.symbol == catalogEntry.instrument.symbol else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.marketEventInstrumentMismatch(
                expected: catalogEntry.instrument.symbol.rawValue,
                actual: marketEvent.symbol.rawValue
            )
        }
        guard runtimePrice.semantic == .price else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .dataEngineMarketEvent, actual: .portfolioProjectionEvent)
        }
        guard runtimeQuantity.semantic == .quantity else {
            throw RuntimeMessageBusError.payloadTypeMismatch(expected: .dataEngineMarketEvent, actual: .strategyIntentEvent)
        }

        self.source = source
        self.catalogEntry = catalogEntry
        self.marketEvent = marketEvent
        self.runtimePrice = runtimePrice
        self.runtimeQuantity = runtimeQuantity
        self.qualityTag = try FoundationTargetID(qualityTag, field: "releaseV050DataEngineQualityTag").rawValue
    }

    /// 构造 MessageBus typed payload；payload 只保留 runtime market data 必需字段。
    public func runtimePayload() throws -> ReleaseV050RuntimeEventPayload {
        try .dataEngineMarket(
            DataEngineMarketEvent(
                instrument: instrument,
                price: runtimePrice,
                quantity: runtimeQuantity,
                qualityTag: qualityTag
            )
        )
    }
}

public typealias ReleaseV050DataEngineOperationalDryRunMarketInput = ReleaseV050DataEngineDryRunMarketInput

/// ReleaseV050DataEngineOperationalDryRunEmission 是一次 DataEngine publish + Cache ingest 的证据。
public struct ReleaseV050DataEngineOperationalDryRunEmission: Codable, Equatable, Sendable {
    public let input: ReleaseV050DataEngineDryRunMarketInput
    public let payload: ReleaseV050RuntimeEventPayload
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let cacheEventCountAfterApply: Int

    public var runID: Identifier {
        envelope.runID
    }

    public var boundaryHeld: Bool {
        envelope.envelopeHeld
            && envelope.sourceModule == .dataEngine
            && envelope.payloadType == .dataEngineMarketEvent
            && payload.payloadType == .dataEngineMarketEvent
            && payload.sourceModule == .dataEngine
            && input.instrument.venue.rawValue == "binance"
            && ReleaseV050DataEngineOperationalDryRunPathContract.requiredProductTypes.contains(input.productType)
            && input.marketEvent.symbol == input.instrument.symbol
            && input.source.publicReadOnlyBoundaryHeld
            && cacheEventCountAfterApply > 0
    }
}

/// ReleaseV050DataEngineOperationalDryRunEvidence 汇总 GH-732 operational dry-run path。
public struct ReleaseV050DataEngineOperationalDryRunEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let emissions: [ReleaseV050DataEngineOperationalDryRunEmission]
    public let replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let cacheSnapshot: ProductAwareCacheSnapshot
    public let replayedCacheSnapshot: ProductAwareCacheSnapshot
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var eventEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        emissions.map(\.envelope)
    }

    public var marketInputs: [ReleaseV050DataEngineDryRunMarketInput] {
        emissions.map(\.input)
    }

    public var productTypes: [ProductType] {
        marketInputs.map(\.productType)
    }

    public var productIdentityCoverageHeld: Bool {
        Set(productTypes) == Set(ReleaseV050DataEngineOperationalDryRunPathContract.requiredProductTypes)
            && marketInputs.allSatisfy { $0.instrument.venue.rawValue == "binance" }
            && marketInputs.allSatisfy { $0.marketEvent.symbol == $0.instrument.symbol }
            && marketInputs.allSatisfy { $0.source.symbol == $0.instrument.symbol }
    }

    public var runScopedMessageBusHeld: Bool {
        emissions.isEmpty == false
            && emissions.allSatisfy(\.boundaryHeld)
            && eventEnvelopes == replayedEnvelopes
            && eventEnvelopes.allSatisfy { $0.runID == runID }
            && eventEnvelopes.allSatisfy { $0.streamID == streamID }
            && eventEnvelopes.allSatisfy { $0.correlationID == correlationID }
            && eventEnvelopes.map(\.sequence) == Array(1...eventEnvelopes.count)
            && eventEnvelopes.dropFirst().compactMap(\.causationID) == eventEnvelopes.dropLast().map(\.eventID)
    }

    public var cacheProjectionHeld: Bool {
        cacheSnapshot == replayedCacheSnapshot
            && cacheSnapshot.marketData.marketEventCount == emissions.count
            && cacheSnapshot.productAwareBoundaryHeld
    }

    public var forbiddenRuntimeHeld: Bool {
        networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-732"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-728", "GH-730", "GH-731"]
            && previousIssueID.rawValue == "GH-731"
            && productIdentityCoverageHeld
            && runScopedMessageBusHeld
            && cacheProjectionHeld
            && validationAnchors == ReleaseV050DataEngineOperationalDryRunPathContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV050DataEngineOperationalDryRunPathContract.requiredValidationCommands
            && forbiddenRuntimeHeld
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-732"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-728"),
            Identifier.constant("GH-730"),
            Identifier.constant("GH-731")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-731"),
        runID: Identifier,
        streamID: MessageBusJournalStreamID,
        correlationID: Identifier,
        emissions: [ReleaseV050DataEngineOperationalDryRunEmission],
        replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        cacheSnapshot: ProductAwareCacheSnapshot,
        replayedCacheSnapshot: ProductAwareCacheSnapshot,
        validationAnchors: [String] = ReleaseV050DataEngineOperationalDryRunPathContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV050DataEngineOperationalDryRunPathContract.requiredValidationCommands,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.runID = runID
        self.streamID = streamID
        self.correlationID = correlationID
        self.emissions = emissions
        self.replayedEnvelopes = replayedEnvelopes
        self.cacheSnapshot = cacheSnapshot
        self.replayedCacheSnapshot = replayedCacheSnapshot
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.forbiddenProductionCapability("evidenceContractDrift")
        }
    }
}

/// ReleaseV050DataEngineOperationalDryRunPath 执行本地 public market input dry-run。
///
/// 该 path 只在内存中消费 DataClient public source identity 和 `MarketEvent`，把 typed
/// `DataEngineMarketEvent` 写入 RuntimeMessageBus actor，同时投影到 ProductAwareCache。
public struct ReleaseV050DataEngineOperationalDryRunPath: Sendable {
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval
    public let eventIDPrefix: String

    public init(
        runID: Identifier = Identifier.constant("gh-732-v050-dataengine-dry-run"),
        streamID: MessageBusJournalStreamID? = nil,
        correlationID: Identifier = Identifier.constant("gh-732-v050-dataengine-correlation"),
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_732),
        recordedAtStride: TimeInterval = 1,
        eventIDPrefix: String = "gh-732-v050-dataengine-event"
    ) throws {
        guard recordedAtStride > 0 else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.invalidRecordedAtStride(recordedAtStride)
        }
        self.runID = runID
        self.streamID = try streamID ?? MessageBusJournalStreamID("release-v050-dataengine-dry-run")
        self.correlationID = correlationID
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
        self.eventIDPrefix = try FoundationTargetID(eventIDPrefix, field: "runtimeEventIDPrefix").rawValue
    }

    public func run(
        inputs: [ReleaseV050DataEngineDryRunMarketInput]
    ) async throws -> ReleaseV050DataEngineOperationalDryRunEvidence {
        guard inputs.isEmpty == false else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.emptyInputs
        }

        let bus = try RuntimeMessageBus<ReleaseV050RuntimeEventPayload>()
        var cache = ProductAwareCache()
        var emissions: [ReleaseV050DataEngineOperationalDryRunEmission] = []
        var causationID: Identifier?

        for (index, input) in inputs.enumerated() {
            let payload = try input.runtimePayload()
            let envelope = try await bus.publish(
                runID: runID,
                streamID: streamID,
                correlationID: correlationID,
                causationID: causationID,
                sourceModule: payload.sourceModule,
                payloadType: payload.payloadType,
                payload: payload,
                recordedAt: firstRecordedAt.addingTimeInterval(TimeInterval(index) * recordedAtStride),
                eventID: Identifier.constant("\(eventIDPrefix)-\(index + 1)", field: "runtimeEventID")
            )
            causationID = envelope.eventID
            let cacheSnapshot = try cache.ingestMarketEvent(input.marketEvent, instrument: input.instrument)
            emissions.append(
                ReleaseV050DataEngineOperationalDryRunEmission(
                    input: input,
                    payload: payload,
                    envelope: envelope,
                    cacheEventCountAfterApply: cacheSnapshot.marketData.marketEventCount
                )
            )
        }

        let replayed = await bus.replay(
            runID: runID,
            streamID: streamID,
            payloadType: .dataEngineMarketEvent
        )
        guard replayed == emissions.map(\.envelope) else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.replayMismatch
        }

        let replayedCacheSnapshot = try Self.replayCache(from: emissions)
        guard replayedCacheSnapshot == cache.snapshot else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.cacheReplayMismatch
        }

        return try ReleaseV050DataEngineOperationalDryRunEvidence(
            runID: runID,
            streamID: streamID,
            correlationID: correlationID,
            emissions: emissions,
            replayedEnvelopes: replayed,
            cacheSnapshot: cache.snapshot,
            replayedCacheSnapshot: replayedCacheSnapshot
        )
    }

    public static func deterministicEvidence() async throws -> ReleaseV050DataEngineOperationalDryRunEvidence {
        let path = try ReleaseV050DataEngineOperationalDryRunPath()
        return try await path.run(inputs: deterministicInputs())
    }

    public static func deterministicInputs() throws -> [ReleaseV050DataEngineDryRunMarketInput] {
        let catalog = try ReleaseV050InstrumentCatalog.deterministicFixture()
        let symbol = Symbol.constant("BTCUSDT")
        let interval = DateRange.constant(
            start: Date(timeIntervalSince1970: 1_800_000_700),
            end: Date(timeIntervalSince1970: 1_800_000_760)
        )
        let spotInstrument = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perpInstrument = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let spotEntry = try requiredEntry(catalog: catalog, instrument: spotInstrument)
        let perpEntry = try requiredEntry(catalog: catalog, instrument: perpInstrument)
        let spotSource = try DataClientReadOnlyMarketDataSource(
            sourceID: try FoundationTargetID("gh-732-data-client-spot-source"),
            venue: .binance,
            symbol: symbol,
            timeframe: .oneMinute,
            datasetVersion: "v0.5.0-gh-732-spot-public-market-input"
        )
        let perpSource = try DataClientReadOnlyMarketDataSource(
            sourceID: try FoundationTargetID("gh-732-data-client-usdm-source"),
            venue: .binance,
            symbol: symbol,
            timeframe: .oneMinute,
            datasetVersion: "v0.5.0-gh-732-usdm-public-market-input"
        )
        let spotBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 67_500,
            high: 67_650,
            low: 67_450,
            close: 67_550,
            volume: 12.345
        )
        let perpBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 67_505,
            high: 67_670,
            low: 67_480,
            close: 67_560,
            volume: 48.125
        )

        return [
            try ReleaseV050DataEngineDryRunMarketInput(
                source: spotSource,
                catalogEntry: spotEntry,
                marketEvent: .bar(spotBar),
                runtimePrice: .price(minorUnits: 6_755_000, scale: 2),
                runtimeQuantity: .quantity(minorUnits: 12_345_000, scale: 6),
                qualityTag: "dry-run-public-spot"
            ),
            try ReleaseV050DataEngineDryRunMarketInput(
                source: perpSource,
                catalogEntry: perpEntry,
                marketEvent: .bar(perpBar),
                runtimePrice: .price(minorUnits: 675_600, scale: 1),
                runtimeQuantity: .quantity(minorUnits: 48_125, scale: 3),
                qualityTag: "dry-run-public-usdm-perp"
            )
        ]
    }

    private static func replayCache(
        from emissions: [ReleaseV050DataEngineOperationalDryRunEmission]
    ) throws -> ProductAwareCacheSnapshot {
        var cache = ProductAwareCache()
        for emission in emissions {
            try cache.ingestMarketEvent(emission.input.marketEvent, instrument: emission.input.instrument)
        }
        return cache.snapshot
    }

    private static func requiredEntry(
        catalog: ReleaseV050InstrumentCatalog,
        instrument: InstrumentIdentity
    ) throws -> ReleaseV050InstrumentCatalogEntry {
        guard let entry = catalog.entry(for: instrument) else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.instrumentCatalogMismatch(
                expected: instrument.rawValue,
                actual: "missing"
            )
        }
        return entry
    }
}

/// ReleaseV050DataEngineOperationalDryRunPathContract 固定 GH-732 validation anchors 和边界。
public struct ReleaseV050DataEngineOperationalDryRunPathContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let allowedVenue: String
    public let allowedProductTypes: [ProductType]
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
        issueID.rawValue == "GH-732"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-728", "GH-730", "GH-731"]
            && previousIssueID.rawValue == "GH-731"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-733", "GH-735", "GH-739"]
            && releaseVersion == "v0.5.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && allowedVenue == "binance"
            && allowedProductTypes == Self.requiredProductTypes
            && productionDefaultsClosed
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-732"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-728"),
            Identifier.constant("GH-730"),
            Identifier.constant("GH-731")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-731"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-733"),
            Identifier.constant("GH-735"),
            Identifier.constant("GH-739")
        ],
        releaseVersion: String = "v0.5.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        allowedVenue: String = "binance",
        allowedProductTypes: [ProductType] = Self.requiredProductTypes,
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
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV050DataEngineOperationalDryRunPathError.forbiddenProductionCapability("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV050DataEngineOperationalDryRunPathContract {
        try ReleaseV050DataEngineOperationalDryRunPathContract()
    }

    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]

    public static let requiredValidationAnchors = [
        "V050-07-DATAENGINE-OPERATIONAL-DRY-RUN-PATH",
        "V050-07-PUBLIC-MARKET-INPUT-DATACLIENT-DATAENGINE",
        "V050-07-TYPED-DATAENGINE-MARKET-EVENTS",
        "V050-07-RUN-SCOPED-MESSAGEBUS-CACHE-PROJECTION",
        "TVM-RELEASE-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH732DataEngineOperationalDryRunPathPublishesTypedMarketEventsIntoMessageBusAndCache",
        "bash checks/verify-v0.5.0-dataengine.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
