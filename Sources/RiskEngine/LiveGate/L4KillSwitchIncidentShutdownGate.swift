import DomainModel
import Foundation

/// L4IncidentStopSourceKind 固定 GH-465 允许记录的 incident stop source identity 类型。
///
/// Source identity 只用于本地 deterministic shutdown gate evidence。它不读取 secret、不触碰
/// production operations runtime，不代表真实 broker emergency stop、Live PRO Console 操作或人工运维 runbook。
public enum L4IncidentStopSourceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanOperator = "human operator"
    case riskEngineIncidentStop = "RiskEngine incident stop"
    case operationsPolicy = "operations policy"
}

/// L4CommandShutdownGateDecisionOutcome 描述 GH-465 shutdown gate 对 command path 的判定。
///
/// 当前唯一允许的结果是阻断 command path。恢复只记录为边界条件，不自动恢复 submit / cancel / replace。
public enum L4CommandShutdownGateDecisionOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blockedByCommandShutdown = "blocked by command shutdown"
}

/// L4CommandShutdownGateReason 固定 GH-465 可审计的 shutdown reason。
///
/// Reason 只服务 audit evidence / Dashboard read-model explanation，不构成真实 incident operations 指令。
public enum L4CommandShutdownGateReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentStopActive = "incident stop active"
    case commandShutdownActive = "command shutdown active"
    case sourceIdentityRequired = "source identity required"
    case manualRecoveryRequired = "manual recovery required"
    case productionTradingDisabled = "production trading disabled"
}

/// L4CommandShutdownRecoveryBoundary 固定 GH-465 的恢复边界。
///
/// 恢复边界必须保持不可自动绕过：任何后续恢复、cutover 或 production enablement 都需要后续明确 issue 和 gate。
public enum L4CommandShutdownRecoveryBoundary: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case noAutomaticRecovery = "no automatic recovery"
    case requiresManualReviewEvidence = "requires manual review evidence"
    case requiresFreshRiskGate = "requires fresh RiskEngine gate"
    case requiresFutureProductionCutoverGate = "requires future production cutover gate"
}

/// L4CommandShutdownForbiddenCapability 枚举 GH-465 必须继续关闭的能力。
///
/// GH-465 只实现 kill switch / incident stop / command shutdown 的 deterministic evidence。它不提交真实订单、
/// 不调用 ExecutionClient、不实现 broker emergency API、不开放 Live PRO Console command surface。
public enum L4CommandShutdownForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabled = "production trading enabled"
    case productionOperationsRuntime = "production operations runtime"
    case readsSecret = "reads secret"
    case callsExecutionClient = "calls ExecutionClient"
    case touchesBrokerGateway = "touches broker gateway"
    case submitsRealOrder = "submits real order"
    case cancelsRealOrder = "cancels real order"
    case replacesRealOrder = "replaces real order"
    case autoRecoveryEnabled = "auto recovery enabled"
    case bypassesRiskEngine = "bypasses RiskEngine"
    case bypassesOMS = "bypasses OMS"
    case exposesLiveCommandSurface = "exposes Live command surface"
    case exposesTradingButton = "exposes trading button"
}

/// L4IncidentStopSourceEvidence 是 GH-465 的 source identity 证据。
///
/// Source identity 必须绑定 GH-464 incident stop decision。它只说明 shutdown gate 从哪个可审计来源激活，
/// 不包含真实操作者 secret、production credential、broker state 或 Live PRO Console command。
public struct L4IncidentStopSourceEvidence: Codable, Equatable, Sendable {
    public let sourceEvidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let sourceKind: L4IncidentStopSourceKind
    public let sourceID: Identifier
    public let incidentID: Identifier
    public let triggeredByRiskDecisionID: Identifier
    public let upstreamRiskOutcome: L4LiveRiskPreTradeDecisionOutcome
    public let reason: String
    public let identityRecorded: Bool
    public let operatorAcknowledged: Bool
    public let autoRecoveryAuthorized: Bool
    public let liveCommandSurfaceTouched: Bool
    public let productionOperationsRuntimeTouched: Bool
    public let brokerGatewayTouched: Bool

