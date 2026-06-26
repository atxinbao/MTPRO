import Crypto
import DomainModel
import Foundation

// GH-1105 static contract boundary:
// cliCommand=spot-testnet-status-query
// httpMethod=GET
// endpointHost=testnet.binance.vision
// endpointPath=/api/v3/order
// sourceSubmitArtifactConsumed=true
// redactedOrderReferenceConsumed=true
// signedGETOrderStatusQueryPerformed=true
// redactedRequestResponseEvidence=true
// productionHostRejected=true
// missingPriorArtifactFailsClosed=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false
// GH-1137-VERIFY-V0161-STATUS-QUERY-TRANSPORT-WORDING
// TVM-RELEASE-V0161-STATUS-QUERY-TRANSPORT-WORDING
// V0161-005-REQUEST-EVIDENCE-FLAG-CLARIFIED
// V0161-005-TRANSPORT-RESULT-EVIDENCE-CLARIFIED
// V0161-005-NO-FAKE-STATUS-QUERY-WORDING
// V0161-005-NO-PRODUCTION-READINESS-OVERSTATEMENT
// requestEvidenceNetworkStatusQueryPerformed=false
// statusTransportResultEvidence=guarded-testnet-status-result

/// ReleaseV0160CLIOrderStatusQueryFlowError 描述 GH-1105 稳定 status query CLI 的 fail-closed 错误。
///
/// 该错误只覆盖 Binance Spot Testnet operator beta 的 signed GET `/api/v3/order` 状态观察。
/// 它不授权 production endpoint、broker endpoint、production secret、生产订单或 production cutover。
public enum ReleaseV0160CLIOrderStatusQueryFlowError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidArgument(field: String, expected: String, actual: String)
    case forbiddenProductionArgument(String)
    case forbiddenAction(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .invalidArgument(field, expected, actual):
            "Release v0.16.0 CLI order status query invalid argument \(field): expected \(expected), actual \(actual)"
        case let .forbiddenProductionArgument(argument):
            "Release v0.16.0 CLI order status query forbids production argument: \(argument)"
        case let .forbiddenAction(action):
            "Release v0.16.0 CLI order status query only supports status query, actual \(action)"
        case let .boundaryDrift(field):
            "Release v0.16.0 CLI order status query boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence 记录 signed GET order status request。
///
/// Evidence 只保存 testnet host、GET 方法、redacted unsigned query digest、signature 和 redacted
/// order reference。真实 API key、secret、raw originalClientOrderId 和完整 signed query 只在调用栈内短暂存在。
public struct ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence: Codable, Equatable, Sendable, CustomStringConvertible {
    public let requestID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let intentID: Identifier
    public let credentialReferenceID: Identifier
    public let credentialReferenceRedacted: String
    public let orderIdentityReferenceID: Identifier
    public let orderIdentityReferenceRedacted: String
    public let productType: ProductType
    public let symbol: Symbol
    public let timestampMilliseconds: Int64
    public let receiveWindowMilliseconds: Int
    public let httpMethod: String
    public let endpointHost: String
    public let endpointPath: String
    public let redactedUnsignedQueryDigest: String
    public let signature: String
    public let signedQueryStringRedacted: Bool
    public let apiKeyHeaderName: String
    public let apiKeyHeaderValueRedacted: Bool
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let orderIdentityMaterialRedacted: Bool
    /// Request evidence 只描述本地 signed GET request shape。
    ///
    /// `networkStatusQueryPerformed=false` 不是说 status query 是 fake / mock；
    /// 它表示 request evidence 本身不直接声明 transport side effect。真正的 guarded
    /// Testnet status transport result 由 `ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult`
    /// 单独记录，避免把 request construction 和 transport result 混成同一个证据层。
    public let networkStatusQueryPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        requestID: Identifier,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        credentialReference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        orderIdentityReference: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference,
        symbol: Symbol,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int,
        redactedUnsignedQueryDigest: String,
        signature: String,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        signedQueryStringRedacted: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        orderIdentityMaterialRedacted: Bool = true,
        networkStatusQueryPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.productType == .spot,
              sourceSubmitEvidence.orderLifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.signedRequest.sourceSubmitEvidence")
        }
        guard credentialReference.boundaryHeld,
              credentialReference.referenceID == sourceSubmitEvidence.credentialReferenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.credentialReference",
                expected: sourceSubmitEvidence.credentialReferenceID.rawValue,
                actual: credentialReference.referenceID.rawValue
            )
        }
        guard orderIdentityReference.boundaryHeld,
              orderIdentityReference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              orderIdentityReference.intentID == sourceSubmitEvidence.intentID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.orderIdentityReference",
                expected: sourceSubmitEvidence.runtimeEvidenceID.rawValue,
                actual: orderIdentityReference.sourceSubmitRuntimeEvidenceID.rawValue
            )
        }
        guard timestampMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.timestampMilliseconds",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds)"
            )
        }
        guard receiveWindowMilliseconds > 0, receiveWindowMilliseconds <= 60_000 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.receiveWindowMilliseconds",
                expected: "1...60000",
                actual: "\(receiveWindowMilliseconds)"
            )
        }
        guard redactedUnsignedQueryDigest.count == 64, redactedUnsignedQueryDigest.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.redactedUnsignedQueryDigest",
                expected: "64 lowercase hex characters",
                actual: redactedUnsignedQueryDigest
            )
        }
        guard signature.count == 64, signature.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.signature",
                expected: "64 lowercase hex characters",
                actual: signature
            )
        }
        guard requestID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            orderIdentityReferenceID: orderIdentityReference.referenceID,
            timestampMilliseconds: timestampMilliseconds
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.requestID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                    orderIdentityReferenceID: orderIdentityReference.referenceID,
                    timestampMilliseconds: timestampMilliseconds
                ).rawValue,
                actual: requestID.rawValue
            )
        }
        guard explicitTestnetMode,
              spotTestnetOnly,
              signedQueryStringRedacted,
              requestBodyRedacted,
              credentialMaterialRedacted,
              orderIdentityMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.signedRequest.unredactedOrNonTestnet")
        }
        try Self.forbid(networkStatusQueryPerformed, "networkStatusQueryPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.requestID = requestID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.intentID = sourceSubmitEvidence.intentID
        self.credentialReferenceID = credentialReference.referenceID
        self.credentialReferenceRedacted = credentialReference.redactedDescription
        self.orderIdentityReferenceID = orderIdentityReference.referenceID
        self.orderIdentityReferenceRedacted = orderIdentityReference.redactedDescription
        self.productType = .spot
        self.symbol = symbol
        self.timestampMilliseconds = timestampMilliseconds
        self.receiveWindowMilliseconds = receiveWindowMilliseconds
        self.httpMethod = Self.httpMethod
        self.endpointHost = Self.canonicalSpotTestnetHost
        self.endpointPath = Self.spotOrderEndpointPath
        self.redactedUnsignedQueryDigest = redactedUnsignedQueryDigest
        self.signature = signature
        self.signedQueryStringRedacted = signedQueryStringRedacted
        self.apiKeyHeaderName = Self.apiKeyHeaderName
        self.apiKeyHeaderValueRedacted = true
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.orderIdentityMaterialRedacted = orderIdentityMaterialRedacted
        self.networkStatusQueryPerformed = networkStatusQueryPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && httpMethod == Self.httpMethod
            && endpointHost == Self.canonicalSpotTestnetHost
            && endpointPath == Self.spotOrderEndpointPath
            && redactedUnsignedQueryDigest.count == 64
            && signature.count == 64
            && signedQueryStringRedacted
            && apiKeyHeaderName == Self.apiKeyHeaderName
            && apiKeyHeaderValueRedacted
            && explicitTestnetMode
            && spotTestnetOnly
            && requestBodyRedacted
            && credentialMaterialRedacted
            && orderIdentityMaterialRedacted
            && networkStatusQueryPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var description: String {
        "ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence(requestID: \(requestID.rawValue), sourceSubmitRuntimeEvidenceID: \(sourceSubmitRuntimeEvidenceID.rawValue), credentialReference: \(credentialReferenceRedacted), orderIdentity: <redacted>, endpoint: \(endpointHost)\(endpointPath), signedQueryString: <redacted>, apiKeyHeaderValue: <redacted>)"
    }

    public static let canonicalSpotTestnetHost = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
    public static let spotOrderEndpointPath = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
    public static let apiKeyHeaderName = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.apiKeyHeaderName
    public static let httpMethod = "GET"
    public static let requiredValidationAnchors = [
        "GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY",
        "TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY",
        "V0160-005-SIGNED-GET-ORDER-STATUS",
        "V0160-005-TESTNET-ENDPOINT-ALLOWLIST",
        "V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE",
        "V0160-005-NO-RAW-SECRET-PERSISTENCE",
        "V0160-005-PRODUCTION-HOST-REJECTED",
        "V0160-005-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        orderIdentityReferenceID: Identifier,
        timestampMilliseconds: Int64
    ) -> Identifier {
        .constant(
            "gh-1105-spot-testnet-order-status-request:\(sourceSubmitRuntimeEvidenceID.rawValue):\(orderIdentityReferenceID.rawValue):\(timestampMilliseconds)",
            field: "releaseV0160OrderStatus.signedRequest.requestID"
        )
    }

    public static func timestampMilliseconds(_ timestamp: Date) throws -> Int64 {
        guard timestamp.timeIntervalSince1970.isFinite, timestamp.timeIntervalSince1970 > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.signedRequest.timestamp",
                expected: "positive unix timestamp",
                actual: "\(timestamp)"
            )
        }
        return Int64((timestamp.timeIntervalSince1970 * 1_000).rounded())
    }

    public static func unsignedOrderStatusQueryString(
        symbol: Symbol,
        originalClientOrderID: String,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        [
            "symbol=\(symbol.rawValue)",
            "origClientOrderId=\(originalClientOrderID)",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
    }

    public static func redactedUnsignedQueryDigest(for unsignedQueryString: String) -> String {
        let payload = "gh-1105-redacted-status-query:\(unsignedQueryString)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.signedRequest.\(field)")
        }
    }
}

