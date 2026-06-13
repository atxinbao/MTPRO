import DomainModel
import Foundation

/// ReleaseV050SecretProfileRefKind 固定 GH-728 的 secret profile 引用类型。
///
/// 这里的 profile 都只是身份引用，不携带 secret value，也不会解析环境变量或 keychain。
public enum ReleaseV050SecretProfileRefKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noSecretRequired = "no secret required"
    case testnetReferenceOnly = "testnet reference only"
    case productionBlockedReference = "production blocked reference"
}

/// ReleaseV050EndpointPolicyDecision 描述 endpoint policy 的本地解析结果。
///
/// Decision 只用于 deterministic evidence；它不打开 socket、不创建请求对象，也不连接 Binance。
public enum ReleaseV050EndpointPolicyDecision: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noEndpointRequired = "no endpoint required"
    case testnetEndpointAllowed = "testnet endpoint allowed"
    case productionBlockedFailClosed = "production blocked fail-closed"
}

/// ReleaseV050SecretProfileRef 是 GH-728 的 reference-only credential identity。
///
/// 它只保存 profile 名称、mode 和阻断标志，不保存或读取任何 secret value。
public struct ReleaseV050SecretProfileRef: Codable, Equatable, Sendable {
    public let referenceID: Identifier
    public let mode: ReleaseV050RuntimeMode
    public let kind: ReleaseV050SecretProfileRefKind
    public let profileReference: String
    public let containsSecretValue: Bool
    public let resolvesSecretValue: Bool
    public let productionSecretResolutionBlocked: Bool

    public var referenceOnlyHeld: Bool {
        profileReference.isEmpty == false
            && kind == Self.expectedKind(for: mode)
            && containsSecretValue == false
            && resolvesSecretValue == false
            && productionSecretResolutionBlocked
    }

    public init(
        referenceID: Identifier,
        mode: ReleaseV050RuntimeMode,
        kind: ReleaseV050SecretProfileRefKind,
        profileReference: String,
        containsSecretValue: Bool = false,
        resolvesSecretValue: Bool = false,
        productionSecretResolutionBlocked: Bool = true
    ) throws {
        guard profileReference.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "profileReference",
                expected: "non-empty secret profile reference",
                actual: "empty"
            )
        }
        guard kind == Self.expectedKind(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "secretProfileKind",
                expected: Self.expectedKind(for: mode).rawValue,
                actual: kind.rawValue
            )
        }
        guard containsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsSecretValue")
        }
        guard resolvesSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("resolvesSecretValue")
        }
        guard productionSecretResolutionBlocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productionSecretResolutionBlocked",
                expected: "true",
                actual: "false"
            )
        }

        self.referenceID = referenceID
        self.mode = mode
        self.kind = kind
        self.profileReference = profileReference
        self.containsSecretValue = containsSecretValue
        self.resolvesSecretValue = resolvesSecretValue
        self.productionSecretResolutionBlocked = productionSecretResolutionBlocked
    }

    public static func expectedKind(for mode: ReleaseV050RuntimeMode) -> ReleaseV050SecretProfileRefKind {
        switch mode {
        case .dryRun:
            .noSecretRequired
        case .testnetGuarded:
            .testnetReferenceOnly
        case .productionBlocked:
            .productionBlockedReference
        }
    }

    public static func fixture(for mode: ReleaseV050RuntimeMode) throws -> ReleaseV050SecretProfileRef {
        try ReleaseV050SecretProfileRef(
            referenceID: Identifier.constant("gh-728-\(mode.rawValue)-secret-profile-ref"),
            mode: mode,
            kind: expectedKind(for: mode),
            profileReference: expectedProfileReference(for: mode)
        )
    }

    private static func expectedProfileReference(for mode: ReleaseV050RuntimeMode) -> String {
        switch mode {
        case .dryRun:
            "local-dry-run-no-secret"
        case .testnetGuarded:
            "binance-testnet-reference-only"
        case .productionBlocked:
            "production-secret-resolution-blocked"
        }
    }
}

/// ReleaseV050EndpointResolutionEvidence 是 endpoint policy 的 deterministic evidence。
///
/// Evidence 记录 allowlist / scheme / product 结论，但不会创建网络 request。
public struct ReleaseV050EndpointResolutionEvidence: Codable, Equatable, Sendable {
    public let mode: ReleaseV050RuntimeMode
    public let decision: ReleaseV050EndpointPolicyDecision
    public let endpointReference: String
    public let productType: String
    public let hostAllowed: Bool
    public let schemeAllowed: Bool
    public let productBound: Bool
    public let productionHostBlocked: Bool
    public let endpointResolved: Bool
    public let networkConnectionOpened: Bool

    public var boundaryHeld: Bool {
        productionHostBlocked
            && networkConnectionOpened == false
            && decisionBoundaryHeld
    }