    public var sourceBoundaryHeld: Bool {
        issueID.rawValue == "GH-465"
            && upstreamIssueID.rawValue == "GH-464"
            && upstreamRiskOutcome == .incidentStop
            && reason.isEmpty == false
            && identityRecorded
            && operatorAcknowledged
            && autoRecoveryAuthorized == false
            && liveCommandSurfaceTouched == false
            && productionOperationsRuntimeTouched == false
            && brokerGatewayTouched == false
    }

    public init(
        sourceEvidenceID: Identifier = Identifier.constant("gh-465-incident-stop-source-identity"),
        issueID: Identifier = Identifier.constant("GH-465"),
        upstreamIssueID: Identifier = Identifier.constant("GH-464"),
        sourceKind: L4IncidentStopSourceKind = .riskEngineIncidentStop,
        sourceID: Identifier = Identifier.constant("gh-465-riskengine-incident-stop-source"),
        incidentID: Identifier = Identifier.constant("gh-465-command-shutdown-incident"),
        triggeredByRiskDecisionID: Identifier,
        upstreamRiskOutcome: L4LiveRiskPreTradeDecisionOutcome,
        reason: String,
        identityRecorded: Bool = true,
        operatorAcknowledged: Bool = true,
        autoRecoveryAuthorized: Bool = false,
        liveCommandSurfaceTouched: Bool = false,
        productionOperationsRuntimeTouched: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-465" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-465",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-464" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-464",
                actual: upstreamIssueID.rawValue
            )
        }
        guard upstreamRiskOutcome == .incidentStop else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamRiskOutcome",
                expected: L4LiveRiskPreTradeDecisionOutcome.incidentStop.rawValue,
                actual: upstreamRiskOutcome.rawValue
            )
        }
        guard reason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reason",
                expected: "non-empty GH-465 incident stop reason",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("identityRecorded", identityRecorded),
            ("operatorAcknowledged", operatorAcknowledged)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("autoRecoveryAuthorized", autoRecoveryAuthorized),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched),
            ("productionOperationsRuntimeTouched", productionOperationsRuntimeTouched),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.sourceEvidenceID = sourceEvidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.sourceKind = sourceKind
        self.sourceID = sourceID
        self.incidentID = incidentID
        self.triggeredByRiskDecisionID = triggeredByRiskDecisionID
        self.upstreamRiskOutcome = upstreamRiskOutcome
        self.reason = reason
        self.identityRecorded = identityRecorded
        self.operatorAcknowledged = operatorAcknowledged
        self.autoRecoveryAuthorized = autoRecoveryAuthorized
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
        self.productionOperationsRuntimeTouched = productionOperationsRuntimeTouched
        self.brokerGatewayTouched = brokerGatewayTouched
    }
}

