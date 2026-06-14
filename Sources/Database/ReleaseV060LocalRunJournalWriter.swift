import Crypto
import DomainModel
import Foundation

/// ReleaseV060LocalRunJournalWriterError 描述 GH-756 本地 run journal writer 的文件系统合同错误。
///
/// 错误只覆盖本地 `.local/mtpro/runs/<runID>/` artifact 写入和 run 状态判断；
/// 不表达 endpoint、secret、broker、OMS production runtime 或真实订单能力。
public enum ReleaseV060LocalRunJournalWriterError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case completedRunRewriteRejected(String)
    case eventLogAlreadyContainsRecords(String)
    case missingArtifact(String)
    case artifactMetadataMismatch(String)
    case checksumMismatch(path: String, expected: String, actual: String)
    case byteCountMismatch(path: String, expected: Int, actual: Int)
    case invalidStatusPayload(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.6.0 local run journal writer requires a non-empty runID"
        case let .completedRunRewriteRejected(path):
            "Release v0.6.0 local run journal writer rejects completed run rewrite at \(path)"
        case let .eventLogAlreadyContainsRecords(path):
            "Release v0.6.0 local run journal writer refuses to overwrite existing JSONL records at \(path)"
        case let .missingArtifact(path):
            "Release v0.6.0 local run journal writer cannot classify completed run without artifact \(path)"
        case let .artifactMetadataMismatch(reason):
            "Release v0.6.0 local run manifest artifact metadata is inconsistent: \(reason)"
        case let .checksumMismatch(path, expected, actual):
            "Release v0.6.0 local run artifact checksum mismatch at \(path), expected \(expected), actual \(actual)"
        case let .byteCountMismatch(path, expected, actual):
            "Release v0.6.0 local run artifact byte count mismatch at \(path), expected \(expected), actual \(actual)"
        case let .invalidStatusPayload(path):
            "Release v0.6.0 local run journal writer cannot decode status payload at \(path)"
        }
    }
}

/// ReleaseV060LocalRunJournalWriterState 是 `_RUN_STATUS.json` 的 run 状态枚举。
///
/// `completed` 只有在 manifest 与所有 required artifacts 存在时才会被 inspect 视为完成；
/// manifest 缺失时，writer 必须把 run 视为 `incomplete`。
public enum ReleaseV060LocalRunJournalWriterState: String, Codable, CaseIterable, Equatable, Sendable {
    case completed
    case failed
    case incomplete
}

/// ReleaseV060LocalRunJournalWriterStatus 是 GH-756 `_RUN_STATUS.json` 的本地状态 shape。
public struct ReleaseV060LocalRunJournalWriterStatus: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let state: ReleaseV060LocalRunJournalWriterState
    public let eventCount: Int
    public let requiredArtifactsPresent: Bool
    public let manifestPresent: Bool
    public let completed: Bool
    public let failureReason: String?
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var statusHeld: Bool {
        issueID.rawValue == "GH-756"
            && eventCount >= 0
            && completed == (state == .completed && requiredArtifactsPresent && manifestPresent)
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-756"),
        runID: Identifier,
        state: ReleaseV060LocalRunJournalWriterState,
        eventCount: Int,
        requiredArtifactsPresent: Bool,
        manifestPresent: Bool,
        failureReason: String? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV060LocalRunJournalWriterError.emptyRunID
        }
        self.issueID = issueID
        self.runID = runID
        self.state = state
        self.eventCount = eventCount
        self.requiredArtifactsPresent = requiredArtifactsPresent
        self.manifestPresent = manifestPresent
        self.completed = state == .completed && requiredArtifactsPresent && manifestPresent
        self.failureReason = failureReason
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard statusHeld else {
            throw ReleaseV060LocalRunJournalWriterError.invalidStatusPayload("_RUN_STATUS.json")
        }
    }
}