public extension ReleaseV0150BinanceSpotTestnetSignedRequestBuilder {
    /// 构造 Binance Spot Testnet signed GET order status query evidence。
    ///
    /// 该方法复用 prior submit evidence 和 redacted order identity，生成可审计签名证据；
    /// raw originalClientOrderId 只作为短生命周期 material 进入签名，不进入 Codable evidence。
    func buildOrderStatusQueryRequest(
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        symbol: Symbol,
        timestamp: Date,
        receiveWindowMilliseconds: Int = 5_000
    ) throws -> ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.requestBuilder.boundary")
        }
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.credentialReferenceID == credential.reference.referenceID,
              orderIdentity.reference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.requestBuilder.sourceSubmit",
                expected: sourceSubmitEvidence.runtimeEvidenceID.rawValue,
                actual: orderIdentity.reference.sourceSubmitRuntimeEvidenceID.rawValue
            )
        }
        let timestampMilliseconds = try ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence
            .timestampMilliseconds(timestamp)
        let unsignedQueryString = ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence
            .unsignedOrderStatusQueryString(
                symbol: symbol,
                originalClientOrderID: orderIdentity.binanceOriginalClientOrderID(),
                timestampMilliseconds: timestampMilliseconds,
                receiveWindowMilliseconds: receiveWindowMilliseconds
            )
        let signature = credential.signature(for: unsignedQueryString)
        let redactedDigest = ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence
            .redactedUnsignedQueryDigest(for: unsignedQueryString)
        let requestID = ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            orderIdentityReferenceID: orderIdentity.reference.referenceID,
            timestampMilliseconds: timestampMilliseconds
        )

        return try ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence(
            requestID: requestID,
            sourceSubmitEvidence: sourceSubmitEvidence,
            credentialReference: credential.reference,
            orderIdentityReference: orderIdentity.reference,
            symbol: symbol,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds,
            redactedUnsignedQueryDigest: redactedDigest,
            signature: signature
        )
    }
}

/// ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult 是 signed GET status query 的脱敏结果。
///
/// Transport 可以执行 Binance Spot Testnet GET `/api/v3/order`，但只能返回 HTTP 状态、
/// redacted response digest 和禁区 flags，不保存 raw response body、API key、secret 或 raw order identity。
public struct ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult: Codable, Equatable, Sendable, CustomStringConvertible {
    public let transportResultID: Identifier
    public let signedStatusQueryRequestID: Identifier
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let acceptedByTestnet: Bool
    public let orderStatusObserved: Bool
    public let orderStatusRedacted: Bool
    public let responseBodyRedacted: Bool
    public let redactedResponseDigest: String
    public let testnetNetworkStatusQueryPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        transportResultID: Identifier,
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        httpStatusCode: Int,
        redactedResponseDigest: String,
        acceptedByTestnet: Bool = true,
        orderStatusObserved: Bool = true,
        orderStatusRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        testnetNetworkStatusQueryPerformed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard signedRequest.boundaryHeld,
              signedRequest.productType == .spot,
              signedRequest.httpMethod == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.httpMethod,
              signedRequest.endpointHost == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.canonicalSpotTestnetHost else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.transportResult.signedRequest")
        }
        guard transportResultID == Self.deterministicID(
            signedStatusQueryRequestID: signedRequest.requestID,
            httpStatusCode: httpStatusCode,
            redactedResponseDigest: redactedResponseDigest
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.transportResultID",
                expected: Self.deterministicID(
                    signedStatusQueryRequestID: signedRequest.requestID,
                    httpStatusCode: httpStatusCode,
                    redactedResponseDigest: redactedResponseDigest
                ).rawValue,
                actual: transportResultID.rawValue
            )
        }
        guard (200..<300).contains(httpStatusCode), acceptedByTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.httpStatusCode",
                expected: "2xx accepted Spot Testnet status response",
                actual: "\(httpStatusCode)"
            )
        }
        guard orderStatusObserved, orderStatusRedacted, responseBodyRedacted, testnetNetworkStatusQueryPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.transportResult.unredactedOrMissingStatus")
        }
        guard redactedResponseDigest.count == 64, redactedResponseDigest.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0160OrderStatus.redactedResponseDigest",
                expected: "64 lowercase hex characters",
                actual: redactedResponseDigest
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.transportResultID = transportResultID
        self.signedStatusQueryRequestID = signedRequest.requestID
        self.endpointHost = signedRequest.endpointHost
        self.endpointPath = signedRequest.endpointPath
        self.httpStatusCode = httpStatusCode
        self.acceptedByTestnet = acceptedByTestnet
        self.orderStatusObserved = orderStatusObserved
        self.orderStatusRedacted = orderStatusRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.redactedResponseDigest = redactedResponseDigest
        self.testnetNetworkStatusQueryPerformed = testnetNetworkStatusQueryPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        endpointHost == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence.spotOrderEndpointPath
            && (200..<300).contains(httpStatusCode)
            && acceptedByTestnet
            && orderStatusObserved
            && orderStatusRedacted
            && responseBodyRedacted
            && redactedResponseDigest.count == 64
            && testnetNetworkStatusQueryPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var description: String {
        "ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult(signedStatusQueryRequestID: \(signedStatusQueryRequestID.rawValue), httpStatusCode: \(httpStatusCode), responseBody: <redacted>, orderStatus: <redacted>, testnetNetworkStatusQueryPerformed: \(testnetNetworkStatusQueryPerformed))"
    }

    public static func redactedDigest(statusCode: Int, acknowledgement: String) -> String {
        let payload = "gh-1105-redacted-status-response:\(statusCode):\(acknowledgement)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func deterministicID(
        signedStatusQueryRequestID: Identifier,
        httpStatusCode: Int,
        redactedResponseDigest: String
    ) -> Identifier {
        .constant(
            "gh-1105-spot-testnet-status-transport-result:\(signedStatusQueryRequestID.rawValue):\(httpStatusCode):\(redactedResponseDigest)",
            field: "releaseV0160OrderStatus.transportResultID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatus.transportResult.\(field)")
        }
    }
}

/// ReleaseV0160BinanceSpotTestnetOrderStatusTransport 是 signed GET status query 的注入式 transport 边界。
///
/// 实现方只能消费 redacted signed request evidence、短生命周期 credential 和短生命周期 order identity。
/// 返回值必须是 redacted status observation evidence，不能持久化 raw secret、raw order identity 或 production data。
public protocol ReleaseV0160BinanceSpotTestnetOrderStatusTransport: Sendable {
    func querySpotTestnetOrderStatus(
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial
    ) async throws -> ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult
}

