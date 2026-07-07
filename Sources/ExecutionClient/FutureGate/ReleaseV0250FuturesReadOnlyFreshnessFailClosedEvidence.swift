import Foundation

public enum ReleaseV0250FuturesReadOnlyFailureClass: String, Codable, Equatable, Sendable, CaseIterable {
    case staleReadOnlyEvidence = "stale-readonly-evidence"
    case missingReadOnlyEvidence = "missing-readonly-evidence"
    case endpointBlocked = "endpoint-blocked"
    case capabilityMismatch = "capability-mismatch"
}

public struct ReleaseV0250FuturesReadOnlyFailureEvidence: Codable, Equatable, Sendable {
    public let failureClass: ReleaseV0250FuturesReadOnlyFailureClass
    public let blockedEvidence: String
    public let failClosed: Bool
    public let orderMutationEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool

    public init(
        failureClass: ReleaseV0250FuturesReadOnlyFailureClass,
        blockedEvidence: String,
        failClosed: Bool,
        orderMutationEnabled: Bool,
        listenKeyRuntimeEnabled: Bool
    ) {
        self.failureClass = failureClass
        self.blockedEvidence = blockedEvidence
        self.failClosed = failClosed
        self.orderMutationEnabled = orderMutationEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
    }

    public var evidenceHeld: Bool {
        blockedEvidence.hasPrefix("blocked:")
            && failClosed
            && orderMutationEnabled == false
            && listenKeyRuntimeEnabled == false
    }
}

public struct ReleaseV0250FuturesReadOnlyFreshnessFailClosedEvidence:
    Codable, Equatable, Sendable
{
    // v0.25.0 Futures remains read-only; freshness evidence never opens execution.
    public static let validationAnchor =
        "TVM-RELEASE-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE"
    public static let verificationAnchor =
        "GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE"
    public static let requiredAnchors = [
        "GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE",
        "TVM-RELEASE-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE",
        "V0250-004-FUTURES-READONLY-FRESHNESS",
        "V0250-004-STALE-FAILS-CLOSED",
        "V0250-004-MISSING-FAILS-CLOSED",
        "V0250-004-ENDPOINT-BLOCKED",
        "V0250-004-CAPABILITY-MISMATCH-BLOCKED",
        "V0250-004-NO-FUTURES-ORDER-MUTATION"
    ]

    public let release: String
    public let upstreamPolicyRelease: String
    public let venue: String
    public let productType: String
    public let environment: String
    public let freshnessWindowSeconds: Int
    public let latestEvidenceAgeSeconds: Int
    public let readOnlyEvidenceFresh: Bool
    public let readOnlyEvidenceRequired: Bool
    public let failureEvidence: [ReleaseV0250FuturesReadOnlyFailureEvidence]
    public let productionTradingEnabledByDefault: Bool
    public let futuresSubmitCancelReplaceEnabled: Bool
    public let leverageMutationEnabled: Bool
    public let marginModeMutationEnabled: Bool
    public let positionModeMutationEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let futuresBrokerAdapterEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamPolicyRelease: String,
        venue: String,
        productType: String,
        environment: String,
        freshnessWindowSeconds: Int,
        latestEvidenceAgeSeconds: Int,
        readOnlyEvidenceFresh: Bool,
        readOnlyEvidenceRequired: Bool,
        failureEvidence: [ReleaseV0250FuturesReadOnlyFailureEvidence],
        productionTradingEnabledByDefault: Bool,
        futuresSubmitCancelReplaceEnabled: Bool,
        leverageMutationEnabled: Bool,
        marginModeMutationEnabled: Bool,
        positionModeMutationEnabled: Bool,
        listenKeyRuntimeEnabled: Bool,
        futuresBrokerAdapterEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamPolicyRelease = upstreamPolicyRelease
        self.venue = venue
        self.productType = productType
        self.environment = environment
        self.freshnessWindowSeconds = freshnessWindowSeconds
        self.latestEvidenceAgeSeconds = latestEvidenceAgeSeconds
        self.readOnlyEvidenceFresh = readOnlyEvidenceFresh
        self.readOnlyEvidenceRequired = readOnlyEvidenceRequired
        self.failureEvidence = failureEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresSubmitCancelReplaceEnabled = futuresSubmitCancelReplaceEnabled
        self.leverageMutationEnabled = leverageMutationEnabled
        self.marginModeMutationEnabled = marginModeMutationEnabled
        self.positionModeMutationEnabled = positionModeMutationEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.futuresBrokerAdapterEnabled = futuresBrokerAdapterEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamPolicyRelease: "v0.25.0/V0250-002",
            venue: "binance",
            productType: "usdsPerpetual",
            environment: "productionShadow",
            freshnessWindowSeconds: 300,
            latestEvidenceAgeSeconds: 120,
            readOnlyEvidenceFresh: true,
            readOnlyEvidenceRequired: true,
            failureEvidence: [
                .init(
                    failureClass: .staleReadOnlyEvidence,
                    blockedEvidence: "blocked:futures-readonly-evidence-stale",
                    failClosed: true,
                    orderMutationEnabled: false,
                    listenKeyRuntimeEnabled: false
                ),
                .init(
                    failureClass: .missingReadOnlyEvidence,
                    blockedEvidence: "blocked:futures-readonly-evidence-missing",
                    failClosed: true,
                    orderMutationEnabled: false,
                    listenKeyRuntimeEnabled: false
                ),
                .init(
                    failureClass: .endpointBlocked,
                    blockedEvidence: "blocked:futures-production-endpoint-not-authorized",
                    failClosed: true,
                    orderMutationEnabled: false,
                    listenKeyRuntimeEnabled: false
                ),
                .init(
                    failureClass: .capabilityMismatch,
                    blockedEvidence: "blocked:futures-execution-capability-mismatch",
                    failClosed: true,
                    orderMutationEnabled: false,
                    listenKeyRuntimeEnabled: false
                )
            ],
            productionTradingEnabledByDefault: false,
            futuresSubmitCancelReplaceEnabled: false,
            leverageMutationEnabled: false,
            marginModeMutationEnabled: false,
            positionModeMutationEnabled: false,
            listenKeyRuntimeEnabled: false,
            futuresBrokerAdapterEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var evidenceHeld: Bool {
        release == "v0.25.0"
            && upstreamPolicyRelease == "v0.25.0/V0250-002"
            && venue == "binance"
            && productType == "usdsPerpetual"
            && environment == "productionShadow"
            && freshnessWindowSeconds == 300
            && latestEvidenceAgeSeconds <= freshnessWindowSeconds
            && readOnlyEvidenceFresh
            && readOnlyEvidenceRequired
            && Set(failureEvidence.map(\.failureClass)) == Set(ReleaseV0250FuturesReadOnlyFailureClass.allCases)
            && failureEvidence.allSatisfy(\.evidenceHeld)
            && forbiddenCapabilitiesClosed
            && boundaryHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresSubmitCancelReplaceEnabled == false
            && leverageMutationEnabled == false
            && marginModeMutationEnabled == false
            && positionModeMutationEnabled == false
            && listenKeyRuntimeEnabled == false
            && futuresBrokerAdapterEnabled == false
            && productionCutoverAuthorized == false
    }
}
