import Crypto
import DomainModel
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// BinancePrivateStreamRuntimeError 描述 GH-526 private stream / account snapshot runtime 的错误边界。
///
/// 错误只覆盖 testnet listenKey lifecycle、private event frame ingest 和 canonical read-model mapping。
/// 它不表示 broker、OMS、ExecutionClient command path 或 production trading 状态。
public enum BinancePrivateStreamRuntimeError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidBaseURL(String)
    case productionEndpointForbidden(String)
    case emptyCredentialReference
    case emptyListenKey
    case listenKeyValueExposed
    case invalidURL(String)
    case httpStatus(Int)
    case emptySourceIdentity
    case emptyCanonicalValue
    case invalidDecimal(field: String, value: String)
    case forbiddenEventKind(String)
    case forbiddenCapability(String)

    public var description: String {
        switch self {
        case let .invalidBaseURL(value):
            "Binance private stream base URL is invalid: \(value)"
        case let .productionEndpointForbidden(host):
            "Binance private stream production endpoint is forbidden by default: \(host)"
        case .emptyCredentialReference:
            "Binance private stream credential reference must not be empty"
        case .emptyListenKey:
            "Binance private stream listenKey must not be empty"
        case .listenKeyValueExposed:
            "Binance private stream listenKey value must not be exposed in read model evidence"
        case let .invalidURL(value):
            "Binance private stream URL is invalid: \(value)"
        case let .httpStatus(status):
            "Binance private stream lifecycle transport returned unsupported HTTP status: \(status)"
        case .emptySourceIdentity:
            "Binance private stream source identity must not be empty"
        case .emptyCanonicalValue:
            "Binance private stream canonical read model value must not be empty"
        case let .invalidDecimal(field, value):
            "Binance private stream decimal is invalid for \(field): \(value)"
        case let .forbiddenEventKind(value):
            "Binance private stream event kind is forbidden for GH-526: \(value)"
        case let .forbiddenCapability(value):
            "Binance private stream runtime contains forbidden capability: \(value)"
        }
    }
}

/// BinancePrivateStreamListenKeyLifecycleAction 固定 GH-526 允许的 listenKey 生命周期动作。
///
/// 这些动作只面向 Binance Spot testnet / local fixture-first validation，不授权 production endpoint。
public enum BinancePrivateStreamListenKeyLifecycleAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case create = "create"
    case keepAlive = "keep-alive"
    case close = "close"

    public var httpMethod: String {
        switch self {
        case .create:
            "POST"
        case .keepAlive:
            "PUT"
        case .close:
            "DELETE"
        }
    }
}

/// BinancePrivateStreamFreshnessStatus 表达 GH-526 stale / blocked / missing / disconnect evidence。
///
/// 这些状态只进入 read model，不驱动 reconnect、order retry、broker fallback 或 command path。
public enum BinancePrivateStreamFreshnessStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fresh = "fresh"
    case stale = "stale"
    case blocked = "blocked"
    case missing = "missing"
    case disconnected = "disconnected"
}

/// BinancePrivateStreamReadModelEventKind 固定 GH-526 可进入 account snapshot read model 的事件类别。
///
/// `executionReport`、order update、broker fill 等交易事件会被 decoder 拒绝，不进入 read model。
public enum BinancePrivateStreamReadModelEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accountSnapshot = "account snapshot"
    case balanceUpdate = "balance update"
    case positionUpdate = "position update"
    case staleEvidence = "stale evidence"
    case blockedEvidence = "blocked evidence"
    case missingEvidence = "missing evidence"
    case disconnectedEvidence = "disconnected evidence"
}

/// BinancePrivateStreamRuntimeConfiguration 固定 GH-526 的 endpoint gate。
///
/// 默认只使用 Binance Spot testnet base URL；production `api.binance.com` 和 non-HTTPS URL 会被拒绝。
public struct BinancePrivateStreamRuntimeConfiguration: Equatable, Sendable {
    public let environment: BinanceSignedAccountReadEnvironment
    public let restBaseURL: URL
    public let streamBaseURL: URL
    public let staleAfterSeconds: Int

