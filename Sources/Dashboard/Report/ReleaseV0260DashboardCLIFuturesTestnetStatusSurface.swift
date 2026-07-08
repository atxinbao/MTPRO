import ExecutionClient
import Foundation

// GH-1401 Dashboard / CLI Futures testnet status anchors:
// GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
// TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
// V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS
// V0260-008-NO-DASHBOARD-TRADING-CONTROLS
// GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT
// TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION
// V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION
// V0260-001-NO-PRODUCTION-CUTOVER
// GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE
// V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE
// V0260-002-CREDENTIAL-REFERENCE-ONLY
// GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION
// V0260-003-NO-PRODUCTION-CUTOVER
// V0260-003-ORDER-INTENT-VALIDATED
// GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE
// V0260-004-MANUAL-APPROVAL-HARD-CAPS
// V0260-004-IDEMPOTENCY-REDACTION
// GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK
// V0260-005-CANCEL-STATUS-ROLLBACK
// V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY
// GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION
// V0260-006-OMS-EVENT-LOG-RECONCILIATION
// V0260-006-APPEND-ONLY-EVIDENCE
// GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS
// V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD
// V0260-007-REDUCE-ONLY-HARD-CAP
// GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION
// TVM-RELEASE-V0260-AGGREGATE-VALIDATION
// V0260-009-AGGREGATE-VALIDATION-SUITE
// GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS
// V0260-010-STAGE-CODE-AUDIT
// V0260-010-NO-PRODUCTION-CUTOVER
// V0260-010-NO-TAG-OR-RELEASE-PUBLICATION
// Binance USD-M Futures testnet controlled execution foundation.
// productionFuturesOrderExecutionEnabled=false.
// production cutover not authorized.

public struct ReleaseV0260DashboardCLIFuturesTestnetStatusSurface: Equatable, Sendable {
    public static let panelID = "release-v0.26.0-futures-testnet-controlled-execution-status"
    public static let validationAnchor =
        ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.validationAnchor
    public static let verificationAnchor =
        "GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE"
    public static let requiredAnchors =
        ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence.requiredAnchors

    public let source: ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence

    public init(
        source: ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence = .deterministicFixture
    ) {
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
                "dashboardTradingControlsEnabled=false",
                "tradingButtonVisible=false",
                "orderFormVisible=false",
                "liveCommandVisible=false",
                "liveProConsoleEnabled=false",
                "productionCutoverAuthorized=false"
            ]
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.productionFuturesOrderExecutionEnabled == false
            && source.productionTradingEnabledByDefault == false
            && source.productionCutoverAuthorized == false
            && source.okxActiveRuntimeEnabled == false
            && source.dashboardTradingControlsEnabled == false
    }
}
