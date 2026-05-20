import Foundation
import Core
#if canImport(SwiftUI) && os(macOS)
import SwiftUI
#endif

/// DashboardShellMetric 是 macOS 看板壳用于渲染单个只读指标的稳定展示快照。
///
/// 输入必须来自 `DashboardViewModel` 派生的 shell snapshot；输出只包含 label / value 文本，
/// 不携带数据库行、运行时对象或任何可触发交易动作的命令。
public struct DashboardShellMetric: Codable, Equatable, Identifiable, Sendable {
    public let label: String
    public let value: String

    public var id: String {
        label
    }

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

/// DashboardShellSectionSnapshot 是 SwiftUI section panel 的只读输入模型。
///
/// 每个 section 只绑定现有 ViewModel snapshot，`source` 保留 read-model-only 证据；
/// detail rows 只用于观察，不暴露表名、SQL、adapter 请求、账户信息或 broker side effect。
public struct DashboardShellSectionSnapshot: Codable, Equatable, Identifiable, Sendable {
    public let section: DashboardSection
    public let title: String
    public let systemImage: String
    public let source: ViewModelSourceContract
    public let metrics: [DashboardShellMetric]
    public let details: [String]

    public var id: DashboardSection {
        section
    }

    public init(
        section: DashboardSection,
        title: String,
        systemImage: String,
        source: ViewModelSourceContract,
        metrics: [DashboardShellMetric],
        details: [String]
    ) {
        self.section = section
        self.title = title
        self.systemImage = systemImage
        self.source = source
        self.metrics = metrics
        self.details = details
    }
}

/// DashboardShellControlSnapshot 是 Workbench 壳展示 session-level local control 的只读行。
///
/// 该 snapshot 消费 MTP-48 的 Command Model 枚举，但只作为展示输入：scope、level、execution mode
/// 和 capability flags 都被固定为本地 paper session。它不携带 command ID，不写 event log，
/// 也不提供 order submit / cancel / replace、broker action 或真实交易授权。
public struct DashboardShellControlSnapshot: Codable, Equatable, Identifiable, Sendable {
    public let control: PaperWorkflowSessionControl
    public let commandAction: PaperSessionLocalControlAction
    public let label: String
    public let systemImage: String
    public let scope: PaperSessionLocalControlScope
    public let controlLevel: PaperSessionLocalControlLevel
    public let executionMode: ExecutionMode
    public let readOnlyPresentation: Bool
    public let authorizesOrderLevelCommand: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesAccountEndpoint: Bool
    public let touchesListenKey: Bool
    public let touchesBrokerAction: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var id: PaperWorkflowSessionControl {
        control
    }

    public init(control: PaperWorkflowSessionControl) {
        self.control = control
        self.commandAction = Self.commandAction(for: control)
        self.label = control.rawValue
        self.systemImage = Self.systemImage(for: control)
        self.scope = .localPaperSession
        self.controlLevel = .session
        self.executionMode = .paper
        self.readOnlyPresentation = true
        self.authorizesOrderLevelCommand = false
        self.authorizesTradingExecution = false
        self.authorizesLiveTrading = false
        self.touchesSignedEndpoint = false
        self.touchesAccountEndpoint = false
        self.touchesListenKey = false
        self.touchesBrokerAction = false
        self.submitsRealOrder = false
        self.cancelsRealOrder = false
        self.replacesRealOrder = false
    }

    public var isSessionLevelLocalPaperControl: Bool {
        scope == .localPaperSession
            && controlLevel == .session
            && executionMode == .paper
            && commandAction.rawValue == control.rawValue
    }

