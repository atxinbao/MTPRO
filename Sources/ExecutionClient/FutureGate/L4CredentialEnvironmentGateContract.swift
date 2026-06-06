import DomainModel
import Foundation

/// L4CredentialEnvironmentScope 固定 GH-453 允许讨论的环境范围。
///
/// 这些 scope 只用于配置合同、文档和 deterministic tests。它们不代表当前已经存在
/// sandbox runtime、production runtime、signed endpoint、private stream 或真实 broker 连接。
public enum L4CredentialEnvironmentScope: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case local = "local"
    case continuousIntegration = "CI"
    case sandbox = "sandbox"
    case production = "production"
}

/// L4CredentialSourceIdentity 描述 GH-453 可以保存在仓库中的 credential 身份信息。
///
/// 身份信息只能说明“从哪里取得 credential”或“哪个 gate 必须保持关闭”，不能包含 API key、
/// secret value、signed payload、listenKey、account payload 或 broker credential。
public enum L4CredentialSourceIdentity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case venueEnvironment = "venue environment"
    case credentialReference = "credential reference"
    case sandboxOnlyFlag = "sandbox-only flag"
    case productionCutoverFlag = "production cutover flag"
    case forbiddenCredentialValue = "forbidden credential value"
}

/// L4CredentialEnvironmentGate 描述 credential / environment 进入 L4 后续 issue 前的门禁。
///
/// Gate 只表达 validation 需要证明的边界。GH-453 不读取环境变量值、不连接网络、不实现
/// signed endpoint，也不允许把 sandbox 配置升级成 production trading 默认打开。
public enum L4CredentialEnvironmentGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case githubFallbackQueueWIP1 = "GitHub fallback queue WIP=1"
    case l4CommandContractComplete = "GH-452 L4 command contract complete"
    case credentialSourceIdentityRequired = "credential source identity required"
    case secretValueRedactionRequired = "secret value redaction required"
    case sandboxOnlyEnablementGate = "sandbox-only enablement gate"
    case productionDisabledByDefault = "production disabled by default"
    case productionCutoverBlockedUntilGH471 = "production cutover blocked until GH-471"
    case localValidationRejectsSecretValue = "local validation rejects secret value"
    case ciValidationRejectsProductionDefault = "CI validation rejects production default"
    case networkIndependentValidation = "network-independent validation"
}

/// L4CredentialEnvironmentForbiddenCapability 枚举 GH-453 必须保持关闭的能力。
///
/// 这些值可以进入 PR evidence 和后续 issue 的验收锚点，但不能变成当前 Swift runtime、
/// shell secret probe、network request、broker adapter、Dashboard command 或 production shortcut。
public enum L4CredentialEnvironmentForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case plaintextCredentialInRepository = "plaintext credential in repository"
    case credentialValueRead = "credential value read"
    case credentialValuePrint = "credential value print"
    case secretStorage = "secret storage"
    case apiKeyHeaderConstruction = "API-key header construction"
    case requestSignatureGeneration = "request signature generation"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case privateStreamOpen = "private stream open"
    case sandboxNetworkConnection = "sandbox network connection"
    case productionNetworkConnection = "production network connection"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionCutoverBeforeGH471 = "production cutover before GH-471"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4CredentialEnvironmentValidationRule 是 GH-453 的环境变量身份和验证规则。
///
/// `environmentVariableName` 只能是配置键名，不能是 secret value。`expectedEvidence`
/// 说明 local / CI validation 应该证明什么；所有 rule 默认拒绝 secret value、production
/// default 和网络连接，确保当前仓库只留下可审计合同，不留下可执行 credential。
public struct L4CredentialEnvironmentValidationRule: Codable, Equatable, Sendable {
    public let environmentVariableName: String
    public let sourceIdentity: L4CredentialSourceIdentity
    public let allowedScopes: [L4CredentialEnvironmentScope]
    public let expectedEvidence: String
    public let allowsSecretValue: Bool
    public let allowsProductionDefault: Bool
    public let allowsNetworkConnection: Bool

