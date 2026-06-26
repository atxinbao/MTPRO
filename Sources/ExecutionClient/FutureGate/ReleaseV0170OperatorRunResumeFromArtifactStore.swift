import Crypto
import DomainModel
import Foundation

// GH-1142 static contract boundary:
// operatorRunResumeFromArtifactStore=ReleaseV0170OperatorRunResumeFromArtifactStore
// localArtifactStoreResume=true
// replayValidationRequired=true
// auditContinuityPreserved=true
// noResubmitOnResume=true
// redactedArtifactEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170OperatorRunResumeStatus 固定 GH-1142 artifact-store resume 的顶层状态。
///
/// `.passed` 表示本地 artifact store 已通过 GH-1140 replay validation，并且可以从最新
/// append-only checksum 继续审计链；`.failed` 只表示 resume evidence 不可信，不能触发网络、
/// broker command、订单重提或 production cutover。
public enum ReleaseV0170OperatorRunResumeStatus:
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

/// ReleaseV0170OperatorRunResumeFailureReason 描述 GH-1142 resume 失败的 fail-closed 分类。
public enum ReleaseV0170OperatorRunResumeFailureReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case artifactBundleValidationFailed
    case artifactReplayFailed
    case emptyArtifactBundle
    case auditContinuityMismatch
    case actionSequenceUnsupported
    case redactionPolicyViolation
    case boundaryDrift
}

/// ReleaseV0170OperatorRunResumeFailure 是 GH-1142 的确定性失败 evidence。
///
/// Failure 只保存字段和脱敏摘要。它不能携带 credential、listenKey、raw order id、
/// broker payload 或 production endpoint marker。
public struct ReleaseV0170OperatorRunResumeFailure:
    Codable,
    Equatable,
    Sendable
{
    public let failureID: Identifier
    public let reason: ReleaseV0170OperatorRunResumeFailureReason
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
        reason: ReleaseV0170OperatorRunResumeFailureReason,
        field: String,
        detail: String,
        failClosed: Bool = true
    ) throws {
        let trimmedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedDetail = Self.sanitizedDetail(detail)
        guard trimmedField.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170OperatorRunResumeFailure.field",
                expected: "non-empty field",
                actual: field
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0170OperatorRunResumeFailure.failOpen"
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
                field: "releaseV0170OperatorRunResumeFailure",
                expected: "fail-closed redacted resume failure",
                actual: reason.rawValue
            )
        }
    }

    public static func deterministicID(
        reason: ReleaseV0170OperatorRunResumeFailureReason,
        field: String,
        detail: String
    ) -> Identifier {
        Identifier.constant(
            "gh-1142-v0170-operator-run-resume-failure:\(reason.rawValue):\(field):\(detail)",
            field: "releaseV0170OperatorRunResumeFailure.failureID"
        )
    }

    private static func sanitizedDetail(_ detail: String) -> String {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return trimmed.isEmpty ? "unspecified fail-closed resume failure" : trimmed
    }
}

