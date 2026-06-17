import DomainModel
import Foundation

/// ReleaseV0100SecretProviderReferenceType 固定 GH-881 允许记录的 secret provider 引用类型。
///
/// 这些类型只描述 provider reference identity，不代表 secret value、secret handle、endpoint session 或 broker credential。
public enum ReleaseV0100SecretProviderReferenceType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case environmentVariableReference = "environmentVariableReference"
    case keychainItemReference = "keychainItemReference"
    case operatorManualReference = "operatorManualReference"
}

/// ReleaseV0100SecretProviderEvidenceArtifactKind 固定 GH-881 必须产生的 readiness evidence 文件。
public enum ReleaseV0100SecretProviderEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case secretReadiness = "secret_readiness.json"
    case redactionProof = "redaction_proof.json"
}

/// ReleaseV0100SecretProviderReadinessRequirement 固定 GH-881 的 secret provider readiness 合同要求。
public enum ReleaseV0100SecretProviderReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamProductionEnvironmentProfileRequired = "upstream production environment profile required"
    case credentialReferenceExists = "credential reference exists"
    case providerTypeDeclared = "provider type declared"
    case redactionPolicyRequired = "redaction policy required"
    case secretReadinessEvidenceExists = "secret_readiness.json evidence exists"
    case redactionProofEvidenceExists = "redaction_proof.json evidence exists"
    case ciNoSecretProofRequired = "ci no secret proof required"
    case manualSecretGateRequired = "manual secret gate required"
    case referenceOnlyPersistence = "reference-only persistence"
}

/// ReleaseV0100SecretProviderForbiddenCapability 枚举 GH-881 必须拒绝的能力。
public enum ReleaseV0100SecretProviderForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionSecretValueRead = "production secret value read"
    case productionSecretValueStored = "production secret value stored"
    case secretValuePrinted = "secret value printed"
    case dashboardSecretDisplay = "dashboard secret display"
    case ciSecretAvailability = "CI secret availability"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionCutoverAuthorization = "production cutover authorization"
    case orderSubmissionEnabled = "order submission enabled"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonEnabled = "trading button enabled"
    case orderFormEnabled = "order form enabled"
    case liveCommandEnabled = "live command enabled"
}

/// ReleaseV0100SecretProviderReference 是 GH-881 的 credential reference row。
///
/// Row 只保存 provider reference identity、provider type 和 redaction policy。它不保存 secret value，
/// 不读取 secret，不打印 secret，不把 secret 暴露给 Dashboard，也不要求 CI 存在 secret。
public struct ReleaseV0100SecretProviderReference: Codable, Equatable, Sendable {
    public let referenceID: Identifier
    public let providerType: ReleaseV0100SecretProviderReferenceType
    public let credentialReferenceExists: Bool
    public let redactionPolicy: String
    public let operatorConfirmationRequired: Bool
    public let storesSecretValue: Bool
    public let readsSecretValue: Bool
    public let printsSecretValue: Bool
    public let dashboardDisplaysSecretValue: Bool
    public let ciSecretAvailable: Bool

    public var referenceOnlyHeld: Bool {
        credentialReferenceExists
            && redactionPolicy == ReleaseV0100SecretProviderReadinessGate.requiredRedactionPolicy
            && operatorConfirmationRequired
            && storesSecretValue == false
            && readsSecretValue == false
            && printsSecretValue == false
            && dashboardDisplaysSecretValue == false
            && ciSecretAvailable == false
    }

    public init(
        referenceID: Identifier,
        providerType: ReleaseV0100SecretProviderReferenceType,
        credentialReferenceExists: Bool = true,
        redactionPolicy: String = ReleaseV0100SecretProviderReadinessGate.requiredRedactionPolicy,
        operatorConfirmationRequired: Bool = true,
        storesSecretValue: Bool = false,
        readsSecretValue: Bool = false,
        printsSecretValue: Bool = false,
        dashboardDisplaysSecretValue: Bool = false,
        ciSecretAvailable: Bool = false
    ) throws {
        guard credentialReferenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialReferenceExists",
                expected: "true",
                actual: "false"
            )
        }
        guard redactionPolicy == ReleaseV0100SecretProviderReadinessGate.requiredRedactionPolicy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "redactionPolicy",
                expected: ReleaseV0100SecretProviderReadinessGate.requiredRedactionPolicy,
                actual: redactionPolicy
            )
        }
        guard operatorConfirmationRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "operatorConfirmationRequired",
                expected: "true",
                actual: "false"
            )
        }
        guard storesSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("storesSecretValue")
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsSecretValue")
        }
        guard printsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("printsSecretValue")
        }
        guard dashboardDisplaysSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardDisplaysSecretValue")
        }
        guard ciSecretAvailable == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("ciSecretAvailable")
        }

        self.referenceID = referenceID
        self.providerType = providerType
        self.credentialReferenceExists = credentialReferenceExists
        self.redactionPolicy = redactionPolicy
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.storesSecretValue = storesSecretValue
        self.readsSecretValue = readsSecretValue
        self.printsSecretValue = printsSecretValue
        self.dashboardDisplaysSecretValue = dashboardDisplaysSecretValue
        self.ciSecretAvailable = ciSecretAvailable
    }
}

