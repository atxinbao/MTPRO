import Database
import DataClient
import DomainModel
import ExecutionClient
import ExecutionEngine
import Foundation
import Portfolio

// GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT
// GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE
// GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST
// GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES
// GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK
// GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES
// GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION
// GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE
// GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE
// GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE
// V0310-001-NO-DEFAULT-TRADING-CONTRACT
// V0310-002-CREDENTIAL-APPROVAL-GATE
// V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST
// V0310-004-CAPITAL-RISK-STALE-INPUT-GATES
// V0310-005-MANUAL-APPROVAL-RUN-LOCK
// V0310-006-KILL-NOTRADE-ROLLBACK-GATES
// V0310-007-SIGNED-READONLY-NO-MUTATION
// V0310-008-IMMUTABLE-AUDIT-BUNDLE
// V0310-009-READONLY-STATUS-SURFACE
// V0310-010-STAGE-AUDIT-RELEASE-DOCS
// GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE
// GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH
// GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY
// GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY
// GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION
// GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS
// GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX
// GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS
// GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES
// TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR
// V0311-001-RELEASE-PUBLICATION-AFTER-FULL-MATRIX
// V0311-002-ENDPOINT-METHOD-HOST-PATH-PRODUCT-FAMILY
// V0311-003-APPROVAL-SCOPE-EXPIRY-SOURCE-POLICY
// V0311-004-PERSISTENT-RUN-LOCK-REPLAY-PROTECTION
// V0311-005-EVIDENCE-ROOT-ARTIFACT-VALIDATION
// V0311-006-RISK-GATE-NEGATIVE-INPUTS
// V0311-007-NEGATIVE-REGRESSION-MATRIX
// V0311-008-V0310-PUBLICATION-FACTS
// V0311-009-STAGE-AUDIT-RELEASE-NOTES
// GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT
// GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE
// GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE
// GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL
// GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
// GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK
// GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP
// GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS
// GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE
// GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS
// V0320-001-CANARY-OPERATIONS-CONTRACT
// V0320-002-HUMAN-APPROVED-ENABLEMENT-BUNDLE
// V0320-003-STRICT-SIZE-CAP-FINAL-GATE
// V0320-004-SPOT-CANARY-SUBMIT-STATUS-CANCEL
// V0320-005-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
// V0320-006-OMS-RECONCILIATION-ROLLBACK
// V0320-007-KILL-NOTRADE-INCIDENT-STOP
// V0320-008-DASHBOARD-CLI-CANARY-STATUS
// V0320-009-AGGREGATE-VALIDATION-SUITE
// V0320-010-STAGE-AUDIT-RELEASE-DOCS

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output = try await MTPROStrictCLI.commandLineOutput(arguments: arguments)
    print(output)
} catch let error as ReleaseV0170CLIArtifactVerifyCommandFailedValidation {
    print(error.renderedOutput)
    Foundation.exit(error.exitCode)
} catch {
    print("mtpro error: \(error)")
    Foundation.exit(64)
}

/// MTPROCLIParserError 是 GH-727 strict CLI parser 的本地错误类型。
///
/// 它让未知命令在进入旧 release surface 前就失败，避免旧 v0.2 / v0.3 / v0.4
/// fallback 把不属于当前命令集合的输入误解释为历史验收入口。
private enum MTPROCLIParserError: Error, CustomStringConvertible, Equatable {
    case invalidArguments(field: String, expected: String, actual: String)

    var description: String {
        switch self {
        case let .invalidArguments(field, expected, actual):
            "\(field) expected \(expected), actual \(actual)"
        }
    }
}

/// MTPROStrictCLI 固定 GH-727 的严格命令路由。
///
/// 新 v0.10.1 readiness contract shape 继续暴露 `help`、`run`、`status`、`stop`、`recover`、
/// `monitor`、`verify`、`risk-policy` 和 `readiness` 等安全本地入口；历史
/// `rehearsal-status`、`unified-run-status`、`run-observer`、`run-detail-observer`、
/// `testnet-readonly-probe`、`verify-fast`、`verify-release` 仍可被显式调用。
/// 任何其他命令必须在这里失败，不得 fallback 到旧 release surface。
private enum MTPROStrictCLI {
    static let validationAnchor = "TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE"
    static let strictParserAnchor = "TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER"
    static let persistentLocalSessionVerificationAnchor = "GH-810-VERIFY-V080-CLI-LOCAL-SESSION"
    static let persistentLocalSessionAnchor = "TVM-RELEASE-V080-CLI-LOCAL-SESSION"
    static let riskPolicyProfileVerificationAnchor = "GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT"
    static let riskPolicyProfileAnchor = "TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT"
    static let releaseV080VerificationAnchor = "GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK"
    static let releaseV080ValidationAnchor = "TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
    static let releaseV090VerificationAnchor = "GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"
    static let releaseV090ValidationAnchor = "TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
    static let releaseV090OperatorUXVerificationAnchor = "GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX"
    static let releaseV090OperatorUXValidationAnchor = "TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX"
    static let releaseV0161ManualEvidenceBundleContentVerificationAnchor =
        "GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT"
    static let releaseV0161ManualEvidenceBundleContentValidationAnchor =
        "TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT"
    static let releaseV0161ManualEvidenceBundleContentRequiredAnchors = [
        "V0161-002-BUNDLE-SCHEMA-PARSED",
        "V0161-002-ACTION-SEQUENCE-CHECKED",
        "V0161-002-CHECKSUM-REFERENCES-CHECKED",
        "V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS",
        "V0161-002-NO-PRODUCTION-CUTOVER"
    ]
    static let releaseV0170CLIArtifactVerifyCommandVerificationAnchor =
        "GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND"
    static let releaseV0170CLIArtifactVerifyCommandValidationAnchor =
        "TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND"
    static let releaseV0170CLIArtifactVerifyCommandRequiredAnchors = [
        "GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND",
        "TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND",
        "V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY",
        "V0170-007-LOCAL-ONLY-NO-NETWORK",
        "V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT",
        "V0170-007-REDACTED-OUTPUT",
        "V0170-007-NO-PRODUCTION-CUTOVER"
    ]
    static let releaseV0171CLIArtifactVerifyFailClosedVerificationAnchor =
        "GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED"
    static let releaseV0171CLIArtifactVerifyFailClosedValidationAnchor =
        "TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED"
    static let releaseV0171CLIArtifactVerifyFailClosedRequiredAnchors = [
        "GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED",
        "TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED",
        "V0171-001-FAILED-VALIDATION-NONZERO-EXIT",
        "V0171-001-VALID-BUNDLE-EXIT-ZERO",
        "V0171-001-LOCAL-REPORTING-PATH-REDACTED",
        "V0171-001-NO-PRODUCTION-CUTOVER"
    ]
    static let releaseV0181OperatorRunCLICommandVerificationAnchor =
        "GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS"
    static let releaseV0181OperatorRunCLICommandValidationAnchor =
        "TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS"
    static let releaseV0181OperatorRunCLICommandRequiredAnchors = [
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
    // GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
    // TVM-RELEASE-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
    // V0190-009-CLI-REGISTRY-LIST
    // V0190-009-CLI-CAPABILITIES-INSPECT
    // V0190-009-CLI-EXPLAIN-UNSUPPORTED
    // V0190-009-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED
    // V0190-009-READ-ONLY-NO-COMMANDS
    // V0190-009-NO-PRODUCTION-CUTOVER
    static let releaseV0190VenueProductRegistryInspectVerificationAnchor =
        ReleaseV0190CLIVenueProductRegistryInspect.verificationAnchor
    static let releaseV0190VenueProductRegistryInspectValidationAnchor =
        ReleaseV0190CLIVenueProductRegistryInspect.validationAnchor
    // GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
    // TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
    // V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
    // V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER
    // V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES
    // V0200-010-DASHBOARD-CLI-NO-CONTROLS
    // V0200-010-NO-PRODUCTION-CUTOVER
    static let releaseV0200ReadOnlyLiveReadinessSurfaceVerificationAnchor =
        "GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE"
    static let releaseV0200ReadOnlyLiveReadinessSurfaceValidationAnchor =
        "TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE"
    // GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
    // TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
    // V0210-011-DASHBOARD-CLI-CANARY-STATUS
    // V0210-011-CANARY-STATE-GATES
    // V0210-011-RISK-ORDER-CANCEL-RECONCILIATION
    // V0210-011-READ-ONLY-NO-COMMANDS
    // V0210-011-NO-PRODUCTION-CUTOVER
    static let releaseV0210CanaryStatusSurfaceVerificationAnchor =
        "GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE"
    static let releaseV0210CanaryStatusSurfaceValidationAnchor =
        "TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE"
    static let releaseV0100VerificationAnchor = "GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
    static let releaseV0100ValidationAnchor = "TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
    static let cliVerifyV0100WordingAnchor = "GH-909-VERIFY-V0101-CLI-V0100-WORDING"
    static let cliVerifyV0100WordingValidationAnchor = "TVM-RELEASE-V0101-CLI-V0100-WORDING"
    static let cliVerifyV0100WordingRequiredAnchors = [
        "V0101-004-CLI-V0100-READINESS-CONTRACT-WORDING",
        "V0101-004-REFERENCE-EVIDENCE-MODEL",
        "V0101-004-NOT-OPERATIONAL-PRODUCTION-READINESS",
        "V0101-004-NO-PRODUCTION-CUTOVER",
        "V0101-004-NO-ENDPOINT-READINESS-CLAIM",
        "V0101-004-NO-LIVE-ORDER-AUTHORIZATION"
    ]
    static let readinessCLIHelpVerificationAnchor = "GH-910-VERIFY-V0101-READINESS-CLI-HELP"
    static let readinessCLIHelpValidationAnchor = "TVM-RELEASE-V0101-READINESS-CLI-HELP"
    static let readinessCLIHelpRequiredAnchors = [
        "V0101-005-READINESS-CLI-HELP-PLACEHOLDER",
        "V0101-005-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS",
        "V0101-005-NON-MUTATING-NO-ARTIFACT-WRITE",
        "V0101-005-NO-PRODUCTION-CUTOVER",
        "V0101-005-NO-PRODUCTION-SECRET-ENDPOINT-ORDER",
        "V0101-005-NO-READINESS-ARTIFACT-RUNTIME"
    ]
    static let readinessCLILocalArtifactsVerificationAnchor =
        "GH-920-VERIFY-V0110-READINESS-CLI-LOCAL-ARTIFACTS"
    static let readinessCLILocalArtifactsValidationAnchor =
        "TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS"
    static let readinessCLILocalArtifactsRequiredAnchors = [
        "V0110-008-READINESS-CLI-LOCAL-ARTIFACTS",
        "V0110-008-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS",
        "V0110-008-LOCAL-ARTIFACT-STORE-BUNDLE-VALIDATION",
        "V0110-008-MISSING-INVALID-STALE-CHECKSUM-MISMATCH",
        "V0110-008-NO-PRODUCTION-SECRET-ENDPOINT-ORDER"
    ]
    static let readinessAssessmentCLILifecycleVerificationAnchor =
        "GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE"
    static let readinessAssessmentCLILifecycleValidationAnchor =
        "TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE"
    static let readinessAssessmentCLILifecycleRequiredAnchors = [
        "V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE",
        "V0120-012-CREATE-BUILD-STATUS-VALIDATE-EXPORT-ARCHIVE",
        "V0120-012-COMPARE-LOCAL-ASSESSMENTS",
        "V0120-012-INVALID-ASSESSMENT-ID-FAIL-CLOSED",
        "V0120-012-LOCAL-REGISTRY-STORE-ONLY",
        "V0120-012-NO-PRODUCTION-CUTOVER"
    ]
    static let releaseV090OperatorUXRequiredAnchors = [
        "V090-013-DASHBOARD-CLI-OPERATOR-UX",
        "V090-013-MONITOR-START-STATUS-STOP-RECOVER-EXPORT",
        "V090-013-DASHBOARD-READ-STATE-TIMELINES-ALERTS-EXPORT",
        "V090-013-SAFE-LOCAL-READONLY-CONTROLS",
        "V090-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V090-013-NO-TESTNET-ORDER-ROUTING",
        "V090-013-NO-PRODUCTION-CUTOVER"
    ]
    static let cliVerifyV080WordingAnchor = "GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING"
    static let cliVerifyV080WordingValidationAnchor = "TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING"
    static let cliVerifyV080WordingRequiredAnchors = [
        "V081-003-CLI-VERIFY-V080-WORDING",
        "V081-003-HISTORICAL-V070-GUARDS",
        "V081-003-NO-PRODUCTION-CUTOVER"
    ]
    static let riskPolicyProfileRequiredAnchors = [
        "V080-010-RISK-POLICY-PROFILE-MANAGEMENT",
        "V080-010-RISK-POLICY-JSON-VERSION-HASH",
        "V080-010-DETERMINISTIC-POLICY-DIFF",
        "V080-010-OPERATOR-CHANGE-METADATA",
        "V080-010-RUN-APPLICATION-POLICY-REFERENCE",
        "V080-010-CLI-SHOW-VALIDATE-DIFF",
        "V080-010-NO-BROKER-ENDPOINT-OMS-ORDER-PATH"
    ]
    static let riskPolicySupportedActionCommands = [
        "risk-policy show",
        "risk-policy validate",
        "risk-policy diff"
    ]
    static let readinessSupportedActionCommands = [
        "readiness help",
        "readiness build",
        "readiness status",
        "readiness validate",
        "readiness export",
        "readiness approval-status",
        "readiness build-v013 <assessmentID> <evidenceRoot>",
        "readiness intake <evidenceRoot>"
    ]
    static let readinessAssessmentSupportedActionCommands = [
        "readiness create [assessmentID]",
        "readiness build <assessmentID>",
        "readiness status <assessmentID>",
        "readiness validate <assessmentID>",
        "readiness export <assessmentID>",
        "readiness archive <assessmentID>",
        "readiness compare <baselineAssessmentID> <followUpAssessmentID>"
    ]
    static let monitorSupportedActionCommands = [
        "monitor start",
        "monitor status",
        "monitor stop",
        "monitor recover",
        "monitor export"
    ]
    static let supportedCommands = [
        // GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
        // TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
        // V0220-010-BLOCKED-BY-GH1317
        // V0220-010-LIVE-CANARY-EVIDENCE-CHAIN
        // V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION
        // V0220-010-FAILURE-CLASS-NEXT-ACTION
        // V0220-010-READ-ONLY-DASHBOARD-CLI
        // V0220-010-REDACTION-FAILURE-STATES-VISIBLE
        // V0220-010-NO-TRADING-COMMANDS
        // V0220-010-NO-FUTURES-OKX
        // V0220-010-NO-PRODUCTION-CUTOVER
        // TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR
        // GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT
        // GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE
        // GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE
        // GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT
        // GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
        // GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE
        // GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION
        // GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS
        // TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN
        // V0300-001-OBSERVED-RUN-LIFECYCLE
        // V0300-001-NO-SUBMIT-CONTRACT
        // V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE
        // V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE
        // V0300-003-IMMUTABLE-MANIFEST-PROVENANCE
        // V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT
        // V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
        // V0300-006-DASHBOARD-CLI-READONLY-SURFACE
        // V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION
        // V0300-008-STAGE-AUDIT-RELEASE-DOCS
        "help",
        "run",
        "status",
        "stop",
        "recover",
        "risk-policy",
        "readiness",
        "monitor",
        "verify",
        ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
        ReleaseV0160CLISubmitExecutionFlow.cliCommand,
        ReleaseV0160CLICancelExecutionFlow.cliCommand,
        ReleaseV0160CLIOrderStatusQueryFlow.cliCommand,
        "validate-manual-evidence-bundle",
        ReleaseV0170CLIArtifactVerifyCommand.cliCommand,
        ReleaseV0181OperatorRunCLICommand.cliCommand,
        ReleaseV0190CLIVenueProductRegistryInspect.cliCommand,
        ReleaseV0200ReadOnlyLiveReadinessSurface.cliCommand,
        ReleaseV0210CanaryStatusReadOnlySurface.cliCommand,
        ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.cliCommand,
        ReleaseV0230FuturesReadOnlyFoundationEvidence.cliCommand,
        ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.cliCommand,
        ReleaseV0250DualProductProductionReadinessContract.cliCommand,
        ReleaseV0250OperatorReadinessSurface.cliCommand,
        ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.cliCommand,
        ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.cliCommand,
        ReleaseV0280ProductionCutoverReadinessGate.cliCommand,
        ReleaseV0290ProductionDryRunShadowAcceptance.cliCommand,
        ReleaseV0300ObservedProductionShadowRun.cliCommand,
        ReleaseV0310ControlledProductionEnablementGate.cliCommand,
        ReleaseV0311ControlledEnablementIntegrityRepair.cliCommand,
        ReleaseV0320ControlledProductionCanaryOperations.cliCommand,
        // GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
        // GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256
        // GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK
        // GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX
        // GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
        // GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
        // GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE
        // GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS
        // TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR
        // V0321-001-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
        // V0321-002-EVIDENCE-ROOT-MANIFEST-SHA256
        // V0321-003-APPROVAL-SCOPE-RUN-LOCK
        // V0321-004-CAP-VALIDATION-NEGATIVE-MATRIX
        // V0321-005-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
        // V0321-006-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
        // V0321-007-FULL-MATRIX-BEFORE-RELEASE
        // V0321-008-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS
        ReleaseV0321ControlledCanaryIntegrityRepair.cliCommand,
        // GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX
        // GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY
        // GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS
        // GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY
        // GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE
        // GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT
        // TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH
        // V0322-001-RELEASE-CREATION-BEHIND-FULL-MATRIX
        // V0322-002-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY
        // V0322-003-COMMIT-CLOCK-APPROVAL-FRESHNESS
        // V0322-004-ATOMIC-RUN-LOCK-REPLAY-REGISTRY
        // V0322-005-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE
        // V0322-006-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT
        ReleaseV0322ControlledCanaryIntegrityClosurePatch.cliCommand,
        ReleaseV0330DemoCanaryCLI.cliCommand,
        ReleaseV0330DemoCanaryCLI.prepareCommand,
        ReleaseV030CLIRehearsalSurface.cliCommand,
        ReleaseV040UnifiedRunSurface.cliCommand,
        ReleaseV050RunObserverSurface.cliCommand,
        ReleaseV060RunDetailObserverSurface.cliCommand,
        ReleaseV060TestnetReadOnlyProbe.cliCommand,
        "verify-fast",
        "verify-release"
    ]
    static let publicHelpCommands = [
        "help",
        "run",
        "status",
        "stop",
        "recover",
        "risk-policy",
        "readiness",
        "monitor",
        "verify",
        ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
        ReleaseV0160CLISubmitExecutionFlow.cliCommand,
        ReleaseV0160CLICancelExecutionFlow.cliCommand,
        ReleaseV0160CLIOrderStatusQueryFlow.cliCommand,
        ReleaseV0181OperatorRunCLICommand.cliCommand,
        ReleaseV0190CLIVenueProductRegistryInspect.cliCommand,
        ReleaseV0200ReadOnlyLiveReadinessSurface.cliCommand,
        ReleaseV0210CanaryStatusReadOnlySurface.cliCommand,
        ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.cliCommand,
        ReleaseV0230FuturesReadOnlyFoundationEvidence.cliCommand,
        ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.cliCommand,
        ReleaseV0250DualProductProductionReadinessContract.cliCommand,
        ReleaseV0250OperatorReadinessSurface.cliCommand,
        ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.cliCommand,
        ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.cliCommand,
        ReleaseV0280ProductionCutoverReadinessGate.cliCommand,
        ReleaseV0290ProductionDryRunShadowAcceptance.cliCommand,
        ReleaseV0300ObservedProductionShadowRun.cliCommand,
        ReleaseV0310ControlledProductionEnablementGate.cliCommand,
        ReleaseV0311ControlledEnablementIntegrityRepair.cliCommand,
        ReleaseV0320ControlledProductionCanaryOperations.cliCommand,
        ReleaseV0321ControlledCanaryIntegrityRepair.cliCommand,
        ReleaseV0322ControlledCanaryIntegrityClosurePatch.cliCommand,
        ReleaseV030CLIRehearsalSurface.cliCommand,
        ReleaseV040UnifiedRunSurface.cliCommand,
        ReleaseV050RunObserverSurface.cliCommand,
        ReleaseV060RunDetailObserverSurface.cliCommand,
        ReleaseV060TestnetReadOnlyProbe.cliCommand,
        "verify-fast",
        "verify-release"
    ]

    static func commandLineOutput(arguments: [String]) async throws -> String {
        guard let command = arguments.first else {
            return helpOutput()
        }

        switch command {
        case "help", "--help", "-h":
            try requireExactCount(arguments, expected: 1, command: command)
            return helpOutput()
        case "run":
            return try runOutput(arguments: arguments)
        case "status":
            return try statusOutput(arguments: arguments)
        case "stop":
            return try stopOutput(arguments: arguments)
        case "recover":
            return try recoverOutput(arguments: arguments)
        case "risk-policy":
            return try riskPolicyOutput(arguments: arguments)
        case "readiness":
            return try readinessOutput(arguments: arguments)
        case "monitor":
            return try monitorOutput(arguments: arguments)
        case "verify":
            try requireExactCount(arguments, expected: 1, command: command)
            return verifyOutput()
        case ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand:
            return try await ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.commandLineOutput(arguments: arguments)
        case ReleaseV0160CLISubmitExecutionFlow.cliCommand:
            return try await ReleaseV0160CLISubmitExecutionFlow.commandLineOutput(arguments: arguments)
        case ReleaseV0160CLICancelExecutionFlow.cliCommand:
            return try await ReleaseV0160CLICancelExecutionFlow.commandLineOutput(arguments: arguments)
        case ReleaseV0160CLIOrderStatusQueryFlow.cliCommand:
            return try await ReleaseV0160CLIOrderStatusQueryFlow.commandLineOutput(arguments: arguments)
        case "validate-manual-evidence-bundle":
            try requireExactCount(arguments, expected: 2, command: command)
            return try ReleaseV0160ManualTestnetValidationWorkflow.contentValidationCommandOutput(
                bundlePath: arguments[1]
            )
        case ReleaseV0170CLIArtifactVerifyCommand.cliCommand:
            try requireExactCount(arguments, expected: 3, command: command)
            return try ReleaseV0170CLIArtifactVerifyCommand.commandLineOutput(arguments: arguments)
        case ReleaseV0181OperatorRunCLICommand.cliCommand:
            return try ReleaseV0181OperatorRunCLICommand.commandLineOutput(arguments: arguments)
        case ReleaseV0190CLIVenueProductRegistryInspect.cliCommand:
            return try ReleaseV0190CLIVenueProductRegistryInspect.commandLineOutput(arguments: arguments)
        case ReleaseV0200ReadOnlyLiveReadinessSurface.cliCommand:
            return try ReleaseV0200ReadOnlyLiveReadinessSurface.commandLineOutput(arguments: arguments)
        case ReleaseV0210CanaryStatusReadOnlySurface.cliCommand:
            return try ReleaseV0210CanaryStatusReadOnlySurface.commandLineOutput(arguments: arguments)
        case ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.cliCommand:
            return try ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.commandLineOutput(arguments: arguments)
        case ReleaseV0230FuturesReadOnlyFoundationEvidence.cliCommand:
            return try ReleaseV0230FuturesReadOnlyFoundationEvidence.commandLineOutput(arguments: arguments)
        case ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.cliCommand:
            return try ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.commandLineOutput(arguments: arguments)
        case ReleaseV0250DualProductProductionReadinessContract.cliCommand:
            return try ReleaseV0250DualProductProductionReadinessContract.commandLineOutput(arguments: arguments)
        case ReleaseV0250OperatorReadinessSurface.cliCommand:
            return try ReleaseV0250OperatorReadinessSurface.commandLineOutput(arguments: arguments)
        case ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.cliCommand:
            return try ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.commandLineOutput(
                arguments: arguments
            )
        case ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.cliCommand:
            return try ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.commandLineOutput(
                arguments: arguments
            )
        case ReleaseV0280ProductionCutoverReadinessGate.cliCommand:
            return try ReleaseV0280ProductionCutoverReadinessGate.commandLineOutput(arguments: arguments)
        case ReleaseV0290ProductionDryRunShadowAcceptance.cliCommand:
            return try ReleaseV0290ProductionDryRunShadowAcceptance.commandLineOutput(arguments: arguments)
        case ReleaseV0300ObservedProductionShadowRun.cliCommand:
            return try ReleaseV0300ObservedProductionShadowRun.commandLineOutput(arguments: arguments)
        case ReleaseV0310ControlledProductionEnablementGate.cliCommand:
            return try ReleaseV0310ControlledProductionEnablementGate.commandLineOutput(arguments: arguments)
        case ReleaseV0311ControlledEnablementIntegrityRepair.cliCommand:
            return try ReleaseV0311ControlledEnablementIntegrityRepair.commandLineOutput(arguments: arguments)
        case ReleaseV0320ControlledProductionCanaryOperations.cliCommand:
            return try ReleaseV0320ControlledProductionCanaryOperations.commandLineOutput(arguments: arguments)
        case ReleaseV0321ControlledCanaryIntegrityRepair.cliCommand:
            return try ReleaseV0321ControlledCanaryIntegrityRepair.commandLineOutput(arguments: arguments)
        case ReleaseV0322ControlledCanaryIntegrityClosurePatch.cliCommand:
            return try ReleaseV0322ControlledCanaryIntegrityClosurePatch.commandLineOutput(arguments: arguments)
        case ReleaseV0330DemoCanaryCLI.cliCommand:
            return try await ReleaseV0330DemoCanaryCLI.commandLineOutput(arguments: arguments)
        case ReleaseV0330DemoCanaryCLI.prepareCommand:
            return try ReleaseV0330DemoCanaryCLI.prepareConfigurationOutput(arguments: arguments)
        case ReleaseV030CLIRehearsalSurface.cliCommand:
            return try ReleaseV030CLIRehearsalSurface.commandLineOutput(arguments: arguments)
        case ReleaseV040UnifiedRunSurface.cliCommand:
            return try ReleaseV040UnifiedRunSurface.commandLineOutput(arguments: arguments)
        case ReleaseV050RunObserverSurface.cliCommand:
            return try await ReleaseV050RunObserverSurface.commandLineOutput(arguments: arguments)
        case ReleaseV060RunDetailObserverSurface.cliCommand:
            return try ReleaseV060RunDetailObserverSurface.commandLineOutput(arguments: arguments)
        case ReleaseV060TestnetReadOnlyProbe.cliCommand:
            return try await ReleaseV060TestnetReadOnlyProbe.commandLineOutput(arguments: arguments)
        case "verify-fast", "verify-release":
            return try ReleaseV020CLIProductSurface.commandLineOutput(arguments: arguments)
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.strict.arguments",
                expected: supportedCommands.joined(separator: ","),
                actual: arguments.joined(separator: " ")
            )
        }
    }

