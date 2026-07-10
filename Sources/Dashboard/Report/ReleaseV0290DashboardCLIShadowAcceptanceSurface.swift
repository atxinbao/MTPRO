import ExecutionClient
import Foundation

// GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT
// TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
// V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
// V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT
// V0290-001-NO-DEFAULT-TRADING
// V0290-001-NO-SUBMIT
// GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL
// V0290-002-PRODUCTION-SHADOW-CONFIGURATION
// V0290-002-NO-SECRET-CONFIGURATION
// V0290-002-MISMATCH-FAILS-CLOSED
// GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION
// V0290-003-CREDENTIAL-REFERENCE-ONLY
// V0290-003-OPERATOR-APPROVAL-REQUIRED
// V0290-003-SECRET-VALUE-NOT-PERSISTED
// GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT
// V0290-004-ENDPOINT-ALLOWLIST-READONLY
// V0290-004-MUTATION-ENDPOINTS-BLOCKED
// GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
// V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
// V0290-005-STALE-MISSING-INPUTS-BLOCKED
// GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE
// V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE
// V0290-006-NO-BROKER-FILL-INTERPRETATION
// GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
// V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
// V0290-007-NO-BROKER-SIDE-EFFECT
// GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE
// V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE
// V0290-008-NO-TRADING-CONTROLS
// GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION
// V0290-009-AGGREGATE-VALIDATION
// V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX
// GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS
// V0290-010-STAGE-AUDIT-RELEASE-DOCS
// V0290-010-NO-PRODUCTION-CUTOVER
// productionTradingEnabledByDefault=false
// productionCutoverAuthorized=false
// productionSecretAutoReadEnabled=false
// automaticBrokerConnectionEnabled=false
// productionSubmitCancelReplaceEnabled=false
// futuresProductionExecutionEnabled=false
// leverageMarginPositionMutationEnabled=false
// okxActiveRuntimeEnabled=false
// dashboardTradingControlsEnabled=false
// orderFormEnabled=false
// liveCommandEnabled=false
// noSubmitTransportMode=true
// shadowOnly=true
// evidenceComplete=true
// boundaryHeld=true
// TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR

public struct ReleaseV0290DashboardCLIShadowAcceptanceSurface: Equatable, Sendable {
    public static let panelID = "release-v0.29.0-production-dry-run-shadow-acceptance"
    public static let validationAnchor =
        ReleaseV0290ProductionDryRunShadowAcceptance.validationAnchor
    public static let verificationAnchor =
        "GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE"
    public static let requiredAnchors =
        ReleaseV0290ProductionDryRunShadowAcceptance.requiredAnchors

    public let source: ReleaseV0290ProductionDryRunShadowAcceptance

    public init(source: ReleaseV0290ProductionDryRunShadowAcceptance = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        var lines = [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)"
        ]
        lines.append(contentsOf: source.statusLines)
        lines.append(contentsOf: source.evidenceLines)
        lines.append(contentsOf: source.boundaryLines)
        lines.append(contentsOf: [
            "evidenceOrigin=\(source.evidenceOrigin.rawValue)",
            "acceptanceDecision=\(source.acceptanceDecision.rawValue)",
            "acceptanceClassification=contract-deterministic-fixture",
            "observedRunAccepted=\(source.observedRunAccepted)",
            "dashboardBoundary=read-only",
            "cliBoundary=inspect-status-verify-export-only",
            "shadowOnly=true",
            "noSubmit=true",
            "productionCutoverAuthorized=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "rawSecretVisible=false",
            "rawBrokerPayloadVisible=false"
        ])
        return lines
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.shadowOnly
            && source.noSubmitTransportMode
            && source.dashboardTradingControlsEnabled == false
            && source.orderFormEnabled == false
            && source.liveCommandEnabled == false
            && source.productionCutoverAuthorized == false
            && source.productionSubmitCancelReplaceEnabled == false
            && source.automaticBrokerConnectionEnabled == false
            && source.okxActiveRuntimeEnabled == false
    }
}
