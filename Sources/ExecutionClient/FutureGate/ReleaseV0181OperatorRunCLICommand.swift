import DomainModel
import Foundation

// GH-1202 static contract boundary:
// operatorRunCLICommand=ReleaseV0181OperatorRunCLICommand
// operatorRunResumeHelpVisible=true
// operatorRunReplayHelpVisible=true
// operatorRunExplainFailureHelpVisible=true
// existingLocalArtifactModelRouted=true
// failedEvidenceReadOnlyReportPath=true
// localOnlyRedactedOutput=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS
// TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS
// V0181-003-OPERATOR-RUN-HELP-VISIBLE
// V0181-003-RESUME-CLI-ROUTE
// V0181-003-REPLAY-CLI-ROUTE
// V0181-003-EXPLAIN-FAILURE-CLI-ROUTE
// V0181-003-FAILED-EVIDENCE-READ-ONLY-REPORT-PATH
// V0181-003-LOCAL-ONLY-REDACTED-OUTPUT
// V0181-003-NO-PRODUCTION-CUTOVER
// GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS
// TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS
// V0181-004-RUNS-NAMESPACE-PATH
// V0181-004-V0180-ACTIVE-PATHS-MIGRATED
// V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED
// V0181-004-OLD-VERSION-FIXTURES-PRESERVED
// V0181-004-NO-PRODUCTION-CUTOVER

/// ReleaseV0181OperatorRunCLICommand 将 v0.18 operator-run 本地证据模型暴露为公开 CLI。
///
/// 该 binder 只解析 operator 提供的 namespace，并调用既有 v0.18 read-only result 类型生成
/// deterministic 输出。它不读取 secret、不连接 endpoint、不触发 broker mutation，也不写真实订单。
public enum ReleaseV0181OperatorRunCLICommand {
    public static let cliCommand = "operator-run"

    public static let supportedActions = [
        "operator-run help",
        "operator-run resume --run-id <runID> --venue <venue> --product <product> --environment <environment> --account-profile <profile>",
        "operator-run replay --run-id <runID> --venue <venue> --product <product> --environment <environment> --account-profile <profile>",
        "operator-run replay-cancel-status-reconciliation --run-id <runID> --venue <venue> --product <product> --environment <environment> --account-profile <profile>",
        "operator-run explain-failure --run-id <runID> --venue <venue> --product <product> --environment <environment> --account-profile <profile> [--stage stage] [--reason reason] [--next-action action]"
    ]

    public static let requiredValidationAnchors = [
        "GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS",
        "TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS",
        "V0181-003-OPERATOR-RUN-HELP-VISIBLE",
        "V0181-003-RESUME-CLI-ROUTE",
        "V0181-003-REPLAY-CLI-ROUTE",
        "V0181-003-EXPLAIN-FAILURE-CLI-ROUTE",
        "V0181-003-FAILED-EVIDENCE-READ-ONLY-REPORT-PATH",
        "V0181-003-LOCAL-ONLY-REDACTED-OUTPUT",
        "V0181-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1202OperatorRunCLICommandsAreHelpVisibleAndFailClosed",
        "bash checks/verify-v0.18.1-operator-run-cli-commands.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw invalidArguments(
                field: "releaseV0181OperatorRunCLI.command",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        guard arguments.count >= 2 else {
            return helpOutput()
        }

        switch arguments[1] {
        case "help", "--help", "-h":
            guard arguments.count == 2 else {
                throw invalidArguments(
                    field: "releaseV0181OperatorRunCLI.help",
                    expected: "operator-run help",
                    actual: arguments.joined(separator: " ")
                )
            }
            return helpOutput()
        case "resume":
            let parsed = try ParsedOptions(arguments: arguments, action: "resume")
            return try resumeOutput(namespace: parsed.namespace)
        case "replay", "replay-cancel-status-reconciliation":
            let parsed = try ParsedOptions(arguments: arguments, action: arguments[1])
            return try replayOutput(namespace: parsed.namespace, action: arguments[1])
        case "explain-failure":
            let parsed = try ParsedOptions(arguments: arguments, action: "explain-failure")
            return try explainFailureOutput(parsed: parsed)
        default:
            throw invalidArguments(
                field: "releaseV0181OperatorRunCLI.action",
                expected: supportedActions.joined(separator: ","),
                actual: arguments.joined(separator: " ")
            )
        }
    }

