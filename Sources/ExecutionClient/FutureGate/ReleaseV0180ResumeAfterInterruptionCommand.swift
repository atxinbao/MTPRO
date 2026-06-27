import Crypto
import DomainModel
import Foundation

// GH-1179 static contract boundary:
// resumeAfterInterruptionCommand=ReleaseV0180ResumeAfterInterruptionCommand
// localArtifactBackedResume=true
// lifecycleManifestValidationRequired=true
// statusQueryRetryEvidenceRequired=true
// reconciliationEvidenceRequired=true
// venueProductEnvironmentNamespaceRequired=true
// crossVenueProductReuseRejected=true
// failClosedResume=true
// noAutomaticNetworkRetry=true
// brokerMutationEnabled=false
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1179-VERIFY-V0180-RESUME-AFTER-INTERRUPTION-COMMAND
// TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND
// V0180-004-DEPENDENCIES-GH1177-GH1178-DONE
// V0180-004-LOCAL-ARTIFACT-BACKED-RESUME
// V0180-004-LIFECYCLE-MANIFEST-REQUIRED
// V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED
// V0180-004-RECONCILIATION-EVIDENCE-REQUIRED
// V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED
// V0180-004-NO-AUTOMATIC-NETWORK-RETRY
// V0180-004-NO-PRODUCTION-CUTOVER

/// ReleaseV0180ResumeAfterInterruptionStatus 固定 GH-1179 resume command 顶层状态。
///
/// `.passed` 只表示本地 artifact store、lifecycle manifest、status-query snapshot 和
/// reconciliation evidence 足够恢复审计 cursor；它不代表可以重试网络、重提订单或打开
/// production cutover。
public enum ReleaseV0180ResumeAfterInterruptionStatus:
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

/// ReleaseV0180ResumeAfterInterruptionFailureReason 描述 GH-1179 的 fail-closed 分类。
public enum ReleaseV0180ResumeAfterInterruptionFailureReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case lifecycleManifestMissingOrInvalid
    case statusQueryEvidenceMissingOrInvalid
    case reconciliationEvidenceMissingOrInvalid
    case namespaceMismatch
    case baseResumeFailed
    case boundaryDrift
}