    private var decisionBoundaryHeld: Bool {
        switch decision {
        case .noEndpointRequired:
            endpointReference == "none"
                && endpointResolved == false
        case .testnetEndpointAllowed:
            endpointResolved
                && hostAllowed
                && schemeAllowed
                && productBound
        case .productionBlockedFailClosed:
            endpointResolved == false
        }
    }
}

/// ReleaseV050EndpointPolicy 固定 GH-728 的 endpoint allowlist、scheme 和 product binding。
///
/// Policy 可验证 testnet URL shape，但不打开网络连接；production host 只能作为 forbidden host
/// evidence 出现，不能被解析成可连接 endpoint。
public struct ReleaseV050EndpointPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let mode: ReleaseV050RuntimeMode
    public let allowedHosts: [String]
    public let forbiddenHosts: [String]
    public let requiredScheme: String
    public let productBindings: [String]
    public let endpointResolutionAllowed: Bool
    public let explicitTestnetPolicyRequired: Bool
    public let connectsEndpoint: Bool
    public let productionFallbackAllowed: Bool

    public var policyHeld: Bool {
        allowedHosts == Self.expectedAllowedHosts(for: mode)
            && forbiddenHosts == Self.requiredForbiddenHosts
            && requiredScheme == Self.expectedRequiredScheme(for: mode)
            && productBindings == Self.expectedProductBindings(for: mode)
            && endpointResolutionAllowed == Self.expectedEndpointResolutionAllowed(for: mode)
            && explicitTestnetPolicyRequired == (mode == .testnetGuarded)
            && connectsEndpoint == false
            && productionFallbackAllowed == false
            && Set(allowedHosts).isDisjoint(with: Set(forbiddenHosts))
    }

    public init(
        policyID: Identifier,
        mode: ReleaseV050RuntimeMode,
        allowedHosts: [String],
        forbiddenHosts: [String] = Self.requiredForbiddenHosts,
        requiredScheme: String,
        productBindings: [String],
        endpointResolutionAllowed: Bool,
        explicitTestnetPolicyRequired: Bool,
        connectsEndpoint: Bool = false,
        productionFallbackAllowed: Bool = false
    ) throws {
        guard allowedHosts == Self.expectedAllowedHosts(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedHosts",
                expected: Self.expectedAllowedHosts(for: mode).joined(separator: ","),
                actual: allowedHosts.joined(separator: ",")
            )
        }
        guard forbiddenHosts == Self.requiredForbiddenHosts else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenHosts",
                expected: Self.requiredForbiddenHosts.joined(separator: ","),
                actual: forbiddenHosts.joined(separator: ",")
            )
        }
        guard Set(allowedHosts).isDisjoint(with: Set(forbiddenHosts)) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowedHostOverlapsProductionHost")
        }
        guard requiredScheme == Self.expectedRequiredScheme(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredScheme",
                expected: Self.expectedRequiredScheme(for: mode),
                actual: requiredScheme
            )
        }
        guard productBindings == Self.expectedProductBindings(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productBindings",
                expected: Self.expectedProductBindings(for: mode).joined(separator: ","),
                actual: productBindings.joined(separator: ",")
            )
        }
        guard endpointResolutionAllowed == Self.expectedEndpointResolutionAllowed(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointResolutionAllowed",
                expected: String(Self.expectedEndpointResolutionAllowed(for: mode)),
                actual: String(endpointResolutionAllowed)
            )
        }
        guard explicitTestnetPolicyRequired == (mode == .testnetGuarded) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "explicitTestnetPolicyRequired",
                expected: String(mode == .testnetGuarded),
                actual: String(explicitTestnetPolicyRequired)
            )
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("connectsEndpoint")
        }
        guard productionFallbackAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionFallbackAllowed")
        }

        self.policyID = policyID
        self.mode = mode
        self.allowedHosts = allowedHosts
        self.forbiddenHosts = forbiddenHosts
        self.requiredScheme = requiredScheme
        self.productBindings = productBindings
        self.endpointResolutionAllowed = endpointResolutionAllowed
        self.explicitTestnetPolicyRequired = explicitTestnetPolicyRequired
        self.connectsEndpoint = connectsEndpoint
        self.productionFallbackAllowed = productionFallbackAllowed
    }

    public func resolve(endpointReference: String?, productType: String) throws -> ReleaseV050EndpointResolutionEvidence {
        switch mode {
        case .dryRun:
            guard endpointReference == nil else {
                throw CoreError.liveTradingBoundaryForbiddenCapability("dryRunEndpointResolution")
            }
            return ReleaseV050EndpointResolutionEvidence(
                mode: mode,
                decision: .noEndpointRequired,
                endpointReference: "none",
                productType: productType,
                hostAllowed: false,
                schemeAllowed: false,
                productBound: productBindings.contains(productType),
                productionHostBlocked: true,
                endpointResolved: false,
                networkConnectionOpened: false
            )
        case .testnetGuarded:
            guard let endpointReference else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "endpointReference",
                    expected: "explicit testnet endpoint reference",
                    actual: "none"
                )
            }
            guard let url = URL(string: endpointReference), let host = url.host?.lowercased() else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "endpointReference",
                    expected: "valid HTTPS testnet URL",
                    actual: endpointReference
                )
            }
            guard forbiddenHosts.contains(host) == false else {
                throw CoreError.liveTradingBoundaryForbiddenCapability("productionEndpointHost")
            }
            guard url.scheme?.lowercased() == requiredScheme else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "endpointScheme",
                    expected: requiredScheme,
                    actual: url.scheme ?? "missing"
                )
            }
            guard allowedHosts.contains(host) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "endpointHost",
                    expected: allowedHosts.joined(separator: ","),
                    actual: host
                )
            }
            guard productBindings.contains(productType) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "productType",
                    expected: productBindings.joined(separator: ","),
                    actual: productType
                )
            }
            return ReleaseV050EndpointResolutionEvidence(
                mode: mode,
                decision: .testnetEndpointAllowed,
                endpointReference: endpointReference,
                productType: productType,
                hostAllowed: true,
                schemeAllowed: true,
                productBound: true,
                productionHostBlocked: true,
                endpointResolved: true,
                networkConnectionOpened: false
            )
        case .productionBlocked:
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionBlockedEndpointResolution")
        }
    }

    public static func fixture(for mode: ReleaseV050RuntimeMode) throws -> ReleaseV050EndpointPolicy {
        try ReleaseV050EndpointPolicy(
            policyID: Identifier.constant("gh-728-\(mode.rawValue)-endpoint-policy"),
            mode: mode,
            allowedHosts: expectedAllowedHosts(for: mode),
            requiredScheme: expectedRequiredScheme(for: mode),
            productBindings: expectedProductBindings(for: mode),
            endpointResolutionAllowed: expectedEndpointResolutionAllowed(for: mode),
            explicitTestnetPolicyRequired: mode == .testnetGuarded
        )
    }

    public static let requiredForbiddenHosts = [
        "api.binance.com",
        "fapi.binance.com"
    ]

    public static let requiredTestnetHosts = [
        "testnet.binance.vision",
        "testnet.binancefuture.com"
    ]

    public static let requiredProductBindings = [
        "spot",
        "usdsPerpetual"
    ]

    public static func expectedAllowedHosts(for mode: ReleaseV050RuntimeMode) -> [String] {
        switch mode {
        case .dryRun, .productionBlocked:
            []
        case .testnetGuarded:
            requiredTestnetHosts
        }
    }

    public static func expectedRequiredScheme(for mode: ReleaseV050RuntimeMode) -> String {
        switch mode {
        case .dryRun, .productionBlocked:
            "none"
        case .testnetGuarded:
            "https"
        }
    }

    public static func expectedProductBindings(for mode: ReleaseV050RuntimeMode) -> [String] {
        switch mode {
        case .dryRun:
            []
        case .testnetGuarded:
            requiredProductBindings
        case .productionBlocked:
            []
        }
    }

    public static func expectedEndpointResolutionAllowed(for mode: ReleaseV050RuntimeMode) -> Bool {
        mode == .testnetGuarded
    }
}

