import Core
import Foundation

/// DashboardBetaFirstRunStateKind 定义 Dashboard 启动时可展示的只读状态集合。
///
/// MTP-121 只允许这些状态作为 App 层 Read Model / ViewModel evidence 进入 Dashboard。
/// 它们不代表 Runtime state machine，不读取数据库 schema，不创建 command surface，也不授权
/// signed endpoint、account endpoint、broker、Live PRO Console、live command 或交易按钮。
public enum DashboardBetaFirstRunStateKind: String, Codable, CaseIterable, Sendable {
    case defaultDemo = "default demo"
    case empty = "empty"
    case loading = "loading"
    case error = "error"
}

/// DashboardBetaFirstRunFallbackState 是 MTP-121 的 empty / loading / error fallback 行。
///
/// Fallback 只给 Dashboard 解释当前 first-run read model 的展示状态；它不携带重试命令、
/// 网络下载命令、Runtime object、adapter request、broker action 或真实交易授权。
public struct DashboardBetaFirstRunFallbackState: Codable, Equatable, Sendable {
    public let state: DashboardBetaFirstRunStateKind
    public let label: String
    public let summary: String
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let authorizesTradingExecution: Bool

    public init(
        state: DashboardBetaFirstRunStateKind,
        label: String,
        summary: String,
        readModelOnlyBoundaryHeld: Bool = true,
        exposesDatabaseSchema: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesAdapterRequest: Bool = false,
        providesCommandSurface: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.state = state
        self.label = label
        self.summary = summary
        self.readModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesCommandSurface = providesCommandSurface
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var boundaryHeld: Bool {
        readModelOnlyBoundaryHeld
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && providesCommandSurface == false
            && authorizesTradingExecution == false
    }
}

/// DashboardBetaFirstRunEvidenceSummary 是 Dashboard first-run 默认 demo 的只读证据摘要。
///
/// Summary 只复制 MTP-120 `DashboardBetaDemoFixtureEvidence` 的稳定字段：selected scenario、
/// dataset / fixture version、checksum / freshness / quality、report input version 和 L1.5 / L2
/// relationship。它不执行 replay、不读取 Persistence schema、不调用 Adapter、不启动 Runtime，
/// 也不把 simulated parity 或 paper evidence 升级为真实订单、broker fill 或交易入口。
public struct DashboardBetaFirstRunEvidenceSummary: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let scenarioID: String
    public let datasetVersion: String
    public let fixtureVersion: String
    public let symbol: String
    public let timeframe: String
    public let checksum: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let qualityVerdict: ScenarioDataQualityVerdict
    public let reportInputVersionIdentity: String
    public let simulatedParityEvidenceIdentity: String
    public let deterministicDemoIdentity: String
    public let relationshipSummary: String
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let scenarioReplayWiringHeld: Bool
    public let simulatedParityWiringHeld: Bool
    public let localDeterministicFixtureOnly: Bool
    public let readModelOnlyHandoff: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let runsLiveRuntime: Bool
    public let providesCommandSurface: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(fixture: DashboardBetaDemoFixtureEvidence = .deterministicFixture) {
        self.evidenceID = fixture.evidenceID.rawValue
        self.scenarioID = fixture.selection.scenarioID.rawValue
        self.datasetVersion = fixture.selection.datasetVersion.rawValue
        self.fixtureVersion = fixture.selection.fixtureVersion.rawValue
        self.symbol = fixture.selection.symbol.rawValue
        self.timeframe = fixture.selection.timeframe.rawValue
        self.checksum = fixture.checksum
        self.freshnessStatus = fixture.freshnessStatus
        self.qualityVerdict = fixture.qualityVerdict
        self.reportInputVersionIdentity = fixture.reportInputVersionIdentity
        self.simulatedParityEvidenceIdentity = fixture.simulatedParityEvidenceIdentity
        self.deterministicDemoIdentity = fixture.deterministicDemoIdentity
        self.relationshipSummary = fixture.relationshipSummary
        self.sourceAnchors = fixture.selection.sourceAnchors
        self.validationAnchors = Self.validationAnchors
        self.scenarioReplayWiringHeld = fixture.scenarioReplayWiringHeld
        self.simulatedParityWiringHeld = fixture.simulatedParityWiringHeld
        self.localDeterministicFixtureOnly = fixture.localDeterministicFixtureOnly
        self.readModelOnlyHandoff = fixture.readModelOnlyHandoff
        self.requiredValidationDependsOnNetwork = fixture.requiredValidationDependsOnNetwork
        self.exposesDatabaseSchema = false
        self.exposesRuntimeObject = false
        self.exposesAdapterRequest = false
        self.readsSecret = fixture.readsSecret
        self.usesSignedEndpoint = fixture.usesSignedEndpoint
        self.callsAccountEndpoint = fixture.callsAccountEndpoint
        self.createsListenKey = fixture.createsListenKey
        self.connectsBroker = fixture.connectsBroker
        self.implementsLiveExecutionAdapter = fixture.implementsLiveExecutionAdapter
        self.implementsOMS = fixture.implementsOMS
        self.implementsRealOrderLifecycle = fixture.implementsRealOrderLifecycle
        self.runsLiveRuntime = fixture.runsLiveRuntime
        self.providesCommandSurface = false
        self.providesLiveCommand = fixture.providesLiveCommand
        self.providesTradingButton = fixture.providesTradingButton
        self.authorizesLiveTrading = false
        self.touchesBrokerAction = false
        self.authorizesTradingExecution = false
        self.readModelOnlyBoundaryHeld = fixture.fixtureWiringBoundaryHeld
            && scenarioReplayWiringHeld
            && simulatedParityWiringHeld
            && localDeterministicFixtureOnly
            && readModelOnlyHandoff
            && requiredValidationDependsOnNetwork == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && runsLiveRuntime == false
            && providesCommandSurface == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }

