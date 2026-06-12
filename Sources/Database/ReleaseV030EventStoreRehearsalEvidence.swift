import DomainModel
import Foundation
import MessageBus

/// ReleaseV030EventStoreRehearsalStage 固定 GH-664 需要审计的 rehearsal causality 阶段。
///
/// Stage 只表达本地 evidence chain 的阶段标签，不代表 runtime object、broker event、
/// production Event Store schema 或 Dashboard command payload。
public enum ReleaseV030EventStoreRehearsalStage:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case strategy
    case risk
    case execution
    case oms
    case adapter
    case portfolio
}

/// ReleaseV030EventStoreRehearsalRequirement 固定 GH-664 的验收要求。
public enum ReleaseV030EventStoreRehearsalRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamAdapterRehearsalRequired = "upstream GH-663 adapter rehearsal evidence required"
    case appendOnlyRecordsRequired = "append-only records required"
    case correlationCausationRequired = "correlation and causation links required"
    case replayReconstructsState = "replay reconstructs key rehearsal state"
    case strategyRiskExecutionOMSPortfolioChainRequired = "strategy -> risk -> execution -> OMS -> portfolio chain required"
    case noProductionEventStoreSideEffect = "no production Event Store side effect"
}

/// ReleaseV030EventStoreRehearsalForbiddenCapability 枚举 GH-664 必须保持关闭的能力。
public enum ReleaseV030EventStoreRehearsalForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case productionEventStoreRuntime = "production Event Store runtime"
    case rawBrokerPayloadStored = "raw broker payload stored"
    case rawDatabaseSchemaExposedToDashboard = "raw database schema exposed to Dashboard"
    case brokerGatewayAccess = "broker gateway access"
    case dashboardCommandSurface = "Dashboard command surface"
    case commandGatewayBypass = "CommandGateway bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case eventStoreBypass = "Event Store bypass"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030EventStoreRehearsalRecord 是 GH-664 的 append-only event-store record。
///
/// checksum 是本地 deterministic replay 校验，不是安全签名，也不用于授权交易。
public struct ReleaseV030EventStoreRehearsalRecord: Codable, Equatable, Sendable {
    public let sequence: Int
    public let eventID: Identifier
    public let correlationID: Identifier
    public let causationID: Identifier?
    public let stage: ReleaseV030EventStoreRehearsalStage
    public let sourceIssueID: Identifier
    public let sourceEvidenceAnchor: String
    public let stream: MessageBusJournalStreamID
    public let sourceID: FoundationTargetID
    public let payloadType: String
    public let instrumentID: InstrumentIdentity
    public let strategyID: Identifier
    public let previousChecksum: String
    public let checksum: String
    public let recordedAt: Date
    public let rawPayloadStored: Bool
    public let productionEventStoreTouched: Bool
    public let productionOrderSubmitted: Bool

