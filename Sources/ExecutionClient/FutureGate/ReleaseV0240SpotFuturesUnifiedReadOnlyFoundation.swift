import Foundation

public enum ReleaseV0240DualProductFailureClass: String, Codable, Equatable, Sendable, CaseIterable {
    case productScopeMismatch = "product-scope-mismatch"
    case spotCanaryEvidenceMissing = "spot-canary-evidence-missing"
    case futuresReadOnlyEvidenceMissing = "futures-readonly-evidence-missing"
    case riskGateNotSatisfied = "risk-gate-not-satisfied"
    case reconciliationMismatch = "reconciliation-mismatch"
    case productionCutoverAttempted = "production-cutover-attempted"
    case dashboardCommandAttempted = "dashboard-command-attempted"
}

public struct ReleaseV0240ProductEvidence: Codable, Equatable, Sendable {
    public let venue: String
    public let productType: String
    public let evidenceMode: String
    public let sourceRelease: String
    public let orderExecutionEnabled: Bool
    public let readOnlyEvidence: Bool

    public init(
        venue: String,
        productType: String,
        evidenceMode: String,
        sourceRelease: String,
        orderExecutionEnabled: Bool,
        readOnlyEvidence: Bool
    ) {
        self.venue = venue
        self.productType = productType
        self.evidenceMode = evidenceMode
        self.sourceRelease = sourceRelease
        self.orderExecutionEnabled = orderExecutionEnabled
        self.readOnlyEvidence = readOnlyEvidence
    }
}

public struct ReleaseV0240SpotFuturesUnifiedReadOnlyFoundationEvidence: Codable, Equatable, Sendable {
    // Spot + Futures unified evidence foundation; Futures execution and production cutover remain disabled.
    public static let cliCommand = "dual-product-readonly-readiness"
    public static let supportedActions = [
        "status",
        "oms",
        "portfolio",
        "risk",
        "reconciliation",
        "failures",
        "dashboard"
    ]

    public static let validationAnchor = "TVM-RELEASE-V0240-SPOT-FUTURES-UNIFIED-READONLY-FOUNDATION"
    public static let verificationAnchor = "GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT"
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

    public let release: String
    public let prerequisitePatchRelease: String
    public let productEvidence: [ReleaseV0240ProductEvidence]
    public let unifiedOMSModel: String
    public let portfolioProjectionMode: String
    public let riskReadinessMode: String
    public let reconciliationMode: String
    public let futuresOrderExecutionEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let brokerReconciliationRuntimeEnabled: Bool
    public let boundaryHeld: Bool
    public let failureClasses: [ReleaseV0240DualProductFailureClass]

