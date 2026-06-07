import Foundation

/// L4GuardedCommandUIControlState 固定 GH-469 guarded command control 必须展示的状态。
///
/// 这些状态只服务 Live PRO Console ViewModel evidence。`sandboxGateEnabled` 表示 command 只在
/// sandbox gate 下可用；它不是 production command，也不会调用 broker、signed endpoint 或真实订单 API。
public enum L4GuardedCommandUIControlState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case disabledByDefault = "disabled by default"
    case sandboxGateEnabled = "sandbox gate enabled"
    case blocked = "blocked"
    case incidentStopped = "incident stopped"
}

/// L4GuardedCommandUIForbiddenCapability 枚举 GH-469 必须继续关闭的能力。
///
/// GH-469 只实现 guarded UI surface 的 deterministic evidence。它不实现真实 production trading button，
/// 不存储 secret，不触碰真实 broker gateway，也不绕过 RiskEngine / OMS / ExecutionEngine sandbox gate。
public enum L4GuardedCommandUIForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboardCommandSurface = "Dashboard command surface"
    case productionCommandEnabled = "production command enabled"
    case realBrokerGatewayTouched = "real broker gateway touched"
    case secretStored = "secret stored"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case executionEngineSandboxBypass = "ExecutionEngine sandbox bypass"
    case confirmationBypass = "confirmation bypass"
    case auditEvidenceBypass = "audit evidence bypass"
    case incidentStopBypass = "incident stop bypass"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// L4GuardedCommandUISurfaceError 描述 GH-469 guarded UI evidence 被扩大或破坏时的失败原因。
///
/// 错误只用于本地合同测试；它不提供运行时恢复路径，也不转换成真实交易错误。
public enum L4GuardedCommandUISurfaceError: Error, Equatable, Sendable {
    case issueMismatch
    case upstreamIssuesMismatch
    case commandActionsMismatch
    case controlStatesMismatch
    case commandSurfaceLocationMismatch
    case missingConfirmation(String)
    case missingBlockedReason(String)
    case missingIncidentStop(String)
    case missingAuditEvidence(String)
    case upstreamEvidenceMismatch(String)
    case forbiddenCapabilityEnabled(String)
    case validationAnchorsMismatch
}