/// ReleaseV0160CLIOrderStatusQueryCommand 是 GH-1105 解析后的 stable status query command。
public struct ReleaseV0160CLIOrderStatusQueryCommand: Equatable, Sendable {
    public let runID: Identifier
    public let operatorConfirmationPhrase: String
    public let credentialProviderKind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind
    public let credentialReferenceID: Identifier
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String
    public let symbol: String
    public let side: String
    public let quantity: String
    public let strategy: String
    public let sourceSequence: Int
    public let correlationID: Identifier
    public let strategySignalID: Identifier
    public let sourceMessageID: Identifier
    public let strategyRunID: Identifier
    public let intentID: Identifier?
    public let sourceSubmitEvidenceJSONPath: String
    public let networkEventLogJSONPath: String
    public let originalClientOrderID: String?
    public let timestampMilliseconds: Int64
    public let observedAtMilliseconds: Int64
    public let redactedOutputRequested: Bool

    public var boundaryHeld: Bool {
        operatorConfirmationPhrase == ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase
            && credentialProviderKind == .testnetEnvironment
            && apiKeyEnvironmentName.uppercased().contains("TESTNET")
            && secretEnvironmentName.uppercased().contains("TESTNET")
            && sourceSubmitEvidenceJSONPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && networkEventLogJSONPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && redactedOutputRequested
            && runID.rawValue.isEmpty == false
    }
}

