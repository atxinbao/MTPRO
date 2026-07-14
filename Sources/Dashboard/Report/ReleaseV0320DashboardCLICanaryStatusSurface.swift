import ExecutionClient
import Foundation

// GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT
// GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE
// GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE
// GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL
// GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
// GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK
// GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP
// GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS
// GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE
// GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS
// V0320-001-CANARY-OPERATIONS-CONTRACT
// V0320-002-HUMAN-APPROVED-ENABLEMENT-BUNDLE
// V0320-003-STRICT-SIZE-CAP-FINAL-GATE
// V0320-004-SPOT-CANARY-SUBMIT-STATUS-CANCEL
// V0320-005-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
// V0320-006-OMS-RECONCILIATION-ROLLBACK
// V0320-007-KILL-NOTRADE-INCIDENT-STOP
// V0320-008-DASHBOARD-CLI-CANARY-STATUS
// V0320-009-AGGREGATE-VALIDATION-SUITE
// V0320-010-STAGE-AUDIT-RELEASE-DOCS

/// v0.32.0 Dashboard/CLI 只展示 canary 状态，不提供无限制交易控件。
public struct ReleaseV0320DashboardCLICanaryStatusSurface: Equatable, Sendable {
    public static let panelID = "release-v0.32.0-controlled-production-canary-status"
    public static let validationAnchor = ReleaseV0320ControlledProductionCanaryOperations.validationAnchor
    public static let verificationAnchor = "GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS"

    public let source: ReleaseV0320ControlledProductionCanaryOperations

    public init(source: ReleaseV0320ControlledProductionCanaryOperations = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "dashboardBoundary=read-only-canary-status",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "unrestrictedLiveCommandVisible=false",
            "operatorCanViewCanaryStatus=true",
            "operatorCanViewHardCaps=true",
            "operatorCanViewRiskAndIncidentGates=true",
            "operatorCanViewOMSReconciliation=true",
            "uiCanBypassRisk=false",
            "uiCanBypassKillSwitch=false",
            "uiCanBypassV0311Dependency=false"
        ] + source.statusLines
            + source.contractLines
            + source.capLines
            + source.omsLines
            + source.incidentLines
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.contract.dashboardTradingButtonEnabled == false
            && source.contract.unrestrictedTradingEnabled == false
            && source.contract.automaticBrokerConnectionEnabled == false
            && source.productionCutoverAuthorized == false
    }
}
