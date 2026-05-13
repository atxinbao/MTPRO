import Foundation
import MTPROCore

public struct BinanceReadOnlyAdapterBoundary: Equatable, Sendable {
    public let sourceName: String
    public let allowedCapabilities: [String]
    public let forbiddenCapabilities: [String]

    public init() {
        self.sourceName = "Binance public market data"
        self.allowedCapabilities = [
            "exchangeInfo",
            "klines",
            "trades",
            "bookTicker",
            "depth snapshot",
            "depth delta"
        ]
        self.forbiddenCapabilities = [
            "API key",
            "signed endpoint",
            "account endpoint",
            "order submit",
            "order cancel",
            "order replace",
            "listenKey user data stream"
        ]
    }
}