/// L4CommandShutdownGateDecisionEvidence 是 GH-465 单个 submit / cancel / replace command 的 shutdown 判定。
///
/// Decision 证明 incident stop 激活后 command path 被 shutdown gate 阻断。它不执行 command、不调用
/// ExecutionClient、不触碰 broker gateway、不暴露 Live command UI，也不会自动恢复。
public struct L4CommandShutdownGateDecisionEvidence: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let sourceEvidenceID: Identifier
    public let triggeredByRiskDecisionID: Identifier
    public let commandKind: L4LiveRiskPreTradeCommandKind
    public let outcome: L4CommandShutdownGateDecisionOutcome
    public let reasons: [L4CommandShutdownGateReason]
    public let recoveryBoundary: [L4CommandShutdownRecoveryBoundary]
    public let incidentStopActive: Bool
    public let commandShutdownActive: Bool
    public let sourceIdentityAttached: Bool
    public let dashboardAuditExplainable: Bool
    public let executesCommand: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let productionTradingEnabled: Bool
    public let autoRecoveryEnabled: Bool
    public let exposesLiveCommandSurface: Bool

    public var decisionBoundaryHeld: Bool {
        issueID.rawValue == "GH-465"
            && upstreamIssueID.rawValue == "GH-464"
            && outcome == .blockedByCommandShutdown
            && reasons == Self.requiredReasons
            && recoveryBoundary == Self.requiredRecoveryBoundary
            && incidentStopActive
            && commandShutdownActive
            && sourceIdentityAttached
            && dashboardAuditExplainable
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            executesCommand,
            callsExecutionClient,
            touchesBrokerGateway,
            submitsRealOrder,
            productionTradingEnabled,
            autoRecoveryEnabled,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        decisionID: Identifier,
        issueID: Identifier = Identifier.constant("GH-465"),
        upstreamIssueID: Identifier = Identifier.constant("GH-464"),
        sourceEvidenceID: Identifier,
        triggeredByRiskDecisionID: Identifier,
        commandKind: L4LiveRiskPreTradeCommandKind,
        outcome: L4CommandShutdownGateDecisionOutcome = .blockedByCommandShutdown,
        reasons: [L4CommandShutdownGateReason] = Self.requiredReasons,
        recoveryBoundary: [L4CommandShutdownRecoveryBoundary] = Self.requiredRecoveryBoundary,
        incidentStopActive: Bool = true,
        commandShutdownActive: Bool = true,
        sourceIdentityAttached: Bool = true,
        dashboardAuditExplainable: Bool = true,
        executesCommand: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        productionTradingEnabled: Bool = false,
        autoRecoveryEnabled: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-465" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-465",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-464" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-464",
                actual: upstreamIssueID.rawValue
            )
        }
        guard outcome == .blockedByCommandShutdown else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "outcome",
                expected: L4CommandShutdownGateDecisionOutcome.blockedByCommandShutdown.rawValue,
                actual: outcome.rawValue
            )
        }
        guard reasons == Self.requiredReasons else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reasons",
                expected: Self.requiredReasons.map(\.rawValue).joined(separator: ","),
                actual: reasons.map(\.rawValue).joined(separator: ",")
            )
        }
        guard recoveryBoundary == Self.requiredRecoveryBoundary else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recoveryBoundary",
                expected: Self.requiredRecoveryBoundary.map(\.rawValue).joined(separator: ","),
                actual: recoveryBoundary.map(\.rawValue).joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("incidentStopActive", incidentStopActive),
            ("commandShutdownActive", commandShutdownActive),
            ("sourceIdentityAttached", sourceIdentityAttached),
            ("dashboardAuditExplainable", dashboardAuditExplainable)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("executesCommand", executesCommand),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("productionTradingEnabled", productionTradingEnabled),
            ("autoRecoveryEnabled", autoRecoveryEnabled),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.decisionID = decisionID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.sourceEvidenceID = sourceEvidenceID
        self.triggeredByRiskDecisionID = triggeredByRiskDecisionID
        self.commandKind = commandKind
        self.outcome = outcome
        self.reasons = reasons
        self.recoveryBoundary = recoveryBoundary
        self.incidentStopActive = incidentStopActive
        self.commandShutdownActive = commandShutdownActive
        self.sourceIdentityAttached = sourceIdentityAttached
        self.dashboardAuditExplainable = dashboardAuditExplainable
        self.executesCommand = executesCommand
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.productionTradingEnabled = productionTradingEnabled
        self.autoRecoveryEnabled = autoRecoveryEnabled
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredReasons: [L4CommandShutdownGateReason] = [
        .incidentStopActive,
        .commandShutdownActive,
        .sourceIdentityRequired,
        .manualRecoveryRequired,
        .productionTradingDisabled
    ]

    public static let requiredRecoveryBoundary: [L4CommandShutdownRecoveryBoundary] = [
        .noAutomaticRecovery,
        .requiresManualReviewEvidence,
        .requiresFreshRiskGate,
        .requiresFutureProductionCutoverGate
    ]
}

