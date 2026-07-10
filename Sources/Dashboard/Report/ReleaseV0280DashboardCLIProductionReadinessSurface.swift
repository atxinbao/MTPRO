import ExecutionClient
import Foundation

// GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT
// TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE
// V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS
// V0280-001-NOT-PRODUCTION-CUTOVER
// V0280-001-SPOT-USDM-FUTURES-ONLY
// V0280-001-OKX-NOT-ACTIVE
// GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY
// V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL
// V0280-002-NO-DEFAULT-SECRET-READ
// V0280-002-REDACTION-REQUIRED
// GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST
// V0280-003-ENDPOINT-ALLOWLIST
// V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION
// V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS
// GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION
// V0280-004-MANUAL-APPROVAL-REQUIRED
// V0280-004-OPERATOR-CONFIRMATION-REQUIRED
// V0280-004-NO-AUTO-CUTOVER
// GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE
// V0280-005-CAPITAL-RISK-GATE
// V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS
// V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED
// GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP
// V0280-006-KILL-SWITCH-REQUIRED
// V0280-006-NO-TRADE-STATE-REQUIRED
// V0280-006-ROLLBACK-INCIDENT-STOP-READY
// GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE
// V0280-007-DASHBOARD-CLI-READINESS
// V0280-007-NO-TRADING-BUTTON
// V0280-007-NO-ORDER-FORM
// V0280-007-NO-LIVE-COMMAND
// GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
// V0280-008-AGGREGATE-VALIDATION
// V0280-008-STAGE-AUDIT-RELEASE-DOCS
// V0280-008-NO-PRODUCTION-CUTOVER
// GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC
// GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE
// GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD
// GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES
// V0281-004-EVALUATION-MODE-CONTRACT-ONLY
// V0281-004-READINESS-STATUS-NOT-EVALUATED
// V0281-004-CUTOVER-DECISION-BLOCKED
// GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE
// V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES
// GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE
// GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE
// GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES
// evaluationMode=contract-only
// readinessStatus=not-evaluated
// cutoverDecision=blocked
// readinessGateEvidenceComplete=true

public struct ReleaseV0280DashboardCLIProductionReadinessSurface: Equatable, Sendable {
    public static let panelID = "release-v0.28.0-production-cutover-readiness"
    public static let validationAnchor =
        ReleaseV0280ProductionCutoverReadinessGate.validationAnchor
    public static let verificationAnchor =
        "GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE"
    public static let requiredAnchors =
        ReleaseV0280ProductionCutoverReadinessGate.requiredAnchors

    public let source: ReleaseV0280ProductionCutoverReadinessGate

    public init(source: ReleaseV0280ProductionCutoverReadinessGate = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        var lines = [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)"
        ]
        lines.append(contentsOf: source.statusLines)
        lines.append(contentsOf: source.gateLines)
        lines.append(contentsOf: source.boundaryLines)
        lines.append(contentsOf: [
            "dashboardBoundary=read-only",
            "rawSecretVisible=false",
            "rawBrokerPayloadVisible=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "productionCutoverAuthorized=false"
        ])
        return lines
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.dashboardTradingControlsEnabled == false
            && source.orderFormEnabled == false
            && source.liveCommandEnabled == false
            && source.productionCutoverAuthorized == false
            && source.productionOrderSubmitCancelReplaceEnabled == false
            && source.okxActiveRuntimeEnabled == false
    }
}