/// ReleaseV0100SecretProviderReadinessEvidenceArtifact 是 GH-881 的 evidence file row。
///
/// Artifact 只证明 evidence 文件名、kind 和 redaction 状态；它不保存 secret payload，也不表示 CI 有 secret。
public struct ReleaseV0100SecretProviderReadinessEvidenceArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100SecretProviderEvidenceArtifactKind
    public let fileName: String
    public let evidenceExists: Bool
    public let containsSecretValue: Bool
    public let redacted: Bool
    public let producedByCI: Bool

    public var evidenceBoundaryHeld: Bool {
        fileName == kind.rawValue
            && evidenceExists
            && containsSecretValue == false
            && redacted
            && producedByCI == false
    }

    public init(
        kind: ReleaseV0100SecretProviderEvidenceArtifactKind,
        fileName: String,
        evidenceExists: Bool = true,
        containsSecretValue: Bool = false,
        redacted: Bool = true,
        producedByCI: Bool = false
    ) throws {
        guard fileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "secretProviderEvidenceFile",
                expected: kind.rawValue,
                actual: fileName
            )
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "secretProviderEvidenceExists",
                expected: "true",
                actual: "false"
            )
        }
        guard containsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsSecretValue")
        }
        guard redacted else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "redacted",
                expected: "true",
                actual: "false"
            )
        }
        guard producedByCI == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("producedByCI")
        }

        self.kind = kind
        self.fileName = fileName
        self.evidenceExists = evidenceExists
        self.containsSecretValue = containsSecretValue
        self.redacted = redacted
        self.producedByCI = producedByCI
    }
}

