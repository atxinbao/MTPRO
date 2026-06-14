import DomainModel
import Foundation
import MessageBus

/// ReleaseV050DurableLocalRunJournalError 描述 GH-731 本地 run journal 合同错误。
///
/// 错误只覆盖本地 append-only journal、typed envelope replay 和禁用敏感信息落盘；
/// 不表达真实文件系统写入、broker 连接、signed endpoint 或生产订单能力。
public enum ReleaseV050DurableLocalRunJournalError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case emptyJournal
    case nonContiguousSequence(expected: Int, actual: Int)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case checksumMismatch(expected: String, actual: String)
    case forbiddenJournalPayloadFragment(String)
    case rewriteAttemptRejected
    case replayCursorRunIDMismatch(expected: Identifier, actual: Identifier)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.5.0 run journal requires a non-empty runID"
        case .emptyJournal:
            "Release v0.5.0 run journal requires at least one appended event before artifact export"
        case let .nonContiguousSequence(expected, actual):
            "Release v0.5.0 run journal sequence must be contiguous: expected \(expected), actual \(actual)"
        case let .runIDMismatch(expected, actual):
            "Release v0.5.0 run journal runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case let .checksumMismatch(expected, actual):
            "Release v0.5.0 run journal checksum mismatch: expected \(expected), actual \(actual)"
        case let .forbiddenJournalPayloadFragment(fragment):
            "Release v0.5.0 run journal rejected forbidden payload fragment: \(fragment)"
        case .rewriteAttemptRejected:
            "Release v0.5.0 run journal rejects mutable rewrite attempts"
        case let .replayCursorRunIDMismatch(expected, actual):
            "Release v0.5.0 replay cursor runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        }
    }
}

/// ReleaseV050LocalRunJournalPath 固定 GH-731 的本地 run artifact 路径形状。
///
/// 该类型描述 `.local/mtpro/runs/<runID>/...` 合同，不创建目录或追加文件；
/// 本地 artifact 仍不能被解释为 production account truth。
public struct ReleaseV050LocalRunJournalPath: Codable, Equatable, Sendable {
    public static let root = ".local/mtpro/runs"

    public let runID: Identifier
    public let runDirectory: String
    public let eventsJSONLPath: String
    public let projectionJSONPath: String
    public let summaryJSONPath: String

    public init(runID: Identifier) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV050DurableLocalRunJournalError.emptyRunID
        }
        self.runID = runID
        self.runDirectory = "\(Self.root)/\(runID.rawValue)"
        self.eventsJSONLPath = "\(runDirectory)/events.jsonl"
        self.projectionJSONPath = "\(runDirectory)/projection.json"
        self.summaryJSONPath = "\(runDirectory)/summary.json"
    }
}

/// ReleaseV050DurableLocalRunJournalRecord 是 GH-731 的 append-only JSONL record。
///
/// Record 保留 #730 的 `RuntimeEventEnvelope` typed fields，并额外记录 local journal
/// checksum 链。它不存储 secret value、production endpoint、raw broker payload 或
/// mutable rewrite marker。
public struct ReleaseV050DurableLocalRunJournalRecord: Codable, Equatable, Sendable {
    public let journalSequence: Int
    public let journalRecordID: Identifier
    public let envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    public let previousJournalChecksum: String
    public let journalChecksum: String
    public let mutableRewriteAllowed: Bool
    public let productionEndpointLeakageRejected: Bool
    public let secretValueLeakageRejected: Bool

    public var runID: Identifier {
        envelope.runID
    }

    public var eventID: Identifier {
        envelope.eventID
    }

    public var recordHeld: Bool {
        journalSequence > 0
            && envelope.envelopeHeld
            && mutableRewriteAllowed == false
            && productionEndpointLeakageRejected
            && secretValueLeakageRejected
            && journalChecksum == Self.stableChecksum(
                journalSequence: journalSequence,
                journalRecordID: journalRecordID,
                envelope: envelope,
                previousJournalChecksum: previousJournalChecksum
            )
    }

