import DomainModel
import Foundation
import MessageBus

/// ReleaseV040EventStoreRunJournalRequirement 固定 GH-703 的 run journal 验收要求。
public enum ReleaseV040EventStoreRunJournalRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamOMSAndAdapterEvidenceRequired = "upstream GH-700 OMS and GH-701 adapter evidence required"
    case appendOnlyRunRecordsRequired = "append-only run records required"
    case oneRunIDRequired = "one runID required"
    case correlationCausationRequired = "correlation and causation chain required"
    case dashboardCLIProjectionReplayRequired = "Dashboard / CLI projection replay required"
    case noProductionEventStoreRuntime = "no production Event Store runtime"
}

/// ReleaseV040EventStoreRunJournalForbiddenCapability 枚举 GH-703 必须保持关闭的能力。
public enum ReleaseV040EventStoreRunJournalForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointConnection = "production endpoint connection"
    case productionSecretRead = "production secret read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case productionEventStoreRuntime = "production Event Store runtime"
    case mutableEventRewrite = "mutable event rewrite"
    case rawBrokerPayloadStored = "raw broker payload stored"
    case brokerGatewayAccess = "broker gateway access"
    case dashboardCommandSurface = "Dashboard command surface"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV040EventStoreRunJournalRecord 是 GH-703 的 append-only run event record。
///
/// Record 只存储统一 evidence envelope 的审计身份，不保存 raw broker payload、database schema、
/// production secret 或 UI command。checksum 是 deterministic replay 校验，不是交易授权。
public struct ReleaseV040EventStoreRunJournalRecord: Codable, Equatable, Sendable {
    public let sequence: Int
    public let recordID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let module: ReleaseV040UnifiedEvidenceModule
    public let sourceIssueID: Identifier
    public let sourceEvidenceID: Identifier
    public let sourceEnvelopeID: Identifier
    public let sourceEnvelopeSequence: Int
    public let sourceUpstreamEvidenceID: Identifier?
    public let validationAnchor: String
    public let correlationID: Identifier
    public let causationID: Identifier?
    public let stream: MessageBusJournalStreamID
    public let sourceID: FoundationTargetID
    public let payloadType: String
    public let previousChecksum: String
    public let checksum: String
    public let recordedAt: Date
    public let rawPayloadStored: Bool
    public let mutableRewriteAllowed: Bool
    public let productionEventStoreRuntimeTouched: Bool
    public let productionOrderSubmitted: Bool

    public var runID: Identifier { runContext.runID }

    public var recordHeld: Bool {
        sequence > 0
            && runContext.boundaryHeld
            && validationAnchor.hasPrefix("TVM-RELEASE-V040-")
            && sourceIssueID.rawValue.hasPrefix("GH-")
            && rawPayloadStored == false
            && mutableRewriteAllowed == false
            && productionEventStoreRuntimeTouched == false
            && productionOrderSubmitted == false
            && checksum == Self.stableChecksum(
                sequence: sequence,
                recordID: recordID,
                runID: runID,
                module: module,
                sourceIssueID: sourceIssueID,
                sourceEvidenceID: sourceEvidenceID,
                sourceEnvelopeID: sourceEnvelopeID,
                sourceEnvelopeSequence: sourceEnvelopeSequence,
                sourceUpstreamEvidenceID: sourceUpstreamEvidenceID,
                validationAnchor: validationAnchor,
                correlationID: correlationID,
                causationID: causationID,
                payloadType: payloadType,
                previousChecksum: previousChecksum,
                recordedAt: recordedAt
            )
    }

