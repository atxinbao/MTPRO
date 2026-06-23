import Crypto
import DomainModel
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// GH-1096 static contract boundary:
// endpointHost=testnet.binance.vision
// endpointPath=/api/v3/order
// URLSession transport enabled for Binance Spot Testnet only
// responseBodyRedacted=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0151BinanceSpotTestnetURLSessionTransportError 描述具体 Spot Testnet 网络 transport gate。
///
/// 错误只覆盖 canonical testnet URL、timeout、HTTP response shape 和非 2xx 状态。
/// 它不代表 production cutover、broker connection、production endpoint access 或真实生产订单。
public enum ReleaseV0151BinanceSpotTestnetURLSessionTransportError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidBaseURL(String)
    case productionHostForbidden(String)
    case invalidRequestURL(String)
    case invalidTimeout(TimeInterval)
    case nonHTTPResponse
    case httpStatus(Int)

    public var description: String {
        switch self {
        case let .invalidBaseURL(value):
            "Release v0.15.1 Spot Testnet URLSession transport base URL is invalid: \(value)"
        case let .productionHostForbidden(host):
            "Release v0.15.1 Spot Testnet URLSession transport forbids production host: \(host)"
        case let .invalidRequestURL(value):
            "Release v0.15.1 Spot Testnet URLSession transport request URL is invalid: \(value)"
        case let .invalidTimeout(value):
            "Release v0.15.1 Spot Testnet URLSession transport timeout is invalid: \(value)"
        case .nonHTTPResponse:
            "Release v0.15.1 Spot Testnet URLSession transport requires HTTPURLResponse"
        case let .httpStatus(status):
            "Release v0.15.1 Spot Testnet URLSession transport received unsupported HTTP status: \(status)"
        }
    }
}

/// ReleaseV0151BinanceSpotTestnetURLSessionDataLoading 隔离 URLSession，方便测试注入本地 loader。
///
/// 协议只把原始响应 bytes 返回给 concrete transport；transport 会立刻降维成 SHA-256
/// 脱敏证据，不持久化 response body、API key 或 signing secret。
public protocol ReleaseV0151BinanceSpotTestnetURLSessionDataLoading: Sendable {
    func load(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// ReleaseV0151BinanceSpotTestnetURLSessionDataLoader 是默认 URLSession-backed data loader。
///
/// 它只执行 allowlisted transport 传入的单次 URLSession data request；不构造 production URL、
/// 不读取 credential，也不负责任何 evidence persistence。
public actor ReleaseV0151BinanceSpotTestnetURLSessionDataLoader: ReleaseV0151BinanceSpotTestnetURLSessionDataLoading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// ReleaseV0151BinanceSpotTestnetURLSessionTransport 是具体 Binance Spot Testnet 网络 transport。
///
/// 该 actor 用真实 URLSession-backed runner 实现 v0.15.0 注入式 submit / cancel transport 协议。
/// 它只构造 `https://testnet.binance.vision/api/v3/order` 的 POST / DELETE request，fail-closed 拒绝
/// production host，设置显式 timeout，并只返回脱敏 transport result evidence。它不保存 raw response body、
/// API key、signing secret 或 raw order identity。
public actor ReleaseV0151BinanceSpotTestnetURLSessionTransport:
    ReleaseV0150BinanceSpotTestnetSubmitTransport,
    ReleaseV0150BinanceSpotTestnetCancelTransport
{
    public let baseURL: URL
    public let timeoutSeconds: TimeInterval

    private let dataLoader: any ReleaseV0151BinanceSpotTestnetURLSessionDataLoading

    public init(
        baseURL: URL? = nil,
        session: URLSession = .shared,
        timeoutSeconds: TimeInterval = 15
    ) throws {
        try self.init(
            baseURL: baseURL,
            dataLoader: ReleaseV0151BinanceSpotTestnetURLSessionDataLoader(session: session),
            timeoutSeconds: timeoutSeconds
        )
    }

    public init(
        baseURL: URL? = nil,
        dataLoader: any ReleaseV0151BinanceSpotTestnetURLSessionDataLoading,
        timeoutSeconds: TimeInterval = 15
    ) throws {
        let resolvedBaseURL = try baseURL ?? ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.canonicalBaseURL()
        try Self.validateCanonicalBaseURL(resolvedBaseURL)
        guard timeoutSeconds.isFinite, timeoutSeconds > 0 else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidTimeout(timeoutSeconds)
        }

        self.baseURL = resolvedBaseURL
        self.dataLoader = dataLoader
        self.timeoutSeconds = timeoutSeconds
    }

    public var boundaryHeld: Bool {
        (try? Self.validateCanonicalBaseURL(baseURL)) != nil
            && timeoutSeconds.isFinite
            && timeoutSeconds > 0
    }

    public func submitSpotTestnetOrder(
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial
    ) async throws -> ReleaseV0150BinanceSpotTestnetSubmitTransportResult {
        guard boundaryHeld, signedRequest.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetURLSessionTransport.submit.boundary")
        }
        guard signedRequest.httpMethod == "POST",
              signedRequest.endpointHost == Self.canonicalSpotTestnetHost,
              signedRequest.endpointPath == Self.spotOrderEndpointPath else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidRequestURL(
                "\(signedRequest.endpointHost)\(signedRequest.endpointPath)"
            )
        }

