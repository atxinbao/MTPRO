import Crypto
import DomainModel
import Foundation

// GH-1067 静态合同边界：
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetCredentialProviderKind 描述 v0.15.0 允许的 testnet credential 引用来源。
///
/// 该枚举只表达 reference source，不读取环境变量、keychain 或 production secret。真实 secret
/// 只能由调用方以短生命周期 material 注入，且不得写入 evidence、日志、Dashboard 或文档。
public enum ReleaseV0150BinanceSpotTestnetCredentialProviderKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case operatorProvidedReference = "operatorProvidedReference"
    case testnetEnvironmentReference = "testnetEnvironmentReference"
}

/// ReleaseV0150BinanceSpotTestnetCredentialReference 是 GH-1067 的 credential identity gate。
///
/// 它只保存可审计 reference ID 和 provider kind；secret value、API key value、production secret reader
/// 和 broker endpoint 都被明确排除。后续 submit runtime 只能消费该 redacted reference 与短生命周期
/// material，不能把 material 序列化进 request evidence。
public struct ReleaseV0150BinanceSpotTestnetCredentialReference: Codable, Equatable, Sendable, CustomStringConvertible {
    public let referenceID: Identifier
    public let providerKind: ReleaseV0150BinanceSpotTestnetCredentialProviderKind
    public let redactionPolicy: String
    public let operatorConfirmationRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionSecretValueRead: Bool
    public let productionSecretValueStored: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let secretValuePrinted: Bool

    public init(
        referenceID: Identifier,
        providerKind: ReleaseV0150BinanceSpotTestnetCredentialProviderKind,
        redactionPolicy: String = Self.requiredRedactionPolicy,
        operatorConfirmationRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionSecretValueRead: Bool = false,
        productionSecretValueStored: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        secretValuePrinted: Bool = false
    ) throws {
        guard redactionPolicy == Self.requiredRedactionPolicy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialReference.redactionPolicy",
                expected: Self.requiredRedactionPolicy,
                actual: redactionPolicy
            )
        }
        guard operatorConfirmationRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialReference.operatorConfirmationRequired",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionSecretValueRead, "productionSecretValueRead")
        try Self.forbid(productionSecretValueStored, "productionSecretValueStored")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(secretValuePrinted, "secretValuePrinted")

        self.referenceID = referenceID
        self.providerKind = providerKind
        self.redactionPolicy = redactionPolicy
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionSecretValueRead = productionSecretValueRead
        self.productionSecretValueStored = productionSecretValueStored
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.secretValuePrinted = secretValuePrinted
    }

    public var boundaryHeld: Bool {
        redactionPolicy == Self.requiredRedactionPolicy
            && operatorConfirmationRequired
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionSecretValueRead == false
            && productionSecretValueStored == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && secretValuePrinted == false
    }

    public var redactedDescription: String {
        "\(referenceID.rawValue):<redacted>"
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCredentialReference(referenceID: \(redactedDescription), providerKind: \(providerKind.rawValue), redactionPolicy: \(redactionPolicy))"
    }

    public static let requiredRedactionPolicy = "redactedIdentifierOnly"

    public static func deterministicFixture(
        referenceID: Identifier = .constant("gh-1067-binance-spot-testnet-credential")
    ) throws -> ReleaseV0150BinanceSpotTestnetCredentialReference {
        try ReleaseV0150BinanceSpotTestnetCredentialReference(
            referenceID: referenceID,
            providerKind: .operatorProvidedReference
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.credentialReference.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCredentialMaterial 是签名时短生命周期进入内存的 testnet material。
///
/// 该类型不实现 Codable，避免 API key / secret 被持久化。`binanceAPIKeyHeaderValue()` 只服务后续
/// transport handoff；GH-1067 的 signed request evidence 不会保存该 header value。
public struct ReleaseV0150BinanceSpotTestnetCredentialMaterial: Sendable, CustomStringConvertible {
    public let reference: ReleaseV0150BinanceSpotTestnetCredentialReference
    private let apiKeyHeaderValue: String
    private let signingSecretValue: String

    public init(
        reference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        apiKeyHeaderValue: String,
        signingSecretValue: String
    ) throws {
        guard reference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.credentialMaterial.reference")
        }

        let trimmedHeader = apiKeyHeaderValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecret = signingSecretValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedHeader.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialMaterial.apiKeyHeaderValue",
                expected: "non-empty testnet API key header",
                actual: "empty"
            )
        }
        guard trimmedSecret.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialMaterial.signingSecretValue",
                expected: "non-empty testnet signing secret",
                actual: "empty"
            )
        }

        self.reference = reference
        self.apiKeyHeaderValue = trimmedHeader
        self.signingSecretValue = trimmedSecret
    }

    public func binanceAPIKeyHeaderValue() -> String {
        apiKeyHeaderValue
    }

    public func signature(for canonicalQueryString: String) -> String {
        let key = SymmetricKey(data: Data(signingSecretValue.utf8))
        let signature = HMAC<SHA256>.authenticationCode(
            for: Data(canonicalQueryString.utf8),
            using: key
        )
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCredentialMaterial(reference: \(reference.redactedDescription), apiKeyHeaderValue: <redacted>, signingSecretValue: <redacted>)"
    }
}

/// ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence 记录 GH-1067 的签名请求构造结果。
///
/// Evidence 只证明 Binance Spot Testnet `/api/v3/order` 的 canonical query 和 signature 构造正确。
/// 它不保存 API key / secret，不创建 URLRequest，不发送网络请求，也不授权 production order。
public struct ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence: Codable, Equatable, Sendable, CustomStringConvertible {
    public let requestID: Identifier
    public let credentialReferenceID: Identifier
    public let credentialReferenceRedacted: String
    public let productType: ProductType
    public let symbol: Symbol
    public let side: OrderIntentSide
    public let orderType: String
    public let quantityText: String
    public let timestampMilliseconds: Int64
    public let receiveWindowMilliseconds: Int
    public let httpMethod: String
    public let endpointHost: String
    public let endpointPath: String
    public let unsignedQueryString: String
    public let signature: String
    public let signedQueryString: String
    public let apiKeyHeaderName: String
    public let apiKeyHeaderValueRedacted: Bool
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let networkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        requestID: Identifier,
        credentialReference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        productType: ProductType,
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int,
        unsignedQueryString: String,
        signature: String,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        networkSubmitPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard credentialReference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.unheldCredentialReference")
        }
        guard productType == Self.requiredProductType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.productType",
                expected: Self.requiredProductType.rawValue,
                actual: productType.rawValue
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.quantity",
                expected: "positive Spot Testnet order quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard timestampMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.timestampMilliseconds",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds)"
            )
        }
        guard receiveWindowMilliseconds > 0, receiveWindowMilliseconds <= 60_000 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.receiveWindowMilliseconds",
                expected: "1...60000",
                actual: "\(receiveWindowMilliseconds)"
            )
        }
        guard signature.count == 64, signature.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.signature",
                expected: "64 lowercase hex characters",
                actual: signature
            )
        }
        guard explicitTestnetMode, spotTestnetOnly, requestBodyRedacted, credentialMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.unredactedOrNonTestnetEvidence")
        }
        try Self.forbid(networkSubmitPerformed, "networkSubmitPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.requestID = requestID
        self.credentialReferenceID = credentialReference.referenceID
        self.credentialReferenceRedacted = credentialReference.redactedDescription
        self.productType = productType
        self.symbol = symbol
        self.side = side
        self.orderType = Self.marketOrderType
        self.quantityText = Self.quantityText(quantity)
        self.timestampMilliseconds = timestampMilliseconds
        self.receiveWindowMilliseconds = receiveWindowMilliseconds
        self.httpMethod = Self.httpMethod
        self.endpointHost = Self.canonicalSpotTestnetHost
        self.endpointPath = Self.spotOrderEndpointPath
        self.unsignedQueryString = unsignedQueryString
        self.signature = signature
        self.signedQueryString = "\(unsignedQueryString)&signature=\(signature)"
        self.apiKeyHeaderName = Self.apiKeyHeaderName
        self.apiKeyHeaderValueRedacted = true
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.networkSubmitPerformed = networkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        productType == Self.requiredProductType
            && orderType == Self.marketOrderType
            && httpMethod == Self.httpMethod
            && endpointHost == Self.canonicalSpotTestnetHost
            && endpointPath == Self.spotOrderEndpointPath
            && apiKeyHeaderName == Self.apiKeyHeaderName
            && apiKeyHeaderValueRedacted
            && explicitTestnetMode
            && spotTestnetOnly
            && requestBodyRedacted
            && credentialMaterialRedacted
            && networkSubmitPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && signedQueryString == "\(unsignedQueryString)&signature=\(signature)"
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence(requestID: \(requestID.rawValue), credentialReference: \(credentialReferenceRedacted), endpoint: \(endpointHost)\(endpointPath), apiKeyHeaderValue: <redacted>, credentialMaterial: <redacted>, networkSubmitPerformed: \(networkSubmitPerformed))"
    }

    public static let requiredProductType: ProductType = .spot
    public static let canonicalSpotTestnetHost = "testnet.binance.vision"
    public static let spotOrderEndpointPath = "/api/v3/order"
    public static let httpMethod = "POST"
    public static let marketOrderType = "MARKET"
    public static let apiKeyHeaderName = "X-MBX-APIKEY"
    public static let requiredValidationAnchors = [
        "GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST",
        "TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST",
        "V0150-002-CREDENTIAL-REFERENCE",
        "V0150-002-HMAC-SHA256-SIGNED-REQUEST",
        "V0150-002-BINANCE-SPOT-TESTNET-ONLY",
        "V0150-002-NO-PRODUCTION-SECRET-AUTO-READ",
        "V0150-002-PRODUCTION-ENDPOINT-BLOCKED",
        "V0150-002-REDACTED-EVIDENCE",
        "V0150-002-NO-NETWORK-ACTION"
    ]

    public static func deterministicID(
        credentialReferenceID: Identifier,
        symbol: Symbol,
        side: OrderIntentSide,
        timestampMilliseconds: Int64
    ) -> Identifier {
        .constant(
            "gh-1067-binance-spot-testnet-signed-request:\(credentialReferenceID.rawValue):\(symbol.rawValue):\(side.rawValue):\(timestampMilliseconds)",
            field: "releaseV0150SignedRequest.requestID"
        )
    }

    public static func quantityText(_ quantity: Quantity) -> String {
        String(format: "%.8f", locale: Locale(identifier: "en_US_POSIX"), quantity.rawValue)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.evidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetSignedRequestBuilder 构造 GH-1067 的 Spot Testnet signed request evidence。
///
/// Builder 只接受 canonical `https://testnet.binance.vision` 和 `/api/v3/order`。它不创建
/// URLRequest、不调用 URLSession、不读取 secret store，也不把 Binance Spot Testnet 扩大到
/// USDⓈ-M Perpetual 或 production endpoint。
public struct ReleaseV0150BinanceSpotTestnetSignedRequestBuilder: Equatable, Sendable {
    public let baseURL: URL
    public let productType: ProductType
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool

    public init(
        baseURL: URL? = nil,
        productType: ProductType = .spot,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false
    ) throws {
        let resolvedBaseURL = try baseURL ?? Self.canonicalBaseURL()
        guard explicitTestnetMode, spotTestnetOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.nonTestnetMode")
        }
        guard productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.productType",
                expected: ProductType.spot.rawValue,
                actual: productType.rawValue
            )
        }
        try Self.validateCanonicalBaseURL(resolvedBaseURL)
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")

        self.baseURL = resolvedBaseURL
        self.productType = productType
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && explicitTestnetMode
            && spotTestnetOnly
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && baseURL.scheme?.lowercased() == "https"
            && baseURL.host?.lowercased() == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && (baseURL.path.isEmpty || baseURL.path == "/")
            && baseURL.query == nil
            && baseURL.fragment == nil
            && baseURL.user == nil
            && baseURL.password == nil
    }

    public func buildMarketSubmitRequest(
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestamp: Date,
        receiveWindowMilliseconds: Int = 5_000
    ) throws -> ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.boundary")
        }
        let timestampMilliseconds = try Self.timestampMilliseconds(timestamp)
        let unsignedQueryString = Self.unsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantity: quantity,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let signature = credential.signature(for: unsignedQueryString)
        let requestID = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.deterministicID(
            credentialReferenceID: credential.reference.referenceID,
            symbol: symbol,
            side: side,
            timestampMilliseconds: timestampMilliseconds
        )

        return try ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence(
            requestID: requestID,
            credentialReference: credential.reference,
            productType: productType,
            symbol: symbol,
            side: side,
            quantity: quantity,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds,
            unsignedQueryString: unsignedQueryString,
            signature: signature
        )
    }

    public static func canonicalBaseURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
        guard let url = components.url else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.canonicalBaseURL",
                expected: "https://testnet.binance.vision",
                actual: "unconstructable"
            )
        }
        return url
    }

    public static func unsignedMarketOrderQueryString(
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        [
            "symbol=\(symbol.rawValue)",
            "side=\(side.rawValue.uppercased())",
            "type=\(ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.marketOrderType)",
            "quantity=\(ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.quantityText(quantity))",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
    }

    private static let forbiddenProductionHosts: Set<String> = [
        "api.binance.com",
        "fapi.binance.com",
        "dapi.binance.com"
    ]

    private static func validateCanonicalBaseURL(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.baseURL",
                expected: "https://testnet.binance.vision",
                actual: url.absoluteString
            )
        }
        let host = components.host?.lowercased() ?? ""
        guard forbiddenProductionHosts.contains(host) == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.productionHost")
        }
        guard components.scheme?.lowercased() == "https",
              host == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost,
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.percentEncodedPath.isEmpty,
              components.percentEncodedQuery == nil,
              components.percentEncodedFragment == nil else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.baseURL",
                expected: "https://testnet.binance.vision",
                actual: url.absoluteString
            )
        }
    }

    private static func timestampMilliseconds(_ timestamp: Date) throws -> Int64 {
        guard timestamp.timeIntervalSince1970.isFinite, timestamp.timeIntervalSince1970 > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.timestamp",
                expected: "positive unix timestamp",
                actual: "\(timestamp)"
            )
        }
        return Int64((timestamp.timeIntervalSince1970 * 1_000).rounded())
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.\(field)")
        }
    }
}
