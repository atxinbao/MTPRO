import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowPublicMarketProbeClassification 描述 GH-1243 public market probe 的响应分类。
///
/// 分类只表达已观察到的 public market read-only 结果；它不是 transport、重试器、signed request、
/// account endpoint、order endpoint 或 production cutover 授权。
public enum ReleaseV0200ProductionShadowPublicMarketProbeClassification: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case reachable = "reachable"
    case rateLimited = "rate-limited"
    case serviceUnavailable = "service-unavailable"
    case networkUnavailable = "network-unavailable"
}

/// ReleaseV0200ProductionShadowPublicMarketProbeRequirement 固定 #1243 的验收要求。
public enum ReleaseV0200ProductionShadowPublicMarketProbeRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamCredentialReferenceReadinessHeld = "upstream credential reference readiness held"
    case binanceSpotProductionShadowOnly = "Binance Spot production-shadow only"
    case publicMarketEndpointShapeRequired = "public market endpoint shape required"
    case responseClassificationRequired = "response classification required"
    case credentialNotRequired = "credential not required"
    case accountPayloadNotRequired = "account payload not required"
    case signedAndTradingEndpointsForbidden = "signed and trading endpoints forbidden"
    case noSecretRead = "no secret read"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability 枚举 #1243 必须继续拒绝的能力。
public enum ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialRequired = "credential required"
    case accountPayloadRequired = "account payload required"
    case productionSecretValueRead = "production secret value read"
    case rawResponsePayloadPersisted = "raw response payload persisted"
    case signedAccountEndpointRuntime = "signed account endpoint runtime"
    case privateStreamRuntime = "private stream runtime"
    case listenKeyRuntime = "listenKey runtime"
    case accountEndpointTouched = "account endpoint touched"
    case tradingEndpointTouched = "trading endpoint touched"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case spotCanary = "Spot canary"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case dashboardTradingButton = "Dashboard trading button"
    case orderForm = "order form"
    case liveCommand = "live command"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0200ProductionShadowPublicMarketProbeObservation 表达单个 public market read-only probe 结果。
///
/// Observation 可保存 endpoint shape、HTTP 状态和分类摘要，但不能保存 credential、account payload、
/// signed request、order endpoint 或 raw response payload。真实网络调用若由人工/外部 runner 执行，只能把
/// 已脱敏的分类结果注入为此 evidence；本类型自身不打开连接。
public struct ReleaseV0200ProductionShadowPublicMarketProbeObservation: Codable, Equatable, Sendable {
    public let observationID: Identifier
    public let endpointEvidence: ReleaseV0200ProductionShadowEndpointShapeEvidence
    public let classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification
    public let httpStatusCode: Int?
    public let classificationSummary: String
    public let credentialRequired: Bool
    public let accountPayloadRequired: Bool
    public let productionSecretValueRead: Bool
    public let rawResponsePayloadPersisted: Bool
    public let signedEndpointTouched: Bool
    public let accountEndpointTouched: Bool
    public let tradingEndpointTouched: Bool

    public var observationHeld: Bool {
        endpointEvidence.shapeHeld
            && Self.isStatusCodeAllowed(classification: classification, statusCode: httpStatusCode)
            && Self.isClassificationSummaryAllowed(classificationSummary, classification: classification)
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        credentialRequired == false
            && accountPayloadRequired == false
            && productionSecretValueRead == false
            && rawResponsePayloadPersisted == false
            && signedEndpointTouched == false
            && accountEndpointTouched == false
            && tradingEndpointTouched == false
    }

    public init(
        observationID: Identifier? = nil,
        endpointEvidence: ReleaseV0200ProductionShadowEndpointShapeEvidence,
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification,
        httpStatusCode: Int?,
        classificationSummary: String? = nil,
        credentialRequired: Bool = false,
        accountPayloadRequired: Bool = false,
        productionSecretValueRead: Bool = false,
        rawResponsePayloadPersisted: Bool = false,
        signedEndpointTouched: Bool = false,
        accountEndpointTouched: Bool = false,
        tradingEndpointTouched: Bool = false
    ) throws {
        let resolvedSummary = classificationSummary ?? Self.defaultClassificationSummary(
            kind: endpointEvidence.kind,
            classification: classification
        )
        let resolvedID = observationID ?? Self.deterministicID(
            kind: endpointEvidence.kind,
            classification: classification,
            statusCode: httpStatusCode
        )
        try Self.validate(
            endpointEvidence: endpointEvidence,
            classification: classification,
            httpStatusCode: httpStatusCode,
            classificationSummary: resolvedSummary,
            credentialRequired: credentialRequired,
            accountPayloadRequired: accountPayloadRequired,
            productionSecretValueRead: productionSecretValueRead,
            rawResponsePayloadPersisted: rawResponsePayloadPersisted,
            signedEndpointTouched: signedEndpointTouched,
            accountEndpointTouched: accountEndpointTouched,
            tradingEndpointTouched: tradingEndpointTouched
        )

        self.observationID = resolvedID
        self.endpointEvidence = endpointEvidence
        self.classification = classification
        self.httpStatusCode = httpStatusCode
        self.classificationSummary = resolvedSummary
        self.credentialRequired = credentialRequired
        self.accountPayloadRequired = accountPayloadRequired
        self.productionSecretValueRead = productionSecretValueRead
        self.rawResponsePayloadPersisted = rawResponsePayloadPersisted
        self.signedEndpointTouched = signedEndpointTouched
        self.accountEndpointTouched = accountEndpointTouched
        self.tradingEndpointTouched = tradingEndpointTouched
    }

