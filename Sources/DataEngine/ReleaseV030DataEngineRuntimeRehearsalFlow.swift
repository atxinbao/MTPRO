import Cache
import DomainModel
import Foundation
import MessageBus

/// ReleaseV030DataEngineRehearsalMode 是 DataEngine 本地的 v0.3.0 rehearsal mode 表示。
///
/// DataEngine 不能反向依赖 ExecutionClient 的 GH-658 config 类型；这里仅复用相同
/// contract raw value 作为 evidence 字段，证明 DataEngine rehearsal flow 承接 upstream
/// environment config anchor，但不获得 endpoint、secret、broker 或 order command 能力。
public enum ReleaseV030DataEngineRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ReleaseV030DataEngineRuntimeRehearsalRequirement 固定 GH-659 的 DataEngine 输入与证据要求。
public enum ReleaseV030DataEngineRuntimeRehearsalRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamEnvironmentConfigRequired = "upstream runtime environment config required"
    case binanceSpotProductIdentityRequired = "Binance Spot product identity required"
    case binanceUSDMPerpetualProductIdentityRequired = "Binance USD-M Perpetual product identity required"
    case productAwareCacheProjectionRequired = "product-aware cache projection required"
    case traceableMessageBusEvidenceRequired = "traceable MessageBus evidence required"
    case noProductionEndpointDependency = "no production endpoint dependency"
    case noProductionSecretAutoRead = "no production secret auto-read"
    case noProductionOrderSubmission = "no production order submission"
    case noProductionCutoverAuthorization = "no production cutover authorization"
}

/// ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability 枚举 GH-659 必须拒绝的漂移。
public enum ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case missingSpotRehearsalEvent = "missing Spot rehearsal event"
    case missingUSDMPerpetualRehearsalEvent = "missing USD-M Perpetual rehearsal event"
    case commandGatewayBypass = "CommandGateway bypass"
    case strategyExecutionClientDirectAccess = "Strategy direct ExecutionClient access"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030DataEngineRuntimeRehearsalRecord 是单个产品类型进入 DataEngine 的证据。
///
/// record 只描述已经进入本地 DataEngine / Cache / MessageBus 的 public market data
/// rehearsal event，不描述网络 connector、真实 Binance endpoint 或可交易 command。
public struct ReleaseV030DataEngineRuntimeRehearsalRecord: Codable, Equatable, Sendable {
    public let mode: ReleaseV030DataEngineRehearsalMode
    public let instrument: InstrumentIdentity
    public let marketEventCount: Int
    public let messageBusEnvelopeCount: Int
    public let payloadTypes: [String]
    public let usesProductionEndpoint: Bool
    public let readsProductionSecret: Bool
    public let submitsProductionOrder: Bool
    public let authorizesProductionCutover: Bool

    public var recordHeld: Bool {
        instrument.venue.rawValue == "binance"
            && [.spot, .usdsPerpetual].contains(instrument.productType)
            && marketEventCount > 0
            && messageBusEnvelopeCount >= marketEventCount
            && payloadTypes.isEmpty == false
            && payloadTypes.allSatisfy { $0.contains("dataengine.release-v0.3.0.binance") }
            && productionCapabilitiesClosed
    }

    public var productionCapabilitiesClosed: Bool {
        usesProductionEndpoint == false
            && readsProductionSecret == false
            && submitsProductionOrder == false
            && authorizesProductionCutover == false
    }

    public init(
        mode: ReleaseV030DataEngineRehearsalMode,
        instrument: InstrumentIdentity,
        marketEventCount: Int,
        messageBusEnvelopeCount: Int,
        payloadTypes: [String],
        usesProductionEndpoint: Bool = false,
        readsProductionSecret: Bool = false,
        submitsProductionOrder: Bool = false,
        authorizesProductionCutover: Bool = false
    ) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonBinanceVenue")
        }
        guard [.spot, .usdsPerpetual].contains(instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedProductType")
        }
        guard marketEventCount > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "marketEventCount",
                expected: "positive",
                actual: "\(marketEventCount)"
            )
        }
        guard messageBusEnvelopeCount >= marketEventCount else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "messageBusEnvelopeCount",
                expected: ">= marketEventCount",
                actual: "\(messageBusEnvelopeCount)"
            )
        }
        guard payloadTypes.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "payloadTypes",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard usesProductionEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("usesProductionEndpoint")
        }
        guard readsProductionSecret == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsProductionSecret")
        }
        guard submitsProductionOrder == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("submitsProductionOrder")
        }
        guard authorizesProductionCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("authorizesProductionCutover")
        }

        self.mode = mode
        self.instrument = instrument
        self.marketEventCount = marketEventCount
        self.messageBusEnvelopeCount = messageBusEnvelopeCount
        self.payloadTypes = payloadTypes
        self.usesProductionEndpoint = usesProductionEndpoint
        self.readsProductionSecret = readsProductionSecret
        self.submitsProductionOrder = submitsProductionOrder
        self.authorizesProductionCutover = authorizesProductionCutover
    }
}

