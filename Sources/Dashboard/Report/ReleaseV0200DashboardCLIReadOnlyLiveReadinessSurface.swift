import Core
import ExecutionClient
import Foundation

// GH-1248 Dashboard surface anchors:
// GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// TVM-RELEASE-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// V0200-010-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE
// V0200-010-GATE-STATE-ENDPOINT-CREDENTIAL-REDACTION-NO-ORDER
// V0200-010-BLOCKED-READY-FAIL-CLOSED-STATES
// V0200-010-DASHBOARD-CLI-NO-CONTROLS
// V0200-010-NO-PRODUCTION-CUTOVER

/// ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurfaceViewModel 是 GH-1248 的 Dashboard 只读面。
///
/// ViewModel 只包装 `ReleaseV0200ReadOnlyLiveReadinessSurface` 的本地 deterministic evidence。
/// Dashboard 从中展示 gate state、endpoint class、credential reference、redaction 和 no-order
/// status；它不提供交易按钮、订单表单、live command 或任何生产切换入口。
public struct ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurfaceViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let source: ViewModelSourceContract
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let previousIssueID: String
    public let downstreamIssueID: String
    public let releaseVersion: String
    public let rows: [ReleaseV0200ReadOnlyLiveReadinessSurfaceRow]
    public let stateLabels: [String]
    public let endpointClassLabels: [String]
    public let credentialStateLabels: [String]
    public let noOrderStatusLabels: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let surfaceHeld: Bool
    public let upstreamEvidenceHeld: Bool
    public let productionDefaultsClosed: Bool
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

    public var rowCount: Int {
        rows.count
    }

    public static let requiredValidationAnchors = ReleaseV0200ReadOnlyLiveReadinessSurface.requiredValidationAnchors

    public var boundaryHeld: Bool {
        source.isReadModelOnly
            && surfaceHeld
            && rows.allSatisfy(\.rowHeld)
            && productionDefaultsClosed
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.20 readiness rows", value: "\(rowCount)"),
            DashboardShellMetric(label: "v0.20 readiness states", value: stateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Endpoint classes", value: endpointClassLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Credential states", value: credentialStateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "No-order statuses", value: noOrderStatusLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        rows.map { row in
            """
            \(row.area.rawValue): state=\(row.state.rawValue); issue=\(row.sourceIssueID); \
            endpoint=\(row.endpointClass.rawValue); credential=\(row.credentialState.rawValue); \
            redaction=\(row.redactionState.rawValue); noOrder=\(row.noOrderStatus.rawValue); \
            summary=\(row.statusSummary)
            """
        } + [
            "Dashboard command surface: none",
            "CLI command surface: read-only status only",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production secret value: not read",
            "Production endpoint: not connected",
            "Production cutover: none",
            "Readiness surface boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        surface: ReleaseV0200ReadOnlyLiveReadinessSurface
    ) {
        self.source = source
        self.issueID = surface.issueID.rawValue
        self.upstreamIssueIDs = surface.upstreamIssueIDs.map(\.rawValue)
        self.previousIssueID = surface.previousIssueID.rawValue
        self.downstreamIssueID = surface.downstreamIssueID.rawValue
        self.releaseVersion = surface.releaseVersion
        self.rows = surface.rows
        self.stateLabels = surface.stateLabels
        self.endpointClassLabels = surface.endpointClassLabels
        self.credentialStateLabels = surface.credentialStateLabels
        self.noOrderStatusLabels = surface.noOrderStatusLabels
        self.validationAnchors = surface.validationAnchors
        self.requiredValidationCommands = surface.requiredValidationCommands
        self.surfaceHeld = surface.surfaceHeld
        self.upstreamEvidenceHeld = surface.upstreamEvidenceHeld
        self.productionDefaultsClosed = surface.productionDefaultsClosed
        self.productionTradingEnabledByDefault = surface.productionTradingEnabledByDefault
        self.productionSecretValueRead = surface.productionSecretValueRead
        self.productionEndpointConnected = surface.productionEndpointConnected
        self.brokerEndpointConnected = surface.brokerEndpointConnected
        self.signedOrderMaterialGenerated = surface.signedOrderMaterialGenerated
        self.accountEndpointConnected = surface.accountEndpointConnected
        self.orderEndpointTouched = surface.orderEndpointTouched
        self.submitCancelReplaceEnabled = surface.submitCancelReplaceEnabled
        self.dashboardTradingButtonVisible = surface.dashboardTradingButtonVisible
        self.orderFormVisible = surface.orderFormVisible
        self.liveCommandVisible = surface.liveCommandVisible
        self.spotCanaryEnabled = surface.spotCanaryEnabled
        self.futuresRuntimeEnabled = surface.futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = surface.okxActiveImplementationEnabled
        self.productionCutoverAuthorized = surface.productionCutoverAuthorized
        self.createsTagOrRelease = surface.createsTagOrRelease
    }

    public static var deterministicFixture: ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurfaceViewModel {
        do {
            return try deterministic()
        } catch {
            preconditionFailure("Release v0.20.0 Dashboard / CLI readiness surface fixture failed: \(error)")
        }
    }

    public static func deterministic() throws -> ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurfaceViewModel {
        try ReleaseV0200DashboardCLIReadOnlyLiveReadinessSurfaceViewModel(
            surface: ReleaseV0200ReadOnlyLiveReadinessSurface.deterministicFixture()
        )
    }
}
