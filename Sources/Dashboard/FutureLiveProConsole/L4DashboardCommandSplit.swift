import Foundation

/// L4LiveCommandAction 固定 GH-468 需要隔离的未来 command action。
///
/// 这些 action 只是 command gate state 的标签，不是 SwiftUI Button、Command model、broker request 或真实订单入口。
public enum L4LiveCommandAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// L4CommandGateState 固定 GH-468 read-only-to-command split 必须表达的状态。
///
/// State 只服务 Dashboard / future Live PRO Console ViewModel 合同。它不打开生产交易，也不授权任何
/// submit / cancel / replace command。
public enum L4CommandGateState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case readOnly = "read-only"
    case armed
    case blocked
    case incident
}

/// L4DashboardCommandSplitSurface 区分当前 Dashboard 和未来 gated Live PRO Console。
///
/// Dashboard 必须继续 read-model-only；未来 Live PRO Console 只能作为独立 gate surface 被描述，不能在 GH-468
/// 中变成可点击交易台。
public enum L4DashboardCommandSplitSurface: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboard = "Dashboard"
    case livePROConsole = "Live PRO Console"
}

/// L4DashboardCommandSplitForbiddenCapability 枚举 GH-468 必须保持关闭的 UI / command 能力。
///
/// GH-468 只定义 split contract 和 command gate state，不实现 guarded UI、不接 broker、不绕过 RiskEngine / OMS。
public enum L4DashboardCommandSplitForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboardSubmitCancelReplace = "Dashboard submit / cancel / replace"
    case dashboardTradingButton = "Dashboard trading button"
    case dashboardOrderForm = "Dashboard order form"
    case productionCommandEnabled = "production command enabled"
    case livePROConsoleCommandEnabled = "Live PRO Console command enabled"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case reconciliationBypass = "reconciliation bypass"
    case auditTrailBypass = "audit trail bypass"
    case brokerGatewayTouched = "broker gateway touched"
    case signedEndpointCalled = "signed endpoint called"
    case realOrderSubmitted = "real order submitted"
}

/// L4DashboardCommandSplitContractError 描述 GH-468 split fixture 被扩大或破坏时的失败原因。
///
/// 错误只服务本地合同测试，不对外暴露 API，也不提供交易动作恢复路径。
public enum L4DashboardCommandSplitContractError: Error, Equatable, Sendable {
    case issueMismatch
    case upstreamIssuesMismatch
    case dashboardCommandSurfaceExposed
    case commandGateStatesMismatch
    case liveConsoleActionsMismatch
    case liveConsoleEnabledBeforeGuardedUIIssue
    case commandSurfaceLocationMismatch
    case forbiddenCapabilityEnabled(String)
    case validationAnchorsMismatch
}

/// L4DashboardLivePROConsoleCommandSplitContract 是 GH-468 的 read-only-to-command split 合同。
///
/// Contract 固定 Dashboard 继续只读，submit / cancel / replace 只能作为未来 Live PRO Console gate action
/// 被描述，并且在 GH-469 guarded UI 前保持不可执行。它不实现真实 command UI、order form 或 broker action。
public struct L4DashboardLivePROConsoleCommandSplitContract: Codable, Equatable, Sendable {
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let dashboardSurface: L4DashboardCommandSplitSurface
    public let commandSurface: L4DashboardCommandSplitSurface
    public let dashboardState: L4CommandGateState
    public let commandGateStates: [L4CommandGateState]
    public let liveConsoleGatedActions: [L4LiveCommandAction]
    public let dashboardVisibleActions: [L4LiveCommandAction]
    public let dashboardEnabledActions: [L4LiveCommandAction]
    public let commandUIDefaultVisible: Bool
    public let commandUIDefaultEnabled: Bool
    public let consumesViewModelReadModelCommandGateState: Bool
    public let riskEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let reconciliationEvidenceRequired: Bool
    public let auditTrailEvidenceRequired: Bool
    public let productionCommandEnabled: Bool
    public let brokerGatewayTouched: Bool
    public let signedEndpointCalled: Bool
    public let realOrderSubmitted: Bool
    public let validationAnchors: [String]

