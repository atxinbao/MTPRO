import Core
import Foundation

// GH-1283 Dashboard surface anchors:
// GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
// TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
// V0210-011-DASHBOARD-CLI-CANARY-STATUS
// V0210-011-CANARY-STATE-GATES
// V0210-011-RISK-ORDER-CANCEL-RECONCILIATION
// V0210-011-READ-ONLY-NO-COMMANDS
// V0210-011-NO-PRODUCTION-CUTOVER

/// ReleaseV0210DashboardCLICanaryStatusSurfaceViewModel 是 GH-1283 的 Dashboard 只读面。
///
/// ViewModel 只包装 `ReleaseV0210CanaryStatusReadOnlySurface` 的本地 deterministic evidence。
/// Dashboard 从中展示 canary state、gate stack、risk decision、order lifecycle、cancel /
/// rollback 和 reconciliation；它不提供交易按钮、订单表单、live command 或 production cutover
/// 控制入口。
public struct ReleaseV0210DashboardCLICanaryStatusSurfaceViewModel:
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
    public let rows: [ReleaseV0210CanaryStatusRow]
    public let stateLabels: [String]
    public let gateLabels: [String]
    public let lifecycleEventLabels: [String]
    public let reconciliationLabels: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let upstreamEvidenceHeld: Bool
    public let surfaceHeld: Bool
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
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool
    public let realOrderSent: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var rowCount: Int {
        rows.count
    }

    public static let requiredValidationAnchors =
        ReleaseV0210CanaryStatusReadOnlySurface.requiredValidationAnchors

    public var boundaryHeld: Bool {
        source.isReadModelOnly
            && upstreamEvidenceHeld
            && surfaceHeld
            && rows.allSatisfy(\.rowHeld)
            && productionTradingEnabledByDefault == false
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
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
            && realOrderSent == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.21 canary rows", value: "\(rowCount)"),
            DashboardShellMetric(label: "v0.21 canary states", value: stateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Canary gates", value: gateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Lifecycle events", value: lifecycleEventLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Reconciliation", value: reconciliationLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        rows.map { row in
            """
            \(row.area.rawValue): state=\(row.state.rawValue); issue=\(row.sourceIssueID); \
            gate=\(row.gateLabel); digest=\(row.redactedEvidenceDigest); summary=\(row.statusSummary)
            """
        } + [
            "Dashboard command surface: none",
            "CLI command surface: read-only status / events / reconciliation only",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Raw order id: hidden",
            "Raw broker payload: hidden",
            "Production secret value: not read",
            "Production endpoint: not connected",
            "Production cutover: none",
            "Canary status surface boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        surface: ReleaseV0210CanaryStatusReadOnlySurface
    ) {
        self.source = source
        self.issueID = surface.issueID.rawValue
        self.upstreamIssueIDs = surface.upstreamIssueIDs.map(\.rawValue)
        self.previousIssueID = surface.previousIssueID.rawValue
        self.downstreamIssueID = surface.downstreamIssueID.rawValue
        self.releaseVersion = surface.releaseVersion
        self.rows = surface.rows
        self.stateLabels = surface.stateLabels
        self.gateLabels = surface.gateLabels
        self.lifecycleEventLabels = surface.lifecycleEventLabels
        self.reconciliationLabels = surface.reconciliationLabels
        self.validationAnchors = surface.validationAnchors
        self.requiredValidationCommands = surface.requiredValidationCommands
        self.upstreamEvidenceHeld = surface.upstreamEvidenceHeld
        self.surfaceHeld = surface.surfaceHeld
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
        self.rawOrderIDVisible = surface.rawOrderIDVisible
        self.rawBrokerPayloadVisible = surface.rawBrokerPayloadVisible
        self.realOrderSent = surface.realOrderSent
        self.createsTagOrRelease = surface.createsTagOrRelease
        self.productionCutoverAuthorized = surface.productionCutoverAuthorized
    }

    public static var deterministicFixture: ReleaseV0210DashboardCLICanaryStatusSurfaceViewModel {
        do {
            return try deterministic()
        } catch {
            preconditionFailure("Release v0.21.0 Dashboard / CLI canary status surface fixture failed: \(error)")
        }
    }

    public static func deterministic() throws -> ReleaseV0210DashboardCLICanaryStatusSurfaceViewModel {
        try ReleaseV0210DashboardCLICanaryStatusSurfaceViewModel(
            surface: ReleaseV0210CanaryStatusReadOnlySurface.deterministicFixture()
        )
    }
}
