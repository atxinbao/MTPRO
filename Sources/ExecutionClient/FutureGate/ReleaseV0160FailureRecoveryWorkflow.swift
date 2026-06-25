import DomainModel
import Foundation

// GH-1109 static contract boundary:
// failureRecoveryWorkflow=ReleaseV0160FailureRecoveryWorkflowEngine
// submitSucceededArtifactWriteFailedCovered=true
// networkTimeoutPossibleExchangeReceiptCovered=true
// cancelUnknownStateCovered=true
// statusQueryCompensationWorkflowCovered=true
// noAutomaticRetryIntoProduction=true
// localRecoveryEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0160FailureRecoveryWorkflowError 描述 GH-1109 本地恢复工作流的 fail-closed 错误。
///
/// 该错误只覆盖 Binance Spot Testnet operator beta 的本地恢复证据。恢复工作流可以要求
/// operator 先执行 signed status query compensation，但它自身不读取 secret、不连接 endpoint、
/// 不自动 retry submit / cancel，也不授权 production cutover。
public enum ReleaseV0160FailureRecoveryWorkflowError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyEvidence(String)
    case missingScenario(ReleaseV0160FailureRecoveryScenario)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .emptyEvidence(field):
            "Release v0.16.0 failure recovery workflow requires non-empty evidence: \(field)"
        case let .missingScenario(scenario):
            "Release v0.16.0 failure recovery workflow missing scenario: \(scenario.rawValue)"
        case let .boundaryDrift(field):
            "Release v0.16.0 failure recovery workflow boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160FailureRecoveryScenario 固定 #1109 必须覆盖的 ambiguous failure 场景。
public enum ReleaseV0160FailureRecoveryScenario: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitSucceededArtifactWriteFailed = "submit-succeeded-artifact-write-failed"
    case networkTimeoutPossibleExchangeReceipt = "network-timeout-possible-exchange-receipt"
    case cancelUnknownState = "cancel-unknown-state"
    case statusQueryCompensationWorkflow = "status-query-compensation-workflow"
}

/// ReleaseV0160FailureRecoveryOperatorAction 是 operator 恢复 runbook 的本地动作。
///
/// 这些动作只描述恢复步骤，不代表自动网络请求。`runStatusQueryCompensation` 表示必须由
/// 已授权的 #1105 status query flow 产生新的脱敏 artifact 后，再进入 #1107 reconciliation。
public enum ReleaseV0160FailureRecoveryOperatorAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case freezeRun = "freeze-run"
    case quarantinePartialArtifact = "quarantine-partial-artifact"
    case preserveRedactedTransportEvidence = "preserve-redacted-transport-evidence"
    case runStatusQueryCompensation = "run-status-query-compensation"
    case reconcileObservedStatus = "reconcile-observed-status"
    case requireOperatorReview = "require-operator-review"
    case closeFailedNoRetry = "close-failed-no-retry"
}

/// ReleaseV0160FailureRecoveryCase 是单个 ambiguous 状态的恢复证据。
///
/// Case 必须显式记录是否需要 status query compensation、是否隔离 partial artifact、
/// 是否承认 exchange receipt 可能已存在，以及是否阻断自动 retry。它只保存本地 ID、
/// checksum / report reference 和脱敏状态，不保存 raw request、raw response、API key、
/// secret、broker payload 或 production endpoint。
public struct ReleaseV0160FailureRecoveryCase: Codable, Equatable, Sendable {
    public let caseID: Identifier
    public let scenario: ReleaseV0160FailureRecoveryScenario
    public let sourceRunID: Identifier
    public let sourceArtifactRecordID: Identifier?
    public let sourceReconciliationReportID: Identifier?
    public let observedExchangeState: String
    public let operatorActionPlan: [ReleaseV0160FailureRecoveryOperatorAction]
    public let statusQueryCompensationRequired: Bool
    public let partialArtifactQuarantined: Bool
    public let possibleExchangeReceiptAcknowledged: Bool
    public let automaticRetryBlocked: Bool
    public let productionRetryBlocked: Bool
    public let failClosed: Bool
    public let localRecoveryEvidenceOnly: Bool
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

