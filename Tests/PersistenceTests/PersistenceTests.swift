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
        XCTAssertEqual(portfolio.state, .updated)
        XCTAssertEqual(portfolio.updatedAt?.timeIntervalSince1970, 1_500)
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
        let lastImbalanceRatio = try XCTUnwrap(snapshot.signalTimeline.last?.imbalanceRatio)
        XCTAssertEqual(lastImbalanceRatio, -0.2088353414, accuracy: 0.0001)
    }

    func testProjectionIsolationKeepsRuntimeAndAnalyticalReadModelsSeparate() throws {
        let envelopes = try makeFullEventLog()
        let sqliteSnapshot = SQLiteRuntimeProjectionStore.project(envelopes)
        let duckDBSnapshot = DuckDBAnalyticalProjectionStore.project(envelopes)

        XCTAssertEqual(sqliteSnapshot.paperSessions.count, 1)
        XCTAssertEqual(sqliteSnapshot.portfolioProjections.count, 1)
        XCTAssertEqual(sqliteSnapshot.rejectedPaperOrderIDs.count, 1)

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
        try messageBus.publish(
            .risk(
                .evaluationRequested(
                    RiskEvaluationQuery(
                        paperOrderID: paperOrderID,
                        symbol: try Symbol(rawValue: "BTCUSDT"),
                        proposedQuantity: 1.25
                    )
                )
            ),
            stream: .risk,
            recordedAt: Date(timeIntervalSince1970: 1_400)
        )
        try messageBus.publish(
            .risk(.rejected(paperOrderID)),
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
            .portfolio(.projectionUpdated(portfolioID)),
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 1_500)
        )

        return messageBus.envelopes
    }

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
        let neutral = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_060),
            bids: [
                try makeOrderBookLevel(price: 100, quantity: 1),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 100, quantity: 1),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            source: .snapshot
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