    public var paperOnlyBoundaryHeld: Bool {
        isSessionLevelLocalPaperControl
            && readOnlyPresentation
            && authorizesOrderLevelCommand == false
            && authorizesTradingExecution == false
            && authorizesLiveTrading == false
            && touchesSignedEndpoint == false
            && touchesAccountEndpoint == false
            && touchesListenKey == false
            && touchesBrokerAction == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    private static func commandAction(
        for control: PaperWorkflowSessionControl
    ) -> PaperSessionLocalControlAction {
        switch control {
        case .start:
            .start
        case .pause:
            .pause
        case .close:
            .close
        case .reset:
            .reset
        }
    }

    private static func systemImage(for control: PaperWorkflowSessionControl) -> String {
        switch control {
        case .start:
            "play.circle"
        case .pause:
            "pause.circle"
        case .close:
            "xmark.circle"
        case .reset:
            "arrow.counterclockwise.circle"
        }
    }
}

/// DashboardShellWorkbenchSnapshot 汇总 MTP-52 需要渲染的 Paper workflow Workbench 壳输入。
///
/// Workbench 壳只组合现有 App 层 ViewModel / Read Model / Command Model：session-level controls
/// 来自固定合同，observability、Evidence Explorer 和 Live blocked evidence 都来自
/// `DashboardViewModel`。所有字段都是 read-only 展示材料，不访问运行时对象、adapter request、
/// 数据库结构或真实账户能力，也不形成 live command、交易按钮或真实交易入口。
public struct DashboardShellWorkbenchSnapshot: Codable, Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let source: ViewModelSourceContract
    public let observabilitySource: ViewModelSourceContract
    public let evidenceExplorerSource: ViewModelSourceContract
    public let liveBlockedEvidenceSource: ViewModelSourceContract
    public let sessionControls: [DashboardShellControlSnapshot]
    public let observabilitySections: [PaperWorkflowObservabilitySection]
    public let observabilityMetrics: [DashboardShellMetric]
    public let observabilityDetails: [String]
    public let evidenceExplorerMetrics: [DashboardShellMetric]
    public let evidenceExplorerDetails: [String]
    public let liveBlockedEvidenceMetrics: [DashboardShellMetric]
    public let liveBlockedEvidenceDetails: [String]
    public let timelinePreview: [String]
    public let readModelOnlyBoundaryHeld: Bool
    public let paperOnlyBoundaryHeld: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        title: String = "Paper Workflow Control Shell",
        subtitle: String = "Session-level controls and read-model-only workflow evidence",
        source: ViewModelSourceContract,
        observabilitySource: ViewModelSourceContract,
        evidenceExplorerSource: ViewModelSourceContract,
        liveBlockedEvidenceSource: ViewModelSourceContract,
        sessionControls: [DashboardShellControlSnapshot],
        observabilitySections: [PaperWorkflowObservabilitySection],
        observabilityMetrics: [DashboardShellMetric],
        observabilityDetails: [String],
        evidenceExplorerMetrics: [DashboardShellMetric],
        evidenceExplorerDetails: [String],
        liveBlockedEvidenceMetrics: [DashboardShellMetric],
        liveBlockedEvidenceDetails: [String],
        timelinePreview: [String],
        paperOnlyBoundaryHeld: Bool,
        providesCommandSurface: Bool,
        providesOrderLevelCommand: Bool,
        exposesDatabaseSchema: Bool,
        exposesRuntimeObject: Bool,
        exposesAdapterRequest: Bool,
        authorizesLiveTrading: Bool,
        touchesBrokerAction: Bool,
        authorizesTradingExecution: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.observabilitySource = observabilitySource
        self.evidenceExplorerSource = evidenceExplorerSource
        self.liveBlockedEvidenceSource = liveBlockedEvidenceSource
        self.sessionControls = sessionControls
        self.observabilitySections = observabilitySections
        self.observabilityMetrics = observabilityMetrics
        self.observabilityDetails = observabilityDetails
        self.evidenceExplorerMetrics = evidenceExplorerMetrics
        self.evidenceExplorerDetails = evidenceExplorerDetails
        self.liveBlockedEvidenceMetrics = liveBlockedEvidenceMetrics
        self.liveBlockedEvidenceDetails = liveBlockedEvidenceDetails
        self.timelinePreview = timelinePreview
        self.paperOnlyBoundaryHeld = paperOnlyBoundaryHeld
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && observabilitySource.isReadModelOnly
            && evidenceExplorerSource.isReadModelOnly
            && liveBlockedEvidenceSource.isReadModelOnly
            && sessionControls.allSatisfy(\.paperOnlyBoundaryHeld)
            && paperOnlyBoundaryHeld
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }

    public var viewModelSources: [ViewModelSourceContract] {
        [source, observabilitySource, evidenceExplorerSource, liveBlockedEvidenceSource]
    }

    public var controlLabels: [String] {
        sessionControls.map(\.label)
    }
}