    static func unknownCommandRejected(_ arguments: [String]) async -> Bool {
        (try? await commandLineOutput(arguments: arguments)) == nil
    }

    private static func helpOutput() -> String {
        let commandList = publicHelpCommands.joined(separator: ",")
        return [
            "mtpro help",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "strictParserAnchor=\(strictParserAnchor)",
            "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
            "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
            "riskPolicyValidationAnchor=\(riskPolicyProfileAnchor)",
            "riskPolicyVerificationAnchor=\(riskPolicyProfileVerificationAnchor)",
            "commands=\(commandList)",
            "defaultMode=local-dry-run",
            "runtimeSessionContract=v0.7.0",
            "persistentLocalSessionContract=v0.8.0",
            "riskPolicyProfileContract=v0.8.0",
            "readinessContract=v0.11.0",
            "runtimeModes=local-dry-run,testnet-read-only-monitor,recovery-observe,production-blocked",
            "legacyRuntimeModes=testnet-read-only-probe",
            "localSessionActions=run,status,stop,recover",
            "riskPolicyActions=\(riskPolicySupportedActionCommands.joined(separator: ","))",
            "readinessActions=\(readinessSupportedActionCommands.joined(separator: ","))",
            "readinessAssessmentSessionContract=v0.12.0",
            "readinessAssessmentActions=\(readinessAssessmentSupportedActionCommands.joined(separator: ","))",
            "monitorActions=\(monitorSupportedActionCommands.joined(separator: ","))",
            "releaseV0150CLIOperatorCommand=\(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand)",
            "releaseV0150CLIOperatorValidationAnchor=TVM-RELEASE-V0150-CLI-OPERATOR-FLOW",
            "releaseV0150CLIOperatorVerificationAnchor=GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW",
            "releaseV0150CLIOperatorConfirmationPhrase=\(ReleaseV0150BinanceSpotTestnetCLIOperatorInput.requiredOperatorConfirmationPhrase)",
            "releaseV0160CLISubmitCommand=\(ReleaseV0160CLISubmitExecutionFlow.cliCommand)",
            "releaseV0160CLISubmitValidationAnchor=TVM-RELEASE-V0160-CLI-SUBMIT-FLOW",
            "releaseV0160CLISubmitVerificationAnchor=GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW",
            "releaseV0160CLISubmitConfirmationPhrase=\(ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase)",
            "releaseV0160CLICancelCommand=\(ReleaseV0160CLICancelExecutionFlow.cliCommand)",
            "releaseV0160CLICancelValidationAnchor=TVM-RELEASE-V0160-CLI-CANCEL-FLOW",
            "releaseV0160CLICancelVerificationAnchor=GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW",
            "releaseV0160CLICancelConfirmationPhrase=\(ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase)",
            "releaseV0160CLIOrderStatusQueryCommand=\(ReleaseV0160CLIOrderStatusQueryFlow.cliCommand)",
            "releaseV0160CLIOrderStatusQueryValidationAnchor=TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY",
            "releaseV0160CLIOrderStatusQueryVerificationAnchor=GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY",
            "releaseV0160CLIOrderStatusQueryConfirmationPhrase=\(ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase)",
            "releaseV0161ManualEvidenceBundleContentCommand=validate-manual-evidence-bundle",
            "releaseV0161ManualEvidenceBundleContentValidationAnchor=\(releaseV0161ManualEvidenceBundleContentValidationAnchor)",
            "releaseV0161ManualEvidenceBundleContentVerificationAnchor=\(releaseV0161ManualEvidenceBundleContentVerificationAnchor)",
            "releaseV0161ManualEvidenceBundleContentRequiredAnchors=\(releaseV0161ManualEvidenceBundleContentRequiredAnchors.joined(separator: ","))",
            "releaseV0170CLIArtifactVerifyCommand=\(ReleaseV0170CLIArtifactVerifyCommand.cliCommand)",
            "releaseV0170CLIArtifactVerifyCommandLiteral=verify-operator-beta-artifact-bundle",
            "releaseV0170CLIArtifactVerifyCommandValidationAnchor=\(releaseV0170CLIArtifactVerifyCommandValidationAnchor)",
            "releaseV0170CLIArtifactVerifyCommandVerificationAnchor=\(releaseV0170CLIArtifactVerifyCommandVerificationAnchor)",
            "releaseV0170CLIArtifactVerifyCommandRequiredAnchors=\(releaseV0170CLIArtifactVerifyCommandRequiredAnchors.joined(separator: ","))",
            "releaseV0171CLIArtifactVerifyFailClosedValidationAnchor=\(releaseV0171CLIArtifactVerifyFailClosedValidationAnchor)",
            "releaseV0171CLIArtifactVerifyFailClosedVerificationAnchor=\(releaseV0171CLIArtifactVerifyFailClosedVerificationAnchor)",
            "releaseV0171CLIArtifactVerifyFailClosedRequiredAnchors=\(releaseV0171CLIArtifactVerifyFailClosedRequiredAnchors.joined(separator: ","))",
            "releaseV0171CLIArtifactVerifyFailedValidationNonzeroExit=true",
            "releaseV0181OperatorRunCLICommand=\(ReleaseV0181OperatorRunCLICommand.cliCommand)",
            "releaseV0181OperatorRunCLICommandValidationAnchor=\(releaseV0181OperatorRunCLICommandValidationAnchor)",
            "releaseV0181OperatorRunCLICommandVerificationAnchor=\(releaseV0181OperatorRunCLICommandVerificationAnchor)",
            "releaseV0181OperatorRunCLICommandRequiredAnchors=\(releaseV0181OperatorRunCLICommandRequiredAnchors.joined(separator: ","))",
            "operatorRunActions=\(ReleaseV0181OperatorRunCLICommand.supportedActions.joined(separator: ","))",
            "releaseV0190VenueProductRegistryInspectCommand=\(ReleaseV0190CLIVenueProductRegistryInspect.cliCommand)",
            "releaseV0190VenueProductRegistryInspectValidationAnchor=\(releaseV0190VenueProductRegistryInspectValidationAnchor)",
            "releaseV0190VenueProductRegistryInspectVerificationAnchor=\(releaseV0190VenueProductRegistryInspectVerificationAnchor)",
            "venueProductRegistryInspectActions=\(ReleaseV0190CLIVenueProductRegistryInspect.supportedActions.joined(separator: ","))",
            "releaseV0200ReadOnlyLiveReadinessSurfaceCommand=\(ReleaseV0200ReadOnlyLiveReadinessSurface.cliCommand)",
            "releaseV0200ReadOnlyLiveReadinessSurfaceValidationAnchor=\(releaseV0200ReadOnlyLiveReadinessSurfaceValidationAnchor)",
            "releaseV0200ReadOnlyLiveReadinessSurfaceVerificationAnchor=\(releaseV0200ReadOnlyLiveReadinessSurfaceVerificationAnchor)",
            "releaseV0200ReadOnlyLiveReadinessSurfaceActions=status",
            "releaseV0210CanaryStatusSurfaceCommand=\(ReleaseV0210CanaryStatusReadOnlySurface.cliCommand)",
            "releaseV0210CanaryStatusSurfaceValidationAnchor=\(releaseV0210CanaryStatusSurfaceValidationAnchor)",
            "releaseV0210CanaryStatusSurfaceVerificationAnchor=\(releaseV0210CanaryStatusSurfaceVerificationAnchor)",
            "releaseV0210CanaryStatusSurfaceActions=status,events,reconciliation",
            "releaseV0220LiveCanaryEvidenceSurfaceCommand=\(ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.cliCommand)",
            "releaseV0220LiveCanaryEvidenceSurfaceValidationAnchor=TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
            "releaseV0220LiveCanaryEvidenceSurfaceVerificationAnchor=GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
            "releaseV0220LiveCanaryEvidenceSurfaceActions=status,failures,rollback,reconciliation",
            // GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT
            // TVM-RELEASE-V0230-FUTURES-READONLY-CONTRACT
            // V0230-001-BINANCE-USDM-FUTURES-READONLY-FOUNDATION
            // V0230-001-NO-FUTURES-ORDER-EXECUTION
            // GH-1342-VERIFY-V0230-FUTURES-PROFILE-ENDPOINT-ALLOWLIST
            // V0230-002-BINANCE-USDM-FUTURES-PROFILE
            // V0230-002-READ-ONLY-ENDPOINT-ALLOWLIST
            // GH-1343-VERIFY-V0230-FUTURES-CREDENTIAL-REFERENCE-GATE
            // V0230-003-CREDENTIAL-REFERENCE-ONLY
            // V0230-003-SIGNED-READONLY-APPROVAL-GATE
            // GH-1344-VERIFY-V0230-FUTURES-ACCOUNT-SNAPSHOT-REDACTION
            // V0230-004-REDACTED-ACCOUNT-SNAPSHOT
            // GH-1345-VERIFY-V0230-FUTURES-POSITION-MARGIN-LEVERAGE-READONLY
            // V0230-005-POSITION-MARGIN-LEVERAGE-OBSERVED-STATE
            // GH-1346-VERIFY-V0230-FUTURES-FUNDING-MARK-LIQUIDATION-READONLY
            // V0230-006-FUNDING-MARK-LIQUIDATION-OBSERVATION
            // GH-1347-VERIFY-V0230-FUTURES-TRANSPORT-ARTIFACT-FAILURE-CLASSIFICATION
            // V0230-007-READONLY-TRANSPORT-ARTIFACT
            // V0230-007-FAIL-CLOSED-FAILURE-CLASSIFICATION
            // GH-1348-VERIFY-V0230-FUTURES-READONLY-RECONCILIATION
            // V0230-008-LOCAL-REGISTRY-RECONCILIATION
            // V0230-008-NO-BROKER-RECONCILIATION-RUNTIME
            // GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
            // TVM-RELEASE-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
            // V0230-009-DASHBOARD-CLI-READONLY-FUTURES-READINESS
            // V0230-009-NO-TRADING-COMMANDS
            // V0230-009-NO-DASHBOARD-TRADING-CONTROLS
            // GH-1350-VERIFY-V0230-AGGREGATE-VALIDATION
            // TVM-RELEASE-V0230-AGGREGATE-VALIDATION
            // V0230-010-AGGREGATE-VALIDATION-SUITE
            // V0230-010-FUTURES-READONLY-FOUNDATION
            // V0230-010-NO-FUTURES-ORDER-EXECUTION
            // GH-1351-VERIFY-V0230-STAGE-AUDIT-RELEASE-DOCS
            // V0230-011-STAGE-CODE-AUDIT
            // V0230-011-NO-PRODUCTION-CUTOVER
            "releaseV0230FuturesReadOnlyReadinessCommand=\(ReleaseV0230FuturesReadOnlyFoundationEvidence.cliCommand)",
            "releaseV0230FuturesReadOnlyReadinessValidationAnchor=\(ReleaseV0230FuturesReadOnlyFoundationEvidence.validationAnchor)",
            "releaseV0230FuturesReadOnlyReadinessVerificationAnchor=\(ReleaseV0230FuturesReadOnlyFoundationEvidence.verificationAnchor)",
            "releaseV0230FuturesReadOnlyReadinessActions=\(ReleaseV0230FuturesReadOnlyFoundationEvidence.supportedActions.joined(separator: ","))",
            // GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT
            // TVM-RELEASE-V0240-DUAL-PRODUCT-CONTRACT
            // V0240-001-SPOT-FUTURES-DUAL-PRODUCT-UNIFICATION
            // V0240-001-BLOCKED-BY-V0231-COMPLETION
            // GH-1359-VERIFY-V0240-PRODUCT-AWARE-OMS-EVIDENCE
            // V0240-002-UNIFIED-OMS-EVENT-EVIDENCE
            // V0240-002-NO-FUTURES-ORDER-EXECUTION
            // GH-1360-VERIFY-V0240-UNIFIED-PORTFOLIO-PROJECTION
            // V0240-003-SPOT-CANARY-FUTURES-READONLY-PORTFOLIO
            // V0240-003-FUTURES-READONLY-NOT-TRADING-AUTHORIZATION
            // GH-1361-VERIFY-V0240-UNIFIED-RISK-READINESS
            // V0240-004-SPOT-FUTURES-RISK-READINESS
            // V0240-004-READINESS-NOT-PRODUCTION-RISK-APPROVAL
            // GH-1362-VERIFY-V0240-DUAL-PRODUCT-RECONCILIATION
            // V0240-005-SPOT-FUTURES-RECONCILIATION-FOUNDATION
            // V0240-005-NO-BROKER-RECONCILIATION-RUNTIME
            // GH-1363-VERIFY-V0240-DUAL-PRODUCT-FAILURE-MATRIX
            // V0240-006-DUAL-PRODUCT-FAILURE-CLASSIFICATION
            // V0240-006-FAIL-CLOSED-EVIDENCE
            // GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE
            // TVM-RELEASE-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE
            // V0240-007-DASHBOARD-CLI-DUAL-PRODUCT-READONLY
            // V0240-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
            // GH-1365-VERIFY-V0240-AGGREGATE-VALIDATION
            // TVM-RELEASE-V0240-AGGREGATE-VALIDATION
            // V0240-008-AGGREGATE-VALIDATION-SUITE
            // V0240-008-STAGE-AUDIT-RELEASE-DOCS
            // V0240-008-NO-PRODUCTION-CUTOVER
            "releaseV0240DualProductReadOnlyReadinessCommand=\(ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.cliCommand)",
            "releaseV0240DualProductReadOnlyReadinessValidationAnchor=\(ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.validationAnchor)",
            "releaseV0240DualProductReadOnlyReadinessVerificationAnchor=\(ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.verificationAnchor)",
            "releaseV0240DualProductReadOnlyReadinessActions=\(ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence.supportedActions.joined(separator: ","))",
            // GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
            // TVM-RELEASE-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
            // V0250-001-DUAL-PRODUCT-PRODUCTION-READINESS
            // V0250-001-NO-DEFAULT-TRADING
            // V0250-001-SPOT-CANARY-EVIDENCE-NOT-CUTOVER
            // V0250-001-FUTURES-READONLY-EVIDENCE-NOT-EXECUTION
            // V0250-001-BLOCKED-BY-V0241-COMPLETION
            "releaseV0250DualProductProductionReadinessCommand=\(ReleaseV0250DualProductProductionReadinessContract.cliCommand)",
            "releaseV0250DualProductProductionReadinessValidationAnchor=\(ReleaseV0250DualProductProductionReadinessContract.validationAnchor)",
            "releaseV0250DualProductProductionReadinessVerificationAnchor=\(ReleaseV0250DualProductProductionReadinessContract.verificationAnchor)",
            "releaseV0250DualProductProductionReadinessActions=\(ReleaseV0250DualProductProductionReadinessContract.supportedActions.joined(separator: ","))",
            "releaseV0250OperatorReadinessSurfaceCommand=\(ReleaseV0250OperatorReadinessSurface.cliCommand)",
            "releaseV0250OperatorReadinessSurfaceValidationAnchor=\(ReleaseV0250OperatorReadinessSurface.validationAnchor)",
            "releaseV0250OperatorReadinessSurfaceVerificationAnchor=\(ReleaseV0250OperatorReadinessSurface.verificationAnchor)",
            "releaseV0250OperatorReadinessSurfaceActions=\(ReleaseV0250OperatorReadinessSurface.supportedActions.joined(separator: ","))",
            // GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT
            // TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION
            // V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION
            // V0260-001-NO-PRODUCTION-CUTOVER
            // GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE
            // V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE
            // V0260-002-CREDENTIAL-REFERENCE-ONLY
            // GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION
            // V0260-003-NO-PRODUCTION-CUTOVER
            // V0260-003-ORDER-INTENT-VALIDATED
            // GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE
            // V0260-004-MANUAL-APPROVAL-HARD-CAPS
            // V0260-004-IDEMPOTENCY-REDACTION
            // GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK
            // V0260-005-CANCEL-STATUS-ROLLBACK
            // V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY
            // GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION
            // V0260-006-OMS-EVENT-LOG-RECONCILIATION
            // V0260-006-APPEND-ONLY-EVIDENCE
            // GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS
            // V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD
            // V0260-007-REDUCE-ONLY-HARD-CAP
            // GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
            // TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
            // V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS
            // V0260-008-NO-DASHBOARD-TRADING-CONTROLS
            // GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION
            // TVM-RELEASE-V0260-AGGREGATE-VALIDATION
            // V0260-009-AGGREGATE-VALIDATION-SUITE
            // GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS
            // V0260-010-STAGE-CODE-AUDIT
            // V0260-010-NO-PRODUCTION-CUTOVER
            // V0260-010-NO-TAG-OR-RELEASE-PUBLICATION
            "releaseV0260FuturesTestnetControlledExecutionCommand=\(ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.cliCommand)",
            "releaseV0260FuturesTestnetControlledExecutionValidationAnchor=\(ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.validationAnchor)",
            "releaseV0260FuturesTestnetControlledExecutionVerificationAnchor=\(ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.verificationAnchor)",
            "releaseV0260FuturesTestnetControlledExecutionActions=\(ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.supportedActions.joined(separator: ","))",
            // GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
            // TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING
            // V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
            // V0270-001-FAIL-CLOSED-SEMANTICS
            // GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST
            // V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST
            // V0270-002-RUN-IDENTITY-EVIDENCE
            // GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
            // V0270-003-SIGNED-STATUS-RETRY-TIMEOUT
            // V0270-003-CLASSIFIED-FAILURE-EVIDENCE
            // GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY
            // V0270-004-CANCEL-STATUS-RECOVERY
            // V0270-004-RECONCILIATION-RECOVERY
            // GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
            // V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
            // V0270-005-CHECKSUM-FAIL-CLOSED
            // GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK
            // V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD
            // V0270-006-RUN-LOCK-HARDENING
            // GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY
            // V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN
            // V0270-007-NO-DASHBOARD-TRADING-CONTROLS
            // GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION
            // V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
            // V0270-008-REDACTION-EVIDENCE
            // GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION
            // V0270-009-AGGREGATE-VALIDATION-SUITE
            // GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS
            // V0270-010-STAGE-CODE-AUDIT
            // V0270-010-RELEASE-NOTES
            // V0270-010-NO-PRODUCTION-CUTOVER
            "releaseV0270FuturesTestnetOperatorHardeningCommand=\(ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.cliCommand)",
            "releaseV0270FuturesTestnetOperatorHardeningValidationAnchor=\(ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.validationAnchor)",
            "releaseV0270FuturesTestnetOperatorHardeningVerificationAnchor=\(ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.verificationAnchor)",
            "releaseV0270FuturesTestnetOperatorHardeningActions=\(ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.supportedActions.joined(separator: ","))",
            // GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT
            // TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE
            // V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS
            // V0280-001-NOT-PRODUCTION-CUTOVER
            // V0280-001-SPOT-USDM-FUTURES-ONLY
            // V0280-001-OKX-NOT-ACTIVE
            // GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY
            // V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL
            // V0280-002-NO-DEFAULT-SECRET-READ
            // V0280-002-REDACTION-REQUIRED
            // GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST
            // V0280-003-ENDPOINT-ALLOWLIST
            // V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION
            // V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS
            // GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION
            // V0280-004-MANUAL-APPROVAL-REQUIRED
            // V0280-004-OPERATOR-CONFIRMATION-REQUIRED
            // V0280-004-NO-AUTO-CUTOVER
            // GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE
            // V0280-005-CAPITAL-RISK-GATE
            // V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS
            // V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED
            // GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP
            // V0280-006-KILL-SWITCH-REQUIRED
            // V0280-006-NO-TRADE-STATE-REQUIRED
            // V0280-006-ROLLBACK-INCIDENT-STOP-READY
            // GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE
            // V0280-007-DASHBOARD-CLI-READINESS
            // V0280-007-NO-TRADING-BUTTON
            // V0280-007-NO-ORDER-FORM
            // V0280-007-NO-LIVE-COMMAND
            // GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
            // V0280-008-AGGREGATE-VALIDATION
            // V0280-008-STAGE-AUDIT-RELEASE-DOCS
            // V0280-008-NO-PRODUCTION-CUTOVER
            "releaseV0280ProductionCutoverReadinessCommand=\(ReleaseV0280ProductionCutoverReadinessGate.cliCommand)",
            "releaseV0280ProductionCutoverReadinessValidationAnchor=\(ReleaseV0280ProductionCutoverReadinessGate.validationAnchor)",
            "releaseV0280ProductionCutoverReadinessVerificationAnchor=\(ReleaseV0280ProductionCutoverReadinessGate.verificationAnchor)",
            "releaseV0280ProductionCutoverReadinessActions=\(ReleaseV0280ProductionCutoverReadinessGate.supportedActions.joined(separator: ","))",
            "operatorRunFailedEvidenceNonzeroOrReadOnlyReportPath=true",
            "readinessPlaceholderOnly=false",
            "readinessArtifactRuntimeImplemented=true",
            "productionReadinessArtifactStoreImplemented=true",
            "testnetRequiresOperatorConfirmation=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    /// `mtpro readiness` 是 GH-920 的 v0.11.0 本地 readiness artifact CLI。
    ///
    /// 它只读写 `ProductionReadinessArtifactStore` 的本地 evidence root，所有 action 都保持
    /// production secret / endpoint / broker / order / cutover capability 为 false。
    private static func readinessOutput(arguments: [String]) throws -> String {
        guard arguments.count >= 2 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.arguments",
                expected: (readinessSupportedActionCommands + readinessAssessmentSupportedActionCommands)
                    .joined(separator: ","),
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments[1]
        if ["help", "build", "status", "validate", "export", "approval-status"].contains(action),
           arguments.count == 2 {
            return try ReleaseV0110ReadinessCLI(action: action).output()
        }

        if action == "intake" {
            guard arguments.count == 3 else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.readiness.arguments",
                    expected: "readiness intake <evidenceRoot>",
                    actual: arguments.joined(separator: " ")
                )
            }
            return try ReleaseV0130LocalEvidenceIntakeCLI(evidenceRootPath: arguments[2]).output()
        }

        if action == "build-v013" {
            guard arguments.count == 4 else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.readiness.arguments",
                    expected: "readiness build-v013 <assessmentID> <evidenceRoot>",
                    actual: arguments.joined(separator: " ")
                )
            }
            return try ReleaseV0130LocalEvidenceProvenanceBuildCLI(
                assessmentID: try readinessAssessmentID(arguments[2]),
                evidenceRootPath: arguments[3]
            ).output()
        }

        if action == "create" {
            guard arguments.count == 2 || arguments.count == 3 else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.readiness.arguments",
                    expected: "readiness create [assessmentID]",
                    actual: arguments.joined(separator: " ")
                )
            }
            let assessmentID = arguments.count == 3 ? try readinessAssessmentID(arguments[2]) : nil
            return try ReleaseV0120ReadinessAssessmentCLI(
                action: action,
                assessmentID: assessmentID,
                comparisonAssessmentID: nil
            ).output()
        }

        if ["build", "status", "validate", "export", "archive"].contains(action) {
            guard arguments.count == 3 else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.readiness.arguments",
                    expected: "readiness \(action) <assessmentID>",
                    actual: arguments.joined(separator: " ")
                )
            }
            return try ReleaseV0120ReadinessAssessmentCLI(
                action: action,
                assessmentID: try readinessAssessmentID(arguments[2]),
                comparisonAssessmentID: nil
            ).output()
        }

        if action == "compare" {
            guard arguments.count == 4 else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.readiness.arguments",
                    expected: "readiness compare <baselineAssessmentID> <followUpAssessmentID>",
                    actual: arguments.joined(separator: " ")
                )
            }
            return try ReleaseV0120ReadinessAssessmentCLI(
                action: action,
                assessmentID: try readinessAssessmentID(arguments[2]),
                comparisonAssessmentID: try readinessAssessmentID(arguments[3])
            ).output()
        }

        guard ["help", "build", "status", "validate", "export", "approval-status", "build-v013"].contains(action) else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.action",
                expected: "help,build,status,validate,export,approval-status,build-v013,intake,create,archive,compare",
                actual: arguments.joined(separator: " ")
            )
        }

        throw MTPROCLIParserError.invalidArguments(
            field: "mtpro.readiness.arguments",
            expected: "readiness \(action) or readiness \(action) <assessmentID>",
            actual: arguments.joined(separator: " ")
        )
    }

    private static func readinessAssessmentID(_ rawValue: String) throws -> Identifier {
        guard rawValue.isEmpty == false,
              rawValue.hasPrefix("-") == false,
              rawValue != ".",
              rawValue != "..",
              rawValue.hasPrefix("~") == false,
              rawValue.contains("/") == false,
              rawValue.contains("\\") == false else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.arguments",
                expected: "safe assessmentID path component",
                actual: rawValue
            )
        }
        return Identifier.constant(rawValue)
    }

    private static func monitorOutput(arguments: [String]) throws -> String {
        guard arguments.count == 2 || arguments.count == 3 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.monitor.arguments",
                expected: "monitor start|status|stop|recover|export [runID]",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments[1]
        guard ["start", "status", "stop", "recover", "export"].contains(action) else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.monitor.action",
                expected: "start,status,stop,recover,export",
                actual: arguments.joined(separator: " ")
            )
        }
        let runID = arguments.count == 3 ? arguments[2] : "latest"
        let binding = try ReleaseV090CLIMonitorSessionBinder().perform(action: action, runID: Identifier.constant(runID))
        let localArtifactMutationOnly = ["start", "stop", "recover"].contains(action)
        let readOnlySnapshotOnly = ["status", "export"].contains(action)
        let monitorState: String
        switch action {
        case "start":
            monitorState = binding.operatorState
        case "status":
            monitorState = "read-only-status"
        case "stop":
            monitorState = binding.operatorState
        case "recover":
            monitorState = "recovered"
        default:
            monitorState = "local-export-ready"
        }

        return [
            "mtpro monitor \(action) v0.9.0",
            "issue=GH-855",
            "validationAnchor=\(releaseV090OperatorUXValidationAnchor)",
            "verificationAnchor=\(releaseV090OperatorUXVerificationAnchor)",
            "requiredAnchors=\(releaseV090OperatorUXRequiredAnchors.joined(separator: ","))",
            "operatorUXContract=v0.9.0",
            "monitorAction=\(action)",
            "runID=\(runID)",
            "monitorState=\(monitorState)",
            "monitorStoreBinding=ReleaseV090TestnetReadOnlyMonitorSessionStore",
            "monitorStoreMutationApplied=\(binding.storeMutationApplied)",
            "monitorStoreSessionState=\(binding.session.state.rawValue)",
            "monitorStoreStatusChecksum=\(binding.status.statusChecksum)",
            "cliMonitorCommands=\(monitorSupportedActionCommands.joined(separator: ","))",
            "dashboardMonitorSurfaces=monitor-state,timelines,alerts,export-status,safe-local-controls",
            "monitorSessionPath=\(binding.session.artifactPaths.monitorSessionJSONPath)",
            "monitorStatusPath=\(binding.session.artifactPaths.monitorStatusJSONPath)",
            "monitorTimelinePath=\(binding.session.artifactPaths.monitorEventsJSONLPath)",
            "alertReadModelPath=\(binding.session.artifactPaths.monitorDirectoryPath)/monitor-alerts.json",
            "exportBundlePath=\(binding.session.artifactPaths.runMonitorExportBundleJSONPath)",
            "exportStatusPath=\(binding.session.artifactPaths.monitorDirectoryPath)/export-status.json",
            "localArtifactMutationOnly=\(localArtifactMutationOnly)",
            "readOnlySnapshotOnly=\(readOnlySnapshotOnly)",
            "manualProofReplayableByCI=false",
            "credentialValueVisible=false",
            "rawListenKeyVisible=false",
            "rawPrivatePayloadVisible=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "brokerCommandCreated=false",
            "testnetOrderRoutingAllowed=false",
            "testnetOrderSubmissionAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func riskPolicyOutput(arguments: [String]) throws -> String {
        guard arguments.count == 2 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.riskPolicy.arguments",
                expected: "risk-policy show|validate|diff",
                actual: arguments.joined(separator: " ")
            )
        }
        switch arguments[1] {
        case "show":
            return riskPolicyShowOutput()
        case "validate":
            return riskPolicyValidateOutput()
        case "diff":
            return riskPolicyDiffOutput()
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.riskPolicy.arguments",
                expected: "risk-policy show|validate|diff",
                actual: arguments.joined(separator: " ")
            )
        }
    }

    private static func riskPolicyBaseOutput(action: String) -> [String] {
        [
            "mtpro risk-policy \(action)",
            "issue=GH-816",
            "validationAnchor=\(riskPolicyProfileAnchor)",
            "verificationAnchor=\(riskPolicyProfileVerificationAnchor)",
            "requiredAnchors=\(riskPolicyProfileRequiredAnchors.joined(separator: ","))",
            "riskPolicyProfileContract=v0.8.0",
            "profilePath=.local/mtpro/risk_policy.json",
            "profileVersion=v0.8.0-risk-policy-profile.2",
            "policyHash=risk-policy-fnv64-deterministic-local-profile",
            "operatorMetadata=local-operator-change-reference",
            "appliedRunIDs=gh-810-local-alpha,gh-811-run-alpha",
            "showValidateDiffSurface=true"
        ]
    }

    private static func riskPolicyShowOutput() -> String {
        (riskPolicyBaseOutput(action: "show") + [
            "maxNotionalMinorUnits=40000000",
            "maxExposureMinorUnits=100000000",
            "allowedSymbols=BTCUSDT,ETHUSDT",
            "allowedProductTypes=spot,usdsPerpetual",
            "killSwitchRequired=true",
            "noTradeRequired=true",
            "credentialValueStored=false",
            "brokerEnabled=false",
            "productionEndpointEnabled=false",
            "omsBypassEnabled=false",
            "orderCommandPathEnabled=false",
            "testnetOrderRoutingAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private static func riskPolicyValidateOutput() -> String {
        (riskPolicyBaseOutput(action: "validate") + [
            "profileValid=true",
            "versionHashValid=true",
            "operatorMetadataValid=true",
            "appliedRunReferenceValid=true",
            "forbiddenCapabilityGate=held",
            "brokerEnabled=false",
            "productionEndpointEnabled=false",
            "omsBypassEnabled=false",
            "orderCommandPathEnabled=false",
            "testnetOrderRoutingAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private static func riskPolicyDiffOutput() -> String {
        (riskPolicyBaseOutput(action: "diff") + [
            "previousProfileVersion=v0.8.0-risk-policy-profile.1",
            "nextProfileVersion=v0.8.0-risk-policy-profile.2",
            "previousPolicyHash=risk-policy-fnv64-previous-local-profile",
            "nextPolicyHash=risk-policy-fnv64-deterministic-local-profile",
            "changedFields=profileVersion,maxNotionalMinorUnits,maxExposureMinorUnits,appliedRunIDs",
            "diffLine.profileVersion=v0.8.0-risk-policy-profile.1 -> v0.8.0-risk-policy-profile.2",
            "diffLine.maxNotionalMinorUnits=50000000 -> 40000000",
            "diffLine.maxExposureMinorUnits=125000000 -> 100000000",
            "diffLine.appliedRunIDs=gh-810-local-alpha -> gh-810-local-alpha,gh-811-run-alpha",
            "brokerEnabled=false",
            "productionEndpointEnabled=false",
            "omsBypassEnabled=false",
            "orderCommandPathEnabled=false",
            "testnetOrderRoutingAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private static func runOutput(arguments: [String]) throws -> String {
        let mode = try runMode(arguments: arguments)
        let requestedRunID = try runIDOption(arguments: arguments)
        if mode == "local-dry-run" {
            let result = try ReleaseV080CLILocalSessionBinder().startDryRun(requestedRunID: requestedRunID)
            return (baseRunOutput(mode: mode) + [
                "issue=GH-810",
                "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
                "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
                "persistentLocalSessionContract=v0.8.0",
                "localSessionCreated=true",
                "runID=\(result.runID.rawValue)",
                "registryPath=\(result.registryURL.path)",
                "runDirectoryPath=\(result.runDirectoryURL.path)",
                "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror",
                "canonicalStatusArtifact=status.json",
                "status.json=\(result.statusMirrorURL.path)",
                "compatibilityRunStatusArtifact=_RUN_STATUS.json",
                "_RUN_STATUS.json=\(result.statusURL.path)",
                "events.jsonl=\(result.eventsURL.path)",
                "manifest.json=\(result.manifestURL.path)",
                "registryState=running",
                "eventLogInitialized=true",
                "manifestCreated=true"
            ]).joined(separator: "\n")
        }

        return baseRunOutput(mode: mode).joined(separator: "\n")
    }

    private static func baseRunOutput(mode: String) -> [String] {
        [
            "mtpro run no-order-runtime-session",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "mode=\(mode)",
            "runtimeSessionContract=v0.7.0",
            "noOrderRuntimeSession=true",
            "localNoOrderSessionFlow=gh-783-operational-run-session",
            "brokerSessionStarted=false",
            "runRegistryState=local-run-registry-ready",
            "runsListSource=local-run-registry-metadata",
            "runsInspectSource=local-run-registry-metadata",
            "runArchiveAllowed=true",
            "runRecoverLocalEvidenceOnly=true",
            "testnetConnected=false",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ]
    }

    private static func statusOutput(arguments: [String]) throws -> String {
        let runID: String
        switch arguments.count {
        case 1:
            runID = "latest"
        case 2:
            runID = arguments[1]
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.status.arguments",
                expected: "status [runID]",
                actual: arguments.joined(separator: " ")
            )
        }

        let status = ReleaseV080CLILocalSessionBinder().statusLines(requestedRunID: runID)
        return [
            "mtpro status no-order-runtime-session",
            "issue=GH-810",
            "validationAnchor=\(validationAnchor)",
            "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
            "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
            "runID=\(status.runID)",
            "runtimeSessionContract=v0.7.0",
            "persistentLocalSessionContract=v0.8.0",
            "activeTopLevelStatusSurface=v0.7.0",
            "noOrderRuntimeSession=true",
            "legacyV040StatusSurface=false",
            "legacyV050ObserverSurface=false",
            "sessionRegistrySource=local-run-registry-state",
            "sessionState=\(status.sessionState)",
            "registryState=\(status.registryState)",
            "localSessionFound=\(status.localSessionFound)",
            "artifactLocationSource=.local/mtpro/runs/<runID>",
            "runDirectoryPath=\(status.runDirectoryPath)",
            "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror",
            "canonicalStatusArtifact=status.json",
            "status.json=\(status.canonicalStatusPath)",
            "compatibilityRunStatusArtifact=_RUN_STATUS.json",
            "_RUN_STATUS.json=\(status.compatibilityRunStatusPath)",
            "events.jsonl=\(status.eventsPath)",
            "manifest.json=\(status.manifestPath)",
            "recoverySemantics=local-evidence-only",
            "readOnlyProbeState=not-connected",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func stopOutput(arguments: [String]) throws -> String {
        guard arguments.count == 2 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.stop.arguments",
                expected: "stop <runID>",
                actual: arguments.joined(separator: " ")
            )
        }
        let result = try ReleaseV080CLILocalSessionBinder().stop(runID: Identifier.constant(arguments[1]))
        return [
            "mtpro stop local-no-order-session",
            "issue=GH-810",
            "validationAnchor=\(validationAnchor)",
            "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
            "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
            "runID=\(result.runID.rawValue)",
            "persistentLocalSessionContract=v0.8.0",
            "noOrderRuntimeSession=true",
            "sessionState=stopped",
            "registryState=stopped",
            "localSessionMutated=true",
            "_RUN_STATUS.json=\(result.statusURL.path)",
            "manifest.json=\(result.manifestURL.path)",
            "recoverySemantics=local-evidence-only",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func recoverOutput(arguments: [String]) throws -> String {
        guard arguments.count == 2 || arguments.count == 4 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.recover.arguments",
                expected: "recover <runID> [--reason reason]",
                actual: arguments.joined(separator: " ")
            )
        }
        let reason: String
        if arguments.count == 4 {
            guard arguments[2] == "--reason" else {
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.recover.arguments",
                    expected: "recover <runID> [--reason reason]",
                    actual: arguments.joined(separator: " ")
                )
            }
            reason = arguments[3]
        } else {
            reason = "operator-local-recovery"
        }
        let result = try ReleaseV080CLILocalSessionBinder().recover(
            runID: Identifier.constant(arguments[1]),
            reason: reason
        )
        return [
            "mtpro recover local-no-order-session",
            "issue=GH-810",
            "validationAnchor=\(validationAnchor)",
            "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
            "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
            "runID=\(result.runID.rawValue)",
            "persistentLocalSessionContract=v0.8.0",
            "noOrderRuntimeSession=true",
            "sessionState=recovered",
            "registryState=recovered",
            "localSessionMutated=true",
            "recoveryReason=\(reason)",
            "_RUN_STATUS.json=\(result.statusURL.path)",
            "manifest.json=\(result.manifestURL.path)",
            "recoverySemantics=local-evidence-only",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func verifyOutput() -> String {
        [
            "mtpro verify v0.10.0",
            "issue=GH-909",
            "validationAnchor=\(releaseV0100ValidationAnchor)",
            "verificationAnchor=\(releaseV0100VerificationAnchor)",
            "wordingGuard=\(cliVerifyV0100WordingAnchor)",
            "wordingValidationAnchor=\(cliVerifyV0100WordingValidationAnchor)",
            "releaseModel=production-readiness-contract-reference-evidence",
            "releaseScope=MTPRO Release v0.10.0 Production Readiness Contract / Reference Evidence Model",
            "readinessContractOnly=true",
            "referenceEvidenceModel=true",
            "operationalProductionReadiness=false",
            "productionCutoverReadinessClaim=false",
            "productionEndpointReadinessClaim=false",
            "liveOrderAuthorization=false",
            "productionCutoverRequiresSeparateGate=true",
            "persistentValidationAnchor=\(persistentLocalSessionAnchor)",
            "persistentVerificationAnchor=\(persistentLocalSessionVerificationAnchor)",
            "checks=verify-v0.10.0-contract,verify-v0.10.0-dashboard-production-readiness-center,verify-v0.10.1-cli-verify-v0100-wording,verify-v0.10.0,automation-readiness,checks-run",
            "historicalV090Issue=GH-856",
            "historicalV090ValidationAnchor=\(releaseV090ValidationAnchor)",
            "historicalV090VerificationAnchor=\(releaseV090VerificationAnchor)",
            "historicalV090Checks=verify-v0.9.0-contract,verify-v0.9.0-dashboard-cli-operator-ux,verify-v0.9.0",
            "historicalV080Issue=GH-820",
            "historicalV080Checks=verify-v0.8.0-contract,verify-v0.8.0-release-publication-policy,verify-v0.8.0-cli-local-session,verify-v0.8.0-validation-lanes,verify-v0.8.0",
            "historicalV070Checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli",
            "requiredAnchors=\(cliVerifyV0100WordingRequiredAnchors.joined(separator: ","))",
            "unknownCommandFailure=mtpro.strict.arguments",
            "legacyFallbackDisabled=true",
            "legacyV040ActiveTopLevelSurface=false",
            "legacyV050ActiveTopLevelSurface=false",
            "persistentLocalSessionContract=v0.8.0",
            "noOrderRuntimeSession=true",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func runMode(arguments: [String]) throws -> String {
        let parsed = try parseRunOptions(arguments: arguments)
        switch parsed.mode {
        case "dry-run", "local-dry-run":
            return "local-dry-run"
        case "testnet-read-only-monitor":
            return "testnet-read-only-monitor"
        case "recovery-observe":
            return "recovery-observe"
        case "testnet-read-only-probe":
            return "testnet-read-only-probe"
        case "production":
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.production",
                expected: "production-blocked",
                actual: arguments.joined(separator: " ")
            )
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.arguments",
                expected: "run [--mode dry-run|testnet-read-only-monitor|recovery-observe|testnet-read-only-probe] [--run-id id]",
                actual: arguments.joined(separator: " ")
            )
        }
    }

    private static func runIDOption(arguments: [String]) throws -> Identifier? {
        let parsed = try parseRunOptions(arguments: arguments)
        return parsed.runID.map { Identifier.constant($0) }
    }

    private static func parseRunOptions(arguments: [String]) throws -> (mode: String, runID: String?) {
        guard arguments.first == "run" else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.arguments",
                expected: "run",
                actual: arguments.joined(separator: " ")
            )
        }
        var mode = "local-dry-run"
        var runID: String?
        var index = 1
        while index < arguments.count {
            switch arguments[index] {
            case "--mode":
                guard index + 1 < arguments.count else {
                    throw MTPROCLIParserError.invalidArguments(
                        field: "mtpro.run.arguments",
                        expected: "--mode value",
                        actual: arguments.joined(separator: " ")
                    )
                }
                mode = arguments[index + 1]
                index += 2
            case "--run-id":
                guard index + 1 < arguments.count else {
                    throw MTPROCLIParserError.invalidArguments(
                        field: "mtpro.run.arguments",
                        expected: "--run-id value",
                        actual: arguments.joined(separator: " ")
                    )
                }
                runID = arguments[index + 1]
                index += 2
            case "--production":
                mode = "production"
                index += 1
            default:
                throw MTPROCLIParserError.invalidArguments(
                    field: "mtpro.run.arguments",
                    expected: "run [--mode dry-run|testnet-read-only-monitor|recovery-observe|testnet-read-only-probe] [--run-id id]",
                    actual: arguments.joined(separator: " ")
                )
            }
        }
        return (mode, runID)
    }

    private static func requireExactCount(_ arguments: [String], expected: Int, command: String) throws {
        guard arguments.count == expected else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.\(command).arguments",
                expected: command,
                actual: arguments.joined(separator: " ")
            )
        }
    }
}

/// ReleaseV090CLIMonitorSessionBinder 将 `mtpro monitor` 绑定到 v0.9.0 本地 monitor session store。
///
/// 该绑定层只读写 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/` 下的
/// monitor_session / monitor_status / monitor_events evidence；不读取 secret、不连接
/// endpoint / broker，也不创建 testnet 或 production order。
private struct ReleaseV090CLIMonitorSessionBinder {
    private static let rootEnvironmentKey = "MTPRO_LOCAL_RUNS_ROOT"

    let storageRootURL: URL
    let store: ReleaseV090TestnetReadOnlyMonitorSessionStore

    init(storageRootURL: URL? = nil, fileManager: FileManager = .default) {
        if let storageRootURL {
            self.storageRootURL = storageRootURL
        } else if let override = ProcessInfo.processInfo.environment[Self.rootEnvironmentKey], override.isEmpty == false {
            self.storageRootURL = URL(fileURLWithPath: override, isDirectory: true)
        } else {
            self.storageRootURL = URL(fileURLWithPath: ".local/mtpro/runs", isDirectory: true)
        }
        self.store = ReleaseV090TestnetReadOnlyMonitorSessionStore(
            storageRootURL: self.storageRootURL,
            fileManager: fileManager
        )
    }

    struct Result {
        let session: ReleaseV090TestnetReadOnlyMonitorSessionDocument
        let status: ReleaseV090TestnetReadOnlyMonitorStatusDocument
        let storeMutationApplied: Bool
        let operatorState: String
    }

    func perform(action: String, runID: Identifier) throws -> Result {
        let now = Self.canonicalNow()
        switch action {
        case "start":
            let session = try startedSession(runID: runID, at: now)
            return try result(session: session, mutationApplied: true, operatorState: "observing")
        case "status":
            let session = try requireExistingSession(runID: runID)
            return try result(session: session, mutationApplied: false, operatorState: "read-only-status")
        case "stop":
            let session = try stoppedSession(runID: runID, at: now)
            return try result(session: session, mutationApplied: true, operatorState: "stopped")
        case "recover":
            let session = try recoveredSession(runID: runID, at: now)
            return try result(session: session, mutationApplied: true, operatorState: "recovered")
        case "export":
            let session = try requireExistingSession(runID: runID)
            return try result(session: session, mutationApplied: false, operatorState: "local-export-ready")
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.monitor.action",
                expected: "start,status,stop,recover,export",
                actual: action
            )
        }
    }

    private static func canonicalNow() -> Date {
        Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
    }

    private func result(
        session: ReleaseV090TestnetReadOnlyMonitorSessionDocument,
        mutationApplied: Bool,
        operatorState: String
    ) throws -> Result {
        Result(
            session: session,
            status: try store.status(runID: session.runID),
            storeMutationApplied: mutationApplied,
            operatorState: operatorState
        )
    }

    private func requireExistingSession(
        runID: Identifier
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        try store.load(runID: runID)
    }

    private func ensureSession(
        runID: Identifier,
        createdAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        do {
            return try store.load(runID: runID)
        } catch ReleaseV090TestnetReadOnlyMonitorSessionStoreError.missingMonitorSession(_) {
            return try store.create(runID: runID, reason: "cli-monitor-session-created", createdAt: createdAt)
        }
    }

    private func startedSession(
        runID: Identifier,
        at observedAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        var session = try ensureSession(runID: runID, createdAt: observedAt)
        if session.state == .created {
            session = try store.apply(
                runID: runID,
                command: .connect,
                reason: "cli-monitor-start-connect",
                at: observedAt.addingTimeInterval(1)
            )
        }
        if session.state == .connecting || session.state == .recovering {
            session = try store.apply(
                runID: runID,
                command: .observe,
                reason: "cli-monitor-start-observe",
                at: observedAt.addingTimeInterval(2)
            )
        }
        return session
    }

    private func stoppedSession(
        runID: Identifier,
        at observedAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        let session = try ensureSession(runID: runID, createdAt: observedAt)
        guard session.state != .stopped, session.state != .failed else {
            return session
        }
        return try store.apply(
            runID: runID,
            command: .stop,
            reason: "cli-monitor-local-stop",
            at: observedAt.addingTimeInterval(1)
        )
    }

    private func recoveredSession(
        runID: Identifier,
        at observedAt: Date
    ) throws -> ReleaseV090TestnetReadOnlyMonitorSessionDocument {
        var session = try startedSession(runID: runID, at: observedAt)
        if session.state == .observing {
            session = try store.apply(
                runID: runID,
                command: .markStale,
                reason: "cli-monitor-recovery-drill-stale",
                at: observedAt.addingTimeInterval(3)
            )
        }
        guard session.state == .stale || session.state == .disconnected else {
            return session
        }
        _ = try store.recordCLIMonitorRecovery(
            runID: runID,
            recoveredAt: observedAt.addingTimeInterval(4),
            streamEvidenceReference: "cli-monitor-stream-reference",
            recoveryReason: "cli-monitor-manual-recovery",
            rebuiltReadModelEvidenceReference: "cli-monitor-rebuilt-read-model",
            observedAfterRecoveryAt: observedAt.addingTimeInterval(5)
        )
        return try store.load(runID: runID)
    }
}

