import DomainModel
import Foundation

/// ProductionCutoverCredentialPolicyScope 固定 GH-503 可以讨论的 credential / secret 范围。
///
/// 这些 scope 只用于 production cutover readiness evidence。它们不读取环境变量值、
/// 不保存 secret、不连接 signed endpoint，也不允许 sandbox command 推导 production credential。
public enum ProductionCutoverCredentialPolicyScope: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFixture = "local fixture"
    case dryRun = "dry-run"
    case productionBlocked = "production blocked"
    case futureProductionCredential = "future production credential"
}

/// ProductionCutoverSecretPolicyGate 描述 GH-503 的 secret policy gate。
///
/// Gate 只表达后续 cutover 前必须证明的边界；它不是 credential provider、secret store、
/// key rotation service、signed request builder 或 broker credential runtime。
public enum ProductionCutoverSecretPolicyGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noDefaultSecretRead = "no default secret read"
    case noEnvironmentSecretProbe = "no environment secret probe"
    case localFixtureDryRunProductionIsolation = "local / fixture / dry-run / production isolation"
    case sandboxCommandCredentialIsolation = "sandbox command credential isolation"
    case secretStorageFutureGateOnly = "secret storage future gate only"
    case secretInjectionFutureGateOnly = "secret injection future gate only"
    case secretRotationFutureGateOnly = "secret rotation future gate only"
    case productionBlockedEvidence = "production blocked evidence"
}

/// ProductionCutoverCredentialForbiddenCapability 枚举 GH-503 必须继续关闭的能力。
///
/// 这些值可以进入 readiness matrix 和 tests，但不能变成当前仓库的 secret probe、
/// production endpoint call、broker adapter、OMS、Live command 或真实订单能力。
public enum ProductionCutoverCredentialForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case defaultSecretRead = "default secret read"
    case environmentSecretProbe = "environment secret probe"
    case plaintextCredentialInRepository = "plaintext credential in repository"
    case apiKeyStorage = "API key storage"
    case apiSecretStorage = "API secret storage"
    case apiKeyHeaderConstruction = "API-key header construction"
    case requestSignatureGeneration = "request signature generation"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case brokerConnection = "broker connection"
    case sandboxCommandPromotesProductionCredential = "sandbox command promotes production credential"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// ProductionCutoverCredentialReadinessEvidence 是 GH-503 的 deterministic evidence row。
///
/// Evidence row 只能描述身份、scope 和 blocked reason。它不得携带 secret value、
/// production credential path、API key header 或任何可执行 broker 连接信息。
public struct ProductionCutoverCredentialReadinessEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let scope: ProductionCutoverCredentialPolicyScope
    public let expectedEvidence: String
    public let blockedReason: String
    public let readsSecretValue: Bool
    public let allowsProductionCredential: Bool
    public let allowsSandboxToProductionPromotion: Bool

    public init(
        evidenceID: Identifier,
        scope: ProductionCutoverCredentialPolicyScope,
        expectedEvidence: String,
        blockedReason: String,
        readsSecretValue: Bool = false,
        allowsProductionCredential: Bool = false,
        allowsSandboxToProductionPromotion: Bool = false
    ) throws {
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty credential readiness evidence",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty production blocked reason",
                actual: "empty"
            )
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsSecretValue")
        }
        guard allowsProductionCredential == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsProductionCredential")
        }
        guard allowsSandboxToProductionPromotion == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsSandboxToProductionPromotion")
        }

        self.evidenceID = evidenceID
        self.scope = scope
        self.expectedEvidence = expectedEvidence
        self.blockedReason = blockedReason
        self.readsSecretValue = readsSecretValue
        self.allowsProductionCredential = allowsProductionCredential
        self.allowsSandboxToProductionPromotion = allowsSandboxToProductionPromotion
    }
}

