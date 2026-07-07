import Foundation

public struct ReleaseV0250OperatorReadinessSurface: Codable, Equatable, Sendable {
    // v0.25.0 operator surface is read-only; it exposes evidence, not trading controls.
    public static let cliCommand = "dual-product-operator-readiness"
    public static let supportedActions = [
        "status",
        "evidence",
        "boundaries"
    ]
    public static let validationAnchor =
        "TVM-RELEASE-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE"
    public static let verificationAnchor =
        "GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE"
    public static let requiredAnchors = [
        "GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE",
        "TVM-RELEASE-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE",
        "V0250-007-DASHBOARD-CLI-OPERATOR-READINESS",
        "V0250-007-ENVIRONMENT-CREDENTIAL-APPROVAL-EVIDENCE",
        "V0250-007-RISK-ROLLBACK-NOTRADE-EVIDENCE",
        "V0250-007-READ-ONLY-SURFACE",
        "V0250-007-NO-TRADING-BUTTON",
        "V0250-007-NO-ORDER-FORM",
        "V0250-007-NO-LIVE-COMMAND"
    ]

    public let release: String
    public let upstreamIssueIDs: [String]
    public let products: [String]
    public let environmentRows: [String]
    public let credentialRows: [String]
    public let approvalRows: [String]
    public let riskRows: [String]
    public let rollbackRows: [String]
    public let noTradeRows: [String]
    public let productionTradingEnabledByDefault: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let liveProConsoleEnabled: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamIssueIDs: [String],
        products: [String],
        environmentRows: [String],
        credentialRows: [String],
        approvalRows: [String],
        riskRows: [String],
        rollbackRows: [String],
        noTradeRows: [String],
        productionTradingEnabledByDefault: Bool,
        dashboardTradingControlsEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandVisible: Bool,
        liveProConsoleEnabled: Bool,
        submitCancelReplaceEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamIssueIDs = upstreamIssueIDs
        self.products = products
        self.environmentRows = environmentRows
        self.credentialRows = credentialRows
        self.approvalRows = approvalRows
        self.riskRows = riskRows
        self.rollbackRows = rollbackRows
        self.noTradeRows = noTradeRows
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.liveProConsoleEnabled = liveProConsoleEnabled
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamIssueIDs: ["V0250-002", "V0250-003", "V0250-004", "V0250-005", "V0250-006"],
            products: ["binance/spot", "binance/usdsPerpetual"],
            environmentRows: [
                "environmentIsolation=v0.25.0/V0250-002",
                "productionTradingEnabledByDefault=false",
                "productionEndpointConnectionAuthorized=false",
                "brokerEndpointConnectionAuthorized=false"
            ],
            credentialRows: [
                "credentialPolicy=reference-only",
                "productionSecretRead=false",
                "credentialValueStored=false"
            ],
            approvalRows: [
                "spotCanaryApprovalEvidence=v0.25.0/V0250-003",
                "futuresReadOnlyApprovalEvidence=v0.25.0/V0250-004"
            ],
            riskRows: [
                "riskCapitalExposureNotionalGate=v0.25.0/V0250-005",
                "riskEvidenceCanAuthorizeLiveCommand=false"
            ],
            rollbackRows: [
                "incidentRollbackNoTradeKillSwitch=v0.25.0/V0250-006",
                "operationalControlRuntimeEnabled=false"
            ],
            noTradeRows: [
                "noTradeStateEvidence=readiness-only",
                "submitCancelReplaceEnabled=false"
            ],
            productionTradingEnabledByDefault: false,
            dashboardTradingControlsEnabled: false,
            tradingButtonVisible: false,
            orderFormVisible: false,
            liveCommandVisible: false,
            liveProConsoleEnabled: false,
            submitCancelReplaceEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "surface=dual-product-operator-readiness-read-only",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "products=\(products.joined(separator: ","))",
            "upstreamIssueIDs=\(upstreamIssueIDs.joined(separator: ","))",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "tradingButtonVisible=\(tradingButtonVisible)",
            "orderFormVisible=\(orderFormVisible)",
            "liveCommandVisible=\(liveCommandVisible)",
            "liveProConsoleEnabled=\(liveProConsoleEnabled)",
            "submitCancelReplaceEnabled=\(submitCancelReplaceEnabled)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(evidenceHeld)"
        ]
    }

    public var evidenceLines: [String] {
        environmentRows.map { "environment=\($0)" }
            + credentialRows.map { "credential=\($0)" }
            + approvalRows.map { "approval=\($0)" }
            + riskRows.map { "risk=\($0)" }
            + rollbackRows.map { "rollback=\($0)" }
            + noTradeRows.map { "noTrade=\($0)" }
    }

    public var boundaryLines: [String] {
        [
            "readOnlySurface=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "liveProConsoleEnabled=false",
            "submitCancelReplaceEnabled=false",
            "productionCutoverAuthorized=false"
        ]
    }

    public var reportLines: [String] {
        statusLines + evidenceLines + boundaryLines
    }

    public var evidenceHeld: Bool {
        release == "v0.25.0"
            && upstreamIssueIDs == ["V0250-002", "V0250-003", "V0250-004", "V0250-005", "V0250-006"]
            && products == ["binance/spot", "binance/usdsPerpetual"]
            && productionTradingEnabledByDefault == false
            && dashboardTradingControlsEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && liveProConsoleEnabled == false
            && submitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
            && boundaryHeld
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0250OperatorReadinessSurfaceCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0250OperatorReadinessSurfaceCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let surface = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = surface.statusLines
        case "evidence":
            actionLines = surface.statusLines + surface.evidenceLines
        case "boundaries":
            actionLines = surface.statusLines + surface.boundaryLines
        default:
            actionLines = surface.statusLines
        }

        return (["command=\(cliCommand)", "action=\(action)"] + actionLines).joined(separator: "\n")
    }
}

public enum ReleaseV0250OperatorReadinessSurfaceCLIError:
    Error, Equatable, CustomStringConvertible, Sendable
{
    case invalidArguments(expected: String, actual: String)

    public var description: String {
        switch self {
        case let .invalidArguments(expected, actual):
            "ReleaseV0250OperatorReadinessSurfaceCLIError expected \(expected), actual \(actual)"
        }
    }
}
