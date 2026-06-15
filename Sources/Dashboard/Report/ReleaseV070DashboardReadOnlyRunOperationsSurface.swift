import Foundation

/// ReleaseV070DashboardRunOperationControl 固定 GH-788 Dashboard 可展示的本地 run session 操作。
///
/// 这些值只表示 local dry-run session 的 start / stop / recover 可见性，不映射订单、
/// broker、signed endpoint、production endpoint 或 production cutover command。
public enum ReleaseV070DashboardRunOperationControl:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case start
    case stop
    case recover
}

/// ReleaseV070DashboardRunOperationRecord 是 Dashboard run list / detail 的只读行。
///
/// 每行只记录 registry / journal / projection artifact 的 source identity 和摘要；它不
/// 持有 runtime object、adapter request、credential value、listenKey value 或 broker state。
public struct ReleaseV070DashboardRunOperationRecord: Codable, Equatable, Sendable {
    public let runID: String
    public let state: String
    public let lifecycle: String
    public let artifactDirectoryPath: String
    public let eventsJSONLPath: String
    public let projectionJSONPath: String
    public let statusJSONPath: String
    public let manifestJSONPath: String
    public let failureSummary: String?
    public let replayEvidenceVisible: Bool
    public let projectionEvidenceVisible: Bool
    public let registrySourceIdentity: String
    public let journalSourceIdentity: String

    public var recordHeld: Bool {
        runID.isEmpty == false
            && state.isEmpty == false
            && lifecycle.isEmpty == false
            && artifactDirectoryPath.hasPrefix(".local/mtpro/runs/")
            && eventsJSONLPath.hasSuffix("events.jsonl")
            && projectionJSONPath.hasSuffix("projection.json")
            && statusJSONPath.hasSuffix("_RUN_STATUS.json")
            && manifestJSONPath.hasSuffix("manifest.json")
            && replayEvidenceVisible
            && projectionEvidenceVisible
            && registrySourceIdentity == "ReleaseV070RunRegistry.local-run-registry-metadata"
            && journalSourceIdentity == "ReleaseV070RuntimeEventLogWriter.events.jsonl"
    }

    public init(
        runID: String,
        state: String,
        lifecycle: String,
        failureSummary: String? = nil,
        replayEvidenceVisible: Bool = true,
        projectionEvidenceVisible: Bool = true,
        registrySourceIdentity: String = "ReleaseV070RunRegistry.local-run-registry-metadata",
        journalSourceIdentity: String = "ReleaseV070RuntimeEventLogWriter.events.jsonl"
    ) {
        self.runID = runID
        self.state = state
        self.lifecycle = lifecycle
        self.artifactDirectoryPath = ".local/mtpro/runs/\(runID)"
        self.eventsJSONLPath = ".local/mtpro/runs/\(runID)/events.jsonl"
        self.projectionJSONPath = ".local/mtpro/runs/\(runID)/projection.json"
        self.statusJSONPath = ".local/mtpro/runs/\(runID)/_RUN_STATUS.json"
        self.manifestJSONPath = ".local/mtpro/runs/\(runID)/manifest.json"
        self.failureSummary = failureSummary
        self.replayEvidenceVisible = replayEvidenceVisible
        self.projectionEvidenceVisible = projectionEvidenceVisible
        self.registrySourceIdentity = registrySourceIdentity
        self.journalSourceIdentity = journalSourceIdentity
    }
}

/// ReleaseV070DashboardReadOnlyProbeStatus 是 testnet read-only probe 在 Dashboard 上的状态行。
///
/// 状态行只暴露 redacted reference 和 artifact summary，不暴露 credential value、raw listenKey、
/// raw private payload、broker state 或 execution command path。
public struct ReleaseV070DashboardReadOnlyProbeStatus: Codable, Equatable, Sendable {
    public let probeName: String
    public let issueID: String
    public let artifactSourceIdentity: String
    public let status: String
    public let redactedCredentialReferenceVisible: Bool
    public let redactedListenKeyReferenceVisible: Bool
    public let accountPositionBalanceReadModelVisible: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let executionReportCommandPathVisible: Bool

    public var statusHeld: Bool {
        probeName.isEmpty == false
            && ["GH-786", "GH-787"].contains(issueID)
            && artifactSourceIdentity.isEmpty == false
            && status == "read-only-visible"
            && redactedCredentialReferenceVisible
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && executionReportCommandPathVisible == false
    }

