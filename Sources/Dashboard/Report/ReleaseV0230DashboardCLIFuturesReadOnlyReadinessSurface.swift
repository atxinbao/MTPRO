import Foundation

public struct ReleaseV0230DashboardCLIFuturesReadOnlyReadinessSurface: Equatable, Sendable {
    // Binance USD-M Futures read-only foundation; futuresOrderExecutionEnabled=false; production cutover not authorized.
    public static let panelID = "release-v0.23.0-futures-readonly-readiness"
    public static let validationAnchor = "TVM-RELEASE-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE"
    public static let verificationAnchor = "GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE"
    public static let requiredAnchors = [
        "GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT",
        "TVM-RELEASE-V0230-FUTURES-READONLY-CONTRACT",
        "V0230-001-BINANCE-USDM-FUTURES-READONLY-FOUNDATION",
        "V0230-001-NO-FUTURES-ORDER-EXECUTION",
        "GH-1342-VERIFY-V0230-FUTURES-PROFILE-ENDPOINT-ALLOWLIST",
        "V0230-002-BINANCE-USDM-FUTURES-PROFILE",
        "V0230-002-READ-ONLY-ENDPOINT-ALLOWLIST",
        "GH-1343-VERIFY-V0230-FUTURES-CREDENTIAL-REFERENCE-GATE",
        "V0230-003-CREDENTIAL-REFERENCE-ONLY",
        "V0230-003-SIGNED-READONLY-APPROVAL-GATE",
        "GH-1344-VERIFY-V0230-FUTURES-ACCOUNT-SNAPSHOT-REDACTION",
        "V0230-004-REDACTED-ACCOUNT-SNAPSHOT",
        "GH-1345-VERIFY-V0230-FUTURES-POSITION-MARGIN-LEVERAGE-READONLY",
        "V0230-005-POSITION-MARGIN-LEVERAGE-OBSERVED-STATE",
        "GH-1346-VERIFY-V0230-FUTURES-FUNDING-MARK-LIQUIDATION-READONLY",
        "V0230-006-FUNDING-MARK-LIQUIDATION-OBSERVATION",
        "GH-1347-VERIFY-V0230-FUTURES-TRANSPORT-ARTIFACT-FAILURE-CLASSIFICATION",
        "V0230-007-READONLY-TRANSPORT-ARTIFACT",
        "V0230-007-FAIL-CLOSED-FAILURE-CLASSIFICATION",
        "GH-1348-VERIFY-V0230-FUTURES-READONLY-RECONCILIATION",
        "V0230-008-LOCAL-REGISTRY-RECONCILIATION",
        "V0230-008-NO-BROKER-RECONCILIATION-RUNTIME",
        "GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE",
        "TVM-RELEASE-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE",
        "V0230-009-DASHBOARD-CLI-READONLY-FUTURES-READINESS",
        "V0230-009-NO-TRADING-COMMANDS",
        "V0230-009-NO-DASHBOARD-TRADING-CONTROLS",
        "GH-1350-VERIFY-V0230-AGGREGATE-VALIDATION",
        "TVM-RELEASE-V0230-AGGREGATE-VALIDATION",
        "V0230-010-AGGREGATE-VALIDATION-SUITE",
        "V0230-010-FUTURES-READONLY-FOUNDATION",
        "V0230-010-NO-FUTURES-ORDER-EXECUTION",
        "GH-1351-VERIFY-V0230-STAGE-AUDIT-RELEASE-DOCS",
        "V0230-011-STAGE-CODE-AUDIT",
        "V0230-011-NO-PRODUCTION-CUTOVER",
        "V0230-009-NO-PRODUCTION-CUTOVER"
    ]

    public let title: String
    public let venue: String
    public let productType: String
    public let statusRows: [String]
    public let failureRows: [String]
    public let commandRows: [String]

    public init(
        title: String = "Binance USD-M Futures read-only foundation",
        venue: String = "binance",
        productType: String = "usdsPerpetual",
        statusRows: [String] = [
            "accountSnapshotRedacted=true",
            "positionMarginLeverageReadOnly=true",
            "fundingMarkLiquidationReadOnly=true",
            "transportArtifactReadOnly=true",
            "registryReconciliation=read-only"
        ],
        failureRows: [String] = [
            "approval-missing",
            "credential-reference-missing",
            "endpoint-not-allowed",
            "signed-order-endpoint-rejected",
            "response-shape-mismatch",
            "reconciliation-mismatch"
        ],
        commandRows: [String] = [
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "submitCancelReplaceEnabled=false",
            "futuresOrderExecutionEnabled=false",
            "productionCutoverAuthorized=false"
        ]
    ) {
        self.title = title
        self.venue = venue
        self.productType = productType
        self.statusRows = statusRows
        self.failureRows = failureRows
        self.commandRows = commandRows
    }

    public var reportLines: [String] {
        [
            "panelID=\(Self.panelID)",
            "title=\(title)",
            "venue=\(venue)",
            "productType=\(productType)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))"
        ] + statusRows.map { "status=\($0)" }
            + failureRows.map { "failureClass=\($0);nextAction=operator-review" }
            + commandRows.map { "commandBoundary=\($0)" }
            + ["boundary=production cutover not authorized"]
    }
}
