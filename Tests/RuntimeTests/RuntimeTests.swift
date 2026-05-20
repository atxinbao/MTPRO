import Adapters
import Core
import Persistence
import Runtime
import XCTest

final class RuntimeTests: XCTestCase {
    func testMarketDataIngestReplayProjectionWorkflowUsesMockTransportAndStableSnapshots() async throws {
        // 测试场景：MTP-21 端到端链路必须从 mock Binance public transport 读取 fixture，
        // 经 Core ingest 写入 append-only event log，再从 replay 重建 projection snapshots。
        let symbol = try Symbol(rawValue: "BTCUSDT")
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
            case "/ws/btcusdt@depth":
                Self.depthDeltaFixture
            default:
                throw BinancePublicMarketDataClientError.invalidURL(path: request.contract.path)
            }
        }
        let workflow = try makeWorkflow(transport: transport)
        let plan = PublicMarketDataIngestPlan(
            symbol: symbol,
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 1_704_067_200),
                end: Date(timeIntervalSince1970: 1_704_067_320)
            ),
            klineLimit: 500,
            recentTradeLimit: 100,
            depthSnapshotLimit: .oneHundred,
            bestBidAskObservedAt: Date(timeIntervalSince1970: 1_704_067_202),
            depthSnapshotObservedAt: observedAt,
            firstRecordedAt: Date(timeIntervalSince1970: 2_000),
            recordedAtStride: 2
        )

        let result = try await workflow.run(plan)

        let expectedEvents = try Self.expectedFixtureEvents(symbol: symbol, observedAt: observedAt)
        XCTAssertEqual(result.ingestedEvents, expectedEvents)
        XCTAssertEqual(result.eventEnvelopes.map(\.sequence), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(result.eventEnvelopes.map(\.stream), Array(repeating: .market, count: 6))
        XCTAssertEqual(
            result.eventEnvelopes.map { $0.recordedAt.timeIntervalSince1970 },
            [2_000, 2_002, 2_004, 2_006, 2_008, 2_010]
        )
        XCTAssertEqual(result.replayResult.envelopes, result.eventEnvelopes)
        XCTAssertEqual(result.cacheSnapshot.marketEventCount, 6)

        let analytical = result.analyticalProjectionSnapshot
        XCTAssertEqual(analytical.marketBars.count, 2)
        XCTAssertEqual(analytical.trades.count, 1)
        XCTAssertEqual(analytical.bestBidAsks.count, 1)
        XCTAssertEqual(analytical.orderBookSnapshots.count, 1)
        XCTAssertEqual(analytical.orderBookDeltas.count, 1)
        XCTAssertEqual(analytical.lastAppliedSequence, 6)

        // Market-only ingest 不产生 Paper / Risk / Portfolio 运行时事实；SQLite runtime snapshot
        // 仍必须从 replay 重建并保持稳定空快照，不能通过 UI 或 schema 直连补数据。
        XCTAssertEqual(result.runtimeProjectionSnapshot, SQLiteRuntimeProjectionSnapshot())

        let requests = await transport.requests()
        XCTAssertEqual(
            requests.map(\.contract.capability),
            [.klines, .recentTrades, .bestBidAsk, .depthSnapshot, .depthDelta]
        )
        XCTAssertTrue(requests.allSatisfy(\.contract.isReadOnly))
        XCTAssertFalse(requests.contains(where: \.contract.requiresAPIKey))
        XCTAssertNoForbiddenBinanceFragments(requests)
    }

    func testWorkflowRejectsNonEmptyFileEventLogStoreToProtectSequenceInvariant() async throws {
        // 测试场景：当前 MTP-21 编排只定义单次 ingest run；非空文件事实源必须拒绝，
        // 避免新 run 从 sequence 1 追加到未知历史后破坏 append-only 单调序列。
        let store = try makeTemporaryFileEventLogStore()
        try store.append(
            try EventEnvelope(
                sequence: 1,
                stream: .market,
                recordedAt: Date(timeIntervalSince1970: 1),
                event: .market(.bar(try makeMarketBar()))
            )
        )
        let transport = MockBinancePublicMarketDataTransport { _ in Self.klineFixture }
        let workflow = MarketDataIngestReplayProjectionWorkflow(
            client: BinancePublicMarketDataClient(transport: transport),
            fileEventLogStore: store
        )
        let plan = try makePlan()

        do {
            _ = try await workflow.run(plan)
            XCTFail("workflow must reject a non-empty file event log store before ingest")
        } catch {
            XCTAssertEqual(
                error as? MarketDataIngestReplayProjectionWorkflowError,
                .fileEventLogStoreAlreadyContainsEvents(1)
            )
        }

        let requests = await transport.requests()
        XCTAssertTrue(requests.isEmpty)
    }

    func testWorkflowCanPersistRuntimeProjectionThroughSQLiteAdapterFromReplay() async throws {
        // 测试场景：当调用方提供 SQLite adapter 时，runtime snapshot 仍由 replay envelope 驱动写入，
        // querySnapshot 返回稳定 read model，不暴露 SQLite 表、列或 SQL statement。
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
            case "/ws/btcusdt@depth":
                Self.depthDeltaFixture
            default:
                throw BinancePublicMarketDataClientError.invalidURL(path: request.contract.path)
            }
        }
        let sqliteAdapter = try makeTemporarySQLiteRuntimeProjectionAdapter()
        let workflow = try makeWorkflow(
            transport: transport,
            sqliteRuntimeProjectionAdapter: sqliteAdapter
        )

        let result = try await workflow.run(try makePlan())
        let queriedSnapshot = try sqliteAdapter.querySnapshot()

        XCTAssertEqual(queriedSnapshot, result.runtimeProjectionSnapshot)
        XCTAssertEqual(queriedSnapshot, SQLiteRuntimeProjectionSnapshot())
        XCTAssertFalse(PersistenceBoundary().exposesDatabaseTablesToUI)
    }

    func testMarketDataReplayProjectionConsistencyLinksEventLogReplayAndSnapshots() throws {
        // 测试场景：MTP-58 将本地 batch replay output 写入 append-only event log，
        // 再从同一 replay result 重建 cache / SQLite / DuckDB projection snapshot consistency evidence。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let summary = try MarketDataReplayProjectionConsistencyFixture.deterministicSummary()

        XCTAssertEqual(summary.batchID, "batch-BTCUSDT-1m-20240101")
        XCTAssertEqual(summary.replayRunID, "replay-run-BTCUSDT-1m-20240101T000000Z")
        XCTAssertEqual(summary.symbol, "BTCUSDT")
        XCTAssertEqual(summary.timeframe, "1m")
        XCTAssertEqual(summary.freshnessStatus, .fresh)
        XCTAssertEqual(summary.eventLogEvidence.eventLogStream, "market")
        XCTAssertEqual(summary.eventLogEvidence.eventLogSequences, [1])
        XCTAssertEqual(summary.eventLogEvidence.replayResultSequences, [1])
        XCTAssertTrue(summary.eventLogEvidence.appendOnlyFactsSource)
        XCTAssertTrue(summary.eventLogEvidence.eventLogMatchesReplayOutput)
        XCTAssertEqual(summary.metadataRecordCount, 1)
        XCTAssertEqual(summary.eventLogRecordCount, 1)
        XCTAssertEqual(summary.replayedRecordCount, 1)
        XCTAssertEqual(summary.cacheMarketEventCount, 1)
        XCTAssertEqual(summary.cacheBarCount, 1)
        XCTAssertEqual(summary.analyticalMarketBarCount, 1)
        XCTAssertEqual(summary.eventLogLastSequence, 1)
        XCTAssertEqual(summary.projectionLastAppliedSequence, 1)
        XCTAssertEqual(summary.replayOutputSummary, summary.cacheSnapshotSummary)
        XCTAssertEqual(summary.replayOutputSummary, summary.projectionSnapshotSummary)
        XCTAssertTrue(summary.appendOnlyFactsSource)
        XCTAssertTrue(summary.eventLogConsistencyHeld)
        XCTAssertTrue(summary.projectionSnapshotConsistencyHeld)
        XCTAssertTrue(summary.deterministicProjectionSummary)
        XCTAssertTrue(summary.readModelOnlyBoundaryHeld)
        XCTAssertFalse(summary.containsForbiddenCapabilityText(contract.forbiddenCapabilities))
    }

    func testMarketDataReplayProjectionConsistencySummaryIsCodableDeterministicAndHidesSchema() throws {
        // 测试场景：projection consistency summary 是后续 UI / Report 可消费的稳定 read model，
        // 它只携带摘要、计数和边界 flags，不暴露 SQLite / DuckDB schema、SQL、adapter 或 Runtime object。
        let first = try MarketDataReplayProjectionConsistencyFixture.deterministicSummary()
        let second = try MarketDataReplayProjectionConsistencyFixture.deterministicSummary()

        XCTAssertEqual(first, second)
        XCTAssertEqual(
            first.summaryLine,
            "batch=batch-BTCUSDT-1m-20240101; replay=replay-run-BTCUSDT-1m-20240101T000000Z; eventLogRecords=1; replayRecords=1; cacheBars=1; analyticalBars=1; projectionLastSequence=1; readModelOnly=true"
        )
        XCTAssertTrue(first.source.isReadModelOnly)
        XCTAssertFalse(first.exposesSQLiteSchema)
        XCTAssertFalse(first.exposesDuckDBSchema)
        XCTAssertFalse(first.exposesAdapterRequest)
        XCTAssertFalse(first.exposesRuntimeObject)
        XCTAssertFalse(first.exposesSQLStatement)
        XCTAssertFalse(first.authorizesLiveTrading)
        XCTAssertFalse(first.touchesBrokerAction)
        XCTAssertFalse(first.authorizesTradingExecution)
        XCTAssertFalse(first.authorizesProductionRuntimeOperations)
        XCTAssertFalse(first.summaryLine.lowercased().contains("sqlite"))
        XCTAssertFalse(first.summaryLine.lowercased().contains("duckdb"))
        XCTAssertFalse(first.summaryLine.lowercased().contains("sql"))
        XCTAssertFalse(first.consistencyEvidence.joined(separator: " ").lowercased().contains("schema"))

        let encoded = try JSONEncoder().encode(first)
        let decoded = try JSONDecoder().decode(
            MarketDataReplayProjectionSnapshotConsistencySummary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, first)
    }

    func testMarketDataReplayProjectionConsistencyRejectsEventLogAndProjectionDrift() throws {
        // 测试场景：event log facts 或 projection snapshot 只要与 deterministic replay output 不一致，
        // MTP-58 evidence 就必须拒绝，避免 replay run -> event log -> projection 链路出现伪一致。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let freshnessEvidence = try BinanceMarketDataReplayOperationsFixture.deterministicFreshnessEvidence()
        let replayConsistencyEvidence = try BinanceMarketDataReplayOperationsFixture
            .deterministicReplayConsistencyEvidence()
        let envelopes = try MarketDataReplayProjectionConsistencyFixture.deterministicEventLogEnvelopes()
        let driftedBar = try MarketBar(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try DateRange(
                start: Date(timeIntervalSince1970: 1_704_067_200),
                end: Date(timeIntervalSince1970: 1_704_067_260)
            ),
            open: 42_000.10,
            high: 42_100.20,
            low: 41_900.30,
            close: 42_051.40,
            volume: 12.345
        )
        let driftedEnvelope = try EventEnvelope(
            sequence: 1,
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 1_704_067_300),
            event: .market(.bar(driftedBar))
        )

        XCTAssertThrowsError(
            try MarketDataReplayProjectionConsistency.summarize(
                contract: contract,
                freshnessEvidence: freshnessEvidence,
                replayConsistencyEvidence: replayConsistencyEvidence,
                eventLogEnvelopes: [driftedEnvelope]
            )
        ) { error in
            XCTAssertEqual(
                error as? MarketDataReplayProjectionConsistencyError,
                .eventLogReplayOutputMismatch(
                    expected: replayConsistencyEvidence.replayOutputSummary,
                    actual: BinanceMarketDataBatchReplayDeterministicParity
                        .canonicalReplaySummary(for: [driftedBar])
                )
            )
        }

        let replayBoundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market]
        )

        XCTAssertThrowsError(
            try MarketDataReplayProjectionConsistency.summarize(
                contract: contract,
                freshnessEvidence: freshnessEvidence,
                replayConsistencyEvidence: replayConsistencyEvidence,
                eventLogEnvelopes: envelopes,
                replayResult: replayBoundary.replay(command),
                cacheSnapshot: replayBoundary.rebuildMarketDataCache(from: command),
                runtimeProjectionSnapshot: replayBoundary.rebuildSQLiteRuntimeProjection(from: command),
                analyticalProjectionSnapshot: DuckDBAnalyticalProjectionSnapshot(
                    marketBars: [],
                    lastAppliedSequence: 1
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? MarketDataReplayProjectionConsistencyError,
                .analyticalProjectionMismatch(
                    expected: replayConsistencyEvidence.replayOutputSummary,
                    actual: []
                )
            )
        }
    }

    func testMarketDataReplayProjectionConsistencyRejectsSchemaAndLiveBoundaryDrift() throws {
        // 测试场景：consistency summary 的来源如果暴露 schema / runtime surface，或 replay contract
        // 退化为真实网络 / production operations，就必须被拒绝，不能进入后续 UI evidence。
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        let freshnessEvidence = try BinanceMarketDataReplayOperationsFixture.deterministicFreshnessEvidence()
        let replayConsistencyEvidence = try BinanceMarketDataReplayOperationsFixture
            .deterministicReplayConsistencyEvidence()
        let envelopes = try MarketDataReplayProjectionConsistencyFixture.deterministicEventLogEnvelopes()

        XCTAssertThrowsError(
            try MarketDataReplayProjectionConsistency.summarize(
                contract: contract,
                freshnessEvidence: freshnessEvidence,
                replayConsistencyEvidence: replayConsistencyEvidence,
                eventLogEnvelopes: envelopes,
                source: MarketDataReplayProjectionSourceContract(exposesSQLiteSchema: true)
            )
        ) { error in
            XCTAssertEqual(
                error as? MarketDataReplayProjectionConsistencyError,
                .projectionSourceBoundaryViolation
            )
        }

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
            try MarketDataReplayProjectionConsistency.summarize(
                contract: nonLocalContract,
                freshnessEvidence: freshnessEvidence,
                replayConsistencyEvidence: replayConsistencyEvidence,
                eventLogEnvelopes: envelopes
            )
        ) { error in
            XCTAssertEqual(
                error as? MarketDataReplayProjectionConsistencyError,
                .nonLocalReplayEvidence
            )
        }
    }

    private func makeWorkflow(
        transport: MockBinancePublicMarketDataTransport,
        sqliteRuntimeProjectionAdapter: SQLiteRuntimeProjectionAdapter? = nil
    ) throws -> MarketDataIngestReplayProjectionWorkflow {
        MarketDataIngestReplayProjectionWorkflow(
            client: BinancePublicMarketDataClient(transport: transport),
            fileEventLogStore: try makeTemporaryFileEventLogStore(),
            sqliteRuntimeProjectionAdapter: sqliteRuntimeProjectionAdapter
        )
    }

    private func makePlan() throws -> PublicMarketDataIngestPlan {
        PublicMarketDataIngestPlan(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 1_704_067_200),
                end: Date(timeIntervalSince1970: 1_704_067_320)
            ),
            klineLimit: 500,
            recentTradeLimit: 100,
            depthSnapshotLimit: .oneHundred,
            bestBidAskObservedAt: Date(timeIntervalSince1970: 1_704_067_202),
            depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_204),
            firstRecordedAt: Date(timeIntervalSince1970: 2_000),
            recordedAtStride: 2
        )
    }

    private static func expectedFixtureEvents(
        symbol: Symbol,
        observedAt: Date
    ) throws -> [MarketEvent] {
        try BinancePublicMarketDataPayloadDecoder.decodeKlines(
            from: klineFixture,
            symbol: symbol,
            timeframe: .oneMinute
        ).map(MarketEvent.bar)
            + BinancePublicMarketDataPayloadDecoder.decodeRecentTrades(
                from: recentTradesFixture,
                symbol: symbol
            ).map(MarketEvent.trade)
            + [
                .bestBidAsk(
                    try BinancePublicMarketDataPayloadDecoder.decodeBestBidAsk(
                        from: bookTickerFixture,
                        observedAt: Date(timeIntervalSince1970: 1_704_067_202)
                    )
                ),
                .orderBookSnapshot(
                    try BinancePublicMarketDataPayloadDecoder.decodeDepthSnapshot(
                        from: depthSnapshotFixture,
                        symbol: symbol,
                        observedAt: observedAt
                    )
                ),
                .orderBookDelta(
                    try BinancePublicMarketDataPayloadDecoder.decodeDepthDelta(
                        from: depthDeltaFixture
                    )
                )
            ]
    }

    private func makeTemporaryFileEventLogStore() throws -> FileEventLogStore {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "MTPRO-RuntimeEventLog-\(UUID().uuidString)",
            isDirectory: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return FileEventLogStore(fileURL: directoryURL.appendingPathComponent("events.jsonl"))
    }

    private func makeTemporarySQLiteRuntimeProjectionAdapter() throws -> SQLiteRuntimeProjectionAdapter {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "MTPRO-RuntimeSQLite-\(UUID().uuidString)",
            isDirectory: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return SQLiteRuntimeProjectionAdapter(
            databaseURL: directoryURL.appendingPathComponent("runtime.sqlite")
        )
    }

    private func makeMarketBar() throws -> MarketBar {
        try MarketBar(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 160)
            ),
            open: 42_000,
            high: 42_100,
            low: 41_900,
            close: 42_050,
            volume: 12.345
        )
    }

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
          ],
          [
            1704067260000,
            "42050.40",
            "42200.00",
            "42000.00",
            "42125.00",
            "8.250",
            1704067319999,
            "347000.00",
            100,
            "4.100",
            "172000.00",
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
          "symbol": "BTCUSDT",
          "bidPrice": "42000.10",
          "bidQty": "2.500",
          "askPrice": "42000.20",
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
          "s": "BTCUSDT",
          "U": 101,
          "u": 102,
          "b": [["42000.10", "4.000"]],
          "a": [["42000.30", "0.000"]]
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
}

/// Runtime 测试用 mock transport 只记录 public request 并返回 fixture payload。
/// 它不访问真实 Binance 网络，确保 required validation 完全离线且可重复。
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