    public init(
        probeName: String,
        issueID: String,
        artifactSourceIdentity: String,
        redactedListenKeyReferenceVisible: Bool,
        accountPositionBalanceReadModelVisible: Bool
    ) {
        self.probeName = probeName
        self.issueID = issueID
        self.artifactSourceIdentity = artifactSourceIdentity
        self.status = "read-only-visible"
        self.redactedCredentialReferenceVisible = true
        self.redactedListenKeyReferenceVisible = redactedListenKeyReferenceVisible
        self.accountPositionBalanceReadModelVisible = accountPositionBalanceReadModelVisible
        self.credentialValueVisible = false
        self.rawListenKeyVisible = false
        self.rawPrivatePayloadVisible = false
        self.executionReportCommandPathVisible = false
    }
}

/// ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel 是 GH-788 的 Dashboard 只读操作面。
///
/// ViewModel 只展示 run registry、local journal、projection 和 testnet read-only probe artifact
/// 的状态；local start / stop / recover 只作为 session-level dry-run controls 可见，不升级为
/// order command、live command、production command 或 production cutover control。
public struct ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let releaseVersion: String
    public let source: ViewModelSourceContract
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let records: [ReleaseV070DashboardRunOperationRecord]
    public let selectedRunID: String
    public let safeLocalRunControls: [ReleaseV070DashboardRunOperationControl]
    public let safeLocalDryRunControlsVisible: Bool
    public let safeLocalDryRunControlsWiredToSessionCommands: Bool
    public let sessionCommandSourceIdentity: String
    public let probeStatuses: [ReleaseV070DashboardReadOnlyProbeStatus]
    public let runListVisible: Bool
    public let runDetailsVisible: Bool
    public let failureEvidenceVisible: Bool
    public let replayEvidenceVisible: Bool
    public let projectionEvidenceVisible: Bool
    public let registryJournalOnly: Bool
    public let readModelOnly: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let productionCommandEnabled: Bool
    public let orderSubmitVisible: Bool
    public let orderCancelVisible: Bool
    public let orderReplaceVisible: Bool
    public let brokerEndpointConnected: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public var visibleRunCount: Int {
        records.count
    }

    public var visibleProbeCount: Int {
        probeStatuses.count
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "Run operations", value: "\(visibleRunCount)"),
            DashboardShellMetric(label: "Safe local controls", value: safeLocalRunControls.map(\.rawValue).joined(separator: ",")),
            DashboardShellMetric(label: "Probe statuses", value: "\(visibleProbeCount)"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Run IDs: \(records.map(\.runID).joined(separator: ", "))",
            "Run states: \(records.map(\.state).joined(separator: ", "))",
            "Run lifecycles: \(records.map(\.lifecycle).joined(separator: ", "))",
            "Failure evidence: \(records.compactMap(\.failureSummary).joined(separator: ", "))",
            "Registry source: \(records.first?.registrySourceIdentity ?? "n/a")",
            "Journal source: \(records.first?.journalSourceIdentity ?? "n/a")",
            "Artifact paths: \(records.flatMap { [$0.eventsJSONLPath, $0.projectionJSONPath, $0.statusJSONPath, $0.manifestJSONPath] }.joined(separator: ", "))",
            "Safe local controls: \(safeLocalRunControls.map(\.rawValue).joined(separator: ", "))",
            "Session command source: \(sessionCommandSourceIdentity)",
            "Probe statuses: \(probeStatuses.map { "\($0.issueID):\($0.probeName)=\($0.status)" }.joined(separator: ", "))",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Production command: none",
            "Submit / cancel / replace: none",
            "Dashboard run operations boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-788",
        upstreamIssueIDs: [String] = ["GH-783", "GH-785", "GH-786", "GH-787"],
        releaseVersion: String = "v0.7.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        records: [ReleaseV070DashboardRunOperationRecord] = Self.defaultRecords,
        selectedRunID: String = "gh-785-run-alpha",
        safeLocalRunControls: [ReleaseV070DashboardRunOperationControl] = ReleaseV070DashboardRunOperationControl.allCases,
        safeLocalDryRunControlsVisible: Bool = true,
        safeLocalDryRunControlsWiredToSessionCommands: Bool = true,
        sessionCommandSourceIdentity: String = "ReleaseV070OperationalRunSessionCommand.safe-local",
        probeStatuses: [ReleaseV070DashboardReadOnlyProbeStatus] = Self.defaultProbeStatuses,
        runListVisible: Bool = true,
        runDetailsVisible: Bool = true,
        failureEvidenceVisible: Bool = true,
        replayEvidenceVisible: Bool = true,
        projectionEvidenceVisible: Bool = true,
        registryJournalOnly: Bool = true,
        readModelOnly: Bool = true,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCommandEnabled: Bool = false,
        orderSubmitVisible: Bool = false,
        orderCancelVisible: Bool = false,
        orderReplaceVisible: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.records = records
        self.selectedRunID = selectedRunID
        self.safeLocalRunControls = safeLocalRunControls
        self.safeLocalDryRunControlsVisible = safeLocalDryRunControlsVisible
        self.safeLocalDryRunControlsWiredToSessionCommands = safeLocalDryRunControlsWiredToSessionCommands
        self.sessionCommandSourceIdentity = sessionCommandSourceIdentity
        self.probeStatuses = probeStatuses
        self.runListVisible = runListVisible
        self.runDetailsVisible = runDetailsVisible
        self.failureEvidenceVisible = failureEvidenceVisible
        self.replayEvidenceVisible = replayEvidenceVisible
        self.projectionEvidenceVisible = projectionEvidenceVisible
        self.registryJournalOnly = registryJournalOnly
        self.readModelOnly = readModelOnly
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCommandEnabled = productionCommandEnabled
        self.orderSubmitVisible = orderSubmitVisible
        self.orderCancelVisible = orderCancelVisible
        self.orderReplaceVisible = orderReplaceVisible
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = issueID == "GH-788"
            && upstreamIssueIDs == ["GH-783", "GH-785", "GH-786", "GH-787"]
            && releaseVersion == "v0.7.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && records.isEmpty == false
            && records.allSatisfy(\.recordHeld)
            && records.contains { $0.runID == selectedRunID }
            && safeLocalRunControls == ReleaseV070DashboardRunOperationControl.allCases
            && safeLocalDryRunControlsVisible
            && safeLocalDryRunControlsWiredToSessionCommands
            && sessionCommandSourceIdentity == "ReleaseV070OperationalRunSessionCommand.safe-local"
            && probeStatuses.map(\.issueID) == ["GH-786", "GH-787"]
            && probeStatuses.allSatisfy(\.statusHeld)
            && runListVisible
            && runDetailsVisible
            && failureEvidenceVisible
            && replayEvidenceVisible
            && projectionEvidenceVisible
            && registryJournalOnly
            && readModelOnly
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && productionCommandEnabled == false
            && orderSubmitVisible == false
            && orderCancelVisible == false
            && orderReplaceVisible == false
            && brokerEndpointConnected == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
    }

    public static var deterministicFixture: ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel {
        ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS",
        "TVM-RELEASE-V070-DASHBOARD-READONLY-RUN-OPERATIONS",
        "V070-010-DASHBOARD-RUN-LIST-DETAILS-STATE-EVIDENCE",
        "V070-010-LOCAL-DRY-RUN-START-STOP-RECOVER-SAFE-COMMANDS",
        "V070-010-TESTNET-READONLY-PROBE-STATUS-VISIBILITY",
        "V070-010-REGISTRY-JOURNAL-READMODEL-ONLY",
        "V070-010-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V070-010-NO-ORDER-NO-PRODUCTION-BOUNDARY"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH788DashboardReadOnlyRunOperationsSurfaceShowsRegistryJournalAndProbeStatusWithoutCommands",
        "swift test --filter TargetGraphTests/testGH788DashboardReadOnlyRunOperationsSurfaceIsAnchoredInV070Guards",
        "bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRecords = [
        ReleaseV070DashboardRunOperationRecord(
            runID: "gh-785-run-alpha",
            state: "running",
            lifecycle: "active"
        ),
        ReleaseV070DashboardRunOperationRecord(
            runID: "gh-785-run-beta",
            state: "recovered",
            lifecycle: "recoveryEvidence",
            failureSummary: "partial-line-recovery-evidence"
        )
    ]

    public static let defaultProbeStatuses = [
        ReleaseV070DashboardReadOnlyProbeStatus(
            probeName: "signed-account-read-only",
            issueID: "GH-786",
            artifactSourceIdentity: "ReleaseV070TestnetSignedAccountReadOnlyProbeArtifact",
            redactedListenKeyReferenceVisible: false,
            accountPositionBalanceReadModelVisible: true
        ),
        ReleaseV070DashboardReadOnlyProbeStatus(
            probeName: "private-stream-read-only",
            issueID: "GH-787",
            artifactSourceIdentity: "ReleaseV070TestnetPrivateStreamReadOnlyProbeArtifact",
            redactedListenKeyReferenceVisible: true,
            accountPositionBalanceReadModelVisible: true
        )
    ]
}
