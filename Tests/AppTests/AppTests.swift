import App
import Core
import Persistence
import XCTest

final class AppTests: XCTestCase {
    func testDashboardSectionsUseResearchFirstInformationArchitecture() {
        let baseline = AppBaseline()

        XCTAssertEqual(
            baseline.sections,
            [.market, .strategy, .backtest, .report, .paper, .risk, .portfolio, .events]
        )
    }

    func testDashboardViewModelsUseStableReadModelSourcesOnly() throws {
        let viewModel = try makeDashboardViewModel()

        XCTAssertEqual(
            viewModel.sections,
            [.market, .strategy, .backtest, .report, .paper, .risk, .portfolio, .events]
        )
        XCTAssertTrue(viewModel.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertEqual(viewModel.report.source.sourceKind, .stableReadModelProjection)
        XCTAssertFalse(viewModel.report.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.source.providesLiveOrderAction)
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

        XCTAssertEqual(viewModel.report.artifactCount, 1)
        XCTAssertEqual(viewModel.report.completedBacktestCount, 1)
        XCTAssertEqual(viewModel.report.researchRunCount, 1)
        XCTAssertEqual(viewModel.report.paperSessionCount, 1)
        XCTAssertEqual(viewModel.report.matchedParityEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.latestParityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(viewModel.report.lastAppliedSequence, 12)
        XCTAssertFalse(viewModel.report.authorizesTradingExecution)
        let report = try XCTUnwrap(viewModel.report.artifacts.first)
        XCTAssertEqual(report.reportID, "report-backtest-ema-fixture")
        XCTAssertEqual(report.backtestRunID, "backtest-ema-fixture")
        XCTAssertEqual(report.backtestState, .completed)
        XCTAssertEqual(report.researchIDs, ["obi-research-fixture"])
        XCTAssertEqual(report.paperSessionIDs, ["paper-ema-fixture"])
        XCTAssertEqual(report.strategyIDs, ["ema-cross", "obi-fixture"])
        XCTAssertEqual(report.symbol, "BTCUSDT")
        XCTAssertEqual(report.timeframe, "1m")
        XCTAssertEqual(report.backtestSignalCount, 2)
        XCTAssertEqual(report.researchSignalCount, 1)
        XCTAssertEqual(report.paperSignalCount, 2)
        XCTAssertEqual(report.eventCount, 3)
        XCTAssertEqual(report.parityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(report.executionAuthorization, .researchOutputOnly)
        XCTAssertFalse(report.authorizesTradingExecution)

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
        let decoded = try JSONDecoder().decode(DashboardViewModel.self, from: encoded)

        XCTAssertEqual(decoded, viewModel)
        XCTAssertEqual(decoded.market.section, .market)
        XCTAssertEqual(decoded.backtest.runs.first?.state, .completed)
        XCTAssertEqual(decoded.report.artifacts.first?.parityStatus, .matchedProjectionEvidence)
        XCTAssertFalse(decoded.report.authorizesTradingExecution)
        XCTAssertEqual(decoded.paper.sessions.first?.state, .completed)
        XCTAssertEqual(decoded.events.lastSequence, 3)
    }

    func testReportReadModelMarksMissingPaperProjectionWithoutLiveFallback() throws {
        // 测试场景：MTP-23 报告只能从 projection snapshot / read model 生成。
        // 当 Paper 投影缺失时，报告必须给出缺失证据状态，不能退回 Live、broker 或真实订单路径。
        let report = ReportReadModel(
            analyticalProjection: try makeAnalyticalProjection(),
            runtimeProjection: SQLiteRuntimeProjectionSnapshot(),
            eventTimeline: try makeEventTimeline()
        )
        let artifact = try XCTUnwrap(report.artifacts.first)

        XCTAssertEqual(artifact.parityStatus, .missingPaperProjection)
        XCTAssertEqual(artifact.executionAuthorization, .researchOutputOnly)
        XCTAssertFalse(artifact.authorizesTradingExecution)
        XCTAssertEqual(artifact.paperSessionIDs, [])
    }

    @MainActor
    func testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell() throws {
        // 测试场景：MTP-22 macOS 看板壳必须把现有 DashboardViewModel 快照绑定到七个只读区域，
        // 且每个区域继续保留 read-model-only 来源证据，不能新增交易控制或外部 adapter 调用。
        let viewModel = try makeDashboardViewModel()
        let shell = DashboardShellView(viewModel: viewModel)
        let snapshot = shell.snapshot

        XCTAssertEqual(snapshot.title, "MTPRO Research Workbench")
        XCTAssertEqual(snapshot.subtitle, "Research -> Backtest -> Report")
        XCTAssertEqual(snapshot.sections.map(\.section), viewModel.sections)
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.viewModelSources.allSatisfy(\.isReadModelOnly))

        let market = try XCTUnwrap(snapshot.sections.first { $0.section == .market })
        XCTAssertEqual(metricValue("Symbols", in: market), "2")
        XCTAssertEqual(metricValue("Bars", in: market), "2")
        XCTAssertEqual(metricValue("Latest close", in: market), "2305.00")
        XCTAssertTrue(market.details.contains("Universe: BTCUSDT, ETHUSDT"))

        let backtest = try XCTUnwrap(snapshot.sections.first { $0.section == .backtest })
        XCTAssertEqual(metricValue("Runs", in: backtest), "1")
        XCTAssertEqual(metricValue("Signals", in: backtest), "2")

        let report = try XCTUnwrap(snapshot.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Reports", in: report), "1")
        XCTAssertEqual(metricValue("Backtests", in: report), "1")
        XCTAssertEqual(metricValue("Research", in: report), "1")
        XCTAssertEqual(metricValue("Parity", in: report), "1")
        XCTAssertTrue(report.details.contains("Report IDs: report-backtest-ema-fixture"))
        XCTAssertTrue(report.details.contains("Execution: research-only"))
        XCTAssertTrue(report.details.contains("Latest parity: matched projection evidence"))

        let paper = try XCTUnwrap(snapshot.sections.first { $0.section == .paper })
        XCTAssertEqual(metricValue("Sessions", in: paper), "1")
        XCTAssertEqual(metricValue("Completed", in: paper), "1")

        XCTAssertTrue(snapshot.smokeSummary.contains("sections=8"))
        XCTAssertTrue(snapshot.smokeSummary.contains("readModelOnly=true"))
    }

    func testDashboardShellInitialSnapshotIsEmptyReadModelProjection() {
        // 测试场景：可运行 macOS shell 的默认快照只能表示空 read model projection，
        // 不能伪造行情、Paper、Risk、Portfolio 或事件事实。
        let snapshot = DashboardShellSnapshot(viewModel: .emptyResearchWorkbench)

        XCTAssertEqual(snapshot.sections.map(\.section), DashboardSection.allCases)
        XCTAssertTrue(snapshot.isReadModelOnly)

        let market = snapshot.sections.first { $0.section == .market }
        XCTAssertEqual(market?.metrics.first { $0.label == "Symbols" }?.value, "0")
        XCTAssertEqual(market?.metrics.first { $0.label == "Bars" }?.value, "0")
        XCTAssertEqual(market?.metrics.first { $0.label == "Latest close" }?.value, "n/a")

        let report = snapshot.sections.first { $0.section == .report }
        XCTAssertEqual(report?.metrics.first { $0.label == "Reports" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Parity" }?.value, "0")

        let events = snapshot.sections.first { $0.section == .events }
        XCTAssertEqual(events?.metrics.first { $0.label == "Events" }?.value, "0")
        XCTAssertEqual(events?.metrics.first { $0.label == "Last sequence" }?.value, "n/a")
    }

    func testDashboardShellSourceDoesNotImportForbiddenIntegrationLayers() throws {
        // 测试场景：SwiftUI shell 文件只能消费 App 层 ViewModel，不能导入 Runtime / Adapters，
        // 也不能直接引用数据库实现名或 public market data client 类型。
        let shellSource = try String(contentsOf: sourceFile("Sources/App/DashboardShell.swift"))
        let executableSource = try String(
            contentsOf: sourceFile("Sources/MTPRODashboard/MTPRODashboardApplication.swift")
        )

        XCTAssertFalse(shellSource.contains("import Runtime"))
        XCTAssertFalse(shellSource.contains("import Adapters"))
        XCTAssertFalse(shellSource.contains("BinancePublic"))
        XCTAssertFalse(shellSource.contains("SQLite"))
        XCTAssertFalse(shellSource.contains("DuckDB"))

        XCTAssertFalse(executableSource.contains("import Runtime"))
        XCTAssertFalse(executableSource.contains("import Adapters"))
        XCTAssertFalse(executableSource.contains("BinancePublic"))
        XCTAssertFalse(executableSource.contains("SQLite"))
        XCTAssertFalse(executableSource.contains("DuckDB"))
    }

    private func makeDashboardViewModel() throws -> DashboardViewModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline
        )

        return DashboardViewModel(readModel: readModel)
    }

    private func metricValue(
        _ label: String,
        in section: DashboardShellSectionSnapshot
    ) -> String? {
        section.metrics.first { $0.label == label }?.value
    }

    private func sourceFile(_ relativePath: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(relativePath)
    }

    private func makeRuntimeProjection() throws -> SQLiteRuntimeProjectionSnapshot {
        let sessionID = try Identifier("paper-ema-fixture")
        let portfolioID = try Identifier("portfolio-main")

        let session = SQLitePaperSessionProjection(
            sessionID: sessionID,
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper,
            state: .completed,
            signalCount: 2,
            requestedAt: Date(timeIntervalSince1970: 900),
            completedAt: Date(timeIntervalSince1970: 1_000),
            lastUpdatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let portfolio = SQLitePortfolioProjection(
            portfolioID: portfolioID,
            state: .updated,
            requestedAt: Date(timeIntervalSince1970: 1_100),
            updatedAt: Date(timeIntervalSince1970: 1_120),
            lastUpdatedAt: Date(timeIntervalSince1970: 1_120)
        )

        return SQLiteRuntimeProjectionSnapshot(
            paperSessions: [sessionID: session],
            rejectedPaperOrderIDs: [try Identifier("paper-order-rejected")],
            portfolioProjections: [portfolioID: portfolio],
            lastAppliedSequence: 11
        )
    }

    private func makeAnalyticalProjection() throws -> DuckDBAnalyticalProjectionSnapshot {
        let backtestRunID = try Identifier("backtest-ema-fixture")
        let backtest = DuckDBBacktestProjection(
            runID: backtestRunID,
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            state: .completed,
            signalCount: 2,
            completedAt: Date(timeIntervalSince1970: 800)
        )
        let researchID = try Identifier("obi-research-fixture")
        let research = DuckDBOrderBookResearchProjection(
            researchID: researchID,
            strategyID: try Identifier("obi-fixture"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            depth: 2,
            state: .completed,
            signalCount: 1,
            completedAt: Date(timeIntervalSince1970: 1_300)
        )

        return DuckDBAnalyticalProjectionSnapshot(
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
                DuckDBSignalTimelineProjection(
                    source: .backtest,
                    strategyID: try Identifier("ema-cross"),
                    symbol: try Symbol(rawValue: "BTCUSDT"),
                    timeframe: .oneMinute,
                    generatedAt: Date(timeIntervalSince1970: 280),
                    direction: .long,
                    close: 12,
                    shortEMA: 11.5,
                    longEMA: 11.25
                ),
                DuckDBSignalTimelineProjection(
                    source: .backtest,
                    strategyID: try Identifier("ema-cross"),
                    symbol: try Symbol(rawValue: "BTCUSDT"),
                    timeframe: .oneMinute,
                    generatedAt: Date(timeIntervalSince1970: 340),
                    direction: .flat,
                    close: 10,
                    shortEMA: 10.5,
                    longEMA: 10.75
                ),
                DuckDBSignalTimelineProjection(
                    source: .orderBookImbalanceResearch,
                    strategyID: try Identifier("obi-fixture"),
                    symbol: try Symbol(rawValue: "BTCUSDT"),
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
                            runID: try Identifier("backtest-ema-fixture"),
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
                            sessionID: try Identifier("paper-ema-fixture"),
                            strategy: try makeEMAStrategy(),
                            marketData: try makeEMAMarketDataQuery(),
                            riskProfileID: try Identifier("paper-risk"),
                            executionMode: .paper
                        )
                    )
                )
            )
        ]
    }

    private func makeMarketBar(symbol: String, close: Double, start: TimeInterval) throws -> MarketBar {
        try MarketBar(
            symbol: try Symbol(rawValue: symbol),
            timeframe: .oneMinute,
            interval: try DateRange(
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

    private func makeTradeTick() throws -> TradeTick {
        try TradeTick(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            tradedAt: Date(timeIntervalSince1970: 220),
            price: 42_010,
            quantity: 0.25,
            makerSide: .bid
        )
    }

    private func makeBestBidAsk() throws -> BestBidAsk {
        try BestBidAsk(
            symbol: Symbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 230),
            bid: OrderBookLevel(price: 42_000, quantity: 1.25),
            ask: OrderBookLevel(price: 42_001, quantity: 0.75)
        )
    }

    private func makeOrderBookSnapshot() throws -> OrderBookSnapshot {
        try OrderBookSnapshot(
            symbol: Symbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 240),
            bids: [OrderBookLevel(price: 42_000, quantity: 1)],
            asks: [OrderBookLevel(price: 42_001, quantity: 1)]
        )
    }

    private func makeOrderBookDelta() throws -> OrderBookDelta {
        try OrderBookDelta(
            symbol: Symbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 250),
            bidUpdates: [OrderBookLevel(price: 42_000, quantity: 1.5)],
            askUpdates: [OrderBookLevel(price: 42_002, quantity: 0.5)]
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
}
