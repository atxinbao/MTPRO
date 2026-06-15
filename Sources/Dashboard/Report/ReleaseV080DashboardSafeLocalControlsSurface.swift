import Foundation

/// ReleaseV080DashboardSafeLocalControl 固定 GH-818 Dashboard 可展示的本地安全控制。
///
/// 这些控制只绑定 v0.8 local run registry 和 operational run session store 的本地
/// artifact read/write 语义；它们不映射 order command、broker command、signed endpoint、
/// production endpoint 或 production cutover command。
public enum ReleaseV080DashboardSafeLocalControl:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case start = "start"
    case stop = "stop"
    case recover = "recover"
    case archive = "archive"
    case openDetail = "open-detail"
}

/// ReleaseV080DashboardSafeLocalControlResult 是 GH-818 单个 Dashboard 控制的持久化绑定证据。
///
/// Result 只记录 Dashboard control 如何落到 `.local/mtpro/runs/...` 下的 registry /
/// session artifacts。它不持有 runtime object、adapter request、credential value、
/// listenKey value、broker state 或任何订单 payload。
public struct ReleaseV080DashboardSafeLocalControlResult: Codable, Equatable, Sendable {
    public let control: ReleaseV080DashboardSafeLocalControl
    public let runID: String
    public let registryStoreSourceIdentity: String
    public let sessionStoreSourceIdentity: String
    public let registryOperation: String
    public let sessionOperation: String
    public let registryStateBefore: String
    public let registryStateAfter: String
    public let sessionStateBefore: String
    public let sessionStateAfter: String
    public let runDirectoryPath: String
    public let registryJSONPath: String
    public let registryLockPath: String
    public let operatorSessionStoreJSONPath: String
    public let sessionJSONPath: String
    public let sessionEventsJSONLPath: String
    public let sessionStatusJSONPath: String
    public let dashboardDetailSnapshotJSONPath: String
    public let mutationScope: String
    public let localArtifactMutationOnly: Bool
    public let detailOpenReadOnly: Bool
    public let registryWriteRequired: Bool
    public let sessionWriteRequired: Bool
    public let sessionReadRequired: Bool
    public let orderCommandCreated: Bool
    public let productionCommandCreated: Bool
    public let testnetOrderCommandCreated: Bool
    public let brokerCommandCreated: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var resultHeld: Bool {
        runID.isEmpty == false
            && registryStoreSourceIdentity == "ReleaseV080RunRegistryStore.registry-json"
            && sessionStoreSourceIdentity == "ReleaseV080OperationalRunSessionStore.session-json-events-status"
            && runDirectoryPath == ".local/mtpro/runs/\(runID)"
            && registryJSONPath == ".local/mtpro/runs/registry.json"
            && registryLockPath == ".local/mtpro/runs/registry.lock"
            && operatorSessionStoreJSONPath == "\(runDirectoryPath)/operator-session-store.json"
            && sessionJSONPath == "\(runDirectoryPath)/session.json"
            && sessionEventsJSONLPath == "\(runDirectoryPath)/session_events.jsonl"
            && sessionStatusJSONPath == "\(runDirectoryPath)/session_status.json"
            && dashboardDetailSnapshotJSONPath == "\(runDirectoryPath)/dashboard-readonly-snapshot.json"
            && mutationScope == "local-run-artifacts-only"
            && localArtifactMutationOnly
            && Self.allowedTransition(
                control: control,
                registryOperation: registryOperation,
                sessionOperation: sessionOperation,
                registryStateBefore: registryStateBefore,
                registryStateAfter: registryStateAfter,
                sessionStateBefore: sessionStateBefore,
                sessionStateAfter: sessionStateAfter,
                detailOpenReadOnly: detailOpenReadOnly,
                registryWriteRequired: registryWriteRequired,
                sessionWriteRequired: sessionWriteRequired,
                sessionReadRequired: sessionReadRequired
            )
            && orderCommandCreated == false
            && productionCommandCreated == false
            && testnetOrderCommandCreated == false
            && brokerCommandCreated == false
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        control: ReleaseV080DashboardSafeLocalControl,
        runID: String,
        registryOperation: String,
        sessionOperation: String,
        registryStateBefore: String,
        registryStateAfter: String,
        sessionStateBefore: String,
        sessionStateAfter: String,
        detailOpenReadOnly: Bool = false,
        registryWriteRequired: Bool = true,
        sessionWriteRequired: Bool = true,
        sessionReadRequired: Bool = true,
        registryStoreSourceIdentity: String = "ReleaseV080RunRegistryStore.registry-json",
        sessionStoreSourceIdentity: String = "ReleaseV080OperationalRunSessionStore.session-json-events-status",
        mutationScope: String = "local-run-artifacts-only",
        localArtifactMutationOnly: Bool = true,
        orderCommandCreated: Bool = false,
        productionCommandCreated: Bool = false,
        testnetOrderCommandCreated: Bool = false,
        brokerCommandCreated: Bool = false,
        credentialValueVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.control = control
        self.runID = runID
        self.registryStoreSourceIdentity = registryStoreSourceIdentity
        self.sessionStoreSourceIdentity = sessionStoreSourceIdentity
        self.registryOperation = registryOperation
        self.sessionOperation = sessionOperation
        self.registryStateBefore = registryStateBefore
        self.registryStateAfter = registryStateAfter
        self.sessionStateBefore = sessionStateBefore
        self.sessionStateAfter = sessionStateAfter
        self.runDirectoryPath = ".local/mtpro/runs/\(runID)"
        self.registryJSONPath = ".local/mtpro/runs/registry.json"
        self.registryLockPath = ".local/mtpro/runs/registry.lock"
        self.operatorSessionStoreJSONPath = ".local/mtpro/runs/\(runID)/operator-session-store.json"
        self.sessionJSONPath = ".local/mtpro/runs/\(runID)/session.json"
        self.sessionEventsJSONLPath = ".local/mtpro/runs/\(runID)/session_events.jsonl"
        self.sessionStatusJSONPath = ".local/mtpro/runs/\(runID)/session_status.json"
        self.dashboardDetailSnapshotJSONPath = ".local/mtpro/runs/\(runID)/dashboard-readonly-snapshot.json"
        self.mutationScope = mutationScope
        self.localArtifactMutationOnly = localArtifactMutationOnly
        self.detailOpenReadOnly = detailOpenReadOnly
        self.registryWriteRequired = registryWriteRequired
        self.sessionWriteRequired = sessionWriteRequired
        self.sessionReadRequired = sessionReadRequired
        self.orderCommandCreated = orderCommandCreated
        self.productionCommandCreated = productionCommandCreated
        self.testnetOrderCommandCreated = testnetOrderCommandCreated
        self.brokerCommandCreated = brokerCommandCreated
        self.credentialValueVisible = credentialValueVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    private static func allowedTransition(
        control: ReleaseV080DashboardSafeLocalControl,
        registryOperation: String,
        sessionOperation: String,
        registryStateBefore: String,
        registryStateAfter: String,
        sessionStateBefore: String,
        sessionStateAfter: String,
        detailOpenReadOnly: Bool,
        registryWriteRequired: Bool,
        sessionWriteRequired: Bool,
        sessionReadRequired: Bool
    ) -> Bool {
        switch control {
        case .start:
            return registryOperation == "ReleaseV080RunRegistryStore.save"
                && sessionOperation == "ReleaseV080OperationalRunSessionStore.create+apply(start,start)"
                && registryStateBefore == "created"
                && registryStateAfter == "running"
                && sessionStateBefore == "created"
                && sessionStateAfter == "running"
                && detailOpenReadOnly == false
                && registryWriteRequired
                && sessionWriteRequired
                && sessionReadRequired
        case .stop:
            return registryOperation == "ReleaseV080RunRegistryStore.replacing(stopped)"
                && sessionOperation == "ReleaseV080OperationalRunSessionStore.apply(stop,stop)"
                && registryStateBefore == "running"
                && registryStateAfter == "stopped"
                && sessionStateBefore == "running"
                && sessionStateAfter == "stopped"
                && detailOpenReadOnly == false
                && registryWriteRequired
                && sessionWriteRequired
                && sessionReadRequired
        case .recover:
            return registryOperation == "ReleaseV080RunRegistryStore.recover"
                && sessionOperation == "ReleaseV080OperationalRunSessionStore.apply(recover)"
                && registryStateBefore == "failed"
                && registryStateAfter == "recovered"
                && sessionStateBefore == "failed"
                && sessionStateAfter == "recovered"
                && detailOpenReadOnly == false
                && registryWriteRequired
                && sessionWriteRequired
                && sessionReadRequired
        case .archive:
            return registryOperation == "ReleaseV080RunRegistryStore.archive"
                && sessionOperation == "ReleaseV080OperationalRunSessionStore.load+status"
                && registryStateBefore == "stopped"
                && registryStateAfter == "archived"
                && sessionStateBefore == "stopped"
                && sessionStateAfter == "stopped"
                && detailOpenReadOnly == false
                && registryWriteRequired
                && sessionWriteRequired == false
                && sessionReadRequired
        case .openDetail:
            return registryOperation == "ReleaseV080RunRegistryStore.inspect"
                && sessionOperation == "ReleaseV080OperationalRunSessionStore.load+status"
                && registryStateBefore == "running"
                && registryStateAfter == "running"
                && sessionStateBefore == "running"
                && sessionStateAfter == "running"
                && detailOpenReadOnly
                && registryWriteRequired == false
                && sessionWriteRequired == false
                && sessionReadRequired
        }
    }
}

/// ReleaseV080DashboardSafeLocalControlsSurfaceViewModel 是 GH-818 的 Dashboard 安全控制面。
///
/// ViewModel 只把 start / stop / recover / archive / open-detail 绑定到 v0.8 本地
/// registry 和 session store artifacts。Dashboard 可以展示这些本地控制结果，但不能由此
/// 创建订单命令、production command、testnet order route 或 broker side effect。
public struct ReleaseV080DashboardSafeLocalControlsSurfaceViewModel:
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
    public let controlResults: [ReleaseV080DashboardSafeLocalControlResult]
    public let registryAndSessionStoresBound: Bool
    public let localRunArtifactsOnly: Bool
    public let startLocalDryRunVisible: Bool
    public let stopLocalDryRunVisible: Bool
    public let recoverFailedLocalRunVisible: Bool
    public let archiveRunVisible: Bool
    public let openDetailVisible: Bool
    public let persistentRegistryPathVisible: Bool
    public let persistentSessionStorePathsVisible: Bool
    public let detailSurfaceReadOnly: Bool
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

