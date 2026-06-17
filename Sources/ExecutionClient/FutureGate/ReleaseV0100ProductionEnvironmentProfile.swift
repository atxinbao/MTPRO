import DomainModel
import Foundation

/// ReleaseV0100ProductionEnvironmentPolicyReferenceKind 固定生产环境 profile 可保存的引用类型。
///
/// 这些引用只是 policy identity，不是 secret value、endpoint URL、broker connection 或运行时句柄。
public enum ReleaseV0100ProductionEnvironmentPolicyReferenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case endpointPolicy = "endpoint policy"
    case secretPolicy = "secret policy"
    case riskPolicy = "risk policy"
}

/// ReleaseV0100ProductionEnvironmentProfileRequirement 固定 GH-880 的 profile 合同要求。
public enum ReleaseV0100ProductionEnvironmentProfileRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamReadinessContractRequired = "upstream readiness contract required"
    case productionEnvironmentExplicit = "production environment explicit"
    case binanceVenueOnly = "Binance venue only"
    case spotAndUSDSPerpetualOnly = "spot and USDⓈ-M perpetual only"
    case endpointPolicyReferenceRequired = "endpoint policy reference required"
    case secretPolicyReferenceRequired = "secret policy reference required"
    case riskPolicyReferenceRequired = "risk policy reference required"
    case referencesOnly = "references only"
    case productionCutoverDisabled = "production cutover disabled"
    case orderSubmissionDisabled = "order submission disabled"
    case productionEndpointConnectionDisabled = "production endpoint connection disabled"
}

/// ReleaseV0100ProductionEnvironmentProfileForbiddenCapability 枚举 GH-880 必须拒绝的生产能力。
public enum ReleaseV0100ProductionEnvironmentProfileForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case policyValuePersistence = "policy value persistence"
    case productionSecretValueRead = "production secret value read"
    case productionSecretValueStored = "production secret value stored"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionCutoverAuthorization = "production cutover authorization"
    case orderSubmissionEnabled = "order submission enabled"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonEnabled = "trading button enabled"
    case orderFormEnabled = "order form enabled"
    case liveCommandEnabled = "live command enabled"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
}

/// ReleaseV0100ProductionEnvironmentPolicyReference 是 GH-880 的 reference-only policy row。
///
/// Row 只保存引用名称和 anchor，不保存 policy body、secret value、endpoint URL 或风险阈值实体。
public struct ReleaseV0100ProductionEnvironmentPolicyReference: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100ProductionEnvironmentPolicyReferenceKind
    public let reference: String
    public let anchor: String
    public let storesResolvedValue: Bool
    public let readsSecretValue: Bool
    public let connectsEndpoint: Bool
    public let enablesOrderSubmission: Bool

    public var referenceOnlyHeld: Bool {
        reference.isEmpty == false
            && anchor.isEmpty == false
            && storesResolvedValue == false
            && readsSecretValue == false
            && connectsEndpoint == false
            && enablesOrderSubmission == false
    }

    public init(
        kind: ReleaseV0100ProductionEnvironmentPolicyReferenceKind,
        reference: String,
        anchor: String,
        storesResolvedValue: Bool = false,
        readsSecretValue: Bool = false,
        connectsEndpoint: Bool = false,
        enablesOrderSubmission: Bool = false
    ) throws {
        guard reference.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "policyReference",
                expected: "non-empty production environment policy reference",
                actual: "empty"
            )
        }
        guard anchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "policyAnchor",
                expected: "non-empty production environment policy anchor",
                actual: "empty"
            )
        }
        guard storesResolvedValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("storesResolvedValue")
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsSecretValue")
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("connectsEndpoint")
        }
        guard enablesOrderSubmission == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("enablesOrderSubmission")
        }

        self.kind = kind
        self.reference = reference
        self.anchor = anchor
        self.storesResolvedValue = storesResolvedValue
        self.readsSecretValue = readsSecretValue
        self.connectsEndpoint = connectsEndpoint
        self.enablesOrderSubmission = enablesOrderSubmission
    }
}