/// ReleaseV050EnvironmentProfile 组合 GH-728 的 mode、endpoint policy 和 secret ref。
///
/// Profile 只作为本地 policy evidence，不提供 runtime connector、secret provider 或 order path。
public struct ReleaseV050EnvironmentProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let mode: ReleaseV050RuntimeMode
    public let endpointPolicy: ReleaseV050EndpointPolicy
    public let secretProfileRef: ReleaseV050SecretProfileRef
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool

    public var profileHeld: Bool {
        endpointPolicy.mode == mode
            && secretProfileRef.mode == mode
            && endpointPolicy.policyHeld
            && secretProfileRef.referenceOnlyHeld
            && productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
    }

    public init(
        profileID: Identifier,
        mode: ReleaseV050RuntimeMode,
        endpointPolicy: ReleaseV050EndpointPolicy,
        secretProfileRef: ReleaseV050SecretProfileRef,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false
    ) throws {
        guard endpointPolicy.mode == mode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicy.mode",
                expected: mode.rawValue,
                actual: endpointPolicy.mode.rawValue
            )
        }
        guard secretProfileRef.mode == mode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "secretProfileRef.mode",
                expected: mode.rawValue,
                actual: secretProfileRef.mode.rawValue
            )
        }
        guard endpointPolicy.policyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicy.policyHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard secretProfileRef.referenceOnlyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "secretProfileRef.referenceOnlyHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard productionTradingEnabledByDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
        }
        guard productionSecretResolutionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionSecretResolutionEnabled")
        }
        guard productionEndpointConnectionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionEndpointConnectionEnabled")
        }
        guard realOrderAuthorizationEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("realOrderAuthorizationEnabled")
        }

        self.profileID = profileID
        self.mode = mode
        self.endpointPolicy = endpointPolicy
        self.secretProfileRef = secretProfileRef
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
    }

    public static func fixture(for mode: ReleaseV050RuntimeMode) throws -> ReleaseV050EnvironmentProfile {
        try ReleaseV050EnvironmentProfile(
            profileID: Identifier.constant("gh-728-\(mode.rawValue)-environment-profile"),
            mode: mode,
            endpointPolicy: ReleaseV050EndpointPolicy.fixture(for: mode),
            secretProfileRef: ReleaseV050SecretProfileRef.fixture(for: mode)
        )
    }
}

