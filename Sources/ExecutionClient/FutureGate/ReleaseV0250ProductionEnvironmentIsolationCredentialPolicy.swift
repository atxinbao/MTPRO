import Foundation

public enum ReleaseV0250EnvironmentIsolationProfileRole: String, Codable, Equatable, Sendable, CaseIterable {
    case sandboxDryRun = "sandbox-dry-run"
    case spotCanaryReadiness = "spot-canary-readiness"
    case futuresReadOnlyReadiness = "futures-readonly-readiness"
    case blockedProductionLiveDefault = "blocked-production-live-default"
}

public struct ReleaseV0250EnvironmentIsolationProfileEvidence: Codable, Equatable, Sendable {
    public let profileRole: ReleaseV0250EnvironmentIsolationProfileRole
    public let venue: String
    public let productType: String
    public let environment: String
    public let credentialNamespace: String
    public let manualApprovalRequired: Bool
    public let credentialReferenceOnly: Bool
    public let secretValueRead: Bool
    public let endpointConnectionEnabled: Bool
    public let orderMutationEnabled: Bool
    public let blockedEvidence: String

    public init(
        profileRole: ReleaseV0250EnvironmentIsolationProfileRole,
        venue: String,
        productType: String,
        environment: String,
        credentialNamespace: String,
        manualApprovalRequired: Bool,
        credentialReferenceOnly: Bool,
        secretValueRead: Bool,
        endpointConnectionEnabled: Bool,
        orderMutationEnabled: Bool,
        blockedEvidence: String
    ) {
        self.profileRole = profileRole
        self.venue = venue
        self.productType = productType
        self.environment = environment
        self.credentialNamespace = credentialNamespace
        self.manualApprovalRequired = manualApprovalRequired
        self.credentialReferenceOnly = credentialReferenceOnly
        self.secretValueRead = secretValueRead
        self.endpointConnectionEnabled = endpointConnectionEnabled
        self.orderMutationEnabled = orderMutationEnabled
        self.blockedEvidence = blockedEvidence
    }

    public var failClosed: Bool {
        credentialReferenceOnly
            && secretValueRead == false
            && endpointConnectionEnabled == false
            && orderMutationEnabled == false
            && blockedEvidence.hasPrefix("blocked:")
    }
}

