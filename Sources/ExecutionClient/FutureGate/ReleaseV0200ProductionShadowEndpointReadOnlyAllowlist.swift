import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowReadOnlyEndpointKind 固定 GH-1241 允许表达的 Binance Spot 只读 endpoint shape。
///
/// 这些 case 只表示 production-shadow readiness 可以引用的 read-only HTTP shape；它们不是 transport、
/// signed request builder、account endpoint runtime、listenKey runtime 或 trading command。
public enum ReleaseV0200ProductionShadowReadOnlyEndpointKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case serverTime = "server-time"
    case exchangeInfo = "exchange-info"
    case tickerPrice = "ticker-price"
    case depthSnapshot = "depth-snapshot"

    public var path: String {
        switch self {
        case .serverTime:
            "/api/v3/time"
        case .exchangeInfo:
            "/api/v3/exchangeInfo"
        case .tickerPrice:
            "/api/v3/ticker/price"
        case .depthSnapshot:
            "/api/v3/depth"
        }
    }

    public var allowedQueryItemNames: Set<String> {
        switch self {
        case .serverTime:
            []
        case .exchangeInfo:
            ["symbol", "symbols"]
        case .tickerPrice:
            ["symbol"]
        case .depthSnapshot:
            ["symbol", "limit"]
        }
    }
}

/// ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName 固定 GH-1241 明确拒绝的 signed / order query 字段。
public enum ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signature
    case timestamp
    case recvWindow
    case listenKey
    case orderId
    case origClientOrderId
    case newClientOrderId
    case apiKey
    case secret
}

/// ReleaseV0200ProductionShadowEndpointForbiddenPath 固定 GH-1241 明确拒绝的 signed / trading endpoint path。
public enum ReleaseV0200ProductionShadowEndpointForbiddenPath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case account = "/api/v3/account"
    case order = "/api/v3/order"
    case orderTest = "/api/v3/order/test"
    case openOrders = "/api/v3/openOrders"
    case allOrders = "/api/v3/allOrders"
    case myTrades = "/api/v3/myTrades"
    case userDataStream = "/api/v3/userDataStream"
}

/// ReleaseV0200ProductionShadowEndpointAllowlistRequirement 固定 #1241 的 endpoint allowlist 验收要求。
public enum ReleaseV0200ProductionShadowEndpointAllowlistRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamEnvironmentProfileHeld = "upstream environment profile held"
    case binanceSpotProductionShadowOnly = "Binance Spot production-shadow only"
    case httpsOnly = "HTTPS only"
    case hostFamilyMustMatchRegistry = "host family must match registry"
    case readOnlyPathAllowlistRequired = "read-only path allowlist required"
    case queryShapeAllowlistRequired = "query shape allowlist required"
    case signedAndTradingEndpointsForbidden = "signed and trading endpoints forbidden"
    case noEndpointConnection = "no endpoint connection"
    case noSecretRead = "no secret read"
    case noProductionCutover = "no production cutover"
}

/// ReleaseV0200ProductionShadowEndpointForbiddenCapability 枚举 #1241 必须继续拒绝的能力。
public enum ReleaseV0200ProductionShadowEndpointForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case nonHTTPS = "non-HTTPS endpoint"
    case unexpectedHost = "unexpected host"
    case unexpectedPath = "unexpected path"
    case unexpectedQuery = "unexpected query"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyEndpoint = "listenKey endpoint"
    case orderEndpoint = "order endpoint"
    case websocketEndpoint = "WebSocket endpoint"
    case productionEndpointConnection = "production endpoint connection"
    case productionSecretValueRead = "production secret value read"
    case productionBrokerConnection = "production broker connection"
    case orderSubmitCancelReplace = "order submit / cancel / replace"
    case spotCanary = "Spot canary"
    case futuresRuntime = "Futures runtime"
    case okxActiveImplementation = "OKX active implementation"
    case productionCutoverAuthorization = "production cutover authorization"
    case tagOrReleasePublication = "tag or GitHub Release publication"
}