    public static func deterministicFixtures() throws -> [ReleaseV0200ProductionShadowPublicMarketProbeObservation] {
        let endpointEvidence = try ReleaseV0200ProductionShadowEndpointShapeEvidence.deterministicFixtures()
        return try endpointEvidence.map { evidence in
            switch evidence.kind {
            case .serverTime, .exchangeInfo:
                return try ReleaseV0200ProductionShadowPublicMarketProbeObservation(
                    endpointEvidence: evidence,
                    classification: .reachable,
                    httpStatusCode: 200
                )
            case .tickerPrice:
                return try ReleaseV0200ProductionShadowPublicMarketProbeObservation(
                    endpointEvidence: evidence,
                    classification: .rateLimited,
                    httpStatusCode: 429
                )
            case .depthSnapshot:
                return try ReleaseV0200ProductionShadowPublicMarketProbeObservation(
                    endpointEvidence: evidence,
                    classification: .networkUnavailable,
                    httpStatusCode: nil
                )
            }
        }
    }

    public static func deterministicID(
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification,
        statusCode: Int?
    ) -> Identifier {
        .constant(
            [
                "gh-1243-v0200-public-market-readonly-probe-observation",
                kind.rawValue,
                classification.rawValue,
                statusCode.map(String.init) ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0200.publicMarketProbe.observationID"
        )
    }

    public static let requiredSummaryPrefix = "public-market-probe="
    public static let requiredReachableClassificationMarker = "classification=reachable"
    public static let requiredPayloadMarker = "payload=<not-persisted>"
}

private extension ReleaseV0200ProductionShadowPublicMarketProbeObservation {
    static func validate(
        endpointEvidence: ReleaseV0200ProductionShadowEndpointShapeEvidence,
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification,
        httpStatusCode: Int?,
        classificationSummary: String,
        credentialRequired: Bool,
        accountPayloadRequired: Bool,
        productionSecretValueRead: Bool,
        rawResponsePayloadPersisted: Bool,
        signedEndpointTouched: Bool,
        accountEndpointTouched: Bool,
        tradingEndpointTouched: Bool
    ) throws {
        guard endpointEvidence.shapeHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.publicMarketProbe.endpointEvidence",
                expected: "read-only endpoint shape evidence",
                actual: endpointEvidence.path
            )
        }
        guard isStatusCodeAllowed(classification: classification, statusCode: httpStatusCode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.publicMarketProbe.httpStatusCode",
                expected: "status code matching \(classification.rawValue)",
                actual: httpStatusCode.map(String.init) ?? "nil"
            )
        }
        guard isClassificationSummaryAllowed(classificationSummary, classification: classification) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.publicMarketProbe.unredactedOrUnclassifiedSummary"
            )
        }
        for (field, value) in [
            ("credentialRequired", credentialRequired),
            ("accountPayloadRequired", accountPayloadRequired),
            ("productionSecretValueRead", productionSecretValueRead),
            ("rawResponsePayloadPersisted", rawResponsePayloadPersisted),
            ("signedEndpointTouched", signedEndpointTouched),
            ("accountEndpointTouched", accountEndpointTouched),
            ("tradingEndpointTouched", tradingEndpointTouched)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.publicMarketProbe.\(field)"
            )
        }
    }

    static func isStatusCodeAllowed(
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification,
        statusCode: Int?
    ) -> Bool {
        switch classification {
        case .reachable:
            guard let statusCode else { return false }
            return (200...299).contains(statusCode)
        case .rateLimited:
            return statusCode == 429
        case .serviceUnavailable:
            guard let statusCode else { return false }
            return (500...599).contains(statusCode)
        case .networkUnavailable:
            return statusCode == nil
        }
    }

    static func defaultClassificationSummary(
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification
    ) -> String {
        "\(ReleaseV0200ProductionShadowPublicMarketProbeObservation.requiredSummaryPrefix)\(kind.rawValue); classification=\(classification.rawValue); \(ReleaseV0200ProductionShadowPublicMarketProbeObservation.requiredPayloadMarker)"
    }

    static func isClassificationSummaryAllowed(
        _ summary: String,
        classification: ReleaseV0200ProductionShadowPublicMarketProbeClassification
    ) -> Bool {
        summary.contains(ReleaseV0200ProductionShadowPublicMarketProbeObservation.requiredSummaryPrefix)
            && summary.contains("classification=\(classification.rawValue)")
            && summary.contains(ReleaseV0200ProductionShadowPublicMarketProbeObservation.requiredPayloadMarker)
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("listenKey") == false
            && summary.localizedCaseInsensitiveContains("account payload") == false
            && summary.localizedCaseInsensitiveContains("order payload") == false
    }
}

/// ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe 是 GH-1243 的 public market readiness evidence。
///
/// Probe 绑定 #1242 credential reference readiness 和 #1241 endpoint allowlist，只证明 Binance Spot
/// production-shadow public market endpoint 的 read-only shape 与 response classification 可以被审计。
/// 它不读取 credential、不要求 account payload、不触达 signed/account/trading endpoint、不提交订单，也不授权
/// Spot canary、tag / release publication 或 production cutover。
public struct ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe: Codable, Equatable, Sendable {
    public let probeID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamCredentialReferenceReadinessHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let endpointFamilyReference: String
    public let probeObservations: [ReleaseV0200ProductionShadowPublicMarketProbeObservation]
    public let requirements: [ReleaseV0200ProductionShadowPublicMarketProbeRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialRequired: Bool
    public let accountPayloadRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let signedAccountEndpointRuntimeEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let accountEndpointTouched: Bool
    public let tradingEndpointTouched: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var probeHeld: Bool {
        issueID.rawValue == "GH-1243"
            && upstreamIssueID.rawValue == "GH-1242"
            && downstreamIssueID.rawValue == "GH-1244"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamCredentialReferenceReadinessHeld
            && namespaceHeld
            && endpointFamilyReference == "https://api.binance.com"
            && probeObservations.map(\.endpointEvidence.kind) == ReleaseV0200ProductionShadowReadOnlyEndpointKind.allCases
            && probeObservations.allSatisfy(\.observationHeld)
            && probeObservations.contains { $0.classification == .reachable }
            && requirements == ReleaseV0200ProductionShadowPublicMarketProbeRequirement.allCases
            && forbiddenCapabilities == ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionShadow
    }

    public var classificationEvidenceHeld: Bool {
        probeObservations.isEmpty == false
            && probeObservations.allSatisfy(\.observationHeld)
            && Set(probeObservations.map(\.classification)).isSubset(
                of: Set(ReleaseV0200ProductionShadowPublicMarketProbeClassification.allCases)
            )
    }

    public var productionDefaultsClosed: Bool {
        credentialRequired == false
            && accountPayloadRequired == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && signedAccountEndpointRuntimeEnabled == false
            && privateStreamRuntimeEnabled == false
            && listenKeyRuntimeEnabled == false
            && accountEndpointTouched == false
            && tradingEndpointTouched == false
            && productionBrokerConnectionEnabled == false
            && orderSubmitCancelReplaceEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        probeID: Identifier = Identifier.constant("gh-1243-release-v0.20.0-binance-spot-production-shadow-public-market-read-only-probe"),
        issueID: Identifier = Identifier.constant("GH-1243"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1242"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1244"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamCredentialReferenceReadinessHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionShadow,
        endpointFamilyReference: String = "https://api.binance.com",
        probeObservations: [ReleaseV0200ProductionShadowPublicMarketProbeObservation]? = nil,
        requirements: [ReleaseV0200ProductionShadowPublicMarketProbeRequirement] =
            ReleaseV0200ProductionShadowPublicMarketProbeRequirement.allCases,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability] =
            ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        credentialRequired: Bool = false,
        accountPayloadRequired: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        signedAccountEndpointRuntimeEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        listenKeyRuntimeEnabled: Bool = false,
        accountEndpointTouched: Bool = false,
        tradingEndpointTouched: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedObservations: [ReleaseV0200ProductionShadowPublicMarketProbeObservation]
        if let probeObservations {
            resolvedObservations = probeObservations
        } else {
            resolvedObservations = try ReleaseV0200ProductionShadowPublicMarketProbeObservation.deterministicFixtures()
        }
        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueID: upstreamIssueID,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            endpointFamilyReference: endpointFamilyReference,
            probeObservations: resolvedObservations,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrue(
            upstreamCredentialReferenceReadinessHeld: upstreamCredentialReferenceReadinessHeld
        )
        try Self.validateForbiddenFlags(
            credentialRequired: credentialRequired,
            accountPayloadRequired: accountPayloadRequired,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            signedAccountEndpointRuntimeEnabled: signedAccountEndpointRuntimeEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            listenKeyRuntimeEnabled: listenKeyRuntimeEnabled,
            accountEndpointTouched: accountEndpointTouched,
            tradingEndpointTouched: tradingEndpointTouched,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.probeID = probeID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamCredentialReferenceReadinessHeld = upstreamCredentialReferenceReadinessHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.endpointFamilyReference = endpointFamilyReference
        self.probeObservations = resolvedObservations
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialRequired = credentialRequired
        self.accountPayloadRequired = accountPayloadRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.signedAccountEndpointRuntimeEnabled = signedAccountEndpointRuntimeEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.accountEndpointTouched = accountEndpointTouched
        self.tradingEndpointTouched = tradingEndpointTouched
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe {
        _ = try ReleaseV0200ProductionShadowCredentialReferenceReadiness.deterministicFixture()
        return try ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe()
    }

    public static let requiredValidationAnchors = [
        "GH-1243-VERIFY-V0200-PUBLIC-MARKET-READ-ONLY-PROBE",
        "TVM-RELEASE-V0200-PUBLIC-MARKET-READ-ONLY-PROBE",
        "V0200-005-BINANCE-SPOT-PRODUCTION-SHADOW-PUBLIC-MARKET-PROBE",
        "V0200-005-PUBLIC-MARKET-READ-ONLY-REACHABILITY",
        "V0200-005-RESPONSE-CLASSIFICATION-EVIDENCE",
        "V0200-005-NO-CREDENTIAL-REQUIRED",
        "V0200-005-NO-SIGNED-ACCOUNT-ENDPOINT",
        "V0200-005-NO-ORDER-ENDPOINT",
        "V0200-005-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1243ReleaseV0200PublicMarketReadOnlyProbe",
        "bash checks/verify-v0.20.0-public-market-readonly-probe.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowPublicMarketReadOnlyProbe {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueID: Identifier,
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        endpointFamilyReference: String,
        probeObservations: [ReleaseV0200ProductionShadowPublicMarketProbeObservation],
        requirements: [ReleaseV0200ProductionShadowPublicMarketProbeRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let endpointFamily = try ReleaseV0190VenueEndpointFamilyRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1243", "GH-1243", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1242", "GH-1242", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1244", "GH-1244", downstreamIssueID.rawValue),
            (
                "canonicalQueueRange",
                canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
                canonicalQueueRange
            ),
            (
                "projectName",
                projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
                projectName
            ),
            ("releaseVersion", releaseVersion == "v0.20.0", "v0.20.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            (
                "tradingEnvironment",
                tradingEnvironment == .productionShadow,
                ReleaseV0181TradingEnvironment.productionShadow.rawValue,
                tradingEnvironment.rawValue
            ),
            (
                "endpointFamilyReference",
                endpointFamilyReference == endpointFamily.reference,
                endpointFamily.reference,
                endpointFamilyReference
            ),
            (
                "probeObservations",
                probeObservations.map(\.endpointEvidence.kind) == ReleaseV0200ProductionShadowReadOnlyEndpointKind.allCases
                    && probeObservations.allSatisfy(\.observationHeld)
                    && probeObservations.contains { $0.classification == .reachable },
                "all read-only endpoint kinds classified with at least one reachable result",
                probeObservations.map { "\($0.endpointEvidence.kind.rawValue):\($0.classification.rawValue)" }.joined(separator: ",")
            ),
            (
                "requirements",
                requirements == ReleaseV0200ProductionShadowPublicMarketProbeRequirement.allCases,
                ReleaseV0200ProductionShadowPublicMarketProbeRequirement.allCases.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability.allCases,
                ReleaseV0200ProductionShadowPublicMarketProbeForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == Self.requiredValidationAnchors,
                Self.requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.publicMarketProbe.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrue(upstreamCredentialReferenceReadinessHeld: Bool) throws {
        guard upstreamCredentialReferenceReadinessHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.publicMarketProbe.upstreamCredentialReferenceReadinessHeld",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        credentialRequired: Bool,
        accountPayloadRequired: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        signedAccountEndpointRuntimeEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        listenKeyRuntimeEnabled: Bool,
        accountEndpointTouched: Bool,
        tradingEndpointTouched: Bool,
        productionBrokerConnectionEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("credentialRequired", credentialRequired),
            ("accountPayloadRequired", accountPayloadRequired),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("signedAccountEndpointRuntimeEnabled", signedAccountEndpointRuntimeEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("listenKeyRuntimeEnabled", listenKeyRuntimeEnabled),
            ("accountEndpointTouched", accountEndpointTouched),
            ("tradingEndpointTouched", tradingEndpointTouched),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.publicMarketProbe.\(field)"
            )
        }
    }
}
