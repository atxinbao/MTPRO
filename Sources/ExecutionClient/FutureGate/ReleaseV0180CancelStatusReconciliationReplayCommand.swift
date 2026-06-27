import Crypto
import DomainModel
import Foundation

// GH-1180 static contract boundary:
// cancelStatusReconciliationReplayCommand=ReleaseV0180CancelStatusReconciliationReplayCommand
// localArtifactReplayRequired=true
// statusQueryRetryPersistenceRequired=true
// resumeAfterInterruptionEvidenceRequired=true
// observedExpectedLifecycleStateExplained=true
// missingReconciliationFailsClosed=true
// mismatchReconciliationFailsClosed=true
// readOnlyOperatorAction=true
// crossVenueProductReuseRejected=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND
// TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND
// V0180-005-DEPENDENCIES-GH1178-GH1179-DONE
// V0180-005-LOCAL-ARTIFACT-REPLAY
// V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED
// V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED
// V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED
// V0180-005-READ-ONLY-OPERATOR-ACTION
// V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED
// V0180-005-NO-PRODUCTION-CUTOVER

/// ReleaseV0180CancelStatusReconciliationReplayStatus 固定 GH-1180 replay command 顶层状态。
///
/// `.passed` 只表示本地 cancel/status reconciliation replay 证据一致；`.failed` 表示缺少
/// reconciliation evidence、namespace drift 或 observed/expected mismatch。两种状态都不授权
/// 网络、broker mutation、订单动作或 production cutover。
public enum ReleaseV0180CancelStatusReconciliationReplayStatus:
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

/// ReleaseV0180CancelStatusReconciliationReplayFailureReason 描述 GH-1180 fail-closed 分类。
public enum ReleaseV0180CancelStatusReconciliationReplayFailureReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case resumeEvidenceMissingOrInvalid
    case statusQueryEvidenceMissingOrInvalid
    case reconciliationEvidenceMissing
    case recoveryReportMissingOrInvalid
    case namespaceMismatch
    case reconciliationMismatch
    case boundaryDrift
}

/// ReleaseV0180CancelStatusReconciliationReplayFailure 是 operator 可见的本地 replay failure。
///
/// Failure 只保存脱敏字段说明和 observed / expected 摘要；它不会保存 credential、raw order
/// identity、broker payload 或 endpoint response。
public struct ReleaseV0180CancelStatusReconciliationReplayFailure:
    Codable,
    Equatable,
    Sendable
{
    public let failureID: Identifier
    public let reason: ReleaseV0180CancelStatusReconciliationReplayFailureReason
    public let field: String
    public let expected: String
    public let observed: String
    public let failClosed: Bool
    public let operatorVisible: Bool

    public var failureHeld: Bool {
        failureID == Self.deterministicID(
            reason: reason,
            field: field,
            expected: expected,
            observed: observed
        )
            && field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && expected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && observed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && failClosed
            && operatorVisible
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: expected).isEmpty
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: observed).isEmpty
    }

    public init(
        reason: ReleaseV0180CancelStatusReconciliationReplayFailureReason,
        field: String,
        expected: String,
        observed: String,
        failClosed: Bool = true,
        operatorVisible: Bool = true
    ) throws {
        let sanitizedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedExpected = Self.sanitized(expected, fallback: "unspecified expected local reconciliation state")
        let sanitizedObserved = Self.sanitized(observed, fallback: "unspecified observed local reconciliation state")
        guard sanitizedField.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180CancelStatusReplay.failure.field")
        }
        guard failClosed, operatorVisible else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180CancelStatusReplay.failure.open")
        }
        self.failureID = Self.deterministicID(
            reason: reason,
            field: sanitizedField,
            expected: sanitizedExpected,
            observed: sanitizedObserved
        )
        self.reason = reason
        self.field = sanitizedField
        self.expected = sanitizedExpected
        self.observed = sanitizedObserved
        self.failClosed = failClosed
        self.operatorVisible = operatorVisible

        guard failureHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180CancelStatusReplay.failure")
        }
    }

    public static func deterministicID(
        reason: ReleaseV0180CancelStatusReconciliationReplayFailureReason,
        field: String,
        expected: String,
        observed: String
    ) -> Identifier {
        let checksum = releaseV0180CancelStatusReplaySHA256([
            "GH-1180",
            reason.rawValue,
            field,
            expected,
            observed,
            "failClosed=true"
        ])
        return Identifier.constant(
            "gh-1180-v0180-cancel-status-replay-failure:\(checksum)",
            field: "releaseV0180CancelStatusReconciliationReplayFailure.failureID"
        )
    }

    private static func sanitized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(220))
    }
}

