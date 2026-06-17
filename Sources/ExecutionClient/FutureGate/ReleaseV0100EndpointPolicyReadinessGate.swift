import DomainModel
import Foundation

/// ReleaseV0100EndpointPolicyEnvironment 固定 GH-882 需要覆盖的 endpoint policy 环境。
///
/// 环境只描述 policy row 的归属，不代表 runtime 会连接 endpoint。Production row 只能作为
/// allowlist / forbidden fallback evidence，不能被解析成可连接 broker 或 signed endpoint。
public enum ReleaseV0100EndpointPolicyEnvironment: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case testnet = "testnet"
    case production = "production"
}

/// ReleaseV0100EndpointPolicyEvidenceArtifactKind 固定 GH-882 必须产生的 readiness evidence 文件。
public enum ReleaseV0100EndpointPolicyEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case endpointPolicyReadiness = "endpoint_policy_readiness.json"
}

/// ReleaseV0100EndpointPolicyReadinessRequirement 固定 GH-882 的 endpoint policy readiness 合同要求。
public enum ReleaseV0100EndpointPolicyReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamProductionEnvironmentProfileRequired = "upstream production environment profile required"
    case upstreamSecretProviderReadinessRequired = "upstream secret provider readiness required"
    case testnetEndpointAllowlistRequired = "testnet endpoint allowlist required"
    case productionEndpointAllowlistRequired = "production endpoint allowlist required"
    case environmentBindingRequired = "environment binding required"
    case hostValidationRequired = "host validation required"
    case schemeValidationRequired = "scheme validation required"
    case noSilentFallbackRequired = "no silent fallback required"
    case endpointPolicyReadinessEvidenceExists = "endpoint_policy_readiness.json evidence exists"
}

/// ReleaseV0100EndpointPolicyForbiddenCapability 枚举 GH-882 必须拒绝的 endpoint / trading 能力。
public enum ReleaseV0100EndpointPolicyForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionEndpointConnected = "production endpoint connected"
    case productionBrokerConnection = "production broker connection"
    case fallbackToProduction = "fallback to production"
    case testnetToProductionFallback = "testnet to production fallback"
    case silentEndpointFallback = "silent endpoint fallback"
    case invalidEndpointSchemeAccepted = "invalid endpoint scheme accepted"
    case invalidEndpointHostAccepted = "invalid endpoint host accepted"
    case productionSecretValueRead = "production secret value read"
    case productionCutoverAuthorization = "production cutover authorization"
    case orderSubmissionEnabled = "order submission enabled"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonEnabled = "trading button enabled"
    case orderFormEnabled = "order form enabled"
    case liveCommandEnabled = "live command enabled"
}

/// ReleaseV0100EndpointPolicyReadinessRow 是 GH-882 的 endpoint allowlist row。
///
/// Row 只保存 environment、host、scheme 和 product binding policy evidence。它不会解析 URL，
/// 不打开 socket，不探测 endpoint，不读取 secret，也不会把 production allowlist 转成 connection permission。
public struct ReleaseV0100EndpointPolicyReadinessRow: Codable, Equatable, Sendable {
    public let environment: ReleaseV0100EndpointPolicyEnvironment
    public let host: String
    public let scheme: String
    public let productTypes: [String]
    public let environmentBound: Bool
    public let hostValidationRequired: Bool
    public let schemeValidationRequired: Bool
    public let endpointConnectionAllowed: Bool

    public var policyBoundaryHeld: Bool {
        environmentBound
            && hostValidationRequired
            && schemeValidationRequired
            && endpointConnectionAllowed == false
            && scheme == ReleaseV0100EndpointPolicyReadinessGate.requiredScheme
            && productTypes == ReleaseV0100EndpointPolicyReadinessGate.requiredProductTypes
            && ReleaseV0100EndpointPolicyReadinessGate.allowedHosts(for: environment).contains(host)
    }

