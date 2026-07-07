import Foundation

public enum ReleaseV0250RiskGateProduct: String, Codable, Equatable, Sendable, CaseIterable {
    case spot = "spot"
    case usdsPerpetual = "usdsPerpetual"
}

public enum ReleaseV0250RiskGateKind: String, Codable, Equatable, Sendable, CaseIterable {
    case capital = "capital"
    case exposure = "exposure"
    case notional = "notional"
    case readinessClassification = "readiness-classification"
}

public struct ReleaseV0250RiskGateProductEvidence: Codable, Equatable, Sendable {
    public let product: ReleaseV0250RiskGateProduct
    public let evidenceSource: String
    public let capitalGateHeld: Bool
    public let exposureGateHeld: Bool
    public let notionalGateHeld: Bool
    public let failClosedReadinessClassification: String
    public let accountBalanceReadEnabled: Bool
    public let brokerPositionReadEnabled: Bool
    public let marginReadEnabled: Bool
    public let leverageReadEnabled: Bool
    public let liveCommandAuthorizationEnabled: Bool

    public init(
        product: ReleaseV0250RiskGateProduct,
        evidenceSource: String,
        capitalGateHeld: Bool,
        exposureGateHeld: Bool,
        notionalGateHeld: Bool,
        failClosedReadinessClassification: String,
        accountBalanceReadEnabled: Bool,
        brokerPositionReadEnabled: Bool,
        marginReadEnabled: Bool,
        leverageReadEnabled: Bool,
        liveCommandAuthorizationEnabled: Bool
    ) {
        self.product = product
        self.evidenceSource = evidenceSource
        self.capitalGateHeld = capitalGateHeld
        self.exposureGateHeld = exposureGateHeld
        self.notionalGateHeld = notionalGateHeld
        self.failClosedReadinessClassification = failClosedReadinessClassification
        self.accountBalanceReadEnabled = accountBalanceReadEnabled
        self.brokerPositionReadEnabled = brokerPositionReadEnabled
        self.marginReadEnabled = marginReadEnabled
        self.leverageReadEnabled = leverageReadEnabled
        self.liveCommandAuthorizationEnabled = liveCommandAuthorizationEnabled
    }

    public var evidenceHeld: Bool {
        evidenceSource.hasPrefix("v0.25.0/V0250-")
            && capitalGateHeld
            && exposureGateHeld
            && notionalGateHeld
            && failClosedReadinessClassification == "fail-closed-readiness-only"
            && accountBalanceReadEnabled == false
            && brokerPositionReadEnabled == false
            && marginReadEnabled == false
            && leverageReadEnabled == false
            && liveCommandAuthorizationEnabled == false
    }
}