/// ReleaseV0160CLIOrderStatusQueryResult 是 GH-1105 stable status query CLI 的脱敏输出。
public struct ReleaseV0160CLIOrderStatusQueryResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let command: String
    public let action: String
    public let runID: Identifier
    public let operatorRunState: ReleaseV0160OperatorRunState
    public let operatorRunActionSequence: [ReleaseV0160OperatorRunAction]
    public let artifactPath: String
    public let artifactChecksum: String
    public let signedStatusQueryRequestID: Identifier
    public let statusTransportResultID: Identifier
    public let sourceSubmitEvidenceJSONPath: String
    public let networkEventLogJSONPath: String
    public let credentialProvider: String
    public let explicitOperatorConfirmationRequired: Bool
    public let operatorConfirmationAccepted: Bool
    public let sourceSubmitArtifactConsumed: Bool
    public let redactedOrderReferenceConsumed: Bool
    public let signedGETOrderStatusQueryPerformed: Bool
    public let testnetEndpointAllowlisted: Bool
    public let redactedRequestResponseEvidence: Bool
    public let productionHostRejected: Bool
    public let missingPriorArtifactFailsClosed: Bool
    public let redactedOutputPrinted: Bool
    public let artifactPathReturned: Bool
    public let checksumReturned: Bool
    public let rawSecretPrinted: Bool
    public let rawCredentialPrinted: Bool
    public let rawOrderIdentityPrinted: Bool
    public let rawBrokerPayloadPrinted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        resultID: Identifier,
        runID: Identifier,
        operatorRunModel: ReleaseV0160OperatorRunModel,
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        transportResult: ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult,
        sourceSubmitEvidenceJSONPath: String,
        networkEventLogJSONPath: String,
        artifactPath: String,
        artifactChecksum: String,
        command: String = ReleaseV0160CLIOrderStatusQueryFlow.cliCommand,
        action: String = ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue,
        credentialProvider: String = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
        explicitOperatorConfirmationRequired: Bool = true,
        operatorConfirmationAccepted: Bool = true,
        sourceSubmitArtifactConsumed: Bool = true,
        redactedOrderReferenceConsumed: Bool = true,
        signedGETOrderStatusQueryPerformed: Bool = true,
        testnetEndpointAllowlisted: Bool = true,
        redactedRequestResponseEvidence: Bool = true,
        productionHostRejected: Bool = true,
        missingPriorArtifactFailsClosed: Bool = true,
        redactedOutputPrinted: Bool = true,
        artifactPathReturned: Bool = true,
        checksumReturned: Bool = true,
        rawSecretPrinted: Bool = false,
        rawCredentialPrinted: Bool = false,
        rawOrderIdentityPrinted: Bool = false,
        rawBrokerPayloadPrinted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard operatorRunModel.state == .statusObserved,
              operatorRunModel.actionSequence == [.create, .requestSubmit, .recordSubmitObserved, .requestStatus, .recordStatusObserved],
              signedRequest.boundaryHeld,
              transportResult.boundaryHeld,
              transportResult.signedStatusQueryRequestID == signedRequest.requestID else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("statusResult.evidence")
        }
        guard artifactPath == operatorRunModel.metadata.artifactLinks
            .first(where: { $0.role == .statusSnapshotJSON })?.path else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("artifactPath")
        }
        guard artifactChecksum == Self.artifactChecksum(
            runID: runID,
            artifactPath: artifactPath,
            operatorRunModel: operatorRunModel,
            signedRequest: signedRequest,
            transportResult: transportResult,
            sourceSubmitEvidenceJSONPath: sourceSubmitEvidenceJSONPath,
            networkEventLogJSONPath: networkEventLogJSONPath
        ) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("artifactChecksum")
        }
        guard resultID == Self.deterministicID(
            runID: runID,
            artifactChecksum: artifactChecksum,
            signedStatusQueryRequestID: signedRequest.requestID,
            statusTransportResultID: transportResult.transportResultID
        ) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("resultID")
        }
        guard command == ReleaseV0160CLIOrderStatusQueryFlow.cliCommand,
              action == ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue,
              credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
              explicitOperatorConfirmationRequired,
              operatorConfirmationAccepted,
              sourceSubmitArtifactConsumed,
              redactedOrderReferenceConsumed,
              signedGETOrderStatusQueryPerformed,
              testnetEndpointAllowlisted,
              redactedRequestResponseEvidence,
              productionHostRejected,
              missingPriorArtifactFailsClosed,
              redactedOutputPrinted,
              artifactPathReturned,
              checksumReturned,
              validationAnchors == Self.requiredValidationAnchors else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("resultFlags")
        }
        try Self.forbid(rawSecretPrinted, "rawSecretPrinted")
        try Self.forbid(rawCredentialPrinted, "rawCredentialPrinted")
        try Self.forbid(rawOrderIdentityPrinted, "rawOrderIdentityPrinted")
        try Self.forbid(rawBrokerPayloadPrinted, "rawBrokerPayloadPrinted")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.resultID = resultID
        self.command = command
        self.action = action
        self.runID = runID
        self.operatorRunState = operatorRunModel.state
        self.operatorRunActionSequence = operatorRunModel.actionSequence
        self.artifactPath = artifactPath
        self.artifactChecksum = artifactChecksum
        self.signedStatusQueryRequestID = signedRequest.requestID
        self.statusTransportResultID = transportResult.transportResultID
        self.sourceSubmitEvidenceJSONPath = sourceSubmitEvidenceJSONPath
        self.networkEventLogJSONPath = networkEventLogJSONPath
        self.credentialProvider = credentialProvider
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.operatorConfirmationAccepted = operatorConfirmationAccepted
        self.sourceSubmitArtifactConsumed = sourceSubmitArtifactConsumed
        self.redactedOrderReferenceConsumed = redactedOrderReferenceConsumed
        self.signedGETOrderStatusQueryPerformed = signedGETOrderStatusQueryPerformed
        self.testnetEndpointAllowlisted = testnetEndpointAllowlisted
        self.redactedRequestResponseEvidence = redactedRequestResponseEvidence
        self.productionHostRejected = productionHostRejected
        self.missingPriorArtifactFailsClosed = missingPriorArtifactFailsClosed
        self.redactedOutputPrinted = redactedOutputPrinted
        self.artifactPathReturned = artifactPathReturned
        self.checksumReturned = checksumReturned
        self.rawSecretPrinted = rawSecretPrinted
        self.rawCredentialPrinted = rawCredentialPrinted
        self.rawOrderIdentityPrinted = rawOrderIdentityPrinted
        self.rawBrokerPayloadPrinted = rawBrokerPayloadPrinted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        command == ReleaseV0160CLIOrderStatusQueryFlow.cliCommand
            && action == ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue
            && operatorRunState == .statusObserved
            && operatorRunActionSequence == [.create, .requestSubmit, .recordSubmitObserved, .requestStatus, .recordStatusObserved]
            && artifactPath.hasPrefix(".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/")
            && artifactPath.hasSuffix(ReleaseV0160OperatorRunArtifactRole.statusSnapshotJSON.rawValue)
            && Self.isLowercaseSHA256(artifactChecksum)
            && credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue
            && explicitOperatorConfirmationRequired
            && operatorConfirmationAccepted
            && sourceSubmitArtifactConsumed
            && redactedOrderReferenceConsumed
            && signedGETOrderStatusQueryPerformed
            && testnetEndpointAllowlisted
            && redactedRequestResponseEvidence
            && productionHostRejected
            && missingPriorArtifactFailsClosed
            && redactedOutputPrinted
            && artifactPathReturned
            && checksumReturned
            && rawSecretPrinted == false
            && rawCredentialPrinted == false
            && rawOrderIdentityPrinted == false
            && rawBrokerPayloadPrinted == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var operatorRunActionSequenceText: String {
        operatorRunActionSequence.map(\.rawValue).joined(separator: ">")
    }

    public var redactedOutputLines: [String] {
        [
            "mtpro \(ReleaseV0160CLIOrderStatusQueryFlow.cliCommand)",
            "issue=GH-1105",
            "verificationAnchor=GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY",
            "validationAnchor=TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "command=\(command)",
            "action=\(action)",
            "runID=\(runID.rawValue)",
            "operatorRunState=\(operatorRunState.rawValue)",
            "operatorRunActionSequence=\(operatorRunActionSequenceText)",
            "artifactPath=\(artifactPath)",
            "artifactChecksum=\(artifactChecksum)",
            "signedStatusQueryRequestID=\(signedStatusQueryRequestID.rawValue)",
            "statusTransportResultID=\(statusTransportResultID.rawValue)",
            "sourceSubmitEvidenceJSON=<redacted-path>",
            "networkEventLogJSON=<redacted-path>",
            "credentialProvider=\(credentialProvider)",
            "credentialReference=<redacted>",
            "orderReference=<redacted>",
            "explicitOperatorConfirmationRequired=\(explicitOperatorConfirmationRequired)",
            "operatorConfirmationAccepted=\(operatorConfirmationAccepted)",
            "sourceSubmitArtifactConsumed=\(sourceSubmitArtifactConsumed)",
            "redactedOrderReferenceConsumed=\(redactedOrderReferenceConsumed)",
            "signedGETOrderStatusQueryPerformed=\(signedGETOrderStatusQueryPerformed)",
            "testnetEndpointAllowlisted=\(testnetEndpointAllowlisted)",
            "redactedRequestResponseEvidence=\(redactedRequestResponseEvidence)",
            "productionHostRejected=\(productionHostRejected)",
            "missingPriorArtifactFailsClosed=\(missingPriorArtifactFailsClosed)",
            "redactedOutputPrinted=\(redactedOutputPrinted)",
            "artifactPathReturned=\(artifactPathReturned)",
            "checksumReturned=\(checksumReturned)",
            "rawSecretPrinted=\(rawSecretPrinted)",
            "rawCredentialPrinted=\(rawCredentialPrinted)",
            "rawOrderIdentityPrinted=\(rawOrderIdentityPrinted)",
            "rawBrokerPayloadPrinted=\(rawBrokerPayloadPrinted)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretAutoRead=\(productionSecretAutoRead)",
            "productionEndpointConnected=\(productionEndpointConnected)",
            "brokerEndpointConnected=\(brokerEndpointConnected)",
            "productionOrderSubmitted=\(productionOrderSubmitted)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public static let requiredValidationAnchors = ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence
        .requiredValidationAnchors

    public static func artifactChecksum(
        runID: Identifier,
        artifactPath: String,
        operatorRunModel: ReleaseV0160OperatorRunModel,
        signedRequest: ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence,
        transportResult: ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult,
        sourceSubmitEvidenceJSONPath: String,
        networkEventLogJSONPath: String
    ) -> String {
        stableSHA256([
            "GH-1105",
            "v0.16.0",
            "signed-order-status-query",
            runID.rawValue,
            artifactPath,
            operatorRunModel.events.last?.eventChecksum ?? "",
            signedRequest.requestID.rawValue,
            signedRequest.redactedUnsignedQueryDigest,
            transportResult.transportResultID.rawValue,
            transportResult.redactedResponseDigest,
            sourceSubmitEvidenceJSONPath,
            networkEventLogJSONPath
        ])
    }

    public static func deterministicID(
        runID: Identifier,
        artifactChecksum: String,
        signedStatusQueryRequestID: Identifier,
        statusTransportResultID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1105-v0160-order-status-query",
                runID.rawValue,
                artifactChecksum,
                signedStatusQueryRequestID.rawValue,
                statusTransportResultID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0160OrderStatusQuery.resultID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatusQuery.\(field)")
        }
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }
}