/// ReleaseV0180CancelStatusReconciliationReplayInput 是 GH-1180 的只读 replay command 输入。
///
/// 输入必须来自本地 evidence object：GH-1178 status-query retry persistence、GH-1179 resume
/// result、GH-1107 observed-status reconciliation report 和 GH-1143 recovery report。可选字段允许
/// command 在缺失 reconciliation evidence 时生成 deterministic fail-closed 结果，而不是抛出后
/// 丢失 operator 可见说明。
public struct ReleaseV0180CancelStatusReconciliationReplayInput: Equatable, Sendable {
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence
    public let resumeResult: ReleaseV0180ResumeAfterInterruptionResult
    public let observedReconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport?
    public let recoveryReport: ReleaseV0170CancelStatusReconciliationRecoveryReport?

    public var namespaceMatched: Bool {
        statusQueryPersistence.namespace == namespace
            && statusQueryPersistence.snapshot.namespace == namespace
            && statusQueryPersistence.replay.runID == namespace.runID
            && resumeResult.namespace == namespace
            && resumeResult.resumeCursor?.runID == namespace.runID
            && (observedReconciliationReport?.runID ?? namespace.runID) == namespace.runID
            && (recoveryReport?.sourceRunID ?? namespace.runID) == namespace.runID
    }

    public var statusQueryEvidenceHeld: Bool {
        statusQueryPersistence.persistenceHeld
            && statusQueryPersistence.snapshot.localArtifactStoreReplayable
            && statusQueryPersistence.replay.replayedKinds.contains(.status)
    }

    public var resumeEvidenceHeld: Bool {
        resumeResult.resultHeld
            && resumeResult.status == .passed
            && resumeResult.reconciliationEvidenceValidated
            && resumeResult.resumeCursor?.cursorHeld == true
            && resumeResult.localArtifactBackedResume
            && resumeResult.noAutomaticNetworkRetry
    }

    public var reconciliationEvidenceHeld: Bool {
        guard let observedReconciliationReport, let recoveryReport else { return false }
        return observedReconciliationReport.boundaryHeld
            && recoveryReport.reportHeld
            && observedReconciliationReport.runID == namespace.runID
            && recoveryReport.sourceRunID == namespace.runID
            && recoveryReport.reconciliationReportID == observedReconciliationReport.reportID
            && recoveryReport.resumeResultID == resumeResult.baseResumeResultID
            && (recoveryReport.signedStatusQueryResultID == nil
                || recoveryReport.signedStatusQueryResultID == statusQueryPersistence.snapshot.resultID)
    }

    public var inputHeld: Bool {
        namespace.namespaceHeld
            && namespaceMatched
            && statusQueryEvidenceHeld
            && resumeEvidenceHeld
            && reconciliationEvidenceHeld
    }

    public init(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence,
        resumeResult: ReleaseV0180ResumeAfterInterruptionResult,
        observedReconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport?,
        recoveryReport: ReleaseV0170CancelStatusReconciliationRecoveryReport?
    ) {
        self.namespace = namespace
        self.statusQueryPersistence = statusQueryPersistence
        self.resumeResult = resumeResult
        self.observedReconciliationReport = observedReconciliationReport
        self.recoveryReport = recoveryReport
    }
}