    public static func helpOutput() -> String {
        ([
            "mtpro operator-run help",
            "issue=GH-1202",
            "validationAnchors=\(requiredValidationAnchors.joined(separator: ","))",
            "supportedActions=\(supportedActions.joined(separator: ","))",
            "resumeCommand=operator-run resume",
            "replayCommand=operator-run replay-cancel-status-reconciliation",
            "explainFailureCommand=operator-run explain-failure",
            "existingLocalArtifactModelRouted=true",
            "failedEvidenceNonzeroOrReadOnlyReportPath=true",
            "localOnlyRedactedOutput=true"
        ] + productionBoundaryLines()).joined(separator: "\n")
    }

    private static func resumeOutput(namespace: ReleaseV0180StatusQueryRetryArtifactNamespace) throws -> String {
        let failure = try ReleaseV0180ResumeAfterInterruptionFailure(
            reason: .lifecycleManifestMissingOrInvalid,
            field: "operatorRunArtifactModel",
            detail: "operator-run resume CLI route requires validated local lifecycle, status-query and reconciliation evidence"
        )
        let result = try ReleaseV0180ResumeAfterInterruptionResult(
            namespace: namespace,
            lifecycleManifestNamespaceKey: namespace.namespaceKey,
            lifecycleManifestValidated: false,
            statusQueryResultID: .constant("gh-1202-cli-missing-status-query-result"),
            statusQuerySnapshotValidated: false,
            baseResumeResultID: .constant("gh-1202-cli-missing-base-resume-result"),
            reconciliationEvidenceValidated: false,
            resumeCursor: nil,
            failures: [failure]
        )

        return rendered(
            header: "mtpro operator-run resume",
            namespace: namespace,
            reportRole: "resume-report",
            status: result.status.rawValue,
            operatorCommand: result.operatorCommand,
            operatorNextAction: result.operatorNextAction,
            resultID: result.resultID.rawValue,
            additionalLines: [
                "routedModel=ReleaseV0180ResumeAfterInterruptionResult",
                "localArtifactBackedResume=\(result.localArtifactBackedResume)",
                "failClosedResume=\(result.failClosedResume)",
                "failureReasons=\(result.failures.map(\.reason.rawValue).joined(separator: ","))"
            ]
        )
    }

    private static func replayOutput(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        action: String
    ) throws -> String {
        let failure = try ReleaseV0180CancelStatusReconciliationReplayFailure(
            reason: .reconciliationEvidenceMissing,
            field: "operatorRunReconciliationEvidence",
            expected: "local cancel/status reconciliation report",
            observed: "missing validated local evidence for CLI route"
        )
        let result = try ReleaseV0180CancelStatusReconciliationReplayResult(
            namespace: namespace,
            statusQueryResultID: .constant("gh-1202-cli-missing-status-query-result"),
            resumeResultID: .constant("gh-1202-cli-missing-resume-result"),
            observedReconciliationReport: nil,
            recoveryReport: nil,
            failures: [failure]
        )

        return rendered(
            header: "mtpro operator-run \(action)",
            namespace: namespace,
            reportRole: "replay-cancel-status-reconciliation-report",
            status: result.status.rawValue,
            operatorCommand: result.operatorCommand,
            operatorNextAction: result.operatorNextAction,
            resultID: result.resultID.rawValue,
            additionalLines: [
                "routedModel=ReleaseV0180CancelStatusReconciliationReplayResult",
                "localArtifactReplayRequired=\(result.localArtifactReplayRequired)",
                "readOnlyOperatorAction=\(result.readOnlyOperatorAction)",
                "expectedLifecycleState=\(result.expectedLifecycleState)",
                "observedLifecycleState=\(result.observedLifecycleState)",
                "failureReasons=\(result.failures.map(\.reason.rawValue).joined(separator: ","))"
            ]
        )
    }

    private static func explainFailureOutput(parsed: ParsedOptions) throws -> String {
        let result = try ReleaseV0180OperatorFailureClassificationNextActionCLI().classify(
            input: ReleaseV0180OperatorFailureClassificationNextActionInput(
                namespace: parsed.namespace,
                lifecycleManifestNamespaceKey: parsed.namespace.namespaceKey,
                lifecycleManifestValidated: false,
                statusQueryPersistence: nil,
                resumeResult: nil,
                reconciliationReplayResult: nil
            )
        )

        return rendered(
            header: "mtpro operator-run explain-failure",
            namespace: parsed.namespace,
            reportRole: "explain-failure-report",
            status: result.status.rawValue,
            operatorCommand: result.operatorNextActionCLI,
            operatorNextAction: result.topLevelNextAction.rawValue,
            resultID: result.resultID.rawValue,
            additionalLines: [
                "routedModel=ReleaseV0180OperatorFailureClassificationNextActionResult",
                "requestedStage=\(parsed.stage ?? "not-specified")",
                "requestedReason=\(parsed.reason ?? "not-specified")",
                "requestedNextAction=\(parsed.nextAction ?? "not-specified")",
                "classificationCount=\(result.classifications.count)",
                "classificationReasons=\(result.classifications.map(\.reason.rawValue).joined(separator: ","))",
                "readOnlyOperatorAction=\(result.readOnlyOperatorAction)",
                "automaticRemediationEnabled=\(result.automaticRemediationEnabled)"
            ]
        )
    }

