import DomainModel
import Foundation

// GH-1248 static contract boundary:
// cliCommand=production-shadow-readiness
// dashboardReadinessSurfaceRows=environment-profile,endpoint-allowlist,credential-reference,public-market-probe,signed-account-readiness,account-snapshot-redaction,no-order-capability,risk-kill-switch-no-trade
// dashboardReadinessStates=ready,blocked,fail-closed
// dashboardReadinessReadOnly=true
// cliReadinessReadOnly=true
// tradingButtonVisible=false
// orderFormVisible=false
// liveCommandVisible=false
// submitCancelReplaceEnabled=false
// productionTradingEnabledByDefault=false
// productionSecretValueRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionCutoverAuthorized=false
// GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER
// V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES
// V0200-010-DASHBOARD-CLI-NO-CONTROLS
// V0200-010-NO-PRODUCTION-CUTOVER

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceArea 固定 GH-1248 需要展示的 readiness 区域。
///
/// 这些区域只把 #1240 到 #1247 的 evidence 投影成 operator 可读状态。它们不是 runtime
/// component，不会连接 endpoint，不会读取 secret，也不会创建任何交易命令。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceArea:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case environmentProfile = "environment-profile"
    case endpointAllowlist = "endpoint-allowlist"
    case credentialReference = "credential-reference"
    case publicMarketProbe = "public-market-probe"
    case signedAccountReadiness = "signed-account-readiness"
    case accountSnapshotRedaction = "account-snapshot-redaction"
    case noOrderCapability = "no-order-capability"
    case riskKillSwitchNoTrade = "risk-kill-switch-no-trade"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceState 是 Dashboard / CLI 可以显示的只读 gate 状态。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case ready
    case blocked
    case failClosed = "fail-closed"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceEndpointClass 表达只读 surface 可见的 endpoint 类别。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceEndpointClass:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case publicReadOnly = "public-read-only"
    case signedReadOnlyIntent = "signed-read-only-intent"
    case noEndpointConnection = "no-endpoint-connection"
    case notApplicable = "not-applicable"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceCredentialState 表达 credential reference 的只读状态。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceCredentialState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case noCredentialRequired = "no-credential-required"
    case identityReferenceOnly = "identity-reference-only"
    case redactedReferenceOnly = "redacted-reference-only"
    case notApplicable = "not-applicable"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceRedactionState 表达 artifact / payload redaction 状态。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceRedactionState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case redacted = "redacted"
    case noRawPayload = "no-raw-payload"
    case notApplicable = "not-applicable"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceNoOrderStatus 表达 submit / cancel / replace 状态。
public enum ReleaseV0200ReadOnlyLiveReadinessSurfaceNoOrderStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case blocked
    case notApplicable = "not-applicable"
}

