import Crypto
import DomainModel
import Foundation

// GH-1140 static contract boundary:
// artifactBundleReplayValidator=ReleaseV0170OperatorBetaArtifactBundleReplayValidator
// realArtifactBundleIngest=true
// schemaValidation=true
// checksumValidation=true
// actionSequenceValidation=true
// reconciliationArtifactRequired=true
// deterministicPassFailResult=true
// redactedArtifactEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170OperatorBetaArtifactBundleValidationStatus 固定 GH-1140 bundle replay validator 的顶层结果。
///
/// `.passed` 表示本地 artifact bundle 已通过 schema、checksum、动作序列和 reconciliation presence 校验。
/// `.failed` 只表示本地证据不可被信任；它不会触发 retry、网络请求、订单提交或 production cutover。
public enum ReleaseV0170OperatorBetaArtifactBundleValidationStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case passed
    case failed
}

/// ReleaseV0170OperatorBetaArtifactBundleFailureReason 描述 GH-1140 的 fail-closed 分类。
public enum ReleaseV0170OperatorBetaArtifactBundleFailureReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case bundleReadFailed
    case schemaDecodeFailed
    case checksumMismatch
    case actionSequenceMismatch
    case reconciliationArtifactMissing
    case redactionPolicyViolation
    case boundaryDrift
}

/// ReleaseV0170OperatorBetaArtifactBundleValidationFailure 是 GH-1140 的确定性失败证据。
///
/// Failure 只保存分类、字段和脱敏后的摘要。任何原始 credential、listenKey、broker payload 或
/// production endpoint marker 都必须在进入 failure detail 前被归一化为 redaction policy violation。
public struct ReleaseV0170OperatorBetaArtifactBundleValidationFailure:
    Codable,
    Equatable,
    Sendable
{
    public let failureID: Identifier
    public let reason: ReleaseV0170OperatorBetaArtifactBundleFailureReason
    public let field: String
    public let detail: String
    public let failClosed: Bool

    public var failureHeld: Bool {
        failureID == Self.deterministicID(reason: reason, field: field, detail: detail)
            && field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && failClosed
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: detail).isEmpty
    }

    public init(
        reason: ReleaseV0170OperatorBetaArtifactBundleFailureReason,
        field: String,
        detail: String,
        failClosed: Bool = true
    ) throws {
        let trimmedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedDetail = Self.sanitizedDetail(detail)
        guard trimmedField.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170ArtifactBundleFailure.field",
                expected: "non-empty field",
                actual: field
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0170ArtifactBundleFailure.failOpen"
            )
        }
        self.failureID = Self.deterministicID(
            reason: reason,
            field: trimmedField,
            detail: sanitizedDetail
        )
        self.reason = reason
        self.field = trimmedField
        self.detail = sanitizedDetail
        self.failClosed = failClosed

        guard failureHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170ArtifactBundleFailure",
                expected: "fail-closed redacted failure",
                actual: reason.rawValue
            )
        }
    }

    public static func deterministicID(
        reason: ReleaseV0170OperatorBetaArtifactBundleFailureReason,
        field: String,
        detail: String
    ) -> Identifier {
        Identifier.constant(
            "gh-1140-v0170-artifact-bundle-failure:\(reason.rawValue):\(field):\(detail)",
            field: "releaseV0170ArtifactBundleFailure.failureID"
        )
    }

    private static func sanitizedDetail(_ detail: String) -> String {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return trimmed.isEmpty ? "unspecified fail-closed validation failure" : trimmed
    }
}