    public var splitBoundaryHeld: Bool {
        issueID == "GH-468"
            && upstreamIssueIDs == Self.requiredUpstreamIssueIDs
            && dashboardSurface == .dashboard
            && commandSurface == .livePROConsole
            && dashboardState == .readOnly
            && commandGateStates == L4CommandGateState.allCases
            && liveConsoleGatedActions == L4LiveCommandAction.allCases
            && dashboardVisibleActions.isEmpty
            && dashboardEnabledActions.isEmpty
            && commandUIDefaultVisible == false
            && commandUIDefaultEnabled == false
            && consumesViewModelReadModelCommandGateState
            && riskEngineGateRequired
            && omsGateRequired
            && killSwitchGateRequired
            && reconciliationEvidenceRequired
            && auditTrailEvidenceRequired
            && productionCommandEnabled == false
            && brokerGatewayTouched == false
            && signedEndpointCalled == false
            && realOrderSubmitted == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public init(
        issueID: String = "GH-468",
        upstreamIssueIDs: [String] = Self.requiredUpstreamIssueIDs,
        dashboardSurface: L4DashboardCommandSplitSurface = .dashboard,
        commandSurface: L4DashboardCommandSplitSurface = .livePROConsole,
        dashboardState: L4CommandGateState = .readOnly,
        commandGateStates: [L4CommandGateState] = L4CommandGateState.allCases,
        liveConsoleGatedActions: [L4LiveCommandAction] = L4LiveCommandAction.allCases,
        dashboardVisibleActions: [L4LiveCommandAction] = [],
        dashboardEnabledActions: [L4LiveCommandAction] = [],
        commandUIDefaultVisible: Bool = false,
        commandUIDefaultEnabled: Bool = false,
        consumesViewModelReadModelCommandGateState: Bool = true,
        riskEngineGateRequired: Bool = true,
        omsGateRequired: Bool = true,
        killSwitchGateRequired: Bool = true,
        reconciliationEvidenceRequired: Bool = true,
        auditTrailEvidenceRequired: Bool = true,
        productionCommandEnabled: Bool = false,
        brokerGatewayTouched: Bool = false,
        signedEndpointCalled: Bool = false,
        realOrderSubmitted: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard issueID == "GH-468" else {
            throw L4DashboardCommandSplitContractError.issueMismatch
        }
        guard upstreamIssueIDs == Self.requiredUpstreamIssueIDs else {
            throw L4DashboardCommandSplitContractError.upstreamIssuesMismatch
        }
        guard dashboardSurface == .dashboard, commandSurface == .livePROConsole else {
            throw L4DashboardCommandSplitContractError.commandSurfaceLocationMismatch
        }
        guard dashboardState == .readOnly,
              dashboardVisibleActions.isEmpty,
              dashboardEnabledActions.isEmpty
        else {
            throw L4DashboardCommandSplitContractError.dashboardCommandSurfaceExposed
        }
        guard commandGateStates == L4CommandGateState.allCases else {
            throw L4DashboardCommandSplitContractError.commandGateStatesMismatch
        }
        guard liveConsoleGatedActions == L4LiveCommandAction.allCases else {
            throw L4DashboardCommandSplitContractError.liveConsoleActionsMismatch
        }
        guard commandUIDefaultVisible == false,
              commandUIDefaultEnabled == false
        else {
            throw L4DashboardCommandSplitContractError.liveConsoleEnabledBeforeGuardedUIIssue
        }
        for requiredFlag in [
            ("consumesViewModelReadModelCommandGateState", consumesViewModelReadModelCommandGateState),
            ("riskEngineGateRequired", riskEngineGateRequired),
            ("omsGateRequired", omsGateRequired),
            ("killSwitchGateRequired", killSwitchGateRequired),
            ("reconciliationEvidenceRequired", reconciliationEvidenceRequired),
            ("auditTrailEvidenceRequired", auditTrailEvidenceRequired)
        ] where requiredFlag.1 == false {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("productionCommandEnabled", productionCommandEnabled),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("signedEndpointCalled", signedEndpointCalled),
            ("realOrderSubmitted", realOrderSubmitted)
        ] where forbiddenFlag.1 {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw L4DashboardCommandSplitContractError.validationAnchorsMismatch
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.dashboardSurface = dashboardSurface
        self.commandSurface = commandSurface
        self.dashboardState = dashboardState
        self.commandGateStates = commandGateStates
        self.liveConsoleGatedActions = liveConsoleGatedActions
        self.dashboardVisibleActions = dashboardVisibleActions
        self.dashboardEnabledActions = dashboardEnabledActions
        self.commandUIDefaultVisible = commandUIDefaultVisible
        self.commandUIDefaultEnabled = commandUIDefaultEnabled
        self.consumesViewModelReadModelCommandGateState = consumesViewModelReadModelCommandGateState
        self.riskEngineGateRequired = riskEngineGateRequired
        self.omsGateRequired = omsGateRequired
        self.killSwitchGateRequired = killSwitchGateRequired
        self.reconciliationEvidenceRequired = reconciliationEvidenceRequired
        self.auditTrailEvidenceRequired = auditTrailEvidenceRequired
        self.productionCommandEnabled = productionCommandEnabled
        self.brokerGatewayTouched = brokerGatewayTouched
        self.signedEndpointCalled = signedEndpointCalled
        self.realOrderSubmitted = realOrderSubmitted
        self.validationAnchors = validationAnchors
    }

    public static let requiredUpstreamIssueIDs = ["GH-464", "GH-465", "GH-466", "GH-467"]

    public static let requiredValidationAnchors = [
        "GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT",
        "GH-468-DASHBOARD-READ-MODEL-ONLY",
        "GH-468-LIVEPRO-CONSOLE-COMMAND-GATE",
        "GH-468-READONLY-ARMED-BLOCKED-INCIDENT-STATES",
        "GH-468-NO-DASHBOARD-SUBMIT-CANCEL-REPLACE",
        "TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT"
    ]
}

/// L4LivePROConsoleCommandGateViewModel 是 GH-468 future console command gate 的只读 ViewModel。
///
/// ViewModel 只表达 gate state、action labels 和 disabled reason。即使在 `armed` state，它也不启用
/// submit / cancel / replace；真正 guarded UI surface 必须等 GH-469。
public struct L4LivePROConsoleCommandGateViewModel: Codable, Equatable, Sendable {
    public let state: L4CommandGateState
    public let surface: L4DashboardCommandSplitSurface
    public let gatedActions: [L4LiveCommandAction]
    public let dashboardCommandSurfaceVisible: Bool
    public let liveConsoleCommandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let consumesCommandGateState: Bool
    public let disabledReason: String
    public let requiresGH469GuardedUISurface: Bool
    public let riskEngineGateRequired: Bool
    public let omsGateRequired: Bool
    public let killSwitchGateRequired: Bool
    public let reconciliationEvidenceRequired: Bool
    public let auditTrailEvidenceRequired: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var commandGateBoundaryHeld: Bool {
        surface == .livePROConsole
            && gatedActions == L4LiveCommandAction.allCases
            && dashboardCommandSurfaceVisible == false
            && commandSurfaceEnabled == false
            && consumesCommandGateState
            && disabledReason.isEmpty == false
            && requiresGH469GuardedUISurface
            && riskEngineGateRequired
            && omsGateRequired
            && killSwitchGateRequired
            && reconciliationEvidenceRequired
            && auditTrailEvidenceRequired
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    public init(
        state: L4CommandGateState,
        surface: L4DashboardCommandSplitSurface = .livePROConsole,
        gatedActions: [L4LiveCommandAction] = L4LiveCommandAction.allCases,
        dashboardCommandSurfaceVisible: Bool = false,
        liveConsoleCommandSurfaceVisible: Bool? = nil,
        commandSurfaceEnabled: Bool = false,
        consumesCommandGateState: Bool = true,
        disabledReason: String? = nil,
        requiresGH469GuardedUISurface: Bool = true,
        riskEngineGateRequired: Bool = true,
        omsGateRequired: Bool = true,
        killSwitchGateRequired: Bool = true,
        reconciliationEvidenceRequired: Bool = true,
        auditTrailEvidenceRequired: Bool = true,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard surface == .livePROConsole else {
            throw L4DashboardCommandSplitContractError.commandSurfaceLocationMismatch
        }
        guard gatedActions == L4LiveCommandAction.allCases else {
            throw L4DashboardCommandSplitContractError.liveConsoleActionsMismatch
        }
        guard dashboardCommandSurfaceVisible == false else {
            throw L4DashboardCommandSplitContractError.dashboardCommandSurfaceExposed
        }
        guard commandSurfaceEnabled == false else {
            throw L4DashboardCommandSplitContractError.liveConsoleEnabledBeforeGuardedUIIssue
        }
        for requiredFlag in [
            ("consumesCommandGateState", consumesCommandGateState),
            ("requiresGH469GuardedUISurface", requiresGH469GuardedUISurface),
            ("riskEngineGateRequired", riskEngineGateRequired),
            ("omsGateRequired", omsGateRequired),
            ("killSwitchGateRequired", killSwitchGateRequired),
            ("reconciliationEvidenceRequired", reconciliationEvidenceRequired),
            ("auditTrailEvidenceRequired", auditTrailEvidenceRequired)
        ] where requiredFlag.1 == false {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ] where forbiddenFlag.1 {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.state = state
        self.surface = surface
        self.gatedActions = gatedActions
        self.dashboardCommandSurfaceVisible = dashboardCommandSurfaceVisible
        self.liveConsoleCommandSurfaceVisible = liveConsoleCommandSurfaceVisible ?? Self.defaultVisibility(for: state)
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.consumesCommandGateState = consumesCommandGateState
        self.disabledReason = disabledReason ?? Self.defaultDisabledReason(for: state)
        self.requiresGH469GuardedUISurface = requiresGH469GuardedUISurface
        self.riskEngineGateRequired = riskEngineGateRequired
        self.omsGateRequired = omsGateRequired
        self.killSwitchGateRequired = killSwitchGateRequired
        self.reconciliationEvidenceRequired = reconciliationEvidenceRequired
        self.auditTrailEvidenceRequired = auditTrailEvidenceRequired
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder

        guard commandGateBoundaryHeld else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("commandGateBoundaryHeld")
        }
    }

    private static func defaultVisibility(for state: L4CommandGateState) -> Bool {
        switch state {
        case .readOnly, .incident:
            false
        case .armed, .blocked:
            true
        }
    }

    private static func defaultDisabledReason(for state: L4CommandGateState) -> String {
        switch state {
        case .readOnly:
            "Dashboard remains read-model-only; command surface hidden."
        case .armed:
            "Future Live PRO Console gate is armed but disabled until GH-469 guarded UI."
        case .blocked:
            "Kill switch / command shutdown gate blocks command surface."
        case .incident:
            "Incident state hides command surface and requires audit review."
        }
    }
}

/// L4DashboardLivePROConsoleCommandSplitEvidence 汇总 GH-468 split evidence。
///
/// Evidence 证明 Dashboard 继续只读，未来 Live PRO Console command gate 独立存在但默认不可执行。它不实现
/// guarded submit / cancel / replace UI，不绕过 RiskEngine / OMS，也不触碰 broker gateway。
public struct L4DashboardLivePROConsoleCommandSplitEvidence: Codable, Equatable, Sendable {
    public let contract: L4DashboardLivePROConsoleCommandSplitContract
    public let commandGateViewModels: [L4LivePROConsoleCommandGateViewModel]
    public let forbiddenCapabilities: [L4DashboardCommandSplitForbiddenCapability]
    public let validationAnchors: [String]
    public let dashboardReadModelOnly: Bool
    public let commandSurfaceOnlyInLivePROConsole: Bool
    public let commandUIDefaultInvisibleOrDisabled: Bool
    public let consumesOnlyViewModelReadModelCommandGateState: Bool
    public let dashboardProvidesSubmitCancelReplace: Bool
    public let productionCommandEnabled: Bool
    public let riskEngineBypassed: Bool
    public let omsBypassed: Bool
    public let brokerGatewayTouched: Bool

    public var splitEvidenceHeld: Bool {
        contract.splitBoundaryHeld
            && Set(commandGateViewModels.map(\.state)) == Set(L4CommandGateState.allCases)
            && commandGateViewModels.allSatisfy(\.commandGateBoundaryHeld)
            && forbiddenCapabilities == L4DashboardCommandSplitForbiddenCapability.allCases
            && validationAnchors == L4DashboardLivePROConsoleCommandSplitContract.requiredValidationAnchors
            && dashboardReadModelOnly
            && commandSurfaceOnlyInLivePROConsole
            && commandUIDefaultInvisibleOrDisabled
            && consumesOnlyViewModelReadModelCommandGateState
            && dashboardProvidesSubmitCancelReplace == false
            && productionCommandEnabled == false
            && riskEngineBypassed == false
            && omsBypassed == false
            && brokerGatewayTouched == false
    }

    public init(
        contract: L4DashboardLivePROConsoleCommandSplitContract,
        commandGateViewModels: [L4LivePROConsoleCommandGateViewModel],
        forbiddenCapabilities: [L4DashboardCommandSplitForbiddenCapability] = L4DashboardCommandSplitForbiddenCapability.allCases,
        validationAnchors: [String] = L4DashboardLivePROConsoleCommandSplitContract.requiredValidationAnchors,
        dashboardReadModelOnly: Bool = true,
        commandSurfaceOnlyInLivePROConsole: Bool = true,
        commandUIDefaultInvisibleOrDisabled: Bool = true,
        consumesOnlyViewModelReadModelCommandGateState: Bool = true,
        dashboardProvidesSubmitCancelReplace: Bool = false,
        productionCommandEnabled: Bool = false,
        riskEngineBypassed: Bool = false,
        omsBypassed: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard contract.splitBoundaryHeld else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("contract.splitBoundaryHeld")
        }
        guard Set(commandGateViewModels.map(\.state)) == Set(L4CommandGateState.allCases) else {
            throw L4DashboardCommandSplitContractError.commandGateStatesMismatch
        }
        guard commandGateViewModels.allSatisfy(\.commandGateBoundaryHeld) else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("commandGateViewModels")
        }
        guard forbiddenCapabilities == L4DashboardCommandSplitForbiddenCapability.allCases else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("forbiddenCapabilities")
        }
        guard validationAnchors == L4DashboardLivePROConsoleCommandSplitContract.requiredValidationAnchors else {
            throw L4DashboardCommandSplitContractError.validationAnchorsMismatch
        }
        for requiredFlag in [
            ("dashboardReadModelOnly", dashboardReadModelOnly),
            ("commandSurfaceOnlyInLivePROConsole", commandSurfaceOnlyInLivePROConsole),
            ("commandUIDefaultInvisibleOrDisabled", commandUIDefaultInvisibleOrDisabled),
            ("consumesOnlyViewModelReadModelCommandGateState", consumesOnlyViewModelReadModelCommandGateState)
        ] where requiredFlag.1 == false {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("dashboardProvidesSubmitCancelReplace", dashboardProvidesSubmitCancelReplace),
            ("productionCommandEnabled", productionCommandEnabled),
            ("riskEngineBypassed", riskEngineBypassed),
            ("omsBypassed", omsBypassed),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.contract = contract
        self.commandGateViewModels = commandGateViewModels
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.commandSurfaceOnlyInLivePROConsole = commandSurfaceOnlyInLivePROConsole
        self.commandUIDefaultInvisibleOrDisabled = commandUIDefaultInvisibleOrDisabled
        self.consumesOnlyViewModelReadModelCommandGateState = consumesOnlyViewModelReadModelCommandGateState
        self.dashboardProvidesSubmitCancelReplace = dashboardProvidesSubmitCancelReplace
        self.productionCommandEnabled = productionCommandEnabled
        self.riskEngineBypassed = riskEngineBypassed
        self.omsBypassed = omsBypassed
        self.brokerGatewayTouched = brokerGatewayTouched
    }
}

/// L4DashboardCommandSplitRuntime 生成 GH-468 deterministic split evidence。
///
/// Runtime 名称只表示本地 ViewModel fixture builder。它不渲染真实交易控件，不启用生产 command，
/// 不连接 broker，也不调用 signed / account endpoint。
public struct L4DashboardCommandSplitRuntime: Codable, Equatable, Sendable {
    public let contract: L4DashboardLivePROConsoleCommandSplitContract
    public let dashboardProvidesSubmitCancelReplace: Bool
    public let productionCommandEnabled: Bool
    public let riskEngineBypassed: Bool
    public let omsBypassed: Bool
    public let brokerGatewayTouched: Bool
    public let signedEndpointCalled: Bool
    public let realOrderSubmitted: Bool