    public init(
        environment: ReleaseV0100EndpointPolicyEnvironment,
        host: String,
        scheme: String = ReleaseV0100EndpointPolicyReadinessGate.requiredScheme,
        productTypes: [String] = ReleaseV0100EndpointPolicyReadinessGate.requiredProductTypes,
        environmentBound: Bool = true,
        hostValidationRequired: Bool = true,
        schemeValidationRequired: Bool = true,
        endpointConnectionAllowed: Bool = false
    ) throws {
        guard ReleaseV0100EndpointPolicyReadinessGate.allowedHosts(for: environment).contains(host) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicyHost",
                expected: ReleaseV0100EndpointPolicyReadinessGate.allowedHosts(for: environment).joined(separator: ","),
                actual: host
            )
        }
        guard scheme == ReleaseV0100EndpointPolicyReadinessGate.requiredScheme else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicyScheme",
                expected: ReleaseV0100EndpointPolicyReadinessGate.requiredScheme,
                actual: scheme
            )
        }
        guard productTypes == ReleaseV0100EndpointPolicyReadinessGate.requiredProductTypes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicyProductTypes",
                expected: ReleaseV0100EndpointPolicyReadinessGate.requiredProductTypes.joined(separator: ","),
                actual: productTypes.joined(separator: ",")
            )
        }
        guard environmentBound else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "environmentBound",
                expected: "true",
                actual: "false"
            )
        }
        guard hostValidationRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "hostValidationRequired",
                expected: "true",
                actual: "false"
            )
        }
        guard schemeValidationRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "schemeValidationRequired",
                expected: "true",
                actual: "false"
            )
        }
        guard endpointConnectionAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("endpointConnectionAllowed")
        }

        self.environment = environment
        self.host = host
        self.scheme = scheme
        self.productTypes = productTypes
        self.environmentBound = environmentBound
        self.hostValidationRequired = hostValidationRequired
        self.schemeValidationRequired = schemeValidationRequired
        self.endpointConnectionAllowed = endpointConnectionAllowed
    }
}

/// ReleaseV0100EndpointPolicyReadinessEvidenceArtifact 是 GH-882 的 evidence file row。
///
/// Artifact 只证明 `endpoint_policy_readiness.json` 文件名和 readiness flags。它不携带
/// endpoint response、network proof、secret、listenKey 或 broker session。
public struct ReleaseV0100EndpointPolicyReadinessEvidenceArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100EndpointPolicyEvidenceArtifactKind
    public let fileName: String
    public let evidenceExists: Bool
    public let containsEndpointResponse: Bool
    public let producedByConnection: Bool

    public var evidenceBoundaryHeld: Bool {
        kind == .endpointPolicyReadiness
            && fileName == kind.rawValue
            && evidenceExists
            && containsEndpointResponse == false
            && producedByConnection == false
    }

    public init(
        kind: ReleaseV0100EndpointPolicyEvidenceArtifactKind = .endpointPolicyReadiness,
        fileName: String = ReleaseV0100EndpointPolicyEvidenceArtifactKind.endpointPolicyReadiness.rawValue,
        evidenceExists: Bool = true,
        containsEndpointResponse: Bool = false,
        producedByConnection: Bool = false
    ) throws {
        guard fileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicyEvidenceFile",
                expected: kind.rawValue,
                actual: fileName
            )
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicyReadinessEvidenceExists",
                expected: "true",
                actual: "false"
            )
        }
        guard containsEndpointResponse == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsEndpointResponse")
        }
        guard producedByConnection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("producedByConnection")
        }

        self.kind = kind
        self.fileName = fileName
        self.evidenceExists = evidenceExists
        self.containsEndpointResponse = containsEndpointResponse
        self.producedByConnection = producedByConnection
    }
}