/// ReleaseV0200ProductionShadowEndpointQueryItem 是 allowlist evidence 可保存的非敏感 query item。
///
/// Query item 只用于本地合同校验。它不能保存 signature、timestamp、recvWindow、listenKey、orderId、
/// client order id、API key 或 secret 这类 signed / trading 字段。
public struct ReleaseV0200ProductionShadowEndpointQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.productionShadowEndpoint.query.name",
                expected: "non-empty read-only query item name",
                actual: name
            )
        }
        guard normalizedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.productionShadowEndpoint.query.value",
                expected: "non-empty non-secret query value",
                actual: value
            )
        }
        guard Self.forbiddenNames.contains(normalizedName) == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.productionShadowEndpoint.query.\(normalizedName)"
            )
        }
        self.name = normalizedName
        self.value = normalizedValue
    }

    private static let forbiddenNames = Set(
        ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName.allCases.map(\.rawValue)
    )
}

/// ReleaseV0200ProductionShadowEndpointShapeEvidence 表达单个 read-only endpoint shape 的本地证据。
///
/// Evidence 只校验 scheme、host、path 和 query shape 是否在 allowlist 中。它不会构造 URLRequest，
/// 不会打开 network connection，不会读取 secret，也不会把 signed / trading endpoint 当成 readiness 证据。
public struct ReleaseV0200ProductionShadowEndpointShapeEvidence: Codable, Equatable, Sendable {
    public let endpointShapeID: Identifier
    public let kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind
    public let scheme: String
    public let host: String
    public let path: String
    public let queryItems: [ReleaseV0200ProductionShadowEndpointQueryItem]
    public let productionEndpointConnectionOpened: Bool
    public let productionSecretValueRead: Bool
    public let signedEndpointRuntimeEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool

    public var shapeHeld: Bool {
        kind.path == path
            && scheme.lowercased() == Self.requiredScheme
            && host.lowercased() == Self.requiredHost
            && Self.isAllowedQueryShape(kind: kind, queryItems: queryItems)
            && productionEndpointConnectionOpened == false
            && productionSecretValueRead == false
            && signedEndpointRuntimeEnabled == false
            && orderSubmitCancelReplaceEnabled == false
    }

    public init(
        endpointShapeID: Identifier? = nil,
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        scheme: String = Self.requiredScheme,
        host: String = Self.requiredHost,
        path: String? = nil,
        queryItems: [ReleaseV0200ProductionShadowEndpointQueryItem] = [],
        productionEndpointConnectionOpened: Bool = false,
        productionSecretValueRead: Bool = false,
        signedEndpointRuntimeEnabled: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false
    ) throws {
        let resolvedPath = path ?? kind.path
        let resolvedID = endpointShapeID ?? Self.deterministicID(
            kind: kind,
            scheme: scheme,
            host: host,
            path: resolvedPath,
            queryItems: queryItems
        )
        try Self.validate(
            kind: kind,
            scheme: scheme,
            host: host,
            path: resolvedPath,
            queryItems: queryItems,
            productionEndpointConnectionOpened: productionEndpointConnectionOpened,
            productionSecretValueRead: productionSecretValueRead,
            signedEndpointRuntimeEnabled: signedEndpointRuntimeEnabled,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled
        )
        self.endpointShapeID = resolvedID
        self.kind = kind
        self.scheme = scheme.lowercased()
        self.host = host.lowercased()
        self.path = resolvedPath
        self.queryItems = queryItems
        self.productionEndpointConnectionOpened = productionEndpointConnectionOpened
        self.productionSecretValueRead = productionSecretValueRead
        self.signedEndpointRuntimeEnabled = signedEndpointRuntimeEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
    }

    public static let requiredScheme = "https"
    public static let requiredHost = "api.binance.com"

    public static func deterministicFixtures() throws -> [ReleaseV0200ProductionShadowEndpointShapeEvidence] {
        [
            try ReleaseV0200ProductionShadowEndpointShapeEvidence(kind: .serverTime),
            try ReleaseV0200ProductionShadowEndpointShapeEvidence(
                kind: .exchangeInfo,
                queryItems: [try ReleaseV0200ProductionShadowEndpointQueryItem(name: "symbol", value: "BTCUSDT")]
            ),
            try ReleaseV0200ProductionShadowEndpointShapeEvidence(
                kind: .tickerPrice,
                queryItems: [try ReleaseV0200ProductionShadowEndpointQueryItem(name: "symbol", value: "BTCUSDT")]
            ),
            try ReleaseV0200ProductionShadowEndpointShapeEvidence(
                kind: .depthSnapshot,
                queryItems: [
                    try ReleaseV0200ProductionShadowEndpointQueryItem(name: "symbol", value: "BTCUSDT"),
                    try ReleaseV0200ProductionShadowEndpointQueryItem(name: "limit", value: "5")
                ]
            )
        ]
    }