/// ReleaseV0170OperatorBetaArtifactBundleValidationResult 是 GH-1140 输出的确定性 pass/fail read model。
///
/// Result 可以引用 v0.16.0 本地 artifact store 的 manifest checksum 和 record checksum，但不复制
/// payload 内容。它只表达本地 bundle 是否可被后续 resume / reconciliation / Dashboard / CLI issue 信任。
public struct ReleaseV0170OperatorBetaArtifactBundleValidationResult:
    Codable,
    Equatable,
    Sendable
{
    public let resultID: Identifier
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let releaseVersion: String
    public let mode: ReleaseV0170OperatorBetaHardeningMode
    public let sourceRunID: Identifier
    public let sourceManifestPath: String?
    public let sourceManifestChecksum: String?
    public let sourceRecordChecksums: [String]
    public let replayedKinds: [ReleaseV0160LocalExecutionArtifactKind]
    public let expectedActionSequence: [ReleaseV0160LocalExecutionArtifactKind]
    public let status: ReleaseV0170OperatorBetaArtifactBundleValidationStatus
    public let failures: [ReleaseV0170OperatorBetaArtifactBundleValidationFailure]
    public let schemaValidated: Bool
    public let checksumValidated: Bool
    public let actionSequenceValidated: Bool
    public let reconciliationValidated: Bool
    public let realArtifactBundleIngest: Bool
    public let deterministicPassFailResult: Bool
    public let redactedArtifactEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var resultHeld: Bool {
        resultID == Self.deterministicID(
            sourceRunID: sourceRunID,
            sourceManifestChecksum: sourceManifestChecksum,
            status: status,
            failures: failures
        )
            && issueID.rawValue == "GH-1140"
            && blockedByIssueID.rawValue == "GH-1139"
            && releaseVersion == "v0.17.0"
            && mode == .artifactBundleIngestReplayValidator
            && sourceRunID.rawValue.isEmpty == false
            && expectedActionSequence == Self.requiredActionSequence
            && status == (failures.isEmpty ? .passed : .failed)
            && failures.allSatisfy(\.failureHeld)
            && passedImpliesAllValidationHeld
            && realArtifactBundleIngest
            && deterministicPassFailResult
            && redactedArtifactEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var passedImpliesAllValidationHeld: Bool {
        if status == .failed {
            return true
        }
        return schemaValidated
            && checksumValidated
            && actionSequenceValidated
            && reconciliationValidated
            && sourceManifestPath?.isEmpty == false
            && sourceManifestChecksum.map(ReleaseV0160LocalExecutionArtifactRecord.isSHA256) == true
            && sourceRecordChecksums.isEmpty == false
            && sourceRecordChecksums.allSatisfy(ReleaseV0160LocalExecutionArtifactRecord.isSHA256)
            && replayedKinds == Self.requiredActionSequence
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        sourceRunID: Identifier,
        sourceManifestPath: String?,
        sourceManifestChecksum: String?,
        sourceRecordChecksums: [String],
        replayedKinds: [ReleaseV0160LocalExecutionArtifactKind],
        failures: [ReleaseV0170OperatorBetaArtifactBundleValidationFailure],
        schemaValidated: Bool,
        checksumValidated: Bool,
        actionSequenceValidated: Bool,
        reconciliationValidated: Bool,
        issueID: Identifier = Identifier.constant("GH-1140"),
        blockedByIssueID: Identifier = Identifier.constant("GH-1139"),
        releaseVersion: String = "v0.17.0",
        mode: ReleaseV0170OperatorBetaHardeningMode = .artifactBundleIngestReplayValidator,
        expectedActionSequence: [ReleaseV0160LocalExecutionArtifactKind] = Self.requiredActionSequence,
        realArtifactBundleIngest: Bool = true,
        deterministicPassFailResult: Bool = true,
        redactedArtifactEvidenceOnly: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let status: ReleaseV0170OperatorBetaArtifactBundleValidationStatus =
            failures.isEmpty ? .passed : .failed
        self.resultID = Self.deterministicID(
            sourceRunID: sourceRunID,
            sourceManifestChecksum: sourceManifestChecksum,
            status: status,
            failures: failures
        )
        self.issueID = issueID
        self.blockedByIssueID = blockedByIssueID
        self.releaseVersion = releaseVersion
        self.mode = mode
        self.sourceRunID = sourceRunID
        self.sourceManifestPath = sourceManifestPath
        self.sourceManifestChecksum = sourceManifestChecksum
        self.sourceRecordChecksums = sourceRecordChecksums
        self.replayedKinds = replayedKinds
        self.expectedActionSequence = expectedActionSequence
        self.status = status
        self.failures = failures
        self.schemaValidated = schemaValidated
        self.checksumValidated = checksumValidated
        self.actionSequenceValidated = actionSequenceValidated
        self.reconciliationValidated = reconciliationValidated
        self.realArtifactBundleIngest = realArtifactBundleIngest
        self.deterministicPassFailResult = deterministicPassFailResult
        self.redactedArtifactEvidenceOnly = redactedArtifactEvidenceOnly
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard resultHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170ArtifactBundleValidationResult",
                expected: "GH-1140 deterministic pass/fail result",
                actual: status.rawValue
            )
        }
    }

    public static let requiredActionSequence: [ReleaseV0160LocalExecutionArtifactKind] = [
        .submit,
        .cancel,
        .status,
        .reconciliation
    ]

    public static let requiredValidationAnchors = [
        "GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR",
        "TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR",
        "V0170-002-REAL-ARTIFACT-BUNDLE-INGEST",
        "V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION",
        "V0170-002-ACTION-SEQUENCE-VALIDATION",
        "V0170-002-RECONCILIATION-ARTIFACT-REQUIRED",
        "V0170-002-DETERMINISTIC-PASS-FAIL-RESULT",
        "V0170-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1140ReleaseV0170ArtifactBundleReplayValidator",
        "bash checks/verify-v0.17.0-artifact-bundle-replay-validator.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(
        sourceRunID: Identifier,
        sourceManifestChecksum: String?,
        status: ReleaseV0170OperatorBetaArtifactBundleValidationStatus,
        failures: [ReleaseV0170OperatorBetaArtifactBundleValidationFailure]
    ) -> Identifier {
        let failureIDs = failures.map(\.failureID.rawValue).joined(separator: ",")
        let checksum = releaseV0170ArtifactBundleSHA256([
            sourceRunID.rawValue,
            sourceManifestChecksum ?? "no-manifest",
            status.rawValue,
            failureIDs
        ])
        return Identifier.constant(
            "gh-1140-v0170-artifact-bundle-result:\(checksum)",
            field: "releaseV0170ArtifactBundleValidationResult.resultID"
        )
    }
}