/// L4GuardedCommandControlViewModel 是 GH-469 submit / cancel / replace 的 guarded control evidence。
///
/// ViewModel 只描述未来 Live PRO Console 的 sandbox-gated command control。每个 control 都必须默认 disabled，
/// 只有 sandbox gate 可用，并且带 confirmation、blocked reason、incident stop 和 audit evidence。
/// 它不渲染真实按钮、不发真实订单、不保存 secret、不访问 broker。
public struct L4GuardedCommandControlViewModel: Codable, Equatable, Sendable {
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let action: L4LiveCommandAction
    public let surface: L4DashboardCommandSplitSurface
    public let controlStates: [L4GuardedCommandUIControlState]
    public let defaultEnabled: Bool
    public let sandboxGateEnabled: Bool
    public let productionGateEnabled: Bool
    public let confirmationRequired: Bool
    public let confirmationPrompt: String
    public let confirmationEvidenceID: String
    public let blockedReason: String
    public let incidentStopReason: String
    public let splitEvidenceAnchor: String
    public let riskEngineEvidenceAnchor: String
    public let omsEvidenceAnchor: String
    public let executionEngineSandboxEvidenceAnchor: String
    public let auditEvidenceAnchor: String
    public let auditEvidenceID: String
    public let dashboardCommandSurfaceVisible: Bool
    public let brokerGatewayTouched: Bool
    public let signedEndpointCalled: Bool
    public let secretStored: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var controlBoundaryHeld: Bool {
        issueID == "GH-469"
            && upstreamIssueIDs == Self.requiredUpstreamIssueIDs
            && surface == .livePROConsole
            && controlStates == L4GuardedCommandUIControlState.allCases
            && defaultEnabled == false
            && sandboxGateEnabled
            && productionGateEnabled == false
            && confirmationRequired
            && confirmationPrompt.isEmpty == false
            && confirmationEvidenceID.isEmpty == false
            && blockedReason.isEmpty == false
            && incidentStopReason.isEmpty == false
            && splitEvidenceAnchor == Self.requiredSplitEvidenceAnchor
            && riskEngineEvidenceAnchor == Self.requiredRiskEngineEvidenceAnchor
            && omsEvidenceAnchor == Self.requiredOMSEvidenceAnchor
            && executionEngineSandboxEvidenceAnchor == Self.requiredExecutionEngineSandboxEvidenceAnchor
            && auditEvidenceAnchor == Self.requiredAuditEvidenceAnchor
            && auditEvidenceID.isEmpty == false
            && dashboardCommandSurfaceVisible == false
            && brokerGatewayTouched == false
            && signedEndpointCalled == false
            && secretStored == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    public init(
        issueID: String = "GH-469",
        upstreamIssueIDs: [String] = Self.requiredUpstreamIssueIDs,
        action: L4LiveCommandAction,
        surface: L4DashboardCommandSplitSurface = .livePROConsole,
        controlStates: [L4GuardedCommandUIControlState] = L4GuardedCommandUIControlState.allCases,
        defaultEnabled: Bool = false,
        sandboxGateEnabled: Bool = true,
        productionGateEnabled: Bool = false,
        confirmationRequired: Bool = true,
        confirmationPrompt: String? = nil,
        confirmationEvidenceID: String? = nil,
        blockedReason: String? = nil,
        incidentStopReason: String? = nil,
        splitEvidenceAnchor: String = Self.requiredSplitEvidenceAnchor,
        riskEngineEvidenceAnchor: String = Self.requiredRiskEngineEvidenceAnchor,
        omsEvidenceAnchor: String = Self.requiredOMSEvidenceAnchor,
        executionEngineSandboxEvidenceAnchor: String = Self.requiredExecutionEngineSandboxEvidenceAnchor,
        auditEvidenceAnchor: String = Self.requiredAuditEvidenceAnchor,
        auditEvidenceID: String? = nil,
        dashboardCommandSurfaceVisible: Bool = false,
        brokerGatewayTouched: Bool = false,
        signedEndpointCalled: Bool = false,
        secretStored: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard issueID == "GH-469" else {
            throw L4GuardedCommandUISurfaceError.issueMismatch
        }
        guard upstreamIssueIDs == Self.requiredUpstreamIssueIDs else {
            throw L4GuardedCommandUISurfaceError.upstreamIssuesMismatch
        }
        guard surface == .livePROConsole else {
            throw L4GuardedCommandUISurfaceError.commandSurfaceLocationMismatch
        }
        guard controlStates == L4GuardedCommandUIControlState.allCases else {
            throw L4GuardedCommandUISurfaceError.controlStatesMismatch
        }
        guard defaultEnabled == false, sandboxGateEnabled, productionGateEnabled == false else {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled("commandGate")
        }
        guard confirmationRequired else {
            throw L4GuardedCommandUISurfaceError.missingConfirmation(action.rawValue)
        }

        let resolvedConfirmationPrompt = confirmationPrompt
            ?? "Confirm sandbox \(action.rawValue) command before dispatching through GH-463 evidence."
        let resolvedConfirmationEvidenceID = confirmationEvidenceID
            ?? "gh-469-\(action.rawValue)-confirmation-required"
        let resolvedBlockedReason = blockedReason
            ?? "Production gate is not satisfied; command remains sandbox-only and blocked outside GH-463 path."
        let resolvedIncidentStopReason = incidentStopReason
            ?? "GH-465 incident stop / command shutdown gate blocks \(action.rawValue) when incident state is active."
        let resolvedAuditEvidenceID = auditEvidenceID
            ?? "gh-469-\(action.rawValue)-guarded-ui-audit-evidence"

        guard resolvedConfirmationPrompt.isEmpty == false,
              resolvedConfirmationEvidenceID.isEmpty == false
        else {
            throw L4GuardedCommandUISurfaceError.missingConfirmation(action.rawValue)
        }
        guard resolvedBlockedReason.isEmpty == false else {
            throw L4GuardedCommandUISurfaceError.missingBlockedReason(action.rawValue)
        }
        guard resolvedIncidentStopReason.isEmpty == false else {
            throw L4GuardedCommandUISurfaceError.missingIncidentStop(action.rawValue)
        }
        guard resolvedAuditEvidenceID.isEmpty == false else {
            throw L4GuardedCommandUISurfaceError.missingAuditEvidence(action.rawValue)
        }
        for upstreamAnchor in [
            ("splitEvidenceAnchor", splitEvidenceAnchor, Self.requiredSplitEvidenceAnchor),
            ("riskEngineEvidenceAnchor", riskEngineEvidenceAnchor, Self.requiredRiskEngineEvidenceAnchor),
            ("omsEvidenceAnchor", omsEvidenceAnchor, Self.requiredOMSEvidenceAnchor),
            (
                "executionEngineSandboxEvidenceAnchor",
                executionEngineSandboxEvidenceAnchor,
                Self.requiredExecutionEngineSandboxEvidenceAnchor
            ),
            ("auditEvidenceAnchor", auditEvidenceAnchor, Self.requiredAuditEvidenceAnchor)
        ] where upstreamAnchor.1 != upstreamAnchor.2 {
            throw L4GuardedCommandUISurfaceError.upstreamEvidenceMismatch(upstreamAnchor.0)
        }
        for forbiddenFlag in [
            ("dashboardCommandSurfaceVisible", dashboardCommandSurfaceVisible),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("signedEndpointCalled", signedEndpointCalled),
            ("secretStored", secretStored),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ] where forbiddenFlag.1 {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.action = action
        self.surface = surface
        self.controlStates = controlStates
        self.defaultEnabled = defaultEnabled
        self.sandboxGateEnabled = sandboxGateEnabled
        self.productionGateEnabled = productionGateEnabled
        self.confirmationRequired = confirmationRequired
        self.confirmationPrompt = resolvedConfirmationPrompt
        self.confirmationEvidenceID = resolvedConfirmationEvidenceID
        self.blockedReason = resolvedBlockedReason
        self.incidentStopReason = resolvedIncidentStopReason
        self.splitEvidenceAnchor = splitEvidenceAnchor
        self.riskEngineEvidenceAnchor = riskEngineEvidenceAnchor
        self.omsEvidenceAnchor = omsEvidenceAnchor
        self.executionEngineSandboxEvidenceAnchor = executionEngineSandboxEvidenceAnchor
        self.auditEvidenceAnchor = auditEvidenceAnchor
        self.auditEvidenceID = resolvedAuditEvidenceID
        self.dashboardCommandSurfaceVisible = dashboardCommandSurfaceVisible
        self.brokerGatewayTouched = brokerGatewayTouched
        self.signedEndpointCalled = signedEndpointCalled
        self.secretStored = secretStored
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder

        guard controlBoundaryHeld else {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled("controlBoundaryHeld")
        }
    }

    public static let requiredUpstreamIssueIDs = ["GH-468"]
    public static let requiredSplitEvidenceAnchor = "GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT"
    public static let requiredRiskEngineEvidenceAnchor = "GH-464-LIVE-RISK-PRETRADE-GATE"
    public static let requiredOMSEvidenceAnchor = "GH-461-GH-462-OMS-LIFECYCLE-LOCAL-TRANSITION"
    public static let requiredExecutionEngineSandboxEvidenceAnchor = "GH-463-EXECUTIONENGINE-SANDBOX-PATH"
    public static let requiredAuditEvidenceAnchor = "GH-467-AUDIT-TRAIL-INCIDENT-REPLAY"
}

/// L4GuardedCommandUISurfaceEvidence 汇总 GH-469 guarded submit / cancel / replace UI surface evidence。
///
/// Evidence 证明 Dashboard 仍然 read-model-only，Live PRO Console 只暴露 sandbox-gated controls，
/// 且每个 control 都带 confirmation、blocked reason、incident stop 和 audit evidence。
public struct L4GuardedCommandUISurfaceEvidence: Codable, Equatable, Sendable {
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let splitEvidence: L4DashboardLivePROConsoleCommandSplitEvidence
    public let controls: [L4GuardedCommandControlViewModel]
    public let forbiddenCapabilities: [L4GuardedCommandUIForbiddenCapability]
    public let validationAnchors: [String]
    public let dashboardReadModelOnly: Bool
    public let livePROConsoleSurfaceOnly: Bool
    public let controlsDisabledByDefault: Bool
    public let sandboxOnlyActions: [L4LiveCommandAction]
    public let allControlsHaveConfirmation: Bool
    public let allControlsHaveAuditEvidence: Bool
    public let blockedReasonVisible: Bool
    public let incidentStopVisible: Bool
    public let riskEngineEvidenceConsumed: Bool
    public let omsEvidenceConsumed: Bool
    public let executionEngineSandboxEvidenceConsumed: Bool
    public let productionCommandEnabled: Bool
    public let brokerGatewayTouched: Bool
    public let signedEndpointCalled: Bool
    public let secretStored: Bool
    public let realSubmitCancelReplaceEnabled: Bool

    public var guardedSurfaceEvidenceHeld: Bool {
        issueID == "GH-469"
            && upstreamIssueIDs == ["GH-468"]
            && splitEvidence.splitEvidenceHeld
            && controls.map(\.action) == L4LiveCommandAction.allCases
            && controls.allSatisfy(\.controlBoundaryHeld)
            && forbiddenCapabilities == L4GuardedCommandUIForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && dashboardReadModelOnly
            && livePROConsoleSurfaceOnly
            && controlsDisabledByDefault
            && sandboxOnlyActions == L4LiveCommandAction.allCases
            && allControlsHaveConfirmation
            && allControlsHaveAuditEvidence
            && blockedReasonVisible
            && incidentStopVisible
            && riskEngineEvidenceConsumed
            && omsEvidenceConsumed
            && executionEngineSandboxEvidenceConsumed
            && productionCommandEnabled == false
            && brokerGatewayTouched == false
            && signedEndpointCalled == false
            && secretStored == false
            && realSubmitCancelReplaceEnabled == false
    }

    public init(
        issueID: String = "GH-469",
        upstreamIssueIDs: [String] = ["GH-468"],
        splitEvidence: L4DashboardLivePROConsoleCommandSplitEvidence,
        controls: [L4GuardedCommandControlViewModel],
        forbiddenCapabilities: [L4GuardedCommandUIForbiddenCapability] = L4GuardedCommandUIForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        dashboardReadModelOnly: Bool = true,
        livePROConsoleSurfaceOnly: Bool = true,
        controlsDisabledByDefault: Bool = true,
        sandboxOnlyActions: [L4LiveCommandAction] = L4LiveCommandAction.allCases,
        allControlsHaveConfirmation: Bool = true,
        allControlsHaveAuditEvidence: Bool = true,
        blockedReasonVisible: Bool = true,
        incidentStopVisible: Bool = true,
        riskEngineEvidenceConsumed: Bool = true,
        omsEvidenceConsumed: Bool = true,
        executionEngineSandboxEvidenceConsumed: Bool = true,
        productionCommandEnabled: Bool = false,
        brokerGatewayTouched: Bool = false,
        signedEndpointCalled: Bool = false,
        secretStored: Bool = false,
        realSubmitCancelReplaceEnabled: Bool = false
    ) throws {
        guard issueID == "GH-469" else {
            throw L4GuardedCommandUISurfaceError.issueMismatch
        }
        guard upstreamIssueIDs == ["GH-468"] else {
            throw L4GuardedCommandUISurfaceError.upstreamIssuesMismatch
        }
        guard splitEvidence.splitEvidenceHeld else {
            throw L4GuardedCommandUISurfaceError.upstreamEvidenceMismatch("GH-468")
        }
        guard controls.map(\.action) == L4LiveCommandAction.allCases,
              controls.allSatisfy(\.controlBoundaryHeld)
        else {
            throw L4GuardedCommandUISurfaceError.commandActionsMismatch
        }
        guard forbiddenCapabilities == L4GuardedCommandUIForbiddenCapability.allCases else {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled("forbiddenCapabilities")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw L4GuardedCommandUISurfaceError.validationAnchorsMismatch
        }
        for requiredFlag in [
            ("dashboardReadModelOnly", dashboardReadModelOnly),
            ("livePROConsoleSurfaceOnly", livePROConsoleSurfaceOnly),
            ("controlsDisabledByDefault", controlsDisabledByDefault),
            ("allControlsHaveConfirmation", allControlsHaveConfirmation),
            ("allControlsHaveAuditEvidence", allControlsHaveAuditEvidence),
            ("blockedReasonVisible", blockedReasonVisible),
            ("incidentStopVisible", incidentStopVisible),
            ("riskEngineEvidenceConsumed", riskEngineEvidenceConsumed),
            ("omsEvidenceConsumed", omsEvidenceConsumed),
            ("executionEngineSandboxEvidenceConsumed", executionEngineSandboxEvidenceConsumed)
        ] where requiredFlag.1 == false {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled(requiredFlag.0)
        }
        guard sandboxOnlyActions == L4LiveCommandAction.allCases else {
            throw L4GuardedCommandUISurfaceError.commandActionsMismatch
        }
        for forbiddenFlag in [
            ("productionCommandEnabled", productionCommandEnabled),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("signedEndpointCalled", signedEndpointCalled),
            ("secretStored", secretStored),
            ("realSubmitCancelReplaceEnabled", realSubmitCancelReplaceEnabled)
        ] where forbiddenFlag.1 {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.splitEvidence = splitEvidence
        self.controls = controls
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.livePROConsoleSurfaceOnly = livePROConsoleSurfaceOnly
        self.controlsDisabledByDefault = controlsDisabledByDefault
        self.sandboxOnlyActions = sandboxOnlyActions
        self.allControlsHaveConfirmation = allControlsHaveConfirmation
        self.allControlsHaveAuditEvidence = allControlsHaveAuditEvidence
        self.blockedReasonVisible = blockedReasonVisible
        self.incidentStopVisible = incidentStopVisible
        self.riskEngineEvidenceConsumed = riskEngineEvidenceConsumed
        self.omsEvidenceConsumed = omsEvidenceConsumed
        self.executionEngineSandboxEvidenceConsumed = executionEngineSandboxEvidenceConsumed
        self.productionCommandEnabled = productionCommandEnabled
        self.brokerGatewayTouched = brokerGatewayTouched
        self.signedEndpointCalled = signedEndpointCalled
        self.secretStored = secretStored
        self.realSubmitCancelReplaceEnabled = realSubmitCancelReplaceEnabled
    }

    public static let requiredValidationAnchors = [
        "GH-469-GUARDED-SUBMIT-CANCEL-REPLACE-UI-SURFACE",
        "GH-469-SANDBOX-GATE-ONLY-COMMANDS",
        "GH-469-CONFIRMATION-BLOCKED-INCIDENT-EVIDENCE",
        "GH-469-NO-PRODUCTION-COMMAND-DEFAULT",
        "TVM-L4-GUARDED-COMMAND-UI-SURFACE"
    ]
}

/// L4GuardedCommandUISurfaceRuntime 生成 GH-469 deterministic guarded UI surface evidence。
///
/// Runtime 名称只表示本地 fixture builder。它不渲染真实 SwiftUI 按钮，不读取 secret，不调用
/// ExecutionClient，不连接 broker，也不提交 / 撤销 / 替换真实订单。
public struct L4GuardedCommandUISurfaceRuntime: Codable, Equatable, Sendable {
    public let issueID: String
    public let productionCommandEnabled: Bool
    public let dashboardCommandSurfaceVisible: Bool
    public let brokerGatewayTouched: Bool
    public let signedEndpointCalled: Bool
    public let secretStored: Bool
    public let riskEngineBypassed: Bool
    public let omsBypassed: Bool
    public let executionEngineSandboxBypassed: Bool
    public let confirmationBypassed: Bool
    public let auditEvidenceBypassed: Bool
    public let incidentStopBypassed: Bool
    public let realSubmitCancelReplaceEnabled: Bool

    public var runtimeBoundaryHeld: Bool {
        issueID == "GH-469"
            && productionCommandEnabled == false
            && dashboardCommandSurfaceVisible == false
            && brokerGatewayTouched == false
            && signedEndpointCalled == false
            && secretStored == false
            && riskEngineBypassed == false
            && omsBypassed == false
            && executionEngineSandboxBypassed == false
            && confirmationBypassed == false
            && auditEvidenceBypassed == false
            && incidentStopBypassed == false
            && realSubmitCancelReplaceEnabled == false
    }

    public init(
        issueID: String = "GH-469",
        productionCommandEnabled: Bool = false,
        dashboardCommandSurfaceVisible: Bool = false,
        brokerGatewayTouched: Bool = false,
        signedEndpointCalled: Bool = false,
        secretStored: Bool = false,
        riskEngineBypassed: Bool = false,
        omsBypassed: Bool = false,
        executionEngineSandboxBypassed: Bool = false,
        confirmationBypassed: Bool = false,
        auditEvidenceBypassed: Bool = false,
        incidentStopBypassed: Bool = false,
        realSubmitCancelReplaceEnabled: Bool = false
    ) throws {
        guard issueID == "GH-469" else {
            throw L4GuardedCommandUISurfaceError.issueMismatch
        }
        for forbiddenFlag in [
            ("productionCommandEnabled", productionCommandEnabled),
            ("dashboardCommandSurfaceVisible", dashboardCommandSurfaceVisible),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("signedEndpointCalled", signedEndpointCalled),
            ("secretStored", secretStored),
            ("riskEngineBypassed", riskEngineBypassed),
            ("omsBypassed", omsBypassed),
            ("executionEngineSandboxBypassed", executionEngineSandboxBypassed),
            ("confirmationBypassed", confirmationBypassed),
            ("auditEvidenceBypassed", auditEvidenceBypassed),
            ("incidentStopBypassed", incidentStopBypassed),
            ("realSubmitCancelReplaceEnabled", realSubmitCancelReplaceEnabled)
        ] where forbiddenFlag.1 {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled(forbiddenFlag.0)
        }

        self.issueID = issueID
        self.productionCommandEnabled = productionCommandEnabled
        self.dashboardCommandSurfaceVisible = dashboardCommandSurfaceVisible
        self.brokerGatewayTouched = brokerGatewayTouched
        self.signedEndpointCalled = signedEndpointCalled
        self.secretStored = secretStored
        self.riskEngineBypassed = riskEngineBypassed
        self.omsBypassed = omsBypassed
        self.executionEngineSandboxBypassed = executionEngineSandboxBypassed
        self.confirmationBypassed = confirmationBypassed
        self.auditEvidenceBypassed = auditEvidenceBypassed
        self.incidentStopBypassed = incidentStopBypassed
        self.realSubmitCancelReplaceEnabled = realSubmitCancelReplaceEnabled
    }

    public static func deterministicFixture() throws -> L4GuardedCommandUISurfaceRuntime {
        try L4GuardedCommandUISurfaceRuntime()
    }

    public func deterministicEvidence() throws -> L4GuardedCommandUISurfaceEvidence {
        guard runtimeBoundaryHeld else {
            throw L4GuardedCommandUISurfaceError.forbiddenCapabilityEnabled("runtimeBoundaryHeld")
        }
        let splitEvidence = try L4DashboardCommandSplitRuntime
            .deterministicFixture()
            .deterministicEvidence()
        let controls = try L4LiveCommandAction.allCases.map { action in
            try L4GuardedCommandControlViewModel(action: action)
        }
        return try L4GuardedCommandUISurfaceEvidence(
            splitEvidence: splitEvidence,
            controls: controls
        )
    }
}