    public init(
        environment: BinanceSignedAccountReadEnvironment = .testnet,
        restBaseURL: URL? = nil,
        streamBaseURL: URL? = nil,
        staleAfterSeconds: Int = 60
    ) throws {
        let resolvedRestBaseURL = try restBaseURL ?? Self.defaultTestnetRESTBaseURL()
        let resolvedStreamBaseURL = try streamBaseURL ?? Self.defaultTestnetStreamBaseURL()
        try Self.validate(baseURL: resolvedRestBaseURL)
        try Self.validate(baseURL: resolvedStreamBaseURL)
        if resolvedRestBaseURL.host?.lowercased() == "api.binance.com" {
            throw BinancePrivateStreamRuntimeError.productionEndpointForbidden(
                resolvedRestBaseURL.host ?? "api.binance.com"
            )
        }
        if resolvedStreamBaseURL.host?.lowercased() == "stream.binance.com" {
            throw BinancePrivateStreamRuntimeError.productionEndpointForbidden(
                resolvedStreamBaseURL.host ?? "stream.binance.com"
            )
        }
        guard staleAfterSeconds > 0 else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("staleAfterSeconds<=0")
        }

        self.environment = environment
        self.restBaseURL = resolvedRestBaseURL
        self.streamBaseURL = resolvedStreamBaseURL
        self.staleAfterSeconds = staleAfterSeconds
    }

    private static func defaultTestnetRESTBaseURL() throws -> URL {
        guard let url = URL(string: "https://testnet.binance.vision") else {
            throw BinancePrivateStreamRuntimeError.invalidBaseURL("https://testnet.binance.vision")
        }
        return url
    }

    private static func defaultTestnetStreamBaseURL() throws -> URL {
        guard let url = URL(string: "wss://stream.testnet.binance.vision") else {
            throw BinancePrivateStreamRuntimeError.invalidBaseURL("wss://stream.testnet.binance.vision")
        }
        return url
    }

    private static func validate(baseURL: URL) throws {
        guard ["https", "wss"].contains(baseURL.scheme) else {
            throw BinancePrivateStreamRuntimeError.invalidBaseURL(baseURL.absoluteString)
        }
    }
}

/// BinancePrivateStreamListenKeyLifecycleRequest 是 GH-526 listenKey REST lifecycle 的唯一 request 形状。
///
/// request 只允许 `/api/v3/userDataStream`，只携带 Binance API key header，不生成 order path、
/// broker path、signed order request 或 production authorization。
public struct BinancePrivateStreamListenKeyLifecycleRequest: Equatable, Sendable {
    public let environment: BinanceSignedAccountReadEnvironment
    public let action: BinancePrivateStreamListenKeyLifecycleAction
    public let method: String
    public let path: String
    public let url: URL
    public let headers: [String: String]
    public let credentialReference: String

    public init(
        environment: BinanceSignedAccountReadEnvironment,
        action: BinancePrivateStreamListenKeyLifecycleAction,
        method: String,
        path: String,
        url: URL,
        headers: [String: String],
        credentialReference: String
    ) throws {
        guard path == Self.userDataStreamPath else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability(path)
        }
        guard method == action.httpMethod else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("method:\(method)")
        }
        let trimmedCredentialReference = credentialReference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCredentialReference.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptyCredentialReference
        }
        let serialized = "\(path)?\(url.query ?? "") \(headers.keys.joined(separator: " "))".lowercased()
        for forbidden in Self.forbiddenFragments where serialized.contains(forbidden) {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability(forbidden)
        }

        self.environment = environment
        self.action = action
        self.method = method
        self.path = path
        self.url = url
        self.headers = headers
        self.credentialReference = trimmedCredentialReference
    }

    public static let userDataStreamPath = "/api/v3/userDataStream"

    private static let forbiddenFragments = [
        "/api/v3/order",
        "/sapi/",
        "/fapi/",
        "/dapi/",
        "executionreport",
        "submit",
        "cancel",
        "replace"
    ]
}