/// DashboardShellSnapshot 是 macOS 看板壳的唯一 View input。
///
/// 它从 `DashboardViewModel` 生成可渲染快照，保证 UI 只消费 App 层 ViewModel / Read Model；
/// shell 不直接连接外部行情 adapter、数据库 schema、runtime object 或任何真实交易能力；
/// Live gates 只作为 blocked evidence 展示，不能被解释成实盘监控台或执行控制面。
public struct DashboardShellSnapshot: Codable, Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let workbench: DashboardShellWorkbenchSnapshot
    public let sections: [DashboardShellSectionSnapshot]

    public init(
        title: String = "MTPRO Research Workbench",
        subtitle: String = "Research -> Backtest -> Report",
        viewModel: DashboardViewModel
    ) {
        self.title = title
        self.subtitle = subtitle
        self.workbench = Self.makeWorkbenchSnapshot(viewModel)
        self.sections = viewModel.sections.map { section in
            Self.makeSectionSnapshot(for: section, viewModel: viewModel)
        }
    }

    public var viewModelSources: [ViewModelSourceContract] {
        sections.map(\.source) + workbench.viewModelSources
    }

    public var isReadModelOnly: Bool {
        viewModelSources.allSatisfy(\.isReadModelOnly)
            && workbench.readModelOnlyBoundaryHeld
    }

    public var smokeSummary: String {
        let sectionNames = sections.map(\.title).joined(separator: ",")
        let controls = workbench.controlLabels.joined(separator: ",")
        let timelineItems = Self.metricValue("Timeline items", in: workbench.evidenceExplorerMetrics)
        let liveBlockedGates = Self.metricValue("Live gates", in: workbench.liveBlockedEvidenceMetrics)
        return "Dashboard smoke: sections=\(sections.count); readModelOnly=\(isReadModelOnly); workbenchReadModelOnly=\(workbench.readModelOnlyBoundaryHeld); controls=\(controls); timelineItems=\(timelineItems); liveBlockedGates=\(liveBlockedGates); sections=\(sectionNames)"
    }

    private static func makeSectionSnapshot(
        for section: DashboardSection,
        viewModel: DashboardViewModel
    ) -> DashboardShellSectionSnapshot {
        switch section {
        case .market:
            return makeMarketSnapshot(viewModel.market)
        case .strategy:
            return makeStrategySnapshot(viewModel.strategy)
        case .backtest:
            return makeBacktestSnapshot(viewModel.backtest)
        case .report:
            return makeReportSnapshot(viewModel.report)
        case .paper:
            return makePaperSnapshot(viewModel.paper)
        case .risk:
            return makeRiskSnapshot(viewModel.risk)
        case .portfolio:
            return makePortfolioSnapshot(viewModel.portfolio)
        case .events:
            return makeEventsSnapshot(viewModel.events)
        }
    }

    private static func makeWorkbenchSnapshot(
        _ viewModel: DashboardViewModel
    ) -> DashboardShellWorkbenchSnapshot {
        let architecture = PaperWorkflowWorkbenchInformationArchitecture.deterministicFixture
        let observability = viewModel.paperWorkflowObservability
        let explorer = viewModel.paperWorkflowEvidenceExplorer
        let liveBlockedEvidence = viewModel.report.liveTradingBlockedEvidence
        let sessionControls = architecture.sessionLevelControls.map(DashboardShellControlSnapshot.init)

        return DashboardShellWorkbenchSnapshot(
            source: architecture.source,
            observabilitySource: observability.source,
            evidenceExplorerSource: explorer.source,
            liveBlockedEvidenceSource: liveBlockedEvidence.source,
            sessionControls: sessionControls,
            observabilitySections: architecture.observabilitySections,
            observabilityMetrics: [
                DashboardShellMetric(label: "Controls", value: "\(sessionControls.count)"),
                DashboardShellMetric(label: "Active sessions", value: "\(observability.activeSessionCount)"),
                DashboardShellMetric(label: "Completed sessions", value: "\(observability.completedSessionCount)"),
                DashboardShellMetric(label: "Allowed evidence", value: "\(observability.allowedEvidenceCount)"),
                DashboardShellMetric(label: "Blocked evidence", value: "\(observability.blockedEvidenceCount)"),
                DashboardShellMetric(label: "Replay", value: observability.replayFreshness.rawValue)
            ],
            observabilityDetails: [
                "Session controls: \(joined(sessionControls.map(\.label)))",
                "Observability sections: \(joined(architecture.observabilitySections.map(\.rawValue)))",
                "Session status: \(joined(observability.sessionStatusLabels))",
                "Proposals: \(joined(observability.proposalIDs))",
                "Allowed decisions: \(joined(observability.allowedDecisionIDs))",
                "Paper orders: \(joined(observability.allowedPaperOrderIDs))",
                "Simulated fills: \(joined(observability.allowedSimulatedFillIDs))",
                "Portfolio updates: \(joined(observability.portfolioUpdateIDs))",
                "Blocked risk evidence: \(joined(observability.blockedRiskEvidenceIDs))",
                "Report artifacts: \(joined(observability.reportArtifactIDs))",
                "Paper boundary: \(formatRuntimeBoundary(observability.paperOnlyBoundaryHeld))",
                "Read model boundary: \(formatEvidenceFlag(observability.readModelOnlyBoundaryHeld))"
            ],
            evidenceExplorerMetrics: [
                DashboardShellMetric(label: "Timeline items", value: "\(explorer.timelineItemCount)"),
                DashboardShellMetric(label: "Evidence links", value: "\(explorer.evidenceLinkCount)"),
                DashboardShellMetric(label: "Sections", value: "\(explorer.sectionSnapshots.count)"),
                DashboardShellMetric(label: "Selected", value: "\(explorer.filterSnapshot.selectedSections.count)")
            ],
            evidenceExplorerDetails: [
                "Explorer sections: \(joined(explorer.filterSnapshot.selectedSections.map(\.rawValue)))",
                "Section coverage: \(formatExplorerCoverage(explorer))",
                "Filter: \(formatReadOnlyFilter(explorer.filterSnapshot))",
                "Command surface: \(formatForbiddenFlag(explorer.providesCommandSurface))",
                "Query language: \(formatForbiddenFlag(explorer.supportsQueryLanguage))",
                "Read model boundary: \(formatEvidenceFlag(explorer.readModelOnlyBoundaryHeld))"
            ],
            liveBlockedEvidenceMetrics: [
                DashboardShellMetric(label: "Live gates", value: "\(liveBlockedEvidence.blockedEvidenceCount)"),
                DashboardShellMetric(label: "Blocked", value: "\(liveBlockedEvidence.blockedCapabilityLabels.count)"),
                DashboardShellMetric(label: "Status", value: liveBlockedEvidence.status.rawValue)
            ],
            liveBlockedEvidenceDetails: [
                "Live readiness: \(liveBlockedEvidence.status.rawValue)",
                "Live blocked capabilities: \(joined(liveBlockedEvidence.blockedCapabilityLabels))",
                "Live gates: \(joined(liveBlockedEvidence.blockedGateLabels))",
                "Live source anchors: \(joined(liveBlockedEvidence.sourceAnchors))",
                "Live command surface: \(formatForbiddenFlag(liveBlockedEvidence.providesCommandSurface))",
                "Live trading authorization: \(formatForbiddenFlag(liveBlockedEvidence.authorizesLiveTrading))",
                "Live blocked boundary: \(formatEvidenceFlag(liveBlockedEvidence.readModelOnlyBoundaryHeld))"
            ],
            timelinePreview: explorer.timelineItems.prefix(5).map {
                "\($0.title): \($0.summary)"
            },
            paperOnlyBoundaryHeld: observability.paperOnlyBoundaryHeld,
            providesCommandSurface: explorer.providesCommandSurface,
            providesOrderLevelCommand: observability.providesOrderLevelCommand
                || explorer.providesOrderLevelCommand
                || liveBlockedEvidence.providesOrderLevelCommand
                || sessionControls.contains { $0.authorizesOrderLevelCommand },
            exposesDatabaseSchema: observability.exposesDatabaseSchema
                || explorer.exposesDatabaseSchema
                || liveBlockedEvidence.exposesDatabaseSchema,
            exposesRuntimeObject: observability.exposesRuntimeObject
                || explorer.exposesRuntimeObject
                || liveBlockedEvidence.exposesRuntimeObject,
            exposesAdapterRequest: observability.exposesAdapterRequest
                || explorer.exposesAdapterRequest
                || liveBlockedEvidence.exposesAdapterSurface,
            authorizesLiveTrading: observability.authorizesLiveTrading
                || explorer.authorizesLiveTrading
                || liveBlockedEvidence.authorizesLiveTrading,
            touchesBrokerAction: observability.touchesBrokerAction
                || explorer.touchesBrokerAction
                || liveBlockedEvidence.touchesBrokerAction,
            authorizesTradingExecution: observability.authorizesTradingExecution
                || explorer.authorizesTradingExecution
                || liveBlockedEvidence.authorizesTradingExecution
        )
    }

    private static func makeMarketSnapshot(
        _ viewModel: MarketViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .market,
            title: viewModel.section.rawValue,
            systemImage: "chart.xyaxis.line",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Symbols", value: "\(viewModel.symbols.count)"),
                DashboardShellMetric(label: "Bars", value: "\(viewModel.barCount)"),
                DashboardShellMetric(label: "Trades", value: "\(viewModel.tradeCount)"),
                DashboardShellMetric(label: "Latest close", value: format(viewModel.latestBarClose))
            ],
            details: [
                "Universe: \(joined(viewModel.symbols))",
                "Best bid / ask: \(viewModel.bestBidAskCount)",
                "Order book snapshots: \(viewModel.orderBookSnapshotCount)",
                "Order book deltas: \(viewModel.orderBookDeltaCount)",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeStrategySnapshot(
        _ viewModel: StrategyViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .strategy,
            title: viewModel.section.rawValue,
            systemImage: "point.3.connected.trianglepath.dotted",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Strategies", value: "\(viewModel.strategyIDs.count)"),
                DashboardShellMetric(label: "Signals", value: "\(viewModel.signalCount)"),
                DashboardShellMetric(label: "Latest signal", value: format(viewModel.latestSignalDirection))
            ],
            details: [
                "Strategy IDs: \(joined(viewModel.strategyIDs))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeBacktestSnapshot(
        _ viewModel: BacktestViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .backtest,
            title: viewModel.section.rawValue,
            systemImage: "clock.arrow.circlepath",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Runs", value: "\(viewModel.runs.count)"),
                DashboardShellMetric(label: "Completed", value: "\(viewModel.completedRunCount)"),
                DashboardShellMetric(label: "Signals", value: "\(viewModel.totalSignalCount)"),
                DashboardShellMetric(label: "Latest signal", value: format(viewModel.latestSignalDirection))
            ],
            details: [
                "Run IDs: \(joined(viewModel.runs.map(\.runID)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeReportSnapshot(
        _ viewModel: ReportViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .report,
            title: viewModel.section.rawValue,
            systemImage: "doc.richtext",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Reports", value: "\(viewModel.artifactCount)"),
                DashboardShellMetric(label: "Parity", value: "\(viewModel.matchedParityEvidenceCount)"),
                DashboardShellMetric(label: "Cost evidence", value: "\(viewModel.executionCostEvidenceCount)"),
                DashboardShellMetric(label: "Risk blockers", value: "\(viewModel.riskBlockerEvidenceCount)"),
                DashboardShellMetric(label: "Exposure", value: "\(viewModel.portfolioExposureEvidenceCount)"),
                DashboardShellMetric(label: "Runtime", value: "\(viewModel.paperRuntimeEvidenceCount)"),
                DashboardShellMetric(label: "Replay facts", value: "\(viewModel.paperRuntimeReplaySequenceCount)"),
                DashboardShellMetric(label: "Exec workflow", value: "\(viewModel.paperExecutionWorkflowEvidenceCount)"),
                DashboardShellMetric(label: "Replay ops", value: "\(viewModel.marketDataReplayEvidenceCount)"),
                DashboardShellMetric(label: "Live gates", value: "\(viewModel.liveBlockedEvidenceCount)")
            ],
            details: [
                "Report IDs: \(joined(viewModel.artifacts.map(\.reportID)))",
                "Backtest run IDs: \(joined(viewModel.artifacts.map(\.backtestRunID)))",
                "Paper sessions: \(joined(viewModel.artifacts.flatMap(\.paperSessionIDs)))",
                "Cost assumptions: \(joined(viewModel.executionCostAssumptionIDs))",
                "Cost parity: \(formatCostParity(viewModel))",
                "Risk blocker evidence: \(joined(viewModel.riskBlockerEvidenceIDs))",
                "Exposure symbols: \(joined(viewModel.portfolioExposureSymbols))",
                "Gross exposure: \(format(viewModel.portfolioGrossExposureNotional))",
                "Runtime sessions: \(joined(viewModel.paperRuntimeSessionIDs))",
                "Lifecycle: \(joined(viewModel.paperRuntimeLifecycleStates))",
                "Proposals: \(joined(viewModel.paperRuntimeProposalIDs))",
                "Runtime blockers: \(joined(viewModel.paperRuntimeRiskBlockerEvidenceIDs))",
                "Portfolio updates: \(joined(viewModel.paperRuntimePortfolioUpdateIDs))",
                "Replay streams: \(joined(viewModel.paperRuntimeReplayStreams))",
                "Runtime boundary: \(formatRuntimeBoundary(viewModel.paperRuntimePaperOnlyBoundaryHeld))",
                "Replay deterministic: \(formatEvidenceFlag(viewModel.paperRuntimeReplayDeterministic))",
                "Execution decisions: \(joined(viewModel.paperExecutionWorkflowDecisionIDs))",
                "Paper orders: \(joined(viewModel.paperExecutionWorkflowOrderIDs))",
                "Simulated fills: \(joined(viewModel.paperExecutionWorkflowSimulatedFillIDs))",
                "Execution workflow streams: \(joined(viewModel.paperExecutionWorkflowStreams))",
                "Execution workflow chain: \(formatEvidenceFlag(viewModel.paperExecutionWorkflowCoversDecisionOrderFillChain))",
                "Execution workflow portfolio projection: \(formatEvidenceFlag(viewModel.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill))",
                "Execution workflow boundary: \(formatRuntimeBoundary(viewModel.paperExecutionWorkflowPaperOnlyBoundaryHeld))",
                "Replay operation batches: \(joined(viewModel.marketDataReplayBatchIDs))",
                "Replay operation runs: \(joined(viewModel.marketDataReplayRunIDs))",
                "Replay operation freshness: \(joined(viewModel.marketDataReplayFreshnessStatuses))",
                "Replay operation retention: \(joined(viewModel.marketDataReplayRetentionStatuses.map(\.rawValue)))",
                "Replay operation projections: \(joined(viewModel.marketDataReplayProjectionConsistencySummaries))",
                "Replay operation boundary: \(formatEvidenceFlag(viewModel.marketDataReplayReadModelOnlyBoundaryHeld))",
                "Live readiness: \(viewModel.liveReadinessStatus.rawValue)",
                "Live blocked capabilities: \(joined(viewModel.liveBlockedCapabilityLabels))",
                "Live gates: \(joined(viewModel.liveBlockedGateLabels))",
                "Live source anchors: \(joined(viewModel.liveBlockedSourceAnchors))",
                "Live blocked boundary: \(formatEvidenceFlag(viewModel.liveReadinessReadModelOnlyBoundaryHeld))",
                "Live command surface: \(formatForbiddenFlag(viewModel.liveReadinessProvidesCommandSurface))",
                "Live trading authorization: \(formatForbiddenFlag(viewModel.liveReadinessAuthorizesLiveTrading))",
                "Trading validation execution: \(format(viewModel.tradingValidationAuthorizesExecution))",
                "Execution: \(format(viewModel.authorizesTradingExecution))",
                "Latest parity: \(format(viewModel.latestParityStatus))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makePaperSnapshot(
        _ viewModel: PaperViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .paper,
            title: viewModel.section.rawValue,
            systemImage: "doc.text.magnifyingglass",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Sessions", value: "\(viewModel.sessions.count)"),
                DashboardShellMetric(label: "Active", value: "\(viewModel.activeSessionCount)"),
                DashboardShellMetric(label: "Completed", value: "\(viewModel.completedSessionCount)")
            ],
            details: [
                "Session IDs: \(joined(viewModel.sessions.map(\.sessionID)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeRiskSnapshot(
        _ viewModel: RiskViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .risk,
            title: viewModel.section.rawValue,
            systemImage: "exclamationmark.triangle",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Blockers", value: "\(viewModel.rejectionCount)")
            ],
            details: [
                "Rejected paper order IDs: \(joined(viewModel.rejectedPaperOrderIDs))",
                "Reasons: \(joined(viewModel.blockerReasons.map(\.rawValue)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makePortfolioSnapshot(
        _ viewModel: PortfolioViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .portfolio,
            title: viewModel.section.rawValue,
            systemImage: "briefcase",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Portfolios", value: "\(viewModel.portfolioIDs.count)"),
                DashboardShellMetric(label: "Updated", value: "\(viewModel.updatedPortfolioCount)"),
                DashboardShellMetric(label: "Exposures", value: "\(viewModel.exposureCount)"),
                DashboardShellMetric(label: "Gross exposure", value: format(viewModel.totalGrossExposureNotional))
            ],
            details: [
                "Portfolio IDs: \(joined(viewModel.portfolioIDs))",
                "Exposure symbols: \(joined(viewModel.exposures.map(\.symbol)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeEventsSnapshot(
        _ viewModel: EventLogViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .events,
            title: viewModel.section.rawValue,
            systemImage: "list.bullet.rectangle",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Events", value: "\(viewModel.eventCount)"),
                DashboardShellMetric(label: "Streams", value: "\(viewModel.streams.count)"),
                DashboardShellMetric(label: "Last sequence", value: format(viewModel.lastSequence))
            ],
            details: [
                "Streams: \(joined(viewModel.streams))"
            ]
        )
    }

    private static func format(_ value: Double?) -> String {
        guard let value else {
            return "n/a"
        }
        return String(format: "%.2f", value)
    }

    private static func format(_ value: Int?) -> String {
        guard let value else {
            return "n/a"
        }
        return "\(value)"
    }

    private static func format(_ value: SignalDirection?) -> String {
        guard let value else {
            return "n/a"
        }
        return value.rawValue
    }

    private static func format(_ value: Bool) -> String {
        value ? "authorized" : "research-only"
    }

    private static func format(_ value: ReportParityStatus?) -> String {
        guard let value else {
            return "n/a"
        }
        return value.rawValue
    }

    private static func formatCostParity(_ viewModel: ReportViewModel) -> String {
        guard viewModel.executionCostEvidenceCount > 0 else {
            return "missing"
        }
        return viewModel.executionCostParityConsistent ? "consistent" : "mismatched"
    }

    private static func formatRuntimeBoundary(_ value: Bool) -> String {
        value ? "paper-only" : "breached"
    }

    private static func formatEvidenceFlag(_ value: Bool) -> String {
        value ? "confirmed" : "missing"
    }

    private static func formatForbiddenFlag(_ value: Bool) -> String {
        value ? "exposed" : "none"
    }

    private static func formatExplorerCoverage(
        _ viewModel: PaperWorkflowEvidenceExplorerViewModel
    ) -> String {
        let covered = viewModel.sectionSnapshots
            .filter { $0.itemCount > 0 }
            .map { $0.section.rawValue }
        return joined(covered)
    }

    private static func formatReadOnlyFilter(
        _ snapshot: PaperWorkflowEvidenceExplorerFilterSnapshot
    ) -> String {
        snapshot.readOnly
            && snapshot.supportsQueryLanguage == false
            && snapshot.supportsCommandSurface == false
            ? "read-only"
            : "mutable"
    }

    private static func joined(_ values: [String]) -> String {
        values.isEmpty ? "n/a" : values.joined(separator: ", ")
    }

    private static func metricValue(
        _ label: String,
        in metrics: [DashboardShellMetric]
    ) -> String {
        metrics.first { $0.label == label }?.value ?? "n/a"
    }
}