    public init(
        journalSequence: Int,
        journalRecordID: Identifier,
        envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>,
        previousJournalChecksum: String,
        journalChecksum: String? = nil,
        mutableRewriteAllowed: Bool = false,
        productionEndpointLeakageRejected: Bool = true,
        secretValueLeakageRejected: Bool = true
    ) throws {
        guard journalSequence > 0 else {
            throw ReleaseV050DurableLocalRunJournalError.nonContiguousSequence(
                expected: 1,
                actual: journalSequence
            )
        }
        guard envelope.envelopeHeld else {
            throw RuntimeMessageBusError.checksumMismatch(expected: "held runtime envelope", actual: envelope.checksum)
        }
        guard mutableRewriteAllowed == false else {
            throw ReleaseV050DurableLocalRunJournalError.rewriteAttemptRejected
        }
        let resolvedChecksum = journalChecksum ?? Self.stableChecksum(
            journalSequence: journalSequence,
            journalRecordID: journalRecordID,
            envelope: envelope,
            previousJournalChecksum: previousJournalChecksum
        )
        let expectedChecksum = Self.stableChecksum(
            journalSequence: journalSequence,
            journalRecordID: journalRecordID,
            envelope: envelope,
            previousJournalChecksum: previousJournalChecksum
        )
        guard resolvedChecksum == expectedChecksum else {
            throw ReleaseV050DurableLocalRunJournalError.checksumMismatch(
                expected: expectedChecksum,
                actual: resolvedChecksum
            )
        }

        self.journalSequence = journalSequence
        self.journalRecordID = journalRecordID
        self.envelope = envelope
        self.previousJournalChecksum = previousJournalChecksum
        self.journalChecksum = resolvedChecksum
        self.mutableRewriteAllowed = mutableRewriteAllowed
        self.productionEndpointLeakageRejected = productionEndpointLeakageRejected
        self.secretValueLeakageRejected = secretValueLeakageRejected
    }

    public static func stableChecksum(
        journalSequence: Int,
        journalRecordID: Identifier,
        envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>,
        previousJournalChecksum: String
    ) -> String {
        let input = [
            "\(journalSequence)",
            journalRecordID.rawValue,
            envelope.eventID.rawValue,
            envelope.runID.rawValue,
            "\(envelope.sequence)",
            envelope.streamID.rawValue,
            envelope.correlationID.rawValue,
            envelope.causationID?.rawValue ?? "root",
            envelope.sourceModule.rawValue,
            envelope.payloadType.rawValue,
            envelope.checksum,
            previousJournalChecksum,
            String(format: "%.6f", envelope.recordedAt.timeIntervalSince1970)
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
}

/// ReleaseV050RunJournalReplayCursor 固定 GH-731 的 replay cursor 合同。
///
/// Cursor 只按 runID、sequence 和可选上限过滤本地 journal records；它不连接
/// production Event Store，也不从 broker 或 account endpoint 补数。
public struct ReleaseV050RunJournalReplayCursor: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let afterJournalSequence: Int
    public let limit: Int?

    public init(
        runID: Identifier,
        afterJournalSequence: Int = 0,
        limit: Int? = nil
    ) throws {
        guard afterJournalSequence >= 0 else {
            throw ReleaseV050DurableLocalRunJournalError.nonContiguousSequence(
                expected: 0,
                actual: afterJournalSequence
            )
        }
        if let limit {
            guard limit > 0 else {
                throw ReleaseV050DurableLocalRunJournalError.nonContiguousSequence(expected: 1, actual: limit)
            }
        }
        self.runID = runID
        self.afterJournalSequence = afterJournalSequence
        self.limit = limit
    }
}

/// ReleaseV050RunJournalProjection 是 `projection.json` 的 deterministic read-model 形状。
public struct ReleaseV050RunJournalProjection: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let eventCount: Int
    public let streamIDs: [MessageBusJournalStreamID]
    public let payloadTypes: [RuntimeEventPayloadType]
    public let sourceModules: [RuntimeEventSourceModule]
    public let firstEventID: Identifier
    public let latestEventID: Identifier
    public let latestJournalChecksum: String
    public let replayCursor: ReleaseV050RunJournalReplayCursor
    public let dashboardCLIProjectionReady: Bool
}

