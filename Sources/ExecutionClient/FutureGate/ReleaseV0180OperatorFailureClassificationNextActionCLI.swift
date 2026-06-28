import Crypto
import DomainModel
import Foundation

// GH-1181 static contract boundary:
// operatorFailureClassificationNextActionCLI=ReleaseV0180OperatorFailureClassificationNextActionCLI
// artifactManifestFailureClassified=true
// statusQueryFailureClassified=true
// resumeFailureClassified=true
// reconciliationReplayFailureClassified=true
// nextActionCLIVisible=true
// venueProductEnvironmentFailureExplanation=true
// readOnlyOperatorAction=true
// automaticRemediationEnabled=false
// brokerMutationEnabled=false
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI
// TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI
// V0180-006-DEPENDENCIES-GH1179-GH1180-DONE
// V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED
// V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED
// V0180-006-RESUME-FAILURE-CLASSIFIED
// V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED
// V0180-006-NEXT-ACTION-CLI
// V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION
// V0180-006-READ-ONLY-OPERATOR-ACTION
// V0180-006-NO-PRODUCTION-CUTOVER

/// ReleaseV0180OperatorFailureClassificationStatus 固定 GH-1181 分类器顶层状态。
///
/// `.failed` 表示至少一个本地 evidence surface 需要 operator 处理；它不代表可以执行网络
/// 补偿、broker mutation 或 production cutover。
public enum ReleaseV0180OperatorFailureClassificationStatus:
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

/// ReleaseV0180OperatorFailureClassificationStage 表示 operator failure 来源层。
public enum ReleaseV0180OperatorFailureClassificationStage:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case artifactManifest
    case statusQuery
    case resume
    case reconciliationReplay
}

/// ReleaseV0180OperatorNextAction 是 CLI 对 operator 暴露的下一步动作集合。
///
/// 这些动作只是人工操作提示；`retry` 也只是提示 operator 回到显式授权的 read-only status
/// query workflow，不会在本类型内触发 endpoint 或 broker side effect。
public enum ReleaseV0180OperatorNextAction:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case retry
    case resume
    case manualReview
    case stop
}

/// ReleaseV0180OperatorFailureClassificationReason 是 GH-1181 的跨 evidence 失败分类。
public enum ReleaseV0180OperatorFailureClassificationReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case artifactManifestMissingOrInvalid
    case statusQueryEvidenceMissingOrInvalid
    case statusQueryTimeout
    case statusQueryRetryLimitExceeded
    case statusQueryBoundaryFailure
    case resumeEvidenceMissingOrInvalid
    case reconciliationEvidenceMissing
    case reconciliationMismatch
    case namespaceMismatch
    case recoveryReportMissingOrInvalid
    case boundaryDrift
}