/// L4KillSwitchIncidentShutdownGateEvidence 汇总 GH-465 kill switch / incident stop / shutdown gate evidence。
///
/// Evidence 覆盖 submit / cancel / replace 在 incident stop 激活后的阻断规则、source identity、Dashboard /
/// audit explanation 和 recovery boundary。它不授权 production runbook、real emergency broker API 或 live command。
public struct L4KillSwitchIncidentShutdownGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sourceEvidence: L4IncidentStopSourceEvidence
    public let decisions: [L4CommandShutdownGateDecisionEvidence]
    public let forbiddenCapabilities: [L4CommandShutdownForbiddenCapability]
    public let validationAnchors: [String]
    public let incidentStopBlocksCommandPath: Bool
    public let submitCancelReplaceBlocked: Bool
    public let sourceIdentityAuditable: Bool
    public let dashboardAuditEvidenceExplainable: Bool
    public let recoveryBoundaryNotAutomatic: Bool
    public let productionEnablementClosed: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let exposesLiveCommandSurface: Bool

    public var gateEvidenceHeld: Bool {
        issueID.rawValue == "GH-465"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-464"]
            && sourceEvidence.sourceBoundaryHeld
            && decisions.map(\.commandKind) == L4LiveRiskPreTradeCommandKind.allCases
            && decisions.allSatisfy(\.decisionBoundaryHeld)
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && incidentStopBlocksCommandPath
            && submitCancelReplaceBlocked
            && sourceIdentityAuditable
            && dashboardAuditEvidenceExplainable
            && recoveryBoundaryNotAutomatic
            && productionEnablementClosed
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && exposesLiveCommandSurface == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-465-kill-switch-incident-shutdown-gate-evidence"),
        issueID: Identifier = Identifier.constant("GH-465"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-464")],
        sourceEvidence: L4IncidentStopSourceEvidence,
        decisions: [L4CommandShutdownGateDecisionEvidence],
        forbiddenCapabilities: [L4CommandShutdownForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        incidentStopBlocksCommandPath: Bool = true,
        submitCancelReplaceBlocked: Bool = true,
        sourceIdentityAuditable: Bool = true,
        dashboardAuditEvidenceExplainable: Bool = true,
        recoveryBoundaryNotAutomatic: Bool = true,
        productionEnablementClosed: Bool = true,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-465" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-465",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-464"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-464",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceEvidence.sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceEvidence",
                expected: "GH-465 source boundary held",
                actual: "mismatch"
            )
        }
        guard decisions.map(\.commandKind) == L4LiveRiskPreTradeCommandKind.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions.commandKind",
                expected: L4LiveRiskPreTradeCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: decisions.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard decisions.allSatisfy(\.decisionBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "decisions",
                expected: "all GH-465 shutdown decisions held",
                actual: "mismatch"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("incidentStopBlocksCommandPath", incidentStopBlocksCommandPath),
            ("submitCancelReplaceBlocked", submitCancelReplaceBlocked),
            ("sourceIdentityAuditable", sourceIdentityAuditable),
            ("dashboardAuditEvidenceExplainable", dashboardAuditEvidenceExplainable),
            ("recoveryBoundaryNotAutomatic", recoveryBoundaryNotAutomatic),
            ("productionEnablementClosed", productionEnablementClosed)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sourceEvidence = sourceEvidence
        self.decisions = decisions
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.incidentStopBlocksCommandPath = incidentStopBlocksCommandPath
        self.submitCancelReplaceBlocked = submitCancelReplaceBlocked
        self.sourceIdentityAuditable = sourceIdentityAuditable
        self.dashboardAuditEvidenceExplainable = dashboardAuditEvidenceExplainable
        self.recoveryBoundaryNotAutomatic = recoveryBoundaryNotAutomatic
        self.productionEnablementClosed = productionEnablementClosed
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredForbiddenCapabilities = L4CommandShutdownForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-465-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE",
        "GH-465-INCIDENT-STOP-SOURCE-IDENTITY",
        "GH-465-SUBMIT-CANCEL-REPLACE-SHUTDOWN-RULES",
        "GH-465-DASHBOARD-AUDIT-SHUTDOWN-EVIDENCE",
        "GH-465-NO-AUTOMATIC-RECOVERY",
        "TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE"
    ]
}

