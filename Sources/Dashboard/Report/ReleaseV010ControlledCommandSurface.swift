import Foundation

/// ReleaseV010ControlledCommandAction 固定 GH-535 Dashboard 可展示的受控 command action。
///
/// 这些 action 只是 release v0.1.0 Dashboard 的 gate label；它们不等于 SwiftUI Button、broker
/// request、ExecutionClient call、OMS mutation 或真实 submit / cancel / replace 命令。
public enum ReleaseV010ControlledCommandAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// ReleaseV010ControlledCommandMode 固定 GH-535 command entry 的可见模式。
///
/// 默认必须是 `noTrade`。`dryRun` 和 `testnet` 只是已具备 evidence 的受控路径标签，
/// `productionDisabled` 用于解释为什么 production 仍被关闭。
public enum ReleaseV010ControlledCommandMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noTrade = "no-trade"
    case dryRun = "dry-run"
    case testnet = "testnet"
    case productionDisabled = "production disabled"
}

/// ReleaseV010ControlledCommandEvidenceAnchor 绑定 GH-535 必须消费的上游 release evidence。
///
/// Anchor 只用于 Dashboard 显示和测试断言，不能被解释为实际 runtime dependency。
public struct ReleaseV010ControlledCommandEvidenceAnchor: Codable, Equatable, Sendable {
    public let issueID: String
    public let anchor: String
    public let purpose: String

    public init(issueID: String, anchor: String, purpose: String) {
        self.issueID = issueID
        self.anchor = anchor
        self.purpose = purpose
    }

    public var anchorBoundaryHeld: Bool {
        issueID.hasPrefix("GH-")
            && anchor.isEmpty == false
            && purpose.isEmpty == false
    }
}

/// ReleaseV010ControlledCommandControlViewModel 是 GH-535 单个受控 command 的展示模型。
///
/// 每个 control 默认 no-trade，并展示 dry-run / testnet gate 与 production disabled reason。
/// 它不保存 secret、不读取 production endpoint、不触发 broker、RiskEngine、ExecutionEngine 或 OMS。
public struct ReleaseV010ControlledCommandControlViewModel: Codable, Equatable, Sendable {
    public let action: ReleaseV010ControlledCommandAction
    public let defaultMode: ReleaseV010ControlledCommandMode
    public let visibleModes: [ReleaseV010ControlledCommandMode]
    public let commandEntryVisible: Bool
    public let commandEntryEnabled: Bool
    public let dryRunGateVisible: Bool
    public let testnetGateVisible: Bool
    public let productionGateVisible: Bool
    public let productionGateEnabled: Bool
    public let operatorConfirmationRequired: Bool
    public let riskEngineGateRequired: Bool
    public let executionEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let disabledReason: String
    public let productionDisabledExplanation: String
    public let evidenceAnchors: [ReleaseV010ControlledCommandEvidenceAnchor]
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let callsExecutionClient: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let authorizesTradingExecution: Bool