/// ReleaseV0200ReadOnlyLiveReadinessSurfaceRow 是 GH-1248 Dashboard / CLI 共用的只读状态行。
///
/// Row 只保留 issue、gate state、endpoint class、credential reference、redaction 和 no-order
/// status。它不会保存 API key、secret、account payload、endpoint response、order payload 或
/// broker state。
public struct ReleaseV0200ReadOnlyLiveReadinessSurfaceRow: Codable, Equatable, Sendable {
    public let area: ReleaseV0200ReadOnlyLiveReadinessSurfaceArea
    public let sourceIssueID: String
    public let state: ReleaseV0200ReadOnlyLiveReadinessSurfaceState
    public let endpointClass: ReleaseV0200ReadOnlyLiveReadinessSurfaceEndpointClass
    public let credentialState: ReleaseV0200ReadOnlyLiveReadinessSurfaceCredentialState
    public let redactionState: ReleaseV0200ReadOnlyLiveReadinessSurfaceRedactionState
    public let noOrderStatus: ReleaseV0200ReadOnlyLiveReadinessSurfaceNoOrderStatus
    public let statusSummary: String
    public let visibleInDashboard: Bool
    public let visibleInCLI: Bool
    public let readOnly: Bool
    public let commandSurfaceEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sourceIssueID.hasPrefix("GH-")
            && Self.expectedState(for: area) == state
            && statusSummary.isEmpty == false
            && visibleInDashboard
            && visibleInCLI
            && readOnly
            && commandSurfaceEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        area: ReleaseV0200ReadOnlyLiveReadinessSurfaceArea,
        sourceIssueID: String,
        state: ReleaseV0200ReadOnlyLiveReadinessSurfaceState,
        endpointClass: ReleaseV0200ReadOnlyLiveReadinessSurfaceEndpointClass,
        credentialState: ReleaseV0200ReadOnlyLiveReadinessSurfaceCredentialState,
        redactionState: ReleaseV0200ReadOnlyLiveReadinessSurfaceRedactionState,
        noOrderStatus: ReleaseV0200ReadOnlyLiveReadinessSurfaceNoOrderStatus,
        statusSummary: String,
        visibleInDashboard: Bool = true,
        visibleInCLI: Bool = true,
        readOnly: Bool = true,
        commandSurfaceEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) throws {
        self.area = area
        self.sourceIssueID = sourceIssueID
        self.state = state
        self.endpointClass = endpointClass
        self.credentialState = credentialState
        self.redactionState = redactionState
        self.noOrderStatus = noOrderStatus
        self.statusSummary = statusSummary
        self.visibleInDashboard = visibleInDashboard
        self.visibleInCLI = visibleInCLI
        self.readOnly = readOnly
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        try Self.validate(self)
    }

    public static func expectedState(
        for area: ReleaseV0200ReadOnlyLiveReadinessSurfaceArea
    ) -> ReleaseV0200ReadOnlyLiveReadinessSurfaceState {
        switch area {
        case .environmentProfile, .endpointAllowlist, .credentialReference, .publicMarketProbe,
             .accountSnapshotRedaction:
            .ready
        case .signedAccountReadiness:
            .blocked
        case .noOrderCapability, .riskKillSwitchNoTrade:
            .failClosed
        }
    }

    private static func validate(_ row: ReleaseV0200ReadOnlyLiveReadinessSurfaceRow) throws {
        guard row.rowHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.readOnlyLiveReadinessSurface.row.\(row.area.rawValue)",
                expected: "read-only visible row with expected gate state",
                actual: row.statusSummary
            )
        }
    }
}

/// ReleaseV0200ReadOnlyLiveReadinessSurface 是 GH-1248 的共享 Dashboard / CLI projection。
///
/// Surface 汇总 #1240-#1247 的确定性 evidence，只展示 state，不开放 control。CLI 和
/// Dashboard 只能消费这些 row；任何生产交易、secret、endpoint connection、submit /
/// cancel / replace 或 cutover flag 都必须保持 false。
public struct ReleaseV0200ReadOnlyLiveReadinessSurface: Codable, Equatable, Sendable {
    public static let cliCommand = "production-shadow-readiness"

    public let surfaceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let environmentProfile: ReleaseV0200ProductionShadowEnvironmentProfile
    public let endpointAllowlist: ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist
    public let credentialReferenceReadiness: ReleaseV0200ProductionShadowCredentialReferenceReadiness
    public let publicMarketProbe: ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe
    public let signedAccountReadiness: ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness
    public let accountSnapshotRedactionPolicy: ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy
    public let noOrderCapabilityGuard: ReleaseV0200ProductionShadowNoOrderCapabilityGuard
    public let riskKillSwitchNoTradeReadiness: ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness
    public let upstreamEvidenceHeldSnapshot: Bool
    public let rows: [ReleaseV0200ReadOnlyLiveReadinessSurfaceRow]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionDefaultsClosedSnapshot: Bool
    public let surfaceHeldSnapshot: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let signedOrderMaterialGenerated: Bool
    public let accountEndpointConnected: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceEnabled: Bool
    public let dashboardTradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var surfaceHeld: Bool {
        surfaceHeldSnapshot
    }

