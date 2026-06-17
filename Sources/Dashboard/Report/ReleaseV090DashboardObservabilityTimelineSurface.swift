import Foundation

/// ReleaseV090DashboardObservabilityTimelineKind 固定 GH-849 Dashboard 可展示的 v0.9 timeline 类型。
///
/// 这些类型只映射 GH-845..GH-848 已落仓的本地 monitor/session artifacts；它们不是
/// reconnect、listenKey refresh、broker request、testnet order routing 或 production cutover 命令。
public enum ReleaseV090DashboardObservabilityTimelineKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case accountSnapshot
    case privateStream
    case freshness
    case stale
    case disconnected
    case recovered
}

/// ReleaseV090DashboardObservabilityTimelineEvent 是 GH-849 Dashboard timeline 的只读事件行。
///
/// Event 只保存 artifact 名称、source issue、状态标签和 checksum reference；它不保存 raw
/// credential、raw listenKey、raw private payload、endpoint、broker state 或订单 command payload。
public struct ReleaseV090DashboardObservabilityTimelineEvent: Codable, Equatable, Sendable {
    public let sourceIssueID: String
    public let title: String
    public let sourceArtifact: String
    public let kind: ReleaseV090DashboardObservabilityTimelineKind
    public let monitorState: String
    public let observedAtLabel: String
    public let summary: String
    public let lastObservedEventKind: String
    public let checksumReference: String
    public let redactionHeld: Bool
    public let noOrderHeld: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool

    public var eventHeld: Bool {
        ["GH-845", "GH-846", "GH-847", "GH-848"].contains(sourceIssueID)
            && title.isEmpty == false
            && [
                "monitor_session.json",
                "monitor_events.jsonl",
                "monitor_status.json",
                "account-snapshot-freshness.json",
                "private-stream-heartbeat.json",
                "monitor-recovery.json"
            ].contains(sourceArtifact)
            && monitorState.isEmpty == false
            && observedAtLabel.isEmpty == false
            && summary.isEmpty == false
            && lastObservedEventKind.isEmpty == false
            && checksumReference.hasPrefix("sha256:")
            && redactionHeld
            && noOrderHeld
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
    }

    public init(
        sourceIssueID: String,
        title: String,
        sourceArtifact: String,
        kind: ReleaseV090DashboardObservabilityTimelineKind,
        monitorState: String,
        observedAtLabel: String,
        summary: String,
        lastObservedEventKind: String,
        checksumReference: String,
        redactionHeld: Bool = true,
        noOrderHeld: Bool = true,
        credentialValueVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false
    ) {
        self.sourceIssueID = sourceIssueID
        self.title = title
        self.sourceArtifact = sourceArtifact
        self.kind = kind
        self.monitorState = monitorState
        self.observedAtLabel = observedAtLabel
        self.summary = summary
        self.lastObservedEventKind = lastObservedEventKind
        self.checksumReference = checksumReference
        self.redactionHeld = redactionHeld
        self.noOrderHeld = noOrderHeld
        self.credentialValueVisible = credentialValueVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
    }
}