/// ReleaseV060LocalRunJournalArtifactMetadata 是 GH-757 `manifest.json` 中的 artifact 审计元数据。
///
/// 元数据只描述本地 artifact path、schemaVersion、sha256、bytes、createdAt 与 required 标记；
/// 它不代表远程签名、生产 attestation、broker payload 或真实订单授权。
public struct ReleaseV060LocalRunJournalArtifactMetadata: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0.6.0.local-run-artifact.v1"

    public let path: String
    public let schemaVersion: String
    public let sha256: String
    public let bytes: Int
    public let createdAt: Date
    public let required: Bool

    public var metadataHeld: Bool {
        path.isEmpty == false
            && schemaVersion == Self.schemaVersion
            && sha256.hasPrefix("sha256:")
            && bytes >= 0
            && required
    }

    public init(
        path: String,
        schemaVersion: String = Self.schemaVersion,
        sha256: String,
        bytes: Int,
        createdAt: Date,
        required: Bool = true
    ) throws {
        self.path = path
        self.schemaVersion = schemaVersion
        self.sha256 = sha256
        self.bytes = bytes
        self.createdAt = createdAt
        self.required = required

        guard metadataHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(path)
        }
    }
}

/// ReleaseV060LocalRunJournalWriterManifest 是 GH-756 `manifest.json` 的本地完成证据。
public struct ReleaseV060LocalRunJournalWriterManifest: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let runDirectoryPath: String
    public let eventFileName: String
    public let projectionFileName: String
    public let summaryFileName: String
    public let statusFileName: String
    public let manifestFileName: String
    public let writeOrder: [String]
    public let artifactMetadataSchemaVersion: String
    public let artifacts: [ReleaseV060LocalRunJournalArtifactMetadata]
    public let eventCount: Int
    public let eventsAppendOnly: Bool
    public let atomicArtifactsWritten: Bool
    public let manifestWrittenLast: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-756"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-755", "GH-731"]
            && releaseVersion == "v0.6.0"
            && eventFileName == "events.jsonl"
            && projectionFileName == "projection.json"
            && summaryFileName == "summary.json"
            && statusFileName == "_RUN_STATUS.json"
            && manifestFileName == "manifest.json"
            && writeOrder == [eventFileName, projectionFileName, summaryFileName, statusFileName, manifestFileName]
            && artifactMetadataSchemaVersion == ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
            && artifacts.map { URL(fileURLWithPath: $0.path).lastPathComponent }
                == [eventFileName, projectionFileName, summaryFileName, statusFileName]
            && artifacts.allSatisfy(\.metadataHeld)
            && eventCount > 0
            && eventsAppendOnly
            && atomicArtifactsWritten
            && manifestWrittenLast
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-756"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-755"), Identifier.constant("GH-731")],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        runDirectoryPath: String,
        eventFileName: String = "events.jsonl",
        projectionFileName: String = "projection.json",
        summaryFileName: String = "summary.json",
        statusFileName: String = "_RUN_STATUS.json",
        manifestFileName: String = "manifest.json",
        artifacts: [ReleaseV060LocalRunJournalArtifactMetadata],
        eventCount: Int,
        eventsAppendOnly: Bool = true,
        atomicArtifactsWritten: Bool = true,
        manifestWrittenLast: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV060LocalRunJournalWriterError.emptyRunID
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.runDirectoryPath = runDirectoryPath
        self.eventFileName = eventFileName
        self.projectionFileName = projectionFileName
        self.summaryFileName = summaryFileName
        self.statusFileName = statusFileName
        self.manifestFileName = manifestFileName
        self.writeOrder = [eventFileName, projectionFileName, summaryFileName, statusFileName, manifestFileName]
        self.artifactMetadataSchemaVersion = ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
        self.artifacts = artifacts
        self.eventCount = eventCount
        self.eventsAppendOnly = eventsAppendOnly
        self.atomicArtifactsWritten = atomicArtifactsWritten
        self.manifestWrittenLast = manifestWrittenLast
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard manifestHeld else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(manifestFileName)
        }
    }
}

