import Crypto
import DomainModel
import Foundation

// GH-1143 static contract boundary:
// cancelStatusReconciliationRecovery=ReleaseV0170CancelStatusReconciliationRecoveryPath
// cancelStatusMismatchClassification=true
// interruptedStatusEvidenceRecovery=true
// resumeCursorContinuityRequired=true
// statusCompensationRequired=true
// noAutomaticOrderRetry=true
// redactedRecoveryEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170CancelStatusReconciliationRecoveryStatus 固定 GH-1143 recovery report 的顶层状态。
///
/// `.failed` 表示 cancel/status reconciliation 或 signed status query 已产生需要 operator 处理的
/// fail-closed recovery case；`.passed` 只表示当前输入没有 recovery case。两种状态都不授权网络、
/// submit / cancel / replace、production endpoint 或 production cutover。
public enum ReleaseV0170CancelStatusReconciliationRecoveryStatus:
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

/// ReleaseV0170CancelStatusReconciliationRecoveryReason 描述 GH-1143 的恢复分类。
public enum ReleaseV0170CancelStatusReconciliationRecoveryReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case cancelStatusMismatch
    case interruptedStatusEvidence
    case resumeCursorMissing
    case reconciliationBoundaryDrift
    case signedStatusBoundaryDrift
    case redactionPolicyViolation
    case boundaryDrift
}

