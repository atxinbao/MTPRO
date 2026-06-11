import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import DomainModel

public enum BinancePublicMarketDataContractError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidLimit(field: String, value: Int, allowedRange: String)
    case invalidNumericField(field: String, value: String)

    public var description: String {
        switch self {
        case let .invalidLimit(field, value, allowedRange):
            "Binance limit is invalid for \(field): \(value), allowed: \(allowedRange)"
        case let .invalidNumericField(field, value):
            "Binance numeric field is invalid for \(field): \(value)"
        }
    }
}

public enum BinancePublicMarketDataCapability: String, CaseIterable, Codable, Equatable, Sendable {
    case exchangeInfo = "exchangeInfo"
    case klines = "klines"
    case recentTrades = "recent trades"
    case bestBidAsk = "best bid / ask"
    case depthSnapshot = "depth snapshot"
    case depthDelta = "depth delta"
    case premiumIndex = "premium index"
    case openInterest = "open interest"
}

public enum BinanceForbiddenCapability: String, CaseIterable, Codable, Equatable, Sendable {
    case apiKey = "API key"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case orderSubmit = "order submit"
    case orderCancel = "order cancel"
    case orderReplace = "order replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case orderReconciliation = "order reconciliation"
    case realAccountState = "real account state"
    case brokerPositionSync = "broker position sync"
    case listenKeyUserDataStream = "listenKey user data stream"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case executionVenueConnection = "execution venue connection"
    case realOrderLifecycle = "real order lifecycle"
    case oms = "OMS"
}

public enum BinancePublicTransport: String, Codable, Equatable, Sendable {
    case restGET = "REST GET"
    case webSocketStream = "WebSocket stream"
}

public enum BinanceDepthSnapshotLimit: Int, CaseIterable, Codable, Equatable, Sendable {
    case five = 5
    case ten = 10
    case twenty = 20
    case fifty = 50
    case oneHundred = 100
    case fiveHundred = 500
    case oneThousand = 1_000
    case fiveThousand = 5_000
}

public struct BinanceQueryItem: Equatable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public struct BinancePublicRequestContract: Equatable, Sendable {
    public let capability: BinancePublicMarketDataCapability
    public let productType: ProductType?
    public let transport: BinancePublicTransport
    public let path: String
    public let queryItems: [BinanceQueryItem]
    public let isReadOnly: Bool
    public let requiresAPIKey: Bool

    public init(
        capability: BinancePublicMarketDataCapability,
        productType: ProductType? = nil,
        transport: BinancePublicTransport,
        path: String,
        queryItems: [BinanceQueryItem] = [],
        isReadOnly: Bool = true,
        requiresAPIKey: Bool = false
    ) {
        self.capability = capability
        self.productType = productType
        self.transport = transport
        self.path = path
        self.queryItems = queryItems
        self.isReadOnly = isReadOnly
        self.requiresAPIKey = requiresAPIKey
    }
}

/// Binance public 行情客户端配置只保存公开 REST 与 WebSocket base URL，不保存 API key、
/// signature、account 或 order 相关信息。输入来自只读 endpoint contract，输出仍由 decoder
/// 转成 DomainModel / Core 兼容市场数据模型，禁止把网络响应直接暴露给 App 或 Persistence。
public struct BinancePublicMarketDataClientConfiguration: Equatable, Sendable {
    public let restBaseURL: URL
    public let webSocketBaseURL: URL
    public let usdsPerpetualRestBaseURL: URL
    public let usdsPerpetualWebSocketBaseURL: URL

    public init(
        restBaseURL: URL = URL(string: "https://api.binance.com")!,
        webSocketBaseURL: URL = URL(string: "wss://stream.binance.com:9443")!,
        usdsPerpetualRestBaseURL: URL = URL(string: "https://fapi.binance.com")!,
        usdsPerpetualWebSocketBaseURL: URL = URL(string: "wss://fstream.binance.com")!
    ) {
        self.restBaseURL = restBaseURL
        self.webSocketBaseURL = webSocketBaseURL
        self.usdsPerpetualRestBaseURL = usdsPerpetualRestBaseURL
        self.usdsPerpetualWebSocketBaseURL = usdsPerpetualWebSocketBaseURL
    }

    public init(
        restBaseURL: URL,
        webSocketBaseURL: URL
    ) {
        self.init(
            restBaseURL: restBaseURL,
            webSocketBaseURL: webSocketBaseURL,
            usdsPerpetualRestBaseURL: URL(string: "https://fapi.binance.com")!,
            usdsPerpetualWebSocketBaseURL: URL(string: "wss://fstream.binance.com")!
        )
    }
}

/// Binance public transport request 是客户端交给传输层的唯一请求形态。
/// headers 固定由客户端生成且默认为空，用于保证 required validation 可以断言没有 API key、
/// signature、listenKey 或任何 signed/account/order 能力进入网络边界。
public struct BinancePublicTransportRequest: Equatable, Sendable {
    public let contract: BinancePublicRequestContract
    public let method: String
    public let url: URL
    public let headers: [String: String]

    public init(
        contract: BinancePublicRequestContract,
        method: String,
        url: URL,
        headers: [String: String] = [:]
    ) {
        self.contract = contract
        self.method = method
        self.url = url
        self.headers = headers
    }
}