    public init(
        release: String,
        prerequisitePatchRelease: String,
        productEvidence: [ReleaseV0240ProductEvidence],
        unifiedOMSModel: String,
        portfolioProjectionMode: String,
        riskReadinessMode: String,
        reconciliationMode: String,
        futuresOrderExecutionEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        brokerReconciliationRuntimeEnabled: Bool,
        boundaryHeld: Bool,
        failureClasses: [ReleaseV0240DualProductFailureClass]
    ) {
        self.release = release
        self.prerequisitePatchRelease = prerequisitePatchRelease
        self.productEvidence = productEvidence
        self.unifiedOMSModel = unifiedOMSModel
        self.portfolioProjectionMode = portfolioProjectionMode
        self.riskReadinessMode = riskReadinessMode
        self.reconciliationMode = reconciliationMode
        self.futuresOrderExecutionEnabled = futuresOrderExecutionEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.brokerReconciliationRuntimeEnabled = brokerReconciliationRuntimeEnabled
        self.boundaryHeld = boundaryHeld
        self.failureClasses = failureClasses
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.24.0",
            prerequisitePatchRelease: "v0.23.1",
            productEvidence: [
                .init(
                    venue: "binance",
                    productType: "spot",
                    evidenceMode: "controlled-canary-evidence",
                    sourceRelease: "v0.22.0",
                    orderExecutionEnabled: true,
                    readOnlyEvidence: false
                ),
                .init(
                    venue: "binance",
                    productType: "usdsPerpetual",
                    evidenceMode: "futures-readonly-evidence",
                    sourceRelease: "v0.23.0",
                    orderExecutionEnabled: false,
                    readOnlyEvidence: true
                )
            ],
            unifiedOMSModel: "product-aware-local-evidence",
            portfolioProjectionMode: "spot-canary-plus-futures-readonly",
            riskReadinessMode: "readiness-evidence-not-production-approval",
            reconciliationMode: "local-evidence-foundation",
            futuresOrderExecutionEnabled: false,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            brokerReconciliationRuntimeEnabled: false,
            boundaryHeld: true,
            failureClasses: ReleaseV0240DualProductFailureClass.allCases
        )
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Spot + Futures unified OMS / Portfolio / Risk / Reconciliation foundation",
            "prerequisitePatchRelease=\(prerequisitePatchRelease)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "unifiedOMSModel=\(unifiedOMSModel)",
            "portfolioProjectionMode=\(portfolioProjectionMode)",
            "riskReadinessMode=\(riskReadinessMode)",
            "reconciliationMode=\(reconciliationMode)",
            "futuresOrderExecutionEnabled=\(futuresOrderExecutionEnabled)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "brokerReconciliationRuntimeEnabled=\(brokerReconciliationRuntimeEnabled)",
            "boundaryHeld=\(boundaryHeld)"
        ] + productEvidence.map {
            "productEvidence=venue:\($0.venue);productType:\($0.productType);mode:\($0.evidenceMode);sourceRelease:\($0.sourceRelease);orderExecutionEnabled:\($0.orderExecutionEnabled);readOnlyEvidence:\($0.readOnlyEvidence)"
        }
    }

    public var omsLines: [String] {
        [
            "omsEventModel=product-aware-local-evidence",
            "spotSource=controlled-canary-submit-status-cancel-oms-reconciliation",
            "futuresSource=readonly-account-position-transport-registry",
            "futuresOrderLifecycleCreated=false",
            "boundary=Futures execution remains disabled"
        ]
    }

    public var portfolioLines: [String] {
        [
            "portfolioProjection=spot-canary-plus-futures-readonly",
            "spotProjectionSource=canary-oms-reconciliation",
            "futuresProjectionSource=readonly-position-margin-leverage",
            "futuresReadOnlyNotTradingAuthorization=true"
        ]
    }

    public var riskLines: [String] {
        [
            "riskReadiness=spot-hard-limits-plus-futures-margin-leverage-liquidation-readiness",
            "spotRiskSource=hard-limit-kill-switch-no-trade",
            "futuresRiskSource=margin-leverage-liquidation-risk-readiness",
            "productionRiskApproval=false",
            "readinessNotProductionRiskApproval=true"
        ]
    }

    public var reconciliationLines: [String] {
        [
            "reconciliation=local-evidence-foundation",
            "spotReconciliationSource=canary-oms-transport-rollback",
            "futuresReconciliationSource=readonly-transport-registry-account-position",
            "brokerReconciliationRuntime=false",
            "repairCommandCreated=false"
        ]
    }

    public var failureLines: [String] {
        failureClasses.map { "failureClass=\($0.rawValue);failClosed=true" }
    }

    public var dashboardLines: [String] {
        [
            "dashboardSurface=dual-product-readonly",
            "spotCanarySummaryVisible=true",
            "futuresReadOnlySummaryVisible=true",
            "unifiedPortfolioRiskReconciliationVisible=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0240DualProductReadOnlyCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0240DualProductReadOnlyCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = evidence.statusLines
        case "oms":
            actionLines = evidence.statusLines + evidence.omsLines
        case "portfolio":
            actionLines = evidence.statusLines + evidence.portfolioLines
        case "risk":
            actionLines = evidence.statusLines + evidence.riskLines
        case "reconciliation":
            actionLines = evidence.statusLines + evidence.reconciliationLines
        case "failures":
            actionLines = evidence.statusLines + evidence.failureLines
        case "dashboard":
            actionLines = evidence.statusLines + evidence.dashboardLines
        default:
            actionLines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only",
            "tradingCommandCreated=false"
        ] + actionLines).joined(separator: "\n")
    }
}

public enum ReleaseV0240DualProductReadOnlyCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