/// BinancePrivateStreamListenKeyLease 是 listenKey 的短生命周期 lease。
///
/// Public surface 只暴露 hash 后的 `listenKeyReference`，raw listenKey 仅供同一 DataClient runtime
/// 构造 testnet stream URL，不写入 read model、Dashboard、MessageBus、日志或 verification evidence。
public struct BinancePrivateStreamListenKeyLease: Equatable, Sendable, CustomStringConvertible {
    public let listenKeyReference: String
    public let credentialReference: String
    public let createdAt: Date
    public let expiresAt: Date

    private let rawListenKeyValue: String

    public init(
        rawListenKey: String,
        credentialReference: String,
        createdAt: Date,
        expiresAt: Date
    ) throws {
        let trimmedListenKey = rawListenKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCredentialReference = credentialReference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedListenKey.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptyListenKey
        }
        guard trimmedCredentialReference.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptyCredentialReference
        }
        guard expiresAt > createdAt else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("expiresAt<=createdAt")
        }

        self.listenKeyReference = "listen-key:\(Self.referenceHash(for: trimmedListenKey))"
        self.credentialReference = trimmedCredentialReference
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.rawListenKeyValue = trimmedListenKey
    }

    func rawListenKeyForTransport() -> String {
        rawListenKeyValue
    }

    public var description: String {
        "\(listenKeyReference):<redacted>"
    }

    private static func referenceHash(for value: String) -> String {
        SHA256.hash(data: Data(value.utf8))
            .prefix(8)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

/// BinancePrivateStreamListenKeyTransport 抽象 testnet listenKey lifecycle transport。
///
/// Tests 使用 mock transport；真实 URLSession transport 也只接收已由 configuration 拒绝过 production
/// host 的 request，不保存 credential，不提交订单。
public protocol BinancePrivateStreamListenKeyTransport: Sendable {
    func perform(_ request: BinancePrivateStreamListenKeyLifecycleRequest) async throws -> Data
}

/// URLSessionBinancePrivateStreamListenKeyTransport 是 testnet listenKey lifecycle 的 REST transport。
///
/// 该 actor 不保存 API key，不创建 broker connection，不支持 order submit / cancel / replace。
public actor URLSessionBinancePrivateStreamListenKeyTransport: BinancePrivateStreamListenKeyTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func perform(_ request: BinancePrivateStreamListenKeyLifecycleRequest) async throws -> Data {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        for (name, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        let (data, response) = try await session.data(for: urlRequest)
        if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
            throw BinancePrivateStreamRuntimeError.httpStatus(response.statusCode)
        }
        return data
    }
}

/// BinancePrivateStreamListenKeyClient 构造 GH-526 listenKey lifecycle request。
///
/// Client 只用 credential reference 和 API key header 访问 testnet `/api/v3/userDataStream`；
/// 它不生成 HMAC order signature，不连接 production endpoint，也不授权 private stream command。
public struct BinancePrivateStreamListenKeyClient: Sendable {
    public let configuration: BinancePrivateStreamRuntimeConfiguration

    private let credentialProvider: any BinanceSignedAccountCredentialProvider
    private let transport: any BinancePrivateStreamListenKeyTransport

    public init(
        configuration: BinancePrivateStreamRuntimeConfiguration,
        credentialProvider: any BinanceSignedAccountCredentialProvider,
        transport: any BinancePrivateStreamListenKeyTransport = URLSessionBinancePrivateStreamListenKeyTransport()
    ) {
        self.configuration = configuration
        self.credentialProvider = credentialProvider
        self.transport = transport
    }

    public func openListenKey(createdAt: Date) async throws -> BinancePrivateStreamListenKeyLease {
        let material = try await credentialProvider.loadCredentialMaterial()
        let request = try lifecycleRequest(action: .create, credential: material, lease: nil)
        let payload = try await transport.perform(request)
        let decoded = try JSONDecoder().decode(BinancePrivateStreamListenKeyPayload.self, from: payload)
        return try BinancePrivateStreamListenKeyLease(
            rawListenKey: decoded.listenKey,
            credentialReference: material.referenceID,
            createdAt: createdAt,
            expiresAt: createdAt.addingTimeInterval(60 * 60)
        )
    }

