import Crypto
import DomainModel
import Foundation

// GH-1106 static contract boundary:
// localExecutionArtifactStore=ReleaseV0160LocalExecutionArtifactStore
// appendOnlyArtifactPersistence=true
// checksumManifestWritten=true
// checksumMismatchRejected=true
// replayValidationSupported=true
// redactedExportBundleSupported=true
// submitCancelStatusReconciliationEvidenceSupported=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false
// GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
// TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
// V0161-003-SHARED-REDACTION-POLICY-SOURCE
// V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE
// V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE
// V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE
// V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS
// V0161-003-NO-PRODUCTION-CUTOVER
// GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE
// TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE
// V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS
// V0161-004-SIGNED-QUERY-MARKERS
// V0161-004-PRODUCTION-HOST-MARKERS
// V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS
// V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE

/// ReleaseV0160LocalExecutionArtifactStoreError 描述 GH-1106 本地 artifact store 的 fail-closed 错误。
///
/// 这些错误只覆盖 v0.16.0 Binance Spot Testnet operator beta 的本地 evidence 持久化、
/// checksum manifest、replay validation 和 redacted export。它不读取 secret，不连接 endpoint，
/// 不提交订单，也不授权 production cutover。
public enum ReleaseV0160LocalExecutionArtifactStoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyRunID
    case invalidPayload(String)
    case appendOnlyViolation(String)
    case checksumMismatch(field: String, expected: String, actual: String)
    case missingArtifact(String)
    case forbiddenRawMarker(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case .emptyRunID:
            "Release v0.16.0 local execution artifact store requires a non-empty runID"
        case let .invalidPayload(field):
            "Release v0.16.0 local execution artifact store invalid payload: \(field)"
        case let .appendOnlyViolation(field):
            "Release v0.16.0 local execution artifact store append-only violation: \(field)"
        case let .checksumMismatch(field, expected, actual):
            "Release v0.16.0 local execution artifact store checksum mismatch for \(field): expected \(expected), actual \(actual)"
        case let .missingArtifact(path):
            "Release v0.16.0 local execution artifact store missing artifact: \(path)"
        case let .forbiddenRawMarker(marker):
            "Release v0.16.0 local execution artifact store rejected forbidden raw marker: \(marker)"
        case let .boundaryDrift(field):
            "Release v0.16.0 local execution artifact store boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160LocalExecutionArtifactKind 固定 GH-1106 支持的本地 evidence 类型。
///
/// 类型名覆盖 submit / cancel / status / reconciliation，但仅表示 redacted local artifact；
/// 不代表真实生产交易能力，也不触发 broker command。
public enum ReleaseV0160LocalExecutionArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case status
    case reconciliation

    public var artifactRole: ReleaseV0160OperatorRunArtifactRole {
        switch self {
        case .submit, .cancel:
            .redactedExecutionEvidenceJSON
        case .status:
            .statusSnapshotJSON
        case .reconciliation:
            .reconciliationJSON
        }
    }

    public var operatorAction: ReleaseV0160OperatorRunAction {
        switch self {
        case .submit:
            .recordSubmitObserved
        case .cancel:
            .recordCancelObserved
        case .status:
            .recordStatusObserved
        case .reconciliation:
            .reconcile
        }
    }
}

