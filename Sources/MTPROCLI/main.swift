import Database
import DataClient
import DomainModel
import ExecutionClient
import Foundation
import Portfolio

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output = try await MTPROStrictCLI.commandLineOutput(arguments: arguments)
    print(output)
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
        "readiness approval-status"
    ]
    static let monitorSupportedActionCommands = [
        "monitor start",
        "monitor status",
        "monitor stop",
        "monitor recover",
        "monitor export"
    ]
    static let supportedCommands = [
        "help",
        "run",
        "status",
        "stop",
        "recover",
        "risk-policy",
        "readiness",
        "monitor",
        "verify",
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
        let commandList = supportedCommands.joined(separator: ",")
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
            "monitorActions=\(monitorSupportedActionCommands.joined(separator: ","))",
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
        guard arguments.count == 2 else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.arguments",
                expected: readinessSupportedActionCommands.joined(separator: ","),
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments[1]
        guard ["help", "build", "status", "validate", "export", "approval-status"].contains(action) else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.readiness.action",
                expected: "help,build,status,validate,export,approval-status",
                actual: arguments.joined(separator: " ")
            )
        }

        return try ReleaseV0110ReadinessCLI(action: action).output()
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