/// Binance public market data transport 抽象只负责读取公开 payload。
/// 实现者不得要求 API key，不得签名请求，不得访问 account/order/listenKey endpoint；
/// 测试可注入 mock transport，避免 required validation 依赖真实 Binance 网络。
public protocol BinancePublicMarketDataTransport: Sendable {
    func load(_ request: BinancePublicTransportRequest) async throws -> Data
}

/// URLSession 传输实现提供真实网络客户端边界，但只接受客户端已经校验过的 public read-only
/// request。REST 使用 GET 读取公开 endpoint；WebSocket 分支只接收单条公开 stream payload，
/// 不管理 listenKey、不建立用户数据流，也不触发任何交易或账户动作。
public actor URLSessionBinancePublicMarketDataTransport: BinancePublicMarketDataTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load(_ request: BinancePublicTransportRequest) async throws -> Data {
        switch request.contract.transport {
        case .restGET:
            var urlRequest = URLRequest(url: request.url)
            urlRequest.httpMethod = request.method
            request.headers.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            let (data, response) = try await session.data(for: urlRequest)
            if let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) == false {
                throw BinancePublicMarketDataClientError.httpStatus(response.statusCode)
            }
            return data

        case .webSocketStream:
            #if os(macOS)
            let task = session.webSocketTask(with: request.url)
            task.resume()
            defer {
                task.cancel(with: .goingAway, reason: nil)
            }
            let message = try await task.receive()
            switch message {
            case let .data(data):
                return data
            case let .string(text):
                return Data(text.utf8)
            @unknown default:
                throw BinancePublicMarketDataClientError.unsupportedWebSocketPayload
            }
            #else
            throw BinancePublicMarketDataClientError.webSocketUnavailable
            #endif
        }
    }
}

/// Binance public client 错误只描述只读客户端边界内的校验、URL 构造、HTTP 状态或
/// WebSocket payload 问题；它不表达账户、订单、broker 或 Live trading 状态。
public enum BinancePublicMarketDataClientError: Error, Equatable, Sendable, CustomStringConvertible {
    case forbiddenRequest(path: String, reason: String)
    case invalidURL(path: String)
    case httpStatus(Int)
    case unsupportedWebSocketPayload
    case webSocketUnavailable
    case streamSymbolMismatch(expected: String, actual: String)

    public var description: String {
        switch self {
        case let .forbiddenRequest(path, reason):
            "Binance public client rejected request \(path): \(reason)"
        case let .invalidURL(path):
            "Binance public client could not build URL for \(path)"
        case let .httpStatus(statusCode):
            "Binance public client received unsupported HTTP status \(statusCode)"
        case .unsupportedWebSocketPayload:
            "Binance public client received unsupported WebSocket payload"
        case .webSocketUnavailable:
            "Binance public client WebSocket transport is unavailable on this platform"
        case let .streamSymbolMismatch(expected, actual):
            "Binance public client stream symbol mismatch, expected \(expected), actual \(actual)"
        }
    }
}

/// Binance public market data client 是 DataClient/Binance 目录下的只读网络边界。
/// 它复用 `BinancePublicMarketDataContract` 生成 endpoint / stream 请求路径，复用
/// `BinancePublicMarketDataPayloadDecoder` 转换 payload，并在发给 transport 前拒绝
/// mutable、requires API key、signed、account、order 和 listenKey 语义。该类型不负责
/// MTP-21 ingest 串联，不写 event log，不连接 broker，也不执行真实订单动作。
/// SwiftPM `Adapters` target 当前只是迁移期兼容壳，长期目标模块名以 DataClient 为准。
public struct BinancePublicMarketDataClient: Sendable {
    public let configuration: BinancePublicMarketDataClientConfiguration

    private let transport: any BinancePublicMarketDataTransport

    public init(
        configuration: BinancePublicMarketDataClientConfiguration = BinancePublicMarketDataClientConfiguration(),
        transport: any BinancePublicMarketDataTransport = URLSessionBinancePublicMarketDataTransport()
    ) {
        self.configuration = configuration
        self.transport = transport
    }

    /// 读取 Binance exchangeInfo public endpoint，并只返回已配置交易标的的稳定模型。
    public func exchangeInfo(symbols: [Symbol]) async throws -> BinanceExchangeInfo {
        let data = try await payload(for: .exchangeInfo(symbols: symbols))
        return try BinancePublicMarketDataPayloadDecoder.decodeExchangeInfo(from: data)
    }

    /// 读取 Binance USDⓈ-M Perpetual exchangeInfo public endpoint，并生成 perpetual instrument metadata。
    ///
    /// 该方法只消费公开合约元数据，不读取 leverage、margin action、account endpoint 或 order endpoint。
    public func usdsPerpetualExchangeInfo(symbols: [Symbol]) async throws -> [BinanceUSDMPerpetualInstrumentMetadata] {
        let data = try await payload(for: .usdsPerpetualExchangeInfo(symbols: symbols))
        return try BinancePublicMarketDataPayloadDecoder.decodeUSDMPerpetualExchangeInfo(from: data)
    }

    /// 读取 Binance kline public endpoint，并把 fixture 或真实 public payload 转成 Core `MarketBar`。
    public func klines(
        symbol: Symbol,
        timeframe: Timeframe,
        range: DateRange,
        limit: Int
    ) async throws -> [MarketBar] {
        let data = try await payload(
            for: .klines(
                symbol: symbol,
                timeframe: timeframe,
                range: range,
                limit: limit
            )
        )
        return try BinancePublicMarketDataPayloadDecoder.decodeKlines(
            from: data,
            symbol: symbol,
            timeframe: timeframe
        )
    }