/// ReleaseV0160LocalExecutionArtifactPayload 是写入本地 store 前的脱敏 evidence payload。
///
/// Payload 只能保存 evidence id、redacted summary 和 redacted reference。它显式拒绝 API key、
/// secret、listenKey、raw order id、broker payload、production endpoint 和 production command。
public struct ReleaseV0160LocalExecutionArtifactPayload: Codable, Equatable, Sendable {
    public let payloadID: Identifier
    public let kind: ReleaseV0160LocalExecutionArtifactKind
    public let evidenceID: Identifier
    public let redactedSummary: String
    public let redactedEvidenceReferences: [String]
    public let observedAt: Date
    public let explicitOperatorConfirmationRequired: Bool
    public let redactedEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        payloadID == Self.deterministicID(kind: kind, evidenceID: evidenceID)
            && evidenceID.rawValue.isEmpty == false
            && redactedSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && redactedEvidenceReferences.isEmpty == false
            && explicitOperatorConfirmationRequired
            && redactedEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && Self.redactionPolicy.policyHeld
            && Self.forbiddenRawMarkers(in: redactedSummary).isEmpty
            && redactedEvidenceReferences.allSatisfy { Self.forbiddenRawMarkers(in: $0).isEmpty }
    }

    public init(
        kind: ReleaseV0160LocalExecutionArtifactKind,
        evidenceID: Identifier,
        redactedSummary: String,
        redactedEvidenceReferences: [String],
        observedAt: Date,
        payloadID: Identifier? = nil,
        explicitOperatorConfirmationRequired: Bool = true,
        redactedEvidenceOnly: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard evidenceID.rawValue.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.invalidPayload("evidenceID")
        }
        self.payloadID = payloadID ?? Self.deterministicID(kind: kind, evidenceID: evidenceID)
        self.kind = kind
        self.evidenceID = evidenceID
        self.redactedSummary = redactedSummary
        self.redactedEvidenceReferences = redactedEvidenceReferences
        self.observedAt = observedAt
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard boundaryHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.invalidPayload(kind.rawValue)
        }
    }

    public static func deterministicID(
        kind: ReleaseV0160LocalExecutionArtifactKind,
        evidenceID: Identifier
    ) -> Identifier {
        Identifier.constant(
            "gh-1106-v0160-artifact-payload:\(kind.rawValue):\(evidenceID.rawValue)",
            field: "releaseV0160LocalExecutionArtifactPayload.payloadID"
        )
    }

    public static func fixture(
        kind: ReleaseV0160LocalExecutionArtifactKind,
        suffix: String,
        observedAt: Date
    ) throws -> ReleaseV0160LocalExecutionArtifactPayload {
        try ReleaseV0160LocalExecutionArtifactPayload(
            kind: kind,
            evidenceID: Identifier.constant("gh-1106-\(kind.rawValue)-\(suffix)-evidence"),
            redactedSummary: "redacted \(kind.rawValue) evidence for GH-1106 \(suffix)",
            redactedEvidenceReferences: [
                ".local/mtpro/v0.16.0/operator-runs/gh-1106-v0160-artifact-store-run/\(kind.rawValue)-\(suffix)-redacted.json"
            ],
            observedAt: observedAt
        )
    }

    public static func forbiddenRawMarkers(in text: String) -> [String] {
        redactionPolicy.forbiddenMarkers(in: text)
    }

    public static var forbiddenRawMarkers: [String] {
        redactionPolicy.forbiddenMarkers
    }

    public static let redactionPolicy = ReleaseV0161OperatorBetaArtifactRedactionPolicy.current
}

/// ReleaseV0160LocalExecutionArtifactRecord 是 append-only JSONL 的单条记录。
public struct ReleaseV0160LocalExecutionArtifactRecord: Codable, Equatable, Sendable {
    public let recordID: Identifier
    public let runID: Identifier
    public let sequence: Int
    public let kind: ReleaseV0160LocalExecutionArtifactKind
    public let artifactRole: ReleaseV0160OperatorRunArtifactRole
    public let payloadID: Identifier
    public let evidenceID: Identifier
    public let payloadPath: String
    public let payloadChecksum: String
    public let previousRecordChecksum: String?
    public let recordChecksum: String
    public let appendedAt: Date
    public let appendOnly: Bool
    public let redactedEvidenceOnly: Bool
    public let productionCutoverAuthorized: Bool

    public var recordHeld: Bool {
        runID.rawValue.isEmpty == false
            && sequence > 0
            && kind.artifactRole == artifactRole
            && payloadID.rawValue.isEmpty == false
            && evidenceID.rawValue.isEmpty == false
            && payloadPath.hasPrefix(".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/evidence/")
            && payloadPath.hasSuffix(".json")
            && Self.isSHA256(payloadChecksum)
            && (previousRecordChecksum == nil || Self.isSHA256(previousRecordChecksum ?? ""))
            && recordChecksum == Self.stableRecordChecksum(
                runID: runID,
                sequence: sequence,
                kind: kind,
                artifactRole: artifactRole,
                payloadID: payloadID,
                evidenceID: evidenceID,
                payloadPath: payloadPath,
                payloadChecksum: payloadChecksum,
                previousRecordChecksum: previousRecordChecksum,
                appendedAt: appendedAt
            )
            && appendOnly
            && redactedEvidenceOnly
            && productionCutoverAuthorized == false
    }