/// ReleaseV0170OperatorRunResumeCursor 是从本地 append-only artifact store 推导出的只读续跑位置。
///
/// Cursor 只描述下一条本地 evidence 应追加到哪里，以及上一条 record checksum 是什么；它不代表
/// 可以重新 submit / cancel / replace，也不会打开任何 endpoint 或 broker connection。
public struct ReleaseV0170OperatorRunResumeCursor:
    Codable,
    Equatable,
    Sendable
{
    public let cursorID: Identifier
    public let runID: Identifier
    public let manifestChecksum: String
    public let latestRecordChecksum: String
    public let nextSequence: Int
    public let lastArtifactKind: ReleaseV0160LocalExecutionArtifactKind
    public let lastOperatorAction: ReleaseV0160OperatorRunAction
    public let auditContinuityChecksum: String
    public let appendOnlyResumePoint: Bool
    public let localArtifactStoreResume: Bool
    public let noResubmitOnResume: Bool
    public let networkConnectionRequired: Bool
    public let productionCutoverAuthorized: Bool

    public var cursorHeld: Bool {
        cursorID == Self.deterministicID(
            runID: runID,
            manifestChecksum: manifestChecksum,
            latestRecordChecksum: latestRecordChecksum,
            nextSequence: nextSequence
        )
            && runID.rawValue.isEmpty == false
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(manifestChecksum)
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(latestRecordChecksum)
            && nextSequence > 1
            && lastArtifactKind.operatorAction == lastOperatorAction
            && auditContinuityChecksum == Self.stableAuditContinuityChecksum(
                runID: runID,
                manifestChecksum: manifestChecksum,
                latestRecordChecksum: latestRecordChecksum,
                nextSequence: nextSequence
            )
            && appendOnlyResumePoint
            && localArtifactStoreResume
            && noResubmitOnResume
            && networkConnectionRequired == false
            && productionCutoverAuthorized == false
    }

    public init(
        runID: Identifier,
        manifestChecksum: String,
        latestRecordChecksum: String,
        nextSequence: Int,
        lastArtifactKind: ReleaseV0160LocalExecutionArtifactKind,
        cursorID: Identifier? = nil,
        auditContinuityChecksum: String? = nil,
        appendOnlyResumePoint: Bool = true,
        localArtifactStoreResume: Bool = true,
        noResubmitOnResume: Bool = true,
        networkConnectionRequired: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.cursorID = cursorID ?? Self.deterministicID(
            runID: runID,
            manifestChecksum: manifestChecksum,
            latestRecordChecksum: latestRecordChecksum,
            nextSequence: nextSequence
        )
        self.runID = runID
        self.manifestChecksum = manifestChecksum
        self.latestRecordChecksum = latestRecordChecksum
        self.nextSequence = nextSequence
        self.lastArtifactKind = lastArtifactKind
        self.lastOperatorAction = lastArtifactKind.operatorAction
        self.auditContinuityChecksum = auditContinuityChecksum ?? Self.stableAuditContinuityChecksum(
            runID: runID,
            manifestChecksum: manifestChecksum,
            latestRecordChecksum: latestRecordChecksum,
            nextSequence: nextSequence
        )
        self.appendOnlyResumePoint = appendOnlyResumePoint
        self.localArtifactStoreResume = localArtifactStoreResume
        self.noResubmitOnResume = noResubmitOnResume
        self.networkConnectionRequired = networkConnectionRequired
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard cursorHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170OperatorRunResumeCursor",
                expected: "append-only local artifact resume cursor",
                actual: runID.rawValue
            )
        }
    }

    public static func deterministicID(
        runID: Identifier,
        manifestChecksum: String,
        latestRecordChecksum: String,
        nextSequence: Int
    ) -> Identifier {
        let checksum = stableAuditContinuityChecksum(
            runID: runID,
            manifestChecksum: manifestChecksum,
            latestRecordChecksum: latestRecordChecksum,
            nextSequence: nextSequence
        )
        return Identifier.constant(
            "gh-1142-v0170-operator-run-resume-cursor:\(checksum)",
            field: "releaseV0170OperatorRunResumeCursor.cursorID"
        )
    }

    public static func stableAuditContinuityChecksum(
        runID: Identifier,
        manifestChecksum: String,
        latestRecordChecksum: String,
        nextSequence: Int
    ) -> String {
        releaseV0170OperatorRunResumeSHA256([
            "GH-1142",
            "v0.17.0",
            "operator-run-resume-cursor",
            runID.rawValue,
            manifestChecksum,
            latestRecordChecksum,
            String(nextSequence),
            "appendOnlyResumePoint=true",
            "localArtifactStoreResume=true",
            "noResubmitOnResume=true",
            "productionCutoverAuthorized=false"
        ])
    }
}

