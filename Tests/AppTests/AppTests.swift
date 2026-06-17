import Adapters
import Core
import Dashboard
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
            viewModel.report.simulatedExchangeParityEvidence.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.simulatedExchangeParityEvidence.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityEvidence.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityEvidence.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityEvidence.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityEvidence.source.providesLiveOrderAction)
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
            viewModel.report.liveReadOnlyDashboardBoundary.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.accountPositionBalanceReadModelOnlySurface.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.source.providesLiveOrderAction)
        XCTAssertEqual(
            viewModel.report.privateStreamSimulationGateEvidenceSurface.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.source.exposesORMModels)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.source.providesLiveOrderAction)
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
        XCTAssertEqual(
            viewModel.dashboardBetaAcceptancePath.source.sourceKind,
            .stableReadModelProjection
        )
        XCTAssertFalse(viewModel.dashboardBetaAcceptancePath.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.dashboardBetaAcceptancePath.source.exposesORMModels)
        XCTAssertFalse(viewModel.dashboardBetaAcceptancePath.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.dashboardBetaAcceptancePath.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.dashboardBetaAcceptancePath.source.providesLiveOrderAction)
        XCTAssertEqual(viewModel.events.source.sourceKind, .stableReadModelProjection)
        XCTAssertFalse(viewModel.events.source.exposesDatabaseTables)
        XCTAssertFalse(viewModel.events.source.exposesORMModels)
        XCTAssertFalse(viewModel.events.source.exposesRuntimeObjects)
        XCTAssertFalse(viewModel.events.source.callsBinanceAdapter)
        XCTAssertFalse(viewModel.events.source.providesLiveOrderAction)
    }

    func testLiveReadOnlyDashboardBoundaryViewModelAggregatesMTP131ReadOnlySurface() throws {
        // 测试场景：MTP-131 只把 Core deterministic fixture 映射成 App 层 ReadModel / ViewModel，
        // 供 Dashboard、Report 和 Event Timeline 展示；任何 API key、connect、command 或订单 surface 都必须缺席。
        let readModel = LiveReadOnlyDashboardBoundaryReadModel()
        let viewModel = LiveReadOnlyDashboardBoundaryViewModel(readModel: readModel)

        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertTrue(viewModel.source.isReadModelOnly)
        XCTAssertEqual(viewModel.contractID, "mtp-131-live-read-only-workbench-read-model-boundary")
        XCTAssertEqual(viewModel.issueID, "MTP-131")
        XCTAssertEqual(viewModel.matrixID, "TVM-LIVE-READ-ONLY-READINESS")
        XCTAssertEqual(viewModel.boundarySurfaceCount, 5)
        XCTAssertEqual(viewModel.inputBoundaryCount, 9)
        XCTAssertEqual(viewModel.forbiddenUISurfaceCount, 19)
        XCTAssertEqual(viewModel.detailAuditRouteCount, 4)
        XCTAssertEqual(viewModel.handoffTargetCount, 3)
        XCTAssertTrue(viewModel.boundarySurfaceLabels.contains("Workbench Live readiness evidence"))
        XCTAssertTrue(viewModel.boundarySurfaceLabels.contains("Dashboard Live readiness summary"))
        XCTAssertTrue(viewModel.inputBoundaryLabels.contains("Dashboard shell snapshot"))
        XCTAssertTrue(viewModel.forbiddenUISurfaceLabels.contains("API key input"))
        XCTAssertTrue(viewModel.forbiddenUISurfaceLabels.contains("Live PRO Console"))
        XCTAssertTrue(viewModel.forbiddenUISurfaceLabels.contains("trading button"))
        XCTAssertTrue(viewModel.forbiddenUISurfaceLabels.contains("order form"))
        XCTAssertTrue(
            viewModel.handoffTargetLabels.contains(
                "L3.1 account / position / balance read-model-only"
            )
        )
        XCTAssertTrue(
            viewModel.validationAnchors.contains(
                "MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY"
            )
        )
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.exposesAPIKeyInput)
        XCTAssertFalse(viewModel.storesSecret)
        XCTAssertFalse(viewModel.providesBrokerConnect)
        XCTAssertFalse(viewModel.providesAccountConnect)
        XCTAssertFalse(viewModel.exposesLivePROConsole)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.providesLiveCommand)
        XCTAssertFalse(viewModel.exposesOrderForm)
        XCTAssertFalse(viewModel.exposesRuntimeObject)
        XCTAssertFalse(viewModel.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.exposesAdapterSurface)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.callsSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.instantiatesBrokerAdapter)
        XCTAssertFalse(viewModel.implementsLiveExecutionAdapter)
        XCTAssertFalse(viewModel.implementsOMS)
        XCTAssertFalse(viewModel.implementsRealOrderLifecycle)
        XCTAssertFalse(viewModel.submitsRealOrder)
        XCTAssertFalse(viewModel.cancelsRealOrder)
        XCTAssertFalse(viewModel.replacesRealOrder)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(
            LiveReadOnlyDashboardBoundaryViewModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, viewModel)
    }

    func testGH468DashboardLivePROConsoleSplitKeepsDashboardReadModelOnly() throws {
        // 测试场景：GH-468 只允许 Dashboard 继续展示 read-model-only evidence，并把未来
        // submit / cancel / replace command surface 固定在独立 Live PRO Console gate 中。
        let dashboardBoundary = DashboardTargetBoundary.gh420
        let runtime = try L4DashboardCommandSplitRuntime.deterministicFixture()
        let evidence = try runtime.deterministicEvidence()

        XCTAssertTrue(dashboardBoundary.dependencyDirectionHeld)
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertTrue(evidence.splitEvidenceHeld)
        XCTAssertEqual(evidence.contract.issueID, "GH-468")
        XCTAssertEqual(evidence.contract.upstreamIssueIDs, ["GH-464", "GH-465", "GH-466", "GH-467"])
        XCTAssertEqual(evidence.contract.dashboardSurface, .dashboard)
        XCTAssertEqual(evidence.contract.commandSurface, .livePROConsole)
        XCTAssertEqual(evidence.contract.dashboardState, .readOnly)
        XCTAssertEqual(evidence.contract.commandGateStates, L4CommandGateState.allCases)
        XCTAssertEqual(evidence.contract.liveConsoleGatedActions, L4LiveCommandAction.allCases)
        XCTAssertTrue(evidence.contract.dashboardVisibleActions.isEmpty)
        XCTAssertTrue(evidence.contract.dashboardEnabledActions.isEmpty)
        XCTAssertFalse(evidence.contract.commandUIDefaultVisible)
        XCTAssertFalse(evidence.contract.commandUIDefaultEnabled)
        XCTAssertTrue(evidence.contract.consumesViewModelReadModelCommandGateState)
        XCTAssertTrue(evidence.contract.riskEngineGateRequired)
        XCTAssertTrue(evidence.contract.omsGateRequired)
        XCTAssertTrue(evidence.contract.killSwitchGateRequired)
        XCTAssertTrue(evidence.contract.reconciliationEvidenceRequired)
        XCTAssertTrue(evidence.contract.auditTrailEvidenceRequired)
        XCTAssertFalse(evidence.contract.productionCommandEnabled)
        XCTAssertFalse(evidence.contract.brokerGatewayTouched)
        XCTAssertFalse(evidence.contract.signedEndpointCalled)
        XCTAssertFalse(evidence.contract.realOrderSubmitted)

        XCTAssertEqual(Set(evidence.commandGateViewModels.map(\.state)), Set(L4CommandGateState.allCases))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.commandGateBoundaryHeld))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.surface == .livePROConsole })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.gatedActions == L4LiveCommandAction.allCases })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.dashboardCommandSurfaceVisible == false })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.commandSurfaceEnabled == false })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.consumesCommandGateState))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.requiresGH469GuardedUISurface))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.riskEngineGateRequired))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.omsGateRequired))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.killSwitchGateRequired))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.reconciliationEvidenceRequired))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy(\.auditTrailEvidenceRequired))
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.submitsRealOrder == false })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.cancelsRealOrder == false })
        XCTAssertTrue(evidence.commandGateViewModels.allSatisfy { $0.replacesRealOrder == false })
        XCTAssertFalse(try XCTUnwrap(evidence.commandGateViewModels.first { $0.state == .readOnly }).liveConsoleCommandSurfaceVisible)
        XCTAssertTrue(try XCTUnwrap(evidence.commandGateViewModels.first { $0.state == .armed }).liveConsoleCommandSurfaceVisible)
        XCTAssertTrue(try XCTUnwrap(evidence.commandGateViewModels.first { $0.state == .blocked }).liveConsoleCommandSurfaceVisible)
        XCTAssertFalse(try XCTUnwrap(evidence.commandGateViewModels.first { $0.state == .incident }).liveConsoleCommandSurfaceVisible)

        XCTAssertTrue(evidence.dashboardReadModelOnly)
        XCTAssertTrue(evidence.commandSurfaceOnlyInLivePROConsole)
        XCTAssertTrue(evidence.commandUIDefaultInvisibleOrDisabled)
        XCTAssertTrue(evidence.consumesOnlyViewModelReadModelCommandGateState)
        XCTAssertFalse(evidence.dashboardProvidesSubmitCancelReplace)
        XCTAssertFalse(evidence.productionCommandEnabled)
        XCTAssertFalse(evidence.riskEngineBypassed)
        XCTAssertFalse(evidence.omsBypassed)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertTrue(evidence.validationAnchors.contains("GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-468-DASHBOARD-READ-MODEL-ONLY"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-468-LIVEPRO-CONSOLE-COMMAND-GATE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-468-READONLY-ARMED-BLOCKED-INCIDENT-STATES"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-468-NO-DASHBOARD-SUBMIT-CANCEL-REPLACE"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT"))

        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/Dashboard/FutureLiveProConsole/L4DashboardCommandSplit.swift"
                ).path
            )
        )
    }

    func testGH468DashboardLivePROConsoleSplitRejectsDashboardCommandsAndGateBypass() throws {
        // 测试场景：Dashboard command surface、提前启用 Live PRO Console command UI、
        // production command 或缺少 gate state coverage 都必须被 GH-468 合同拒绝。
        XCTAssertThrowsError(
            try L4DashboardLivePROConsoleCommandSplitContract(
                dashboardVisibleActions: [.submit]
            )
        ) { error in
            XCTAssertEqual(error as? L4DashboardCommandSplitContractError, .dashboardCommandSurfaceExposed)
        }

        XCTAssertThrowsError(
            try L4LivePROConsoleCommandGateViewModel(
                state: .armed,
                commandSurfaceEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? L4DashboardCommandSplitContractError,
                .liveConsoleEnabledBeforeGuardedUIIssue
            )
        }

        XCTAssertThrowsError(
            try L4DashboardCommandSplitRuntime(productionCommandEnabled: true)
        ) { error in
            XCTAssertEqual(
                error as? L4DashboardCommandSplitContractError,
                .forbiddenCapabilityEnabled("productionCommandEnabled")
            )
        }

        let runtime = try L4DashboardCommandSplitRuntime.deterministicFixture()
        let evidence = try runtime.deterministicEvidence()
        XCTAssertThrowsError(
            try L4DashboardLivePROConsoleCommandSplitEvidence(
                contract: evidence.contract,
                commandGateViewModels: Array(evidence.commandGateViewModels.dropLast())
            )
        ) { error in
            XCTAssertEqual(error as? L4DashboardCommandSplitContractError, .commandGateStatesMismatch)
        }
    }

    func testGH469GuardedCommandUISurfaceAllowsSandboxOnlySubmitCancelReplace() throws {
        // 测试场景：GH-469 只允许 Live PRO Console 暴露 sandbox-gated guarded controls；
        // Dashboard 仍然 read-model-only，production gate 未满足时不能执行真实 command。
        let runtime = try L4GuardedCommandUISurfaceRuntime.deterministicFixture()
        let evidence = try runtime.deterministicEvidence()

        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertTrue(evidence.guardedSurfaceEvidenceHeld)
        XCTAssertTrue(evidence.splitEvidence.splitEvidenceHeld)
        XCTAssertEqual(evidence.issueID, "GH-469")
        XCTAssertEqual(evidence.upstreamIssueIDs, ["GH-468"])
        XCTAssertEqual(evidence.controls.map(\.action), L4LiveCommandAction.allCases)
        XCTAssertEqual(evidence.sandboxOnlyActions, L4LiveCommandAction.allCases)
        XCTAssertTrue(evidence.dashboardReadModelOnly)
        XCTAssertTrue(evidence.livePROConsoleSurfaceOnly)
        XCTAssertTrue(evidence.controlsDisabledByDefault)
        XCTAssertTrue(evidence.allControlsHaveConfirmation)
        XCTAssertTrue(evidence.allControlsHaveAuditEvidence)
        XCTAssertTrue(evidence.blockedReasonVisible)
        XCTAssertTrue(evidence.incidentStopVisible)
        XCTAssertTrue(evidence.riskEngineEvidenceConsumed)
        XCTAssertTrue(evidence.omsEvidenceConsumed)
        XCTAssertTrue(evidence.executionEngineSandboxEvidenceConsumed)
        XCTAssertFalse(evidence.productionCommandEnabled)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.signedEndpointCalled)
        XCTAssertFalse(evidence.secretStored)
        XCTAssertFalse(evidence.realSubmitCancelReplaceEnabled)

        XCTAssertTrue(evidence.controls.allSatisfy(\.controlBoundaryHeld))
        XCTAssertTrue(evidence.controls.allSatisfy { $0.surface == .livePROConsole })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.controlStates == L4GuardedCommandUIControlState.allCases })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.defaultEnabled == false })
        XCTAssertTrue(evidence.controls.allSatisfy(\.sandboxGateEnabled))
        XCTAssertTrue(evidence.controls.allSatisfy { $0.productionGateEnabled == false })
        XCTAssertTrue(evidence.controls.allSatisfy(\.confirmationRequired))
        XCTAssertTrue(evidence.controls.allSatisfy { $0.confirmationPrompt.isEmpty == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.confirmationEvidenceID.isEmpty == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.blockedReason.isEmpty == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.incidentStopReason.isEmpty == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.auditEvidenceID.isEmpty == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.dashboardCommandSurfaceVisible == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.brokerGatewayTouched == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.signedEndpointCalled == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.secretStored == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.submitsRealOrder == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.cancelsRealOrder == false })
        XCTAssertTrue(evidence.controls.allSatisfy { $0.replacesRealOrder == false })
        XCTAssertTrue(evidence.validationAnchors.contains("GH-469-GUARDED-SUBMIT-CANCEL-REPLACE-UI-SURFACE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-469-SANDBOX-GATE-ONLY-COMMANDS"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-469-CONFIRMATION-BLOCKED-INCIDENT-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-469-NO-PRODUCTION-COMMAND-DEFAULT"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-GUARDED-COMMAND-UI-SURFACE"))
    }

    func testGH469GuardedCommandUISurfaceRejectsProductionBypassAndMissingEvidence() throws {
        // 测试场景：GH-469 的 guarded UI surface 不能被 production command、Dashboard command surface、
        // 缺失 confirmation、缺失 audit evidence 或绕过 sandbox evidence 的输入扩大。
        XCTAssertThrowsError(
            try L4GuardedCommandUISurfaceRuntime(productionCommandEnabled: true)
        ) { error in
            XCTAssertEqual(
                error as? L4GuardedCommandUISurfaceError,
                .forbiddenCapabilityEnabled("productionCommandEnabled")
            )
        }

        XCTAssertThrowsError(
            try L4GuardedCommandControlViewModel(
                action: .submit,
                surface: .dashboard
            )
        ) { error in
            XCTAssertEqual(error as? L4GuardedCommandUISurfaceError, .commandSurfaceLocationMismatch)
        }

        XCTAssertThrowsError(
            try L4GuardedCommandControlViewModel(
                action: .cancel,
                confirmationRequired: false
            )
        ) { error in
            XCTAssertEqual(error as? L4GuardedCommandUISurfaceError, .missingConfirmation("cancel"))
        }

        XCTAssertThrowsError(
            try L4GuardedCommandControlViewModel(
                action: .replace,
                auditEvidenceID: ""
            )
        ) { error in
            XCTAssertEqual(error as? L4GuardedCommandUISurfaceError, .missingAuditEvidence("replace"))
        }

        XCTAssertThrowsError(
            try L4GuardedCommandControlViewModel(
                action: .submit,
                executionEngineSandboxEvidenceAnchor: "production-broker-path"
            )
        ) { error in
            XCTAssertEqual(
                error as? L4GuardedCommandUISurfaceError,
                .upstreamEvidenceMismatch("executionEngineSandboxEvidenceAnchor")
            )
        }

        let runtime = try L4GuardedCommandUISurfaceRuntime.deterministicFixture()
        let evidence = try runtime.deterministicEvidence()
        XCTAssertThrowsError(
            try L4GuardedCommandUISurfaceEvidence(
                splitEvidence: evidence.splitEvidence,
                controls: Array(evidence.controls.dropLast())
            )
        ) { error in
            XCTAssertEqual(error as? L4GuardedCommandUISurfaceError, .commandActionsMismatch)
        }
    }

    func testGH534ReleaseV010DashboardLiveMonitoringSurfaceIsReadModelOnly() throws {
        // 测试场景：GH-534 只把 release v0.1.0 已完成的 live evidence identity 接入 Dashboard。
        // Dashboard 能读取 connection / account / Trader / EMA / Risk / Execution / Portfolio 摘要，
        // 但不直接消费 runtime object，也不暴露 secret editor、交易按钮、live command 或 order form。
        let surfaceReadModel = ReleaseV010LiveMonitoringSurfaceReadModel()
        XCTAssertTrue(surfaceReadModel.readModelOnlyBoundaryHeld)
        XCTAssertEqual(surfaceReadModel.evidenceItems.count, 7)
        XCTAssertEqual(
            surfaceReadModel.validationAnchors,
            ReleaseV010LiveMonitoringSurfaceReadModel.requiredValidationAnchors
        )
        XCTAssertTrue(
            surfaceReadModel.validationAnchors.contains("GH-534-DASHBOARD-LIVE-MONITORING-SURFACE")
        )
        XCTAssertTrue(
            surfaceReadModel.validationAnchors.contains("GH-534-READ-MODEL-ONLY-NO-COMMAND-SURFACE")
        )

        let surface = ReleaseV010LiveMonitoringSurfaceViewModel(readModel: surfaceReadModel)
        XCTAssertTrue(surface.readModelOnlyBoundaryHeld)
        XCTAssertEqual(surface.issueID, "GH-534")
        XCTAssertEqual(surface.matrixID, "TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE")
        XCTAssertEqual(
            surface.sourceIssueIDs,
            ["GH-526", "GH-528", "GH-529", "GH-530", "GH-532", "GH-533"]
        )
        XCTAssertEqual(surface.connectionHealthCount, 1)
        XCTAssertEqual(surface.accountPrivateStreamStatusCount, 1)
        XCTAssertEqual(surface.traderEMARiskExecutionPortfolioSummaryCount, 5)
        XCTAssertTrue(surface.categoryLabels.contains("connection health"))
        XCTAssertTrue(surface.categoryLabels.contains("Portfolio reconciliation"))
        XCTAssertFalse(surface.consumesRuntimeObject)
        XCTAssertFalse(surface.opensNetworkConnection)
        XCTAssertFalse(surface.exposesAccountPayload)
        XCTAssertFalse(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesSecretEditor)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.authorizesLiveTrading)
        XCTAssertFalse(surface.authorizesTradingExecution)

        let report = ReportReadModel(releaseV010LiveMonitoringSurface: surfaceReadModel)
        let dashboard = DashboardViewModel(
            readModel: DashboardReadModel(
                market: MarketReadModel(),
                strategy: StrategyReadModel(),
                backtest: BacktestReadModel(),
                report: report,
                paper: PaperReadModel(),
                risk: RiskReadModel(),
                portfolio: PortfolioReadModel(),
                events: EventTimelineReadModel()
            )
        )
        XCTAssertEqual(dashboard.report.releaseV010LiveMonitoringEvidenceCount, 7)
        XCTAssertTrue(dashboard.report.releaseV010LiveMonitoringReadModelOnlyBoundaryHeld)
        XCTAssertFalse(dashboard.report.releaseV010LiveMonitoringProvidesCommandSurface)
        XCTAssertFalse(dashboard.report.releaseV010LiveMonitoringProvidesTradingButton)
        XCTAssertFalse(dashboard.report.releaseV010LiveMonitoringAuthorizesTradingExecution)
        XCTAssertTrue(dashboard.viewModelSources.allSatisfy(\.isReadModelOnly))

        let shell = DashboardShellSnapshot(viewModel: dashboard)
        XCTAssertTrue(shell.isReadModelOnly)
        XCTAssertTrue(shell.smokeSummary.contains("releaseLiveMonitoringSurface=7"))
        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertTrue(reportSection.metrics.contains(DashboardShellMetric(label: "Release live", value: "7")))
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release live monitoring boundary: confirmed")
            }
        )
    }

    func testGH535ReleaseV010DashboardControlledCommandSurfaceDefaultsNoTrade() throws {
        // 测试场景：GH-535 可以在 Dashboard 展示受控 command entry，但默认必须是 no-trade。
        // dry-run / Binance testnet 只是 gate label；production 继续禁用，不能生成真实交易命令。
        let commandReadModel = ReleaseV010ControlledCommandSurfaceReadModel()
        XCTAssertTrue(commandReadModel.commandSurfaceBoundaryHeld)
        XCTAssertEqual(
            commandReadModel.validationAnchors,
            ReleaseV010ControlledCommandSurfaceReadModel.requiredValidationAnchors
        )
        XCTAssertTrue(
            commandReadModel.validationAnchors.contains("GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE")
        )
        XCTAssertTrue(
            commandReadModel.validationAnchors.contains("GH-535-PRODUCTION-DISABLED-BY-DEFAULT")
        )

        let surface = ReleaseV010ControlledCommandSurfaceViewModel(readModel: commandReadModel)
        XCTAssertEqual(surface.issueID, "GH-535")
        XCTAssertEqual(surface.matrixID, "TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE")
        XCTAssertEqual(surface.actionLabels, ["cancel", "replace", "submit"])
        XCTAssertEqual(surface.controlCount, 3)
        XCTAssertEqual(surface.defaultModeLabels, ["no-trade"])
        XCTAssertTrue(surface.visibleModeLabels.contains("dry-run"))
        XCTAssertTrue(surface.visibleModeLabels.contains("testnet"))
        XCTAssertTrue(surface.visibleModeLabels.contains("production disabled"))
        XCTAssertTrue(surface.commandEntryDefaultNoTrade)
        XCTAssertTrue(surface.dryRunGateVisible)
        XCTAssertTrue(surface.testnetGateVisible)
        XCTAssertTrue(surface.productionGateVisible)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertTrue(surface.commandSurfaceVisible)
        XCTAssertFalse(surface.commandSurfaceEnabled)
        XCTAssertTrue(surface.operatorConfirmationRequired)
        XCTAssertTrue(surface.riskEngineGateRequired)
        XCTAssertTrue(surface.executionEngineGateRequired)
        XCTAssertTrue(surface.omsGateRequired)
        XCTAssertTrue(surface.killSwitchGateRequired)
        XCTAssertTrue(surface.commandSurfaceBoundaryHeld)
        XCTAssertTrue(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesSecretEditor)
        XCTAssertFalse(surface.readsSecret)
        XCTAssertFalse(surface.opensProductionEndpoint)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.callsExecutionClient)
        XCTAssertFalse(surface.bypassesRiskEngine)
        XCTAssertFalse(surface.bypassesExecutionEngine)
        XCTAssertFalse(surface.bypassesOMS)
        XCTAssertFalse(surface.bypassesKillSwitch)
        XCTAssertFalse(surface.submitsRealOrder)
        XCTAssertFalse(surface.cancelsRealOrder)
        XCTAssertFalse(surface.replacesRealOrder)
        XCTAssertFalse(surface.authorizesTradingExecution)
        XCTAssertTrue(
            surface.productionDisabledExplanations.allSatisfy {
                $0.contains("Production trading is disabled by default")
            }
        )

        let report = ReportReadModel(releaseV010ControlledCommandSurface: commandReadModel)
        let dashboard = DashboardViewModel(
            readModel: DashboardReadModel(
                market: MarketReadModel(),
                strategy: StrategyReadModel(),
                backtest: BacktestReadModel(),
                report: report,
                paper: PaperReadModel(),
                risk: RiskReadModel(),
                portfolio: PortfolioReadModel(),
                events: EventTimelineReadModel()
            )
        )
        XCTAssertEqual(dashboard.report.releaseV010ControlledCommandActionCount, 3)
        XCTAssertTrue(dashboard.report.releaseV010ControlledCommandEntryDefaultNoTrade)
        XCTAssertTrue(dashboard.report.releaseV010ControlledCommandDryRunGateVisible)
        XCTAssertTrue(dashboard.report.releaseV010ControlledCommandTestnetGateVisible)
        XCTAssertTrue(dashboard.report.releaseV010ControlledCommandProductionDisabled)
        XCTAssertFalse(dashboard.report.releaseV010ControlledCommandSurfaceEnabled)
        XCTAssertTrue(dashboard.report.releaseV010ControlledCommandBoundaryHeld)
        XCTAssertFalse(dashboard.report.releaseV010ControlledCommandAuthorizesTradingExecution)
        XCTAssertFalse(dashboard.report.authorizesTradingExecution)
        XCTAssertTrue(dashboard.viewModelSources.allSatisfy(\.isReadModelOnly))

        let shell = DashboardShellSnapshot(viewModel: dashboard)
        XCTAssertTrue(shell.isReadModelOnly)
        XCTAssertTrue(shell.smokeSummary.contains("releaseCommandSurface=3"))
        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertTrue(reportSection.metrics.contains(DashboardShellMetric(label: "Release commands", value: "3")))
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release command default no-trade: confirmed")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release command production disabled: confirmed")
            }
        )
    }

    func testGH536ReleaseV010KillSwitchBlocksSubmitCancelReplaceAndAuditsRollback() throws {
        // 测试场景：GH-536 把 GH-535 的 submit / cancel / replace command entry 全部接入
        // global no-trade、kill switch 和 rollback/operator evidence；Dashboard 只能展示阻断证据。
        let killSwitchReadModel = ReleaseV010KillSwitchNoTradeRollbackSurfaceReadModel()
        XCTAssertTrue(killSwitchReadModel.killSwitchNoTradeRollbackBoundaryHeld)
        XCTAssertEqual(
            killSwitchReadModel.validationAnchors,
            ReleaseV010KillSwitchNoTradeRollbackSurfaceReadModel.requiredValidationAnchors
        )
        XCTAssertTrue(
            killSwitchReadModel.validationAnchors.contains(
                "GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS"
            )
        )
        XCTAssertTrue(
            killSwitchReadModel.validationAnchors.contains(
                "GH-536-SUBMIT-CANCEL-REPLACE-BLOCKED"
            )
        )
        XCTAssertTrue(killSwitchReadModel.rollbackEvidence.rollbackBoundaryHeld)
        XCTAssertEqual(killSwitchReadModel.blockedActions.count, 3)
        XCTAssertEqual(killSwitchReadModel.blockedActions.map(\.action.rawValue), ["cancel", "replace", "submit"])

        for blockedAction in killSwitchReadModel.blockedActions {
            XCTAssertTrue(blockedAction.actionBoundaryHeld)
            XCTAssertTrue(blockedAction.blockedByGlobalNoTrade)
            XCTAssertTrue(blockedAction.blockedByKillSwitch)
            XCTAssertTrue(blockedAction.rollbackEvidenceRequired)
            XCTAssertTrue(blockedAction.operatorEvidenceRequired)
            XCTAssertFalse(blockedAction.commandEntryEnabled)
            XCTAssertFalse(blockedAction.readsSecret)
            XCTAssertFalse(blockedAction.opensProductionEndpoint)
            XCTAssertFalse(blockedAction.connectsBroker)
            XCTAssertFalse(blockedAction.callsExecutionClient)
            XCTAssertFalse(blockedAction.bypassesRiskEngine)
            XCTAssertFalse(blockedAction.bypassesExecutionEngine)
            XCTAssertFalse(blockedAction.bypassesOMS)
            XCTAssertFalse(blockedAction.bypassesKillSwitch)
            XCTAssertFalse(blockedAction.submitsRealOrder)
            XCTAssertFalse(blockedAction.cancelsRealOrder)
            XCTAssertFalse(blockedAction.replacesRealOrder)
            XCTAssertFalse(blockedAction.triggersAutoRecovery)
            XCTAssertFalse(blockedAction.authorizesLiveTrading)
            XCTAssertFalse(blockedAction.authorizesTradingExecution)
        }

        let surface = ReleaseV010KillSwitchNoTradeRollbackSurfaceViewModel(
            readModel: killSwitchReadModel
        )
        XCTAssertEqual(surface.issueID, "GH-536")
        XCTAssertEqual(surface.matrixID, "TVM-RELEASE-V010-KILL-SWITCH-NO-TRADE-ROLLBACK")
        XCTAssertEqual(surface.blockedActionLabels, ["cancel", "replace", "submit"])
        XCTAssertEqual(surface.blockedActionCount, 3)
        XCTAssertTrue(surface.globalNoTradeActive)
        XCTAssertTrue(surface.killSwitchActive)
        XCTAssertTrue(surface.submitCancelReplaceBlocked)
        XCTAssertTrue(surface.rollbackEvidenceAuditable)
        XCTAssertTrue(surface.operatorEvidenceRequired)
        XCTAssertTrue(surface.noAutomaticRecovery)
        XCTAssertTrue(surface.productionTradingDisabledByDefault)
        XCTAssertTrue(surface.commandSurfaceVisible)
        XCTAssertFalse(surface.commandSurfaceEnabled)
        XCTAssertTrue(surface.killSwitchNoTradeRollbackBoundaryHeld)
        XCTAssertTrue(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesSecretEditor)
        XCTAssertFalse(surface.readsSecret)
        XCTAssertFalse(surface.opensProductionEndpoint)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.callsExecutionClient)
        XCTAssertFalse(surface.bypassesRiskEngine)
        XCTAssertFalse(surface.bypassesExecutionEngine)
        XCTAssertFalse(surface.bypassesOMS)
        XCTAssertFalse(surface.bypassesKillSwitch)
        XCTAssertFalse(surface.submitsRealOrder)
        XCTAssertFalse(surface.cancelsRealOrder)
        XCTAssertFalse(surface.replacesRealOrder)
        XCTAssertFalse(surface.triggersAutoRecovery)
        XCTAssertFalse(surface.authorizesLiveTrading)
        XCTAssertFalse(surface.authorizesTradingExecution)

        let report = ReportReadModel(releaseV010KillSwitchNoTradeRollbackSurface: killSwitchReadModel)
        let dashboard = DashboardViewModel(
            readModel: DashboardReadModel(
                market: MarketReadModel(),
                strategy: StrategyReadModel(),
                backtest: BacktestReadModel(),
                report: report,
                paper: PaperReadModel(),
                risk: RiskReadModel(),
                portfolio: PortfolioReadModel(),
                events: EventTimelineReadModel()
            )
        )
        XCTAssertEqual(dashboard.report.releaseV010KillSwitchBlockedActionCount, 3)
        XCTAssertEqual(dashboard.report.releaseV010KillSwitchBlockedActionLabels, ["cancel", "replace", "submit"])
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchGlobalNoTradeActive)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchActive)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchSubmitCancelReplaceBlocked)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchRollbackAuditable)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchOperatorEvidenceRequired)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchNoAutomaticRecovery)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchProductionDisabledByDefault)
        XCTAssertFalse(dashboard.report.releaseV010KillSwitchCommandSurfaceEnabled)
        XCTAssertTrue(dashboard.report.releaseV010KillSwitchBoundaryHeld)
        XCTAssertFalse(dashboard.report.releaseV010KillSwitchAuthorizesTradingExecution)
        XCTAssertFalse(dashboard.report.authorizesTradingExecution)
        XCTAssertTrue(dashboard.viewModelSources.allSatisfy(\.isReadModelOnly))

        let shell = DashboardShellSnapshot(viewModel: dashboard)
        XCTAssertTrue(shell.isReadModelOnly)
        XCTAssertTrue(shell.smokeSummary.contains("releaseKillSwitch=3"))
        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertTrue(
            reportSection.metrics.contains(
                DashboardShellMetric(label: "Release kill switch", value: "3")
            )
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release kill switch blocked SCR: confirmed")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release kill switch rollback: confirmed")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release kill switch command enabled: none")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release kill switch trading execution: none")
            }
        )
    }

    func testAccountPositionBalanceReadModelOnlySurfaceAggregatesMTP138Evidence() throws {
        // 测试场景：MTP-138 只把 MTP-137 deterministic fixture 映射成 App 层 ReadModel / ViewModel，
        // 供 Workbench、Report 和 Event Timeline 展示；任何 account connect、broker connect 或交易入口都必须缺席。
        let readModel = AccountPositionBalanceReadModelOnlySurfaceReadModel()
        let viewModel = AccountPositionBalanceReadModelOnlySurfaceViewModel(readModel: readModel)

        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertTrue(viewModel.source.isReadModelOnly)
        XCTAssertEqual(viewModel.issueID, "MTP-138")
        XCTAssertEqual(viewModel.matrixID, "TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY")
        XCTAssertEqual(viewModel.fixtureVersion, "fixture-v1")
        XCTAssertEqual(viewModel.recordCount, 3)
        XCTAssertEqual(viewModel.eventTraceItemCount, 3)
        XCTAssertEqual(
            viewModel.componentLabels,
            ["account snapshot", "position snapshot", "balance snapshot"]
        )
        XCTAssertEqual(
            viewModel.sourceIdentity,
            "fixture:mtp-137-account-position-balance-read-model-only"
        )
        XCTAssertTrue(viewModel.reportSummary.contains("read-model-only surface"))
        XCTAssertTrue(viewModel.dashboardPanelSummaries.contains {
            $0.contains("Account evidence:")
        })
        XCTAssertTrue(viewModel.blockedStateLabels.contains("account connect blocked"))
        XCTAssertTrue(viewModel.blockedStateLabels.contains("trading button blocked"))
        XCTAssertTrue(viewModel.staleStateLabels.contains("stale balance evidence display only"))
        XCTAssertTrue(viewModel.simulatedStateLabels.contains("simulated position exposure evidence"))
        XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.exposesAPIKeyInput)
        XCTAssertFalse(viewModel.storesSecret)
        XCTAssertFalse(viewModel.providesBrokerConnect)
        XCTAssertFalse(viewModel.providesAccountConnect)
        XCTAssertFalse(viewModel.exposesLivePROConsole)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.providesLiveCommand)
        XCTAssertFalse(viewModel.exposesOrderForm)
        XCTAssertFalse(viewModel.exposesRuntimeObject)
        XCTAssertFalse(viewModel.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.exposesAdapterRequest)
        XCTAssertFalse(viewModel.exposesAccountPayload)
        XCTAssertFalse(viewModel.exposesBrokerState)
        XCTAssertFalse(viewModel.callsSignedEndpoint)
        XCTAssertFalse(viewModel.callsAccountEndpoint)
        XCTAssertFalse(viewModel.createsListenKey)
        XCTAssertFalse(viewModel.connectsBroker)
        XCTAssertFalse(viewModel.implementsLiveExecutionAdapter)
        XCTAssertFalse(viewModel.implementsOMS)
        XCTAssertFalse(viewModel.implementsRealOrderLifecycle)
        XCTAssertFalse(viewModel.readsRealAccount)
        XCTAssertFalse(viewModel.syncsBrokerPosition)
        XCTAssertFalse(viewModel.readsRealPnL)
        XCTAssertFalse(viewModel.readsMargin)
        XCTAssertFalse(viewModel.readsLeverage)
        XCTAssertFalse(viewModel.providesCommandSurface)
        XCTAssertFalse(viewModel.providesOrderLevelCommand)
        XCTAssertFalse(viewModel.authorizesLiveTrading)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(viewModel)
        let decoded = try JSONDecoder().decode(
            AccountPositionBalanceReadModelOnlySurfaceViewModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, viewModel)
    }

    func testPaperWorkflowDashboardInformationArchitectureDefinesSessionControlShellBoundary() throws {
        // 测试场景：MTP-47 只固定 Paper workflow Workbench 信息架构和控制壳边界。
        // fixture 必须保持 read-model-only，并且 session-level control 只能是 start / pause / close / reset。
        let contract = PaperWorkflowDashboardInformationArchitecture.deterministicFixture

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

    func testPaperWorkflowDashboardInformationArchitectureRejectsOutOfScopeControlShellExpansion() throws {
        // 测试场景：任何 order-level command、非 read-model-only source 或提前实现 Command/UI/Event Timeline
        // 的尝试都必须被合同 fixture 拒绝，避免 MTP-47 越界进入后续 issue。
        XCTAssertThrowsError(
            try PaperWorkflowDashboardInformationArchitecture(allowsOrderLevelCommand: true)
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowDashboardContractError, .orderLevelCommandExposed)
        }
        XCTAssertThrowsError(
            try PaperWorkflowDashboardInformationArchitecture(sessionLevelControls: [.start, .pause, .close])
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowDashboardContractError, .sessionControlsMismatch)
        }
        XCTAssertThrowsError(
            try PaperWorkflowDashboardInformationArchitecture(dashboardSections: [.paper])
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowDashboardContractError, .dashboardSectionsMismatch)
        }
        XCTAssertThrowsError(
            try PaperWorkflowDashboardInformationArchitecture(
                source: ViewModelSourceContract(exposesRuntimeObjects: true)
            )
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowDashboardContractError, .sourceIsNotReadModelOnly)
        }
        XCTAssertThrowsError(
            try PaperWorkflowDashboardInformationArchitecture(implementsCommandModel: true)
        ) { error in
            XCTAssertEqual(error as? PaperWorkflowDashboardContractError, .implementationEscapedIssueScope)
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
        // 汇总 market event、account / position / balance 只读 evidence、Live blocked evidence、Live monitoring evidence、execution-control
        // blocked evidence、Strategy / Trader readiness evidence、Live Risk gate blocked evidence、incident / stop blocked evidence、
        // strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact links。
        let explorer = try makeDashboardViewModel().paperWorkflowEvidenceExplorer

        XCTAssertTrue(explorer.source.isReadModelOnly)
        XCTAssertEqual(explorer.timelineItemCount, 95)
        XCTAssertTrue(explorer.coversMarketEvents)
        XCTAssertTrue(explorer.coversMarketDataReplayOperations)
        XCTAssertTrue(explorer.coversScenarioReplayEvidence)
        XCTAssertTrue(explorer.coversSimulatedExchangeParityEvidence)
        XCTAssertTrue(explorer.coversAccountPositionBalanceReadModelOnlySurface)
        XCTAssertTrue(explorer.coversPrivateStreamSimulationGateEvidenceSurface)
        XCTAssertTrue(explorer.coversLiveMonitoringReadOnlyConsoleV2Surface)
        XCTAssertTrue(explorer.coversStrategyTraderReadinessEvidenceSurface)
        XCTAssertTrue(explorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(explorer.coversLiveReadOnlyDashboardBoundary)
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
        XCTAssertEqual(itemCounts[.simulatedExchangeParityEvidence], 7)
        XCTAssertEqual(itemCounts[.accountPositionBalanceReadModelOnlySurface], 3)
        XCTAssertEqual(itemCounts[.privateStreamSimulationGateEvidenceSurface], 4)
        XCTAssertEqual(itemCounts[.liveMonitoringReadOnlyConsoleV2Surface], 4)
        XCTAssertEqual(itemCounts[.strategyTraderReadinessEvidenceSurface], 6)
        XCTAssertEqual(itemCounts[.liveExecutionControlBlockedEvidence], 7)
        XCTAssertEqual(itemCounts[.liveRiskGateBlockedEvidence], 6)
        XCTAssertEqual(itemCounts[.liveIncidentStopBlockedEvidence], 5)
        XCTAssertEqual(itemCounts[.liveReadOnlyDashboardBoundary], 1)
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
        XCTAssertTrue(evidenceIDs.contains("mtp-115-simulated-exchange-portfolio-projection-parity"))
        XCTAssertTrue(evidenceIDs.contains("mtp-131-live-read-only-workbench-read-model-boundary"))
        XCTAssertTrue(evidenceIDs.contains("MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY"))
        XCTAssertTrue(evidenceIDs.contains("account-evidence|fixture|mtp-137|1704067500|fresh"))
        XCTAssertTrue(evidenceIDs.contains("position-evidence|fixture|mtp-137|BTCUSDT|long|1704067500|fresh"))
        XCTAssertTrue(evidenceIDs.contains("balance-evidence|fixture|mtp-137|paper-simulated|1704067500|fresh"))
        XCTAssertTrue(evidenceIDs.contains("MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"))
        XCTAssertTrue(evidenceIDs.contains("mtp-144-simulated-account-snapshot-freshness-evidence"))
        XCTAssertTrue(
            evidenceIDs.contains(
                "MTP-145-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SIMULATION-GATE-SURFACE"
            )
        )
        XCTAssertTrue(evidenceIDs.contains("mtp-148-live-monitoring-source-identity"))
        XCTAssertTrue(evidenceIDs.contains("mtp-149-live-monitoring-simulation-gate-health"))
        XCTAssertTrue(evidenceIDs.contains("mtp-150-live-monitoring-connection-readiness-explanation"))
        XCTAssertTrue(evidenceIDs.contains("mtp-151-live-monitoring-forbidden-capability-tests"))
        XCTAssertTrue(
            evidenceIDs.contains(
                "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            )
        )
        XCTAssertTrue(evidenceIDs.contains("mtp-154-strategy-trader-readiness-terminology"))
        XCTAssertTrue(evidenceIDs.contains("mtp-155-strategy-trader-lifecycle-identity"))
        XCTAssertTrue(evidenceIDs.contains("mtp-156-quoter-hedger-role-taxonomy"))
        XCTAssertTrue(evidenceIDs.contains("mtp-157-account-portfolio-risk-read-model-input"))
        XCTAssertTrue(evidenceIDs.contains("mtp-158-paper-live-neutral-proposal-isolation"))
        XCTAssertTrue(evidenceIDs.contains("mtp-159-forbidden-command-capability-tests"))
        XCTAssertTrue(evidenceIDs.contains("MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION"))
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
        XCTAssertEqual(explorer.timelineItems.last?.section, .strategyTraderReadinessEvidenceSurface)
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
        XCTAssertEqual(viewModel.report.simulatedExchangeParityEvidenceCount, 1)
        XCTAssertEqual(
            viewModel.report.simulatedExchangeParityScenarioIDs,
            ["mtp-104-btcusdt-1m-first-scenario"]
        )
        XCTAssertEqual(viewModel.report.simulatedExchangeParityDatasetVersions, ["dataset-v1"])
        XCTAssertEqual(viewModel.report.simulatedExchangeParityFixtureVersions, ["fixture-v1"])
        XCTAssertEqual(
            viewModel.report.simulatedExchangeParityMatchingResults,
            ["simulated exchange order matched"]
        )
        XCTAssertEqual(
            viewModel.report.simulatedExchangeParityOutcomeLabels,
            ["partial", "full", "rejected simulated", "expired simulated"]
        )
        XCTAssertEqual(viewModel.report.simulatedExchangeParityTimelineEntryCount, 7)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityProjectionParityHeld)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityCostParityConsistent)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityExposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesCommandSurface)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesOrderLevelCommand)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesTradingButton)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityAuthorizesTradingExecution)
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
        XCTAssertEqual(viewModel.report.liveReadOnlyDashboardBoundary.boundarySurfaceCount, 5)
        XCTAssertEqual(viewModel.report.liveReadOnlyDashboardBoundary.forbiddenUISurfaceCount, 19)
        XCTAssertTrue(viewModel.report.liveReadOnlyDashboardBoundary.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.exposesAPIKeyInput)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.providesBrokerConnect)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.providesAccountConnect)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.exposesLivePROConsole)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.providesTradingButton)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.providesLiveCommand)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.exposesOrderForm)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.callsSignedEndpoint)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.callsAccountEndpoint)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.createsListenKey)
        XCTAssertFalse(viewModel.report.liveReadOnlyDashboardBoundary.authorizesTradingExecution)
        XCTAssertEqual(viewModel.report.accountPositionBalanceReadModelOnlySurface.recordCount, 3)
        XCTAssertTrue(viewModel.report.accountPositionBalanceReadModelOnlySurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.providesAccountConnect)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.providesBrokerConnect)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.providesTradingButton)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.providesLiveCommand)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.exposesOrderForm)
        XCTAssertFalse(viewModel.report.accountPositionBalanceReadModelOnlySurface.authorizesTradingExecution)
        XCTAssertEqual(viewModel.report.privateStreamSimulationGateEvidenceSurface.sourceIdentityRecordCount, 3)
        XCTAssertEqual(viewModel.report.privateStreamSimulationGateEvidenceSurface.snapshotInputCount, 1)
        XCTAssertEqual(viewModel.report.privateStreamSimulationGateEvidenceSurface.updateFixtureRecordCount, 3)
        XCTAssertEqual(viewModel.report.privateStreamSimulationGateEvidenceSurface.freshnessEvidenceCount, 4)
        XCTAssertEqual(viewModel.report.privateStreamSimulationGateEvidenceSurface.eventTraceItemCount, 4)
        XCTAssertTrue(viewModel.report.privateStreamSimulationGateEvidenceSurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesAPIKeyInput)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.storesSecret)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.providesAccountConnect)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.providesBrokerConnect)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesLivePROConsole)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.providesTradingButton)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.providesLiveCommand)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesOrderForm)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.callsSignedEndpoint)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.callsAccountEndpoint)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.createsListenKey)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.runsPrivateStreamRuntime)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.runsAccountSnapshotRuntime)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesRuntimeObject)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesAdapterRequest)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesAccountPayload)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.exposesBrokerState)
        XCTAssertFalse(viewModel.report.privateStreamSimulationGateEvidenceSurface.authorizesTradingExecution)
        XCTAssertEqual(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.eventTraceItemCount, 4)
        XCTAssertEqual(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.forbiddenTestCaseCount, 19)
        XCTAssertTrue(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.providesTradingButton)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.providesLiveCommand)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesOrderForm)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesRuntimeObject)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesAdapterRequest)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesAccountPayload)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.exposesBrokerState)
        XCTAssertFalse(viewModel.report.liveMonitoringReadOnlyConsoleV2Surface.authorizesTradingExecution)
        XCTAssertEqual(viewModel.report.strategyTraderReadinessEvidenceSurface.recordCount, 6)
        XCTAssertEqual(viewModel.report.strategyTraderReadinessEvidenceSurface.eventTraceItemCount, 6)
        XCTAssertTrue(viewModel.report.strategyTraderReadinessEvidenceSurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.providesCommandSurface)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.providesOrderLevelCommand)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.providesTradingButton)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.providesLiveCommand)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.exposesOrderForm)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.exposesRuntimeObject)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.exposesAdapterRequest)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.exposesDatabaseSchema)
        XCTAssertFalse(viewModel.report.strategyTraderReadinessEvidenceSurface.authorizesTradingExecution)
        XCTAssertEqual(viewModel.report.latestParityStatus, .matchedProjectionEvidence)
        XCTAssertEqual(viewModel.report.lastAppliedSequence, 16)
        XCTAssertFalse(viewModel.report.tradingValidationAuthorizesExecution)
        XCTAssertFalse(viewModel.report.authorizesTradingExecution)
        XCTAssertEqual(viewModel.paperWorkflowEvidenceExplorer.timelineItemCount, 95)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversPaperWorkflowChainEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversMarketDataReplayOperations)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversSimulatedExchangeParityEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversAccountPositionBalanceReadModelOnlySurface)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversPrivateStreamSimulationGateEvidenceSurface)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveMonitoringReadOnlyConsoleV2Surface)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversStrategyTraderReadinessEvidenceSurface)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversLiveReadOnlyDashboardBoundary)
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

    func testMTP116SimulatedExchangeParityReadModelFeedsReportDashboardAndEvents() throws {
        // 测试场景：MTP-116 只把 MTP-112 至 MTP-115 的 deterministic parity evidence
        // 复制为 Report / Dashboard / Events 可消费的只读 ViewModel，不新增 Runtime command、schema
        // 暴露、broker action、live command、order-level command UI 或交易按钮。
        let viewModel = try makeDashboardViewModel()
        let parity = viewModel.report.simulatedExchangeParityEvidence
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let shell = DashboardShellSnapshot(viewModel: viewModel)

        XCTAssertEqual(parity.evidenceCount, 1)
        XCTAssertEqual(parity.scenarioIDs, ["mtp-104-btcusdt-1m-first-scenario"])
        XCTAssertEqual(parity.datasetVersions, ["dataset-v1"])
        XCTAssertEqual(parity.fixtureVersions, ["fixture-v1"])
        XCTAssertEqual(parity.replayWindows, ["1704067200...1704067380"])
        XCTAssertEqual(parity.matchingResults, ["simulated exchange order matched"])
        XCTAssertEqual(parity.matchingEventIDs, ["mtp-112-simulated-exchange-order-matched"])
        XCTAssertEqual(parity.orderIDs, ["paper-order-intent-allowed"])
        XCTAssertEqual(parity.orderTypes, ["market order simulated execution"])
        XCTAssertEqual(
            parity.outcomeLabels,
            ["partial", "full", "rejected simulated", "expired simulated"]
        )
        XCTAssertEqual(parity.sourceReplaySequences, [3])
        XCTAssertEqual(parity.timelineEntryCount, 7)
        XCTAssertEqual(parity.validationAnchorCount, 7)
        XCTAssertEqual(try XCTUnwrap(parity.matchedPrice), 42_120.70, accuracy: 0.00000001)
        XCTAssertEqual(try XCTUnwrap(parity.matchedQuantity), 0.5, accuracy: 0.00000001)
        XCTAssertEqual(parity.netQuantity, 0.25, accuracy: 0.00000001)
        XCTAssertEqual(parity.grossExposureNotional, 10_530.175, accuracy: 0.00000001)
        XCTAssertEqual(parity.netSimulatedPnL, -6.84461375, accuracy: 0.00000001)
        XCTAssertEqual(parity.feeAmount, 5.2650875, accuracy: 0.00000001)
        XCTAssertEqual(parity.slippageAmount, 1.57952625, accuracy: 0.00000001)
        XCTAssertEqual(try XCTUnwrap(parity.latencyMilliseconds), 250, accuracy: 0.00000001)
        XCTAssertTrue(parity.projectionParityHeld)
        XCTAssertTrue(parity.costParityConsistent)
        XCTAssertTrue(parity.reportReproducibilityEvidenceHeld)
        XCTAssertTrue(parity.readModelOnlyBoundaryHeld)
        XCTAssertFalse(parity.exposesDatabaseSchema)
        XCTAssertFalse(parity.exposesRuntimeObject)
        XCTAssertFalse(parity.exposesAdapterRequest)
        XCTAssertFalse(parity.providesCommandSurface)
        XCTAssertFalse(parity.providesOrderLevelCommand)
        XCTAssertFalse(parity.providesLiveCommand)
        XCTAssertFalse(parity.providesTradingButton)
        XCTAssertFalse(parity.authorizesLiveTrading)
        XCTAssertFalse(parity.touchesBrokerAction)
        XCTAssertFalse(parity.authorizesTradingExecution)
        XCTAssertFalse(parity.requiredValidationDependsOnNetwork)

        XCTAssertEqual(viewModel.report.simulatedExchangeParityEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.simulatedExchangeParityTimelineEntryCount, 7)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityProjectionParityHeld)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityCostParityConsistent)
        XCTAssertTrue(viewModel.report.simulatedExchangeParityReadModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesCommandSurface)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesOrderLevelCommand)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityProvidesTradingButton)
        XCTAssertFalse(viewModel.report.simulatedExchangeParityAuthorizesTradingExecution)

        XCTAssertTrue(explorer.coversSimulatedExchangeParityEvidence)
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .simulatedExchangeParityEvidence
                    && $0.title == "Backtest / paper portfolio parity"
                    && $0.summary.contains("netPnL=-6.84461375")
            }
        )
        XCTAssertTrue(explorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(explorer.providesCommandSurface)
        XCTAssertFalse(explorer.providesOrderLevelCommand)

        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Sim parity", in: reportSection), "1")
        XCTAssertTrue(reportSection.details.contains("Simulated parity portfolio: confirmed"))
        XCTAssertTrue(reportSection.details.contains("Simulated parity command surface: none"))
        XCTAssertTrue(reportSection.details.contains("Simulated parity trading buttons: none"))
        XCTAssertEqual(metricValue("Parity evidence", in: shell.readModelSurface.simulatedExchangeParityEvidenceMetrics), "1")
        XCTAssertEqual(metricValue("Timeline", in: shell.readModelSurface.simulatedExchangeParityEvidenceMetrics), "7")
        XCTAssertTrue(shell.readModelSurface.simulatedExchangeParityEvidenceDetails.contains("Parity boundary: confirmed"))
        XCTAssertTrue(shell.smokeSummary.contains("simulatedParityEvidence=1"))
    }

    func testPrivateStreamSimulationGateEvidenceSurfaceAggregatesMTP145ReadOnlySurface() throws {
        // 测试场景：MTP-145 只能把 MTP-141..144 deterministic Core evidence 汇总成
        // Workbench / Report / Events 的 App read-model-only surface，不能暴露 endpoint、
        // adapter、Runtime、schema、account payload、broker state 或任何真实交易入口。
        let viewModel = try makeDashboardViewModel()
        let surface = viewModel.report.privateStreamSimulationGateEvidenceSurface
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let shell = DashboardShellSnapshot(viewModel: viewModel)

        XCTAssertEqual(surface.issueID, "MTP-145")
        XCTAssertEqual(surface.matrixID, "TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE")
        XCTAssertEqual(surface.sourceIdentityRecordCount, 3)
        XCTAssertEqual(surface.snapshotInputCount, 1)
        XCTAssertEqual(surface.updateFixtureRecordCount, 3)
        XCTAssertEqual(surface.freshnessEvidenceCount, 4)
        XCTAssertEqual(surface.eventTraceItemCount, 4)
        XCTAssertEqual(
            surface.sourceIdentities.first,
            "fixture:private-stream:mtp-141-local-private-account-event"
        )
        XCTAssertEqual(
            surface.snapshotInputIDs,
            ["simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh"]
        )
        XCTAssertEqual(
            surface.freshnessStatuses,
            [.fresh, .stale, .blocked, .missing]
        )
        XCTAssertEqual(
            surface.boundaryReasonCodes,
            [
                "fixture-freshness-within-threshold",
                "fixture-freshness-threshold-exceeded",
                "forbidden-capability-boundary-held",
                "fixture-input-absent"
            ]
        )
        XCTAssertTrue(surface.reportSummary.contains("read-model-only surface"))
        XCTAssertTrue(surface.dashboardPanelSummaries.contains { $0.contains("Forbidden UI") })
        XCTAssertTrue(surface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(surface.exposesAPIKeyInput)
        XCTAssertFalse(surface.storesSecret)
        XCTAssertFalse(surface.providesAccountConnect)
        XCTAssertFalse(surface.providesBrokerConnect)
        XCTAssertFalse(surface.exposesLivePROConsole)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.callsSignedEndpoint)
        XCTAssertFalse(surface.callsAccountEndpoint)
        XCTAssertFalse(surface.createsListenKey)
        XCTAssertFalse(surface.opensPrivateWebSocket)
        XCTAssertFalse(surface.runsPrivateStreamRuntime)
        XCTAssertFalse(surface.runsAccountSnapshotRuntime)
        XCTAssertFalse(surface.exposesRuntimeObject)
        XCTAssertFalse(surface.exposesAdapterRequest)
        XCTAssertFalse(surface.exposesDatabaseSchema)
        XCTAssertFalse(surface.exposesAccountPayload)
        XCTAssertFalse(surface.exposesBrokerState)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.implementsLiveExecutionAdapter)
        XCTAssertFalse(surface.implementsOMS)
        XCTAssertFalse(surface.writesRealOrder)
        XCTAssertFalse(surface.authorizesLiveTrading)
        XCTAssertFalse(surface.authorizesTradingExecution)
        XCTAssertFalse(surface.requiredValidationDependsOnNetwork)

        XCTAssertTrue(explorer.coversPrivateStreamSimulationGateEvidenceSurface)
        XCTAssertEqual(
            explorer.sectionSnapshots.first {
                $0.section == .privateStreamSimulationGateEvidenceSurface
            }?.itemCount,
            4
        )
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .privateStreamSimulationGateEvidenceSurface
                    && $0.title == "Simulated account snapshot freshness read-model-only evidence"
            }
        )
        XCTAssertTrue(
            explorer.evidenceLinks.contains {
                $0.evidenceID == "MTP-145-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SIMULATION-GATE-SURFACE"
            }
        )

        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Simulation gate", in: reportSection), "4")
        XCTAssertTrue(reportSection.details.contains("Simulation gate boundary: confirmed"))
        XCTAssertTrue(reportSection.details.contains("Simulation gate account connect: none"))
        XCTAssertTrue(reportSection.details.contains("Simulation gate broker connect: none"))
        XCTAssertTrue(reportSection.details.contains("Simulation gate trading button: none"))
        XCTAssertEqual(
            metricValue("Simulation gate", in: shell.readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Boundary", in: shell.readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            shell.readModelSurface.privateStreamSimulationGateEvidenceSurfaceDetails.contains(
                "Simulation gate account snapshot runtime: none"
            )
        )
        XCTAssertTrue(shell.smokeSummary.contains("privateStreamSimulationGateEvidence=4"))

        let encoded = try JSONEncoder().encode(surface)
        let decoded = try JSONDecoder().decode(
            PrivateStreamSimulationGateEvidenceSurfaceViewModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, surface)
    }

    func testLiveMonitoringReadOnlyConsoleV2SurfaceAggregatesMTP152WorkbenchReportEventsEvidence() throws {
        // 测试场景：MTP-152 只把 MTP-148..151 deterministic Core evidence 接入
        // Workbench / Report / Events read-model-only surface；不能暴露 Runtime、Adapter、schema、
        // account payload、broker state、Live PRO Console、trading button、live command 或 order form。
        let viewModel = try makeDashboardViewModel()
        let surface = viewModel.report.liveMonitoringReadOnlyConsoleV2Surface
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let shell = DashboardShellSnapshot(viewModel: viewModel)

        XCTAssertEqual(surface.issueID, "MTP-152")
        XCTAssertEqual(surface.matrixID, "TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2")
        XCTAssertEqual(surface.sourceIdentityRecordCount, 4)
        XCTAssertEqual(surface.healthEvidenceCount, 4)
        XCTAssertEqual(surface.readinessExplanationCount, 4)
        XCTAssertEqual(surface.forbiddenTestCaseCount, 19)
        XCTAssertEqual(surface.eventTraceItemCount, 4)
        XCTAssertEqual(surface.sourceIdentityChecksum, LiveMonitoringSourceIdentityContract.requiredChecksum)
        XCTAssertEqual(surface.simulationGateHealthChecksum, LiveMonitoringSimulationGateHealthContract.requiredChecksum)
        XCTAssertEqual(surface.connectionReadinessChecksum, LiveMonitoringConnectionReadinessExplanationContract.requiredChecksum)
        XCTAssertEqual(surface.forbiddenCapabilityChecksum, LiveMonitoringForbiddenCapabilityTestContract.requiredChecksum)
        XCTAssertTrue(surface.reportSummary.contains("Live Monitoring Read-only Console v2 surface"))
        XCTAssertTrue(surface.readinessStateLabels.contains { $0.contains("blocked") })
        XCTAssertTrue(surface.readinessStateLabels.contains { $0.contains("stale") })
        XCTAssertTrue(surface.readinessStateLabels.contains { $0.contains("missing") })
        XCTAssertEqual(surface.blockedExplanationIDs.count, 1)
        XCTAssertEqual(surface.staleExplanationIDs.count, 1)
        XCTAssertEqual(surface.missingExplanationIDs.count, 1)
        XCTAssertTrue(surface.dashboardPanelSummaries.contains { $0.contains("Forbidden capability tests") })
        XCTAssertTrue(surface.consumesOnlyReadModelViewModel)
        XCTAssertTrue(surface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(surface.exposesLivePROConsole)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesRuntimeObject)
        XCTAssertFalse(surface.exposesDatabaseSchema)
        XCTAssertFalse(surface.exposesAdapterRequest)
        XCTAssertFalse(surface.exposesAccountPayload)
        XCTAssertFalse(surface.exposesBrokerState)
        XCTAssertFalse(surface.callsSignedEndpoint)
        XCTAssertFalse(surface.callsAccountEndpoint)
        XCTAssertFalse(surface.createsListenKey)
        XCTAssertFalse(surface.opensPrivateWebSocket)
        XCTAssertFalse(surface.runsPrivateStreamRuntime)
        XCTAssertFalse(surface.runsAccountSnapshotRuntime)
        XCTAssertFalse(surface.createsConnectionManager)
        XCTAssertFalse(surface.opensRuntimeConnection)
        XCTAssertFalse(surface.implementsLiveReadiness)
        XCTAssertFalse(surface.runsLiveMonitoringRuntime)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.connectsExchangeExecutionAdapter)
        XCTAssertFalse(surface.implementsLiveExecutionAdapter)
        XCTAssertFalse(surface.implementsOMS)
        XCTAssertFalse(surface.readsRealAccount)
        XCTAssertFalse(surface.readsRealPosition)
        XCTAssertFalse(surface.readsRealBalance)
        XCTAssertFalse(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesOrderLevelCommand)
        XCTAssertFalse(surface.authorizesLiveTrading)
        XCTAssertFalse(surface.authorizesTradingExecution)
        XCTAssertFalse(surface.requiredValidationDependsOnNetwork)

        XCTAssertTrue(explorer.coversLiveMonitoringReadOnlyConsoleV2Surface)
        XCTAssertEqual(
            explorer.sectionSnapshots.first {
                $0.section == .liveMonitoringReadOnlyConsoleV2Surface
            }?.itemCount,
            4
        )
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .liveMonitoringReadOnlyConsoleV2Surface
                    && $0.title == "Live Monitoring v2 readiness / stale / blocked / missing evidence"
            }
        )
        XCTAssertTrue(
            explorer.evidenceLinks.contains {
                $0.evidenceID == "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            }
        )

        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Live monitoring v2", in: reportSection), "4")
        XCTAssertTrue(reportSection.details.contains("Live Monitoring v2 command surface: none"))
        XCTAssertTrue(reportSection.details.contains("Live Monitoring v2 runtime object: none"))
        XCTAssertTrue(reportSection.details.contains("Live Monitoring v2 database schema: none"))
        XCTAssertTrue(reportSection.details.contains("Live Monitoring v2 broker state: none"))
        XCTAssertTrue(reportSection.details.contains("Live Monitoring v2 boundary: confirmed"))
        XCTAssertEqual(
            metricValue("Live monitoring v2", in: shell.readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Boundary", in: shell.readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            shell.readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceDetails.contains(
                "Live Monitoring v2 broker connect: none"
            )
        )
        XCTAssertTrue(shell.smokeSummary.contains("liveMonitoringReadOnlyConsoleV2Surface=4"))

        let encoded = try JSONEncoder().encode(surface)
        let decoded = try JSONDecoder().decode(
            LiveMonitoringReadOnlyConsoleV2SurfaceViewModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, surface)
    }

    func testStrategyTraderReadinessSurfaceAggregatesMTP160WorkbenchReportEventsEvidence() throws {
        // 测试场景：MTP-160 只把 MTP-154..159 readiness / forbidden capability 合同证据接入
        // Workbench / Report / Events read-model-only surface；不得创建 Strategy Console、Runtime、
        // Execution Client、broker command、OMS、Live PRO Console、trading button、live command 或 order form。
        let viewModel = try makeDashboardViewModel()
        let surface = viewModel.report.strategyTraderReadinessEvidenceSurface
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let shell = DashboardShellSnapshot(viewModel: viewModel)

        XCTAssertEqual(surface.issueID, "MTP-160")
        XCTAssertEqual(surface.matrixID, "TVM-STRATEGY-TRADER-INSTANCE-READINESS")
        XCTAssertEqual(surface.recordCount, 6)
        XCTAssertEqual(surface.eventTraceItemCount, 6)
        XCTAssertEqual(surface.roleLabels, ["quoter readiness role", "hedger readiness role"])
        XCTAssertEqual(
            surface.readModelInputLabels,
            ["account read-model input", "portfolio read-model input", "risk read-model input"]
        )
        XCTAssertTrue(surface.proposalIsolationLabels.contains("proposal-to-command isolation"))
        XCTAssertTrue(surface.forbiddenCapabilityLabels.contains("Strategy -> Execution Client blocked"))
        XCTAssertTrue(surface.forbiddenCapabilityLabels.contains("Live PRO Console blocked"))
        XCTAssertTrue(surface.forbiddenCapabilityLabels.contains("signed/account endpoint and listenKey blocked"))
        XCTAssertTrue(surface.reportSummary.contains("Strategy / Trader readiness read-model-only surface"))
        XCTAssertTrue(surface.dashboardPanelSummaries.contains { $0.contains("Forbidden capabilities") })
        XCTAssertTrue(surface.consumesOnlyReadModelViewModel)
        XCTAssertTrue(surface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(surface.exposesStrategyConsole)
        XCTAssertFalse(surface.exposesLivePROConsole)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesRuntimeObject)
        XCTAssertFalse(surface.exposesDatabaseSchema)
        XCTAssertFalse(surface.exposesAdapterRequest)
        XCTAssertFalse(surface.exposesAccountPayload)
        XCTAssertFalse(surface.exposesBrokerState)
        XCTAssertFalse(surface.callsSignedEndpoint)
        XCTAssertFalse(surface.callsAccountEndpoint)
        XCTAssertFalse(surface.createsListenKey)
        XCTAssertFalse(surface.runsStrategyRuntime)
        XCTAssertFalse(surface.runsTraderRuntime)
        XCTAssertFalse(surface.runsExecutionRuntime)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.implementsLiveExecutionAdapter)
        XCTAssertFalse(surface.implementsOMS)
        XCTAssertFalse(surface.readsRealAccount)
        XCTAssertFalse(surface.readsRealPosition)
        XCTAssertFalse(surface.readsRealBalance)
        XCTAssertFalse(surface.readsMargin)
        XCTAssertFalse(surface.readsLeverage)
        XCTAssertFalse(surface.readsRealPnL)
        XCTAssertFalse(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesOrderLevelCommand)
        XCTAssertFalse(surface.authorizesLiveTrading)
        XCTAssertFalse(surface.authorizesTradingExecution)
        XCTAssertFalse(surface.requiredValidationDependsOnNetwork)

        XCTAssertTrue(explorer.coversStrategyTraderReadinessEvidenceSurface)
        XCTAssertEqual(
            explorer.sectionSnapshots.first {
                $0.section == .strategyTraderReadinessEvidenceSurface
            }?.itemCount,
            6
        )
        XCTAssertTrue(
            explorer.timelineItems.contains {
                $0.section == .strategyTraderReadinessEvidenceSurface
                    && $0.title == "MTP-158 proposal isolation readiness evidence"
            }
        )
        XCTAssertTrue(
            explorer.evidenceLinks.contains {
                $0.evidenceID == "MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION"
            }
        )

        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertEqual(metricValue("Strategy readiness", in: reportSection), "6")
        XCTAssertTrue(reportSection.details.contains("Strategy readiness command surface: none"))
        XCTAssertTrue(reportSection.details.contains("Strategy readiness runtime object: none"))
        XCTAssertTrue(reportSection.details.contains("Strategy readiness database schema: none"))
        XCTAssertTrue(reportSection.details.contains("Strategy readiness boundary: confirmed"))
        XCTAssertEqual(
            metricValue("Strategy readiness", in: shell.readModelSurface.strategyTraderReadinessEvidenceSurfaceMetrics),
            "6"
        )
        XCTAssertEqual(
            metricValue("Boundary", in: shell.readModelSurface.strategyTraderReadinessEvidenceSurfaceMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            shell.readModelSurface.strategyTraderReadinessEvidenceSurfaceDetails.contains(
                "Strategy readiness broker connect: none"
            )
        )
        XCTAssertTrue(shell.smokeSummary.contains("strategyTraderReadinessSurface=6"))

        let encoded = try JSONEncoder().encode(surface)
        let decoded = try JSONDecoder().decode(
            StrategyTraderReadinessEvidenceSurfaceViewModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, surface)
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
        XCTAssertEqual(decoded.paperWorkflowEvidenceExplorer.timelineItemCount, 95)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversReportArtifacts)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversMarketDataReplayOperations)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversScenarioReplayEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversAccountPositionBalanceReadModelOnlySurface)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversPrivateStreamSimulationGateEvidenceSurface)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveMonitoringReadOnlyConsoleV2Surface)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversStrategyTraderReadinessEvidenceSurface)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveExecutionControlBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveRiskGateBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveIncidentStopBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveReadOnlyDashboardBoundary)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveTradingBlockedEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.coversLiveMonitoringEvidence)
        XCTAssertTrue(decoded.paperWorkflowEvidenceExplorer.readModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.marketDataReplayEvidenceCount, 1)
        XCTAssertTrue(decoded.report.marketDataReplayReadModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.scenarioReplayEvidenceCount, 1)
        XCTAssertTrue(decoded.report.scenarioReplayReadModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.privateStreamSimulationGateEvidenceSurface.freshnessEvidenceCount, 4)
        XCTAssertTrue(decoded.report.privateStreamSimulationGateEvidenceSurface.readModelOnlyBoundaryHeld)
        XCTAssertEqual(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.eventTraceItemCount, 4)
        XCTAssertTrue(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.providesLiveCommand)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.exposesRuntimeObject)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.exposesAdapterRequest)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.exposesDatabaseSchema)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.exposesAccountPayload)
        XCTAssertFalse(decoded.report.liveMonitoringReadOnlyConsoleV2Surface.exposesBrokerState)
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
        XCTAssertEqual(decoded.report.liveReadOnlyDashboardBoundary.boundarySurfaceCount, 5)
        XCTAssertTrue(decoded.report.liveReadOnlyDashboardBoundary.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.providesCommandSurface)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.exposesLivePROConsole)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.providesTradingButton)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.providesLiveCommand)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.exposesOrderForm)
        XCTAssertFalse(decoded.report.liveReadOnlyDashboardBoundary.authorizesTradingExecution)
        XCTAssertEqual(decoded.report.accountPositionBalanceReadModelOnlySurface.recordCount, 3)
        XCTAssertEqual(
            decoded.report.accountPositionBalanceReadModelOnlySurface.evidenceIDs,
            [
                "account-evidence|fixture|mtp-137|1704067500|fresh",
                "position-evidence|fixture|mtp-137|BTCUSDT|long|1704067500|fresh",
                "balance-evidence|fixture|mtp-137|paper-simulated|1704067500|fresh"
            ]
        )
        XCTAssertTrue(decoded.report.accountPositionBalanceReadModelOnlySurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.providesAccountConnect)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.providesBrokerConnect)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.providesTradingButton)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.providesLiveCommand)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.exposesOrderForm)
        XCTAssertFalse(decoded.report.accountPositionBalanceReadModelOnlySurface.authorizesTradingExecution)
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

        XCTAssertEqual(snapshot.title, "MTPRO Research Dashboard")
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
        XCTAssertEqual(metricValue("Dashboard boundary", in: report), "5")
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
        XCTAssertTrue(report.details.contains("Dashboard Live readiness boundary: confirmed"))
        XCTAssertTrue(
            report.details.contains(
                "Dashboard Live readiness surfaces: Workbench Live readiness evidence, Dashboard Live readiness summary, Report Live readiness boundary evidence, Event Timeline audit route, detail inspector boundary evidence"
            )
        )
        XCTAssertTrue(report.details.contains("Dashboard API key input: none"))
        XCTAssertTrue(report.details.contains("Dashboard broker connect: none"))
        XCTAssertTrue(report.details.contains("Dashboard account connect: none"))
        XCTAssertTrue(report.details.contains("Dashboard Live PRO Console: none"))
        XCTAssertTrue(report.details.contains("Dashboard trading buttons: none"))
        XCTAssertTrue(report.details.contains("Dashboard live command: none"))
        XCTAssertTrue(report.details.contains("Dashboard order form: none"))
        XCTAssertTrue(report.details.contains("Dashboard signed endpoint: none"))
        XCTAssertTrue(report.details.contains("Dashboard account endpoint: none"))
        XCTAssertTrue(report.details.contains("Dashboard listenKey: none"))
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
        XCTAssertTrue(snapshot.smokeSummary.contains("dashboardReadModelOnly=true"))
        XCTAssertTrue(snapshot.smokeSummary.contains("controls=start,pause,close,reset"))
        XCTAssertTrue(snapshot.smokeSummary.contains("timelineItems=95"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioReplayEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("accountPositionBalanceEvidence=3"))
        XCTAssertTrue(snapshot.smokeSummary.contains("privateStreamSimulationGateEvidence=4"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveMonitoringReadOnlyConsoleV2Surface=4"))
        XCTAssertTrue(snapshot.smokeSummary.contains("strategyTraderReadinessSurface=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioQualityGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveBlockedGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveExecutionControlGates=7"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveRiskGates=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveIncidentStopGates=5"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveReadOnlyDashboardBoundary=5"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveMonitoringHealth=blocked"))
        XCTAssertTrue(snapshot.smokeSummary.contains("liveMonitoringErrors=3"))
    }

    func testDashboardShellReadModelSurfaceSnapshotBindsControlsObservabilityAndExplorerReadOnly() throws {
        // 测试场景：MTP-52 只在现有 Dashboard / Workbench shell 上增量展示控制壳、
        // observability 和 Evidence Explorer 子集；展示层必须继续保持 read-model-only，
        // 且 session control 只能表达本地 Paper session-level intent。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let readModelSurface = snapshot.readModelSurface

        XCTAssertEqual(readModelSurface.title, "Paper Workflow Control Shell")
        XCTAssertEqual(readModelSurface.sessionControls.map(\.control), [.start, .pause, .close, .reset])
        XCTAssertEqual(readModelSurface.sessionControls.map(\.commandAction), [.start, .pause, .close, .reset])
        XCTAssertTrue(readModelSurface.sessionControls.allSatisfy(\.isSessionLevelLocalPaperControl))
        XCTAssertTrue(readModelSurface.sessionControls.allSatisfy(\.paperOnlyBoundaryHeld))
        XCTAssertEqual(
            readModelSurface.sessionControls.map(\.scope),
            Array(repeating: .localPaperSession, count: 4)
        )
        XCTAssertEqual(
            readModelSurface.sessionControls.map(\.controlLevel),
            Array(repeating: .session, count: 4)
        )
        XCTAssertEqual(
            readModelSurface.sessionControls.map(\.executionMode),
            Array(repeating: .paper, count: 4)
        )
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.authorizesOrderLevelCommand })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.authorizesTradingExecution })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.touchesBrokerAction })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.submitsRealOrder })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.cancelsRealOrder })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.replacesRealOrder })

        XCTAssertEqual(readModelSurface.observabilitySections, PaperWorkflowObservabilitySection.allCases)
        XCTAssertEqual(metricValue("Controls", in: readModelSurface.observabilityMetrics), "4")
        XCTAssertEqual(metricValue("Completed sessions", in: readModelSurface.observabilityMetrics), "1")
        XCTAssertEqual(metricValue("Allowed evidence", in: readModelSurface.observabilityMetrics), "3")
        XCTAssertEqual(metricValue("Blocked evidence", in: readModelSurface.observabilityMetrics), "1")
        XCTAssertEqual(metricValue("Replay", in: readModelSurface.observabilityMetrics), "fresh")
        XCTAssertTrue(readModelSurface.observabilityDetails.contains("Session status: started, updated, closed"))
        XCTAssertTrue(
            readModelSurface.observabilityDetails.contains(
                "Session controls: start, pause, close, reset"
            )
        )

        XCTAssertEqual(metricValue("Timeline items", in: readModelSurface.evidenceExplorerMetrics), "95")
        XCTAssertEqual(metricValue("Sections", in: readModelSurface.evidenceExplorerMetrics), "21")
        XCTAssertTrue(
            readModelSurface.evidenceExplorerDetails.contains(
                "Filter: read-only"
            )
        )
        XCTAssertTrue(readModelSurface.timelinePreview.isEmpty == false)
        XCTAssertTrue(readModelSurface.timelinePreview.allSatisfy { $0.contains(":") })
        XCTAssertEqual(metricValue("APB records", in: readModelSurface.accountPositionBalanceReadModelOnlySurfaceMetrics), "3")
        XCTAssertEqual(metricValue("Fixture", in: readModelSurface.accountPositionBalanceReadModelOnlySurfaceMetrics), "fixture-v1")
        XCTAssertEqual(
            metricValue("Freshness", in: readModelSurface.accountPositionBalanceReadModelOnlySurfaceMetrics),
            "fresh, fresh, fresh"
        )
        XCTAssertEqual(metricValue("Event trace", in: readModelSurface.accountPositionBalanceReadModelOnlySurfaceMetrics), "3")
        XCTAssertEqual(metricValue("Boundary", in: readModelSurface.accountPositionBalanceReadModelOnlySurfaceMetrics), "confirmed")
        XCTAssertTrue(
            readModelSurface.accountPositionBalanceReadModelOnlySurfaceDetails.contains(
                "APB account connect: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.accountPositionBalanceReadModelOnlySurfaceDetails.contains(
                "APB broker connect: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.accountPositionBalanceReadModelOnlySurfaceDetails.contains(
                "APB trading button: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.accountPositionBalanceReadModelOnlySurfaceDetails.contains(
                "APB live command: none"
            )
        )
        XCTAssertEqual(
            metricValue("Simulation gate", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Sources", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "3"
        )
        XCTAssertEqual(
            metricValue("Snapshot inputs", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "1"
        )
        XCTAssertEqual(
            metricValue("Update fixtures", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "3"
        )
        XCTAssertEqual(
            metricValue("Event trace", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Boundary", in: readModelSurface.privateStreamSimulationGateEvidenceSurfaceMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            readModelSurface.privateStreamSimulationGateEvidenceSurfaceDetails.contains(
                "Simulation gate account connect: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.privateStreamSimulationGateEvidenceSurfaceDetails.contains(
                "Simulation gate broker connect: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.privateStreamSimulationGateEvidenceSurfaceDetails.contains(
                "Simulation gate trading button: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.privateStreamSimulationGateEvidenceSurfaceDetails.contains(
                "Simulation gate account snapshot runtime: none"
            )
        )
        XCTAssertEqual(
            metricValue("Live monitoring v2", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Sources", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Health evidence", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Readiness", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "4"
        )
        XCTAssertEqual(
            metricValue("Forbidden tests", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "19"
        )
        XCTAssertEqual(
            metricValue("Boundary", in: readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceDetails.contains(
                "Live Monitoring v2 live command: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceDetails.contains(
                "Live Monitoring v2 account payload: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveMonitoringReadOnlyConsoleV2SurfaceDetails.contains(
                "Live Monitoring v2 broker state: none"
            )
        )
        XCTAssertEqual(
            metricValue("Dashboard boundary", in: readModelSurface.liveReadOnlyDashboardBoundaryMetrics),
            "5"
        )
        XCTAssertEqual(
            metricValue("Forbidden UI", in: readModelSurface.liveReadOnlyDashboardBoundaryMetrics),
            "19"
        )
        XCTAssertEqual(metricValue("Handoff", in: readModelSurface.liveReadOnlyDashboardBoundaryMetrics), "3")
        XCTAssertEqual(
            metricValue("Boundary", in: readModelSurface.liveReadOnlyDashboardBoundaryMetrics),
            "confirmed"
        )
        XCTAssertTrue(
            readModelSurface.liveReadOnlyDashboardBoundaryDetails.contains(
                "Dashboard API key input: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveReadOnlyDashboardBoundaryDetails.contains(
                "Dashboard Live PRO Console: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveReadOnlyDashboardBoundaryDetails.contains(
                "Dashboard trading buttons: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveReadOnlyDashboardBoundaryDetails.contains(
                "Dashboard order form: none"
            )
        )
        XCTAssertTrue(readModelSurface.liveReadOnlyDashboardBoundaryDetails.contains("Dashboard boundary: confirmed"))
        XCTAssertEqual(metricValue("Live gates", in: readModelSurface.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: readModelSurface.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Status", in: readModelSurface.liveBlockedEvidenceMetrics), "blocked")
        XCTAssertTrue(readModelSurface.liveBlockedEvidenceDetails.contains("Live readiness: blocked"))
        XCTAssertTrue(
            readModelSurface.liveBlockedEvidenceDetails.contains(
                "Live command surface: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveBlockedEvidenceDetails.contains(
                "Live trading authorization: none"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveBlockedEvidenceDetails.contains(
                "Live blocked boundary: confirmed"
            )
        )
        XCTAssertEqual(metricValue("Health", in: readModelSurface.liveMonitoringEvidenceMetrics), "blocked")
        XCTAssertEqual(metricValue("Connections", in: readModelSurface.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Streams", in: readModelSurface.liveMonitoringEvidenceMetrics), "4")
        XCTAssertEqual(metricValue("Latency", in: readModelSurface.liveMonitoringEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Errors", in: readModelSurface.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Degraded", in: readModelSurface.liveMonitoringEvidenceMetrics), "2")
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring health: blocked"))
        XCTAssertTrue(
            readModelSurface.liveMonitoringEvidenceDetails.contains(
                "Monitoring connections: disconnected, blocked, unavailable"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveMonitoringEvidenceDetails.contains(
                "Monitoring latency: stale, degraded, nominal, unavailable"
            )
        )
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring command surface: none"))
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring trading buttons: none"))
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring schema exposure: none"))
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring runtime exposure: none"))
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring adapter exposure: none"))
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceDetails.contains("Monitoring boundary: confirmed"))
        XCTAssertEqual(metricValue("Execution gates", in: readModelSurface.liveExecutionControlBlockedEvidenceMetrics), "7")
        XCTAssertEqual(metricValue("Reasons", in: readModelSurface.liveExecutionControlBlockedEvidenceMetrics), "15")
        XCTAssertEqual(metricValue("Blocked", in: readModelSurface.liveExecutionControlBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains(
                "Execution gates: submit, cancel, replace, execution report, broker fill, reconciliation, incident fallback"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains(
                "Execution command surface: none"
            )
        )
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution order form: none"))
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution trading buttons: none"))
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution schema exposure: none"))
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution runtime exposure: none"))
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution adapter exposure: none"))
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceDetails.contains("Execution boundary: confirmed"))
        XCTAssertEqual(metricValue("Risk gates", in: readModelSurface.liveRiskGateBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: readModelSurface.liveRiskGateBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            readModelSurface.liveRiskGateBlockedEvidenceDetails.contains(
                "Risk gates: exposure, order notional, frequency, loss / drawdown, circuit breaker, no-trade state"
            )
        )
        XCTAssertTrue(readModelSurface.liveRiskGateBlockedEvidenceDetails.contains("Risk command surface: none"))
        XCTAssertTrue(readModelSurface.liveRiskGateBlockedEvidenceDetails.contains("Risk trading buttons: none"))
        XCTAssertTrue(readModelSurface.liveRiskGateBlockedEvidenceDetails.contains("Risk boundary: confirmed"))
        XCTAssertEqual(metricValue("Incident stop gates", in: readModelSurface.liveIncidentStopBlockedEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Blocked", in: readModelSurface.liveIncidentStopBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(
            readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains(
                "Incident / stop gates: audit trail, incident replay, emergency stop, shutdown, restore"
            )
        )
        XCTAssertTrue(
            readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains(
                "Incident replay runtime: none"
            )
        )
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Stop control: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Emergency stop: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Shutdown command: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Restore command: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Live PRO Console: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Stop button: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Trading buttons: none"))
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceDetails.contains("Incident / stop boundary: confirmed"))

        XCTAssertTrue(readModelSurface.source.isReadModelOnly)
        XCTAssertTrue(readModelSurface.observabilitySource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.evidenceExplorerSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.liveBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.liveMonitoringEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.liveExecutionControlBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.liveRiskGateBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.liveIncidentStopBlockedEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertTrue(readModelSurface.paperOnlyBoundaryHeld)
        XCTAssertFalse(readModelSurface.providesCommandSurface)
        XCTAssertFalse(readModelSurface.providesOrderLevelCommand)
        XCTAssertFalse(readModelSurface.exposesDatabaseSchema)
        XCTAssertFalse(readModelSurface.exposesRuntimeObject)
        XCTAssertFalse(readModelSurface.exposesAdapterRequest)
        XCTAssertFalse(readModelSurface.authorizesLiveTrading)
        XCTAssertFalse(readModelSurface.touchesBrokerAction)
        XCTAssertFalse(readModelSurface.authorizesTradingExecution)
    }

    func testGH788DashboardReadOnlyRunOperationsSurfaceShowsRegistryJournalAndProbeStatusWithoutCommands() throws {
        // 测试场景：GH-788 Dashboard 只展示 v0.7 local run registry / journal /
        // projection 和 testnet read-only probe status；start / stop / recover 只作为
        // local dry-run session controls 可见，不能升级为订单、live 或 production command。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let surface = snapshot.releaseV070RunOperationsSurface

        XCTAssertEqual(surface.issueID, "GH-788")
        XCTAssertEqual(surface.upstreamIssueIDs, ["GH-783", "GH-785", "GH-786", "GH-787"])
        XCTAssertEqual(surface.releaseVersion, "v0.7.0")
        XCTAssertTrue(surface.source.isReadModelOnly)
        XCTAssertTrue(surface.boundaryHeld)
        XCTAssertEqual(surface.records.map(\.runID), ["gh-785-run-alpha", "gh-785-run-beta"])
        XCTAssertEqual(surface.records.map(\.state), ["running", "recovered"])
        XCTAssertEqual(surface.records.map(\.lifecycle), ["active", "recoveryEvidence"])
        XCTAssertTrue(surface.records.allSatisfy(\.recordHeld))
        XCTAssertTrue(surface.records.allSatisfy(\.replayEvidenceVisible))
        XCTAssertTrue(surface.records.allSatisfy(\.projectionEvidenceVisible))
        XCTAssertEqual(
            surface.records.map(\.eventsJSONLPath),
            [
                ".local/mtpro/runs/gh-785-run-alpha/events.jsonl",
                ".local/mtpro/runs/gh-785-run-beta/events.jsonl"
            ]
        )
        XCTAssertEqual(surface.safeLocalRunControls, [.start, .stop, .recover])
        XCTAssertTrue(surface.safeLocalDryRunControlsVisible)
        XCTAssertTrue(surface.safeLocalDryRunControlsWiredToSessionCommands)
        XCTAssertEqual(surface.sessionCommandSourceIdentity, "ReleaseV070OperationalRunSessionCommand.safe-local")
        XCTAssertEqual(surface.probeStatuses.map(\.issueID), ["GH-786", "GH-787"])
        XCTAssertTrue(surface.probeStatuses.allSatisfy(\.statusHeld))
        XCTAssertTrue(surface.probeStatuses.allSatisfy(\.redactedCredentialReferenceVisible))
        XCTAssertTrue(surface.probeStatuses.contains { $0.redactedListenKeyReferenceVisible })
        XCTAssertTrue(surface.probeStatuses.allSatisfy(\.accountPositionBalanceReadModelVisible))
        XCTAssertTrue(surface.runListVisible)
        XCTAssertTrue(surface.runDetailsVisible)
        XCTAssertTrue(surface.failureEvidenceVisible)
        XCTAssertTrue(surface.replayEvidenceVisible)
        XCTAssertTrue(surface.projectionEvidenceVisible)
        XCTAssertTrue(surface.registryJournalOnly)
        XCTAssertTrue(surface.readModelOnly)
        XCTAssertFalse(surface.tradingButtonVisible)
        XCTAssertFalse(surface.orderFormVisible)
        XCTAssertFalse(surface.liveCommandEnabled)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertFalse(surface.orderSubmitVisible)
        XCTAssertFalse(surface.orderCancelVisible)
        XCTAssertFalse(surface.orderReplaceVisible)
        XCTAssertFalse(surface.brokerEndpointConnected)
        XCTAssertFalse(surface.productionEndpointConnected)
        XCTAssertFalse(surface.productionSecretAutoReadEnabled)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionCutoverAuthorized)
        XCTAssertEqual(metricValue("Run operations", in: surface.metrics), "2")
        XCTAssertEqual(metricValue("Safe local controls", in: surface.metrics), "start,stop,recover")
        XCTAssertEqual(metricValue("Probe statuses", in: surface.metrics), "2")
        XCTAssertEqual(metricValue("Boundary", in: surface.metrics), "confirmed")
        XCTAssertTrue(surface.details.contains("Trading button: none"))
        XCTAssertTrue(surface.details.contains("Order form: none"))
        XCTAssertTrue(surface.details.contains("Live command: none"))
        XCTAssertTrue(surface.details.contains("Production command: none"))
        XCTAssertTrue(surface.details.contains("Submit / cancel / replace: none"))
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV070RunOperations=2"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV070RunOperationControls=start,stop,recover"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV070RunOperationProbes=2"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV070RunOperationBoundary=confirmed"))

        for anchor in ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel.requiredValidationAnchors {
            XCTAssertTrue(surface.validationAnchors.contains(anchor), "\(anchor) must be part of GH-788 surface")
        }
    }

    func testGH815DashboardTestnetReadOnlyMonitorSurfaceShowsFreshnessLifecycleAndRedactionWithoutCommands() throws {
        // 测试场景：GH-815 Dashboard 只展示 GH-813 / GH-814 已落仓 proof artifact 的
        // read-model 摘要，包括 freshness、listenKey lifecycle、last event 和 redaction status；
        // 任何 credential value、raw payload、trading button、order form 或 live command 都必须缺席。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let surface = snapshot.releaseV080TestnetMonitorSurface

        XCTAssertEqual(surface.issueID, "GH-815")
        XCTAssertEqual(surface.upstreamIssueIDs, ["GH-813", "GH-814"])
        XCTAssertEqual(surface.previousIssueID, "GH-814")
        XCTAssertEqual(surface.downstreamIssueID, "GH-816")
        XCTAssertEqual(surface.releaseVersion, "v0.8.0")
        XCTAssertTrue(surface.source.isReadModelOnly)
        XCTAssertTrue(surface.boundaryHeld)
        XCTAssertEqual(surface.visibleStatusCount, 3)
        XCTAssertEqual(Set(surface.statusRows.map(\.issueID)), Set(["GH-813", "GH-814"]))
        XCTAssertTrue(surface.statusRows.allSatisfy(\.statusHeld))
        XCTAssertTrue(surface.statusRows.allSatisfy(\.redactedCredentialReferenceVisible))
        XCTAssertTrue(surface.statusRows.contains { $0.redactedListenKeyReferenceVisible })
        XCTAssertTrue(surface.statusRows.allSatisfy(\.accountSnapshotReadModelVisible))
        XCTAssertTrue(surface.statusRows.allSatisfy(\.balanceReadModelVisible))
        XCTAssertTrue(surface.statusRows.allSatisfy(\.positionReadModelVisible))
        XCTAssertTrue(surface.monitorStates.contains(.stale))
        XCTAssertTrue(surface.monitorStates.contains(.disconnected))
        XCTAssertTrue(surface.monitorStates.contains(.recovered))
        XCTAssertTrue(surface.staleStatesVisible)
        XCTAssertTrue(surface.disconnectedStatesVisible)
        XCTAssertTrue(surface.recoveredStatesVisible)
        XCTAssertTrue(surface.credentialRedactionStatusVisible)
        XCTAssertTrue(surface.listenKeyLifecycleVisible)
        XCTAssertTrue(surface.lastObservedEventVisible)
        XCTAssertTrue(surface.accountBalancePositionReadModelVisible)
        XCTAssertTrue(surface.readModelOnly)
        XCTAssertFalse(surface.dashboardDependsOnDataClientTarget)
        XCTAssertFalse(surface.credentialValueVisible)
        XCTAssertFalse(surface.rawListenKeyVisible)
        XCTAssertFalse(surface.rawPrivatePayloadVisible)
        XCTAssertFalse(surface.tradingButtonVisible)
        XCTAssertFalse(surface.orderFormVisible)
        XCTAssertFalse(surface.liveCommandEnabled)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertFalse(surface.orderSubmitVisible)
        XCTAssertFalse(surface.orderCancelVisible)
        XCTAssertFalse(surface.orderReplaceVisible)
        XCTAssertFalse(surface.testnetOrderRoutingAllowed)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionSecretAutoReadEnabled)
        XCTAssertFalse(surface.productionEndpointConnected)
        XCTAssertFalse(surface.brokerEndpointConnected)
        XCTAssertFalse(surface.productionOrderSubmitted)
        XCTAssertFalse(surface.productionCutoverAuthorized)
        XCTAssertEqual(metricValue("Testnet monitor rows", in: surface.metrics), "3")
        XCTAssertEqual(metricValue("Monitor states", in: surface.metrics), "stale,disconnected,recovered")
        XCTAssertEqual(metricValue("Boundary", in: surface.metrics), "confirmed")
        XCTAssertTrue(surface.details.contains("Credential values: none"))
        XCTAssertTrue(surface.details.contains("Raw listenKey: none"))
        XCTAssertTrue(surface.details.contains("Raw private payload: none"))
        XCTAssertTrue(surface.details.contains("Trading button: none"))
        XCTAssertTrue(surface.details.contains("Order form: none"))
        XCTAssertTrue(surface.details.contains("Live command: none"))
        XCTAssertTrue(surface.details.contains("Submit / cancel / replace: none"))
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080TestnetMonitorRows=3"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080TestnetMonitorStates=stale,disconnected,recovered"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080TestnetMonitorBoundary=confirmed"))

        for anchor in ReleaseV080DashboardTestnetReadOnlyMonitorSurfaceViewModel.requiredValidationAnchors {
            XCTAssertTrue(surface.validationAnchors.contains(anchor), "\(anchor) must be part of GH-815 surface")
        }
    }

    func testGH849DashboardObservabilityTimelineShowsMonitorArtifactsWithoutCommands() throws {
        // 测试场景：GH-849 Dashboard 只展示 GH-845..GH-848 已落仓 monitor/session artifacts
        // 的 timeline 摘要。snapshot、private stream、freshness、stale、disconnected 和 recovered
        // 均为只读 evidence，不得出现交易按钮、订单表单、live command、secret 或 raw payload。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let surface = snapshot.releaseV090ObservabilityTimelineSurface

        XCTAssertEqual(surface.issueID, "GH-849")
        XCTAssertEqual(surface.upstreamIssueIDs, ["GH-845", "GH-846", "GH-847", "GH-848"])
        XCTAssertEqual(surface.previousIssueID, "GH-848")
        XCTAssertEqual(surface.downstreamIssueID, "GH-850")
        XCTAssertEqual(surface.releaseVersion, "v0.9.0")
        XCTAssertTrue(surface.source.isReadModelOnly)
        XCTAssertTrue(surface.boundaryHeld)
        XCTAssertTrue(surface.monitorSessionArtifactsOnly)
        XCTAssertEqual(surface.timelineEvents.count, 6)
        XCTAssertTrue(surface.timelineEvents.allSatisfy(\.eventHeld))
        XCTAssertEqual(surface.snapshotTimeline.count, 1)
        XCTAssertEqual(surface.privateStreamTimeline.count, 3)
        XCTAssertEqual(surface.freshnessTimeline.count, 2)
        XCTAssertTrue(surface.snapshotTimelineVisible)
        XCTAssertTrue(surface.privateStreamTimelineVisible)
        XCTAssertTrue(surface.freshnessTimelineVisible)
        XCTAssertTrue(surface.staleEventsVisible)
        XCTAssertTrue(surface.disconnectedEventsVisible)
        XCTAssertTrue(surface.recoveredEventsVisible)
        XCTAssertTrue(surface.lastObservedEventKindVisible)
        XCTAssertEqual(surface.lastObservedEventKind, "monitorRecovered")
        XCTAssertTrue(surface.timelineEvents.contains { $0.sourceArtifact == "monitor_session.json" })
        XCTAssertTrue(surface.timelineEvents.contains { $0.sourceArtifact == "account-snapshot-freshness.json" })
        XCTAssertTrue(surface.timelineEvents.contains { $0.sourceArtifact == "private-stream-heartbeat.json" })
        XCTAssertTrue(surface.timelineEvents.contains { $0.sourceArtifact == "monitor-recovery.json" })
        XCTAssertTrue(surface.timelineEvents.contains { $0.kind == .stale })
        XCTAssertTrue(surface.timelineEvents.contains { $0.kind == .disconnected })
        XCTAssertTrue(surface.timelineEvents.contains { $0.kind == .recovered })
        XCTAssertTrue(surface.readModelOnly)
        XCTAssertFalse(surface.dashboardDependsOnDataClientTarget)
        XCTAssertFalse(surface.dashboardDependsOnDatabaseRuntime)
        XCTAssertFalse(surface.credentialValueVisible)
        XCTAssertFalse(surface.rawListenKeyVisible)
        XCTAssertFalse(surface.rawPrivatePayloadVisible)
        XCTAssertFalse(surface.tradingButtonVisible)
        XCTAssertFalse(surface.orderFormVisible)
        XCTAssertFalse(surface.liveCommandEnabled)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertFalse(surface.orderSubmitVisible)
        XCTAssertFalse(surface.orderCancelVisible)
        XCTAssertFalse(surface.orderReplaceVisible)
        XCTAssertFalse(surface.testnetOrderRoutingAllowed)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionSecretAutoReadEnabled)
        XCTAssertFalse(surface.productionEndpointConnected)
        XCTAssertFalse(surface.brokerEndpointConnected)
        XCTAssertFalse(surface.productionOrderSubmitted)
        XCTAssertFalse(surface.productionCutoverAuthorized)
        XCTAssertEqual(metricValue("v0.9 timeline events", in: surface.metrics), "6")
        XCTAssertEqual(metricValue("Snapshot timeline", in: surface.metrics), "1")
        XCTAssertEqual(metricValue("Stream timeline", in: surface.metrics), "3")
        XCTAssertEqual(metricValue("Last event", in: surface.metrics), "monitorRecovered")
        XCTAssertEqual(metricValue("Boundary", in: surface.metrics), "confirmed")
        XCTAssertTrue(surface.details.contains("Credential values: none"))
        XCTAssertTrue(surface.details.contains("Raw listenKey: none"))
        XCTAssertTrue(surface.details.contains("Raw private payload: none"))
        XCTAssertTrue(surface.details.contains("Trading button: none"))
        XCTAssertTrue(surface.details.contains("Order form: none"))
        XCTAssertTrue(surface.details.contains("Live command: none"))
        XCTAssertTrue(surface.details.contains("Submit / cancel / replace: none"))
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV090ObservabilityTimelineEvents=6"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV090ObservabilitySnapshotTimeline=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV090ObservabilityStreamTimeline=3"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV090ObservabilityLastEvent=monitorRecovered"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV090ObservabilityBoundary=confirmed"))

        for anchor in ReleaseV090DashboardObservabilityTimelineSurfaceViewModel.requiredValidationAnchors {
            XCTAssertTrue(surface.validationAnchors.contains(anchor), "\(anchor) must be part of GH-849 surface")
        }
    }

    func testGH818DashboardSafeLocalControlsBindSessionStoresWithoutCommands() throws {
        // 测试场景：GH-818 Dashboard 可展示 start / stop / recover / archive / open-detail
        // safe local controls，并将它们绑定到 v0.8 local registry 和 session store artifact；
        // 控制结果只能写本地 `.local/mtpro/runs/...` 证据，不能创建订单或生产命令。
        let snapshot = DashboardShellSnapshot(viewModel: try makeDashboardViewModel())
        let surface = snapshot.releaseV080SafeLocalControlsSurface

        XCTAssertEqual(surface.issueID, "GH-818")
        XCTAssertEqual(surface.upstreamIssueIDs, ["GH-810", "GH-811", "GH-815"])
        XCTAssertEqual(surface.previousIssueID, "GH-817")
        XCTAssertEqual(surface.downstreamIssueID, "GH-819")
        XCTAssertEqual(surface.releaseVersion, "v0.8.0")
        XCTAssertTrue(surface.source.isReadModelOnly)
        XCTAssertTrue(surface.boundaryHeld)
        XCTAssertEqual(surface.visibleControlCount, 5)
        XCTAssertEqual(surface.controls, [.start, .stop, .recover, .archive, .openDetail])
        XCTAssertTrue(surface.registryAndSessionStoresBound)
        XCTAssertTrue(surface.localRunArtifactsOnly)
        XCTAssertTrue(surface.startLocalDryRunVisible)
        XCTAssertTrue(surface.stopLocalDryRunVisible)
        XCTAssertTrue(surface.recoverFailedLocalRunVisible)
        XCTAssertTrue(surface.archiveRunVisible)
        XCTAssertTrue(surface.openDetailVisible)
        XCTAssertTrue(surface.persistentRegistryPathVisible)
        XCTAssertTrue(surface.persistentSessionStorePathsVisible)
        XCTAssertTrue(surface.detailSurfaceReadOnly)
        XCTAssertTrue(surface.readModelOnly)
        XCTAssertFalse(surface.dashboardDependsOnDataClientTarget)

        XCTAssertTrue(surface.controlResults.allSatisfy(\.resultHeld))
        XCTAssertTrue(surface.controlResults.allSatisfy(\.localArtifactMutationOnly))
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.registryJSONPath == ".local/mtpro/runs/registry.json" })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.registryLockPath == ".local/mtpro/runs/registry.lock" })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.runDirectoryPath.hasPrefix(".local/mtpro/runs/") })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.sessionJSONPath.hasSuffix("/session.json") })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.sessionEventsJSONLPath.hasSuffix("/session_events.jsonl") })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.sessionStatusJSONPath.hasSuffix("/session_status.json") })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.operatorSessionStoreJSONPath.hasSuffix("/operator-session-store.json") })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.dashboardDetailSnapshotJSONPath.hasSuffix("/dashboard-readonly-snapshot.json") })

        let start = try XCTUnwrap(surface.controlResults.first { $0.control == .start })
        XCTAssertEqual(start.registryOperation, "ReleaseV080RunRegistryStore.save")
        XCTAssertEqual(start.sessionOperation, "ReleaseV080OperationalRunSessionStore.create+apply(start,start)")
        XCTAssertEqual(start.registryStateAfter, "running")
        XCTAssertEqual(start.sessionStateAfter, "running")
        XCTAssertTrue(start.registryWriteRequired)
        XCTAssertTrue(start.sessionWriteRequired)

        let stop = try XCTUnwrap(surface.controlResults.first { $0.control == .stop })
        XCTAssertEqual(stop.registryOperation, "ReleaseV080RunRegistryStore.replacing(stopped)")
        XCTAssertEqual(stop.sessionOperation, "ReleaseV080OperationalRunSessionStore.apply(stop,stop)")
        XCTAssertEqual(stop.registryStateAfter, "stopped")
        XCTAssertEqual(stop.sessionStateAfter, "stopped")

        let recover = try XCTUnwrap(surface.controlResults.first { $0.control == .recover })
        XCTAssertEqual(recover.registryOperation, "ReleaseV080RunRegistryStore.recover")
        XCTAssertEqual(recover.sessionOperation, "ReleaseV080OperationalRunSessionStore.apply(recover)")
        XCTAssertEqual(recover.registryStateAfter, "recovered")
        XCTAssertEqual(recover.sessionStateAfter, "recovered")

        let archive = try XCTUnwrap(surface.controlResults.first { $0.control == .archive })
        XCTAssertEqual(archive.registryOperation, "ReleaseV080RunRegistryStore.archive")
        XCTAssertEqual(archive.sessionOperation, "ReleaseV080OperationalRunSessionStore.load+status")
        XCTAssertEqual(archive.registryStateAfter, "archived")
        XCTAssertFalse(archive.sessionWriteRequired)
        XCTAssertTrue(archive.sessionReadRequired)

        let openDetail = try XCTUnwrap(surface.controlResults.first { $0.control == .openDetail })
        XCTAssertEqual(openDetail.registryOperation, "ReleaseV080RunRegistryStore.inspect")
        XCTAssertEqual(openDetail.sessionOperation, "ReleaseV080OperationalRunSessionStore.load+status")
        XCTAssertTrue(openDetail.detailOpenReadOnly)
        XCTAssertFalse(openDetail.registryWriteRequired)
        XCTAssertFalse(openDetail.sessionWriteRequired)
        XCTAssertTrue(openDetail.sessionReadRequired)

        XCTAssertTrue(surface.controlResults.allSatisfy { $0.orderCommandCreated == false })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.productionCommandCreated == false })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.testnetOrderCommandCreated == false })
        XCTAssertTrue(surface.controlResults.allSatisfy { $0.brokerCommandCreated == false })
        XCTAssertFalse(surface.credentialValueVisible)
        XCTAssertFalse(surface.rawListenKeyVisible)
        XCTAssertFalse(surface.rawPrivatePayloadVisible)
        XCTAssertFalse(surface.tradingButtonVisible)
        XCTAssertFalse(surface.orderFormVisible)
        XCTAssertFalse(surface.liveCommandEnabled)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertFalse(surface.orderSubmitVisible)
        XCTAssertFalse(surface.orderCancelVisible)
        XCTAssertFalse(surface.orderReplaceVisible)
        XCTAssertFalse(surface.testnetOrderRoutingAllowed)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionSecretAutoReadEnabled)
        XCTAssertFalse(surface.productionEndpointConnected)
        XCTAssertFalse(surface.brokerEndpointConnected)
        XCTAssertFalse(surface.productionOrderSubmitted)
        XCTAssertFalse(surface.productionCutoverAuthorized)
        XCTAssertEqual(metricValue("Safe local control rows", in: surface.metrics), "5")
        XCTAssertEqual(metricValue("Safe local controls", in: surface.metrics), "start,stop,recover,archive,open-detail")
        XCTAssertEqual(metricValue("Store bindings", in: surface.metrics), "registry+session")
        XCTAssertEqual(metricValue("Artifact scope", in: surface.metrics), "local-only")
        XCTAssertEqual(metricValue("Boundary", in: surface.metrics), "confirmed")
        XCTAssertTrue(surface.details.contains("Local artifact mutation: only"))
        XCTAssertTrue(surface.details.contains("Open detail: read-only"))
        XCTAssertTrue(surface.details.contains("Trading button: none"))
        XCTAssertTrue(surface.details.contains("Order form: none"))
        XCTAssertTrue(surface.details.contains("Live command: none"))
        XCTAssertTrue(surface.details.contains("Production command: none"))
        XCTAssertTrue(surface.details.contains("Submit / cancel / replace: none"))
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.viewModelSources.allSatisfy(\.isReadModelOnly))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080SafeLocalControls=5"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080SafeLocalControlNames=start,stop,recover,archive,open-detail"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080SafeLocalControlBindings=registry+session"))
        XCTAssertTrue(snapshot.smokeSummary.contains("releaseV080SafeLocalControlBoundary=confirmed"))

        for anchor in ReleaseV080DashboardSafeLocalControlsSurfaceViewModel.requiredValidationAnchors {
            XCTAssertTrue(surface.validationAnchors.contains(anchor), "\(anchor) must be part of GH-818 surface")
        }
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
        let readModelSurface = snapshot.readModelSurface

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
        XCTAssertTrue(readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertTrue(readModelSurface.paperOnlyBoundaryHeld)
        XCTAssertFalse(readModelSurface.providesCommandSurface)
        XCTAssertFalse(readModelSurface.providesOrderLevelCommand)
        XCTAssertFalse(readModelSurface.exposesDatabaseSchema)
        XCTAssertFalse(readModelSurface.exposesRuntimeObject)
        XCTAssertFalse(readModelSurface.exposesAdapterRequest)
        XCTAssertFalse(readModelSurface.authorizesLiveTrading)
        XCTAssertFalse(readModelSurface.touchesBrokerAction)
        XCTAssertFalse(readModelSurface.authorizesTradingExecution)
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.authorizesOrderLevelCommand })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.submitsRealOrder })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.cancelsRealOrder })
        XCTAssertFalse(readModelSurface.sessionControls.contains { $0.replacesRealOrder })
        XCTAssertTrue(snapshot.smokeSummary.contains("readModelOnly=true"))
        XCTAssertTrue(snapshot.smokeSummary.contains("dashboardReadModelOnly=true"))
    }

    func testDashboardShellInitialSnapshotIsEmptyReadModelProjection() {
        // 测试场景：可运行 macOS shell 的默认快照只能表示空事实投影和静态 Live blocked gates，
        // 不能伪造行情、Paper、Risk、Portfolio 或真实交易事件事实。
        let snapshot = DashboardShellSnapshot(viewModel: .emptyResearchDashboard)

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
        XCTAssertEqual(report?.metrics.first { $0.label == "Strategy readiness" }?.value, "6")
        XCTAssertEqual(report?.metrics.first { $0.label == "Live gates" }?.value, "6")
        XCTAssertEqual(report?.metrics.first { $0.label == "Monitoring" }?.value, "4")
        XCTAssertEqual(report?.metrics.first { $0.label == "Execution control" }?.value, "7")
        XCTAssertEqual(report?.metrics.first { $0.label == "Live risk" }?.value, "6")
        XCTAssertEqual(report?.metrics.first { $0.label == "Incident stop" }?.value, "5")
        XCTAssertEqual(report?.metrics.first { $0.label == "Dashboard boundary" }?.value, "5")

        let events = snapshot.sections.first { $0.section == .events }
        XCTAssertEqual(events?.metrics.first { $0.label == "Events" }?.value, "0")
        XCTAssertEqual(events?.metrics.first { $0.label == "Last sequence" }?.value, "n/a")

        XCTAssertEqual(metricValue("Controls", in: snapshot.readModelSurface.observabilityMetrics), "4")
        XCTAssertEqual(metricValue("Timeline items", in: snapshot.readModelSurface.evidenceExplorerMetrics), "60")
        XCTAssertEqual(metricValue("Scenarios", in: snapshot.readModelSurface.scenarioReplayEvidenceMetrics), "0")
        XCTAssertEqual(metricValue("Quality gates", in: snapshot.readModelSurface.scenarioReplayEvidenceMetrics), "0")
        XCTAssertEqual(
            metricValue("Strategy readiness", in: snapshot.readModelSurface.strategyTraderReadinessEvidenceSurfaceMetrics),
            "6"
        )
        XCTAssertEqual(
            metricValue("Dashboard boundary", in: snapshot.readModelSurface.liveReadOnlyDashboardBoundaryMetrics),
            "5"
        )
        XCTAssertEqual(
            metricValue("Forbidden UI", in: snapshot.readModelSurface.liveReadOnlyDashboardBoundaryMetrics),
            "19"
        )
        XCTAssertEqual(metricValue("Live gates", in: snapshot.readModelSurface.liveBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Health", in: snapshot.readModelSurface.liveMonitoringEvidenceMetrics), "blocked")
        XCTAssertEqual(metricValue("Errors", in: snapshot.readModelSurface.liveMonitoringEvidenceMetrics), "3")
        XCTAssertEqual(metricValue("Execution gates", in: snapshot.readModelSurface.liveExecutionControlBlockedEvidenceMetrics), "7")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.readModelSurface.liveExecutionControlBlockedEvidenceMetrics), "confirmed")
        XCTAssertEqual(metricValue("Risk gates", in: snapshot.readModelSurface.liveRiskGateBlockedEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.readModelSurface.liveRiskGateBlockedEvidenceMetrics), "confirmed")
        XCTAssertEqual(metricValue("Incident stop gates", in: snapshot.readModelSurface.liveIncidentStopBlockedEvidenceMetrics), "5")
        XCTAssertEqual(metricValue("Blocked", in: snapshot.readModelSurface.liveIncidentStopBlockedEvidenceMetrics), "confirmed")
        XCTAssertTrue(snapshot.readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(snapshot.readModelSurface.providesOrderLevelCommand)
    }

    func testMTP121DashboardFirstRunDefaultDemoStateFeedsDashboardSmokeReadOnly() throws {
        // 测试场景：MTP-121 Dashboard 启动默认状态必须选择 MTP-120 的 deterministic beta demo
        // fixture，并把 first-run evidence 作为 App ViewModel / Dashboard smoke 只读证据输出。
        let viewModel = DashboardViewModel.defaultDashboardBetaDemo
        let firstRun = viewModel.dashboardBetaFirstRun
        let summary = try XCTUnwrap(firstRun.evidenceSummary)
        let snapshot = DashboardShellSnapshot(viewModel: viewModel)
        let readModelSurface = snapshot.readModelSurface

        XCTAssertEqual(firstRun.state, .defaultDemo)
        XCTAssertEqual(firstRun.selectedScenarioID, "mtp-104-btcusdt-1m-first-scenario")
        XCTAssertEqual(firstRun.defaultSelectedScenarioID, "mtp-104-btcusdt-1m-first-scenario")
        XCTAssertTrue(firstRun.isDefaultSelectedScenario)
        XCTAssertEqual(firstRun.fallbackStateLabels, ["empty", "loading", "error"])
        XCTAssertEqual(summary.evidenceID, "mtp-120-workbench-beta-demo-fixture-evidence")
        XCTAssertEqual(summary.scenarioID, "mtp-104-btcusdt-1m-first-scenario")
        XCTAssertEqual(summary.datasetVersion, "dataset-v1")
        XCTAssertEqual(summary.fixtureVersion, "fixture-v1")
        XCTAssertEqual(summary.symbol, "BTCUSDT")
        XCTAssertEqual(summary.timeframe, "1m")
        XCTAssertEqual(summary.checksum, "fnv1a64:3c6cd4ff13cd4062")
        XCTAssertEqual(summary.freshnessStatus, .fresh)
        XCTAssertEqual(summary.qualityVerdict, .accepted)
        XCTAssertEqual(
            summary.reportInputVersionIdentity,
            "mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted"
        )
        XCTAssertTrue(summary.simulatedParityEvidenceIdentity.contains("paper-order-intent-allowed"))
        XCTAssertEqual(summary.validationAnchors, DashboardBetaFirstRunEvidenceSummary.validationAnchors)
        XCTAssertTrue(summary.scenarioReplayWiringHeld)
        XCTAssertTrue(summary.simulatedParityWiringHeld)
        XCTAssertTrue(summary.localDeterministicFixtureOnly)
        XCTAssertTrue(summary.readModelOnlyHandoff)

        XCTAssertEqual(viewModel.report.scenarioReplayEvidenceCount, 1)
        XCTAssertEqual(viewModel.report.simulatedExchangeParityEvidenceCount, 1)
        XCTAssertEqual(metricValue("First run", in: readModelSurface.dashboardBetaFirstRunMetrics), "default demo")
        XCTAssertEqual(
            metricValue("Demo scenario", in: readModelSurface.dashboardBetaFirstRunMetrics),
            "mtp-104-btcusdt-1m-first-scenario"
        )
        XCTAssertEqual(metricValue("Fallbacks", in: readModelSurface.dashboardBetaFirstRunMetrics), "3")
        XCTAssertTrue(readModelSurface.dashboardBetaFirstRunReadModelOnlyBoundaryHeld)
        XCTAssertTrue(readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioReplayEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("simulatedParityEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("defaultDemoState=default demo"))
        XCTAssertTrue(snapshot.smokeSummary.contains("defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario"))
        XCTAssertTrue(snapshot.smokeSummary.contains("betaFirstRunFallbacks=3"))

        XCTAssertFalse(firstRun.requiredValidationDependsOnNetwork)
        XCTAssertFalse(firstRun.exposesDatabaseSchema)
        XCTAssertFalse(firstRun.exposesRuntimeObject)
        XCTAssertFalse(firstRun.exposesAdapterRequest)
        XCTAssertFalse(firstRun.providesCommandSurface)
        XCTAssertFalse(firstRun.providesOrderLevelCommand)
        XCTAssertFalse(firstRun.providesLiveCommand)
        XCTAssertFalse(firstRun.providesTradingButton)
        XCTAssertFalse(firstRun.authorizesLiveTrading)
        XCTAssertFalse(firstRun.touchesBrokerAction)
        XCTAssertFalse(firstRun.authorizesTradingExecution)
    }

    func testMTP121DashboardFirstRunFallbackStatesRemainReadModelOnly() {
        // 测试场景：MTP-121 的 empty / loading / error fallback 只解释 first-run 展示状态，
        // 不携带下载、重试、Runtime mutation、broker action、live command 或交易按钮。
        for state in [DashboardBetaFirstRunStateKind.empty, .loading, .error] {
            let viewModel = DashboardBetaFirstRunViewModel(
                readModel: DashboardBetaFirstRunReadModel.fallback(state)
            )

            XCTAssertEqual(viewModel.state, state)
            XCTAssertNil(viewModel.selectedScenarioID)
            XCTAssertNil(viewModel.evidenceSummary)
            XCTAssertEqual(viewModel.fallbackStateLabels, ["empty", "loading", "error"])
            XCTAssertTrue(viewModel.fallbackStates.allSatisfy(\.boundaryHeld))
            XCTAssertTrue(viewModel.readModelOnlyBoundaryHeld)
            XCTAssertFalse(viewModel.requiredValidationDependsOnNetwork)
            XCTAssertFalse(viewModel.exposesDatabaseSchema)
            XCTAssertFalse(viewModel.exposesRuntimeObject)
            XCTAssertFalse(viewModel.exposesAdapterRequest)
            XCTAssertFalse(viewModel.providesCommandSurface)
            XCTAssertFalse(viewModel.providesOrderLevelCommand)
            XCTAssertFalse(viewModel.providesLiveCommand)
            XCTAssertFalse(viewModel.providesTradingButton)
            XCTAssertFalse(viewModel.authorizesLiveTrading)
            XCTAssertFalse(viewModel.touchesBrokerAction)
            XCTAssertFalse(viewModel.authorizesTradingExecution)
        }
    }

    func testMTP122DashboardBetaAcceptancePathFeedsReportDashboardAndEventsReadOnly() throws {
        // 测试场景：MTP-122 只把 MTP-120 / MTP-121 的同一 deterministic demo fixture
        // 串成 Report summary、Dashboard panels 和 Events trace；不得新增 Runtime command、
        // broker action、signed endpoint、schema exposure、live command 或交易按钮。
        let viewModel = DashboardViewModel.defaultDashboardBetaDemo
        let acceptance = viewModel.dashboardBetaAcceptancePath
        let snapshot = DashboardShellSnapshot(viewModel: viewModel)
        let readModelSurface = snapshot.readModelSurface
        let acceptanceItems = viewModel.paperWorkflowEvidenceExplorer.timelineItems.filter {
            $0.section == .dashboardBetaAcceptancePath
        }
        let sectionCounts = Dictionary(
            uniqueKeysWithValues: viewModel.paperWorkflowEvidenceExplorer.sectionSnapshots.map {
                ($0.section, $0.itemCount)
            }
        )

        XCTAssertEqual(acceptance.acceptancePathCount, 1)
        XCTAssertEqual(acceptance.scenarioIDs, ["mtp-104-btcusdt-1m-first-scenario"])
        XCTAssertEqual(acceptance.datasetVersions, ["dataset-v1"])
        XCTAssertEqual(acceptance.fixtureVersions, ["fixture-v1"])
        XCTAssertEqual(
            acceptance.reportInputVersionIdentities,
            [
                "mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted"
            ]
        )
        XCTAssertTrue(
            acceptance.reportSummaries.first?.contains(
                "Report acceptance scenario=mtp-104-btcusdt-1m-first-scenario"
            ) == true
        )
        XCTAssertEqual(acceptance.dashboardPanelSummaries.count, 4)
        XCTAssertEqual(acceptance.eventTraceItemCount, 5)
        XCTAssertEqual(
            acceptance.portfolioEvidenceIDs,
            ["mtp-115-simulated-exchange-portfolio-projection-parity-portfolio-parity"]
        )
        XCTAssertEqual(acceptance.grossExposureNotional, 10_530.175, accuracy: 0.00000001)
        XCTAssertEqual(acceptance.netSimulatedPnL, -6.84461375, accuracy: 0.00000001)
        XCTAssertEqual(acceptance.validationAnchors, DashboardBetaAcceptancePathReadModel.validationAnchors)
        XCTAssertTrue(acceptance.sameDemoScenarioHeld)
        XCTAssertTrue(acceptance.reportSurfaceReady)
        XCTAssertTrue(acceptance.dashboardPanelsReady)
        XCTAssertTrue(acceptance.eventsTraceReady)
        XCTAssertTrue(acceptance.scenarioReplayEvidenceHeld)
        XCTAssertTrue(acceptance.simulatedParityEvidenceHeld)
        XCTAssertTrue(acceptance.portfolioEvidenceHeld)
        XCTAssertTrue(acceptance.readModelOnlyBoundaryHeld)
        XCTAssertFalse(acceptance.requiredValidationDependsOnNetwork)
        XCTAssertFalse(acceptance.exposesDatabaseSchema)
        XCTAssertFalse(acceptance.exposesRuntimeObject)
        XCTAssertFalse(acceptance.exposesAdapterRequest)
        XCTAssertFalse(acceptance.usesSignedEndpoint)
        XCTAssertFalse(acceptance.callsAccountEndpoint)
        XCTAssertFalse(acceptance.createsListenKey)
        XCTAssertFalse(acceptance.connectsBroker)
        XCTAssertFalse(acceptance.implementsLiveExecutionAdapter)
        XCTAssertFalse(acceptance.implementsOMS)
        XCTAssertFalse(acceptance.implementsRealOrderLifecycle)
        XCTAssertFalse(acceptance.providesCommandSurface)
        XCTAssertFalse(acceptance.providesOrderLevelCommand)
        XCTAssertFalse(acceptance.providesLiveCommand)
        XCTAssertFalse(acceptance.providesTradingButton)
        XCTAssertFalse(acceptance.authorizesLiveTrading)
        XCTAssertFalse(acceptance.touchesBrokerAction)
        XCTAssertFalse(acceptance.authorizesTradingExecution)

        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.coversDashboardBetaAcceptancePath)
        XCTAssertEqual(acceptanceItems.count, 5)
        XCTAssertEqual(sectionCounts[.dashboardBetaAcceptancePath], 5)
        XCTAssertTrue(
            acceptanceItems.contains {
                $0.title == "Report beta acceptance summary"
                    && $0.summary.contains("mtp-104-btcusdt-1m-first-scenario")
            }
        )
        XCTAssertTrue(
            acceptanceItems.contains {
                $0.title == "Portfolio acceptance evidence"
                    && $0.summary.contains("grossExposure=10530.175")
            }
        )
        XCTAssertTrue(
            acceptanceItems.flatMap(\.evidenceLinks).contains {
                $0.evidenceID == acceptance.reportInputVersionIdentities.first
            }
        )
        XCTAssertTrue(viewModel.paperWorkflowEvidenceExplorer.readModelOnlyBoundaryHeld)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesCommandSurface)
        XCTAssertFalse(viewModel.paperWorkflowEvidenceExplorer.providesOrderLevelCommand)

        XCTAssertEqual(metricValue("Acceptance paths", in: readModelSurface.dashboardBetaAcceptancePathMetrics), "1")
        XCTAssertEqual(
            metricValue("Acceptance scenario", in: readModelSurface.dashboardBetaAcceptancePathMetrics),
            "mtp-104-btcusdt-1m-first-scenario"
        )
        XCTAssertEqual(metricValue("Event trace", in: readModelSurface.dashboardBetaAcceptancePathMetrics), "5")
        XCTAssertEqual(metricValue("Portfolio", in: readModelSurface.dashboardBetaAcceptancePathMetrics), "confirmed")
        XCTAssertTrue(readModelSurface.dashboardBetaAcceptancePathReadModelOnlyBoundaryHeld)
        XCTAssertTrue(readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertTrue(snapshot.isReadModelOnly)
        XCTAssertTrue(snapshot.smokeSummary.contains("betaAcceptancePaths=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario"))
        XCTAssertTrue(snapshot.smokeSummary.contains("betaAcceptanceTrace=5"))
    }

    func testDashboardShellSourceDoesNotImportForbiddenIntegrationLayers() throws {
        // 测试场景：SwiftUI shell 文件只能消费 App 层 ViewModel，不能导入 Runtime / Adapters，
        // 也不能直接引用数据库实现名或 public market data client 类型。
        let shellSource = try String(contentsOf: sourceFile("Sources/Dashboard/DashboardShell.swift"))
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

    func testMTP189WorkbenchDashboardSourceMigrationBoundaryIsPhysicalAndReadModelOnly() throws {
        // 测试场景：MTP-189 只做 Workbench / Dashboard physical source migration。
        // Dashboard 目录直接承载 read model、Report、Events、future Live PRO Console label
        // 和 shell snapshot；它不能暴露 runtime、adapter、schema 或 live command surface。
        let migratedSourcePaths = [
            "Sources/Dashboard/ReadModels/App.swift",
            "Sources/Dashboard/Report/AccountPositionBalanceReadModelOnlySurface.swift",
            "Sources/Dashboard/Report/LiveMonitoringReadOnlyConsoleV2Surface.swift",
            "Sources/Dashboard/Report/StrategyTraderReadinessEvidenceSurface.swift",
            "Sources/Dashboard/DashboardBetaFirstRunState.swift",
            "Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift",
            "Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyDashboardBoundary.swift",
            "Sources/Dashboard/DashboardShell.swift",
            "Sources/Dashboard/DashboardApplication.swift"
        ]

        for path in migratedSourcePaths {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: sourceFile(path).path),
                "\(path) should exist after MTP-189 migration"
            )
        }

        let legacyAppDirectory = sourceFile("Sources/App")
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: legacyAppDirectory.path),
            "Sources/App must not remain the Workbench source owner after MTP-189"
        )

        let packageSource = try String(contentsOf: sourceFile("Package.swift"))
        XCTAssertFalse(packageSource.contains("path: \"Sources/Workbench\""))
        XCTAssertFalse(packageSource.contains(".library(name: \"Workbench\""))
        XCTAssertTrue(packageSource.contains("path: \"Sources/Dashboard\""))
        XCTAssertTrue(packageSource.contains("\"ReadModels\""))
        XCTAssertTrue(packageSource.contains("\"Report\""))
        XCTAssertTrue(packageSource.contains("\"Events\""))
        XCTAssertTrue(packageSource.contains("\"FutureLiveProConsole\""))
        XCTAssertTrue(packageSource.contains("\"DashboardApplication.swift\""))
        XCTAssertTrue(packageSource.contains("\"DashboardShell.swift\""))

        let workbenchReportSource = try String(
            contentsOf: sourceFile("Sources/Dashboard/Report/LiveMonitoringReadOnlyConsoleV2Surface.swift")
        )
        let dashboardShellSource = try String(contentsOf: sourceFile("Sources/Dashboard/DashboardShell.swift"))

        for forbidden in [
            "import Runtime",
            "import Adapters",
            "Button(",
            "TextField(",
            "Toggle("
        ] {
            XCTAssertFalse(workbenchReportSource.contains(forbidden))
            XCTAssertFalse(dashboardShellSource.contains(forbidden))
        }
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
        let readModelSurface = snapshot.readModelSurface

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
        XCTAssertEqual(metricValue("Scenarios", in: readModelSurface.scenarioReplayEvidenceMetrics), "1")
        XCTAssertEqual(metricValue("Quality gates", in: readModelSurface.scenarioReplayEvidenceMetrics), "6")
        XCTAssertEqual(metricValue("Report inputs", in: readModelSurface.scenarioReplayEvidenceMetrics), "1")
        XCTAssertEqual(metricValue("Quality", in: readModelSurface.scenarioReplayEvidenceMetrics), "accepted")
        XCTAssertTrue(readModelSurface.scenarioReplayEvidenceSource.isReadModelOnly)
        XCTAssertTrue(readModelSurface.scenarioReplayEvidenceDetails.contains("Quality verdicts: accepted"))
        XCTAssertTrue(readModelSurface.scenarioReplayEvidenceDetails.contains("Command surface: none"))
        XCTAssertTrue(readModelSurface.scenarioReplayEvidenceDetails.contains("Query language: none"))
        XCTAssertTrue(readModelSurface.readModelOnlyBoundaryHeld)
        XCTAssertFalse(readModelSurface.providesCommandSurface)
        XCTAssertFalse(readModelSurface.authorizesTradingExecution)
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioReplayEvidence=1"))
        XCTAssertTrue(snapshot.smokeSummary.contains("scenarioQualityGates=6"))
    }

    private func makeDashboardViewModel() throws -> DashboardViewModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let marketDataReplayOperations = try makeMarketDataReplayOperationsReadModel()
        let scenarioReplayEvidence = makeScenarioReplayEvidenceReadModel()
        let simulatedExchangeParityEvidence = makeSimulatedExchangeParityEvidenceReadModel()
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence,
            simulatedExchangeParityEvidence: simulatedExchangeParityEvidence
        )

        return DashboardViewModel(readModel: readModel)
    }

    private func makeEvidenceExplorerReadModel() throws -> PaperWorkflowEvidenceExplorerReadModel {
        let runtimeProjection = try makeRuntimeProjection()
        let analyticalProjection = try makeAnalyticalProjection()
        let eventTimeline = try makeEventTimeline()
        let marketDataReplayOperations = try makeMarketDataReplayOperationsReadModel()
        let scenarioReplayEvidence = makeScenarioReplayEvidenceReadModel()
        let simulatedExchangeParityEvidence = makeSimulatedExchangeParityEvidenceReadModel()
        let readModel = DashboardReadModel(
            runtimeProjection: runtimeProjection,
            analyticalProjection: analyticalProjection,
            eventTimeline: eventTimeline,
            marketDataReplayOperations: marketDataReplayOperations,
            scenarioReplayEvidence: scenarioReplayEvidence,
            simulatedExchangeParityEvidence: simulatedExchangeParityEvidence
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

    private func makeSimulatedExchangeParityEvidenceReadModel() -> SimulatedExchangeParityEvidenceReadModel {
        // 测试场景：MTP-116 只把 Core deterministic parity value objects 复制成 App 层 read model。
        // App / Dashboard 不运行撮合、执行或 portfolio runtime，不暴露 schema，也不新增交易入口。
        SimulatedExchangeParityEvidenceReadModel.deterministicFixture
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
