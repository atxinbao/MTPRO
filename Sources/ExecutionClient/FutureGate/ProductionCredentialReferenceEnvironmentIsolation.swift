import DomainModel
import Foundation

/// ProductionCredentialEnvironmentKind 固定 GH-644 可以表达的 credential environment。
///
/// 这些 environment 只用于身份引用和 fail-closed evidence。Production 仍是 blocked / future-gated，
/// 不能由 dry-run、testnet、缺省值或模糊选择自动回退得到。
public enum ProductionCredentialEnvironmentKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case productionBlocked = "production blocked"
    case futureProduction = "future production"
}

/// ProductionCredentialAuthorizationState 描述 credential reference 是否具备当前可用授权。
///
/// Production 相关状态只能是 fail-closed 或 future manual gate，不能在当前 issue 中变成
/// production secret provider、production endpoint connection 或真实订单授权。
public enum ProductionCredentialAuthorizationState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFixtureAuthorized = "local fixture authorized"
    case testnetReferenceAuthorized = "testnet reference authorized"
    case productionMissingFailClosed = "production missing authorization fail-closed"
    case futureProductionManualGateRequired = "future production manual gate required"
}

/// ProductionCredentialReferenceRequirement 固定 GH-644 的 credential reference / environment isolation 要求。
public enum ProductionCredentialReferenceRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamRuntimeHardeningContractRequired = "upstream runtime hardening contract required"
    case identityReferenceOnly = "identity reference only"
    case profileNameOnly = "profile name only"
    case noSecretValueRead = "no secret value read"
    case explicitEnvironmentSelection = "explicit environment selection"
    case dryRunTestnetProductionIsolation = "dry-run / testnet / production isolation"
    case missingAuthorizationFailsClosed = "missing authorization fails closed"
    case noProductionFallback = "no production fallback"
}

/// ProductionCredentialReferenceForbiddenCapability 枚举 GH-644 必须拒绝的 credential / environment 绕过。
public enum ProductionCredentialReferenceForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case secretValueRead = "secret value read"
    case environmentSecretProbe = "environment secret probe"
    case secretValueStorage = "secret value storage"
    case defaultProductionCredential = "default production credential"
    case defaultProductionEnvironment = "default production environment"
    case ambiguousEnvironmentPromotesProduction = "ambiguous environment promotes production"
    case productionFallback = "production fallback"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case realBrokerConnection = "real broker connection"
    case realOrderSubmission = "real order submission"
    case commandRiskExecutionOMSBypass = "CommandGateway / RiskEngine / ExecutionEngine / OMS bypass"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionCredentialProfileReference 是 GH-644 的 credential identity row。
///
/// Row 只能携带 profile / environment / authorization evidence identity，不能携带 secret value。
/// Production row 必须保持 missing-fail-closed 或 future-manual-gate 状态。
public struct ProductionCredentialProfileReference: Codable, Equatable, Sendable {
    public let referenceID: Identifier
    public let environment: ProductionCredentialEnvironmentKind
    public let profileReference: String
    public let authorizationState: ProductionCredentialAuthorizationState
    public let authorizationAnchor: String
    public let readsSecretValue: Bool
    public let storesSecretValue: Bool
    public let allowsProductionFallback: Bool
    public let connectsProductionEndpoint: Bool

    public var referenceBoundaryHeld: Bool {
        profileReference.isEmpty == false
            && authorizationAnchor.isEmpty == false
            && readsSecretValue == false
            && storesSecretValue == false
            && allowsProductionFallback == false
            && connectsProductionEndpoint == false
            && productionStateBoundaryHeld
    }

    private var productionStateBoundaryHeld: Bool {
        switch environment {
        case .dryRun:
            authorizationState == .localFixtureAuthorized
        case .testnet:
            authorizationState == .testnetReferenceAuthorized
        case .productionBlocked:
            authorizationState == .productionMissingFailClosed
        case .futureProduction:
            authorizationState == .futureProductionManualGateRequired
        }
    }

