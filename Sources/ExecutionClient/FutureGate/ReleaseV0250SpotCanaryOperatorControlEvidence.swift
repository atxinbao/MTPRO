import Foundation

public enum ReleaseV0250SpotCanaryControlEvidenceKind: String, Codable, Equatable, Sendable, CaseIterable {
    case operatorConfirmation = "operator-confirmation"
    case idempotency = "idempotency"
    case sizeCap = "size-cap"
    case rollback = "rollback"
    case transportAlignment = "v0.22-transport-alignment"
    case vocabularyAlignment = "v0.24-dual-product-vocabulary"
}

public struct ReleaseV0250SpotCanaryControlEvidenceItem: Codable, Equatable, Sendable {
    public let kind: ReleaseV0250SpotCanaryControlEvidenceKind
    public let evidenceID: String
    public let status: String
    public let requiredBeforeSubmit: Bool
    public let blockedEvidence: String

    public init(
        kind: ReleaseV0250SpotCanaryControlEvidenceKind,
        evidenceID: String,
        status: String,
        requiredBeforeSubmit: Bool,
        blockedEvidence: String
    ) {
        self.kind = kind
        self.evidenceID = evidenceID
        self.status = status
        self.requiredBeforeSubmit = requiredBeforeSubmit
        self.blockedEvidence = blockedEvidence
    }

    public var evidenceHeld: Bool {
        status == "held"
            && requiredBeforeSubmit
            && blockedEvidence.hasPrefix("blocked:")
    }
}

public struct ReleaseV0250SpotCanaryOperatorControlEvidence: Codable, Equatable, Sendable {
    // v0.25.0 只加固 Spot canary evidence chain，不扩大 production trading scope。
    public static let validationAnchor =
        "TVM-RELEASE-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE"
    public static let verificationAnchor =
        "GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE"
    public static let requiredAnchors = [
        "GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE",
        "TVM-RELEASE-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE",
        "V0250-003-SPOT-CANARY-OPERATOR-CONFIRMATION",
        "V0250-003-IDEMPOTENCY-EVIDENCE",
        "V0250-003-SIZE-CAP-EVIDENCE",
        "V0250-003-ROLLBACK-EVIDENCE",
        "V0250-003-NO-UNRESTRICTED-LIVE-TRADING"
    ]

    public let release: String
    public let upstreamPolicyRelease: String
    public let spotTransportEvidenceSource: String
    public let dualProductVocabularySource: String
    public let venue: String
    public let productType: String
    public let canarySymbolAllowlist: [String]
    public let maxNotionalUSDT: Decimal
    public let maxBaseQuantity: Decimal
    public let operatorConfirmationProofRequired: Bool
    public let idempotencyKeyRequired: Bool
    public let rollbackEvidenceRequired: Bool
    public let evidenceItems: [ReleaseV0250SpotCanaryControlEvidenceItem]
    public let productionTradingEnabledByDefault: Bool
    public let unrestrictedLiveTradingAuthorized: Bool
    public let defaultOrderMutationEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamPolicyRelease: String,
        spotTransportEvidenceSource: String,
        dualProductVocabularySource: String,
        venue: String,
        productType: String,
        canarySymbolAllowlist: [String],
        maxNotionalUSDT: Decimal,
        maxBaseQuantity: Decimal,
        operatorConfirmationProofRequired: Bool,
        idempotencyKeyRequired: Bool,
        rollbackEvidenceRequired: Bool,
        evidenceItems: [ReleaseV0250SpotCanaryControlEvidenceItem],
        productionTradingEnabledByDefault: Bool,
        unrestrictedLiveTradingAuthorized: Bool,
        defaultOrderMutationEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamPolicyRelease = upstreamPolicyRelease
        self.spotTransportEvidenceSource = spotTransportEvidenceSource
        self.dualProductVocabularySource = dualProductVocabularySource
        self.venue = venue
        self.productType = productType
        self.canarySymbolAllowlist = canarySymbolAllowlist
        self.maxNotionalUSDT = maxNotionalUSDT
        self.maxBaseQuantity = maxBaseQuantity
        self.operatorConfirmationProofRequired = operatorConfirmationProofRequired
        self.idempotencyKeyRequired = idempotencyKeyRequired
        self.rollbackEvidenceRequired = rollbackEvidenceRequired
        self.evidenceItems = evidenceItems
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.unrestrictedLiveTradingAuthorized = unrestrictedLiveTradingAuthorized
        self.defaultOrderMutationEnabled = defaultOrderMutationEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamPolicyRelease: "v0.25.0/V0250-002",
            spotTransportEvidenceSource: "v0.22.0",
            dualProductVocabularySource: "v0.24.0",
            venue: "binance",
            productType: "spot",
            canarySymbolAllowlist: ["BTCUSDT"],
            maxNotionalUSDT: Decimal(10),
            maxBaseQuantity: Decimal(string: "0.001") ?? 0,
            operatorConfirmationProofRequired: true,
            idempotencyKeyRequired: true,
            rollbackEvidenceRequired: true,
            evidenceItems: [
                .init(
                    kind: .operatorConfirmation,
                    evidenceID: "v0250-spot-canary-operator-confirmation-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:missing-operator-confirmation"
                ),
                .init(
                    kind: .idempotency,
                    evidenceID: "v0250-spot-canary-idempotency-key-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:missing-or-reused-idempotency-key"
                ),
                .init(
                    kind: .sizeCap,
                    evidenceID: "v0250-spot-canary-size-cap-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:notional-or-quantity-exceeds-canary-cap"
                ),
                .init(
                    kind: .rollback,
                    evidenceID: "v0250-spot-canary-rollback-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:rollback-evidence-missing"
                ),
                .init(
                    kind: .transportAlignment,
                    evidenceID: "v0250-spot-canary-v022-transport-alignment-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:v022-transport-evidence-missing"
                ),
                .init(
                    kind: .vocabularyAlignment,
                    evidenceID: "v0250-spot-canary-v024-dual-product-vocabulary-proof",
                    status: "held",
                    requiredBeforeSubmit: true,
                    blockedEvidence: "blocked:v024-dual-product-vocabulary-missing"
                )
            ],
            productionTradingEnabledByDefault: false,
            unrestrictedLiveTradingAuthorized: false,
            defaultOrderMutationEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var evidenceHeld: Bool {
        release == "v0.25.0"
            && upstreamPolicyRelease == "v0.25.0/V0250-002"
            && spotTransportEvidenceSource == "v0.22.0"
            && dualProductVocabularySource == "v0.24.0"
            && venue == "binance"
            && productType == "spot"
            && canarySymbolAllowlist == ["BTCUSDT"]
            && maxNotionalUSDT == Decimal(10)
            && maxBaseQuantity == (Decimal(string: "0.001") ?? 0)
            && operatorConfirmationProofRequired
            && idempotencyKeyRequired
            && rollbackEvidenceRequired
            && Set(evidenceItems.map(\.kind)) == Set(ReleaseV0250SpotCanaryControlEvidenceKind.allCases)
            && evidenceItems.allSatisfy(\.evidenceHeld)
            && forbiddenCapabilitiesClosed
            && boundaryHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && unrestrictedLiveTradingAuthorized == false
            && defaultOrderMutationEnabled == false
            && dashboardTradingControlsEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && productionCutoverAuthorized == false
    }
}