    public init(
        sequence: Int,
        recordID: Identifier,
        sourceEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        causationID: Identifier?,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        previousChecksum: String,
        checksum: String? = nil,
        recordedAt: Date,
        rawPayloadStored: Bool = false,
        mutableRewriteAllowed: Bool = false,
        productionEventStoreRuntimeTouched: Bool = false,
        productionOrderSubmitted: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        guard sourceEnvelope.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040EventStore.sourceEnvelope",
                expected: "held v0.4 unified evidence envelope",
                actual: sourceEnvelope.envelopeID.rawValue
            )
        }
        let normalizedPayloadType = try FoundationTargetID(
            payloadType,
            field: "releaseV040EventStore.payloadType"
        ).rawValue
        try Self.forbid(rawPayloadStored, "rawPayloadStored")
        try Self.forbid(mutableRewriteAllowed, "mutableRewriteAllowed")
        try Self.forbid(productionEventStoreRuntimeTouched, "productionEventStoreRuntimeTouched")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")

        let resolvedChecksum = checksum ?? Self.stableChecksum(
            sequence: sequence,
            recordID: recordID,
            runID: sourceEnvelope.runID,
            module: sourceEnvelope.module,
            sourceIssueID: sourceEnvelope.sourceIssueID,
            sourceEvidenceID: sourceEnvelope.evidenceID,
            sourceEnvelopeID: sourceEnvelope.envelopeID,
            sourceEnvelopeSequence: sourceEnvelope.sequence,
            sourceUpstreamEvidenceID: sourceEnvelope.upstreamEvidenceID,
            validationAnchor: sourceEnvelope.validationAnchor,
            correlationID: sourceEnvelope.correlationID,
            causationID: causationID,
            payloadType: normalizedPayloadType,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        )
        guard resolvedChecksum == Self.stableChecksum(
            sequence: sequence,
            recordID: recordID,
            runID: sourceEnvelope.runID,
            module: sourceEnvelope.module,
            sourceIssueID: sourceEnvelope.sourceIssueID,
            sourceEvidenceID: sourceEnvelope.evidenceID,
            sourceEnvelopeID: sourceEnvelope.envelopeID,
            sourceEnvelopeSequence: sourceEnvelope.sequence,
            sourceUpstreamEvidenceID: sourceEnvelope.upstreamEvidenceID,
            validationAnchor: sourceEnvelope.validationAnchor,
            correlationID: sourceEnvelope.correlationID,
            causationID: causationID,
            payloadType: normalizedPayloadType,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040EventStore.checksum",
                expected: "stable deterministic checksum",
                actual: resolvedChecksum
            )
        }

        self.sequence = sequence
        self.recordID = recordID
        self.runContext = sourceEnvelope.runContext
        self.module = sourceEnvelope.module
        self.sourceIssueID = sourceEnvelope.sourceIssueID
        self.sourceEvidenceID = sourceEnvelope.evidenceID
        self.sourceEnvelopeID = sourceEnvelope.envelopeID
        self.sourceEnvelopeSequence = sourceEnvelope.sequence
        self.sourceUpstreamEvidenceID = sourceEnvelope.upstreamEvidenceID
        self.validationAnchor = sourceEnvelope.validationAnchor
        self.correlationID = sourceEnvelope.correlationID
        self.causationID = causationID
        self.stream = stream
        self.sourceID = sourceID
        self.payloadType = normalizedPayloadType
        self.previousChecksum = previousChecksum
        self.checksum = resolvedChecksum
        self.recordedAt = recordedAt
        self.rawPayloadStored = rawPayloadStored
        self.mutableRewriteAllowed = mutableRewriteAllowed
        self.productionEventStoreRuntimeTouched = productionEventStoreRuntimeTouched
        self.productionOrderSubmitted = productionOrderSubmitted
    }

    public static func stableChecksum(
        sequence: Int,
        recordID: Identifier,
        runID: Identifier,
        module: ReleaseV040UnifiedEvidenceModule,
        sourceIssueID: Identifier,
        sourceEvidenceID: Identifier,
        sourceEnvelopeID: Identifier,
        sourceEnvelopeSequence: Int,
        sourceUpstreamEvidenceID: Identifier?,
        validationAnchor: String,
        correlationID: Identifier,
        causationID: Identifier?,
        payloadType: String,
        previousChecksum: String,
        recordedAt: Date
    ) -> String {
        let input = [
            "\(sequence)",
            recordID.rawValue,
            runID.rawValue,
            module.rawValue,
            sourceIssueID.rawValue,
            sourceEvidenceID.rawValue,
            sourceEnvelopeID.rawValue,
            "\(sourceEnvelopeSequence)",
            sourceUpstreamEvidenceID?.rawValue ?? "root",
            validationAnchor,
            correlationID.rawValue,
            causationID?.rawValue ?? "root",
            payloadType,
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
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040EventStore.record.\(field)")
        }
    }
}