    public func lifecycleRequest(
        action: BinancePrivateStreamListenKeyLifecycleAction,
        credential: BinanceSignedAccountCredentialMaterial,
        lease: BinancePrivateStreamListenKeyLease?
    ) throws -> BinancePrivateStreamListenKeyLifecycleRequest {
        let base = configuration.restBaseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = BinancePrivateStreamListenKeyLifecycleRequest.userDataStreamPath
        guard var components = URLComponents(string: "\(base)\(path)") else {
            throw BinancePrivateStreamRuntimeError.invalidURL(path)
        }
        if action != .create {
            guard let lease else {
                throw BinancePrivateStreamRuntimeError.emptyListenKey
            }
            components.queryItems = [URLQueryItem(name: "listenKey", value: lease.rawListenKeyForTransport())]
        }
        guard let url = components.url else {
            throw BinancePrivateStreamRuntimeError.invalidURL(path)
        }
        return try BinancePrivateStreamListenKeyLifecycleRequest(
            environment: configuration.environment,
            action: action,
            method: action.httpMethod,
            path: path,
            url: url,
            headers: [BinanceSignedAccountReadTransportRequest.binanceKeyHeaderName: credential.binanceHeaderValue()],
            credentialReference: credential.referenceID
        )
    }
}

/// BinancePrivateStreamEventSource 抽象 private stream frames 的来源。
///
/// GH-526 required validation 使用 mock source 注入 WebSocket JSON frames。该协议不暴露
/// URLSessionWebSocketTask、listenKey value、broker payload 或 command retry。
public protocol BinancePrivateStreamEventSource: Sendable {
    func receiveEvents(for lease: BinancePrivateStreamListenKeyLease) async throws -> [Data]
}

/// BinancePrivateStreamSubscription 描述由 listenKey 派生的 testnet stream subscription。
///
/// Public fields 只暴露 redacted listenKey reference 和 URL host/path 级信息；raw listenKey
/// 不进入 read model evidence。
public struct BinancePrivateStreamSubscription: Equatable, Sendable {
    public let redactedStreamURL: URL
    public let listenKeyReference: String
    public let credentialReference: String
    public let exposesListenKeyValue: Bool
    public let opensProductionStream: Bool

    public var boundaryHeld: Bool {
        exposesListenKeyValue == false
            && opensProductionStream == false
            && redactedStreamURL.scheme == "wss"
            && redactedStreamURL.host?.lowercased() != "stream.binance.com"
            && redactedStreamURL.absoluteString.contains(listenKeyReference)
    }
}

/// BinancePrivateStreamReadModelRecord 是 GH-526 private stream / snapshot read model 的单行。
///
/// Row 只表达 canonical account / balance / position / freshness evidence，不暴露 raw private
/// payload、listenKey、broker state、execution report、order id 或 command payload。
public struct BinancePrivateStreamReadModelRecord: Codable, Equatable, Sendable {
    public let eventKind: BinancePrivateStreamReadModelEventKind
    public let freshnessStatus: BinancePrivateStreamFreshnessStatus
    public let asset: String?
    public let free: Decimal?
    public let locked: Decimal?
    public let delta: Decimal?
    public let eventTime: Date?
    public let canonicalReadModelValue: String
    public let sourceIdentity: String
    public let rawPrivatePayloadExposed: Bool
    public let listenKeyValueExposed: Bool
    public let commandSurfaceEnabled: Bool

