import ExecutionClient
import Foundation

// GH-1417 read-only Dashboard / CLI Futures testnet failure drilldown anchors:
// GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
// TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING
// V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
// V0270-001-FAIL-CLOSED-SEMANTICS
// GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST
// V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST
// V0270-002-RUN-IDENTITY-EVIDENCE
// GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
// V0270-003-SIGNED-STATUS-RETRY-TIMEOUT
// V0270-003-CLASSIFIED-FAILURE-EVIDENCE
// GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY
// V0270-004-CANCEL-STATUS-RECOVERY
// V0270-004-RECONCILIATION-RECOVERY
// GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
// V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
// V0270-005-CHECKSUM-FAIL-CLOSED
// GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK
// V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD
// V0270-006-RUN-LOCK-HARDENING
// GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY
// V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN
// V0270-007-NO-DASHBOARD-TRADING-CONTROLS
// GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION
// V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
// V0270-008-REDACTION-EVIDENCE
// GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION
// V0270-009-AGGREGATE-VALIDATION-SUITE
// GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS
// V0270-010-STAGE-CODE-AUDIT
// V0270-010-RELEASE-NOTES
// V0270-010-NO-PRODUCTION-CUTOVER
// Binance USD-M Futures testnet operator runtime hardening.
// productionFuturesOrderExecutionEnabled=false.
// production cutover not authorized.

public struct ReleaseV0270DashboardCLIFuturesTestnetFailureDrilldownSurface:
    Equatable,
    Sendable
{
    public static let panelID = "release-v0.27.0-futures-testnet-failure-drilldown"
    public static let validationAnchor =
        ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.validationAnchor
    public static let verificationAnchor =
        "GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY"
    public static let requiredAnchors =
        ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence.requiredAnchors

    public let source: ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence

    public init(
        source: ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence = .deterministicFixture
    ) {
        self.source = source
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)"
        ] + source.statusLines
            + source.failureLines
            + source.recoveryLines
            + source.surfaceLines
            + [
                "dashboardBoundary=read-only",
                "rawBrokerPayloadVisible=false",
                "rawSecretVisible=false",
                "productionCutoverAuthorized=false"
            ]
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.dashboardFailureDrilldownReadOnly
            && source.dashboardTradingControlsEnabled == false
            && source.productionFuturesOrderExecutionEnabled == false
            && source.productionTradingEnabledByDefault == false
            && source.productionCutoverAuthorized == false
            && source.okxActiveRuntimeEnabled == false
    }
}