/// ReleaseV040EventStoreRunJournal 是 GH-703 的本地 append-only run journal。
public struct ReleaseV040EventStoreRunJournal: Codable, Equatable, Sendable {
    public static let genesisChecksum = "GH-703-GENESIS"
    public private(set) var records: [ReleaseV040EventStoreRunJournalRecord]

    public init(records: [ReleaseV040EventStoreRunJournalRecord] = []) throws {
        for (index, record) in records.enumerated() {
            let expectedSequence = index + 1
            let expectedPreviousChecksum = index == 0 ? Self.genesisChecksum : records[index - 1].checksum
            let expectedCausationID = index == 0 ? nil : records[index - 1].recordID
            guard record.sequence == expectedSequence,
                  record.previousChecksum == expectedPreviousChecksum,
                  record.causationID == expectedCausationID,
                  record.recordHeld else {
                throw CoreError.invalidSequenceRange
            }
            if index > 0 {
                guard record.runID == records[0].runID else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV040EventStore.runID",
                        expected: records[0].runID.rawValue,
                        actual: record.runID.rawValue
                    )
                }
            }
        }
        self.records = records
    }

    @discardableResult
    public mutating func append(
        sourceEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        payloadType: String,
        recordedAt: Date
    ) throws -> ReleaseV040EventStoreRunJournalRecord {
        if let existingRunID = records.first?.runID {
            guard sourceEnvelope.runID == existingRunID else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040EventStore.runID",
                    expected: existingRunID.rawValue,
                    actual: sourceEnvelope.runID.rawValue
                )
            }
        }
        let nextSequence = records.count + 1
        let record = try ReleaseV040EventStoreRunJournalRecord(
            sequence: nextSequence,
            recordID: Identifier.constant("gh-703-v040-\(nextSequence)-\(sourceEnvelope.module.rawValue.normalizedEvidenceComponent)-event"),
            sourceEnvelope: sourceEnvelope,
            causationID: records.last?.recordID,
            stream: try Self.requiredStreamID(),
            sourceID: try Self.requiredSourceID(),
            payloadType: payloadType,
            previousChecksum: records.last?.checksum ?? Self.genesisChecksum,
            recordedAt: recordedAt
        )
        records.append(record)
        return record
    }

    public func replay(runID: Identifier) -> [ReleaseV040EventStoreRunJournalRecord] {
        records.filter { $0.runID == runID }
    }

    public var appendOnlyHeld: Bool {
        (try? Self(records: records))?.records == records
            && records.isEmpty == false
            && records.allSatisfy(\.recordHeld)
    }

    public var latestChecksum: String {
        records.last?.checksum ?? Self.genesisChecksum
    }

    public static func requiredStreamID() throws -> MessageBusJournalStreamID {
        try MessageBusJournalStreamID("database.release-v0.4.0.event-store-run-journal")
    }

    public static func requiredSourceID() throws -> FoundationTargetID {
        try FoundationTargetID("gh-703-event-store-run-journal-source")
    }
}