    public init(
        action: ReleaseV010ControlledCommandAction,
        defaultMode: ReleaseV010ControlledCommandMode = .noTrade,
        visibleModes: [ReleaseV010ControlledCommandMode] = ReleaseV010ControlledCommandMode.allCases,
        commandEntryVisible: Bool = true,
        commandEntryEnabled: Bool = false,
        dryRunGateVisible: Bool = true,
        testnetGateVisible: Bool = true,
        productionGateVisible: Bool = true,
        productionGateEnabled: Bool = false,
        operatorConfirmationRequired: Bool = true,
        riskEngineGateRequired: Bool = true,
        executionEngineGateRequired: Bool = true,
        omsGateRequired: Bool = true,
        killSwitchGateRequired: Bool = true,
        disabledReason: String? = nil,
        productionDisabledExplanation: String? = nil,
        evidenceAnchors: [ReleaseV010ControlledCommandEvidenceAnchor] = Self.requiredEvidenceAnchors,
        readsSecret: Bool = false,
        opensProductionEndpoint: Bool = false,
        connectsBroker: Bool = false,
        callsExecutionClient: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesExecutionEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.action = action
        self.defaultMode = defaultMode
        self.visibleModes = visibleModes
        self.commandEntryVisible = commandEntryVisible
        self.commandEntryEnabled = commandEntryEnabled
        self.dryRunGateVisible = dryRunGateVisible
        self.testnetGateVisible = testnetGateVisible
        self.productionGateVisible = productionGateVisible
        self.productionGateEnabled = productionGateEnabled
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.riskEngineGateRequired = riskEngineGateRequired
        self.executionEngineGateRequired = executionEngineGateRequired
        self.omsGateRequired = omsGateRequired
        self.killSwitchGateRequired = killSwitchGateRequired
        self.disabledReason = disabledReason
            ?? "\(action.rawValue) remains no-trade until dry-run or Binance testnet gate evidence is selected."
        self.productionDisabledExplanation = productionDisabledExplanation
            ?? "Production trading is disabled by default; no release gate, operator confirmation, risk approval and kill switch pass has authorized production \(action.rawValue)."
        self.evidenceAnchors = evidenceAnchors
        self.readsSecret = readsSecret
        self.opensProductionEndpoint = opensProductionEndpoint
        self.connectsBroker = connectsBroker
        self.callsExecutionClient = callsExecutionClient
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesExecutionEngine = bypassesExecutionEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesKillSwitch = bypassesKillSwitch
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var commandBoundaryHeld: Bool {
        defaultMode == .noTrade
            && visibleModes == ReleaseV010ControlledCommandMode.allCases
            && commandEntryVisible
            && commandEntryEnabled == false
            && dryRunGateVisible
            && testnetGateVisible
            && productionGateVisible
            && productionGateEnabled == false
            && operatorConfirmationRequired
            && riskEngineGateRequired
            && executionEngineGateRequired
            && omsGateRequired
            && killSwitchGateRequired
            && disabledReason.isEmpty == false
            && productionDisabledExplanation.contains("Production trading is disabled by default")
            && evidenceAnchors == Self.requiredEvidenceAnchors
            && evidenceAnchors.allSatisfy(\.anchorBoundaryHeld)
            && readsSecret == false
            && opensProductionEndpoint == false
            && connectsBroker == false
            && callsExecutionClient == false
            && bypassesRiskEngine == false
            && bypassesExecutionEngine == false
            && bypassesOMS == false
            && bypassesKillSwitch == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && authorizesTradingExecution == false
    }

    public static let requiredEvidenceAnchors = [
        ReleaseV010ControlledCommandEvidenceAnchor(
            issueID: "GH-529",
            anchor: "GH-529-RISKENGINE-PRE-TRADE-GATE",
            purpose: "RiskEngine pre-trade gate must be satisfied before command dispatch."
        ),
        ReleaseV010ControlledCommandEvidenceAnchor(
            issueID: "GH-530",
            anchor: "GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE",
            purpose: "ExecutionEngine and OMS state evidence must exist before testnet command dispatch."
        ),
        ReleaseV010ControlledCommandEvidenceAnchor(
            issueID: "GH-531",
            anchor: "GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE",
            purpose: "Only Binance testnet submit / cancel / replace is in release scope."
        ),
        ReleaseV010ControlledCommandEvidenceAnchor(
            issueID: "GH-534",
            anchor: "GH-534-DASHBOARD-LIVE-MONITORING-SURFACE",
            purpose: "Dashboard command status is shown next to read-model-only release monitoring."
        )
    ]
}

/// ReleaseV010ControlledCommandSurfaceReadModel 是 GH-535 Dashboard command gate 输入。
///
/// 它只描述默认 no-trade、dry-run/testnet gate 和 production disabled explanation，不包含
/// secret、endpoint、broker session、ExecutionClient object、OMS store 或真实订单 payload。
/// `GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE`
public struct ReleaseV010ControlledCommandSurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let controls: [ReleaseV010ControlledCommandControlViewModel]
    public let validationAnchors: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        controls: [ReleaseV010ControlledCommandControlViewModel] = Self.requiredControls,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.controls = controls.sorted {
            $0.action.rawValue < $1.action.rawValue
        }
        self.validationAnchors = validationAnchors
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var commandSurfaceBoundaryHeld: Bool {
        source.isReadModelOnly
            && controls.count == ReleaseV010ControlledCommandAction.allCases.count
            && controls.map(\.action).sorted { $0.rawValue < $1.rawValue }
                == ReleaseV010ControlledCommandAction.allCases.sorted { $0.rawValue < $1.rawValue }
            && controls.allSatisfy(\.commandBoundaryHeld)
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE",
        "GH-535-DEFAULT-NO-TRADE-COMMAND-ENTRY",
        "GH-535-DRYRUN-TESTNET-GATE",
        "GH-535-PRODUCTION-DISABLED-BY-DEFAULT",
        "GH-535-NO-RISK-EXECUTION-KILLSWITCH-BYPASS",
        "TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE"
    ]

    public static let requiredControls = ReleaseV010ControlledCommandAction.allCases.map {
        ReleaseV010ControlledCommandControlViewModel(action: $0)
    }
}