/// ReleaseV030DataEngineRuntimeRehearsalEvidence 是 GH-659 的最终 DataEngine evidence。
///
/// Evidence 同时绑定 Spot 和 USDⓈ-M Perpetual product identity、product-aware cache
/// projection 和 MessageBus replay。它不读取 secret、不连接 production endpoint、不提交订单。
public struct ReleaseV030DataEngineRuntimeRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamEnvironmentConfigAnchor: String
    public let mode: ReleaseV030DataEngineRehearsalMode
    public let spotRecord: ReleaseV030DataEngineRuntimeRehearsalRecord
    public let usdmPerpetualRecord: ReleaseV030DataEngineRuntimeRehearsalRecord
    public let cacheSnapshot: ProductAwareMarketDataCacheSnapshot
    public let eventEnvelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let requirements: [ReleaseV030DataEngineRuntimeRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let commandGatewayBypassAllowed: Bool
    public let strategyExecutionClientDirectAccessAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-659"
            && upstreamIssueID.rawValue == "GH-658"
            && downstreamIssueID.rawValue == "GH-660"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamEnvironmentConfigAnchor == Self.requiredUpstreamEnvironmentConfigAnchor
            && mode == .dryRun
            && spotRecord.recordHeld
            && usdmPerpetualRecord.recordHeld
            && productIdentityCoverageHeld
            && traceableMessageBusEvidenceHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionCapabilitiesClosed
            && startsNextMilestone == false
    }

    public var productIdentityCoverageHeld: Bool {
        let spotInstrument = spotRecord.instrument
        let perpInstrument = usdmPerpetualRecord.instrument
        let spotKey = ProductAwareMarketDataSeriesKey(instrument: spotInstrument, timeframe: .oneMinute)
        let perpKey = ProductAwareMarketDataSeriesKey(instrument: perpInstrument, timeframe: .oneMinute)

        return spotInstrument.venue.rawValue == "binance"
            && perpInstrument.venue.rawValue == "binance"
            && spotInstrument.productType == .spot
            && perpInstrument.productType == .usdsPerpetual
            && spotInstrument.symbol == perpInstrument.symbol
            && spotInstrument != perpInstrument
            && cacheSnapshot.productAwareBoundaryHeld
            && cacheSnapshot.barsBySeries[spotKey]?.isEmpty == false
            && cacheSnapshot.barsBySeries[perpKey]?.isEmpty == false
    }

    public var traceableMessageBusEvidenceHeld: Bool {
        eventEnvelopes.isEmpty == false
            && eventEnvelopes == replayedEnvelopes
            && eventEnvelopes.contains { $0.instrumentID == spotRecord.instrument && $0.productType == .spot }
            && eventEnvelopes.contains { $0.instrumentID == usdmPerpetualRecord.instrument && $0.productType == .usdsPerpetual }
            && eventEnvelopes.allSatisfy { $0.payloadType.contains("dataengine.release-v0.3.0.binance") }
    }

    public var productionCapabilitiesClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && commandGatewayBypassAllowed == false
            && strategyExecutionClientDirectAccessAllowed == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-659-release-v0.3.0-dataengine-runtime-rehearsal-flow"),
        issueID: Identifier = Identifier.constant("GH-659"),
        upstreamIssueID: Identifier = Identifier.constant("GH-658"),
        downstreamIssueID: Identifier = Identifier.constant("GH-660"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamEnvironmentConfigAnchor: String = Self.requiredUpstreamEnvironmentConfigAnchor,
        mode: ReleaseV030DataEngineRehearsalMode = .dryRun,
        spotRecord: ReleaseV030DataEngineRuntimeRehearsalRecord,
        usdmPerpetualRecord: ReleaseV030DataEngineRuntimeRehearsalRecord,
        cacheSnapshot: ProductAwareMarketDataCacheSnapshot,
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        requirements: [ReleaseV030DataEngineRuntimeRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        strategyExecutionClientDirectAccessAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamEnvironmentConfigAnchor: upstreamEnvironmentConfigAnchor,
            mode: mode,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            strategyExecutionClientDirectAccessAllowed: strategyExecutionClientDirectAccessAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamEnvironmentConfigAnchor = upstreamEnvironmentConfigAnchor
        self.mode = mode
        self.spotRecord = spotRecord
        self.usdmPerpetualRecord = usdmPerpetualRecord
        self.cacheSnapshot = cacheSnapshot
        self.eventEnvelopes = eventEnvelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.strategyExecutionClientDirectAccessAllowed = strategyExecutionClientDirectAccessAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamEnvironmentConfigAnchor = "TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG"
    public static let requiredRequirements = ReleaseV030DataEngineRuntimeRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V030-03-DATAENGINE-RUNTIME-REHEARSAL-FLOW",
        "V030-03-SPOT-REHEARSAL-PRODUCT-IDENTITY",
        "V030-03-USDM-PERP-REHEARSAL-PRODUCT-IDENTITY",
        "V030-03-TRACEABLE-DATAENGINE-REHEARSAL-EVIDENCE",
        "V030-03-NO-PRODUCTION-ENDPOINT-DEPENDENCY",
        "TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030DataEngineRuntimeRehearsalFlow 把 Spot / Perp public market data 统一成 GH-659 evidence。
public struct ReleaseV030DataEngineRuntimeRehearsalFlow: Sendable {
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_704_068_000),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordedAtStride",
                expected: "positive",
                actual: "\(recordedAtStride)"
            )
        }
        if let sourceID {
            self.sourceID = sourceID
        } else {
            self.sourceID = try FoundationTargetID("gh-659-dataengine-rehearsal-source")
        }
        if let streamID {
            self.streamID = streamID
        } else {
            self.streamID = try MessageBusJournalStreamID("dataengine.release-v0.3.0.rehearsal-market")
        }
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public func run(
        mode: ReleaseV030DataEngineRehearsalMode = .dryRun,
        upstreamEnvironmentConfigAnchor: String = ReleaseV030DataEngineRuntimeRehearsalEvidence.requiredUpstreamEnvironmentConfigAnchor,
        spotEvents: [BinanceSpotProductAwareMarketDataEvent],
        usdmPerpetualEvents: [BinanceUSDMPerpetualProductAwareMarketDataEvent]
    ) throws -> ReleaseV030DataEngineRuntimeRehearsalEvidence {
        guard upstreamEnvironmentConfigAnchor == ReleaseV030DataEngineRuntimeRehearsalEvidence.requiredUpstreamEnvironmentConfigAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamEnvironmentConfigAnchor",
                expected: ReleaseV030DataEngineRuntimeRehearsalEvidence.requiredUpstreamEnvironmentConfigAnchor,
                actual: upstreamEnvironmentConfigAnchor
            )
        }
        guard let spotInstrument = spotEvents.first?.instrument else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingSpotRehearsalEvent")
        }
        guard let usdmPerpetualInstrument = usdmPerpetualEvents.first?.instrument else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingUSDMPerpetualRehearsalEvent")
        }

        var journal = try MessageBusAppendOnlyJournal()
        var cacheSnapshot = ProductAwareMarketDataCacheSnapshot()
        var eventEnvelopes: [MessageBusJournalEnvelope] = []
        var spotPayloadTypes: [String] = []
        var usdmPerpetualPayloadTypes: [String] = []
        var sequence = 0

        for event in spotEvents {
            try validateSpotEvent(event, expectedInstrument: spotInstrument)
            cacheSnapshot = try cacheSnapshot.applying(event.marketEvent, instrument: event.instrument)
            let payloadType = payloadType(for: event)
            spotPayloadTypes.append(payloadType)
            eventEnvelopes.append(
                try appendEnvelope(
                    journal: &journal,
                    payloadType: payloadType,
                    instrument: event.instrument,
                    sequence: sequence
                )
            )
            sequence += 1
        }

        var usdmPerpetualMarketEventCount = 0
        for event in usdmPerpetualEvents {
            try validateUSDMPerpetualEvent(event, expectedInstrument: usdmPerpetualInstrument)
            if let marketEvent = event.marketEvent {
                cacheSnapshot = try cacheSnapshot.applying(marketEvent, instrument: event.instrument)
                usdmPerpetualMarketEventCount += 1
            }
            let payloadType = payloadType(for: event)
            usdmPerpetualPayloadTypes.append(payloadType)
            eventEnvelopes.append(
                try appendEnvelope(
                    journal: &journal,
                    payloadType: payloadType,
                    instrument: event.instrument,
                    sequence: sequence
                )
            )
            sequence += 1
        }

        let replayedEnvelopes = journal.replay(stream: streamID)
        let spotRecord = try ReleaseV030DataEngineRuntimeRehearsalRecord(
            mode: mode,
            instrument: spotInstrument,
            marketEventCount: spotEvents.count,
            messageBusEnvelopeCount: spotPayloadTypes.count,
            payloadTypes: spotPayloadTypes
        )
        let usdmPerpetualRecord = try ReleaseV030DataEngineRuntimeRehearsalRecord(
            mode: mode,
            instrument: usdmPerpetualInstrument,
            marketEventCount: usdmPerpetualMarketEventCount,
            messageBusEnvelopeCount: usdmPerpetualPayloadTypes.count,
            payloadTypes: usdmPerpetualPayloadTypes
        )

        return try ReleaseV030DataEngineRuntimeRehearsalEvidence(
            upstreamEnvironmentConfigAnchor: upstreamEnvironmentConfigAnchor,
            mode: mode,
            spotRecord: spotRecord,
            usdmPerpetualRecord: usdmPerpetualRecord,
            cacheSnapshot: cacheSnapshot,
            eventEnvelopes: eventEnvelopes,
            replayedEnvelopes: replayedEnvelopes
        )
    }

    private func appendEnvelope(
        journal: inout MessageBusAppendOnlyJournal,
        payloadType: String,
        instrument: InstrumentIdentity,
        sequence: Int
    ) throws -> MessageBusJournalEnvelope {
        try journal.append(
            stream: streamID,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: instrument,
            recordedAt: firstRecordedAt.addingTimeInterval(TimeInterval(sequence) * recordedAtStride)
        )
    }

    private func validateSpotEvent(
        _ event: BinanceSpotProductAwareMarketDataEvent,
        expectedInstrument: InstrumentIdentity
    ) throws {
        guard event.instrument == expectedInstrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "spot.instrument",
                expected: expectedInstrument.rawValue,
                actual: event.instrument.rawValue
            )
        }
        guard event.instrument.venue.rawValue == "binance", event.productType == .spot else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("invalidSpotRehearsalProductIdentity")
        }
    }

    private func validateUSDMPerpetualEvent(
        _ event: BinanceUSDMPerpetualProductAwareMarketDataEvent,
        expectedInstrument: InstrumentIdentity
    ) throws {
        guard event.instrument == expectedInstrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "usdmPerpetual.instrument",
                expected: expectedInstrument.rawValue,
                actual: event.instrument.rawValue
            )
        }
        guard event.instrument.venue.rawValue == "binance", event.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("invalidUSDMPerpetualRehearsalProductIdentity")
        }
    }

    private func payloadType(for event: BinanceSpotProductAwareMarketDataEvent) -> String {
        "dataengine.release-v0.3.0.binance.\(event.productType.rawValue).rehearsal.\(event.marketEvent.symbol.rawValue)"
    }

    private func payloadType(for event: BinanceUSDMPerpetualProductAwareMarketDataEvent) -> String {
        "dataengine.release-v0.3.0.binance.\(event.productType.rawValue).rehearsal.\(event.instrument.symbol.rawValue)"
    }
}

private extension ReleaseV030DataEngineRuntimeRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamEnvironmentConfigAnchor: String,
        mode: ReleaseV030DataEngineRehearsalMode,
        requirements: [ReleaseV030DataEngineRuntimeRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamEnvironmentConfigAnchor",
                upstreamEnvironmentConfigAnchor == requiredUpstreamEnvironmentConfigAnchor,
                requiredUpstreamEnvironmentConfigAnchor,
                upstreamEnvironmentConfigAnchor
            ),
            ("mode", mode == .dryRun, ReleaseV030DataEngineRehearsalMode.dryRun.rawValue, mode.rawValue),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateForbiddenFlags(
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        commandGatewayBypassAllowed: Bool,
        strategyExecutionClientDirectAccessAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("strategyExecutionClientDirectAccessAllowed", strategyExecutionClientDirectAccessAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, isEnabled) in forbiddenFlags where isEnabled {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