    public init(
        runID: Identifier,
        sequence: Int,
        payload: ReleaseV0160LocalExecutionArtifactPayload,
        payloadPath: String,
        payloadChecksum: String,
        previousRecordChecksum: String?,
        appendedAt: Date
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.emptyRunID
        }
        guard payload.boundaryHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.invalidPayload(payload.kind.rawValue)
        }
        self.recordID = Self.deterministicID(runID: runID, sequence: sequence, kind: payload.kind)
        self.runID = runID
        self.sequence = sequence
        self.kind = payload.kind
        self.artifactRole = payload.kind.artifactRole
        self.payloadID = payload.payloadID
        self.evidenceID = payload.evidenceID
        self.payloadPath = payloadPath
        self.payloadChecksum = payloadChecksum
        self.previousRecordChecksum = previousRecordChecksum
        self.appendedAt = appendedAt
        self.appendOnly = true
        self.redactedEvidenceOnly = true
        self.productionCutoverAuthorized = false
        self.recordChecksum = Self.stableRecordChecksum(
            runID: runID,
            sequence: sequence,
            kind: payload.kind,
            artifactRole: payload.kind.artifactRole,
            payloadID: payload.payloadID,
            evidenceID: payload.evidenceID,
            payloadPath: payloadPath,
            payloadChecksum: payloadChecksum,
            previousRecordChecksum: previousRecordChecksum,
            appendedAt: appendedAt
        )

        guard recordHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("artifactRecord.\(payload.kind.rawValue)")
        }
    }

    public static func deterministicID(
        runID: Identifier,
        sequence: Int,
        kind: ReleaseV0160LocalExecutionArtifactKind
    ) -> Identifier {
        Identifier.constant(
            "gh-1106-v0160-artifact-record:\(runID.rawValue):\(sequence):\(kind.rawValue)",
            field: "releaseV0160LocalExecutionArtifactRecord.recordID"
        )
    }

    public static func stableRecordChecksum(
        runID: Identifier,
        sequence: Int,
        kind: ReleaseV0160LocalExecutionArtifactKind,
        artifactRole: ReleaseV0160OperatorRunArtifactRole,
        payloadID: Identifier,
        evidenceID: Identifier,
        payloadPath: String,
        payloadChecksum: String,
        previousRecordChecksum: String?,
        appendedAt: Date
    ) -> String {
        releaseV0160LocalArtifactSHA256([
            "GH-1106",
            "v0.16.0",
            "artifact-record",
            runID.rawValue,
            String(sequence),
            kind.rawValue,
            artifactRole.rawValue,
            payloadID.rawValue,
            evidenceID.rawValue,
            payloadPath,
            payloadChecksum,
            previousRecordChecksum ?? "",
            String(appendedAt.timeIntervalSince1970),
            "appendOnly=true",
            "redactedEvidenceOnly=true",
            "productionCutoverAuthorized=false"
        ])
    }

    public static func isSHA256(_ value: String) -> Bool {
        guard value.hasPrefix("sha256:") else { return false }
        let hex = value.dropFirst("sha256:".count)
        return hex.count == 64 && hex.allSatisfy { "0123456789abcdef".contains($0) }
    }
}