/// ReleaseV0160CLIOrderStatusQueryFlow 暴露 v0.16.0 stable signed GET order status CLI。
public enum ReleaseV0160CLIOrderStatusQueryFlow {
    public static let cliCommand = ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue

    public static func commandLineOutput(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        statusTransport: (any ReleaseV0160BinanceSpotTestnetOrderStatusTransport)? = nil
    ) async throws -> String {
        try await result(
            arguments: arguments,
            environment: environment,
            statusTransport: statusTransport
        ).redactedOutputLines.joined(separator: "\n")
    }

    public static func result(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        statusTransport: (any ReleaseV0160BinanceSpotTestnetOrderStatusTransport)? = nil
    ) async throws -> ReleaseV0160CLIOrderStatusQueryResult {
        let command = try parse(arguments: arguments)
        try ReleaseV0160BetaSafetyGuard.validate(command: command)
        let credentialProvider = try ReleaseV0151BinanceSpotTestnetCLICredentialProvider(
            kind: command.credentialProviderKind,
            environment: environment,
            apiKeyEnvironmentName: command.apiKeyEnvironmentName,
            secretEnvironmentName: command.secretEnvironmentName
        )
        let credential = try credentialProvider.credential(referenceID: command.credentialReferenceID)
        let sourceSubmitEvidence = try decode(ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence.self, fromPath: command.sourceSubmitEvidenceJSONPath)
        let networkEventLog = try decode(ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.self, fromPath: command.networkEventLogJSONPath)
        let intent = try makeOrderIntent(command: command)
        try validateExplicitIntentID(command.intentID, actual: intent.intentID)
        try validateSourceSubmitEvidence(sourceSubmitEvidence, networkEventLog: networkEventLog, intent: intent, credentialReferenceID: credential.reference.referenceID)
        let orderIdentity = try makeOrderIdentity(
            sourceSubmitEvidence: sourceSubmitEvidence,
            originalClientOrderID: command.originalClientOrderID
        )
        let signedRequest = try ReleaseV0150BinanceSpotTestnetSignedRequestBuilder()
            .buildOrderStatusQueryRequest(
                sourceSubmitEvidence: sourceSubmitEvidence,
                credential: credential,
                orderIdentity: orderIdentity,
                symbol: intent.instrument.symbol,
                timestamp: date(milliseconds: command.timestampMilliseconds)
            )
        let resolvedTransport: any ReleaseV0160BinanceSpotTestnetOrderStatusTransport
        if let statusTransport {
            resolvedTransport = statusTransport
        } else {
            resolvedTransport = try ReleaseV0151BinanceSpotTestnetURLSessionTransport()
        }
        let transportResult = try await resolvedTransport.querySpotTestnetOrderStatus(
            signedRequest: signedRequest,
            orderIdentity: orderIdentity,
            credential: credential
        )
        let operatorRunModel = try ReleaseV0160OperatorRunModel
            .created(
                runID: command.runID,
                createdAt: date(milliseconds: command.timestampMilliseconds - 3)
            )
            .applying(
                .requestSubmit,
                artifactRoles: [.actionEventsJSONL, .redactedExecutionEvidenceJSON],
                at: date(milliseconds: command.timestampMilliseconds - 2)
            )
            .applying(
                .recordSubmitObserved,
                artifactRoles: [.redactedExecutionEvidenceJSON, .statusSnapshotJSON],
                at: date(milliseconds: command.timestampMilliseconds - 1)
            )
            .applying(
                .requestStatus,
                artifactRoles: [.actionEventsJSONL, .statusSnapshotJSON],
                at: date(milliseconds: command.timestampMilliseconds)
            )
            .applying(
                .recordStatusObserved,
                artifactRoles: [.statusSnapshotJSON],
                at: date(milliseconds: command.observedAtMilliseconds)
            )
        guard let statusArtifact = operatorRunModel.metadata.artifactLinks
            .first(where: { $0.role == .statusSnapshotJSON }) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("statusSnapshotJSON")
        }
        let checksum = ReleaseV0160CLIOrderStatusQueryResult.artifactChecksum(
            runID: command.runID,
            artifactPath: statusArtifact.path,
            operatorRunModel: operatorRunModel,
            signedRequest: signedRequest,
            transportResult: transportResult,
            sourceSubmitEvidenceJSONPath: command.sourceSubmitEvidenceJSONPath,
            networkEventLogJSONPath: command.networkEventLogJSONPath
        )
        return try ReleaseV0160CLIOrderStatusQueryResult(
            resultID: ReleaseV0160CLIOrderStatusQueryResult.deterministicID(
                runID: command.runID,
                artifactChecksum: checksum,
                signedStatusQueryRequestID: signedRequest.requestID,
                statusTransportResultID: transportResult.transportResultID
            ),
            runID: command.runID,
            operatorRunModel: operatorRunModel,
            signedRequest: signedRequest,
            transportResult: transportResult,
            sourceSubmitEvidenceJSONPath: command.sourceSubmitEvidenceJSONPath,
            networkEventLogJSONPath: command.networkEventLogJSONPath,
            artifactPath: statusArtifact.path,
            artifactChecksum: checksum
        )
    }

    public static func parse(arguments: [String]) throws -> ReleaseV0160CLIOrderStatusQueryCommand {
        guard arguments.first == cliCommand else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "command",
                expected: cliCommand,
                actual: arguments.first ?? "missing"
            )
        }
        let parser = try ReleaseV0160OrderStatusArgumentParser(arguments: arguments)
        try parser.requireFlag(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag)
        try parser.forbidProductionArguments()
        if let action = parser.value(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.actionFlag),
           action != ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.forbiddenAction(action)
        }

        let confirmation = try parser.requiredValue(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.operatorConfirmFlag)
        guard confirmation == ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatusQuery.operatorConfirmation")
        }
        let providerRaw = try parser.requiredValue("--credential-provider")
        guard let provider = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind(rawValue: providerRaw),
              provider == .testnetEnvironment else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProvider(providerRaw)
        }
        let output = parser.value(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.outputFlag)
            ?? ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput
        guard output == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160OrderStatusQuery.output.\(output)")
        }

        let apiKeyEnvironmentName = parser.value("--testnet-api-key-env")
            ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultAPIKeyEnvironmentName
        let secretEnvironmentName = parser.value("--testnet-secret-env")
            ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultSecretEnvironmentName
        try ReleaseV0151BinanceSpotTestnetCLICredentialProvider
            .validateTestnetEnvironmentName(apiKeyEnvironmentName, field: "apiKeyEnvironmentName")
        try ReleaseV0151BinanceSpotTestnetCLICredentialProvider
            .validateTestnetEnvironmentName(secretEnvironmentName, field: "secretEnvironmentName")

        let runID = Identifier.constant(parser.value("--run-id") ?? "gh-1105-v0160-spot-testnet-status-query-run")
        let timestampMilliseconds = try parser.optionalInt64("--timestamp-ms") ?? 1_704_067_320_000
        let observedAtMilliseconds = try parser.optionalInt64("--observed-at-ms") ?? timestampMilliseconds
        guard timestampMilliseconds > 0, observedAtMilliseconds > 0 else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "timestamp",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds):\(observedAtMilliseconds)"
            )
        }

        let command = ReleaseV0160CLIOrderStatusQueryCommand(
            runID: runID,
            operatorConfirmationPhrase: confirmation,
            credentialProviderKind: provider,
            credentialReferenceID: Identifier.constant(
                parser.value("--credential-reference-id") ?? "gh-1105-binance-spot-testnet-credential"
            ),
            apiKeyEnvironmentName: apiKeyEnvironmentName,
            secretEnvironmentName: secretEnvironmentName,
            symbol: try parser.requiredValue("--symbol"),
            side: try parser.requiredValue("--side"),
            quantity: try parser.requiredValue("--quantity"),
            strategy: parser.value("--strategy") ?? OrderIntentStrategyKind.ema.rawValue,
            sourceSequence: try parser.optionalInt("--source-sequence") ?? 1105,
            correlationID: Identifier.constant(parser.value("--correlation-id") ?? "gh-1105-status-correlation"),
            strategySignalID: Identifier.constant(parser.value("--strategy-signal-id") ?? "gh-1105-status-signal"),
            sourceMessageID: Identifier.constant(parser.value("--source-message-id") ?? "gh-1105-status-message"),
            strategyRunID: Identifier.constant(parser.value("--strategy-run-id") ?? runID.rawValue),
            intentID: optionalIdentifier(parser.value("--intent-id")),
            sourceSubmitEvidenceJSONPath: try parser.requiredValue("--source-submit-evidence-json"),
            networkEventLogJSONPath: try parser.requiredValue("--network-event-log-json"),
            originalClientOrderID: parser.value("--original-client-order-id"),
            timestampMilliseconds: timestampMilliseconds,
            observedAtMilliseconds: observedAtMilliseconds,
            redactedOutputRequested: true
        )
        guard command.boundaryHeld else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.boundaryDrift("command")
        }
        return command
    }

    private static func makeOrderIntent(command: ReleaseV0160CLIOrderStatusQueryCommand) throws -> OrderIntent {
        let symbol = try Symbol(rawValue: command.symbol)
        let sideRaw = command.side
        guard let side = OrderIntentSide(rawValue: sideRaw) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "side",
                expected: OrderIntentSide.allCases.map(\.rawValue).joined(separator: ","),
                actual: sideRaw
            )
        }
        let strategyRaw = command.strategy
        guard let strategy = OrderIntentStrategyKind(rawValue: strategyRaw.uppercased()) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "strategy",
                expected: OrderIntentStrategyKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: strategyRaw
            )
        }
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let quantity = try Quantity(Double(command.quantity) ?? -1, field: "releaseV0160OrderStatus.quantity")
        let policy = try OrderIntentPolicy(timeInForce: .goodTillCanceled)
        let correlation = try OrderIntentCorrelationMetadata(
            correlationID: command.correlationID,
            strategySignalID: command.strategySignalID,
            sourceMessageID: command.sourceMessageID,
            strategyRunID: command.strategyRunID,
            sourceSequence: command.sourceSequence
        )
        return try OrderIntent(
            intentID: OrderIntent.deterministicID(
                instrument: instrument,
                side: side,
                quantity: quantity,
                strategy: strategy,
                policy: policy,
                correlation: correlation
            ),
            instrument: instrument,
            side: side,
            quantity: quantity,
            strategy: strategy,
            policy: policy,
            correlation: correlation,
            createdAt: date(milliseconds: command.timestampMilliseconds)
        )
    }

    private static func validateSourceSubmitEvidence(
        _ evidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        intent: OrderIntent,
        credentialReferenceID: Identifier
    ) throws {
        guard evidence.boundaryHeld,
              evidence.intentID == intent.intentID,
              evidence.credentialReferenceID == credentialReferenceID else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.sourceArtifactMismatch(
                field: "sourceSubmitEvidence",
                expected: "\(intent.intentID.rawValue):\(credentialReferenceID.rawValue)",
                actual: "\(evidence.intentID.rawValue):\(evidence.credentialReferenceID.rawValue)"
            )
        }
        guard networkEventLog.boundaryHeld,
              networkEventLog.eventArtifacts.contains(where: { $0.actionEvidenceID == evidence.runtimeEvidenceID }) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.sourceArtifactMismatch(
                field: "networkEventLog.sourceSubmitEvidence",
                expected: evidence.runtimeEvidenceID.rawValue,
                actual: networkEventLog.eventArtifacts.map(\.actionEvidenceID.rawValue).joined(separator: ",")
            )
        }
    }

    private static func makeOrderIdentity(
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        originalClientOrderID: String?
    ) throws -> ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial {
        let material = try ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial.derivedFromSubmitEvidence(
            sourceSubmitEvidence
        )
        if let originalClientOrderID,
           originalClientOrderID.trimmingCharacters(in: .whitespacesAndNewlines) != material.binanceOriginalClientOrderID() {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "--original-client-order-id",
                expected: "deterministic client order id derived from submit evidence",
                actual: "<redacted-mismatch>"
            )
        }
        return material
    }

    private static func decode<T: Decodable>(_ type: T.Type, fromPath path: String) throws -> T {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    private static func validateExplicitIntentID(_ explicit: Identifier?, actual: Identifier) throws {
        guard let explicit else { return }
        guard explicit == actual else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: "--intent-id",
                expected: actual.rawValue,
                actual: explicit.rawValue
            )
        }
    }

    private static func date(milliseconds: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1_000)
    }

    private static func optionalIdentifier(_ raw: String?) -> Identifier? {
        guard let raw, raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return nil
        }
        return .constant(raw)
    }
}