    /// 读取 Binance USDⓈ-M Perpetual kline public endpoint，并输出通用 `MarketBar`。
    ///
    /// 输出仍是只读行情事件，不携带 broker position、margin action、leverage action 或交易授权。
    public func usdsPerpetualKlines(
        symbol: Symbol,
        timeframe: Timeframe,
        range: DateRange,
        limit: Int
    ) async throws -> [MarketBar] {
        let data = try await payload(
            for: .usdsPerpetualKlines(
                symbol: symbol,
                timeframe: timeframe,
                range: range,
                limit: limit
            )
        )
        return try BinancePublicMarketDataPayloadDecoder.decodeKlines(
            from: data,
            symbol: symbol,
            timeframe: timeframe
        )
    }

    /// 读取 Binance recent trades public endpoint，不读取 account trades 或 private fill。
    public func recentTrades(symbol: Symbol, limit: Int) async throws -> [TradeTick] {
        let data = try await payload(for: .recentTrades(symbol: symbol, limit: limit))
        return try BinancePublicMarketDataPayloadDecoder.decodeRecentTrades(from: data, symbol: symbol)
    }

    /// 读取 Binance best bid / ask public endpoint，并由调用方提供本地 observedAt 观察时间。
    public func bestBidAsk(symbol: Symbol, observedAt: Date) async throws -> BestBidAsk {
        let data = try await payload(for: .bestBidAsk(symbol: symbol))
        return try BinancePublicMarketDataPayloadDecoder.decodeBestBidAsk(from: data, observedAt: observedAt)
    }

    /// 读取 Binance limited depth snapshot public endpoint，只返回有限深度 read model 输入。
    public func depthSnapshot(
        symbol: Symbol,
        limit: BinanceDepthSnapshotLimit,
        observedAt: Date
    ) async throws -> OrderBookSnapshot {
        let data = try await payload(for: .depthSnapshot(symbol: symbol, limit: limit))
        return try BinancePublicMarketDataPayloadDecoder.decodeDepthSnapshot(
            from: data,
            symbol: symbol,
            observedAt: observedAt
        )
    }

    /// 读取 Binance USDⓈ-M Perpetual public depth snapshot。
    ///
    /// 该 snapshot 只进入 DataEngine / Cache read model，不表示可交易订单簿或 broker route。
    public func usdsPerpetualDepthSnapshot(
        symbol: Symbol,
        limit: BinanceDepthSnapshotLimit,
        observedAt: Date
    ) async throws -> OrderBookSnapshot {
        let data = try await payload(for: .usdsPerpetualDepthSnapshot(symbol: symbol, limit: limit))
        return try BinancePublicMarketDataPayloadDecoder.decodeDepthSnapshot(
            from: data,
            symbol: symbol,
            observedAt: observedAt
        )
    }

    /// 读取 Binance public depth stream 的单条 payload，用于验证 stream request path 和 decoder
    /// parity；该方法不创建 listenKey user data stream，也不串联 ingest 或交易执行。
    public func depthDelta(symbol: Symbol) async throws -> OrderBookDelta {
        let data = try await payload(for: .depthDelta(symbol: symbol))
        let delta = try BinancePublicMarketDataPayloadDecoder.decodeDepthDelta(from: data)
        guard delta.symbol == symbol else {
            throw BinancePublicMarketDataClientError.streamSymbolMismatch(
                expected: symbol.rawValue,
                actual: delta.symbol.rawValue
            )
        }
        return delta
    }

    /// 读取 Binance USDⓈ-M Perpetual public depth stream 的单条 payload。
    ///
    /// 该方法使用 public futures stream base，不创建 listenKey，也不连接 private user stream。
    public func usdsPerpetualDepthDelta(symbol: Symbol) async throws -> OrderBookDelta {
        let data = try await payload(for: .usdsPerpetualDepthDelta(symbol: symbol))
        let delta = try BinancePublicMarketDataPayloadDecoder.decodeDepthDelta(from: data)
        guard delta.symbol == symbol else {
            throw BinancePublicMarketDataClientError.streamSymbolMismatch(
                expected: symbol.rawValue,
                actual: delta.symbol.rawValue
            )
        }
        return delta
    }

    /// 读取 Binance USDⓈ-M Perpetual premium index public endpoint。
    ///
    /// premium index 同时提供 mark price、index price 和 funding rate evidence；它不是
    /// account margin、position、leverage 或 order command。
    public func usdsPerpetualPremiumIndex(symbol: Symbol) async throws -> BinanceUSDMPerpetualPremiumIndex {
        let data = try await payload(for: .usdsPerpetualPremiumIndex(symbol: symbol))
        return try BinancePublicMarketDataPayloadDecoder.decodeUSDMPerpetualPremiumIndex(from: data)
    }

    /// 读取 Binance USDⓈ-M Perpetual open interest public endpoint。
    ///
    /// open interest 只作为市场公开读模型输入，不代表账户持仓或 broker position sync。
    public func usdsPerpetualOpenInterest(symbol: Symbol) async throws -> BinanceUSDMPerpetualOpenInterest {
        let data = try await payload(for: .usdsPerpetualOpenInterest(symbol: symbol))
        return try BinancePublicMarketDataPayloadDecoder.decodeUSDMPerpetualOpenInterest(from: data)
    }

    /// 按 endpoint 生成只读 contract 后读取原始 payload，供测试验证 request path 与 decoder parity。
    public func payload(for endpoint: BinancePublicMarketDataEndpoint) async throws -> Data {
        try await payload(for: BinancePublicMarketDataContract.request(for: endpoint))
    }