/// ReleaseV050RunJournalSummary 是 `summary.json` 的 deterministic audit summary。
public struct ReleaseV050RunJournalSummary: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let paths: ReleaseV050LocalRunJournalPath
    public let eventCount: Int
    public let appendOnlyHeld: Bool
    public let replayCursorCanReconstructOneRun: Bool
    public let typedRuntimeEnvelopeFieldsPreserved: Bool
    public let secretValuesWritten: Bool
    public let productionEndpointValuesWritten: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
}

/// ReleaseV050DurableLocalRunJournalArtifact 是 GH-731 的本地 durable artifact 视图。
///
/// Artifact 用字符串承载 `events.jsonl`、`projection.json` 和 `summary.json` 内容，
/// 便于测试和审计稳定复现；本类型不执行真实本地落盘。
public struct ReleaseV050DurableLocalRunJournalArtifact: Codable, Equatable, Sendable {
    public let paths: ReleaseV050LocalRunJournalPath
    public let eventsJSONLLines: [String]
    public let projectionJSON: String
    public let summaryJSON: String
}

/// ReleaseV050DurableLocalRunJournal 是 GH-731 的本地 append-only run journal。
///
/// Journal 只消费 `RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>`，按单一
/// runID 追加 record，并可通过 replay cursor 重建同一 run chain。它不连接
/// production broker，不读取 secret，不连接 endpoint，也不发送真实订单。
public struct ReleaseV050DurableLocalRunJournal: Codable, Equatable, Sendable {
    public static let genesisChecksum = "GH-731-V050-GENESIS"

    public let paths: ReleaseV050LocalRunJournalPath
    public private(set) var records: [ReleaseV050DurableLocalRunJournalRecord]

    public init(
        runID: Identifier,
        records: [ReleaseV050DurableLocalRunJournalRecord] = []
    ) throws {
        self.paths = try ReleaseV050LocalRunJournalPath(runID: runID)
        try Self.validate(records: records, runID: runID)
        self.records = records
    }

    @discardableResult
    public mutating func append(
        envelope: RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>
    ) throws -> ReleaseV050DurableLocalRunJournalRecord {
        guard envelope.runID == paths.runID else {
            throw ReleaseV050DurableLocalRunJournalError.runIDMismatch(
                expected: paths.runID,
                actual: envelope.runID
            )
        }
        let nextSequence = records.count + 1
        let expectedEnvelopeSequence = nextSequence
        guard envelope.sequence == expectedEnvelopeSequence else {
            throw ReleaseV050DurableLocalRunJournalError.nonContiguousSequence(
                expected: expectedEnvelopeSequence,
                actual: envelope.sequence
            )
        }

        let record = try ReleaseV050DurableLocalRunJournalRecord(
            journalSequence: nextSequence,
            journalRecordID: Identifier.constant("gh-731-v050-run-journal-record-\(nextSequence)"),
            envelope: envelope,
            previousJournalChecksum: records.last?.journalChecksum ?? Self.genesisChecksum
        )
        try Self.rejectForbiddenPayloadFragments(in: try Self.payloadAuditString(record.envelope.payload))
        records.append(record)
        return record
    }

    public func replay(
        cursor: ReleaseV050RunJournalReplayCursor
    ) throws -> [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        guard cursor.runID == paths.runID else {
            throw ReleaseV050DurableLocalRunJournalError.replayCursorRunIDMismatch(
                expected: paths.runID,
                actual: cursor.runID
            )
        }
        let filtered = records
            .filter { $0.runID == cursor.runID && $0.journalSequence > cursor.afterJournalSequence }
            .sorted { $0.journalSequence < $1.journalSequence }
        return Array(filtered.prefix(cursor.limit ?? filtered.count)).map(\.envelope)
    }

    public var appendOnlyHeld: Bool {
        (try? Self(runID: paths.runID, records: records))?.records == records
            && records.isEmpty == false
            && records.allSatisfy(\.recordHeld)
    }

    public var latestJournalChecksum: String {
        records.last?.journalChecksum ?? Self.genesisChecksum
    }

