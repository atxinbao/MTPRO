import Foundation

/// PaperWorkflowSessionControl 定义 MTP-47 允许进入后续控制壳设计的 session-level 本地动作。
///
/// 这些值只是 Dashboard 信息架构和合同 fixture，不是 `Command` 模型、SwiftUI 控件或 runtime
/// side effect。后续 issue 只能在该集合内实现本地 paper-only session 控制，不得把它扩展成
/// order-level command、broker action、signed endpoint 或真实订单入口。
public enum PaperWorkflowSessionControl: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case start
    case pause
    case close
    case reset
}

/// PaperWorkflowObservabilitySection 固定 Paper workflow Dashboard 必须能观察的 read-model-only 区域。
///
/// 每个 section 都代表后续 ViewModel / Read Model 的观察合同；它不暴露 SQLite / DuckDB schema、
/// runtime object、adapter request，也不要求当前 issue 实现 Event Timeline 或 UI 控件。
public enum PaperWorkflowObservabilitySection: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case session
    case proposal
    case riskDecision = "risk decision"
    case paperOrder = "paper order"
    case simulatedFill = "simulated fill"
    case portfolioProjection = "portfolio projection"
    case replayFreshness = "replay freshness"
    case reportArtifactStatus = "report artifact status"
    case eventTimeline = "event timeline"
}

/// PaperWorkflowForbiddenCapability 是 MTP-47 控制壳合同必须显式排除的能力清单。
///
/// 该清单用于 fixture-level validation：如果后续实现试图把控制壳扩大到 order command、
/// Live trading、broker 或 schema surface，合同测试会先失败。
public enum PaperWorkflowForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case orderLevelCommand = "order-level command"
    case liveTrading = "Live trading"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case brokerAction = "broker action"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case oms = "OMS"
    case databaseSchemaSurface = "database schema surface"
    case runtimeObjectSurface = "runtime object surface"
    case adapterRequestSurface = "adapter request surface"
}

/// PaperWorkflowDashboardContractError 描述 Dashboard IA fixture 被扩大或破坏时的失败原因。
///
/// 错误只服务本地合同验证，不对外暴露 API，也不提供任何交易动作恢复路径。
public enum PaperWorkflowDashboardContractError: Error, Equatable, Sendable {
    case dashboardSectionsMismatch
    case sessionControlsMismatch
    case observabilitySectionsMismatch
    case forbiddenCapabilitiesMismatch
    case sourceIsNotReadModelOnly
    case orderLevelCommandExposed
    case implementationEscapedIssueScope
}

/// PaperWorkflowDashboardInformationArchitecture 是 MTP-47 的稳定信息架构合同。
///
/// 合同把 Paper workflow 的观察面、session-level control shell、read-model-only 来源和 forbidden
/// capability 一次性固定下来，供后续 ViewModel、Command Model 和 Event Timeline issue 逐步消费。
/// 当前类型不实现命令模型、不渲染控件、不写 event log，也不连接 broker / exchange。
public struct PaperWorkflowDashboardInformationArchitecture: Codable, Equatable, Sendable {
    public let name: String
    public let source: ViewModelSourceContract
    public let dashboardSections: [DashboardSection]
    public let sessionLevelControls: [PaperWorkflowSessionControl]
    public let observabilitySections: [PaperWorkflowObservabilitySection]
    public let forbiddenCapabilities: [PaperWorkflowForbiddenCapability]
    public let allowsOrderLevelCommand: Bool
    public let implementsCommandModel: Bool
    public let implementsUIControls: Bool
    public let implementsEventTimeline: Bool

    public init(
        name: String = "Paper workflow Dashboard control shell",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        dashboardSections: [DashboardSection] = DashboardSection.allCases,
        sessionLevelControls: [PaperWorkflowSessionControl] = Self.requiredSessionLevelControls,
        observabilitySections: [PaperWorkflowObservabilitySection] = Self.requiredObservabilitySections,
        forbiddenCapabilities: [PaperWorkflowForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowsOrderLevelCommand: Bool = false,
        implementsCommandModel: Bool = false,
        implementsUIControls: Bool = false,
        implementsEventTimeline: Bool = false
    ) throws {
        guard source.isReadModelOnly else {
            throw PaperWorkflowDashboardContractError.sourceIsNotReadModelOnly
        }
        guard dashboardSections == DashboardSection.allCases else {
            throw PaperWorkflowDashboardContractError.dashboardSectionsMismatch
        }
        guard sessionLevelControls == Self.requiredSessionLevelControls else {
            throw PaperWorkflowDashboardContractError.sessionControlsMismatch
        }
        guard observabilitySections == Self.requiredObservabilitySections else {
            throw PaperWorkflowDashboardContractError.observabilitySectionsMismatch
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw PaperWorkflowDashboardContractError.forbiddenCapabilitiesMismatch
        }
        guard allowsOrderLevelCommand == false else {
            throw PaperWorkflowDashboardContractError.orderLevelCommandExposed
        }
        guard implementsCommandModel == false,
              implementsUIControls == false,
              implementsEventTimeline == false
        else {
            throw PaperWorkflowDashboardContractError.implementationEscapedIssueScope
        }

        self.name = name
        self.source = source
        self.dashboardSections = dashboardSections
        self.sessionLevelControls = sessionLevelControls
        self.observabilitySections = observabilitySections
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowsOrderLevelCommand = allowsOrderLevelCommand
        self.implementsCommandModel = implementsCommandModel
        self.implementsUIControls = implementsUIControls
        self.implementsEventTimeline = implementsEventTimeline
    }

    public var controlShellBoundaryHeld: Bool {
        source.isReadModelOnly
            && dashboardSections == DashboardSection.allCases
            && sessionLevelControls == Self.requiredSessionLevelControls
            && observabilitySections == Self.requiredObservabilitySections
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowsOrderLevelCommand == false
            && implementsCommandModel == false
            && implementsUIControls == false
            && implementsEventTimeline == false
    }

    public static let requiredSessionLevelControls: [PaperWorkflowSessionControl] = [
        .start,
        .pause,
        .close,
        .reset
    ]

    public static let requiredObservabilitySections: [PaperWorkflowObservabilitySection] = [
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

    public static let requiredForbiddenCapabilities: [PaperWorkflowForbiddenCapability] = [
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

    public static let deterministicFixture: PaperWorkflowDashboardInformationArchitecture = {
        do {
            return try PaperWorkflowDashboardInformationArchitecture()
        } catch {
            preconditionFailure("Paper workflow Dashboard IA fixture must satisfy MTP-47 boundary: \(error)")
        }
    }()
}