    /// 读取已经构造好的 public request contract；发起 transport 前会重新校验 read-only、不需要
    /// API key，并拒绝 signed/account/order/listenKey 字符串进入 URL 或 query。
    public func payload(for contract: BinancePublicRequestContract) async throws -> Data {
        try validatePublicReadOnlyContract(contract)
        let request = try transportRequest(for: contract)
        return try await transport.load(request)
    }

    private func transportRequest(for contract: BinancePublicRequestContract) throws -> BinancePublicTransportRequest {
        let baseURL: URL
        switch contract.transport {
        case .restGET:
            baseURL = contract.productType == .usdsPerpetual
                ? configuration.usdsPerpetualRestBaseURL
                : configuration.restBaseURL
        case .webSocketStream:
            baseURL = contract.productType == .usdsPerpetual
                ? configuration.usdsPerpetualWebSocketBaseURL
                : configuration.webSocketBaseURL
        }

        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = contract.path.hasPrefix("/") ? contract.path : "/\(contract.path)"
        guard var components = URLComponents(string: "\(base)\(path)") else {
            throw BinancePublicMarketDataClientError.invalidURL(path: contract.path)
        }
        if contract.queryItems.isEmpty == false {
            components.queryItems = contract.queryItems.map { item in
                URLQueryItem(name: item.name, value: item.value)
            }
        }
        guard let url = components.url else {
            throw BinancePublicMarketDataClientError.invalidURL(path: contract.path)
        }
        return BinancePublicTransportRequest(
            contract: contract,
            method: "GET",
            url: url,
            headers: [:]
        )
    }

    private func validatePublicReadOnlyContract(_ contract: BinancePublicRequestContract) throws {
        guard contract.isReadOnly else {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "request is not read-only"
            )
        }
        guard contract.requiresAPIKey == false else {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "request requires API key"
            )
        }
        let publicPaths = Self.allowedPublicPaths(
            for: contract.capability,
            productType: contract.productType
        )
        guard contract.transport == publicPaths.transport else {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "transport does not match public capability"
            )
        }
        guard publicPaths.paths.contains(contract.path) else {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "path is not in Binance public allowlist"
            )
        }

        let allowedQueryItemNames = Self.allowedQueryItemNames(for: contract.capability)
        if let disallowedQueryItem = contract.queryItems.first(where: { allowedQueryItemNames.contains($0.name) == false }) {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "query item is not allowed: \(disallowedQueryItem.name)"
            )
        }

        let serializedRequest = (
            [contract.path]
                + contract.queryItems.flatMap { [$0.name, $0.value] }
        )
        .joined(separator: " ")
        .lowercased()

        if let forbiddenFragment = Self.forbiddenRequestFragments.first(where: { serializedRequest.contains($0) }) {
            throw BinancePublicMarketDataClientError.forbiddenRequest(
                path: contract.path,
                reason: "contains forbidden fragment: \(forbiddenFragment)"
            )
        }
    }

    private static let forbiddenRequestFragments = [
        "apikey",
        "signature",
        "listenkey",
        "/api/v3/account",
        "/api/v3/order",
        "/api/v3/userdatastream",
        "/fapi/v1/account",
        "/fapi/v1/order",
        "/fapi/v1/listenkey",
        "/fapi/v1/userdatastream",
        "liveexecutionadapter",
        "executionadapter",
        "broker fill",
        "broker",
        "order reconciliation",
        "realorder",
        "order submit",
        "order cancel",
        "order replace",
        "submit",
        "cancel",
        "replace",
        "execution report",
        "reconciliation",
        "oms",
        "real account state",
        "broker position sync",
        "/sapi/",
        "/dapi/"
    ]

    private static func allowedPublicPaths(
        for capability: BinancePublicMarketDataCapability,
        productType: ProductType?
    ) -> (transport: BinancePublicTransport, paths: [String]) {
        switch capability {
        case .exchangeInfo:
            switch productType {
            case .usdsPerpetual:
                (.restGET, ["/fapi/v1/exchangeInfo"])
            default:
                (.restGET, ["/api/v3/exchangeInfo", "/fapi/v1/exchangeInfo"])
            }
        case .klines:
            switch productType {
            case .usdsPerpetual:
                (.restGET, ["/fapi/v1/klines"])
            default:
                (.restGET, ["/api/v3/klines", "/fapi/v1/klines"])
            }
        case .recentTrades:
            (.restGET, ["/api/v3/trades"])
        case .bestBidAsk:
            (.restGET, ["/api/v3/ticker/bookTicker"])
        case .depthSnapshot:
            switch productType {
            case .usdsPerpetual:
                (.restGET, ["/fapi/v1/depth"])
            default:
                (.restGET, ["/api/v3/depth", "/fapi/v1/depth"])
            }
        case .depthDelta:
            (
                .webSocketStream,
                Symbol.supportedRawValues.map { symbol in
                    "/ws/\(symbol.lowercased())@depth"
                }
            )
        case .premiumIndex:
            (.restGET, ["/fapi/v1/premiumIndex"])
        case .openInterest:
            (.restGET, ["/fapi/v1/openInterest"])
        }
    }

    private static func allowedQueryItemNames(for capability: BinancePublicMarketDataCapability) -> Set<String> {
        switch capability {
        case .exchangeInfo:
            ["symbols"]
        case .klines:
            ["symbol", "interval", "startTime", "endTime", "limit"]
        case .recentTrades:
            ["symbol", "limit"]
        case .bestBidAsk:
            ["symbol"]
        case .depthSnapshot:
            ["symbol", "limit"]
        case .depthDelta:
            []
        case .premiumIndex, .openInterest:
            ["symbol"]
        }
    }
}