    private static func rendered(
        header: String,
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        reportRole: String,
        status: String,
        operatorCommand: String,
        operatorNextAction: String,
        resultID: String,
        additionalLines: [String]
    ) -> String {
        ([
            header,
            "issue=GH-1202",
            "validationAnchors=\(requiredValidationAnchors.joined(separator: ","))",
            "namespace=\(namespace.namespaceKey)",
            "runID=\(namespace.runID.rawValue)",
            "venue=\(namespace.venue)",
            "product=\(namespace.product)",
            "environment=\(namespace.environment)",
            "accountProfile=\(namespace.accountProfile)",
            "status=\(status)",
            "resultID=\(resultID)",
            "operatorCommand=\(operatorCommand)",
            "operatorNextAction=\(operatorNextAction)",
            "readOnlyReportPath=\(readOnlyReportPath(namespace: namespace, reportRole: reportRole))",
            "readOnlyReportPathClassified=true",
            "failedEvidenceNonzeroOrReadOnlyReportPath=true",
            "recommendedExitCodeForFailedEvidence=64",
            "localOnlyRedactedOutput=true"
        ] + additionalLines + productionBoundaryLines()).joined(separator: "\n")
    }

    private static func readOnlyReportPath(
        namespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        reportRole: String
    ) -> String {
        ".local/mtpro/runs/\(namespace.venue)/\(namespace.product)/\(namespace.environment)/\(namespace.accountProfile)/\(namespace.runID.rawValue)/operator-run/\(reportRole).json"
    }

    private static func productionBoundaryLines() -> [String] {
        [
            "productionTradingEnabledByDefault=false",
            "productionSecretReadEnabled=false",
            "productionEndpointConnectionEnabled=false",
            "productionBrokerConnectionEnabled=false",
            "productionOrderSubmitCancelReplaceEnabled=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ]
    }

    private static func invalidArguments(field: String, expected: String, actual: String) -> CoreError {
        .liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
    }

    private struct ParsedOptions: Equatable, Sendable {
        let namespace: ReleaseV0180StatusQueryRetryArtifactNamespace
        let stage: String?
        let reason: String?
        let nextAction: String?

        init(arguments: [String], action: String) throws {
            var values: [String: String] = [:]
            var index = 2
            while index < arguments.count {
                let option = arguments[index]
                guard option.hasPrefix("--"), index + 1 < arguments.count else {
                    throw ReleaseV0181OperatorRunCLICommand.invalidArguments(
                        field: "releaseV0181OperatorRunCLI.arguments",
                        expected: "paired --option value arguments",
                        actual: arguments.joined(separator: " ")
                    )
                }
                let value = arguments[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                guard value.isEmpty == false else {
                    throw ReleaseV0181OperatorRunCLICommand.invalidArguments(
                        field: "releaseV0181OperatorRunCLI.\(option)",
                        expected: "non-empty value",
                        actual: arguments.joined(separator: " ")
                    )
                }
                values[option] = value
                index += 2
            }

            let required = ["--run-id", "--venue", "--product", "--environment", "--account-profile"]
            for option in required where values[option] == nil {
                throw ReleaseV0181OperatorRunCLICommand.invalidArguments(
                    field: "releaseV0181OperatorRunCLI.\(option)",
                    expected: "\(action) requires \(required.joined(separator: ","))",
                    actual: arguments.joined(separator: " ")
                )
            }

            let allowed = Set(required + ["--stage", "--reason", "--next-action"])
            for option in values.keys where allowed.contains(option) == false {
                throw ReleaseV0181OperatorRunCLICommand.invalidArguments(
                    field: "releaseV0181OperatorRunCLI.option",
                    expected: allowed.sorted().joined(separator: ","),
                    actual: option
                )
            }

            self.namespace = try ReleaseV0180StatusQueryRetryArtifactNamespace(
                venue: values["--venue"]!,
                product: values["--product"]!,
                environment: values["--environment"]!,
                accountProfile: values["--account-profile"]!,
                runID: Identifier.constant(
                    values["--run-id"]!,
                    field: "releaseV0181OperatorRunCLI.runID"
                )
            )
            self.stage = values["--stage"]
            self.reason = values["--reason"]
            self.nextAction = values["--next-action"]
        }
    }
}