/// ReleaseV0180CancelStatusReconciliationReplayResult 是 GH-1180 的 deterministic read-only result。
///
/// Result 明确显示 expected / observed lifecycle state、reconciliation report、recovery report 和
/// operator next action。失败 result 仍是可审计证据，用于阻断自动 retry 或订单动作。
public struct ReleaseV0180CancelStatusReconciliationReplayResult:
    Codable,
    Equatable,
    Sendable
{
    public let resultID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let statusQueryResultID: Identifier
    public let resumeResultID: Identifier
    public let observedReconciliationReportID: Identifier?
    public let recoveryReportID: Identifier?
    public let expectedLifecycleState: String
    public let observedLifecycleState: String
    public let reconciliationReportStatus: String
    public let recoveryReportStatus: String
    public let recoveryCaseCount: Int
    public let status: ReleaseV0180CancelStatusReconciliationReplayStatus
    public let failures: [ReleaseV0180CancelStatusReconciliationReplayFailure]
    public let operatorCommand: String
    public let operatorNextAction: String
    public let localArtifactReplayRequired: Bool
    public let observedExpectedLifecycleStateExplained: Bool
    public let missingReconciliationFailsClosed: Bool
    public let mismatchReconciliationFailsClosed: Bool
    public let readOnlyOperatorAction: Bool
    public let crossVenueProductReuseRejected: Bool
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
            statusQueryResultID: statusQueryResultID,
            resumeResultID: resumeResultID,
            observedReconciliationReportID: observedReconciliationReportID,
            recoveryReportID: recoveryReportID,
            expectedLifecycleState: expectedLifecycleState,
            observedLifecycleState: observedLifecycleState,
            status: status,
            failures: failures
        )
            && issueID.rawValue == "GH-1180"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1178", "GH-1179"]
            && releaseVersion == "v0.18.0"
            && namespace.namespaceHeld
            && statusQueryResultID.rawValue.isEmpty == false
            && resumeResultID.rawValue.isEmpty == false
            && expectedLifecycleState.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && observedLifecycleState.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && status == (failures.isEmpty ? .passed : .failed)
            && failures.allSatisfy(\.failureHeld)
            && localArtifactReplayRequired
            && observedExpectedLifecycleStateExplained
            && missingReconciliationFailsClosed
            && mismatchReconciliationFailsClosed
            && readOnlyOperatorAction
            && crossVenueProductReuseRejected
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
            && passedImpliesConsistentReplay
    }

    public var passedImpliesConsistentReplay: Bool {
        if status == .failed {
            return failures.isEmpty == false
                && operatorCommand == "cancel-status-reconciliation-replay-refused-fail-closed"
                && operatorNextAction == "inspect-local-cancel-status-reconciliation-evidence-before-replay"
        }
        return observedReconciliationReportID != nil
            && recoveryReportID != nil
            && reconciliationReportStatus == "passed"
            && recoveryReportStatus == "passed"
            && recoveryCaseCount == 0
            && operatorCommand == Self.operatorCommand(namespace: namespace)
            && operatorNextAction == "continue-local-operator-review-from-replayed-cancel-status-reconciliation"
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
        statusQueryResultID: Identifier,
        resumeResultID: Identifier,
        observedReconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport?,
        recoveryReport: ReleaseV0170CancelStatusReconciliationRecoveryReport?,
        failures: [ReleaseV0180CancelStatusReconciliationReplayFailure],
        issueID: Identifier = .constant("GH-1180"),
        blockedByIssueIDs: [Identifier] = [.constant("GH-1178"), .constant("GH-1179")],
        releaseVersion: String = "v0.18.0",
        localArtifactReplayRequired: Bool = true,
        observedExpectedLifecycleStateExplained: Bool = true,
        missingReconciliationFailsClosed: Bool = true,
        mismatchReconciliationFailsClosed: Bool = true,
        readOnlyOperatorAction: Bool = true,
        crossVenueProductReuseRejected: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let expectedLifecycleState = observedReconciliationReport?.expectedState.rawValue
            ?? "missing expected lifecycle state"
        let observedLifecycleState = observedReconciliationReport?.observedStatus.rawValue
            ?? "missing observed lifecycle state"
        let status: ReleaseV0180CancelStatusReconciliationReplayStatus = failures.isEmpty ? .passed : .failed
        self.resultID = Self.deterministicID(
            namespace: namespace,
            statusQueryResultID: statusQueryResultID,
            resumeResultID: resumeResultID,
            observedReconciliationReportID: observedReconciliationReport?.reportID,
            recoveryReportID: recoveryReport?.reportID,
            expectedLifecycleState: expectedLifecycleState,
            observedLifecycleState: observedLifecycleState,
            status: status,
            failures: failures
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.namespace = namespace
        self.statusQueryResultID = statusQueryResultID
        self.resumeResultID = resumeResultID
        self.observedReconciliationReportID = observedReconciliationReport?.reportID
        self.recoveryReportID = recoveryReport?.reportID
        self.expectedLifecycleState = expectedLifecycleState
        self.observedLifecycleState = observedLifecycleState
        self.reconciliationReportStatus = observedReconciliationReport?.status.rawValue ?? "missing"
        self.recoveryReportStatus = recoveryReport?.status.rawValue ?? "missing"
        self.recoveryCaseCount = recoveryReport?.cases.count ?? 0
        self.status = status
        self.failures = failures
        self.operatorCommand = status == .passed
            ? Self.operatorCommand(namespace: namespace)
            : "cancel-status-reconciliation-replay-refused-fail-closed"
        self.operatorNextAction = status == .passed
            ? "continue-local-operator-review-from-replayed-cancel-status-reconciliation"
            : "inspect-local-cancel-status-reconciliation-evidence-before-replay"
        self.localArtifactReplayRequired = localArtifactReplayRequired
        self.observedExpectedLifecycleStateExplained = observedExpectedLifecycleStateExplained
        self.missingReconciliationFailsClosed = missingReconciliationFailsClosed
        self.mismatchReconciliationFailsClosed = mismatchReconciliationFailsClosed
        self.readOnlyOperatorAction = readOnlyOperatorAction
        self.crossVenueProductReuseRejected = crossVenueProductReuseRejected
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard resultHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180CancelStatusReplay.result")
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND",
        "TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND",
        "V0180-005-DEPENDENCIES-GH1178-GH1179-DONE",
        "V0180-005-LOCAL-ARTIFACT-REPLAY",
        "V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED",
        "V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED",
        "V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED",
        "V0180-005-READ-ONLY-OPERATOR-ACTION",
        "V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED",
        "V0180-005-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1180CancelStatusReconciliationReplayCommandUsesLocalArtifacts",
        "bash checks/verify-v0.18.0-cancel-status-reconciliation-replay-command.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func operatorCommand(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    ) -> String {
        [
            "mtpro operator-run replay-cancel-status-reconciliation",
            "--run-id \(namespace.runID.rawValue)",
            "--venue \(namespace.venue)",
            "--product \(namespace.product)",
            "--environment \(namespace.environment)",
            "--account-profile \(namespace.accountProfile)"
        ].joined(separator: " ")
    }

    public static func deterministicID(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        statusQueryResultID: Identifier,
        resumeResultID: Identifier,
        observedReconciliationReportID: Identifier?,
        recoveryReportID: Identifier?,
        expectedLifecycleState: String,
        observedLifecycleState: String,
        status: ReleaseV0180CancelStatusReconciliationReplayStatus,
        failures: [ReleaseV0180CancelStatusReconciliationReplayFailure]
    ) -> Identifier {
        let checksum = releaseV0180CancelStatusReplaySHA256([
            "GH-1180",
            "v0.18.0",
            namespace.namespaceKey,
            statusQueryResultID.rawValue,
            resumeResultID.rawValue,
            observedReconciliationReportID?.rawValue ?? "missing-reconciliation-report",
            recoveryReportID?.rawValue ?? "missing-recovery-report",
            expectedLifecycleState,
            observedLifecycleState,
            status.rawValue,
            failures.map(\.failureID.rawValue).joined(separator: ",")
        ])
        return Identifier.constant(
            "gh-1180-v0180-cancel-status-reconciliation-replay-result:\(checksum)",
            field: "releaseV0180CancelStatusReconciliationReplayResult.resultID"
        )
    }
}