    /// MTP-121 的 App / Dashboard first-run 验收 anchors。
    public static let validationAnchors: [String] = [
        "MTP-121-DEFAULT-SELECTED-SCENARIO",
        "MTP-121-READ-MODEL-ONLY-DASHBOARD-STATE",
        "MTP-121-FIRST-RUN-FALLBACK-STATES",
        "MTP-121-FIRST-RUN-EVIDENCE-SUMMARY",
        "MTP-121-DEMO-FIXTURE-ALIGNMENT",
        "MTP-121-NO-LIVE-PRO-CONSOLE-TRADING-COMMAND",
        "MTP-121-DASHBOARD-SMOKE-DEFAULT-DEMO-VALIDATION"
    ]
}

/// DashboardBetaFirstRunReadModel 是 MTP-121 的 App 层 first-run contract。
///
/// Read model 可以表达 default demo、empty、loading 和 error，但所有状态都保持
/// read-model-only。默认 demo 只消费 MTP-120 deterministic fixture evidence；fallback 状态只
/// 解释 UI 可展示状态，不产生重试按钮、下载任务、Runtime mutation 或真实交易动作。
public struct DashboardBetaFirstRunReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let state: DashboardBetaFirstRunStateKind
    public let evidenceSummary: DashboardBetaFirstRunEvidenceSummary?
    public let fallbackStates: [DashboardBetaFirstRunFallbackState]
    public let selectedScenarioID: String?
    public let defaultSelectedScenarioID: String
    public let stateSummary: String
    public let displayPriority: Int
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        state: DashboardBetaFirstRunStateKind,
        evidenceSummary: DashboardBetaFirstRunEvidenceSummary?,
        fallbackStates: [DashboardBetaFirstRunFallbackState] = Self.standardFallbackStates,
        selectedScenarioID: String?,
        defaultSelectedScenarioID: String = DashboardBetaDemoScenarioSelection
            .deterministicFixture
            .scenarioID
            .rawValue,
        stateSummary: String,
        displayPriority: Int,
        requiredValidationDependsOnNetwork: Bool = false,
        exposesDatabaseSchema: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesAdapterRequest: Bool = false,
        providesCommandSurface: Bool = false,
        providesOrderLevelCommand: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false,
        authorizesLiveTrading: Bool = false,
        touchesBrokerAction: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.source = source
        self.state = state
        self.evidenceSummary = evidenceSummary
        self.fallbackStates = fallbackStates
        self.selectedScenarioID = selectedScenarioID
        self.defaultSelectedScenarioID = defaultSelectedScenarioID
        self.stateSummary = stateSummary
        self.displayPriority = displayPriority
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && fallbackStates.allSatisfy(\.boundaryHeld)
            && (state != .defaultDemo || evidenceSummary?.readModelOnlyBoundaryHeld == true)
            && requiredValidationDependsOnNetwork == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesLiveCommand == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }

    public var isDefaultSelectedScenario: Bool {
        selectedScenarioID == defaultSelectedScenarioID
    }

    public static var defaultDemoState: DashboardBetaFirstRunReadModel {
        let summary = DashboardBetaFirstRunEvidenceSummary()
        return DashboardBetaFirstRunReadModel(
            state: .defaultDemo,
            evidenceSummary: summary,
            selectedScenarioID: summary.scenarioID,
            stateSummary: "default demo scenario selected; beta evidence ready",
            displayPriority: 0
        )
    }

    public static var empty: DashboardBetaFirstRunReadModel {
        fallback(.empty)
    }

    public static func fallback(
        _ state: DashboardBetaFirstRunStateKind,
        summary: String? = nil
    ) -> DashboardBetaFirstRunReadModel {
        precondition(state != .defaultDemo, "Use defaultDemoState for the selected beta demo state.")
        return DashboardBetaFirstRunReadModel(
            state: state,
            evidenceSummary: nil,
            selectedScenarioID: nil,
            stateSummary: summary ?? fallbackSummary(for: state),
            displayPriority: fallbackPriority(for: state)
        )
    }

    public static let standardFallbackStates: [DashboardBetaFirstRunFallbackState] = [
        DashboardBetaFirstRunFallbackState(
            state: .empty,
            label: "Empty",
            summary: "No beta evidence read model is available yet."
        ),
        DashboardBetaFirstRunFallbackState(
            state: .loading,
            label: "Loading",
            summary: "Beta evidence read model is being assembled locally."
        ),
        DashboardBetaFirstRunFallbackState(
            state: .error,
            label: "Error",
            summary: "Beta evidence read model failed validation and remains read-only."
        )
    ]

    private static func fallbackSummary(for state: DashboardBetaFirstRunStateKind) -> String {
        switch state {
        case .defaultDemo:
            "default demo scenario selected; beta evidence ready"
        case .empty:
            "no beta evidence read model is available yet"
        case .loading:
            "beta evidence read model is being assembled locally"
        case .error:
            "beta evidence read model failed validation"
        }
    }

    private static func fallbackPriority(for state: DashboardBetaFirstRunStateKind) -> Int {
        switch state {
        case .defaultDemo:
            0
        case .loading:
            1
        case .empty:
            2
        case .error:
            3
        }
    }
}

