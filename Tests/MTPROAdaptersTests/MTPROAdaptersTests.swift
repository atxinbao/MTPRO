import MTPROAdapters
import MTPROCore
import XCTest

final class MTPROAdaptersTests: XCTestCase {
    func testBinanceBoundaryIsReadOnlyAndMatchesConfiguredUniverse() {
        let boundary = BinanceReadOnlyAdapterBoundary()

        XCTAssertTrue(boundary.allowedCapabilities.contains("klines"))
        XCTAssertTrue(boundary.allowedCapabilities.contains("depth delta"))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains("order submit"))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains("API key"))
        XCTAssertEqual(boundary.supportedSymbols, ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"])
        XCTAssertEqual(boundary.supportedTimeframes, ["1m", "5m"])
    }

    func testPublicRequestContractsUseReadOnlyPublicEndpointsOnly() throws {
        let symbol = try MTPROSymbol(rawValue: "BTCUSDT")
        let range = try MTPRODateRange(
            start: Date(timeIntervalSince1970: 1_704_067_200),
            end: Date(timeIntervalSince1970: 1_704_067_260)
        )
        let endpoints: [BinancePublicMarketDataEndpoint] = [
            .exchangeInfo(symbols: [symbol]),
            .klines(symbol: symbol, timeframe: .oneMinute, range: range, limit: 500),
            .recentTrades(symbol: symbol, limit: 100),
            .bestBidAsk(symbol: symbol),
            .depthSnapshot(symbol: symbol, limit: .oneHundred),
            .depthDelta(symbol: symbol)
        ]

        let contracts = try endpoints.map(BinancePublicMarketDataContract.request(for:))

        XCTAssertEqual(contracts.map(\.capability), BinancePublicMarketDataCapability.allCases)
        XCTAssertTrue(contracts.allSatisfy(\.isReadOnly))
        XCTAssertFalse(contracts.contains(where: \.requiresAPIKey))
        XCTAssertEqual(contracts.first?.path, "/api/v3/exchangeInfo")
        XCTAssertEqual(contracts.last?.transport, .webSocketStream)
        XCTAssertEqual(contracts.last?.path, "/ws/btcusdt@depth")

        let serializedContracts = contracts
            .flatMap { [$0.path] + $0.queryItems.flatMap { [$0.name, $0.value] } }
            .joined(separator: " ")
            .lowercased()

        XCTAssertFalse(serializedContracts.contains("apikey"))
        XCTAssertFalse(serializedContracts.contains("signature"))
        XCTAssertFalse(serializedContracts.contains("listenkey"))
        XCTAssertFalse(serializedContracts.contains("/api/v3/order"))
        XCTAssertFalse(serializedContracts.contains("/api/v3/account"))
    }

    func testPublicRequestContractRejectsInvalidRecordLimits() throws {
        let symbol = try MTPROSymbol(rawValue: "ETHUSDT")
        let range = try MTPRODateRange(
            start: Date(timeIntervalSince1970: 1_704_067_200),
            end: Date(timeIntervalSince1970: 1_704_067_260)
        )

        XCTAssertThrowsError(
            try BinancePublicMarketDataContract.request(
                for: .klines(symbol: symbol, timeframe: .oneMinute, range: range, limit: 0)
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataContractError,
                .invalidLimit(field: "klines.limit", value: 0, allowedRange: "1...1000")
            )
        }

        XCTAssertThrowsError(
            try BinancePublicMarketDataContract.request(
                for: .recentTrades(symbol: symbol, limit: 1_001)
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataContractError,
                .invalidLimit(field: "recentTrades.limit", value: 1_001, allowedRange: "1...1000")
            )
        }
    }

    func testExchangeInfoFixtureKeepsOnlyConfiguredTradingSymbols() throws {
        let payload = Data(
            #"""
            {
              "symbols": [
                { "symbol": "BTCUSDT", "status": "TRADING" },
                { "symbol": "DOGEUSDT", "status": "TRADING" },
                { "symbol": "ETHUSDT", "status": "BREAK" },
                { "symbol": "SOLUSDT", "status": "TRADING" }
              ]
            }
            """#.utf8
        )

        let exchangeInfo = try BinancePublicMarketDataPayloadDecoder.decodeExchangeInfo(from: payload)

        XCTAssertEqual(exchangeInfo.symbols.map(\.rawValue), ["BTCUSDT", "SOLUSDT"])
    }

    func testKlineFixtureDecodesIntoCoreMarketBars() throws {
        let payload = Data(
            #"""
            [
              [
                1704067200000,
                "42000.10",
                "42100.20",
                "41900.30",
                "42050.40",
                "12.345",
                1704067259999,
                "519000.00",
                120,
                "6.000",
                "252000.00",
                "0"
              ]
            ]
            """#.utf8
        )

        let bars = try BinancePublicMarketDataPayloadDecoder.decodeKlines(
            from: payload,
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute
        )

        XCTAssertEqual(bars.count, 1)
        XCTAssertEqual(bars[0].symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(bars[0].timeframe, .oneMinute)
        XCTAssertEqual(bars[0].open.rawValue, 42_000.10)
        XCTAssertEqual(bars[0].high.rawValue, 42_100.20)
        XCTAssertEqual(bars[0].low.rawValue, 41_900.30)
        XCTAssertEqual(bars[0].close.rawValue, 42_050.40)
        XCTAssertEqual(bars[0].volume.rawValue, 12.345)
        XCTAssertEqual(bars[0].interval.start.timeIntervalSince1970, 1_704_067_200, accuracy: 0.0001)
        XCTAssertEqual(bars[0].interval.end.timeIntervalSince1970, 1_704_067_260, accuracy: 0.0001)
    }

    func testRecentTradeAndBookTickerFixturesDecodeIntoCoreMarketEvents() throws {
        let tradesPayload = Data(
            #"""
            [
              {
                "id": 1,
                "price": "42010.50",
                "qty": "0.125",
                "time": 1704067201000,
                "isBuyerMaker": true,
                "isBestMatch": true
              }
            ]
            """#.utf8
        )
        let bookTickerPayload = Data(
            #"""
            {
              "symbol": "ETHUSDT",
              "bidPrice": "2300.10",
              "bidQty": "2.500",
              "askPrice": "2300.20",
              "askQty": "1.750"
            }
            """#.utf8
        )

        let trades = try BinancePublicMarketDataPayloadDecoder.decodeRecentTrades(
            from: tradesPayload,
            symbol: try MTPROSymbol(rawValue: "BTCUSDT")
        )
        let bestBidAsk = try BinancePublicMarketDataPayloadDecoder.decodeBestBidAsk(
            from: bookTickerPayload,
            observedAt: Date(timeIntervalSince1970: 1_704_067_202)
        )

        XCTAssertEqual(trades.count, 1)
        XCTAssertEqual(trades[0].symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(trades[0].makerSide, .bid)
        XCTAssertEqual(trades[0].price.rawValue, 42_010.50)
        XCTAssertEqual(trades[0].quantity.rawValue, 0.125)
        XCTAssertEqual(trades[0].tradedAt.timeIntervalSince1970, 1_704_067_201, accuracy: 0.0001)

        XCTAssertEqual(bestBidAsk.symbol.rawValue, "ETHUSDT")
        XCTAssertEqual(bestBidAsk.bid.price.rawValue, 2_300.10)
        XCTAssertEqual(bestBidAsk.bid.quantity.rawValue, 2.5)
        XCTAssertEqual(bestBidAsk.ask.price.rawValue, 2_300.20)
        XCTAssertEqual(bestBidAsk.ask.quantity.rawValue, 1.75)
        XCTAssertEqual(bestBidAsk.observedAt.timeIntervalSince1970, 1_704_067_202, accuracy: 0.0001)
    }

    func testDepthSnapshotAndDepthDeltaFixturesDecodeIntoCoreOrderBookEvents() throws {
        let snapshotPayload = Data(
            #"""
            {
              "lastUpdateId": 100,
              "bids": [["42000.00", "1.100"], ["41999.50", "0.800"]],
              "asks": [["42001.00", "0.900"], ["42002.00", "1.250"]]
            }
            """#.utf8
        )
        let deltaPayload = Data(
            #"""
            {
              "e": "depthUpdate",
              "E": 1704067203000,
              "s": "BNBUSDT",
              "U": 101,
              "u": 102,
              "b": [["310.10", "4.000"]],
              "a": [["310.30", "0.000"]]
            }
            """#.utf8
        )

        let snapshot = try BinancePublicMarketDataPayloadDecoder.decodeDepthSnapshot(
            from: snapshotPayload,
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 1_704_067_204)
        )
        let delta = try BinancePublicMarketDataPayloadDecoder.decodeDepthDelta(from: deltaPayload)

        XCTAssertEqual(snapshot.symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(snapshot.bids.map(\.price.rawValue), [42_000.00, 41_999.50])
        XCTAssertEqual(snapshot.asks.map(\.quantity.rawValue), [0.9, 1.25])
        XCTAssertEqual(snapshot.observedAt.timeIntervalSince1970, 1_704_067_204, accuracy: 0.0001)

        XCTAssertEqual(delta.symbol.rawValue, "BNBUSDT")
        XCTAssertEqual(delta.bidUpdates[0].price.rawValue, 310.10)
        XCTAssertEqual(delta.bidUpdates[0].quantity.rawValue, 4.0)
        XCTAssertEqual(delta.askUpdates[0].price.rawValue, 310.30)
        XCTAssertEqual(delta.askUpdates[0].quantity.rawValue, 0.0)
        XCTAssertEqual(delta.observedAt.timeIntervalSince1970, 1_704_067_203, accuracy: 0.0001)
    }

    func testFixtureDecodingRejectsUnsupportedSymbolsAndInvalidNumbers() {
        let unsupportedBookTicker = Data(
            #"""
            {
              "symbol": "DOGEUSDT",
              "bidPrice": "0.10",
              "bidQty": "1.0",
              "askPrice": "0.11",
              "askQty": "1.0"
            }
            """#.utf8
        )
        let invalidKline = Data(
            #"""
            [
              [
                1704067200000,
                "not-a-number",
                "42100.20",
                "41900.30",
                "42050.40",
                "12.345",
                1704067259999
              ]
            ]
            """#.utf8
        )

        XCTAssertThrowsError(
            try BinancePublicMarketDataPayloadDecoder.decodeBestBidAsk(
                from: unsupportedBookTicker,
                observedAt: Date(timeIntervalSince1970: 1_704_067_202)
            )
        ) { error in
            XCTAssertEqual(error as? MTPROCoreError, .unsupportedSymbol("DOGEUSDT"))
        }

        XCTAssertThrowsError(
            try BinancePublicMarketDataPayloadDecoder.decodeKlines(
                from: invalidKline,
                symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataContractError,
                .invalidNumericField(field: "kline.open", value: "not-a-number")
            )
        }
    }
}
