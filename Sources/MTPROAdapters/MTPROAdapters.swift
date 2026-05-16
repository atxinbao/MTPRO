import Foundation
import MTPROCore

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
}

public enum BinanceForbiddenCapability: String, CaseIterable, Codable, Equatable, Sendable {
    case apiKey = "API key"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case orderSubmit = "order submit"
    case orderCancel = "order cancel"
    case orderReplace = "order replace"
    case listenKeyUserDataStream = "listenKey user data stream"
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
    public let transport: BinancePublicTransport
    public let path: String
    public let queryItems: [BinanceQueryItem]
    public let isReadOnly: Bool
    public let requiresAPIKey: Bool

    public init(
        capability: BinancePublicMarketDataCapability,
        transport: BinancePublicTransport,
        path: String,
        queryItems: [BinanceQueryItem] = [],
        isReadOnly: Bool = true,
        requiresAPIKey: Bool = false
    ) {
        self.capability = capability
        self.transport = transport
        self.path = path
        self.queryItems = queryItems
        self.isReadOnly = isReadOnly
        self.requiresAPIKey = requiresAPIKey
    }
}

public enum BinancePublicMarketDataEndpoint: Equatable, Sendable {
    case exchangeInfo(symbols: [MTPROSymbol])
    case klines(symbol: MTPROSymbol, timeframe: MTPROTimeframe, range: MTPRODateRange, limit: Int)
    case recentTrades(symbol: MTPROSymbol, limit: Int)
    case bestBidAsk(symbol: MTPROSymbol)
    case depthSnapshot(symbol: MTPROSymbol, limit: BinanceDepthSnapshotLimit)
    case depthDelta(symbol: MTPROSymbol)

    public var capability: BinancePublicMarketDataCapability {
        switch self {
        case .exchangeInfo:
            .exchangeInfo
        case .klines:
            .klines
        case .recentTrades:
            .recentTrades
        case .bestBidAsk:
            .bestBidAsk
        case .depthSnapshot:
            .depthSnapshot
        case .depthDelta:
            .depthDelta
        }
    }
}

public enum BinancePublicMarketDataContract {
    public static let supportedSymbols = MTPROSymbol.supportedRawValues
    public static let supportedTimeframes = MTPROTimeframe.supportedRawValues
    public static let forbiddenCapabilities = BinanceForbiddenCapability.allCases

    public static func request(for endpoint: BinancePublicMarketDataEndpoint) throws -> BinancePublicRequestContract {
        switch endpoint {
        case let .exchangeInfo(symbols):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                transport: .restGET,
                path: "/api/v3/exchangeInfo",
                queryItems: [
                    BinanceQueryItem(name: "symbols", value: symbolsQueryValue(symbols))
                ]
            )

        case let .klines(symbol, timeframe, range, limit):
            try validate(limit: limit, field: "klines.limit", allowedRange: 1...1_000)
            return BinancePublicRequestContract(
                capability: endpoint.capability,
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

        case let .recentTrades(symbol, limit):
            try validate(limit: limit, field: "recentTrades.limit", allowedRange: 1...1_000)
            return BinancePublicRequestContract(
                capability: endpoint.capability,
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
                transport: .restGET,
                path: "/api/v3/ticker/bookTicker",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue)
                ]
            )

