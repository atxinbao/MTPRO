import DomainModel
import ExecutionClient
import Foundation

/// L4OMSOrderLifecycleState 固定 GH-461 OMS 合同允许描述的 local order state。
///
/// 这些 state 只属于本地 OMS lifecycle contract taxonomy。当前 issue 不创建 production order
/// store，不提交真实订单，不消费真实 broker report，也不把 state transition 连接到 Live command surface。
public enum L4OMSOrderLifecycleState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accepted = "accepted"
    case submitted = "submitted"
    case partiallyFilled = "partially filled"
    case filled = "filled"
    case cancelled = "cancelled"
    case rejected = "rejected"
}

/// L4OMSOrderLifecycleTrigger 描述 GH-461 state machine 的触发来源。
///
/// Trigger 只说明 state transition contract 如何引用 GH-459 command evidence 和 GH-460 sandbox
/// report parser evidence；它不代表真实 broker callback、production execution report 或 OMS runtime。
public enum L4OMSOrderLifecycleTrigger: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandboxSubmitAccepted = "sandbox submit accepted"
    case sandboxPartialFillReport = "sandbox partial fill report"
    case sandboxFillReport = "sandbox fill report"
    case sandboxCancelAcknowledgement = "sandbox cancel acknowledgement"
    case sandboxRejectReport = "sandbox reject report"
    case rollbackIncidentEvidence = "rollback / incident evidence"
}

/// L4OMSForbiddenCapability 枚举 GH-461 定义合同时仍必须关闭的能力。
///
/// OMS 合同可以命名 lifecycle state 和非法转换 evidence，但不能实现 production order manager、
/// broker gateway、真实订单生命周期、reconciliation、Portfolio mutation 或 Live command surface。
public enum L4OMSForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionOrderManagerImplemented = "production order manager implemented"
    case realOrderSubmissionEnabled = "real order submission enabled"
    case directExecutionClientBypass = "direct ExecutionClient bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case productionBrokerReportConsumed = "production broker report consumed"
    case brokerGatewayTouched = "broker gateway touched"
    case realOrderStateStoreWritten = "real order state store written"
    case portfolioMutationProduced = "Portfolio mutation produced"
    case reconciliationRuntimeProduced = "reconciliation runtime produced"
    case liveCommandSurfaceTouched = "Live command surface touched"
}

/// L4OMSOrderStateTransitionRule 是 GH-461 的合法 state transition 合同行。
///
/// Rule 只定义 allowed graph，不执行状态变更。真正的本地 transition evidence 留给 GH-462；ExecutionEngine
/// wiring 留给 GH-463，reconciliation 留给 GH-466。
public struct L4OMSOrderStateTransitionRule: Codable, Equatable, Sendable {
    public let fromState: L4OMSOrderLifecycleState
    public let trigger: L4OMSOrderLifecycleTrigger
    public let toState: L4OMSOrderLifecycleState
    public let sourceEvidence: String
    public let requiresExecutionEngineCoordination: Bool
    public let requiresExecutionClientEvidence: Bool
    public let writesPortfolioProjection: Bool
    public let performsReconciliation: Bool

    public init(
        fromState: L4OMSOrderLifecycleState,
        trigger: L4OMSOrderLifecycleTrigger,
        toState: L4OMSOrderLifecycleState,
        sourceEvidence: String,
        requiresExecutionEngineCoordination: Bool = true,
        requiresExecutionClientEvidence: Bool = true,
        writesPortfolioProjection: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        guard sourceEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceEvidence",
                expected: "non-empty GH-461 transition evidence source",
                actual: "empty"
            )
        }
        guard Self.allowedPairs.contains(Self.key(from: fromState, trigger: trigger, to: toState)) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transition",
                expected: Self.allowedPairs.sorted().joined(separator: ","),
                actual: Self.key(from: fromState, trigger: trigger, to: toState)
            )
        }
        guard requiresExecutionEngineCoordination else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("requiresExecutionEngineCoordination")
        }
        guard requiresExecutionClientEvidence else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("requiresExecutionClientEvidence")
        }
        guard writesPortfolioProjection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("writesPortfolioProjection")
        }
        guard performsReconciliation == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("performsReconciliation")
        }

        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sourceEvidence = sourceEvidence
        self.requiresExecutionEngineCoordination = requiresExecutionEngineCoordination
        self.requiresExecutionClientEvidence = requiresExecutionClientEvidence
        self.writesPortfolioProjection = writesPortfolioProjection
        self.performsReconciliation = performsReconciliation
    }

    fileprivate init(
        trustedFromState fromState: L4OMSOrderLifecycleState,
        trigger: L4OMSOrderLifecycleTrigger,
        toState: L4OMSOrderLifecycleState,
        sourceEvidence: String
    ) {
        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sourceEvidence = sourceEvidence
        self.requiresExecutionEngineCoordination = true
        self.requiresExecutionClientEvidence = true
        self.writesPortfolioProjection = false
        self.performsReconciliation = false
    }

    private static let allowedPairs = Set(
        L4OMSOrderLifecycleContract.requiredTransitionRules.map {
            key(from: $0.fromState, trigger: $0.trigger, to: $0.toState)
        }
    )

    private static func key(
        from: L4OMSOrderLifecycleState,
        trigger: L4OMSOrderLifecycleTrigger,
        to: L4OMSOrderLifecycleState
    ) -> String {
        "\(from.rawValue)|\(trigger.rawValue)|\(to.rawValue)"
    }
}