public enum BinancePublicMarketDataEndpoint: Equatable, Sendable {
    case exchangeInfo(symbols: [Symbol])
    case usdsPerpetualExchangeInfo(symbols: [Symbol])
    case klines(symbol: Symbol, timeframe: Timeframe, range: DateRange, limit: Int)
    case usdsPerpetualKlines(symbol: Symbol, timeframe: Timeframe, range: DateRange, limit: Int)
    case recentTrades(symbol: Symbol, limit: Int)
    case bestBidAsk(symbol: Symbol)
    case depthSnapshot(symbol: Symbol, limit: BinanceDepthSnapshotLimit)
    case usdsPerpetualDepthSnapshot(symbol: Symbol, limit: BinanceDepthSnapshotLimit)
    case depthDelta(symbol: Symbol)
    case usdsPerpetualDepthDelta(symbol: Symbol)
    case usdsPerpetualPremiumIndex(symbol: Symbol)
    case usdsPerpetualOpenInterest(symbol: Symbol)

    public var capability: BinancePublicMarketDataCapability {
        switch self {
        case .exchangeInfo, .usdsPerpetualExchangeInfo:
            .exchangeInfo
        case .klines, .usdsPerpetualKlines:
            .klines
        case .recentTrades:
            .recentTrades
        case .bestBidAsk:
            .bestBidAsk
        case .depthSnapshot, .usdsPerpetualDepthSnapshot:
            .depthSnapshot
        case .depthDelta, .usdsPerpetualDepthDelta:
            .depthDelta
        case .usdsPerpetualPremiumIndex:
            .premiumIndex
        case .usdsPerpetualOpenInterest:
            .openInterest
        }
    }
}

public enum BinancePublicMarketDataContract {
    public static let supportedSymbols = Symbol.supportedRawValues
    public static let supportedTimeframes = Timeframe.supportedRawValues
    public static let forbiddenCapabilities = BinanceForbiddenCapability.allCases

    public static func request(for endpoint: BinancePublicMarketDataEndpoint) throws -> BinancePublicRequestContract {
        switch endpoint {
        case let .exchangeInfo(symbols):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .restGET,
                path: "/api/v3/exchangeInfo",
                queryItems: [
                    BinanceQueryItem(name: "symbols", value: symbolsQueryValue(symbols))
                ]
            )

        case let .usdsPerpetualExchangeInfo(symbols):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .restGET,
                path: "/fapi/v1/exchangeInfo",
                queryItems: [
                    BinanceQueryItem(name: "symbols", value: symbolsQueryValue(symbols))
                ]
            )

        case let .klines(symbol, timeframe, range, limit):
            try validate(limit: limit, field: "klines.limit", allowedRange: 1...1_000)
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .restGET,
                path: "/api/v3/klines",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "interval", value: timeframe.rawValue),
                    BinanceQueryItem(name: "startTime", value: millisecondsString(from: range.start)),
                    BinanceQueryItem(name: "endTime", value: millisecondsString(from: range.end)),
                    BinanceQueryItem(name: "limit", value: String(limit))
                ]
            )

        case let .usdsPerpetualKlines(symbol, timeframe, range, limit):
            try validate(limit: limit, field: "usdsPerpetualKlines.limit", allowedRange: 1...1_500)
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .restGET,
                path: "/fapi/v1/klines",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "interval", value: timeframe.rawValue),
                    BinanceQueryItem(name: "startTime", value: millisecondsString(from: range.start)),
                    BinanceQueryItem(name: "endTime", value: millisecondsString(from: range.end)),
                    BinanceQueryItem(name: "limit", value: String(limit))
                ]
            )

        case let .recentTrades(symbol, limit):
            try validate(limit: limit, field: "recentTrades.limit", allowedRange: 1...1_000)
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .restGET,
                path: "/api/v3/trades",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "limit", value: String(limit))
                ]
            )

        case let .bestBidAsk(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .restGET,
                path: "/api/v3/ticker/bookTicker",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue)
                ]
            )

        case let .depthSnapshot(symbol, limit):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .restGET,
                path: "/api/v3/depth",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "limit", value: String(limit.rawValue))
                ]
            )

        case let .usdsPerpetualDepthSnapshot(symbol, limit):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .restGET,
                path: "/fapi/v1/depth",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "limit", value: String(limit.rawValue))
                ]
            )

        case let .depthDelta(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .spot,
                transport: .webSocketStream,
                path: "/ws/\(symbol.rawValue.lowercased())@depth"
            )

        case let .usdsPerpetualDepthDelta(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .webSocketStream,
                path: "/ws/\(symbol.rawValue.lowercased())@depth"
            )

        case let .usdsPerpetualPremiumIndex(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .restGET,
                path: "/fapi/v1/premiumIndex",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue)
                ]
            )

        case let .usdsPerpetualOpenInterest(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                productType: .usdsPerpetual,
                transport: .restGET,
                path: "/fapi/v1/openInterest",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue)
                ]
            )
        }
    }

    private static func validate(limit: Int, field: String, allowedRange: ClosedRange<Int>) throws {
        guard allowedRange.contains(limit) else {
            throw BinancePublicMarketDataContractError.invalidLimit(
                field: field,
                value: limit,
                allowedRange: "\(allowedRange.lowerBound)...\(allowedRange.upperBound)"
            )
        }
    }

    private static func millisecondsString(from date: Date) -> String {
        String(Int64((date.timeIntervalSince1970 * 1_000).rounded()))
    }

    private static func symbolsQueryValue(_ symbols: [Symbol]) -> String {
        let values = symbols.map { #""\#($0.rawValue)""# }.joined(separator: ",")
        return "[\(values)]"
    }
}