/// ReleaseV040EventStoreRunReplayState 是 replay 后可供 audit / Dashboard / CLI projection 使用的状态。
public struct ReleaseV040EventStoreRunReplayState: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let eventCount: Int
    public let moduleTrail: [ReleaseV040UnifiedEvidenceModule]
    public let sourceIssueTrail: [Identifier]
    public let latestChecksum: String
    public let correlationID: Identifier
    public let correlationCausationHeld: Bool
    public let dashboardCLIProjectionReplayReady: Bool

    public init(records: [ReleaseV040EventStoreRunJournalRecord]) throws {
        guard let first = records.first, let latest = records.last else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040EventStore.replayRecords",
                expected: "non-empty replay records",
                actual: "empty"
            )
        }
        let moduleTrail = records.map(\.module)
        let causationHeld = records.enumerated().allSatisfy { index, record in
            index == 0
                ? record.causationID == nil
                : record.causationID == records[index - 1].recordID
        }
        guard Set(records.map(\.runID)) == Set([first.runID]),
              Set(records.map(\.correlationID)) == Set([first.correlationID]),
              moduleTrail == Self.requiredModuleTrail,
              causationHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040EventStore.replayState",
                expected: Self.requiredModuleTrail.map(\.rawValue).joined(separator: "->"),
                actual: moduleTrail.map(\.rawValue).joined(separator: "->")
            )
        }

        self.runID = first.runID
        self.eventCount = records.count
        self.moduleTrail = moduleTrail
        self.sourceIssueTrail = records.map(\.sourceIssueID)
        self.latestChecksum = latest.checksum
        self.correlationID = first.correlationID
        self.correlationCausationHeld = causationHeld
        self.dashboardCLIProjectionReplayReady = moduleTrail.last == .portfolio
    }

    public var replayStateHeld: Bool {
        eventCount == Self.requiredModuleTrail.count
            && moduleTrail == Self.requiredModuleTrail
            && sourceIssueTrail.map(\.rawValue) == ["GH-697", "GH-698", "GH-699", "GH-700", "GH-700", "GH-701", "GH-703"]
            && correlationCausationHeld
            && dashboardCLIProjectionReplayReady
    }

    public static let requiredModuleTrail: [ReleaseV040UnifiedEvidenceModule] = [
        .dataEngine,
        .trader,
        .riskEngine,
        .executionEngine,
        .oms,
        .executionClient,
        .portfolio
    ]
}