/// ReleaseV080CLILocalSessionBinder 是 GH-810 的 top-level CLI -> local artifact 绑定层。
///
/// Binder 只写 `.local/mtpro/runs` 下的 registry、`status.json`、`_RUN_STATUS.json`、
/// `events.jsonl` 和 `manifest.json`。GH-839 起，`status.json` 是 v0.8+ canonical
/// operator status artifact，`_RUN_STATUS.json` 只是为 v0.6/v0.7 reader 保留的兼容镜像。
/// 它不读取 secret、不连接 endpoint / broker、不提交或取消订单；`stop` / `recover`
/// 也只变更本地 session evidence。
private struct ReleaseV080CLILocalSessionBinder {
    private static let rootEnvironmentKey = "MTPRO_LOCAL_RUNS_ROOT"

    let storageRootURL: URL
    let fileManager: FileManager

    init(
        storageRootURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        if let storageRootURL {
            self.storageRootURL = storageRootURL
        } else if let override = ProcessInfo.processInfo.environment[Self.rootEnvironmentKey], override.isEmpty == false {
            self.storageRootURL = URL(fileURLWithPath: override, isDirectory: true)
        } else {
            self.storageRootURL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true)
        }
        self.fileManager = fileManager
    }

    @discardableResult
    func startDryRun(requestedRunID: Identifier?) throws -> ReleaseV080CLILocalSessionMutationResult {
        let runID = requestedRunID ?? Identifier.constant("gh-810-local-\(UUID().uuidString.lowercased())")
        let now = Self.canonicalNow()
        let registry = ReleaseV080RunRegistryStore(storageRootURL: storageRootURL, fileManager: fileManager)
        let existing = try loadRegistryIfPresent(registry)
        if existing.entries.contains(where: { $0.runID == runID }) {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.runID",
                expected: "new local runID",
                actual: runID.rawValue
            )
        }

        let paths = artifactURLs(runID: runID)
        try fileManager.createDirectory(at: paths.runDirectoryURL, withIntermediateDirectories: true)
        try appendEvent(runID: runID, action: "run", state: "running")
        let status = try ReleaseV080CLILocalSessionStatus(
            runID: runID.rawValue,
            state: "running",
            eventCount: 1,
            reason: "local-dry-run-session-created",
            createdAt: now,
            updatedAt: now
        )
        try writeStatus(status, to: paths)
        try writeManifest(runID: runID, state: "running", createdAt: now, updatedAt: now, to: paths)

        let entry = try ReleaseV080RunRegistryEntry(
            runID: runID,
            state: .running,
            createdAt: now,
            updatedAt: now
        )
        try registry.save(
            entries: existing.entries + [entry],
            createdAt: existing.createdAt ?? now,
            updatedAt: now
        )
        return ReleaseV080CLILocalSessionMutationResult(runID: runID, storageRootURL: storageRootURL)
    }

    @discardableResult
    func stop(runID: Identifier) throws -> ReleaseV080CLILocalSessionMutationResult {
        try mutate(runID: runID, state: .stopped, action: "stop", reason: "operator-local-stop")
    }

    @discardableResult
    func recover(runID: Identifier, reason: String) throws -> ReleaseV080CLILocalSessionMutationResult {
        try mutate(runID: runID, state: .recovered, action: "recover", reason: reason)
    }

    func statusLines(requestedRunID: String) -> ReleaseV080CLILocalSessionStatusLines {
        let registry = ReleaseV080RunRegistryStore(storageRootURL: storageRootURL, fileManager: fileManager)
        do {
            let document = try registry.load()
            let entry: ReleaseV080RunRegistryEntry
            if requestedRunID == "latest" {
                guard let latest = document.entries.sorted(by: { $0.updatedAt < $1.updatedAt }).last else {
                    return .missing(requestedRunID: requestedRunID, storageRootURL: storageRootURL)
                }
                entry = latest
            } else {
                entry = try document.inspect(runID: Identifier.constant(requestedRunID))
            }
            let paths = artifactURLs(runID: entry.runID)
            let statusState = (try? readStatus(from: paths.statusMirrorURL))?.state ?? entry.state.rawValue
            return ReleaseV080CLILocalSessionStatusLines(
                runID: entry.runID.rawValue,
                sessionState: statusState,
                registryState: entry.state.rawValue,
                localSessionFound: true,
                runDirectoryPath: paths.runDirectoryURL.path,
                canonicalStatusPath: paths.statusMirrorURL.path,
                compatibilityRunStatusPath: paths.statusURL.path,
                eventsPath: paths.eventsURL.path,
                manifestPath: paths.manifestURL.path
            )
        } catch {
            return .missing(requestedRunID: requestedRunID, storageRootURL: storageRootURL)
        }
    }

    private func mutate(
        runID: Identifier,
        state: ReleaseV080RunRegistryState,
        action: String,
        reason: String
    ) throws -> ReleaseV080CLILocalSessionMutationResult {
        let now = Self.canonicalNow()
        let registry = ReleaseV080RunRegistryStore(storageRootURL: storageRootURL, fileManager: fileManager)
        let document = try registry.load()
        let current = try document.inspect(runID: runID)
        try appendEvent(runID: runID, action: action, state: state.rawValue)
        let paths = artifactURLs(runID: runID)
        let eventCount = (try? ReleaseV060LocalRunJournalWriter(
            storageRootURL: storageRootURL,
            fileManager: fileManager
        ).validateRuntimeEventLog(runID: runID).eventCount) ?? 0
        let status = try ReleaseV080CLILocalSessionStatus(
            runID: runID.rawValue,
            state: state.rawValue,
            eventCount: eventCount,
            reason: reason,
            createdAt: current.createdAt,
            updatedAt: now
        )
        try writeStatus(status, to: paths)
        try writeManifest(runID: runID, state: state.rawValue, createdAt: current.createdAt, updatedAt: now, to: paths)

        let nextEntry: ReleaseV080RunRegistryEntry
        if state == .recovered {
            nextEntry = try current.recovered(reason: reason, at: now)
        } else {
            nextEntry = try ReleaseV080RunRegistryEntry(
                runID: runID,
                state: state,
                lifecycle: current.lifecycle,
                createdAt: current.createdAt,
                updatedAt: now,
                failureReason: current.failureReason,
                recoveryReason: current.recoveryReason
            )
        }
        let entries = document.entries.filter { $0.runID != runID } + [nextEntry]
        try registry.save(entries: entries, createdAt: document.createdAt, updatedAt: now)
        return ReleaseV080CLILocalSessionMutationResult(runID: runID, storageRootURL: storageRootURL)
    }

    private func appendEvent(runID: Identifier, action: String, state: String) throws {
        let payload = #"{"issue":"GH-810","action":"\#(action)","state":"\#(state)","noOrder":true}"#
        let event = try ReleaseV070RuntimeEventLogEvent(
            eventID: Identifier.constant("\(runID.rawValue)-cli-\(action)"),
            payloadJSON: payload
        )
        _ = try ReleaseV060LocalRunJournalWriter(
            storageRootURL: storageRootURL,
            fileManager: fileManager
        ).appendRuntimeEvents(runID: runID, events: [event])
    }

    private static func canonicalNow() -> Date {
        Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
    }

    private func loadRegistryIfPresent(
        _ registry: ReleaseV080RunRegistryStore
    ) throws -> (entries: [ReleaseV080RunRegistryEntry], createdAt: Date?) {
        do {
            let document = try registry.load()
            return (document.entries, document.createdAt)
        } catch ReleaseV080RunRegistryStoreError.missingRegistry {
            return ([], nil)
        }
    }

    private func artifactURLs(runID: Identifier) -> ReleaseV080CLILocalSessionArtifactURLs {
        let runDirectoryURL = storageRootURL.appendingPathComponent(runID.rawValue, isDirectory: true)
        return ReleaseV080CLILocalSessionArtifactURLs(
            runDirectoryURL: runDirectoryURL,
            eventsURL: runDirectoryURL.appendingPathComponent("events.jsonl", isDirectory: false),
            statusURL: runDirectoryURL.appendingPathComponent("_RUN_STATUS.json", isDirectory: false),
            statusMirrorURL: runDirectoryURL.appendingPathComponent("status.json", isDirectory: false),
            manifestURL: runDirectoryURL.appendingPathComponent("manifest.json", isDirectory: false)
        )
    }

    private func writeStatus(
        _ status: ReleaseV080CLILocalSessionStatus,
        to paths: ReleaseV080CLILocalSessionArtifactURLs
    ) throws {
        // `status.json` 是 v0.8+ canonical operator 状态，`_RUN_STATUS.json` 仅为兼容镜像。
        try writeJSON(status, to: paths.statusMirrorURL)
        try writeJSON(status, to: paths.statusURL)
    }

    private func readStatus(from url: URL) throws -> ReleaseV080CLILocalSessionStatus {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ReleaseV080CLILocalSessionStatus.self, from: Data(contentsOf: url))
    }

    private func writeManifest(
        runID: Identifier,
        state: String,
        createdAt: Date,
        updatedAt: Date,
        to paths: ReleaseV080CLILocalSessionArtifactURLs
    ) throws {
        let manifest = try ReleaseV080CLILocalSessionManifest(
            runID: runID.rawValue,
            state: state,
            eventsJSONLPath: paths.eventsURL.path,
            statusJSONPath: paths.statusMirrorURL.path,
            runStatusJSONPath: paths.statusURL.path,
            createdAt: createdAt,
            updatedAt: updatedAt,
            artifacts: [
                try artifactMetadata(path: paths.eventsURL.path, url: paths.eventsURL),
                try artifactMetadata(path: paths.statusURL.path, url: paths.statusURL),
                try artifactMetadata(path: paths.statusMirrorURL.path, url: paths.statusMirrorURL)
            ]
        )
        try writeJSON(manifest, to: paths.manifestURL)
    }

    private func artifactMetadata(
        path: String,
        url: URL
    ) throws -> ReleaseV080CLILocalSessionArtifactMetadata {
        let data = try Data(contentsOf: url)
        return ReleaseV080CLILocalSessionArtifactMetadata(
            path: path,
            sha256: ReleaseV060LocalRunJournalWriter.sha256Hex(data),
            bytes: data.count
        )
    }

    private func writeJSON<Value: Encodable>(_ value: Value, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }
}