        let request = try makeRequest(
            method: signedRequest.httpMethod,
            queryString: signedRequest.binanceSignedQueryStringForTransport(),
            apiKeyHeaderName: signedRequest.apiKeyHeaderName,
            apiKeyHeaderValue: credential.binanceAPIKeyHeaderValue()
        )
        let (data, response) = try await dataLoader.load(request)
        let statusCode = try Self.validatedStatusCode(response)
        let redactedDigest = ReleaseV0150BinanceSpotTestnetSubmitTransportResult.redactedDigest(
            statusCode: statusCode,
            acknowledgement: Self.redactedAcknowledgement(
                action: "submit",
                requestID: signedRequest.requestID,
                responseData: data
            )
        )

        return try ReleaseV0150BinanceSpotTestnetSubmitTransportResult(
            transportResultID: ReleaseV0150BinanceSpotTestnetSubmitTransportResult.deterministicID(
                signedRequestID: signedRequest.requestID,
                httpStatusCode: statusCode,
                redactedResponseDigest: redactedDigest
            ),
            signedRequest: signedRequest,
            httpStatusCode: statusCode,
            redactedResponseDigest: redactedDigest
        )
    }

    public func cancelSpotTestnetOrder(
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial
    ) async throws -> ReleaseV0150BinanceSpotTestnetCancelTransportResult {
        guard boundaryHeld, signedRequest.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetURLSessionTransport.cancel.boundary")
        }
        guard signedRequest.httpMethod == "DELETE",
              signedRequest.endpointHost == Self.canonicalSpotTestnetHost,
              signedRequest.endpointPath == Self.spotOrderEndpointPath else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidRequestURL(
                "\(signedRequest.endpointHost)\(signedRequest.endpointPath)"
            )
        }

        let unsignedQueryString = ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.unsignedCancelOrderQueryString(
            symbol: signedRequest.symbol,
            originalClientOrderID: orderIdentity.binanceOriginalClientOrderID(),
            timestampMilliseconds: signedRequest.timestampMilliseconds,
            receiveWindowMilliseconds: signedRequest.receiveWindowMilliseconds
        )
        guard ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.redactedUnsignedQueryDigest(
            for: unsignedQueryString
        ) == signedRequest.redactedUnsignedQueryDigest else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetURLSessionTransport.cancel.redactedUnsignedQueryDigest",
                expected: signedRequest.redactedUnsignedQueryDigest,
                actual: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.redactedUnsignedQueryDigest(
                    for: unsignedQueryString
                )
            )
        }
        guard credential.signature(for: unsignedQueryString) == signedRequest.signature else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetURLSessionTransport.cancel.signatureMismatch")
        }

        let request = try makeRequest(
            method: signedRequest.httpMethod,
            queryString: "\(unsignedQueryString)&signature=\(signedRequest.signature)",
            apiKeyHeaderName: signedRequest.apiKeyHeaderName,
            apiKeyHeaderValue: credential.binanceAPIKeyHeaderValue()
        )
        let (data, response) = try await dataLoader.load(request)
        let statusCode = try Self.validatedStatusCode(response)
        let redactedDigest = ReleaseV0150BinanceSpotTestnetCancelTransportResult.redactedDigest(
            statusCode: statusCode,
            acknowledgement: Self.redactedAcknowledgement(
                action: "cancel",
                requestID: signedRequest.requestID,
                responseData: data
            )
        )

        return try ReleaseV0150BinanceSpotTestnetCancelTransportResult(
            transportResultID: ReleaseV0150BinanceSpotTestnetCancelTransportResult.deterministicID(
                signedCancelRequestID: signedRequest.requestID,
                httpStatusCode: statusCode,
                redactedResponseDigest: redactedDigest
            ),
            signedRequest: signedRequest,
            httpStatusCode: statusCode,
            redactedResponseDigest: redactedDigest
        )
    }

    public static let canonicalSpotTestnetHost = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
    public static let spotOrderEndpointPath = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
    public static let apiKeyHeaderName = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.apiKeyHeaderName
    public static let validationAnchors = [
        "GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT",
        "TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT",
        "V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST",
        "V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT",
        "V0151-003-REDACTED-RESPONSE-DIGEST",
        "V0151-003-NO-SECRET-PERSISTENCE",
        "V0151-003-PRODUCTION-ENDPOINT-REJECTED",
        "V0151-003-NO-PRODUCTION-CUTOVER"
    ]

    public static func validateCanonicalBaseURL(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidBaseURL(url.absoluteString)
        }
        let host = components.host?.lowercased() ?? ""
        guard forbiddenProductionHosts.contains(host) == false else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.productionHostForbidden(host)
        }
        guard components.scheme?.lowercased() == "https",
              host == canonicalSpotTestnetHost,
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.percentEncodedPath.isEmpty,
              components.percentEncodedQuery == nil,
              components.percentEncodedFragment == nil else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidBaseURL(url.absoluteString)
        }
    }

    private static let forbiddenProductionHosts: Set<String> = [
        "api.binance.com",
        "fapi.binance.com",
        "dapi.binance.com"
    ]

    private func makeRequest(
        method: String,
        queryString: String,
        apiKeyHeaderName: String,
        apiKeyHeaderValue: String
    ) throws -> URLRequest {
        guard apiKeyHeaderName == Self.apiKeyHeaderName else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetURLSessionTransport.apiKeyHeaderName",
                expected: Self.apiKeyHeaderName,
                actual: apiKeyHeaderName
            )
        }
        guard apiKeyHeaderValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetURLSessionTransport.emptyAPIKey")
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.canonicalSpotTestnetHost
        components.path = Self.spotOrderEndpointPath
        components.percentEncodedQuery = queryString

        guard let url = components.url else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidRequestURL(queryString)
        }
        try Self.validateRequestURL(url)

        var request = URLRequest(url: url, timeoutInterval: timeoutSeconds)
        request.httpMethod = method
        request.setValue(apiKeyHeaderValue, forHTTPHeaderField: Self.apiKeyHeaderName)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = nil
        return request
    }

    private static func validateRequestURL(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidRequestURL(url.absoluteString)
        }
        let host = components.host?.lowercased() ?? ""
        guard forbiddenProductionHosts.contains(host) == false else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.productionHostForbidden(host)
        }
        guard components.scheme?.lowercased() == "https",
              host == canonicalSpotTestnetHost,
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.percentEncodedPath == spotOrderEndpointPath,
              components.percentEncodedQuery?.isEmpty == false,
              components.percentEncodedFragment == nil else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.invalidRequestURL(url.absoluteString)
        }
    }

    private static func validatedStatusCode(_ response: URLResponse) throws -> Int {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.nonHTTPResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ReleaseV0151BinanceSpotTestnetURLSessionTransportError.httpStatus(httpResponse.statusCode)
        }
        return httpResponse.statusCode
    }

    private static func redactedAcknowledgement(
        action: String,
        requestID: Identifier,
        responseData: Data
    ) -> String {
        let responseDigest = SHA256.hash(data: responseData)
            .map { String(format: "%02x", $0) }
            .joined()
        return "gh-1096-urlsession-\(action):\(requestID.rawValue):response-sha256:\(responseDigest)"
    }
}