/// ReleaseV0100ProductionEnvironmentProfile 是 GH-880 的 production environment profile 合同。
///
/// Profile 只把 production 环境、Binance venue、spot / USDⓈ-M perpetual 产品范围和
/// endpoint / secret / risk policy reference 绑定成 readiness evidence。它不保存 secret value，
/// 不解析 endpoint，不连接 broker，不授权 cutover，也不打开任何 submit / cancel / replace 路径。
public struct ReleaseV0100ProductionEnvironmentProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamReadinessContractHeld: Bool
    public let environment: String
    public let venue: String
    public let productTypes: [String]
    public let policyReferences: [ReleaseV0100ProductionEnvironmentPolicyReference]
    public let requirements: [ReleaseV0100ProductionEnvironmentProfileRequirement]
    public let forbiddenCapabilities: [ReleaseV0100ProductionEnvironmentProfileForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let referencesOnlyPersisted: Bool
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

    public var profileHeld: Bool {
        issueID.rawValue == "GH-880"
            && upstreamIssueID.rawValue == "GH-878"
            && downstreamIssueID.rawValue == "GH-881"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamReadinessContractHeld
            && environment == Self.requiredEnvironment
            && venue == Self.requiredVenue
            && productTypes == Self.requiredProductTypes
            && policyReferences == Self.requiredPolicyReferences
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && referencesOnlyPersisted
            && referenceCoverageHeld
            && productionCapabilitiesDisabled
    }

    public var referenceCoverageHeld: Bool {
        Set(policyReferences.map(\.kind)) == Set(ReleaseV0100ProductionEnvironmentPolicyReferenceKind.allCases)
            && policyReferences.allSatisfy(\.referenceOnlyHeld)
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
        profileID: Identifier = Identifier.constant("gh-880-production-environment-profile"),
        issueID: Identifier = Identifier.constant("GH-880"),
        upstreamIssueID: Identifier = Identifier.constant("GH-878"),
        downstreamIssueID: Identifier = Identifier.constant("GH-881"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamReadinessContractHeld: Bool = true,
        environment: String = Self.requiredEnvironment,
        venue: String = Self.requiredVenue,
        productTypes: [String] = Self.requiredProductTypes,
        policyReferences: [ReleaseV0100ProductionEnvironmentPolicyReference] = Self.requiredPolicyReferences,
        requirements: [ReleaseV0100ProductionEnvironmentProfileRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100ProductionEnvironmentProfileForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        referencesOnlyPersisted: Bool = true,
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
            environment: environment,
            venue: venue,
            productTypes: productTypes,
            policyReferences: policyReferences,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamReadinessContractHeld: upstreamReadinessContractHeld,
            referencesOnlyPersisted: referencesOnlyPersisted
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

        self.profileID = profileID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamReadinessContractHeld = upstreamReadinessContractHeld
        self.environment = environment
        self.venue = venue
        self.productTypes = productTypes
        self.policyReferences = policyReferences
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.referencesOnlyPersisted = referencesOnlyPersisted
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

    public static func deterministicFixture() throws -> ReleaseV0100ProductionEnvironmentProfile {
        try ReleaseV0100ProductionEnvironmentProfile(upstreamReadinessContractHeld: true)
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredEnvironment = "production"
    public static let requiredVenue = "Binance"
    public static let requiredProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredRequirements = ReleaseV0100ProductionEnvironmentProfileRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100ProductionEnvironmentProfileForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-003-PRODUCTION-ENVIRONMENT-PROFILE-CONTRACT",
        "V0100-003-REFERENCE-ONLY-POLICY-REFS",
        "V0100-003-BINANCE-SPOT-USDSM-PERPETUAL-SCOPE",
        "V0100-003-PRODUCTION-CUTOVER-DISABLED",
        "V0100-003-ORDER-SUBMISSION-DISABLED",
        "V0100-003-PRODUCTION-ENDPOINT-CONNECTION-DISABLED",
        "GH-880-VERIFY-V0100-PRODUCTION-ENVIRONMENT-PROFILE",
        "TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH880ProductionEnvironmentProfilePersistsReferencesOnlyAndKeepsProductionDisabled",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredPolicyReferences: [ReleaseV0100ProductionEnvironmentPolicyReference] = {
        do {
            return [
                try ReleaseV0100ProductionEnvironmentPolicyReference(
                    kind: .endpointPolicy,
                    reference: "v0.10.0-production-endpoint-policy-ref",
                    anchor: "V0100-003-ENDPOINT-POLICY-REFERENCE"
                ),
                try ReleaseV0100ProductionEnvironmentPolicyReference(
                    kind: .secretPolicy,
                    reference: "v0.10.0-production-secret-policy-ref",
                    anchor: "V0100-003-SECRET-POLICY-REFERENCE"
                ),
                try ReleaseV0100ProductionEnvironmentPolicyReference(
                    kind: .riskPolicy,
                    reference: "v0.10.0-production-risk-policy-ref",
                    anchor: "V0100-003-RISK-POLICY-REFERENCE"
                )
            ]
        } catch {
            preconditionFailure("GH-880 production environment policy references must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100ProductionEnvironmentProfile {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        environment: String,
        venue: String,
        productTypes: [String],
        policyReferences: [ReleaseV0100ProductionEnvironmentPolicyReference],
        requirements: [ReleaseV0100ProductionEnvironmentProfileRequirement],
        forbiddenCapabilities: [ReleaseV0100ProductionEnvironmentProfileForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("environment", environment == requiredEnvironment, requiredEnvironment, environment),
            ("venue", venue == requiredVenue, requiredVenue, venue),
            (
                "productTypes",
                productTypes == requiredProductTypes,
                requiredProductTypes.joined(separator: ","),
                productTypes.joined(separator: ",")
            ),
            (
                "policyReferences",
                policyReferences == requiredPolicyReferences,
                requiredPolicyReferences.map(\.reference).joined(separator: ","),
                policyReferences.map(\.reference).joined(separator: ",")
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
        upstreamReadinessContractHeld: Bool,
        referencesOnlyPersisted: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamReadinessContractHeld", upstreamReadinessContractHeld),
            ("referencesOnlyPersisted", referencesOnlyPersisted)
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