/// ReleaseV040EventStoreRunJournalEvidence 汇总 GH-703 Event Store run journal evidence。
public struct ReleaseV040EventStoreRunJournalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let releaseVersion: String
    public let records: [ReleaseV040EventStoreRunJournalRecord]
    public let replayedRecords: [ReleaseV040EventStoreRunJournalRecord]
    public let replayState: ReleaseV040EventStoreRunReplayState
    public let requirements: [ReleaseV040EventStoreRunJournalRequirement]
    public let forbiddenCapabilities: [ReleaseV040EventStoreRunJournalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let appendOnlyHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let productionEventStoreRuntimeEnabled: Bool
    public let mutableEventRewriteAllowed: Bool
    public let rawBrokerPayloadStored: Bool
    public let brokerGatewayTouched: Bool
    public let dashboardCommandSurfaceExposed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-703"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-700", "GH-701"]
            && downstreamIssueID.rawValue == "GH-704"
            && releaseVersion == "v0.4.0"
            && records == replayedRecords
            && replayState.replayStateHeld
            && appendOnlyHeld
            && boundaryHeld
            && requirements == ReleaseV040EventStoreRunJournalRequirement.allCases
            && forbiddenCapabilities == ReleaseV040EventStoreRunJournalForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && productionEventStoreRuntimeEnabled == false
            && mutableEventRewriteAllowed == false
            && rawBrokerPayloadStored == false
            && brokerGatewayTouched == false
            && dashboardCommandSurfaceExposed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-703-v040-eventstore-run-journal"),
        issueID: Identifier = Identifier.constant("GH-703"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-700"), Identifier.constant("GH-701")],
        downstreamIssueID: Identifier = Identifier.constant("GH-704"),
        releaseVersion: String = "v0.4.0",
        records: [ReleaseV040EventStoreRunJournalRecord],
        replayedRecords: [ReleaseV040EventStoreRunJournalRecord],
        replayState: ReleaseV040EventStoreRunReplayState,
        requirements: [ReleaseV040EventStoreRunJournalRequirement] = ReleaseV040EventStoreRunJournalRequirement.allCases,
        forbiddenCapabilities: [ReleaseV040EventStoreRunJournalForbiddenCapability] =
            ReleaseV040EventStoreRunJournalForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        appendOnlyHeld: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionEventStoreRuntimeEnabled: Bool = false,
        mutableEventRewriteAllowed: Bool = false,
        rawBrokerPayloadStored: Bool = false,
        brokerGatewayTouched: Bool = false,
        dashboardCommandSurfaceExposed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        try Self.forbid(productionEventStoreRuntimeEnabled, "productionEventStoreRuntimeEnabled")
        try Self.forbid(mutableEventRewriteAllowed, "mutableEventRewriteAllowed")
        try Self.forbid(rawBrokerPayloadStored, "rawBrokerPayloadStored")
        try Self.forbid(brokerGatewayTouched, "brokerGatewayTouched")
        try Self.forbid(dashboardCommandSurfaceExposed, "dashboardCommandSurfaceExposed")
        try Self.forbid(startsNextMilestone, "startsNextMilestone")

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.records = records
        self.replayedRecords = replayedRecords
        self.replayState = replayState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.appendOnlyHeld = appendOnlyHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionEventStoreRuntimeEnabled = productionEventStoreRuntimeEnabled
        self.mutableEventRewriteAllowed = mutableEventRewriteAllowed
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
        self.brokerGatewayTouched = brokerGatewayTouched
        self.dashboardCommandSurfaceExposed = dashboardCommandSurfaceExposed
        self.startsNextMilestone = startsNextMilestone

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040EventStore.evidenceHeld",
                expected: "held GH-703 evidence",
                actual: "false"
            )
        }
    }

    public static let validationAnchor = "TVM-RELEASE-V040-EVENTSTORE-RUN-JOURNAL"

    public static let requiredValidationAnchors = [
        "V040-10-EVENTSTORE-RUN-JOURNAL",
        "V040-10-APPEND-ONLY-RUN-EVENTS",
        "V040-10-RUNID-CORRELATION-CAUSATION-REPLAY",
        "V040-10-DASHBOARD-CLI-PROJECTION-REPLAY",
        "V040-10-NO-PRODUCTION-EVENTSTORE-CUTOVER",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH703EventStoreRunJournalAppendsAndReplaysOneRunIDChain",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040EventStore.evidence.\(field)")
        }
    }
}

/// ReleaseV040EventStoreRunJournalBuilder 生成 GH-703 deterministic run journal evidence。
public enum ReleaseV040EventStoreRunJournalBuilder {
    public static func deterministicEvidence() throws -> ReleaseV040EventStoreRunJournalEvidence {
        var journal = try ReleaseV040EventStoreRunJournal()
        let records = try deterministicRecords(journal: &journal)
        let replayed = journal.replay(runID: try deterministicRunContext().runID)
        let replayState = try ReleaseV040EventStoreRunReplayState(records: replayed)
        return try ReleaseV040EventStoreRunJournalEvidence(
            records: records,
            replayedRecords: replayed,
            replayState: replayState,
            appendOnlyHeld: journal.appendOnlyHeld
        )
    }