/// ReleaseV0180OperatorFailureClassification 是 operator 可见的单条失败说明。
///
/// 每条说明都必须携带 venue/product/environment/accountProfile/runID namespace，保证多 venue /
/// product 恢复审计时不会把一个环境的失败误用到另一个环境。
public struct ReleaseV0180OperatorFailureClassification:
    Codable,
    Equatable,
    Sendable
{
    public let classificationID: Identifier
    public let stage: ReleaseV0180OperatorFailureClassificationStage
    public let reason: ReleaseV0180OperatorFailureClassificationReason
    public let field: String
    public let detail: String
    public let explanation: String
    public let nextAction: ReleaseV0180OperatorNextAction
    public let nextActionCLI: String
    public let failClosed: Bool
    public let operatorVisible: Bool
    public let readOnlyOperatorAction: Bool

    public var classificationHeld: Bool {
        classificationID == Self.deterministicID(
            stage: stage,
            reason: reason,
            field: field,
            detail: detail,
            nextAction: nextAction
        )
            && field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && explanation.contains("venue=")
            && explanation.contains("product=")
            && explanation.contains("environment=")
            && explanation.contains("accountProfile=")
            && explanation.contains("runID=")
            && nextActionCLI.contains("mtpro operator-run explain-failure")
            && nextActionCLI.contains("--next-action \(nextAction.rawValue)")
            && failClosed
            && operatorVisible
            && readOnlyOperatorAction
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: detail).isEmpty
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: explanation).isEmpty
    }

    public init(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        stage: ReleaseV0180OperatorFailureClassificationStage,
        reason: ReleaseV0180OperatorFailureClassificationReason,
        field: String,
        detail: String,
        nextAction: ReleaseV0180OperatorNextAction,
        failClosed: Bool = true,
        operatorVisible: Bool = true,
        readOnlyOperatorAction: Bool = true
    ) throws {
        let trimmedField = field.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedDetail = Self.sanitized(detail)
        guard trimmedField.isEmpty == false else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180FailureCLI.classification.field")
        }
        guard failClosed, operatorVisible, readOnlyOperatorAction else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180FailureCLI.classification.open")
        }
        self.classificationID = Self.deterministicID(
            stage: stage,
            reason: reason,
            field: trimmedField,
            detail: sanitizedDetail,
            nextAction: nextAction
        )
        self.stage = stage
        self.reason = reason
        self.field = trimmedField
        self.detail = sanitizedDetail
        self.explanation = Self.explanation(
            namespace: namespace,
            stage: stage,
            reason: reason,
            field: trimmedField,
            detail: sanitizedDetail,
            nextAction: nextAction
        )
        self.nextAction = nextAction
        self.nextActionCLI = Self.nextActionCLI(
            namespace: namespace,
            stage: stage,
            reason: reason,
            nextAction: nextAction
        )
        self.failClosed = failClosed
        self.operatorVisible = operatorVisible
        self.readOnlyOperatorAction = readOnlyOperatorAction

        guard classificationHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180FailureCLI.classification")
        }
    }

    public static func deterministicID(
        stage: ReleaseV0180OperatorFailureClassificationStage,
        reason: ReleaseV0180OperatorFailureClassificationReason,
        field: String,
        detail: String,
        nextAction: ReleaseV0180OperatorNextAction
    ) -> Identifier {
        let checksum = releaseV0180OperatorFailureCLISHA256([
            "GH-1181",
            stage.rawValue,
            reason.rawValue,
            field,
            detail,
            nextAction.rawValue
        ])
        return Identifier.constant(
            "gh-1181-v0180-operator-failure-classification:\(checksum)",
            field: "releaseV0180OperatorFailureClassification.classificationID"
        )
    }

    private static func explanation(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        stage: ReleaseV0180OperatorFailureClassificationStage,
        reason: ReleaseV0180OperatorFailureClassificationReason,
        field: String,
        detail: String,
        nextAction: ReleaseV0180OperatorNextAction
    ) -> String {
        [
            "venue=\(namespace.venue)",
            "product=\(namespace.product)",
            "environment=\(namespace.environment)",
            "accountProfile=\(namespace.accountProfile)",
            "runID=\(namespace.runID.rawValue)",
            "stage=\(stage.rawValue)",
            "reason=\(reason.rawValue)",
            "field=\(field)",
            "detail=\(detail)",
            "nextAction=\(nextAction.rawValue)"
        ].joined(separator: "; ")
    }

    private static func nextActionCLI(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        stage: ReleaseV0180OperatorFailureClassificationStage,
        reason: ReleaseV0180OperatorFailureClassificationReason,
        nextAction: ReleaseV0180OperatorNextAction
    ) -> String {
        [
            "mtpro operator-run explain-failure",
            "--run-id \(namespace.runID.rawValue)",
            "--venue \(namespace.venue)",
            "--product \(namespace.product)",
            "--environment \(namespace.environment)",
            "--account-profile \(namespace.accountProfile)",
            "--stage \(stage.rawValue)",
            "--reason \(reason.rawValue)",
            "--next-action \(nextAction.rawValue)"
        ].joined(separator: " ")
    }

    private static func sanitized(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReleaseV0161OperatorBetaArtifactRedactionPolicy.forbiddenMarkers(in: trimmed).isEmpty else {
            return "redaction policy rejected forbidden marker"
        }
        return trimmed.isEmpty ? "unspecified operator failure classification detail" : String(trimmed.prefix(260))
    }
}

/// ReleaseV0180OperatorFailureClassificationNextActionInput 是 GH-1181 的只读 CLI 输入。
///
/// 所有字段都来自前序本地 evidence object。可选字段允许分类器在 evidence 缺失时输出
/// deterministic fail-closed 说明，而不是抛错并丢失 operator 下一步动作。
public struct ReleaseV0180OperatorFailureClassificationNextActionInput: Equatable, Sendable {
    public let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let lifecycleManifestNamespaceKey: String
    public let lifecycleManifestValidated: Bool
    public let statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence?
    public let resumeResult: ReleaseV0180ResumeAfterInterruptionResult?
    public let reconciliationReplayResult: ReleaseV0180CancelStatusReconciliationReplayResult?