/// ReleaseV0160LocalExecutionArtifactManifest 是 GH-1106 的 checksum manifest。
public struct ReleaseV0160LocalExecutionArtifactManifest: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let runID: Identifier
    public let manifestPath: String
    public let recordCount: Int
    public let recordChecksums: [String]
    public let latestRecordChecksum: String
    public let artifactKinds: [ReleaseV0160LocalExecutionArtifactKind]
    public let manifestChecksum: String
    public let generatedAt: Date
    public let appendOnlyArtifactPersistence: Bool
    public let checksumManifestWritten: Bool
    public let redactedArtifactStoreOnly: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var manifestHeld: Bool {
        issueID.rawValue == "GH-1106"
            && releaseVersion == "v0.16.0"
            && runID.rawValue.isEmpty == false
            && manifestPath == ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/run-manifest.json"
            && recordCount == recordChecksums.count
            && recordCount > 0
            && recordChecksums.allSatisfy(ReleaseV0160LocalExecutionArtifactRecord.isSHA256)
            && latestRecordChecksum == recordChecksums.last
            && artifactKinds.isEmpty == false
            && manifestChecksum == Self.stableManifestChecksum(
                runID: runID,
                manifestPath: manifestPath,
                recordChecksums: recordChecksums,
                artifactKinds: artifactKinds,
                generatedAt: generatedAt
            )
            && appendOnlyArtifactPersistence
            && checksumManifestWritten
            && redactedArtifactStoreOnly
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public init(
        runID: Identifier,
        records: [ReleaseV0160LocalExecutionArtifactRecord],
        generatedAt: Date,
        manifestChecksum: String? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.emptyRunID
        }
        guard records.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("manifest.records")
        }
        let manifestPath = ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/run-manifest.json"
        let checksums = records.map(\.recordChecksum)
        let kinds = records.map(\.kind)
        self.issueID = Identifier.constant("GH-1106")
        self.releaseVersion = "v0.16.0"
        self.runID = runID
        self.manifestPath = manifestPath
        self.recordCount = records.count
        self.recordChecksums = checksums
        self.latestRecordChecksum = checksums.last ?? ""
        self.artifactKinds = kinds
        self.generatedAt = generatedAt
        self.appendOnlyArtifactPersistence = true
        self.checksumManifestWritten = true
        self.redactedArtifactStoreOnly = true
        self.productionCutoverAuthorized = false
        self.validationAnchors = validationAnchors
        self.manifestChecksum = manifestChecksum ?? Self.stableManifestChecksum(
            runID: runID,
            manifestPath: manifestPath,
            recordChecksums: checksums,
            artifactKinds: kinds,
            generatedAt: generatedAt
        )

        guard manifestHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("manifest")
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1106-VERIFY-V0160-LOCAL-EXECUTION-ARTIFACT-STORE",
        "TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE",
        "V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE",
        "V0160-006-CHECKSUM-MANIFEST",
        "V0160-006-CHECKSUM-MISMATCH-REJECTED",
        "V0160-006-REPLAY-VALIDATION",
        "V0160-006-REDACTED-EXPORT-BUNDLE",
        "V0160-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1106ReleaseV0160LocalExecutionArtifactStorePersistsValidatesReplaysAndExports",
        "bash checks/verify-v0.16.0-local-execution-artifact-store.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func stableManifestChecksum(
        runID: Identifier,
        manifestPath: String,
        recordChecksums: [String],
        artifactKinds: [ReleaseV0160LocalExecutionArtifactKind],
        generatedAt: Date
    ) -> String {
        releaseV0160LocalArtifactSHA256([
            "GH-1106",
            "v0.16.0",
            "artifact-manifest",
            runID.rawValue,
            manifestPath,
            recordChecksums.joined(separator: ","),
            artifactKinds.map(\.rawValue).joined(separator: ","),
            String(generatedAt.timeIntervalSince1970),
            "appendOnlyArtifactPersistence=true",
            "checksumManifestWritten=true",
            "redactedArtifactStoreOnly=true",
            "productionCutoverAuthorized=false"
        ])
    }
}

/// ReleaseV0160LocalExecutionArtifactReplay 是从 append-only records 重建出的本地 replay 证据。
public struct ReleaseV0160LocalExecutionArtifactReplay: Equatable, Sendable {
    public let runID: Identifier
    public let records: [ReleaseV0160LocalExecutionArtifactRecord]
    public let manifest: ReleaseV0160LocalExecutionArtifactManifest
    public let replayedKinds: [ReleaseV0160LocalExecutionArtifactKind]
    public let chainValidated: Bool
    public let replayValidationSupported: Bool
    public let productionCutoverAuthorized: Bool

