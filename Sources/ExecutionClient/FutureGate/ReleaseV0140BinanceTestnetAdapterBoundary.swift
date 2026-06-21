import DomainModel
import Foundation

/// ReleaseV0140BinanceTestnetEndpointReference 固定 GH-1028 允许的 Binance testnet endpoint 引用。
///
/// 该引用只校验 Spot 与 USDⓈ-M Perpetual 的 testnet base URL 形状；它不创建
/// 网络请求对象、不打开网络连接、不读取 credential，也不允许 fallback 到 production host。
public struct ReleaseV0140BinanceTestnetEndpointReference: Codable, Equatable, Sendable {
    public let endpointID: Identifier
    public let productType: ProductType
    public let baseURL: URL
    public let explicitTestnetMode: Bool
    public let testnetOnly: Bool
    public let networkSubmitAllowed: Bool
    public let productionEndpoint: Bool
    public let fallbackToProduction: Bool

    public init(
        endpointID: Identifier,
        productType: ProductType,
        baseURL: URL,
        explicitTestnetMode: Bool = true,
        testnetOnly: Bool = true,
        networkSubmitAllowed: Bool = false,
        productionEndpoint: Bool = false,
        fallbackToProduction: Bool = false
    ) throws {
        guard explicitTestnetMode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.explicitTestnetMode",
                expected: "true",
                actual: "false"
            )
        }
        guard baseURL.scheme?.lowercased() == Self.requiredScheme else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.scheme",
                expected: Self.requiredScheme,
                actual: baseURL.scheme ?? "missing"
            )
        }
        guard baseURL.user == nil, baseURL.password == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.userinfo")
        }
        guard baseURL.path.isEmpty || baseURL.path == "/" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.baseURLPath")
        }
        guard baseURL.query == nil, baseURL.fragment == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.baseURLQuery")
        }
        guard let host = baseURL.host?.lowercased() else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.host",
                expected: Self.expectedHost(for: productType),
                actual: "missing"
            )
        }
        guard Self.productionHosts.contains(host) == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.productionHost")
        }
        guard host == Self.expectedHost(for: productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.host",
                expected: Self.expectedHost(for: productType),
                actual: host
            )
        }
        guard testnetOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.testnetOnly",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(networkSubmitAllowed, "networkSubmitAllowed")
        try Self.forbid(productionEndpoint, "productionEndpoint")
        try Self.forbid(fallbackToProduction, "fallbackToProduction")

        self.endpointID = endpointID
        self.productType = productType
        self.baseURL = baseURL
        self.explicitTestnetMode = explicitTestnetMode
        self.testnetOnly = testnetOnly
        self.networkSubmitAllowed = networkSubmitAllowed
        self.productionEndpoint = productionEndpoint
        self.fallbackToProduction = fallbackToProduction
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && testnetOnly
            && networkSubmitAllowed == false
            && productionEndpoint == false
            && fallbackToProduction == false
            && baseURL.scheme?.lowercased() == Self.requiredScheme
            && baseURL.host?.lowercased() == Self.expectedHost(for: productType)
            && baseURL.user == nil
            && baseURL.password == nil
            && (baseURL.path.isEmpty || baseURL.path == "/")
            && baseURL.query == nil
            && baseURL.fragment == nil
    }

    public static let requiredScheme = "https"

    public static let productionHosts: Set<String> = [
        "api.binance.com",
        "fapi.binance.com",
        "dapi.binance.com"
    ]

    public static func expectedHost(for productType: ProductType) -> String {
        switch productType {
        case .spot:
            "testnet.binance.vision"
        case .usdsPerpetual:
            "testnet.binancefuture.com"
        }
    }

    public static func fixture(productType: ProductType) throws -> ReleaseV0140BinanceTestnetEndpointReference {
        try ReleaseV0140BinanceTestnetEndpointReference(
            endpointID: Identifier.constant(
                "gh-1028-binance-testnet-endpoint:\(productType.rawValue)",
                field: "releaseV0140BinanceTestnetAdapter.endpointID"
            ),
            productType: productType,
            baseURL: URL(string: "https://\(expectedHost(for: productType))")!
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetAdapterBoundary 是 GH-1028 的 adapter 边界证据。
///
/// Boundary 只证明 Binance testnet adapter 的产品、策略、endpoint policy 与
/// ExecutionContract mode 对齐。它明确不实现网络 submit / cancel / replace；这些能力必须由
/// 后续 issue 在各自 gate 下单独授权。
public struct ReleaseV0140BinanceTestnetAdapterBoundary: Codable, Equatable, Sendable {
    public let boundaryID: Identifier
    public let venue: String
    public let mode: ExecutionContractAdapterMode
    public let productTypes: [ProductType]
    public let strategyKinds: [OrderIntentStrategyKind]
    public let endpoints: [ReleaseV0140BinanceTestnetEndpointReference]
    public let requestMappingAllowed: Bool
    public let networkSubmitAllowed: Bool
    public let networkCancelReplaceAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        boundaryID: Identifier = Identifier.constant("gh-1028-binance-testnet-adapter-boundary"),
        venue: String = Self.requiredVenue,
        mode: ExecutionContractAdapterMode = .binanceTestnet,
        productTypes: [ProductType] = Self.requiredProductTypes,
        strategyKinds: [OrderIntentStrategyKind] = Self.requiredActiveStrategies,
        endpoints: [ReleaseV0140BinanceTestnetEndpointReference]? = nil,
        requestMappingAllowed: Bool = true,
        networkSubmitAllowed: Bool = false,
        networkCancelReplaceAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let resolvedEndpoints = try endpoints ?? Self.requiredEndpointReferences()

        guard venue == Self.requiredVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.nonBinanceVenue")
        }
        guard mode == .binanceTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.mode",
                expected: ExecutionContractAdapterMode.binanceTestnet.rawValue,
                actual: mode.rawValue
            )
        }
        guard productTypes == Self.requiredProductTypes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.productTypes",
                expected: Self.requiredProductTypes.map(\.rawValue).joined(separator: ","),
                actual: productTypes.map(\.rawValue).joined(separator: ",")
            )
        }
        guard strategyKinds == Self.requiredActiveStrategies else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.strategyKinds",
                expected: Self.requiredActiveStrategies.map(\.rawValue).joined(separator: ","),
                actual: strategyKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard resolvedEndpoints.map(\.productType) == Self.requiredProductTypes,
              resolvedEndpoints.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.endpoints",
                expected: "boundary-held spot and usdsPerpetual testnet endpoints",
                actual: resolvedEndpoints.map { "\($0.productType.rawValue):\($0.baseURL.absoluteString)" }.joined(separator: ",")
            )
        }
        guard requestMappingAllowed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.requestMappingAllowed",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(networkSubmitAllowed, "networkSubmitAllowed")
        try Self.forbid(networkCancelReplaceAllowed, "networkCancelReplaceAllowed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetAdapter.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.boundaryID = boundaryID
        self.venue = venue
        self.mode = mode
        self.productTypes = productTypes
        self.strategyKinds = strategyKinds
        self.endpoints = resolvedEndpoints
        self.requestMappingAllowed = requestMappingAllowed
        self.networkSubmitAllowed = networkSubmitAllowed
        self.networkCancelReplaceAllowed = networkCancelReplaceAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        venue == Self.requiredVenue
            && mode == .binanceTestnet
            && productTypes == Self.requiredProductTypes
            && strategyKinds == Self.requiredActiveStrategies
            && endpoints.map(\.productType) == Self.requiredProductTypes
            && endpoints.allSatisfy(\.boundaryHeld)
            && requestMappingAllowed
            && networkSubmitAllowed == false
            && networkCancelReplaceAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredVenue = "binance"

    public static let requiredProductTypes: [ProductType] = [
        .spot,
        .usdsPerpetual
    ]

    public static let requiredActiveStrategies: [OrderIntentStrategyKind] = [
        .ema,
        .rsi
    ]

    public static let requiredValidationAnchors = [
        "GH-1028-BINANCE-TESTNET-ADAPTER-BOUNDARY",
        "GH-1028-BINANCE-TESTNET-ENDPOINT-POLICY",
        "GH-1028-BINANCE-TESTNET-NO-NETWORK-SUBMIT",
        "TVM-RELEASE-V0140-BINANCE-TESTNET-ADAPTER-BOUNDARY"
    ]

    public static func requiredEndpointReferences() throws -> [ReleaseV0140BinanceTestnetEndpointReference] {
        try requiredProductTypes.map { try ReleaseV0140BinanceTestnetEndpointReference.fixture(productType: $0) }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetAdapter.\(field)")
        }
    }
}