    public init(
        sequence: Int,
        eventID: Identifier,
        correlationID: Identifier,
        causationID: Identifier?,
        stage: ReleaseV030EventStoreRehearsalStage,
        sourceIssueID: Identifier,
        sourceEvidenceAnchor: String,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        instrumentID: InstrumentIdentity,
        strategyID: Identifier,
        previousChecksum: String,
        checksum: String? = nil,
        recordedAt: Date,
        rawPayloadStored: Bool = false,
        productionEventStoreTouched: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        let normalizedPayloadType = try FoundationTargetID(
            payloadType,
            field: "releaseV030EventStore.payloadType"
        ).rawValue
        guard sourceEvidenceAnchor.hasPrefix("TVM-RELEASE-V030-") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030EventStore.sourceEvidenceAnchor",
                expected: "TVM-RELEASE-V030-* anchor",
                actual: sourceEvidenceAnchor
            )
        }
        try Self.forbid(rawPayloadStored, "rawPayloadStored")
        try Self.forbid(productionEventStoreTouched, "productionEventStoreTouched")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")

        let resolvedChecksum = checksum ?? Self.stableChecksum(
            sequence: sequence,
            eventID: eventID,
            correlationID: correlationID,
            causationID: causationID,
            stage: stage,
            sourceIssueID: sourceIssueID,
            sourceEvidenceAnchor: sourceEvidenceAnchor,
            payloadType: normalizedPayloadType,
            instrumentID: instrumentID,
            strategyID: strategyID,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        )
        guard resolvedChecksum == Self.stableChecksum(
            sequence: sequence,
            eventID: eventID,
            correlationID: correlationID,
            causationID: causationID,
            stage: stage,
            sourceIssueID: sourceIssueID,
            sourceEvidenceAnchor: sourceEvidenceAnchor,
            payloadType: normalizedPayloadType,
            instrumentID: instrumentID,
            strategyID: strategyID,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030EventStore.checksum",
                expected: "stable deterministic checksum",
                actual: resolvedChecksum
            )
        }

        self.sequence = sequence
        self.eventID = eventID
        self.correlationID = correlationID
        self.causationID = causationID
        self.stage = stage
        self.sourceIssueID = sourceIssueID
        self.sourceEvidenceAnchor = sourceEvidenceAnchor
        self.stream = stream
        self.sourceID = sourceID
        self.payloadType = normalizedPayloadType
        self.instrumentID = instrumentID
        self.strategyID = strategyID
        self.previousChecksum = previousChecksum
        self.checksum = resolvedChecksum
        self.recordedAt = recordedAt
        self.rawPayloadStored = rawPayloadStored
        self.productionEventStoreTouched = productionEventStoreTouched
        self.productionOrderSubmitted = productionOrderSubmitted
    }

    public var recordHeld: Bool {
        sequence > 0
            && sourceEvidenceAnchor.hasPrefix("TVM-RELEASE-V030-")
            && rawPayloadStored == false
            && productionEventStoreTouched == false
            && productionOrderSubmitted == false
            && checksum == Self.stableChecksum(
                sequence: sequence,
                eventID: eventID,
                correlationID: correlationID,
                causationID: causationID,
                stage: stage,
                sourceIssueID: sourceIssueID,
                sourceEvidenceAnchor: sourceEvidenceAnchor,
                payloadType: payloadType,
                instrumentID: instrumentID,
                strategyID: strategyID,
                previousChecksum: previousChecksum,
                recordedAt: recordedAt
            )
    }

    public static func stableChecksum(
        sequence: Int,
        eventID: Identifier,
        correlationID: Identifier,
        causationID: Identifier?,
        stage: ReleaseV030EventStoreRehearsalStage,
        sourceIssueID: Identifier,
        sourceEvidenceAnchor: String,
        payloadType: String,
        instrumentID: InstrumentIdentity,
        strategyID: Identifier,
        previousChecksum: String,
        recordedAt: Date
    ) -> String {
        let input = [
            "\(sequence)",
            eventID.rawValue,
            correlationID.rawValue,
            causationID?.rawValue ?? "root",
            stage.rawValue,
            sourceIssueID.rawValue,
            sourceEvidenceAnchor,
            payloadType,
            instrumentID.rawValue,
            strategyID.rawValue,
            previousChecksum,
            String(format: "%.6f", recordedAt.timeIntervalSince1970)
        ].joined(separator: "|")
        return "fnv1a64:\(fnv1a64Hex(input))"
    }

    private static func fnv1a64Hex(_ input: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030EventStore.record.\(field)")
        }
    }
}

/// ReleaseV030EventStoreRehearsalStore 是 GH-664 的本地 append-only store。
public struct ReleaseV030EventStoreRehearsalStore: Codable, Equatable, Sendable {
    public static let genesisChecksum = "GH-664-GENESIS"
    public private(set) var records: [ReleaseV030EventStoreRehearsalRecord]