    public init(
        eventKind: BinancePrivateStreamReadModelEventKind,
        freshnessStatus: BinancePrivateStreamFreshnessStatus,
        asset: String? = nil,
        free: Decimal? = nil,
        locked: Decimal? = nil,
        delta: Decimal? = nil,
        eventTime: Date? = nil,
        canonicalReadModelValue: String,
        sourceIdentity: String,
        rawPrivatePayloadExposed: Bool = false,
        listenKeyValueExposed: Bool = false,
        commandSurfaceEnabled: Bool = false
    ) throws {
        let trimmedValue = canonicalReadModelValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSourceIdentity = sourceIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptyCanonicalValue
        }
        guard trimmedSourceIdentity.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptySourceIdentity
        }
        for forbiddenFlag in [
            ("rawPrivatePayloadExposed", rawPrivatePayloadExposed),
            ("listenKeyValueExposed", listenKeyValueExposed),
            ("commandSurfaceEnabled", commandSurfaceEnabled)
        ] where forbiddenFlag.1 {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability(forbiddenFlag.0)
        }

        self.eventKind = eventKind
        self.freshnessStatus = freshnessStatus
        self.asset = asset
        self.free = free
        self.locked = locked
        self.delta = delta
        self.eventTime = eventTime
        self.canonicalReadModelValue = trimmedValue
        self.sourceIdentity = trimmedSourceIdentity
        self.rawPrivatePayloadExposed = rawPrivatePayloadExposed
        self.listenKeyValueExposed = listenKeyValueExposed
        self.commandSurfaceEnabled = commandSurfaceEnabled
    }
}

/// BinancePrivateStreamAccountSnapshotReadModel 是 GH-526 的 canonical read/update evidence。
///
/// Read model 聚合 GH-525 signed account snapshot、private stream update frames 和 freshness evidence。
/// 它不包含 raw JSON、listenKey value、secret、broker state、OMS state 或 command state。
public struct BinancePrivateStreamAccountSnapshotReadModel: Codable, Equatable, Sendable {
    public let readModelID: FoundationTargetID
    public let signedSnapshotID: FoundationTargetID
    public let listenKeyReference: String
    public let credentialReference: String
    public let sourceIdentity: String
    public let staleAfterSeconds: Int
    public let records: [BinancePrivateStreamReadModelRecord]
    public let validationAnchors: [String]
    public let readModelOnly: Bool
    public let rawPrivatePayloadExposed: Bool
    public let listenKeyValueExposed: Bool
    public let commandRuntimeEnabled: Bool
    public let productionTradingEnabledByDefault: Bool

    public var boundaryHeld: Bool {
        validationAnchors == BinancePrivateStreamAccountSnapshotRuntime.requiredValidationAnchors
            && readModelOnly
            && rawPrivatePayloadExposed == false
            && listenKeyValueExposed == false
            && commandRuntimeEnabled == false
            && productionTradingEnabledByDefault == false
            && Set(records.map(\.freshnessStatus)).isSuperset(of: Set(BinancePrivateStreamFreshnessStatus.allCases))
            && records.contains { $0.eventKind == .accountSnapshot }
            && records.contains { $0.eventKind == .balanceUpdate }
            && records.contains { $0.eventKind == .positionUpdate }
            && records.allSatisfy {
                $0.rawPrivatePayloadExposed == false
                    && $0.listenKeyValueExposed == false
                    && $0.commandSurfaceEnabled == false
            }
    }

    public init(
        readModelID: FoundationTargetID,
        signedSnapshotID: FoundationTargetID,
        listenKeyReference: String,
        credentialReference: String,
        sourceIdentity: String,
        staleAfterSeconds: Int,
        records: [BinancePrivateStreamReadModelRecord],
        validationAnchors: [String] = BinancePrivateStreamAccountSnapshotRuntime.requiredValidationAnchors,
        readModelOnly: Bool = true,
        rawPrivatePayloadExposed: Bool = false,
        listenKeyValueExposed: Bool = false,
        commandRuntimeEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard records.isEmpty == false else {
            throw BinancePrivateStreamRuntimeError.emptyCanonicalValue
        }
        guard validationAnchors == BinancePrivateStreamAccountSnapshotRuntime.requiredValidationAnchors else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("validationAnchors")
        }
        guard readModelOnly else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("readModelOnly=false")
        }
        for forbiddenFlag in [
            ("rawPrivatePayloadExposed", rawPrivatePayloadExposed),
            ("listenKeyValueExposed", listenKeyValueExposed),
            ("commandRuntimeEnabled", commandRuntimeEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ] where forbiddenFlag.1 {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability(forbiddenFlag.0)
        }

        self.readModelID = readModelID
        self.signedSnapshotID = signedSnapshotID
        self.listenKeyReference = listenKeyReference
        self.credentialReference = credentialReference
        self.sourceIdentity = sourceIdentity
        self.staleAfterSeconds = staleAfterSeconds
        self.records = records
        self.validationAnchors = validationAnchors
        self.readModelOnly = readModelOnly
        self.rawPrivatePayloadExposed = rawPrivatePayloadExposed
        self.listenKeyValueExposed = listenKeyValueExposed
        self.commandRuntimeEnabled = commandRuntimeEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }
}

