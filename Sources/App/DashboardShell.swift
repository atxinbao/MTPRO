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
/// 来自固定合同，observability、Evidence Explorer、scenario replay evidence、Live blocked evidence、execution-control
/// blocked evidence、Live Risk gate blocked evidence 和 incident / stop blocked evidence 都来自
/// `DashboardViewModel`。所有字段都是 read-only 展示材料，不访问运行时对象、adapter request、
/// 数据库结构或真实账户能力，也不形成 live command、stop command、交易按钮或真实交易入口。
public struct DashboardShellWorkbenchSnapshot: Codable, Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let source: ViewModelSourceContract
    public let observabilitySource: ViewModelSourceContract
    public let evidenceExplorerSource: ViewModelSourceContract
    public let scenarioReplayEvidenceSource: ViewModelSourceContract
    public let simulatedExchangeParityEvidenceSource: ViewModelSourceContract
    public let accountPositionBalanceReadModelOnlySurfaceSource: ViewModelSourceContract
    public let privateStreamSimulationGateEvidenceSurfaceSource: ViewModelSourceContract
    public let liveMonitoringReadOnlyConsoleV2SurfaceSource: ViewModelSourceContract
    public let workbenchBetaFirstRunSource: ViewModelSourceContract
    public let workbenchBetaAcceptancePathSource: ViewModelSourceContract
    public let liveReadOnlyWorkbenchBoundarySource: ViewModelSourceContract
    public let liveBlockedEvidenceSource: ViewModelSourceContract
    public let liveMonitoringEvidenceSource: ViewModelSourceContract
    public let liveExecutionControlBlockedEvidenceSource: ViewModelSourceContract
    public let liveRiskGateBlockedEvidenceSource: ViewModelSourceContract
    public let liveIncidentStopBlockedEvidenceSource: ViewModelSourceContract
    public let sessionControls: [DashboardShellControlSnapshot]
    public let observabilitySections: [PaperWorkflowObservabilitySection]
    public let observabilityMetrics: [DashboardShellMetric]
    public let observabilityDetails: [String]
    public let evidenceExplorerMetrics: [DashboardShellMetric]
    public let evidenceExplorerDetails: [String]
    public let scenarioReplayEvidenceMetrics: [DashboardShellMetric]
    public let scenarioReplayEvidenceDetails: [String]
    public let simulatedExchangeParityEvidenceMetrics: [DashboardShellMetric]
    public let simulatedExchangeParityEvidenceDetails: [String]
    public let accountPositionBalanceReadModelOnlySurfaceMetrics: [DashboardShellMetric]
    public let accountPositionBalanceReadModelOnlySurfaceDetails: [String]
    public let privateStreamSimulationGateEvidenceSurfaceMetrics: [DashboardShellMetric]
    public let privateStreamSimulationGateEvidenceSurfaceDetails: [String]
    public let liveMonitoringReadOnlyConsoleV2SurfaceMetrics: [DashboardShellMetric]
    public let liveMonitoringReadOnlyConsoleV2SurfaceDetails: [String]
    public let workbenchBetaFirstRunMetrics: [DashboardShellMetric]
    public let workbenchBetaFirstRunDetails: [String]
    public let workbenchBetaAcceptancePathMetrics: [DashboardShellMetric]
    public let workbenchBetaAcceptancePathDetails: [String]
    public let liveReadOnlyWorkbenchBoundaryMetrics: [DashboardShellMetric]
    public let liveReadOnlyWorkbenchBoundaryDetails: [String]
    public let liveBlockedEvidenceMetrics: [DashboardShellMetric]
    public let liveBlockedEvidenceDetails: [String]
    public let liveMonitoringEvidenceMetrics: [DashboardShellMetric]
    public let liveMonitoringEvidenceDetails: [String]
    public let liveExecutionControlBlockedEvidenceMetrics: [DashboardShellMetric]
    public let liveExecutionControlBlockedEvidenceDetails: [String]
    public let liveRiskGateBlockedEvidenceMetrics: [DashboardShellMetric]
    public let liveRiskGateBlockedEvidenceDetails: [String]
    public let liveIncidentStopBlockedEvidenceMetrics: [DashboardShellMetric]
    public let liveIncidentStopBlockedEvidenceDetails: [String]
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
    public let accountPositionBalanceReadModelOnlySurfaceBoundaryHeld: Bool
    public let privateStreamSimulationGateEvidenceSurfaceBoundaryHeld: Bool
    public let liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld: Bool
    public let workbenchBetaFirstRunReadModelOnlyBoundaryHeld: Bool
    public let workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld: Bool
    public let liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld: Bool

    public init(
        title: String = "Paper Workflow Control Shell",
        subtitle: String = "Session-level controls and read-model-only workflow evidence",
        source: ViewModelSourceContract,
        observabilitySource: ViewModelSourceContract,
        evidenceExplorerSource: ViewModelSourceContract,
        scenarioReplayEvidenceSource: ViewModelSourceContract,
        simulatedExchangeParityEvidenceSource: ViewModelSourceContract,
        accountPositionBalanceReadModelOnlySurfaceSource: ViewModelSourceContract,
        privateStreamSimulationGateEvidenceSurfaceSource: ViewModelSourceContract,
        liveMonitoringReadOnlyConsoleV2SurfaceSource: ViewModelSourceContract,
        workbenchBetaFirstRunSource: ViewModelSourceContract,
        workbenchBetaAcceptancePathSource: ViewModelSourceContract,
        liveReadOnlyWorkbenchBoundarySource: ViewModelSourceContract,
        liveBlockedEvidenceSource: ViewModelSourceContract,
        liveMonitoringEvidenceSource: ViewModelSourceContract,
        liveExecutionControlBlockedEvidenceSource: ViewModelSourceContract,
        liveRiskGateBlockedEvidenceSource: ViewModelSourceContract,
        liveIncidentStopBlockedEvidenceSource: ViewModelSourceContract,
        sessionControls: [DashboardShellControlSnapshot],
        observabilitySections: [PaperWorkflowObservabilitySection],
        observabilityMetrics: [DashboardShellMetric],
        observabilityDetails: [String],
        evidenceExplorerMetrics: [DashboardShellMetric],
        evidenceExplorerDetails: [String],
        scenarioReplayEvidenceMetrics: [DashboardShellMetric],
        scenarioReplayEvidenceDetails: [String],
        simulatedExchangeParityEvidenceMetrics: [DashboardShellMetric],
        simulatedExchangeParityEvidenceDetails: [String],
        accountPositionBalanceReadModelOnlySurfaceMetrics: [DashboardShellMetric],
        accountPositionBalanceReadModelOnlySurfaceDetails: [String],
        privateStreamSimulationGateEvidenceSurfaceMetrics: [DashboardShellMetric],
        privateStreamSimulationGateEvidenceSurfaceDetails: [String],
        liveMonitoringReadOnlyConsoleV2SurfaceMetrics: [DashboardShellMetric],
        liveMonitoringReadOnlyConsoleV2SurfaceDetails: [String],
        workbenchBetaFirstRunMetrics: [DashboardShellMetric],
        workbenchBetaFirstRunDetails: [String],
        workbenchBetaAcceptancePathMetrics: [DashboardShellMetric],
        workbenchBetaAcceptancePathDetails: [String],
        liveReadOnlyWorkbenchBoundaryMetrics: [DashboardShellMetric],
        liveReadOnlyWorkbenchBoundaryDetails: [String],
        liveBlockedEvidenceMetrics: [DashboardShellMetric],
        liveBlockedEvidenceDetails: [String],
        liveMonitoringEvidenceMetrics: [DashboardShellMetric],
        liveMonitoringEvidenceDetails: [String],
        liveExecutionControlBlockedEvidenceMetrics: [DashboardShellMetric],
        liveExecutionControlBlockedEvidenceDetails: [String],
        liveRiskGateBlockedEvidenceMetrics: [DashboardShellMetric],
        liveRiskGateBlockedEvidenceDetails: [String],
        liveIncidentStopBlockedEvidenceMetrics: [DashboardShellMetric],
        liveIncidentStopBlockedEvidenceDetails: [String],
        timelinePreview: [String],
        paperOnlyBoundaryHeld: Bool,
        providesCommandSurface: Bool,
        providesOrderLevelCommand: Bool,
        exposesDatabaseSchema: Bool,
        exposesRuntimeObject: Bool,
        exposesAdapterRequest: Bool,
        authorizesLiveTrading: Bool,
        touchesBrokerAction: Bool,
        authorizesTradingExecution: Bool,
        accountPositionBalanceReadModelOnlySurfaceBoundaryHeld: Bool,
        privateStreamSimulationGateEvidenceSurfaceBoundaryHeld: Bool,
        liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld: Bool,
        workbenchBetaFirstRunReadModelOnlyBoundaryHeld: Bool,
        workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld: Bool,
        liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.observabilitySource = observabilitySource
        self.evidenceExplorerSource = evidenceExplorerSource
        self.scenarioReplayEvidenceSource = scenarioReplayEvidenceSource
        self.simulatedExchangeParityEvidenceSource = simulatedExchangeParityEvidenceSource
        self.accountPositionBalanceReadModelOnlySurfaceSource =
            accountPositionBalanceReadModelOnlySurfaceSource
        self.privateStreamSimulationGateEvidenceSurfaceSource =
            privateStreamSimulationGateEvidenceSurfaceSource
        self.liveMonitoringReadOnlyConsoleV2SurfaceSource =
            liveMonitoringReadOnlyConsoleV2SurfaceSource
        self.workbenchBetaFirstRunSource = workbenchBetaFirstRunSource
        self.workbenchBetaAcceptancePathSource = workbenchBetaAcceptancePathSource
        self.liveReadOnlyWorkbenchBoundarySource = liveReadOnlyWorkbenchBoundarySource
        self.liveBlockedEvidenceSource = liveBlockedEvidenceSource
        self.liveMonitoringEvidenceSource = liveMonitoringEvidenceSource
        self.liveExecutionControlBlockedEvidenceSource = liveExecutionControlBlockedEvidenceSource
        self.liveRiskGateBlockedEvidenceSource = liveRiskGateBlockedEvidenceSource
        self.liveIncidentStopBlockedEvidenceSource = liveIncidentStopBlockedEvidenceSource
        self.sessionControls = sessionControls
        self.observabilitySections = observabilitySections
        self.observabilityMetrics = observabilityMetrics
        self.observabilityDetails = observabilityDetails
        self.evidenceExplorerMetrics = evidenceExplorerMetrics
        self.evidenceExplorerDetails = evidenceExplorerDetails
        self.scenarioReplayEvidenceMetrics = scenarioReplayEvidenceMetrics
        self.scenarioReplayEvidenceDetails = scenarioReplayEvidenceDetails
        self.simulatedExchangeParityEvidenceMetrics = simulatedExchangeParityEvidenceMetrics
        self.simulatedExchangeParityEvidenceDetails = simulatedExchangeParityEvidenceDetails
        self.accountPositionBalanceReadModelOnlySurfaceMetrics =
            accountPositionBalanceReadModelOnlySurfaceMetrics
        self.accountPositionBalanceReadModelOnlySurfaceDetails =
            accountPositionBalanceReadModelOnlySurfaceDetails
        self.privateStreamSimulationGateEvidenceSurfaceMetrics =
            privateStreamSimulationGateEvidenceSurfaceMetrics
        self.privateStreamSimulationGateEvidenceSurfaceDetails =
            privateStreamSimulationGateEvidenceSurfaceDetails
        self.liveMonitoringReadOnlyConsoleV2SurfaceMetrics =
            liveMonitoringReadOnlyConsoleV2SurfaceMetrics
        self.liveMonitoringReadOnlyConsoleV2SurfaceDetails =
            liveMonitoringReadOnlyConsoleV2SurfaceDetails
        self.workbenchBetaFirstRunMetrics = workbenchBetaFirstRunMetrics
        self.workbenchBetaFirstRunDetails = workbenchBetaFirstRunDetails
        self.workbenchBetaAcceptancePathMetrics = workbenchBetaAcceptancePathMetrics
        self.workbenchBetaAcceptancePathDetails = workbenchBetaAcceptancePathDetails
        self.liveReadOnlyWorkbenchBoundaryMetrics = liveReadOnlyWorkbenchBoundaryMetrics
        self.liveReadOnlyWorkbenchBoundaryDetails = liveReadOnlyWorkbenchBoundaryDetails
        self.liveBlockedEvidenceMetrics = liveBlockedEvidenceMetrics
        self.liveBlockedEvidenceDetails = liveBlockedEvidenceDetails
        self.liveMonitoringEvidenceMetrics = liveMonitoringEvidenceMetrics
        self.liveMonitoringEvidenceDetails = liveMonitoringEvidenceDetails
        self.liveExecutionControlBlockedEvidenceMetrics = liveExecutionControlBlockedEvidenceMetrics
        self.liveExecutionControlBlockedEvidenceDetails = liveExecutionControlBlockedEvidenceDetails
        self.liveRiskGateBlockedEvidenceMetrics = liveRiskGateBlockedEvidenceMetrics
        self.liveRiskGateBlockedEvidenceDetails = liveRiskGateBlockedEvidenceDetails
        self.liveIncidentStopBlockedEvidenceMetrics = liveIncidentStopBlockedEvidenceMetrics
        self.liveIncidentStopBlockedEvidenceDetails = liveIncidentStopBlockedEvidenceDetails
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
        self.accountPositionBalanceReadModelOnlySurfaceBoundaryHeld =
            accountPositionBalanceReadModelOnlySurfaceBoundaryHeld
        self.privateStreamSimulationGateEvidenceSurfaceBoundaryHeld =
            privateStreamSimulationGateEvidenceSurfaceBoundaryHeld
        self.liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld =
            liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld
        self.workbenchBetaFirstRunReadModelOnlyBoundaryHeld =
            workbenchBetaFirstRunReadModelOnlyBoundaryHeld
        self.workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld =
            workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld
        self.liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld =
            liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && observabilitySource.isReadModelOnly
            && evidenceExplorerSource.isReadModelOnly
            && scenarioReplayEvidenceSource.isReadModelOnly
            && simulatedExchangeParityEvidenceSource.isReadModelOnly
            && accountPositionBalanceReadModelOnlySurfaceSource.isReadModelOnly
            && privateStreamSimulationGateEvidenceSurfaceSource.isReadModelOnly
            && liveMonitoringReadOnlyConsoleV2SurfaceSource.isReadModelOnly
            && workbenchBetaFirstRunSource.isReadModelOnly
            && workbenchBetaAcceptancePathSource.isReadModelOnly
            && liveReadOnlyWorkbenchBoundarySource.isReadModelOnly
            && liveBlockedEvidenceSource.isReadModelOnly
            && liveMonitoringEvidenceSource.isReadModelOnly
            && liveExecutionControlBlockedEvidenceSource.isReadModelOnly
            && liveRiskGateBlockedEvidenceSource.isReadModelOnly
            && liveIncidentStopBlockedEvidenceSource.isReadModelOnly
            && sessionControls.allSatisfy(\.paperOnlyBoundaryHeld)
            && accountPositionBalanceReadModelOnlySurfaceBoundaryHeld
            && privateStreamSimulationGateEvidenceSurfaceBoundaryHeld
            && liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld
            && workbenchBetaFirstRunReadModelOnlyBoundaryHeld
            && workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld
            && liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld
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
        [
            source,
            observabilitySource,
            evidenceExplorerSource,
            scenarioReplayEvidenceSource,
            simulatedExchangeParityEvidenceSource,
            accountPositionBalanceReadModelOnlySurfaceSource,
            privateStreamSimulationGateEvidenceSurfaceSource,
            liveMonitoringReadOnlyConsoleV2SurfaceSource,
            workbenchBetaFirstRunSource,
            workbenchBetaAcceptancePathSource,
            liveReadOnlyWorkbenchBoundarySource,
            liveBlockedEvidenceSource,
            liveMonitoringEvidenceSource,
            liveExecutionControlBlockedEvidenceSource,
            liveRiskGateBlockedEvidenceSource,
            liveIncidentStopBlockedEvidenceSource
        ]
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
        let scenarioReplayEvidence = Self.metricValue(
            "Scenarios",
            in: workbench.scenarioReplayEvidenceMetrics
        )
        let scenarioQualityGates = Self.metricValue(
            "Quality gates",
            in: workbench.scenarioReplayEvidenceMetrics
        )
        let simulatedParityEvidence = Self.metricValue(
            "Parity evidence",
            in: workbench.simulatedExchangeParityEvidenceMetrics
        )
        let accountPositionBalanceEvidence = Self.metricValue(
            "APB records",
            in: workbench.accountPositionBalanceReadModelOnlySurfaceMetrics
        )
        let privateStreamSimulationGateEvidence = Self.metricValue(
            "Simulation gate",
            in: workbench.privateStreamSimulationGateEvidenceSurfaceMetrics
        )
        let liveMonitoringReadOnlyConsoleV2Surface = Self.metricValue(
            "Live monitoring v2",
            in: workbench.liveMonitoringReadOnlyConsoleV2SurfaceMetrics
        )
        let defaultDemoState = Self.metricValue(
            "First run",
            in: workbench.workbenchBetaFirstRunMetrics
        )
        let defaultDemoScenario = Self.metricValue(
            "Demo scenario",
            in: workbench.workbenchBetaFirstRunMetrics
        )
        let betaFallbacks = Self.metricValue(
            "Fallbacks",
            in: workbench.workbenchBetaFirstRunMetrics
        )
        let betaAcceptancePaths = Self.metricValue(
            "Acceptance paths",
            in: workbench.workbenchBetaAcceptancePathMetrics
        )
        let betaAcceptanceScenario = Self.metricValue(
            "Acceptance scenario",
            in: workbench.workbenchBetaAcceptancePathMetrics
        )
        let betaAcceptanceTrace = Self.metricValue(
            "Event trace",
            in: workbench.workbenchBetaAcceptancePathMetrics
        )
        let liveBlockedGates = Self.metricValue("Live gates", in: workbench.liveBlockedEvidenceMetrics)
        let liveExecutionControlGates = Self.metricValue(
            "Execution gates",
            in: workbench.liveExecutionControlBlockedEvidenceMetrics
        )
        let liveRiskGates = Self.metricValue(
            "Risk gates",
            in: workbench.liveRiskGateBlockedEvidenceMetrics
        )
        let liveIncidentStopGates = Self.metricValue(
            "Incident stop gates",
            in: workbench.liveIncidentStopBlockedEvidenceMetrics
        )
        let liveReadOnlyWorkbenchBoundary = Self.metricValue(
            "Workbench boundary",
            in: workbench.liveReadOnlyWorkbenchBoundaryMetrics
        )
        let liveMonitoringHealth = Self.metricValue(
            "Health",
            in: workbench.liveMonitoringEvidenceMetrics
        )
        let liveMonitoringErrors = Self.metricValue(
            "Errors",
            in: workbench.liveMonitoringEvidenceMetrics
        )
        let reportMetrics = sections.first { $0.section == .report }?.metrics ?? []
        let paperRuntimeEvidence = Self.metricValue("Runtime", in: reportMetrics)
        let paperWorkflowEvidence = Self.metricValue("Exec workflow", in: reportMetrics)
        let paperPortfolioImpact = Self.metricValue("Paper PnL", in: reportMetrics)
        return "Dashboard smoke: sections=\(sections.count); readModelOnly=\(isReadModelOnly); workbenchReadModelOnly=\(workbench.readModelOnlyBoundaryHeld); controls=\(controls); timelineItems=\(timelineItems); scenarioReplayEvidence=\(scenarioReplayEvidence); scenarioQualityGates=\(scenarioQualityGates); simulatedParityEvidence=\(simulatedParityEvidence); accountPositionBalanceEvidence=\(accountPositionBalanceEvidence); privateStreamSimulationGateEvidence=\(privateStreamSimulationGateEvidence); liveMonitoringReadOnlyConsoleV2Surface=\(liveMonitoringReadOnlyConsoleV2Surface); defaultDemoState=\(defaultDemoState); defaultDemoScenario=\(defaultDemoScenario); betaFirstRunFallbacks=\(betaFallbacks); betaAcceptancePaths=\(betaAcceptancePaths); betaAcceptanceScenario=\(betaAcceptanceScenario); betaAcceptanceTrace=\(betaAcceptanceTrace); paperRuntimeEvidence=\(paperRuntimeEvidence); paperWorkflowEvidence=\(paperWorkflowEvidence); paperPortfolioImpact=\(paperPortfolioImpact); liveBlockedGates=\(liveBlockedGates); liveExecutionControlGates=\(liveExecutionControlGates); liveRiskGates=\(liveRiskGates); liveIncidentStopGates=\(liveIncidentStopGates); liveReadOnlyWorkbenchBoundary=\(liveReadOnlyWorkbenchBoundary); liveMonitoringHealth=\(liveMonitoringHealth); liveMonitoringErrors=\(liveMonitoringErrors); sections=\(sectionNames)"
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
        let scenarioReplayEvidence = viewModel.report.scenarioReplayEvidence
        let simulatedExchangeParityEvidence = viewModel.report.simulatedExchangeParityEvidence
        let accountPositionBalanceSurface = viewModel.report.accountPositionBalanceReadModelOnlySurface
        let privateStreamSimulationGateSurface = viewModel.report.privateStreamSimulationGateEvidenceSurface
        let liveMonitoringReadOnlyConsoleV2Surface = viewModel.report.liveMonitoringReadOnlyConsoleV2Surface
        let workbenchBetaFirstRun = viewModel.workbenchBetaFirstRun
        let workbenchBetaAcceptancePath = viewModel.workbenchBetaAcceptancePath
        let liveReadOnlyWorkbenchBoundary = viewModel.report.liveReadOnlyWorkbenchBoundary
        let liveBlockedEvidence = viewModel.report.liveTradingBlockedEvidence
        let liveMonitoringEvidence = viewModel.report.liveMonitoringEvidence
        let liveExecutionControlEvidence = viewModel.report.liveExecutionControlBlockedEvidence
        let liveRiskGateEvidence = viewModel.report.liveRiskGateBlockedEvidence
        let liveIncidentStopEvidence = viewModel.report.liveIncidentStopBlockedEvidence
        let sessionControls = architecture.sessionLevelControls.map(DashboardShellControlSnapshot.init)

        return DashboardShellWorkbenchSnapshot(
            source: architecture.source,
            observabilitySource: observability.source,
            evidenceExplorerSource: explorer.source,
            scenarioReplayEvidenceSource: scenarioReplayEvidence.source,
            simulatedExchangeParityEvidenceSource: simulatedExchangeParityEvidence.source,
            accountPositionBalanceReadModelOnlySurfaceSource: accountPositionBalanceSurface.source,
            privateStreamSimulationGateEvidenceSurfaceSource: privateStreamSimulationGateSurface.source,
            liveMonitoringReadOnlyConsoleV2SurfaceSource: liveMonitoringReadOnlyConsoleV2Surface.source,
            workbenchBetaFirstRunSource: workbenchBetaFirstRun.source,
            workbenchBetaAcceptancePathSource: workbenchBetaAcceptancePath.source,
            liveReadOnlyWorkbenchBoundarySource: liveReadOnlyWorkbenchBoundary.source,
            liveBlockedEvidenceSource: liveBlockedEvidence.source,
            liveMonitoringEvidenceSource: liveMonitoringEvidence.source,
            liveExecutionControlBlockedEvidenceSource: liveExecutionControlEvidence.source,
            liveRiskGateBlockedEvidenceSource: liveRiskGateEvidence.source,
            liveIncidentStopBlockedEvidenceSource: liveIncidentStopEvidence.source,
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
            scenarioReplayEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Scenarios",
                    value: "\(scenarioReplayEvidence.evidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Quality gates",
                    value: "\(scenarioReplayEvidence.qualityGateTimelineCount)"
                ),
                DashboardShellMetric(
                    label: "Report inputs",
                    value: "\(scenarioReplayEvidence.reportInputVersionIdentities.count)"
                ),
                DashboardShellMetric(
                    label: "Quality",
                    value: scenarioReplayEvidence.qualityVerdicts.first?.rawValue ?? "n/a"
                )
            ],
            scenarioReplayEvidenceDetails: [
                "Scenario ids: \(joined(scenarioReplayEvidence.scenarioIDs))",
                "Dataset versions: \(joined(scenarioReplayEvidence.datasetVersions))",
                "Fixture versions: \(joined(scenarioReplayEvidence.fixtureVersions))",
                "Replay windows: \(joined(scenarioReplayEvidence.replayWindows))",
                "Checksums: \(joined(scenarioReplayEvidence.checksums))",
                "Freshness: \(joined(scenarioReplayEvidence.freshnessStatuses.map(\.rawValue)))",
                "Quality verdicts: \(joined(scenarioReplayEvidence.qualityVerdicts.map(\.rawValue)))",
                "Drill-down entries: \(joined(scenarioReplayEvidence.drillDownEntries))",
                "Command surface: \(formatForbiddenFlag(scenarioReplayEvidence.providesCommandSurface))",
                "Query language: \(formatForbiddenFlag(scenarioReplayEvidence.supportsQueryLanguage))",
                "Read model boundary: \(formatEvidenceFlag(scenarioReplayEvidence.readModelOnlyBoundaryHeld))"
            ],
            simulatedExchangeParityEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Parity evidence",
                    value: "\(simulatedExchangeParityEvidence.evidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Outcomes",
                    value: "\(simulatedExchangeParityEvidence.outcomeLabels.count)"
                ),
                DashboardShellMetric(
                    label: "Timeline",
                    value: "\(simulatedExchangeParityEvidence.timelineEntryCount)"
                ),
                DashboardShellMetric(
                    label: "Portfolio parity",
                    value: formatEvidenceFlag(simulatedExchangeParityEvidence.projectionParityHeld)
                ),
                DashboardShellMetric(
                    label: "Cost parity",
                    value: formatEvidenceFlag(simulatedExchangeParityEvidence.costParityConsistent)
                )
            ],
            simulatedExchangeParityEvidenceDetails: [
                "Parity scenario ids: \(joined(simulatedExchangeParityEvidence.scenarioIDs))",
                "Parity dataset versions: \(joined(simulatedExchangeParityEvidence.datasetVersions))",
                "Parity fixture versions: \(joined(simulatedExchangeParityEvidence.fixtureVersions))",
                "Parity replay windows: \(joined(simulatedExchangeParityEvidence.replayWindows))",
                "Parity matching results: \(joined(simulatedExchangeParityEvidence.matchingResults))",
                "Parity matching events: \(joined(simulatedExchangeParityEvidence.matchingEventIDs))",
                "Parity order ids: \(joined(simulatedExchangeParityEvidence.orderIDs))",
                "Parity outcomes: \(joined(simulatedExchangeParityEvidence.outcomeLabels))",
                "Parity report inputs: \(joined(simulatedExchangeParityEvidence.reportInputVersionIdentities))",
                "Parity replay sequences: \(joined(simulatedExchangeParityEvidence.sourceReplaySequences.map(String.init)))",
                "Parity portfolio: \(formatEvidenceFlag(simulatedExchangeParityEvidence.projectionParityHeld))",
                "Parity cost: \(formatEvidenceFlag(simulatedExchangeParityEvidence.costParityConsistent))",
                "Parity boundary: \(formatEvidenceFlag(simulatedExchangeParityEvidence.readModelOnlyBoundaryHeld))",
                "Parity command surface: \(formatForbiddenFlag(simulatedExchangeParityEvidence.providesCommandSurface))",
                "Parity order-level command: \(formatForbiddenFlag(simulatedExchangeParityEvidence.providesOrderLevelCommand))",
                "Parity trading buttons: \(formatForbiddenFlag(simulatedExchangeParityEvidence.providesTradingButton))",
                "Parity schema exposure: \(formatForbiddenFlag(simulatedExchangeParityEvidence.exposesDatabaseSchema))",
                "Parity runtime exposure: \(formatForbiddenFlag(simulatedExchangeParityEvidence.exposesRuntimeObject))",
                "Parity adapter exposure: \(formatForbiddenFlag(simulatedExchangeParityEvidence.exposesAdapterRequest))"
            ],
            accountPositionBalanceReadModelOnlySurfaceMetrics: [
                DashboardShellMetric(
                    label: "APB records",
                    value: "\(accountPositionBalanceSurface.recordCount)"
                ),
                DashboardShellMetric(
                    label: "Fixture",
                    value: accountPositionBalanceSurface.fixtureVersion
                ),
                DashboardShellMetric(
                    label: "Freshness",
                    value: joined(accountPositionBalanceSurface.freshnessStatuses.map(\.rawValue))
                ),
                DashboardShellMetric(
                    label: "Event trace",
                    value: "\(accountPositionBalanceSurface.eventTraceItemCount)"
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(accountPositionBalanceSurface.readModelOnlyBoundaryHeld)
                )
            ],
            accountPositionBalanceReadModelOnlySurfaceDetails: [
                "APB report summary: \(accountPositionBalanceSurface.reportSummary)",
                "APB components: \(joined(accountPositionBalanceSurface.componentLabels))",
                "APB snapshots: \(joined(accountPositionBalanceSurface.snapshotIDs))",
                "APB evidence ids: \(joined(accountPositionBalanceSurface.evidenceIDs))",
                "APB source identity: \(accountPositionBalanceSurface.sourceIdentity)",
                "APB source watermark: \(accountPositionBalanceSurface.sourceWatermark)",
                "APB read model fields: \(joined(accountPositionBalanceSurface.readModelFieldNames))",
                "APB dashboard panels: \(joined(accountPositionBalanceSurface.dashboardPanelSummaries))",
                "APB event trace: \(joined(accountPositionBalanceSurface.eventTraceItems.map(\.title)))",
                "APB blocked states: \(joined(accountPositionBalanceSurface.blockedStateLabels))",
                "APB stale states: \(joined(accountPositionBalanceSurface.staleStateLabels))",
                "APB simulated states: \(joined(accountPositionBalanceSurface.simulatedStateLabels))",
                "APB API key input: \(formatForbiddenFlag(accountPositionBalanceSurface.exposesAPIKeyInput))",
                "APB secret storage: \(formatForbiddenFlag(accountPositionBalanceSurface.storesSecret))",
                "APB broker connect: \(formatForbiddenFlag(accountPositionBalanceSurface.providesBrokerConnect))",
                "APB account connect: \(formatForbiddenFlag(accountPositionBalanceSurface.providesAccountConnect))",
                "APB Live PRO Console: \(formatForbiddenFlag(accountPositionBalanceSurface.exposesLivePROConsole))",
                "APB trading button: \(formatForbiddenFlag(accountPositionBalanceSurface.providesTradingButton))",
                "APB live command: \(formatForbiddenFlag(accountPositionBalanceSurface.providesLiveCommand))",
                "APB order form: \(formatForbiddenFlag(accountPositionBalanceSurface.exposesOrderForm))",
                "APB signed endpoint: \(formatForbiddenFlag(accountPositionBalanceSurface.callsSignedEndpoint))",
                "APB account endpoint: \(formatForbiddenFlag(accountPositionBalanceSurface.callsAccountEndpoint))",
                "APB listenKey: \(formatForbiddenFlag(accountPositionBalanceSurface.createsListenKey))",
                "APB runtime object: \(formatForbiddenFlag(accountPositionBalanceSurface.exposesRuntimeObject))",
                "APB adapter request: \(formatForbiddenFlag(accountPositionBalanceSurface.exposesAdapterRequest))",
                "APB boundary: \(formatEvidenceFlag(accountPositionBalanceSurface.readModelOnlyBoundaryHeld))"
            ],
            privateStreamSimulationGateEvidenceSurfaceMetrics: [
                DashboardShellMetric(
                    label: "Simulation gate",
                    value: "\(privateStreamSimulationGateSurface.freshnessEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Sources",
                    value: "\(privateStreamSimulationGateSurface.sourceIdentityRecordCount)"
                ),
                DashboardShellMetric(
                    label: "Snapshot inputs",
                    value: "\(privateStreamSimulationGateSurface.snapshotInputCount)"
                ),
                DashboardShellMetric(
                    label: "Update fixtures",
                    value: "\(privateStreamSimulationGateSurface.updateFixtureRecordCount)"
                ),
                DashboardShellMetric(
                    label: "Event trace",
                    value: "\(privateStreamSimulationGateSurface.eventTraceItemCount)"
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(privateStreamSimulationGateSurface.readModelOnlyBoundaryHeld)
                )
            ],
            privateStreamSimulationGateEvidenceSurfaceDetails: [
                "Simulation gate report summary: \(privateStreamSimulationGateSurface.reportSummary)",
                "Simulation gate source identities: \(joined(privateStreamSimulationGateSurface.sourceIdentities))",
                "Simulation gate snapshot inputs: \(joined(privateStreamSimulationGateSurface.snapshotInputIDs))",
                "Simulation gate update fixtures: \(joined(privateStreamSimulationGateSurface.updateFixtureIDs))",
                "Simulation gate freshness: \(joined(privateStreamSimulationGateSurface.freshnessStatuses.map(\.rawValue)))",
                "Simulation gate input states: \(joined(privateStreamSimulationGateSurface.freshnessInputStates.map(\.rawValue)))",
                "Simulation gate boundary reasons: \(joined(privateStreamSimulationGateSurface.boundaryReasonCodes))",
                "Simulation gate panels: \(joined(privateStreamSimulationGateSurface.dashboardPanelSummaries))",
                "Simulation gate event trace: \(joined(privateStreamSimulationGateSurface.eventTraceItems.map(\.title)))",
                "Simulation gate forbidden UI: \(joined(privateStreamSimulationGateSurface.forbiddenUISurfaceLabels))",
                "Simulation gate API key input: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesAPIKeyInput))",
                "Simulation gate secret storage: \(formatForbiddenFlag(privateStreamSimulationGateSurface.storesSecret))",
                "Simulation gate account connect: \(formatForbiddenFlag(privateStreamSimulationGateSurface.providesAccountConnect))",
                "Simulation gate broker connect: \(formatForbiddenFlag(privateStreamSimulationGateSurface.providesBrokerConnect))",
                "Simulation gate Live PRO Console: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesLivePROConsole))",
                "Simulation gate trading button: \(formatForbiddenFlag(privateStreamSimulationGateSurface.providesTradingButton))",
                "Simulation gate live command: \(formatForbiddenFlag(privateStreamSimulationGateSurface.providesLiveCommand))",
                "Simulation gate order form: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesOrderForm))",
                "Simulation gate signed endpoint: \(formatForbiddenFlag(privateStreamSimulationGateSurface.callsSignedEndpoint))",
                "Simulation gate account endpoint: \(formatForbiddenFlag(privateStreamSimulationGateSurface.callsAccountEndpoint))",
                "Simulation gate listenKey: \(formatForbiddenFlag(privateStreamSimulationGateSurface.createsListenKey))",
                "Simulation gate private stream runtime: \(formatForbiddenFlag(privateStreamSimulationGateSurface.runsPrivateStreamRuntime))",
                "Simulation gate account snapshot runtime: \(formatForbiddenFlag(privateStreamSimulationGateSurface.runsAccountSnapshotRuntime))",
                "Simulation gate runtime object: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesRuntimeObject))",
                "Simulation gate adapter request: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesAdapterRequest))",
                "Simulation gate database schema: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesDatabaseSchema))",
                "Simulation gate account payload: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesAccountPayload))",
                "Simulation gate broker state: \(formatForbiddenFlag(privateStreamSimulationGateSurface.exposesBrokerState))",
                "Simulation gate boundary: \(formatEvidenceFlag(privateStreamSimulationGateSurface.readModelOnlyBoundaryHeld))"
            ],
            liveMonitoringReadOnlyConsoleV2SurfaceMetrics: [
                DashboardShellMetric(
                    label: "Live monitoring v2",
                    value: "\(liveMonitoringReadOnlyConsoleV2Surface.eventTraceItemCount)"
                ),
                DashboardShellMetric(
                    label: "Sources",
                    value: "\(liveMonitoringReadOnlyConsoleV2Surface.sourceIdentityRecordCount)"
                ),
                DashboardShellMetric(
                    label: "Health evidence",
                    value: "\(liveMonitoringReadOnlyConsoleV2Surface.healthEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Readiness",
                    value: "\(liveMonitoringReadOnlyConsoleV2Surface.readinessExplanationCount)"
                ),
                DashboardShellMetric(
                    label: "Forbidden tests",
                    value: "\(liveMonitoringReadOnlyConsoleV2Surface.forbiddenTestCaseCount)"
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(liveMonitoringReadOnlyConsoleV2Surface.readModelOnlyBoundaryHeld)
                )
            ],
            liveMonitoringReadOnlyConsoleV2SurfaceDetails: [
                "Live Monitoring v2 summary: \(liveMonitoringReadOnlyConsoleV2Surface.reportSummary)",
                "Live Monitoring v2 source identities: \(joined(liveMonitoringReadOnlyConsoleV2Surface.sourceIdentities))",
                "Live Monitoring v2 source freshness: \(joined(liveMonitoringReadOnlyConsoleV2Surface.sourceFreshnessLabels))",
                "Live Monitoring v2 health: \(joined(liveMonitoringReadOnlyConsoleV2Surface.healthStatusLabels))",
                "Live Monitoring v2 freshness: \(joined(liveMonitoringReadOnlyConsoleV2Surface.freshnessStatusLabels))",
                "Live Monitoring v2 readiness: \(joined(liveMonitoringReadOnlyConsoleV2Surface.readinessStateLabels))",
                "Live Monitoring v2 blocked explanations: \(joined(liveMonitoringReadOnlyConsoleV2Surface.blockedExplanationIDs))",
                "Live Monitoring v2 stale explanations: \(joined(liveMonitoringReadOnlyConsoleV2Surface.staleExplanationIDs))",
                "Live Monitoring v2 missing explanations: \(joined(liveMonitoringReadOnlyConsoleV2Surface.missingExplanationIDs))",
                "Live Monitoring v2 forbidden domains: \(joined(liveMonitoringReadOnlyConsoleV2Surface.forbiddenTestDomainLabels))",
                "Live Monitoring v2 panels: \(joined(liveMonitoringReadOnlyConsoleV2Surface.dashboardPanelSummaries))",
                "Live Monitoring v2 event trace: \(joined(liveMonitoringReadOnlyConsoleV2Surface.eventTraceItems.map(\.title)))",
                "Live Monitoring v2 Live PRO Console: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesLivePROConsole))",
                "Live Monitoring v2 trading button: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.providesTradingButton))",
                "Live Monitoring v2 live command: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.providesLiveCommand))",
                "Live Monitoring v2 order form: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesOrderForm))",
                "Live Monitoring v2 signed endpoint: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.callsSignedEndpoint))",
                "Live Monitoring v2 account endpoint: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.callsAccountEndpoint))",
                "Live Monitoring v2 listenKey: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.createsListenKey))",
                "Live Monitoring v2 private websocket: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.opensPrivateWebSocket))",
                "Live Monitoring v2 private stream runtime: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.runsPrivateStreamRuntime))",
                "Live Monitoring v2 account snapshot runtime: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.runsAccountSnapshotRuntime))",
                "Live Monitoring v2 connection manager: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.createsConnectionManager))",
                "Live Monitoring v2 runtime connection: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.opensRuntimeConnection))",
                "Live Monitoring v2 live readiness: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.implementsLiveReadiness))",
                "Live Monitoring v2 runtime: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.runsLiveMonitoringRuntime))",
                "Live Monitoring v2 runtime object: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesRuntimeObject))",
                "Live Monitoring v2 adapter request: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesAdapterRequest))",
                "Live Monitoring v2 database schema: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesDatabaseSchema))",
                "Live Monitoring v2 account payload: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesAccountPayload))",
                "Live Monitoring v2 broker state: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.exposesBrokerState))",
                "Live Monitoring v2 broker connect: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.connectsBroker))",
                "Live Monitoring v2 execution adapter: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.implementsLiveExecutionAdapter))",
                "Live Monitoring v2 OMS: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.implementsOMS))",
                "Live Monitoring v2 real account: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.readsRealAccount))",
                "Live Monitoring v2 real position: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.readsRealPosition))",
                "Live Monitoring v2 real balance: \(formatForbiddenFlag(liveMonitoringReadOnlyConsoleV2Surface.readsRealBalance))",
                "Live Monitoring v2 boundary: \(formatEvidenceFlag(liveMonitoringReadOnlyConsoleV2Surface.readModelOnlyBoundaryHeld))"
            ],
            workbenchBetaFirstRunMetrics: [
                DashboardShellMetric(
                    label: "First run",
                    value: workbenchBetaFirstRun.state.rawValue
                ),
                DashboardShellMetric(
                    label: "Demo scenario",
                    value: workbenchBetaFirstRun.selectedScenarioID ?? "n/a"
                ),
                DashboardShellMetric(
                    label: "Fallbacks",
                    value: "\(workbenchBetaFirstRun.fallbackStates.count)"
                ),
                DashboardShellMetric(
                    label: "Default selected",
                    value: formatEvidenceFlag(workbenchBetaFirstRun.isDefaultSelectedScenario)
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(workbenchBetaFirstRun.readModelOnlyBoundaryHeld)
                )
            ],
            workbenchBetaFirstRunDetails: [
                "First-run state: \(workbenchBetaFirstRun.state.rawValue)",
                "First-run summary: \(workbenchBetaFirstRun.stateSummary)",
                "Selected scenario: \(workbenchBetaFirstRun.selectedScenarioID ?? "n/a")",
                "Default scenario: \(workbenchBetaFirstRun.defaultSelectedScenarioID)",
                "Fallback states: \(joined(workbenchBetaFirstRun.fallbackStateLabels))",
                "Dataset version: \(workbenchBetaFirstRun.evidenceSummary?.datasetVersion ?? "n/a")",
                "Fixture version: \(workbenchBetaFirstRun.evidenceSummary?.fixtureVersion ?? "n/a")",
                "Checksum: \(workbenchBetaFirstRun.evidenceSummary?.checksum ?? "n/a")",
                "Freshness: \(workbenchBetaFirstRun.evidenceSummary?.freshnessStatus.rawValue ?? "n/a")",
                "Quality: \(workbenchBetaFirstRun.evidenceSummary?.qualityVerdict.rawValue ?? "n/a")",
                "Report input: \(workbenchBetaFirstRun.evidenceSummary?.reportInputVersionIdentity ?? "n/a")",
                "Read model boundary: \(formatEvidenceFlag(workbenchBetaFirstRun.readModelOnlyBoundaryHeld))",
                "Command surface: \(formatForbiddenFlag(workbenchBetaFirstRun.providesCommandSurface))",
                "Trading button: \(formatForbiddenFlag(workbenchBetaFirstRun.providesTradingButton))",
                "Live command: \(formatForbiddenFlag(workbenchBetaFirstRun.providesLiveCommand))"
            ],
            workbenchBetaAcceptancePathMetrics: [
                DashboardShellMetric(
                    label: "Acceptance paths",
                    value: "\(workbenchBetaAcceptancePath.acceptancePathCount)"
                ),
                DashboardShellMetric(
                    label: "Acceptance scenario",
                    value: workbenchBetaAcceptancePath.scenarioIDs.first ?? "n/a"
                ),
                DashboardShellMetric(
                    label: "Event trace",
                    value: "\(workbenchBetaAcceptancePath.eventTraceItemCount)"
                ),
                DashboardShellMetric(
                    label: "Portfolio",
                    value: formatEvidenceFlag(workbenchBetaAcceptancePath.portfolioEvidenceHeld)
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(workbenchBetaAcceptancePath.readModelOnlyBoundaryHeld)
                )
            ],
            workbenchBetaAcceptancePathDetails: [
                "Report summaries: \(joined(workbenchBetaAcceptancePath.reportSummaries))",
                "Dashboard panels: \(joined(workbenchBetaAcceptancePath.dashboardPanelSummaries))",
                "Event trace: \(joined(workbenchBetaAcceptancePath.eventTraceItems.map(\.title)))",
                "Report inputs: \(joined(workbenchBetaAcceptancePath.reportInputVersionIdentities))",
                "Portfolio evidence: \(joined(workbenchBetaAcceptancePath.portfolioEvidenceIDs))",
                "Gross exposure: \(format(workbenchBetaAcceptancePath.grossExposureNotional))",
                "Net simulated PnL: \(format(workbenchBetaAcceptancePath.netSimulatedPnL))",
                "Same demo scenario: \(formatEvidenceFlag(workbenchBetaAcceptancePath.sameDemoScenarioHeld))",
                "Report surface: \(formatEvidenceFlag(workbenchBetaAcceptancePath.reportSurfaceReady))",
                "Dashboard panels ready: \(formatEvidenceFlag(workbenchBetaAcceptancePath.dashboardPanelsReady))",
                "Events trace ready: \(formatEvidenceFlag(workbenchBetaAcceptancePath.eventsTraceReady))",
                "Command surface: \(formatForbiddenFlag(workbenchBetaAcceptancePath.providesCommandSurface))",
                "Trading button: \(formatForbiddenFlag(workbenchBetaAcceptancePath.providesTradingButton))",
                "Live command: \(formatForbiddenFlag(workbenchBetaAcceptancePath.providesLiveCommand))"
            ],
            liveReadOnlyWorkbenchBoundaryMetrics: [
                DashboardShellMetric(
                    label: "Workbench boundary",
                    value: "\(liveReadOnlyWorkbenchBoundary.boundarySurfaceCount)"
                ),
                DashboardShellMetric(
                    label: "Forbidden UI",
                    value: "\(liveReadOnlyWorkbenchBoundary.forbiddenUISurfaceCount)"
                ),
                DashboardShellMetric(
                    label: "Handoff",
                    value: "\(liveReadOnlyWorkbenchBoundary.handoffTargetCount)"
                ),
                DashboardShellMetric(
                    label: "Boundary",
                    value: formatEvidenceFlag(liveReadOnlyWorkbenchBoundary.readModelOnlyBoundaryHeld)
                )
            ],
            liveReadOnlyWorkbenchBoundaryDetails: [
                "Workbench surfaces: \(joined(liveReadOnlyWorkbenchBoundary.boundarySurfaceLabels))",
                "Workbench inputs: \(joined(liveReadOnlyWorkbenchBoundary.inputBoundaryLabels))",
                "Forbidden UI: \(joined(liveReadOnlyWorkbenchBoundary.forbiddenUISurfaceLabels))",
                "Detail / audit routes: \(joined(liveReadOnlyWorkbenchBoundary.detailAuditRouteLabels))",
                "L3 handoff: \(joined(liveReadOnlyWorkbenchBoundary.handoffTargetLabels))",
                "Workbench source anchors: \(joined(liveReadOnlyWorkbenchBoundary.sourceAnchors))",
                "Workbench API key input: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.exposesAPIKeyInput))",
                "Workbench secret storage: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.storesSecret))",
                "Workbench broker connect: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.providesBrokerConnect))",
                "Workbench account connect: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.providesAccountConnect))",
                "Workbench Live PRO Console: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.exposesLivePROConsole))",
                "Workbench trading buttons: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.providesTradingButton))",
                "Workbench live command: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.providesLiveCommand))",
                "Workbench order form: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.exposesOrderForm))",
                "Workbench signed endpoint: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.callsSignedEndpoint))",
                "Workbench account endpoint: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.callsAccountEndpoint))",
                "Workbench listenKey: \(formatForbiddenFlag(liveReadOnlyWorkbenchBoundary.createsListenKey))",
                "Workbench boundary: \(formatEvidenceFlag(liveReadOnlyWorkbenchBoundary.readModelOnlyBoundaryHeld))"
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
            liveMonitoringEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Health",
                    value: liveMonitoringEvidence.runtimeHealthStatus.rawValue
                ),
                DashboardShellMetric(
                    label: "Connections",
                    value: "\(liveMonitoringEvidence.connectionCount)"
                ),
                DashboardShellMetric(
                    label: "Streams",
                    value: "\(liveMonitoringEvidence.streamEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Latency",
                    value: "\(liveMonitoringEvidence.latencyEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Errors",
                    value: "\(liveMonitoringEvidence.errorEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Degraded",
                    value: "\(liveMonitoringEvidence.degradedStateEvidenceCount)"
                )
            ],
            liveMonitoringEvidenceDetails: [
                "Monitoring health: \(liveMonitoringEvidence.runtimeHealthStatus.rawValue)",
                "Monitoring connections: \(joined(liveMonitoringEvidence.connectionStatusLabels))",
                "Monitoring streams: \(joined(liveMonitoringEvidence.streamKinds))",
                "Monitoring latency: \(joined(liveMonitoringEvidence.latencyBucketLabels))",
                "Monitoring errors: \(joined(liveMonitoringEvidence.errorCodes))",
                "Monitoring degraded states: \(joined(liveMonitoringEvidence.degradedStateStatusLabels))",
                "Monitoring command surface: \(formatForbiddenFlag(liveMonitoringEvidence.providesCommandSurface))",
                "Monitoring trading buttons: \(formatForbiddenFlag(liveMonitoringEvidence.providesTradingButton))",
                "Monitoring schema exposure: \(formatForbiddenFlag(liveMonitoringEvidence.exposesDatabaseSchema))",
                "Monitoring runtime exposure: \(formatForbiddenFlag(liveMonitoringEvidence.exposesRuntimeObject))",
                "Monitoring adapter exposure: \(formatForbiddenFlag(liveMonitoringEvidence.exposesAdapterSurface))",
                "Monitoring boundary: \(formatEvidenceFlag(liveMonitoringEvidence.readModelOnlyBoundaryHeld))"
            ],
            liveExecutionControlBlockedEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Execution gates",
                    value: "\(liveExecutionControlEvidence.blockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Reasons",
                    value: "\(liveExecutionControlEvidence.blockedReasonLabels.count)"
                ),
                DashboardShellMetric(
                    label: "Blocked",
                    value: formatEvidenceFlag(liveExecutionControlEvidence.allExecutionControlGatesBlocked)
                )
            ],
            liveExecutionControlBlockedEvidenceDetails: [
                "Execution gates: \(joined(liveExecutionControlEvidence.blockedGateLabels))",
                "Execution reasons: \(joined(liveExecutionControlEvidence.blockedReasonLabels))",
                "Execution source anchors: \(joined(liveExecutionControlEvidence.sourceAnchors))",
                "Execution command surface: \(formatForbiddenFlag(liveExecutionControlEvidence.providesCommandSurface))",
                "Execution order form: \(formatForbiddenFlag(liveExecutionControlEvidence.exposesOrderForm))",
                "Execution trading buttons: \(formatForbiddenFlag(liveExecutionControlEvidence.providesTradingButton))",
                "Execution schema exposure: \(formatForbiddenFlag(liveExecutionControlEvidence.exposesPersistenceSchema))",
                "Execution runtime exposure: \(formatForbiddenFlag(liveExecutionControlEvidence.invokesRuntimeControl))",
                "Execution adapter exposure: \(formatForbiddenFlag(liveExecutionControlEvidence.readsAdapter))",
                "Execution boundary: \(formatEvidenceFlag(liveExecutionControlEvidence.readModelOnlyBoundaryHeld))"
            ],
            liveRiskGateBlockedEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Risk gates",
                    value: "\(liveRiskGateEvidence.blockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Reasons",
                    value: "\(liveRiskGateEvidence.blockedReasonLabels.count)"
                ),
                DashboardShellMetric(
                    label: "Blocked",
                    value: formatEvidenceFlag(liveRiskGateEvidence.allRiskGatesBlocked)
                )
            ],
            liveRiskGateBlockedEvidenceDetails: [
                "Risk gates: \(joined(liveRiskGateEvidence.blockedGateLabels))",
                "Risk reasons: \(joined(liveRiskGateEvidence.blockedReasonLabels))",
                "Risk source anchors: \(joined(liveRiskGateEvidence.sourceAnchors))",
                "Risk command surface: \(formatForbiddenFlag(liveRiskGateEvidence.providesCommandSurface))",
                "Risk order form: \(formatForbiddenFlag(liveRiskGateEvidence.exposesOrderForm))",
                "Risk trading buttons: \(formatForbiddenFlag(liveRiskGateEvidence.providesTradingButton))",
                "Risk schema exposure: \(formatForbiddenFlag(liveRiskGateEvidence.exposesPersistenceSchema))",
                "Risk runtime exposure: \(formatForbiddenFlag(liveRiskGateEvidence.invokesRuntimeControl))",
                "Risk adapter exposure: \(formatForbiddenFlag(liveRiskGateEvidence.readsAdapter))",
                "Risk boundary: \(formatEvidenceFlag(liveRiskGateEvidence.readModelOnlyBoundaryHeld))"
            ],
            liveIncidentStopBlockedEvidenceMetrics: [
                DashboardShellMetric(
                    label: "Incident stop gates",
                    value: "\(liveIncidentStopEvidence.blockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Reasons",
                    value: "\(liveIncidentStopEvidence.blockedReasonLabels.count)"
                ),
                DashboardShellMetric(
                    label: "Blocked",
                    value: formatEvidenceFlag(liveIncidentStopEvidence.allIncidentStopGatesBlocked)
                )
            ],
            liveIncidentStopBlockedEvidenceDetails: [
                "Incident / stop gates: \(joined(liveIncidentStopEvidence.blockedGateLabels))",
                "Incident / stop reasons: \(joined(liveIncidentStopEvidence.blockedReasonLabels))",
                "Incident / stop source anchors: \(joined(liveIncidentStopEvidence.sourceAnchors))",
                "Incident replay runtime: \(formatForbiddenFlag(liveIncidentStopEvidence.providesIncidentReplay))",
                "Stop control: \(formatForbiddenFlag(liveIncidentStopEvidence.providesStopControl))",
                "Emergency stop: \(formatForbiddenFlag(liveIncidentStopEvidence.providesEmergencyStopCommand))",
                "Shutdown command: \(formatForbiddenFlag(liveIncidentStopEvidence.providesShutdownCommand))",
                "Restore command: \(formatForbiddenFlag(liveIncidentStopEvidence.providesRestoreCommand))",
                "Live PRO Console: \(formatForbiddenFlag(liveIncidentStopEvidence.exposesLiveProConsole))",
                "Stop button: \(formatForbiddenFlag(liveIncidentStopEvidence.providesStopButton))",
                "Trading buttons: \(formatForbiddenFlag(liveIncidentStopEvidence.providesTradingButton))",
                "Incident / stop schema exposure: \(formatForbiddenFlag(liveIncidentStopEvidence.exposesPersistenceSchema))",
                "Incident / stop runtime exposure: \(formatForbiddenFlag(liveIncidentStopEvidence.invokesRuntimeControl))",
                "Incident / stop adapter exposure: \(formatForbiddenFlag(liveIncidentStopEvidence.readsAdapter))",
                "Incident / stop boundary: \(formatEvidenceFlag(liveIncidentStopEvidence.readModelOnlyBoundaryHeld))"
            ],
            timelinePreview: explorer.timelineItems.prefix(5).map {
                "\($0.title): \($0.summary)"
            },
            paperOnlyBoundaryHeld: observability.paperOnlyBoundaryHeld,
            providesCommandSurface: explorer.providesCommandSurface
                || scenarioReplayEvidence.providesCommandSurface
                || simulatedExchangeParityEvidence.providesCommandSurface
                || accountPositionBalanceSurface.providesCommandSurface
                || privateStreamSimulationGateSurface.providesCommandSurface
                || liveMonitoringReadOnlyConsoleV2Surface.providesCommandSurface
                || workbenchBetaFirstRun.providesCommandSurface
                || workbenchBetaAcceptancePath.providesCommandSurface
                || liveReadOnlyWorkbenchBoundary.providesCommandSurface
                || liveMonitoringEvidence.providesCommandSurface
                || liveExecutionControlEvidence.providesCommandSurface
                || liveRiskGateEvidence.providesCommandSurface
                || liveIncidentStopEvidence.providesCommandSurface,
            providesOrderLevelCommand: observability.providesOrderLevelCommand
                || explorer.providesOrderLevelCommand
                || scenarioReplayEvidence.providesOrderLevelCommand
                || simulatedExchangeParityEvidence.providesOrderLevelCommand
                || accountPositionBalanceSurface.providesOrderLevelCommand
                || privateStreamSimulationGateSurface.providesOrderLevelCommand
                || liveMonitoringReadOnlyConsoleV2Surface.providesOrderLevelCommand
                || workbenchBetaFirstRun.providesOrderLevelCommand
                || workbenchBetaAcceptancePath.providesOrderLevelCommand
                || liveBlockedEvidence.providesOrderLevelCommand
                || liveMonitoringEvidence.providesOrderLevelCommand
                || liveExecutionControlEvidence.providesOrderLevelCommand
                || liveReadOnlyWorkbenchBoundary.submitsRealOrder
                || liveReadOnlyWorkbenchBoundary.cancelsRealOrder
                || liveReadOnlyWorkbenchBoundary.replacesRealOrder
                || sessionControls.contains { $0.authorizesOrderLevelCommand },
            exposesDatabaseSchema: observability.exposesDatabaseSchema
                || explorer.exposesDatabaseSchema
                || scenarioReplayEvidence.exposesDatabaseSchema
                || simulatedExchangeParityEvidence.exposesDatabaseSchema
                || accountPositionBalanceSurface.exposesDatabaseSchema
                || privateStreamSimulationGateSurface.exposesDatabaseSchema
                || liveMonitoringReadOnlyConsoleV2Surface.exposesDatabaseSchema
                || workbenchBetaFirstRun.exposesDatabaseSchema
                || workbenchBetaAcceptancePath.exposesDatabaseSchema
                || liveBlockedEvidence.exposesDatabaseSchema
                || liveMonitoringEvidence.exposesDatabaseSchema
                || liveReadOnlyWorkbenchBoundary.exposesDatabaseSchema
                || liveExecutionControlEvidence.exposesPersistenceSchema
                || liveRiskGateEvidence.exposesPersistenceSchema
                || liveIncidentStopEvidence.exposesPersistenceSchema,
            exposesRuntimeObject: observability.exposesRuntimeObject
                || explorer.exposesRuntimeObject
                || scenarioReplayEvidence.exposesRuntimeObject
                || simulatedExchangeParityEvidence.exposesRuntimeObject
                || accountPositionBalanceSurface.exposesRuntimeObject
                || privateStreamSimulationGateSurface.exposesRuntimeObject
                || liveMonitoringReadOnlyConsoleV2Surface.exposesRuntimeObject
                || workbenchBetaFirstRun.exposesRuntimeObject
                || workbenchBetaAcceptancePath.exposesRuntimeObject
                || liveBlockedEvidence.exposesRuntimeObject
                || liveMonitoringEvidence.exposesRuntimeObject
                || liveReadOnlyWorkbenchBoundary.exposesRuntimeObject
                || liveExecutionControlEvidence.invokesRuntimeControl
                || liveRiskGateEvidence.invokesRuntimeControl
                || liveIncidentStopEvidence.invokesRuntimeControl,
            exposesAdapterRequest: observability.exposesAdapterRequest
                || explorer.exposesAdapterRequest
                || scenarioReplayEvidence.exposesAdapterRequest
                || simulatedExchangeParityEvidence.exposesAdapterRequest
                || accountPositionBalanceSurface.exposesAdapterRequest
                || privateStreamSimulationGateSurface.exposesAdapterRequest
                || liveMonitoringReadOnlyConsoleV2Surface.exposesAdapterRequest
                || workbenchBetaFirstRun.exposesAdapterRequest
                || workbenchBetaAcceptancePath.exposesAdapterRequest
                || liveBlockedEvidence.exposesAdapterSurface
                || liveMonitoringEvidence.exposesAdapterSurface
                || liveReadOnlyWorkbenchBoundary.exposesAdapterSurface
                || liveExecutionControlEvidence.readsAdapter
                || liveRiskGateEvidence.readsAdapter
                || liveIncidentStopEvidence.readsAdapter,
            authorizesLiveTrading: observability.authorizesLiveTrading
                || explorer.authorizesLiveTrading
                || scenarioReplayEvidence.authorizesLiveTrading
                || simulatedExchangeParityEvidence.authorizesLiveTrading
                || accountPositionBalanceSurface.authorizesLiveTrading
                || privateStreamSimulationGateSurface.authorizesLiveTrading
                || liveMonitoringReadOnlyConsoleV2Surface.authorizesLiveTrading
                || workbenchBetaFirstRun.authorizesLiveTrading
                || workbenchBetaAcceptancePath.authorizesLiveTrading
                || liveBlockedEvidence.authorizesLiveTrading
                || liveMonitoringEvidence.authorizesLiveTrading
                || liveReadOnlyWorkbenchBoundary.authorizesLiveTrading
                || liveExecutionControlEvidence.authorizesLiveTrading
                || liveRiskGateEvidence.authorizesLiveTrading
                || liveIncidentStopEvidence.authorizesLiveTrading,
            touchesBrokerAction: observability.touchesBrokerAction
                || explorer.touchesBrokerAction
                || scenarioReplayEvidence.touchesBrokerAction
                || simulatedExchangeParityEvidence.touchesBrokerAction
                || accountPositionBalanceSurface.connectsBroker
                || privateStreamSimulationGateSurface.connectsBroker
                || liveMonitoringReadOnlyConsoleV2Surface.connectsBroker
                || workbenchBetaFirstRun.touchesBrokerAction
                || workbenchBetaAcceptancePath.touchesBrokerAction
                || liveBlockedEvidence.touchesBrokerAction
                || liveMonitoringEvidence.instantiatesBrokerAdapter
                || liveReadOnlyWorkbenchBoundary.instantiatesBrokerAdapter
                || liveExecutionControlEvidence.instantiatesBrokerExecutionAdapter
                || liveExecutionControlEvidence.instantiatesExchangeExecutionAdapter
                || liveRiskGateEvidence.instantiatesBrokerExecutionAdapter
                || liveRiskGateEvidence.instantiatesExchangeExecutionAdapter
                || liveIncidentStopEvidence.executesBrokerAction,
            authorizesTradingExecution: observability.authorizesTradingExecution
                || explorer.authorizesTradingExecution
                || scenarioReplayEvidence.authorizesTradingExecution
                || simulatedExchangeParityEvidence.authorizesTradingExecution
                || accountPositionBalanceSurface.authorizesTradingExecution
                || privateStreamSimulationGateSurface.authorizesTradingExecution
                || liveMonitoringReadOnlyConsoleV2Surface.authorizesTradingExecution
                || workbenchBetaFirstRun.authorizesTradingExecution
                || workbenchBetaAcceptancePath.authorizesTradingExecution
                || liveBlockedEvidence.authorizesTradingExecution
                || liveMonitoringEvidence.authorizesTradingExecution
                || liveReadOnlyWorkbenchBoundary.authorizesTradingExecution
                || liveExecutionControlEvidence.authorizesTradingExecution
                || liveRiskGateEvidence.authorizesTradingExecution
                || liveIncidentStopEvidence.authorizesTradingExecution,
            accountPositionBalanceReadModelOnlySurfaceBoundaryHeld: accountPositionBalanceSurface
                .readModelOnlyBoundaryHeld,
            privateStreamSimulationGateEvidenceSurfaceBoundaryHeld: privateStreamSimulationGateSurface
                .readModelOnlyBoundaryHeld,
            liveMonitoringReadOnlyConsoleV2SurfaceBoundaryHeld: liveMonitoringReadOnlyConsoleV2Surface
                .readModelOnlyBoundaryHeld,
            workbenchBetaFirstRunReadModelOnlyBoundaryHeld: workbenchBetaFirstRun
                .readModelOnlyBoundaryHeld,
            workbenchBetaAcceptancePathReadModelOnlyBoundaryHeld: workbenchBetaAcceptancePath
                .readModelOnlyBoundaryHeld,
            liveReadOnlyWorkbenchBoundaryReadModelOnlyBoundaryHeld: liveReadOnlyWorkbenchBoundary
                .readModelOnlyBoundaryHeld
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
                DashboardShellMetric(
                    label: "Lifecycle transitions",
                    value: "\(viewModel.paperExecutionWorkflowLocalLifecycleTransitionIDs.count)"
                ),
                DashboardShellMetric(label: "Paper accounts", value: "\(viewModel.paperAccountIDs.count)"),
                DashboardShellMetric(label: "Positions", value: "\(viewModel.paperPositionCount)"),
                DashboardShellMetric(label: "Paper PnL", value: format(viewModel.paperNetPnL)),
                DashboardShellMetric(
                    label: "Fill cost",
                    value: format(viewModel.paperExecutionWorkflowSimulatedFillCostImpactAmount)
                ),
                DashboardShellMetric(label: "Replay ops", value: "\(viewModel.marketDataReplayEvidenceCount)"),
                DashboardShellMetric(label: "Scenario replay", value: "\(viewModel.scenarioReplayEvidenceCount)"),
                DashboardShellMetric(
                    label: "Scenario gates",
                    value: "\(viewModel.scenarioReplayQualityGateTimelineCount)"
                ),
                DashboardShellMetric(
                    label: "Sim parity",
                    value: "\(viewModel.simulatedExchangeParityEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "APB surface",
                    value: "\(viewModel.accountPositionBalanceReadModelOnlySurface.recordCount)"
                ),
                DashboardShellMetric(
                    label: "Simulation gate",
                    value: "\(viewModel.privateStreamSimulationGateEvidenceSurface.freshnessEvidenceCount)"
                ),
                DashboardShellMetric(
                    label: "Live monitoring v2",
                    value: "\(viewModel.liveMonitoringReadOnlyConsoleV2Surface.eventTraceItemCount)"
                ),
                DashboardShellMetric(label: "Live gates", value: "\(viewModel.liveBlockedEvidenceCount)"),
                DashboardShellMetric(
                    label: "Execution control",
                    value: "\(viewModel.liveExecutionControlBlockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Live risk",
                    value: "\(viewModel.liveRiskGateBlockedEvidence.blockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Incident stop",
                    value: "\(viewModel.liveIncidentStopBlockedEvidence.blockedGateCount)"
                ),
                DashboardShellMetric(
                    label: "Workbench boundary",
                    value: "\(viewModel.liveReadOnlyWorkbenchBoundary.boundarySurfaceCount)"
                ),
                DashboardShellMetric(
                    label: "Monitoring",
                    value: "\(viewModel.liveMonitoringStreamEvidenceCount)"
                )
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
                "Lifecycle transitions: \(joined(viewModel.paperExecutionWorkflowLocalLifecycleTransitionIDs))",
                "Simulated fills: \(joined(viewModel.paperExecutionWorkflowSimulatedFillIDs))",
                "Account portfolio snapshots: \(joined(viewModel.paperExecutionWorkflowAccountPortfolioSnapshotIDs))",
                "Paper accounts: \(joined(viewModel.paperAccountIDs))",
                "Paper positions: \(viewModel.paperPositionCount)",
                "Paper PnL: \(format(viewModel.paperNetPnL))",
                "Simulated fill gross notional: \(format(viewModel.paperExecutionWorkflowSimulatedFillGrossNotional))",
                "Simulated fill fee: \(format(viewModel.paperExecutionWorkflowSimulatedFillFeeAmount))",
                "Simulated fill slippage: \(format(viewModel.paperExecutionWorkflowSimulatedFillSlippageAmount))",
                "Simulated fill cost impact: \(format(viewModel.paperExecutionWorkflowSimulatedFillCostImpactAmount))",
                "Execution workflow streams: \(joined(viewModel.paperExecutionWorkflowStreams))",
                "Execution workflow lifecycle: \(formatEvidenceFlag(viewModel.paperExecutionWorkflowCoversLocalLifecycleEvents))",
                "Execution workflow chain: \(formatEvidenceFlag(viewModel.paperExecutionWorkflowCoversDecisionOrderFillChain))",
                "Execution workflow portfolio projection: \(formatEvidenceFlag(viewModel.paperExecutionWorkflowProjectsPortfolioFromSimulatedFill))",
                "Execution workflow boundary: \(formatRuntimeBoundary(viewModel.paperExecutionWorkflowPaperOnlyBoundaryHeld))",
                "Replay operation batches: \(joined(viewModel.marketDataReplayBatchIDs))",
                "Replay operation runs: \(joined(viewModel.marketDataReplayRunIDs))",
                "Replay operation freshness: \(joined(viewModel.marketDataReplayFreshnessStatuses))",
                "Replay operation retention: \(joined(viewModel.marketDataReplayRetentionStatuses.map(\.rawValue)))",
                "Replay operation projections: \(joined(viewModel.marketDataReplayProjectionConsistencySummaries))",
                "Replay operation boundary: \(formatEvidenceFlag(viewModel.marketDataReplayReadModelOnlyBoundaryHeld))",
                "Scenario replay ids: \(joined(viewModel.scenarioReplayScenarioIDs))",
                "Scenario replay dataset versions: \(joined(viewModel.scenarioReplayDatasetVersions))",
                "Scenario replay fixture versions: \(joined(viewModel.scenarioReplayFixtureVersions))",
                "Scenario replay windows: \(joined(viewModel.scenarioReplayWindows))",
                "Scenario replay checksums: \(joined(viewModel.scenarioReplayChecksums))",
                "Scenario replay freshness: \(joined(viewModel.scenarioReplayFreshnessStatuses.map(\.rawValue)))",
                "Scenario replay quality: \(joined(viewModel.scenarioReplayQualityVerdicts.map(\.rawValue)))",
                "Scenario replay report inputs: \(joined(viewModel.scenarioReplayReportInputVersionIdentities))",
                "Scenario replay drill-down: \(joined(viewModel.scenarioReplayDrillDownEntries))",
                "Scenario replay boundary: \(formatEvidenceFlag(viewModel.scenarioReplayReadModelOnlyBoundaryHeld))",
                "Scenario replay command surface: \(formatForbiddenFlag(viewModel.scenarioReplayProvidesCommandSurface))",
                "Scenario replay query language: \(formatForbiddenFlag(viewModel.scenarioReplaySupportsQueryLanguage))",
                "Simulated parity scenarios: \(joined(viewModel.simulatedExchangeParityScenarioIDs))",
                "Simulated parity datasets: \(joined(viewModel.simulatedExchangeParityDatasetVersions))",
                "Simulated parity fixtures: \(joined(viewModel.simulatedExchangeParityFixtureVersions))",
                "Simulated parity windows: \(joined(viewModel.simulatedExchangeParityReplayWindows))",
                "Simulated parity matching: \(joined(viewModel.simulatedExchangeParityMatchingResults))",
                "Simulated parity orders: \(joined(viewModel.simulatedExchangeParityOrderIDs))",
                "Simulated parity outcomes: \(joined(viewModel.simulatedExchangeParityOutcomeLabels))",
                "Simulated parity report inputs: \(joined(viewModel.simulatedExchangeParityReportInputVersionIdentities))",
                "Simulated parity replay sequences: \(joined(viewModel.simulatedExchangeParitySourceReplaySequences.map(String.init)))",
                "Simulated parity portfolio: \(formatEvidenceFlag(viewModel.simulatedExchangeParityProjectionParityHeld))",
                "Simulated parity cost: \(formatEvidenceFlag(viewModel.simulatedExchangeParityCostParityConsistent))",
                "Simulated parity boundary: \(formatEvidenceFlag(viewModel.simulatedExchangeParityReadModelOnlyBoundaryHeld))",
                "Simulated parity command surface: \(formatForbiddenFlag(viewModel.simulatedExchangeParityProvidesCommandSurface))",
                "Simulated parity order command: \(formatForbiddenFlag(viewModel.simulatedExchangeParityProvidesOrderLevelCommand))",
                "Simulated parity trading buttons: \(formatForbiddenFlag(viewModel.simulatedExchangeParityProvidesTradingButton))",
                "Simulated parity schema exposure: \(formatForbiddenFlag(viewModel.simulatedExchangeParityExposesDatabaseSchema))",
                "Simulated parity runtime exposure: \(formatForbiddenFlag(viewModel.simulatedExchangeParityExposesRuntimeObject))",
                "Simulated parity adapter exposure: \(formatForbiddenFlag(viewModel.simulatedExchangeParityExposesAdapterRequest))",
                "APB surface summary: \(viewModel.accountPositionBalanceReadModelOnlySurface.reportSummary)",
                "APB surface components: \(joined(viewModel.accountPositionBalanceReadModelOnlySurface.componentLabels))",
                "APB surface evidence: \(joined(viewModel.accountPositionBalanceReadModelOnlySurface.evidenceIDs))",
                "APB surface freshness: \(joined(viewModel.accountPositionBalanceReadModelOnlySurface.freshnessStatuses.map(\.rawValue)))",
                "APB surface blocked states: \(joined(viewModel.accountPositionBalanceReadModelOnlySurface.blockedStateLabels))",
                "APB surface command surface: \(formatForbiddenFlag(viewModel.accountPositionBalanceReadModelOnlySurface.providesCommandSurface))",
                "APB surface trading button: \(formatForbiddenFlag(viewModel.accountPositionBalanceReadModelOnlySurface.providesTradingButton))",
                "APB surface live command: \(formatForbiddenFlag(viewModel.accountPositionBalanceReadModelOnlySurface.providesLiveCommand))",
                "APB surface account connect: \(formatForbiddenFlag(viewModel.accountPositionBalanceReadModelOnlySurface.providesAccountConnect))",
                "APB surface broker connect: \(formatForbiddenFlag(viewModel.accountPositionBalanceReadModelOnlySurface.providesBrokerConnect))",
                "APB surface boundary: \(formatEvidenceFlag(viewModel.accountPositionBalanceReadModelOnlySurface.readModelOnlyBoundaryHeld))",
                "Simulation gate summary: \(viewModel.privateStreamSimulationGateEvidenceSurface.reportSummary)",
                "Simulation gate source identities: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.sourceIdentities))",
                "Simulation gate snapshot inputs: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.snapshotInputIDs))",
                "Simulation gate update fixtures: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.updateFixtureIDs))",
                "Simulation gate freshness: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.freshnessStatuses.map(\.rawValue)))",
                "Simulation gate boundary reasons: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.boundaryReasonCodes))",
                "Simulation gate event trace: \(joined(viewModel.privateStreamSimulationGateEvidenceSurface.eventTraceItems.map(\.title)))",
                "Simulation gate command surface: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.providesCommandSurface))",
                "Simulation gate trading button: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.providesTradingButton))",
                "Simulation gate live command: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.providesLiveCommand))",
                "Simulation gate account connect: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.providesAccountConnect))",
                "Simulation gate broker connect: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.providesBrokerConnect))",
                "Simulation gate runtime object: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.exposesRuntimeObject))",
                "Simulation gate adapter request: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.exposesAdapterRequest))",
                "Simulation gate database schema: \(formatForbiddenFlag(viewModel.privateStreamSimulationGateEvidenceSurface.exposesDatabaseSchema))",
                "Simulation gate boundary: \(formatEvidenceFlag(viewModel.privateStreamSimulationGateEvidenceSurface.readModelOnlyBoundaryHeld))",
                "Live Monitoring v2 summary: \(viewModel.liveMonitoringReadOnlyConsoleV2Surface.reportSummary)",
                "Live Monitoring v2 source identities: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.sourceIdentities))",
                "Live Monitoring v2 health: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.healthStatusLabels))",
                "Live Monitoring v2 readiness: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.readinessStateLabels))",
                "Live Monitoring v2 blocked explanations: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.blockedExplanationIDs))",
                "Live Monitoring v2 stale explanations: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.staleExplanationIDs))",
                "Live Monitoring v2 missing explanations: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.missingExplanationIDs))",
                "Live Monitoring v2 forbidden tests: \(viewModel.liveMonitoringReadOnlyConsoleV2Surface.forbiddenTestCaseCount)",
                "Live Monitoring v2 event trace: \(joined(viewModel.liveMonitoringReadOnlyConsoleV2Surface.eventTraceItems.map(\.title)))",
                "Live Monitoring v2 command surface: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.providesCommandSurface))",
                "Live Monitoring v2 trading button: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.providesTradingButton))",
                "Live Monitoring v2 live command: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.providesLiveCommand))",
                "Live Monitoring v2 order form: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesOrderForm))",
                "Live Monitoring v2 runtime object: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesRuntimeObject))",
                "Live Monitoring v2 adapter request: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesAdapterRequest))",
                "Live Monitoring v2 database schema: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesDatabaseSchema))",
                "Live Monitoring v2 account payload: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesAccountPayload))",
                "Live Monitoring v2 broker state: \(formatForbiddenFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.exposesBrokerState))",
                "Live Monitoring v2 boundary: \(formatEvidenceFlag(viewModel.liveMonitoringReadOnlyConsoleV2Surface.readModelOnlyBoundaryHeld))",
                "Live readiness: \(viewModel.liveReadinessStatus.rawValue)",
                "Live blocked capabilities: \(joined(viewModel.liveBlockedCapabilityLabels))",
                "Live gates: \(joined(viewModel.liveBlockedGateLabels))",
                "Live source anchors: \(joined(viewModel.liveBlockedSourceAnchors))",
                "Live blocked boundary: \(formatEvidenceFlag(viewModel.liveReadinessReadModelOnlyBoundaryHeld))",
                "Live command surface: \(formatForbiddenFlag(viewModel.liveReadinessProvidesCommandSurface))",
                "Live trading authorization: \(formatForbiddenFlag(viewModel.liveReadinessAuthorizesLiveTrading))",
                "Execution control gates: \(joined(viewModel.liveExecutionControlBlockedGateLabels))",
                "Execution control reasons: \(joined(viewModel.liveExecutionControlBlockedReasonLabels))",
                "Execution control boundary: \(formatEvidenceFlag(viewModel.liveExecutionControlReadModelOnlyBoundaryHeld))",
                "Execution control command surface: \(formatForbiddenFlag(viewModel.liveExecutionControlProvidesCommandSurface))",
                "Execution control order form: \(formatForbiddenFlag(viewModel.liveExecutionControlExposesOrderForm))",
                "Execution control trading buttons: \(formatForbiddenFlag(viewModel.liveExecutionControlProvidesTradingButton))",
                "Execution control schema exposure: \(formatForbiddenFlag(viewModel.liveExecutionControlExposesPersistenceSchema))",
                "Execution control runtime exposure: \(formatForbiddenFlag(viewModel.liveExecutionControlInvokesRuntimeControl))",
                "Execution control adapter exposure: \(formatForbiddenFlag(viewModel.liveExecutionControlReadsAdapter))",
                "Live risk gates: \(joined(viewModel.liveRiskGateBlockedEvidence.blockedGateLabels))",
                "Live risk reasons: \(joined(viewModel.liveRiskGateBlockedEvidence.blockedReasonLabels))",
                "Live risk boundary: \(formatEvidenceFlag(viewModel.liveRiskGateBlockedEvidence.readModelOnlyBoundaryHeld))",
                "Live risk command surface: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.providesCommandSurface))",
                "Live risk order form: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.exposesOrderForm))",
                "Live risk trading buttons: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.providesTradingButton))",
                "Live risk schema exposure: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.exposesPersistenceSchema))",
                "Live risk runtime exposure: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.invokesRuntimeControl))",
                "Live risk adapter exposure: \(formatForbiddenFlag(viewModel.liveRiskGateBlockedEvidence.readsAdapter))",
                "Incident / stop gates: \(joined(viewModel.liveIncidentStopBlockedEvidence.blockedGateLabels))",
                "Incident / stop reasons: \(joined(viewModel.liveIncidentStopBlockedEvidence.blockedReasonLabels))",
                "Incident / stop boundary: \(formatEvidenceFlag(viewModel.liveIncidentStopBlockedEvidence.readModelOnlyBoundaryHeld))",
                "Incident replay runtime: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.providesIncidentReplay))",
                "Stop control: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.providesStopControl))",
                "Stop button: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.providesStopButton))",
                "Live PRO Console: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.exposesLiveProConsole))",
                "Incident / stop schema exposure: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.exposesPersistenceSchema))",
                "Incident / stop runtime exposure: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.invokesRuntimeControl))",
                "Incident / stop adapter exposure: \(formatForbiddenFlag(viewModel.liveIncidentStopBlockedEvidence.readsAdapter))",
                "Workbench Live readiness boundary: \(formatEvidenceFlag(viewModel.liveReadOnlyWorkbenchBoundary.readModelOnlyBoundaryHeld))",
                "Workbench Live readiness surfaces: \(joined(viewModel.liveReadOnlyWorkbenchBoundary.boundarySurfaceLabels))",
                "Workbench Live readiness inputs: \(joined(viewModel.liveReadOnlyWorkbenchBoundary.inputBoundaryLabels))",
                "Workbench Live readiness forbidden UI: \(joined(viewModel.liveReadOnlyWorkbenchBoundary.forbiddenUISurfaceLabels))",
                "Workbench detail / audit routes: \(joined(viewModel.liveReadOnlyWorkbenchBoundary.detailAuditRouteLabels))",
                "Workbench L3 handoff: \(joined(viewModel.liveReadOnlyWorkbenchBoundary.handoffTargetLabels))",
                "Workbench API key input: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.exposesAPIKeyInput))",
                "Workbench broker connect: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.providesBrokerConnect))",
                "Workbench account connect: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.providesAccountConnect))",
                "Workbench Live PRO Console: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.exposesLivePROConsole))",
                "Workbench trading buttons: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.providesTradingButton))",
                "Workbench live command: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.providesLiveCommand))",
                "Workbench order form: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.exposesOrderForm))",
                "Workbench signed endpoint: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.callsSignedEndpoint))",
                "Workbench account endpoint: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.callsAccountEndpoint))",
                "Workbench listenKey: \(formatForbiddenFlag(viewModel.liveReadOnlyWorkbenchBoundary.createsListenKey))",
                "Monitoring health: \(viewModel.liveMonitoringHealthStatus.rawValue)",
                "Monitoring connections: \(joined(viewModel.liveMonitoringConnectionStatusLabels))",
                "Monitoring streams: \(viewModel.liveMonitoringStreamEvidenceCount)",
                "Monitoring market streams: \(viewModel.liveMonitoringMarketStreamEvidenceCount)",
                "Monitoring order streams: \(viewModel.liveMonitoringOrderStreamEvidenceCount)",
                "Monitoring latency buckets: \(joined(viewModel.liveMonitoringLatencyBucketLabels))",
                "Monitoring errors: \(joined(viewModel.liveMonitoringErrorCodes))",
                "Monitoring degraded states: \(joined(viewModel.liveMonitoringDegradedStateStatusLabels))",
                "Monitoring boundary: \(formatEvidenceFlag(viewModel.liveMonitoringReadModelOnlyBoundaryHeld))",
                "Monitoring command surface: \(formatForbiddenFlag(viewModel.liveMonitoringProvidesCommandSurface))",
                "Monitoring trading buttons: \(formatForbiddenFlag(viewModel.liveMonitoringProvidesTradingButton))",
                "Monitoring schema exposure: \(formatForbiddenFlag(viewModel.liveMonitoringExposesDatabaseSchema))",
                "Monitoring runtime exposure: \(formatForbiddenFlag(viewModel.liveMonitoringExposesRuntimeObject))",
                "Monitoring adapter exposure: \(formatForbiddenFlag(viewModel.liveMonitoringExposesAdapterSurface))",
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
                DashboardShellMetric(label: "Positions", value: "\(viewModel.paperPositionCount)"),
                DashboardShellMetric(label: "Paper PnL", value: format(viewModel.totalNetPaperPnL)),
                DashboardShellMetric(label: "Gross exposure", value: format(viewModel.totalGrossExposureNotional))
            ],
            details: [
                "Portfolio IDs: \(joined(viewModel.portfolioIDs))",
                "Paper accounts: \(joined(viewModel.paperAccounts.map(\.accountID)))",
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

    /// Workbench beta first-run 默认 read model 是 MTP-121 的本地 demo 启动快照。
    ///
    /// 该快照只把 MTP-120 选定的 deterministic fixture evidence 注入 Report 和 first-run
    /// read model，保留空 Market / Paper / Risk / Portfolio facts；它不启动 replay job、不读取
    /// Runtime object、不访问 database schema、不调用 Adapter，也不形成 Live PRO Console、
    /// live command、交易按钮或真实交易入口。
    static var defaultWorkbenchBetaDemo: DashboardReadModel {
        DashboardReadModel(
            market: MarketReadModel(),
            strategy: StrategyReadModel(),
            backtest: BacktestReadModel(),
            report: ReportReadModel(
                scenarioReplayEvidence: .deterministicFixture,
                simulatedExchangeParityEvidence: .deterministicFixture
            ),
            workbenchBetaFirstRun: .defaultDemoState,
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

    /// MTP-121 Dashboard 启动默认 ViewModel snapshot。
    ///
    /// DashboardApplication 使用该 snapshot 让 operator 启动后直接看到 local beta evidence；
    /// 数据仍来自 App read model，不暴露 Core fixture、Persistence schema、Runtime object、
    /// Adapter request、broker action、live command 或交易按钮。
    static var defaultWorkbenchBetaDemo: DashboardViewModel {
        DashboardViewModel(readModel: .defaultWorkbenchBetaDemo)
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
                    title: "First Run",
                    systemImage: "sparkle.magnifyingglass",
                    metrics: workbench.workbenchBetaFirstRunMetrics,
                    details: workbench.workbenchBetaFirstRunDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Beta Acceptance",
                    systemImage: "checkmark.seal",
                    metrics: workbench.workbenchBetaAcceptancePathMetrics,
                    details: workbench.workbenchBetaAcceptancePathDetails
                )
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
                    title: "Simulated Exchange Parity",
                    systemImage: "equal.square",
                    metrics: workbench.simulatedExchangeParityEvidenceMetrics,
                    details: workbench.simulatedExchangeParityEvidenceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Account Position Balance",
                    systemImage: "rectangle.stack.badge.person.crop",
                    metrics: workbench.accountPositionBalanceReadModelOnlySurfaceMetrics,
                    details: workbench.accountPositionBalanceReadModelOnlySurfaceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Read-only Workbench",
                    systemImage: "rectangle.and.text.magnifyingglass",
                    metrics: workbench.liveReadOnlyWorkbenchBoundaryMetrics,
                    details: workbench.liveReadOnlyWorkbenchBoundaryDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Blocked Gates",
                    systemImage: "lock.shield",
                    metrics: workbench.liveBlockedEvidenceMetrics,
                    details: workbench.liveBlockedEvidenceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Monitoring",
                    systemImage: "waveform.path.ecg",
                    metrics: workbench.liveMonitoringEvidenceMetrics,
                    details: workbench.liveMonitoringEvidenceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Execution Control",
                    systemImage: "lock.rectangle.stack",
                    metrics: workbench.liveExecutionControlBlockedEvidenceMetrics,
                    details: workbench.liveExecutionControlBlockedEvidenceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Risk Gates",
                    systemImage: "exclamationmark.shield",
                    metrics: workbench.liveRiskGateBlockedEvidenceMetrics,
                    details: workbench.liveRiskGateBlockedEvidenceDetails
                )
                DashboardWorkbenchDetailGroup(
                    title: "Live Incident / Stop",
                    systemImage: "hand.raised.square",
                    metrics: workbench.liveIncidentStopBlockedEvidenceMetrics,
                    details: workbench.liveIncidentStopBlockedEvidenceDetails
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