/// ReleaseV060LocalRunJournalManifestValidation 是 GH-757 本地 manifest 校验结果。
///
/// Validation 只证明本地 required artifact 存在、bytes 与 sha256 和 manifest 一致；
/// 它不连接 endpoint、不读取 secret、不执行 broker command、不授权 production cutover。
public struct ReleaseV060LocalRunJournalManifestValidation: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let runID: Identifier
    public let artifactMetadataSchemaVersion: String
    public let checkedArtifactCount: Int
    public let artifacts: [ReleaseV060LocalRunJournalArtifactMetadata]
    public let validationPassed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var validationHeld: Bool {
        issueID.rawValue == "GH-757"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-755"]
            && artifactMetadataSchemaVersion == ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion
            && checkedArtifactCount == artifacts.count
            && checkedArtifactCount > 0
            && artifacts.allSatisfy(\.metadataHeld)
            && validationPassed
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-757"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-756"), Identifier.constant("GH-755")],
        runID: Identifier,
        artifactMetadataSchemaVersion: String = ReleaseV060LocalRunJournalArtifactMetadata.schemaVersion,
        artifacts: [ReleaseV060LocalRunJournalArtifactMetadata],
        validationPassed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.runID = runID
        self.artifactMetadataSchemaVersion = artifactMetadataSchemaVersion
        self.checkedArtifactCount = artifacts.count
        self.artifacts = artifacts
        self.validationPassed = validationPassed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard validationHeld else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch("GH-757 validation result")
        }
    }
}

/// ReleaseV060LocalRunJournalWriterResult 汇总一次 completed run 的落盘结果。
public struct ReleaseV060LocalRunJournalWriterResult: Codable, Equatable, Sendable {
    public let runDirectoryPath: String
    public let eventsJSONLPath: String
    public let projectionJSONPath: String
    public let summaryJSONPath: String
    public let statusJSONPath: String
    public let manifestJSONPath: String
    public let status: ReleaseV060LocalRunJournalWriterStatus
    public let manifest: ReleaseV060LocalRunJournalWriterManifest

    public var resultHeld: Bool {
        status.statusHeld
            && status.state == .completed
            && status.completed
            && manifest.manifestHeld
            && manifest.manifestWrittenLast
    }
}

/// ReleaseV060LocalRunJournalWriter 将 GH-731 的 deterministic journal artifact 落到真实本地文件。
///
/// Writer 只写本地 filesystem。它不连接 Binance / production endpoint，不读取 secret，
/// 不调用 broker 或 ExecutionClient，不提交、取消或替换真实订单。
public struct ReleaseV060LocalRunJournalWriter {
    public static let statusFileName = "_RUN_STATUS.json"
    public static let manifestFileName = "manifest.json"

    private let storageRootURL: URL
    private let fileManager: FileManager

    public init(
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true),
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func writeCompletedRun(
        journal: ReleaseV050DurableLocalRunJournal,
        projectionJSON: String? = nil,
        summaryJSON: String? = nil
    ) throws -> ReleaseV060LocalRunJournalWriterResult {
        let runID = journal.paths.runID
        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        guard fileManager.fileExists(atPath: urls.manifestURL.path) == false else {
            throw ReleaseV060LocalRunJournalWriterError.completedRunRewriteRejected(urls.manifestURL.path)
        }
        guard try existingEventByteCount(at: urls.eventsURL) == 0 else {
            throw ReleaseV060LocalRunJournalWriterError.eventLogAlreadyContainsRecords(urls.eventsURL.path)
        }

        let artifact = try journal.artifact()
        try appendEventsJSONL(artifact.eventsJSONLLines, to: urls.eventsURL)
        try writeAtomicString(projectionJSON ?? artifact.projectionJSON, to: urls.projectionURL)
        try writeAtomicString(summaryJSON ?? artifact.summaryJSON, to: urls.summaryURL)

        let status = try ReleaseV060LocalRunJournalWriterStatus(
            runID: runID,
            state: .completed,
            eventCount: artifact.eventsJSONLLines.count,
            requiredArtifactsPresent: true,
            manifestPresent: true
        )
        try writeAtomicJSON(status, to: urls.statusURL)

        let artifacts = try artifactMetadata(
            urls: urls,
            createdAt: Date()
        )
        let manifest = try ReleaseV060LocalRunJournalWriterManifest(
            runID: runID,
            runDirectoryPath: urls.runDirectoryURL.path,
            artifacts: artifacts,
            eventCount: artifact.eventsJSONLLines.count
        )
        try writeAtomicJSON(manifest, to: urls.manifestURL)

        return ReleaseV060LocalRunJournalWriterResult(
            runDirectoryPath: urls.runDirectoryURL.path,
            eventsJSONLPath: urls.eventsURL.path,
            projectionJSONPath: urls.projectionURL.path,
            summaryJSONPath: urls.summaryURL.path,
            statusJSONPath: urls.statusURL.path,
            manifestJSONPath: urls.manifestURL.path,
            status: status,
            manifest: manifest
        )
    }