/// BinancePrivateStreamAccountSnapshotRuntime 是 GH-526 的 private stream / snapshot read-only runtime。
///
/// Runtime 消费 GH-525 signed snapshot 和 private stream frames，输出 read/update evidence。
/// 它不保存 secret、不暴露 listenKey、不连接 broker、不实现 submit / cancel / replace。
public struct BinancePrivateStreamAccountSnapshotRuntime: Sendable {
    public let configuration: BinancePrivateStreamRuntimeConfiguration

    public init(configuration: BinancePrivateStreamRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func subscription(for lease: BinancePrivateStreamListenKeyLease) throws -> BinancePrivateStreamSubscription {
        let base = configuration.streamBaseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let redactedURL = URL(string: "\(base)/ws/\(lease.listenKeyReference)") else {
            throw BinancePrivateStreamRuntimeError.invalidURL("private stream subscription")
        }
        return BinancePrivateStreamSubscription(
            redactedStreamURL: redactedURL,
            listenKeyReference: lease.listenKeyReference,
            credentialReference: lease.credentialReference,
            exposesListenKeyValue: false,
            opensProductionStream: configuration.streamBaseURL.host?.lowercased() == "stream.binance.com"
        )
    }

    public func readModel(
        signedSnapshot: BinanceSignedAccountReadSnapshot,
        lease: BinancePrivateStreamListenKeyLease,
        eventPayloads: [Data],
        sourceIdentity: String = "gh-526-binance-private-stream-account-snapshot-runtime"
    ) throws -> BinancePrivateStreamAccountSnapshotReadModel {
        guard signedSnapshot.snapshotBoundaryHeld else {
            throw BinancePrivateStreamRuntimeError.forbiddenCapability("signedSnapshotBoundary")
        }
        let snapshotRecords = try Self.snapshotRecords(
            from: signedSnapshot,
            sourceIdentity: sourceIdentity
        )
        let eventRecords = try BinancePrivateStreamPayloadDecoder.decodeEventRecords(
            from: eventPayloads,
            sourceIdentity: sourceIdentity
        )
        let freshnessRecords = try Self.freshnessEvidenceRecords(sourceIdentity: sourceIdentity)
        return try BinancePrivateStreamAccountSnapshotReadModel(
            readModelID: try FoundationTargetID("gh-526-binance-private-stream-account-snapshot-read-model"),
            signedSnapshotID: signedSnapshot.snapshotID,
            listenKeyReference: lease.listenKeyReference,
            credentialReference: lease.credentialReference,
            sourceIdentity: sourceIdentity,
            staleAfterSeconds: configuration.staleAfterSeconds,
            records: snapshotRecords + eventRecords + freshnessRecords
        )
    }

    public func readModel(
        signedSnapshot: BinanceSignedAccountReadSnapshot,
        lease: BinancePrivateStreamListenKeyLease,
        eventSource: any BinancePrivateStreamEventSource,
        sourceIdentity: String = "gh-526-binance-private-stream-account-snapshot-runtime"
    ) async throws -> BinancePrivateStreamAccountSnapshotReadModel {
        let payloads = try await eventSource.receiveEvents(for: lease)
        return try readModel(
            signedSnapshot: signedSnapshot,
            lease: lease,
            eventPayloads: payloads,
            sourceIdentity: sourceIdentity
        )
    }

    public static let requiredValidationAnchors = [
        "GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME",
        "TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT"
    ]

    private static func snapshotRecords(
        from snapshot: BinanceSignedAccountReadSnapshot,
        sourceIdentity: String
    ) throws -> [BinancePrivateStreamReadModelRecord] {
        let accountRecord = try BinancePrivateStreamReadModelRecord(
            eventKind: .accountSnapshot,
            freshnessStatus: .fresh,
            eventTime: snapshot.updateTime,
            canonicalReadModelValue: "accountType=\(snapshot.accountType);balanceCount=\(snapshot.balances.count)",
            sourceIdentity: sourceIdentity
        )
        let balanceRecords = try snapshot.balances.flatMap { balance in
            [
                try BinancePrivateStreamReadModelRecord(
                    eventKind: .balanceUpdate,
                    freshnessStatus: .fresh,
                    asset: balance.asset,
                    free: balance.free,
                    locked: balance.locked,
                    eventTime: snapshot.updateTime,
                    canonicalReadModelValue: "\(balance.asset):free=\(balance.free);locked=\(balance.locked)",
                    sourceIdentity: sourceIdentity
                ),
                try BinancePrivateStreamReadModelRecord(
                    eventKind: .positionUpdate,
                    freshnessStatus: .fresh,
                    asset: balance.asset,
                    free: balance.free,
                    locked: balance.locked,
                    eventTime: snapshot.updateTime,
                    canonicalReadModelValue: "\(balance.asset):spot-position-total=\(balance.total)",
                    sourceIdentity: sourceIdentity
                )
            ]
        }
        return [accountRecord] + balanceRecords
    }

    private static func freshnessEvidenceRecords(
        sourceIdentity: String
    ) throws -> [BinancePrivateStreamReadModelRecord] {
        try [
            BinancePrivateStreamReadModelRecord(
                eventKind: .staleEvidence,
                freshnessStatus: .stale,
                canonicalReadModelValue: "stale private stream evidence blocks command inference",
                sourceIdentity: sourceIdentity
            ),
            BinancePrivateStreamReadModelRecord(
                eventKind: .blockedEvidence,
                freshnessStatus: .blocked,
                canonicalReadModelValue: "blocked private stream evidence keeps release read-model-only",
                sourceIdentity: sourceIdentity
            ),
            BinancePrivateStreamReadModelRecord(
                eventKind: .missingEvidence,
                freshnessStatus: .missing,
                canonicalReadModelValue: "missing private stream evidence has no broker fallback",
                sourceIdentity: sourceIdentity
            ),
            BinancePrivateStreamReadModelRecord(
                eventKind: .disconnectedEvidence,
                freshnessStatus: .disconnected,
                canonicalReadModelValue: "disconnect evidence records no reconnect command retry",
                sourceIdentity: sourceIdentity
            )
        ]
    }
}

/// BinancePrivateStreamPayloadDecoder 映射 Binance private stream JSON frames 到 read model records。
///
/// Decoder 只保留 canonical fields；任何 execution report / order update / broker fill frame 都会被拒绝。
public enum BinancePrivateStreamPayloadDecoder {
    public static func decodeEventRecords(
        from payloads: [Data],
        sourceIdentity: String
    ) throws -> [BinancePrivateStreamReadModelRecord] {
        try payloads.flatMap { payload in
            let event = try JSONDecoder().decode(BinancePrivateStreamEnvelope.self, from: payload)
            switch event.eventType {
            case "outboundAccountPosition":
                return try decodeOutboundAccountPosition(payload, sourceIdentity: sourceIdentity)
            case "balanceUpdate":
                return try decodeBalanceUpdate(payload, sourceIdentity: sourceIdentity)
            case "executionReport", "ORDER_TRADE_UPDATE", "listStatus":
                throw BinancePrivateStreamRuntimeError.forbiddenEventKind(event.eventType)
            default:
                throw BinancePrivateStreamRuntimeError.forbiddenEventKind(event.eventType)
            }
        }
    }