public struct BinanceExchangeInfo: Equatable, Sendable {
    public let symbols: [Symbol]

    public init(symbols: [Symbol]) {
        self.symbols = symbols
    }
}

/// BinanceUSDMPerpetualInstrumentMetadata 是 USDⓈ-M perpetual public exchangeInfo 的本地 read model。
///
/// 它只保存公开合约元数据和 `PerpetualContract`，不包含 leverage action、margin action、
/// account position、broker position sync 或 order command。
public struct BinanceUSDMPerpetualInstrumentMetadata: Equatable, Sendable {
    public let contract: PerpetualContract
    public let status: String
    public let contractType: String
    public let pricePrecision: Int
    public let quantityPrecision: Int

    public init(
        contract: PerpetualContract,
        status: String,
        contractType: String,
        pricePrecision: Int,
        quantityPrecision: Int
    ) {
        self.contract = contract
        self.status = status
        self.contractType = contractType
        self.pricePrecision = pricePrecision
        self.quantityPrecision = quantityPrecision
    }

    public var instrument: InstrumentIdentity {
        contract.instrument
    }
}

/// BinanceUSDMPerpetualPremiumIndex 保存 mark price、index price 与 funding evidence。
///
/// 这些字段来自 public premium index endpoint，只能作为行情 read model input，不是账户保证金、
/// funding debit/credit、position 或可执行订单状态。
public struct BinanceUSDMPerpetualPremiumIndex: Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let markPrice: Price
    public let indexPrice: Price
    public let lastFundingRate: Double
    public let nextFundingTime: Date
    public let observedAt: Date

    public init(
        instrument: InstrumentIdentity,
        markPrice: Double,
        indexPrice: Double,
        lastFundingRate: Double,
        nextFundingTime: Date,
        observedAt: Date
    ) throws {
        guard lastFundingRate.isFinite else {
            throw BinancePublicMarketDataContractError.invalidNumericField(
                field: "premiumIndex.lastFundingRate",
                value: "\(lastFundingRate)"
            )
        }
        self.instrument = instrument
        self.markPrice = try Price(markPrice, field: "premiumIndex.markPrice")
        self.indexPrice = try Price(indexPrice, field: "premiumIndex.indexPrice")
        self.lastFundingRate = lastFundingRate
        self.nextFundingTime = nextFundingTime
        self.observedAt = observedAt
    }
}

/// BinanceUSDMPerpetualOpenInterest 保存 public open interest evidence。
///
/// open interest 是市场级公开读模型输入，不等于账户仓位、broker 持仓同步或 reconciliation。
public struct BinanceUSDMPerpetualOpenInterest: Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let openInterest: Quantity
    public let observedAt: Date

    public init(
        instrument: InstrumentIdentity,
        openInterest: Double,
        observedAt: Date
    ) throws {
        self.instrument = instrument
        self.openInterest = try Quantity(openInterest, field: "openInterest")
        self.observedAt = observedAt
    }
}

public enum BinancePublicMarketDataPayloadDecoder {
    public static func decodeExchangeInfo(from data: Data) throws -> BinanceExchangeInfo {
        let payload = try JSONDecoder().decode(BinanceExchangeInfoPayload.self, from: data)
        let symbols = payload.symbols.compactMap { symbol -> Symbol? in
            guard symbol.status == "TRADING" else {
                return nil
            }
            return try? Symbol(rawValue: symbol.symbol)
        }
        return BinanceExchangeInfo(symbols: symbols)
    }

    public static func decodeUSDMPerpetualExchangeInfo(
        from data: Data
    ) throws -> [BinanceUSDMPerpetualInstrumentMetadata] {
        let payload = try JSONDecoder().decode(BinanceUSDMPerpetualExchangeInfoPayload.self, from: data)
        return try payload.symbols.compactMap { symbol -> BinanceUSDMPerpetualInstrumentMetadata? in
            guard symbol.status == "TRADING", symbol.contractType == "PERPETUAL" else {
                return nil
            }
            let instrument = InstrumentIdentity.binance(
                productType: .usdsPerpetual,
                symbol: try Symbol(rawValue: symbol.symbol)
            )
            let contract = try PerpetualContract(
                instrument: instrument,
                marginAsset: try Identifier(symbol.marginAsset, field: "usdsPerpetual.marginAsset"),
                settlementAsset: try Identifier(symbol.quoteAsset, field: "usdsPerpetual.settlementAsset"),
                contractSize: 1,
                fundingIntervalHours: 8
            )
            return BinanceUSDMPerpetualInstrumentMetadata(
                contract: contract,
                status: symbol.status,
                contractType: symbol.contractType,
                pricePrecision: symbol.pricePrecision,
                quantityPrecision: symbol.quantityPrecision
            )
        }
    }