/// DashboardBetaFirstRunViewModel 是 Dashboard 可以直接绑定的 first-run 展示快照。
///
/// ViewModel 只从 `DashboardBetaFirstRunReadModel` 派生字段，保证 Dashboard 不直接读取
/// Core fixture、Persistence schema、Runtime object 或 Adapter request，也不提供 live command、
/// order-level command、交易按钮或真实交易授权。
public struct DashboardBetaFirstRunViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let state: DashboardBetaFirstRunStateKind
    public let stateSummary: String
    public let selectedScenarioID: String?
    public let defaultSelectedScenarioID: String
    public let isDefaultSelectedScenario: Bool
    public let evidenceSummary: DashboardBetaFirstRunEvidenceSummary?
    public let fallbackStates: [DashboardBetaFirstRunFallbackState]
    public let fallbackStateLabels: [String]
    public let validationAnchors: [String]
    public let displayPriority: Int
    public let readModelOnlyBoundaryHeld: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(readModel: DashboardBetaFirstRunReadModel) {
        self.source = readModel.source
        self.state = readModel.state
        self.stateSummary = readModel.stateSummary
        self.selectedScenarioID = readModel.selectedScenarioID
        self.defaultSelectedScenarioID = readModel.defaultSelectedScenarioID
        self.isDefaultSelectedScenario = readModel.isDefaultSelectedScenario
        self.evidenceSummary = readModel.evidenceSummary
        self.fallbackStates = readModel.fallbackStates
        self.fallbackStateLabels = readModel.fallbackStates.map { $0.state.rawValue }
        self.validationAnchors = readModel.evidenceSummary?.validationAnchors
            ?? DashboardBetaFirstRunEvidenceSummary.validationAnchors
        self.displayPriority = readModel.displayPriority
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
        self.requiredValidationDependsOnNetwork = readModel.requiredValidationDependsOnNetwork
        self.exposesDatabaseSchema = readModel.exposesDatabaseSchema
        self.exposesRuntimeObject = readModel.exposesRuntimeObject
        self.exposesAdapterRequest = readModel.exposesAdapterRequest
        self.providesCommandSurface = readModel.providesCommandSurface
        self.providesOrderLevelCommand = readModel.providesOrderLevelCommand
        self.providesLiveCommand = readModel.providesLiveCommand
        self.providesTradingButton = readModel.providesTradingButton
        self.authorizesLiveTrading = readModel.authorizesLiveTrading
        self.touchesBrokerAction = readModel.touchesBrokerAction
        self.authorizesTradingExecution = readModel.authorizesTradingExecution
    }
}