    public init(
        scenario: ReleaseV0160FailureRecoveryScenario,
        sourceRunID: Identifier,
        sourceArtifactRecordID: Identifier?,
        sourceReconciliationReportID: Identifier?,
        observedExchangeState: String,
        operatorActionPlan: [ReleaseV0160FailureRecoveryOperatorAction],
        statusQueryCompensationRequired: Bool,
        partialArtifactQuarantined: Bool = false,
        possibleExchangeReceiptAcknowledged: Bool = false,
        automaticRetryBlocked: Bool = true,
        productionRetryBlocked: Bool = true,
        failClosed: Bool = true,
        localRecoveryEvidenceOnly: Bool = true,
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
        guard sourceRunID.rawValue.isEmpty == false else {
            throw ReleaseV0160FailureRecoveryWorkflowError.emptyEvidence("sourceRunID")
        }
        let normalizedState = observedExchangeState.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedState.isEmpty == false else {
            throw ReleaseV0160FailureRecoveryWorkflowError.emptyEvidence("observedExchangeState")
        }
        self.caseID = Self.deterministicID(
            scenario: scenario,
            sourceRunID: sourceRunID,
            sourceArtifactRecordID: sourceArtifactRecordID,
            sourceReconciliationReportID: sourceReconciliationReportID,
            observedExchangeState: normalizedState
        )
        self.scenario = scenario
        self.sourceRunID = sourceRunID
        self.sourceArtifactRecordID = sourceArtifactRecordID
        self.sourceReconciliationReportID = sourceReconciliationReportID
        self.observedExchangeState = normalizedState
        self.operatorActionPlan = operatorActionPlan
        self.statusQueryCompensationRequired = statusQueryCompensationRequired
        self.partialArtifactQuarantined = partialArtifactQuarantined
        self.possibleExchangeReceiptAcknowledged = possibleExchangeReceiptAcknowledged
        self.automaticRetryBlocked = automaticRetryBlocked
        self.productionRetryBlocked = productionRetryBlocked
        self.failClosed = failClosed
        self.localRecoveryEvidenceOnly = localRecoveryEvidenceOnly
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

        guard caseHeld else {
            throw ReleaseV0160FailureRecoveryWorkflowError.boundaryDrift("case.\(scenario.rawValue)")
        }
    }

    public var caseHeld: Bool {
        caseID == Self.deterministicID(
            scenario: scenario,
            sourceRunID: sourceRunID,
            sourceArtifactRecordID: sourceArtifactRecordID,
            sourceReconciliationReportID: sourceReconciliationReportID,
            observedExchangeState: observedExchangeState
        )
            && sourceRunID.rawValue.isEmpty == false
            && observedExchangeState.isEmpty == false
            && operatorActionPlan.isEmpty == false
            && requiredActionsHeld
            && scenarioFlagsHeld
            && automaticRetryBlocked
            && productionRetryBlocked
            && failClosed
            && localRecoveryEvidenceOnly
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
    }

    public var requiresManualStatusCompensation: Bool {
        statusQueryCompensationRequired
            && operatorActionPlan.contains(.runStatusQueryCompensation)
            && operatorActionPlan.contains(.reconcileObservedStatus)
    }

    private var requiredActionsHeld: Bool {
        operatorActionPlan.contains(.freezeRun)
            && operatorActionPlan.contains(.requireOperatorReview)
            && operatorActionPlan.contains(.closeFailedNoRetry)
    }

    private var scenarioFlagsHeld: Bool {
        switch scenario {
        case .submitSucceededArtifactWriteFailed:
            partialArtifactQuarantined
                && requiresManualStatusCompensation
                && possibleExchangeReceiptAcknowledged
        case .networkTimeoutPossibleExchangeReceipt:
            requiresManualStatusCompensation
                && possibleExchangeReceiptAcknowledged
        case .cancelUnknownState:
            requiresManualStatusCompensation
        case .statusQueryCompensationWorkflow:
            requiresManualStatusCompensation
                && sourceReconciliationReportID != nil
        }
    }

