import Crypto
import DomainModel
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// BinanceSignedAccountReadRuntimeError 描述 GH-525 signed account read-only runtime 的本地错误。
///
/// 错误只覆盖 credential reference、testnet endpoint、签名请求构造和只读账户快照映射。
/// 它不代表 production cutover、broker connection、listenKey、private stream 或订单生命周期状态。
public enum BinanceSignedAccountReadRuntimeError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyCredentialReference
    case emptyCredentialHeader
    case emptySigningSecret
    case invalidBaseURL(String)
    case productionEndpointForbidden(String)
    case invalidReceiveWindow(Int)
    case invalidTimestamp(Date)
    case invalidURL(String)
    case httpStatus(Int)
    case emptyAccountType
    case emptyAsset
    case invalidDecimal(field: String, value: String)
    case forbiddenRequestCapability(String)

    public var description: String {
        switch self {
        case .emptyCredentialReference:
            "Binance signed account read credential reference must not be empty"
        case .emptyCredentialHeader:
            "Binance signed account read credential header must not be empty"
        case .emptySigningSecret:
            "Binance signed account read signing secret must not be empty"
        case let .invalidBaseURL(value):
            "Binance signed account read base URL is invalid: \(value)"
        case let .productionEndpointForbidden(host):
            "Binance signed account read production endpoint is forbidden by default: \(host)"
        case let .invalidReceiveWindow(value):
            "Binance signed account read receive window is invalid: \(value)"
        case let .invalidTimestamp(value):
            "Binance signed account read timestamp is invalid: \(value)"
        case let .invalidURL(value):
            "Binance signed account read URL is invalid: \(value)"
        case let .httpStatus(status):
            "Binance signed account read transport returned unsupported HTTP status: \(status)"
        case .emptyAccountType:
            "Binance signed account snapshot account type must not be empty"
        case .emptyAsset:
            "Binance signed account snapshot asset must not be empty"
        case let .invalidDecimal(field, value):
            "Binance signed account snapshot decimal is invalid for \(field): \(value)"
        case let .forbiddenRequestCapability(value):
            "Binance signed account read request contains forbidden capability: \(value)"
        }
    }
}

/// BinanceSignedAccountReadEnvironment 固定 GH-525 允许的 signed account read 环境。
///
/// Release v0.1.0 只允许 local fixture 和 Binance Spot testnet；production endpoint 没有默认入口。
public enum BinanceSignedAccountReadEnvironment: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFixture = "local fixture"
    case testnet = "testnet"
}

/// BinanceSignedAccountCredentialMaterial 是 signed read runtime 的短生命周期 credential material。
///
/// Public surface 只暴露 `referenceID`，用于审计 credential 来源。header value 和 signing secret
/// 只在构造 request 时进入内存，不写入 snapshot、日志、Dashboard、MessageBus 或 verification evidence。
public struct BinanceSignedAccountCredentialMaterial: Sendable {
    public let referenceID: String
    private let keyHeaderValue: String
    private let signingSecretValue: String

    public init(
        referenceID: String,
        keyHeaderValue: String,
        signingSecretValue: String
    ) throws {
        let trimmedReference = referenceID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHeader = keyHeaderValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecret = signingSecretValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedReference.isEmpty == false else {
            throw BinanceSignedAccountReadRuntimeError.emptyCredentialReference
        }
        guard trimmedHeader.isEmpty == false else {
            throw BinanceSignedAccountReadRuntimeError.emptyCredentialHeader
        }
        guard trimmedSecret.isEmpty == false else {
            throw BinanceSignedAccountReadRuntimeError.emptySigningSecret
        }

        self.referenceID = trimmedReference
        self.keyHeaderValue = trimmedHeader
        self.signingSecretValue = trimmedSecret
    }

    /// Binance header value 只交给 transport request，不进入任何 read model evidence。
    public func binanceHeaderValue() -> String {
        keyHeaderValue
    }

    /// 对 canonical query string 生成 Binance HMAC-SHA256 signature。
    public func signature(for queryString: String) -> String {
        let key = SymmetricKey(data: Data(signingSecretValue.utf8))
        let signature = HMAC<SHA256>.authenticationCode(
            for: Data(queryString.utf8),
            using: key
        )
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    public var redactedReferenceDescription: String {
        "\(referenceID):<redacted>"
    }
}

/// BinanceSignedAccountCredentialProvider 只在调用时提供 credential material。
///
/// 当前仓库不提供 environment secret reader 或 production secret store；required validation 使用
/// `BinanceStaticSignedAccountCredentialProvider` 注入 fixture credential。
public protocol BinanceSignedAccountCredentialProvider: Sendable {
    func loadCredentialMaterial() async throws -> BinanceSignedAccountCredentialMaterial
}

/// BinanceStaticSignedAccountCredentialProvider 只服务 local fixture / testnet validation。
///
/// 该 provider 不读取环境变量、不访问 keychain、不保存到磁盘，也不把 sandbox credential 升级为 production。
public struct BinanceStaticSignedAccountCredentialProvider: BinanceSignedAccountCredentialProvider {
    private let material: BinanceSignedAccountCredentialMaterial