    public init(
        environmentVariableName: String,
        sourceIdentity: L4CredentialSourceIdentity,
        allowedScopes: [L4CredentialEnvironmentScope],
        expectedEvidence: String,
        allowsSecretValue: Bool = false,
        allowsProductionDefault: Bool = false,
        allowsNetworkConnection: Bool = false
    ) throws {
        guard environmentVariableName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "environmentVariableName",
                expected: "non-empty environment variable identity",
                actual: "empty"
            )
        }
        guard allowedScopes.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedScopes",
                expected: "non-empty environment scope list",
                actual: "empty"
            )
        }
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty validation evidence",
                actual: "empty"
            )
        }
        guard allowsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsSecretValue")
        }
        guard allowsProductionDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsProductionDefault")
        }
        guard allowsNetworkConnection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsNetworkConnection")
        }

        self.environmentVariableName = environmentVariableName
        self.sourceIdentity = sourceIdentity
        self.allowedScopes = allowedScopes
        self.expectedEvidence = expectedEvidence
        self.allowsSecretValue = allowsSecretValue
        self.allowsProductionDefault = allowsProductionDefault
        self.allowsNetworkConnection = allowsNetworkConnection
    }
}

/// L4CredentialEnvironmentGateContract 是 GH-453 的 credential / environment gate 合同。
///
/// 合同只定义 credential source identity、sandbox-only enablement、production cutover
/// 阻断和 local / CI validation 要求。所有 secret value、signed endpoint、private stream、
/// ExecutionClient adapter、OMS、真实 submit / cancel / replace、Live PRO Console 和
/// production trading 旗标必须保持关闭；后续 GH-454 / GH-455 才能在各自 scope 内继续细化。
public struct L4CredentialEnvironmentGateContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let maturitySlice: String
    public let scopes: [L4CredentialEnvironmentScope]
    public let sourceIdentities: [L4CredentialSourceIdentity]
    public let gates: [L4CredentialEnvironmentGate]
    public let validationRules: [L4CredentialEnvironmentValidationRule]
    public let forbiddenCapabilities: [L4CredentialEnvironmentForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialSourceIdentityRequired: Bool
    public let sandboxOnlyGateRequired: Bool
    public let productionDisabledByDefault: Bool
    public let productionCutoverRequiresGH471: Bool
    public let localValidationMustRejectSecrets: Bool
    public let ciValidationMustRejectProductionDefault: Bool
    public let networkIndependentValidationRequired: Bool
    public let allowsPlaintextCredentialInRepository: Bool
    public let readsCredentialValue: Bool
    public let printsCredentialValue: Bool
    public let storesSecret: Bool
    public let constructsAPIKeyHeader: Bool
    public let generatesRequestSignature: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateStream: Bool
    public let connectsSandboxNetwork: Bool
    public let connectsProductionNetwork: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAllowedBeforeGH471: Bool
    public let implementsExecutionClientAdapter: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let exposesLiveProConsoleCommandSurface: Bool
    public let exposesOrderForm: Bool

    public var contractHeld: Bool {
        upstreamIssueID.rawValue == "GH-452"
            && canonicalQueueRange == "GH-452..GH-472"
            && scopes == Self.requiredScopes
            && sourceIdentities == Self.requiredSourceIdentities
            && gates == Self.requiredGates
            && validationRules == Self.requiredValidationRules
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && credentialSourceIdentityRequired
            && sandboxOnlyGateRequired
            && productionDisabledByDefault
            && productionCutoverRequiresGH471
            && localValidationMustRejectSecrets
            && ciValidationMustRejectProductionDefault
            && networkIndependentValidationRequired
            && allForbiddenFlagsRemainClosed
    }

    public var validationRulesCoverageHeld: Bool {
        Set(validationRules.map(\.sourceIdentity)) == Set(L4CredentialSourceIdentity.allCases)
            && validationRules.allSatisfy { $0.environmentVariableName.hasPrefix("MTPRO_L4_") }
            && validationRules.allSatisfy { $0.allowsSecretValue == false }
            && validationRules.allSatisfy { $0.allowsProductionDefault == false }
            && validationRules.allSatisfy { $0.allowsNetworkConnection == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            allowsPlaintextCredentialInRepository,
            readsCredentialValue,
            printsCredentialValue,
            storesSecret,
            constructsAPIKeyHeader,
            generatesRequestSignature,
            callsSignedEndpoint,
            callsAccountEndpoint,
            createsListenKey,
            opensPrivateStream,
            connectsSandboxNetwork,
            connectsProductionNetwork,
            productionTradingEnabledByDefault,
            productionCutoverAllowedBeforeGH471,
            implementsExecutionClientAdapter,
            implementsOMS,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            exposesLiveProConsoleCommandSurface,
            exposesOrderForm
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-453-l4-credential-environment-gate-contract"),
        issueID: Identifier = Identifier.constant("GH-453"),
        upstreamIssueID: Identifier = Identifier.constant("GH-452"),
        canonicalQueueRange: String = "GH-452..GH-472",
        maturitySlice: String = "MTPRO L4 Live Production / Trading Commands v1",
        scopes: [L4CredentialEnvironmentScope] = Self.requiredScopes,
        sourceIdentities: [L4CredentialSourceIdentity] = Self.requiredSourceIdentities,
        gates: [L4CredentialEnvironmentGate] = Self.requiredGates,
        validationRules: [L4CredentialEnvironmentValidationRule] = Self.requiredValidationRules,
        forbiddenCapabilities: [L4CredentialEnvironmentForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        credentialSourceIdentityRequired: Bool = true,
        sandboxOnlyGateRequired: Bool = true,
        productionDisabledByDefault: Bool = true,
        productionCutoverRequiresGH471: Bool = true,
        localValidationMustRejectSecrets: Bool = true,
        ciValidationMustRejectProductionDefault: Bool = true,
        networkIndependentValidationRequired: Bool = true,
        allowsPlaintextCredentialInRepository: Bool = false,
        readsCredentialValue: Bool = false,
        printsCredentialValue: Bool = false,
        storesSecret: Bool = false,
        constructsAPIKeyHeader: Bool = false,
        generatesRequestSignature: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateStream: Bool = false,
        connectsSandboxNetwork: Bool = false,
        connectsProductionNetwork: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionCutoverAllowedBeforeGH471: Bool = false,
        implementsExecutionClientAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        exposesLiveProConsoleCommandSurface: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        try Self.validate(
            scopes: scopes,
            sourceIdentities: sourceIdentities,
            gates: gates,
            validationRules: validationRules,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredGates(
            credentialSourceIdentityRequired: credentialSourceIdentityRequired,
            sandboxOnlyGateRequired: sandboxOnlyGateRequired,
            productionDisabledByDefault: productionDisabledByDefault,
            productionCutoverRequiresGH471: productionCutoverRequiresGH471,
            localValidationMustRejectSecrets: localValidationMustRejectSecrets,
            ciValidationMustRejectProductionDefault: ciValidationMustRejectProductionDefault,
            networkIndependentValidationRequired: networkIndependentValidationRequired
        )
        try Self.validateForbiddenFlags(
            allowsPlaintextCredentialInRepository: allowsPlaintextCredentialInRepository,
            readsCredentialValue: readsCredentialValue,
            printsCredentialValue: printsCredentialValue,
            storesSecret: storesSecret,
            constructsAPIKeyHeader: constructsAPIKeyHeader,
            generatesRequestSignature: generatesRequestSignature,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateStream: opensPrivateStream,
            connectsSandboxNetwork: connectsSandboxNetwork,
            connectsProductionNetwork: connectsProductionNetwork,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionCutoverAllowedBeforeGH471: productionCutoverAllowedBeforeGH471,
            implementsExecutionClientAdapter: implementsExecutionClientAdapter,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            exposesLiveProConsoleCommandSurface: exposesLiveProConsoleCommandSurface,
            exposesOrderForm: exposesOrderForm
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.maturitySlice = maturitySlice
        self.scopes = scopes
        self.sourceIdentities = sourceIdentities
        self.gates = gates
        self.validationRules = validationRules
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialSourceIdentityRequired = credentialSourceIdentityRequired
        self.sandboxOnlyGateRequired = sandboxOnlyGateRequired
        self.productionDisabledByDefault = productionDisabledByDefault
        self.productionCutoverRequiresGH471 = productionCutoverRequiresGH471
        self.localValidationMustRejectSecrets = localValidationMustRejectSecrets
        self.ciValidationMustRejectProductionDefault = ciValidationMustRejectProductionDefault
        self.networkIndependentValidationRequired = networkIndependentValidationRequired
        self.allowsPlaintextCredentialInRepository = allowsPlaintextCredentialInRepository
        self.readsCredentialValue = readsCredentialValue
        self.printsCredentialValue = printsCredentialValue
        self.storesSecret = storesSecret
        self.constructsAPIKeyHeader = constructsAPIKeyHeader
        self.generatesRequestSignature = generatesRequestSignature
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateStream = opensPrivateStream
        self.connectsSandboxNetwork = connectsSandboxNetwork
        self.connectsProductionNetwork = connectsProductionNetwork
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAllowedBeforeGH471 = productionCutoverAllowedBeforeGH471
        self.implementsExecutionClientAdapter = implementsExecutionClientAdapter
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.exposesLiveProConsoleCommandSurface = exposesLiveProConsoleCommandSurface
        self.exposesOrderForm = exposesOrderForm
    }

    public static func deterministicFixture() throws -> L4CredentialEnvironmentGateContract {
        try L4CredentialEnvironmentGateContract()
    }

    public static let requiredScopes: [L4CredentialEnvironmentScope] =
        L4CredentialEnvironmentScope.allCases

    public static let requiredSourceIdentities: [L4CredentialSourceIdentity] =
        L4CredentialSourceIdentity.allCases

    public static let requiredGates: [L4CredentialEnvironmentGate] =
        L4CredentialEnvironmentGate.allCases

    public static let requiredForbiddenCapabilities: [L4CredentialEnvironmentForbiddenCapability] =
        L4CredentialEnvironmentForbiddenCapability.allCases

    public static let requiredValidationAnchors: [String] = [
        "GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT",
        "GH-453-CREDENTIAL-SOURCE-IDENTITY",
        "GH-453-SANDBOX-ONLY-ENABLEMENT-GATE",
        "GH-453-PRODUCTION-CUTOVER-BLOCKED-UNTIL-GH-471",
        "GH-453-LOCAL-CI-SECRET-PRODUCTION-VALIDATION",
        "GH-453-NON-AUTHORIZATION",
        "TVM-L4-CREDENTIAL-ENVIRONMENT-GATE"
    ]

    public static let requiredValidationCommands: [String] = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredValidationRules: [L4CredentialEnvironmentValidationRule] = {
        do {
            return try [
                L4CredentialEnvironmentValidationRule(
                    environmentVariableName: "MTPRO_L4_VENUE_ENVIRONMENT",
                    sourceIdentity: .venueEnvironment,
                    allowedScopes: [.local, .continuousIntegration, .sandbox, .production],
                    expectedEvidence: "environment identity only; no endpoint connection"
                ),
                L4CredentialEnvironmentValidationRule(
                    environmentVariableName: "MTPRO_L4_CREDENTIAL_REFERENCE",
                    sourceIdentity: .credentialReference,
                    allowedScopes: [.local, .continuousIntegration, .sandbox, .production],
                    expectedEvidence: "external credential reference only; no API key or secret value"
                ),
                L4CredentialEnvironmentValidationRule(
                    environmentVariableName: "MTPRO_L4_SANDBOX_ONLY",
                    sourceIdentity: .sandboxOnlyFlag,
                    allowedScopes: [.local, .continuousIntegration, .sandbox],
                    expectedEvidence: "sandbox-only gate identity; no network call in validation"
                ),
                L4CredentialEnvironmentValidationRule(
                    environmentVariableName: "MTPRO_L4_PRODUCTION_CUTOVER",
                    sourceIdentity: .productionCutoverFlag,
                    allowedScopes: [.production],
                    expectedEvidence: "must remain blocked until GH-471 production cutover gate"
                ),
                L4CredentialEnvironmentValidationRule(
                    environmentVariableName: "MTPRO_L4_CREDENTIAL_VALUE",
                    sourceIdentity: .forbiddenCredentialValue,
                    allowedScopes: [.local, .continuousIntegration, .sandbox, .production],
                    expectedEvidence: "must be absent from repository, logs, fixtures, docs, and validation output"
                )
            ]
        } catch {
            preconditionFailure("GH-453 L4 credential environment validation rules must be valid: \(error)")
        }
    }()

    private static func validate(
        scopes: [L4CredentialEnvironmentScope],
        sourceIdentities: [L4CredentialSourceIdentity],
        gates: [L4CredentialEnvironmentGate],
        validationRules: [L4CredentialEnvironmentValidationRule],
        forbiddenCapabilities: [L4CredentialEnvironmentForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard scopes == Self.requiredScopes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "scopes",
                expected: Self.requiredScopes.map(\.rawValue).joined(separator: ","),
                actual: scopes.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceIdentities == Self.requiredSourceIdentities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentities",
                expected: Self.requiredSourceIdentities.map(\.rawValue).joined(separator: ","),
                actual: sourceIdentities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard gates == Self.requiredGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gates",
                expected: Self.requiredGates.map(\.rawValue).joined(separator: ","),
                actual: gates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationRules == Self.requiredValidationRules else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationRules",
                expected: "GH-453 required validation rules",
                actual: "\(validationRules.map(\.environmentVariableName))"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
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
    }

    private static func validateRequiredGates(
        credentialSourceIdentityRequired: Bool,
        sandboxOnlyGateRequired: Bool,
        productionDisabledByDefault: Bool,
        productionCutoverRequiresGH471: Bool,
        localValidationMustRejectSecrets: Bool,
        ciValidationMustRejectProductionDefault: Bool,
        networkIndependentValidationRequired: Bool
    ) throws {
        for requiredGate in [
            ("credentialSourceIdentityRequired", credentialSourceIdentityRequired),
            ("sandboxOnlyGateRequired", sandboxOnlyGateRequired),
            ("productionDisabledByDefault", productionDisabledByDefault),
            ("productionCutoverRequiresGH471", productionCutoverRequiresGH471),
            ("localValidationMustRejectSecrets", localValidationMustRejectSecrets),
            ("ciValidationMustRejectProductionDefault", ciValidationMustRejectProductionDefault),
            ("networkIndependentValidationRequired", networkIndependentValidationRequired)
        ] where requiredGate.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredGate.0,
                expected: "true",
                actual: "false"
            )
        }
    }

    private static func validateForbiddenFlags(
        allowsPlaintextCredentialInRepository: Bool,
        readsCredentialValue: Bool,
        printsCredentialValue: Bool,
        storesSecret: Bool,
        constructsAPIKeyHeader: Bool,
        generatesRequestSignature: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateStream: Bool,
        connectsSandboxNetwork: Bool,
        connectsProductionNetwork: Bool,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAllowedBeforeGH471: Bool,
        implementsExecutionClientAdapter: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        exposesLiveProConsoleCommandSurface: Bool,
        exposesOrderForm: Bool
    ) throws {
        for forbiddenFlag in [
            ("allowsPlaintextCredentialInRepository", allowsPlaintextCredentialInRepository),
            ("readsCredentialValue", readsCredentialValue),
            ("printsCredentialValue", printsCredentialValue),
            ("storesSecret", storesSecret),
            ("constructsAPIKeyHeader", constructsAPIKeyHeader),
            ("generatesRequestSignature", generatesRequestSignature),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateStream", opensPrivateStream),
            ("connectsSandboxNetwork", connectsSandboxNetwork),
            ("connectsProductionNetwork", connectsProductionNetwork),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionCutoverAllowedBeforeGH471", productionCutoverAllowedBeforeGH471),
            ("implementsExecutionClientAdapter", implementsExecutionClientAdapter),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("exposesLiveProConsoleCommandSurface", exposesLiveProConsoleCommandSurface),
            ("exposesOrderForm", exposesOrderForm)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }
    }
}