/// ReleaseV0170CancelStatusReconciliationRecoveryCase 是单个 mismatch / interrupted status 的本地恢复证据。
///
/// Case 只保存本地 artifact / reconciliation / status query evidence ID 和 operator action plan。
/// `runStatusQueryCompensation` 表示 operator 必须先补齐已授权的 status query evidence，再重新执行
/// 本地 reconciliation；它不是自动网络调用，也不是订单重试。
public struct ReleaseV0170CancelStatusReconciliationRecoveryCase:
    Codable,
    Equatable,
    Sendable
{
    public let caseID: Identifier
    public let reason: ReleaseV0170CancelStatusReconciliationRecoveryReason
    public let sourceRunID: Identifier
    public let resumeCursorID: Identifier?
    public let reconciliationReportID: Identifier
    public let reconciliationFailureID: Identifier?
    public let signedStatusQueryResultID: Identifier?
    public let signedStatusFailureID: Identifier?
    public let observedState: String
    public let operatorActionPlan: [ReleaseV0160FailureRecoveryOperatorAction]
    public let statusQueryCompensationRequired: Bool
    public let reconciliationReplayRequired: Bool
    public let automaticOrderRetryBlocked: Bool
    public let noResubmitOnResume: Bool
    public let failClosed: Bool
    public let redactedRecoveryEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var caseHeld: Bool {
        caseID == Self.deterministicID(
            reason: reason,
            sourceRunID: sourceRunID,
            resumeCursorID: resumeCursorID,
            reconciliationReportID: reconciliationReportID,
            reconciliationFailureID: reconciliationFailureID,
            signedStatusQueryResultID: signedStatusQueryResultID,
            signedStatusFailureID: signedStatusFailureID,
            observedState: observedState
        )
            && sourceRunID.rawValue.isEmpty == false
            && reconciliationReportID.rawValue.isEmpty == false
            && observedState.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && reasonEvidenceHeld
            && requiredActionsHeld
            && statusQueryCompensationRequired
            && reconciliationReplayRequired
            && automaticOrderRetryBlocked
            && noResubmitOnResume
            && failClosed
            && redactedRecoveryEvidenceOnly
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: observedState).isEmpty
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        reason: ReleaseV0170CancelStatusReconciliationRecoveryReason,
        sourceRunID: Identifier,
        resumeCursorID: Identifier?,
        reconciliationReportID: Identifier,
        reconciliationFailureID: Identifier?,
        signedStatusQueryResultID: Identifier?,
        signedStatusFailureID: Identifier?,
        observedState: String,
        operatorActionPlan: [ReleaseV0160FailureRecoveryOperatorAction] = Self.requiredOperatorActionPlan,
        statusQueryCompensationRequired: Bool = true,
        reconciliationReplayRequired: Bool = true,
        automaticOrderRetryBlocked: Bool = true,
        noResubmitOnResume: Bool = true,
        failClosed: Bool = true,
        redactedRecoveryEvidenceOnly: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let sanitizedState = Self.sanitizedObservedState(observedState)
        self.caseID = Self.deterministicID(
            reason: reason,
            sourceRunID: sourceRunID,
            resumeCursorID: resumeCursorID,
            reconciliationReportID: reconciliationReportID,
            reconciliationFailureID: reconciliationFailureID,
            signedStatusQueryResultID: signedStatusQueryResultID,
            signedStatusFailureID: signedStatusFailureID,
            observedState: sanitizedState
        )
        self.reason = reason
        self.sourceRunID = sourceRunID
        self.resumeCursorID = resumeCursorID
        self.reconciliationReportID = reconciliationReportID
        self.reconciliationFailureID = reconciliationFailureID
        self.signedStatusQueryResultID = signedStatusQueryResultID
        self.signedStatusFailureID = signedStatusFailureID
        self.observedState = sanitizedState
        self.operatorActionPlan = operatorActionPlan
        self.statusQueryCompensationRequired = statusQueryCompensationRequired
        self.reconciliationReplayRequired = reconciliationReplayRequired
        self.automaticOrderRetryBlocked = automaticOrderRetryBlocked
        self.noResubmitOnResume = noResubmitOnResume
        self.failClosed = failClosed
        self.redactedRecoveryEvidenceOnly = redactedRecoveryEvidenceOnly
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard caseHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CancelStatusReconciliationRecoveryCase",
                expected: "fail-closed redacted recovery case",
                actual: reason.rawValue
            )
        }
    }

    public static let requiredOperatorActionPlan: [ReleaseV0160FailureRecoveryOperatorAction] = [
        .freezeRun,
        .runStatusQueryCompensation,
        .reconcileObservedStatus,
        .requireOperatorReview,
        .closeFailedNoRetry
    ]

    public static func deterministicID(
        reason: ReleaseV0170CancelStatusReconciliationRecoveryReason,
        sourceRunID: Identifier,
        resumeCursorID: Identifier?,
        reconciliationReportID: Identifier,
        reconciliationFailureID: Identifier?,
        signedStatusQueryResultID: Identifier?,
        signedStatusFailureID: Identifier?,
        observedState: String
    ) -> Identifier {
        let checksum = releaseV0170CancelStatusReconciliationRecoverySHA256([
            "GH-1143",
            "v0.17.0",
            reason.rawValue,
            sourceRunID.rawValue,
            resumeCursorID?.rawValue ?? "missing-resume-cursor",
            reconciliationReportID.rawValue,
            reconciliationFailureID?.rawValue ?? "no-reconciliation-failure",
            signedStatusQueryResultID?.rawValue ?? "no-signed-status-result",
            signedStatusFailureID?.rawValue ?? "no-signed-status-failure",
            observedState,
            "noAutomaticOrderRetry=true",
            "productionCutoverAuthorized=false"
        ])
        return Identifier.constant(
            "gh-1143-v0170-cancel-status-recovery-case:\(checksum)",
            field: "releaseV0170CancelStatusReconciliationRecoveryCase.caseID"
        )
    }

    private var reasonEvidenceHeld: Bool {
        switch reason {
        case .cancelStatusMismatch:
            return reconciliationFailureID != nil
        case .interruptedStatusEvidence:
            return reconciliationFailureID != nil || signedStatusFailureID != nil
        case .resumeCursorMissing:
            return resumeCursorID == nil
        case .reconciliationBoundaryDrift:
            return reconciliationFailureID == nil
        case .signedStatusBoundaryDrift:
            return signedStatusQueryResultID != nil
        case .redactionPolicyViolation, .boundaryDrift:
            return true
        }
    }

    private var requiredActionsHeld: Bool {
        Self.requiredOperatorActionPlan.allSatisfy { operatorActionPlan.contains($0) }
            && operatorActionPlan.contains(.freezeRun)
            && operatorActionPlan.contains(.closeFailedNoRetry)
    }

    private static func sanitizedObservedState(_ observedState: String) -> String {
        let trimmed = observedState.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return trimmed.isEmpty ? "unspecified fail-closed recovery state" : String(trimmed.prefix(180))
    }
}