private struct ReleaseV080CLILocalSessionArtifactURLs {
    let runDirectoryURL: URL
    let eventsURL: URL
    let statusURL: URL
    let statusMirrorURL: URL
    let manifestURL: URL
}

private struct ReleaseV080CLILocalSessionMutationResult {
    let runID: Identifier
    let storageRootURL: URL

    var registryURL: URL {
        storageRootURL.appendingPathComponent("registry.json", isDirectory: false)
    }

    var runDirectoryURL: URL {
        storageRootURL.appendingPathComponent(runID.rawValue, isDirectory: true)
    }

    var eventsURL: URL {
        runDirectoryURL.appendingPathComponent("events.jsonl", isDirectory: false)
    }

    var statusURL: URL {
        runDirectoryURL.appendingPathComponent("_RUN_STATUS.json", isDirectory: false)
    }

    var statusMirrorURL: URL {
        runDirectoryURL.appendingPathComponent("status.json", isDirectory: false)
    }

    var manifestURL: URL {
        runDirectoryURL.appendingPathComponent("manifest.json", isDirectory: false)
    }
}

private struct ReleaseV080CLILocalSessionStatusLines {
    let runID: String
    let sessionState: String
    let registryState: String
    let localSessionFound: Bool
    let runDirectoryPath: String
    let canonicalStatusPath: String
    let compatibilityRunStatusPath: String
    let eventsPath: String
    let manifestPath: String