    public init(records: [ReleaseV030EventStoreRehearsalRecord] = []) throws {
        for (index, record) in records.enumerated() {
            let previous = index == 0 ? Self.genesisChecksum : records[index - 1].checksum
            guard record.sequence == index + 1,
                  record.previousChecksum == previous,
                  record.recordHeld else {
                throw CoreError.invalidSequenceRange
            }
            if index > 0 {
                guard record.causationID == records[index - 1].eventID else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV030EventStore.causationID",
                        expected: records[index - 1].eventID.rawValue,
                        actual: record.causationID?.rawValue ?? "nil"
                    )
                }
            }
        }
        self.records = records
    }

    @discardableResult
    public mutating func append(
        stage: ReleaseV030EventStoreRehearsalStage,
        sourceIssueID: Identifier,
        sourceEvidenceAnchor: String,
        payloadType: String,
        instrumentID: InstrumentIdentity,
        strategyID: Identifier,
        recordedAt: Date
    ) throws -> ReleaseV030EventStoreRehearsalRecord {
        let nextSequence = records.count + 1
        let eventID = Identifier.constant("gh-664-\(nextSequence)-\(stage.rawValue)-event")
        let record = try ReleaseV030EventStoreRehearsalRecord(
            sequence: nextSequence,
            eventID: eventID,
            correlationID: Self.requiredCorrelationID,
            causationID: records.last?.eventID,
            stage: stage,
            sourceIssueID: sourceIssueID,
            sourceEvidenceAnchor: sourceEvidenceAnchor,
            stream: try Self.requiredStreamID(),
            sourceID: try Self.requiredSourceID(),
            payloadType: payloadType,
            instrumentID: instrumentID,
            strategyID: strategyID,
            previousChecksum: records.last?.checksum ?? Self.genesisChecksum,
            recordedAt: recordedAt
        )
        records.append(record)
        return record
    }

    public func replay(correlationID: Identifier = Self.requiredCorrelationID) -> [ReleaseV030EventStoreRehearsalRecord] {
        records.filter { $0.correlationID == correlationID }
    }

    public var storeHeld: Bool {
        (try? Self(records: records))?.records == records
            && records.isEmpty == false
            && records.allSatisfy(\.recordHeld)
    }

    public var latestChecksum: String {
        records.last?.checksum ?? Self.genesisChecksum
    }

    public static let requiredCorrelationID = Identifier.constant("gh-664-rehearsal-run-correlation")
    public static func requiredStreamID() throws -> MessageBusJournalStreamID {
        try MessageBusJournalStreamID("database.release-v0.3.0.event-store-rehearsal")
    }

    public static func requiredSourceID() throws -> FoundationTargetID {
        try FoundationTargetID("gh-664-event-store-rehearsal-source")
    }
}

/// ReleaseV030EventStoreRehearsalReplayState 是 replay 后重建的关键 rehearsal state。
public struct ReleaseV030EventStoreRehearsalReplayState: Codable, Equatable, Sendable {
    public let correlationID: Identifier
    public let eventCount: Int
    public let stageTrail: [ReleaseV030EventStoreRehearsalStage]
    public let sourceIssueTrail: [Identifier]
    public let finalStage: ReleaseV030EventStoreRehearsalStage
    public let latestChecksum: String
    public let reconstructsStrategyRiskExecutionOMSPortfolio: Bool
    public let correlationCausationHeld: Bool

    public init(records: [ReleaseV030EventStoreRehearsalRecord]) throws {
        guard records.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030EventStore.replayRecords",
                expected: "non-empty replay records",
                actual: "empty"
            )
        }
        let correlationID = records[0].correlationID
        let stages = records.map(\.stage)
        let causationHeld = records.enumerated().allSatisfy { index, record in
            index == 0
                ? record.causationID == nil
                : record.causationID == records[index - 1].eventID
        }
        let requiredTrail: [ReleaseV030EventStoreRehearsalStage] = [
            .strategy, .risk, .execution, .oms, .adapter, .portfolio
        ]
        guard Set(records.map(\.correlationID)) == Set([correlationID]),
              stages == requiredTrail,
              causationHeld,
              let latestChecksum = records.last?.checksum else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030EventStore.replayState",
                expected: "single correlation and strategy-risk-execution-OMS-adapter-portfolio trail",
                actual: stages.map(\.rawValue).joined(separator: "->")
            )
        }

        self.correlationID = correlationID
        self.eventCount = records.count
        self.stageTrail = stages
        self.sourceIssueTrail = records.map(\.sourceIssueID)
        self.finalStage = records.last?.stage ?? .strategy
        self.latestChecksum = latestChecksum
        self.reconstructsStrategyRiskExecutionOMSPortfolio = stages == requiredTrail
        self.correlationCausationHeld = causationHeld
    }

    public var replayStateHeld: Bool {
        eventCount == 6
            && finalStage == .portfolio
            && reconstructsStrategyRiskExecutionOMSPortfolio
            && correlationCausationHeld
            && sourceIssueTrail.map(\.rawValue) == ["GH-660", "GH-661", "GH-662", "GH-662", "GH-663", "GH-664"]
    }
}