/// ReleaseV010ControlledCommandSurfaceViewModel 是 GH-535 Dashboard 可渲染的受控 command summary。
///
/// ViewModel 可以展示 command entry 和 production disabled explanation，但所有 entry 默认 disabled。
/// 它不授权交易执行，也不把 Dashboard 变成真实 Live PRO Console、broker gateway 或 order form。
public struct ReleaseV010ControlledCommandSurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let actionLabels: [String]
    public let defaultModeLabels: [String]
    public let visibleModeLabels: [String]
    public let disabledReasons: [String]
    public let productionDisabledExplanations: [String]
    public let evidenceAnchors: [String]
    public let validationAnchors: [String]
    public let controlCount: Int
    public let commandEntryDefaultNoTrade: Bool
    public let dryRunGateVisible: Bool
    public let testnetGateVisible: Bool
    public let productionGateVisible: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCommandEnabled: Bool
    public let commandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let operatorConfirmationRequired: Bool
    public let riskEngineGateRequired: Bool
    public let executionEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let commandSurfaceBoundaryHeld: Bool
    public let providesCommandSurface: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesSecretEditor: Bool
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let callsExecutionClient: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: ReleaseV010ControlledCommandSurfaceReadModel) {
        let controls = readModel.controls
        let visibleModes = controls.flatMap(\.visibleModes).map(\.rawValue).uniquePreservingOrder()
        let evidenceAnchors = controls.flatMap(\.evidenceAnchors).map(\.anchor).uniquePreservingOrder()

        self.source = readModel.source
        self.issueID = "GH-535"
        self.matrixID = "TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE"
        self.actionLabels = controls.map(\.action.rawValue)
        self.defaultModeLabels = controls.map(\.defaultMode.rawValue).uniquePreservingOrder()
        self.visibleModeLabels = visibleModes
        self.disabledReasons = controls.map(\.disabledReason)
        self.productionDisabledExplanations = controls.map(\.productionDisabledExplanation).uniquePreservingOrder()
        self.evidenceAnchors = evidenceAnchors
        self.validationAnchors = readModel.validationAnchors
        self.controlCount = controls.count
        self.commandEntryDefaultNoTrade = controls.allSatisfy { $0.defaultMode == .noTrade }
        self.dryRunGateVisible = controls.allSatisfy(\.dryRunGateVisible)
        self.testnetGateVisible = controls.allSatisfy(\.testnetGateVisible)
        self.productionGateVisible = controls.allSatisfy(\.productionGateVisible)
        self.productionTradingEnabledByDefault = false
        self.productionCommandEnabled = controls.contains(where: \.productionGateEnabled)
        self.commandSurfaceVisible = controls.allSatisfy(\.commandEntryVisible)
        self.commandSurfaceEnabled = controls.contains(where: \.commandEntryEnabled)
        self.operatorConfirmationRequired = controls.allSatisfy(\.operatorConfirmationRequired)
        self.riskEngineGateRequired = controls.allSatisfy(\.riskEngineGateRequired)
        self.executionEngineGateRequired = controls.allSatisfy(\.executionEngineGateRequired)
        self.omsGateRequired = controls.allSatisfy(\.omsGateRequired)
        self.killSwitchGateRequired = controls.allSatisfy(\.killSwitchGateRequired)
        self.reportSummary = [
            "Release v0.1.0 controlled command surface",
            "actions=\(controls.count)",
            "default=no-trade",
            "production=disabled"
        ].joined(separator: "; ")
        self.dashboardPanelSummaries = controls.map {
            "\($0.action.rawValue): \($0.defaultMode.rawValue), disabled"
        }
        self.commandSurfaceBoundaryHeld = readModel.commandSurfaceBoundaryHeld
            && commandEntryDefaultNoTrade
            && dryRunGateVisible
            && testnetGateVisible
            && productionCommandEnabled == false
            && commandSurfaceEnabled == false
            && controls.allSatisfy(\.commandBoundaryHeld)
        self.providesCommandSurface = commandSurfaceVisible
        self.providesTradingButton = false
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesSecretEditor = false
        self.readsSecret = controls.contains(where: \.readsSecret)
        self.opensProductionEndpoint = controls.contains(where: \.opensProductionEndpoint)
        self.connectsBroker = controls.contains(where: \.connectsBroker)
        self.callsExecutionClient = controls.contains(where: \.callsExecutionClient)
        self.bypassesRiskEngine = controls.contains(where: \.bypassesRiskEngine)
        self.bypassesExecutionEngine = controls.contains(where: \.bypassesExecutionEngine)
        self.bypassesOMS = controls.contains(where: \.bypassesOMS)
        self.bypassesKillSwitch = controls.contains(where: \.bypassesKillSwitch)
        self.submitsRealOrder = controls.contains(where: \.submitsRealOrder)
        self.cancelsRealOrder = controls.contains(where: \.cancelsRealOrder)
        self.replacesRealOrder = controls.contains(where: \.replacesRealOrder)
        self.authorizesTradingExecution = controls.contains(where: \.authorizesTradingExecution)
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element: Hashable {
    func uniquePreservingOrder() -> [Element] {
        var seen = Set<Element>()
        var values: [Element] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}