/// ReleaseV0170CancelStatusReconciliationRecoveryReport 汇总 GH-1143 的本地恢复 evidence。
///
/// Report 连接 GH-1142 resume cursor、GH-1107 reconciliation mismatch 和 GH-1141 signed status
/// failure evidence。它只描述 operator 下一步必须补齐的本地审计动作，不会自动重试订单。
public struct ReleaseV0170CancelStatusReconciliationRecoveryReport:
    Codable,
    Equatable,
    Sendable
{
    public let reportID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let mode: ReleaseV0170OperatorBetaHardeningMode
    public let sourceRunID: Identifier
    public let resumeResultID: Identifier
    public let resumeCursorID: Identifier?
    public let reconciliationReportID: Identifier
    public let signedStatusQueryResultID: Identifier?
    public let status: ReleaseV0170CancelStatusReconciliationRecoveryStatus
    public let cases: [ReleaseV0170CancelStatusReconciliationRecoveryCase]
    public let cancelStatusMismatchClassified: Bool
    public let interruptedStatusEvidenceCovered: Bool
    public let resumeCursorContinuityRequired: Bool
    public let statusCompensationRequired: Bool
    public let noAutomaticOrderRetry: Bool
    public let redactedRecoveryEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var reportHeld: Bool {
        reportID == Self.deterministicID(
            sourceRunID: sourceRunID,
            resumeResultID: resumeResultID,
            reconciliationReportID: reconciliationReportID,
            signedStatusQueryResultID: signedStatusQueryResultID,
            caseIDs: cases.map(\.caseID)
        )
            && issueID.rawValue == "GH-1143"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1141", "GH-1142"]
            && releaseVersion == "v0.17.0"
            && mode == .cancelStatusReconciliationRecovery
            && sourceRunID.rawValue.isEmpty == false
            && resumeResultID.rawValue.isEmpty == false
            && reconciliationReportID.rawValue.isEmpty == false
            && status == (cases.isEmpty ? .passed : .failed)
            && cases.allSatisfy(\.caseHeld)
            && failedReportClassifiesRecovery
            && resumeCursorContinuityRequired
            && statusCompensationRequired
            && noAutomaticOrderRetry
            && redactedRecoveryEvidenceOnly
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public init(
        sourceRunID: Identifier,
        resumeResultID: Identifier,
        resumeCursorID: Identifier?,
        reconciliationReportID: Identifier,
        signedStatusQueryResultID: Identifier?,
        cases: [ReleaseV0170CancelStatusReconciliationRecoveryCase],
        issueID: Identifier = Identifier.constant("GH-1143"),
        blockedByIssueIDs: [Identifier] = [
            Identifier.constant("GH-1141"),
            Identifier.constant("GH-1142")
        ],
        releaseVersion: String = "v0.17.0",
        mode: ReleaseV0170OperatorBetaHardeningMode = .cancelStatusReconciliationRecovery,
        resumeCursorContinuityRequired: Bool = true,
        statusCompensationRequired: Bool = true,
        noAutomaticOrderRetry: Bool = true,
        redactedRecoveryEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        self.reportID = Self.deterministicID(
            sourceRunID: sourceRunID,
            resumeResultID: resumeResultID,
            reconciliationReportID: reconciliationReportID,
            signedStatusQueryResultID: signedStatusQueryResultID,
            caseIDs: cases.map(\.caseID)
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.mode = mode
        self.sourceRunID = sourceRunID
        self.resumeResultID = resumeResultID
        self.resumeCursorID = resumeCursorID
        self.reconciliationReportID = reconciliationReportID
        self.signedStatusQueryResultID = signedStatusQueryResultID
        self.status = cases.isEmpty ? .passed : .failed
        self.cases = cases
        self.cancelStatusMismatchClassified = cases.contains { $0.reason == .cancelStatusMismatch }
        self.interruptedStatusEvidenceCovered = cases.contains { $0.reason == .interruptedStatusEvidence }
        self.resumeCursorContinuityRequired = resumeCursorContinuityRequired
        self.statusCompensationRequired = statusCompensationRequired
        self.noAutomaticOrderRetry = noAutomaticOrderRetry
        self.redactedRecoveryEvidenceOnly = redactedRecoveryEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard reportHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CancelStatusReconciliationRecoveryReport",
                expected: "GH-1143 fail-closed recovery report",
                actual: status.rawValue
            )
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH",
        "TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH",
        "V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION",
        "V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY",
        "V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED",
        "V0170-005-STATUS-COMPENSATION-REQUIRED",
        "V0170-005-NO-AUTOMATIC-ORDER-RETRY",
        "V0170-005-REDACTED-RECOVERY-EVIDENCE",
        "V0170-005-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1143ReleaseV0170CancelStatusReconciliationRecoveryPath",
        "bash checks/verify-v0.17.0-cancel-status-reconciliation-recovery-path.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(
        sourceRunID: Identifier,
        resumeResultID: Identifier,
        reconciliationReportID: Identifier,
        signedStatusQueryResultID: Identifier?,
        caseIDs: [Identifier]
    ) -> Identifier {
        let checksum = releaseV0170CancelStatusReconciliationRecoverySHA256([
            "GH-1143",
            "v0.17.0",
            sourceRunID.rawValue,
            resumeResultID.rawValue,
            reconciliationReportID.rawValue,
            signedStatusQueryResultID?.rawValue ?? "no-signed-status-result",
            caseIDs.map(\.rawValue).joined(separator: ","),
            "noAutomaticOrderRetry=true",
            "productionCutoverAuthorized=false"
        ])
        return Identifier.constant(
            "gh-1143-v0170-cancel-status-recovery-report:\(checksum)",
            field: "releaseV0170CancelStatusReconciliationRecoveryReport.reportID"
        )
    }

    private var failedReportClassifiesRecovery: Bool {
        if status == .passed {
            return cases.isEmpty
        }
        return cancelStatusMismatchClassified || interruptedStatusEvidenceCovered
    }
}

/// ReleaseV0170CancelStatusReconciliationRecoveryPath 生成 GH-1143 本地恢复报告。
///
/// Path 只消费已存在的本地 evidence：GH-1142 resume result、GH-1107 reconciliation report、
/// 以及可选 GH-1141 signed status query result。它不读取 credential、不连接 endpoint、
/// 不执行 status query，也不发送 submit / cancel / replace。
public struct ReleaseV0170CancelStatusReconciliationRecoveryPath:
    Codable,
    Equatable,
    Sendable
{
    public let pathID: Identifier
    public let cancelStatusMismatchClassification: Bool
    public let interruptedStatusEvidenceRecovery: Bool
    public let resumeCursorContinuityRequired: Bool
    public let statusCompensationRequired: Bool
    public let noAutomaticOrderRetry: Bool
    public let redactedRecoveryEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        pathID: Identifier = Identifier.constant("gh-1143-v0170-cancel-status-reconciliation-recovery-path"),
        cancelStatusMismatchClassification: Bool = true,
        interruptedStatusEvidenceRecovery: Bool = true,
        resumeCursorContinuityRequired: Bool = true,
        statusCompensationRequired: Bool = true,
        noAutomaticOrderRetry: Bool = true,
        redactedRecoveryEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0170CancelStatusReconciliationRecoveryReport.requiredValidationAnchors
    ) throws {
        self.pathID = pathID
        self.cancelStatusMismatchClassification = cancelStatusMismatchClassification
        self.interruptedStatusEvidenceRecovery = interruptedStatusEvidenceRecovery
        self.resumeCursorContinuityRequired = resumeCursorContinuityRequired
        self.statusCompensationRequired = statusCompensationRequired
        self.noAutomaticOrderRetry = noAutomaticOrderRetry
        self.redactedRecoveryEvidenceOnly = redactedRecoveryEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CancelStatusReconciliationRecoveryPath",
                expected: "local fail-closed recovery path",
                actual: pathID.rawValue
            )
        }
    }

    public var boundaryHeld: Bool {
        pathID.rawValue.isEmpty == false
            && cancelStatusMismatchClassification
            && interruptedStatusEvidenceRecovery
            && resumeCursorContinuityRequired
            && statusCompensationRequired
            && noAutomaticOrderRetry
            && redactedRecoveryEvidenceOnly
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0170CancelStatusReconciliationRecoveryReport.requiredValidationAnchors
    }

    public func recover(
        resumeResult: ReleaseV0170OperatorRunResumeResult,
        reconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport,
        signedStatusQueryResult: ReleaseV0170SignedStatusQueryResult? = nil
    ) throws -> ReleaseV0170CancelStatusReconciliationRecoveryReport {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CancelStatusReconciliationRecoveryPath.boundaryHeld",
                expected: "closed production boundary",
                actual: "boundary drift"
            )
        }

        let resumeCursor = resumeResult.resumeCursor
        var cases: [ReleaseV0170CancelStatusReconciliationRecoveryCase] = []

        if resumeResult.resultHeld == false
            || resumeResult.status != .passed
            || resumeCursor?.cursorHeld != true {
            cases.append(try makeCase(
                reason: .resumeCursorMissing,
                resumeResult: resumeResult,
                reconciliationReport: reconciliationReport,
                reconciliationFailure: nil,
                signedStatusQueryResult: signedStatusQueryResult,
                signedStatusFailure: nil,
                observedState: "resume cursor missing or invalid"
            ))
        }

        if reconciliationReport.boundaryHeld == false
            || reconciliationReport.runID != resumeResult.sourceRunID {
            cases.append(try makeCase(
                reason: .reconciliationBoundaryDrift,
                resumeResult: resumeResult,
                reconciliationReport: reconciliationReport,
                reconciliationFailure: nil,
                signedStatusQueryResult: signedStatusQueryResult,
                signedStatusFailure: nil,
                observedState: "reconciliation boundary drift"
            ))
        }

        for failure in reconciliationReport.failures {
            cases.append(try makeCase(
                reason: Self.classify(reconciliationFailure: failure),
                resumeResult: resumeResult,
                reconciliationReport: reconciliationReport,
                reconciliationFailure: failure,
                signedStatusQueryResult: signedStatusQueryResult,
                signedStatusFailure: nil,
                observedState: "\(failure.reason.rawValue): expected \(failure.expected) actual \(failure.actual)"
            ))
        }

        if let signedStatusQueryResult {
            if signedStatusQueryResult.resultHeld == false {
                cases.append(try makeCase(
                    reason: .signedStatusBoundaryDrift,
                    resumeResult: resumeResult,
                    reconciliationReport: reconciliationReport,
                    reconciliationFailure: nil,
                    signedStatusQueryResult: signedStatusQueryResult,
                    signedStatusFailure: nil,
                    observedState: "signed status query boundary drift"
                ))
            } else if signedStatusQueryResult.status == .failed {
                for failure in signedStatusQueryResult.failures {
                    cases.append(try makeCase(
                        reason: .interruptedStatusEvidence,
                        resumeResult: resumeResult,
                        reconciliationReport: reconciliationReport,
                        reconciliationFailure: nil,
                        signedStatusQueryResult: signedStatusQueryResult,
                        signedStatusFailure: failure,
                        observedState: "\(failure.reason.rawValue): \(failure.field)"
                    ))
                }
            }
        }

        return try ReleaseV0170CancelStatusReconciliationRecoveryReport(
            sourceRunID: resumeResult.sourceRunID,
            resumeResultID: resumeResult.resultID,
            resumeCursorID: resumeCursor?.cursorID,
            reconciliationReportID: reconciliationReport.reportID,
            signedStatusQueryResultID: signedStatusQueryResult?.resultID,
            cases: cases
        )
    }

    public static func classify(
        reconciliationFailure: ReleaseV0160OMSObservedStatusReconciliationFailure
    ) -> ReleaseV0170CancelStatusReconciliationRecoveryReason {
        switch reconciliationFailure.reason {
        case .cancelStateMismatch, .missingCancelArtifact, .submitStateMismatch:
            .cancelStatusMismatch
        case .missingStatusArtifact, .unknownObservedStatus:
            .interruptedStatusEvidence
        case .boundaryDrift, .artifactKindMismatch:
            .reconciliationBoundaryDrift
        case .missingSubmitArtifact:
            .boundaryDrift
        }
    }

    private func makeCase(
        reason: ReleaseV0170CancelStatusReconciliationRecoveryReason,
        resumeResult: ReleaseV0170OperatorRunResumeResult,
        reconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport,
        reconciliationFailure: ReleaseV0160OMSObservedStatusReconciliationFailure?,
        signedStatusQueryResult: ReleaseV0170SignedStatusQueryResult?,
        signedStatusFailure: ReleaseV0170SignedStatusQueryAttemptFailure?,
        observedState: String
    ) throws -> ReleaseV0170CancelStatusReconciliationRecoveryCase {
        let sanitizedReason: ReleaseV0170CancelStatusReconciliationRecoveryReason =
            ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: observedState).isEmpty
            ? reason
            : .redactionPolicyViolation

        return try ReleaseV0170CancelStatusReconciliationRecoveryCase(
            reason: sanitizedReason,
            sourceRunID: resumeResult.sourceRunID,
            resumeCursorID: resumeResult.resumeCursor?.cursorID,
            reconciliationReportID: reconciliationReport.reportID,
            reconciliationFailureID: reconciliationFailure?.failureID,
            signedStatusQueryResultID: signedStatusQueryResult?.resultID,
            signedStatusFailureID: signedStatusFailure?.failureID,
            observedState: observedState
        )
    }
}

private func releaseV0170CancelStatusReconciliationRecoverySHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
