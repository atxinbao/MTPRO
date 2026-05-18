import Foundation
import Core
import Persistence
import XCTest

final class PersistenceTests: XCTestCase {
    func testPersistenceBoundarySeparatesFactsAndProjections() {
        let boundary = PersistenceBoundary()

        XCTAssertEqual(boundary.factSource, "append-only event log")
        XCTAssertTrue(boundary.sqliteResponsibility.contains("runtime state"))
        XCTAssertTrue(boundary.duckDBResponsibility.contains("backtest"))
        XCTAssertEqual(boundary.uiExposure, "stable read model projections only")
        XCTAssertFalse(boundary.exposesDatabaseTablesToUI)
        XCTAssertFalse(boundary.persistsRuntimeObjectsAsUIContract)
    }

    func testReplayBoundaryRebuildsSelectedEventRanges() throws {
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: 2),
            streams: [.market]
        )

        let replay = boundary.replay(command)
        let rebuiltCache = boundary.rebuildMarketDataCache(from: command)

        XCTAssertEqual(replay.envelopes.map(\.sequence), [1, 2])
        XCTAssertEqual(boundary.envelopes.count, envelopes.count)
        XCTAssertEqual(rebuiltCache.marketEventCount, 2)
        XCTAssertEqual(rebuiltCache.barsBySeries.count, 1)
        XCTAssertEqual(rebuiltCache.tradesBySymbol.count, 1)
    }

    func testFileEventLogStoreAppendsAndReplaysStableEnvelopes() throws {
        // 测试场景：文件事件日志只追加 Core envelope，并通过 replay contract 输出稳定事实。
        let store = try makeTemporaryFileEventLogStore()
        let envelopes = Array(try makeFullEventLog().prefix(3))

        try store.append(contentsOf: envelopes)
        let restoredEnvelopes = try store.readEnvelopes()
        let replay = try store.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 3),
                streams: [.market]
            )
        )

        XCTAssertEqual(restoredEnvelopes, envelopes)
        XCTAssertEqual(restoredEnvelopes.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(replay.envelopes.map(\.sequence), [1, 2])
        XCTAssertTrue(replay.envelopes.allSatisfy { $0.stream == .market })
    }

    func testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant() throws {
        // 测试场景：文件中已有 sequence 1 时拒绝跳过 sequence 2，避免破坏 append-only 事实流。
        let store = try makeTemporaryFileEventLogStore()
        let envelopes = try makeFullEventLog()

        try store.append(envelopes[0])

        XCTAssertThrowsError(try store.append(envelopes[2])) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
        XCTAssertEqual(try store.readEnvelopes(), [envelopes[0]])
    }

    func testReplayBoundaryCanRebuildProjectionSnapshotsFromFileEventLog() throws {
        // 测试场景：文件 facts source 经 replay 后仍只能产生稳定投影输入，不暴露 JSONL 文件格式给 UI。
        let store = try makeTemporaryFileEventLogStore()
        let envelopes = try makeFullEventLog()
        try store.append(contentsOf: envelopes)

        let boundary = try PersistenceReplayBoundary(fileStore: store)
        let marketCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market]
        )
        let runtimeCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.paper, .risk, .portfolio]
        )

        let marketSnapshot = boundary.rebuildMarketDataCache(from: marketCommand)
        let runtimeSnapshot = boundary.rebuildSQLiteRuntimeProjection(from: runtimeCommand)
        let session = try XCTUnwrap(runtimeSnapshot.paperSessions[try Identifier("paper-ema-fixture")])

        XCTAssertEqual(boundary.envelopes, envelopes)
        XCTAssertEqual(marketSnapshot.marketEventCount, 2)
        XCTAssertEqual(runtimeSnapshot.lastAppliedSequence, envelopes.count)
        XCTAssertEqual(session.state, .completed)
        XCTAssertEqual(session.executionMode, .paper)
    }

    func testSQLiteRuntimeProjectionAdapterRebuildsAndQueriesSnapshotFromReplay() throws {
        // 测试场景：SQLite adapter 从 replay envelope 写入私有投影存储，再查询回稳定 runtime snapshot。
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let adapter = try makeTemporarySQLiteRuntimeProjectionAdapter()
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.paper, .risk, .portfolio]
        )

        let rebuiltSnapshot = try boundary.rebuildSQLiteRuntimeProjection(
            from: command,
            using: adapter
        )
        let queriedSnapshot = try adapter.querySnapshot()
        let session = try XCTUnwrap(queriedSnapshot.paperSessions[try Identifier("paper-ema-fixture")])
        let portfolio = try XCTUnwrap(queriedSnapshot.portfolioProjections[try Identifier("portfolio-main")])

        XCTAssertEqual(queriedSnapshot, rebuiltSnapshot)
        XCTAssertEqual(session.state, .completed)
        XCTAssertEqual(session.executionMode, .paper)
        XCTAssertEqual(session.signalCount, 4)
        XCTAssertEqual(queriedSnapshot.rejectedPaperOrderIDs, [try Identifier("paper-order-rejected")])
        XCTAssertEqual(queriedSnapshot.riskBlockerEvidence.first?.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(queriedSnapshot.riskBlockerEvidence.first?.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(portfolio.state, .updated)
        XCTAssertEqual(portfolio.exposures.first?.grossExposureNotional, 52_500)
        XCTAssertEqual(queriedSnapshot.lastAppliedSequence, envelopes.count)
    }

    func testSQLiteRuntimeProjectionAdapterRebuildReplacesPreviousSnapshot() throws {
        // 测试场景：重复 rebuild 必须以 event log replay 为事实源替换旧投影，不能残留旧 risk / portfolio 数据。
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let adapter = try makeTemporarySQLiteRuntimeProjectionAdapter()
        let fullCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.paper, .risk, .portfolio]
        )
        let paperOnlyCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.paper]
        )

        _ = try boundary.rebuildSQLiteRuntimeProjection(from: fullCommand, using: adapter)
        let paperOnlySnapshot = try boundary.rebuildSQLiteRuntimeProjection(
            from: paperOnlyCommand,
            using: adapter
        )
        let queriedSnapshot = try adapter.querySnapshot()

        XCTAssertEqual(queriedSnapshot, paperOnlySnapshot)
        XCTAssertEqual(queriedSnapshot.paperSessions.count, 1)
        XCTAssertTrue(queriedSnapshot.rejectedPaperOrderIDs.isEmpty)
        XCTAssertTrue(queriedSnapshot.portfolioProjections.isEmpty)
        XCTAssertLessThan(try XCTUnwrap(queriedSnapshot.lastAppliedSequence), envelopes.count)
    }

    func testSQLiteRuntimeProjectionAdapterStartsWithStableEmptySnapshot() throws {
        // 测试场景：未重建前的 SQLite adapter 只返回空 read model snapshot，不暴露私有表结构。
        let adapter = try makeTemporarySQLiteRuntimeProjectionAdapter()
        let snapshot = try adapter.querySnapshot()
        let boundary = PersistenceBoundary()

        XCTAssertEqual(snapshot, SQLiteRuntimeProjectionSnapshot())
        XCTAssertEqual(boundary.uiExposure, "stable read model projections only")
        XCTAssertFalse(boundary.exposesDatabaseTablesToUI)
        XCTAssertFalse(boundary.persistsRuntimeObjectsAsUIContract)
    }

    func testTemporarySQLiteProjectionRebuildsRuntimeState() throws {
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.paper, .risk, .portfolio]
        )

        let snapshot = boundary.rebuildSQLiteRuntimeProjection(from: command)
        let session = try XCTUnwrap(snapshot.paperSessions[try Identifier("paper-ema-fixture")])
        let portfolio = try XCTUnwrap(snapshot.portfolioProjections[try Identifier("portfolio-main")])

        XCTAssertEqual(session.state, .completed)
        XCTAssertEqual(session.strategyID, try Identifier("ema-cross"))
        XCTAssertEqual(session.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(session.timeframe, .oneMinute)
        XCTAssertEqual(session.executionMode, .paper)
        XCTAssertEqual(session.signalCount, 4)
        XCTAssertEqual(session.completedAt?.timeIntervalSince1970, 1_000)
        XCTAssertEqual(snapshot.rejectedPaperOrderIDs, [try Identifier("paper-order-rejected")])
        XCTAssertEqual(snapshot.riskBlockerEvidence.first?.sourceSequence, 21)
        XCTAssertEqual(portfolio.state, .updated)
        XCTAssertEqual(portfolio.updatedAt?.timeIntervalSince1970, 1_500)
        XCTAssertEqual(portfolio.exposures.first?.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(portfolio.exposures.first?.source, .paperProjection)
        XCTAssertEqual(portfolio.exposures.first?.grossExposureNotional, 52_500)
    }

    func testTemporaryDuckDBProjectionRebuildsAnalyticalState() throws {
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market, .backtest, .strategy]
        )

        let snapshot = boundary.rebuildDuckDBAnalyticalProjection(from: command)
        let backtest = try XCTUnwrap(snapshot.backtestRuns[try Identifier("backtest-ema-fixture")])
        let research = try XCTUnwrap(snapshot.orderBookResearchRuns[try Identifier("obi-research-fixture")])

        XCTAssertEqual(snapshot.marketBars.count, 1)
        XCTAssertEqual(snapshot.trades.count, 1)
        XCTAssertEqual(backtest.state, .completed)
        XCTAssertEqual(backtest.signalCount, 4)
        XCTAssertEqual(research.state, .completed)
        XCTAssertEqual(research.depth, 2)
        XCTAssertEqual(research.signalCount, 3)
        XCTAssertEqual(snapshot.signalTimeline.count, 7)
        XCTAssertEqual(snapshot.signalTimeline.filter { $0.source == .backtest }.count, 4)
        XCTAssertEqual(snapshot.signalTimeline.filter { $0.source == .orderBookImbalanceResearch }.count, 3)
        XCTAssertEqual(snapshot.signalTimeline.first?.close, 12)
        let researchSignals = snapshot.signalTimeline.filter { $0.source == .orderBookImbalanceResearch }
        XCTAssertEqual(researchSignals.map(\.orderBookInputSource), [.snapshot, .deltaApplied, .snapshot])
        let lastImbalanceRatio = try XCTUnwrap(snapshot.signalTimeline.last?.imbalanceRatio)
        XCTAssertEqual(lastImbalanceRatio, -0.2088353414, accuracy: 0.0001)
    }

    #if canImport(DuckDB)
    func testDuckDBAnalyticalProjectionAdapterRebuildsAndQueriesSnapshotFromReplay() throws {
        // 测试场景：DuckDB adapter 从 replay envelope 写入私有分析投影存储，再查询回稳定 snapshot。
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let adapter = try makeTemporaryDuckDBAnalyticalProjectionAdapter()
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market, .backtest, .strategy]
        )

        let rebuiltSnapshot = try boundary.rebuildDuckDBAnalyticalProjection(
            from: command,
            using: adapter
        )
        let queriedSnapshot = try adapter.querySnapshot()
        let backtest = try XCTUnwrap(queriedSnapshot.backtestRuns[try Identifier("backtest-ema-fixture")])
        let research = try XCTUnwrap(
            queriedSnapshot.orderBookResearchRuns[try Identifier("obi-research-fixture")]
        )

        XCTAssertEqual(queriedSnapshot, rebuiltSnapshot)
        XCTAssertTrue(FileManager.default.fileExists(atPath: adapter.databaseURL.path))
        XCTAssertEqual(queriedSnapshot.marketBars.count, 1)
        XCTAssertEqual(queriedSnapshot.trades.count, 1)
        XCTAssertEqual(backtest.state, .completed)
        XCTAssertEqual(backtest.signalCount, 4)
        XCTAssertEqual(research.state, .completed)
        XCTAssertEqual(research.depth, 2)
        XCTAssertEqual(research.signalCount, 3)
        XCTAssertEqual(queriedSnapshot.signalTimeline.count, 7)
        let queriedResearchSignals = queriedSnapshot.signalTimeline.filter {
            $0.source == .orderBookImbalanceResearch
        }
        XCTAssertEqual(queriedResearchSignals.map(\.orderBookInputSource), [.snapshot, .deltaApplied, .snapshot])
        XCTAssertEqual(queriedSnapshot.lastAppliedSequence, 19)
    }

    func testDuckDBAnalyticalProjectionAdapterRebuildReplacesPreviousSnapshot() throws {
        // 测试场景：重复 rebuild 必须以 event log replay 为事实源替换旧分析投影，不能残留旧研究信号。
        let envelopes = try makeFullEventLog()
        let boundary = try PersistenceReplayBoundary(envelopes: envelopes)
        let adapter = try makeTemporaryDuckDBAnalyticalProjectionAdapter()
        let fullCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market, .backtest, .strategy]
        )
        let marketOnlyCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market]
        )

        _ = try boundary.rebuildDuckDBAnalyticalProjection(from: fullCommand, using: adapter)
        let marketOnlySnapshot = try boundary.rebuildDuckDBAnalyticalProjection(
            from: marketOnlyCommand,
            using: adapter
        )
        let queriedSnapshot = try adapter.querySnapshot()

        XCTAssertEqual(queriedSnapshot, marketOnlySnapshot)
        XCTAssertEqual(queriedSnapshot.marketBars.count, 1)
        XCTAssertEqual(queriedSnapshot.trades.count, 1)
        XCTAssertTrue(queriedSnapshot.backtestRuns.isEmpty)
        XCTAssertTrue(queriedSnapshot.orderBookResearchRuns.isEmpty)
        XCTAssertTrue(queriedSnapshot.signalTimeline.isEmpty)
        XCTAssertEqual(queriedSnapshot.lastAppliedSequence, 2)
    }

    func testDuckDBAnalyticalProjectionAdapterStartsWithStableEmptySnapshot() throws {
        // 测试场景：未重建前的 DuckDB adapter 只返回空 read model snapshot，不暴露私有 schema。
        let adapter = try makeTemporaryDuckDBAnalyticalProjectionAdapter()
        let snapshot = try adapter.querySnapshot()
        let boundary = PersistenceBoundary()

        XCTAssertEqual(snapshot, DuckDBAnalyticalProjectionSnapshot())
        XCTAssertEqual(boundary.uiExposure, "stable read model projections only")
        XCTAssertFalse(boundary.exposesDatabaseTablesToUI)
        XCTAssertFalse(boundary.persistsRuntimeObjectsAsUIContract)
    }
    #endif

    func testProjectionIsolationKeepsRuntimeAndAnalyticalReadModelsSeparate() throws {
        let envelopes = try makeFullEventLog()
        let sqliteSnapshot = SQLiteRuntimeProjectionStore.project(envelopes)
        let duckDBSnapshot = DuckDBAnalyticalProjectionStore.project(envelopes)

        XCTAssertEqual(sqliteSnapshot.paperSessions.count, 1)
        XCTAssertEqual(sqliteSnapshot.portfolioProjections.count, 1)
        XCTAssertEqual(sqliteSnapshot.rejectedPaperOrderIDs.count, 1)
        XCTAssertEqual(sqliteSnapshot.riskBlockerEvidence.first?.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(
            sqliteSnapshot.portfolioProjections[try Identifier("portfolio-main")]?.exposures.count,
            1
        )

        XCTAssertEqual(duckDBSnapshot.backtestRuns.count, 1)
        XCTAssertEqual(duckDBSnapshot.orderBookResearchRuns.count, 1)
        XCTAssertEqual(duckDBSnapshot.signalTimeline.count, 7)
        XCTAssertTrue(duckDBSnapshot.signalTimeline.allSatisfy { $0.source != .orderBookImbalanceResearch || $0.imbalanceRatio != nil })
    }

    private func makeFullEventLog() throws -> [EventEnvelope] {
        var messageBus = try MessageBus()

        try messageBus.publish(
            .market(.bar(try makeMarketBar(close: 105, start: 100))),
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 201)
        )
        try messageBus.publish(
            .market(.trade(try makeTradeTick())),
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 202)
        )

        let bars = try makeEMAFixtureBars()
        let marketDataQuery = try makeEMAMarketDataQuery()
        let strategy = try makeEMAStrategy()
        let backtestRun = try BacktestEventFlow().run(
            BacktestCommand(
                runID: try Identifier("backtest-ema-fixture"),
                strategy: strategy,
                marketData: marketDataQuery
            ),
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 900)
        )
        for (index, event) in backtestRun.events.enumerated() {
            try messageBus.publish(
                .backtest(event),
                stream: .backtest,
                recordedAt: Date(timeIntervalSince1970: 300 + TimeInterval(index))
            )
        }

        let paperRun = try PaperSessionEventFlow().start(
            PaperSessionCommand(
                sessionID: try Identifier("paper-ema-fixture"),
                strategy: strategy,
                marketData: marketDataQuery,
                riskProfileID: try Identifier("paper-risk"),
                executionMode: .paper
            ),
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 1_000)
        )
        for (index, event) in paperRun.events.enumerated() {
            try messageBus.publish(
                .paper(event),
                stream: .paper,
                recordedAt: Date(timeIntervalSince1970: 400 + TimeInterval(index))
            )
        }

        let researchRun = try OrderBookImbalanceResearchEventFlow().run(
            OrderBookImbalanceResearchCommand(
                researchID: try Identifier("obi-research-fixture"),
                strategy: try makeOrderBookImbalanceStrategy(),
                marketData: try makeOrderBookMarketDataQuery()
            ),
            inputs: try makeOrderBookImbalanceInputs(),
            completedAt: Date(timeIntervalSince1970: 1_300)
        )
        for (index, event) in researchRun.events.enumerated() {
            try messageBus.publish(
                .orderBookImbalanceResearch(event),
                stream: .strategy,
                recordedAt: Date(timeIntervalSince1970: 500 + TimeInterval(index))
            )
        }

        let paperOrderID = try Identifier("paper-order-rejected")
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: paperOrderID,
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.25),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        try messageBus.publish(
            .risk(
                .evaluationRequested(
                    riskQuery
                )
            ),
            stream: .risk,
            recordedAt: Date(timeIntervalSince1970: 1_400)
        )
        try messageBus.publish(
            .risk(
                .blocked(
                    RiskBlockerEvidence(
                        evidenceID: try Identifier("risk-blocker-fixture"),
                        query: riskQuery,
                        reason: .maxPaperQuantityExceeded,
                        generatedAt: Date(timeIntervalSince1970: 1_401)
                    )
                )
            ),
            stream: .risk,
            recordedAt: Date(timeIntervalSince1970: 1_401)
        )

        let portfolioID = try Identifier("portfolio-main")
        try messageBus.publish(
            .portfolio(
                .projectionRequested(
                    PortfolioQuery(
                        portfolioID: portfolioID,
                        asOf: Date(timeIntervalSince1970: 1_499)
                    )
                )
            ),
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 1_499)
        )
        try messageBus.publish(
            .portfolio(
                .exposureUpdated(
                    PortfolioExposureSnapshot(
                        portfolioID: portfolioID,
                        symbol: try Symbol(rawValue: "BTCUSDT"),
                        timeframe: .oneMinute,
                        paperQuantity: try Quantity(1.25),
                        referencePrice: try Price(42_000),
                        source: .paperProjection,
                        observedAt: Date(timeIntervalSince1970: 1_500)
                    )
                )
            ),
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 1_500)
        )

        return messageBus.envelopes
    }

    private func makeTemporaryFileEventLogStore() throws -> FileEventLogStore {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "MTPRO-PersistenceTests-\(UUID().uuidString)",
            isDirectory: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return FileEventLogStore(fileURL: directoryURL.appendingPathComponent("events.jsonl"))
    }

    private func makeTemporarySQLiteRuntimeProjectionAdapter() throws -> SQLiteRuntimeProjectionAdapter {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "MTPRO-SQLiteRuntimeProjectionTests-\(UUID().uuidString)",
            isDirectory: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return SQLiteRuntimeProjectionAdapter(
            databaseURL: directoryURL.appendingPathComponent("runtime.sqlite")
        )
    }

    #if canImport(DuckDB)
    private func makeTemporaryDuckDBAnalyticalProjectionAdapter() throws -> DuckDBAnalyticalProjectionAdapter {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "MTPRO-DuckDBAnalyticalProjectionTests-\(UUID().uuidString)",
            isDirectory: true
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return DuckDBAnalyticalProjectionAdapter(
            databaseURL: directoryURL.appendingPathComponent("analytical.duckdb")
        )
    }
    #endif

    private func makeMarketBar(close: Double = 105, start: TimeInterval = 100) throws -> MarketBar {
        try MarketBar(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try DateRange(
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: start + 60)
            ),
            open: 100,
            high: 110,
            low: 95,
            close: close,
            volume: 42
        )
    }

    private func makeTradeTick() throws -> TradeTick {
        try TradeTick(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            tradedAt: Date(timeIntervalSince1970: 310),
            price: 42_000,
            quantity: 0.25,
            makerSide: .bid
        )
    }

    private func makeEMAStrategy() throws -> EMACrossStrategyConfiguration {
        try EMACrossStrategyConfiguration(
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            shortPeriod: 2,
            longPeriod: 3
        )
    }

    private func makeEMAMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 500)
            )
        )
    }

    private func makeEMAFixtureBars() throws -> [MarketBar] {
        try [10.0, 11.0, 12.0, 11.0, 10.0, 13.0].enumerated().map { index, close in
            let start = 100 + TimeInterval(index * 60)
            return try MarketBar(
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                interval: try DateRange(
                    start: Date(timeIntervalSince1970: start),
                    end: Date(timeIntervalSince1970: start + 60)
                ),
                open: close,
                high: close + 1,
                low: close - 1,
                close: close,
                volume: 1
            )
        }
    }

    private func makeOrderBookLevel(price: Double, quantity: Double) throws -> OrderBookLevel {
        try OrderBookLevel(price: price, quantity: quantity)
    }

    private func makeOrderBookImbalanceStrategy() throws -> OrderBookImbalanceStrategyConfiguration {
        try OrderBookImbalanceStrategyConfiguration(
            strategyID: try Identifier("obi-fixture"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            depth: 2,
            signalThreshold: 0.15
        )
    }

    private func makeOrderBookMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 1_000),
                end: Date(timeIntervalSince1970: 1_200)
            )
        )
    }

    private func makeOrderBookImbalanceInputs() throws -> [OrderBookReadModelInput] {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let bidDominant = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_000),
            bids: [
                try makeOrderBookLevel(price: 100, quantity: 2),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 101, quantity: 1),
                try makeOrderBookLevel(price: 102, quantity: 1)
            ],
            source: .snapshot
        )
        let neutral = try bidDominant.applying(
            OrderBookDelta(
                symbol: symbol,
                observedAt: Date(timeIntervalSince1970: 1_060),
                bidUpdates: [
                    try makeOrderBookLevel(price: 100, quantity: 1)
                ],
                askUpdates: [
                    try makeOrderBookLevel(price: 102, quantity: 0.96078431372549)
                ]
            )
        )
        let askDominant = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_120),
            bids: [
                try makeOrderBookLevel(price: 99, quantity: 1),
                try makeOrderBookLevel(price: 98, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 100, quantity: 2),
                try makeOrderBookLevel(price: 101, quantity: 1)
            ],
            source: .snapshot
        )

        return [askDominant, bidDominant, neutral]
    }
}