/// L4OMSIllegalTransitionEvidence 固定 GH-461 必须拒绝的非法转换样本。
///
/// Evidence 只用于 contract / test 证明 illegal transition 会被识别；它不执行 rollback，不改写订单状态，
/// 不触发 incident automation，也不尝试 reconciliation。
public struct L4OMSIllegalTransitionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let fromState: L4OMSOrderLifecycleState
    public let attemptedTrigger: L4OMSOrderLifecycleTrigger
    public let attemptedToState: L4OMSOrderLifecycleState
    public let rejectionReason: String
    public let rollbackEvidenceRequired: Bool
    public let incidentEvidenceRequired: Bool
    public let mutatesOrderState: Bool

    public init(
        evidenceID: Identifier,
        fromState: L4OMSOrderLifecycleState,
        attemptedTrigger: L4OMSOrderLifecycleTrigger,
        attemptedToState: L4OMSOrderLifecycleState,
        rejectionReason: String,
        rollbackEvidenceRequired: Bool = true,
        incidentEvidenceRequired: Bool = true,
        mutatesOrderState: Bool = false
    ) throws {
        guard rejectionReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "rejectionReason",
                expected: "non-empty illegal transition rejection reason",
                actual: "empty"
            )
        }
        guard L4OMSOrderStateTransitionRule.allowedTransition(
            from: fromState,
            trigger: attemptedTrigger,
            to: attemptedToState
        ) == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "illegalTransition",
                expected: "transition not present in GH-461 allowed graph",
                actual: "\(fromState.rawValue)->\(attemptedToState.rawValue)"
            )
        }
        guard rollbackEvidenceRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("rollbackEvidenceRequired")
        }
        guard incidentEvidenceRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("incidentEvidenceRequired")
        }
        guard mutatesOrderState == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("mutatesOrderState")
        }

        self.evidenceID = evidenceID
        self.fromState = fromState
        self.attemptedTrigger = attemptedTrigger
        self.attemptedToState = attemptedToState
        self.rejectionReason = rejectionReason
        self.rollbackEvidenceRequired = rollbackEvidenceRequired
        self.incidentEvidenceRequired = incidentEvidenceRequired
        self.mutatesOrderState = mutatesOrderState
    }
}

/// L4OMSRollbackIncidentEvidence 定义 GH-461 rollback / incident evidence 合同。
///
/// 该 evidence 只说明非法转换和异常状态需要审计证据；它不执行自动撤单、不恢复订单、不重放生产
/// broker report，也不启动 incident automation。
public struct L4OMSRollbackIncidentEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let rollbackEvidenceDefined: Bool
    public let incidentEvidenceDefined: Bool
    public let automaticRetryEnabled: Bool
    public let productionOrderMutationEnabled: Bool
    public let reconciliationRuntimeEnabled: Bool

    public var boundaryHeld: Bool {
        rollbackEvidenceDefined
            && incidentEvidenceDefined
            && automaticRetryEnabled == false
            && productionOrderMutationEnabled == false
            && reconciliationRuntimeEnabled == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-461-oms-rollback-incident-evidence"),
        rollbackEvidenceDefined: Bool = true,
        incidentEvidenceDefined: Bool = true,
        automaticRetryEnabled: Bool = false,
        productionOrderMutationEnabled: Bool = false,
        reconciliationRuntimeEnabled: Bool = false
    ) throws {
        guard rollbackEvidenceDefined else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("rollbackEvidenceDefined")
        }
        guard incidentEvidenceDefined else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("incidentEvidenceDefined")
        }
        for forbiddenFlag in [
            ("automaticRetryEnabled", automaticRetryEnabled),
            ("productionOrderMutationEnabled", productionOrderMutationEnabled),
            ("reconciliationRuntimeEnabled", reconciliationRuntimeEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.rollbackEvidenceDefined = rollbackEvidenceDefined
        self.incidentEvidenceDefined = incidentEvidenceDefined
        self.automaticRetryEnabled = automaticRetryEnabled
        self.productionOrderMutationEnabled = productionOrderMutationEnabled
        self.reconciliationRuntimeEnabled = reconciliationRuntimeEnabled
    }
}

