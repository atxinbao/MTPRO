import Foundation

public struct ReleaseV0240DashboardCLIDualProductReadOnlyEvidenceSurface: Equatable, Sendable {
    // Spot + Futures unified read-only surface; no trading button, order form, live command, or production cutover.
    public static let panelID = "release-v0.24.0-dual-product-readonly-evidence"
    public static let validationAnchor = "TVM-RELEASE-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE"
    public static let verificationAnchor = "GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE"
    public static let requiredAnchors = [
        "GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT",
        "TVM-RELEASE-V0240-DUAL-PRODUCT-CONTRACT",
        "V0240-001-SPOT-FUTURES-DUAL-PRODUCT-UNIFICATION",
        "V0240-001-BLOCKED-BY-V0231-COMPLETION",
        "GH-1359-VERIFY-V0240-PRODUCT-AWARE-OMS-EVIDENCE",
        "V0240-002-UNIFIED-OMS-EVENT-EVIDENCE",
        "V0240-002-NO-FUTURES-ORDER-EXECUTION",
        "GH-1360-VERIFY-V0240-UNIFIED-PORTFOLIO-PROJECTION",
        "V0240-003-SPOT-CANARY-FUTURES-READONLY-PORTFOLIO",
        "V0240-003-FUTURES-READONLY-NOT-TRADING-AUTHORIZATION",
        "GH-1361-VERIFY-V0240-UNIFIED-RISK-READINESS",
        "V0240-004-SPOT-FUTURES-RISK-READINESS",
        "V0240-004-READINESS-NOT-PRODUCTION-RISK-APPROVAL",
        "GH-1362-VERIFY-V0240-DUAL-PRODUCT-RECONCILIATION",
        "V0240-005-SPOT-FUTURES-RECONCILIATION-FOUNDATION",
        "V0240-005-NO-BROKER-RECONCILIATION-RUNTIME",
        "GH-1363-VERIFY-V0240-DUAL-PRODUCT-FAILURE-MATRIX",
        "V0240-006-DUAL-PRODUCT-FAILURE-CLASSIFICATION",
        "V0240-006-FAIL-CLOSED-EVIDENCE",
        "GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE",
        "TVM-RELEASE-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE",
        "V0240-007-DASHBOARD-CLI-DUAL-PRODUCT-READONLY",
        "V0240-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "GH-1365-VERIFY-V0240-AGGREGATE-VALIDATION",
        "TVM-RELEASE-V0240-AGGREGATE-VALIDATION",
        "V0240-008-AGGREGATE-VALIDATION-SUITE",
        "V0240-008-STAGE-AUDIT-RELEASE-DOCS",
        "V0240-008-NO-PRODUCTION-CUTOVER"
    ]

    public let title: String
    public let products: [String]
    public let statusRows: [String]
    public let evidenceRows: [String]
    public let commandRows: [String]

    public init(
        title: String = "Spot + Futures unified read-only evidence foundation",
        products: [String] = ["binance/spot", "binance/usdsPerpetual"],
        statusRows: [String] = [
            "spotCanarySummaryVisible=true",
            "futuresReadOnlySummaryVisible=true",
            "portfolioProjectionMode=spot-canary-plus-futures-readonly",
            "riskReadinessMode=readiness-evidence-not-production-approval",
            "reconciliationMode=local-evidence-foundation"
        ],
        evidenceRows: [String] = [
            "unifiedOMSModel=product-aware-local-evidence",
            "failureClassification=fail-closed",
            "futuresReadOnlyNotTradingAuthorization=true",
            "brokerReconciliationRuntime=false"
        ],
        commandRows: [String] = [
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "dashboardTradingControlsEnabled=false",
            "productionCutoverAuthorized=false"
        ]
    ) {
        self.title = title
        self.products = products
        self.statusRows = statusRows
        self.evidenceRows = evidenceRows
        self.commandRows = commandRows
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "title=\(title)",
            "products=\(products.joined(separator: ","))",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))"
        ] + statusRows.map { "status=\($0)" }
            + evidenceRows.map { "evidence=\($0)" }
            + commandRows.map { "commandBoundary=\($0)" }
            + ["boundary=production cutover not authorized"]
    }
}
