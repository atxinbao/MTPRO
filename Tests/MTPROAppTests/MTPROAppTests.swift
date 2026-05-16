import MTPROApp
import MTPROCore
import MTPROPersistence
import XCTest

final class MTPROAppTests: XCTestCase {
    func testDashboardSectionsUseResearchFirstInformationArchitecture() {
        let baseline = MTPROAppBaseline()

        XCTAssertEqual(
            baseline.sections,
            [.market, .strategy, .backtest, .paper, .risk, .portfolio, .events]
        )
    }

    func testDashboardViewModelsUseStableReadModelSourcesOnly() throws {
        let viewModel = try makeDashboardViewModel()

        XCTAssertEqual(
            viewModel.sections,
            [.market, .strategy, .backtest, .paper, .risk, .portfolio, .events]
        )
        XCTAssertTrue(viewModel.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertEqual(viewModel.events.source.sourceKind, .stableReadModelProjection)
        XCTAssertFalse(viewModel.events.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.events.source.exposesORMModels)
        XCTAssertFalse(viewModel.events.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.events.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.events.source.providesLiveOrderAction)
    }

    func testReadModelProjectionMapsAllDashboardSections() throws {
        let viewModel = try makeDashboardViewModel()

        XCTAssertEqual(viewModel.market.symbols, ["BTCUSDT", "ETHUSDT"])
        XCTAssertEqual(viewModel.market.barCount, 2)
        XCTAssertEqual(viewModel.market.tradeCount, 1)
        XCTAssertEqual(viewModel.market.bestBidAskCount, 1)
        XCTAssertEqual(viewModel.market.orderBookSnapshotCount, 1)
        XCTAssertEqual(viewModel.market.orderBookDeltaCount, 1)
        XCTAssertEqual(viewModel.market.latestBarClose, 2_305)
        XCTAssertEqual(viewModel.market.lastAppliedSequence, 12)

        XCTAssertEqual(viewModel.strategy.strategyIDs, ["ema-cross", "obi-fixture"])
        XCTAssertEqual(viewModel.strategy.signalCount, 3)
        XCTAssertEqual(viewModel.strategy.latestSignalDirection, .flat)

        XCTAssertEqual(viewModel.backtest.runs.map(\.runID), ["backtest-ema-fixture"])
        XCTAssertEqual(viewModel.backtest.totalSignalCount, 2)
        XCTAssertEqual(viewModel.backtest.completedRunCount, 1)
        XCTAssertEqual(viewModel.backtest.latestSignalDirection, .flat)

        XCTAssertEqual(viewModel.paper.sessions.map(\.sessionID), ["paper-ema-fixture"])
        XCTAssertEqual(viewModel.paper.sessions.first?.executionMode, .paper)
        XCTAssertEqual(viewModel.paper.completedSessionCount, 1)
        XCTAssertEqual(viewModel.paper.activeSessionCount, 0)

        XCTAssertEqual(viewModel.risk.rejectedPaperOrderIDs, ["paper-order-rejected"])
        XCTAssertEqual(viewModel.risk.rejectionCount, 1)

        XCTAssertEqual(viewModel.portfolio.portfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.portfolio.updatedPortfolioCount, 1)

        XCTAssertEqual(viewModel.events.eventCount, 3)
        XCTAssertEqual(viewModel.events.streams, ["backtest", "market", "paper"])
        XCTAssertEqual(viewModel.events.lastSequence, 3)
    }

    func testDashboardViewModelStateSnapshotIsCodableAndDeterministic() throws {
        let viewModel = try makeDashboardViewModel()

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(MTPRODashboardViewModel.self, from: encoded)

        XCTAssertEqual(decoded, viewModel)
        XCTAssertEqual(decoded.market.section, .market)
        XCTAssertEqual(decoded.backtest.runs.first?.state, .completed)
        XCTAssertEqual(decoded.paper.sessions.first?.state, .completed)
        XCTAssertEqual(decoded.events.lastSequence, 3)
    }

    private func makeDashboardViewModel() throws -> MTPRODashboardViewModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let readModel = MTPRODashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline
        )