    public init(material: BinanceSignedAccountCredentialMaterial) {
        self.material = material
    }

    public func loadCredentialMaterial() async throws -> BinanceSignedAccountCredentialMaterial {
        material
    }
}

/// BinanceSignedAccountReadClientConfiguration 固定 signed account read-only runtime 的 endpoint gate。
///
/// 默认使用 Binance Spot testnet base URL。自定义 URL 必须是 HTTPS，且不能是 production
/// `api.binance.com` host。该配置不包含 secret value，也不打开 production trading。
public struct BinanceSignedAccountReadClientConfiguration: Equatable, Sendable {
    public let environment: BinanceSignedAccountReadEnvironment
    public let baseURL: URL
    public let receiveWindowMilliseconds: Int

    public init(
        environment: BinanceSignedAccountReadEnvironment = .testnet,
        baseURL: URL? = nil,
        receiveWindowMilliseconds: Int = 5_000
    ) throws {
        let resolvedBaseURL = try baseURL ?? Self.defaultTestnetBaseURL()
        guard receiveWindowMilliseconds > 0 else {
            throw BinanceSignedAccountReadRuntimeError.invalidReceiveWindow(receiveWindowMilliseconds)
        }
        guard resolvedBaseURL.scheme == "https" else {
            throw BinanceSignedAccountReadRuntimeError.invalidBaseURL(resolvedBaseURL.absoluteString)
        }
        if resolvedBaseURL.host?.lowercased() == "api.binance.com" {
            throw BinanceSignedAccountReadRuntimeError.productionEndpointForbidden(
                resolvedBaseURL.host ?? "api.binance.com"
            )
        }

        self.environment = environment
        self.baseURL = resolvedBaseURL
        self.receiveWindowMilliseconds = receiveWindowMilliseconds
    }

    private static func defaultTestnetBaseURL() throws -> URL {
        guard let url = URL(string: "https://testnet.binance.vision") else {
            throw BinanceSignedAccountReadRuntimeError.invalidBaseURL("https://testnet.binance.vision")
        }
        return url
    }
}

/// BinanceSignedAccountReadTransportRequest 是 GH-525 唯一允许的 signed account transport 输入。
///
/// request 可以携带 Binance key header 和 signature query item，但只能访问 `/api/v3/account`，
/// 且只能读取账户快照。它不包含 order path、listenKey path、broker command 或 production authorization。
public struct BinanceSignedAccountReadTransportRequest: Equatable, Sendable {
    public let environment: BinanceSignedAccountReadEnvironment
    public let method: String
    public let path: String
    public let url: URL
    public let headers: [String: String]
    public let unsignedQueryString: String
    public let credentialReference: String

    public init(
        environment: BinanceSignedAccountReadEnvironment,
        method: String,
        path: String,
        url: URL,
        headers: [String: String],
        unsignedQueryString: String,
        credentialReference: String
    ) throws {
        guard path == Self.accountReadOnlyPath else {
            throw BinanceSignedAccountReadRuntimeError.forbiddenRequestCapability(path)
        }
        let serialized = "\(path)?\(url.query ?? "") \(headers.keys.joined(separator: " "))".lowercased()
        for forbidden in Self.forbiddenFragments where serialized.contains(forbidden) {
            throw BinanceSignedAccountReadRuntimeError.forbiddenRequestCapability(forbidden)
        }
        self.environment = environment
        self.method = method
        self.path = path
        self.url = url
        self.headers = headers
        self.unsignedQueryString = unsignedQueryString
        self.credentialReference = credentialReference
    }

    public static let accountReadOnlyPath = "/api/v3/account"
    public static let binanceKeyHeaderName = "X-MBX-APIKEY"

    private static let forbiddenFragments = [
        "/api/v3/order",
        "/api/v3/userdatastream",
        "listenkey",
        "/sapi/",
        "/fapi/",
        "/dapi/"
    ]
}

/// BinanceSignedAccountReadTransport 抽象只负责读取 signed account payload。
///
/// Tests 注入 mock transport。真实 URLSession transport 只能在显式 testnet credential
/// 和 operator-controlled validation 下使用；production endpoint 默认被 configuration 拒绝。
public protocol BinanceSignedAccountReadTransport: Sendable {
    func load(_ request: BinanceSignedAccountReadTransportRequest) async throws -> Data
}

/// URLSessionBinanceSignedAccountReadTransport 是 signed account read-only 的 testnet transport。
///
/// 该 actor 不保存 credential material，不创建 listenKey，不连接 broker，也不支持 submit / cancel / replace。
public actor URLSessionBinanceSignedAccountReadTransport: BinanceSignedAccountReadTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load(_ request: BinanceSignedAccountReadTransportRequest) async throws -> Data {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        for (name, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        let (data, response) = try await session.data(for: urlRequest)
        if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
            throw BinanceSignedAccountReadRuntimeError.httpStatus(response.statusCode)
        }
        return data
    }
}