    public static func deterministicID(
        scenario: ReleaseV0160FailureRecoveryScenario,
        sourceRunID: Identifier,
        sourceArtifactRecordID: Identifier?,
        sourceReconciliationReportID: Identifier?,
        observedExchangeState: String
    ) -> Identifier {
        .constant(
            [
                "gh-1109-v0160-failure-recovery-case",
                scenario.rawValue,
                sourceRunID.rawValue,
                sourceArtifactRecordID?.rawValue ?? "missing-artifact",
                sourceReconciliationReportID?.rawValue ?? "pending-reconciliation",
                observedExchangeState
            ].joined(separator: ":"),
            field: "releaseV0160FailureRecoveryWorkflow.caseID"
        )
    }
}

/// ReleaseV0160FailureRecoveryWorkflowReport 汇总 #1109 的恢复 runbook evidence。
public struct ReleaseV0160FailureRecoveryWorkflowReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let reportID: Identifier
    public let sourceRunID: Identifier
    public let cases: [ReleaseV0160FailureRecoveryCase]
    public let scenarioCoverage: [ReleaseV0160FailureRecoveryScenario]
    public let submitSucceededArtifactWriteFailedCovered: Bool
    public let networkTimeoutPossibleExchangeReceiptCovered: Bool
    public let cancelUnknownStateCovered: Bool
    public let statusQueryCompensationWorkflowCovered: Bool
    public let noAutomaticRetryIntoProduction: Bool
    public let localRecoveryEvidenceOnly: Bool
    public let recoveryRunbookEvidenceWritten: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        sourceRunID: Identifier,
        cases: [ReleaseV0160FailureRecoveryCase],
        issueID: Identifier = Identifier.constant("GH-1109"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-1106"),
            Identifier.constant("GH-1107"),
            Identifier.constant("GH-1108")
        ],
        releaseVersion: String = "v0.16.0",
        noAutomaticRetryIntoProduction: Bool = true,
        localRecoveryEvidenceOnly: Bool = true,
        recoveryRunbookEvidenceWritten: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceRunID.rawValue.isEmpty == false else {
            throw ReleaseV0160FailureRecoveryWorkflowError.emptyEvidence("sourceRunID")
        }
        guard cases.isEmpty == false, cases.allSatisfy(\.caseHeld) else {
            throw ReleaseV0160FailureRecoveryWorkflowError.boundaryDrift("report.cases")
        }
        for scenario in ReleaseV0160FailureRecoveryScenario.allCases where cases.contains(where: { $0.scenario == scenario }) == false {
            throw ReleaseV0160FailureRecoveryWorkflowError.missingScenario(scenario)
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.sourceRunID = sourceRunID
        self.cases = cases
        self.scenarioCoverage = ReleaseV0160FailureRecoveryScenario.allCases
        self.submitSucceededArtifactWriteFailedCovered = cases.contains { $0.scenario == .submitSucceededArtifactWriteFailed }
        self.networkTimeoutPossibleExchangeReceiptCovered = cases.contains { $0.scenario == .networkTimeoutPossibleExchangeReceipt }
        self.cancelUnknownStateCovered = cases.contains { $0.scenario == .cancelUnknownState }
        self.statusQueryCompensationWorkflowCovered = cases.contains { $0.scenario == .statusQueryCompensationWorkflow }
        self.noAutomaticRetryIntoProduction = noAutomaticRetryIntoProduction
        self.localRecoveryEvidenceOnly = localRecoveryEvidenceOnly
        self.recoveryRunbookEvidenceWritten = recoveryRunbookEvidenceWritten
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
        self.reportID = Self.deterministicID(sourceRunID: sourceRunID, caseIDs: cases.map(\.caseID))

        guard reportHeld else {
            throw ReleaseV0160FailureRecoveryWorkflowError.boundaryDrift("report.boundaryHeld")
        }
    }

    public var reportHeld: Bool {
        issueID.rawValue == "GH-1109"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1106", "GH-1107", "GH-1108"]
            && releaseVersion == "v0.16.0"
            && reportID == Self.deterministicID(sourceRunID: sourceRunID, caseIDs: cases.map(\.caseID))
            && sourceRunID.rawValue.isEmpty == false
            && cases.allSatisfy(\.caseHeld)
            && scenarioCoverage == ReleaseV0160FailureRecoveryScenario.allCases
            && submitSucceededArtifactWriteFailedCovered
            && networkTimeoutPossibleExchangeReceiptCovered
            && cancelUnknownStateCovered
            && statusQueryCompensationWorkflowCovered
            && cases.allSatisfy(\.automaticRetryBlocked)
            && cases.allSatisfy(\.productionRetryBlocked)
            && cases.allSatisfy(\.requiresManualStatusCompensation)
            && noAutomaticRetryIntoProduction
            && localRecoveryEvidenceOnly
            && recoveryRunbookEvidenceWritten
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1109-VERIFY-V0160-FAILURE-RECOVERY-WORKFLOW",
        "TVM-RELEASE-V0160-FAILURE-RECOVERY-WORKFLOW",
        "V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED",
        "V0160-009-NETWORK-TIMEOUT-POSSIBLE-EXCHANGE-RECEIPT",
        "V0160-009-CANCEL-UNKNOWN-STATE",
        "V0160-009-STATUS-QUERY-COMPENSATION-WORKFLOW",
        "V0160-009-NO-AUTOMATIC-PRODUCTION-RETRY",
        "V0160-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1109ReleaseV0160FailureRecoveryWorkflowHandlesAmbiguousStatesFailClosed",
        "bash checks/verify-v0.16.0-failure-recovery-workflow.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(sourceRunID: Identifier, caseIDs: [Identifier]) -> Identifier {
        .constant(
            [
                "gh-1109-v0160-failure-recovery-report",
                sourceRunID.rawValue,
                caseIDs.map(\.rawValue).joined(separator: ",")
            ].joined(separator: ":"),
            field: "releaseV0160FailureRecoveryWorkflow.reportID"
        )
    }
}