/// ReleaseV030EventStoreRehearsalEvidence 汇总 GH-664 的 Event Store / replay rehearsal evidence。
public struct ReleaseV030EventStoreRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamAdapterRehearsalAnchor: String
    public let records: [ReleaseV030EventStoreRehearsalRecord]
    public let replayedRecords: [ReleaseV030EventStoreRehearsalRecord]
    public let replayState: ReleaseV030EventStoreRehearsalReplayState
    public let requirements: [ReleaseV030EventStoreRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030EventStoreRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let appendOnlyRecordsHeld: Bool
    public let correlationCausationHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let productionEventStoreRuntimeEnabled: Bool
    public let rawBrokerPayloadStored: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool
    public let dashboardCommandSurfaceExposed: Bool
    public let commandGatewayBypassAllowed: Bool
    public let riskEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let eventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-664"
            && upstreamIssueID.rawValue == "GH-663"
            && downstreamIssueID.rawValue == "GH-665"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamAdapterRehearsalAnchor == Self.requiredUpstreamAdapterRehearsalAnchor
            && records == replayedRecords
            && replayState.replayStateHeld
            && appendOnlyRecordsHeld
            && correlationCausationHeld
            && boundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && productionEventStoreRuntimeEnabled == false
            && rawBrokerPayloadStored == false
            && rawDatabaseSchemaExposedToDashboard == false
            && dashboardCommandSurfaceExposed == false
            && commandGatewayBypassAllowed == false
            && riskEngineBypassAllowed == false
            && omsBypassAllowed == false
            && eventStoreBypassAllowed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-664-release-v0.3.0-event-store-rehearsal-evidence"),
        issueID: Identifier = Identifier.constant("GH-664"),
        upstreamIssueID: Identifier = Identifier.constant("GH-663"),
        downstreamIssueID: Identifier = Identifier.constant("GH-665"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamAdapterRehearsalAnchor: String = Self.requiredUpstreamAdapterRehearsalAnchor,
        records: [ReleaseV030EventStoreRehearsalRecord],
        replayedRecords: [ReleaseV030EventStoreRehearsalRecord],
        replayState: ReleaseV030EventStoreRehearsalReplayState,
        requirements: [ReleaseV030EventStoreRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030EventStoreRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        appendOnlyRecordsHeld: Bool = true,
        correlationCausationHeld: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionEventStoreRuntimeEnabled: Bool = false,
        rawBrokerPayloadStored: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false,
        dashboardCommandSurfaceExposed: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        riskEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamAdapterRehearsalAnchor: upstreamAdapterRehearsalAnchor,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            appendOnlyRecordsHeld: appendOnlyRecordsHeld,
            correlationCausationHeld: correlationCausationHeld,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            productionEventStoreRuntimeEnabled: productionEventStoreRuntimeEnabled,
            rawBrokerPayloadStored: rawBrokerPayloadStored,
            rawDatabaseSchemaExposedToDashboard: rawDatabaseSchemaExposedToDashboard,
            dashboardCommandSurfaceExposed: dashboardCommandSurfaceExposed,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            riskEngineBypassAllowed: riskEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            eventStoreBypassAllowed: eventStoreBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamAdapterRehearsalAnchor = upstreamAdapterRehearsalAnchor
        self.records = records
        self.replayedRecords = replayedRecords
        self.replayState = replayState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.appendOnlyRecordsHeld = appendOnlyRecordsHeld
        self.correlationCausationHeld = correlationCausationHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionEventStoreRuntimeEnabled = productionEventStoreRuntimeEnabled
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
        self.dashboardCommandSurfaceExposed = dashboardCommandSurfaceExposed
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.riskEngineBypassAllowed = riskEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamAdapterRehearsalAnchor =
        "TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL"
    public static let requiredRequirements = ReleaseV030EventStoreRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030EventStoreRehearsalForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V030-08-EVENT-STORE-REHEARSAL-EVIDENCE",
        "V030-08-APPEND-ONLY-REHEARSAL-EVENTS",
        "V030-08-CORRELATION-CAUSATION-LINKS",
        "V030-08-REPLAY-RECONSTRUCTS-KEY-STATE",
        "V030-08-STRATEGY-RISK-EXECUTION-OMS-PORTFOLIO-CHAIN",
        "TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE"
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH664EventStoreReplayReconstructsRehearsalCausalityChain",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030EventStoreRehearsal 生成 GH-664 deterministic Event Store / replay evidence。
public enum ReleaseV030EventStoreRehearsal {
    public static func deterministicEvidence() throws -> ReleaseV030EventStoreRehearsalEvidence {
        var store = try ReleaseV030EventStoreRehearsalStore()
        let records = try deterministicRecords(store: &store)
        let replayed = store.replay()
        let replayState = try ReleaseV030EventStoreRehearsalReplayState(records: replayed)
        return try ReleaseV030EventStoreRehearsalEvidence(
            records: records,
            replayedRecords: replayed,
            replayState: replayState,
            appendOnlyRecordsHeld: store.storeHeld,
            correlationCausationHeld: replayState.correlationCausationHeld
        )
    }

    public static func outOfOrderAppendRejected() throws -> Bool {
        let stream = try MessageBusJournalStreamID("database.release-v0.3.0.event-store-rehearsal")
        let source = try FoundationTargetID("gh-664-event-store-rehearsal-source")
        let btc = InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant("BTCUSDT"))
        let invalid = try ReleaseV030EventStoreRehearsalRecord(
            sequence: 2,
            eventID: Identifier.constant("gh-664-out-of-order"),
            correlationID: ReleaseV030EventStoreRehearsalStore.requiredCorrelationID,
            causationID: nil,
            stage: .strategy,
            sourceIssueID: Identifier.constant("GH-660"),
            sourceEvidenceAnchor: "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW",
            stream: stream,
            sourceID: source,
            payloadType: "database.release-v0.3.0.strategy.intent",
            instrumentID: btc,
            strategyID: Identifier.constant("ema"),
            previousChecksum: ReleaseV030EventStoreRehearsalStore.genesisChecksum,
            recordedAt: Date(timeIntervalSince1970: 1_704_068_500)
        )
        do {
            _ = try ReleaseV030EventStoreRehearsalStore(records: [invalid])
            return false
        } catch CoreError.invalidSequenceRange {
            return true
        } catch {
            throw error
        }
    }

    private static func deterministicRecords(
        store: inout ReleaseV030EventStoreRehearsalStore
    ) throws -> [ReleaseV030EventStoreRehearsalRecord] {
        let btc = InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant("BTCUSDT"))
        let strategyID = Identifier.constant("ema")
        let recordedAt = Date(timeIntervalSince1970: 1_704_068_500)
        let specs: [(ReleaseV030EventStoreRehearsalStage, String, String, String)] = [
            (.strategy, "GH-660", "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW", "strategy.intent"),
            (.risk, "GH-661", "TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE", "risk.allow"),
            (.execution, "GH-662", "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE", "execution.intent"),
            (.oms, "GH-662", "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE", "oms.submitted"),
            (.adapter, "GH-663", "TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL", "adapter.testnet-ack"),
            (.portfolio, "GH-664", "TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE", "portfolio.replay-input")
        ]
        var records: [ReleaseV030EventStoreRehearsalRecord] = []
        for (index, spec) in specs.enumerated() {
            records.append(
                try store.append(
                    stage: spec.0,
                    sourceIssueID: Identifier.constant(spec.1),
                    sourceEvidenceAnchor: spec.2,
                    payloadType: "database.release-v0.3.0.\(spec.3)",
                    instrumentID: btc,
                    strategyID: strategyID,
                    recordedAt: recordedAt.addingTimeInterval(TimeInterval(index))
                )
            )
        }
        return records
    }
}

private extension ReleaseV030EventStoreRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamAdapterRehearsalAnchor: String,
        requirements: [ReleaseV030EventStoreRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030EventStoreRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamAdapterRehearsalAnchor",
                upstreamAdapterRehearsalAnchor == requiredUpstreamAdapterRehearsalAnchor,
                requiredUpstreamAdapterRehearsalAnchor,
                upstreamAdapterRehearsalAnchor
            ),
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
        appendOnlyRecordsHeld: Bool,
        correlationCausationHeld: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        productionEventStoreRuntimeEnabled: Bool,
        rawBrokerPayloadStored: Bool,
        rawDatabaseSchemaExposedToDashboard: Bool,
        dashboardCommandSurfaceExposed: Bool,
        commandGatewayBypassAllowed: Bool,
        riskEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        eventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard appendOnlyRecordsHeld, correlationCausationHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030EventStore.auditInvariants",
                expected: "append-only records and correlation/causation held",
                actual: "\(appendOnlyRecordsHeld):\(correlationCausationHeld)"
            )
        }
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("productionEventStoreRuntimeEnabled", productionEventStoreRuntimeEnabled),
            ("rawBrokerPayloadStored", rawBrokerPayloadStored),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard),
            ("dashboardCommandSurfaceExposed", dashboardCommandSurfaceExposed),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("riskEngineBypassAllowed", riskEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030EventStore.evidence.\(field)")
        }
    }
}