    public func projection() throws -> ReleaseV050RunJournalProjection {
        guard let first = records.first, let latest = records.last else {
            throw ReleaseV050DurableLocalRunJournalError.emptyJournal
        }
        let cursor = try ReleaseV050RunJournalReplayCursor(runID: paths.runID)
        let replayed = try replay(cursor: cursor)
        guard replayed == records.map(\.envelope) else {
            throw ReleaseV050DurableLocalRunJournalError.rewriteAttemptRejected
        }
        return ReleaseV050RunJournalProjection(
            runID: paths.runID,
            eventCount: records.count,
            streamIDs: records.map(\.envelope.streamID),
            payloadTypes: records.map(\.envelope.payloadType),
            sourceModules: records.map(\.envelope.sourceModule),
            firstEventID: first.eventID,
            latestEventID: latest.eventID,
            latestJournalChecksum: latest.journalChecksum,
            replayCursor: cursor,
            dashboardCLIProjectionReady: records.last?.envelope.payloadType == .dashboardReadModelEvent
        )
    }

    public func summary() throws -> ReleaseV050RunJournalSummary {
        let cursor = try ReleaseV050RunJournalReplayCursor(runID: paths.runID)
        let replayed = try replay(cursor: cursor)
        return ReleaseV050RunJournalSummary(
            issueID: Identifier.constant("GH-731"),
            upstreamIssueID: Identifier.constant("GH-730"),
            previousIssueID: Identifier.constant("GH-730"),
            downstreamIssueIDs: [
                Identifier.constant("GH-732"),
                Identifier.constant("GH-734"),
                Identifier.constant("GH-735"),
                Identifier.constant("GH-736"),
                Identifier.constant("GH-737"),
                Identifier.constant("GH-739")
            ],
            releaseVersion: "v0.5.0",
            runID: paths.runID,
            paths: paths,
            eventCount: records.count,
            appendOnlyHeld: appendOnlyHeld,
            replayCursorCanReconstructOneRun: replayed == records.map(\.envelope),
            typedRuntimeEnvelopeFieldsPreserved: records.allSatisfy { $0.envelope.envelopeHeld },
            secretValuesWritten: false,
            productionEndpointValuesWritten: false,
            productionTradingEnabledByDefault: false,
            productionSecretAutoReadEnabled: false,
            productionEndpointAutoConnectEnabled: false,
            productionBrokerConnectionEnabled: false,
            productionOrderSubmissionEnabled: false,
            productionCutoverAuthorized: false
        )
    }

    public func artifact() throws -> ReleaseV050DurableLocalRunJournalArtifact {
        let eventsJSONL = try records.map(Self.encodeJSON)
        let projectionJSON = try Self.encodeJSON(projection())
        let summaryJSON = try Self.encodeJSON(summary())
        for record in records {
            try Self.rejectForbiddenPayloadFragments(in: try Self.payloadAuditString(record.envelope.payload))
        }
        return ReleaseV050DurableLocalRunJournalArtifact(
            paths: paths,
            eventsJSONLLines: eventsJSONL,
            projectionJSON: projectionJSON,
            summaryJSON: summaryJSON
        )
    }

    private static func validate(
        records: [ReleaseV050DurableLocalRunJournalRecord],
        runID: Identifier
    ) throws {
        for (index, record) in records.enumerated() {
            let expectedSequence = index + 1
            let expectedPreviousChecksum = index == 0 ? Self.genesisChecksum : records[index - 1].journalChecksum
            guard record.runID == runID else {
                throw ReleaseV050DurableLocalRunJournalError.runIDMismatch(
                    expected: runID,
                    actual: record.runID
                )
            }
            guard record.journalSequence == expectedSequence,
                  record.envelope.sequence == expectedSequence else {
                throw ReleaseV050DurableLocalRunJournalError.nonContiguousSequence(
                    expected: expectedSequence,
                    actual: record.journalSequence
                )
            }
            let expectedCausationID = index == 0 ? nil : records[index - 1].eventID
            guard record.envelope.causationID == expectedCausationID else {
                throw ReleaseV050DurableLocalRunJournalError.rewriteAttemptRejected
            }
            guard record.previousJournalChecksum == expectedPreviousChecksum else {
                throw ReleaseV050DurableLocalRunJournalError.checksumMismatch(
                    expected: expectedPreviousChecksum,
                    actual: record.previousJournalChecksum
                )
            }
            guard record.recordHeld else {
                throw ReleaseV050DurableLocalRunJournalError.rewriteAttemptRejected
            }
            try rejectForbiddenPayloadFragments(in: try payloadAuditString(record.envelope.payload))
        }
    }