/// ReleaseV0100EndpointPolicyReadinessGate 是 GH-882 的 EndpointPolicyReadinessGate 合同。
///
/// Gate 只证明 testnet / production endpoint allowlist、environment binding、host validation、
/// scheme validation 和 no-silent-fallback policy 已可审计。它不会连接 production endpoint 或
/// broker endpoint，不读取 production secret，不提交 testnet 或 production order，也不授权 cutover。
public struct ReleaseV0100EndpointPolicyReadinessGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamProductionEnvironmentProfileHeld: Bool
    public let upstreamSecretProviderReadinessHeld: Bool
    public let endpointPolicies: [ReleaseV0100EndpointPolicyReadinessRow]
    public let evidenceArtifact: ReleaseV0100EndpointPolicyReadinessEvidenceArtifact
    public let requirements: [ReleaseV0100EndpointPolicyReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0100EndpointPolicyForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionEndpointConnected: Bool
    public let fallbackToProduction: Bool
    public let testnetToProductionFallbackForbidden: Bool
    public let noSilentFallbackRequired: Bool
    public let cutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-882"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-880", "GH-881"]
            && downstreamIssueID.rawValue == "GH-883"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamProductionEnvironmentProfileHeld
            && upstreamSecretProviderReadinessHeld
            && endpointPolicyCoverageHeld
            && evidenceArtifact.evidenceBoundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionEndpointConnected == false
            && fallbackToProduction == false
            && testnetToProductionFallbackForbidden
            && noSilentFallbackRequired
            && productionCapabilitiesDisabled
    }

    public var endpointPolicyCoverageHeld: Bool {
        endpointPolicies == Self.requiredEndpointPolicies
            && endpointPolicies.allSatisfy(\.policyBoundaryHeld)
            && Set(endpointPolicies.map(\.environment)) == Set(ReleaseV0100EndpointPolicyEnvironment.allCases)
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && testnetOrderSubmissionEnabled == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-882-endpoint-policy-readiness-gate"),
        issueID: Identifier = Identifier.constant("GH-882"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-880"), Identifier.constant("GH-881")],
        downstreamIssueID: Identifier = Identifier.constant("GH-883"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamProductionEnvironmentProfileHeld: Bool = true,
        upstreamSecretProviderReadinessHeld: Bool = true,
        endpointPolicies: [ReleaseV0100EndpointPolicyReadinessRow] = Self.requiredEndpointPolicies,
        evidenceArtifact: ReleaseV0100EndpointPolicyReadinessEvidenceArtifact = Self.requiredEvidenceArtifact,
        requirements: [ReleaseV0100EndpointPolicyReadinessRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100EndpointPolicyForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionEndpointConnected: Bool = false,
        fallbackToProduction: Bool = false,
        testnetToProductionFallbackForbidden: Bool = true,
        noSilentFallbackRequired: Bool = true,
        cutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            upstreamIssueIDs: upstreamIssueIDs,
            endpointPolicies: endpointPolicies,
            evidenceArtifact: evidenceArtifact,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamProductionEnvironmentProfileHeld: upstreamProductionEnvironmentProfileHeld,
            upstreamSecretProviderReadinessHeld: upstreamSecretProviderReadinessHeld,
            testnetToProductionFallbackForbidden: testnetToProductionFallbackForbidden,
            noSilentFallbackRequired: noSilentFallbackRequired
        )
        try Self.validateForbiddenFlags(
            productionEndpointConnected: productionEndpointConnected,
            fallbackToProduction: fallbackToProduction,
            cutoverAuthorized: cutoverAuthorized,
            orderSubmissionEnabled: orderSubmissionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonEnabled: tradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamProductionEnvironmentProfileHeld = upstreamProductionEnvironmentProfileHeld
        self.upstreamSecretProviderReadinessHeld = upstreamSecretProviderReadinessHeld
        self.endpointPolicies = endpointPolicies
        self.evidenceArtifact = evidenceArtifact
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionEndpointConnected = productionEndpointConnected
        self.fallbackToProduction = fallbackToProduction
        self.testnetToProductionFallbackForbidden = testnetToProductionFallbackForbidden
        self.noSilentFallbackRequired = noSilentFallbackRequired
        self.cutoverAuthorized = cutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonEnabled = tradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100EndpointPolicyReadinessGate {
        try ReleaseV0100EndpointPolicyReadinessGate()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredScheme = "https"
    public static let requiredProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredRequirements = ReleaseV0100EndpointPolicyReadinessRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100EndpointPolicyForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-005-ENDPOINT-POLICY-READINESS-GATE",
        "V0100-005-TESTNET-ENDPOINT-ALLOWLIST",
        "V0100-005-PRODUCTION-ENDPOINT-ALLOWLIST",
        "V0100-005-ENVIRONMENT-BINDING",
        "V0100-005-HOST-VALIDATION",
        "V0100-005-SCHEME-VALIDATION",
        "V0100-005-NO-SILENT-FALLBACK",
        "V0100-005-ENDPOINT-POLICY-READINESS-JSON",
        "V0100-005-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-882-VERIFY-V0100-ENDPOINT-POLICY-READINESS-GATE",
        "TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH882EndpointPolicyReadinessGateRejectsProductionConnectionAndSilentFallback",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func allowedHosts(for environment: ReleaseV0100EndpointPolicyEnvironment) -> [String] {
        switch environment {
        case .testnet:
            ["testnet.binance.vision", "testnet.binancefuture.com"]
        case .production:
            ["api.binance.com", "fapi.binance.com"]
        }
    }

    public static let requiredEndpointPolicies: [ReleaseV0100EndpointPolicyReadinessRow] = {
        do {
            return [
                try ReleaseV0100EndpointPolicyReadinessRow(
                    environment: .testnet,
                    host: "testnet.binance.vision"
                ),
                try ReleaseV0100EndpointPolicyReadinessRow(
                    environment: .testnet,
                    host: "testnet.binancefuture.com"
                ),
                try ReleaseV0100EndpointPolicyReadinessRow(
                    environment: .production,
                    host: "api.binance.com"
                ),
                try ReleaseV0100EndpointPolicyReadinessRow(
                    environment: .production,
                    host: "fapi.binance.com"
                )
            ]
        } catch {
            preconditionFailure("GH-882 endpoint policy rows must be valid: \(error)")
        }
    }()

    public static let requiredEvidenceArtifact: ReleaseV0100EndpointPolicyReadinessEvidenceArtifact = {
        do {
            return try ReleaseV0100EndpointPolicyReadinessEvidenceArtifact()
        } catch {
            preconditionFailure("GH-882 endpoint policy evidence artifact must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100EndpointPolicyReadinessGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        upstreamIssueIDs: [Identifier],
        endpointPolicies: [ReleaseV0100EndpointPolicyReadinessRow],
        evidenceArtifact: ReleaseV0100EndpointPolicyReadinessEvidenceArtifact,
        requirements: [ReleaseV0100EndpointPolicyReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0100EndpointPolicyForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-880", "GH-881"], "GH-880,GH-881", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("endpointPolicies", endpointPolicies == requiredEndpointPolicies, requiredEndpointPolicies.map(\.host).joined(separator: ","), endpointPolicies.map(\.host).joined(separator: ",")),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
            ("requirements", requirements == requiredRequirements, requiredRequirements.map(\.rawValue).joined(separator: ","), requirements.map(\.rawValue).joined(separator: ",")),
            ("forbiddenCapabilities", forbiddenCapabilities == requiredForbiddenCapabilities, requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","), forbiddenCapabilities.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        upstreamProductionEnvironmentProfileHeld: Bool,
        upstreamSecretProviderReadinessHeld: Bool,
        testnetToProductionFallbackForbidden: Bool,
        noSilentFallbackRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamProductionEnvironmentProfileHeld", upstreamProductionEnvironmentProfileHeld),
            ("upstreamSecretProviderReadinessHeld", upstreamSecretProviderReadinessHeld),
            ("testnetToProductionFallbackForbidden", testnetToProductionFallbackForbidden),
            ("noSilentFallbackRequired", noSilentFallbackRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionEndpointConnected: Bool,
        fallbackToProduction: Bool,
        cutoverAuthorized: Bool,
        orderSubmissionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointConnected", productionEndpointConnected),
            ("fallbackToProduction", fallbackToProduction),
            ("cutoverAuthorized", cutoverAuthorized),
            ("orderSubmissionEnabled", orderSubmissionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonEnabled", tradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