private struct ReleaseV0160OrderStatusArgumentParser {
    private let values: [String: String]
    private let flags: Set<String>

    init(arguments: [String]) throws {
        var values: [String: String] = [:]
        var flags: Set<String> = []
        var index = 1

        while index < arguments.count {
            let argument = arguments[index]
            guard argument.hasPrefix("--") else {
                throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                    field: "arguments",
                    expected: "flag",
                    actual: argument
                )
            }
            if argument == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag
                || argument == "--production" {
                flags.insert(argument)
                index += 1
                continue
            }
            guard index + 1 < arguments.count else {
                throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                    field: argument,
                    expected: "value",
                    actual: "missing"
                )
            }
            values[argument] = arguments[index + 1]
            index += 2
        }
        self.values = values
        self.flags = flags
    }

    func value(_ name: String) -> String? {
        values[name]
    }

    func requiredValue(_ name: String) throws -> String {
        guard let value = values[name]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: name,
                expected: "non-empty value",
                actual: "missing"
            )
        }
        return value
    }

    func optionalInt(_ name: String) throws -> Int? {
        guard let value = values[name] else { return nil }
        guard let parsed = Int(value) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: name,
                expected: "integer",
                actual: value
            )
        }
        return parsed
    }

    func optionalInt64(_ name: String) throws -> Int64? {
        guard let value = values[name] else { return nil }
        guard let parsed = Int64(value) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: name,
                expected: "integer",
                actual: value
            )
        }
        return parsed
    }

    func requireFlag(_ name: String) throws {
        guard flags.contains(name) else {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.invalidArgument(
                field: name,
                expected: "present",
                actual: "missing"
            )
        }
    }

    func forbidProductionArguments() throws {
        for flag in flags where flag.localizedCaseInsensitiveContains("production")
            || flag.localizedCaseInsensitiveContains("prod") {
            throw ReleaseV0160CLIOrderStatusQueryFlowError.forbiddenProductionArgument(flag)
        }
        for (key, value) in values {
            let combined = "\(key)=\(value)"
            if combined.localizedCaseInsensitiveContains("production")
                || combined.localizedCaseInsensitiveContains("prod")
                || key == "--broker-endpoint"
                || key == "--api-key"
                || key == "--secret-key" {
                throw ReleaseV0160CLIOrderStatusQueryFlowError.forbiddenProductionArgument(combined)
            }
        }
    }
}

private func stableSHA256(_ parts: [String]) -> String {
    let payload = parts.joined(separator: "\n")
    let digest = SHA256.hash(data: Data(payload.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
}