/// BinanceSignedAccountReadSnapshot 是 GH-525 的 canonical account read model。
///
/// Snapshot 只暴露 normalized account / balance fields 和 boundary flags，不暴露 raw signed payload、
/// secret、header value、broker state、private stream event 或 command state。
public struct BinanceSignedAccountReadSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: FoundationTargetID
    public let accountType: String
    public let canTrade: Bool
    public let canWithdraw: Bool
    public let canDeposit: Bool
    public let updateTime: Date?
    public let balances: [BinanceSignedAccountBalanceReadModel]
    public let credentialReference: String
    public let sourcePath: String
    public let validationAnchors: [String]
    public let readModelOnly: Bool
    public let rawPayloadExposed: Bool
    public let secretMaterialExposed: Bool
    public let commandRuntimeEnabled: Bool
    public let productionTradingEnabledByDefault: Bool

    public var snapshotBoundaryHeld: Bool {
        sourcePath == BinanceSignedAccountReadTransportRequest.accountReadOnlyPath
            && validationAnchors == Self.requiredValidationAnchors
            && readModelOnly
            && rawPayloadExposed == false
            && secretMaterialExposed == false
            && commandRuntimeEnabled == false
            && productionTradingEnabledByDefault == false
    }

    public init(
        snapshotID: FoundationTargetID,
        accountType: String,
        canTrade: Bool,
        canWithdraw: Bool,
        canDeposit: Bool,
        updateTime: Date?,
        balances: [BinanceSignedAccountBalanceReadModel],
        credentialReference: String,
        sourcePath: String = BinanceSignedAccountReadTransportRequest.accountReadOnlyPath,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        readModelOnly: Bool = true,
        rawPayloadExposed: Bool = false,
        secretMaterialExposed: Bool = false,
        commandRuntimeEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        let trimmedAccountType = accountType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedAccountType.isEmpty == false else {
            throw BinanceSignedAccountReadRuntimeError.emptyAccountType
        }
        guard readModelOnly else {
            throw BinanceSignedAccountReadRuntimeError.forbiddenRequestCapability("readModelOnly=false")
        }
        for (field, value) in [
            ("rawPayloadExposed", rawPayloadExposed),
            ("secretMaterialExposed", secretMaterialExposed),
            ("commandRuntimeEnabled", commandRuntimeEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ] where value {
            throw BinanceSignedAccountReadRuntimeError.forbiddenRequestCapability(field)
        }

        self.snapshotID = snapshotID
        self.accountType = trimmedAccountType
        self.canTrade = canTrade
        self.canWithdraw = canWithdraw
        self.canDeposit = canDeposit
        self.updateTime = updateTime
        self.balances = balances
        self.credentialReference = credentialReference
        self.sourcePath = sourcePath
        self.validationAnchors = validationAnchors
        self.readModelOnly = readModelOnly
        self.rawPayloadExposed = rawPayloadExposed
        self.secretMaterialExposed = secretMaterialExposed
        self.commandRuntimeEnabled = commandRuntimeEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-525-BINANCE-SIGNED-ACCOUNT-READ-RUNTIME",
        "TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ"
    ]
}

/// BinanceSignedAccountBalanceReadModel 是 account snapshot 的 normalized balance row。
///
/// Balance row 只表达 asset、free、locked 和 total，不表达 broker position sync、margin command
/// 或任何可交易授权。
public struct BinanceSignedAccountBalanceReadModel: Codable, Equatable, Sendable {
    public let asset: String
    public let free: Decimal
    public let locked: Decimal
    public let total: Decimal

    public init(asset: String, free: Decimal, locked: Decimal) throws {
        let trimmedAsset = asset.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedAsset.isEmpty == false else {
            throw BinanceSignedAccountReadRuntimeError.emptyAsset
        }
        self.asset = trimmedAsset
        self.free = free
        self.locked = locked
        self.total = free + locked
    }
}

/// BinanceSignedAccountReadClient 是 GH-525 的 signed account read-only runtime。
///
/// 它构造 Binance testnet `/api/v3/account` signed GET request，解析为 canonical read model。
/// 它不实现 listenKey/private stream、不提交订单、不暴露 raw payload、不保存 secret。
public struct BinanceSignedAccountReadClient: Sendable {
    public let configuration: BinanceSignedAccountReadClientConfiguration

