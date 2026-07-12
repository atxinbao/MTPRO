import ExecutionClient
import Foundation

// GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE
// TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE
// V0310-009-READONLY-STATUS-SURFACE
// GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT
// GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE
// GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST
// GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES
// GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK
// GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES
// GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION
// GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE
// GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS
// V0310-001-NO-DEFAULT-TRADING-CONTRACT
// V0310-002-CREDENTIAL-APPROVAL-GATE
// V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST
// V0310-004-CAPITAL-RISK-STALE-INPUT-GATES
// V0310-005-MANUAL-APPROVAL-RUN-LOCK
// V0310-006-KILL-NOTRADE-ROLLBACK-GATES
// V0310-007-SIGNED-READONLY-NO-MUTATION
// V0310-008-IMMUTABLE-AUDIT-BUNDLE
// V0310-010-STAGE-AUDIT-RELEASE-DOCS

public struct ReleaseV0310DashboardCLIProductionEnablementStatusSurface: Equatable, Sendable {
    public static let panelID = "release-v0.31.0-controlled-production-enablement"
    public static let validationAnchor = ReleaseV0310ControlledProductionEnablementGate.validationAnchor
    public static let verificationAnchor = "GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE"

    public let source: ReleaseV0310ControlledProductionEnablementGate

    public init(source: ReleaseV0310ControlledProductionEnablementGate = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)"
        ] + source.statusLines
            + source.gateLines
            + [
                "dashboardBoundary=read-only",
                "cliBoundary=status-gates-preflight-audit-boundaries-only",
                "tradingButtonVisible=false",
                "orderFormVisible=false",
                "liveCommandVisible=false",
                "rawSecretVisible=false",
                "rawAccountPayloadVisible=false",
                "adapterMutationRequestVisible=false",
                "uiCanEnableProductionTrading=false",
                "uiCanSubmitCancelReplace=false"
            ]
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.dashboardTradingControlsEnabled == false
            && source.orderFormEnabled == false
            && source.liveCommandEnabled == false
            && source.submitCancelReplaceEnabled == false
            && source.productionCutoverAuthorized == false
    }
}