    public var visibleControlCount: Int {
        controlResults.count
    }

    public var controls: [ReleaseV080DashboardSafeLocalControl] {
        controlResults.map(\.control)
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "Safe local control rows", value: "\(visibleControlCount)"),
            DashboardShellMetric(label: "Safe local controls", value: controls.map(\.rawValue).joined(separator: ",")),
            DashboardShellMetric(label: "Store bindings", value: registryAndSessionStoresBound ? "registry+session" : "missing"),
            DashboardShellMetric(label: "Artifact scope", value: localRunArtifactsOnly ? "local-only" : "breached"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Controls: \(controls.map(\.rawValue).joined(separator: ", "))",
            "Registry store: \(controlResults.first?.registryStoreSourceIdentity ?? "n/a")",
            "Session store: \(controlResults.first?.sessionStoreSourceIdentity ?? "n/a")",
            "Registry operations: \(controlResults.map(\.registryOperation).joined(separator: ", "))",
            "Session operations: \(controlResults.map(\.sessionOperation).joined(separator: ", "))",
            "Registry path: \(controlResults.first?.registryJSONPath ?? "n/a")",
            "Session paths: \(controlResults.map(\.sessionJSONPath).joined(separator: ", "))",
            "Session event paths: \(controlResults.map(\.sessionEventsJSONLPath).joined(separator: ", "))",
            "Session status paths: \(controlResults.map(\.sessionStatusJSONPath).joined(separator: ", "))",
            "Detail snapshots: \(controlResults.map(\.dashboardDetailSnapshotJSONPath).joined(separator: ", "))",
            "Local artifact mutation: only",
            "Open detail: read-only",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Production command: none",
            "Submit / cancel / replace: none",
            "Dashboard v0.8 safe controls boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-818",
        upstreamIssueIDs: [String] = ["GH-810", "GH-811", "GH-815"],
        previousIssueID: String = "GH-817",
        downstreamIssueID: String = "GH-819",
        releaseVersion: String = "v0.8.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        controlResults: [ReleaseV080DashboardSafeLocalControlResult] = Self.defaultControlResults,
        registryAndSessionStoresBound: Bool = true,
        localRunArtifactsOnly: Bool = true,
        startLocalDryRunVisible: Bool = true,
        stopLocalDryRunVisible: Bool = true,
        recoverFailedLocalRunVisible: Bool = true,
        archiveRunVisible: Bool = true,
        openDetailVisible: Bool = true,
        persistentRegistryPathVisible: Bool = true,
        persistentSessionStorePathsVisible: Bool = true,
        detailSurfaceReadOnly: Bool = true,
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
        let expectedControls = ReleaseV080DashboardSafeLocalControl.allCases
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.controlResults = controlResults
        self.registryAndSessionStoresBound = registryAndSessionStoresBound
        self.localRunArtifactsOnly = localRunArtifactsOnly
        self.startLocalDryRunVisible = startLocalDryRunVisible
        self.stopLocalDryRunVisible = stopLocalDryRunVisible
        self.recoverFailedLocalRunVisible = recoverFailedLocalRunVisible
        self.archiveRunVisible = archiveRunVisible
        self.openDetailVisible = openDetailVisible
        self.persistentRegistryPathVisible = persistentRegistryPathVisible
        self.persistentSessionStorePathsVisible = persistentSessionStorePathsVisible
        self.detailSurfaceReadOnly = detailSurfaceReadOnly
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
        self.boundaryHeld = issueID == "GH-818"
            && upstreamIssueIDs == ["GH-810", "GH-811", "GH-815"]
            && previousIssueID == "GH-817"
            && downstreamIssueID == "GH-819"
            && releaseVersion == "v0.8.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && controlResults.map(\.control) == expectedControls
            && controlResults.allSatisfy(\.resultHeld)
            && registryAndSessionStoresBound
            && localRunArtifactsOnly
            && startLocalDryRunVisible
            && stopLocalDryRunVisible
            && recoverFailedLocalRunVisible
            && archiveRunVisible
            && openDetailVisible
            && persistentRegistryPathVisible
            && persistentSessionStorePathsVisible
            && detailSurfaceReadOnly
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

    public static var deterministicFixture: ReleaseV080DashboardSafeLocalControlsSurfaceViewModel {
        ReleaseV080DashboardSafeLocalControlsSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS",
        "TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS",
        "V080-012-DASHBOARD-SAFE-LOCAL-CONTROLS",
        "V080-012-START-STOP-RECOVER-ARCHIVE-OPEN-DETAIL",
        "V080-012-RUN-REGISTRY-SESSION-STORE-BINDING",
        "V080-012-LOCAL-ARTIFACT-MUTATION-ONLY",
        "V080-012-DETAIL-READONLY-SNAPSHOT",
        "V080-012-NO-ORDER-PRODUCTION-COMMAND",
        "V080-012-NO-TRADING-BUTTON-ORDER-FORM",
        "V080-012-NO-TESTNET-ORDER-ROUTING",
        "V080-012-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH818DashboardSafeLocalControlsBindSessionStoresWithoutCommands",
        "swift test --filter TargetGraphTests/testGH818DashboardSafeLocalControlsSurfaceIsAnchoredInV080Guards",
        "bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultControlResults = [
        ReleaseV080DashboardSafeLocalControlResult(
            control: .start,
            runID: "gh-818-run-alpha",
            registryOperation: "ReleaseV080RunRegistryStore.save",
            sessionOperation: "ReleaseV080OperationalRunSessionStore.create+apply(start,start)",
            registryStateBefore: "created",
            registryStateAfter: "running",
            sessionStateBefore: "created",
            sessionStateAfter: "running"
        ),
        ReleaseV080DashboardSafeLocalControlResult(
            control: .stop,
            runID: "gh-818-run-alpha",
            registryOperation: "ReleaseV080RunRegistryStore.replacing(stopped)",
            sessionOperation: "ReleaseV080OperationalRunSessionStore.apply(stop,stop)",
            registryStateBefore: "running",
            registryStateAfter: "stopped",
            sessionStateBefore: "running",
            sessionStateAfter: "stopped"
        ),
        ReleaseV080DashboardSafeLocalControlResult(
            control: .recover,
            runID: "gh-818-run-beta",
            registryOperation: "ReleaseV080RunRegistryStore.recover",
            sessionOperation: "ReleaseV080OperationalRunSessionStore.apply(recover)",
            registryStateBefore: "failed",
            registryStateAfter: "recovered",
            sessionStateBefore: "failed",
            sessionStateAfter: "recovered"
        ),
        ReleaseV080DashboardSafeLocalControlResult(
            control: .archive,
            runID: "gh-818-run-alpha",
            registryOperation: "ReleaseV080RunRegistryStore.archive",
            sessionOperation: "ReleaseV080OperationalRunSessionStore.load+status",
            registryStateBefore: "stopped",
            registryStateAfter: "archived",
            sessionStateBefore: "stopped",
            sessionStateAfter: "stopped",
            registryWriteRequired: true,
            sessionWriteRequired: false,
            sessionReadRequired: true
        ),
        ReleaseV080DashboardSafeLocalControlResult(
            control: .openDetail,
            runID: "gh-818-run-alpha",
            registryOperation: "ReleaseV080RunRegistryStore.inspect",
            sessionOperation: "ReleaseV080OperationalRunSessionStore.load+status",
            registryStateBefore: "running",
            registryStateAfter: "running",
            sessionStateBefore: "running",
            sessionStateAfter: "running",
            detailOpenReadOnly: true,
            registryWriteRequired: false,
            sessionWriteRequired: false,
            sessionReadRequired: true
        )
    ]
}