/// ReleaseV0170OperatorBetaArtifactBundleReplayValidator 从本地 operator run bundle 生成 GH-1140 校验结果。
///
/// Validator 只读取调用方注入的本地 storage root，通过 v0.16.0 store 完成 schema decode、checksum
/// chain 和 replay 校验，再检查 v0.17.0 要求的 action sequence 与 reconciliation artifact。它不读取
/// credential value、不连接 testnet / production endpoint、不提交订单。
public struct ReleaseV0170OperatorBetaArtifactBundleReplayValidator: Sendable {
    public let expectedActionSequence: [ReleaseV0160LocalExecutionArtifactKind]

    public init(
        expectedActionSequence: [ReleaseV0160LocalExecutionArtifactKind] =
            ReleaseV0170OperatorBetaArtifactBundleValidationResult.requiredActionSequence
    ) throws {
        guard expectedActionSequence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170ArtifactBundleValidator.expectedActionSequence",
                expected: "non-empty action sequence",
                actual: "empty"
            )
        }
        self.expectedActionSequence = expectedActionSequence
    }

    public func validate(
        runID: Identifier,
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) throws -> ReleaseV0170OperatorBetaArtifactBundleValidationResult {
        let store = ReleaseV0160LocalExecutionArtifactStore(
            storageRootURL: storageRootURL,
            fileManager: fileManager
        )
        do {
            return try validate(replay: store.replay(runID: runID))
        } catch {
            return try failClosedResult(
                runID: runID,
                reason: Self.classify(error),
                field: "artifactBundleReplay",
                detail: String(describing: error)
            )
        }
    }

    public func validate(
        replay: ReleaseV0160LocalExecutionArtifactReplay
    ) throws -> ReleaseV0170OperatorBetaArtifactBundleValidationResult {
        var failures: [ReleaseV0170OperatorBetaArtifactBundleValidationFailure] = []
        let replayedKinds = replay.replayedKinds
        let checksumValidated = replay.chainValidated
            && replay.manifest.recordChecksums == replay.records.map(\.recordChecksum)
            && replay.manifest.recordCount == replay.records.count
            && replay.manifest.manifestHeld
        let actionSequenceValidated = replayedKinds == expectedActionSequence
        let reconciliationValidated = replayedKinds.last == .reconciliation
            && replayedKinds.contains(.reconciliation)

        if replay.replayHeld == false || checksumValidated == false {
            failures.append(try ReleaseV0170OperatorBetaArtifactBundleValidationFailure(
                reason: .checksumMismatch,
                field: "checksumChain",
                detail: "record checksums must match manifest and replay chain"
            ))
        }
        if actionSequenceValidated == false {
            let expected = expectedActionSequence.map(\.rawValue).joined(separator: ",")
            let actual = replayedKinds.map(\.rawValue).joined(separator: ",")
            failures.append(try ReleaseV0170OperatorBetaArtifactBundleValidationFailure(
                reason: .actionSequenceMismatch,
                field: "actionSequence",
                detail: "expected \(expected) actual \(actual)"
            ))
        }
        if reconciliationValidated == false {
            failures.append(try ReleaseV0170OperatorBetaArtifactBundleValidationFailure(
                reason: .reconciliationArtifactMissing,
                field: "reconciliation",
                detail: "final artifact must be reconciliation"
            ))
        }

        return try ReleaseV0170OperatorBetaArtifactBundleValidationResult(
            sourceRunID: replay.runID,
            sourceManifestPath: replay.manifest.manifestPath,
            sourceManifestChecksum: replay.manifest.manifestChecksum,
            sourceRecordChecksums: replay.manifest.recordChecksums,
            replayedKinds: replayedKinds,
            failures: failures,
            schemaValidated: true,
            checksumValidated: checksumValidated,
            actionSequenceValidated: actionSequenceValidated,
            reconciliationValidated: reconciliationValidated,
            expectedActionSequence: expectedActionSequence
        )
    }

    public static func classify(
        _ error: Error
    ) -> ReleaseV0170OperatorBetaArtifactBundleFailureReason {
        let description = String(describing: error).lowercased()
        if description.contains("forbidden raw marker")
            || description.contains("redaction")
            || ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: description).isEmpty == false {
            return .redactionPolicyViolation
        }
        if description.contains("checksum mismatch") {
            return .checksumMismatch
        }
        if description.contains("missing artifact") {
            return .bundleReadFailed
        }
        if description.contains("decod")
            || description.contains("schema")
            || description.contains("data corrupted")
            || description.contains("key not found")
            || description.contains("type mismatch") {
            return .schemaDecodeFailed
        }
        if description.contains("boundary drift") || description.contains("contract mismatch") {
            return .boundaryDrift
        }
        return .bundleReadFailed
    }

    private func failClosedResult(
        runID: Identifier,
        reason: ReleaseV0170OperatorBetaArtifactBundleFailureReason,
        field: String,
        detail: String
    ) throws -> ReleaseV0170OperatorBetaArtifactBundleValidationResult {
        let failure = try ReleaseV0170OperatorBetaArtifactBundleValidationFailure(
            reason: reason,
            field: field,
            detail: detail
        )
        return try ReleaseV0170OperatorBetaArtifactBundleValidationResult(
            sourceRunID: runID,
            sourceManifestPath: nil,
            sourceManifestChecksum: nil,
            sourceRecordChecksums: [],
            replayedKinds: [],
            failures: [failure],
            schemaValidated: false,
            checksumValidated: false,
            actionSequenceValidated: false,
            reconciliationValidated: false,
            expectedActionSequence: expectedActionSequence
        )
    }
}

private func releaseV0170ArtifactBundleSHA256(_ parts: [String]) -> String {
    SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
}