        return MTPRODashboardViewModel(readModel: readModel)
    }

    private func makeRuntimeProjection() throws -> MTPROSQLiteRuntimeProjectionSnapshot {
        let sessionID = try MTPROIdentifier("paper-ema-fixture")
        let portfolioID = try MTPROIdentifier("portfolio-main")

        let session = MTPROSQLitePaperSessionProjection(
            sessionID: sessionID,
            strategyID: try MTPROIdentifier("ema-cross"),
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            riskProfileID: try MTPROIdentifier("paper-risk"),
            executionMode: .paper,
            state: .completed,
            signalCount: 2,
            requestedAt: Date(timeIntervalSince1970: 900),
            completedAt: Date(timeIntervalSince1970: 1_000),
            lastUpdatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let portfolio = MTPROSQLitePortfolioProjection(
            portfolioID: portfolioID,
            state: .updated,
            requestedAt: Date(timeIntervalSince1970: 1_100),
            updatedAt: Date(timeIntervalSince1970: 1_120),
            lastUpdatedAt: Date(timeIntervalSince1970: 1_120)
        )

        return MTPROSQLiteRuntimeProjectionSnapshot(
            paperSessions: [sessionID: session],
            rejectedPaperOrderIDs: [try MTPROIdentifier("paper-order-rejected")],
            portfolioProjections: [portfolioID: portfolio],
            lastAppliedSequence: 11
        )
    }

    private func makeAnalyticalProjection() throws -> MTPRODuckDBAnalyticalProjectionSnapshot {
        let backtestRunID = try MTPROIdentifier("backtest-ema-fixture")
        let backtest = MTPRODuckDBBacktestProjection(
            runID: backtestRunID,
            strategyID: try MTPROIdentifier("ema-cross"),
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            state: .completed,
            signalCount: 2,
            completedAt: Date(timeIntervalSince1970: 800)
        )
        let researchID = try MTPROIdentifier("obi-research-fixture")
        let research = MTPRODuckDBOrderBookResearchProjection(
            researchID: researchID,
            strategyID: try MTPROIdentifier("obi-fixture"),
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            depth: 2,
            state: .completed,
            signalCount: 1,
            completedAt: Date(timeIntervalSince1970: 1_300)
        )

        return MTPRODuckDBAnalyticalProjectionSnapshot(
            marketBars: [
                try makeMarketBar(symbol: "BTCUSDT", close: 42_050, start: 100),
                try makeMarketBar(symbol: "ETHUSDT", close: 2_305, start: 160)
            ],
            trades: [try makeTradeTick()],
            bestBidAsks: [try makeBestBidAsk()],
            orderBookSnapshots: [try makeOrderBookSnapshot()],
            orderBookDeltas: [try makeOrderBookDelta()],
            backtestRuns: [backtestRunID: backtest],
            orderBookResearchRuns: [researchID: research],
            signalTimeline: [
                MTPRODuckDBSignalTimelineProjection(
                    source: .backtest,
                    strategyID: try MTPROIdentifier("ema-cross"),
                    symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                    timeframe: .oneMinute,
                    generatedAt: Date(timeIntervalSince1970: 280),
                    direction: .long,
                    close: 12,
                    shortEMA: 11.5,
                    longEMA: 11.25
                ),
                MTPRODuckDBSignalTimelineProjection(
                    source: .backtest,
                    strategyID: try MTPROIdentifier("ema-cross"),
                    symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                    timeframe: .oneMinute,
                    generatedAt: Date(timeIntervalSince1970: 340),
                    direction: .flat,
                    close: 10,
                    shortEMA: 10.5,
                    longEMA: 10.75
                ),
                MTPRODuckDBSignalTimelineProjection(
                    source: .orderBookImbalanceResearch,
                    strategyID: try MTPROIdentifier("obi-fixture"),
                    symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                    timeframe: .oneMinute,
                    generatedAt: Date(timeIntervalSince1970: 1_000),
                    direction: .flat,
                    bidNotional: 198,
                    askNotional: 300,
                    imbalanceRatio: -0.2048
                )
            ],
            lastAppliedSequence: 12
        )
    }

    private func makeEventTimeline() throws -> [EventEnvelope] {
        [
            try EventEnvelope(
                sequence: 1,
                stream: .market,
                recordedAt: Date(timeIntervalSince1970: 201),
                event: .market(.bar(try makeMarketBar(symbol: "BTCUSDT", close: 42_050, start: 100)))
            ),
            try EventEnvelope(
                sequence: 2,
                stream: .backtest,
                recordedAt: Date(timeIntervalSince1970: 300),
                event: .backtest(
                    .requested(
                        BacktestCommand(
                            runID: try MTPROIdentifier("backtest-ema-fixture"),
                            strategy: try makeEMAStrategy(),
                            marketData: try makeEMAMarketDataQuery()
                        )
                    )
                )
            ),
            try EventEnvelope(
                sequence: 3,
                stream: .paper,
                recordedAt: Date(timeIntervalSince1970: 400),
                event: .paper(
                    .sessionRequested(
                        try PaperSessionCommand(
                            sessionID: try MTPROIdentifier("paper-ema-fixture"),
                            strategy: try makeEMAStrategy(),
                            marketData: try makeEMAMarketDataQuery(),
                            riskProfileID: try MTPROIdentifier("paper-risk"),
                            executionMode: .paper
                        )
                    )
                )
            )
        ]
    }

    private func makeMarketBar(symbol: String, close: Double, start: TimeInterval) throws -> MTPROMarketBar {
        try MTPROMarketBar(
            symbol: try MTPROSymbol(rawValue: symbol),
            timeframe: .oneMinute,
            interval: try MTPRODateRange(
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: start + 60)
            ),
            open: close - 10,
            high: close + 10,
            low: close - 20,
            close: close,
            volume: 42
        )
    }

    private func makeTradeTick() throws -> MTPROTradeTick {
        try MTPROTradeTick(
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            tradedAt: Date(timeIntervalSince1970: 220),
            price: 42_010,
            quantity: 0.25,
            makerSide: .bid
        )
    }

    private func makeBestBidAsk() throws -> MTPROBestBidAsk {
        try MTPROBestBidAsk(
            symbol: MTPROSymbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 230),
            bid: MTPROOrderBookLevel(price: 42_000, quantity: 1.25),
            ask: MTPROOrderBookLevel(price: 42_001, quantity: 0.75)
        )
    }

    private func makeOrderBookSnapshot() throws -> MTPROOrderBookSnapshot {
        try MTPROOrderBookSnapshot(
            symbol: MTPROSymbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 240),
            bids: [MTPROOrderBookLevel(price: 42_000, quantity: 1)],
            asks: [MTPROOrderBookLevel(price: 42_001, quantity: 1)]
        )
    }

    private func makeOrderBookDelta() throws -> MTPROOrderBookDelta {
        try MTPROOrderBookDelta(
            symbol: MTPROSymbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 250),
            bidUpdates: [MTPROOrderBookLevel(price: 42_000, quantity: 1.5)],
            askUpdates: [MTPROOrderBookLevel(price: 42_002, quantity: 0.5)]
        )
    }

    private func makeEMAStrategy() throws -> MTPROEMACrossStrategyConfiguration {
        try MTPROEMACrossStrategyConfiguration(
            strategyID: try MTPROIdentifier("ema-cross"),
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            shortPeriod: 2,
            longPeriod: 3
        )
    }

    private func makeEMAMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try MTPRODateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 500)
            )
        )
    }
}