    @discardableResult
    public func writeFailedRun(
        runID: Identifier,
        reason: String
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        try writeTerminalStatus(runID: runID, state: .failed, reason: reason)
    }

    @discardableResult
    public func writeIncompleteRun(
        runID: Identifier,
        reason: String = "incomplete"
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        try writeTerminalStatus(runID: runID, state: .incomplete, reason: reason)
    }

    public func inspectRun(runID: Identifier) throws -> ReleaseV060LocalRunJournalWriterStatus {
        let urls = artifactURLs(runID: runID)
        let eventsPresent = fileManager.fileExists(atPath: urls.eventsURL.path)
        let projectionPresent = fileManager.fileExists(atPath: urls.projectionURL.path)
        let summaryPresent = fileManager.fileExists(atPath: urls.summaryURL.path)
        let statusPresent = fileManager.fileExists(atPath: urls.statusURL.path)
        let manifestPresent = fileManager.fileExists(atPath: urls.manifestURL.path)
        let requiredArtifactsPresent = eventsPresent
            && projectionPresent
            && summaryPresent
            && statusPresent
            && manifestPresent
        let eventCount = try countEventLines(at: urls.eventsURL)

        guard statusPresent else {
            return try ReleaseV060LocalRunJournalWriterStatus(
                runID: runID,
                state: .incomplete,
                eventCount: eventCount,
                requiredArtifactsPresent: requiredArtifactsPresent,
                manifestPresent: manifestPresent,
                failureReason: "missing _RUN_STATUS.json"
            )
        }

        let persistedStatus = try decodeJSON(ReleaseV060LocalRunJournalWriterStatus.self, from: urls.statusURL)
        if persistedStatus.state == .failed {
            return persistedStatus
        }
        guard requiredArtifactsPresent else {
            return try ReleaseV060LocalRunJournalWriterStatus(
                runID: runID,
                state: .incomplete,
                eventCount: eventCount,
                requiredArtifactsPresent: false,
                manifestPresent: manifestPresent,
                failureReason: "required artifacts incomplete"
            )
        }
        _ = try validateRunManifest(runID: runID)
        return persistedStatus
    }

    public func validateRunManifest(runID: Identifier) throws -> ReleaseV060LocalRunJournalManifestValidation {
        let urls = artifactURLs(runID: runID)
        guard fileManager.fileExists(atPath: urls.manifestURL.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(urls.manifestURL.path)
        }
        let manifest = try decodeJSON(ReleaseV060LocalRunJournalWriterManifest.self, from: urls.manifestURL)
        let requiredFileNames = [
            manifest.eventFileName,
            manifest.projectionFileName,
            manifest.summaryFileName,
            manifest.statusFileName
        ]
        let manifestFileNames = manifest.artifacts.filter(\.required)
            .map { URL(fileURLWithPath: $0.path).lastPathComponent }
        guard manifestFileNames == requiredFileNames else {
            throw ReleaseV060LocalRunJournalWriterError.artifactMetadataMismatch(
                "required artifact order \(manifestFileNames.joined(separator: ","))"
            )
        }
        for artifact in manifest.artifacts where artifact.required {
            try validateArtifactMetadata(artifact)
        }
        return try ReleaseV060LocalRunJournalManifestValidation(
            runID: runID,
            artifacts: manifest.artifacts
        )
    }

    private func writeTerminalStatus(
        runID: Identifier,
        state: ReleaseV060LocalRunJournalWriterState,
        reason: String
    ) throws -> ReleaseV060LocalRunJournalWriterStatus {
        let urls = artifactURLs(runID: runID)
        try ensureWritableRunDirectory(urls.runDirectoryURL)
        let status = try ReleaseV060LocalRunJournalWriterStatus(
            runID: runID,
            state: state,
            eventCount: try countEventLines(at: urls.eventsURL),
            requiredArtifactsPresent: false,
            manifestPresent: false,
            failureReason: reason
        )
        try writeAtomicJSON(status, to: urls.statusURL)
        return status
    }