    static func missing(
        requestedRunID: String,
        storageRootURL: URL
    ) -> ReleaseV080CLILocalSessionStatusLines {
        ReleaseV080CLILocalSessionStatusLines(
            runID: requestedRunID,
            sessionState: "missing",
            registryState: "missing",
            localSessionFound: false,
            runDirectoryPath: storageRootURL.appendingPathComponent(requestedRunID, isDirectory: true).path,
            canonicalStatusPath: storageRootURL.appendingPathComponent(requestedRunID).appendingPathComponent("status.json").path,
            compatibilityRunStatusPath: storageRootURL.appendingPathComponent(requestedRunID).appendingPathComponent("_RUN_STATUS.json").path,
            eventsPath: storageRootURL.appendingPathComponent(requestedRunID).appendingPathComponent("events.jsonl").path,
            manifestPath: storageRootURL.appendingPathComponent(requestedRunID).appendingPathComponent("manifest.json").path
        )
    }
}

private struct ReleaseV080CLILocalSessionStatus: Codable {
    let issueID: String
    let upstreamIssueIDs: [String]
    let releaseVersion: String
    let runID: String
    let state: String
    let eventCount: Int
    let reason: String
    let createdAt: Date
    let updatedAt: Date
    let productionTradingEnabledByDefault: Bool
    let productionSecretRead: Bool
    let productionEndpointConnected: Bool
    let productionBrokerConnected: Bool
    let productionOrderSubmitted: Bool
    let productionCutoverAuthorized: Bool
    let testnetOrderSubmissionAllowed: Bool

    init(
        issueID: String = "GH-810",
        upstreamIssueIDs: [String] = ["GH-807", "GH-808", "GH-809"],
        releaseVersion: String = "v0.8.0",
        runID: String,
        state: String,
        eventCount: Int,
        reason: String,
        createdAt: Date,
        updatedAt: Date,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.state = state
        self.eventCount = eventCount
        self.reason = reason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed

        guard issueID == "GH-810",
              upstreamIssueIDs == ["GH-807", "GH-808", "GH-809"],
              releaseVersion == "v0.8.0",
              runID.isEmpty == false,
              eventCount >= 0,
              productionTradingEnabledByDefault == false,
              productionSecretRead == false,
              productionEndpointConnected == false,
              productionBrokerConnected == false,
              productionOrderSubmitted == false,
              productionCutoverAuthorized == false,
              testnetOrderSubmissionAllowed == false else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.localSession.status",
                expected: "GH-810 no-order local status",
                actual: runID
            )
        }
    }
}

private struct ReleaseV080CLILocalSessionManifest: Codable {
    let issueID: String
    let upstreamIssueIDs: [String]
    let releaseVersion: String
    let runID: String
    let state: String
    let eventsJSONLPath: String
    let statusJSONPath: String
    let runStatusJSONPath: String
    let manifestFileName: String
    let createdAt: Date
    let updatedAt: Date
    let artifacts: [ReleaseV080CLILocalSessionArtifactMetadata]
    let productionTradingEnabledByDefault: Bool
    let productionSecretRead: Bool
    let productionEndpointConnected: Bool
    let productionBrokerConnected: Bool
    let productionOrderSubmitted: Bool
    let productionCutoverAuthorized: Bool
    let testnetOrderSubmissionAllowed: Bool

    init(
        issueID: String = "GH-810",
        upstreamIssueIDs: [String] = ["GH-807", "GH-808", "GH-809"],
        releaseVersion: String = "v0.8.0",
        runID: String,
        state: String,
        eventsJSONLPath: String,
        statusJSONPath: String,
        runStatusJSONPath: String,
        manifestFileName: String = "manifest.json",
        createdAt: Date,
        updatedAt: Date,
        artifacts: [ReleaseV080CLILocalSessionArtifactMetadata],
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.state = state
        self.eventsJSONLPath = eventsJSONLPath
        self.statusJSONPath = statusJSONPath
        self.runStatusJSONPath = runStatusJSONPath
        self.manifestFileName = manifestFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.artifacts = artifacts
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed

        guard issueID == "GH-810",
              upstreamIssueIDs == ["GH-807", "GH-808", "GH-809"],
              releaseVersion == "v0.8.0",
              runID.isEmpty == false,
              manifestFileName == "manifest.json",
              artifacts.count == 3,
              artifacts.allSatisfy(\.required),
              productionTradingEnabledByDefault == false,
              productionSecretRead == false,
              productionEndpointConnected == false,
              productionBrokerConnected == false,
              productionOrderSubmitted == false,
              productionCutoverAuthorized == false,
              testnetOrderSubmissionAllowed == false else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.localSession.manifest",
                expected: "GH-810 no-order local manifest",
                actual: runID
            )
        }
    }
}

private struct ReleaseV080CLILocalSessionArtifactMetadata: Codable {
    let path: String
    let sha256: String
    let bytes: Int
    let required: Bool

    init(
        path: String,
        sha256: String,
        bytes: Int,
        required: Bool = true
    ) {
        self.path = path
        self.sha256 = sha256
        self.bytes = bytes
        self.required = required
    }
}

/// ReleaseV0110ReadinessCLI 是 GH-920 的本地 readiness artifact CLI binder。
///
/// 该 binder 只使用 `ProductionReadinessArtifactStore` 的 file URL root、JSON artifact、
/// manifest 和 bundle validation API。它不读取 production secret，不连接 endpoint / broker，
/// 不创建 testnet 或 production order，也不把 approval status 转成 production cutover permission。
private struct ReleaseV0110ReadinessCLI {
    private struct ArtifactSpec {
        let idComponent: String
        let fileName: String
        let title: String
    }

    private static let policyVersion = "policy-v0.11.0-readiness-cli-local"
    private static let manifestRelativePath = "manifest/readiness-manifest.json"
    private static let staleAfterSeconds: TimeInterval = 86_400
    private static let artifacts: [ArtifactSpec] = [
        ArtifactSpec(
            idComponent: "readiness-overview",
            fileName: "production-readiness-overview.json",
            title: "Production readiness overview"
        ),
        ArtifactSpec(
            idComponent: "environment-profile",
            fileName: "production-environment-profile.json",
            title: "Production environment profile"
        ),
        ArtifactSpec(
            idComponent: "secret-readiness",
            fileName: "secret-readiness.json",
            title: "Secret provider readiness reference"
        ),
        ArtifactSpec(
            idComponent: "endpoint-policy",
            fileName: "endpoint-policy-readiness.json",
            title: "Endpoint policy readiness reference"
        ),
        ArtifactSpec(
            idComponent: "risk-capital-limits",
            fileName: "risk-capital-limits.json",
            title: "Risk capital limit reference"
        ),
        ArtifactSpec(
            idComponent: "kill-switch-no-trade",
            fileName: "kill-switch-no-trade-readiness.json",
            title: "Kill switch no-trade reference"
        ),
        ArtifactSpec(
            idComponent: "command-surface-disabled",
            fileName: "command-surface-disabled.json",
            title: "Production command surface disabled proof"
        ),
        ArtifactSpec(
            idComponent: "shadow-dry-run-parity",
            fileName: "shadow-dry-run-parity.json",
            title: "Shadow dry-run parity reference"
        ),
        ArtifactSpec(
            idComponent: "approval-workflow",
            fileName: "approval-workflow.json",
            title: "Manual approval workflow reference"
        ),
        ArtifactSpec(
            idComponent: "readiness-bundle",
            fileName: "production-readiness-bundle.json",
            title: "Readiness bundle validation reference"
        )
    ]

    let action: String
    private let store: ProductionReadinessArtifactStore

    init(action: String) throws {
        self.action = action
        self.store = try ProductionReadinessArtifactStore()
    }