    public init(
        referenceID: Identifier,
        environment: ProductionCredentialEnvironmentKind,
        profileReference: String,
        authorizationState: ProductionCredentialAuthorizationState,
        authorizationAnchor: String,
        readsSecretValue: Bool = false,
        storesSecretValue: Bool = false,
        allowsProductionFallback: Bool = false,
        connectsProductionEndpoint: Bool = false
    ) throws {
        guard profileReference.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "profileReference",
                expected: "non-empty credential profile reference",
                actual: "empty"
            )
        }
        guard authorizationAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "authorizationAnchor",
                expected: "non-empty credential authorization anchor",
                actual: "empty"
            )
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsSecretValue")
        }
        guard storesSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("storesSecretValue")
        }
        guard allowsProductionFallback == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsProductionFallback")
        }
        guard connectsProductionEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("connectsProductionEndpoint")
        }

        self.referenceID = referenceID
        self.environment = environment
        self.profileReference = profileReference
        self.authorizationState = authorizationState
        self.authorizationAnchor = authorizationAnchor
        self.readsSecretValue = readsSecretValue
        self.storesSecretValue = storesSecretValue
        self.allowsProductionFallback = allowsProductionFallback
        self.connectsProductionEndpoint = connectsProductionEndpoint

        guard referenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "referenceBoundaryHeld",
                expected: "credential reference environment state matches fail-closed contract",
                actual: "\(environment.rawValue):\(authorizationState.rawValue)"
            )
        }
    }
}