    private let credentialProvider: any BinanceSignedAccountCredentialProvider
    private let transport: any BinanceSignedAccountReadTransport

    public init(
        configuration: BinanceSignedAccountReadClientConfiguration,
        credentialProvider: any BinanceSignedAccountCredentialProvider,
        transport: any BinanceSignedAccountReadTransport = URLSessionBinanceSignedAccountReadTransport()
    ) {
        self.configuration = configuration
        self.credentialProvider = credentialProvider
        self.transport = transport
    }

    public func accountSnapshot(timestamp: Date) async throws -> BinanceSignedAccountReadSnapshot {
        let material = try await credentialProvider.loadCredentialMaterial()
        let request = try transportRequest(timestamp: timestamp, credential: material)
        let payload = try await transport.load(request)
        return try BinanceSignedAccountPayloadDecoder.decodeAccountSnapshot(
            from: payload,
            credentialReference: material.referenceID,
            sourcePath: request.path
        )
    }

    public func transportRequest(
        timestamp: Date,
        credential: BinanceSignedAccountCredentialMaterial
    ) throws -> BinanceSignedAccountReadTransportRequest {
        guard timestamp.timeIntervalSince1970 >= 0 else {
            throw BinanceSignedAccountReadRuntimeError.invalidTimestamp(timestamp)
        }
        let milliseconds = Int((timestamp.timeIntervalSince1970 * 1_000).rounded(.down))
        let unsignedItems = [
            URLQueryItem(name: "timestamp", value: String(milliseconds)),
            URLQueryItem(name: "recvWindow", value: String(configuration.receiveWindowMilliseconds))
        ]
        let unsignedQuery = Self.canonicalQueryString(unsignedItems)
        let signature = credential.signature(for: unsignedQuery)
        var signedItems = unsignedItems
        signedItems.append(URLQueryItem(name: "signature", value: signature))

        let base = configuration.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = BinanceSignedAccountReadTransportRequest.accountReadOnlyPath
        guard var components = URLComponents(string: "\(base)\(path)") else {
            throw BinanceSignedAccountReadRuntimeError.invalidURL(path)
        }
        components.queryItems = signedItems
        guard let url = components.url else {
            throw BinanceSignedAccountReadRuntimeError.invalidURL(path)
        }

        return try BinanceSignedAccountReadTransportRequest(
            environment: configuration.environment,
            method: "GET",
            path: path,
            url: url,
            headers: [BinanceSignedAccountReadTransportRequest.binanceKeyHeaderName: credential.binanceHeaderValue()],
            unsignedQueryString: unsignedQuery,
            credentialReference: credential.referenceID
        )
    }

    private static func canonicalQueryString(_ items: [URLQueryItem]) -> String {
        items.map { item in
            "\(item.name)=\(item.value ?? "")"
        }
        .joined(separator: "&")
    }
}

/// BinanceSignedAccountPayloadDecoder 只把 account payload 映射为 normalized read model。
///
/// Decoder 不返回 raw JSON，不保留 header / signature，不映射 order、listenKey 或 broker state。
public enum BinanceSignedAccountPayloadDecoder {
    public static func decodeAccountSnapshot(
        from data: Data,
        credentialReference: String,
        sourcePath: String
    ) throws -> BinanceSignedAccountReadSnapshot {
        let payload = try JSONDecoder().decode(BinanceSignedAccountPayload.self, from: data)
        let balances = try payload.balances.map { row in
            try BinanceSignedAccountBalanceReadModel(
                asset: row.asset,
                free: decimal(row.free, field: "balances.free"),
                locked: decimal(row.locked, field: "balances.locked")
            )
        }
        return try BinanceSignedAccountReadSnapshot(
            snapshotID: try FoundationTargetID("gh-525-binance-signed-account-snapshot"),
            accountType: payload.accountType,
            canTrade: payload.canTrade,
            canWithdraw: payload.canWithdraw,
            canDeposit: payload.canDeposit,
            updateTime: payload.updateTime.map { Date(timeIntervalSince1970: Double($0) / 1_000) },
            balances: balances,
            credentialReference: credentialReference,
            sourcePath: sourcePath
        )
    }

    private static func decimal(_ value: String, field: String) throws -> Decimal {
        guard let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
            throw BinanceSignedAccountReadRuntimeError.invalidDecimal(field: field, value: value)
        }
        return decimal
    }
}

private struct BinanceSignedAccountPayload: Decodable {
    let accountType: String
    let canTrade: Bool
    let canWithdraw: Bool
    let canDeposit: Bool
    let updateTime: Int?
    let balances: [BinanceSignedAccountBalancePayload]
}

private struct BinanceSignedAccountBalancePayload: Decodable {
    let asset: String
    let free: String
    let locked: String
}