    public var replayHeld: Bool {
        runID == manifest.runID
            && records.isEmpty == false
            && replayedKinds == records.map(\.kind)
            && records.map(\.recordChecksum) == manifest.recordChecksums
            && chainValidated
            && replayValidationSupported
            && productionCutoverAuthorized == false
    }
}

/// ReleaseV0160LocalExecutionArtifactExportBundle 是 redacted export bundle 的 Codable 输出。
public struct ReleaseV0160LocalExecutionArtifactExportBundle: Codable, Equatable, Sendable {
    public let exportID: Identifier
    public let runID: Identifier
    public let exportPath: String
    public let manifestPath: String
    public let manifestChecksum: String
    public let recordChecksums: [String]
    public let artifactKinds: [ReleaseV0160LocalExecutionArtifactKind]
    public let exportedAt: Date
    public let redactedExportBundleSupported: Bool
    public let redactedEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionCutoverAuthorized: Bool

    public var exportHeld: Bool {
        exportID == Self.deterministicID(runID: runID, manifestChecksum: manifestChecksum)
            && exportPath == ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/export/redacted-export-bundle.json"
            && manifestPath == ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/run-manifest.json"
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(manifestChecksum)
            && recordChecksums.isEmpty == false
            && recordChecksums.allSatisfy(ReleaseV0160LocalExecutionArtifactRecord.isSHA256)
            && artifactKinds.isEmpty == false
            && redactedExportBundleSupported
            && redactedEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionCutoverAuthorized == false
    }

    public init(
        runID: Identifier,
        replay: ReleaseV0160LocalExecutionArtifactReplay,
        exportedAt: Date
    ) throws {
        self.exportID = Self.deterministicID(runID: runID, manifestChecksum: replay.manifest.manifestChecksum)
        self.runID = runID
        self.exportPath = ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/export/redacted-export-bundle.json"
        self.manifestPath = replay.manifest.manifestPath
        self.manifestChecksum = replay.manifest.manifestChecksum
        self.recordChecksums = replay.manifest.recordChecksums
        self.artifactKinds = replay.replayedKinds
        self.exportedAt = exportedAt
        self.redactedExportBundleSupported = true
        self.redactedEvidenceOnly = true
        self.containsCredentialValue = false
        self.containsRawOrderIdentity = false
        self.containsRawBrokerPayload = false
        self.productionCutoverAuthorized = false

        guard exportHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("exportBundle")
        }
    }

    public static func deterministicID(runID: Identifier, manifestChecksum: String) -> Identifier {
        Identifier.constant(
            "gh-1106-v0160-artifact-export:\(runID.rawValue):\(manifestChecksum)",
            field: "releaseV0160LocalExecutionArtifactExportBundle.exportID"
        )
    }
}

/// ReleaseV0160LocalExecutionArtifactStore 管理 GH-1106 本地 execution artifact。
///
/// Store 的真实文件根由调用方注入，公开路径仍固定映射到
/// `.local/mtpro/v0.16.0/operator-runs/<runID>`，便于 operator run manifest 和后续 review
/// issue 复用同一 evidence path 语义。所有写入均为本地文件 I/O，不读取 secret、不连接网络。
public struct ReleaseV0160LocalExecutionArtifactStore {
    public let storageRootURL: URL
    public let fileManager: FileManager

    public init(
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    public func append(
        runID: Identifier,
        payload: ReleaseV0160LocalExecutionArtifactPayload,
        appendedAt: Date
    ) throws -> ReleaseV0160LocalExecutionArtifactRecord {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.emptyRunID
        }
        guard payload.boundaryHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.invalidPayload(payload.kind.rawValue)
        }
        try fileManager.createDirectory(at: evidenceDirectoryURL(runID: runID), withIntermediateDirectories: true)