    public static func decodeKlines(
        from data: Data,
        symbol: Symbol,
        timeframe: Timeframe
    ) throws -> [MarketBar] {
        let rows = try JSONDecoder().decode([BinanceKlineRow].self, from: data)
        return try rows.map { row in
            try MarketBar(
                symbol: symbol,
                timeframe: timeframe,
                interval: try DateRange(
                    start: dateFromMilliseconds(row.openTime),
                    end: dateFromMilliseconds(row.closeTime + 1)
                ),
                open: try decimal(row.open, field: "kline.open"),
                high: try decimal(row.high, field: "kline.high"),
                low: try decimal(row.low, field: "kline.low"),
                close: try decimal(row.close, field: "kline.close"),
                volume: try decimal(row.volume, field: "kline.volume")
            )
        }
    }

    public static func decodeRecentTrades(from data: Data, symbol: Symbol) throws -> [TradeTick] {
        let payloads = try JSONDecoder().decode([BinanceRecentTradePayload].self, from: data)
        return try payloads.map { payload in
            try TradeTick(
                symbol: symbol,
                tradedAt: dateFromMilliseconds(payload.time),
                price: try decimal(payload.price, field: "trade.price"),
                quantity: try decimal(payload.quantity, field: "trade.quantity"),
                makerSide: payload.isBuyerMaker ? .bid : .ask
            )
        }
    }

    public static func decodeBestBidAsk(from data: Data, observedAt: Date) throws -> BestBidAsk {
        let payload = try JSONDecoder().decode(BinanceBookTickerPayload.self, from: data)
        return try BestBidAsk(
            symbol: Symbol(rawValue: payload.symbol),
            observedAt: observedAt,
            bid: try OrderBookLevel(
                price: try decimal(payload.bidPrice, field: "bookTicker.bidPrice"),
                quantity: try decimal(payload.bidQuantity, field: "bookTicker.bidQty")
            ),
            ask: try OrderBookLevel(
                price: try decimal(payload.askPrice, field: "bookTicker.askPrice"),
                quantity: try decimal(payload.askQuantity, field: "bookTicker.askQty")
            )
        )
    }

    public static func decodeDepthSnapshot(from data: Data, symbol: Symbol, observedAt: Date) throws -> OrderBookSnapshot {
        let payload = try JSONDecoder().decode(BinanceDepthSnapshotPayload.self, from: data)
        return try OrderBookSnapshot(
            symbol: symbol,
            observedAt: observedAt,
            bids: payload.bids.map { try $0.toCoreLevel(fieldPrefix: "depthSnapshot.bid") },
            asks: payload.asks.map { try $0.toCoreLevel(fieldPrefix: "depthSnapshot.ask") }
        )
    }

    public static func decodeDepthDelta(from data: Data) throws -> OrderBookDelta {
        let payload = try JSONDecoder().decode(BinanceDepthDeltaPayload.self, from: data)
        return try OrderBookDelta(
            symbol: Symbol(rawValue: payload.symbol),
            observedAt: dateFromMilliseconds(payload.eventTime),
            bidUpdates: payload.bidUpdates.map { try $0.toCoreLevel(fieldPrefix: "depthDelta.bid") },
            askUpdates: payload.askUpdates.map { try $0.toCoreLevel(fieldPrefix: "depthDelta.ask") }
        )
    }

    public static func decodeUSDMPerpetualPremiumIndex(
        from data: Data
    ) throws -> BinanceUSDMPerpetualPremiumIndex {
        let payload = try JSONDecoder().decode(BinanceUSDMPerpetualPremiumIndexPayload.self, from: data)
        let instrument = InstrumentIdentity.binance(
            productType: .usdsPerpetual,
            symbol: try Symbol(rawValue: payload.symbol)
        )
        return try BinanceUSDMPerpetualPremiumIndex(
            instrument: instrument,
            markPrice: decimal(payload.markPrice, field: "premiumIndex.markPrice"),
            indexPrice: decimal(payload.indexPrice, field: "premiumIndex.indexPrice"),
            lastFundingRate: decimal(payload.lastFundingRate, field: "premiumIndex.lastFundingRate"),
            nextFundingTime: dateFromMilliseconds(payload.nextFundingTime),
            observedAt: dateFromMilliseconds(payload.time)
        )
    }

    public static func decodeUSDMPerpetualOpenInterest(
        from data: Data
    ) throws -> BinanceUSDMPerpetualOpenInterest {
        let payload = try JSONDecoder().decode(BinanceUSDMPerpetualOpenInterestPayload.self, from: data)
        let instrument = InstrumentIdentity.binance(
            productType: .usdsPerpetual,
            symbol: try Symbol(rawValue: payload.symbol)
        )
        return try BinanceUSDMPerpetualOpenInterest(
            instrument: instrument,
            openInterest: decimal(payload.openInterest, field: "openInterest"),
            observedAt: dateFromMilliseconds(payload.time)
        )
    }

    private static func dateFromMilliseconds(_ milliseconds: Int64) -> Date {
        Date(timeIntervalSince1970: Double(milliseconds) / 1_000)
    }

    fileprivate static func decimal(_ value: String, field: String) throws -> Double {
        guard let decimal = Double(value), decimal.isFinite else {
            throw BinancePublicMarketDataContractError.invalidNumericField(field: field, value: value)
        }
        return decimal
    }
}

