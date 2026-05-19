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
        XCTAssertEqual(viewModel.backtest.totalSignalCount, 4)
        XCTAssertEqual(viewModel.backtest.completedRunCount, 1)
        XCTAssertEqual(viewModel.backtest.latestSignalDirection, .flat)

        XCTAssertEqual(viewModel.report.artifactCount, 1)
        XCTAssertEqual(viewModel.report.completedBacktestCount, 1)
        XCTAssertEqual(viewModel.report.researchRunCount, 1)
        XCTAssertEqual(viewModel.report.paperSessionCount, 1)
        XCTAssertEqual(viewModel.report.matchedParityEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.tradingValidationEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.executionCostEvidenceCount, 2)
        XCTAssertEqual(viewModel.report.executionCostAssumptionIDs, ["mtp-27-fixed-cost-assumptions"])
        XCTAssertTrue(viewModel.report.executionCostParityConsistent)
        XCTAssertEqual(viewModel.report.riskBlockerEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.riskBlockerEvidenceIDs, ["risk-blocker-paper-replay-proposal-blocked"])
        XCTAssertEqual(viewModel.report.portfolioExposureEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.portfolioExposureSymbols, ["BTCUSDT"])
        XCTAssertEqual(viewModel.report.portfolioGrossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.report.paperRuntimeEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.paperRuntimeSessionIDs, ["paper-replay-session"])
        XCTAssertEqual(viewModel.report.paperRuntimeLifecycleStates, ["started", "updated", "closed"])
        XCTAssertEqual(
            viewModel.report.paperRuntimeProposalIDs,
            ["paper-replay-proposal", "paper-replay-proposal-blocked"]
        )
        XCTAssertEqual(
            viewModel.report.paperRuntimeRiskBlockerEvidenceIDs,
            ["risk-blocker-paper-replay-proposal-blocked"]
        )
        XCTAssertEqual(viewModel.report.paperRuntimePortfolioUpdateIDs, ["paper-replay-portfolio-update"])
        XCTAssertEqual(viewModel.report.paperRuntimePortfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.report.paperRuntimeReplaySequenceCount, 13)
        XCTAssertEqual(viewModel.report.paperRuntimeReplayStreams, ["paper", "portfolio", "risk"])
        XCTAssertTrue(viewModel.report.paperRuntimeCoversSessionEvents)
        XCTAssertTrue(viewModel.report.paperRuntimeCoversProposalEvents)
        XCTAssertTrue(viewModel.report.paperRuntimeCoversRiskBlockerEvents)
        XCTAssertTrue(viewModel.report.paperRuntimeCoversPortfolioProjectionEvents)
        XCTAssertTrue(viewModel.report.paperRuntimeReplayDeterministic)
        XCTAssertTrue(viewModel.report.paperRuntimePaperOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.paperRuntimeAuthorizesLiveTrading)
        XCTAssertFalse(viewModel.report.paperRuntimeTouchesBrokerAction)
        XCTAssertFalse(viewModel.report.paperRuntimeAuthorizesTradingExecution)
        XCTAssertEqual(viewModel.report.latestParityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(viewModel.report.lastAppliedSequence, 13)
        XCTAssertFalse(viewModel.report.tradingValidationAuthorizesExecution)
        XCTAssertFalse(viewModel.report.authorizesTradingExecution)
        let report = try XCTUnwrap(viewModel.report.artifacts.first)
        XCTAssertEqual(report.reportID, "report-backtest-ema-fixture")
        XCTAssertEqual(report.backtestRunID, "backtest-ema-fixture")
        XCTAssertEqual(report.backtestState, .completed)
        XCTAssertEqual(report.researchIDs, ["obi-research-fixture"])
        XCTAssertEqual(report.paperSessionIDs, ["paper-replay-session"])
        XCTAssertEqual(report.strategyIDs, ["ema-cross", "obi-fixture"])
        XCTAssertEqual(report.symbol, "BTCUSDT")
        XCTAssertEqual(report.timeframe, "1m")
        XCTAssertEqual(report.backtestSignalCount, 4)
        XCTAssertEqual(report.researchSignalCount, 1)
        XCTAssertEqual(report.paperSignalCount, 4)
        XCTAssertEqual(report.eventCount, 13)
        XCTAssertEqual(report.parityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(report.executionAuthorization, .researchOutputOnly)
        XCTAssertFalse(report.authorizesTradingExecution)
        XCTAssertEqual(report.tradingValidationEvidence.parityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(report.tradingValidationEvidence.executionCostEvidenceCount, 2)
        XCTAssertTrue(report.tradingValidationEvidence.executionCostParityConsistent)
        XCTAssertEqual(
            report.tradingValidationEvidence.riskBlockerEvidenceIDs,
            ["risk-blocker-paper-replay-proposal-blocked"]
        )
        XCTAssertEqual(report.tradingValidationEvidence.riskBlockerReasons, [.maxPaperQuantityExceeded])
        XCTAssertEqual(report.tradingValidationEvidence.portfolioExposureSymbols, ["BTCUSDT"])
        XCTAssertEqual(report.tradingValidationEvidence.portfolioExposureCount, 1)
        XCTAssertEqual(
            report.tradingValidationEvidence.portfolioGrossExposureNotional,
            50,
            accuracy: 0.00000001
        )
        XCTAssertEqual(report.tradingValidationEvidence.sourceSequences, [8, 13])
        XCTAssertFalse(report.tradingValidationEvidence.authorizesTradingExecution)
        XCTAssertEqual(report.paperRuntimeEvidence.factsSource, "append-only event log replay")
        XCTAssertTrue(report.paperRuntimeEvidence.replayAvailable)
        XCTAssertEqual(report.paperRuntimeEvidence.replayedSequences, Array(1...13))
        XCTAssertEqual(report.paperRuntimeEvidence.replayedStreams, ["paper", "portfolio", "risk"])
        XCTAssertEqual(report.paperRuntimeEvidence.lifecycleStates, [.started, .updated, .closed])
        XCTAssertEqual(report.paperRuntimeEvidence.signalEventCount, 4)
        XCTAssertEqual(report.paperRuntimeEvidence.proposalCount, 2)
        XCTAssertEqual(report.paperRuntimeEvidence.portfolioExposureCount, 1)
        XCTAssertEqual(report.paperRuntimeEvidence.portfolioGrossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(report.paperRuntimeEvidence.sourceSequences, Array(1...13))
        XCTAssertTrue(report.paperRuntimeEvidence.appendOnlyFactsSourceIsReplaySource)
        XCTAssertTrue(report.paperRuntimeEvidence.paperOnlyBoundaryHeld)
        XCTAssertFalse(report.paperRuntimeEvidence.authorizesTradingExecution)
        let makerCost = try XCTUnwrap(
            report.tradingValidationEvidence.executionCostEvidence.first {
                $0.liquidityRole == .maker
            }
        )
        XCTAssertEqual(makerCost.assumptionID, "mtp-27-fixed-cost-assumptions")
        XCTAssertEqual(makerCost.grossNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(makerCost.feeAmount, 0.01, accuracy: 0.00000001)
        XCTAssertEqual(makerCost.slippageAmount, 0.0075, accuracy: 0.00000001)
        XCTAssertEqual(makerCost.backtestTotalCostAmount, 0.0175, accuracy: 0.00000001)
        XCTAssertEqual(makerCost.paperTotalCostAmount, 0.0175, accuracy: 0.00000001)
        XCTAssertTrue(makerCost.parityConsistent)

        XCTAssertEqual(viewModel.paper.sessions.map(\.sessionID), ["paper-replay-session"])
        XCTAssertEqual(viewModel.paper.sessions.first?.executionMode, .paper)
        XCTAssertEqual(viewModel.paper.completedSessionCount, 1)
        XCTAssertEqual(viewModel.paper.activeSessionCount, 0)

        XCTAssertEqual(viewModel.risk.rejectedPaperOrderIDs, ["paper-replay-proposal-blocked"])
        XCTAssertEqual(viewModel.risk.rejectionCount, 1)
        XCTAssertEqual(viewModel.risk.evidence.first?.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(viewModel.risk.evidence.first?.riskProfileID, "paper-risk")
        XCTAssertEqual(viewModel.risk.evidence.first?.symbol, "BTCUSDT")
        XCTAssertEqual(viewModel.risk.evidence.first?.sourceSequence, 13)

        XCTAssertEqual(viewModel.portfolio.portfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.portfolio.updatedPortfolioCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposureCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposures.first?.symbol, "BTCUSDT")
        XCTAssertEqual(viewModel.portfolio.exposures.first?.source, .paperProjection)
        XCTAssertEqual(viewModel.portfolio.totalGrossExposureNotional, 50, accuracy: 0.00000001)

        XCTAssertEqual(viewModel.events.eventCount, 13)
        XCTAssertEqual(viewModel.events.streams, ["paper", "portfolio", "risk"])
        XCTAssertEqual(viewModel.events.lastSequence, 13)
    }

    func testDashboardViewModelStateSnapshotIsCodableAndDeterministic() throws {
        let viewModel = try makeDashboardViewModel()

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(DashboardViewModel.self, from: encoded)

        XCTAssertEqual(decoded, viewModel)
        XCTAssertEqual(decoded.market.section, .market)
        XCTAssertEqual(decoded.backtest.runs.first?.state, .completed)
        XCTAssertEqual(decoded.report.artifacts.first?.parityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(decoded.report.artifacts.first?.paperRuntimeEvidence.proposalCount, 2)
        XCTAssertTrue(decoded.report.paperRuntimePaperOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.authorizesTradingExecution)
        XCTAssertEqual(decoded.paper.sessions.first?.state, .closed)
        XCTAssertEqual(decoded.events.lastSequence, 13)
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
        XCTAssertEqual(artifact.tradingValidationEvidence.executionCostEvidenceCount, 0)
        XCTAssertFalse(artifact.tradingValidationEvidence.executionCostParityConsistent)
        XCTAssertEqual(artifact.tradingValidationEvidence.riskBlockerEvidenceIDs, [])
        XCTAssertEqual(artifact.tradingValidationEvidence.portfolioExposureSymbols, [])
        XCTAssertFalse(artifact.tradingValidationEvidence.authorizesTradingExecution)
    }

    func testPortfolioViewModelConsumesPaperPortfolioUpdateProjectionReadOnly() throws {
        // 测试场景：MTP-34 的 portfolio update path 到达 App 层时只能是 SQLite runtime snapshot
        // 派生的 read model；ViewModel 不得直连 schema、runtime object、broker 或交易动作。
        let decision = try PaperActionProposalRiskFixture.deterministicAllowed()
        let update = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            decision: decision,
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )
        let envelope = try EventEnvelope(
            sequence: 12,
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 1_901),
            event: .portfolio(.paperProjectionUpdated(update))
        )
        let exposure = SQLitePortfolioExposureProjection(update: update, envelope: envelope)
        let portfolio = SQLitePortfolioProjection(
            portfolioID: update.portfolioID,
            state: .updated,
            requestedAt: nil,
            updatedAt: envelope.recordedAt,
            lastUpdatedAt: envelope.recordedAt,
            exposures: [exposure]
        )
        let runtimeProjection = SQLiteRuntimeProjectionSnapshot(
            portfolioProjections: [update.portfolioID: portfolio],
            lastAppliedSequence: envelope.sequence
        )
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: DuckDBAnalyticalProjectionSnapshot(),
            eventTimeline: [envelope]
        )
        let viewModel = DashboardViewModel(readModel: readModel)

        XCTAssertTrue(viewModel.portfolio.source.isReadModelOnly)
        XCTAssertFalse(viewModel.portfolio.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.portfolio.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.portfolio.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.portfolio.source.providesLiveOrderAction)
        XCTAssertEqual(viewModel.portfolio.portfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.portfolio.updatedPortfolioCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposureCount, 1)
        let exposureViewModel = try XCTUnwrap(viewModel.portfolio.exposures.first)
        XCTAssertEqual(exposureViewModel.paperQuantity, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(exposureViewModel.referencePrice, 100, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.portfolio.totalGrossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(exposureViewModel.sourceSequence, decision.sourceSequence)
        XCTAssertEqual(viewModel.events.streams, ["portfolio"])
    }

    @MainActor
    func testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell() throws {
        // 测试场景：macOS 看板壳必须把现有 DashboardViewModel 快照绑定到八个只读区域，
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
        XCTAssertEqual(metricValue("Signals", in: backtest), "4")

        let report = try XCTUnwrap(snapshot.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Reports", in: report), "1")
        XCTAssertEqual(metricValue("Parity", in: report), "1")
        XCTAssertEqual(metricValue("Cost evidence", in: report), "2")
        XCTAssertEqual(metricValue("Risk blockers", in: report), "1")
        XCTAssertEqual(metricValue("Exposure", in: report), "1")
        XCTAssertEqual(metricValue("Runtime", in: report), "1")
        XCTAssertEqual(metricValue("Replay facts", in: report), "13")
        XCTAssertTrue(report.details.contains("Report IDs: report-backtest-ema-fixture"))
        XCTAssertTrue(report.details.contains("Cost assumptions: mtp-27-fixed-cost-assumptions"))
        XCTAssertTrue(report.details.contains("Cost parity: consistent"))
        XCTAssertTrue(report.details.contains("Risk blocker evidence: risk-blocker-paper-replay-proposal-blocked"))
        XCTAssertTrue(report.details.contains("Exposure symbols: BTCUSDT"))
        XCTAssertTrue(report.details.contains("Gross exposure: 50.00"))
        XCTAssertTrue(report.details.contains("Runtime sessions: paper-replay-session"))
        XCTAssertTrue(report.details.contains("Lifecycle: started, updated, closed"))
        XCTAssertTrue(report.details.contains("Proposals: paper-replay-proposal, paper-replay-proposal-blocked"))
        XCTAssertTrue(report.details.contains("Runtime blockers: risk-blocker-paper-replay-proposal-blocked"))
        XCTAssertTrue(report.details.contains("Portfolio updates: paper-replay-portfolio-update"))
        XCTAssertTrue(report.details.contains("Replay streams: paper, portfolio, risk"))
        XCTAssertTrue(report.details.contains("Runtime boundary: paper-only"))
        XCTAssertTrue(report.details.contains("Replay deterministic: confirmed"))
        XCTAssertTrue(report.details.contains("Trading validation execution: research-only"))
        XCTAssertTrue(report.details.contains("Execution: research-only"))
        XCTAssertTrue(report.details.contains("Latest parity: matched projection evidence"))

        let paper = try XCTUnwrap(snapshot.sections.first { $0.section == .paper })
        XCTAssertEqual(metricValue("Sessions", in: paper), "1")
        XCTAssertEqual(metricValue("Completed", in: paper), "1")

        let risk = try XCTUnwrap(snapshot.sections.first { $0.section == .risk })
        XCTAssertEqual(metricValue("Blockers", in: risk), "1")
        XCTAssertTrue(risk.details.contains("Reasons: maxPaperQuantityExceeded"))

        let portfolio = try XCTUnwrap(snapshot.sections.first { $0.section == .portfolio })
        XCTAssertEqual(metricValue("Exposures", in: portfolio), "1")
        XCTAssertEqual(metricValue("Gross exposure", in: portfolio), "50.00")
        XCTAssertTrue(portfolio.details.contains("Exposure symbols: BTCUSDT"))

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
        XCTAssertEqual(report?.metrics.first { $0.label == "Cost evidence" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Risk blockers" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Exposure" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Runtime" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Replay facts" }?.value, "0")

        let events = snapshot.sections.first { $0.section == .events }
        XCTAssertEqual(events?.metrics.first { $0.label == "Events" }?.value, "0")
        XCTAssertEqual(events?.metrics.first { $0.label == "Last sequence" }?.value, "n/a")
    }

    func testDashboardShellSourceDoesNotImportForbiddenIntegrationLayers() throws {
        // 测试场景：SwiftUI shell 文件只能消费 App 层 ViewModel，不能导入 Runtime / Adapters，
        // 也不能直接引用数据库实现名或 public market data client 类型。
        let shellSource = try String(contentsOf: sourceFile("Sources/App/DashboardShell.swift"))
        let executableSource = try String(
            contentsOf: sourceFile("Sources/Dashboard/DashboardApplication.swift")
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
        // 测试场景：App 层 fixture 复用 MTP-35 的 append-only replay facts，
        // 确认 Report / Dashboard 只消费 runtime projection 和 event timeline，不手写交易执行状态。
        try SQLiteRuntimeProjectionStore.project(PaperSessionReplayFixture.deterministicEventLog().envelopes)
    }

    private func makeAnalyticalProjection() throws -> DuckDBAnalyticalProjectionSnapshot {
        let backtestRunID = try Identifier("backtest-ema-fixture")
        let backtest = DuckDBBacktestProjection(
            runID: backtestRunID,
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            state: .completed,
            signalCount: 4,
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
        // 测试场景：Report runtime evidence 必须来自可 replay 的 append-only facts source；
        // 该 deterministic timeline 覆盖 lifecycle、proposal、risk blocker 和 portfolio update。
        try PaperSessionReplayFixture.deterministicEventLog().envelopes
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