/// ProductionCredentialReferenceEnvironmentIsolation 是 GH-644 的 credential reference / environment isolation 合同。
///
/// 合同绑定 GH-643 runtime hardening contract，并把 dry-run、testnet、production-blocked 和
/// future-production 分成明确身份引用。它不读取 secret value，不探测环境变量，不连接 production endpoint，
/// 不允许缺失或模糊环境选择回退到 production。
public struct ProductionCredentialReferenceEnvironmentIsolation: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamRuntimeHardeningContractHeld: Bool
    public let requirements: [ProductionCredentialReferenceRequirement]
    public let forbiddenCapabilities: [ProductionCredentialReferenceForbiddenCapability]
    public let profileReferences: [ProductionCredentialProfileReference]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialIdentityOnlyRequired: Bool
    public let explicitEnvironmentSelectionRequired: Bool
    public let missingAuthorizationFailsClosed: Bool
    public let noProductionFallbackRequired: Bool
    public let readsProductionSecretValue: Bool
    public let probesEnvironmentSecret: Bool
    public let storesSecretValue: Bool
    public let defaultProductionEnvironmentSelected: Bool
    public let ambiguousEnvironmentFallsBackToProduction: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let realBrokerConnectionEnabled: Bool
    public let realOrderSubmissionEnabled: Bool
    public let commandRiskExecutionOMSBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-644"
            && upstreamIssueID.rawValue == "GH-643"
            && downstreamIssueID.rawValue == "GH-645"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName
            && upstreamRuntimeHardeningContractHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && profileReferences == Self.requiredProfileReferences
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && credentialIdentityOnlyRequired
            && explicitEnvironmentSelectionRequired
            && missingAuthorizationFailsClosed
            && noProductionFallbackRequired
            && secretAndEndpointDefaultsClosed
            && commandPathBypassRejected
            && startsNextMilestone == false
    }

    public var environmentCoverageHeld: Bool {
        Set(profileReferences.map(\.environment)) == Set(ProductionCredentialEnvironmentKind.allCases)
            && profileReferences.allSatisfy(\.referenceBoundaryHeld)
            && profileReferences.contains { $0.authorizationState == .productionMissingFailClosed }
            && profileReferences.contains { $0.authorizationState == .futureProductionManualGateRequired }
    }

    public var secretAndEndpointDefaultsClosed: Bool {
        readsProductionSecretValue == false
            && probesEnvironmentSecret == false
            && storesSecretValue == false
            && defaultProductionEnvironmentSelected == false
            && ambiguousEnvironmentFallsBackToProduction == false
            && productionEndpointAutoConnectEnabled == false
            && realBrokerConnectionEnabled == false
            && realOrderSubmissionEnabled == false
    }

    public var commandPathBypassRejected: Bool {
        commandRiskExecutionOMSBypassAllowed == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-644-production-credential-reference-environment-isolation"),
        issueID: Identifier = Identifier.constant("GH-644"),
        upstreamIssueID: Identifier = Identifier.constant("GH-643"),
        downstreamIssueID: Identifier = Identifier.constant("GH-645"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = ProductionCutoverRuntimeHardeningContract.requiredProjectName,
        upstreamRuntimeHardeningContractHeld: Bool = true,
        requirements: [ProductionCredentialReferenceRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionCredentialReferenceForbiddenCapability] = Self.requiredForbiddenCapabilities,
        profileReferences: [ProductionCredentialProfileReference] = Self.requiredProfileReferences,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        credentialIdentityOnlyRequired: Bool = true,
        explicitEnvironmentSelectionRequired: Bool = true,
        missingAuthorizationFailsClosed: Bool = true,
        noProductionFallbackRequired: Bool = true,
        readsProductionSecretValue: Bool = false,
        probesEnvironmentSecret: Bool = false,
        storesSecretValue: Bool = false,
        defaultProductionEnvironmentSelected: Bool = false,
        ambiguousEnvironmentFallsBackToProduction: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        realBrokerConnectionEnabled: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        commandRiskExecutionOMSBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            profileReferences: profileReferences,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamRuntimeHardeningContractHeld: upstreamRuntimeHardeningContractHeld,
            credentialIdentityOnlyRequired: credentialIdentityOnlyRequired,
            explicitEnvironmentSelectionRequired: explicitEnvironmentSelectionRequired,
            missingAuthorizationFailsClosed: missingAuthorizationFailsClosed,
            noProductionFallbackRequired: noProductionFallbackRequired
        )
        try Self.validateForbiddenFlags(
            readsProductionSecretValue: readsProductionSecretValue,
            probesEnvironmentSecret: probesEnvironmentSecret,
            storesSecretValue: storesSecretValue,
            defaultProductionEnvironmentSelected: defaultProductionEnvironmentSelected,
            ambiguousEnvironmentFallsBackToProduction: ambiguousEnvironmentFallsBackToProduction,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            realBrokerConnectionEnabled: realBrokerConnectionEnabled,
            realOrderSubmissionEnabled: realOrderSubmissionEnabled,
            commandRiskExecutionOMSBypassAllowed: commandRiskExecutionOMSBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamRuntimeHardeningContractHeld = upstreamRuntimeHardeningContractHeld
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.profileReferences = profileReferences
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialIdentityOnlyRequired = credentialIdentityOnlyRequired
        self.explicitEnvironmentSelectionRequired = explicitEnvironmentSelectionRequired
        self.missingAuthorizationFailsClosed = missingAuthorizationFailsClosed
        self.noProductionFallbackRequired = noProductionFallbackRequired
        self.readsProductionSecretValue = readsProductionSecretValue
        self.probesEnvironmentSecret = probesEnvironmentSecret
        self.storesSecretValue = storesSecretValue
        self.defaultProductionEnvironmentSelected = defaultProductionEnvironmentSelected
        self.ambiguousEnvironmentFallsBackToProduction = ambiguousEnvironmentFallsBackToProduction
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.realBrokerConnectionEnabled = realBrokerConnectionEnabled
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.commandRiskExecutionOMSBypassAllowed = commandRiskExecutionOMSBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionCredentialReferenceEnvironmentIsolation {
        let upstream = try ProductionCutoverRuntimeHardeningContract.deterministicFixture()
        return try ProductionCredentialReferenceEnvironmentIsolation(
            upstreamRuntimeHardeningContractHeld: upstream.contractHeld
        )
    }

    public static let requiredRequirements = ProductionCredentialReferenceRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionCredentialReferenceForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME",
        "PCHR-02-CREDENTIAL-IDENTITY-PROFILE-REFERENCE",
        "PCHR-02-DRYRUN-TESTNET-PRODUCTION-ENVIRONMENT-ISOLATION",
        "PCHR-02-MISSING-AUTHORIZATION-FAIL-CLOSED",
        "PCHR-02-NO-PRODUCTION-FALLBACK",
        "PCHR-02-NO-PRODUCTION-SECRET-VALUE-READ",
        "TVM-PCHR-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH644CredentialReferenceEnvironmentIsolationFailsClosedWithoutSecretRead",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredProfileReferences: [ProductionCredentialProfileReference] = {
        do {
            return [
                try ProductionCredentialProfileReference(
                    referenceID: Identifier.constant("gh-644-dry-run-profile-reference"),
                    environment: .dryRun,
                    profileReference: "local-fixture-profile-reference",
                    authorizationState: .localFixtureAuthorized,
                    authorizationAnchor: "PCHR-02-DRYRUN-AUTHORIZED-LOCAL-FIXTURE"
                ),
                try ProductionCredentialProfileReference(
                    referenceID: Identifier.constant("gh-644-testnet-profile-reference"),
                    environment: .testnet,
                    profileReference: "binance-testnet-profile-reference",
                    authorizationState: .testnetReferenceAuthorized,
                    authorizationAnchor: "PCHR-02-TESTNET-AUTHORIZED-REFERENCE"
                ),
                try ProductionCredentialProfileReference(
                    referenceID: Identifier.constant("gh-644-production-blocked-profile-reference"),
                    environment: .productionBlocked,
                    profileReference: "production-profile-reference-blocked",
                    authorizationState: .productionMissingFailClosed,
                    authorizationAnchor: "PCHR-02-PRODUCTION-MISSING-AUTHORIZATION-FAIL-CLOSED"
                ),
                try ProductionCredentialProfileReference(
                    referenceID: Identifier.constant("gh-644-future-production-profile-reference"),
                    environment: .futureProduction,
                    profileReference: "future-production-profile-reference",
                    authorizationState: .futureProductionManualGateRequired,
                    authorizationAnchor: "PCHR-02-FUTURE-PRODUCTION-MANUAL-GATE"
                )
            ]
        } catch {
            preconditionFailure("GH-644 credential profile references must be valid: \(error)")
        }
    }()
}

private extension ProductionCredentialReferenceEnvironmentIsolation {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        requirements: [ProductionCredentialReferenceRequirement],
        forbiddenCapabilities: [ProductionCredentialReferenceForbiddenCapability],
        profileReferences: [ProductionCredentialProfileReference],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-643..GH-649", "GH-643..GH-649", canonicalQueueRange),
            (
                "projectName",
                projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                projectName
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "profileReferences",
                profileReferences == requiredProfileReferences,
                requiredProfileReferences.map(\.referenceID.rawValue).joined(separator: ","),
                profileReferences.map(\.referenceID.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        upstreamRuntimeHardeningContractHeld: Bool,
        credentialIdentityOnlyRequired: Bool,
        explicitEnvironmentSelectionRequired: Bool,
        missingAuthorizationFailsClosed: Bool,
        noProductionFallbackRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamRuntimeHardeningContractHeld", upstreamRuntimeHardeningContractHeld),
            ("credentialIdentityOnlyRequired", credentialIdentityOnlyRequired),
            ("explicitEnvironmentSelectionRequired", explicitEnvironmentSelectionRequired),
            ("missingAuthorizationFailsClosed", missingAuthorizationFailsClosed),
            ("noProductionFallbackRequired", noProductionFallbackRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        readsProductionSecretValue: Bool,
        probesEnvironmentSecret: Bool,
        storesSecretValue: Bool,
        defaultProductionEnvironmentSelected: Bool,
        ambiguousEnvironmentFallsBackToProduction: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        realBrokerConnectionEnabled: Bool,
        realOrderSubmissionEnabled: Bool,
        commandRiskExecutionOMSBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("readsProductionSecretValue", readsProductionSecretValue),
            ("probesEnvironmentSecret", probesEnvironmentSecret),
            ("storesSecretValue", storesSecretValue),
            ("defaultProductionEnvironmentSelected", defaultProductionEnvironmentSelected),
            ("ambiguousEnvironmentFallsBackToProduction", ambiguousEnvironmentFallsBackToProduction),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("realBrokerConnectionEnabled", realBrokerConnectionEnabled),
            ("realOrderSubmissionEnabled", realOrderSubmissionEnabled),
            ("commandRiskExecutionOMSBypassAllowed", commandRiskExecutionOMSBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
