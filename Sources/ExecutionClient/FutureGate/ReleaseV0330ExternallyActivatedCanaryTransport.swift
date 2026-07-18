#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CryptoKit
import Foundation

// GH-1563-ADD-EXTERNALLY-ACTIVATED-PRODUCTION-CANARY-TRANSPORT
// TVM-RELEASE-V0330-EXTERNALLY-ACTIVATED-CANARY-TRANSPORT
// V0330-002C-NO-DEFAULT-CREDENTIAL-OR-NETWORK-ACTIVATION

// GH-1565-ADD-EXPLICIT-BINANCE-DEMO-CANARY-ENVIRONMENT
// TVM-RELEASE-V0330-BINANCE-DEMO-ENVIRONMENT-ISOLATION
// V0330-002D-DEMO-ENVIRONMENT-FAIL-CLOSED-BINDING

public struct ReleaseV0330EphemeralCanaryCredentialMaterial: Sendable {
    fileprivate let apiKey: String
    fileprivate let signingSecret: String

    public init(apiKey: String, signingSecret: String) throws {
        guard apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              signingSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.missingCredentialMaterial
        }
        self.apiKey = apiKey
        self.signingSecret = signingSecret
    }
}

public protocol ReleaseV0330CanaryCredentialProviding: Sendable {
    func loadEphemeralCredential(
        reference: String
    ) async throws -> ReleaseV0330EphemeralCanaryCredentialMaterial
}

public struct ReleaseV0330RejectingCanaryCredentialProvider: ReleaseV0330CanaryCredentialProviding {
    public init() {}

    public func loadEphemeralCredential(
        reference _: String
    ) async throws -> ReleaseV0330EphemeralCanaryCredentialMaterial {
        throw ReleaseV0330ExternallyActivatedCanaryTransportError.credentialProviderNotConfigured
    }
}

public struct ReleaseV0330InjectedCanaryCredentialProvider: ReleaseV0330CanaryCredentialProviding {
    private let handler: @Sendable (String) async throws -> ReleaseV0330EphemeralCanaryCredentialMaterial

    public init(
        handler: @escaping @Sendable (String) async throws -> ReleaseV0330EphemeralCanaryCredentialMaterial
    ) {
        self.handler = handler
    }

    public func loadEphemeralCredential(
        reference: String
    ) async throws -> ReleaseV0330EphemeralCanaryCredentialMaterial {
        try await handler(reference)
    }
}

public protocol ReleaseV0330CanaryNetworkLoading: Sendable {
    func load(_ request: URLRequest) async throws -> (Data, URLResponse)
}

public struct ReleaseV0330RejectingCanaryNetworkLoader: ReleaseV0330CanaryNetworkLoading {
    public init() {}

    public func load(_: URLRequest) async throws -> (Data, URLResponse) {
        throw ReleaseV0330ExternallyActivatedCanaryTransportError.networkLoaderNotConfigured
    }
}

public struct ReleaseV0330InjectedCanaryNetworkLoader: ReleaseV0330CanaryNetworkLoading {
    private let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(
        handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.handler = handler
    }

    public func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}

public actor ReleaseV0330URLSessionCanaryNetworkLoader: ReleaseV0330CanaryNetworkLoading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try Self.validate(request)
        return try await session.data(for: request)
    }

    private static func validate(_ request: URLRequest) throws {
        guard let url = request.url,
              url.scheme == "https",
              url.user == nil,
              url.password == nil,
              url.fragment == nil,
              let host = url.host,
              (
                  (host == "api.binance.com" && url.path == "/api/v3/order")
                      || (host == "demo-api.binance.com" && url.path == "/api/v3/order")
                      || (host == "fapi.binance.com" && url.path == "/fapi/v1/order")
                      || (host == "demo-fapi.binance.com" && url.path == "/fapi/v1/order")
              ),
              ["POST", "GET", "DELETE"].contains(request.httpMethod ?? ""),
              request.value(forHTTPHeaderField: "X-MBX-APIKEY")?.isEmpty == false
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidNetworkRequest
        }
    }
}