    static func encodeJSON<Value: Encodable>(_ value: Value) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }

    static func decodeJSON<Value: Decodable>(_ type: Value.Type, from json: String) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(json.utf8))
    }

    static func payloadAuditString(_ payload: ReleaseV050RuntimeEventPayload) throws -> String {
        try encodeJSON(payload) + "|" + String(reflecting: payload)
    }

    static func rejectForbiddenPayloadFragments(in json: String) throws {
        let normalized = json.lowercased()
        for fragment in forbiddenPayloadFragments where normalized.contains(fragment) {
            throw ReleaseV050DurableLocalRunJournalError.forbiddenJournalPayloadFragment(fragment)
        }
    }

    private static let forbiddenPayloadFragments = [
        "production-secret",
        "secret-value",
        "api-key",
        "api_key",
        "apikey",
        "production-endpoint",
        "listenkey",
        "signature=",
        "hmac<",
        "broker-payload"
    ]
}

/// ReleaseV050DurableLocalRunJournalContract 固定 GH-731 的 validation anchors 和边界。
public struct ReleaseV050DurableLocalRunJournalContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let storageRoot: String
    public let eventFileName: String
    public let projectionFileName: String
    public let summaryFileName: String
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
        issueID.rawValue == "GH-731"
            && upstreamIssueID.rawValue == "GH-730"
            && previousIssueID.rawValue == "GH-730"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-732", "GH-734", "GH-735", "GH-736", "GH-737", "GH-739"]
            && releaseVersion == "v0.5.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && storageRoot == ReleaseV050LocalRunJournalPath.root
            && eventFileName == "events.jsonl"
            && projectionFileName == "projection.json"
            && summaryFileName == "summary.json"
            && productionDefaultsClosed
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-731"),
        upstreamIssueID: Identifier = Identifier.constant("GH-730"),
        previousIssueID: Identifier = Identifier.constant("GH-730"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-732"),
            Identifier.constant("GH-734"),
            Identifier.constant("GH-735"),
            Identifier.constant("GH-736"),
            Identifier.constant("GH-737"),
            Identifier.constant("GH-739")
        ],
        releaseVersion: String = "v0.5.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        storageRoot: String = ReleaseV050LocalRunJournalPath.root,
        eventFileName: String = "events.jsonl",
        projectionFileName: String = "projection.json",
        summaryFileName: String = "summary.json",
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.storageRoot = storageRoot
        self.eventFileName = eventFileName
        self.projectionFileName = projectionFileName
        self.summaryFileName = summaryFileName
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV050DurableLocalRunJournalError.rewriteAttemptRejected
        }
    }

    public static func deterministicFixture() throws -> ReleaseV050DurableLocalRunJournalContract {
        try ReleaseV050DurableLocalRunJournalContract()
    }

    public static func deterministicJournal() async throws -> ReleaseV050DurableLocalRunJournal {
        let envelopes = try await ReleaseV050RuntimeMessageBusContract.deterministicEnvelopes()
        guard let runID = envelopes.first?.runID else {
            throw ReleaseV050DurableLocalRunJournalError.emptyJournal
        }
        var journal = try ReleaseV050DurableLocalRunJournal(runID: runID)
        for envelope in envelopes {
            try journal.append(envelope: envelope)
        }
        return journal
    }

    public static let requiredValidationAnchors = [
        "V050-06-DURABLE-LOCAL-RUN-JOURNAL",
        "V050-06-LOCAL-RUN-STORAGE-SHAPE",
        "V050-06-APPEND-ONLY-REPLAY-CURSOR",
        "V050-06-TYPED-RUNTIME-ENVELOPE-PRESERVATION",
        "V050-06-NO-SECRET-ENDPOINT-LEAKAGE",
        "TVM-RELEASE-V050-DURABLE-LOCAL-RUN-JOURNAL"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH731DurableLocalRunJournalPersistsTypedEnvelopeShapeAndReplaysOneRun",
        "bash checks/verify-v0.5.0-run-journal.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