/// L4OMSOrderLifecycleContract 是 GH-461 的 OMS order lifecycle state machine 合同。
///
/// 合同定义 local order state、sandbox broker report relationship、illegal transition evidence 和
/// ExecutionEngine / ExecutionClient / Portfolio 边界。它不是 production OMS implementation，不写真实
/// order store，不提交 / 撤销 / 替换真实订单，不执行 reconciliation。
public struct L4OMSOrderLifecycleContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let parserEvidence: L4ExecutionClientSandboxReportReplayEvidence
    public let states: [L4OMSOrderLifecycleState]
    public let transitionRules: [L4OMSOrderStateTransitionRule]
    public let illegalTransitionEvidence: [L4OMSIllegalTransitionEvidence]
    public let rollbackIncidentEvidence: L4OMSRollbackIncidentEvidence
    public let forbiddenCapabilities: [L4OMSForbiddenCapability]
    public let validationAnchors: [String]
    public let executionEngineOwnsLocalLifecycleCoordination: Bool
    public let executionClientOnlyProvidesSandboxReportEvidence: Bool
    public let portfolioConsumesProjectionOnly: Bool
    public let riskEnginePreTradeBoundaryRequired: Bool
    public let implementsProductionOrderManager: Bool
    public let submitsRealOrder: Bool
    public let consumesProductionBrokerReport: Bool
    public let bypassesRiskEngine: Bool
    public let touchesBrokerGateway: Bool
    public let mutatesPortfolio: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-461"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-458", "GH-460"]
            && parserEvidence.reportParserEvidenceHeld
            && states == L4OMSOrderLifecycleState.allCases
            && transitionRules == Self.requiredTransitionRules
            && illegalTransitionEvidence == Self.requiredIllegalTransitionEvidence
            && rollbackIncidentEvidence.boundaryHeld
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && executionEngineOwnsLocalLifecycleCoordination
            && executionClientOnlyProvidesSandboxReportEvidence
            && portfolioConsumesProjectionOnly
            && riskEnginePreTradeBoundaryRequired
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsProductionOrderManager,
            submitsRealOrder,
            consumesProductionBrokerReport,
            bypassesRiskEngine,
            touchesBrokerGateway,
            mutatesPortfolio,
            performsReconciliation,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-461-oms-order-lifecycle-contract"),
        issueID: Identifier = Identifier.constant("GH-461"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-458"),
            Identifier.constant("GH-460")
        ],
        parserEvidence: L4ExecutionClientSandboxReportReplayEvidence? = nil,
        states: [L4OMSOrderLifecycleState] = L4OMSOrderLifecycleState.allCases,
        transitionRules: [L4OMSOrderStateTransitionRule] = Self.requiredTransitionRules,
        illegalTransitionEvidence: [L4OMSIllegalTransitionEvidence] = Self.requiredIllegalTransitionEvidence,
        rollbackIncidentEvidence: L4OMSRollbackIncidentEvidence? = nil,
        forbiddenCapabilities: [L4OMSForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        executionEngineOwnsLocalLifecycleCoordination: Bool = true,
        executionClientOnlyProvidesSandboxReportEvidence: Bool = true,
        portfolioConsumesProjectionOnly: Bool = true,
        riskEnginePreTradeBoundaryRequired: Bool = true,
        implementsProductionOrderManager: Bool = false,
        submitsRealOrder: Bool = false,
        consumesProductionBrokerReport: Bool = false,
        bypassesRiskEngine: Bool = false,
        touchesBrokerGateway: Bool = false,
        mutatesPortfolio: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-461" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-461",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-458", "GH-460"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-458,GH-460",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        let resolvedParserEvidence = try parserEvidence
            ?? L4ExecutionClientSandboxReportParser.deterministicFixture().deterministicReplayEvidence()
        guard resolvedParserEvidence.reportParserEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-460 parser evidence held",
                actual: "mismatch"
            )
        }
        let resolvedRollbackIncidentEvidence = try rollbackIncidentEvidence ?? L4OMSRollbackIncidentEvidence()
        guard states == L4OMSOrderLifecycleState.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "states",
                expected: L4OMSOrderLifecycleState.allCases.map(\.rawValue).joined(separator: ","),
                actual: states.map(\.rawValue).joined(separator: ",")
            )
        }
        guard transitionRules == Self.requiredTransitionRules else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transitionRules",
                expected: Self.requiredTransitionRules.map(\.transitionKey).joined(separator: ","),
                actual: transitionRules.map(\.transitionKey).joined(separator: ",")
            )
        }
        guard illegalTransitionEvidence == Self.requiredIllegalTransitionEvidence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "illegalTransitionEvidence",
                expected: Self.requiredIllegalTransitionEvidence.map(\.transitionKey).joined(separator: ","),
                actual: illegalTransitionEvidence.map(\.transitionKey).joined(separator: ",")
            )
        }
        guard resolvedRollbackIncidentEvidence.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "rollbackIncidentEvidence",
                expected: "rollback / incident evidence boundary held",
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
            ("executionEngineOwnsLocalLifecycleCoordination", executionEngineOwnsLocalLifecycleCoordination),
            ("executionClientOnlyProvidesSandboxReportEvidence", executionClientOnlyProvidesSandboxReportEvidence),
            ("portfolioConsumesProjectionOnly", portfolioConsumesProjectionOnly),
            ("riskEnginePreTradeBoundaryRequired", riskEnginePreTradeBoundaryRequired)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("implementsProductionOrderManager", implementsProductionOrderManager),
            ("submitsRealOrder", submitsRealOrder),
            ("consumesProductionBrokerReport", consumesProductionBrokerReport),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("mutatesPortfolio", mutatesPortfolio),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.parserEvidence = resolvedParserEvidence
        self.states = states
        self.transitionRules = transitionRules
        self.illegalTransitionEvidence = illegalTransitionEvidence
        self.rollbackIncidentEvidence = resolvedRollbackIncidentEvidence
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.executionEngineOwnsLocalLifecycleCoordination = executionEngineOwnsLocalLifecycleCoordination
        self.executionClientOnlyProvidesSandboxReportEvidence = executionClientOnlyProvidesSandboxReportEvidence
        self.portfolioConsumesProjectionOnly = portfolioConsumesProjectionOnly
        self.riskEnginePreTradeBoundaryRequired = riskEnginePreTradeBoundaryRequired
        self.implementsProductionOrderManager = implementsProductionOrderManager
        self.submitsRealOrder = submitsRealOrder
        self.consumesProductionBrokerReport = consumesProductionBrokerReport
        self.bypassesRiskEngine = bypassesRiskEngine
        self.touchesBrokerGateway = touchesBrokerGateway
        self.mutatesPortfolio = mutatesPortfolio
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public func isAllowedTransition(
        from fromState: L4OMSOrderLifecycleState,
        trigger: L4OMSOrderLifecycleTrigger,
        to toState: L4OMSOrderLifecycleState
    ) -> Bool {
        transitionRules.contains {
            $0.fromState == fromState && $0.trigger == trigger && $0.toState == toState
        }
    }

    public static func deterministicFixture() throws -> L4OMSOrderLifecycleContract {
        try L4OMSOrderLifecycleContract()
    }

    public static let requiredTransitionRules: [L4OMSOrderStateTransitionRule] = [
        L4OMSOrderStateTransitionRule(
            trustedFromState: .accepted,
            trigger: .sandboxSubmitAccepted,
            toState: .submitted,
            sourceEvidence: "GH-459 deterministic sandbox submit command evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .submitted,
            trigger: .sandboxPartialFillReport,
            toState: .partiallyFilled,
            sourceEvidence: "GH-460 partial fill parser evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .partiallyFilled,
            trigger: .sandboxFillReport,
            toState: .filled,
            sourceEvidence: "GH-460 fill parser evidence after partial fill"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .submitted,
            trigger: .sandboxFillReport,
            toState: .filled,
            sourceEvidence: "GH-460 fill parser evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .submitted,
            trigger: .sandboxCancelAcknowledgement,
            toState: .cancelled,
            sourceEvidence: "GH-460 cancel acknowledgement parser evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .partiallyFilled,
            trigger: .sandboxCancelAcknowledgement,
            toState: .cancelled,
            sourceEvidence: "GH-460 cancel acknowledgement after partial fill evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .submitted,
            trigger: .sandboxRejectReport,
            toState: .rejected,
            sourceEvidence: "GH-460 reject parser evidence"
        ),
        L4OMSOrderStateTransitionRule(
            trustedFromState: .accepted,
            trigger: .sandboxRejectReport,
            toState: .rejected,
            sourceEvidence: "GH-460 reject parser evidence before submitted state"
        )
    ]

    public static let requiredIllegalTransitionEvidence: [L4OMSIllegalTransitionEvidence] = [
        L4OMSIllegalTransitionEvidence.trustedFixture(
            evidenceID: Identifier.constant("gh-461-illegal-filled-to-submitted"),
            fromState: .filled,
            attemptedTrigger: .sandboxSubmitAccepted,
            attemptedToState: .submitted,
            rejectionReason: "filled is terminal before GH-462 local transition evidence"
        ),
        L4OMSIllegalTransitionEvidence.trustedFixture(
            evidenceID: Identifier.constant("gh-461-illegal-cancelled-to-partial"),
            fromState: .cancelled,
            attemptedTrigger: .sandboxPartialFillReport,
            attemptedToState: .partiallyFilled,
            rejectionReason: "cancelled cannot accept new fill report"
        ),
        L4OMSIllegalTransitionEvidence.trustedFixture(
            evidenceID: Identifier.constant("gh-461-illegal-rejected-to-filled"),
            fromState: .rejected,
            attemptedTrigger: .sandboxFillReport,
            attemptedToState: .filled,
            rejectionReason: "rejected is terminal and cannot become filled"
        )
    ]

    public static let requiredForbiddenCapabilities = L4OMSForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE",
        "GH-461-LOCAL-ORDER-BROKER-REPORT-RELATIONSHIP",
        "GH-461-ILLEGAL-TRANSITION-EVIDENCE",
        "GH-461-OMS-ENGINE-CLIENT-PORTFOLIO-BOUNDARY",
        "GH-461-ROLLBACK-INCIDENT-EVIDENCE",
        "TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT"
    ]
}