/// ReleaseV0160FailureRecoveryWorkflowEngine 是 #1109 的无状态本地恢复规划器。
///
/// Engine 只生成 operator recovery runbook evidence：freeze run、隔离 partial artifact、
/// 要求手动 status query compensation、再对接 #1107 reconciliation。它不自动 retry，
/// 不切换 production endpoint，也不发送 submit / cancel / replace。
public struct ReleaseV0160FailureRecoveryWorkflowEngine: Codable, Equatable, Sendable {
    public let engineID: Identifier
    public let submitSucceededArtifactWriteFailedCovered: Bool
    public let networkTimeoutPossibleExchangeReceiptCovered: Bool
    public let cancelUnknownStateCovered: Bool
    public let statusQueryCompensationWorkflowCovered: Bool
    public let noAutomaticRetryIntoProduction: Bool
    public let localRecoveryEvidenceOnly: Bool
    public let networkOrderActionPerformedByRecovery: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        engineID: Identifier = Identifier.constant("gh-1109-v0160-failure-recovery-workflow-engine"),
        submitSucceededArtifactWriteFailedCovered: Bool = true,
        networkTimeoutPossibleExchangeReceiptCovered: Bool = true,
        cancelUnknownStateCovered: Bool = true,
        statusQueryCompensationWorkflowCovered: Bool = true,
        noAutomaticRetryIntoProduction: Bool = true,
        localRecoveryEvidenceOnly: Bool = true,
        networkOrderActionPerformedByRecovery: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0160FailureRecoveryWorkflowReport.requiredValidationAnchors
    ) throws {
        self.engineID = engineID
        self.submitSucceededArtifactWriteFailedCovered = submitSucceededArtifactWriteFailedCovered
        self.networkTimeoutPossibleExchangeReceiptCovered = networkTimeoutPossibleExchangeReceiptCovered
        self.cancelUnknownStateCovered = cancelUnknownStateCovered
        self.statusQueryCompensationWorkflowCovered = statusQueryCompensationWorkflowCovered
        self.noAutomaticRetryIntoProduction = noAutomaticRetryIntoProduction
        self.localRecoveryEvidenceOnly = localRecoveryEvidenceOnly
        self.networkOrderActionPerformedByRecovery = networkOrderActionPerformedByRecovery
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard boundaryHeld else {
            throw ReleaseV0160FailureRecoveryWorkflowError.boundaryDrift("engine.boundaryHeld")
        }
    }

    public var boundaryHeld: Bool {
        engineID.rawValue.isEmpty == false
            && submitSucceededArtifactWriteFailedCovered
            && networkTimeoutPossibleExchangeReceiptCovered
            && cancelUnknownStateCovered
            && statusQueryCompensationWorkflowCovered
            && noAutomaticRetryIntoProduction
            && localRecoveryEvidenceOnly
            && networkOrderActionPerformedByRecovery == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0160FailureRecoveryWorkflowReport.requiredValidationAnchors
    }

    public func recover(
        replay: ReleaseV0160LocalExecutionArtifactReplay,
        reconciliationReport: ReleaseV0160OMSObservedStatusReconciliationReport
    ) throws -> ReleaseV0160FailureRecoveryWorkflowReport {
        guard boundaryHeld,
              replay.replayHeld,
              reconciliationReport.boundaryHeld,
              replay.runID == reconciliationReport.runID else {
            throw ReleaseV0160FailureRecoveryWorkflowError.boundaryDrift("engine.recover.source")
        }
        let recordsByKind = Dictionary(grouping: replay.records, by: \.kind)
        let submitArtifact = recordsByKind[.submit]?.last
        let cancelArtifact = recordsByKind[.cancel]?.last
        let statusArtifact = recordsByKind[.status]?.last
        let reportID = reconciliationReport.reportID
        let cases = try [
            ReleaseV0160FailureRecoveryCase(
                scenario: .submitSucceededArtifactWriteFailed,
                sourceRunID: replay.runID,
                sourceArtifactRecordID: submitArtifact?.recordID,
                sourceReconciliationReportID: reportID,
                observedExchangeState: "submit may have reached exchange but local artifact write failed",
                operatorActionPlan: [
                    .freezeRun,
                    .quarantinePartialArtifact,
                    .preserveRedactedTransportEvidence,
                    .runStatusQueryCompensation,
                    .reconcileObservedStatus,
                    .requireOperatorReview,
                    .closeFailedNoRetry
                ],
                statusQueryCompensationRequired: true,
                partialArtifactQuarantined: true,
                possibleExchangeReceiptAcknowledged: true
            ),
            ReleaseV0160FailureRecoveryCase(
                scenario: .networkTimeoutPossibleExchangeReceipt,
                sourceRunID: replay.runID,
                sourceArtifactRecordID: submitArtifact?.recordID,
                sourceReconciliationReportID: reportID,
                observedExchangeState: "network timeout without definitive exchange receipt",
                operatorActionPlan: [
                    .freezeRun,
                    .preserveRedactedTransportEvidence,
                    .runStatusQueryCompensation,
                    .reconcileObservedStatus,
                    .requireOperatorReview,
                    .closeFailedNoRetry
                ],
                statusQueryCompensationRequired: true,
                possibleExchangeReceiptAcknowledged: true
            ),
            ReleaseV0160FailureRecoveryCase(
                scenario: .cancelUnknownState,
                sourceRunID: replay.runID,
                sourceArtifactRecordID: cancelArtifact?.recordID ?? statusArtifact?.recordID,
                sourceReconciliationReportID: reportID,
                observedExchangeState: reconciliationReport.observedStatus.rawValue,
                operatorActionPlan: [
                    .freezeRun,
                    .runStatusQueryCompensation,
                    .reconcileObservedStatus,
                    .requireOperatorReview,
                    .closeFailedNoRetry
                ],
                statusQueryCompensationRequired: true
            ),
            ReleaseV0160FailureRecoveryCase(
                scenario: .statusQueryCompensationWorkflow,
                sourceRunID: replay.runID,
                sourceArtifactRecordID: statusArtifact?.recordID,
                sourceReconciliationReportID: reportID,
                observedExchangeState: "manual status query compensation precedes reconciliation",
                operatorActionPlan: [
                    .freezeRun,
                    .runStatusQueryCompensation,
                    .reconcileObservedStatus,
                    .requireOperatorReview,
                    .closeFailedNoRetry
                ],
                statusQueryCompensationRequired: true
            )
        ]
        return try ReleaseV0160FailureRecoveryWorkflowReport(
            sourceRunID: replay.runID,
            cases: cases
        )
    }
}
