import Adapters
import Core
import XCTest

final class AdaptersTests: XCTestCase {
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
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let range = try DateRange(
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
        let symbol = try Symbol(rawValue: "ETHUSDT")
        let range = try DateRange(
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
            symbol: try Symbol(rawValue: "BTCUSDT"),
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
            symbol: try Symbol(rawValue: "BTCUSDT")
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
            symbol: try Symbol(rawValue: "BTCUSDT"),
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
            XCTAssertEqual(error as? CoreError, .unsupportedSymbol("DOGEUSDT"))
        }

        XCTAssertThrowsError(
            try BinancePublicMarketDataPayloadDecoder.decodeKlines(
                from: invalidKline,
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataContractError,
                .invalidNumericField(field: "kline.open", value: "not-a-number")
            )
        }
    }

    func testPublicClientUsesMockTransportWithoutAPIKeyOrSignedEndpoint() async throws {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let transport = MockBinancePublicMarketDataTransport { request in
            XCTAssertEqual(request.contract.capability, .exchangeInfo)
            XCTAssertEqual(request.method, "GET")
            XCTAssertTrue(request.headers.isEmpty)
            XCTAssertEqual(request.contract.path, "/api/v3/exchangeInfo")
            return Self.exchangeInfoFixture
        }
        let client = BinancePublicMarketDataClient(transport: transport)

        let exchangeInfo = try await client.exchangeInfo(symbols: [symbol])

        XCTAssertEqual(exchangeInfo.symbols.map(\.rawValue), ["BTCUSDT", "SOLUSDT"])
        let requests = await transport.requests()
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests[0].contract.transport, .restGET)
        XCTAssertTrue(requests[0].contract.isReadOnly)
        XCTAssertFalse(requests[0].contract.requiresAPIKey)
        XCTAssertTrue(requests[0].url.absoluteString.hasPrefix("https://api.binance.com/api/v3/exchangeInfo"))
        XCTAssertNoForbiddenBinanceFragments(requests)
    }

    func testPublicClientFixtureParityForRESTEndpoints() async throws {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let eth = try Symbol(rawValue: "ETHUSDT")
        let range = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_067_200),
            end: Date(timeIntervalSince1970: 1_704_067_260)
        )
        let observedAt = Date(timeIntervalSince1970: 1_704_067_204)
        let transport = MockBinancePublicMarketDataTransport { request in
            switch request.contract.path {
            case "/api/v3/klines":
                Self.klineFixture
            case "/api/v3/trades":
                Self.recentTradesFixture
            case "/api/v3/ticker/bookTicker":
                Self.bookTickerFixture
            case "/api/v3/depth":
                Self.depthSnapshotFixture
            default:
                throw BinancePublicMarketDataClientError.invalidURL(path: request.contract.path)
            }
        }
        let client = BinancePublicMarketDataClient(transport: transport)

        let bars = try await client.klines(
            symbol: symbol,
            timeframe: .oneMinute,
            range: range,
            limit: 500
        )
        let trades = try await client.recentTrades(symbol: symbol, limit: 100)
        let bestBidAsk = try await client.bestBidAsk(
            symbol: eth,
            observedAt: Date(timeIntervalSince1970: 1_704_067_202)
        )
        let snapshot = try await client.depthSnapshot(
            symbol: symbol,
            limit: .oneHundred,
            observedAt: observedAt
        )

        XCTAssertEqual(
            bars,
            try BinancePublicMarketDataPayloadDecoder.decodeKlines(
                from: Self.klineFixture,
                symbol: symbol,
                timeframe: .oneMinute
            )
        )
        XCTAssertEqual(
            trades,
            try BinancePublicMarketDataPayloadDecoder.decodeRecentTrades(
                from: Self.recentTradesFixture,
                symbol: symbol
            )
        )
        XCTAssertEqual(
            bestBidAsk,
            try BinancePublicMarketDataPayloadDecoder.decodeBestBidAsk(
                from: Self.bookTickerFixture,
                observedAt: Date(timeIntervalSince1970: 1_704_067_202)
            )
        )
        XCTAssertEqual(
            snapshot,
            try BinancePublicMarketDataPayloadDecoder.decodeDepthSnapshot(
                from: Self.depthSnapshotFixture,
                symbol: symbol,
                observedAt: observedAt
            )
        )

        let requests = await transport.requests()
        XCTAssertEqual(requests.map(\.contract.transport), [.restGET, .restGET, .restGET, .restGET])
        XCTAssertTrue(requests.allSatisfy(\.contract.isReadOnly))
        XCTAssertFalse(requests.contains { $0.contract.requiresAPIKey })
        XCTAssertNoForbiddenBinanceFragments(requests)
    }

    func testPublicClientSupportsDepthDeltaStreamPathThroughMockTransport() async throws {
        let symbol = try Symbol(rawValue: "BNBUSDT")
        let transport = MockBinancePublicMarketDataTransport { request in
            XCTAssertEqual(request.contract.transport, .webSocketStream)
            XCTAssertEqual(request.contract.path, "/ws/bnbusdt@depth")
            XCTAssertEqual(request.url.scheme, "wss")
            XCTAssertTrue(request.headers.isEmpty)
            return Self.depthDeltaFixture
        }
        let client = BinancePublicMarketDataClient(transport: transport)

        let delta = try await client.depthDelta(symbol: symbol)

        XCTAssertEqual(
            delta,
            try BinancePublicMarketDataPayloadDecoder.decodeDepthDelta(from: Self.depthDeltaFixture)
        )
        let requests = await transport.requests()
        XCTAssertEqual(requests.count, 1)
        XCTAssertTrue(requests[0].contract.isReadOnly)
        XCTAssertFalse(requests[0].contract.requiresAPIKey)
        XCTAssertNoForbiddenBinanceFragments(requests)
    }

    func testPublicClientRejectsMutableOrKeyedContractsBeforeTransport() async throws {
        let transport = MockBinancePublicMarketDataTransport { _ in
            Data()
        }
        let client = BinancePublicMarketDataClient(transport: transport)
        let unsafeContract = BinancePublicRequestContract(
            capability: .bestBidAsk,
            transport: .restGET,
            path: "/api/v3/account",
            isReadOnly: false,
            requiresAPIKey: true
        )

        do {
            _ = try await client.payload(for: unsafeContract)
            XCTFail("public client must reject mutable or API-key contracts before transport")
        } catch {
            XCTAssertEqual(
                error as? BinancePublicMarketDataClientError,
                .forbiddenRequest(path: "/api/v3/account", reason: "request is not read-only")
            )
        }

        let privateReadOnlyContract = BinancePublicRequestContract(
            capability: .recentTrades,
            transport: .restGET,
            path: "/api/v3/myTrades",
            queryItems: [
                BinanceQueryItem(name: "symbol", value: "BTCUSDT")
            ],
            isReadOnly: true,
            requiresAPIKey: false
        )

        do {
            _ = try await client.payload(for: privateReadOnlyContract)
            XCTFail("public client must reject non-allowlisted Binance paths before transport")
        } catch {
            XCTAssertEqual(
                error as? BinancePublicMarketDataClientError,
                .forbiddenRequest(path: "/api/v3/myTrades", reason: "path is not in Binance public allowlist")
            )
        }

        let requests = await transport.requests()
        XCTAssertTrue(requests.isEmpty)
    }

    func testPublicReadOnlyAdapterCannotUpgradeIntoMTP62CredentialOrAccountCapability() async throws {
        // 测试场景：MTP-62 的 Gate 1 边界要求 public market data adapter 继续只读；
        // API key、signature、account endpoint 和 listenKey 即使被手写成 contract 也必须在 transport 前拒绝。
        let liveBoundary = LiveTradingCredentialEndpointBoundary.deterministicFixture
        let adapterBoundary = BinanceReadOnlyAdapterBoundary()

        XCTAssertTrue(liveBoundary.gateOneBoundaryHeld)
        XCTAssertFalse(liveBoundary.upgradesPublicReadOnlyAdapter)
        XCTAssertTrue(adapterBoundary.forbiddenCapabilities.contains(BinanceForbiddenCapability.apiKey.rawValue))
        XCTAssertTrue(
            adapterBoundary.forbiddenCapabilities.contains(BinanceForbiddenCapability.signedEndpoint.rawValue)
        )
        XCTAssertTrue(
            adapterBoundary.forbiddenCapabilities.contains(BinanceForbiddenCapability.accountEndpoint.rawValue)
        )
        XCTAssertTrue(
            adapterBoundary.forbiddenCapabilities.contains(
                BinanceForbiddenCapability.listenKeyUserDataStream.rawValue
            )
        )
        XCTAssertFalse(adapterBoundary.allowedCapabilities.contains("signed endpoint"))
        XCTAssertFalse(adapterBoundary.allowedCapabilities.contains("account endpoint"))
        XCTAssertFalse(adapterBoundary.allowedCapabilities.contains("listenKey user data stream"))

        let transport = MockBinancePublicMarketDataTransport { _ in
            Data()
        }
        let client = BinancePublicMarketDataClient(transport: transport)

        func assertRejected(
            _ contract: BinancePublicRequestContract,
            expected: BinancePublicMarketDataClientError,
            file: StaticString = #filePath,
            line: UInt = #line
        ) async {
            do {
                _ = try await client.payload(for: contract)
                XCTFail("MTP-62 forbidden contract should be rejected before transport", file: file, line: line)
            } catch {
                XCTAssertEqual(error as? BinancePublicMarketDataClientError, expected, file: file, line: line)
            }
        }

        await assertRejected(
            BinancePublicRequestContract(
                capability: .bestBidAsk,
                transport: .restGET,
                path: "/api/v3/ticker/bookTicker",
                queryItems: [BinanceQueryItem(name: "symbol", value: "apiKey")],
                isReadOnly: true,
                requiresAPIKey: false
            ),
            expected: .forbiddenRequest(
                path: "/api/v3/ticker/bookTicker",
                reason: "contains forbidden fragment: apikey"
            )
        )
        await assertRejected(
            BinancePublicRequestContract(
                capability: .bestBidAsk,
                transport: .restGET,
                path: "/api/v3/ticker/bookTicker",
                isReadOnly: true,
                requiresAPIKey: true
            ),
            expected: .forbiddenRequest(
                path: "/api/v3/ticker/bookTicker",
                reason: "request requires API key"
            )
        )
        await assertRejected(
            BinancePublicRequestContract(
                capability: .bestBidAsk,
                transport: .restGET,
                path: "/api/v3/ticker/bookTicker",
                queryItems: [BinanceQueryItem(name: "symbol", value: "signature")],
                isReadOnly: true,
                requiresAPIKey: false
            ),
            expected: .forbiddenRequest(
                path: "/api/v3/ticker/bookTicker",
                reason: "contains forbidden fragment: signature"
            )
        )
        await assertRejected(
            BinancePublicRequestContract(
                capability: .bestBidAsk,
                transport: .restGET,
                path: "/api/v3/account",
                isReadOnly: true,
                requiresAPIKey: false
            ),
            expected: .forbiddenRequest(
                path: "/api/v3/account",
                reason: "path is not in Binance public allowlist"
            )
        )
        await assertRejected(
            BinancePublicRequestContract(
                capability: .depthSnapshot,
                transport: .restGET,
                path: "/api/v3/depth",
                queryItems: [BinanceQueryItem(name: "symbol", value: "listenKey")],
                isReadOnly: true,
                requiresAPIKey: false
            ),
            expected: .forbiddenRequest(
                path: "/api/v3/depth",
                reason: "contains forbidden fragment: listenkey"
            )
        )

        let requests = await transport.requests()
        XCTAssertTrue(requests.isEmpty)
    }

    func testBatchReplayBoundaryDefinesPublicReadOnlyLocalFixtureContract() {
        // 测试场景：MTP-54 只定义本地 batch / replay boundary，不实现真实历史下载器、
        // production operations 或任何交易能力。该 fixture 是后续 metadata / replay issue 的合同入口。
        let boundary = BinanceMarketDataBatchReplayBoundary()

        XCTAssertEqual(boundary.boundaryName, "Binance public market data batch / replay boundary")
        XCTAssertEqual(boundary.sourceName, "Binance public market data")
        XCTAssertEqual(boundary.inputFields, [.symbol, .timeframe, .timeWindow, .fixtureSource])
        XCTAssertEqual(boundary.outputFields, [.batchID, .replayRunID, .recordCount, .checksumParityHint])
        XCTAssertEqual(boundary.metadataFields, BinanceMarketDataBatchReplayContractField.allCases)
        XCTAssertTrue(boundary.coversMinimumContractFields)
        XCTAssertEqual(boundary.allowedMarketDataCapabilities, BinancePublicMarketDataCapability.allCases)
        XCTAssertEqual(boundary.requiredValidationModes, [.mockTransport, .fixtureParity, .localBatchReplay])
        XCTAssertEqual(boundary.optionalValidationModes, [.optionalManualNetworkSmoke])
        XCTAssertTrue(boundary.isPublicReadOnly)
        XCTAssertTrue(boundary.isLocalFixtureReplayOnly)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)
        XCTAssertFalse(boundary.authorizesTradingExecution)
        XCTAssertFalse(boundary.authorizesProductionRuntimeOperations)
    }

    func testBatchReplayBoundaryForbidsSignedAccountBrokerAndRealOrderCapabilities() throws {
        // 测试场景：batch replay 的 metadata 字段只能描述本地 fixture / replay evidence；
        // forbidden capability 需要显式存在，但不能混入输入、输出或 metadata 字段。
        let boundary = BinanceMarketDataBatchReplayBoundary()

        XCTAssertTrue(boundary.forbidsCapability("signed endpoint"))
        XCTAssertTrue(boundary.forbidsCapability("account endpoint"))
        XCTAssertTrue(boundary.forbidsCapability("listenKey user data stream"))
        XCTAssertTrue(boundary.forbidsCapability("broker action"))
        XCTAssertTrue(boundary.forbidsCapability("real order submit"))
        XCTAssertTrue(boundary.forbidsCapability("real order cancel"))
        XCTAssertTrue(boundary.forbidsCapability("real order replace"))
        XCTAssertTrue(boundary.forbidsCapability("production runtime operations"))
        XCTAssertFalse(boundary.forbidsCapability("fixture parity"))

        let serializedFields = (boundary.inputFields + boundary.outputFields + boundary.metadataFields)
            .map(\.rawValue)
            .joined(separator: " ")
            .lowercased()

        XCTAssertFalse(serializedFields.contains("signed"))
        XCTAssertFalse(serializedFields.contains("account"))
        XCTAssertFalse(serializedFields.contains("listenkey"))
        XCTAssertFalse(serializedFields.contains("broker"))
        XCTAssertFalse(serializedFields.contains("order submit"))
        XCTAssertFalse(serializedFields.contains("order cancel"))
        XCTAssertFalse(serializedFields.contains("order replace"))

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(BinanceMarketDataBatchReplayBoundary.self, from: encoded)
        XCTAssertEqual(decoded, boundary)
    }

    func testBatchReplayMetadataDefinesDeterministicLocalReplayOperationsEvidence() throws {
        // 测试场景：MTP-55 metadata 只固定本地 replay operations evidence，
        // 不触发真实 Binance 网络、不表达 production runtime operations 或交易授权。
        let metadata = try BinanceMarketDataReplayOperationsFixture.deterministicMetadata()

        XCTAssertEqual(metadata.batchID.rawValue, "batch-BTCUSDT-1m-20240101")
        XCTAssertEqual(metadata.replayRunID.rawValue, "replay-run-BTCUSDT-1m-20240101T000000Z")
        XCTAssertEqual(metadata.symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(metadata.timeframe, .oneMinute)
        XCTAssertEqual(metadata.timeWindowDescription, "1704067200...1704067260")
        XCTAssertEqual(metadata.fixtureSource.rawValue, "fixtures/binance/btcusdt-1m-20240101.json")
        XCTAssertEqual(metadata.recordCount, 1)
        XCTAssertEqual(
            metadata.checksumParityHint,
            BinanceMarketDataBatchReplayDeterministicParity.checksumParityHint(
                for: try BinanceMarketDataReplayOperationsFixture.deterministicReplayRecords()
            )
        )
        XCTAssertEqual(metadata.contractFields, BinanceMarketDataBatchReplayContractField.allCases)
        XCTAssertEqual(metadata.value(for: .symbol), "BTCUSDT")
        XCTAssertEqual(metadata.value(for: .timeframe), "1m")

        let encoded = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(BinanceMarketDataReplayOperationsMetadata.self, from: encoded)
        XCTAssertEqual(decoded, metadata)
    }

    func testBatchReplayContractBindsMetadataToPublicReadOnlyFixtureBoundary() throws {
        // 测试场景：batch replay contract 必须把 MTP-55 metadata 绑定到 MTP-54 public read-only boundary，
        // required validation 只能是 mock transport / fixture parity / local batch replay。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()

        XCTAssertTrue(contract.coversRequiredFields)
        XCTAssertEqual(contract.requiredFields, BinanceMarketDataBatchReplayContractField.allCases)
        XCTAssertEqual(contract.requiredValidationModes, [.mockTransport, .fixtureParity, .localBatchReplay])
        XCTAssertEqual(contract.optionalValidationModes, [.optionalManualNetworkSmoke])
        XCTAssertTrue(contract.requiredValidationIsLocalOnly)
        XCTAssertTrue(contract.isPublicReadOnly)
        XCTAssertTrue(contract.isLocalFixtureReplayOnly)
        XCTAssertFalse(contract.requiredValidationDependsOnNetwork)
        XCTAssertFalse(contract.authorizesTradingExecution)
        XCTAssertFalse(contract.authorizesProductionRuntimeOperations)
        XCTAssertTrue(contract.forbidsCapability("signed endpoint"))
        XCTAssertTrue(contract.forbidsCapability("account endpoint"))
        XCTAssertTrue(contract.forbidsCapability("broker action"))
        XCTAssertTrue(contract.forbidsCapability("real order submit"))
        XCTAssertFalse(contract.metadataContainsForbiddenCapabilityText)

        let encoded = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(BinanceMarketDataBatchReplayContract.self, from: encoded)
        XCTAssertEqual(decoded, contract)
    }

    func testBatchReplayMetadataRejectsInvalidValuesAndForbiddenCapabilitySurface() throws {
        // 测试场景：metadata value model 拒绝非法本地 evidence，并验证 contract surface
        // 不包含 signed/account/listenKey/broker/order 字段或 production operations 字段。
        let metadata = try BinanceMarketDataReplayOperationsFixture.deterministicMetadata()
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let serializedMetadata = metadata.deterministicFieldValues.joined(separator: " ").lowercased()

        XCTAssertFalse(serializedMetadata.contains("signed"))
        XCTAssertFalse(serializedMetadata.contains("account"))
        XCTAssertFalse(serializedMetadata.contains("listenkey"))
        XCTAssertFalse(serializedMetadata.contains("broker"))
        XCTAssertFalse(serializedMetadata.contains("order submit"))
        XCTAssertFalse(serializedMetadata.contains("order cancel"))
        XCTAssertFalse(serializedMetadata.contains("order replace"))
        XCTAssertFalse(serializedMetadata.contains("production runtime operations"))
        XCTAssertFalse(metadata.containsForbiddenCapabilityText(contract.forbiddenCapabilities))

        XCTAssertThrowsError(
            try BinanceMarketDataReplayOperationsMetadata(
                batchID: metadata.batchID,
                replayRunID: metadata.replayRunID,
                symbol: metadata.symbol,
                timeframe: metadata.timeframe,
                timeWindow: metadata.timeWindow,
                fixtureSource: metadata.fixtureSource,
                recordCount: -1,
                checksumParityHint: metadata.checksumParityHint
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayOperationsMetadataError,
                .invalidRecordCount(-1)
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataReplayOperationsMetadata(
                batchID: metadata.batchID,
                replayRunID: metadata.replayRunID,
                symbol: metadata.symbol,
                timeframe: metadata.timeframe,
                timeWindow: metadata.timeWindow,
                fixtureSource: metadata.fixtureSource,
                recordCount: metadata.recordCount,
                checksumParityHint: "   "
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayOperationsMetadataError,
                .emptyChecksumParityHint
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayContract(
                metadata: metadata,
                boundary: BinanceMarketDataBatchReplayBoundary(
                    inputFields: [],
                    outputFields: [],
                    metadataFields: []
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayOperationsMetadataError,
                .incompleteBoundaryContract
            )
        }

        let encodedMetadata = try JSONEncoder().encode(metadata)
        let invalidBoundary = BinanceMarketDataBatchReplayBoundary(metadataFields: [])
        let encodedInvalidBoundary = try JSONEncoder().encode(invalidBoundary)
        let invalidPayload = Data(
            #"{"metadata":\#(String(data: encodedMetadata, encoding: .utf8)!),"boundary":\#(String(data: encodedInvalidBoundary, encoding: .utf8)!)}"#.utf8
        )

        XCTAssertThrowsError(
            try JSONDecoder().decode(BinanceMarketDataBatchReplayContract.self, from: invalidPayload)
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayOperationsMetadataError,
                .incompleteBoundaryContract
            )
        }
    }

    func testBatchReplayRetentionPolicyComputesFreshStaleExpiredEvidence() throws {
        // 测试场景：MTP-56 retention policy 只计算本地 batch evidence 的 fresh / stale / expired 状态，
        // 不执行生产清理任务、不接云端 archive，也不把状态解释为 runtime operations。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let metadata = contract.metadata
        let policy = try BinanceMarketDataReplayOperationsFixture.deterministicRetentionPolicy()

        let freshEvidence = try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: contract,
            policy: policy,
            evaluatedAt: Date(timeIntervalSince1970: metadata.timeWindow.end.timeIntervalSince1970 + 120)
        )
        let staleEvidence = try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: contract,
            policy: policy,
            evaluatedAt: Date(timeIntervalSince1970: metadata.timeWindow.end.timeIntervalSince1970 + 600)
        )
        let expiredEvidence = try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: contract,
            policy: policy,
            evaluatedAt: Date(timeIntervalSince1970: metadata.timeWindow.end.timeIntervalSince1970 + 4_000)
        )
        let notRetainedPolicy = try BinanceMarketDataReplayRetentionPolicy(
            policyID: Identifier("local-replay-retention-policy-disabled"),
            retainBatchLocally: false,
            staleAfterSeconds: 300,
            expiresAfterSeconds: 3_600,
            retentionWindowSeconds: 7_200
        )
        let notRetainedEvidence = try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: contract,
            policy: notRetainedPolicy,
            evaluatedAt: Date(timeIntervalSince1970: metadata.timeWindow.end.timeIntervalSince1970 + 120)
        )

        XCTAssertEqual(freshEvidence.status, .fresh)
        XCTAssertTrue(freshEvidence.isRetainedLocally)
        XCTAssertFalse(freshEvidence.isStale)
        XCTAssertFalse(freshEvidence.isExpired)
        XCTAssertEqual(staleEvidence.status, .stale)
        XCTAssertTrue(staleEvidence.isRetainedLocally)
        XCTAssertTrue(staleEvidence.isStale)
        XCTAssertFalse(staleEvidence.isExpired)
        XCTAssertEqual(expiredEvidence.status, .expired)
        XCTAssertFalse(expiredEvidence.isRetainedLocally)
        XCTAssertFalse(expiredEvidence.isStale)
        XCTAssertTrue(expiredEvidence.isExpired)
        XCTAssertEqual(notRetainedEvidence.status, .notRetained)
        XCTAssertFalse(notRetainedEvidence.isRetainedLocally)

        XCTAssertThrowsError(
            try BinanceMarketDataReplayRetentionPolicy(
                policyID: Identifier("invalid-local-replay-retention-policy"),
                staleAfterSeconds: 3_600,
                expiresAfterSeconds: 300,
                retentionWindowSeconds: 7_200
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayRetentionPolicyError,
                .invalidWindowOrder(staleAfterSeconds: 3_600, expiresAfterSeconds: 300)
            )
        }
    }

    func testBatchReplayFreshnessReadModelIsCodableAndHidesSchemaAdapterRuntimeSurface() throws {
        // 测试场景：freshness read model 是后续 Report / Dashboard / Event Timeline 可消费的稳定 DTO；
        // 它不得暴露 SQLite / DuckDB schema、adapter request、runtime object 或任何真实交易能力。
        let evidence = try BinanceMarketDataReplayOperationsFixture.deterministicFreshnessEvidence()
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()

        XCTAssertEqual(evidence.batchID, "batch-BTCUSDT-1m-20240101")
        XCTAssertEqual(evidence.replayRunID, "replay-run-BTCUSDT-1m-20240101T000000Z")
        XCTAssertEqual(evidence.status, .fresh)
        XCTAssertEqual(evidence.batchAgeSeconds, 120)
        XCTAssertEqual(evidence.retentionEvidence.first, "policy=local-replay-retention-policy-v1")
        XCTAssertEqual(
            evidence.freshnessSummary,
            "batch-BTCUSDT-1m-20240101; fresh; age=120s; retained=true"
        )
        XCTAssertEqual(evidence.requiredValidationModes, [.mockTransport, .fixtureParity, .localBatchReplay])
        XCTAssertTrue(evidence.requiredValidationIsLocalOnly)
        XCTAssertTrue(evidence.isPublicReadOnly)
        XCTAssertTrue(evidence.isLocalFixtureReplayOnly)
        XCTAssertTrue(evidence.readModelOnlyBoundaryHeld)
        XCTAssertFalse(evidence.exposesSQLiteSchema)
        XCTAssertFalse(evidence.exposesDuckDBSchema)
        XCTAssertFalse(evidence.exposesAdapterRequest)
        XCTAssertFalse(evidence.exposesRuntimeObject)
        XCTAssertFalse(evidence.authorizesLiveTrading)
        XCTAssertFalse(evidence.touchesBrokerAction)
        XCTAssertFalse(evidence.authorizesTradingExecution)
        XCTAssertFalse(evidence.containsForbiddenCapabilityText(contract.forbiddenCapabilities))

        let serializedEvidence = (
            evidence.retentionEvidence + [
                evidence.freshnessSummary,
                evidence.source.sourceKind
            ]
        )
        .joined(separator: " ")
        .lowercased()
        XCTAssertFalse(serializedEvidence.contains("sqlite"))
        XCTAssertFalse(serializedEvidence.contains("duckdb"))
        XCTAssertFalse(serializedEvidence.contains("adapter request"))
        XCTAssertFalse(serializedEvidence.contains("runtime object"))
        XCTAssertFalse(serializedEvidence.contains("broker"))
        XCTAssertFalse(serializedEvidence.contains("signed endpoint"))
        XCTAssertFalse(serializedEvidence.contains("account endpoint"))

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            BinanceMarketDataReplayFreshnessEvidenceReadModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        let nonLocalContract = try BinanceMarketDataBatchReplayContract(
            metadata: contract.metadata,
            boundary: BinanceMarketDataBatchReplayBoundary(
                requiredValidationModes: [.optionalManualNetworkSmoke]
            )
        )

        XCTAssertThrowsError(
            try BinanceMarketDataReplayFreshnessEvidenceReadModel(
                contract: nonLocalContract,
                policy: BinanceMarketDataReplayOperationsFixture.deterministicRetentionPolicy(),
                evaluatedAt: Date(timeIntervalSince1970: 1_704_067_380)
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataReplayRetentionPolicyError,
                .nonLocalReplayContract
            )
        }
    }

    func testBatchReplayFreshnessSummaryAggregatesRetentionEvidenceDeterministically() throws {
        // 测试场景：batch freshness summary 只聚合已生成的 read model evidence，
        // 不读取底层 schema、不触发 replay、不执行 retention cleanup 或生产运营动作。
        let policy = try BinanceMarketDataReplayOperationsFixture.deterministicRetentionPolicy()
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_071_260)
        let freshEvidence = try makeFreshnessEvidence(
            batchID: "batch-fresh",
            replayRunID: "replay-fresh",
            windowEnd: Date(timeIntervalSince1970: 1_704_071_140),
            evaluatedAt: evaluatedAt,
            policy: policy
        )
        let staleEvidence = try makeFreshnessEvidence(
            batchID: "batch-stale",
            replayRunID: "replay-stale",
            windowEnd: Date(timeIntervalSince1970: 1_704_070_660),
            evaluatedAt: evaluatedAt,
            policy: policy
        )
        let expiredEvidence = try makeFreshnessEvidence(
            batchID: "batch-expired",
            replayRunID: "replay-expired",
            windowEnd: Date(timeIntervalSince1970: 1_704_067_200),
            evaluatedAt: evaluatedAt,
            policy: policy
        )

        let summary = BinanceMarketDataReplayBatchFreshnessSummary(
            evidence: [
                staleEvidence,
                expiredEvidence,
                freshEvidence
            ]
        )

        XCTAssertEqual(summary.totalBatchCount, 3)
        XCTAssertEqual(summary.freshBatchIDs, ["batch-fresh"])
        XCTAssertEqual(summary.staleBatchIDs, ["batch-stale"])
        XCTAssertEqual(summary.expiredBatchIDs, ["batch-expired"])
        XCTAssertEqual(summary.notRetainedBatchIDs, [])
        XCTAssertEqual(summary.retainedBatchIDs, ["batch-fresh", "batch-stale"])
        XCTAssertEqual(
            summary.summaryLine,
            "batches=3; fresh=1; stale=1; expired=1; notRetained=0; retained=2; readModelOnly=true"
        )
        XCTAssertTrue(summary.readModelOnlyBoundaryHeld)
        XCTAssertFalse(summary.exposesSQLiteSchema)
        XCTAssertFalse(summary.exposesDuckDBSchema)
        XCTAssertFalse(summary.exposesAdapterRequest)
        XCTAssertFalse(summary.exposesRuntimeObject)
        XCTAssertFalse(summary.authorizesLiveTrading)
        XCTAssertFalse(summary.touchesBrokerAction)
        XCTAssertFalse(summary.authorizesTradingExecution)

        let encoded = try JSONEncoder().encode(summary)
        let decoded = try JSONDecoder().decode(
            BinanceMarketDataReplayBatchFreshnessSummary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, summary)
    }

    func testBatchReplayFixtureParityBuildsDeterministicReplayConsistencyEvidence() throws {
        // 测试场景：MTP-57 的 replay consistency evidence 只消费本地 fixture replay output，
        // 并把 metadata record count、ordering 和 checksum / parity hint 锁定为 deterministic。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let records = try BinanceMarketDataReplayOperationsFixture.deterministicReplayRecords()

        let evidence = try BinanceMarketDataBatchReplayDeterministicParity.validate(
            contract: contract,
            replayedBars: records
        )
        let repeatedEvidence = try BinanceMarketDataReplayOperationsFixture.deterministicReplayConsistencyEvidence()

        XCTAssertEqual(evidence, repeatedEvidence)
        XCTAssertEqual(evidence.recordCount, contract.metadata.recordCount)
        XCTAssertEqual(evidence.metadataRecordCount, 1)
        XCTAssertEqual(evidence.replayedBars, records)
        XCTAssertEqual(evidence.orderedRecordStarts, [1_704_067_200])
        XCTAssertEqual(evidence.replayOutputSummary.count, 1)
        XCTAssertEqual(evidence.metadataChecksumParityHint, contract.metadata.checksumParityHint)
        XCTAssertEqual(evidence.computedChecksumParityHint, contract.metadata.checksumParityHint)
        XCTAssertTrue(evidence.checksumParityHintMatched)
        XCTAssertTrue(evidence.metadataConsistencyHeld)
        XCTAssertTrue(evidence.recordOrderingHeld)
        XCTAssertTrue(evidence.networkIndependent)
        XCTAssertEqual(evidence.requiredValidationModes, [.mockTransport, .fixtureParity, .localBatchReplay])
        XCTAssertEqual(evidence.optionalValidationModes, [.optionalManualNetworkSmoke])
        XCTAssertTrue(evidence.requiredValidationIsLocalOnly)
        XCTAssertFalse(evidence.requiredValidationDependsOnNetwork)
        XCTAssertTrue(evidence.isPublicReadOnly)
        XCTAssertTrue(evidence.isLocalFixtureReplayOnly)
        XCTAssertFalse(evidence.authorizesLiveTrading)
        XCTAssertFalse(evidence.touchesBrokerAction)
        XCTAssertFalse(evidence.authorizesTradingExecution)
        XCTAssertFalse(evidence.authorizesProductionRuntimeOperations)
        XCTAssertFalse(evidence.containsForbiddenCapabilityText(contract.forbiddenCapabilities))

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            BinanceMarketDataBatchReplayConsistencyEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)
    }

    func testBatchReplayConsistencyRejectsRecordCountOrderingAndChecksumDrift() throws {
        // 测试场景：replay consistency 必须拒绝 metadata record count 漂移、乱序 output
        // 和 checksum / parity hint 漂移，避免 batch replay 结果被非确定性输入污染。
        let first = try makeReplayBar(
            start: 1_704_067_200,
            end: 1_704_067_260,
            open: 42_000.10,
            high: 42_100.20,
            low: 41_900.30,
            close: 42_050.40,
            volume: 12.345
        )
        let second = try makeReplayBar(
            start: 1_704_067_260,
            end: 1_704_067_320,
            open: 42_050.40,
            high: 42_180.00,
            low: 42_000.00,
            close: 42_120.25,
            volume: 8.5
        )
        let orderedRecords = [first, second]
        let metadata = try makeReplayMetadata(
            recordCount: 2,
            windowStart: 1_704_067_200,
            windowEnd: 1_704_067_320,
            checksumParityHint: BinanceMarketDataBatchReplayDeterministicParity.checksumParityHint(
                for: orderedRecords
            )
        )
        let contract = try BinanceMarketDataBatchReplayContract(metadata: metadata)

        let evidence = try BinanceMarketDataBatchReplayDeterministicParity.validate(
            contract: contract,
            replayedBars: orderedRecords
        )
        XCTAssertEqual(evidence.recordCount, 2)
        XCTAssertEqual(evidence.orderedRecordStarts, [1_704_067_200, 1_704_067_260])
        XCTAssertEqual(evidence.computedChecksumParityHint, metadata.checksumParityHint)

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: contract,
                replayedBars: [first]
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .metadataRecordCountMismatch(expected: 2, actual: 1)
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: contract,
                replayedBars: [second, first]
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .outOfOrderRecord(previousStart: 1_704_067_260, currentStart: 1_704_067_200)
            )
        }

        let driftedChecksumMetadata = try makeReplayMetadata(
            recordCount: 2,
            windowStart: 1_704_067_200,
            windowEnd: 1_704_067_320,
            checksumParityHint: "fnv1a64:0000000000000000"
        )
        let driftedChecksumContract = try BinanceMarketDataBatchReplayContract(metadata: driftedChecksumMetadata)

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: driftedChecksumContract,
                replayedBars: orderedRecords
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .checksumParityHintMismatch(
                    expected: "fnv1a64:0000000000000000",
                    actual: metadata.checksumParityHint
                )
            )
        }
    }

    func testBatchReplayConsistencyRejectsMetadataAndNetworkBoundaryDrift() throws {
        // 测试场景：fixture parity 必须继续拒绝 symbol / interval / time window 漂移，
        // 并证明 required validation 不能退化为真实网络 smoke 或 production operations。
        let records = try BinanceMarketDataReplayOperationsFixture.deterministicReplayRecords()
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let ethRecord = try makeReplayBar(
            symbol: "ETHUSDT",
            start: 1_704_067_200,
            end: 1_704_067_260
        )
        let fiveMinuteRecord = try makeReplayBar(
            timeframe: .fiveMinutes,
            start: 1_704_067_200,
            end: 1_704_067_260
        )
        let shiftedWindowRecord = try makeReplayBar(
            start: 1_704_067_260,
            end: 1_704_067_320
        )
        let nonLocalContract = try BinanceMarketDataBatchReplayContract(
            metadata: contract.metadata,
            boundary: BinanceMarketDataBatchReplayBoundary(
                requiredValidationModes: [.optionalManualNetworkSmoke],
                isLocalFixtureReplayOnly: false,
                requiredValidationDependsOnNetwork: true,
                authorizesProductionRuntimeOperations: true
            )
        )

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: contract,
                replayedBars: [ethRecord]
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .metadataSymbolMismatch(expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: contract,
                replayedBars: [fiveMinuteRecord]
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .metadataTimeframeMismatch(expected: "1m", actual: "5m")
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: contract,
                replayedBars: [shiftedWindowRecord]
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceMarketDataBatchReplayParityError,
                .metadataTimeWindowMismatch(expected: "1704067200...1704067260", actual: "1704067260...1704067320")
            )
        }

        XCTAssertThrowsError(
            try BinanceMarketDataBatchReplayDeterministicParity.validate(
                contract: nonLocalContract,
                replayedBars: records
            )
        ) { error in
            XCTAssertEqual(error as? BinanceMarketDataBatchReplayParityError, .nonLocalReplayContract)
        }
    }

    private static let exchangeInfoFixture = Data(
        #"""
        {
          "symbols": [
            { "symbol": "BTCUSDT", "status": "TRADING" },
            { "symbol": "DOGEUSDT", "status": "TRADING" },
            { "symbol": "SOLUSDT", "status": "TRADING" }
          ]
        }
        """#.utf8
    )

    private static let klineFixture = Data(
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

    private static let recentTradesFixture = Data(
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

    private static let bookTickerFixture = Data(
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

    private static let depthSnapshotFixture = Data(
        #"""
        {
          "lastUpdateId": 100,
          "bids": [["42000.00", "1.100"], ["41999.50", "0.800"]],
          "asks": [["42001.00", "0.900"], ["42002.00", "1.250"]]
        }
        """#.utf8
    )

    private static let depthDeltaFixture = Data(
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

    private func XCTAssertNoForbiddenBinanceFragments(
        _ requests: [BinancePublicTransportRequest],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let serializedRequests = requests
            .map { request in
                "\(request.method) \(request.url.absoluteString) \(request.headers)"
            }
            .joined(separator: " ")
            .lowercased()

        XCTAssertFalse(serializedRequests.contains("apikey"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("signature"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("listenkey"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/api/v3/account"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/api/v3/order"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/sapi/"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/fapi/"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/dapi/"), file: file, line: line)
    }

    private func makeFreshnessEvidence(
        batchID: String,
        replayRunID: String,
        windowEnd: Date,
        evaluatedAt: Date,
        policy: BinanceMarketDataReplayRetentionPolicy
    ) throws -> BinanceMarketDataReplayFreshnessEvidenceReadModel {
        let metadata = try BinanceMarketDataReplayOperationsMetadata(
            batchID: Identifier(batchID),
            replayRunID: Identifier(replayRunID),
            symbol: Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            timeWindow: DateRange(
                start: Date(timeIntervalSince1970: windowEnd.timeIntervalSince1970 - 60),
                end: windowEnd
            ),
            fixtureSource: Identifier("fixtures/binance/\(batchID).json"),
            recordCount: 1,
            checksumParityHint: "sha256:\(batchID)"
        )
        let contract = try BinanceMarketDataBatchReplayContract(metadata: metadata)

        return try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: contract,
            policy: policy,
            evaluatedAt: evaluatedAt
        )
    }

    private func makeReplayMetadata(
        recordCount: Int,
        windowStart: TimeInterval,
        windowEnd: TimeInterval,
        checksumParityHint: String
    ) throws -> BinanceMarketDataReplayOperationsMetadata {
        try BinanceMarketDataReplayOperationsMetadata(
            batchID: Identifier("batch-BTCUSDT-1m-custom"),
            replayRunID: Identifier("replay-run-BTCUSDT-1m-custom"),
            symbol: Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            timeWindow: DateRange(
                start: Date(timeIntervalSince1970: windowStart),
                end: Date(timeIntervalSince1970: windowEnd)
            ),
            fixtureSource: Identifier("fixtures/binance/btcusdt-1m-custom.json"),
            recordCount: recordCount,
            checksumParityHint: checksumParityHint
        )
    }

    private func makeReplayBar(
        symbol rawSymbol: String = "BTCUSDT",
        timeframe: Timeframe = .oneMinute,
        start: TimeInterval,
        end: TimeInterval,
        open: Double = 42_000.10,
        high: Double = 42_100.20,
        low: Double = 41_900.30,
        close: Double = 42_050.40,
        volume: Double = 12.345
    ) throws -> MarketBar {
        try MarketBar(
            symbol: Symbol(rawValue: rawSymbol),
            timeframe: timeframe,
            interval: DateRange(
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: end)
            ),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}

/// 测试用 mock transport 只记录客户端发出的 public request 并返回 fixture payload。
/// 它不访问真实 Binance 网络，用于验证 required validation 离线可重复。
private actor MockBinancePublicMarketDataTransport: BinancePublicMarketDataTransport {
    typealias Handler = @Sendable (BinancePublicTransportRequest) throws -> Data

    private let handler: Handler
    private var loadedRequests: [BinancePublicTransportRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func load(_ request: BinancePublicTransportRequest) async throws -> Data {
        loadedRequests.append(request)
        return try handler(request)
    }

    func requests() -> [BinancePublicTransportRequest] {
        loadedRequests
    }
}