    public var runtimeBoundaryHeld: Bool {
        contract.splitBoundaryHeld
            && dashboardProvidesSubmitCancelReplace == false
            && productionCommandEnabled == false
            && riskEngineBypassed == false
            && omsBypassed == false
            && brokerGatewayTouched == false
            && signedEndpointCalled == false
            && realOrderSubmitted == false
    }

    public init(
        contract: L4DashboardLivePROConsoleCommandSplitContract? = nil,
        dashboardProvidesSubmitCancelReplace: Bool = false,
        productionCommandEnabled: Bool = false,
        riskEngineBypassed: Bool = false,
        omsBypassed: Bool = false,
        brokerGatewayTouched: Bool = false,
        signedEndpointCalled: Bool = false,
        realOrderSubmitted: Bool = false
    ) throws {
        let resolvedContract = try contract ?? L4DashboardLivePROConsoleCommandSplitContract()
        guard resolvedContract.splitBoundaryHeld else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("contract.splitBoundaryHeld")
        }
        for forbiddenFlag in [
            ("dashboardProvidesSubmitCancelReplace", dashboardProvidesSubmitCancelReplace),
            ("productionCommandEnabled", productionCommandEnabled),
            ("riskEngineBypassed", riskEngineBypassed),
            ("omsBypassed", omsBypassed),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("signedEndpointCalled", signedEndpointCalled),
            ("realOrderSubmitted", realOrderSubmitted)
        ] where forbiddenFlag.1 {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.contract = resolvedContract
        self.dashboardProvidesSubmitCancelReplace = dashboardProvidesSubmitCancelReplace
        self.productionCommandEnabled = productionCommandEnabled
        self.riskEngineBypassed = riskEngineBypassed
        self.omsBypassed = omsBypassed
        self.brokerGatewayTouched = brokerGatewayTouched
        self.signedEndpointCalled = signedEndpointCalled
        self.realOrderSubmitted = realOrderSubmitted
    }

    public static func deterministicFixture() throws -> L4DashboardCommandSplitRuntime {
        try L4DashboardCommandSplitRuntime()
    }

    public func deterministicEvidence() throws -> L4DashboardLivePROConsoleCommandSplitEvidence {
        guard runtimeBoundaryHeld else {
            throw L4DashboardCommandSplitContractError.forbiddenCapabilityEnabled("runtimeBoundaryHeld")
        }
        let viewModels = try L4CommandGateState.allCases.map { state in
            try L4LivePROConsoleCommandGateViewModel(state: state)
        }
        return try L4DashboardLivePROConsoleCommandSplitEvidence(
            contract: contract,
            commandGateViewModels: viewModels
        )
    }
}
