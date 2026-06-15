import Foundation

/// ReleaseV080DashboardTestnetReadOnlyMonitorState 固定 GH-815 Dashboard 可展示的监控状态。
///
/// 这些状态只描述 GH-813 / GH-814 已落仓 proof artifact 的只读 freshness / lifecycle 摘要；
/// 它们不是 reconnect、open stream、refresh listenKey、submit / cancel / replace 或 production cutover 命令。
public enum ReleaseV080DashboardTestnetReadOnlyMonitorState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case fresh
    case stale
    case disconnected
    case recovered
}

/// ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow 是 GH-815 Dashboard 监控区的一行。
///
/// Row 只保存 proof artifact 的 redacted source identity、freshness、listenKey lifecycle 和
/// account / balance / position read-model 摘要；它不保存 credential value、raw listenKey、
/// raw private payload、runtime object、adapter request、broker state 或订单命令。
public struct ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow: Codable, Equatable, Sendable {
    public let issueID: String
    public let title: String
    public let artifactSourceIdentity: String
    public let freshnessLabel: String
    public let monitorState: ReleaseV080DashboardTestnetReadOnlyMonitorState
    public let summary: String
    public let accountSnapshotFreshness: String
    public let privateStreamFreshness: String
    public let listenKeyLifecycle: [String]
    public let lastObservedEventKind: String
    public let redactedCredentialReferenceVisible: Bool
    public let redactedListenKeyReferenceVisible: Bool
    public let credentialRedactionStatus: String
    public let accountSnapshotReadModelVisible: Bool
    public let balanceReadModelVisible: Bool
    public let positionReadModelVisible: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool

    public var statusHeld: Bool {
        ["GH-813", "GH-814"].contains(issueID)
            && title.isEmpty == false
            && artifactSourceIdentity.hasPrefix("ReleaseV080ManualBinanceTestnet")
            && freshnessLabel.isEmpty == false
            && summary.isEmpty == false
            && accountSnapshotFreshness.isEmpty == false
            && privateStreamFreshness.isEmpty == false
            && credentialRedactionStatus == "redacted"
            && redactedCredentialReferenceVisible
            && accountSnapshotReadModelVisible
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
    }

    public init(
        issueID: String,
        title: String,
        artifactSourceIdentity: String,
        freshnessLabel: String,
        monitorState: ReleaseV080DashboardTestnetReadOnlyMonitorState,
        summary: String,
        accountSnapshotFreshness: String,
        privateStreamFreshness: String,
        listenKeyLifecycle: [String],
        lastObservedEventKind: String,
        redactedListenKeyReferenceVisible: Bool,
        accountSnapshotReadModelVisible: Bool,
        balanceReadModelVisible: Bool,
        positionReadModelVisible: Bool
    ) {
        self.issueID = issueID
        self.title = title
        self.artifactSourceIdentity = artifactSourceIdentity
        self.freshnessLabel = freshnessLabel
        self.monitorState = monitorState
        self.summary = summary
        self.accountSnapshotFreshness = accountSnapshotFreshness
        self.privateStreamFreshness = privateStreamFreshness
        self.listenKeyLifecycle = listenKeyLifecycle
        self.lastObservedEventKind = lastObservedEventKind
        self.redactedCredentialReferenceVisible = true
        self.redactedListenKeyReferenceVisible = redactedListenKeyReferenceVisible
        self.credentialRedactionStatus = "redacted"
        self.accountSnapshotReadModelVisible = accountSnapshotReadModelVisible
        self.balanceReadModelVisible = balanceReadModelVisible
        self.positionReadModelVisible = positionReadModelVisible
        self.credentialValueVisible = false
        self.rawListenKeyVisible = false
        self.rawPrivatePayloadVisible = false
        self.tradingButtonVisible = false
        self.orderFormVisible = false
        self.liveCommandVisible = false
    }
}

/// ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel 是 GH-815 Dashboard 只读监控面。
///
/// ViewModel 只消费 GH-813 / GH-814 proof artifact 的 Dashboard-safe 摘要字段，展示 account
/// snapshot freshness、private stream freshness、listenKey open / observe / close lifecycle、
/// last observed event、stale / disconnected / recovered 状态和 redaction status。它不依赖
/// DataClient target，不读取 secret，不连接 endpoint，不保存 raw payload，也不提供 trading control。
public struct ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel:
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
    public let statusRows: [ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow]
    public let staleStatesVisible: Bool
    public let disconnectedStatesVisible: Bool
    public let recoveredStatesVisible: Bool
    public let credentialRedactionStatusVisible: Bool
    public let listenKeyLifecycleVisible: Bool
    public let lastObservedEventVisible: Bool
    public let accountBalancePositionReadModelVisible: Bool
    public let readModelOnly: Bool
    public let dashboardDependsOnDataClientTarget: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let productionCommandEnabled: Bool
    public let orderSubmitVisible: Bool
    public let orderCancelVisible: Bool
    public let orderReplaceVisible: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public var visibleStatusCount: Int {
        statusRows.count
    }

    public var monitorStates: [ReleaseV080DashboardTestnetReadOnlyMonitorState] {
        statusRows.map(\.monitorState)
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "Testnet monitor rows", value: "\(visibleStatusCount)"),
            DashboardShellMetric(
                label: "Account freshness",
                value: statusRows.map(\.accountSnapshotFreshness).joined(separator: ",")
            ),
            DashboardShellMetric(
                label: "Stream freshness",
                value: statusRows.map(\.privateStreamFreshness).joined(separator: ",")
            ),
            DashboardShellMetric(
                label: "Monitor states",
                value: monitorStates.map(\.rawValue).joined(separator: ",")
            ),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Proof rows: \(statusRows.map { "\($0.issueID):\($0.title)" }.joined(separator: ", "))",
            "Artifact sources: \(statusRows.map(\.artifactSourceIdentity).joined(separator: ", "))",
            "Account snapshot freshness: \(statusRows.map(\.accountSnapshotFreshness).joined(separator: ", "))",
            "Private stream freshness: \(statusRows.map(\.privateStreamFreshness).joined(separator: ", "))",
            "ListenKey lifecycle: \(statusRows.flatMap(\.listenKeyLifecycle).joined(separator: ", "))",
            "Last observed event: \(statusRows.map(\.lastObservedEventKind).joined(separator: ", "))",
            "Monitor states: \(monitorStates.map(\.rawValue).joined(separator: ", "))",
            "Credential redaction: \(statusRows.map(\.credentialRedactionStatus).joined(separator: ", "))",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production command: none",
            "Dashboard v0.8 monitor boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-815",
        upstreamIssueIDs: [String] = ["GH-813", "GH-814"],
        previousIssueID: String = "GH-814",
        downstreamIssueID: String = "GH-816",
        releaseVersion: String = "v0.8.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        statusRows: [ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow] = Self.defaultStatusRows,
        staleStatesVisible: Bool = true,
        disconnectedStatesVisible: Bool = true,
        recoveredStatesVisible: Bool = true,
        credentialRedactionStatusVisible: Bool = true,
        listenKeyLifecycleVisible: Bool = true,
        lastObservedEventVisible: Bool = true,
        accountBalancePositionReadModelVisible: Bool = true,
        readModelOnly: Bool = true,
        dashboardDependsOnDataClientTarget: Bool = false,
        credentialValueVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCommandEnabled: Bool = false,
        orderSubmitVisible: Bool = false,
        orderCancelVisible: Bool = false,
        orderReplaceVisible: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        let rowStates = statusRows.map(\.monitorState)
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.statusRows = statusRows
        self.staleStatesVisible = staleStatesVisible
        self.disconnectedStatesVisible = disconnectedStatesVisible
        self.recoveredStatesVisible = recoveredStatesVisible
        self.credentialRedactionStatusVisible = credentialRedactionStatusVisible
        self.listenKeyLifecycleVisible = listenKeyLifecycleVisible
        self.lastObservedEventVisible = lastObservedEventVisible
        self.accountBalancePositionReadModelVisible = accountBalancePositionReadModelVisible
        self.readModelOnly = readModelOnly
        self.dashboardDependsOnDataClientTarget = dashboardDependsOnDataClientTarget
        self.credentialValueVisible = credentialValueVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCommandEnabled = productionCommandEnabled
        self.orderSubmitVisible = orderSubmitVisible
        self.orderCancelVisible = orderCancelVisible
        self.orderReplaceVisible = orderReplaceVisible
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = issueID == "GH-815"
            && upstreamIssueIDs == ["GH-813", "GH-814"]
            && previousIssueID == "GH-814"
            && downstreamIssueID == "GH-816"
            && releaseVersion == "v0.8.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && Set(statusRows.map(\.issueID)) == Set(["GH-813", "GH-814"])
            && statusRows.allSatisfy(\.statusHeld)
            && rowStates.contains(.stale)
            && rowStates.contains(.disconnected)
            && rowStates.contains(.recovered)
            && staleStatesVisible
            && disconnectedStatesVisible
            && recoveredStatesVisible
            && credentialRedactionStatusVisible
            && listenKeyLifecycleVisible
            && lastObservedEventVisible
            && accountBalancePositionReadModelVisible
            && readModelOnly
            && dashboardDependsOnDataClientTarget == false
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && productionCommandEnabled == false
            && orderSubmitVisible == false
            && orderCancelVisible == false
            && orderReplaceVisible == false
            && testnetOrderRoutingAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static var deterministicFixture: ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel {
        ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR",
        "TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR",
        "V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE",
        "V080-009-ACCOUNT-SNAPSHOT-FRESHNESS",
        "V080-009-PRIVATE-STREAM-FRESHNESS",
        "V080-009-LISTENKEY-LIFECYCLE-VISIBLE",
        "V080-009-STALE-DISCONNECTED-RECOVERED-STATES",
        "V080-009-CREDENTIAL-LISTENKEY-REDACTION-STATUS",
        "V080-009-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V080-009-NO-TESTNET-ORDER-ROUTING",
        "V080-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH815DashboardTestnetReadOnlyMonitorSurfaceShowsFreshnessLifecycleAndRedactionWithoutCommands",
        "swift test --filter TargetGraphTests/testGH815DashboardTestnetReadOnlyMonitorSurfaceIsAnchoredInV080Guards",
        "bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultStatusRows = [
        ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow(
            issueID: "GH-813",
            title: "Signed account read-only proof",
            artifactSourceIdentity: "ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact",
            freshnessLabel: "account-snapshot:fresh",
            monitorState: .stale,
            summary: "signed account snapshot proof available; stale state visible when operator proof ages",
            accountSnapshotFreshness: "fresh",
            privateStreamFreshness: "not-applicable",
            listenKeyLifecycle: [],
            lastObservedEventKind: "accountSnapshot",
            redactedListenKeyReferenceVisible: false,
            accountSnapshotReadModelVisible: true,
            balanceReadModelVisible: true,
            positionReadModelVisible: true
        ),
        ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow(
            issueID: "GH-814",
            title: "Private stream read-only monitoring proof",
            artifactSourceIdentity: "ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact",
            freshnessLabel: "private-stream:recovered",
            monitorState: .disconnected,
            summary: "private stream monitoring proof shows open / observe / close lifecycle and recovered display state",
            accountSnapshotFreshness: "fresh",
            privateStreamFreshness: "recovered",
            listenKeyLifecycle: ["open", "observe", "close"],
            lastObservedEventKind: "positionUpdate",
            redactedListenKeyReferenceVisible: true,
            accountSnapshotReadModelVisible: true,
            balanceReadModelVisible: true,
            positionReadModelVisible: true
        ),
        ReleaseV080DashboardTestnetReadOnlyMonitorStatusRow(
            issueID: "GH-814",
            title: "Private stream recovered read-only state",
            artifactSourceIdentity: "ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact",
            freshnessLabel: "private-stream:recovered",
            monitorState: .recovered,
            summary: "operator-confirmed read-only monitoring recovered after disconnected state without command surface",
            accountSnapshotFreshness: "fresh",
            privateStreamFreshness: "recovered",
            listenKeyLifecycle: ["open", "observe", "close"],
            lastObservedEventKind: "balanceUpdate",
            redactedListenKeyReferenceVisible: true,
            accountSnapshotReadModelVisible: true,
            balanceReadModelVisible: true,
            positionReadModelVisible: true
        )
    ]
}
