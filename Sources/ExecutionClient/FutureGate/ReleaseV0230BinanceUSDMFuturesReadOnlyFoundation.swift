import Foundation

public enum ReleaseV0230FuturesReadOnlyFailureClass: String, Codable, Equatable, Sendable, CaseIterable {
    case approvalMissing = "approval-missing"
    case credentialReferenceMissing = "credential-reference-missing"
    case endpointNotAllowed = "endpoint-not-allowed"
    case signedOrderEndpointRejected = "signed-order-endpoint-rejected"
    case rateLimited = "rate-limited"
    case responseShapeMismatch = "response-shape-mismatch"
    case staleSnapshot = "stale-snapshot"
    case reconciliationMismatch = "reconciliation-mismatch"
}

public struct ReleaseV0230FuturesReadOnlyEndpointEvidence: Codable, Equatable, Sendable {
    public let name: String
    public let method: String
    public let path: String
    public let signed: Bool
    public let readOnly: Bool
    public let operatorApprovalRequired: Bool

    public init(
        name: String,
        method: String,
        path: String,
        signed: Bool,
        readOnly: Bool,
        operatorApprovalRequired: Bool
    ) {
        self.name = name
        self.method = method
        self.path = path
        self.signed = signed
        self.readOnly = readOnly
        self.operatorApprovalRequired = operatorApprovalRequired
    }
}

public struct ReleaseV0230FuturesReadOnlyFoundationEvidence: Codable, Equatable, Sendable {
    // Binance USD-M Futures read-only foundation; futuresOrderExecutionEnabled=false; production cutover not authorized.
    public static let cliCommand = "futures-readonly-readiness"
    public static let supportedActions = ["status", "endpoints", "failures", "reconciliation"]