    public var lifecycleManifestMatched: Bool {
        lifecycleManifestValidated
            && lifecycleManifestNamespaceKey == namespace.namespaceKey
    }

    public init(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        lifecycleManifestNamespaceKey: String,
        lifecycleManifestValidated: Bool,
        statusQueryPersistence: ReleaseV0180StatusQueryRetryArtifactPersistence?,
        resumeResult: ReleaseV0180ResumeAfterInterruptionResult?,
        reconciliationReplayResult: ReleaseV0180CancelStatusReconciliationReplayResult?
    ) {
        self.namespace = namespace
        self.lifecycleManifestNamespaceKey = lifecycleManifestNamespaceKey
        self.lifecycleManifestValidated = lifecycleManifestValidated
        self.statusQueryPersistence = statusQueryPersistence
        self.resumeResult = resumeResult
        self.reconciliationReplayResult = reconciliationReplayResult
    }
}

/// ReleaseV0180OperatorFailureClassificationNextActionResult 是 GH-1181 的 operator CLI read model。
///
/// Result 将 manifest、status query、resume 和 reconciliation replay 的失败统一排序，
/// 输出 operator 可见的下一步命令；通过时只建议继续本地 resume，不触发自动修复。
public struct ReleaseV0180OperatorFailureClassificationNextActionResult:
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
    public let statusQueryResultID: Identifier?
    public let resumeResultID: Identifier?
    public let reconciliationReplayResultID: Identifier?
    public let status: ReleaseV0180OperatorFailureClassificationStatus
    public let classifications: [ReleaseV0180OperatorFailureClassification]
    public let topLevelNextAction: ReleaseV0180OperatorNextAction
    public let operatorNextActionCLI: String
    public let artifactManifestFailureClassified: Bool
    public let statusQueryFailureClassified: Bool
    public let resumeFailureClassified: Bool
    public let reconciliationReplayFailureClassified: Bool
    public let nextActionCLIVisible: Bool
    public let venueProductEnvironmentFailureExplanation: Bool
    public let readOnlyOperatorAction: Bool
    public let automaticRemediationEnabled: Bool
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
            resumeResultID: resumeResultID,
            reconciliationReplayResultID: reconciliationReplayResultID,
            classifications: classifications,
            topLevelNextAction: topLevelNextAction
        )
            && issueID.rawValue == "GH-1181"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1179", "GH-1180"]
            && releaseVersion == "v0.18.0"
            && namespace.namespaceHeld
            && classifications.allSatisfy(\.classificationHeld)
            && status == (classifications.isEmpty ? .passed : .failed)
            && topLevelNextAction == Self.topLevelNextAction(for: classifications)
            && operatorNextActionCLI.contains("mtpro operator-run explain-failure")
            && operatorNextActionCLI.contains("--next-action \(topLevelNextAction.rawValue)")
            && nextActionCLIVisible
            && venueProductEnvironmentFailureExplanation
            && readOnlyOperatorAction
            && automaticRemediationEnabled == false
            && brokerMutationEnabled == false
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
            && classifiedStageFlagsHeld
    }

    public var classifiedStageFlagsHeld: Bool {
        artifactManifestFailureClassified == classifications.contains { $0.stage == .artifactManifest }
            && statusQueryFailureClassified == classifications.contains { $0.stage == .statusQuery }
            && resumeFailureClassified == classifications.contains { $0.stage == .resume }
            && reconciliationReplayFailureClassified == classifications.contains { $0.stage == .reconciliationReplay }
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
        statusQueryResultID: Identifier?,
        resumeResultID: Identifier?,
        reconciliationReplayResultID: Identifier?,
        classifications: [ReleaseV0180OperatorFailureClassification],
        issueID: Identifier = .constant("GH-1181"),
        blockedByIssueIDs: [Identifier] = [.constant("GH-1179"), .constant("GH-1180")],
        releaseVersion: String = "v0.18.0",
        nextActionCLIVisible: Bool = true,
        venueProductEnvironmentFailureExplanation: Bool = true,
        readOnlyOperatorAction: Bool = true,
        automaticRemediationEnabled: Bool = false,
        brokerMutationEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let topLevelNextAction = Self.topLevelNextAction(for: classifications)
        self.resultID = Self.deterministicID(
            namespace: namespace,
            lifecycleManifestNamespaceKey: lifecycleManifestNamespaceKey,
            statusQueryResultID: statusQueryResultID,
            resumeResultID: resumeResultID,
            reconciliationReplayResultID: reconciliationReplayResultID,
            classifications: classifications,
            topLevelNextAction: topLevelNextAction
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.namespace = namespace
        self.lifecycleManifestNamespaceKey = lifecycleManifestNamespaceKey
        self.lifecycleManifestValidated = lifecycleManifestValidated
        self.statusQueryResultID = statusQueryResultID
        self.resumeResultID = resumeResultID
        self.reconciliationReplayResultID = reconciliationReplayResultID
        self.status = classifications.isEmpty ? .passed : .failed
        self.classifications = classifications
        self.topLevelNextAction = topLevelNextAction
        self.operatorNextActionCLI = Self.operatorNextActionCLI(
            namespace: namespace,
            nextAction: topLevelNextAction
        )
        self.artifactManifestFailureClassified = classifications.contains { $0.stage == .artifactManifest }
        self.statusQueryFailureClassified = classifications.contains { $0.stage == .statusQuery }
        self.resumeFailureClassified = classifications.contains { $0.stage == .resume }
        self.reconciliationReplayFailureClassified = classifications.contains { $0.stage == .reconciliationReplay }
        self.nextActionCLIVisible = nextActionCLIVisible
        self.venueProductEnvironmentFailureExplanation = venueProductEnvironmentFailureExplanation
        self.readOnlyOperatorAction = readOnlyOperatorAction
        self.automaticRemediationEnabled = automaticRemediationEnabled
        self.brokerMutationEnabled = brokerMutationEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard resultHeld else {
            throw ReleaseV0160LocalExecutionArtifactStoreError.boundaryDrift("v0180FailureCLI.result")
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI",
        "TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI",
        "V0180-006-DEPENDENCIES-GH1179-GH1180-DONE",
        "V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED",
        "V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED",
        "V0180-006-RESUME-FAILURE-CLASSIFIED",
        "V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED",
        "V0180-006-NEXT-ACTION-CLI",
        "V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION",
        "V0180-006-READ-ONLY-OPERATOR-ACTION",
        "V0180-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1181OperatorFailureClassificationNextActionCLIExplainsLocalEvidenceFailures",
        "bash checks/verify-v0.18.0-operator-failure-classification-next-action-cli.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func topLevelNextAction(
        for classifications: [ReleaseV0180OperatorFailureClassification]
    ) -> ReleaseV0180OperatorNextAction {
        let actions = Set(classifications.map(\.nextAction))
        if actions.contains(.stop) { return .stop }
        if actions.contains(.manualReview) { return .manualReview }
        if actions.contains(.retry) { return .retry }
        return .resume
    }

    public static func operatorNextActionCLI(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        nextAction: ReleaseV0180OperatorNextAction
    ) -> String {
        [
            "mtpro operator-run explain-failure",
            "--run-id \(namespace.runID.rawValue)",
            "--venue \(namespace.venue)",
            "--product \(namespace.product)",
            "--environment \(namespace.environment)",
            "--account-profile \(namespace.accountProfile)",
            "--next-action \(nextAction.rawValue)"
        ].joined(separator: " ")
    }

    public static func deterministicID(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        lifecycleManifestNamespaceKey: String,
        statusQueryResultID: Identifier?,
        resumeResultID: Identifier?,
        reconciliationReplayResultID: Identifier?,
        classifications: [ReleaseV0180OperatorFailureClassification],
        topLevelNextAction: ReleaseV0180OperatorNextAction
    ) -> Identifier {
        let checksum = releaseV0180OperatorFailureCLISHA256([
            "GH-1181",
            "v0.18.0",
            namespace.namespaceKey,
            lifecycleManifestNamespaceKey,
            statusQueryResultID?.rawValue ?? "missing-status-query-result",
            resumeResultID?.rawValue ?? "missing-resume-result",
            reconciliationReplayResultID?.rawValue ?? "missing-reconciliation-replay-result",
            classifications.map(\.classificationID.rawValue).joined(separator: ","),
            topLevelNextAction.rawValue
        ])
        return Identifier.constant(
            "gh-1181-v0180-operator-failure-next-action-result:\(checksum)",
            field: "releaseV0180OperatorFailureClassificationNextActionResult.resultID"
        )
    }
}

/// ReleaseV0180OperatorFailureClassificationNextActionCLI 汇总 GH-1181 只读 CLI 判定。
public struct ReleaseV0180OperatorFailureClassificationNextActionCLI: Sendable {
    public init() {}

    public func classify(
        input: ReleaseV0180OperatorFailureClassificationNextActionInput
    ) throws -> ReleaseV0180OperatorFailureClassificationNextActionResult {
        var classifications: [ReleaseV0180OperatorFailureClassification] = []

        if input.lifecycleManifestMatched == false {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .artifactManifest,
                reason: .artifactManifestMissingOrInvalid,
                field: "lifecycleManifest",
                detail: "v0.18 lifecycle manifest namespace must be validated before operator recovery",
                nextAction: .stop
            ))
        }

        try appendStatusQueryClassifications(
            input: input,
            into: &classifications
        )
        try appendResumeClassifications(
            input: input,
            into: &classifications
        )
        try appendReconciliationReplayClassifications(
            input: input,
            into: &classifications
        )

        return try ReleaseV0180OperatorFailureClassificationNextActionResult(
            namespace: input.namespace,
            lifecycleManifestNamespaceKey: input.lifecycleManifestNamespaceKey,
            lifecycleManifestValidated: input.lifecycleManifestValidated,
            statusQueryResultID: input.statusQueryPersistence?.snapshot.resultID,
            resumeResultID: input.resumeResult?.resultID,
            reconciliationReplayResultID: input.reconciliationReplayResult?.resultID,
            classifications: classifications
        )
    }

    private func appendStatusQueryClassifications(
        input: ReleaseV0180OperatorFailureClassificationNextActionInput,
        into classifications: inout [ReleaseV0180OperatorFailureClassification]
    ) throws {
        guard let statusQueryPersistence = input.statusQueryPersistence else {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .statusQuery,
                reason: .statusQueryEvidenceMissingOrInvalid,
                field: "statusQueryPersistence",
                detail: "GH-1178 status-query retry artifact evidence is missing",
                nextAction: .manualReview
            ))
            return
        }
        if statusQueryPersistence.namespace != input.namespace
            || statusQueryPersistence.persistenceHeld == false {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .statusQuery,
                reason: .namespaceMismatch,
                field: "statusQueryPersistence",
                detail: "status-query evidence namespace must match operator lifecycle namespace",
                nextAction: .stop
            ))
        }
        for reason in statusQueryPersistence.snapshot.classifiedFailureReasons {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .statusQuery,
                reason: Self.reason(forStatusQueryFailure: reason),
                field: "statusQueryRetrySnapshot",
                detail: "status query classified failure \(reason.rawValue)",
                nextAction: Self.nextAction(forStatusQueryFailure: reason)
            ))
        }
    }

    private func appendResumeClassifications(
        input: ReleaseV0180OperatorFailureClassificationNextActionInput,
        into classifications: inout [ReleaseV0180OperatorFailureClassification]
    ) throws {
        guard let resumeResult = input.resumeResult else {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .resume,
                reason: .resumeEvidenceMissingOrInvalid,
                field: "resumeResult",
                detail: "GH-1179 resume evidence is missing",
                nextAction: .manualReview
            ))
            return
        }
        if resumeResult.namespace != input.namespace
            || resumeResult.resultHeld == false {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .resume,
                reason: .namespaceMismatch,
                field: "resumeResult",
                detail: "resume evidence namespace must match operator lifecycle namespace",
                nextAction: .stop
            ))
        }
        for failure in resumeResult.failures {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .resume,
                reason: Self.reason(forResumeFailure: failure.reason),
                field: failure.field,
                detail: failure.detail,
                nextAction: Self.nextAction(forResumeFailure: failure.reason)
            ))
        }
    }

    private func appendReconciliationReplayClassifications(
        input: ReleaseV0180OperatorFailureClassificationNextActionInput,
        into classifications: inout [ReleaseV0180OperatorFailureClassification]
    ) throws {
        guard let replayResult = input.reconciliationReplayResult else {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .reconciliationReplay,
                reason: .reconciliationEvidenceMissing,
                field: "reconciliationReplayResult",
                detail: "GH-1180 reconciliation replay evidence is missing",
                nextAction: .manualReview
            ))
            return
        }
        if replayResult.namespace != input.namespace
            || replayResult.resultHeld == false {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .reconciliationReplay,
                reason: .namespaceMismatch,
                field: "reconciliationReplayResult",
                detail: "reconciliation replay namespace must match operator lifecycle namespace",
                nextAction: .stop
            ))
        }
        for failure in replayResult.failures {
            classifications.append(try ReleaseV0180OperatorFailureClassification(
                namespace: input.namespace,
                stage: .reconciliationReplay,
                reason: Self.reason(forReplayFailure: failure.reason),
                field: failure.field,
                detail: "expected \(failure.expected); observed \(failure.observed)",
                nextAction: Self.nextAction(forReplayFailure: failure.reason)
            ))
        }
    }

    private static func reason(
        forStatusQueryFailure reason: ReleaseV0170SignedStatusQueryFailureReason
    ) -> ReleaseV0180OperatorFailureClassificationReason {
        switch reason {
        case .timeout:
            .statusQueryTimeout
        case .retryLimitExceeded:
            .statusQueryRetryLimitExceeded
        case .boundaryDrift, .redactionPolicyViolation:
            .statusQueryBoundaryFailure
        case .retryableHTTPStatus, .nonRetryableHTTPStatus, .transportFailure:
            .statusQueryEvidenceMissingOrInvalid
        }
    }

    private static func nextAction(
        forStatusQueryFailure reason: ReleaseV0170SignedStatusQueryFailureReason
    ) -> ReleaseV0180OperatorNextAction {
        switch reason {
        case .timeout, .retryableHTTPStatus:
            .retry
        case .retryLimitExceeded, .nonRetryableHTTPStatus, .transportFailure:
            .manualReview
        case .boundaryDrift, .redactionPolicyViolation:
            .stop
        }
    }

    private static func reason(
        forResumeFailure reason: ReleaseV0180ResumeAfterInterruptionFailureReason
    ) -> ReleaseV0180OperatorFailureClassificationReason {
        switch reason {
        case .lifecycleManifestMissingOrInvalid:
            .artifactManifestMissingOrInvalid
        case .statusQueryEvidenceMissingOrInvalid:
            .statusQueryEvidenceMissingOrInvalid
        case .reconciliationEvidenceMissingOrInvalid:
            .reconciliationEvidenceMissing
        case .namespaceMismatch:
            .namespaceMismatch
        case .baseResumeFailed:
            .resumeEvidenceMissingOrInvalid
        case .boundaryDrift:
            .boundaryDrift
        }
    }

    private static func nextAction(
        forResumeFailure reason: ReleaseV0180ResumeAfterInterruptionFailureReason
    ) -> ReleaseV0180OperatorNextAction {
        switch reason {
        case .namespaceMismatch, .boundaryDrift:
            .stop
        case .statusQueryEvidenceMissingOrInvalid:
            .retry
        case .lifecycleManifestMissingOrInvalid,
             .reconciliationEvidenceMissingOrInvalid,
             .baseResumeFailed:
            .manualReview
        }
    }

    private static func reason(
        forReplayFailure reason: ReleaseV0180CancelStatusReconciliationReplayFailureReason
    ) -> ReleaseV0180OperatorFailureClassificationReason {
        switch reason {
        case .resumeEvidenceMissingOrInvalid:
            .resumeEvidenceMissingOrInvalid
        case .statusQueryEvidenceMissingOrInvalid:
            .statusQueryEvidenceMissingOrInvalid
        case .reconciliationEvidenceMissing:
            .reconciliationEvidenceMissing
        case .recoveryReportMissingOrInvalid:
            .recoveryReportMissingOrInvalid
        case .namespaceMismatch:
            .namespaceMismatch
        case .reconciliationMismatch:
            .reconciliationMismatch
        case .boundaryDrift:
            .boundaryDrift
        }
    }

    private static func nextAction(
        forReplayFailure reason: ReleaseV0180CancelStatusReconciliationReplayFailureReason
    ) -> ReleaseV0180OperatorNextAction {
        switch reason {
        case .namespaceMismatch, .reconciliationMismatch, .boundaryDrift:
            .stop
        case .statusQueryEvidenceMissingOrInvalid:
            .retry
        case .resumeEvidenceMissingOrInvalid,
             .reconciliationEvidenceMissing,
             .recoveryReportMissingOrInvalid:
            .manualReview
        }
    }
}

private func releaseV0180OperatorFailureCLISHA256(_ parts: [String]) -> String {
    let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    return "sha256:\(digest)"
}