public struct ReleaseV0330RedactedCanaryOperationArtifact: Codable, Equatable, Sendable {
    public let runID: String
    public let sourceCommit: String
    public let product: ReleaseV0330CanaryProduct
    public let environment: ReleaseV0330CanaryEnvironment
    public let action: ReleaseV0320CanaryAction
    public let symbol: String
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let exchangeStatus: String
    public let requestSHA256: String
    public let responseSHA256: String
    public let redactedOrderReference: String
    public let observedAtEpochMilliseconds: Int64
    public let rawSecretPersisted: Bool
    public let rawResponsePersisted: Bool
}

public protocol ReleaseV0330CanaryArtifactPersisting: Sendable {
    func persist(
        _ artifact: ReleaseV0330RedactedCanaryOperationArtifact
    ) async throws -> ReleaseV0330ObservedCanaryArtifactReference
}

public struct ReleaseV0330RejectingCanaryArtifactSink: ReleaseV0330CanaryArtifactPersisting {
    public init() {}

    public func persist(
        _: ReleaseV0330RedactedCanaryOperationArtifact
    ) async throws -> ReleaseV0330ObservedCanaryArtifactReference {
        throw ReleaseV0330ExternallyActivatedCanaryTransportError.artifactSinkNotConfigured
    }
}

public struct ReleaseV0330InjectedCanaryArtifactSink: ReleaseV0330CanaryArtifactPersisting {
    private let handler: @Sendable (
        ReleaseV0330RedactedCanaryOperationArtifact
    ) async throws -> ReleaseV0330ObservedCanaryArtifactReference

    public init(
        handler: @escaping @Sendable (
            ReleaseV0330RedactedCanaryOperationArtifact
        ) async throws -> ReleaseV0330ObservedCanaryArtifactReference
    ) {
        self.handler = handler
    }

    public func persist(
        _ artifact: ReleaseV0330RedactedCanaryOperationArtifact
    ) async throws -> ReleaseV0330ObservedCanaryArtifactReference {
        try await handler(artifact)
    }
}

public enum ReleaseV0330ExternallyActivatedCanaryTransportError: Error, Equatable, Sendable {
    case credentialProviderNotConfigured
    case networkLoaderNotConfigured
    case artifactSinkNotConfigured
    case missingCredentialMaterial
    case invalidNetworkRequest
    case invalidEndpoint
    case invalidOrderPlan
    case invalidHTTPResponse
    case rejectedHTTPStatus(Int)
    case malformedExchangeResponse
    case exchangeOrderIdentityMismatch
    case unsafeArtifactReference
}

