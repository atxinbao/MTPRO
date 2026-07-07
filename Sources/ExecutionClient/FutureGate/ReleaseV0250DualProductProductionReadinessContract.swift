import Foundation

public enum ReleaseV0250DualProductReadinessRole: String, Codable, Equatable, Sendable, CaseIterable {
    case spotControlledCanaryEvidence = "spot-controlled-canary-evidence"
    case futuresReadOnlyEvidence = "futures-readonly-evidence"
}

public struct ReleaseV0250ProductReadinessEvidence: Codable, Equatable, Sendable {
    public let venue: String
    public let productType: String
    public let readinessRole: ReleaseV0250DualProductReadinessRole
    public let sourceRelease: String
    public let manualApprovalRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let orderMutationEnabled: Bool
    public let readOnlyOnly: Bool

    public init(
        venue: String,
        productType: String,
        readinessRole: ReleaseV0250DualProductReadinessRole,
        sourceRelease: String,
        manualApprovalRequired: Bool,
        productionTradingEnabledByDefault: Bool,
        orderMutationEnabled: Bool,
        readOnlyOnly: Bool
    ) {
        self.venue = venue
        self.productType = productType
        self.readinessRole = readinessRole
        self.sourceRelease = sourceRelease
        self.manualApprovalRequired = manualApprovalRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.orderMutationEnabled = orderMutationEnabled
        self.readOnlyOnly = readOnlyOnly
    }
}

public struct ReleaseV0250DualProductProductionReadinessContract: Codable, Equatable, Sendable {
    // v0.25.0 只定义 dual-product readiness / hardening 入口合同，不授权 production cutover。
    public static let cliCommand = "dual-product-production-readiness"
    public static let supportedActions = [
        "status",
        "products",
        "boundaries"
    ]

    public static let validationAnchor = "TVM-RELEASE-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT"
    public static let verificationAnchor = "GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT"
    public static let requiredAnchors = [
        "GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT",
        "TVM-RELEASE-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT",
        "V0250-001-DUAL-PRODUCT-PRODUCTION-READINESS",
        "V0250-001-NO-DEFAULT-TRADING",
        "V0250-001-SPOT-CANARY-EVIDENCE-NOT-CUTOVER",
        "V0250-001-FUTURES-READONLY-EVIDENCE-NOT-EXECUTION",
        "V0250-001-BLOCKED-BY-V0241-COMPLETION"
    ]

    public let release: String
    public let prerequisitePatchRelease: String
    public let productEvidence: [ReleaseV0250ProductReadinessEvidence]
    public let readinessVocabulary: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let futuresSubmitCancelReplaceEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let dryRunOrBlockedEvidenceRequired: Bool
    public let manualApprovalRequired: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        prerequisitePatchRelease: String,
        productEvidence: [ReleaseV0250ProductReadinessEvidence],
        readinessVocabulary: [String],
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        futuresSubmitCancelReplaceEnabled: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        dryRunOrBlockedEvidenceRequired: Bool,
        manualApprovalRequired: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.prerequisitePatchRelease = prerequisitePatchRelease
        self.productEvidence = productEvidence
        self.readinessVocabulary = readinessVocabulary
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.futuresSubmitCancelReplaceEnabled = futuresSubmitCancelReplaceEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.dryRunOrBlockedEvidenceRequired = dryRunOrBlockedEvidenceRequired
        self.manualApprovalRequired = manualApprovalRequired
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            prerequisitePatchRelease: "v0.24.1",
            productEvidence: [
                .init(
                    venue: "binance",
                    productType: "spot",
                    readinessRole: .spotControlledCanaryEvidence,
                    sourceRelease: "v0.22.0",
                    manualApprovalRequired: true,
                    productionTradingEnabledByDefault: false,
                    orderMutationEnabled: false,
                    readOnlyOnly: false
                ),
                .init(
                    venue: "binance",
                    productType: "usdsPerpetual",
                    readinessRole: .futuresReadOnlyEvidence,
                    sourceRelease: "v0.23.0",
                    manualApprovalRequired: true,
                    productionTradingEnabledByDefault: false,
                    orderMutationEnabled: false,
                    readOnlyOnly: true
                )
            ],
            readinessVocabulary: [
                "dual-product-readiness",
                "no-default-trading",
                "manual-approval-required",
                "dry-run-or-blocked-evidence",
                "spot-canary-evidence",
                "futures-readonly-evidence"
            ],
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            futuresSubmitCancelReplaceEnabled: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            dryRunOrBlockedEvidenceRequired: true,
            manualApprovalRequired: true,
            boundaryHeld: true
        )
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance dual-product production readiness / canary hardening contract",
            "prerequisitePatchRelease=\(prerequisitePatchRelease)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "readinessVocabulary=\(readinessVocabulary.joined(separator: ","))",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "futuresSubmitCancelReplaceEnabled=\(futuresSubmitCancelReplaceEnabled)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "dryRunOrBlockedEvidenceRequired=\(dryRunOrBlockedEvidenceRequired)",
            "manualApprovalRequired=\(manualApprovalRequired)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var productLines: [String] {
        productEvidence.map {
            "productEvidence=venue:\($0.venue);productType:\($0.productType);role:\($0.readinessRole.rawValue);sourceRelease:\($0.sourceRelease);manualApprovalRequired:\($0.manualApprovalRequired);productionTradingEnabledByDefault:\($0.productionTradingEnabledByDefault);orderMutationEnabled:\($0.orderMutationEnabled);readOnlyOnly:\($0.readOnlyOnly)"
        }
    }

    public var boundaryLines: [String] {
        [
            "spotCanaryEvidenceNotCutover=true",
            "futuresReadOnlyEvidenceNotExecution=true",
            "productionSecretReadAuthorized=false",
            "productionEndpointConnectionAuthorized=false",
            "brokerEndpointConnectionAuthorized=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "unrestrictedLiveTradingAuthorized=false"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0250DualProductProductionReadinessCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0250DualProductProductionReadinessCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = evidence.statusLines
        case "products":
            actionLines = evidence.statusLines + evidence.productLines
        case "boundaries":
            actionLines = evidence.statusLines + evidence.boundaryLines
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

public enum ReleaseV0250DualProductProductionReadinessCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