/// ReleaseV0180CancelStatusReconciliationReplayCommand 汇总 GH-1180 本地 replay 判定。
///
/// Command 不读取文件、不连接网络；它只消费调用方已经从 artifact store replay / validate 的
///本地 evidence object，并将 mismatch 或缺失证据转成 operator 可读的 fail-closed result。
public struct ReleaseV0180CancelStatusReconciliationReplayCommand: Sendable {
    public init() {}

    public func replay(
        input: ReleaseV0180CancelStatusReconciliationReplayInput
    ) throws -> ReleaseV0180CancelStatusReconciliationReplayResult {
        var failures: [ReleaseV0180CancelStatusReconciliationReplayFailure] = []

        if input.namespaceMatched == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .namespaceMismatch,
                field: "namespace",
                expected: input.namespace.namespaceKey,
                observed: "local evidence namespace mismatch"
            ))
        }
        if input.statusQueryEvidenceHeld == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .statusQueryEvidenceMissingOrInvalid,
                field: "statusQueryPersistence",
                expected: "GH-1178 local status-query retry persistence",
                observed: "missing or invalid status-query replay evidence"
            ))
        }
        if input.resumeEvidenceHeld == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .resumeEvidenceMissingOrInvalid,
                field: "resumeResult",
                expected: "GH-1179 passed resume result with reconciliation cursor",
                observed: input.resumeResult.status.rawValue
            ))
        }
        if input.observedReconciliationReport == nil {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .reconciliationEvidenceMissing,
                field: "observedReconciliationReport",
                expected: "GH-1107 observed-status reconciliation report",
                observed: "missing"
            ))
        }
        if input.recoveryReport == nil {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .recoveryReportMissingOrInvalid,
                field: "recoveryReport",
                expected: "GH-1143 cancel/status recovery report",
                observed: "missing"
            ))
        }
        if let observedReport = input.observedReconciliationReport,
           observedReport.boundaryHeld == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .boundaryDrift,
                field: "observedReconciliationReport",
                expected: "boundaryHeld=true",
                observed: "boundaryHeld=false"
            ))
        }
        if let recoveryReport = input.recoveryReport,
           recoveryReport.reportHeld == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .recoveryReportMissingOrInvalid,
                field: "recoveryReport",
                expected: "reportHeld=true",
                observed: "reportHeld=false"
            ))
        }
        if input.reconciliationEvidenceHeld == false {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .reconciliationEvidenceMissing,
                field: "reconciliationEvidence",
                expected: "matching local reconciliation and recovery reports",
                observed: "missing, invalid or namespace-mismatched"
            ))
        }
        if let observedReport = input.observedReconciliationReport,
           observedReport.status == .failed {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .reconciliationMismatch,
                field: "observedExpectedLifecycleState",
                expected: observedReport.expectedState.rawValue,
                observed: observedReport.observedStatus.rawValue
            ))
        }
        if let recoveryReport = input.recoveryReport,
           recoveryReport.status == .failed {
            failures.append(try ReleaseV0180CancelStatusReconciliationReplayFailure(
                reason: .reconciliationMismatch,
                field: "recoveryCases",
                expected: "0 recovery cases",
                observed: "\(recoveryReport.cases.count) recovery cases"
            ))
        }

        return try ReleaseV0180CancelStatusReconciliationReplayResult(
            namespace: input.namespace,
            statusQueryResultID: input.statusQueryPersistence.snapshot.resultID,
            resumeResultID: input.resumeResult.resultID,
            observedReconciliationReport: input.observedReconciliationReport,
            recoveryReport: input.recoveryReport,
            failures: failures
        )
    }
}

private func releaseV0180CancelStatusReplaySHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