/// ReleaseV0170OperatorRunResumeResult 是 GH-1142 的 pass/fail resume read model。
///
/// Result 复用 GH-1140 bundle validation result，并引用 v0.16.0 manifest / record checksum。
/// 通过时它只给出 append-only cursor 和 audit continuity checksum；失败时保持 fail closed。
public struct ReleaseV0170OperatorRunResumeResult:
    Codable,
    Equatable,
    Sendable
{
    public let resultID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let mode: ReleaseV0170OperatorBetaHardeningMode
    public let sourceRunID: Identifier
    public let sourceManifestPath: String?
    public let sourceManifestChecksum: String?
    public let sourceLatestRecordChecksum: String?
    public let sourceRecordChecksums: [String]
    public let replayedKinds: [ReleaseV0160LocalExecutionArtifactKind]
    public let artifactBundleValidationResultID: Identifier?
    public let artifactBundleValidationStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus
    public let resumeCursor: ReleaseV0170OperatorRunResumeCursor?
    public let status: ReleaseV0170OperatorRunResumeStatus
    public let failures: [ReleaseV0170OperatorRunResumeFailure]
    public let replayValidationRequired: Bool
    public let artifactReplayValidated: Bool
    public let auditContinuityPreserved: Bool
    public let localArtifactStoreResume: Bool
    public let noResubmitOnResume: Bool
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
            sourceLatestRecordChecksum: sourceLatestRecordChecksum,
            status: status,
            failures: failures
        )
            && issueID.rawValue == "GH-1142"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1140", "GH-1141"]
            && releaseVersion == "v0.17.0"
            && mode == .operatorRunResumeFromArtifactStore
            && sourceRunID.rawValue.isEmpty == false
            && artifactBundleValidationStatus == (failures.isEmpty ? .passed : artifactBundleValidationStatus)
            && status == (failures.isEmpty ? .passed : .failed)
            && failures.allSatisfy(\.failureHeld)
            && replayValidationRequired
            && localArtifactStoreResume
            && noResubmitOnResume
            && redactedArtifactEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
            && passedImpliesResumeHeld
    }

    public var passedImpliesResumeHeld: Bool {
        if status == .failed {
            return true
        }
        return artifactBundleValidationStatus == .passed
            && replayedKinds == ReleaseV0170OperatorBetaArtifactBundleValidationResult.requiredActionSequence
            && sourceManifestPath?.isEmpty == false
            && sourceManifestChecksum.map(ReleaseV0160LocalExecutionArtifactRecord.isSHA256) == true
            && sourceLatestRecordChecksum.map(ReleaseV0160LocalExecutionArtifactRecord.isSHA256) == true
            && sourceRecordChecksums.isEmpty == false
            && sourceRecordChecksums.last == sourceLatestRecordChecksum
            && sourceRecordChecksums.allSatisfy(ReleaseV0160LocalExecutionArtifactRecord.isSHA256)
            && artifactBundleValidationResultID != nil
            && resumeCursor?.cursorHeld == true
            && resumeCursor?.latestRecordChecksum == sourceLatestRecordChecksum
            && resumeCursor?.nextSequence == sourceRecordChecksums.count + 1
            && artifactReplayValidated
            && auditContinuityPreserved
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
        sourceLatestRecordChecksum: String?,
        sourceRecordChecksums: [String],
        replayedKinds: [ReleaseV0160LocalExecutionArtifactKind],
        artifactBundleValidationResultID: Identifier?,
        artifactBundleValidationStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus,
        resumeCursor: ReleaseV0170OperatorRunResumeCursor?,
        failures: [ReleaseV0170OperatorRunResumeFailure],
        artifactReplayValidated: Bool,
        auditContinuityPreserved: Bool,
        issueID: Identifier = Identifier.constant("GH-1142"),
        blockedByIssueIDs: [Identifier] = [
            Identifier.constant("GH-1140"),
            Identifier.constant("GH-1141")
        ],
        releaseVersion: String = "v0.17.0",
        mode: ReleaseV0170OperatorBetaHardeningMode = .operatorRunResumeFromArtifactStore,
        replayValidationRequired: Bool = true,
        localArtifactStoreResume: Bool = true,
        noResubmitOnResume: Bool = true,
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
        let status: ReleaseV0170OperatorRunResumeStatus = failures.isEmpty ? .passed : .failed
        self.resultID = Self.deterministicID(
            sourceRunID: sourceRunID,
            sourceManifestChecksum: sourceManifestChecksum,
            sourceLatestRecordChecksum: sourceLatestRecordChecksum,
            status: status,
            failures: failures
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.mode = mode
        self.sourceRunID = sourceRunID
        self.sourceManifestPath = sourceManifestPath
        self.sourceManifestChecksum = sourceManifestChecksum
        self.sourceLatestRecordChecksum = sourceLatestRecordChecksum
        self.sourceRecordChecksums = sourceRecordChecksums
        self.replayedKinds = replayedKinds
        self.artifactBundleValidationResultID = artifactBundleValidationResultID
        self.artifactBundleValidationStatus = artifactBundleValidationStatus
        self.resumeCursor = resumeCursor
        self.status = status
        self.failures = failures
        self.replayValidationRequired = replayValidationRequired
        self.artifactReplayValidated = artifactReplayValidated
        self.auditContinuityPreserved = auditContinuityPreserved
        self.localArtifactStoreResume = localArtifactStoreResume
        self.noResubmitOnResume = noResubmitOnResume
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
                field: "releaseV0170OperatorRunResumeResult",
                expected: "GH-1142 artifact-store resume evidence",
                actual: status.rawValue
            )
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE",
        "TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE",
        "V0170-004-LOCAL-ARTIFACT-STORE-RESUME",
        "V0170-004-REPLAY-VALIDATION-REQUIRED",
        "V0170-004-AUDIT-CONTINUITY-PRESERVED",
        "V0170-004-NO-RESUBMIT-ON-RESUME",
        "V0170-004-REDACTED-RESUME-EVIDENCE",
        "V0170-004-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1142ReleaseV0170OperatorRunResumeFromArtifactStore",
        "bash checks/verify-v0.17.0-operator-run-resume-from-artifact-store.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(
        sourceRunID: Identifier,
        sourceManifestChecksum: String?,
        sourceLatestRecordChecksum: String?,
        status: ReleaseV0170OperatorRunResumeStatus,
        failures: [ReleaseV0170OperatorRunResumeFailure]
    ) -> Identifier {
        let failureIDs = failures.map(\.failureID.rawValue).joined(separator: ",")
        let checksum = releaseV0170OperatorRunResumeSHA256([
            sourceRunID.rawValue,
            sourceManifestChecksum ?? "no-manifest",
            sourceLatestRecordChecksum ?? "no-latest-record",
            status.rawValue,
            failureIDs
        ])
        return Identifier.constant(
            "gh-1142-v0170-operator-run-resume-result:\(checksum)",
            field: "releaseV0170OperatorRunResumeResult.resultID"
        )
    }
}

