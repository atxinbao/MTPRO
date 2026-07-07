import ExecutionClient
import Foundation

// GH-1378 Dashboard / CLI operator readiness anchors:
// GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE
// TVM-RELEASE-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE
// V0250-007-DASHBOARD-CLI-OPERATOR-READINESS
// V0250-007-ENVIRONMENT-CREDENTIAL-APPROVAL-EVIDENCE
// V0250-007-RISK-ROLLBACK-NOTRADE-EVIDENCE
// V0250-007-READ-ONLY-SURFACE
// V0250-007-NO-TRADING-BUTTON
// V0250-007-NO-ORDER-FORM
// V0250-007-NO-LIVE-COMMAND

public struct ReleaseV0250DashboardCLIOperatorReadinessSurface: Equatable, Sendable {
    // Dashboard reads the same v0.25.0 operator readiness evidence as CLI and exposes no controls.
    public static let panelID = "release-v0.25.0-operator-readiness"
    public static let validationAnchor = ReleaseV0250OperatorReadinessSurface.validationAnchor
    public static let verificationAnchor = ReleaseV0250OperatorReadinessSurface.verificationAnchor
    public static let requiredAnchors = ReleaseV0250OperatorReadinessSurface.requiredAnchors

    public let source: ReleaseV0250OperatorReadinessSurface

    public init(source: ReleaseV0250OperatorReadinessSurface = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)"
        ] + source.reportLines
            + [
                "dashboardBoundary=read-only",
                "dashboardTradingControlsEnabled=false",
                "tradingButtonVisible=false",
                "orderFormVisible=false",
                "liveCommandVisible=false",
                "productionCutoverAuthorized=false"
            ]
    }

    public var boundaryHeld: Bool {
        source.evidenceHeld
            && source.dashboardTradingControlsEnabled == false
            && source.tradingButtonVisible == false
            && source.orderFormVisible == false
            && source.liveCommandVisible == false
            && source.liveProConsoleEnabled == false
            && source.submitCancelReplaceEnabled == false
            && source.productionCutoverAuthorized == false
    }
}