/// ReleaseV0100SecretProviderReadinessGate 是 GH-881 的 SecretProviderReadinessGate 合同。
///
/// Gate 只证明 credential reference layer 已具备 reference identity、provider type、redaction policy、
/// `secret_readiness.json` / `redaction_proof.json` evidence 文件和 manual gate。它不读取 production secret，
/// 不保存 secret value，不把 secret 暴露到 CI 或 Dashboard，不连接 endpoint / broker，也不授权任何 order path。
public struct ReleaseV0100SecretProviderReadinessGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamProductionEnvironmentProfileHeld: Bool
    public let credentialReferences: [ReleaseV0100SecretProviderReference]
    public let evidenceArtifacts: [ReleaseV0100SecretProviderReadinessEvidenceArtifact]
    public let requirements: [ReleaseV0100SecretProviderReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0100SecretProviderForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let ciNoSecretProof: Bool
    public let manualSecretGateRequired: Bool
    public let cutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let productionSecretValueStored: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-881"
            && upstreamIssueID.rawValue == "GH-880"
            && downstreamIssueID.rawValue == "GH-882"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamProductionEnvironmentProfileHeld
            && credentialReferenceCoverageHeld
            && evidenceArtifactsHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && ciNoSecretProof
            && manualSecretGateRequired
            && productionCapabilitiesDisabled
    }

    public var credentialReferenceCoverageHeld: Bool {
        Set(credentialReferences.map(\.providerType)) == Set(ReleaseV0100SecretProviderReferenceType.allCases)
            && credentialReferences.allSatisfy(\.referenceOnlyHeld)
    }

    public var evidenceArtifactsHeld: Bool {
        Set(evidenceArtifacts.map(\.kind)) == Set(ReleaseV0100SecretProviderEvidenceArtifactKind.allCases)
            && evidenceArtifacts.allSatisfy(\.evidenceBoundaryHeld)
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && productionSecretValueStored == false
            && testnetOrderSubmissionEnabled == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-881-secret-provider-readiness-gate"),
        issueID: Identifier = Identifier.constant("GH-881"),
        upstreamIssueID: Identifier = Identifier.constant("GH-880"),
        downstreamIssueID: Identifier = Identifier.constant("GH-882"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamProductionEnvironmentProfileHeld: Bool = true,
        credentialReferences: [ReleaseV0100SecretProviderReference] = Self.requiredCredentialReferences,
        evidenceArtifacts: [ReleaseV0100SecretProviderReadinessEvidenceArtifact] = Self.requiredEvidenceArtifacts,
        requirements: [ReleaseV0100SecretProviderReadinessRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100SecretProviderForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        ciNoSecretProof: Bool = true,
        manualSecretGateRequired: Bool = true,
        cutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        productionSecretValueStored: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            credentialReferences: credentialReferences,
            evidenceArtifacts: evidenceArtifacts,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamProductionEnvironmentProfileHeld: upstreamProductionEnvironmentProfileHeld,
            ciNoSecretProof: ciNoSecretProof,
            manualSecretGateRequired: manualSecretGateRequired
        )
        try Self.validateForbiddenFlags(
            cutoverAuthorized: cutoverAuthorized,
            orderSubmissionEnabled: orderSubmissionEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            productionSecretValueStored: productionSecretValueStored,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonEnabled: tradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamProductionEnvironmentProfileHeld = upstreamProductionEnvironmentProfileHeld
        self.credentialReferences = credentialReferences
        self.evidenceArtifacts = evidenceArtifacts
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.ciNoSecretProof = ciNoSecretProof
        self.manualSecretGateRequired = manualSecretGateRequired
        self.cutoverAuthorized = cutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.productionSecretValueStored = productionSecretValueStored
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonEnabled = tradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100SecretProviderReadinessGate {
        try ReleaseV0100SecretProviderReadinessGate(upstreamProductionEnvironmentProfileHeld: true)
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRedactionPolicy = "redactedIdentifierOnly"
    public static let requiredRequirements = ReleaseV0100SecretProviderReadinessRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100SecretProviderForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-004-SECRET-PROVIDER-READINESS-GATE",
        "V0100-004-CREDENTIAL-REFERENCE-EXISTS",
        "V0100-004-PROVIDER-TYPE-REFERENCE-ONLY",
        "V0100-004-REDACTION-POLICY-REQUIRED",
        "V0100-004-SECRET-READINESS-JSON",
        "V0100-004-REDACTION-PROOF-JSON",
        "V0100-004-CI-NO-SECRET-PROOF",
        "V0100-004-MANUAL-SECRET-GATE-REQUIRED",
        "V0100-004-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-881-VERIFY-V0100-SECRET-PROVIDER-READINESS-GATE",
        "TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH881SecretProviderReadinessGateKeepsSecretsOutOfRuntimeCIDashboardAndEvidence",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredCredentialReferences: [ReleaseV0100SecretProviderReference] = {
        do {
            return [
                try ReleaseV0100SecretProviderReference(
                    referenceID: Identifier.constant("v0.10.0-env-var-secret-provider-ref"),
                    providerType: .environmentVariableReference
                ),
                try ReleaseV0100SecretProviderReference(
                    referenceID: Identifier.constant("v0.10.0-keychain-secret-provider-ref"),
                    providerType: .keychainItemReference
                ),
                try ReleaseV0100SecretProviderReference(
                    referenceID: Identifier.constant("v0.10.0-operator-manual-secret-provider-ref"),
                    providerType: .operatorManualReference
                )
            ]
        } catch {
            preconditionFailure("GH-881 secret provider references must be valid: \(error)")
        }
    }()

    public static let requiredEvidenceArtifacts: [ReleaseV0100SecretProviderReadinessEvidenceArtifact] = {
        do {
            return [
                try ReleaseV0100SecretProviderReadinessEvidenceArtifact(
                    kind: .secretReadiness,
                    fileName: "secret_readiness.json"
                ),
                try ReleaseV0100SecretProviderReadinessEvidenceArtifact(
                    kind: .redactionProof,
                    fileName: "redaction_proof.json"
                )
            ]
        } catch {
            preconditionFailure("GH-881 secret provider evidence artifacts must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100SecretProviderReadinessGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        credentialReferences: [ReleaseV0100SecretProviderReference],
        evidenceArtifacts: [ReleaseV0100SecretProviderReadinessEvidenceArtifact],
        requirements: [ReleaseV0100SecretProviderReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0100SecretProviderForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            (
                "credentialReferences",
                credentialReferences == requiredCredentialReferences,
                requiredCredentialReferences.map(\.providerType.rawValue).joined(separator: ","),
                credentialReferences.map(\.providerType.rawValue).joined(separator: ",")
            ),
            (
                "evidenceArtifacts",
                evidenceArtifacts == requiredEvidenceArtifacts,
                requiredEvidenceArtifacts.map(\.fileName).joined(separator: ","),
                evidenceArtifacts.map(\.fileName).joined(separator: ",")
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
        upstreamProductionEnvironmentProfileHeld: Bool,
        ciNoSecretProof: Bool,
        manualSecretGateRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamProductionEnvironmentProfileHeld", upstreamProductionEnvironmentProfileHeld),
            ("ciNoSecretProof", ciNoSecretProof),
            ("manualSecretGateRequired", manualSecretGateRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        cutoverAuthorized: Bool,
        orderSubmissionEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        productionSecretValueStored: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("orderSubmissionEnabled", orderSubmissionEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionSecretValueStored", productionSecretValueStored),
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