    public static func deterministicID(
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        scheme: String,
        host: String,
        path: String,
        queryItems: [ReleaseV0200ProductionShadowEndpointQueryItem]
    ) -> Identifier {
        let querySuffix = queryItems
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "&")
        return .constant(
            [
                "gh-1241-v0200-prod-shadow-endpoint-shape",
                kind.rawValue,
                scheme.lowercased(),
                host.lowercased(),
                path,
                querySuffix
            ].joined(separator: ":"),
            field: "releaseV0200.productionShadowEndpoint.endpointShapeID"
        )
    }
}

private extension ReleaseV0200ProductionShadowEndpointShapeEvidence {
    static func validate(
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        scheme: String,
        host: String,
        path: String,
        queryItems: [ReleaseV0200ProductionShadowEndpointQueryItem],
        productionEndpointConnectionOpened: Bool,
        productionSecretValueRead: Bool,
        signedEndpointRuntimeEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool
    ) throws {
        let endpointFamily = try ReleaseV0190VenueEndpointFamilyRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        guard scheme.lowercased() == endpointFamily.scheme else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.productionShadowEndpoint.scheme",
                expected: endpointFamily.scheme,
                actual: scheme
            )
        }
        guard host.lowercased() == endpointFamily.host else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.productionShadowEndpoint.host",
                expected: endpointFamily.host,
                actual: host
            )
        }
        guard ReleaseV0200ProductionShadowEndpointForbiddenPath(rawValue: path) == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.productionShadowEndpoint.path.\(path)"
            )
        }
        guard path == kind.path else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.productionShadowEndpoint.path",
                expected: kind.path,
                actual: path
            )
        }
        guard isAllowedQueryShape(kind: kind, queryItems: queryItems) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.productionShadowEndpoint.queryShape"
            )
        }
        for (field, value) in [
            ("productionEndpointConnectionOpened", productionEndpointConnectionOpened),
            ("productionSecretValueRead", productionSecretValueRead),
            ("signedEndpointRuntimeEnabled", signedEndpointRuntimeEnabled),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.productionShadowEndpoint.\(field)"
            )
        }
    }

    static func isAllowedQueryShape(
        kind: ReleaseV0200ProductionShadowReadOnlyEndpointKind,
        queryItems: [ReleaseV0200ProductionShadowEndpointQueryItem]
    ) -> Bool {
        var seen = Set<String>()
        for item in queryItems {
            guard seen.insert(item.name).inserted else { return false }
            guard kind.allowedQueryItemNames.contains(item.name) else { return false }
        }
        return true
    }
}

/// ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist 是 GH-1241 的 Binance Spot production-shadow endpoint policy。
///
/// Allowlist 绑定 #1240 environment profile 和 v0.19.0 endpoint family registry，只允许表达 HTTPS +
/// `api.binance.com` + read-only Spot path / query shape。它不连接 production endpoint，不读取 production
/// secret，不实现 signed/account endpoint runtime，不创建 listenKey/private stream，不提交 / 取消 / 替换订单，
/// 不运行 Spot canary，也不授权 production cutover。
public struct ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist: Codable, Equatable, Sendable {
    public let allowlistID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamEnvironmentProfileHeld: Bool
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let endpointScheme: String
    public let endpointHost: String
    public let endpointFamilyReference: String
    public let allowedEndpointEvidence: [ReleaseV0200ProductionShadowEndpointShapeEvidence]
    public let requirements: [ReleaseV0200ProductionShadowEndpointAllowlistRequirement]
    public let forbiddenCapabilities: [ReleaseV0200ProductionShadowEndpointForbiddenCapability]
    public let forbiddenPaths: [ReleaseV0200ProductionShadowEndpointForbiddenPath]
    public let forbiddenQueryItemNames: [ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionEndpointConnectionEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let signedAccountEndpointRuntimeEnabled: Bool
    public let privateStreamRuntimeEnabled: Bool
    public let listenKeyRuntimeEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let orderSubmitCancelReplaceEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var allowlistHeld: Bool {
        issueID.rawValue == "GH-1241"
            && upstreamIssueID.rawValue == "GH-1240"
            && downstreamIssueID.rawValue == "GH-1242"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && upstreamEnvironmentProfileHeld
            && namespaceHeld
            && endpointFamilyHeld
            && allowedEndpointEvidence.map(\.kind) == ReleaseV0200ProductionShadowReadOnlyEndpointKind.allCases
            && allowedEndpointEvidence.allSatisfy(\.shapeHeld)
            && requirements == ReleaseV0200ProductionShadowEndpointAllowlistRequirement.allCases
            && forbiddenCapabilities == ReleaseV0200ProductionShadowEndpointForbiddenCapability.allCases
            && forbiddenPaths == ReleaseV0200ProductionShadowEndpointForbiddenPath.allCases
            && forbiddenQueryItemNames == ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionShadow
    }

    public var endpointFamilyHeld: Bool {
        endpointScheme == ReleaseV0200ProductionShadowEndpointShapeEvidence.requiredScheme
            && endpointHost == ReleaseV0200ProductionShadowEndpointShapeEvidence.requiredHost
            && endpointFamilyReference == "https://api.binance.com"
    }

    public var productionDefaultsClosed: Bool {
        productionEndpointConnectionEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && signedAccountEndpointRuntimeEnabled == false
            && privateStreamRuntimeEnabled == false
            && listenKeyRuntimeEnabled == false
            && productionBrokerConnectionEnabled == false
            && orderSubmitCancelReplaceEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        allowlistID: Identifier = Identifier.constant("gh-1241-release-v0.20.0-binance-spot-production-shadow-endpoint-read-only-allowlist"),
        issueID: Identifier = Identifier.constant("GH-1241"),
        upstreamIssueID: Identifier = Identifier.constant("GH-1240"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1242"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        upstreamEnvironmentProfileHeld: Bool = true,
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionShadow,
        endpointScheme: String = ReleaseV0200ProductionShadowEndpointShapeEvidence.requiredScheme,
        endpointHost: String = ReleaseV0200ProductionShadowEndpointShapeEvidence.requiredHost,
        endpointFamilyReference: String = "https://api.binance.com",
        allowedEndpointEvidence: [ReleaseV0200ProductionShadowEndpointShapeEvidence]? = nil,
        requirements: [ReleaseV0200ProductionShadowEndpointAllowlistRequirement] = ReleaseV0200ProductionShadowEndpointAllowlistRequirement.allCases,
        forbiddenCapabilities: [ReleaseV0200ProductionShadowEndpointForbiddenCapability] = ReleaseV0200ProductionShadowEndpointForbiddenCapability.allCases,
        forbiddenPaths: [ReleaseV0200ProductionShadowEndpointForbiddenPath] = ReleaseV0200ProductionShadowEndpointForbiddenPath.allCases,
        forbiddenQueryItemNames: [ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName] = ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionEndpointConnectionEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        signedAccountEndpointRuntimeEnabled: Bool = false,
        privateStreamRuntimeEnabled: Bool = false,
        listenKeyRuntimeEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        orderSubmitCancelReplaceEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedEvidence: [ReleaseV0200ProductionShadowEndpointShapeEvidence]
        if let allowedEndpointEvidence {
            resolvedEvidence = allowedEndpointEvidence
        } else {
            resolvedEvidence = try ReleaseV0200ProductionShadowEndpointShapeEvidence.deterministicFixtures()
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
            endpointScheme: endpointScheme,
            endpointHost: endpointHost,
            endpointFamilyReference: endpointFamilyReference,
            allowedEndpointEvidence: resolvedEvidence,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            forbiddenPaths: forbiddenPaths,
            forbiddenQueryItemNames: forbiddenQueryItemNames,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrue(upstreamEnvironmentProfileHeld: upstreamEnvironmentProfileHeld)
        try Self.validateForbiddenFlags(
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            signedAccountEndpointRuntimeEnabled: signedAccountEndpointRuntimeEnabled,
            privateStreamRuntimeEnabled: privateStreamRuntimeEnabled,
            listenKeyRuntimeEnabled: listenKeyRuntimeEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            orderSubmitCancelReplaceEnabled: orderSubmitCancelReplaceEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )

        self.allowlistID = allowlistID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamEnvironmentProfileHeld = upstreamEnvironmentProfileHeld
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.endpointScheme = endpointScheme
        self.endpointHost = endpointHost
        self.endpointFamilyReference = endpointFamilyReference
        self.allowedEndpointEvidence = resolvedEvidence
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.forbiddenPaths = forbiddenPaths
        self.forbiddenQueryItemNames = forbiddenQueryItemNames
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.signedAccountEndpointRuntimeEnabled = signedAccountEndpointRuntimeEnabled
        self.privateStreamRuntimeEnabled = privateStreamRuntimeEnabled
        self.listenKeyRuntimeEnabled = listenKeyRuntimeEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.orderSubmitCancelReplaceEnabled = orderSubmitCancelReplaceEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist {
        _ = try ReleaseV0200ProductionShadowEnvironmentProfile.deterministicFixture()
        return try ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist()
    }

    public static let requiredValidationAnchors = [
        "GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST",
        "TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST",
        "V0200-003-BINANCE-SPOT-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST",
        "V0200-003-HTTPS-API-BINANCE-COM-ONLY",
        "V0200-003-READ-ONLY-PATH-ALLOWLIST",
        "V0200-003-QUERY-SHAPE-ALLOWLIST",
        "V0200-003-SIGNED-TRADING-ENDPOINTS-FORBIDDEN",
        "V0200-003-NO-ENDPOINT-CONNECTION",
        "V0200-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1241ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist",
        "bash checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist {
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
        endpointScheme: String,
        endpointHost: String,
        endpointFamilyReference: String,
        allowedEndpointEvidence: [ReleaseV0200ProductionShadowEndpointShapeEvidence],
        requirements: [ReleaseV0200ProductionShadowEndpointAllowlistRequirement],
        forbiddenCapabilities: [ReleaseV0200ProductionShadowEndpointForbiddenCapability],
        forbiddenPaths: [ReleaseV0200ProductionShadowEndpointForbiddenPath],
        forbiddenQueryItemNames: [ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let endpointFamily = try ReleaseV0190VenueEndpointFamilyRegistry.entry(
            venueID: .binance,
            productKind: .spot,
            tradingEnvironment: .productionShadow
        )
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1241", "GH-1241", issueID.rawValue),
            ("upstreamIssueID", upstreamIssueID.rawValue == "GH-1240", "GH-1240", upstreamIssueID.rawValue),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1242", "GH-1242", downstreamIssueID.rawValue),
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
            ("endpointScheme", endpointScheme == endpointFamily.scheme, endpointFamily.scheme, endpointScheme),
            ("endpointHost", endpointHost == endpointFamily.host, endpointFamily.host, endpointHost),
            (
                "endpointFamilyReference",
                endpointFamilyReference == endpointFamily.reference,
                endpointFamily.reference,
                endpointFamilyReference
            ),
            (
                "allowedEndpointEvidence",
                allowedEndpointEvidence.map(\.kind) == ReleaseV0200ProductionShadowReadOnlyEndpointKind.allCases
                    && allowedEndpointEvidence.allSatisfy(\.shapeHeld),
                ReleaseV0200ProductionShadowReadOnlyEndpointKind.allCases.map(\.rawValue).joined(separator: ","),
                allowedEndpointEvidence.map { "\($0.kind.rawValue):\($0.path)" }.joined(separator: ",")
            ),
            (
                "requirements",
                requirements == ReleaseV0200ProductionShadowEndpointAllowlistRequirement.allCases,
                ReleaseV0200ProductionShadowEndpointAllowlistRequirement.allCases.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ReleaseV0200ProductionShadowEndpointForbiddenCapability.allCases,
                ReleaseV0200ProductionShadowEndpointForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenPaths",
                forbiddenPaths == ReleaseV0200ProductionShadowEndpointForbiddenPath.allCases,
                ReleaseV0200ProductionShadowEndpointForbiddenPath.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenPaths.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenQueryItemNames",
                forbiddenQueryItemNames == ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName.allCases,
                ReleaseV0200ProductionShadowEndpointForbiddenQueryItemName.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenQueryItemNames.map(\.rawValue).joined(separator: ",")
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

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrue(upstreamEnvironmentProfileHeld: Bool) throws {
        guard upstreamEnvironmentProfileHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamEnvironmentProfileHeld",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionEndpointConnectionEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        signedAccountEndpointRuntimeEnabled: Bool,
        privateStreamRuntimeEnabled: Bool,
        listenKeyRuntimeEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        orderSubmitCancelReplaceEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("signedAccountEndpointRuntimeEnabled", signedAccountEndpointRuntimeEnabled),
            ("privateStreamRuntimeEnabled", privateStreamRuntimeEnabled),
            ("listenKeyRuntimeEnabled", listenKeyRuntimeEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("orderSubmitCancelReplaceEnabled", orderSubmitCancelReplaceEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