/// ReleaseV0170OperatorRunResumeFromArtifactStore 从本地 artifact store 恢复 operator run 审计位置。
///
/// Resumer 必须先通过 GH-1140 bundle replay validation，再用 v0.16.0 store replay 生成 cursor。
/// 它不读取 credential value、不连接 endpoint、不提交或重提任何订单。
public struct ReleaseV0170OperatorRunResumeFromArtifactStore: Sendable {
    public let validator: ReleaseV0170OperatorBetaArtifactBundleReplayValidator

    public init(
        validator: ReleaseV0170OperatorBetaArtifactBundleReplayValidator
    ) {
        self.validator = validator
    }

    public init() throws {
        self.validator = try ReleaseV0170OperatorBetaArtifactBundleReplayValidator()
    }

    public func resume(
        runID: Identifier,
        storageRootURL: URL,
        fileManager: FileManager = .default
    ) throws -> ReleaseV0170OperatorRunResumeResult {
        let validationResult = try validator.validate(
            runID: runID,
            storageRootURL: storageRootURL,
            fileManager: fileManager
        )
        guard validationResult.status == .passed, validationResult.resultHeld else {
            return try failClosedResult(
                runID: runID,
                validationResult: validationResult,
                reason: .artifactBundleValidationFailed,
                field: "artifactBundleValidation",
                detail: validationResult.failures.map(\.reason.rawValue).joined(separator: ",")
            )
        }

        let store = ReleaseV0160LocalExecutionArtifactStore(
            storageRootURL: storageRootURL,
            fileManager: fileManager
        )
        do {
            return try resume(validationResult: validationResult, replay: store.replay(runID: runID))
        } catch {
            return try failClosedResult(
                runID: runID,
                validationResult: validationResult,
                reason: Self.classify(error),
                field: "artifactReplay",
                detail: String(describing: error)
            )
        }
    }