    private func ensureWritableRunDirectory(_ url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func appendEventsJSONL(_ lines: [String], to url: URL) throws {
        if fileManager.fileExists(atPath: url.path) == false {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer {
            try? handle.close()
        }
        try handle.seekToEnd()
        for line in lines {
            try handle.write(contentsOf: Data((line + "\n").utf8))
        }
    }

    private func writeAtomicJSON<Value: Encodable>(_ value: Value, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private func writeAtomicString(_ value: String, to url: URL) throws {
        try Data(value.utf8).write(to: url, options: .atomic)
    }

    private func artifactMetadata(
        urls: ArtifactURLs,
        createdAt: Date
    ) throws -> [ReleaseV060LocalRunJournalArtifactMetadata] {
        try [
            metadata(for: urls.eventsURL, createdAt: createdAt),
            metadata(for: urls.projectionURL, createdAt: createdAt),
            metadata(for: urls.summaryURL, createdAt: createdAt),
            metadata(for: urls.statusURL, createdAt: createdAt)
        ]
    }

    private func metadata(
        for url: URL,
        createdAt: Date
    ) throws -> ReleaseV060LocalRunJournalArtifactMetadata {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(url.path)
        }
        let data = try Data(contentsOf: url)
        return try ReleaseV060LocalRunJournalArtifactMetadata(
            path: url.path,
            sha256: Self.sha256Hex(data),
            bytes: data.count,
            createdAt: createdAt,
            required: true
        )
    }

    private func validateArtifactMetadata(
        _ artifact: ReleaseV060LocalRunJournalArtifactMetadata
    ) throws {
        guard fileManager.fileExists(atPath: artifact.path) else {
            throw ReleaseV060LocalRunJournalWriterError.missingArtifact(artifact.path)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: artifact.path))
        guard data.count == artifact.bytes else {
            throw ReleaseV060LocalRunJournalWriterError.byteCountMismatch(
                path: artifact.path,
                expected: artifact.bytes,
                actual: data.count
            )
        }
        let actualChecksum = Self.sha256Hex(data)
        guard actualChecksum == artifact.sha256 else {
            throw ReleaseV060LocalRunJournalWriterError.checksumMismatch(
                path: artifact.path,
                expected: artifact.sha256,
                actual: actualChecksum
            )
        }
    }

    public static func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    private func decodeJSON<Value: Decodable>(_ type: Value.Type, from url: URL) throws -> Value {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV060LocalRunJournalWriterError.invalidStatusPayload(url.path)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: url))
    }

    private func existingEventByteCount(at url: URL) throws -> UInt64 {
        guard fileManager.fileExists(atPath: url.path) else {
            return 0
        }
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? UInt64 ?? 0
    }

    private func countEventLines(at url: URL) throws -> Int {
        guard fileManager.fileExists(atPath: url.path) else {
            return 0
        }
        let contents = try String(contentsOf: url, encoding: .utf8)
        return contents.split(separator: "\n", omittingEmptySubsequences: true).count
    }

    private func artifactURLs(runID: Identifier) -> ArtifactURLs {
        let runDirectoryURL = storageRootURL.appendingPathComponent(runID.rawValue, isDirectory: true)
        return ArtifactURLs(
            runDirectoryURL: runDirectoryURL,
            eventsURL: runDirectoryURL.appendingPathComponent("events.jsonl"),
            projectionURL: runDirectoryURL.appendingPathComponent("projection.json"),
            summaryURL: runDirectoryURL.appendingPathComponent("summary.json"),
            statusURL: runDirectoryURL.appendingPathComponent(Self.statusFileName),
            manifestURL: runDirectoryURL.appendingPathComponent(Self.manifestFileName)
        )
    }

    private struct ArtifactURLs {
        let runDirectoryURL: URL
        let eventsURL: URL
        let projectionURL: URL
        let summaryURL: URL
        let statusURL: URL
        let manifestURL: URL
    }
}