    public var upstreamEvidenceHeld: Bool {
        upstreamEvidenceHeldSnapshot
    }

    public var productionDefaultsClosed: Bool {
        productionDefaultsClosedSnapshot
    }

    public var stateLabels: [String] {
        Self.stateLabels(for: rows)
    }

    public var endpointClassLabels: [String] {
        rows.map(\.endpointClass.rawValue).uniqueStable()
    }

    public var credentialStateLabels: [String] {
        rows.map(\.credentialState.rawValue).uniqueStable()
    }

    public var noOrderStatusLabels: [String] {
        rows.map(\.noOrderStatus.rawValue).uniqueStable()
    }

    public init(
        surfaceID: Identifier = Identifier.constant("gh-1248-release-v0.20.0-dashboard-cli-read-only-live-readiness-surface"),
        issueID: Identifier = Identifier.constant("GH-1248"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-1243"),
            Identifier.constant("GH-1244"),
            Identifier.constant("GH-1245"),
            Identifier.constant("GH-1246"),
            Identifier.constant("GH-1247")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-1247"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1249"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        environmentProfile: ReleaseV0200ProductionShadowEnvironmentProfile? = nil,
        endpointAllowlist: ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist? = nil,
        credentialReferenceReadiness: ReleaseV0200ProductionShadowCredentialReferenceReadiness? = nil,
        publicMarketProbe: ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe? = nil,
        signedAccountReadiness: ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness? = nil,
        accountSnapshotRedactionPolicy: ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy? = nil,
        noOrderCapabilityGuard: ReleaseV0200ProductionShadowNoOrderCapabilityGuard? = nil,
        riskKillSwitchNoTradeReadiness: ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness? = nil,
        rows: [ReleaseV0200ReadOnlyLiveReadinessSurfaceRow]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        signedOrderMaterialGenerated: Bool = false,
        accountEndpointConnected: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        dashboardTradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedEnvironment = try environmentProfile
            ?? ReleaseV0200ProductionShadowEnvironmentProfile.deterministicFixture()
        let resolvedEndpointAllowlist = try endpointAllowlist
            ?? ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist.deterministicFixture()
        let resolvedCredential = try credentialReferenceReadiness
            ?? ReleaseV0200ProductionShadowCredentialReferenceReadiness.deterministicFixture()
        let resolvedPublicMarket = try publicMarketProbe
            ?? ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe.deterministicFixture()
        let resolvedSignedAccount = try signedAccountReadiness
            ?? ReleaseV0200ProductionShadowSignedAccountReadOnlyReadiness.deterministicFixture()
        let resolvedRedaction = try accountSnapshotRedactionPolicy
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy.deterministicFixture()
        let resolvedNoOrder = try noOrderCapabilityGuard
            ?? ReleaseV0200ProductionShadowNoOrderCapabilityGuard.deterministicFixture()
        let resolvedRisk = try riskKillSwitchNoTradeReadiness
            ?? ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness.deterministicFixture()
        let resolvedUpstreamEvidenceHeld = resolvedEnvironment.profileHeld
            && resolvedEndpointAllowlist.allowlistHeld
            && resolvedCredential.readinessHeld
            && resolvedPublicMarket.probeHeld
            && resolvedSignedAccount.readinessHeld
            && resolvedRedaction.policyHeld
            && resolvedNoOrder.guardHeld
            && resolvedRisk.readinessHeld
        let resolvedRows = try rows ?? Self.defaultRows()
        let resolvedProductionDefaultsClosed = productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && signedOrderMaterialGenerated == false
            && accountEndpointConnected == false
            && orderEndpointTouched == false
            && submitCancelReplaceEnabled == false
            && dashboardTradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
        let resolvedSurfaceHeld = issueID.rawValue == "GH-1248"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1243", "GH-1244", "GH-1245", "GH-1246", "GH-1247"]
            && previousIssueID.rawValue == "GH-1247"
            && downstreamIssueID.rawValue == "GH-1249"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && resolvedUpstreamEvidenceHeld
            && resolvedRows.count == ReleaseV0200ReadOnlyLiveReadinessSurfaceArea.allCases.count
            && resolvedRows.map(\.area) == ReleaseV0200ReadOnlyLiveReadinessSurfaceArea.allCases
            && resolvedRows.allSatisfy(\.rowHeld)
            && Self.stateLabels(for: resolvedRows)
                == ReleaseV0200ReadOnlyLiveReadinessSurfaceState.allCases.map(\.rawValue)
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && resolvedProductionDefaultsClosed
        self.surfaceID = surfaceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.environmentProfile = resolvedEnvironment
        self.endpointAllowlist = resolvedEndpointAllowlist
        self.credentialReferenceReadiness = resolvedCredential
        self.publicMarketProbe = resolvedPublicMarket
        self.signedAccountReadiness = resolvedSignedAccount
        self.accountSnapshotRedactionPolicy = resolvedRedaction
        self.noOrderCapabilityGuard = resolvedNoOrder
        self.riskKillSwitchNoTradeReadiness = resolvedRisk
        self.upstreamEvidenceHeldSnapshot = resolvedUpstreamEvidenceHeld
        self.rows = resolvedRows
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionDefaultsClosedSnapshot = resolvedProductionDefaultsClosed
        self.surfaceHeldSnapshot = resolvedSurfaceHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.signedOrderMaterialGenerated = signedOrderMaterialGenerated
        self.accountEndpointConnected = accountEndpointConnected
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.dashboardTradingButtonVisible = dashboardTradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
        try validate()
    }

    public static let requiredValidationAnchors = [
        "GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
        "TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
        "V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
        "V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER",
        "V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES",
        "V0200-010-DASHBOARD-CLI-NO-CONTROLS",
        "V0200-010-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1248DashboardReadOnlyLiveReadinessSurfaceShowsProductionShadowStateWithoutControls",
        "swift test --filter TargetGraphTests/testGH1248ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurface",
        "bash checks/verify-v0.20.0-dashboard-cli-read-only-live-readiness-surface.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicFixture() throws -> ReleaseV0200ReadOnlyLiveReadinessSurface {
        try ReleaseV0200ReadOnlyLiveReadinessSurface()
    }

    private static func stateLabels(for rows: [ReleaseV0200ReadOnlyLiveReadinessSurfaceRow]) -> [String] {
        ReleaseV0200ReadOnlyLiveReadinessSurfaceState.allCases
            .filter { state in rows.contains { $0.state == state } }
            .map(\.rawValue)
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.readOnlyLiveReadinessSurface.cliCommand",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        guard arguments.count == 1 || arguments == [cliCommand, "status"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.readOnlyLiveReadinessSurface.arguments",
                expected: "\(cliCommand) [status]",
                actual: arguments.joined(separator: " ")
            )
        }
        return lightweightCommandLineOutput()
    }

    public func commandLineOutput() -> String {
        ([
            "mtpro \(Self.cliCommand) status",
            "issue=GH-1248",
            "validationAnchor=TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
            "verificationAnchor=GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "releaseVersion=\(releaseVersion)",
            "projectName=\(projectName)",
            "surfaceRows=\(rows.count)",
            "states=\(stateLabels.joined(separator: ","))",
            "endpointClasses=\(endpointClassLabels.joined(separator: ","))",
            "credentialStates=\(credentialStateLabels.joined(separator: ","))",
            "noOrderStatuses=\(noOrderStatusLabels.joined(separator: ","))"
        ] + rows.map { row in
            [
                "row=\(row.area.rawValue)",
                "issue=\(row.sourceIssueID)",
                "state=\(row.state.rawValue)",
                "endpointClass=\(row.endpointClass.rawValue)",
                "credentialState=\(row.credentialState.rawValue)",
                "redactionState=\(row.redactionState.rawValue)",
                "noOrderStatus=\(row.noOrderStatus.rawValue)",
                "summary=\(row.statusSummary)"
            ].joined(separator: ";")
        } + [
            "dashboardReadOnly=true",
            "cliReadOnly=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "submitCancelReplaceEnabled=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretValueRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionCutoverAuthorized=false",
            "realOrderSent=false",
            "boundaryHeld=\(surfaceHeld)"
        ]).joined(separator: "\n")
    }

    private static func lightweightCommandLineOutput() -> String {
        let rowLines = readOnlyStatusRows.map { row in
            [
                "row=\(row.area)",
                "issue=\(row.issue)",
                "state=\(row.state)",
                "endpointClass=\(row.endpointClass)",
                "credentialState=\(row.credentialState)",
                "redactionState=\(row.redactionState)",
                "noOrderStatus=\(row.noOrderStatus)",
                "summary=\(row.summary)"
            ].joined(separator: ";")
        }

        return ([
            "mtpro \(cliCommand) status",
            "issue=GH-1248",
            "validationAnchor=TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
            "verificationAnchor=GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE",
            "requiredAnchors=\(requiredValidationAnchors.joined(separator: ","))",
            "releaseVersion=v0.20.0",
            "projectName=\(ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName)",
            "surfaceRows=\(readOnlyStatusRows.count)",
            "states=ready,blocked,fail-closed",
            "endpointClasses=no-endpoint-connection,public-read-only,signed-read-only-intent,not-applicable",
            "credentialStates=identity-reference-only,not-applicable,redacted-reference-only,no-credential-required",
            "noOrderStatuses=not-applicable,blocked"
        ] + rowLines + [
            "dashboardReadOnly=true",
            "cliReadOnly=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "submitCancelReplaceEnabled=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretValueRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionCutoverAuthorized=false",
            "realOrderSent=false",
            "boundaryHeld=true"
        ]).joined(separator: "\n")
    }

    private static let readOnlyStatusRows = [
        (
            area: "environment-profile",
            issue: "GH-1240",
            state: "ready",
            endpointClass: "no-endpoint-connection",
            credentialState: "identity-reference-only",
            redactionState: "redacted",
            noOrderStatus: "not-applicable",
            summary: "production-shadow profile registered; endpoint intent only"
        ),
        (
            area: "endpoint-allowlist",
            issue: "GH-1241",
            state: "ready",
            endpointClass: "public-read-only",
            credentialState: "not-applicable",
            redactionState: "not-applicable",
            noOrderStatus: "blocked",
            summary: "public read-only endpoint shapes allowlisted; no connection opened"
        ),
        (
            area: "credential-reference",
            issue: "GH-1242",
            state: "ready",
            endpointClass: "no-endpoint-connection",
            credentialState: "redacted-reference-only",
            redactionState: "redacted",
            noOrderStatus: "not-applicable",
            summary: "credential identity reference only; secret value not read"
        ),
        (
            area: "public-market-probe",
            issue: "GH-1243",
            state: "ready",
            endpointClass: "public-read-only",
            credentialState: "no-credential-required",
            redactionState: "no-raw-payload",
            noOrderStatus: "blocked",
            summary: "public market read-only classification visible"
        ),
        (
            area: "signed-account-readiness",
            issue: "GH-1244",
            state: "blocked",
            endpointClass: "signed-read-only-intent",
            credentialState: "redacted-reference-only",
            redactionState: "redacted",
            noOrderStatus: "blocked",
            summary: "signed account endpoint remains intent-only; no signed request material"
        ),
        (
            area: "account-snapshot-redaction",
            issue: "GH-1245",
            state: "ready",
            endpointClass: "signed-read-only-intent",
            credentialState: "redacted-reference-only",
            redactionState: "redacted",
            noOrderStatus: "blocked",
            summary: "account snapshot artifact policy redacts raw account, balance and payload fields"
        ),
        (
            area: "no-order-capability",
            issue: "GH-1246",
            state: "fail-closed",
            endpointClass: "not-applicable",
            credentialState: "not-applicable",
            redactionState: "not-applicable",
            noOrderStatus: "blocked",
            summary: "submit, cancel, replace and Dashboard / CLI bypass attempts remain blocked"
        ),
        (
            area: "risk-kill-switch-no-trade",
            issue: "GH-1247",
            state: "fail-closed",
            endpointClass: "not-applicable",
            credentialState: "not-applicable",
            redactionState: "not-applicable",
            noOrderStatus: "blocked",
            summary: "risk gate, kill switch and no-trade state are visible and fail closed"
        )
    ]

    private static func defaultRows() throws -> [ReleaseV0200ReadOnlyLiveReadinessSurfaceRow] {
        try [
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .environmentProfile,
                sourceIssueID: "GH-1240",
                state: .ready,
                endpointClass: .noEndpointConnection,
                credentialState: .identityReferenceOnly,
                redactionState: .redacted,
                noOrderStatus: .notApplicable,
                statusSummary: "production-shadow profile registered; endpoint intent only"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .endpointAllowlist,
                sourceIssueID: "GH-1241",
                state: .ready,
                endpointClass: .publicReadOnly,
                credentialState: .notApplicable,
                redactionState: .notApplicable,
                noOrderStatus: .blocked,
                statusSummary: "public read-only endpoint shapes allowlisted; no connection opened"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .credentialReference,
                sourceIssueID: "GH-1242",
                state: .ready,
                endpointClass: .noEndpointConnection,
                credentialState: .redactedReferenceOnly,
                redactionState: .redacted,
                noOrderStatus: .notApplicable,
                statusSummary: "credential identity reference only; secret value not read"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .publicMarketProbe,
                sourceIssueID: "GH-1243",
                state: .ready,
                endpointClass: .publicReadOnly,
                credentialState: .noCredentialRequired,
                redactionState: .noRawPayload,
                noOrderStatus: .blocked,
                statusSummary: "public market read-only classification visible"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .signedAccountReadiness,
                sourceIssueID: "GH-1244",
                state: .blocked,
                endpointClass: .signedReadOnlyIntent,
                credentialState: .redactedReferenceOnly,
                redactionState: .redacted,
                noOrderStatus: .blocked,
                statusSummary: "signed account endpoint remains intent-only; no signed request material"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .accountSnapshotRedaction,
                sourceIssueID: "GH-1245",
                state: .ready,
                endpointClass: .signedReadOnlyIntent,
                credentialState: .redactedReferenceOnly,
                redactionState: .redacted,
                noOrderStatus: .blocked,
                statusSummary: "account snapshot artifact policy redacts raw account, balance and payload fields"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .noOrderCapability,
                sourceIssueID: "GH-1246",
                state: .failClosed,
                endpointClass: .notApplicable,
                credentialState: .notApplicable,
                redactionState: .notApplicable,
                noOrderStatus: .blocked,
                statusSummary: "submit, cancel, replace and Dashboard / CLI bypass attempts remain blocked"
            ),
            ReleaseV0200ReadOnlyLiveReadinessSurfaceRow(
                area: .riskKillSwitchNoTrade,
                sourceIssueID: "GH-1247",
                state: .failClosed,
                endpointClass: .notApplicable,
                credentialState: .notApplicable,
                redactionState: .notApplicable,
                noOrderStatus: .blocked,
                statusSummary: "risk gate, kill switch and no-trade state are visible and fail closed"
            )
        ]
    }

    private func validate() throws {
        guard surfaceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.readOnlyLiveReadinessSurface",
                expected: "Dashboard / CLI read-only live readiness surface held",
                actual: issueID.rawValue
            )
        }
    }
}

private extension Array where Element == String {
    func uniqueStable() -> [String] {
        var seen: Set<String> = []
        return filter { seen.insert($0).inserted }
    }
}