    public static func outOfOrderAppendRejected() throws -> Bool {
        let invalidEnvelope = try deterministicEnvelope(
            runContext: deterministicRunContext(),
            module: .dataEngine,
            sourceIssueID: "GH-697",
            evidenceComponent: "dataengine",
            upstreamEvidenceID: nil,
            sequence: 1
        )
        let invalid = try ReleaseV040EventStoreRunJournalRecord(
            sequence: 2,
            recordID: Identifier.constant("gh-703-out-of-order"),
            sourceEnvelope: invalidEnvelope,
            causationID: nil,
            stream: try ReleaseV040EventStoreRunJournal.requiredStreamID(),
            sourceID: try ReleaseV040EventStoreRunJournal.requiredSourceID(),
            payloadType: "database.release-v0.4.0.eventstore.out-of-order",
            previousChecksum: ReleaseV040EventStoreRunJournal.genesisChecksum,
            recordedAt: Date(timeIntervalSince1970: 1_705_003_000)
        )
        do {
            _ = try ReleaseV040EventStoreRunJournal(records: [invalid])
            return false
        } catch CoreError.invalidSequenceRange {
            return true
        }
    }

    public static func deterministicRecords(
        journal: inout ReleaseV040EventStoreRunJournal
    ) throws -> [ReleaseV040EventStoreRunJournalRecord] {
        let context = try deterministicRunContext()
        let descriptors: [(ReleaseV040UnifiedEvidenceModule, String, String, Identifier?)] = [
            (.dataEngine, "GH-697", "dataengine-market-events", nil),
            (.trader, "GH-698", "trader-strategy-intents", Identifier.constant("gh-703-dataengine-market-events-evidence")),
            (.riskEngine, "GH-699", "riskengine-decisions", Identifier.constant("gh-703-trader-strategy-intents-evidence")),
            (.executionEngine, "GH-700", "executionengine-lifecycle", Identifier.constant("gh-703-riskengine-decisions-evidence")),
            (.oms, "GH-700", "oms-state-replay", Identifier.constant("gh-703-executionengine-lifecycle-evidence")),
            (.executionClient, "GH-701", "executionclient-dryrun-adapter", Identifier.constant("gh-703-oms-state-replay-evidence")),
            (.portfolio, "GH-703", "portfolio-projection-ready", Identifier.constant("gh-703-executionclient-dryrun-adapter-evidence"))
        ]
        var records: [ReleaseV040EventStoreRunJournalRecord] = []
        for (index, descriptor) in descriptors.enumerated() {
            let sequence = index + 1
            let envelope = try deterministicEnvelope(
                runContext: context,
                module: descriptor.0,
                sourceIssueID: descriptor.1,
                evidenceComponent: descriptor.2,
                upstreamEvidenceID: descriptor.3,
                sequence: sequence
            )
            let record = try journal.append(
                sourceEnvelope: envelope,
                payloadType: "database.release-v0.4.0.eventstore.\(descriptor.2)",
                recordedAt: Date(timeIntervalSince1970: 1_705_003_000 + TimeInterval(sequence))
            )
            records.append(record)
        }
        return records
    }

    private static func deterministicRunContext() throws -> ReleaseV040RehearsalRunContext {
        try ReleaseV040RehearsalRunContext(
            runID: Identifier.constant("gh-703-v040-eventstore-run"),
            correlationID: Identifier.constant("gh-703-v040-correlation"),
            causationID: Identifier.constant("gh-701-v040-binance-dryrun-executionclient-adapter")
        )
    }

    private static func deterministicEnvelope(
        runContext: ReleaseV040RehearsalRunContext,
        module: ReleaseV040UnifiedEvidenceModule,
        sourceIssueID: String,
        evidenceComponent: String,
        upstreamEvidenceID: Identifier?,
        sequence: Int
    ) throws -> ReleaseV040UnifiedEvidenceEnvelope {
        try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-703-\(evidenceComponent)-envelope"),
            runContext: runContext,
            module: module,
            sourceIssueID: Identifier.constant(sourceIssueID),
            evidenceID: Identifier.constant("gh-703-\(evidenceComponent)-evidence"),
            upstreamEvidenceID: upstreamEvidenceID,
            validationAnchor: ReleaseV040EventStoreRunJournalEvidence.validationAnchor,
            sequence: sequence
        )
    }
}

private extension String {
    var normalizedEvidenceComponent: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
}