    private static func decodeOutboundAccountPosition(
        _ data: Data,
        sourceIdentity: String
    ) throws -> [BinancePrivateStreamReadModelRecord] {
        let payload = try JSONDecoder().decode(BinanceOutboundAccountPositionPayload.self, from: data)
        let eventTime = Date(timeIntervalSince1970: Double(payload.eventTime) / 1_000)
        let updateTime = Date(timeIntervalSince1970: Double(payload.updateTime) / 1_000)
        let accountRecord = try BinancePrivateStreamReadModelRecord(
            eventKind: .accountSnapshot,
            freshnessStatus: .fresh,
            eventTime: eventTime,
            canonicalReadModelValue: "outboundAccountPosition:updateTime=\(Int(updateTime.timeIntervalSince1970 * 1_000));balances=\(payload.balances.count)",
            sourceIdentity: sourceIdentity
        )
        let balanceRecords = try payload.balances.flatMap { balance in
            let free = try decimal(balance.free, field: "outboundAccountPosition.B.free")
            let locked = try decimal(balance.locked, field: "outboundAccountPosition.B.locked")
            return [
                try BinancePrivateStreamReadModelRecord(
                    eventKind: .balanceUpdate,
                    freshnessStatus: .fresh,
                    asset: balance.asset,
                    free: free,
                    locked: locked,
                    eventTime: eventTime,
                    canonicalReadModelValue: "\(balance.asset):stream-free=\(free);stream-locked=\(locked)",
                    sourceIdentity: sourceIdentity
                ),
                try BinancePrivateStreamReadModelRecord(
                    eventKind: .positionUpdate,
                    freshnessStatus: .fresh,
                    asset: balance.asset,
                    free: free,
                    locked: locked,
                    eventTime: eventTime,
                    canonicalReadModelValue: "\(balance.asset):stream-spot-position-total=\(free + locked)",
                    sourceIdentity: sourceIdentity
                )
            ]
        }
        return [accountRecord] + balanceRecords
    }