    public func resume(
        validationResult: ReleaseV0170OperatorBetaArtifactBundleValidationResult,
        replay: ReleaseV0160LocalExecutionArtifactReplay
    ) throws -> ReleaseV0170OperatorRunResumeResult {
        var failures: [ReleaseV0170OperatorRunResumeFailure] = []
        let recordChecksums = replay.manifest.recordChecksums
        let latestChecksum = replay.manifest.latestRecordChecksum
        let replayValidated = validationResult.status == .passed
            && validationResult.resultHeld
            && replay.replayHeld
            && replay.runID == validationResult.sourceRunID
            && replay.manifest.manifestChecksum == validationResult.sourceManifestChecksum
            && recordChecksums == validationResult.sourceRecordChecksums
        let actionSequenceSupported = replay.replayedKinds ==
            ReleaseV0170OperatorBetaArtifactBundleValidationResult.requiredActionSequence
        let auditContinuityPreserved = replayValidated
            && actionSequenceSupported
            && recordChecksums.isEmpty == false
            && recordChecksums.last == latestChecksum
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(latestChecksum)

        if recordChecksums.isEmpty {
            failures.append(try ReleaseV0170OperatorRunResumeFailure(
                reason: .emptyArtifactBundle,
                field: "recordChecksums",
                detail: "resume requires at least one append-only artifact record"
            ))
        }
        if replayValidated == false {
            failures.append(try ReleaseV0170OperatorRunResumeFailure(
                reason: .artifactReplayFailed,
                field: "artifactReplay",
                detail: "GH-1140 validation result must match local replay"
            ))
        }
        if actionSequenceSupported == false {
            failures.append(try ReleaseV0170OperatorRunResumeFailure(
                reason: .actionSequenceUnsupported,
                field: "actionSequence",
                detail: "resume requires submit,cancel,status,reconciliation artifact sequence"
            ))
        }
        if auditContinuityPreserved == false {
            failures.append(try ReleaseV0170OperatorRunResumeFailure(
                reason: .auditContinuityMismatch,
                field: "auditContinuity",
                detail: "latest record checksum must match manifest and resume cursor"
            ))
        }

        let cursor: ReleaseV0170OperatorRunResumeCursor? = try failures.isEmpty ? ReleaseV0170OperatorRunResumeCursor(
            runID: replay.runID,
            manifestChecksum: replay.manifest.manifestChecksum,
            latestRecordChecksum: latestChecksum,
            nextSequence: replay.records.count + 1,
            lastArtifactKind: replay.replayedKinds.last ?? .reconciliation
        ) : nil

        return try ReleaseV0170OperatorRunResumeResult(
            sourceRunID: validationResult.sourceRunID,
            sourceManifestPath: validationResult.sourceManifestPath,
            sourceManifestChecksum: validationResult.sourceManifestChecksum,
            sourceLatestRecordChecksum: latestChecksum.isEmpty ? nil : latestChecksum,
            sourceRecordChecksums: recordChecksums,
            replayedKinds: replay.replayedKinds,
            artifactBundleValidationResultID: validationResult.resultID,
            artifactBundleValidationStatus: validationResult.status,
            resumeCursor: cursor,
            failures: failures,
            artifactReplayValidated: replayValidated,
            auditContinuityPreserved: auditContinuityPreserved
        )
    }

    public static func classify(_ error: Error) -> ReleaseV0170OperatorRunResumeFailureReason {
        let description = String(describing: error).lowercased()
        if description.contains("forbidden raw marker")
            || description.contains("redaction")
            || ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: description).isEmpty == false {
            return .redactionPolicyViolation
        }
        if description.contains("checksum") {
            return .auditContinuityMismatch
        }
        if description.contains("missing artifact") {
            return .artifactReplayFailed
        }
        if description.contains("boundary drift") || description.contains("contract mismatch") {
            return .boundaryDrift
        }
        return .artifactReplayFailed
    }

    private func failClosedResult(
        runID: Identifier,
        validationResult: ReleaseV0170OperatorBetaArtifactBundleValidationResult,
        reason: ReleaseV0170OperatorRunResumeFailureReason,
        field: String,
        detail: String
    ) throws -> ReleaseV0170OperatorRunResumeResult {
        let failure = try ReleaseV0170OperatorRunResumeFailure(
            reason: reason,
            field: field,
            detail: detail.isEmpty ? "artifact bundle validation failed" : detail
        )
        return try ReleaseV0170OperatorRunResumeResult(
            sourceRunID: runID,
            sourceManifestPath: validationResult.sourceManifestPath,
            sourceManifestChecksum: validationResult.sourceManifestChecksum,
            sourceLatestRecordChecksum: validationResult.sourceRecordChecksums.last,
            sourceRecordChecksums: validationResult.sourceRecordChecksums,
            replayedKinds: validationResult.replayedKinds,
            artifactBundleValidationResultID: validationResult.resultID,
            artifactBundleValidationStatus: validationResult.status,
            resumeCursor: nil,
            failures: [failure],
            artifactReplayValidated: false,
            auditContinuityPreserved: false
        )
    }
}

private func releaseV0170OperatorRunResumeSHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