        let existing = try readRecords(runID: runID)
        try validateRecordChain(existing, runID: runID)
        let nextSequence = existing.count + 1
        let payloadPath = payloadRelativePath(runID: runID, kind: payload.kind, sequence: nextSequence)
        let payloadURL = fileURL(forRelativePath: payloadPath)
        guard fileManager.fileExists(atPath: payloadURL.path) == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.appendOnlyViolation(payloadPath)
        }
        let payloadData = try Self.encoder.encode(payload)
        try validateRedactedData(payloadData, field: payloadPath)
        try payloadData.write(to: payloadURL, options: .atomic)

        let record = try ReleaseV0160LocalExecutionArtifactRecord(
            runID: runID,
            sequence: nextSequence,
            payload: payload,
            payloadPath: payloadPath,
            payloadChecksum: Self.sha256Checksum(for: payloadData),
            previousRecordChecksum: existing.last?.recordChecksum,
            appendedAt: appendedAt
        )
        try appendRecordLine(record, runID: runID)
        _ = try writeManifest(runID: runID, records: existing + [record], generatedAt: appendedAt)
        return record
    }

    public func validate(runID: Identifier) throws -> ReleaseV0160LocalExecutionArtifactManifest {
        let records = try readRecords(runID: runID)
        try validateRecordChain(records, runID: runID)
        for record in records {
            let payloadURL = fileURL(forRelativePath: record.payloadPath)
            guard fileManager.fileExists(atPath: payloadURL.path) else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.missingArtifact(record.payloadPath)
            }
            let data = try Data(contentsOf: payloadURL)
            try validateRedactedData(data, field: record.payloadPath)
            let actual = Self.sha256Checksum(for: data)
            guard actual == record.payloadChecksum else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.checksumMismatch(
                    field: record.payloadPath,
                    expected: record.payloadChecksum,
                    actual: actual
                )
            }
        }
        let manifest = try readManifest(runID: runID)
        let expected = try ReleaseV0160LocalExecutionArtifactManifest(
            runID: runID,
            records: records,
            generatedAt: manifest.generatedAt
        )
        guard manifest == expected else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.checksumMismatch(
                field: "manifest",
                expected: expected.manifestChecksum,
                actual: manifest.manifestChecksum
            )
        }
        return manifest
    }

    public func replay(runID: Identifier) throws -> ReleaseV0160LocalExecutionArtifactReplay {
        let manifest = try validate(runID: runID)
        let records = try readRecords(runID: runID)
        let replay = ReleaseV0160LocalExecutionArtifactReplay(
            runID: runID,
            records: records,
            manifest: manifest,
            replayedKinds: records.map(\.kind),
            chainValidated: true,
            replayValidationSupported: true,
            productionCutoverAuthorized: false
        )
        guard replay.replayHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("replay")
        }
        return replay
    }

    public func exportRedactedBundle(
        runID: Identifier,
        exportedAt: Date
    ) throws -> ReleaseV0160LocalExecutionArtifactExportBundle {
        let replay = try replay(runID: runID)
        let bundle = try ReleaseV0160LocalExecutionArtifactExportBundle(
            runID: runID,
            replay: replay,
            exportedAt: exportedAt
        )
        try fileManager.createDirectory(at: exportDirectoryURL(runID: runID), withIntermediateDirectories: true)
        let data = try Self.encoder.encode(bundle)
        try validateRedactedData(data, field: bundle.exportPath)
        try data.write(to: fileURL(forRelativePath: bundle.exportPath), options: .atomic)
        return bundle
    }

    public func fileURL(forRelativePath relativePath: String) -> URL {
        let prefix = ".local/mtpro/v0.16.0/"
        let sanitized = relativePath.hasPrefix(prefix)
            ? String(relativePath.dropFirst(prefix.count))
            : relativePath
        return sanitized
            .split(separator: "/")
            .reduce(storageRootURL) { partial, component in
                partial.appendingPathComponent(String(component), isDirectory: false)
            }
    }

    private func writeManifest(
        runID: Identifier,
        records: [ReleaseV0160LocalExecutionArtifactRecord],
        generatedAt: Date
    ) throws -> ReleaseV0160LocalExecutionArtifactManifest {
        let manifest = try ReleaseV0160LocalExecutionArtifactManifest(
            runID: runID,
            records: records,
            generatedAt: generatedAt
        )
        let data = try Self.encoder.encode(manifest)
        try data.write(to: manifestURL(runID: runID), options: .atomic)
        return manifest
    }

    private func readManifest(runID: Identifier) throws -> ReleaseV0160LocalExecutionArtifactManifest {
        let url = manifestURL(runID: runID)
        guard fileManager.fileExists(atPath: url.path) else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.missingArtifact(
                ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/run-manifest.json"
            )
        }
        return try Self.decoder.decode(
            ReleaseV0160LocalExecutionArtifactManifest.self,
            from: Data(contentsOf: url)
        )
    }

    private func readRecords(runID: Identifier) throws -> [ReleaseV0160LocalExecutionArtifactRecord] {
        let url = recordsURL(runID: runID)
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        return try text
            .split(separator: "\n")
            .map { line in
                try Self.decoder.decode(
                    ReleaseV0160LocalExecutionArtifactRecord.self,
                    from: Data(line.utf8)
                )
            }
    }

    private func appendRecordLine(
        _ record: ReleaseV0160LocalExecutionArtifactRecord,
        runID: Identifier
    ) throws {
        var line = try Self.recordLineEncoder.encode(record)
        line.append(Data("\n".utf8))
        let url = recordsURL(runID: runID)
        if fileManager.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            try handle.seekToEnd()
            try handle.write(contentsOf: line)
            try handle.close()
        } else {
            try fileManager.createDirectory(at: runDirectoryURL(runID: runID), withIntermediateDirectories: true)
            try line.write(to: url, options: .atomic)
        }
    }

    private func validateRecordChain(
        _ records: [ReleaseV0160LocalExecutionArtifactRecord],
        runID: Identifier
    ) throws {
        for (index, record) in records.enumerated() {
            guard record.runID == runID else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("record.runID")
            }
            guard record.sequence == index + 1 else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.appendOnlyViolation("sequence.\(record.sequence)")
            }
            guard record.recordHeld else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("record.\(record.sequence)")
            }
            let expectedPrevious = index == 0 ? nil : records[index - 1].recordChecksum
            guard record.previousRecordChecksum == expectedPrevious else {
                throw ReleaseV0160LocalExecutionArtifactStoreError.checksumMismatch(
                    field: "previousRecordChecksum.\(record.sequence)",
                    expected: expectedPrevious ?? "nil",
                    actual: record.previousRecordChecksum ?? "nil"
                )
            }
        }
    }

    private func validateRedactedData(_ data: Data, field: String) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.forbiddenRawMarker("non-utf8:\(field)")
        }
        if let marker = ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers(in: text).first {
            throw ReleaseV0160LocalExecutionArtifactStoreError.forbiddenRawMarker(marker)
        }
    }

    private func payloadRelativePath(
        runID: Identifier,
        kind: ReleaseV0160LocalExecutionArtifactKind,
        sequence: Int
    ) -> String {
        ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/evidence/\(String(format: "%04d", sequence))-\(kind.rawValue)-redacted.json"
    }

    private func runDirectoryURL(runID: Identifier) -> URL {
        storageRootURL
            .appendingPathComponent("operator-runs", isDirectory: true)
            .appendingPathComponent(runID.rawValue, isDirectory: true)
    }

    private func evidenceDirectoryURL(runID: Identifier) -> URL {
        runDirectoryURL(runID: runID).appendingPathComponent("evidence", isDirectory: true)
    }

    private func exportDirectoryURL(runID: Identifier) -> URL {
        runDirectoryURL(runID: runID).appendingPathComponent("export", isDirectory: true)
    }

    private func recordsURL(runID: Identifier) -> URL {
        runDirectoryURL(runID: runID).appendingPathComponent("action-events.jsonl", isDirectory: false)
    }

    private func manifestURL(runID: Identifier) -> URL {
        runDirectoryURL(runID: runID).appendingPathComponent("run-manifest.json", isDirectory: false)
    }

    private static func sha256Checksum(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var recordLineEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

private func releaseV0160LocalArtifactSHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