public extension DashboardReadModel {
    /// 空研究工作台 read model 是可运行 shell 的安全初始快照。
    ///
    /// 该快照只表达“当前没有已重放事实”和静态 Live blocked gates，不会伪造 market、
    /// paper、risk、portfolio 或真实交易状态；后续真实数据必须继续通过稳定 read model
    /// projection 注入，Live capability 仍需 future gate 独立授权。
    static var emptyResearchWorkbench: DashboardReadModel {
        DashboardReadModel(
            market: MarketReadModel(),
            strategy: StrategyReadModel(),
            backtest: BacktestReadModel(),
            report: ReportReadModel(),
            paper: PaperReadModel(),
            risk: RiskReadModel(),
            portfolio: PortfolioReadModel(),
            events: EventTimelineReadModel()
        )
    }
}

public extension DashboardViewModel {
    /// 可运行 macOS shell 的默认 ViewModel snapshot。
    ///
    /// 输入来自空 read model projection，仅用于 app launch 和 smoke validation；
    /// 它不打开网络、不读取数据库 schema、不创建 broker action，也不提供真实交易控制。
    static var emptyResearchWorkbench: DashboardViewModel {
        DashboardViewModel(readModel: .emptyResearchWorkbench)
    }
}

/// DashboardShellView 是 MTPRO 第一版 macOS 只读看板壳。
///
/// 该 View 只接收 `DashboardViewModel`，内部立即转换为 `DashboardShellSnapshot` 渲染
/// Market、Strategy、Backtest、Report、Paper、Risk、Portfolio 和 Events 八个区域；它没有按钮、
/// 表单或命令出口，因此不会触发外部系统、副作用或真实交易行为。
#if canImport(SwiftUI) && os(macOS)
public struct DashboardShellView: View {
    public let snapshot: DashboardShellSnapshot