    func output() throws -> String {
        switch action {
        case "help":
            return helpOutput()
        case "build":
            return try buildOutput()
        case "status":
            return try statusOutput()
        case "validate":
            return try validateOutput()
        case "export":
            return try exportOutput()
        case "approval-status":
            return try approvalStatusOutput()
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.action",
                expected: "help,build,status,validate,export,approval-status",
                actual: "readiness \(action)"
            )
        }
    }

    private func helpOutput() -> String {
        (baseOutput(action: action, mutationApplied: false, artifactWritten: false, readinessBundleWritten: false) + [
            "supportedActions=\(MTPROStrictCLI.readinessSupportedActionCommands.joined(separator: ","))",
            "localArtifactRoot=\(store.evidenceRootURL.path)",
            "manifestRelativePath=\(Self.manifestRelativePath)",
            "requiredArtifactCount=\(Self.artifacts.count)",
            "readinessState=not-evaluated",
            "operatorApprovalStatus=not-authorized",
            "approvalCanAuthorizeProductionCutover=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func buildOutput() throws -> String {
        let now = Self.buildTimestamp()
        let descriptors = try Self.requiredDescriptors()
        for (index, descriptor) in descriptors.enumerated() {
            _ = try store.writeStringArtifact(
                descriptor: descriptor,
                string: try Self.payload(for: Self.artifacts[index]),
                modifiedAt: now
            )
        }
        let manifestDescriptor = try Self.manifestDescriptor()
        let manifest = try store.writeReadinessManifest(
            manifestID: manifestDescriptor.artifactID,
            manifestRelativePath: manifestDescriptor.relativePath,
            descriptors: descriptors,
            policyVersion: Self.policyVersion,
            generatedAt: now.addingTimeInterval(1),
            now: now
        )
        let validation = try store.validateReadinessBundle(
            manifestDescriptor: manifestDescriptor,
            requiredPolicyVersion: Self.policyVersion,
            requiredArtifactIDs: descriptors.map(\.artifactID),
            now: now.addingTimeInterval(2)
        )
        return (baseOutput(action: action, mutationApplied: true, artifactWritten: true, readinessBundleWritten: true) + [
            "localArtifactRoot=\(store.evidenceRootURL.path)",
            "manifestRelativePath=\(manifestDescriptor.relativePath)",
            "manifestArtifactID=\(manifest.manifest.manifestID.rawValue)",
            "requiredArtifactCount=\(descriptors.count)",
            "manifestEntryCount=\(manifest.manifest.entries.count)",
            "readinessState=\(validation.state.rawValue)",
            "readinessStateReason=\(validation.stateReason)",
            "bundleValidationHeld=\(validation.resultHeld)",
            "blockedState=\(validation.state != .valid)",
            "operatorApprovalStatus=not-authorized",
            "approvalCanAuthorizeProductionCutover=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func statusOutput() throws -> String {
        let descriptors = try Self.requiredDescriptors()
        let snapshot = try store.inspectArtifacts(descriptors, now: Date())
        let validation = try currentValidation(requiredArtifactIDs: descriptors.map(\.artifactID))
        return (baseOutput(action: action, mutationApplied: false, artifactWritten: false, readinessBundleWritten: false) + [
            "localArtifactRoot=\(store.evidenceRootURL.path)",
            "manifestRelativePath=\(Self.manifestRelativePath)",
            "readinessState=\(validation.state.rawValue)",
            "readinessStateReason=\(validation.stateReason)",
            "missingCount=\(snapshot.missingCount)",
            "invalidCount=\(snapshot.invalidCount)",
            "staleCount=\(snapshot.staleCount)",
            "validCount=\(snapshot.validCount)",
            "blockedState=\(validation.state != .valid)",
            "operatorApprovalStatus=not-authorized",
            "approvalCanAuthorizeProductionCutover=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func validateOutput() throws -> String {
        let descriptors = try Self.requiredDescriptors()
        let validation = try currentValidation(requiredArtifactIDs: descriptors.map(\.artifactID))
        return (baseOutput(action: action, mutationApplied: false, artifactWritten: false, readinessBundleWritten: false) + [
            "manifestRelativePath=\(Self.manifestRelativePath)",
            "readinessState=\(validation.state.rawValue)",
            "readinessStateReason=\(validation.stateReason)",
            "requiredArtifactIDs=\(validation.requiredArtifactIDs.map(\.rawValue).joined(separator: ","))",
            "manifestArtifactIDs=\(validation.manifestArtifactIDs.map(\.rawValue).joined(separator: ","))",
            "missingRequiredArtifactIDs=\(validation.missingRequiredArtifactIDs.map(\.rawValue).joined(separator: ","))",
            "unexpectedArtifactIDs=\(validation.unexpectedArtifactIDs.map(\.rawValue).joined(separator: ","))",
            "missingInvalidStaleChecksumMismatchStates=missing,invalid,stale,checksum-mismatch",
            "blockedState=\(validation.state != .valid)",
            "operatorApprovalStatus=not-authorized",
            "approvalCanAuthorizeProductionCutover=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func exportOutput() throws -> String {
        let descriptors = try Self.requiredDescriptors()
        let validation = try currentValidation(requiredArtifactIDs: descriptors.map(\.artifactID))
        let manifestDescriptor = try Self.manifestDescriptor()
        let manifestExists = (try? store.inspectArtifact(manifestDescriptor, now: Date()).state) == .valid
        return (baseOutput(action: action, mutationApplied: false, artifactWritten: false, readinessBundleWritten: false) + [
            "exportFormat=local-readiness-summary",
            "exportSnapshotOnly=true",
            "exportAvailable=\(manifestExists)",
            "localArtifactRoot=\(store.evidenceRootURL.path)",
            "manifestRelativePath=\(manifestDescriptor.relativePath)",
            "requiredArtifactFiles=\(Self.artifacts.map(\.fileName).joined(separator: ","))",
            "readinessState=\(validation.state.rawValue)",
            "readinessStateReason=\(validation.stateReason)",
            "operatorApprovalStatus=not-authorized",
            "approvalCanAuthorizeProductionCutover=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func approvalStatusOutput() throws -> String {
        let descriptors = try Self.requiredDescriptors()
        let validation = try currentValidation(requiredArtifactIDs: descriptors.map(\.artifactID))
        return (baseOutput(action: action, mutationApplied: false, artifactWritten: false, readinessBundleWritten: false) + [
            "readinessState=\(validation.state.rawValue)",
            "readinessStateReason=\(validation.stateReason)",
            "operatorApprovalStatus=not-authorized",
            "manualApprovalEvidenceLocalOnly=true",
            "approvalConvertedToTradingPermission=false",
            "approvalCanAuthorizeProductionCutover=false",
            "productionCutoverRemainsSeparatelyGated=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func currentValidation(
        requiredArtifactIDs: [Identifier]
    ) throws -> ProductionReadinessBundleValidationResult {
        try store.validateReadinessBundle(
            manifestDescriptor: Self.manifestDescriptor(),
            requiredPolicyVersion: Self.policyVersion,
            requiredArtifactIDs: requiredArtifactIDs,
            now: Date()
        )
    }

    private func baseOutput(
        action: String,
        mutationApplied: Bool,
        artifactWritten: Bool,
        readinessBundleWritten: Bool
    ) -> [String] {
        [
            "mtpro readiness \(action) v0.11.0",
            "issue=GH-920",
            "validationAnchor=\(MTPROStrictCLI.readinessCLILocalArtifactsValidationAnchor)",
            "verificationAnchor=\(MTPROStrictCLI.readinessCLILocalArtifactsVerificationAnchor)",
            "requiredAnchors=\(MTPROStrictCLI.readinessCLILocalArtifactsRequiredAnchors.joined(separator: ","))",
            "readinessPlaceholderContract=retired-by-v0.11.0",
            "readinessArtifactRuntimeImplemented=true",
            "productionReadinessArtifactStoreImplemented=true",
            "readinessCLIAllowed=true",
            "action=\(action)",
            "policyVersion=\(Self.policyVersion)",
            "mutationApplied=\(mutationApplied)",
            "artifactWritten=\(artifactWritten)",
            "readinessBundleWritten=\(readinessBundleWritten)",
            "noSecretValue=true",
            "noOrderPayload=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "productionCutoverAuthorized=false"
        ]
    }

    private static func buildTimestamp() -> Date {
        Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
    }

    private static func requiredDescriptors() throws -> [ProductionReadinessArtifactDescriptor] {
        try artifacts.map { spec in
            try ProductionReadinessArtifactDescriptor(
                artifactID: Identifier.constant("gh-920-\(spec.idComponent)"),
                relativePath: "artifacts/\(spec.fileName)",
                artifactType: .jsonEvidence,
                staleAfterSeconds: staleAfterSeconds
            )
        }
    }

    private static func manifestDescriptor() throws -> ProductionReadinessArtifactDescriptor {
        try ProductionReadinessArtifactDescriptor(
            artifactID: Identifier.constant("gh-920-readiness-manifest"),
            relativePath: manifestRelativePath,
            artifactType: .jsonEvidence
        )
    }

    private static func payload(for spec: ArtifactSpec) throws -> String {
        let object: [String: Any] = [
            "artifactID": "gh-920-\(spec.idComponent)",
            "releaseVersion": "v0.11.0",
            "sourceIssueID": "GH-920",
            "title": spec.title,
            "policyVersion": policyVersion,
            "validationState": "valid",
            "evidenceExists": true,
            "stateReason": "local readiness artifact generated",
            "localFileURLOnly": true,
            "redactionProof": true,
            "noSecretValue": true,
            "noOrderPayload": true,
            "productionTradingEnabledByDefault": false,
            "productionCutoverAuthorized": false,
            "productionSecretRead": false,
            "productionEndpointConnected": false,
            "brokerEndpointConnected": false,
            "productionOrderSubmitted": false,
            "testnetOrderSubmissionAllowed": false,
            "operatorApprovalStatus": "not-authorized",
            "approvalConvertedToTradingPermission": false
        ]
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        guard let payload = String(data: data, encoding: .utf8) else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.payload",
                expected: "UTF-8 JSON",
                actual: spec.fileName
            )
        }
        return payload
    }
}

/// ReleaseV0120ReadinessAssessmentCLI 是 GH-963 的 assessment-scoped readiness CLI binder。
///
/// 该 binder 只读写 v0.12.0 本地 readiness registry / assessment artifact root，并通过
/// `ReadinessAssessmentRegistryStore` 生成 assessment metadata、manifest、bundle 和 compare
/// report evidence。它不读取 secret、不连接 production endpoint / broker，不提交 / 取消 /
/// 替换订单，也不把任何 readiness result 升级为 production cutover authorization。
private struct ReleaseV0121ReadinessLocalEvidenceArtifactMetadata {
    let artifactID: Identifier
    let generationID: Identifier
    let url: URL
    let relativePath: String
    let data: Data
    let artifactSHA256: String
    let artifactBytes: Int
    let sourceRunID: Identifier
}

private struct ReleaseV0121ReadinessLocalSourceRunEvidence: Decodable {
    let sourceRunManifestChecksum: String
    let eventIDs: [String]
    let riskDecisionIDs: [String]
    let omsDryRunLifecycleIDs: [String]
    let portfolioProjectionChecksum: String
    let reconciliationChecksum: String
}

private typealias LocalEvidenceArtifactMetadata = ReleaseV0121ReadinessLocalEvidenceArtifactMetadata
private typealias LocalSourceRunEvidence = ReleaseV0121ReadinessLocalSourceRunEvidence

/// ReleaseV0130LocalEvidenceIntakeCLI 是 GH-995 的本地证据 intake CLI binder。
///
/// 该 binder 只读取调用方显式传入的 local evidence root，并输出 discover / validate
/// diagnostics；它不写 assessment output、不写 registry、不生成 bundle、不做 diff，也不触发
/// production secret / endpoint / broker / order capability。
private struct ReleaseV0130LocalEvidenceIntakeCLI {
    private static let validationAnchor = "GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL"
    private static let matrixAnchor = "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL"
    private static let requiredAnchors = [
        "V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT",
        "V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS",
        "V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS",
        "V0130-002-MISSING-MALFORMED-FAILS-CLOSED",
        "V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER",
        "V0130-002-READ-ONLY-INTAKE"
    ]

    let evidenceRootPath: String
    private let model: ReleaseV0130LocalEvidenceIntakeModel

    init(
        evidenceRootPath: String,
        model: ReleaseV0130LocalEvidenceIntakeModel = ReleaseV0130LocalEvidenceIntakeModel()
    ) {
        self.evidenceRootPath = evidenceRootPath
        self.model = model
    }

    func output() throws -> String {
        let report = try model.validate(
            evidenceRootURL: URL(fileURLWithPath: evidenceRootPath, isDirectory: true)
        )
        let stateByCategory = Dictionary(uniqueKeysWithValues: report.records.map {
            ($0.descriptor.category.rawValue, $0.state.rawValue)
        })
        let validCategories = report.records
            .filter { $0.state == .valid }
            .map(\.descriptor.category.rawValue)
            .joined(separator: ",")
        let failedCategories = report.records
            .filter { $0.state != .valid }
            .map(\.descriptor.category.rawValue)
            .joined(separator: ",")
        let diagnostics = report.diagnostics.isEmpty
            ? "none"
            : report.diagnostics.map { $0.replacingOccurrences(of: "\n", with: " ") }.joined(separator: " | ")
        let requiredAnchors = ([
            Self.validationAnchor,
            Self.matrixAnchor
        ] + Self.requiredAnchors).joined(separator: ",")

        return [
            "mtpro readiness intake v0.13.0",
            "issue=GH-995",
            "validationAnchor=\(Self.validationAnchor)",
            "matrixAnchor=\(Self.matrixAnchor)",
            "requiredAnchors=\(requiredAnchors)",
            "action=intake",
            "evidenceRoot=\(report.evidenceRootPath)",
            "requiredDirectories=\(report.requiredDirectoryPaths.joined(separator: ","))",
            "recordCount=\(report.records.count)",
            "categoryStates=\(stateByCategory.sorted { $0.key < $1.key }.map { "\($0.key):\($0.value)" }.joined(separator: ","))",
            "validCategories=\(validCategories)",
            "failedCategories=\(failedCategories)",
            "intakeValid=\(report.valid)",
            "failClosed=\(report.failClosed)",
            "diagnosticCount=\(report.diagnostics.count)",
            "missingDiagnosticCount=\(report.missingDiagnostics.count)",
            "malformedDiagnosticCount=\(report.malformedDiagnostics.count)",
            "forbiddenDiagnosticCount=\(report.forbiddenDiagnostics.count)",
            "diagnostics=\(diagnostics)",
            "localReadOnly=\(report.readOnlyIntake)",
            "assessmentOutputWritten=\(report.assessmentOutputWritten)",
            "registryWritten=\(report.registryWritten)",
            "bundleWritten=\(report.bundleWritten)",
            "diffBuilt=\(report.diffBuilt)",
            "noSecretValue=true",
            "noEndpointPayload=true",
            "noOrderPayload=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=\(report.localFileURLOnly && report.productionCapabilitiesDisabled)"
        ].joined(separator: "\n")
    }
}

/// ReleaseV0130LocalEvidenceProvenanceBuildCLI 是 GH-997 的 deterministic build pipeline 入口。
///
/// 该 binder 必须先消费 #995 已验证的显式 local evidence root，再把 sourceCommit、
/// sourceRunIDs、artifact bytes 和 checksum 交给 #997 schema / checksum / policy /
/// manifest / bundle / registry flow。它不会从 assessmentID 伪造 source run，不生成
/// synthetic artifact metadata，不执行 diff，也不授权 production secret、endpoint、broker
/// 或订单能力。
private struct ReleaseV0130LocalEvidenceProvenanceBuildCLI {
    private static let readinessRootEnvironmentKey = "MTPRO_READINESS_ROOT"
    private static let validationAnchor = "GH-997-VERIFY-V0130-BUILD-PIPELINE"
    private static let matrixAnchor = "TVM-RELEASE-V0130-BUILD-PIPELINE"
    private static let producerVersion = "mtpro-cli-v0.13.0"
    private static let requiredAnchors = [
        "V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW",
        "V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE",
        "V0130-004-PROVENANCE-VALIDATION-REPORT",
        "V0130-004-BUILD-FAILS-CLOSED",
        "V0130-004-NO-PRODUCTION-CUTOVER",
        "GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION",
        "TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION",
        "V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE",
        "V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA",
        "V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED",
        "V0130-003-FIXTURE-ONLY-ISOLATION",
        "V0130-003-NO-PRODUCTION-CUTOVER"
    ]

    let assessmentID: Identifier
    let evidenceRootPath: String
    let store: ReadinessAssessmentRegistryStore
    private let model: ReleaseV0130LocalEvidenceIntakeModel

    init(
        assessmentID: Identifier,
        evidenceRootPath: String,
        storageRootURL: URL? = nil,
        fileManager: FileManager = .default,
        model: ReleaseV0130LocalEvidenceIntakeModel = ReleaseV0130LocalEvidenceIntakeModel()
    ) {
        self.assessmentID = assessmentID
        self.evidenceRootPath = evidenceRootPath
        self.model = model
        if let storageRootURL {
            self.store = ReadinessAssessmentRegistryStore(storageRootURL: storageRootURL, fileManager: fileManager)
        } else if let override = ProcessInfo.processInfo.environment[Self.readinessRootEnvironmentKey],
                  override.isEmpty == false {
            self.store = ReadinessAssessmentRegistryStore(
                storageRootURL: URL(fileURLWithPath: override, isDirectory: true),
                fileManager: fileManager
            )
        } else {
            self.store = ReadinessAssessmentRegistryStore(
                storageRootURL: URL(
                    fileURLWithPath: ReadinessAssessmentRegistryStore.defaultRelativeRoot,
                    isDirectory: true
                ),
                fileManager: fileManager
            )
        }
    }

    func output() throws -> String {
        let now = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
        let evidenceRootURL = URL(fileURLWithPath: evidenceRootPath, isDirectory: true)
        let generationID = try ReleaseV0130GenerationIDFactory.makeGenerationID(
            assessmentID: assessmentID,
            scope: "v0130-generation",
            createdAt: now,
            stableComponents: [
                evidenceRootURL.standardizedFileURL.path,
                Self.producerVersion
            ]
        )
        let result = try model.buildPipeline(
            assessmentID: assessmentID,
            generationID: generationID,
            evidenceRootURL: evidenceRootURL,
            store: store,
            createdAt: now
        )

        let requiredAnchors = ([
            Self.validationAnchor,
            Self.matrixAnchor
        ] + Self.requiredAnchors).joined(separator: ",")
        let artifactPaths = result.provenance.artifactProvenances.map(\.relativePath).joined(separator: ",")
        let artifactChecksums = result.provenance.artifactProvenances
            .map { "\($0.relativePath)=\($0.sha256)" }
            .joined(separator: ",")
        let artifactByteCounts = result.provenance.artifactProvenances
            .map { "\($0.relativePath)=\($0.byteCount)" }
            .joined(separator: ",")
        let contentValidationChecksums = result.contentValidations
            .map { "\($0.artifactID.rawValue)=\($0.contentValidationChecksum)" }
            .joined(separator: ",")
        let policyChecksums = result.validationReport.artifactValidations
            .map { "\($0.artifactID.rawValue)=\($0.policyChecksum)" }
            .joined(separator: ",")
        let observedFields = result.validationReport.artifactValidations
            .map { "\($0.artifactID.rawValue)=\($0.observedTopLevelJSONFields.joined(separator: "+"))" }
            .joined(separator: ",")

        return [
            "mtpro readiness build-v013 v0.13.0",
            "issue=GH-997",
            "provenanceIssue=GH-996",
            "validationAnchor=\(Self.validationAnchor)",
            "matrixAnchor=\(Self.matrixAnchor)",
            "requiredAnchors=\(requiredAnchors)",
            "action=build-v013",
            "assessmentID=\(result.registryEntry.assessmentID.rawValue)",
            "generationID=\(result.manifest.generationID.rawValue)",
            "evidenceRoot=\(result.provenance.evidenceRootPath)",
            "evidenceClassification=\(result.provenance.evidenceClassification)",
            "sourceCommit=\(result.provenance.sourceCommit)",
            "sourceRunIDs=\(result.provenance.sourceRunIDs.map(\.rawValue).joined(separator: ","))",
            "artifactRelativePaths=\(artifactPaths)",
            "artifactChecksums=\(artifactChecksums)",
            "artifactByteCounts=\(artifactByteCounts)",
            "schemaValidated=\(result.validationReport.schemaValidated)",
            "checksumValidated=\(result.validationReport.checksumValidated)",
            "contentPolicyValidated=\(result.validationReport.contentPolicyValidated)",
            "policyChecksums=\(policyChecksums)",
            "contentValidationChecksums=\(contentValidationChecksums)",
            "observedTopLevelJSONFields=\(observedFields)",
            "validationReportChecksum=\(result.validationReport.validationReportChecksum)",
            "manifestArtifactSHA256=\(result.manifest.artifactSHA256)",
            "manifestArtifactBytes=\(result.manifest.artifactBytes)",
            "manifestV2Path=\(result.manifest.manifestV2Path)",
            "manifestChecksum=\(result.manifest.manifestChecksum)",
            "manifestWritten=true",
            "readinessBundlePath=\(result.bundleWrite.bundle.bundlePath)",
            "readinessBundleChecksum=\(result.bundleWrite.bundle.bundleChecksum)",
            "readinessBundleManifestPath=\(result.bundleWrite.manifest.manifestPath)",
            "readinessBundleManifestChecksum=\(result.bundleWrite.manifest.manifestChecksum)",
            "readinessBundleWritten=true",
            "registryEntryConfirmed=true",
            "registryEntryCreated=\(result.registryEntryCreated)",
            "registryChecksum=\(result.registryDocument.registryChecksum)",
            "registryLifecycleWritten=true",
            "diffBuilt=false",
            "syntheticProvenanceRejected=\(result.provenance.syntheticProvenanceRejected)",
            "fixtureOnly=\(result.provenance.fixtureOnly)",
            "fixtureOnlyEvidenceRejected=true",
            "localEvidenceTraceable=\(result.provenance.localEvidenceTraceable)",
            "normalManifestEligible=\(result.provenance.normalManifestEligible)",
            "noSecretValue=true",
            "noEndpointPayload=true",
            "noOrderPayload=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=\(result.pipelineHeld)"
        ].joined(separator: "\n")
    }
}

private struct ReleaseV0120ReadinessAssessmentCLI {
    private static let readinessRootEnvironmentKey = "MTPRO_READINESS_ROOT"
    private static let sourceCommitEnvironmentKey = "MTPRO_READINESS_SOURCE_COMMIT"
    private static let sourceCommitExpectedDescription =
        "\(sourceCommitEnvironmentKey)=<40 lowercase hex commit> or verified local git HEAD"
    private static let producerVersion = "mtpro-cli-v0.12.0"
    private static let localEvidenceArtifactFileName = "readiness-summary.json"
    private static let localEvidenceArtifactJSONFields = [
        "assessmentID",
        "artifactPath",
        "brokerEndpointConnected",
        "createdAtEpochSeconds",
        "evidenceKind",
        "generationID",
        "localOnly",
        "noOrderPayload",
        "noSecretValue",
        "omsDryRunLifecycleIDs",
        "portfolioProjectionChecksum",
        "producerVersion",
        "productionCutoverAuthorized",
        "productionEndpointConnected",
        "productionOrderSubmitted",
        "productionSecretRead",
        "productionTradingEnabledByDefault",
        "redactedEvidenceOnly",
        "reconciliationChecksum",
        "registryEntryChecksum",
        "riskDecisionIDs",
        "sourceCommit",
        "sourceRunManifestChecksum",
        "eventIDs"
    ]
    private static let validationMarkerFileName = "validation-state.json"
    private static let exportMarkerFileName = "export-state.json"

    private struct ReadinessLifecycleSnapshot {
        let generationID: Identifier
        let manifestChecksum: String
        let readinessBundleChecksum: String
        let readinessBundleManifestChecksum: String
        let artifactSHA256: String
        let artifactBytes: Int
        let sourceRunIDs: [String]
        let sourceCommit: String
        let producerVersion: String
    }

    private struct ReadinessLifecycleValidationMarker: Codable, Equatable {
        let issueID: String
        let assessmentID: String
        let generationID: String
        let validationState: String
        let evidenceChainCoherent: Bool
        let manifestChecksum: String
        let readinessBundleChecksum: String
        let readinessBundleManifestChecksum: String
        let artifactSHA256: String
        let artifactBytes: Int
        let sourceRunIDs: [String]
        let sourceCommit: String
        let producerVersion: String
        let validatedAtEpochSeconds: Int
        let productionTradingEnabledByDefault: Bool
        let productionSecretRead: Bool
        let productionEndpointConnected: Bool
        let brokerEndpointConnected: Bool
        let productionOrderSubmitted: Bool
        let productionCutoverAuthorized: Bool

        var markerHeld: Bool {
            issueID == "GH-1003"
                && validationState == "valid"
                && evidenceChainCoherent
                && assessmentID.isEmpty == false
                && generationID.isEmpty == false
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(manifestChecksum)
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleChecksum)
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleManifestChecksum)
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactSHA256)
                && artifactBytes > 0
                && sourceRunIDs.isEmpty == false
                && sourceRunIDs.allSatisfy { $0.isEmpty == false }
                && ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit)
                && producerVersion.isEmpty == false
                && productionTradingEnabledByDefault == false
                && productionSecretRead == false
                && productionEndpointConnected == false
                && brokerEndpointConnected == false
                && productionOrderSubmitted == false
                && productionCutoverAuthorized == false
        }

        func matches(_ snapshot: ReadinessLifecycleSnapshot) -> Bool {
            generationID == snapshot.generationID.rawValue
                && manifestChecksum == snapshot.manifestChecksum
                && readinessBundleChecksum == snapshot.readinessBundleChecksum
                && readinessBundleManifestChecksum == snapshot.readinessBundleManifestChecksum
                && artifactSHA256 == snapshot.artifactSHA256
                && artifactBytes == snapshot.artifactBytes
                && sourceRunIDs == snapshot.sourceRunIDs
                && sourceCommit == snapshot.sourceCommit
                && producerVersion == snapshot.producerVersion
        }
    }

    private struct ReadinessLifecycleExportMarker: Codable, Equatable {
        let issueID: String
        let assessmentID: String
        let generationID: String
        let exportFormat: String
        let exportDirectoryPath: String
        let validationState: String
        let evidenceChainCoherent: Bool
        let manifestChecksum: String
        let readinessBundleChecksum: String
        let readinessBundleManifestChecksum: String
        let validationMarkerPath: String
        let exportedAtEpochSeconds: Int
        let productionTradingEnabledByDefault: Bool
        let productionSecretRead: Bool
        let productionEndpointConnected: Bool
        let brokerEndpointConnected: Bool
        let productionOrderSubmitted: Bool
        let productionCutoverAuthorized: Bool

        var markerHeld: Bool {
            issueID == "GH-1003"
                && assessmentID.isEmpty == false
                && generationID.isEmpty == false
                && exportFormat.isEmpty == false
                && exportDirectoryPath.isEmpty == false
                && validationState == "valid"
                && evidenceChainCoherent
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(manifestChecksum)
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleChecksum)
                && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleManifestChecksum)
                && validationMarkerPath.hasSuffix(Self.validationMarkerFileSuffix)
                && productionTradingEnabledByDefault == false
                && productionSecretRead == false
                && productionEndpointConnected == false
                && brokerEndpointConnected == false
                && productionOrderSubmitted == false
                && productionCutoverAuthorized == false
        }

        private static let validationMarkerFileSuffix = "/\(ReleaseV0120ReadinessAssessmentCLI.validationMarkerFileName)"

        func matches(
            validationMarker: ReadinessLifecycleValidationMarker,
            snapshot: ReadinessLifecycleSnapshot
        ) -> Bool {
            validationMarker.markerHeld
                && validationMarker.matches(snapshot)
                && generationID == snapshot.generationID.rawValue
                && validationState == validationMarker.validationState
                && evidenceChainCoherent == validationMarker.evidenceChainCoherent
                && manifestChecksum == snapshot.manifestChecksum
                && readinessBundleChecksum == snapshot.readinessBundleChecksum
                && readinessBundleManifestChecksum == snapshot.readinessBundleManifestChecksum
        }
    }

    let action: String
    let assessmentID: Identifier?
    let comparisonAssessmentID: Identifier?
    let store: ReadinessAssessmentRegistryStore
    let sourceCommitResolver: () throws -> String

    init(
        action: String,
        assessmentID: Identifier?,
        comparisonAssessmentID: Identifier?,
        storageRootURL: URL? = nil,
        fileManager: FileManager = .default,
        sourceCommitResolver: (() throws -> String)? = nil
    ) {
        self.action = action
        self.assessmentID = assessmentID
        self.comparisonAssessmentID = comparisonAssessmentID
        self.sourceCommitResolver = sourceCommitResolver ?? Self.defaultSourceCommit
        if let storageRootURL {
            self.store = ReadinessAssessmentRegistryStore(storageRootURL: storageRootURL, fileManager: fileManager)
        } else if let override = ProcessInfo.processInfo.environment[Self.readinessRootEnvironmentKey],
                  override.isEmpty == false {
            self.store = ReadinessAssessmentRegistryStore(
                storageRootURL: URL(fileURLWithPath: override, isDirectory: true),
                fileManager: fileManager
            )
        } else {
            self.store = ReadinessAssessmentRegistryStore(
                storageRootURL: URL(
                    fileURLWithPath: ReadinessAssessmentRegistryStore.defaultRelativeRoot,
                    isDirectory: true
                ),
                fileManager: fileManager
            )
        }
    }

    func output() throws -> String {
        switch action {
        case "create":
            return try createOutput()
        case "build":
            return try buildOutput()
        case "status":
            return try statusOutput()
        case "validate":
            return try validateOutput()
        case "export":
            return try exportOutput()
        case "archive":
            return try archiveOutput()
        case "compare":
            return try compareOutput()
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.action",
                expected: "create,build,status,validate,export,archive,compare",
                actual: "readiness \(action)"
            )
        }
    }

    private func createOutput() throws -> String {
        let now = Self.canonicalNow()
        let resolvedAssessmentID = assessmentID
            ?? Identifier.constant("gh-963-assessment-\(UUID().uuidString.lowercased())")
        let document = try store.create(
            assessmentID: resolvedAssessmentID,
            state: .baseline,
            sourceReleaseVersion: "v0.12.0",
            sourcePatchVersion: "v0.11.1",
            assessedBy: "Codex",
            reason: "assessment-scoped CLI lifecycle create",
            createdAt: now,
            updatedAt: now
        )
        let entry = try document.inspect(assessmentID: resolvedAssessmentID)
        return (baseOutput(action: action, entry: entry, mutationApplied: true) + [
            "created=true",
            "registryEntryCount=\(document.entries.count)",
            "assessmentDirectoryPath=\(entry.artifactPaths.assessmentDirectoryPath)",
            "metadataJSONPath=\(entry.artifactPaths.metadataJSONPath)",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func buildOutput() throws -> String {
        let entry = try requiredEntry()
        let now = Self.canonicalNow()
        let sourceCommit = try sourceCommitResolver()
        let generationID = try ReleaseV0130GenerationIDFactory.makeGenerationID(
            assessmentID: entry.assessmentID,
            scope: "generation",
            createdAt: now,
            stableComponents: [
                sourceCommit,
                entry.entryChecksum,
                Self.producerVersion
            ]
        )
        let localEvidenceArtifact = try writeLocalEvidenceArtifact(
            entry: entry,
            generationID: generationID,
            sourceCommit: sourceCommit,
            createdAt: now
        )
        let manifest = try ReadinessAssessmentManifestV2(
            assessmentID: entry.assessmentID,
            generationID: generationID,
            sourceRunIDs: [localEvidenceArtifact.sourceRunID],
            sourceCommit: sourceCommit,
            artifactContentType: .jsonEvidence,
            artifactSHA256: localEvidenceArtifact.artifactSHA256,
            artifactBytes: localEvidenceArtifact.artifactBytes,
            createdAt: now,
            producerVersion: Self.producerVersion
        )
        _ = try store.writeManifestV2(manifest)

        let contentPolicy = try localEvidenceArtifactContentPolicy(artifactID: localEvidenceArtifact.artifactID)
        let contentValidation = try store.validateArtifactContent(
            data: localEvidenceArtifact.data,
            manifest: manifest,
            policy: contentPolicy,
            validatedAt: now.addingTimeInterval(1)
        )
        let artifactSnapshot = try ReadinessAssessmentBundleV2ArtifactSnapshot(
            artifactID: localEvidenceArtifact.artifactID,
            manifestChecksum: manifest.manifestChecksum,
            artifactSHA256: localEvidenceArtifact.artifactSHA256,
            contentValidationChecksum: contentValidation.contentValidationChecksum,
            artifactPath: localEvidenceArtifact.relativePath
        )
        let bundle = try ReadinessAssessmentBundleV2(
            assessmentID: entry.assessmentID,
            generationID: generationID,
            reviewState: .inReview,
            sourceRunIDs: manifest.sourceRunIDs,
            sourceCommit: manifest.sourceCommit,
            artifactSnapshots: [artifactSnapshot],
            createdAt: now.addingTimeInterval(1),
            producerVersion: Self.producerVersion
        )
        let writeResult = try store.writeReadinessBundleV2ReviewSnapshot(bundle)
        return (baseOutput(action: action, entry: entry, mutationApplied: true) + [
            "generationID=\(generationID.rawValue)",
            "sourceRunIDs=\(manifest.sourceRunIDs.map(\.rawValue).joined(separator: ","))",
            "sourceCommit=\(manifest.sourceCommit)",
            "localEvidenceArtifactPath=\(localEvidenceArtifact.relativePath)",
            "artifactSHA256=\(manifest.artifactSHA256)",
            "artifactBytes=\(manifest.artifactBytes)",
            "contentValidationChecksum=\(contentValidation.contentValidationChecksum)",
            "manifestV2Path=\(manifest.manifestV2Path)",
            "manifestChecksum=\(manifest.manifestChecksum)",
            "readinessBundlePath=\(writeResult.bundle.bundlePath)",
            "readinessBundleChecksum=\(writeResult.bundle.bundleChecksum)",
            "readinessBundleManifestPath=\(writeResult.manifest.manifestPath)",
            "artifactWritten=true",
            "readinessBundleWritten=true",
            "readinessState=in-review",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func statusOutput() throws -> String {
        let entry = try requiredEntry()
        let manifest = try? store.readManifestV2(assessmentID: entry.assessmentID)
        return (baseOutput(action: action, entry: entry, mutationApplied: false) + [
            "registryState=\(entry.state.rawValue)",
            "registryLifecycle=\(entry.lifecycle.rawValue)",
            "manifestV2Present=\(manifest != nil)",
            "generationID=\(manifest?.generationID.rawValue ?? "not-built")",
            "sourceCommit=\(manifest?.sourceCommit ?? "not-built")",
            "manifestChecksum=\(manifest?.manifestChecksum ?? "not-built")",
            "readinessState=\(manifest == nil ? "not-built" : "in-review")",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func validateOutput() throws -> String {
        let entry = try requiredEntry()
        let manifest = try? store.readManifestV2(assessmentID: entry.assessmentID)
        let localEvidenceArtifact = try? manifest.map {
            try localEvidenceArtifactMetadata(
                entry: entry,
                generationID: $0.generationID,
                artifactID: Self.localEvidenceArtifactID(for: entry)
            )
        }
        let artifactEvidenceMatchesManifest: Bool = {
            guard let manifest, let localEvidenceArtifact else {
                return false
            }
            return manifest.artifactSHA256 == localEvidenceArtifact.artifactSHA256
                && manifest.artifactBytes == localEvidenceArtifact.artifactBytes
                && manifest.sourceRunIDs == [localEvidenceArtifact.sourceRunID]
        }()
        let evidenceChainReport = try ReleaseV0130LocalEvidenceIntakeModel(
            fileManager: store.fileManager
        ).validateEvidenceChain(
            assessmentID: entry.assessmentID,
            store: store
        )
        let validationMarker = try writeValidationMarkerIfValid(
            entry: entry,
            evidenceChainReport: evidenceChainReport,
            validatedAt: Self.canonicalNow()
        )
        return (baseOutput(action: action, entry: entry, mutationApplied: false) + [
            "issue=GH-998",
            "lifecycleIssue=GH-1003",
            "v013ValidationAnchor=GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE",
            "v013MatrixAnchor=TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE",
            "v013ConsistencyAnchor=V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY",
            "v013ArtifactPolicyAnchor=V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE",
            "v013ExportComparisonAnchor=V0130-005-EXPORT-COMPARISON-IDENTITY",
            "v013FailClosedAnchor=V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED",
            "v013NoCutoverAnchor=V0130-005-NO-PRODUCTION-CUTOVER",
            "assessmentIDValid=true",
            "registryEntryHeld=\(entry.entryHeld)",
            "manifestV2Present=\(manifest != nil)",
            "manifestHeld=\(manifest?.manifestHeld ?? false)",
            "artifactEvidencePresent=\(localEvidenceArtifact != nil)",
            "artifactEvidenceMatchesManifest=\(artifactEvidenceMatchesManifest)",
            "registryDocumentHeld=\(evidenceChainReport.registryDocumentHeld)",
            "bundleV2Present=\(evidenceChainReport.bundleV2Present)",
            "bundleHeld=\(evidenceChainReport.bundleHeld)",
            "bundleManifestPresent=\(evidenceChainReport.bundleManifestPresent)",
            "bundleManifestHeld=\(evidenceChainReport.bundleManifestHeld)",
            "bundleBytesMatchManifest=\(evidenceChainReport.bundleBytesMatchManifest)",
            "registryManifestAssessmentMatches=\(evidenceChainReport.registryManifestAssessmentMatches)",
            "manifestBundleIdentityMatches=\(evidenceChainReport.manifestBundleIdentityMatches)",
            "manifestBundleProvenanceMatches=\(evidenceChainReport.manifestBundleProvenanceMatches)",
            "artifactSnapshotsPresent=\(evidenceChainReport.artifactSnapshotsPresent)",
            "artifactSnapshotsMatchManifest=\(evidenceChainReport.artifactSnapshotsMatchManifest)",
            "contentValidationChecksumsPresent=\(evidenceChainReport.contentValidationChecksumsPresent)",
            "exportComparisonIdentityConsistent=\(evidenceChainReport.exportComparisonIdentityConsistent)",
            "evidenceChainCoherent=\(evidenceChainReport.evidenceChainCoherent)",
            "failureReasons=\(evidenceChainReport.failureReasons.isEmpty ? "none" : evidenceChainReport.failureReasons.joined(separator: ","))",
            "productionCapabilitiesDisabled=\(entry.productionCapabilitiesDisabled)",
            "validationState=\(evidenceChainReport.validationState)",
            "validationMarkerWritten=\(validationMarker != nil)",
            "validationMarkerHeld=\(validationMarker?.markerHeld ?? false)",
            "validationMarkerPath=\(Self.lifecycleMarkerRelativePath(for: entry, fileName: Self.validationMarkerFileName))",
            "lifecycleOrderHeld=\(validationMarker?.markerHeld ?? false)",
            "nextRequiredAction=\(validationMarker?.markerHeld == true ? "readiness export \(entry.assessmentID.rawValue)" : "readiness build \(entry.assessmentID.rawValue)")",
            "invalidAssessmentIDsFailClosed=true",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func exportOutput() throws -> String {
        let entry = try requiredEntry()
        let validationMarker = try requireValidValidationMarker(entry: entry)
        guard try redactedAuditExportPackageEligible(entry: entry) else {
            return try snapshotExportOutput(entry: entry, validationMarker: validationMarker)
        }
        return try redactedAuditExportPackageOutput(entry: entry, validationMarker: validationMarker)
    }

    /// #999 的 package writer 只接管 `build-v013` 产出的 v0.13 evidence-chain。
    ///
    /// 普通 `readiness build` 仍属于 v0.12 assessment CLI contract，必须保持
    /// `exportSnapshotOnly=true`，避免破坏历史 release guard。
    private func redactedAuditExportPackageEligible(entry: ReadinessAssessmentRegistryEntry) throws -> Bool {
        let manifest = try? store.readManifestV2(assessmentID: entry.assessmentID)
        return manifest?.producerVersion.hasPrefix("mtpro-v0.13.0") == true
    }

    private func snapshotExportOutput(
        entry: ReadinessAssessmentRegistryEntry,
        validationMarker: ReadinessLifecycleValidationMarker
    ) throws -> String {
        let manifest = try? store.readManifestV2(assessmentID: entry.assessmentID)
        let exportMarker = try writeExportMarker(
            entry: entry,
            validationMarker: validationMarker,
            exportFormat: "redacted-readiness-assessment-summary",
            exportDirectoryPath: entry.artifactPaths.redactedExportDirectoryPath,
            exportedAt: Self.canonicalNow()
        )
        return (baseOutput(action: action, entry: entry, mutationApplied: false) + [
            "lifecycleIssue=GH-1003",
            "exportFormat=redacted-readiness-assessment-summary",
            "exportSnapshotOnly=true",
            "exportDirectoryPath=\(entry.artifactPaths.redactedExportDirectoryPath)",
            "manifestV2Present=\(manifest != nil)",
            "validationMarkerHeld=\(validationMarker.markerHeld)",
            "exportMarkerWritten=true",
            "exportMarkerHeld=\(exportMarker.markerHeld)",
            "exportMarkerPath=\(Self.lifecycleMarkerRelativePath(for: entry, fileName: Self.exportMarkerFileName))",
            "lifecycleOrderHeld=\(validationMarker.markerHeld && exportMarker.markerHeld)",
            "nextRequiredAction=readiness compare/archive",
            "redactedEvidenceOnly=true",
            "noSecretValue=true",
            "noOrderPayload=true",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func redactedAuditExportPackageOutput(
        entry: ReadinessAssessmentRegistryEntry,
        validationMarker: ReadinessLifecycleValidationMarker
    ) throws -> String {
        let report = try ReleaseV0130LocalEvidenceIntakeModel(
            fileManager: store.fileManager
        ).writeRedactedAuditExportPackage(
            assessmentID: entry.assessmentID,
            store: store
        )
        let exportMarker = try writeExportMarker(
            entry: entry,
            validationMarker: validationMarker,
            exportFormat: "redacted-audit-export-package",
            exportDirectoryPath: report.exportDirectoryPath,
            exportedAt: Self.canonicalNow()
        )
        return (baseOutput(action: action, entry: entry, mutationApplied: false) + [
            "issue=GH-999",
            "lifecycleIssue=GH-1003",
            "v013ValidationAnchor=GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE",
            "v013MatrixAnchor=TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE",
            "v013ExportPackageAnchor=V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE",
            "v013CompletePackageAnchor=V0130-006-COMPLETE-AUDIT-PACKAGE",
            "v013ChecksumAnchor=V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE",
            "v013FailClosedAnchor=V0130-006-MISSING-EVIDENCE-FAILS-CLOSED",
            "v013NoSecretCutoverAnchor=V0130-006-NO-SECRET-PRODUCTION-CUTOVER",
            "exportFormat=redacted-audit-export-package",
            "exportSnapshotOnly=false",
            "exportDirectoryPath=\(report.exportDirectoryPath)",
            "packageFileNames=\(report.files.map(\.fileName).joined(separator: ","))",
            "packageComplete=\(report.packageComplete)",
            "exportedChecksumsMatchSource=\(report.exportedChecksumsMatchSource)",
            "evidenceChainCoherent=\(report.evidenceChainCoherent)",
            "provenanceSummaryJSONPath=\(report.provenanceSummaryJSONPath)",
            "comparisonMetadataJSONPath=\(report.comparisonMetadataJSONPath)",
            "missingEvidenceFailsClosed=\(report.missingEvidenceFailsClosed)",
            "validationMarkerHeld=\(validationMarker.markerHeld)",
            "exportMarkerWritten=true",
            "exportMarkerHeld=\(exportMarker.markerHeld)",
            "exportMarkerPath=\(Self.lifecycleMarkerRelativePath(for: entry, fileName: Self.exportMarkerFileName))",
            "lifecycleOrderHeld=\(validationMarker.markerHeld && exportMarker.markerHeld)",
            "nextRequiredAction=readiness compare/archive",
            "redactedEvidenceOnly=true",
            "noSecretValue=true",
            "noEndpointPayload=true",
            "noOrderPayload=true",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func archiveOutput() throws -> String {
        let entry = try requiredEntry()
        let exportMarker = try requireValidExportMarker(entry: entry)
        let now = Self.canonicalNow()
        let document = try store.archive(assessmentID: entry.assessmentID, updatedAt: now)
        let archivedEntry = try document.inspect(assessmentID: entry.assessmentID)
        return (baseOutput(action: action, entry: archivedEntry, mutationApplied: true) + [
            "lifecycleIssue=GH-1003",
            "archived=true",
            "registryState=\(archivedEntry.state.rawValue)",
            "registryLifecycle=\(archivedEntry.lifecycle.rawValue)",
            "exportMarkerHeld=\(exportMarker.markerHeld)",
            "lifecycleOrderHeld=\(exportMarker.markerHeld)",
            "nextRequiredAction=none",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func compareOutput() throws -> String {
        let baselineEntry = try requiredEntry()
        guard let comparisonAssessmentID else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.arguments",
                expected: "readiness compare <baselineAssessmentID> <followUpAssessmentID>",
                actual: "readiness compare \(baselineEntry.assessmentID.rawValue)"
            )
        }
        let followUpEntry = try store.inspect(assessmentID: comparisonAssessmentID)
        let baselineExportMarker = try requireExportMarkerPresence(entry: baselineEntry)
        let followUpValidationMarker = try requireValidationMarkerPresence(entry: followUpEntry)
        if try evidenceLevelCompareEligible(
            baselineEntry: baselineEntry,
            followUpEntry: followUpEntry
        ) {
            return try evidenceLevelCompareOutput(
                baselineEntry: baselineEntry,
                followUpEntry: followUpEntry
            )
        }
        let report = try store.compareAssessments(
            baselineSnapshot: try comparisonSnapshot(for: baselineEntry),
            followUpSnapshot: try comparisonSnapshot(for: followUpEntry),
            comparedAt: Self.canonicalNow()
        )
        return (baseOutput(action: action, entry: baselineEntry, mutationApplied: false) + [
            "lifecycleIssue=GH-1003",
            "baselineAssessmentID=\(report.baselineAssessmentID.rawValue)",
            "followUpAssessmentID=\(report.followUpAssessmentID.rawValue)",
            "comparedSections=\(report.comparedSections.map(\.rawValue).joined(separator: ","))",
            "changedSections=\(report.changedSections.map(\.rawValue).joined(separator: ","))",
            "unchangedSections=\(report.unchangedSections.map(\.rawValue).joined(separator: ","))",
            "hasDifferences=\(report.hasDifferences)",
            "reportChecksum=\(report.reportChecksum)",
            "compareDoesNotMutateAssessments=\(report.compareDoesNotMutateAssessments)",
            "operatorReviewOnly=\(report.operatorReviewOnly)",
            "baselineExportMarkerHeld=\(baselineExportMarker.markerHeld)",
            "followUpValidationMarkerHeld=\(followUpValidationMarker.markerHeld)",
            "lifecycleOrderHeld=\(baselineExportMarker.markerHeld && followUpValidationMarker.markerHeld)",
            "nextRequiredAction=readiness archive \(baselineEntry.assessmentID.rawValue)",
            "localRegistryStoreOnly=true",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func evidenceLevelCompareEligible(
        baselineEntry: ReadinessAssessmentRegistryEntry,
        followUpEntry: ReadinessAssessmentRegistryEntry
    ) throws -> Bool {
        try redactedAuditExportPackageEligible(entry: baselineEntry)
            && redactedAuditExportPackageEligible(entry: followUpEntry)
    }

    private func evidenceLevelCompareOutput(
        baselineEntry: ReadinessAssessmentRegistryEntry,
        followUpEntry: ReadinessAssessmentRegistryEntry
    ) throws -> String {
        let report = try ReleaseV0130LocalEvidenceIntakeModel(
            fileManager: store.fileManager
        ).compareEvidenceLevelAssessments(
            baselineAssessmentID: baselineEntry.assessmentID,
            followUpAssessmentID: followUpEntry.assessmentID,
            store: store,
            comparedAt: Self.canonicalNow()
        )
        return (baseOutput(action: action, entry: baselineEntry, mutationApplied: false) + [
            "issue=GH-1000",
            "lifecycleIssue=GH-1003",
            "v013ValidationAnchor=GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF",
            "v013MatrixAnchor=TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF",
            "v013DiffAnchor=V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE",
            "v013SectionsAnchor=V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS",
            "v013BlockerAnchor=V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER",
            "v013ExportValidationAnchor=V0130-007-COMPARISON-EXPORT-VALIDATION",
            "v013NoCutoverAnchor=V0130-007-NO-PRODUCTION-CUTOVER",
            "baselineAssessmentID=\(report.baselineAssessmentID.rawValue)",
            "followUpAssessmentID=\(report.followUpAssessmentID.rawValue)",
            "comparisonFormat=evidence-level-readiness-diff",
            "comparisonState=\(report.comparisonState)",
            "baselineValidationState=\(report.baselineValidationState)",
            "followUpValidationState=\(report.followUpValidationState)",
            "comparedSections=\(report.comparedSections.map(\.rawValue).joined(separator: ","))",
            "changedSections=\(report.changedSections.map(\.rawValue).joined(separator: ","))",
            "unchangedSections=\(report.unchangedSections.map(\.rawValue).joined(separator: ","))",
            "blockedSections=\(report.blockedSections.map(\.rawValue).joined(separator: ","))",
            "blockers=\(report.blockers.isEmpty ? "none" : report.blockers.joined(separator: ","))",
            "hasDifferences=\(report.changedSections.isEmpty == false)",
            "reportChecksum=\(report.reportChecksum)",
            "comparisonMetadataJSONPath=\(followUpEntry.artifactPaths.comparisonMetadataJSONPath)",
            "compareDoesNotMutateAssessments=\(report.comparisonDoesNotMutateAssessments)",
            "operatorReviewOnly=\(report.operatorReviewOnly)",
            "baselineExportMarkerHeld=true",
            "followUpValidationMarkerHeld=true",
            "lifecycleOrderHeld=true",
            "nextRequiredAction=readiness archive \(baselineEntry.assessmentID.rawValue)",
            "localRegistryStoreOnly=\(report.localRegistryStoreOnly)",
            "redactedEvidenceOnly=\(report.redactedEvidenceOnly)",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private func writeValidationMarkerIfValid(
        entry: ReadinessAssessmentRegistryEntry,
        evidenceChainReport: ReleaseV0130LocalEvidenceChainValidationReport,
        validatedAt: Date
    ) throws -> ReadinessLifecycleValidationMarker? {
        guard evidenceChainReport.validationState == "valid",
              evidenceChainReport.evidenceChainCoherent else {
            return nil
        }
        let snapshot = try lifecycleSnapshot(entry: entry)
        let marker = ReadinessLifecycleValidationMarker(
            issueID: "GH-1003",
            assessmentID: entry.assessmentID.rawValue,
            generationID: snapshot.generationID.rawValue,
            validationState: evidenceChainReport.validationState,
            evidenceChainCoherent: evidenceChainReport.evidenceChainCoherent,
            manifestChecksum: snapshot.manifestChecksum,
            readinessBundleChecksum: snapshot.readinessBundleChecksum,
            readinessBundleManifestChecksum: snapshot.readinessBundleManifestChecksum,
            artifactSHA256: snapshot.artifactSHA256,
            artifactBytes: snapshot.artifactBytes,
            sourceRunIDs: snapshot.sourceRunIDs,
            sourceCommit: snapshot.sourceCommit,
            producerVersion: snapshot.producerVersion,
            validatedAtEpochSeconds: Int(validatedAt.timeIntervalSince1970),
            productionTradingEnabledByDefault: false,
            productionSecretRead: false,
            productionEndpointConnected: false,
            brokerEndpointConnected: false,
            productionOrderSubmitted: false,
            productionCutoverAuthorized: false
        )
        guard marker.markerHeld else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness validate \(entry.assessmentID.rawValue)",
                reason: "validationMarkerInvalid",
                attemptedAction: "readiness validate \(entry.assessmentID.rawValue)"
            )
        }
        try writeLifecycleMarker(marker, to: validationMarkerURL(for: entry))
        return marker
    }

    private func requireValidValidationMarker(
        entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessLifecycleValidationMarker {
        let marker = try requireValidationMarkerPresence(entry: entry)
        let snapshot = try lifecycleSnapshot(entry: entry)
        guard marker.matches(snapshot) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness validate \(entry.assessmentID.rawValue)",
                reason: "validationMarkerStale",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        return marker
    }

    private func requireValidationMarkerPresence(
        entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessLifecycleValidationMarker {
        let url = validationMarkerURL(for: entry)
        guard store.fileManager.fileExists(atPath: url.path) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness validate \(entry.assessmentID.rawValue)",
                reason: "validationMarkerMissing",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        let marker = try readLifecycleMarker(ReadinessLifecycleValidationMarker.self, from: url)
        guard marker.markerHeld,
              marker.assessmentID == entry.assessmentID.rawValue else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness validate \(entry.assessmentID.rawValue)",
                reason: "validationMarkerInvalid",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        return marker
    }

    private func writeExportMarker(
        entry: ReadinessAssessmentRegistryEntry,
        validationMarker: ReadinessLifecycleValidationMarker,
        exportFormat: String,
        exportDirectoryPath: String,
        exportedAt: Date
    ) throws -> ReadinessLifecycleExportMarker {
        let snapshot = try lifecycleSnapshot(entry: entry)
        guard validationMarker.markerHeld,
              validationMarker.matches(snapshot) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness validate \(entry.assessmentID.rawValue)",
                reason: "validationMarkerStale",
                attemptedAction: "readiness export \(entry.assessmentID.rawValue)"
            )
        }
        let marker = ReadinessLifecycleExportMarker(
            issueID: "GH-1003",
            assessmentID: entry.assessmentID.rawValue,
            generationID: snapshot.generationID.rawValue,
            exportFormat: exportFormat,
            exportDirectoryPath: exportDirectoryPath,
            validationState: validationMarker.validationState,
            evidenceChainCoherent: validationMarker.evidenceChainCoherent,
            manifestChecksum: snapshot.manifestChecksum,
            readinessBundleChecksum: snapshot.readinessBundleChecksum,
            readinessBundleManifestChecksum: snapshot.readinessBundleManifestChecksum,
            validationMarkerPath: Self.lifecycleMarkerRelativePath(
                for: entry,
                fileName: Self.validationMarkerFileName
            ),
            exportedAtEpochSeconds: Int(exportedAt.timeIntervalSince1970),
            productionTradingEnabledByDefault: false,
            productionSecretRead: false,
            productionEndpointConnected: false,
            brokerEndpointConnected: false,
            productionOrderSubmitted: false,
            productionCutoverAuthorized: false
        )
        guard marker.markerHeld,
              marker.matches(validationMarker: validationMarker, snapshot: snapshot) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness export \(entry.assessmentID.rawValue)",
                reason: "exportMarkerInvalid",
                attemptedAction: "readiness export \(entry.assessmentID.rawValue)"
            )
        }
        try writeLifecycleMarker(marker, to: exportMarkerURL(for: entry))
        return marker
    }

    private func requireValidExportMarker(
        entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessLifecycleExportMarker {
        let marker = try requireExportMarkerPresence(entry: entry)
        let validationMarker = try requireValidValidationMarker(entry: entry)
        let snapshot = try lifecycleSnapshot(entry: entry)
        guard marker.matches(validationMarker: validationMarker, snapshot: snapshot) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness export \(entry.assessmentID.rawValue)",
                reason: "exportMarkerStale",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        return marker
    }

    private func requireExportMarkerPresence(
        entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessLifecycleExportMarker {
        let url = exportMarkerURL(for: entry)
        guard store.fileManager.fileExists(atPath: url.path) else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness export \(entry.assessmentID.rawValue)",
                reason: "exportMarkerMissing",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        let marker = try readLifecycleMarker(ReadinessLifecycleExportMarker.self, from: url)
        guard marker.markerHeld,
              marker.assessmentID == entry.assessmentID.rawValue else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness export \(entry.assessmentID.rawValue)",
                reason: "exportMarkerInvalid",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        return marker
    }

    private func lifecycleSnapshot(
        entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessLifecycleSnapshot {
        let manifest = try requiredManifest(for: entry)
        let bundle = try store.readReadinessBundleV2(
            assessmentID: entry.assessmentID,
            generationID: manifest.generationID
        )
        let bundleManifest = try store.readReadinessBundleV2Manifest(
            assessmentID: entry.assessmentID,
            generationID: manifest.generationID
        )
        let v012LocalEvidenceArtifact = try? localEvidenceArtifactMetadata(
            entry: entry,
            generationID: manifest.generationID,
            artifactID: Self.localEvidenceArtifactID(for: entry)
        )
        let v013ArtifactSnapshotBytes = bundle.artifactSnapshots.compactMap { snapshot -> Data? in
            guard snapshot.snapshotHeld,
                  snapshot.manifestChecksum == manifest.manifestChecksum,
                  ReadinessAssessmentManifestV2.isValidSHA256Checksum(snapshot.artifactSHA256),
                  ReadinessAssessmentManifestV2.isValidSHA256Checksum(snapshot.contentValidationChecksum),
                  snapshot.artifactPath.isEmpty == false else {
                return nil
            }
            let url = Self.storeURL(for: snapshot.artifactPath, store: store, isDirectory: false)
            guard store.fileManager.fileExists(atPath: url.path),
                  let data = try? Data(contentsOf: url),
                  ReleaseV060LocalRunJournalWriter.sha256Hex(data) == snapshot.artifactSHA256,
                  data.isEmpty == false else {
                return nil
            }
            return data
        }
        let v013ArtifactSnapshotsMatchManifest = bundle.artifactSnapshots.isEmpty == false
            && v013ArtifactSnapshotBytes.count == bundle.artifactSnapshots.count
        let v012LocalArtifactMatchesManifest = {
            guard let v012LocalEvidenceArtifact else {
                return false
            }
            return manifest.artifactSHA256 == v012LocalEvidenceArtifact.artifactSHA256
                && manifest.artifactBytes == v012LocalEvidenceArtifact.artifactBytes
                && manifest.sourceRunIDs == [v012LocalEvidenceArtifact.sourceRunID]
        }()
        guard (v012LocalArtifactMatchesManifest || v013ArtifactSnapshotsMatchManifest),
              bundle.bundleChecksum == bundleManifest.bundleChecksum else {
            throw lifecycleOrderError(
                entry: entry,
                expectedAction: "readiness build \(entry.assessmentID.rawValue)",
                reason: "buildEvidenceMismatch",
                attemptedAction: "readiness \(action) \(entry.assessmentID.rawValue)"
            )
        }
        let lifecycleArtifactSHA256 = if let firstSnapshot = bundle.artifactSnapshots.sorted(by: { $0.artifactID.rawValue < $1.artifactID.rawValue }).first,
                                         v013ArtifactSnapshotsMatchManifest {
            firstSnapshot.artifactSHA256
        } else {
            manifest.artifactSHA256
        }
        let lifecycleArtifactBytes = if v013ArtifactSnapshotsMatchManifest {
            v013ArtifactSnapshotBytes.reduce(0) { $0 + $1.count }
        } else {
            manifest.artifactBytes
        }
        return ReadinessLifecycleSnapshot(
            generationID: manifest.generationID,
            manifestChecksum: manifest.manifestChecksum,
            readinessBundleChecksum: bundle.bundleChecksum,
            readinessBundleManifestChecksum: bundleManifest.manifestChecksum,
            artifactSHA256: lifecycleArtifactSHA256,
            artifactBytes: lifecycleArtifactBytes,
            sourceRunIDs: manifest.sourceRunIDs.map(\.rawValue),
            sourceCommit: manifest.sourceCommit,
            producerVersion: manifest.producerVersion
        )
    }

    private static func storeURL(
        for relativePath: String,
        store: ReadinessAssessmentRegistryStore,
        isDirectory: Bool
    ) -> URL {
        let normalizedPath = relativePath.replacingOccurrences(
            of: "\(ReadinessAssessmentRegistryStore.defaultRelativeRoot)/",
            with: ""
        )
        return store.storageRootURL.appendingPathComponent(normalizedPath, isDirectory: isDirectory)
    }

    private func validationMarkerURL(for entry: ReadinessAssessmentRegistryEntry) -> URL {
        lifecycleMarkerURL(for: entry, fileName: Self.validationMarkerFileName)
    }

    private func exportMarkerURL(for entry: ReadinessAssessmentRegistryEntry) -> URL {
        lifecycleMarkerURL(for: entry, fileName: Self.exportMarkerFileName)
    }

    private func lifecycleMarkerURL(
        for entry: ReadinessAssessmentRegistryEntry,
        fileName: String
    ) -> URL {
        store.storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(entry.assessmentID.rawValue, isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)
    }

    private static func lifecycleMarkerRelativePath(
        for entry: ReadinessAssessmentRegistryEntry,
        fileName: String
    ) -> String {
        "\(entry.artifactPaths.assessmentDirectoryPath)/\(fileName)"
    }

    private func writeLifecycleMarker<T: Encodable>(_ marker: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(marker)
        let parentURL = url.deletingLastPathComponent()
        try store.fileManager.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions]
        )
        try data.write(to: url, options: .atomic)
        try store.fileManager.setAttributes(
            [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyFilePermissions],
            ofItemAtPath: url.path
        )
    }

    private func readLifecycleMarker<T: Decodable>(_ markerType: T.Type, from url: URL) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(markerType, from: Data(contentsOf: url))
    }

    private func lifecycleOrderError(
        entry: ReadinessAssessmentRegistryEntry,
        expectedAction: String,
        reason: String,
        attemptedAction: String
    ) -> MTPROCLIParserError {
        MTPROCLIParserError.invalidArguments(
            field: "mtpro.readiness.lifecycle",
            expected: "nextRequiredAction=\(expectedAction); reason=\(reason)",
            actual: attemptedAction
        )
    }

    private func requiredEntry() throws -> ReadinessAssessmentRegistryEntry {
        guard let assessmentID else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.arguments",
                expected: "assessmentID",
                actual: "readiness \(action)"
            )
        }
        return try store.inspect(assessmentID: assessmentID)
    }

    private func writeLocalEvidenceArtifact(
        entry: ReadinessAssessmentRegistryEntry,
        generationID: Identifier,
        sourceCommit: String,
        createdAt: Date
    ) throws -> LocalEvidenceArtifactMetadata {
        let artifactID = Self.localEvidenceArtifactID(for: entry)
        let relativePath = Self.localEvidenceArtifactRelativePath(for: entry)
        let artifactURL = localEvidenceArtifactURL(for: entry)
        let payload: [String: Any] = [
            "assessmentID": entry.assessmentID.rawValue,
            "artifactPath": relativePath,
            "brokerEndpointConnected": false,
            "createdAtEpochSeconds": Int(createdAt.timeIntervalSince1970),
            "evidenceKind": "readiness-local-summary",
            "eventIDs": [Self.localEvidenceEventID(for: entry).rawValue],
            "generationID": generationID.rawValue,
            "localOnly": true,
            "noOrderPayload": true,
            "noSecretValue": true,
            "omsDryRunLifecycleIDs": [Self.localEvidenceOMSDryRunLifecycleID(for: entry).rawValue],
            "portfolioProjectionChecksum": Self.stableChecksum("portfolio-\(entry.assessmentID.rawValue)-\(generationID.rawValue)"),
            "producerVersion": Self.producerVersion,
            "productionCutoverAuthorized": false,
            "productionEndpointConnected": false,
            "productionOrderSubmitted": false,
            "productionSecretRead": false,
            "productionTradingEnabledByDefault": false,
            "redactedEvidenceOnly": true,
            "reconciliationChecksum": Self.stableChecksum("reconciliation-\(entry.assessmentID.rawValue)-\(generationID.rawValue)"),
            "registryEntryChecksum": entry.entryChecksum,
            "riskDecisionIDs": [Self.localEvidenceRiskDecisionID(for: entry).rawValue],
            "sourceCommit": sourceCommit,
            "sourceRunManifestChecksum": Self.stableChecksum("source-run-manifest-\(entry.assessmentID.rawValue)-\(generationID.rawValue)")
        ]
        let data = try Self.canonicalJSONData(payload)
        try writeLocalEvidenceData(data, to: artifactURL)
        return try localEvidenceArtifactMetadata(entry: entry, generationID: generationID, artifactID: artifactID)
    }

    private func localEvidenceArtifactMetadata(
        entry: ReadinessAssessmentRegistryEntry,
        generationID: Identifier,
        artifactID: Identifier
    ) throws -> LocalEvidenceArtifactMetadata {
        let artifactURL = localEvidenceArtifactURL(for: entry)
        guard store.fileManager.fileExists(atPath: artifactURL.path) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("localEvidenceArtifact:missing")
        }
        let data = try Data(contentsOf: artifactURL)
        guard data.isEmpty == false else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("localEvidenceArtifact:empty")
        }
        let artifactSHA256 = ReleaseV060LocalRunJournalWriter.sha256Hex(data)
        let sourceRunID = try Self.sourceRunID(artifactSHA256: artifactSHA256)
        return LocalEvidenceArtifactMetadata(
            artifactID: artifactID,
            generationID: generationID,
            url: artifactURL,
            relativePath: Self.localEvidenceArtifactRelativePath(for: entry),
            data: data,
            artifactSHA256: artifactSHA256,
            artifactBytes: data.count,
            sourceRunID: sourceRunID
        )
    }

    private func localEvidenceArtifactContentPolicy(
        artifactID: Identifier
    ) throws -> ReadinessAssessmentArtifactContentPolicy {
        try ReadinessAssessmentArtifactContentPolicy(
            policyVersion: "v0.12.1.local-evidence-metadata.v1",
            artifactID: artifactID,
            allowedJSONFields: Self.localEvidenceArtifactJSONFields,
            requiredJSONFields: Self.localEvidenceArtifactJSONFields
        )
    }

    private func localEvidenceArtifactURL(for entry: ReadinessAssessmentRegistryEntry) -> URL {
        store.storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(entry.assessmentID.rawValue, isDirectory: true)
            .appendingPathComponent("artifacts", isDirectory: true)
            .appendingPathComponent(Self.localEvidenceArtifactFileName, isDirectory: false)
    }

    private func writeLocalEvidenceData(_ data: Data, to url: URL) throws {
        let parentURL = url.deletingLastPathComponent()
        try store.fileManager.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions]
        )
        try data.write(to: url, options: .atomic)
        try store.fileManager.setAttributes(
            [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyFilePermissions],
            ofItemAtPath: url.path
        )
    }

    private static func localEvidenceArtifactID(for entry: ReadinessAssessmentRegistryEntry) -> Identifier {
        Identifier.constant("\(entry.assessmentID.rawValue)-readiness-summary")
    }

    private static func localEvidenceEventID(for entry: ReadinessAssessmentRegistryEntry) -> Identifier {
        Identifier.constant("\(entry.assessmentID.rawValue)-local-evidence-event")
    }

    private static func localEvidenceRiskDecisionID(for entry: ReadinessAssessmentRegistryEntry) -> Identifier {
        Identifier.constant("\(entry.assessmentID.rawValue)-local-evidence-risk-decision")
    }

    private static func localEvidenceOMSDryRunLifecycleID(for entry: ReadinessAssessmentRegistryEntry) -> Identifier {
        Identifier.constant("\(entry.assessmentID.rawValue)-local-evidence-oms-lifecycle")
    }

    private static func localEvidenceArtifactRelativePath(for entry: ReadinessAssessmentRegistryEntry) -> String {
        "\(entry.artifactPaths.assessmentDirectoryPath)/artifacts/\(localEvidenceArtifactFileName)"
    }

    private static func sourceRunID(artifactSHA256: String) throws -> Identifier {
        guard ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactSHA256) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("localEvidenceArtifact:invalidChecksum")
        }
        let hex = artifactSHA256.dropFirst("sha256:".count)
        return Identifier.constant("source-run-\(String(hex.prefix(16)))")
    }

    private static func canonicalJSONData(_ payload: [String: Any]) throws -> Data {
        guard JSONSerialization.isValidJSONObject(payload) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("localEvidenceArtifact:invalidJSON")
        }
        return try JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func comparisonSnapshot(
        for entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessAssessmentComparisonSnapshot {
        let manifest = try requiredManifest(for: entry)
        let localEvidenceArtifact = try localEvidenceArtifactMetadata(
            entry: entry,
            generationID: manifest.generationID,
            artifactID: Self.localEvidenceArtifactID(for: entry)
        )
        guard manifest.artifactSHA256 == localEvidenceArtifact.artifactSHA256,
              manifest.artifactBytes == localEvidenceArtifact.artifactBytes,
              manifest.sourceRunIDs == [localEvidenceArtifact.sourceRunID] else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessCompare:localEvidenceManifestMismatch")
        }
        let localSourceRunEvidence = try localSourceRunEvidence(from: localEvidenceArtifact)
        let sourceRunSnapshot = try ReleaseV0120ShadowParitySourceRunSnapshot(
            runID: localEvidenceArtifact.sourceRunID,
            sourceRunManifestChecksum: localSourceRunEvidence.sourceRunManifestChecksum,
            eventIDs: try localSourceRunEvidence.eventIDs.map { try Identifier($0) },
            riskDecisionIDs: try localSourceRunEvidence.riskDecisionIDs.map { try Identifier($0) },
            omsDryRunLifecycleIDs: try localSourceRunEvidence.omsDryRunLifecycleIDs.map { try Identifier($0) },
            portfolioProjectionChecksum: localSourceRunEvidence.portfolioProjectionChecksum,
            reconciliationChecksum: localSourceRunEvidence.reconciliationChecksum
        )
        return try ReadinessAssessmentComparisonSnapshot(
            assessmentID: entry.assessmentID,
            generationID: manifest.generationID,
            policyChecksum: Self.stableChecksum("policy-v0.12.0"),
            artifactBundleChecksum: manifest.manifestChecksum,
            riskLimitChecksum: Self.stableChecksum("risk-limits-v0.12.0"),
            killSwitchStateChecksum: Self.stableChecksum("kill-switch-\(entry.assessmentID.rawValue)"),
            approvalStateChecksum: Self.stableChecksum("approval-\(entry.assessmentID.rawValue)"),
            sourceRunSnapshot: sourceRunSnapshot
        )
    }

    private func requiredManifest(
        for entry: ReadinessAssessmentRegistryEntry
    ) throws -> ReadinessAssessmentManifestV2 {
        let manifestURL = store.storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(entry.assessmentID.rawValue, isDirectory: true)
            .appendingPathComponent("manifest-v2.json", isDirectory: false)
        guard store.fileManager.fileExists(atPath: manifestURL.path) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift(
                "readinessCompare:missingManifest:\(entry.assessmentID.rawValue)"
            )
        }
        return try store.readManifestV2(assessmentID: entry.assessmentID)
    }

    private func localSourceRunEvidence(
        from artifact: LocalEvidenceArtifactMetadata
    ) throws -> LocalSourceRunEvidence {
        let evidence: LocalSourceRunEvidence
        do {
            evidence = try JSONDecoder().decode(LocalSourceRunEvidence.self, from: artifact.data)
        } catch {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessCompare:missingSourceRunEvidence")
        }
        guard ReadinessAssessmentManifestV2.isValidSHA256Checksum(evidence.sourceRunManifestChecksum),
              evidence.eventIDs.isEmpty == false,
              evidence.riskDecisionIDs.isEmpty == false,
              evidence.omsDryRunLifecycleIDs.isEmpty == false,
              ReadinessAssessmentManifestV2.isValidSHA256Checksum(evidence.portfolioProjectionChecksum),
              ReadinessAssessmentManifestV2.isValidSHA256Checksum(evidence.reconciliationChecksum) else {
            throw ReadinessAssessmentRegistryStoreError.boundaryDrift("readinessCompare:missingSourceRunEvidence")
        }
        return evidence
    }

    private func baseOutput(
        action: String,
        entry: ReadinessAssessmentRegistryEntry,
        mutationApplied: Bool
    ) -> [String] {
        [
            "mtpro readiness \(action) v0.12.0",
            "issue=GH-963",
            "validationAnchor=\(MTPROStrictCLI.readinessAssessmentCLILifecycleValidationAnchor)",
            "verificationAnchor=\(MTPROStrictCLI.readinessAssessmentCLILifecycleVerificationAnchor)",
            "requiredAnchors=\(MTPROStrictCLI.readinessAssessmentCLILifecycleRequiredAnchors.joined(separator: ","))",
            "v013LifecycleAnchor=GH-1003-VERIFY-V0130-ORDERED-READINESS-CLI-LIFECYCLE",
            "v013LifecycleMatrixAnchor=TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE",
            "v013LifecycleOrderAnchor=V0130-010-CREATE-BUILD-VALIDATE-EXPORT-COMPARE-ARCHIVE",
            "v013LifecycleMarkerAnchor=V0130-010-VALIDATION-EXPORT-MARKERS",
            "v013LifecycleBypassAnchor=V0130-010-BYPASS-MANUAL-FILES-REJECTED",
            "v013LifecycleNoCutoverAnchor=V0130-010-NO-PRODUCTION-CUTOVER",
            "assessmentSessionContract=v0.12.0",
            "assessmentID=\(entry.assessmentID.rawValue)",
            "registryPath=.local/mtpro/readiness/registry.json",
            "storageRoot=\(store.storageRootURL.path)",
            "mutationApplied=\(mutationApplied)",
            "assessmentSessionLocalOnly=\(entry.assessmentSessionLocalOnly)",
            "invalidAssessmentIDsFailClosed=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "testnetOrderRoutingAllowed=false",
            "productionCutoverAuthorized=false"
        ]
    }

    private static func canonicalNow() -> Date {
        Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
    }

    private static func defaultSourceCommit() throws -> String {
        if let override = ProcessInfo.processInfo.environment[sourceCommitEnvironmentKey] {
            return try canonicalSourceCommit(override, provenance: sourceCommitEnvironmentKey)
        }

        return try localGitHeadSourceCommit()
    }

    private static func localGitHeadSourceCommit() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "rev-parse", "--verify", "HEAD"]
        process.currentDirectoryURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )

        let standardOutput = Pipe()
        let standardError = Pipe()
        process.standardOutput = standardOutput
        process.standardError = standardError

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.sourceCommit",
                expected: sourceCommitExpectedDescription,
                actual: "local git HEAD unavailable: \(error)"
            )
        }

        let output = String(
            data: standardOutput.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""
        let errorOutput = String(
            data: standardError.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        guard process.terminationStatus == 0 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.sourceCommit",
                expected: sourceCommitExpectedDescription,
                actual: errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        return try canonicalSourceCommit(output, provenance: "local git HEAD")
    }

    private static func canonicalSourceCommit(_ rawValue: String, provenance: String) throws -> String {
        let sourceCommit = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit) else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.sourceCommit",
                expected: sourceCommitExpectedDescription,
                actual: "\(provenance)=\(sourceCommit.isEmpty ? "empty" : sourceCommit)"
            )
        }
        return sourceCommit
    }

    private static func stableChecksum(_ seed: String) -> String {
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        let chunk = String(format: "%016llx", hash)
        return "sha256:\(String(repeating: chunk, count: 4))"
    }
}
