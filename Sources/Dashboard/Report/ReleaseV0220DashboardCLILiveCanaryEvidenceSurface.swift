import Core
import Foundation

// GH-1318 Dashboard surface anchors:
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

/// GH-1318 Dashboard / CLI live canary evidence surface view model。
///
/// 该 ViewModel 只包装 `ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface`
/// deterministic evidence，向 Dashboard 展示 approval、preflight、submit、
/// status/cancel、OMS、reconciliation、failure class、next action 和 redaction 状态。
/// 它不提供交易按钮、订单表单、live command 或 production cutover 控制。
public struct ReleaseV0220DashboardCLILiveCanaryEvidenceSurfaceViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let source: ViewModelSourceContract
    public let issueID: String
    public let blockedByIssueIDs: [String]
    public let downstreamIssueIDs: [String]
    public let releaseVersion: String
    public let rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow]
    public let stateLabels: [String]
    public let gateLabels: [String]
    public let failureClassLabels: [String]
    public let nextActionLabels: [String]
    public let rollbackCommandLabels: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let surfaceHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresEnabled: Bool
    public let okxEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var rowCount: Int {
        rows.count
    }

    public static let requiredValidationAnchors =
        ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredValidationAnchors

    public var boundaryHeld: Bool {
        source.isReadModelOnly
            && surfaceHeld
            && rows.allSatisfy(\.rowHeld)
            && productionTradingEnabledByDefault == false
            && futuresEnabled == false
            && okxEnabled == false
            && dashboardTradingCommandEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
            && rawBrokerPayloadPersisted == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.22 canary evidence rows", value: "\(rowCount)"),
            DashboardShellMetric(label: "v0.22 states", value: stateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Evidence gates", value: gateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Failure classes", value: failureClassLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Next actions", value: nextActionLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Rollback commands", value: rollbackCommandLabels.joined(separator: ",")),
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
            "CLI command surface: read-only status / failures / rollback / reconciliation only",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Futures: disabled",
            "OKX: disabled",
            "Raw order id: hidden",
            "Raw broker payload: hidden",
            "Production cutover: none",
            "Live canary evidence surface boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        surface: ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface
    ) {
        self.init(
            source: source,
            issueID: surface.issueID.rawValue,
            blockedByIssueIDs: surface.blockedByIssueIDs.map(\.rawValue),
            downstreamIssueIDs: surface.downstreamIssueIDs.map(\.rawValue),
            releaseVersion: surface.releaseVersion,
            rows: surface.rows,
            stateLabels: surface.stateLabels,
            gateLabels: surface.gateLabels,
            failureClassLabels: surface.failureClassLabels,
            nextActionLabels: surface.nextActionLabels,
            rollbackCommandLabels: surface.rollbackCommandLabels,
            validationAnchors: surface.validationAnchors,
            requiredValidationCommands: surface.requiredValidationCommands,
            surfaceHeld: surface.surfaceHeld,
            productionTradingEnabledByDefault: surface.productionTradingEnabledByDefault,
            futuresEnabled: surface.futuresEnabled,
            okxEnabled: surface.okxEnabled,
            dashboardTradingCommandEnabled: surface.dashboardTradingCommandEnabled,
            tradingButtonVisible: surface.tradingButtonVisible,
            orderFormVisible: surface.orderFormVisible,
            liveCommandVisible: surface.liveCommandVisible,
            submitCancelReplaceEnabled: surface.submitCancelReplaceEnabled,
            rawOrderIDVisible: surface.rawOrderIDVisible,
            rawBrokerPayloadVisible: surface.rawBrokerPayloadVisible,
            rawBrokerPayloadPersisted: surface.rawBrokerPayloadPersisted,
            createsTagOrRelease: surface.createsTagOrRelease,
            productionCutoverAuthorized: surface.productionCutoverAuthorized
        )
    }

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        issueID: String = "GH-1318",
        blockedByIssueIDs: [String] = ["GH-1317"],
        downstreamIssueIDs: [String] = ["GH-1319"],
        releaseVersion: String = "v0.22.0",
        rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow],
        stateLabels: [String],
        gateLabels: [String],
        failureClassLabels: [String],
        nextActionLabels: [String],
        rollbackCommandLabels: [String],
        validationAnchors: [String] =
            ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredValidationAnchors,
        requiredValidationCommands: [String] =
            ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredValidationCommands,
        surfaceHeld: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresEnabled: Bool = false,
        okxEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        rawOrderIDVisible: Bool = false,
        rawBrokerPayloadVisible: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.source = source
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.rows = rows
        self.stateLabels = stateLabels
        self.gateLabels = gateLabels
        self.failureClassLabels = failureClassLabels
        self.nextActionLabels = nextActionLabels
        self.rollbackCommandLabels = rollbackCommandLabels
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.surfaceHeld = surfaceHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresEnabled = futuresEnabled
        self.okxEnabled = okxEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.rawOrderIDVisible = rawOrderIDVisible
        self.rawBrokerPayloadVisible = rawBrokerPayloadVisible
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static var deterministicFixture: ReleaseV0220DashboardCLILiveCanaryEvidenceSurfaceViewModel {
        do {
            return try deterministic()
        } catch {
            preconditionFailure("Release v0.22.0 Dashboard / CLI live canary evidence fixture failed: \(error)")
        }
    }

    public static func deterministic() throws
        -> ReleaseV0220DashboardCLILiveCanaryEvidenceSurfaceViewModel
    {
        let rows = try ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.deterministicRows()
        return ReleaseV0220DashboardCLILiveCanaryEvidenceSurfaceViewModel(
            rows: rows,
            stateLabels: uniqueStable(rows.map { $0.state.rawValue }),
            gateLabels: uniqueStable(rows.map(\.gateLabel)),
            failureClassLabels: ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredFailureClassLabels,
            nextActionLabels: ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredNextActionLabels,
            rollbackCommandLabels: ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.requiredRollbackCommandLabels
        )
    }

    private static func uniqueStable(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }
}