    public init(viewModel: DashboardViewModel) {
        self.snapshot = DashboardShellSnapshot(viewModel: viewModel)
    }

    public init(snapshot: DashboardShellSnapshot) {
        self.snapshot = snapshot
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.title)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                    Text(snapshot.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                DashboardWorkbenchPanel(workbench: snapshot.workbench)

                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: 260, maximum: 420),
                            spacing: 12,
                            alignment: .top
                        )
                    ],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(snapshot.sections) { section in
                        DashboardSectionPanel(section: section)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#else
/// DashboardShellView 的非 macOS fallback 只保留 snapshot binding contract。
///
/// GitHub Linux runner 不提供 SwiftUI；该 fallback 让 App target 和 XCTest 仍能验证
/// ViewModel snapshot 绑定、只读来源和 forbidden integration 边界。真实 macOS UI 只在
/// `canImport(SwiftUI) && os(macOS)` 分支中构建。
public struct DashboardShellView: Equatable, Sendable {
    public let snapshot: DashboardShellSnapshot

    public init(viewModel: DashboardViewModel) {
        self.snapshot = DashboardShellSnapshot(viewModel: viewModel)
    }

    public init(snapshot: DashboardShellSnapshot) {
        self.snapshot = snapshot
    }
}
#endif

#if canImport(SwiftUI) && os(macOS)
private struct DashboardWorkbenchPanel: View {
    let workbench: DashboardShellWorkbenchSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label(workbench.title, systemImage: "rectangle.3.group")
                    .font(.headline)
                Text(workbench.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top, spacing: 8) {
                ForEach(workbench.sessionControls) { control in
                    DashboardControlTile(control: control)
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 230, maximum: 360), spacing: 12, alignment: .top)
                ],
                alignment: .leading,
                spacing: 12
            ) {
                DashboardWorkbenchDetailGroup(
                    title: "Observability",
                    systemImage: "eye",
                    metrics: workbench.observabilityMetrics,
                    details: workbench.observabilityDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Evidence Explorer",
                    systemImage: "timeline.selection",
                    metrics: workbench.evidenceExplorerMetrics,
                    details: workbench.evidenceExplorerDetails + workbench.timelinePreview
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Blocked Gates",
                    systemImage: "lock.shield",
                    metrics: workbench.liveBlockedEvidenceMetrics,
                    details: workbench.liveBlockedEvidenceDetails
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}

private struct DashboardControlTile: View {
    let control: DashboardShellControlSnapshot

    var body: some View {
        Label(control.label.capitalized, systemImage: control.systemImage)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
            .help("Read-only \(control.scope.rawValue) \(control.controlLevel.rawValue) control")
    }
}

private struct DashboardWorkbenchDetailGroup: View {
    let title: String
    let systemImage: String
    let metrics: [DashboardShellMetric]
    let details: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))

            HStack(alignment: .top, spacing: 8) {
                ForEach(metrics) { metric in
                    DashboardMetricTile(metric: metric)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(details.prefix(8), id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct DashboardSectionPanel: View {
    let section: DashboardShellSectionSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(section.title, systemImage: section.systemImage)
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                ForEach(section.metrics) { metric in
                    DashboardMetricTile(metric: metric)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.details, id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 172, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}

private struct DashboardMetricTile: View {
    let metric: DashboardShellMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(metric.value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(metric.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
#endif