public struct ReleaseV0250UnifiedRiskCapitalExposureNotionalGateEvidence:
    Codable, Equatable, Sendable
{
    // v0.25.0 records gate evidence only; risk evidence is never a command authorization.
    public static let validationAnchor =
        "TVM-RELEASE-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE"
    public static let verificationAnchor =
        "GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE"
    public static let requiredAnchors = [
        "GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE",
        "TVM-RELEASE-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE",
        "V0250-005-UNIFIED-RISK-GATE",
        "V0250-005-CAPITAL-GATE",
        "V0250-005-EXPOSURE-GATE",
        "V0250-005-NOTIONAL-GATE",
        "V0250-005-FAIL-CLOSED-READINESS-CLASSIFICATION",
        "V0250-005-NO-LIVE-COMMAND-AUTHORIZATION"
    ]

    public let release: String
    public let upstreamPolicyRelease: String
    public let spotEvidenceRelease: String
    public let futuresEvidenceRelease: String
    public let gateKinds: [ReleaseV0250RiskGateKind]
    public let productEvidence: [ReleaseV0250RiskGateProductEvidence]
    public let productionTradingEnabledByDefault: Bool
    public let riskEvidenceCanAuthorizeLiveCommand: Bool
    public let accountBalanceReadEnabled: Bool
    public let brokerPositionReadEnabled: Bool
    public let marginReadEnabled: Bool
    public let leverageReadEnabled: Bool
    public let orderMutationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamPolicyRelease: String,
        spotEvidenceRelease: String,
        futuresEvidenceRelease: String,
        gateKinds: [ReleaseV0250RiskGateKind],
        productEvidence: [ReleaseV0250RiskGateProductEvidence],
        productionTradingEnabledByDefault: Bool,
        riskEvidenceCanAuthorizeLiveCommand: Bool,
        accountBalanceReadEnabled: Bool,
        brokerPositionReadEnabled: Bool,
        marginReadEnabled: Bool,
        leverageReadEnabled: Bool,
        orderMutationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamPolicyRelease = upstreamPolicyRelease
        self.spotEvidenceRelease = spotEvidenceRelease
        self.futuresEvidenceRelease = futuresEvidenceRelease
        self.gateKinds = gateKinds
        self.productEvidence = productEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.riskEvidenceCanAuthorizeLiveCommand = riskEvidenceCanAuthorizeLiveCommand
        self.accountBalanceReadEnabled = accountBalanceReadEnabled
        self.brokerPositionReadEnabled = brokerPositionReadEnabled
        self.marginReadEnabled = marginReadEnabled
        self.leverageReadEnabled = leverageReadEnabled
        self.orderMutationEnabled = orderMutationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamPolicyRelease: "v0.25.0/V0250-002",
            spotEvidenceRelease: "v0.25.0/V0250-003",
            futuresEvidenceRelease: "v0.25.0/V0250-004",
            gateKinds: ReleaseV0250RiskGateKind.allCases,
            productEvidence: [
                .init(
                    product: .spot,
                    evidenceSource: "v0.25.0/V0250-003",
                    capitalGateHeld: true,
                    exposureGateHeld: true,
                    notionalGateHeld: true,
                    failClosedReadinessClassification: "fail-closed-readiness-only",
                    accountBalanceReadEnabled: false,
                    brokerPositionReadEnabled: false,
                    marginReadEnabled: false,
                    leverageReadEnabled: false,
                    liveCommandAuthorizationEnabled: false
                ),
                .init(
                    product: .usdsPerpetual,
                    evidenceSource: "v0.25.0/V0250-004",
                    capitalGateHeld: true,
                    exposureGateHeld: true,
                    notionalGateHeld: true,
                    failClosedReadinessClassification: "fail-closed-readiness-only",
                    accountBalanceReadEnabled: false,
                    brokerPositionReadEnabled: false,
                    marginReadEnabled: false,
                    leverageReadEnabled: false,
                    liveCommandAuthorizationEnabled: false
                )
            ],
            productionTradingEnabledByDefault: false,
            riskEvidenceCanAuthorizeLiveCommand: false,
            accountBalanceReadEnabled: false,
            brokerPositionReadEnabled: false,
            marginReadEnabled: false,
            leverageReadEnabled: false,
            orderMutationEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var evidenceHeld: Bool {
        release == "v0.25.0"
            && upstreamPolicyRelease == "v0.25.0/V0250-002"
            && spotEvidenceRelease == "v0.25.0/V0250-003"
            && futuresEvidenceRelease == "v0.25.0/V0250-004"
            && Set(gateKinds) == Set(ReleaseV0250RiskGateKind.allCases)
            && Set(productEvidence.map(\.product)) == Set(ReleaseV0250RiskGateProduct.allCases)
            && productEvidence.allSatisfy(\.evidenceHeld)
            && forbiddenCapabilitiesClosed
            && boundaryHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && riskEvidenceCanAuthorizeLiveCommand == false
            && accountBalanceReadEnabled == false
            && brokerPositionReadEnabled == false
            && marginReadEnabled == false
            && leverageReadEnabled == false
            && orderMutationEnabled == false
            && productionCutoverAuthorized == false
    }
}