/// ReleaseV0180ResumeAfterInterruptionFailure 是 operator 可见的本地失败 evidence。
///
/// Failure 只保存字段名和脱敏说明；任何 credential、listenKey、raw order id、broker payload
/// 或 production endpoint marker 都会被 redaction policy 拒绝并转为安全说明。
public struct ReleaseV0180ResumeAfterInterruptionFailure:
    Codable,
    Equatable,
    Sendable
{
    public let failureID: Identifier
    public let reason: ReleaseV0180ResumeAfterInterruptionFailureReason
    public let field: String
    public let detail: String
    public let failClosed: Bool
    public let operatorVisible: Bool

    public var failureHeld: Bool {
        failureID == Self.deterministicID(reason: reason, field: field, detail: detail)
            && field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && failClosed
            && operatorVisible
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: detail).isEmpty
    }

    public init(
        reason: ReleaseV0180ResumeAfterInterruptionFailureReason,
        field: String,
        detail: String,
        failClosed: Bool = true,
        operatorVisible: Bool = true
    ) throws {
        let trimmedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedDetail = Self.sanitizedDetail(detail)
        guard trimmedField.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180Resume.failure.field")
        }
        guard failClosed, operatorVisible else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180Resume.failure.open")
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
        self.operatorVisible = operatorVisible

        guard failureHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180Resume.failure")
        }
    }

    public static func deterministicID(
        reason: ReleaseV0180ResumeAfterInterruptionFailureReason,
        field: String,
        detail: String
    ) -> Identifier {
        Identifier.constant(
            "gh-1179-v0180-resume-failure:\(reason.rawValue):\(field):\(detail)",
            field: "releaseV0180ResumeAfterInterruptionFailure.failureID"
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

/// ReleaseV0180ResumeAfterInterruptionInput 是 GH-1179 的本地 resume command 输入合同。
///
/// ExecutionClient 不反向依赖 Database target，因此 lifecycle manifest 以已验证的 namespace key
/// snapshot 形式传入；测试会证明该 key 与 GH-1177 `ReleaseV0180RunArtifactLifecycleNamespace`
/// 对齐。Status-query retry persistence 与 v0.17 resume result 继续使用本 target 的强类型证据。
public struct ReleaseV0180ResumeAfterInterruptionInput: Equatable, Sendable {
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let lifecycleManifestNamespaceKey: String
    public let lifecycleManifestValidated: Bool
    public let statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence
    public let baseResumeResult: ReleaseV0170OperatorRunResumeResult

    public var namespaceMatched: Bool {
        lifecycleManifestNamespaceKey == namespace.namespaceKey
            && statusQueryPersistence.namespace == namespace
            && statusQueryPersistence.snapshot.namespace == namespace
            && statusQueryPersistence.replay.runID == namespace.runID
            && baseResumeResult.sourceRunID == namespace.runID
    }

    public var statusQueryEvidenceHeld: Bool {
        statusQueryPersistence.persistenceHeld
            && statusQueryPersistence.snapshot.localArtifactStoreReplayable
            && statusQueryPersistence.snapshot.redactionStatusPersisted
            && statusQueryPersistence.snapshot.failedStatusQueryFailClosed
    }

    public var reconciliationEvidenceHeld: Bool {
        baseResumeResult.status == .passed
            && baseResumeResult.resultHeld
            && baseResumeResult.auditContinuityPreserved
            && baseResumeResult.replayedKinds.contains(.reconciliation)
            && baseResumeResult.resumeCursor?.lastArtifactKind == .reconciliation
    }

    public var inputHeld: Bool {
        namespace.namespaceHeld
            && lifecycleManifestValidated
            && namespaceMatched
            && statusQueryEvidenceHeld
            && reconciliationEvidenceHeld
            && baseResumeResult.localArtifactStoreResume
            && baseResumeResult.noResubmitOnResume
            && baseResumeResult.productionDefaultsClosed
    }

    public init(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        lifecycleManifestNamespaceKey: String,
        lifecycleManifestValidated: Bool,
        statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence,
        baseResumeResult: ReleaseV0170OperatorRunResumeResult
    ) {
        self.namespace = namespace
        self.lifecycleManifestNamespaceKey = lifecycleManifestNamespaceKey
        self.lifecycleManifestValidated = lifecycleManifestValidated
        self.statusQueryPersistence = statusQueryPersistence
        self.baseResumeResult = baseResumeResult
    }
}

/// ReleaseV0180ResumeAfterInterruptionResult 是 GH-1179 的确定性 command read model。
///
/// Result 只输出本地 resume command evidence、resume cursor 和失败原因。通过时也只允许
/// operator 从 append-only cursor 继续写本地 evidence；失败时保持 fail closed。
public struct ReleaseV0180ResumeAfterInterruptionResult:
    Codable,
    Equatable,
    Sendable
{
    public let resultID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let lifecycleManifestNamespaceKey: String
    public let lifecycleManifestValidated: Bool
    public let statusQueryResultID: Identifier
    public let statusQuerySnapshotValidated: Bool
    public let baseResumeResultID: Identifier
    public let reconciliationEvidenceValidated: Bool
    public let resumeCursor: ReleaseV0170OperatorRunResumeCursor?
    public let status: ReleaseV0180ResumeAfterInterruptionStatus
    public let failures: [ReleaseV0180ResumeAfterInterruptionFailure]
    public let operatorCommand: String
    public let operatorNextAction: String
    public let localArtifactBackedResume: Bool
    public let failClosedResume: Bool
    public let crossVenueProductReuseRejected: Bool
    public let noAutomaticNetworkRetry: Bool
    public let brokerMutationEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var resultHeld: Bool {
        resultID == Self.deterministicID(
            namespace: namespace,
            lifecycleManifestNamespaceKey: lifecycleManifestNamespaceKey,
            statusQueryResultID: statusQueryResultID,
            baseResumeResultID: baseResumeResultID,
            status: status,
            failures: failures
        )
            && issueID.rawValue == "GH-1179"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1177", "GH-1178"]
            && releaseVersion == "v0.18.0"
            && namespace.namespaceHeld
            && statusQueryResultID.rawValue.isEmpty == false
            && baseResumeResultID.rawValue.isEmpty == false
            && failures.allSatisfy(\.failureHeld)
            && status == (failures.isEmpty ? .passed : .failed)
            && localArtifactBackedResume
            && failClosedResume
            && crossVenueProductReuseRejected
            && noAutomaticNetworkRetry
            && brokerMutationEnabled == false
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
            && passedImpliesEvidenceHeld
    }

    public var passedImpliesEvidenceHeld: Bool {
        if status == .failed {
            return resumeCursor == nil
                && failures.isEmpty == false
        }
        return lifecycleManifestValidated
            && lifecycleManifestNamespaceKey == namespace.namespaceKey
            && statusQuerySnapshotValidated
            && reconciliationEvidenceValidated
            && resumeCursor?.cursorHeld == true
            && resumeCursor?.runID == namespace.runID
            && operatorCommand == Self.operatorCommand(namespace: namespace)
            && operatorNextAction == "continue-from-local-artifact-resume-cursor"
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
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        lifecycleManifestNamespaceKey: String,
        lifecycleManifestValidated: Bool,
        statusQueryResultID: Identifier,
        statusQuerySnapshotValidated: Bool,
        baseResumeResultID: Identifier,
        reconciliationEvidenceValidated: Bool,
        resumeCursor: ReleaseV0170OperatorRunResumeCursor?,
        failures: [ReleaseV0180ResumeAfterInterruptionFailure],
        issueID: Identifier = Identifier.constant("GH-1179"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1177"), Identifier.constant("GH-1178")],
        releaseVersion: String = "v0.18.0",
        localArtifactBackedResume: Bool = true,
        failClosedResume: Bool = true,
        crossVenueProductReuseRejected: Bool = true,
        noAutomaticNetworkRetry: Bool = true,
        brokerMutationEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let status: ReleaseV0180ResumeAfterInterruptionStatus = failures.isEmpty ? .passed : .failed
        self.resultID = Self.deterministicID(
            namespace: namespace,
            lifecycleManifestNamespaceKey: lifecycleManifestNamespaceKey,
            statusQueryResultID: statusQueryResultID,
            baseResumeResultID: baseResumeResultID,
            status: status,
            failures: failures
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.namespace = namespace
        self.lifecycleManifestNamespaceKey = lifecycleManifestNamespaceKey
        self.lifecycleManifestValidated = lifecycleManifestValidated
        self.statusQueryResultID = statusQueryResultID
        self.statusQuerySnapshotValidated = statusQuerySnapshotValidated
        self.baseResumeResultID = baseResumeResultID
        self.reconciliationEvidenceValidated = reconciliationEvidenceValidated
        self.resumeCursor = status == .passed ? resumeCursor : nil
        self.status = status
        self.failures = failures
        self.operatorCommand = status == .passed
            ? Self.operatorCommand(namespace: namespace)
            : "resume-refused-fail-closed"
        self.operatorNextAction = status == .passed
            ? "continue-from-local-artifact-resume-cursor"
            : "inspect-local-artifact-evidence-before-resume"
        self.localArtifactBackedResume = localArtifactBackedResume
        self.failClosedResume = failClosedResume
        self.crossVenueProductReuseRejected = crossVenueProductReuseRejected
        self.noAutomaticNetworkRetry = noAutomaticNetworkRetry
        self.brokerMutationEnabled = brokerMutationEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard resultHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180Resume.result")
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1179-VERIFY-V0180-RESUME-AFTER-INTERRUPTION-COMMAND",
        "TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND",
        "V0180-004-DEPENDENCIES-GH1177-GH1178-DONE",
        "V0180-004-LOCAL-ARTIFACT-BACKED-RESUME",
        "V0180-004-LIFECYCLE-MANIFEST-REQUIRED",
        "V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED",
        "V0180-004-RECONCILIATION-EVIDENCE-REQUIRED",
        "V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED",
        "V0180-004-NO-AUTOMATIC-NETWORK-RETRY",
        "V0180-004-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1179ResumeAfterInterruptionCommandUsesArtifactStoreEvidence",
        "bash checks/verify-v0.18.0-resume-after-interruption-command.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func operatorCommand(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    ) -> String {
        [
            "mtpro operator-run resume",
            "--run-id \(namespace.runID.rawValue)",
            "--venue \(namespace.venue)",
            "--product \(namespace.product)",
            "--environment \(namespace.environment)",
            "--account-profile \(namespace.accountProfile)"
        ].joined(separator: " ")
    }

    public static func deterministicID(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        lifecycleManifestNamespaceKey: String,
        statusQueryResultID: Identifier,
        baseResumeResultID: Identifier,
        status: ReleaseV0180ResumeAfterInterruptionStatus,
        failures: [ReleaseV0180ResumeAfterInterruptionFailure]
    ) -> Identifier {
        let checksum = releaseV0180ResumeAfterInterruptionSHA256([
            "GH-1179",
            "v0.18.0",
            namespace.namespaceKey,
            lifecycleManifestNamespaceKey,
            statusQueryResultID.rawValue,
            baseResumeResultID.rawValue,
            status.rawValue,
            failures.map(\.failureID.rawValue).joined(separator: ",")
        ])
        return Identifier.constant(
            "gh-1179-v0180-resume-after-interruption-result:\(checksum)",
            field: "releaseV0180ResumeAfterInterruptionResult.resultID"
        )
    }
}

/// ReleaseV0180ResumeAfterInterruptionCommand 汇总 GH-1179 本地 resume 判定。
///
/// Command 不读取文件、不连接网络，只消费调用方已经验证过的 local evidence object：
/// lifecycle manifest namespace、status-query retry snapshot 和 v0.17 base resume result。
public struct ReleaseV0180ResumeAfterInterruptionCommand: Sendable {
    public init() {}

    public func resume(
        input: ReleaseV0180ResumeAfterInterruptionInput
    ) throws -> ReleaseV0180ResumeAfterInterruptionResult {
        var failures: [ReleaseV0180ResumeAfterInterruptionFailure] = []

        if input.lifecycleManifestValidated == false {
            failures.append(try ReleaseV0180ResumeAfterInterruptionFailure(
                reason: .lifecycleManifestMissingOrInvalid,
                field: "lifecycleManifest",
                detail: "v0.18 lifecycle manifest validation is required before resume"
            ))
        }
        if input.namespaceMatched == false {
            failures.append(try ReleaseV0180ResumeAfterInterruptionFailure(
                reason: .namespaceMismatch,
                field: "namespace",
                detail: "venue/product/environment/accountProfile/runID namespace must match lifecycle, status and resume evidence"
            ))
        }
        if input.statusQueryEvidenceHeld == false {
            failures.append(try ReleaseV0180ResumeAfterInterruptionFailure(
                reason: .statusQueryEvidenceMissingOrInvalid,
                field: "statusQueryRetrySnapshot",
                detail: "persisted status query retry evidence is required before resume"
            ))
        }
        if input.baseResumeResult.status != .passed || input.baseResumeResult.resultHeld == false {
            failures.append(try ReleaseV0180ResumeAfterInterruptionFailure(
                reason: .baseResumeFailed,
                field: "baseResumeResult",
                detail: "v0.17 artifact-store resume must pass before v0.18 resume command"
            ))
        }
        if input.reconciliationEvidenceHeld == false {
            failures.append(try ReleaseV0180ResumeAfterInterruptionFailure(
                reason: .reconciliationEvidenceMissingOrInvalid,
                field: "reconciliationEvidence",
                detail: "resume requires append-only reconciliation artifact evidence"
            ))
        }

        return try ReleaseV0180ResumeAfterInterruptionResult(
            namespace: input.namespace,
            lifecycleManifestNamespaceKey: input.lifecycleManifestNamespaceKey,
            lifecycleManifestValidated: input.lifecycleManifestValidated,
            statusQueryResultID: input.statusQueryPersistence.snapshot.resultID,
            statusQuerySnapshotValidated: input.statusQueryEvidenceHeld,
            baseResumeResultID: input.baseResumeResult.resultID,
            reconciliationEvidenceValidated: input.reconciliationEvidenceHeld,
            resumeCursor: input.baseResumeResult.resumeCursor,
            failures: failures
        )
    }
}

private func releaseV0180ResumeAfterInterruptionSHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