    private static func decodeBalanceUpdate(
        _ data: Data,
        sourceIdentity: String
    ) throws -> [BinancePrivateStreamReadModelRecord] {
        let payload = try JSONDecoder().decode(BinanceBalanceUpdatePayload.self, from: data)
        let clearTime = Date(timeIntervalSince1970: Double(payload.clearTime) / 1_000)
        let delta = try decimal(payload.delta, field: "balanceUpdate.d")
        return [
            try BinancePrivateStreamReadModelRecord(
                eventKind: .balanceUpdate,
                freshnessStatus: .fresh,
                asset: payload.asset,
                delta: delta,
                eventTime: clearTime,
                canonicalReadModelValue: "\(payload.asset):balance-delta=\(delta)",
                sourceIdentity: sourceIdentity
            )
        ]
    }

    private static func decimal(_ value: String, field: String) throws -> Decimal {
        guard let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
            throw BinancePrivateStreamRuntimeError.invalidDecimal(field: field, value: value)
        }
        return decimal
    }
}

private struct BinancePrivateStreamListenKeyPayload: Decodable {
    let listenKey: String
}

private struct BinancePrivateStreamEnvelope: Decodable {
    let eventType: String

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
    }
}

private struct BinanceOutboundAccountPositionPayload: Decodable {
    let eventType: String
    let eventTime: Int
    let updateTime: Int
    let balances: [BinanceOutboundAccountPositionBalancePayload]

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case updateTime = "u"
        case balances = "B"
    }
}

private struct BinanceOutboundAccountPositionBalancePayload: Decodable {
    let asset: String
    let free: String
    let locked: String

    enum CodingKeys: String, CodingKey {
        case asset = "a"
        case free = "f"
        case locked = "l"
    }
}

private struct BinanceBalanceUpdatePayload: Decodable {
    let eventType: String
    let eventTime: Int
    let asset: String
    let delta: String
    let clearTime: Int

    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case asset = "a"
        case delta = "d"
        case clearTime = "T"
    }
}
