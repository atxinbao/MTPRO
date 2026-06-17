import Foundation

/// ReleaseV090OperatorUXControl 固定 GH-855 允许展示的 monitor operator 操作。
///
/// 这些操作只表示本地 monitor artifact 的 operator UX；它们不是 broker command、
/// listenKey refresh、testnet order routing、production command 或 production cutover。
public enum ReleaseV090OperatorUXControl:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case start
    case status
    case stop
    case recover
    case export
}

/// ReleaseV090DashboardOperatorUXControlRow 是 Dashboard / CLI 共享的 monitor 操作展示行。
///
/// 每一行只绑定 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/...` 本地 evidence
/// 路径和 read-model 摘要。`start` / `stop` / `recover` 只允许本地 artifact 状态变化；
/// `status` / `export` 只允许读取或汇总本地 evidence，不上传、不通知、不下单。
public struct ReleaseV090DashboardOperatorUXControlRow: Codable, Equatable, Sendable {
    public let control: ReleaseV090OperatorUXControl
    public let cliCommand: String
    public let dashboardSurface: String
    public let monitorStateVisible: Bool
    public let timelineVisible: Bool
    public let alertVisible: Bool
    public let exportStatusVisible: Bool
    public let safeLocalControlVisible: Bool
    public let localArtifactMutationOnly: Bool
    public let readOnlySnapshotOnly: Bool
    public let sourceArtifactPath: String
    public let resultArtifactPath: String
    public let checksumReference: String
    public let rawCredentialVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let brokerCommandCreated: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var rowHeld: Bool {
        ReleaseV090OperatorUXControl.allCases.contains(control)
            && cliCommand == "mtpro monitor \(control.rawValue)"
            && dashboardSurface == "ReleaseV090DashboardOperatorUXSurface"
            && monitorStateVisible
            && timelineVisible
            && alertVisible
            && exportStatusVisible
            && safeLocalControlVisible
            && localArtifactMutationOnly == [.start, .stop, .recover].contains(control)
            && readOnlySnapshotOnly == [.status, .export].contains(control)
            && sourceArtifactPath.hasPrefix(".local/mtpro/runs/<runID>/testnet-readonly-monitor/")
            && resultArtifactPath.hasPrefix(".local/mtpro/runs/<runID>/testnet-readonly-monitor/")
            && checksumReference.hasPrefix("sha256:")
            && rawCredentialVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && brokerCommandCreated == false
            && testnetOrderRoutingAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        control: ReleaseV090OperatorUXControl,
        sourceArtifactPath: String,
        resultArtifactPath: String,
        checksumReference: String,
        monitorStateVisible: Bool = true,
        timelineVisible: Bool = true,
        alertVisible: Bool = true,
        exportStatusVisible: Bool = true,
        safeLocalControlVisible: Bool = true,
        localArtifactMutationOnly: Bool,
        readOnlySnapshotOnly: Bool,
        rawCredentialVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        brokerCommandCreated: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.control = control
        self.cliCommand = "mtpro monitor \(control.rawValue)"
        self.dashboardSurface = "ReleaseV090DashboardOperatorUXSurface"
        self.monitorStateVisible = monitorStateVisible
        self.timelineVisible = timelineVisible
        self.alertVisible = alertVisible
        self.exportStatusVisible = exportStatusVisible
        self.safeLocalControlVisible = safeLocalControlVisible
        self.localArtifactMutationOnly = localArtifactMutationOnly
        self.readOnlySnapshotOnly = readOnlySnapshotOnly
        self.sourceArtifactPath = sourceArtifactPath
        self.resultArtifactPath = resultArtifactPath
        self.checksumReference = checksumReference
        self.rawCredentialVisible = rawCredentialVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.brokerCommandCreated = brokerCommandCreated
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV090DashboardOperatorUXSurfaceViewModel 是 GH-855 Dashboard / CLI monitor UX 汇总。
///
/// 该 surface 只把 GH-849 timeline、GH-850 alert、GH-853 export bundle 和 GH-854 lane split
/// 合成为 operator 可读的 monitor operations。Dashboard 可展示 monitor state、timelines、
/// alerts、export status 和 safe local controls；CLI 可展示 `monitor start/status/stop/recover/export`
/// 五个 deterministic 输出。所有字段保持 no-order、read-only/safe-local，不连接任何 endpoint。
public struct ReleaseV090DashboardOperatorUXSurfaceViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let previousIssueID: String
    public let downstreamIssueID: String
    public let releaseVersion: String
    public let source: ViewModelSourceContract
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let controlRows: [ReleaseV090DashboardOperatorUXControlRow]
    public let dashboardStateSurfaces: [String]
    public let monitorOperationNames: [String]
    public let monitorStateReadModelVisible: Bool
    public let timelineReadModelVisible: Bool
    public let alertReadModelVisible: Bool
    public let exportStatusReadModelVisible: Bool
    public let safeLocalControlsVisible: Bool
    public let cliMonitorCommandsVisible: Bool
    public let manualProofReplayableByCI: Bool
    public let dashboardDependsOnDataClientTarget: Bool
    public let dashboardDependsOnDatabaseRuntime: Bool
    public let cliReadsSecret: Bool
    public let cliOpensNetwork: Bool
    public let rawCredentialVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let brokerCommandCreated: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.9 monitor UX controls", value: "\(controlRows.count)"),
            DashboardShellMetric(label: "CLI monitor commands", value: monitorOperationNames.joined(separator: ",")),
            DashboardShellMetric(label: "Dashboard monitor surfaces", value: dashboardStateSurfaces.joined(separator: ",")),
            DashboardShellMetric(label: "Export status", value: exportStatusReadModelVisible ? "local-export-ready" : "hidden"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Monitor commands: \(monitorOperationNames.joined(separator: ", "))",
            "Dashboard reads: \(dashboardStateSurfaces.joined(separator: ", "))",
            "Control rows: \(controlRows.map(\.cliCommand).joined(separator: ", "))",
            "Source artifacts: \(controlRows.map(\.sourceArtifactPath).joined(separator: ", "))",
            "Result artifacts: \(controlRows.map(\.resultArtifactPath).joined(separator: ", "))",
            "Manual proof replay by CI: none",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Broker command: none",
            "Testnet order routing: none",
            "Production cutover: none",
            "Dashboard v0.9 operator UX boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-855",
        upstreamIssueIDs: [String] = ["GH-849", "GH-853", "GH-854"],
        previousIssueID: String = "GH-854",
        downstreamIssueID: String = "GH-856",
        releaseVersion: String = "v0.9.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        controlRows: [ReleaseV090DashboardOperatorUXControlRow] = Self.defaultControlRows,
        dashboardStateSurfaces: [String] = Self.dashboardStateSurfaces,
        monitorOperationNames: [String] = Self.monitorOperationNames,
        monitorStateReadModelVisible: Bool = true,
        timelineReadModelVisible: Bool = true,
        alertReadModelVisible: Bool = true,
        exportStatusReadModelVisible: Bool = true,
        safeLocalControlsVisible: Bool = true,
        cliMonitorCommandsVisible: Bool = true,
        manualProofReplayableByCI: Bool = false,
        dashboardDependsOnDataClientTarget: Bool = false,
        dashboardDependsOnDatabaseRuntime: Bool = false,
        cliReadsSecret: Bool = false,
        cliOpensNetwork: Bool = false,
        rawCredentialVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        brokerCommandCreated: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.controlRows = controlRows
        self.dashboardStateSurfaces = dashboardStateSurfaces
        self.monitorOperationNames = monitorOperationNames
        self.monitorStateReadModelVisible = monitorStateReadModelVisible
        self.timelineReadModelVisible = timelineReadModelVisible
        self.alertReadModelVisible = alertReadModelVisible
        self.exportStatusReadModelVisible = exportStatusReadModelVisible
        self.safeLocalControlsVisible = safeLocalControlsVisible
        self.cliMonitorCommandsVisible = cliMonitorCommandsVisible
        self.manualProofReplayableByCI = manualProofReplayableByCI
        self.dashboardDependsOnDataClientTarget = dashboardDependsOnDataClientTarget
        self.dashboardDependsOnDatabaseRuntime = dashboardDependsOnDatabaseRuntime
        self.cliReadsSecret = cliReadsSecret
        self.cliOpensNetwork = cliOpensNetwork
        self.rawCredentialVisible = rawCredentialVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.brokerCommandCreated = brokerCommandCreated
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = issueID == "GH-855"
            && upstreamIssueIDs == ["GH-849", "GH-853", "GH-854"]
            && previousIssueID == "GH-854"
            && downstreamIssueID == "GH-856"
            && releaseVersion == "v0.9.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && controlRows.map(\.control) == ReleaseV090OperatorUXControl.allCases
            && controlRows.allSatisfy(\.rowHeld)
            && dashboardStateSurfaces == Self.dashboardStateSurfaces
            && monitorOperationNames == Self.monitorOperationNames
            && monitorStateReadModelVisible
            && timelineReadModelVisible
            && alertReadModelVisible
            && exportStatusReadModelVisible
            && safeLocalControlsVisible
            && cliMonitorCommandsVisible
            && manualProofReplayableByCI == false
            && dashboardDependsOnDataClientTarget == false
            && dashboardDependsOnDatabaseRuntime == false
            && cliReadsSecret == false
            && cliOpensNetwork == false
            && rawCredentialVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && brokerCommandCreated == false
            && testnetOrderRoutingAllowed == false
            && testnetOrderSubmissionAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static var deterministicFixture: ReleaseV090DashboardOperatorUXSurfaceViewModel {
        ReleaseV090DashboardOperatorUXSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX",
        "TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX",
        "V090-013-DASHBOARD-CLI-OPERATOR-UX",
        "V090-013-MONITOR-START-STATUS-STOP-RECOVER-EXPORT",
        "V090-013-DASHBOARD-READ-STATE-TIMELINES-ALERTS-EXPORT",
        "V090-013-SAFE-LOCAL-READONLY-CONTROLS",
        "V090-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V090-013-NO-TESTNET-ORDER-ROUTING",
        "V090-013-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH855DashboardOperatorUXShowsMonitorOperationsWithoutCommands",
        "swift test --filter TargetGraphTests/testGH855DashboardCLIOperatorUXIsAnchoredInV090Guards",
        "bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let dashboardStateSurfaces = [
        "monitor-state",
        "timelines",
        "alerts",
        "export-status",
        "safe-local-controls"
    ]

    public static let monitorOperationNames = [
        "start",
        "status",
        "stop",
        "recover",
        "export"
    ]

    public static let defaultControlRows = [
        ReleaseV090DashboardOperatorUXControlRow(
            control: .start,
            sourceArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_session.json",
            resultArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_status.json",
            checksumReference: "sha256:gh855-monitor-start",
            localArtifactMutationOnly: true,
            readOnlySnapshotOnly: false
        ),
        ReleaseV090DashboardOperatorUXControlRow(
            control: .status,
            sourceArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_status.json",
            resultArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/dashboard-operator-status.json",
            checksumReference: "sha256:gh855-monitor-status",
            localArtifactMutationOnly: false,
            readOnlySnapshotOnly: true
        ),
        ReleaseV090DashboardOperatorUXControlRow(
            control: .stop,
            sourceArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_events.jsonl",
            resultArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_status.json",
            checksumReference: "sha256:gh855-monitor-stop",
            localArtifactMutationOnly: true,
            readOnlySnapshotOnly: false
        ),
        ReleaseV090DashboardOperatorUXControlRow(
            control: .recover,
            sourceArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor-recovery.json",
            resultArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_status.json",
            checksumReference: "sha256:gh855-monitor-recover",
            localArtifactMutationOnly: true,
            readOnlySnapshotOnly: false
        ),
        ReleaseV090DashboardOperatorUXControlRow(
            control: .export,
            sourceArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/run-monitor-export-bundle.json",
            resultArtifactPath: ".local/mtpro/runs/<runID>/testnet-readonly-monitor/export-status.json",
            checksumReference: "sha256:gh855-monitor-export",
            localArtifactMutationOnly: false,
            readOnlySnapshotOnly: true
        )
    ]
}