/// ProductionCutoverCredentialSecretPolicyGate 是 GH-503 的 credential / secret policy cutover gate。
///
/// 合同只定义 production cutover 前的 no-default-secret-read、local / fixture / dry-run /
/// production credential 隔离和 future secret storage / injection / rotation gate。它不实现
/// API key / secret storage，不读取真实 secret，不连接 broker，不接 signed/account endpoint。
public struct ProductionCutoverCredentialSecretPolicyGate: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let projectName: String
    public let canonicalQueueRange: String
    public let scopes: [ProductionCutoverCredentialPolicyScope]
    public let gates: [ProductionCutoverSecretPolicyGate]
    public let forbiddenCapabilities: [ProductionCutoverCredentialForbiddenCapability]
    public let readinessEvidence: [ProductionCutoverCredentialReadinessEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let noDefaultSecretReadRequired: Bool
    public let localFixtureDryRunProductionIsolationRequired: Bool
    public let secretStorageFutureGateOnly: Bool
    public let secretInjectionRotationFutureGateOnly: Bool
    public let productionBlockedByDefault: Bool
    public let readsSecretValue: Bool
    public let probesEnvironmentSecret: Bool
    public let storesAPIKey: Bool
    public let storesAPISecret: Bool
    public let constructsAPIKeyHeader: Bool
    public let generatesRequestSignature: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let sandboxCommandPromotesProductionCredential: Bool
    public let productionTradingEnabledByDefault: Bool
    public let implementsExecutionClientAdapter: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-503"
            && projectName == Self.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && scopes == Self.requiredScopes
            && gates == Self.requiredGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && readinessEvidence == Self.requiredReadinessEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && noDefaultSecretReadRequired
            && localFixtureDryRunProductionIsolationRequired
            && secretStorageFutureGateOnly
            && secretInjectionRotationFutureGateOnly
            && productionBlockedByDefault
            && allForbiddenFlagsRemainClosed
    }

    public var readinessEvidenceCoverageHeld: Bool {
        Set(readinessEvidence.map(\.scope)) == Set(ProductionCutoverCredentialPolicyScope.allCases)
            && readinessEvidence.allSatisfy { $0.readsSecretValue == false }
            && readinessEvidence.allSatisfy { $0.allowsProductionCredential == false }
            && readinessEvidence.allSatisfy { $0.allowsSandboxToProductionPromotion == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            readsSecretValue,
            probesEnvironmentSecret,
            storesAPIKey,
            storesAPISecret,
            constructsAPIKeyHeader,
            generatesRequestSignature,
            callsSignedEndpoint,
            callsAccountEndpoint,
            createsListenKey,
            connectsBroker,
            sandboxCommandPromotesProductionCredential,
            productionTradingEnabledByDefault,
            implementsExecutionClientAdapter,
            implementsOMS,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-503-production-cutover-credential-secret-policy-gate"),
        issueID: Identifier = Identifier.constant("GH-503"),
        projectName: String = Self.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        scopes: [ProductionCutoverCredentialPolicyScope] = Self.requiredScopes,
        gates: [ProductionCutoverSecretPolicyGate] = Self.requiredGates,
        forbiddenCapabilities: [ProductionCutoverCredentialForbiddenCapability] = Self.requiredForbiddenCapabilities,
        readinessEvidence: [ProductionCutoverCredentialReadinessEvidence] = Self.requiredReadinessEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        noDefaultSecretReadRequired: Bool = true,
        localFixtureDryRunProductionIsolationRequired: Bool = true,
        secretStorageFutureGateOnly: Bool = true,
        secretInjectionRotationFutureGateOnly: Bool = true,
        productionBlockedByDefault: Bool = true,
        readsSecretValue: Bool = false,
        probesEnvironmentSecret: Bool = false,
        storesAPIKey: Bool = false,
        storesAPISecret: Bool = false,
        constructsAPIKeyHeader: Bool = false,
        generatesRequestSignature: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        sandboxCommandPromotesProductionCredential: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        implementsExecutionClientAdapter: Bool = false,
        implementsOMS: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        try Self.validateRequired(
            scopes: scopes,
            gates: gates,
            forbiddenCapabilities: forbiddenCapabilities,
            readinessEvidence: readinessEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            noDefaultSecretReadRequired: noDefaultSecretReadRequired,
            localFixtureDryRunProductionIsolationRequired: localFixtureDryRunProductionIsolationRequired,
            secretStorageFutureGateOnly: secretStorageFutureGateOnly,
            secretInjectionRotationFutureGateOnly: secretInjectionRotationFutureGateOnly,
            productionBlockedByDefault: productionBlockedByDefault
        )
        try Self.validateForbiddenFlags(
            readsSecretValue: readsSecretValue,
            probesEnvironmentSecret: probesEnvironmentSecret,
            storesAPIKey: storesAPIKey,
            storesAPISecret: storesAPISecret,
            constructsAPIKeyHeader: constructsAPIKeyHeader,
            generatesRequestSignature: generatesRequestSignature,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            sandboxCommandPromotesProductionCredential: sandboxCommandPromotesProductionCredential,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            implementsExecutionClientAdapter: implementsExecutionClientAdapter,
            implementsOMS: implementsOMS,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.contractID = contractID
        self.issueID = issueID
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.scopes = scopes
        self.gates = gates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.readinessEvidence = readinessEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.noDefaultSecretReadRequired = noDefaultSecretReadRequired
        self.localFixtureDryRunProductionIsolationRequired = localFixtureDryRunProductionIsolationRequired
        self.secretStorageFutureGateOnly = secretStorageFutureGateOnly
        self.secretInjectionRotationFutureGateOnly = secretInjectionRotationFutureGateOnly
        self.productionBlockedByDefault = productionBlockedByDefault
        self.readsSecretValue = readsSecretValue
        self.probesEnvironmentSecret = probesEnvironmentSecret
        self.storesAPIKey = storesAPIKey
        self.storesAPISecret = storesAPISecret
        self.constructsAPIKeyHeader = constructsAPIKeyHeader
        self.generatesRequestSignature = generatesRequestSignature
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.sandboxCommandPromotesProductionCredential = sandboxCommandPromotesProductionCredential
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.implementsExecutionClientAdapter = implementsExecutionClientAdapter
        self.implementsOMS = implementsOMS
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public static func deterministicFixture() throws -> ProductionCutoverCredentialSecretPolicyGate {
        try ProductionCutoverCredentialSecretPolicyGate()
    }

    public static let requiredProjectName = "MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1"
    public static let requiredScopes = ProductionCutoverCredentialPolicyScope.allCases
    public static let requiredGates = ProductionCutoverSecretPolicyGate.allCases
    public static let requiredForbiddenCapabilities = ProductionCutoverCredentialForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-503-PRODUCTION-CUTOVER-CREDENTIAL-SECRET-POLICY-GATE",
        "GH-503-NO-DEFAULT-SECRET-READ",
        "GH-503-LOCAL-FIXTURE-DRY-RUN-PRODUCTION-ISOLATION",
        "GH-503-FUTURE-SECRET-STORAGE-INJECTION-ROTATION-GATE",
        "GH-503-PRODUCTION-BLOCKED-EVIDENCE"
    ]

    public static let requiredValidationCommands = [
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredReadinessEvidence: [ProductionCutoverCredentialReadinessEvidence] = {
        do {
            return [
                try ProductionCutoverCredentialReadinessEvidence(
                    evidenceID: Identifier.constant("gh-503-local-fixture-secret-read-blocked"),
                    scope: .localFixture,
                    expectedEvidence: "local fixtures keep credential identity separate from secret value",
                    blockedReason: "local fixture must not read or print production secret"
                ),
                try ProductionCutoverCredentialReadinessEvidence(
                    evidenceID: Identifier.constant("gh-503-dry-run-secret-read-blocked"),
                    scope: .dryRun,
                    expectedEvidence: "dry-run command keeps production credential path absent",
                    blockedReason: "dry-run must not infer production credential path"
                ),
                try ProductionCutoverCredentialReadinessEvidence(
                    evidenceID: Identifier.constant("gh-503-production-blocked-secret-read-blocked"),
                    scope: .productionBlocked,
                    expectedEvidence: "production remains blocked until a future cutover gate",
                    blockedReason: "production credential cannot be loaded by default"
                ),
                try ProductionCutoverCredentialReadinessEvidence(
                    evidenceID: Identifier.constant("gh-503-future-production-secret-gate-only"),
                    scope: .futureProductionCredential,
                    expectedEvidence: "secret storage, injection and rotation remain future-gated",
                    blockedReason: "future production credential is not a current runtime capability"
                )
            ]
        } catch {
            preconditionFailure("GH-503 deterministic credential readiness evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverCredentialSecretPolicyGate {
    static func validateRequired(
        scopes: [ProductionCutoverCredentialPolicyScope],
        gates: [ProductionCutoverSecretPolicyGate],
        forbiddenCapabilities: [ProductionCutoverCredentialForbiddenCapability],
        readinessEvidence: [ProductionCutoverCredentialReadinessEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "scopes",
                scopes == requiredScopes,
                requiredScopes.map(\.rawValue).joined(separator: ","),
                scopes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "gates",
                gates == requiredGates,
                requiredGates.map(\.rawValue).joined(separator: ","),
                gates.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "readinessEvidence",
                readinessEvidence == requiredReadinessEvidence,
                "GH-503 required credential readiness evidence",
                readinessEvidence.map(\.evidenceID.rawValue).joined(separator: ",")
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
        noDefaultSecretReadRequired: Bool,
        localFixtureDryRunProductionIsolationRequired: Bool,
        secretStorageFutureGateOnly: Bool,
        secretInjectionRotationFutureGateOnly: Bool,
        productionBlockedByDefault: Bool
    ) throws {
        let requiredTrueFlags = [
            ("noDefaultSecretReadRequired", noDefaultSecretReadRequired),
            ("localFixtureDryRunProductionIsolationRequired", localFixtureDryRunProductionIsolationRequired),
            ("secretStorageFutureGateOnly", secretStorageFutureGateOnly),
            ("secretInjectionRotationFutureGateOnly", secretInjectionRotationFutureGateOnly),
            ("productionBlockedByDefault", productionBlockedByDefault)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        readsSecretValue: Bool,
        probesEnvironmentSecret: Bool,
        storesAPIKey: Bool,
        storesAPISecret: Bool,
        constructsAPIKeyHeader: Bool,
        generatesRequestSignature: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        sandboxCommandPromotesProductionCredential: Bool,
        productionTradingEnabledByDefault: Bool,
        implementsExecutionClientAdapter: Bool,
        implementsOMS: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("readsSecretValue", readsSecretValue),
            ("probesEnvironmentSecret", probesEnvironmentSecret),
            ("storesAPIKey", storesAPIKey),
            ("storesAPISecret", storesAPISecret),
            ("constructsAPIKeyHeader", constructsAPIKeyHeader),
            ("generatesRequestSignature", generatesRequestSignature),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("sandboxCommandPromotesProductionCredential", sandboxCommandPromotesProductionCredential),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("implementsExecutionClientAdapter", implementsExecutionClientAdapter),
            ("implementsOMS", implementsOMS),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