/// ReleaseV050EnvironmentEndpointSecretPolicyContract 是 GH-728 的统一环境 / endpoint / secret 合同。
///
/// 合同把 dry-run、testnet-guarded、production-blocked 的 endpoint 和 secret policy 固定成
/// 本地可验证证据；它不解析 secret、不连接 endpoint、不授权生产交易。
public struct ReleaseV050EnvironmentEndpointSecretPolicyContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let profiles: [ReleaseV050EnvironmentProfile]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let realOrderAuthorizationEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        guard let requiredProfiles = try? Self.requiredProfiles() else {
            return false
        }

        return issueID.rawValue == "GH-728"
            && upstreamIssueID.rawValue == "GH-726"
            && previousIssueID.rawValue == "GH-727"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-732", "GH-733", "GH-738", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName
            && profiles == requiredProfiles
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && modeCoverageHeld
            && productionDefaultsClosed
    }

    public var modeCoverageHeld: Bool {
        Set(profiles.map(\.mode)) == Set(ReleaseV050RuntimeMode.allCases)
            && profiles.allSatisfy(\.profileHeld)
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && realOrderAuthorizationEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-728-release-v0.5.0-environment-endpoint-secret-policy"),
        issueID: Identifier = Identifier.constant("GH-728"),
        upstreamIssueID: Identifier = Identifier.constant("GH-726"),
        previousIssueID: Identifier = Identifier.constant("GH-727"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-732"),
            Identifier.constant("GH-733"),
            Identifier.constant("GH-738"),
            Identifier.constant("GH-739")
        ],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName,
        profiles: [ReleaseV050EnvironmentProfile]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        realOrderAuthorizationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedProfiles = try profiles ?? Self.requiredProfiles()

        guard downstreamIssueIDs.map(\.rawValue) == ["GH-732", "GH-733", "GH-738", "GH-739"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "downstreamIssueIDs",
                expected: "GH-732,GH-733,GH-738,GH-739",
                actual: downstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard canonicalQueueRange == "GH-726..GH-739" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "canonicalQueueRange",
                expected: "GH-726..GH-739",
                actual: canonicalQueueRange
            )
        }
        guard projectName == ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "projectName",
                expected: ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName,
                actual: projectName
            )
        }
        guard resolvedProfiles == (try Self.requiredProfiles()) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "profiles",
                expected: "dry-run,testnet-guarded,production-blocked",
                actual: resolvedProfiles.map(\.mode.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        guard productionTradingEnabledByDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
        }
        guard productionSecretResolutionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionSecretResolutionEnabled")
        }
        guard productionEndpointConnectionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionEndpointConnectionEnabled")
        }
        guard realOrderAuthorizationEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("realOrderAuthorizationEnabled")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionCutoverAuthorized")
        }

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.profiles = resolvedProfiles
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.realOrderAuthorizationEnabled = realOrderAuthorizationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws -> ReleaseV050EnvironmentEndpointSecretPolicyContract {
        try ReleaseV050EnvironmentEndpointSecretPolicyContract()
    }

    public static let requiredValidationAnchors = [
        "V050-03-ENVIRONMENT-PROFILE-ENDPOINT-SECRET-POLICY",
        "V050-03-DRYRUN-NO-SECRET-NO-ENDPOINT",
        "V050-03-TESTNET-HTTPS-ALLOWLIST-POLICY",
        "V050-03-PRODUCTION-BLOCKED-FAILS-CLOSED",
        "V050-03-SECRET-PROFILE-REFERENCE-ONLY",
        "TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH728EnvironmentEndpointSecretPolicyFailsClosed",
        "bash checks/verify-v0.5.0-environment.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func requiredProfiles() throws -> [ReleaseV050EnvironmentProfile] {
        try ReleaseV050RuntimeMode.allCases.map { try ReleaseV050EnvironmentProfile.fixture(for: $0) }
    }
}