public actor ReleaseV0330ExternallyActivatedCanaryTransport: ReleaseV0330ObservedCanaryTransport {
    public static let validationAnchor = "TVM-RELEASE-V0330-EXTERNALLY-ACTIVATED-CANARY-TRANSPORT"

    private let credentialProvider: any ReleaseV0330CanaryCredentialProviding
    private let networkLoader: any ReleaseV0330CanaryNetworkLoading
    private let artifactSink: any ReleaseV0330CanaryArtifactPersisting
    private let nowMilliseconds: @Sendable () -> Int64

    public init(
        credentialProvider: any ReleaseV0330CanaryCredentialProviding =
            ReleaseV0330RejectingCanaryCredentialProvider(),
        networkLoader: any ReleaseV0330CanaryNetworkLoading =
            ReleaseV0330RejectingCanaryNetworkLoader(),
        artifactSink: any ReleaseV0330CanaryArtifactPersisting =
            ReleaseV0330RejectingCanaryArtifactSink(),
        nowMilliseconds: @escaping @Sendable () -> Int64 = {
            Int64(Date().timeIntervalSince1970 * 1_000)
        }
    ) {
        self.credentialProvider = credentialProvider
        self.networkLoader = networkLoader
        self.artifactSink = artifactSink
        self.nowMilliseconds = nowMilliseconds
    }

    public func perform(
        _ request: ReleaseV0330ObservedCanaryTransportRequest
    ) async throws -> ReleaseV0330ObservedCanaryTransportObservation {
        try validate(request)
        let credential = try await credentialProvider.loadEphemeralCredential(
            reference: request.credentialReference
        )
        let timestamp = nowMilliseconds()
        guard timestamp > 0 else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidNetworkRequest
        }

        let unsignedQuery = try canonicalUnsignedQuery(for: request, timestamp: timestamp)
        let signature = Self.signature(for: unsignedQuery, secret: credential.signingSecret)
        let signedQuery = unsignedQuery + "&signature=" + signature
        let urlRequest = try makeURLRequest(
            request,
            signedQuery: signedQuery,
            apiKey: credential.apiKey
        )
        let (data, response) = try await networkLoader.load(urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidHTTPResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.rejectedHTTPStatus(
                httpResponse.statusCode
            )
        }

        let exchange = try parseExchangeResponse(data, expectedClientOrderID: request.orderPlan.clientOrderID)
        let requestDigest = Self.sha256(Data(signedQuery.utf8))
        let responseDigest = Self.sha256(data)
        let orderReference = Self.sha256(
            Data("\(exchange.orderID)|\(exchange.clientOrderID)".utf8)
        )
        let path = request.orderPlan.product == .spot ? "/api/v3/order" : "/fapi/v1/order"
        let artifact = ReleaseV0330RedactedCanaryOperationArtifact(
            runID: request.runID,
            sourceCommit: request.sourceCommit,
            product: request.product,
            environment: request.environment,
            action: request.action,
            symbol: request.symbol,
            endpointHost: request.baseURL.host ?? "",
            endpointPath: path,
            httpStatusCode: httpResponse.statusCode,
            exchangeStatus: exchange.status,
            requestSHA256: requestDigest,
            responseSHA256: responseDigest,
            redactedOrderReference: orderReference,
            observedAtEpochMilliseconds: timestamp,
            rawSecretPersisted: false,
            rawResponsePersisted: false
        )
        let artifactReference = try await artifactSink.persist(artifact)
        guard Self.safeRelativePath(artifactReference.relativePath),
              Self.isSHA256(artifactReference.sha256)
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.unsafeArtifactReference
        }

        return ReleaseV0330ObservedCanaryTransportObservation(
            runID: request.runID,
            product: request.product,
            action: request.action,
            environment: request.environment,
            requestID: requestDigest,
            redactedOrderReference: orderReference,
            endpointHost: request.baseURL.host ?? "",
            artifact: artifactReference,
            rawSecretPersisted: false,
            rawResponsePersisted: false
        )
    }

    private func validate(_ request: ReleaseV0330ObservedCanaryTransportRequest) throws {
        let expectedHost = request.environment.endpointHost(for: request.product)
        guard request.baseURL.scheme == "https",
              request.baseURL.host == expectedHost,
              request.baseURL.user == nil,
              request.baseURL.password == nil,
              request.baseURL.query == nil,
              request.baseURL.fragment == nil,
              request.baseURL.path.isEmpty || request.baseURL.path == "/"
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidEndpoint
        }
        guard request.orderPlan.orderType == "LIMIT",
              request.orderPlan.timeInForce == "GTC",
              request.orderPlan.side == "BUY" || request.orderPlan.side == "SELL",
              request.orderPlan.clientOrderID.isEmpty == false,
              request.orderPlan.priceQuoteMinorUnits > 0,
              request.orderPlan.quantityBaseAtomicUnits > 0,
              (1...12).contains(request.orderPlan.baseAssetScale),
              request.credentialReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidOrderPlan
        }
    }

    private func canonicalUnsignedQuery(
        for request: ReleaseV0330ObservedCanaryTransportRequest,
        timestamp: Int64
    ) throws -> String {
        var pairs: [(String, String)] = [
            ("symbol", request.orderPlan.symbol),
        ]
        if request.action == .submit {
            pairs.append(contentsOf: [
                ("side", request.orderPlan.side),
                ("type", request.orderPlan.orderType),
                ("timeInForce", request.orderPlan.timeInForce),
                ("quantity", Self.decimalString(
                    units: request.orderPlan.quantityBaseAtomicUnits,
                    scale: request.orderPlan.baseAssetScale
                )),
                ("price", Self.decimalString(
                    units: request.orderPlan.priceQuoteMinorUnits,
                    scale: 2
                )),
                ("newClientOrderId", request.orderPlan.clientOrderID),
            ])
        } else {
            pairs.append(("origClientOrderId", request.orderPlan.clientOrderID))
        }
        pairs.append(("recvWindow", "5000"))
        pairs.append(("timestamp", String(timestamp)))
        return pairs.map { Self.percentEncode($0.0) + "=" + Self.percentEncode($0.1) }
            .joined(separator: "&")
    }

    private func makeURLRequest(
        _ request: ReleaseV0330ObservedCanaryTransportRequest,
        signedQuery: String,
        apiKey: String
    ) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = request.environment.endpointHost(for: request.product)
        components.path = request.product == .spot ? "/api/v3/order" : "/fapi/v1/order"
        components.percentEncodedQuery = signedQuery
        guard let url = components.url else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.invalidNetworkRequest
        }
        var urlRequest = URLRequest(url: url, timeoutInterval: 15)
        switch request.action {
        case .submit:
            urlRequest.httpMethod = "POST"
        case .status:
            urlRequest.httpMethod = "GET"
        case .cancel:
            urlRequest.httpMethod = "DELETE"
        }
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
        return urlRequest
    }

    private func parseExchangeResponse(
        _ data: Data,
        expectedClientOrderID: String
    ) throws -> (orderID: String, clientOrderID: String, status: String) {
        guard let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              let orderID = Self.stringValue(dictionary["orderId"]),
              let clientOrderID = Self.stringValue(
                  dictionary["clientOrderId"] ?? dictionary["origClientOrderId"]
              ),
              let status = Self.stringValue(dictionary["status"]),
              orderID.isEmpty == false,
              clientOrderID.isEmpty == false,
              status.isEmpty == false
        else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.malformedExchangeResponse
        }
        guard clientOrderID == expectedClientOrderID else {
            throw ReleaseV0330ExternallyActivatedCanaryTransportError.exchangeOrderIdentityMismatch
        }
        return (orderID, clientOrderID, status)
    }

    private static func stringValue(_ value: Any?) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as NSNumber:
            return value.stringValue
        default:
            return nil
        }
    }

    private static func signature(for query: String, secret: String) -> String {
        let key = SymmetricKey(data: Data(secret.utf8))
        let digest = HMAC<SHA256>.authenticationCode(for: Data(query.utf8), using: key)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func decimalString(units: Int64, scale: Int) -> String {
        guard scale > 0 else { return String(units) }
        let divisor = Int64(pow(10.0, Double(scale)))
        let whole = units / divisor
        let fraction = String(format: "%0*lld", scale, units % divisor)
            .replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
        return fraction.isEmpty ? String(whole) : "\(whole).\(fraction)"
    }

    private static func percentEncode(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+?")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }

    private static func safeRelativePath(_ path: String) -> Bool {
        path.isEmpty == false
            && path.hasPrefix("/") == false
            && path.hasPrefix("~") == false
            && path.contains("\\") == false
            && path.split(separator: "/", omittingEmptySubsequences: false).allSatisfy {
                $0.isEmpty == false && $0 != "." && $0 != ".."
            }
    }

    private static func isSHA256(_ value: String) -> Bool {
        guard value.hasPrefix("sha256:") else { return false }
        let digest = value.dropFirst("sha256:".count)
        return digest.count == 64 && digest.allSatisfy { $0.isHexDigit && $0.isASCII }
    }
}