private extension L4OMSOrderStateTransitionRule {
    var transitionKey: String {
        "\(fromState.rawValue)|\(trigger.rawValue)|\(toState.rawValue)"
    }

    static func allowedTransition(
        from fromState: L4OMSOrderLifecycleState,
        trigger: L4OMSOrderLifecycleTrigger,
        to toState: L4OMSOrderLifecycleState
    ) -> Bool {
        L4OMSOrderLifecycleContract.requiredTransitionRules.contains {
            $0.fromState == fromState && $0.trigger == trigger && $0.toState == toState
        }
    }
}

private extension L4OMSIllegalTransitionEvidence {
    var transitionKey: String {
        "\(fromState.rawValue)|\(attemptedTrigger.rawValue)|\(attemptedToState.rawValue)"
    }

    static func trustedFixture(
        evidenceID: Identifier,
        fromState: L4OMSOrderLifecycleState,
        attemptedTrigger: L4OMSOrderLifecycleTrigger,
        attemptedToState: L4OMSOrderLifecycleState,
        rejectionReason: String
    ) -> L4OMSIllegalTransitionEvidence {
        L4OMSIllegalTransitionEvidence(
            trustedEvidenceID: evidenceID,
            fromState: fromState,
            attemptedTrigger: attemptedTrigger,
            attemptedToState: attemptedToState,
            rejectionReason: rejectionReason
        )
    }

    init(
        trustedEvidenceID evidenceID: Identifier,
        fromState: L4OMSOrderLifecycleState,
        attemptedTrigger: L4OMSOrderLifecycleTrigger,
        attemptedToState: L4OMSOrderLifecycleState,
        rejectionReason: String
    ) {
        self.evidenceID = evidenceID
        self.fromState = fromState
        self.attemptedTrigger = attemptedTrigger
        self.attemptedToState = attemptedToState
        self.rejectionReason = rejectionReason
        self.rollbackEvidenceRequired = true
        self.incidentEvidenceRequired = true
        self.mutatesOrderState = false
    }
}