/// ReleaseV090DashboardObservabilityTimelineSurfaceViewModel 是 GH-849 Dashboard 只读 observability timeline。
///
/// ViewModel 只消费 GH-845 monitor session、GH-846 snapshot freshness、GH-847 private stream
/// heartbeat 和 GH-848 recovery artifacts 的 Dashboard-safe 摘要。它展示 snapshot timeline、
/// private stream timeline、freshness timeline、stale / disconnected / recovered 事件和
/// last observed event kind；不依赖 DataClient / Database runtime，不读取 secret，不连接 endpoint，
/// 不提供 trading button、order form、live command 或 testnet / production submit / cancel / replace。
public struct ReleaseV090DashboardObservabilityTimelineSurfaceViewModel:
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
    public let timelineEvents: [ReleaseV090DashboardObservabilityTimelineEvent]
    public let snapshotTimelineVisible: Bool
    public let privateStreamTimelineVisible: Bool
    public let freshnessTimelineVisible: Bool
    public let staleEventsVisible: Bool
    public let disconnectedEventsVisible: Bool
    public let recoveredEventsVisible: Bool
    public let lastObservedEventKindVisible: Bool
    public let readModelOnly: Bool
    public let monitorSessionArtifactsOnly: Bool
    public let dashboardDependsOnDataClientTarget: Bool
    public let dashboardDependsOnDatabaseRuntime: Bool
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

    public var snapshotTimeline: [ReleaseV090DashboardObservabilityTimelineEvent] {
        timelineEvents.filter { $0.kind == .accountSnapshot }
    }

    public var privateStreamTimeline: [ReleaseV090DashboardObservabilityTimelineEvent] {
        timelineEvents.filter { $0.kind == .privateStream || $0.kind == .disconnected || $0.kind == .recovered }
    }

    public var freshnessTimeline: [ReleaseV090DashboardObservabilityTimelineEvent] {
        timelineEvents.filter { $0.kind == .freshness || $0.kind == .stale }
    }

    public var lastObservedEventKind: String {
        timelineEvents.last?.lastObservedEventKind ?? "none"
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.9 timeline events", value: "\(timelineEvents.count)"),
            DashboardShellMetric(label: "Snapshot timeline", value: "\(snapshotTimeline.count)"),
            DashboardShellMetric(label: "Stream timeline", value: "\(privateStreamTimeline.count)"),
            DashboardShellMetric(label: "Freshness timeline", value: "\(freshnessTimeline.count)"),
            DashboardShellMetric(label: "Last event", value: lastObservedEventKind),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Artifacts: \(timelineEvents.map(\.sourceArtifact).joined(separator: ", "))",
            "Source issues: \(timelineEvents.map(\.sourceIssueID).joined(separator: ", "))",
            "Monitor states: \(timelineEvents.map(\.monitorState).joined(separator: ", "))",
            "Last observed event kind: \(lastObservedEventKind)",
            "Snapshot timeline: \(snapshotTimeline.map(\.title).joined(separator: ", "))",
            "Private stream timeline: \(privateStreamTimeline.map(\.title).joined(separator: ", "))",
            "Freshness timeline: \(freshnessTimeline.map(\.title).joined(separator: ", "))",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production command: none",
            "Dashboard v0.9 observability timeline boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-849",
        upstreamIssueIDs: [String] = ["GH-845", "GH-846", "GH-847", "GH-848"],
        previousIssueID: String = "GH-848",
        downstreamIssueID: String = "GH-850",
        releaseVersion: String = "v0.9.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        timelineEvents: [ReleaseV090DashboardObservabilityTimelineEvent] = Self.defaultTimelineEvents,
        snapshotTimelineVisible: Bool = true,
        privateStreamTimelineVisible: Bool = true,
        freshnessTimelineVisible: Bool = true,
        staleEventsVisible: Bool = true,
        disconnectedEventsVisible: Bool = true,
        recoveredEventsVisible: Bool = true,
        lastObservedEventKindVisible: Bool = true,
        readModelOnly: Bool = true,
        monitorSessionArtifactsOnly: Bool = true,
        dashboardDependsOnDataClientTarget: Bool = false,
        dashboardDependsOnDatabaseRuntime: Bool = false,
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
        let kinds = Set(timelineEvents.map(\.kind))
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.timelineEvents = timelineEvents
        self.snapshotTimelineVisible = snapshotTimelineVisible
        self.privateStreamTimelineVisible = privateStreamTimelineVisible
        self.freshnessTimelineVisible = freshnessTimelineVisible
        self.staleEventsVisible = staleEventsVisible
        self.disconnectedEventsVisible = disconnectedEventsVisible
        self.recoveredEventsVisible = recoveredEventsVisible
        self.lastObservedEventKindVisible = lastObservedEventKindVisible
        self.readModelOnly = readModelOnly
        self.monitorSessionArtifactsOnly = monitorSessionArtifactsOnly
        self.dashboardDependsOnDataClientTarget = dashboardDependsOnDataClientTarget
        self.dashboardDependsOnDatabaseRuntime = dashboardDependsOnDatabaseRuntime
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
        self.boundaryHeld = issueID == "GH-849"
            && upstreamIssueIDs == ["GH-845", "GH-846", "GH-847", "GH-848"]
            && previousIssueID == "GH-848"
            && downstreamIssueID == "GH-850"
            && releaseVersion == "v0.9.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && timelineEvents.count >= 5
            && timelineEvents.allSatisfy(\.eventHeld)
            && kinds.contains(.accountSnapshot)
            && kinds.contains(.privateStream)
            && kinds.contains(.freshness)
            && kinds.contains(.stale)
            && kinds.contains(.disconnected)
            && kinds.contains(.recovered)
            && snapshotTimelineVisible
            && privateStreamTimelineVisible
            && freshnessTimelineVisible
            && staleEventsVisible
            && disconnectedEventsVisible
            && recoveredEventsVisible
            && lastObservedEventKindVisible
            && readModelOnly
            && monitorSessionArtifactsOnly
            && dashboardDependsOnDataClientTarget == false
            && dashboardDependsOnDatabaseRuntime == false
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

    public static var deterministicFixture: ReleaseV090DashboardObservabilityTimelineSurfaceViewModel {
        ReleaseV090DashboardObservabilityTimelineSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE",
        "TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE",
        "V090-007-DASHBOARD-OBSERVABILITY-TIMELINE",
        "V090-007-MONITOR-SESSION-ARTIFACTS-ONLY",
        "V090-007-SNAPSHOT-PRIVATE-STREAM-FRESHNESS-TIMELINES",
        "V090-007-STALE-DISCONNECTED-RECOVERED-EVENTS",
        "V090-007-LAST-OBSERVED-EVENT-KIND",
        "V090-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V090-007-NO-TESTNET-ORDER-ROUTING",
        "V090-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH849DashboardObservabilityTimelineShowsMonitorArtifactsWithoutCommands",
        "swift test --filter TargetGraphTests/testGH849DashboardObservabilityTimelineIsAnchoredInV090Guards",
        "bash checks/verify-v0.9.0-dashboard-observability-timeline.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultTimelineEvents = [
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-845",
            title: "Monitor session created",
            sourceArtifact: "monitor_session.json",
            kind: .freshness,
            monitorState: "created",
            observedAtLabel: "session-created",
            summary: "monitor session artifact anchors runID, state taxonomy and append-only events",
            lastObservedEventKind: "monitorSessionCreated",
            checksumReference: "sha256:gh849-monitor-session"
        ),
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-846",
            title: "Account snapshot freshness",
            sourceArtifact: "account-snapshot-freshness.json",
            kind: .accountSnapshot,
            monitorState: "fresh",
            observedAtLabel: "snapshot-observed",
            summary: "signed account snapshot freshness artifact is visible as redacted read-model evidence",
            lastObservedEventKind: "accountSnapshot",
            checksumReference: "sha256:gh849-account-snapshot"
        ),
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-846",
            title: "Snapshot stale threshold",
            sourceArtifact: "account-snapshot-freshness.json",
            kind: .stale,
            monitorState: "stale",
            observedAtLabel: "snapshot-stale-threshold",
            summary: "snapshot freshness can age into stale state without reconnect or account mutation command",
            lastObservedEventKind: "accountSnapshotStale",
            checksumReference: "sha256:gh849-snapshot-stale"
        ),
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-847",
            title: "Private stream heartbeat",
            sourceArtifact: "private-stream-heartbeat.json",
            kind: .privateStream,
            monitorState: "healthy",
            observedAtLabel: "heartbeat-observed",
            summary: "private stream heartbeat artifact exposes last event age and redacted listenKey reference",
            lastObservedEventKind: "privateStreamHeartbeat",
            checksumReference: "sha256:gh849-private-stream"
        ),
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-847",
            title: "Private stream disconnected",
            sourceArtifact: "private-stream-heartbeat.json",
            kind: .disconnected,
            monitorState: "disconnected",
            observedAtLabel: "stream-disconnected",
            summary: "disconnected state remains observable evidence and does not start automatic reconnect",
            lastObservedEventKind: "privateStreamDisconnected",
            checksumReference: "sha256:gh849-stream-disconnected"
        ),
        ReleaseV090DashboardObservabilityTimelineEvent(
            sourceIssueID: "GH-848",
            title: "Monitor recovered",
            sourceArtifact: "monitor-recovery.json",
            kind: .recovered,
            monitorState: "recovered",
            observedAtLabel: "manual-recovery-observed",
            summary: "local manual recovery preserves event history and rebuilds read-model evidence checksum",
            lastObservedEventKind: "monitorRecovered",
            checksumReference: "sha256:gh849-monitor-recovered"
        )
    ]
}
