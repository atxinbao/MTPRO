import ExecutionClient
import Foundation

// GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT
// GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE
// GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE
// GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT
// GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
// GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE
// GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION
// GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN
// V0300-001-OBSERVED-RUN-LIFECYCLE
// V0300-001-NO-SUBMIT-CONTRACT
// V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE
// V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE
// V0300-003-IMMUTABLE-MANIFEST-PROVENANCE
// V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT
// V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
// V0300-006-DASHBOARD-CLI-READONLY-SURFACE
// V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION
// V0300-008-STAGE-AUDIT-RELEASE-DOCS

/// Dashboard / CLI 共享的 v0.30.0 只读 read model。
///
/// 该 surface 只消费 `ReleaseV0300ObservedProductionShadowRun` 生成的已验证
/// evidence，不暴露 secret、broker raw payload、adapter request 或 mutation command。
public struct ReleaseV0300DashboardCLIObservedShadowRunSurface: Equatable, Sendable {
    public static let panelID = "release-v0.30.0-observed-production-shadow-run"
    public static let validationAnchor =
        ReleaseV0300ObservedProductionShadowRun.validationAnchor
    public static let verificationAnchor =
        "GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE"
    public static let requiredAnchors =
        ReleaseV0300ObservedProductionShadowRun.requiredAnchors

    public let source: ReleaseV0300ObservedProductionShadowRun

    public init(source: ReleaseV0300ObservedProductionShadowRun = .deterministicFixture) {
        self.source = source
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "dashboardBoundary=read-only",
            "cliBoundary=run-status-evidence-validate-export-only"
        ] + source.statusLines + source.validationLines + source.boundaryLines + [
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "rawSecretVisible=false",
            "rawBrokerPayloadVisible=false",
            "adapterRequestVisible=false",
            "uiCanModifyRunEvidence=false"
        ]
    }

    public var boundaryHeld: Bool {
        source.boundaryHeld
            && source.observedRunAccepted
            && !source.dashboardTradingControlsEnabled
            && !source.orderFormEnabled
            && !source.liveCommandEnabled
            && !source.productionSubmitCancelReplaceEnabled
            && !source.automaticBrokerConnectionEnabled
    }
}