public struct BinanceReadOnlyAdapterBoundary: Equatable, Sendable {
    public let sourceName: String
    public let allowedCapabilities: [String]
    public let forbiddenCapabilities: [String]
    public let supportedSymbols: [String]
    public let supportedTimeframes: [String]
    public let isReadOnly: Bool
    public let requiresAPIKey: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let connectsBrokerExecutionAdapter: Bool
    public let connectsExchangeExecutionAdapter: Bool
    public let exposesExecutionVenueConnection: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let implementsOMS: Bool
    public let readsRealAccountState: Bool
    public let syncsBrokerPosition: Bool

    public init() {
        self.sourceName = "Binance public market data"
        self.allowedCapabilities = BinancePublicMarketDataCapability.allCases.map(\.rawValue)
        self.forbiddenCapabilities = BinanceForbiddenCapability.allCases.map(\.rawValue)
        self.supportedSymbols = BinancePublicMarketDataContract.supportedSymbols
        self.supportedTimeframes = BinancePublicMarketDataContract.supportedTimeframes
        self.isReadOnly = true
        self.requiresAPIKey = false
        self.usesSignedEndpoint = false
        self.callsAccountEndpoint = false
        self.createsListenKey = false
        self.implementsLiveExecutionAdapter = false
        self.connectsBrokerExecutionAdapter = false
        self.connectsExchangeExecutionAdapter = false
        self.exposesExecutionVenueConnection = false
        self.submitsRealOrder = false
        self.cancelsRealOrder = false
        self.replacesRealOrder = false
        self.consumesExecutionReport = false
        self.recordsBrokerFill = false
        self.performsReconciliation = false
        self.implementsOMS = false
        self.readsRealAccountState = false
        self.syncsBrokerPosition = false
    }

    /// MTP-63 / MTP-64 adapter capability isolation 证明当前 Binance adapter 仍只是公开行情读取边界。
    /// 该 summary 不创建 future live adapter，不连接 broker / exchange execution venue，
    /// 也不提供 submit / cancel / replace、execution report、broker fill、reconciliation
    /// 或 OMS 等真实订单生命周期能力。
    public var adapterCapabilityIsolationHeld: Bool {
        isReadOnly
            && requiresAPIKey == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && implementsLiveExecutionAdapter == false
            && connectsBrokerExecutionAdapter == false
            && connectsExchangeExecutionAdapter == false
            && exposesExecutionVenueConnection == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && implementsOMS == false
            && readsRealAccountState == false
            && syncsBrokerPosition == false
    }

    public func forbidsCapability(_ capability: BinanceForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability.rawValue)
    }
}

private struct BinanceExchangeInfoPayload: Decodable {
    let symbols: [Symbol]

    struct Symbol: Decodable {
        let symbol: String
        let status: String
    }
}

private struct BinanceUSDMPerpetualExchangeInfoPayload: Decodable {
    let symbols: [Symbol]

    struct Symbol: Decodable {
        let symbol: String
        let status: String
        let contractType: String
        let marginAsset: String
        let quoteAsset: String
        let pricePrecision: Int
        let quantityPrecision: Int
    }
}

private struct BinanceKlineRow: Decodable {
    let openTime: Int64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    let closeTime: Int64

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.openTime = try container.decode(Int64.self)
        self.open = try container.decode(String.self)
        self.high = try container.decode(String.self)
        self.low = try container.decode(String.self)
        self.close = try container.decode(String.self)
        self.volume = try container.decode(String.self)
        self.closeTime = try container.decode(Int64.self)
    }
}

private struct BinanceRecentTradePayload: Decodable {
    let price: String
    let quantity: String
    let time: Int64
    let isBuyerMaker: Bool

    private enum CodingKeys: String, CodingKey {
        case price
        case quantity = "qty"
        case time
        case isBuyerMaker
    }
}

private struct BinanceBookTickerPayload: Decodable {
    let symbol: String
    let bidPrice: String
    let bidQuantity: String
    let askPrice: String
    let askQuantity: String

    private enum CodingKeys: String, CodingKey {
        case symbol
        case bidPrice
        case bidQuantity = "bidQty"
        case askPrice
        case askQuantity = "askQty"
    }
}

private struct BinanceDepthSnapshotPayload: Decodable {
    let bids: [BinanceDepthLevelPayload]
    let asks: [BinanceDepthLevelPayload]
}

private struct BinanceDepthDeltaPayload: Decodable {
    let eventTime: Int64
    let symbol: String
    let bidUpdates: [BinanceDepthLevelPayload]
    let askUpdates: [BinanceDepthLevelPayload]

    private enum CodingKeys: String, CodingKey {
        case eventTime = "E"
        case symbol = "s"
        case bidUpdates = "b"
        case askUpdates = "a"
    }
}

private struct BinanceUSDMPerpetualPremiumIndexPayload: Decodable {
    let symbol: String
    let markPrice: String
    let indexPrice: String
    let lastFundingRate: String
    let nextFundingTime: Int64
    let time: Int64
}

private struct BinanceUSDMPerpetualOpenInterestPayload: Decodable {
    let symbol: String
    let openInterest: String
    let time: Int64
}

private struct BinanceDepthLevelPayload: Decodable {
    let price: String
    let quantity: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.price = try container.decode(String.self)
        self.quantity = try container.decode(String.self)
    }

    func toCoreLevel(fieldPrefix: String) throws -> OrderBookLevel {
        try OrderBookLevel(
            price: try BinancePublicMarketDataPayloadDecoder.decimal(price, field: "\(fieldPrefix).price"),
            quantity: try BinancePublicMarketDataPayloadDecoder.decimal(quantity, field: "\(fieldPrefix).quantity")
        )
    }
}