public struct ReleaseV0250ProductionEnvironmentIsolationCredentialPolicy:
    Codable, Equatable, Sendable
{
    // v0.25.0 只固定 environment / credential reference policy，不读取真实 secret。
    public static let validationAnchor =
        "TVM-RELEASE-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY"
    public static let verificationAnchor =
        "GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY"
    public static let requiredAnchors = [
        "GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY",
        "TVM-RELEASE-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY",
        "V0250-002-PRODUCTION-ENVIRONMENT-ISOLATION",
        "V0250-002-CREDENTIAL-REFERENCE-ONLY",
        "V0250-002-MISMATCH-FAILS-CLOSED",
        "V0250-002-MISSING-APPROVAL-FAILS-CLOSED",
        "V0250-002-NO-SECRET-READ"
    ]

    public let release: String
    public let upstreamContractRelease: String
    public let profiles: [ReleaseV0250EnvironmentIsolationProfileEvidence]
    public let allowedProfileRoles: [ReleaseV0250EnvironmentIsolationProfileRole]
    public let mismatchBlockedEvidence: [String]
    public let missingApprovalBlockedEvidence: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let credentialValueStored: Bool
    public let fallbackCredentialProviderEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let brokerEndpointConnectionEnabled: Bool
    public let signedAccountEndpointEnabled: Bool
    public let privateStreamEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public init(
        release: String,
        upstreamContractRelease: String,
        profiles: [ReleaseV0250EnvironmentIsolationProfileEvidence],
        allowedProfileRoles: [ReleaseV0250EnvironmentIsolationProfileRole],
        mismatchBlockedEvidence: [String],
        missingApprovalBlockedEvidence: [String],
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabled: Bool,
        credentialValueStored: Bool,
        fallbackCredentialProviderEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        brokerEndpointConnectionEnabled: Bool,
        signedAccountEndpointEnabled: Bool,
        privateStreamEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        futuresExecutionEnabled: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        productionCutoverAuthorized: Bool,
        boundaryHeld: Bool
    ) {
        self.release = release
        self.upstreamContractRelease = upstreamContractRelease
        self.profiles = profiles
        self.allowedProfileRoles = allowedProfileRoles
        self.mismatchBlockedEvidence = mismatchBlockedEvidence
        self.missingApprovalBlockedEvidence = missingApprovalBlockedEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.credentialValueStored = credentialValueStored
        self.fallbackCredentialProviderEnabled = fallbackCredentialProviderEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.brokerEndpointConnectionEnabled = brokerEndpointConnectionEnabled
        self.signedAccountEndpointEnabled = signedAccountEndpointEnabled
        self.privateStreamEnabled = privateStreamEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = boundaryHeld
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.25.0",
            upstreamContractRelease: "v0.25.0/V0250-001",
            profiles: [
                .init(
                    profileRole: .sandboxDryRun,
                    venue: "binance",
                    productType: "spot",
                    environment: "sandbox",
                    credentialNamespace: "binance/spot/sandbox/reference-only",
                    manualApprovalRequired: false,
                    credentialReferenceOnly: true,
                    secretValueRead: false,
                    endpointConnectionEnabled: false,
                    orderMutationEnabled: false,
                    blockedEvidence: "blocked:no-live-endpoint-for-sandbox-profile"
                ),
                .init(
                    profileRole: .spotCanaryReadiness,
                    venue: "binance",
                    productType: "spot",
                    environment: "productionLive",
                    credentialNamespace: "binance/spot/productionLive/canary/reference-only",
                    manualApprovalRequired: true,
                    credentialReferenceOnly: true,
                    secretValueRead: false,
                    endpointConnectionEnabled: false,
                    orderMutationEnabled: false,
                    blockedEvidence: "blocked:missing-scoped-operator-approval"
                ),
                .init(
                    profileRole: .futuresReadOnlyReadiness,
                    venue: "binance",
                    productType: "usdsPerpetual",
                    environment: "productionShadow",
                    credentialNamespace: "binance/usdsPerpetual/productionShadow/read-only/reference-only",
                    manualApprovalRequired: true,
                    credentialReferenceOnly: true,
                    secretValueRead: false,
                    endpointConnectionEnabled: false,
                    orderMutationEnabled: false,
                    blockedEvidence: "blocked:futures-execution-not-authorized"
                ),
                .init(
                    profileRole: .blockedProductionLiveDefault,
                    venue: "binance",
                    productType: "usdsPerpetual",
                    environment: "productionLive",
                    credentialNamespace: "binance/usdsPerpetual/productionLive/blocked/reference-only",
                    manualApprovalRequired: true,
                    credentialReferenceOnly: true,
                    secretValueRead: false,
                    endpointConnectionEnabled: false,
                    orderMutationEnabled: false,
                    blockedEvidence: "blocked:production-live-default-disabled"
                )
            ],
            allowedProfileRoles: ReleaseV0250EnvironmentIsolationProfileRole.allCases,
            mismatchBlockedEvidence: [
                "blocked:credential-namespace-mismatch",
                "blocked:environment-profile-mismatch",
                "blocked:venue-product-profile-mismatch"
            ],
            missingApprovalBlockedEvidence: [
                "blocked:missing-manual-approval",
                "blocked:missing-dry-run-or-blocked-evidence",
                "blocked:missing-redacted-credential-reference"
            ],
            productionTradingEnabledByDefault: false,
            productionSecretReadEnabled: false,
            credentialValueStored: false,
            fallbackCredentialProviderEnabled: false,
            productionEndpointConnectionEnabled: false,
            brokerEndpointConnectionEnabled: false,
            signedAccountEndpointEnabled: false,
            privateStreamEnabled: false,
            orderSubmitCancelReplaceEnabled: false,
            futuresExecutionEnabled: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            productionCutoverAuthorized: false,
            boundaryHeld: true
        )
    }

    public var policyHeld: Bool {
        release == "v0.25.0"
            && upstreamContractRelease == "v0.25.0/V0250-001"
            && Set(profiles.map(\.profileRole)) == Set(allowedProfileRoles)
            && profiles.allSatisfy(\.failClosed)
            && mismatchBlockedEvidence.allSatisfy { $0.hasPrefix("blocked:") }
            && missingApprovalBlockedEvidence.allSatisfy { $0.hasPrefix("blocked:") }
            && forbiddenCapabilitiesClosed
            && boundaryHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && credentialValueStored == false
            && fallbackCredentialProviderEnabled == false
            && productionEndpointConnectionEnabled == false
            && brokerEndpointConnectionEnabled == false
            && signedAccountEndpointEnabled == false
            && privateStreamEnabled == false
            && orderSubmitCancelReplaceEnabled == false
            && futuresExecutionEnabled == false
            && okxActiveRuntimeEnabled == false
            && dashboardTradingControlsEnabled == false
            && productionCutoverAuthorized == false
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "profiles=\(allowedProfileRoles.map(\.rawValue).joined(separator: ","))",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretReadEnabled=\(productionSecretReadEnabled)",
            "credentialValueStored=\(credentialValueStored)",
            "fallbackCredentialProviderEnabled=\(fallbackCredentialProviderEnabled)",
            "productionEndpointConnectionEnabled=\(productionEndpointConnectionEnabled)",
            "brokerEndpointConnectionEnabled=\(brokerEndpointConnectionEnabled)",
            "orderSubmitCancelReplaceEnabled=\(orderSubmitCancelReplaceEnabled)",
            "futuresExecutionEnabled=\(futuresExecutionEnabled)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "policyHeld=\(policyHeld)"
        ]
    }
}