    public static let validationAnchor = "TVM-RELEASE-V0230-FUTURES-READONLY-FOUNDATION"
    public static let verificationAnchor = "GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT"
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
        "V0230-011-NO-PRODUCTION-CUTOVER"
    ]

    public let release: String
    public let venue: String
    public let productType: String
    public let environment: String
    public let credentialReferenceOnly: Bool
    public let signedReadOnlyApprovalRequired: Bool
    public let accountSnapshotRedacted: Bool
    public let positionMarginLeverageReadOnly: Bool
    public let fundingMarkLiquidationReadOnly: Bool
    public let transportArtifactReadOnly: Bool
    public let reconciliationAgainstLocalRegistryOnly: Bool
    public let futuresOrderExecutionEnabled: Bool
    public let signedOrderEndpointEnabled: Bool
    public let orderMutationEndpointEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let okxEnabled: Bool
    public let boundaryHeld: Bool
    public let allowedEndpoints: [ReleaseV0230FuturesReadOnlyEndpointEvidence]
    public let forbiddenEndpoints: [String]
    public let failureClasses: [ReleaseV0230FuturesReadOnlyFailureClass]

    public init(
        release: String,
        venue: String,
        productType: String,
        environment: String,
        credentialReferenceOnly: Bool,
        signedReadOnlyApprovalRequired: Bool,
        accountSnapshotRedacted: Bool,
        positionMarginLeverageReadOnly: Bool,
        fundingMarkLiquidationReadOnly: Bool,
        transportArtifactReadOnly: Bool,
        reconciliationAgainstLocalRegistryOnly: Bool,
        futuresOrderExecutionEnabled: Bool,
        signedOrderEndpointEnabled: Bool,
        orderMutationEndpointEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        okxEnabled: Bool,
        boundaryHeld: Bool,
        allowedEndpoints: [ReleaseV0230FuturesReadOnlyEndpointEvidence],
        forbiddenEndpoints: [String],
        failureClasses: [ReleaseV0230FuturesReadOnlyFailureClass]
    ) {
        self.release = release
        self.venue = venue
        self.productType = productType
        self.environment = environment
        self.credentialReferenceOnly = credentialReferenceOnly
        self.signedReadOnlyApprovalRequired = signedReadOnlyApprovalRequired
        self.accountSnapshotRedacted = accountSnapshotRedacted
        self.positionMarginLeverageReadOnly = positionMarginLeverageReadOnly
        self.fundingMarkLiquidationReadOnly = fundingMarkLiquidationReadOnly
        self.transportArtifactReadOnly = transportArtifactReadOnly
        self.reconciliationAgainstLocalRegistryOnly = reconciliationAgainstLocalRegistryOnly
        self.futuresOrderExecutionEnabled = futuresOrderExecutionEnabled
        self.signedOrderEndpointEnabled = signedOrderEndpointEnabled
        self.orderMutationEndpointEnabled = orderMutationEndpointEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.okxEnabled = okxEnabled
        self.boundaryHeld = boundaryHeld
        self.allowedEndpoints = allowedEndpoints
        self.forbiddenEndpoints = forbiddenEndpoints
        self.failureClasses = failureClasses
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.23.0",
            venue: "binance",
            productType: "usdsPerpetual",
            environment: "productionShadowReadOnly",
            credentialReferenceOnly: true,
            signedReadOnlyApprovalRequired: true,
            accountSnapshotRedacted: true,
            positionMarginLeverageReadOnly: true,
            fundingMarkLiquidationReadOnly: true,
            transportArtifactReadOnly: true,
            reconciliationAgainstLocalRegistryOnly: true,
            futuresOrderExecutionEnabled: false,
            signedOrderEndpointEnabled: false,
            orderMutationEndpointEnabled: false,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            okxEnabled: false,
            boundaryHeld: true,
            allowedEndpoints: [
                .init(
                    name: "exchangeInfo",
                    method: "GET",
                    path: "/fapi/v1/exchangeInfo",
                    signed: false,
                    readOnly: true,
                    operatorApprovalRequired: false
                ),
                .init(
                    name: "time",
                    method: "GET",
                    path: "/fapi/v1/time",
                    signed: false,
                    readOnly: true,
                    operatorApprovalRequired: false
                ),
                .init(
                    name: "premiumIndex",
                    method: "GET",
                    path: "/fapi/v1/premiumIndex",
                    signed: false,
                    readOnly: true,
                    operatorApprovalRequired: false
                ),
                .init(
                    name: "fundingRate",
                    method: "GET",
                    path: "/fapi/v1/fundingRate",
                    signed: false,
                    readOnly: true,
                    operatorApprovalRequired: false
                ),
                .init(
                    name: "account",
                    method: "GET",
                    path: "/fapi/v2/account",
                    signed: true,
                    readOnly: true,
                    operatorApprovalRequired: true
                ),
                .init(
                    name: "positionRisk",
                    method: "GET",
                    path: "/fapi/v2/positionRisk",
                    signed: true,
                    readOnly: true,
                    operatorApprovalRequired: true
                )
            ],
            forbiddenEndpoints: [
                "POST /fapi/v1/order",
                "DELETE /fapi/v1/order",
                "PUT /fapi/v1/order",
                "POST /fapi/v1/listenKey",
                "POST /fapi/v1/leverage",
                "POST /fapi/v1/marginType",
                "POST /fapi/v1/positionSide/dual"
            ],
            failureClasses: ReleaseV0230FuturesReadOnlyFailureClass.allCases
        )
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance USD-M Futures read-only foundation",
            "venue=\(venue)",
            "productType=\(productType)",
            "environment=\(environment)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "credentialReferenceOnly=\(credentialReferenceOnly)",
            "signedReadOnlyApprovalRequired=\(signedReadOnlyApprovalRequired)",
            "accountSnapshotRedacted=\(accountSnapshotRedacted)",
            "positionMarginLeverageReadOnly=\(positionMarginLeverageReadOnly)",
            "fundingMarkLiquidationReadOnly=\(fundingMarkLiquidationReadOnly)",
            "transportArtifactReadOnly=\(transportArtifactReadOnly)",
            "reconciliationAgainstLocalRegistryOnly=\(reconciliationAgainstLocalRegistryOnly)",
            "futuresOrderExecutionEnabled=\(futuresOrderExecutionEnabled)",
            "signedOrderEndpointEnabled=\(signedOrderEndpointEnabled)",
            "orderMutationEndpointEnabled=\(orderMutationEndpointEnabled)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "productionCutoverStatus=production cutover not authorized",
            "okxEnabled=\(okxEnabled)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var endpointLines: [String] {
        allowedEndpoints.map {
            "allowedEndpoint=\($0.method) \($0.path);name=\($0.name);signed=\($0.signed);readOnly=\($0.readOnly);operatorApprovalRequired=\($0.operatorApprovalRequired)"
        } + forbiddenEndpoints.map { "forbiddenEndpoint=\($0)" }
    }

    public var failureLines: [String] {
        failureClasses.map { "failureClass=\($0.rawValue);failClosed=true" }
    }

    public var reconciliationLines: [String] {
        [
            "localRegistryVenue=binance",
            "localRegistryProduct=usdsPerpetual",
            "observedSnapshotNamespace=binance/usdsPerpetual/productionShadowReadOnly",
            "registryReconciliation=read-only",
            "mismatchAction=explain-without-command",
            "brokerReconciliationRuntime=false",
            "orderRepairCommandCreated=false",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0230FuturesReadOnlyCLIError.invalidArguments(
                expected: "\(cliCommand) status|endpoints|failures|reconciliation",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0230FuturesReadOnlyCLIError.invalidArguments(
                expected: "\(cliCommand) status|endpoints|failures|reconciliation",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = evidence.statusLines
        case "endpoints":
            actionLines = evidence.statusLines + evidence.endpointLines
        case "failures":
            actionLines = evidence.statusLines + evidence.failureLines
        case "reconciliation":
            actionLines = evidence.statusLines + evidence.reconciliationLines
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

public enum ReleaseV0230FuturesReadOnlyCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