        case let .depthSnapshot(symbol, limit):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                transport: .restGET,
                path: "/api/v3/depth",
                queryItems: [
                    BinanceQueryItem(name: "symbol", value: symbol.rawValue),
                    BinanceQueryItem(name: "limit", value: String(limit.rawValue))
                ]
            )

        case let .depthDelta(symbol):
            return BinancePublicRequestContract(
                capability: endpoint.capability,
                transport: .webSocketStream,
                path: "/ws/\(symbol.rawValue.lowercased())@depth"
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

    private static func symbolsQueryValue(_ symbols: [MTPROSymbol]) -> String {
        let values = symbols.map { #""\#($0.rawValue)""# }.joined(separator: ",")
        return "[\(values)]"
    }
}

public struct BinanceExchangeInfo: Equatable, Sendable {
    public let symbols: [MTPROSymbol]

    public init(symbols: [MTPROSymbol]) {
        self.symbols = symbols
    }
}

public enum BinancePublicMarketDataPayloadDecoder {
    public static func decodeExchangeInfo(from data: Data) throws -> BinanceExchangeInfo {
        let payload = try JSONDecoder().decode(BinanceExchangeInfoPayload.self, from: data)
        let symbols = payload.symbols.compactMap { symbol -> MTPROSymbol? in
            guard symbol.status == "TRADING" else {
                return nil
            }
            return try? MTPROSymbol(rawValue: symbol.symbol)
        }
        return BinanceExchangeInfo(symbols: symbols)
    }

    public static func decodeKlines(
        from data: Data,
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe
    ) throws -> [MTPROMarketBar] {
        let rows = try JSONDecoder().decode([BinanceKlineRow].self, from: data)
        return try rows.map { row in
            try MTPROMarketBar(
                symbol: symbol,
                timeframe: timeframe,
                interval: try MTPRODateRange(
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

    public static func decodeRecentTrades(from data: Data, symbol: MTPROSymbol) throws -> [MTPROTradeTick] {
        let payloads = try JSONDecoder().decode([BinanceRecentTradePayload].self, from: data)
        return try payloads.map { payload in
            try MTPROTradeTick(
                symbol: symbol,
                tradedAt: dateFromMilliseconds(payload.time),
                price: try decimal(payload.price, field: "trade.price"),
                quantity: try decimal(payload.quantity, field: "trade.quantity"),
                makerSide: payload.isBuyerMaker ? .bid : .ask
            )
        }
    }

    public static func decodeBestBidAsk(from data: Data, observedAt: Date) throws -> MTPROBestBidAsk {
        let payload = try JSONDecoder().decode(BinanceBookTickerPayload.self, from: data)
        return try MTPROBestBidAsk(
            symbol: MTPROSymbol(rawValue: payload.symbol),
            observedAt: observedAt,
            bid: try MTPROOrderBookLevel(
                price: try decimal(payload.bidPrice, field: "bookTicker.bidPrice"),
                quantity: try decimal(payload.bidQuantity, field: "bookTicker.bidQty")
            ),
            ask: try MTPROOrderBookLevel(
                price: try decimal(payload.askPrice, field: "bookTicker.askPrice"),
                quantity: try decimal(payload.askQuantity, field: "bookTicker.askQty")
            )
        )
    }

    public static func decodeDepthSnapshot(from data: Data, symbol: MTPROSymbol, observedAt: Date) throws -> MTPROOrderBookSnapshot {
        let payload = try JSONDecoder().decode(BinanceDepthSnapshotPayload.self, from: data)
        return try MTPROOrderBookSnapshot(
            symbol: symbol,
            observedAt: observedAt,
            bids: payload.bids.map { try $0.toCoreLevel(fieldPrefix: "depthSnapshot.bid") },
            asks: payload.asks.map { try $0.toCoreLevel(fieldPrefix: "depthSnapshot.ask") }
        )
    }

    public static func decodeDepthDelta(from data: Data) throws -> MTPROOrderBookDelta {
        let payload = try JSONDecoder().decode(BinanceDepthDeltaPayload.self, from: data)
        return try MTPROOrderBookDelta(
            symbol: MTPROSymbol(rawValue: payload.symbol),
            observedAt: dateFromMilliseconds(payload.eventTime),
            bidUpdates: payload.bidUpdates.map { try $0.toCoreLevel(fieldPrefix: "depthDelta.bid") },
            askUpdates: payload.askUpdates.map { try $0.toCoreLevel(fieldPrefix: "depthDelta.ask") }
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

    public init() {
        self.sourceName = "Binance public market data"
        self.allowedCapabilities = BinancePublicMarketDataCapability.allCases.map(\.rawValue)
        self.forbiddenCapabilities = BinanceForbiddenCapability.allCases.map(\.rawValue)
        self.supportedSymbols = BinancePublicMarketDataContract.supportedSymbols
        self.supportedTimeframes = BinancePublicMarketDataContract.supportedTimeframes
    }
}

private struct BinanceExchangeInfoPayload: Decodable {
    let symbols: [Symbol]

    struct Symbol: Decodable {
        let symbol: String
        let status: String
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

private struct BinanceDepthLevelPayload: Decodable {
    let price: String
    let quantity: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.price = try container.decode(String.self)
        self.quantity = try container.decode(String.self)
    }

    func toCoreLevel(fieldPrefix: String) throws -> MTPROOrderBookLevel {
        try MTPROOrderBookLevel(
            price: try BinancePublicMarketDataPayloadDecoder.decimal(price, field: "\(fieldPrefix).price"),
            quantity: try BinancePublicMarketDataPayloadDecoder.decimal(quantity, field: "\(fieldPrefix).quantity")
        )
    }
}
