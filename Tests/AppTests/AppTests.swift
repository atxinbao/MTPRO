import App
import Adapters
import Core
import Persistence
import Runtime
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
        XCTAssertEqual(
            viewModel.report.marketDataReplayOperations.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.marketDataReplayOperations.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.marketDataReplayOperations.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.marketDataReplayOperations.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.marketDataReplayOperations.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.marketDataReplayOperations.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.scenarioReplayEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.scenarioReplayEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.scenarioReplayEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.scenarioReplayEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.scenarioReplayEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.scenarioReplayEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.liveTradingBlockedEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveTradingBlockedEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveTradingBlockedEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveTradingBlockedEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveTradingBlockedEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveTradingBlockedEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.liveMonitoringEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveMonitoringEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveMonitoringEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveMonitoringEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveMonitoringEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveMonitoringEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.liveExecutionControlBlockedEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveExecutionControlBlockedEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveExecutionControlBlockedEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveExecutionControlBlockedEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveExecutionControlBlockedEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveExecutionControlBlockedEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.liveRiskGateBlockedEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveRiskGateBlockedEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveRiskGateBlockedEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveRiskGateBlockedEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveRiskGateBlockedEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveRiskGateBlockedEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.liveIncidentStopBlockedEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.paperWorkflowObservability.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.paperWorkflowObservability.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.paperWorkflowObservability.source.exposesORMModels)
        XCTAssertFalse(viewModel.paperWorkflowObservability.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.paperWorkflowObservability.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.paperWorkflowObservability.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.paperWorkflowEvidenceExplorer.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.source.exposesORMModels)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.source.providesLiveOrderAction)
        XCTAssertEqual(viewModel.events.source.sourceKind, .stableReadModelProjection)
        XCTAssertFalse(viewModel.events.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.events.source.exposesORMModels)
        XCTAssertFalse(viewModel.events.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.events.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.events.source.providesLiveOrderAction)
    }

    func testPaperWorkflowWorkbenchInformationArchitectureDefinesSessionControlShellBoundary() throws {
        // 测试场景：MTP-47 只固定 Paper workflow Workbench 信息架构和控制壳边界。
        // fixture 必须保持 read-model-only，并且 session-level control 只能是 start / pause / close / reset。
        let contract = PaperWorkflowWorkbenchInformationArchitecture.deterministicFixture

        XCTAssertEqual(contract.dashboardSections, DashboardSection.allCases)
        XCTAssertEqual(contract.sessionLevelControls, [.start, .pause, .close, .reset])
        XCTAssertEqual(
            contract.observabilitySections,
            [
                .session,
                .proposal,
                .riskDecision,
                .paperOrder,
                .simulatedFill,
                .portfolioProjection,
                .replayFreshness,
                .reportArtifactStatus,
                .eventTimeline
            ]
        )
        XCTAssertEqual(
            contract.forbiddenCapabilities,
            [
                .orderLevelCommand,
                .liveTrading,
                .signedEndpoint,
                .accountEndpoint,
                .listenKey,
                .brokerAction,
                .realOrderSubmit,
                .realOrderCancel,
                .realOrderReplace,
                .oms,
                .databaseSchemaSurface,
                .runtimeObjectSurface,
                .adapterRequestSurface
            ]
        )
        XCTAssertTrue(contract.source.isReadModelOnly)
        XCTAssertTrue(contract.controlShellBoundaryHeld)
        XCTAssertFalse(contract.allowsOrderLevelCommand)
        XCTAssertFalse(contract.implementsCommandModel)
        XCTAssertFalse(contract.implementsUIControls)
        XCTAssertFalse(contract.implementsEventTimeline)
    }

    func testPaperWorkflowWorkbenchInformationArchitectureRejectsOutOfScopeControlShellExpansion() throws {
        // 测试场景：任何 order-level command、非 read-model-only source 或提前实现 Command/UI/Event Timeline
        // 的尝试都必须被合同 fixture 拒绝，避免 MTP-47 越界进入后续 issue。
        XCTAssertThrowsError(
            try PaperWorkflowWorkbenchInformationArchitecture(allowsOrderLevelCommand: true)
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowWorkbenchContractError, .orderLevelCommandExposed)
        }
        XCTAssertThrowsError(
            try PaperWorkflowWorkbenchInformationArchitecture(sessionLevelControls: [.start, .pause, .close])
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowWorkbenchContractError, .sessionControlsMismatch)
        }
        XCTAssertThrowsError(
            try PaperWorkflowWorkbenchInformationArchitecture(dashboardSections: [.paper])
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowWorkbenchContractError, .dashboardSectionsMismatch)
        }
        XCTAssertThrowsError(
            try PaperWorkflowWorkbenchInformationArchitecture(
                source: ViewModelSourceContract(exposesRuntimeObjects: true)
            )
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowWorkbenchContractError, .sourceIsNotReadModelOnly)
        }
        XCTAssertThrowsError(
            try PaperWorkflowWorkbenchInformationArchitecture(implementsCommandModel: true)
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowWorkbenchContractError, .implementationEscapedIssueScope)
        }
    }

    func testPaperWorkflowObservabilityViewModelAggregatesStatusChainAndFreshness() throws {
        // 测试场景：MTP-50 的 Paper workflow observability 必须只从既有 read model / ViewModel
        // evidence 汇总 session status、blocked / allowed evidence、执行链覆盖和 replay freshness。
        let viewModel = try makeDashboardViewModel().paperWorkflowObservability

        XCTAssertTrue(viewModel.source.isReadModelOnly)
        XCTAssertEqual(viewModel.sessionIDs, ["paper-replay-session"])
        XCTAssertEqual(viewModel.sessionStatusLabels, ["started", "updated", "closed"])
        XCTAssertEqual(viewModel.activeSessionCount, 0)
        XCTAssertEqual(viewModel.completedSessionCount, 1)
        XCTAssertEqual(
            viewModel.proposalIDs,
            ["paper-replay-proposal", "paper-replay-proposal-blocked"]
        )
        XCTAssertEqual(viewModel.allowedDecisionIDs, ["paper-replay-execution-decision-allowed"])
        XCTAssertEqual(viewModel.allowedPaperOrderIDs, ["paper-replay-order-allowed"])
        XCTAssertEqual(viewModel.allowedSimulatedFillIDs, ["paper-replay-fill-allowed"])
        XCTAssertEqual(viewModel.portfolioUpdateIDs, ["paper-replay-portfolio-update"])
        XCTAssertEqual(viewModel.portfolioIDs, ["portfolio-main"])
        XCTAssertEqual(
            viewModel.blockedRiskEvidenceIDs,
            ["risk-blocker-paper-replay-proposal-blocked"]
        )
        XCTAssertEqual(viewModel.blockedPaperOrderIDs, ["paper-replay-proposal-blocked"])
        XCTAssertEqual(viewModel.allowedEvidenceCount, 3)
        XCTAssertEqual(viewModel.blockedEvidenceCount, 1)

        XCTAssertTrue(viewModel.coversSessionStatus)
        XCTAssertTrue(viewModel.coversProposalEvidence)
        XCTAssertTrue(viewModel.coversRiskDecisionEvidence)
        XCTAssertTrue(viewModel.coversPaperOrderEvidence)
        XCTAssertTrue(viewModel.coversSimulatedFillEvidence)
        XCTAssertTrue(viewModel.coversPortfolioProjectionEvidence)
        XCTAssertTrue(viewModel.coversAllowedExecutionChain)
        XCTAssertTrue(viewModel.coversBlockedEvidence)
        XCTAssertTrue(viewModel.coversReportArtifactStatus)

        XCTAssertTrue(viewModel.replayAvailable)
        XCTAssertTrue(viewModel.replayDeterministic)
        XCTAssertTrue(viewModel.appendOnlyFactsSourceIsReplaySource)
        XCTAssertEqual(viewModel.replaySequenceCount, 16)
        XCTAssertEqual(viewModel.lastReplaySequence, 16)
        XCTAssertEqual(viewModel.eventTimelineLastSequence, 16)
        XCTAssertEqual(viewModel.replayFreshness, .fresh)

        XCTAssertEqual(viewModel.reportArtifactIDs, ["report-backtest-ema-fixture"])
        XCTAssertEqual(viewModel.reportArtifactStatuses, [.matchedProjectionEvidence])
        XCTAssertEqual(viewModel.reportArtifactCount, 1)
        XCTAssertEqual(viewModel.completedReportArtifactCount, 1)
        XCTAssertEqual(viewModel.latestReportParityStatus, .matchedProjectionEvidence)
        XCTAssertTrue(viewModel.reportArtifactsHavePaperOnlyAuthorization)
        XCTAssertEqual(viewModel.lastAppliedSequence, 16)
    }

    func testPaperWorkflowObservabilityViewModelIsCodableAndKeepsReadModelOnlyBoundary() throws {
        // 测试场景：MTP-50 新增 ViewModel 必须是 deterministic Codable snapshot，并且不能暴露
        // database schema、runtime object、adapter request、order-level command 或真实交易授权。
        let viewModel = try makeDashboardViewModel().paperWorkflowObservability

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(
            PaperWorkflowObservabilityViewModel.self,
            from: encoded
        )

        XCTAssertEqual(decoded, viewModel)
        XCTAssertTrue(decoded.paperOnlyBoundaryHeld)
        XCTAssertTrue(decoded.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.exposesDatabaseSchema)
        XCTAssertFalse(decoded.exposesRuntimeObject)
        XCTAssertFalse(decoded.exposesAdapterRequest)
        XCTAssertFalse(decoded.providesOrderLevelCommand)
        XCTAssertFalse(decoded.authorizesLiveTrading)
        XCTAssertFalse(decoded.touchesBrokerAction)
        XCTAssertFalse(decoded.authorizesTradingExecution)
    }

    func testPaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence() throws {
        // 测试场景：MTP-73 的 Event Timeline / Evidence Explorer 子集必须只从 read model
        // 汇总 market event、Live blocked evidence、Live monitoring evidence、execution-control
        // blocked evidence、Live Risk gate blocked evidence、incident / stop blocked evidence、
        // strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact links。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer

        XCTAssertTrue(explorer.source.isReadModelOnly)
        XCTAssertEqual(explorer.timelineItemCount, 70)
        XCTAssertTrue(explorer.coversMarketEvents)
        XCTAssertTrue(explorer.coversMarketDataReplayOperations)
        XCTAssertTrue(explorer.coversScenarioReplayEvidence)
        XCTAssertTrue(explorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveTradingBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveMonitoringEvidence)
        XCTAssertTrue(explorer.coversStrategySignals)
        XCTAssertTrue(explorer.coversRiskDecisions)
        XCTAssertTrue(explorer.coversPaperOrders)
        XCTAssertTrue(explorer.coversSimulatedFills)
        XCTAssertTrue(explorer.coversPortfolioProjections)
        XCTAssertTrue(explorer.coversReportArtifacts)
        XCTAssertTrue(explorer.coversPaperWorkflowChainEvidence)

        let itemCounts = Dictionary(
            uniqueKeysWithValues: explorer.sectionSnapshots.map { ($0.section, $0.itemCount) }
        )
        XCTAssertEqual(itemCounts[.marketEvent], 6)
        XCTAssertEqual(itemCounts[.marketDataReplayOperation], 1)
        XCTAssertEqual(itemCounts[.scenarioReplayEvidence], 10)
        XCTAssertEqual(itemCounts[.liveExecutionControlBlockedEvidence], 7)
        XCTAssertEqual(itemCounts[.liveRiskGateBlockedEvidence], 6)
        XCTAssertEqual(itemCounts[.liveIncidentStopBlockedEvidence], 5)
        XCTAssertEqual(itemCounts[.liveTradingBlockedEvidence], 6)
        XCTAssertEqual(itemCounts[.liveMonitoringEvidence], 18)
        XCTAssertEqual(itemCounts[.strategySignal], 3)
        XCTAssertEqual(itemCounts[.riskDecision], 4)
        XCTAssertEqual(itemCounts[.paperOrder], 1)
        XCTAssertEqual(itemCounts[.simulatedFill], 1)
        XCTAssertEqual(itemCounts[.portfolioProjection], 1)
        XCTAssertEqual(itemCounts[.reportArtifact], 1)

        XCTAssertEqual(explorer.filterSnapshot.availableSections, PaperWorkflowEvidenceExplorerSection.allCases)
        XCTAssertEqual(explorer.filterSnapshot.selectedSections, PaperWorkflowEvidenceExplorerSection.allCases)
        XCTAssertTrue(explorer.filterSnapshot.readOnly)
        XCTAssertFalse(explorer.filterSnapshot.supportsQueryLanguage)
        XCTAssertFalse(explorer.filterSnapshot.supportsCommandSurface)

        let evidenceIDs = explorer.evidenceLinks.map(\.evidenceID)
        XCTAssertTrue(evidenceIDs.contains("report-backtest-ema-fixture"))
        XCTAssertTrue(evidenceIDs.contains("paper-replay-execution-decision-allowed"))
        XCTAssertTrue(evidenceIDs.contains("paper-replay-order-allowed"))
        XCTAssertTrue(evidenceIDs.contains("paper-replay-fill-allowed"))
        XCTAssertTrue(evidenceIDs.contains("paper-replay-portfolio-update"))
        XCTAssertTrue(evidenceIDs.contains("risk-blocker-paper-replay-proposal-blocked"))
        XCTAssertTrue(evidenceIDs.contains("batch-BTCUSDT-1m-20240101"))
        XCTAssertTrue(evidenceIDs.contains("replay-run-BTCUSDT-1m-20240101T000000Z"))
        XCTAssertTrue(evidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-window"))
        XCTAssertTrue(evidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-gate-checksum-match"))
        XCTAssertTrue(evidenceIDs.contains("mtp-65-api-key-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-65-real-order-lifecycle-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-submit-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-execution-report-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-reconciliation-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-exposure-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-no-trade-state-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-audit-trail-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-incident-replay-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-emergency-stop-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-shutdown-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-restore-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-69-live-runtime-health"))
        XCTAssertTrue(evidenceIDs.contains("mtp-70-order-stream-future-gate"))
        XCTAssertTrue(evidenceIDs.contains("mtp-71-public-market-stream-error-disconnected"))
        XCTAssertTrue(evidenceIDs.contains("mtp-71-broker-session-unavailable"))
        XCTAssertEqual(explorer.timelineItems.first?.section, .marketEvent)
        XCTAssertTrue(explorer.timelineItems.contains { $0.section == .liveTradingBlockedEvidence })
        XCTAssertEqual(explorer.timelineItems.last?.section, .scenarioReplayEvidence)
        XCTAssertEqual(explorer.lastAppliedSequence, 16)
    }

    func testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems() throws {
        // 测试场景：MTP-73 只把 MTP-72 App 层 live monitoring evidence 接入 Event Timeline
        // preview；preview 必须覆盖 health、connection、stream、latency、error、blocked/degraded/future
        // evidence，并保持无 command、无 live audit、无 incident replay、无 stop control。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer
        let liveItems = explorer.timelineItems.filter { $0.section == .liveMonitoringEvidence }
        let titles = liveItems.map(\.title)
        let summaries = liveItems.map(\.summary)
        let evidenceLinks = liveItems.flatMap(\.evidenceLinks)
        let evidenceIDs = evidenceLinks.map(\.evidenceID)

        XCTAssertEqual(liveItems.count, 18)
        XCTAssertTrue(explorer.coversLiveMonitoringEvidence)
        XCTAssertTrue(titles.contains("Live monitoring runtime health"))
        XCTAssertTrue(titles.contains("Live monitoring connection"))
        XCTAssertTrue(titles.contains("Live monitoring stream"))
        XCTAssertTrue(titles.contains("Live monitoring latency"))
        XCTAssertTrue(titles.contains("Live monitoring error"))
        XCTAssertTrue(titles.contains("Live monitoring degraded state"))
        XCTAssertTrue(summaries.contains { $0.contains("health=blocked") })
        XCTAssertTrue(summaries.contains { $0.contains("future private user data connection blocked") })
        XCTAssertTrue(summaries.contains { $0.contains("future order stream unavailable") })
        XCTAssertTrue(summaries.contains { $0.contains("future private user data unavailable") })
        XCTAssertTrue(summaries.contains { $0.contains("public market stream degraded") })
        XCTAssertTrue(summaries.contains { $0.contains("MTP71_PRIVATE_USER_DATA_BLOCKED") })

        XCTAssertTrue(evidenceIDs.contains("mtp-69-live-runtime-health"))
        XCTAssertTrue(evidenceIDs.contains("mtp-69-private-user-data-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-70-public-market-stream-disconnected"))
        XCTAssertTrue(evidenceIDs.contains("mtp-70-order-stream-simulated-paper-evidence"))
        XCTAssertTrue(evidenceIDs.contains("mtp-71-private-user-data-latency-unavailable"))
        XCTAssertTrue(evidenceIDs.contains("mtp-71-broker-session-error-unavailable"))
        XCTAssertTrue(evidenceIDs.contains("mtp-71-public-market-stream-degraded"))
        XCTAssertTrue(evidenceLinks.allSatisfy { $0.section == .liveMonitoringEvidence })

        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)
        XCTAssertFalse(explorer.supportsQueryLanguage)
        XCTAssertFalse(explorer.providesLiveAudit)
        XCTAssertFalse(explorer.providesIncidentReplay)
        XCTAssertFalse(explorer.providesStopControl)
        XCTAssertFalse(explorer.authorizesLiveTrading)
        XCTAssertFalse(explorer.touchesBrokerAction)
        XCTAssertFalse(explorer.authorizesTradingExecution)
    }

    func testLiveExecutionControlBlockedEvidenceViewModelAggregatesMTP80ReadOnlySurface() throws {
        // 测试场景：MTP-80 只把 MTP-79 Core blocked evidence 复制成 App 层只读展示快照。
        // ViewModel 必须覆盖 submit / cancel / replace / execution report / broker fill /
        // reconciliation / incident fallback，但不能提供任何 live command、order form 或交易按钮。
        let readModel = LiveExecutionControlBlockedEvidenceReadModel()
        let viewModel = LiveExecutionControlBlockedEvidenceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(viewModel.contractID, "mtp-79-live-execution-control-blocked-evidence")
        XCTAssertEqual(viewModel.issueID, "MTP-79")
        XCTAssertEqual(viewModel.blockedGateCount, 7)
        XCTAssertEqual(
            viewModel.blockedGateLabels,
            [
                "submit",
                "cancel",
                "replace",
                "execution report",
                "broker fill",
                "reconciliation",
                "incident fallback"
            ]
        )
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("signed command request forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("execution report implementation forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("broker fill implementation forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("reconciliation runtime forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("incident fallback automation forbidden"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY"))
        XCTAssertTrue(viewModel.deterministicSnapshot.first?.hasPrefix("submit|blocked|") == true)
        XCTAssertTrue(viewModel.allExecutionControlGatesBlocked)
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.exposesPersistenceSchema)
        XCTAssertFalse(viewModel.readsAdapter)
        XCTAssertFalse(viewModel.invokesRuntimeControl)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesOrderLevelCommand)
        XCTAssertFalse(viewModel.exposesOrderForm)
        XCTAssertFalse(viewModel.exposesOrderLevelCommandUI)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.authorizesLiveExecution)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.readsAPIKey)
        XCTAssertFalse(viewModel.usesSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(viewModel.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(viewModel.implementsLiveExecutionAdapter)
        XCTAssertFalse(viewModel.implementsRealOrderStateMachine)
        XCTAssertFalse(viewModel.implementsOMS)
        XCTAssertFalse(viewModel.submitsRealOrder)
        XCTAssertFalse(viewModel.cancelsRealOrder)
        XCTAssertFalse(viewModel.replacesRealOrder)
        XCTAssertFalse(viewModel.consumesExecutionReport)
        XCTAssertFalse(viewModel.recordsBrokerFill)
        XCTAssertFalse(viewModel.performsReconciliation)
        XCTAssertFalse(viewModel.executesIncidentFallback)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)
    }

    func testLiveExecutionControlEvidenceExplorerPreviewDefinesMTP80ReadOnlyTimelineItems() throws {
        // 测试场景：MTP-80 的 Event Timeline / Evidence Explorer 只展示 execution-control
        // blocked evidence rows，不提供查询语言、live audit、incident replay、stop control 或 command。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer
        let executionItems = explorer.timelineItems.filter {
            $0.section == .liveExecutionControlBlockedEvidence
        }
        let evidenceLinks = executionItems.flatMap(\.evidenceLinks)
        let evidenceIDs = evidenceLinks.map(\.evidenceID)

        XCTAssertEqual(executionItems.count, 7)
        XCTAssertTrue(explorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(executionItems.allSatisfy { $0.title == "Live execution control gate blocked" })
        XCTAssertTrue(executionItems.contains { $0.summary.contains("submit blocked") })
        XCTAssertTrue(executionItems.contains { $0.summary.contains("execution report blocked") })
        XCTAssertTrue(executionItems.contains { $0.summary.contains("broker fill blocked") })
        XCTAssertTrue(executionItems.contains { $0.summary.contains("incident fallback blocked") })
        XCTAssertTrue(evidenceIDs.contains("mtp-79-submit-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-cancel-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-replace-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-execution-report-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-broker-fill-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-reconciliation-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-79-incident-fallback-blocked"))
        XCTAssertTrue(evidenceLinks.allSatisfy { $0.section == .liveExecutionControlBlockedEvidence })

        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)
        XCTAssertFalse(explorer.supportsQueryLanguage)
        XCTAssertFalse(explorer.providesLiveAudit)
        XCTAssertFalse(explorer.providesIncidentReplay)
        XCTAssertFalse(explorer.providesStopControl)
        XCTAssertFalse(explorer.authorizesLiveTrading)
        XCTAssertFalse(explorer.touchesBrokerAction)
        XCTAssertFalse(explorer.authorizesTradingExecution)
    }

    func testPaperWorkflowEvidenceExplorerFilterIsReadOnlyAndKeepsBoundary() throws {
        // 测试场景：MTP-51 的 filter 只是 ViewModel snapshot 内的只读 section 选择，
        // 不能下推成查询语言、Runtime command、schema access 或 order-level command。
        let readModel = try makeEvidenceExplorerReadModel()
        let explorer = PaperWorkflowEvidenceExplorerViewModel(
            readModel: readModel,
            selectedSections: [.paperOrder, .simulatedFill]
        )

        XCTAssertEqual(explorer.timelineItems.map(\.section), [.paperOrder, .simulatedFill])
        XCTAssertEqual(explorer.filterSnapshot.selectedSections, [.paperOrder, .simulatedFill])
        XCTAssertEqual(explorer.filterSnapshot.matchingItemCount, 2)
        XCTAssertTrue(explorer.filterSnapshot.readOnly)
        XCTAssertFalse(explorer.filterSnapshot.supportsQueryLanguage)
        XCTAssertFalse(explorer.filterSnapshot.supportsCommandSurface)
        XCTAssertTrue(explorer.sectionSnapshots.first { $0.section == .paperOrder }?.selected == true)
        XCTAssertTrue(explorer.sectionSnapshots.first { $0.section == .simulatedFill }?.selected == true)
        XCTAssertTrue(explorer.sectionSnapshots.first { $0.section == .marketEvent }?.selected == false)

        let encoded = try JSONEncoder().encode(explorer)
        let decoded = try JSONDecoder().decode(
            PaperWorkflowEvidenceExplorerViewModel.self,
            from: encoded
        )

        XCTAssertEqual(decoded, explorer)
        XCTAssertTrue(decoded.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.exposesDatabaseSchema)
        XCTAssertFalse(decoded.exposesRuntimeObject)
        XCTAssertFalse(decoded.exposesAdapterRequest)
        XCTAssertFalse(decoded.providesCommandSurface)
        XCTAssertFalse(decoded.providesOrderLevelCommand)
        XCTAssertFalse(decoded.supportsQueryLanguage)
        XCTAssertFalse(decoded.authorizesLiveTrading)
        XCTAssertFalse(decoded.touchesBrokerAction)
        XCTAssertFalse(decoded.authorizesTradingExecution)
    }

    func testLiveTradingBlockedEvidenceViewModelAggregatesMTP66ReadModelOnlyEvidence() throws {
        // 测试场景：MTP-66 只把 Core `LiveReadiness` 复制成 App 层 Dashboard / Report /
        // Event Timeline 可消费的 read-model-only evidence，不新增 live command 或交易入口。
        let readModel = LiveTradingBlockedEvidenceReadModel()
        let viewModel = LiveTradingBlockedEvidenceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.source.isReadModelOnly)
        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(viewModel.readinessID, "mtp-65-live-readiness")
        XCTAssertEqual(viewModel.issueID, "MTP-65")
        XCTAssertEqual(viewModel.status, .blocked)
        XCTAssertEqual(viewModel.blockedEvidenceCount, 6)
        XCTAssertEqual(
            viewModel.blockedCapabilityLabels,
            [
                "API key",
                "signed endpoint",
                "account endpoint",
                "listenKey user data stream",
                "broker adapter",
                "real order lifecycle"
            ]
        )
        XCTAssertEqual(
            viewModel.blockedGateLabels,
            [
                "Gate 1 API key / signed / account / listenKey boundary",
                "Gate 2 adapter capability isolation",
                "Gate 3 real order lifecycle terms"
            ]
        )
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-63-ADAPTER-CAPABILITY-ISOLATION"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY"))
        XCTAssertTrue(viewModel.allLiveGatesBlocked)
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesOrderLevelCommand)
        XCTAssertFalse(viewModel.supportsQueryLanguage)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.touchesBrokerAction)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.exposesRuntimeObject)
        XCTAssertFalse(viewModel.exposesAdapterSurface)
        XCTAssertFalse(viewModel.readsAPIKey)
        XCTAssertFalse(viewModel.usesSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.instantiatesBrokerAdapter)
        XCTAssertFalse(viewModel.representsRealOrderLifecycle)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(
            LiveTradingBlockedEvidenceViewModel.self,
            from: encoded
        )

        XCTAssertEqual(decoded, viewModel)
        XCTAssertTrue(decoded.items.allSatisfy(\.boundaryHeld))
    }

    func testLiveMonitoringEvidenceViewModelAggregatesMTP72ReadModelOnlyEvidence() throws {
        // 测试场景：MTP-72 只把 MTP-69 / MTP-70 / MTP-71 的 Core read model 复制成
        // Dashboard / Report 可展示的只读 monitoring evidence，不新增 live command 或交易按钮。
        let readModel = LiveMonitoringEvidenceReadModel()
        let viewModel = LiveMonitoringEvidenceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.source.isReadModelOnly)
        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(viewModel.readModelID, "mtp-71-live-latency-error-degraded-evidence")
        XCTAssertEqual(viewModel.issueID, "MTP-71")
        XCTAssertEqual(viewModel.runtimeHealthStatus, .blocked)
        XCTAssertEqual(viewModel.connectionCount, 3)
        XCTAssertEqual(
            viewModel.connectionKinds,
            [
                "public market data connection",
                "future private user data connection",
                "future broker session"
            ]
        )
        XCTAssertEqual(viewModel.connectionStatusLabels, ["disconnected", "blocked", "unavailable"])
        XCTAssertEqual(viewModel.streamEvidenceCount, 4)
        XCTAssertEqual(viewModel.marketStreamEvidenceCount, 1)
        XCTAssertEqual(viewModel.orderStreamEvidenceCount, 3)
        XCTAssertEqual(
            viewModel.streamKinds,
            [
                "public market stream",
                "blocked order stream",
                "simulated order stream",
                "future order stream"
            ]
        )
        XCTAssertEqual(
            viewModel.orderStreamEvidenceKindLabels,
            [
                "blocked order stream evidence",
                "simulated paper order evidence",
                "future order stream gate evidence"
            ]
        )
        XCTAssertEqual(viewModel.latencyEvidenceCount, 5)
        XCTAssertEqual(viewModel.latencyBucketLabels, ["stale", "degraded", "nominal", "unavailable"])
        XCTAssertEqual(viewModel.errorEvidenceCount, 3)
        XCTAssertEqual(
            viewModel.errorCodes,
            [
                "MTP71_PUBLIC_MARKET_STREAM_DISCONNECTED",
                "MTP71_PRIVATE_USER_DATA_BLOCKED",
                "MTP71_BROKER_SESSION_UNAVAILABLE"
            ]
        )
        XCTAssertEqual(viewModel.degradedStateEvidenceCount, 2)
        XCTAssertEqual(viewModel.degradedStateStatusLabels, ["degraded", "unavailable"])
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL"))

        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesOrderLevelCommand)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.providesRiskCommand)
        XCTAssertFalse(viewModel.providesPositionCommand)
        XCTAssertFalse(viewModel.providesAlertingCommand)
        XCTAssertFalse(viewModel.providesPagingCommand)
        XCTAssertFalse(viewModel.providesReconnectCommand)
        XCTAssertFalse(viewModel.providesStopControl)
        XCTAssertFalse(viewModel.providesLiveRiskControl)
        XCTAssertFalse(viewModel.triggersIncidentCommand)
        XCTAssertFalse(viewModel.triggersAutoRecovery)
        XCTAssertFalse(viewModel.usesProductionTelemetry)
        XCTAssertFalse(viewModel.usesExternalMetricsService)
        XCTAssertFalse(viewModel.opensNetworkConnection)
        XCTAssertFalse(viewModel.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.exposesRuntimeObject)
        XCTAssertFalse(viewModel.exposesAdapterSurface)
        XCTAssertFalse(viewModel.readsAPIKey)
        XCTAssertFalse(viewModel.readsSecret)
        XCTAssertFalse(viewModel.callsSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.readsAccountPayload)
        XCTAssertFalse(viewModel.instantiatesBrokerAdapter)
        XCTAssertFalse(viewModel.implementsRealOrderStateMachine)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(
            LiveMonitoringEvidenceViewModel.self,
            from: encoded
        )

        XCTAssertEqual(decoded, viewModel)
        XCTAssertTrue(decoded.readModelOnlyBoundaryHeld)
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
        XCTAssertEqual(viewModel.report.paperRuntimeReplaySequenceCount, 16)
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
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowEvidenceCount, 1)
        XCTAssertEqual(
            viewModel.report.paperExecutionWorkflowDecisionIDs,
            ["paper-replay-execution-decision-allowed"]
        )
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowOrderIDs, ["paper-replay-order-allowed"])
        XCTAssertEqual(
            viewModel.report.paperExecutionWorkflowSimulatedFillIDs,
            ["paper-replay-fill-allowed"]
        )
        XCTAssertEqual(
            viewModel.report.paperExecutionWorkflowPortfolioUpdateIDs,
            ["paper-replay-portfolio-update"]
        )
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowPortfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSequenceCount, 4)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowStreams, ["paper", "portfolio"])
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversDecisionEvents)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversOrderEvents)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversSimulatedFillEvents)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversDecisionOrderFillChain)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowReplayDeterministic)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowPaperOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.paperExecutionWorkflowAuthorizesLiveTrading)
        XCTAssertFalse(viewModel.report.paperExecutionWorkflowTouchesBrokerAction)
        XCTAssertFalse(viewModel.report.paperExecutionWorkflowAuthorizesTradingExecution)
        XCTAssertEqual(viewModel.report.marketDataReplayEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.marketDataReplayBatchIDs, ["batch-BTCUSDT-1m-20240101"])
        XCTAssertEqual(
            viewModel.report.marketDataReplayRunIDs,
            ["replay-run-BTCUSDT-1m-20240101T000000Z"]
        )
        XCTAssertEqual(viewModel.report.marketDataReplayFreshnessStatuses, ["fresh"])
        XCTAssertEqual(viewModel.report.marketDataReplayRetentionStatuses, [.retained])
        XCTAssertEqual(viewModel.report.marketDataReplayEventLogRecordCount, 1)
        XCTAssertEqual(viewModel.report.marketDataReplayReplayedRecordCount, 1)
        XCTAssertTrue(viewModel.report.marketDataReplayProjectionConsistencyHeld)
        XCTAssertTrue(viewModel.report.marketDataReplayReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.marketDataReplayAuthorizesTradingExecution)
        XCTAssertEqual(viewModel.report.scenarioReplayEvidenceCount, 1)
        XCTAssertTrue(viewModel.report.scenarioReplayReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.scenarioReplayAuthorizesTradingExecution)
        XCTAssertEqual(viewModel.report.liveBlockedEvidenceCount, 6)
        XCTAssertEqual(
            viewModel.report.liveBlockedCapabilityLabels,
            [
                "API key",
                "signed endpoint",
                "account endpoint",
                "listenKey user data stream",
                "broker adapter",
                "real order lifecycle"
            ]
        )
        XCTAssertEqual(viewModel.report.liveReadinessStatus, .blocked)
        XCTAssertTrue(viewModel.report.liveReadinessAllGatesBlocked)
        XCTAssertTrue(viewModel.report.liveReadinessReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.liveReadinessProvidesCommandSurface)
        XCTAssertFalse(viewModel.report.liveReadinessAuthorizesLiveTrading)
        XCTAssertFalse(viewModel.report.liveReadinessTouchesBrokerAction)
        XCTAssertFalse(viewModel.report.liveReadinessAuthorizesTradingExecution)
        XCTAssertFalse(viewModel.report.liveReadinessExposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.liveReadinessExposesRuntimeObject)
        XCTAssertFalse(viewModel.report.liveReadinessExposesAdapterSurface)
        XCTAssertFalse(viewModel.report.liveReadinessReadsAPIKey)
        XCTAssertFalse(viewModel.report.liveReadinessUsesSignedEndpoint)
        XCTAssertFalse(viewModel.report.liveReadinessCallsAccountEndpoint)
        XCTAssertFalse(viewModel.report.liveReadinessCreatesListenKey)
        XCTAssertFalse(viewModel.report.liveReadinessInstantiatesBrokerAdapter)
        XCTAssertFalse(viewModel.report.liveReadinessRepresentsRealOrderLifecycle)
        XCTAssertEqual(viewModel.report.liveMonitoringHealthStatus, .blocked)
        XCTAssertEqual(viewModel.report.liveMonitoringConnectionCount, 3)
        XCTAssertEqual(
            viewModel.report.liveMonitoringConnectionStatusLabels,
            ["disconnected", "blocked", "unavailable"]
        )
        XCTAssertEqual(viewModel.report.liveMonitoringStreamEvidenceCount, 4)
        XCTAssertEqual(viewModel.report.liveMonitoringMarketStreamEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.liveMonitoringOrderStreamEvidenceCount, 3)
        XCTAssertEqual(viewModel.report.liveMonitoringLatencyEvidenceCount, 5)
        XCTAssertEqual(
            viewModel.report.liveMonitoringLatencyBucketLabels,
            ["stale", "degraded", "nominal", "unavailable"]
        )
        XCTAssertEqual(viewModel.report.liveMonitoringErrorEvidenceCount, 3)
        XCTAssertEqual(
            viewModel.report.liveMonitoringErrorCodes,
            [
                "MTP71_PUBLIC_MARKET_STREAM_DISCONNECTED",
                "MTP71_PRIVATE_USER_DATA_BLOCKED",
                "MTP71_BROKER_SESSION_UNAVAILABLE"
            ]
        )
        XCTAssertEqual(viewModel.report.liveMonitoringDegradedStateEvidenceCount, 2)
        XCTAssertEqual(
            viewModel.report.liveMonitoringDegradedStateStatusLabels,
            ["degraded", "unavailable"]
        )
        XCTAssertTrue(viewModel.report.liveMonitoringReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesCommandSurface)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesOrderLevelCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesTradingButton)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesRiskCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesPositionCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringExposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.liveMonitoringExposesRuntimeObject)
        XCTAssertFalse(viewModel.report.liveMonitoringExposesAdapterSurface)
        XCTAssertFalse(viewModel.report.liveMonitoringOpensNetworkConnection)
        XCTAssertFalse(viewModel.report.liveMonitoringUsesProductionTelemetry)
        XCTAssertFalse(viewModel.report.liveMonitoringUsesExternalMetricsService)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesAlertingCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesPagingCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesReconnectCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesStopControl)
        XCTAssertFalse(viewModel.report.liveMonitoringProvidesLiveRiskControl)
        XCTAssertFalse(viewModel.report.liveMonitoringTriggersIncidentCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringTriggersAutoRecovery)
        XCTAssertFalse(viewModel.report.liveMonitoringReadsAPIKey)
        XCTAssertFalse(viewModel.report.liveMonitoringReadsSecret)
        XCTAssertFalse(viewModel.report.liveMonitoringCallsSignedEndpoint)
        XCTAssertFalse(viewModel.report.liveMonitoringCallsAccountEndpoint)
        XCTAssertFalse(viewModel.report.liveMonitoringCreatesListenKey)
        XCTAssertFalse(viewModel.report.liveMonitoringReadsAccountPayload)
        XCTAssertFalse(viewModel.report.liveMonitoringInstantiatesBrokerAdapter)
        XCTAssertFalse(viewModel.report.liveMonitoringImplementsRealOrderStateMachine)
        XCTAssertFalse(viewModel.report.liveMonitoringAuthorizesLiveTrading)
        XCTAssertFalse(viewModel.report.liveMonitoringAuthorizesTradingExecution)
        XCTAssertFalse(viewModel.report.liveMonitoringRequiredValidationDependsOnNetwork)
        XCTAssertEqual(viewModel.report.liveIncidentStopBlockedEvidence.blockedGateCount, 5)
        XCTAssertEqual(
            viewModel.report.liveIncidentStopBlockedEvidence.blockedGateLabels,
            ["audit trail", "incident replay", "emergency stop", "shutdown", "restore"]
        )
        XCTAssertTrue(viewModel.report.liveIncidentStopBlockedEvidence.allIncidentStopGatesBlocked)
        XCTAssertTrue(viewModel.report.liveIncidentStopBlockedEvidence.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesCommandSurface)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesIncidentReplay)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesStopControl)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesEmergencyStopCommand)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesShutdownCommand)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesRestoreCommand)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.exposesLiveProConsole)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesStopButton)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.providesTradingButton)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.authorizesLiveTrading)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.authorizesTradingExecution)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.usesSignedEndpoint)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.callsAccountEndpoint)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.createsListenKey)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.executesBrokerAction)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.runsIncidentReplayRuntime)
        XCTAssertFalse(viewModel.report.liveIncidentStopBlockedEvidence.runsProductionOperations)
        XCTAssertEqual(viewModel.report.latestParityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(viewModel.report.lastAppliedSequence, 16)
        XCTAssertFalse(viewModel.report.tradingValidationAuthorizesExecution)
        XCTAssertFalse(viewModel.report.authorizesTradingExecution)
        XCTAssertEqual(viewModel.paperWorkflowEvidenceExplorer.timelineItemCount, 70)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversPaperWorkflowChainEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversMarketDataReplayOperations)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveTradingBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveMonitoringEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesCommandSurface)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesLiveAudit)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesIncidentReplay)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesStopControl)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.exposesDatabaseSchema)
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
        XCTAssertEqual(report.eventCount, 16)
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
        XCTAssertEqual(report.tradingValidationEvidence.sourceSequences, [12, 16])
        XCTAssertFalse(report.tradingValidationEvidence.authorizesTradingExecution)
        XCTAssertEqual(report.paperRuntimeEvidence.factsSource, "append-only event log replay")
        XCTAssertTrue(report.paperRuntimeEvidence.replayAvailable)
        XCTAssertEqual(report.paperRuntimeEvidence.replayedSequences, Array(1...16))
        XCTAssertEqual(report.paperRuntimeEvidence.replayedStreams, ["paper", "portfolio", "risk"])
        XCTAssertEqual(report.paperRuntimeEvidence.lifecycleStates, [.started, .updated, .closed])
        XCTAssertEqual(report.paperRuntimeEvidence.signalEventCount, 4)
        XCTAssertEqual(report.paperRuntimeEvidence.proposalCount, 2)
        XCTAssertEqual(report.paperRuntimeEvidence.portfolioExposureCount, 1)
        XCTAssertEqual(report.paperRuntimeEvidence.portfolioGrossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(report.paperRuntimeEvidence.sourceSequences, Array(1...16))
        XCTAssertTrue(report.paperRuntimeEvidence.appendOnlyFactsSourceIsReplaySource)
        XCTAssertTrue(report.paperRuntimeEvidence.paperOnlyBoundaryHeld)
        XCTAssertFalse(report.paperRuntimeEvidence.authorizesTradingExecution)
        XCTAssertEqual(report.paperExecutionWorkflowEvidence.factsSource, "append-only event log replay")
        XCTAssertTrue(report.paperExecutionWorkflowEvidence.replayAvailable)
        XCTAssertEqual(report.paperExecutionWorkflowEvidence.workflowSequenceCount, 4)
        XCTAssertEqual(report.paperExecutionWorkflowEvidence.workflowStreams, ["paper", "portfolio"])
        XCTAssertEqual(
            report.paperExecutionWorkflowEvidence.decisionIDs,
            ["paper-replay-execution-decision-allowed"]
        )
        XCTAssertEqual(report.paperExecutionWorkflowEvidence.paperOrderIDs, ["paper-replay-order-allowed"])
        XCTAssertEqual(
            report.paperExecutionWorkflowEvidence.simulatedFillIDs,
            ["paper-replay-fill-allowed"]
        )
        XCTAssertTrue(report.paperExecutionWorkflowEvidence.coversDecisionOrderFillChain)
        XCTAssertTrue(report.paperExecutionWorkflowEvidence.projectsPortfolioFromSimulatedFill)
        XCTAssertTrue(report.paperExecutionWorkflowEvidence.appendOnlyFactsSourceIsReplaySource)
        XCTAssertTrue(report.paperExecutionWorkflowEvidence.paperOnlyBoundaryHeld)
        XCTAssertFalse(report.paperExecutionWorkflowEvidence.authorizesTradingExecution)
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
        XCTAssertEqual(viewModel.risk.evidence.first?.sourceSequence, 16)

        XCTAssertEqual(viewModel.portfolio.portfolioIDs, ["portfolio-main"])
        XCTAssertEqual(viewModel.portfolio.updatedPortfolioCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposureCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposures.first?.symbol, "BTCUSDT")
        XCTAssertEqual(viewModel.portfolio.exposures.first?.source, .paperProjection)
        XCTAssertEqual(viewModel.portfolio.totalGrossExposureNotional, 50, accuracy: 0.00000001)

        XCTAssertEqual(viewModel.events.eventCount, 16)
        XCTAssertEqual(viewModel.events.streams, ["paper", "portfolio", "risk"])
        XCTAssertEqual(viewModel.events.lastSequence, 16)
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
        XCTAssertEqual(
            decoded.report.artifacts.first?.paperExecutionWorkflowEvidence.paperOrderIDs,
            ["paper-replay-order-allowed"]
        )
        XCTAssertEqual(decoded.paperWorkflowEvidenceExplorer.timelineItemCount, 70)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversReportArtifacts)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversMarketDataReplayOperations)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversScenarioReplayEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveTradingBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveMonitoringEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.readModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.marketDataReplayEvidenceCount, 1)
        XCTAssertTrue(decoded.report.marketDataReplayReadModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.scenarioReplayEvidenceCount, 1)
        XCTAssertTrue(decoded.report.scenarioReplayReadModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.liveBlockedEvidenceCount, 6)
        XCTAssertTrue(decoded.report.liveReadinessReadModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveReadinessProvidesCommandSurface)
        XCTAssertEqual(decoded.report.liveMonitoringHealthStatus, .blocked)
        XCTAssertEqual(decoded.report.liveMonitoringStreamEvidenceCount, 4)
        XCTAssertEqual(decoded.report.liveMonitoringErrorEvidenceCount, 3)
        XCTAssertTrue(decoded.report.liveMonitoringReadModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveMonitoringProvidesCommandSurface)
        XCTAssertFalse(decoded.report.liveMonitoringProvidesTradingButton)
        XCTAssertEqual(decoded.report.liveExecutionControlBlockedGateCount, 7)
        XCTAssertTrue(decoded.report.liveExecutionControlAllGatesBlocked)
        XCTAssertEqual(decoded.report.liveRiskGateBlockedEvidence.blockedGateCount, 6)
        XCTAssertTrue(decoded.report.liveRiskGateBlockedEvidence.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveRiskGateBlockedEvidence.providesCommandSurface)
        XCTAssertEqual(decoded.report.liveIncidentStopBlockedEvidence.blockedGateCount, 5)
        XCTAssertTrue(decoded.report.liveIncidentStopBlockedEvidence.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveIncidentStopBlockedEvidence.providesCommandSurface)
        XCTAssertFalse(decoded.report.liveIncidentStopBlockedEvidence.providesStopButton)
        XCTAssertFalse(decoded.report.liveIncidentStopBlockedEvidence.exposesLiveProConsole)
        XCTAssertTrue(decoded.report.liveExecutionControlReadModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveExecutionControlProvidesCommandSurface)
        XCTAssertFalse(decoded.report.liveExecutionControlProvidesOrderLevelCommand)
        XCTAssertFalse(decoded.report.liveExecutionControlExposesOrderForm)
        XCTAssertFalse(decoded.report.liveExecutionControlProvidesTradingButton)
        XCTAssertFalse(decoded.report.liveExecutionControlAuthorizesLiveExecution)
        XCTAssertFalse(decoded.report.liveExecutionControlAuthorizesTradingExecution)
        XCTAssertFalse(decoded.report.liveExecutionControlConsumesExecutionReport)
        XCTAssertFalse(decoded.report.liveExecutionControlRecordsBrokerFill)
        XCTAssertFalse(decoded.report.liveExecutionControlPerformsReconciliation)
        XCTAssertTrue(decoded.report.paperExecutionWorkflowCoversDecisionOrderFillChain)
        XCTAssertTrue(decoded.report.paperRuntimePaperOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.authorizesTradingExecution)
        XCTAssertEqual(decoded.paper.sessions.first?.state, .closed)
        XCTAssertEqual(decoded.events.lastSequence, 16)
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
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()
        let update = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            simulatedFill: simulatedFill,
            sourceSimulatedFillSequence: 12,
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
        XCTAssertEqual(exposureViewModel.sourceSequence, 12)
        XCTAssertEqual(viewModel.events.streams, ["portfolio"])
    }

    func testMTP101PaperAccountPortfolioProjectionReadModelFeedsReportRiskPortfolioAndDashboard() throws {
        // 测试场景：MTP-101 v2 projection 进入 App 层后，Report / Risk / Portfolio / Dashboard
        // 都只能消费 runtime read model，不能读取 schema、Runtime object、broker 或真实账户。
        let (messageBus, publication) = try PaperSimulatedFillFixture.publishedPartialAndFullFills()
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: messageBus.envelopes.count),
                streams: [.paper]
            )
        )
        let snapshot = try PaperAccountPortfolioProjectionV2Path.project(
            from: replay,
            snapshotID: try Identifier("mtp-101-paper-account-portfolio-snapshot"),
            accountID: try Identifier("mtp-101-paper-account"),
            portfolioID: try Identifier("mtp-101-paper-portfolio"),
            startingCashBalance: 10_000,
            projectedAt: Date(timeIntervalSince1970: 6_100)
        )
        let portfolioEnvelope = try EventEnvelope(
            sequence: 3,
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 6_101),
            event: .portfolio(.paperAccountPortfolioProjectionUpdated(snapshot))
        )
        let eventTimeline = messageBus.envelopes + [portfolioEnvelope]
        let runtimeProjection = SQLiteRuntimeProjectionStore.project(eventTimeline)
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: try makeAnalyticalProjection(),
            eventTimeline: eventTimeline
        )
        let viewModel = DashboardViewModel(readModel: readModel)
        let expectedGross = publication.fills.reduce(0) { $0 + $1.grossNotional }
        let expectedCost = publication.fills.reduce(0) { $0 + $1.costImpactAmount }
        let expectedQuantity = publication.fills.reduce(0) { $0 + $1.filledQuantity.rawValue }
        let expectedMarketValue = expectedQuantity * (try XCTUnwrap(publication.fills.last?.fillPrice.rawValue))
        let expectedNetPnL = expectedMarketValue - expectedGross - expectedCost

        XCTAssertTrue(viewModel.portfolio.source.isReadModelOnly)
        XCTAssertEqual(viewModel.portfolio.portfolioIDs, ["mtp-101-paper-portfolio"])
        XCTAssertEqual(viewModel.portfolio.paperAccountCount, 1)
        XCTAssertEqual(viewModel.portfolio.paperPositionCount, 1)
        XCTAssertEqual(viewModel.portfolio.exposureCount, 1)
        XCTAssertEqual(viewModel.portfolio.totalPaperEquity, 10_000 + expectedNetPnL, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.portfolio.totalNetPaperPnL, expectedNetPnL, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.portfolio.totalGrossExposureNotional, expectedMarketValue, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.portfolio.paperAccounts.map(\.accountID), ["mtp-101-paper-account"])
        XCTAssertEqual(viewModel.portfolio.paperPositions.map(\.positionID), [
            "mtp-101-paper-portfolio-BTCUSDT-1m-paper-position"
        ])

        XCTAssertTrue(viewModel.risk.source.isReadModelOnly)
        XCTAssertEqual(viewModel.risk.paperAccountIDs, ["mtp-101-paper-account"])
        XCTAssertEqual(viewModel.risk.paperPositionCount, 1)
        XCTAssertEqual(viewModel.risk.paperAvailableBalance, 10_000 - expectedGross - expectedCost, accuracy: 0.00000001)

        XCTAssertEqual(viewModel.report.paperAccountIDs, ["mtp-101-paper-account"])
        XCTAssertEqual(viewModel.report.paperPositionCount, 1)
        XCTAssertEqual(viewModel.report.paperNetPnL, expectedNetPnL, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.report.portfolioExposureEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.portfolioExposureSymbols, ["BTCUSDT"])

        let shell = DashboardShellSnapshot(viewModel: viewModel)
        let portfolioSection = try XCTUnwrap(shell.sections.first { $0.section == .portfolio })
        XCTAssertEqual(metricValue("Positions", in: portfolioSection), "1")
        XCTAssertEqual(viewModel.events.streams, ["paper", "portfolio"])
    }

    func testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline() throws {
        // 测试场景：MTP-102 将 risk -> local lifecycle -> simulated fill -> account portfolio projection
        // 串成同一 append-only replay evidence，并只通过 Report / Dashboard / Event Timeline 只读展示。
        var messageBus = try MessageBus()
        let riskPublication = try PaperPreTradeRiskEngineRuntimePath().evaluateAndPublish(
            decisionID: try Identifier("mtp-98-paper-risk-accepted"),
            input: PaperPreTradeRiskEngineFixture.acceptedInput(),
            to: &messageBus,
            clock: PaperPreTradeRiskEngineFixture.deterministicClock,
            envelopeIDs: PaperPreTradeRiskEngineFixture.acceptedEnvelopeIDs,
            correlationID: PaperPreTradeRiskEngineFixture.correlationID,
            rootCausationID: PaperPreTradeRiskEngineFixture.rootCausationID
        )
        let lifecyclePublication = try PaperOrderLocalLifecycleCoordinator().publish(
            PaperOrderLocalLifecycleCoordinatorFixture.acceptedTrace(),
            to: &messageBus,
            clock: PaperOrderLocalLifecycleCoordinatorFixture.deterministicClock,
            envelopeIDs: PaperOrderLocalLifecycleCoordinatorFixture.acceptedEnvelopeIDs,
            correlationID: PaperOrderLocalLifecycleCoordinatorFixture.correlationID,
            rootCausationID: PaperOrderLocalLifecycleCoordinatorFixture.rootCausationID
        )
        let fillPublication = try PaperSimulatedFillEventLogBoundary().publish(
            [
                PaperSimulatedFillFixture.deterministicFullFromLifecycle(),
                PaperSimulatedFillFixture.deterministicPartialFromLifecycle()
            ],
            to: &messageBus,
            clock: PaperSimulatedFillFixture.deterministicClock,
            envelopeIDs: PaperSimulatedFillFixture.envelopeIDs,
            correlationID: PaperSimulatedFillFixture.correlationID,
            rootCausationID: PaperSimulatedFillFixture.rootCausationID
        )
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: messageBus.envelopes.count),
                streams: [.paper, .risk]
            )
        )
        let portfolioSnapshot = try PaperAccountPortfolioProjectionV2Path.project(
            from: replay,
            snapshotID: try Identifier("mtp-102-paper-runtime-closeout-snapshot"),
            accountID: try Identifier("mtp-102-paper-account"),
            portfolioID: try Identifier("mtp-102-paper-portfolio"),
            startingCashBalance: 10_000,
            projectedAt: Date(timeIntervalSince1970: 6_200)
        )
        let portfolioEnvelope = try EventEnvelope(
            sequence: messageBus.envelopes.count + 1,
            stream: .portfolio,
            recordedAt: Date(timeIntervalSince1970: 6_201),
            event: .portfolio(.paperAccountPortfolioProjectionUpdated(portfolioSnapshot))
        )
        let eventTimeline = messageBus.envelopes + [portfolioEnvelope]
        let runtimeProjection = SQLiteRuntimeProjectionStore.project(eventTimeline)
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: try makeAnalyticalProjection(),
            eventTimeline: eventTimeline
        )
        let viewModel = DashboardViewModel(readModel: readModel)
        let expectedLifecycleTransitionIDs = lifecyclePublication.trace.transitions
            .map { $0.transitionID.rawValue }
            .sorted()
        let expectedGross = fillPublication.fills.reduce(0) { $0 + $1.grossNotional }
        let expectedFee = fillPublication.fills.reduce(0) { $0 + $1.costEstimate.feeAmount }
        let expectedSlippage = fillPublication.fills.reduce(0) { $0 + $1.costEstimate.slippageAmount }
        let expectedCost = fillPublication.fills.reduce(0) { $0 + $1.costImpactAmount }
        let expectedQuantity = fillPublication.fills.reduce(0) { $0 + $1.filledQuantity.rawValue }
        let expectedMarketValue = expectedQuantity * (try XCTUnwrap(fillPublication.fills.last?.fillPrice.rawValue))
        let expectedNetPnL = expectedMarketValue - expectedGross - expectedCost

        XCTAssertTrue(riskPublication.replayMatchesRouteEvidence)
        XCTAssertTrue(lifecyclePublication.replayMatchesRouteEvidence)
        XCTAssertTrue(lifecyclePublication.everyTransitionHasEventFact)
        XCTAssertTrue(fillPublication.replayMatchesRouteEvidence)
        XCTAssertTrue(fillPublication.coversPartialAndFullFills)

        XCTAssertEqual(viewModel.report.paperRuntimeEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.paperRuntimeReplaySequenceCount, 7)
        XCTAssertEqual(viewModel.report.paperRuntimeReplayStreams, ["paper", "portfolio", "risk"])
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowLocalLifecycleTransitionIDs, expectedLifecycleTransitionIDs)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowDecisionIDs, ["mtp-98-paper-risk-accepted"])
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowOrderIDs, ["mtp-99-paper-order-local"])
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSimulatedFillIDs, [
            "mtp-100-full-simulated-fill",
            "mtp-100-partial-simulated-fill"
        ])
        XCTAssertEqual(
            viewModel.report.paperExecutionWorkflowAccountPortfolioSnapshotIDs,
            ["mtp-102-paper-runtime-closeout-snapshot"]
        )
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSimulatedFillGrossNotional, expectedGross, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSimulatedFillFeeAmount, expectedFee, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSimulatedFillSlippageAmount, expectedSlippage, accuracy: 0.00000001)
        XCTAssertEqual(viewModel.report.paperExecutionWorkflowSimulatedFillCostImpactAmount, expectedCost, accuracy: 0.00000001)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversLocalLifecycleEvents)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowCoversDecisionOrderFillChain)
        XCTAssertTrue(viewModel.report.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill)
        XCTAssertEqual(viewModel.report.paperAccountIDs, ["mtp-102-paper-account"])
        XCTAssertEqual(viewModel.report.paperPositionCount, 1)
        XCTAssertEqual(viewModel.report.paperNetPnL, expectedNetPnL, accuracy: 0.00000001)
        XCTAssertFalse(viewModel.report.paperRuntimeAuthorizesLiveTrading)
        XCTAssertFalse(viewModel.report.paperRuntimeTouchesBrokerAction)
        XCTAssertFalse(viewModel.report.paperRuntimeAuthorizesTradingExecution)
        XCTAssertFalse(viewModel.report.paperExecutionWorkflowAuthorizesTradingExecution)

        let timelineTitles = viewModel.paperWorkflowEvidenceExplorer.timelineItems.map(\.title)
        XCTAssertEqual(timelineTitles.filter { $0 == "Paper local lifecycle transition" }.count, 3)
        XCTAssertTrue(timelineTitles.contains("Simulated fill evidence"))
        XCTAssertTrue(timelineTitles.contains("Paper account portfolio projection"))
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesCommandSurface)

        let shell = DashboardShellSnapshot(viewModel: viewModel)
        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Lifecycle transitions", in: reportSection), "3")
        XCTAssertEqual(metricValue("Paper accounts", in: reportSection), "1")
        XCTAssertEqual(metricValue("Positions", in: reportSection), "1")
        XCTAssertEqual(metricValue("Paper PnL", in: reportSection), String(format: "%.2f", expectedNetPnL))
        XCTAssertEqual(metricValue("Fill cost", in: reportSection), String(format: "%.2f", expectedCost))
        XCTAssertTrue(shell.isReadModelOnly)
        XCTAssertTrue(shell.smokeSummary.contains("paperRuntimeEvidence=1"))
        XCTAssertTrue(shell.smokeSummary.contains("paperWorkflowEvidence=1"))
        XCTAssertTrue(shell.smokeSummary.contains("paperPortfolioImpact=\(String(format: "%.2f", expectedNetPnL))"))
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
        XCTAssertEqual(metricValue("Replay facts", in: report), "16")
        XCTAssertEqual(metricValue("Exec workflow", in: report), "1")
        XCTAssertEqual(metricValue("Replay ops", in: report), "1")
        XCTAssertEqual(metricValue("Scenario replay", in: report), "1")
        XCTAssertEqual(metricValue("Scenario gates", in: report), "6")
        XCTAssertEqual(metricValue("Live gates", in: report), "6")
        XCTAssertEqual(metricValue("Monitoring", in: report), "4")
        XCTAssertEqual(metricValue("Execution control", in: report), "7")
        XCTAssertEqual(metricValue("Live risk", in: report), "6")
        XCTAssertEqual(metricValue("Incident stop", in: report), "5")
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
        XCTAssertTrue(report.details.contains("Execution decisions: paper-replay-execution-decision-allowed"))
        XCTAssertTrue(report.details.contains("Paper orders: paper-replay-order-allowed"))
        XCTAssertTrue(report.details.contains("Simulated fills: paper-replay-fill-allowed"))
        XCTAssertTrue(report.details.contains("Execution workflow streams: paper, portfolio"))
        XCTAssertTrue(report.details.contains("Execution workflow chain: confirmed"))
        XCTAssertTrue(report.details.contains("Execution workflow portfolio projection: confirmed"))
        XCTAssertTrue(report.details.contains("Execution workflow boundary: paper-only"))
        XCTAssertTrue(report.details.contains("Replay operation batches: batch-BTCUSDT-1m-20240101"))
        XCTAssertTrue(
            report.details.contains(
                "Replay operation runs: replay-run-BTCUSDT-1m-20240101T000000Z"
            )
        )
        XCTAssertTrue(report.details.contains("Replay operation freshness: fresh"))
        XCTAssertTrue(report.details.contains("Replay operation retention: retained"))
        XCTAssertTrue(report.details.contains("Replay operation boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Live readiness: blocked"))
        XCTAssertTrue(
            report.details.contains(
                "Live blocked capabilities: API key, signed endpoint, account endpoint, listenKey user data stream, broker adapter, real order lifecycle"
            )
        )
        XCTAssertTrue(report.details.contains("Live blocked boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Live command surface: none"))
        XCTAssertTrue(report.details.contains("Live trading authorization: none"))
        XCTAssertTrue(report.details.contains("Monitoring health: blocked"))
        XCTAssertTrue(report.details.contains("Monitoring connections: disconnected, blocked, unavailable"))
        XCTAssertTrue(report.details.contains("Monitoring streams: 4"))
        XCTAssertTrue(report.details.contains("Monitoring market streams: 1"))
        XCTAssertTrue(report.details.contains("Monitoring order streams: 3"))
        XCTAssertTrue(report.details.contains("Monitoring latency buckets: stale, degraded, nominal, unavailable"))
        XCTAssertTrue(
            report.details.contains(
                "Monitoring errors: MTP71_PUBLIC_MARKET_STREAM_DISCONNECTED, MTP71_PRIVATE_USER_DATA_BLOCKED, MTP71_BROKER_SESSION_UNAVAILABLE"
            )
        )
        XCTAssertTrue(report.details.contains("Monitoring degraded states: degraded, unavailable"))
        XCTAssertTrue(report.details.contains("Monitoring boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Monitoring command surface: none"))
        XCTAssertTrue(report.details.contains("Monitoring trading buttons: none"))
        XCTAssertTrue(report.details.contains("Monitoring schema exposure: none"))
        XCTAssertTrue(report.details.contains("Monitoring runtime exposure: none"))
        XCTAssertTrue(report.details.contains("Monitoring adapter exposure: none"))
        XCTAssertTrue(
            report.details.contains(
                "Execution control gates: submit, cancel, replace, execution report, broker fill, reconciliation, incident fallback"
            )
        )
        XCTAssertTrue(report.details.contains("Execution control boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Execution control command surface: none"))
        XCTAssertTrue(report.details.contains("Execution control order form: none"))
        XCTAssertTrue(report.details.contains("Execution control trading buttons: none"))
        XCTAssertTrue(report.details.contains("Execution control schema exposure: none"))
        XCTAssertTrue(report.details.contains("Execution control runtime exposure: none"))
        XCTAssertTrue(report.details.contains("Execution control adapter exposure: none"))
        XCTAssertTrue(
            report.details.contains(
                "Live risk gates: exposure, order notional, frequency, loss / drawdown, circuit breaker, no-trade state"
            )
        )
        XCTAssertTrue(report.details.contains("Live risk boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Live risk command surface: none"))
        XCTAssertTrue(report.details.contains("Live risk order form: none"))
        XCTAssertTrue(report.details.contains("Live risk trading buttons: none"))
        XCTAssertTrue(
            report.details.contains(
                "Incident / stop gates: audit trail, incident replay, emergency stop, shutdown, restore"
            )
        )
        XCTAssertTrue(report.details.contains("Incident / stop boundary: confirmed"))
        XCTAssertTrue(report.details.contains("Incident replay runtime: none"))
        XCTAssertTrue(report.details.contains("Stop control: none"))
        XCTAssertTrue(report.details.contains("Stop button: none"))
        XCTAssertTrue(report.details.contains("Live PRO Console: none"))
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
        XCTAssertTrue(snapshot.smokeSummary.contains("workbenchReadModelOnly=true"))
        XCTAssertTrue(snapshot.smokeSummary.contains("controls=start,pause,close,reset"))
        XCTAssertTrue(snapshot.smokeSummary.contains("timelineItems=70"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioReplayEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioQualityGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveBlockedGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveExecutionControlGates=7"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveRiskGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveIncidentStopGates=5"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveMonitoringHealth=blocked"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveMonitoringErrors=3"))
    }

    func testDashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly() throws {
        // 测试场景：MTP-52 只在现有 Dashboard / Workbench shell 上增量展示控制壳、
        // observability 和 Evidence Explorer 子集；展示层必须继续保持 read-model-only，
        // 且 session control 只能表达本地 Paper session-level intent。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let workbench = snapshot.workbench

        XCTAssertEqual(workbench.title, "Paper Workflow Control Shell")
        XCTAssertEqual(workbench.sessionControls.map(\.control), [.start, .pause, .close, .reset])
        XCTAssertEqual(workbench.sessionControls.map(\.commandAction), [.start, .pause, .close, .reset])
        XCTAssertTrue(workbench.sessionControls.allSatisfy(\.isSessionLevelLocalPaperControl))
        XCTAssertTrue(workbench.sessionControls.allSatisfy(\.paperOnlyBoundaryHeld))
        XCTAssertEqual(
            workbench.sessionControls.map(\.scope),
            Array(repeating: .localPaperSession, count: 4)
        )
        XCTAssertEqual(
            workbench.sessionControls.map(\.controlLevel),
            Array(repeating: .session, count: 4)
        )
        XCTAssertEqual(
            workbench.sessionControls.map(\.executionMode),
            Array(repeating: .paper, count: 4)
        )
        XCTAssertFalse(workbench.sessionControls.contains { $0.authorizesOrderLevelCommand })
        XCTAssertFalse(workbench.sessionControls.contains { $0.authorizesTradingExecution })
        XCTAssertFalse(workbench.sessionControls.contains { $0.touchesBrokerAction })
        XCTAssertFalse(workbench.sessionControls.contains { $0.submitsRealOrder })
        XCTAssertFalse(workbench.sessionControls.contains { $0.cancelsRealOrder })
        XCTAssertFalse(workbench.sessionControls.contains { $0.replacesRealOrder })

        XCTAssertEqual(workbench.observabilitySections, PaperWorkflowObservabilitySection.allCases)
        XCTAssertEqual(metricValue("Controls", in: workbench.observabilityMetrics), "4")
        XCTAssertEqual(metricValue("Completed sessions", in: workbench.observabilityMetrics), "1")
        XCTAssertEqual(metricValue("Allowed evidence", in: workbench.observabilityMetrics), "3")
        XCTAssertEqual(metricValue("Blocked evidence", in: workbench.observabilityMetrics), "1")
        XCTAssertEqual(metricValue("Replay", in: workbench.observabilityMetrics), "fresh")
        XCTAssertTrue(workbench.observabilityDetails.contains("Session status: started, updated, closed"))
        XCTAssertTrue(
            workbench.observabilityDetails.contains(
                "Session controls: start, pause, close, reset"
            )
        )

        XCTAssertEqual(metricValue("Timeline items", in: workbench.evidenceExplorerMetrics), "70")
        XCTAssertEqual(metricValue("Sections", in: workbench.evidenceExplorerMetrics), "14")
        XCTAssertTrue(
            workbench.evidenceExplorerDetails.contains(
                "Filter: read-only"
            )
        )
        XCTAssertTrue(workbench.timelinePreview.isEmpty == false)
        XCTAssertTrue(workbench.timelinePreview.allSatisfy { $0.contains(":") })
        XCTAssertEqual(metricValue("Live gates", in: workbench.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: workbench.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Status", in: workbench.liveBlockedEvidenceMetrics), "blocked")
        XCTAssertTrue(workbench.liveBlockedEvidenceDetails.contains("Live readiness: blocked"))
        XCTAssertTrue(
            workbench.liveBlockedEvidenceDetails.contains(
                "Live command surface: none"
            )
        )
        XCTAssertTrue(
            workbench.liveBlockedEvidenceDetails.contains(
                "Live trading authorization: none"
            )
        )
        XCTAssertTrue(
            workbench.liveBlockedEvidenceDetails.contains(
                "Live blocked boundary: confirmed"
            )
        )
        XCTAssertEqual(metricValue("Health", in: workbench.liveMonitoringEvidenceMetrics), "blocked")
        XCTAssertEqual(metricValue("Connections", in: workbench.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Streams", in: workbench.liveMonitoringEvidenceMetrics), "4")
        XCTAssertEqual(metricValue("Latency", in: workbench.liveMonitoringEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Errors", in: workbench.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Degraded", in: workbench.liveMonitoringEvidenceMetrics), "2")
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring health: blocked"))
        XCTAssertTrue(
            workbench.liveMonitoringEvidenceDetails.contains(
                "Monitoring connections: disconnected, blocked, unavailable"
            )
        )
        XCTAssertTrue(
            workbench.liveMonitoringEvidenceDetails.contains(
                "Monitoring latency: stale, degraded, nominal, unavailable"
            )
        )
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring command surface: none"))
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring trading buttons: none"))
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring schema exposure: none"))
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring runtime exposure: none"))
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring adapter exposure: none"))
        XCTAssertTrue(workbench.liveMonitoringEvidenceDetails.contains("Monitoring boundary: confirmed"))
        XCTAssertEqual(metricValue("Execution gates", in: workbench.liveExecutionControlBlockedEvidenceMetrics), "7")
        XCTAssertEqual(metricValue("Reasons", in: workbench.liveExecutionControlBlockedEvidenceMetrics), "15")
        XCTAssertEqual(metricValue("Blocked", in: workbench.liveExecutionControlBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            workbench.liveExecutionControlBlockedEvidenceDetails.contains(
                "Execution gates: submit, cancel, replace, execution report, broker fill, reconciliation, incident fallback"
            )
        )
        XCTAssertTrue(
            workbench.liveExecutionControlBlockedEvidenceDetails.contains(
                "Execution command surface: none"
            )
        )
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution order form: none"))
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution trading buttons: none"))
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution schema exposure: none"))
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution runtime exposure: none"))
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution adapter exposure: none"))
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceDetails.contains("Execution boundary: confirmed"))
        XCTAssertEqual(metricValue("Risk gates", in: workbench.liveRiskGateBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: workbench.liveRiskGateBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            workbench.liveRiskGateBlockedEvidenceDetails.contains(
                "Risk gates: exposure, order notional, frequency, loss / drawdown, circuit breaker, no-trade state"
            )
        )
        XCTAssertTrue(workbench.liveRiskGateBlockedEvidenceDetails.contains("Risk command surface: none"))
        XCTAssertTrue(workbench.liveRiskGateBlockedEvidenceDetails.contains("Risk trading buttons: none"))
        XCTAssertTrue(workbench.liveRiskGateBlockedEvidenceDetails.contains("Risk boundary: confirmed"))
        XCTAssertEqual(metricValue("Incident stop gates", in: workbench.liveIncidentStopBlockedEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Blocked", in: workbench.liveIncidentStopBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            workbench.liveIncidentStopBlockedEvidenceDetails.contains(
                "Incident / stop gates: audit trail, incident replay, emergency stop, shutdown, restore"
            )
        )
        XCTAssertTrue(
            workbench.liveIncidentStopBlockedEvidenceDetails.contains(
                "Incident replay runtime: none"
            )
        )
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Stop control: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Emergency stop: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Shutdown command: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Restore command: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Live PRO Console: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Stop button: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Trading buttons: none"))
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceDetails.contains("Incident / stop boundary: confirmed"))

        XCTAssertTrue(workbench.source.isReadModelOnly)
        XCTAssertTrue(workbench.observabilitySource.isReadModelOnly)
        XCTAssertTrue(workbench.evidenceExplorerSource.isReadModelOnly)
        XCTAssertTrue(workbench.liveBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.liveMonitoringEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.liveExecutionControlBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.liveRiskGateBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.liveIncidentStopBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.readModelOnlyBoundaryHeld)
        XCTAssertTrue(workbench.paperOnlyBoundaryHeld)
        XCTAssertFalse(workbench.providesCommandSurface)
        XCTAssertFalse(workbench.providesOrderLevelCommand)
        XCTAssertFalse(workbench.exposesDatabaseSchema)
        XCTAssertFalse(workbench.exposesRuntimeObject)
        XCTAssertFalse(workbench.exposesAdapterRequest)
        XCTAssertFalse(workbench.authorizesLiveTrading)
        XCTAssertFalse(workbench.touchesBrokerAction)
        XCTAssertFalse(workbench.authorizesTradingExecution)
    }

    func testReportDashboardAndTimelineRemainMTP78ReadModelOnly() throws {
        // 测试场景：MTP-78 要求 Report、Dashboard 和 Event Timeline 只能展示 paper-only /
        // read-model evidence。它们可以显示 paper order、simulated fill 和 portfolio projection，
        // 但不能提供 real order command、order form、order-level UI 或交易按钮。
        let boundary = LivePaperRealCommandIsolationBoundary.deterministicFixture
        let viewModel = try makeDashboardViewModel()
        let report = viewModel.report
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let snapshot = DashboardShellSnapshot(viewModel: viewModel)
        let workbench = snapshot.workbench

        XCTAssertTrue(boundary.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(boundary.paperEvidenceCannotUpgradeToRealCommand)
        XCTAssertTrue(boundary.futureRealCommandCapabilitiesBlocked)
        XCTAssertTrue(report.source.isReadModelOnly)
        XCTAssertTrue(report.paperExecutionWorkflowPaperOnlyBoundaryHeld)
        XCTAssertTrue(report.paperExecutionWorkflowCoversDecisionOrderFillChain)
        XCTAssertTrue(report.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill)
        XCTAssertFalse(report.paperExecutionWorkflowAuthorizesLiveTrading)
        XCTAssertFalse(report.paperExecutionWorkflowTouchesBrokerAction)
        XCTAssertFalse(report.paperExecutionWorkflowAuthorizesTradingExecution)
        XCTAssertTrue(report.marketDataReplayReadModelOnlyBoundaryHeld)
        XCTAssertFalse(report.marketDataReplayAuthorizesTradingExecution)
        XCTAssertTrue(report.scenarioReplayReadModelOnlyBoundaryHeld)
        XCTAssertFalse(report.scenarioReplayProvidesCommandSurface)
        XCTAssertFalse(report.scenarioReplaySupportsQueryLanguage)
        XCTAssertFalse(report.scenarioReplayAuthorizesTradingExecution)
        XCTAssertTrue(report.liveReadinessReadModelOnlyBoundaryHeld)
        XCTAssertFalse(report.liveReadinessProvidesCommandSurface)
        XCTAssertFalse(report.liveReadinessAuthorizesLiveTrading)
        XCTAssertFalse(report.liveReadinessAuthorizesTradingExecution)
        XCTAssertTrue(report.liveMonitoringReadModelOnlyBoundaryHeld)
        XCTAssertFalse(report.liveMonitoringProvidesCommandSurface)
        XCTAssertFalse(report.liveMonitoringProvidesOrderLevelCommand)
        XCTAssertFalse(report.liveMonitoringProvidesTradingButton)
        XCTAssertFalse(report.liveMonitoringAuthorizesLiveTrading)
        XCTAssertFalse(report.liveMonitoringAuthorizesTradingExecution)
        XCTAssertTrue(report.liveExecutionControlReadModelOnlyBoundaryHeld)
        XCTAssertTrue(report.liveExecutionControlAllGatesBlocked)
        XCTAssertFalse(report.liveExecutionControlProvidesCommandSurface)
        XCTAssertFalse(report.liveExecutionControlProvidesOrderLevelCommand)
        XCTAssertFalse(report.liveExecutionControlProvidesTradingButton)
        XCTAssertFalse(report.liveExecutionControlAuthorizesLiveExecution)
        XCTAssertFalse(report.liveExecutionControlAuthorizesTradingExecution)
        XCTAssertFalse(report.liveExecutionControlConsumesExecutionReport)
        XCTAssertFalse(report.liveExecutionControlRecordsBrokerFill)
        XCTAssertFalse(report.liveExecutionControlPerformsReconciliation)
        XCTAssertFalse(report.authorizesTradingExecution)

        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertTrue(explorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(explorer.coversPaperOrders)
        XCTAssertTrue(explorer.coversSimulatedFills)
        XCTAssertTrue(explorer.coversPortfolioProjections)
        XCTAssertTrue(explorer.coversReportArtifacts)
        XCTAssertTrue(explorer.coversPaperWorkflowChainEvidence)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)
        XCTAssertFalse(explorer.supportsQueryLanguage)
        XCTAssertFalse(explorer.authorizesLiveTrading)
        XCTAssertFalse(explorer.touchesBrokerAction)
        XCTAssertFalse(explorer.authorizesTradingExecution)
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .paperOrder && $0.evidenceLinks.contains { $0.evidenceID == "paper-replay-order-allowed" }
            }
        )
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .simulatedFill
                    && $0.evidenceLinks.contains { $0.evidenceID == "paper-replay-fill-allowed" }
            }
        )
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .portfolioProjection
                    && $0.evidenceLinks.contains { $0.evidenceID == "paper-replay-portfolio-update" }
            }
        )
        XCTAssertFalse(
            explorer.timelineItems.contains {
                $0.title.localizedCaseInsensitiveContains("real order command")
                    || $0.summary.localizedCaseInsensitiveContains("real order command")
            }
        )

        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertTrue(workbench.readModelOnlyBoundaryHeld)
        XCTAssertTrue(workbench.paperOnlyBoundaryHeld)
        XCTAssertFalse(workbench.providesCommandSurface)
        XCTAssertFalse(workbench.providesOrderLevelCommand)
        XCTAssertFalse(workbench.exposesDatabaseSchema)
        XCTAssertFalse(workbench.exposesRuntimeObject)
        XCTAssertFalse(workbench.exposesAdapterRequest)
        XCTAssertFalse(workbench.authorizesLiveTrading)
        XCTAssertFalse(workbench.touchesBrokerAction)
        XCTAssertFalse(workbench.authorizesTradingExecution)
        XCTAssertFalse(workbench.sessionControls.contains { $0.authorizesOrderLevelCommand })
        XCTAssertFalse(workbench.sessionControls.contains { $0.submitsRealOrder })
        XCTAssertFalse(workbench.sessionControls.contains { $0.cancelsRealOrder })
        XCTAssertFalse(workbench.sessionControls.contains { $0.replacesRealOrder })
        XCTAssertTrue(snapshot.smokeSummary.contains("readModelOnly=true"))
        XCTAssertTrue(snapshot.smokeSummary.contains("workbenchReadModelOnly=true"))
    }

    func testDashboardShellInitialSnapshotIsEmptyReadModelProjection() {
        // 测试场景：可运行 macOS shell 的默认快照只能表示空事实投影和静态 Live blocked gates，
        // 不能伪造行情、Paper、Risk、Portfolio 或真实交易事件事实。
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
        XCTAssertEqual(report?.metrics.first { $0.label == "Exec workflow" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Scenario replay" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Scenario gates" }?.value, "0")
        XCTAssertEqual(report?.metrics.first { $0.label == "Live gates" }?.value, "6")
        XCTAssertEqual(report?.metrics.first { $0.label == "Monitoring" }?.value, "4")
        XCTAssertEqual(report?.metrics.first { $0.label == "Execution control" }?.value, "7")
        XCTAssertEqual(report?.metrics.first { $0.label == "Live risk" }?.value, "6")
        XCTAssertEqual(report?.metrics.first { $0.label == "Incident stop" }?.value, "5")

        let events = snapshot.sections.first { $0.section == .events }
        XCTAssertEqual(events?.metrics.first { $0.label == "Events" }?.value, "0")
        XCTAssertEqual(events?.metrics.first { $0.label == "Last sequence" }?.value, "n/a")

        XCTAssertEqual(metricValue("Controls", in: snapshot.workbench.observabilityMetrics), "4")
        XCTAssertEqual(metricValue("Timeline items", in: snapshot.workbench.evidenceExplorerMetrics), "42")
        XCTAssertEqual(metricValue("Scenarios", in: snapshot.workbench.scenarioReplayEvidenceMetrics), "0")
        XCTAssertEqual(metricValue("Quality gates", in: snapshot.workbench.scenarioReplayEvidenceMetrics), "0")
        XCTAssertEqual(metricValue("Live gates", in: snapshot.workbench.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Health", in: snapshot.workbench.liveMonitoringEvidenceMetrics), "blocked")
        XCTAssertEqual(metricValue("Errors", in: snapshot.workbench.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Execution gates", in: snapshot.workbench.liveExecutionControlBlockedEvidenceMetrics), "7")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.workbench.liveExecutionControlBlockedEvidenceMetrics), "confirmed")
        XCTAssertEqual(metricValue("Risk gates", in: snapshot.workbench.liveRiskGateBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.workbench.liveRiskGateBlockedEvidenceMetrics), "confirmed")
        XCTAssertEqual(metricValue("Incident stop gates", in: snapshot.workbench.liveIncidentStopBlockedEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.workbench.liveIncidentStopBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(snapshot.workbench.readModelOnlyBoundaryHeld)
        XCTAssertFalse(snapshot.workbench.providesOrderLevelCommand)
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
        XCTAssertFalse(shellSource.contains("Button("))
        XCTAssertFalse(shellSource.contains("TextField("))
        XCTAssertFalse(shellSource.contains("Toggle("))

        XCTAssertFalse(executableSource.contains("import Runtime"))
        XCTAssertFalse(executableSource.contains("import Adapters"))
        XCTAssertFalse(executableSource.contains("BinancePublic"))
        XCTAssertFalse(executableSource.contains("SQLite"))
        XCTAssertFalse(executableSource.contains("DuckDB"))
        XCTAssertFalse(executableSource.contains("Button("))
        XCTAssertFalse(executableSource.contains("TextField("))
        XCTAssertFalse(executableSource.contains("Toggle("))
    }

    func testLiveRiskGateBlockedEvidenceViewModelAggregatesMTP87ReadOnlySurface() throws {
        // 测试场景：MTP-87 只把 Core Live Risk blocked evidence 复制成 App 只读快照。
        // Report / Dashboard / Event Timeline 可以展示 gate 和 reason，但不能提供风险命令或交易按钮。
        let readModel = LiveRiskGateBlockedEvidenceReadModel()
        let viewModel = LiveRiskGateBlockedEvidenceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(viewModel.contractID, "mtp-87-live-risk-gate-blocked-evidence")
        XCTAssertEqual(viewModel.issueID, "MTP-87")
        XCTAssertEqual(viewModel.blockedGateCount, 6)
        XCTAssertEqual(
            viewModel.blockedGateLabels,
            [
                "exposure",
                "order notional",
                "frequency",
                "loss / drawdown",
                "circuit breaker",
                "no-trade state"
            ]
        )
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("account state source forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("real order notional evaluation forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("real loss / drawdown runtime forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("circuit breaker runtime forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("no-trade state runtime forbidden"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY"))
        XCTAssertTrue(viewModel.deterministicSnapshot.first?.hasPrefix("exposure|blocked|") == true)
        XCTAssertTrue(viewModel.allRiskGatesBlocked)
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.exposesPersistenceSchema)
        XCTAssertFalse(viewModel.readsAdapter)
        XCTAssertFalse(viewModel.invokesRuntimeControl)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesRiskCommandSurface)
        XCTAssertFalse(viewModel.providesPositionManagementCommand)
        XCTAssertFalse(viewModel.exposesOrderForm)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.authorizesLiveRiskDecision)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.readsRealAccountBalance)
        XCTAssertFalse(viewModel.syncsBrokerPosition)
        XCTAssertFalse(viewModel.readsMargin)
        XCTAssertFalse(viewModel.readsLeverage)
        XCTAssertFalse(viewModel.evaluatesRealPreTradeAllow)
        XCTAssertFalse(viewModel.evaluatesRealPreTradeReject)
        XCTAssertFalse(viewModel.runsCircuitBreakerRuntime)
        XCTAssertFalse(viewModel.entersNoTradeStateRuntime)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)
    }

    func testLiveRiskGateEvidenceExplorerPreviewDefinesMTP87ReadOnlyTimelineItems() throws {
        // 测试场景：MTP-87 的 Event Timeline / Evidence Explorer 只展示 Live Risk
        // gate blocked rows，不提供查询语言、risk command、incident replay 或 stop control。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer
        let riskItems = explorer.timelineItems.filter {
            $0.section == .liveRiskGateBlockedEvidence
        }
        let evidenceLinks = riskItems.flatMap(\.evidenceLinks)
        let evidenceIDs = evidenceLinks.map(\.evidenceID)

        XCTAssertEqual(riskItems.count, 6)
        XCTAssertTrue(explorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(riskItems.allSatisfy { $0.title == "Live risk gate blocked" })
        XCTAssertTrue(riskItems.contains { $0.summary.contains("exposure blocked") })
        XCTAssertTrue(riskItems.contains { $0.summary.contains("order notional blocked") })
        XCTAssertTrue(riskItems.contains { $0.summary.contains("loss / drawdown blocked") })
        XCTAssertTrue(riskItems.contains { $0.summary.contains("no-trade state blocked") })
        XCTAssertTrue(evidenceIDs.contains("mtp-87-exposure-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-order-notional-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-frequency-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-loss-drawdown-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-circuit-breaker-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-87-no-trade-state-blocked"))
        XCTAssertTrue(evidenceLinks.allSatisfy { $0.section == .liveRiskGateBlockedEvidence })

        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)
        XCTAssertFalse(explorer.supportsQueryLanguage)
        XCTAssertFalse(explorer.providesLiveAudit)
        XCTAssertFalse(explorer.providesIncidentReplay)
        XCTAssertFalse(explorer.providesStopControl)
        XCTAssertFalse(explorer.authorizesLiveTrading)
        XCTAssertFalse(explorer.touchesBrokerAction)
        XCTAssertFalse(explorer.authorizesTradingExecution)
    }

    func testLiveIncidentStopBlockedEvidenceViewModelAggregatesMTP94ReadOnlySurface() throws {
        // 测试场景：MTP-94 只把 Core incident / stop blocked evidence 复制成 App 只读快照。
        // Report / Dashboard / Event Timeline 可以展示 gate 和 reason，但不能提供 stop button、
        // Live PRO Console、incident replay runtime、shutdown / restore command 或 live command。
        let readModel = LiveIncidentStopBlockedEvidenceReadModel()
        let viewModel = LiveIncidentStopBlockedEvidenceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(viewModel.contractID, "mtp-94-live-incident-stop-blocked-evidence")
        XCTAssertEqual(viewModel.issueID, "MTP-94")
        XCTAssertEqual(viewModel.blockedGateCount, 5)
        XCTAssertEqual(
            viewModel.blockedGateLabels,
            ["audit trail", "incident replay", "emergency stop", "shutdown", "restore"]
        )
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("audit trail runtime forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("incident replay runtime forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("emergency stop command forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("shutdown command forbidden"))
        XCTAssertTrue(viewModel.blockedReasonLabels.contains("restore command forbidden"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES"))
        XCTAssertTrue(viewModel.sourceAnchors.contains("MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE"))
        XCTAssertTrue(viewModel.deterministicSnapshot.first?.hasPrefix("audit trail|blocked|") == true)
        XCTAssertTrue(viewModel.allIncidentStopGatesBlocked)
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.exposesPersistenceSchema)
        XCTAssertFalse(viewModel.readsAdapter)
        XCTAssertFalse(viewModel.invokesRuntimeControl)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesIncidentReplay)
        XCTAssertFalse(viewModel.providesStopControl)
        XCTAssertFalse(viewModel.providesEmergencyStopCommand)
        XCTAssertFalse(viewModel.providesShutdownCommand)
        XCTAssertFalse(viewModel.providesRestoreCommand)
        XCTAssertFalse(viewModel.exposesLiveProConsole)
        XCTAssertFalse(viewModel.providesStopButton)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.readsAPIKey)
        XCTAssertFalse(viewModel.usesSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.executesBrokerAction)
        XCTAssertFalse(viewModel.implementsLiveExecutionAdapter)
        XCTAssertFalse(viewModel.implementsOMS)
        XCTAssertFalse(viewModel.implementsRealOrderStateMachine)
        XCTAssertFalse(viewModel.runsAuditTrailRuntime)
        XCTAssertFalse(viewModel.runsIncidentReplayRuntime)
        XCTAssertFalse(viewModel.runsProductionOperations)
        XCTAssertFalse(viewModel.mutatesBrokerSessionState)
        XCTAssertFalse(viewModel.resumesLiveRuntime)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)
    }

    func testLiveIncidentStopEvidenceExplorerPreviewDefinesMTP94ReadOnlyTimelineItems() throws {
        // 测试场景：MTP-94 的 Event Timeline / Evidence Explorer 只展示 audit / incident /
        // stop blocked rows，不提供查询语言、stop control、incident replay runtime 或 Live PRO Console。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer
        let incidentStopItems = explorer.timelineItems.filter {
            $0.section == .liveIncidentStopBlockedEvidence
        }
        let evidenceLinks = incidentStopItems.flatMap(\.evidenceLinks)
        let evidenceIDs = evidenceLinks.map(\.evidenceID)

        XCTAssertEqual(incidentStopItems.count, 5)
        XCTAssertTrue(explorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(incidentStopItems.allSatisfy { $0.title == "Live incident / stop gate blocked" })
        XCTAssertTrue(incidentStopItems.contains { $0.summary.contains("audit trail blocked") })
        XCTAssertTrue(incidentStopItems.contains { $0.summary.contains("incident replay blocked") })
        XCTAssertTrue(incidentStopItems.contains { $0.summary.contains("emergency stop blocked") })
        XCTAssertTrue(incidentStopItems.contains { $0.summary.contains("shutdown blocked") })
        XCTAssertTrue(incidentStopItems.contains { $0.summary.contains("restore blocked") })
        XCTAssertTrue(evidenceIDs.contains("mtp-94-audit-trail-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-incident-replay-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-emergency-stop-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-shutdown-blocked"))
        XCTAssertTrue(evidenceIDs.contains("mtp-94-restore-blocked"))
        XCTAssertTrue(evidenceLinks.allSatisfy { $0.section == .liveIncidentStopBlockedEvidence })

        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)
        XCTAssertFalse(explorer.supportsQueryLanguage)
        XCTAssertFalse(explorer.providesLiveAudit)
        XCTAssertFalse(explorer.providesIncidentReplay)
        XCTAssertFalse(explorer.providesStopControl)
        XCTAssertFalse(explorer.authorizesLiveTrading)
        XCTAssertFalse(explorer.touchesBrokerAction)
        XCTAssertFalse(explorer.authorizesTradingExecution)
    }

    func testMTP108ScenarioReplayEvidenceFeedsReportWorkbenchAndEventsReadOnly() throws {
        // 测试场景：MTP-108 把 MTP-106 replay evidence 与 MTP-107 quality / report input version
        // 汇总到 Report、Workbench 和 Event Timeline。展示面只能消费 App read model / ViewModel，
        // 不执行 replay、不暴露 schema / adapter / Runtime object，也不提供 command 或交易入口。
        let viewModel = try makeDashboardViewModel()
        let report = viewModel.report
        let scenario = report.scenarioReplayEvidence
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let snapshot = DashboardShellSnapshot(viewModel: viewModel)
        let workbench = snapshot.workbench

        XCTAssertEqual(report.scenarioReplayEvidenceCount, 1)
        XCTAssertEqual(report.scenarioReplayScenarioIDs, ["mtp-104-btcusdt-1m-first-scenario"])
        XCTAssertEqual(report.scenarioReplayDatasetVersions, ["dataset-v1"])
        XCTAssertEqual(report.scenarioReplayFixtureVersions, ["fixture-v1"])
        XCTAssertEqual(report.scenarioReplaySymbols, ["BTCUSDT"])
        XCTAssertEqual(report.scenarioReplayTimeframes, ["1m"])
        XCTAssertEqual(report.scenarioReplayWindows, ["1704067200...1704067380"])
        XCTAssertEqual(report.scenarioReplayChecksums, ["fnv1a64:3c6cd4ff13cd4062"])
        XCTAssertEqual(report.scenarioReplayFreshnessStatuses, [.fresh])
        XCTAssertEqual(report.scenarioReplayQualityVerdicts, [.accepted])
        XCTAssertEqual(report.scenarioReplayQualityGateTimelineCount, 6)
        XCTAssertEqual(report.scenarioReplayTimelineEntryCount, 10)
        XCTAssertTrue(report.scenarioReplayReportReproducibilityEvidenceHeld)
        XCTAssertTrue(report.scenarioReplayReadModelOnlyBoundaryHeld)
        XCTAssertFalse(report.scenarioReplayExposesDatabaseSchema)
        XCTAssertFalse(report.scenarioReplayExposesRuntimeObject)
        XCTAssertFalse(report.scenarioReplayExposesAdapterRequest)
        XCTAssertFalse(report.scenarioReplayProvidesCommandSurface)
        XCTAssertFalse(report.scenarioReplaySupportsQueryLanguage)
        XCTAssertFalse(report.scenarioReplayProvidesLiveCommand)
        XCTAssertFalse(report.scenarioReplayProvidesTradingButton)
        XCTAssertFalse(report.scenarioReplayAuthorizesLiveTrading)
        XCTAssertFalse(report.scenarioReplayTouchesBrokerAction)
        XCTAssertFalse(report.scenarioReplayAuthorizesTradingExecution)
        XCTAssertFalse(report.scenarioReplayRequiredValidationDependsOnNetwork)

        XCTAssertEqual(scenario.evidenceCount, 1)
        XCTAssertEqual(scenario.qualityGateTimelineCount, 6)
        XCTAssertEqual(scenario.timelineEntryCount, 10)
        XCTAssertTrue(scenario.allQualityAccepted)
        XCTAssertTrue(scenario.reportInputVersionIdentities.first?.contains("accepted") == true)
        XCTAssertTrue(scenario.reportInputVersionIdentities.first?.contains("fnv1a64:3c6cd4ff13cd4062") == true)
        XCTAssertEqual(scenario.drillDownEntries, [
            "scenario replay / mtp-104-btcusdt-1m-first-scenario / accepted"
        ])

        let scenarioItems = explorer.timelineItems.filter { $0.section == .scenarioReplayEvidence }
        let scenarioTitles = scenarioItems.map(\.title)
        let scenarioEvidenceIDs = scenarioItems.flatMap(\.evidenceLinks).map(\.evidenceID)
        XCTAssertEqual(scenarioItems.count, 10)
        XCTAssertTrue(explorer.coversScenarioReplayEvidence)
        XCTAssertTrue(scenarioTitles.contains("Scenario replay window"))
        XCTAssertTrue(scenarioTitles.contains("Scenario replay cursor"))
        XCTAssertTrue(scenarioTitles.contains("Scenario replay checksum"))
        XCTAssertTrue(scenarioTitles.contains("Scenario replay freshness"))
        XCTAssertEqual(scenarioTitles.filter { $0 == "Scenario data quality gate" }.count, 6)
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-window"))
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-cursor"))
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-checksum"))
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-freshness"))
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-gate-record-order"))
        XCTAssertTrue(scenarioEvidenceIDs.contains("scenario-replay-mtp-104-btcusdt-1m-first-scenario-fixture-v1-gate-duplicate-data"))

        let reportSection = try XCTUnwrap(snapshot.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Scenario replay", in: reportSection), "1")
        XCTAssertEqual(metricValue("Scenario gates", in: reportSection), "6")
        XCTAssertTrue(reportSection.details.contains("Scenario replay quality: accepted"))
        XCTAssertTrue(reportSection.details.contains("Scenario replay command surface: none"))
        XCTAssertEqual(metricValue("Scenarios", in: workbench.scenarioReplayEvidenceMetrics), "1")
        XCTAssertEqual(metricValue("Quality gates", in: workbench.scenarioReplayEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Report inputs", in: workbench.scenarioReplayEvidenceMetrics), "1")
        XCTAssertEqual(metricValue("Quality", in: workbench.scenarioReplayEvidenceMetrics), "accepted")
        XCTAssertTrue(workbench.scenarioReplayEvidenceSource.isReadModelOnly)
        XCTAssertTrue(workbench.scenarioReplayEvidenceDetails.contains("Quality verdicts: accepted"))
        XCTAssertTrue(workbench.scenarioReplayEvidenceDetails.contains("Command surface: none"))
        XCTAssertTrue(workbench.scenarioReplayEvidenceDetails.contains("Query language: none"))
        XCTAssertTrue(workbench.readModelOnlyBoundaryHeld)
        XCTAssertFalse(workbench.providesCommandSurface)
        XCTAssertFalse(workbench.authorizesTradingExecution)
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioReplayEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioQualityGates=6"))
    }

    private func makeDashboardViewModel() throws -> DashboardViewModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let marketDataReplayOperations = try makeMarketDataReplayOperationsReadModel()
        let scenarioReplayEvidence = makeScenarioReplayEvidenceReadModel()
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence
        )

        return DashboardViewModel(readModel: readModel)
    }

    private func makeEvidenceExplorerReadModel() throws -> PaperWorkflowEvidenceExplorerReadModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let marketDataReplayOperations = try makeMarketDataReplayOperationsReadModel()
        let scenarioReplayEvidence = makeScenarioReplayEvidenceReadModel()
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence
        )

        return readModel.paperWorkflowEvidenceExplorer
    }

    private func makeMarketDataReplayOperationsReadModel() throws -> MarketDataReplayOperationsEvidenceReadModel {
        // 测试场景：MTP-59 只把 MTP-58 已验证 summary 复制成 App 层 read model。
        // App / Dashboard 不导入 Runtime object，不读取 SQLite / DuckDB schema，也不触发 replay side effect。
        let summary = try MarketDataReplayProjectionConsistencyFixture.deterministicSummary()
        let retentionStatus: MarketDataReplayOperationsRetentionStatus = summary.freshnessSummary
            .contains("retained=true") ? .retained : .notRetained
        let item = MarketDataReplayOperationsEvidenceItem(
            batchID: summary.batchID,
            replayRunID: summary.replayRunID,
            symbol: summary.symbol,
            timeframe: summary.timeframe,
            freshnessStatus: summary.freshnessStatus.rawValue,
            retentionStatus: retentionStatus,
            projectionConsistencySummary: summary.summaryLine,
            metadataRecordCount: summary.metadataRecordCount,
            eventLogRecordCount: summary.eventLogRecordCount,
            replayedRecordCount: summary.replayedRecordCount,
            cacheBarCount: summary.cacheBarCount,
            analyticalMarketBarCount: summary.analyticalMarketBarCount,
            eventLogLastSequence: summary.eventLogLastSequence,
            projectionLastAppliedSequence: summary.projectionLastAppliedSequence,
            eventLogConsistencyHeld: summary.eventLogConsistencyHeld,
            projectionSnapshotConsistencyHeld: summary.projectionSnapshotConsistencyHeld,
            deterministicProjectionSummary: summary.deterministicProjectionSummary,
            readModelOnlyBoundaryHeld: summary.readModelOnlyBoundaryHeld,
            isPublicReadOnly: summary.isPublicReadOnly,
            isLocalFixtureReplayOnly: summary.isLocalFixtureReplayOnly,
            requiredValidationIsLocalOnly: summary.requiredValidationIsLocalOnly,
            requiredValidationDependsOnNetwork: summary.requiredValidationDependsOnNetwork,
            exposesSQLiteSchema: summary.exposesSQLiteSchema,
            exposesDuckDBSchema: summary.exposesDuckDBSchema,
            exposesAdapterRequest: summary.exposesAdapterRequest,
            exposesRuntimeObject: summary.exposesRuntimeObject,
            exposesSQLStatement: summary.exposesSQLStatement,
            authorizesLiveTrading: summary.authorizesLiveTrading,
            touchesBrokerAction: summary.touchesBrokerAction,
            authorizesTradingExecution: summary.authorizesTradingExecution,
            authorizesProductionRuntimeOperations: summary.authorizesProductionRuntimeOperations
        )

        return MarketDataReplayOperationsEvidenceReadModel(items: [item])
    }

    private func makeScenarioReplayEvidenceReadModel() -> ScenarioReplayEvidenceReadModel {
        // 测试场景：MTP-108 只把 MTP-107 Core 聚合证据复制成 App 层 read model。
        // App / Dashboard 不执行 replay、不读取 schema、不调用 adapter，也不暴露 command / live surface。
        ScenarioReplayEvidenceReadModel.deterministicFixture
    }

    private func metricValue(
        _ label: String,
        in section: DashboardShellSectionSnapshot
    ) -> String? {
        section.metrics.first { $0.label == label }?.value
    }

    private func metricValue(
        _ label: String,
        in metrics: [DashboardShellMetric]
    ) -> String? {
        metrics.first { $0.label == label }?.value
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