/// L4KillSwitchIncidentShutdownGateRuntime 是 GH-465 的本地 deterministic shutdown gate。
///
/// Runtime 只消费 GH-464 incident stop decision evidence 并输出 command shutdown evidence。它不读取 secret、
/// 不调用 ExecutionClient、不触碰 broker gateway、不提交 / 撤销 / 替换真实订单，也不实现 production cutover。
public struct L4KillSwitchIncidentShutdownGateRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let productionTradingEnabled: Bool
    public let productionOperationsRuntimeTouched: Bool
    public let readsSecret: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let autoRecoveryEnabled: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesOMS: Bool
    public let exposesLiveCommandSurface: Bool

    public var runtimeBoundaryHeld: Bool {
        productionTradingEnabled == false
            && productionOperationsRuntimeTouched == false
            && readsSecret == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
            && autoRecoveryEnabled == false
            && bypassesRiskEngine == false
            && bypassesOMS == false
            && exposesLiveCommandSurface == false
    }

    public init(
        runtimeID: Identifier = Identifier.constant("gh-465-kill-switch-incident-shutdown-gate-runtime"),
        productionTradingEnabled: Bool = false,
        productionOperationsRuntimeTouched: Bool = false,
        readsSecret: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        autoRecoveryEnabled: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesOMS: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        for forbiddenFlag in [
            ("productionTradingEnabled", productionTradingEnabled),
            ("productionOperationsRuntimeTouched", productionOperationsRuntimeTouched),
            ("readsSecret", readsSecret),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("autoRecoveryEnabled", autoRecoveryEnabled),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("bypassesOMS", bypassesOMS),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.runtimeID = runtimeID
        self.productionTradingEnabled = productionTradingEnabled
        self.productionOperationsRuntimeTouched = productionOperationsRuntimeTouched
        self.readsSecret = readsSecret
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.autoRecoveryEnabled = autoRecoveryEnabled
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesOMS = bypassesOMS
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static func deterministicFixture() throws -> L4KillSwitchIncidentShutdownGateRuntime {
        try L4KillSwitchIncidentShutdownGateRuntime()
    }

    public func deterministicEvidence() throws -> L4KillSwitchIncidentShutdownGateEvidence {
        let riskRuntime = try L4LiveRiskPreTradeGateRuntime.deterministicFixture()
        let riskEvidence = try riskRuntime.deterministicEvidence()
        guard let incidentDecision = riskEvidence.decisions.first(where: { $0.outcome == .incidentStop }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "GH-464 incident decision",
                expected: L4LiveRiskPreTradeDecisionOutcome.incidentStop.rawValue,
                actual: riskEvidence.decisions.map { $0.outcome.rawValue }.joined(separator: ",")
            )
        }
        let source = try L4IncidentStopSourceEvidence(
            triggeredByRiskDecisionID: incidentDecision.decisionID,
            upstreamRiskOutcome: incidentDecision.outcome,
            reason: "GH-465 deterministic incident stop activates command shutdown gate"
        )
        return try activate(sourceEvidence: source, riskDecision: incidentDecision)
    }

    public func activate(
        sourceEvidence: L4IncidentStopSourceEvidence,
        riskDecision: L4LiveRiskPreTradeDecisionEvidence
    ) throws -> L4KillSwitchIncidentShutdownGateEvidence {
        guard runtimeBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runtimeBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard sourceEvidence.sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceEvidence",
                expected: "GH-465 source boundary held",
                actual: "mismatch"
            )
        }
        guard riskDecision.outcome == .incidentStop else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskDecision.outcome",
                expected: L4LiveRiskPreTradeDecisionOutcome.incidentStop.rawValue,
                actual: riskDecision.outcome.rawValue
            )
        }
        guard sourceEvidence.triggeredByRiskDecisionID == riskDecision.decisionID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceEvidence.triggeredByRiskDecisionID",
                expected: riskDecision.decisionID.rawValue,
                actual: sourceEvidence.triggeredByRiskDecisionID.rawValue
            )
        }

        let decisions = try L4LiveRiskPreTradeCommandKind.allCases.map { commandKind in
            try L4CommandShutdownGateDecisionEvidence(
                decisionID: Identifier.constant("gh-465-\(commandKind.rawValue)-shutdown-decision"),
                sourceEvidenceID: sourceEvidence.sourceEvidenceID,
                triggeredByRiskDecisionID: riskDecision.decisionID,
                commandKind: commandKind
            )
        }
        return try L4KillSwitchIncidentShutdownGateEvidence(
            sourceEvidence: sourceEvidence,
            decisions: decisions
        )
    }
}
