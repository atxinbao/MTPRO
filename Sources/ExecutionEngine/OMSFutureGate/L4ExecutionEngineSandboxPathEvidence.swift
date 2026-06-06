import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// L4ExecutionEngineSandboxProposalSource 固定 GH-463 允许进入 ExecutionEngine 的 proposal 来源。
///
/// 当前只允许 RiskEngine 已放行的 command proposal。Trader、Strategy 或 Live PRO Console 直连
/// ExecutionClient 都属于 forbidden capability，不能绕过 ExecutionEngine / OMS future gate。
public enum L4ExecutionEngineSandboxProposalSource: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskEngineApproved = "RiskEngine approved command proposal"
    case directTrader = "direct Trader command"
    case directStrategy = "direct Strategy command"
    case liveProConsole = "Live PRO Console command"
}

/// L4ExecutionEngineSandboxPathForbiddenCapability 枚举 GH-463 必须继续关闭的能力。
///
/// GH-463 只能证明 ExecutionEngine 到 sandbox ExecutionClient 的受控输出路径。它不打开 production
/// execution，不实现真实 broker adapter，不绕过 OMS，不执行 reconciliation，也不暴露 live command UI。
public enum L4ExecutionEngineSandboxPathForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case directTraderToExecutionClient = "direct Trader to ExecutionClient"
    case directStrategyToExecutionClient = "direct Strategy to ExecutionClient"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case productionExecutionEnabled = "production execution enabled"
    case productionVenueTouched = "production venue touched"
    case signedRequestGenerated = "signed request generated"
    case brokerGatewayTouched = "broker gateway touched"
    case omsBypassed = "OMS bypassed"
    case realOrderLifecycleTouched = "real order lifecycle touched"
    case portfolioMutationProduced = "Portfolio mutation produced"
    case reconciliationRuntimeProduced = "reconciliation runtime produced"
}

/// L4ExecutionEngineSandboxPathEventKind 描述 GH-463 evidence 内部记录的事件类型。
///
/// 这些 event 只是 deterministic audit evidence，不发布到真实 broker，不代表 production execution report，
/// 也不推进 Portfolio projection 或 reconciliation。
public enum L4ExecutionEngineSandboxPathEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case commandProposalAccepted = "command proposal accepted"
    case sandboxRequestDispatched = "sandbox request dispatched"
    case sandboxResponseRecorded = "sandbox response recorded"
    case localTransitionEvidenceLinked = "local transition evidence linked"
}

/// L4ExecutionEngineSandboxCommandProposal 是 GH-463 的 RiskEngine-approved command proposal。
///
/// Proposal 只表达 RiskEngine 已放行后交给 ExecutionEngine 的 sandbox command 输入。它不能来自
/// Trader / Strategy direct call，不能跳过 OMS local transition evidence，也不能携带 production venue。
public struct L4ExecutionEngineSandboxCommandProposal: Codable, Equatable, Sendable {
    public let proposalID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let source: L4ExecutionEngineSandboxProposalSource
    public let commandKind: L4ExecutionClientSandboxCommandKind
    public let riskEngineDecisionID: Identifier
    public let omsTransitionEvidenceID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let quantity: String
    public let limitPrice: String
    public let reason: String
    public let riskEngineApproved: Bool
    public let routedThroughExecutionEngine: Bool
    public let routedThroughOMS: Bool
    public let directToExecutionClient: Bool
    public let productionVenueTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public var proposalBoundaryHeld: Bool {
        issueID.rawValue == "GH-463"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-459", "GH-461", "GH-462"]
            && source == .riskEngineApproved
            && riskEngineApproved
            && routedThroughExecutionEngine
            && routedThroughOMS
            && directToExecutionClient == false
            && productionVenueTouched == false
            && liveCommandSurfaceTouched == false
    }

    public init(
        proposalID: Identifier,
        issueID: Identifier = Identifier.constant("GH-463"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-459"),
            Identifier.constant("GH-461"),
            Identifier.constant("GH-462")
        ],
        source: L4ExecutionEngineSandboxProposalSource = .riskEngineApproved,
        commandKind: L4ExecutionClientSandboxCommandKind,
        riskEngineDecisionID: Identifier,
        omsTransitionEvidenceID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        quantity: String,
        limitPrice: String,
        reason: String,
        riskEngineApproved: Bool = true,
        routedThroughExecutionEngine: Bool = true,
        routedThroughOMS: Bool = true,
        directToExecutionClient: Bool = false,
        productionVenueTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-463" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-463",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-459", "GH-461", "GH-462"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-459,GH-461,GH-462",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard source == .riskEngineApproved else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(source.rawValue)
        }
        for requiredField in [
            ("symbol", symbol),
            ("quantity", quantity),
            ("limitPrice", limitPrice),
            ("reason", reason)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty GH-463 sandbox command proposal value",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("riskEngineApproved", riskEngineApproved),
            ("routedThroughExecutionEngine", routedThroughExecutionEngine),
            ("routedThroughOMS", routedThroughOMS)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("directToExecutionClient", directToExecutionClient),
            ("productionVenueTouched", productionVenueTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.proposalID = proposalID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.source = source
        self.commandKind = commandKind
        self.riskEngineDecisionID = riskEngineDecisionID
        self.omsTransitionEvidenceID = omsTransitionEvidenceID
        self.clientOrderID = clientOrderID
        self.symbol = symbol
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.reason = reason
        self.riskEngineApproved = riskEngineApproved
        self.routedThroughExecutionEngine = routedThroughExecutionEngine
        self.routedThroughOMS = routedThroughOMS
        self.directToExecutionClient = directToExecutionClient
        self.productionVenueTouched = productionVenueTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    /// 将 GH-463 proposal 翻译成 GH-459 sandbox request envelope。
    ///
    /// 该转换只发生在 ExecutionEngine 内部 evidence 中，不生成 signed request，不携带 secret，
    /// 不触碰 production venue 或真实 broker gateway。
    public func sandboxEnvelope() throws -> L4ExecutionClientSandboxRequestEnvelope {
        guard proposalBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposalBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try L4ExecutionClientSandboxRequestEnvelope(
            envelopeID: Identifier.constant("gh-463-\(commandKind.rawValue)-sandbox-request-envelope"),
            commandKind: commandKind,
            clientOrderID: clientOrderID,
            symbol: symbol,
            quantity: quantity,
            limitPrice: limitPrice,
            reason: reason
        )
    }
}

/// L4ExecutionEngineSandboxPathEvent 是 GH-463 的 command / response / execution event evidence。
///
/// Event 只记录 ExecutionEngine handoff、sandbox request dispatch、sandbox response 和 OMS local transition
/// evidence 之间的关系。它不是 execution report runtime，也不写 Portfolio 或 reconciliation state。
public struct L4ExecutionEngineSandboxPathEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let issueID: Identifier
    public let proposalID: Identifier
    public let eventKind: L4ExecutionEngineSandboxPathEventKind
    public let commandKind: L4ExecutionClientSandboxCommandKind
    public let responseID: Identifier
    public let omsTransitionEvidenceID: Identifier
    public let sequence: Int
    public let deterministicAuditEvidence: Bool
    public let writesPortfolioProjection: Bool
    public let performsReconciliation: Bool
    public let touchesLiveCommandSurface: Bool

    public var eventBoundaryHeld: Bool {
        issueID.rawValue == "GH-463"
            && sequence > 0
            && deterministicAuditEvidence
            && writesPortfolioProjection == false
            && performsReconciliation == false
            && touchesLiveCommandSurface == false
    }

    public init(
        eventID: Identifier,
        issueID: Identifier = Identifier.constant("GH-463"),
        proposalID: Identifier,
        eventKind: L4ExecutionEngineSandboxPathEventKind,
        commandKind: L4ExecutionClientSandboxCommandKind,
        responseID: Identifier,
        omsTransitionEvidenceID: Identifier,
        sequence: Int,
        deterministicAuditEvidence: Bool = true,
        writesPortfolioProjection: Bool = false,
        performsReconciliation: Bool = false,
        touchesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-463" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-463",
                actual: issueID.rawValue
            )
        }
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "positive GH-463 event sequence",
                actual: "\(sequence)"
            )
        }
        guard deterministicAuditEvidence else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("deterministicAuditEvidence")
        }
        for forbiddenFlag in [
            ("writesPortfolioProjection", writesPortfolioProjection),
            ("performsReconciliation", performsReconciliation),
            ("touchesLiveCommandSurface", touchesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.eventID = eventID
        self.issueID = issueID
        self.proposalID = proposalID
        self.eventKind = eventKind
        self.commandKind = commandKind
        self.responseID = responseID
        self.omsTransitionEvidenceID = omsTransitionEvidenceID
        self.sequence = sequence
        self.deterministicAuditEvidence = deterministicAuditEvidence
        self.writesPortfolioProjection = writesPortfolioProjection
        self.performsReconciliation = performsReconciliation
        self.touchesLiveCommandSurface = touchesLiveCommandSurface
    }
}

/// L4ExecutionEngineSandboxPathEvidence 汇总 GH-463 ExecutionEngine -> ExecutionClient sandbox path。
///
/// Evidence 必须证明 proposal 已经 RiskEngine 放行、ExecutionEngine 持有 handoff、OMS local transition
/// evidence 未被绕过、sandbox ExecutionClient 已被调用并返回 response。它不授权 production execution。
public struct L4ExecutionEngineSandboxPathEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let riskEngineBoundary: RiskEngineTargetBoundary
    public let sandboxAdapter: L4ExecutionClientSandboxVenueAdapter
    public let localTransitionEvidence: L4OMSLocalOrderTransitionEvidence
    public let proposals: [L4ExecutionEngineSandboxCommandProposal]
    public let responses: [L4ExecutionClientSandboxCommandResponse]
    public let events: [L4ExecutionEngineSandboxPathEvent]
    public let forbiddenCapabilities: [L4ExecutionEngineSandboxPathForbiddenCapability]
    public let validationAnchors: [String]
    public let commandEvidenceTraceable: Bool
    public let responseEvidenceTraceable: Bool
    public let executionEventEvidenceTraceable: Bool
    public let directTraderStrategyAccessRejected: Bool
    public let omsPathRequired: Bool
    public let productionExecutionDisabled: Bool
    public let performsReconciliation: Bool
    public let mutatesPortfolio: Bool
    public let exposesLiveCommandSurface: Bool

    public var sandboxPathEvidenceHeld: Bool {
        issueID.rawValue == "GH-463"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-459", "GH-461", "GH-462"]
            && riskEngineBoundary.dependencyDirectionHeld
            && sandboxAdapter.sandboxAdapterBoundaryHeld
            && localTransitionEvidence.transitionEvidenceHeld
            && Set(proposals.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && Set(responses.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && Set(events.map(\.eventKind)) == Set(L4ExecutionEngineSandboxPathEventKind.allCases)
            && proposals.allSatisfy(\.proposalBoundaryHeld)
            && responses.allSatisfy(\.acceptedBySandbox)
            && events.allSatisfy(\.eventBoundaryHeld)
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && commandEvidenceTraceable
            && responseEvidenceTraceable
            && executionEventEvidenceTraceable
            && directTraderStrategyAccessRejected
            && omsPathRequired
            && productionExecutionDisabled
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            performsReconciliation,
            mutatesPortfolio,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-463-executionengine-executionclient-sandbox-path-evidence"),
        issueID: Identifier = Identifier.constant("GH-463"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-459"),
            Identifier.constant("GH-461"),
            Identifier.constant("GH-462")
        ],
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        sandboxAdapter: L4ExecutionClientSandboxVenueAdapter,
        localTransitionEvidence: L4OMSLocalOrderTransitionEvidence,
        proposals: [L4ExecutionEngineSandboxCommandProposal],
        responses: [L4ExecutionClientSandboxCommandResponse],
        events: [L4ExecutionEngineSandboxPathEvent],
        forbiddenCapabilities: [L4ExecutionEngineSandboxPathForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        commandEvidenceTraceable: Bool = true,
        responseEvidenceTraceable: Bool = true,
        executionEventEvidenceTraceable: Bool = true,
        directTraderStrategyAccessRejected: Bool = true,
        omsPathRequired: Bool = true,
        productionExecutionDisabled: Bool = true,
        performsReconciliation: Bool = false,
        mutatesPortfolio: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-463" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-463",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-459", "GH-461", "GH-462"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-459,GH-461,GH-462",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard riskEngineBoundary.dependencyDirectionHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskEngineBoundary",
                expected: "RiskEngine pre-execution boundary held",
                actual: "mismatch"
            )
        }
        guard sandboxAdapter.sandboxAdapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxAdapter",
                expected: "GH-459 sandbox adapter boundary held",
                actual: "mismatch"
            )
        }
        guard localTransitionEvidence.transitionEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "localTransitionEvidence",
                expected: "GH-462 local transition evidence held",
                actual: "mismatch"
            )
        }
        guard Set(proposals.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposals",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: proposals.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(responses.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "responses",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: responses.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(events.map(\.eventKind)) == Set(L4ExecutionEngineSandboxPathEventKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "events",
                expected: L4ExecutionEngineSandboxPathEventKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: events.map { $0.eventKind.rawValue }.joined(separator: ",")
            )
        }
        guard proposals.allSatisfy(\.proposalBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposals",
                expected: "all GH-463 proposals held",
                actual: "mismatch"
            )
        }
        guard events.allSatisfy(\.eventBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "events",
                expected: "all GH-463 events held",
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
            ("commandEvidenceTraceable", commandEvidenceTraceable),
            ("responseEvidenceTraceable", responseEvidenceTraceable),
            ("executionEventEvidenceTraceable", executionEventEvidenceTraceable),
            ("directTraderStrategyAccessRejected", directTraderStrategyAccessRejected),
            ("omsPathRequired", omsPathRequired),
            ("productionExecutionDisabled", productionExecutionDisabled)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("performsReconciliation", performsReconciliation),
            ("mutatesPortfolio", mutatesPortfolio),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.riskEngineBoundary = riskEngineBoundary
        self.sandboxAdapter = sandboxAdapter
        self.localTransitionEvidence = localTransitionEvidence
        self.proposals = proposals
        self.responses = responses
        self.events = events
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.commandEvidenceTraceable = commandEvidenceTraceable
        self.responseEvidenceTraceable = responseEvidenceTraceable
        self.executionEventEvidenceTraceable = executionEventEvidenceTraceable
        self.directTraderStrategyAccessRejected = directTraderStrategyAccessRejected
        self.omsPathRequired = omsPathRequired
        self.productionExecutionDisabled = productionExecutionDisabled
        self.performsReconciliation = performsReconciliation
        self.mutatesPortfolio = mutatesPortfolio
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredForbiddenCapabilities = L4ExecutionEngineSandboxPathForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-463-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH",
        "GH-463-RISKENGINE-APPROVED-COMMAND-PROPOSAL",
        "GH-463-SANDBOX-EXECUTIONCLIENT-HANDOFF",
        "GH-463-COMMAND-RESPONSE-EVENT-EVIDENCE",
        "GH-463-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT",
        "TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH"
    ]
}

/// L4ExecutionEngineSandboxPathCoordinator 生成 GH-463 deterministic sandbox path evidence。
///
/// Coordinator 是审计夹具，不是 production ExecutionEngine runtime。它只在本地把 RiskEngine-approved
/// proposals 交给 GH-459 sandbox adapter，并关联 GH-462 local transition evidence。
public struct L4ExecutionEngineSandboxPathCoordinator: Codable, Equatable, Sendable {
    public let coordinatorID: Identifier
    public let riskEngineBoundary: RiskEngineTargetBoundary
    public let sandboxAdapter: L4ExecutionClientSandboxVenueAdapter
    public let localTransitionEvidence: L4OMSLocalOrderTransitionEvidence
    public let productionExecutionEnabled: Bool
    public let directTraderAccessAllowed: Bool
    public let directStrategyAccessAllowed: Bool
    public let skipsOMS: Bool
    public let performsReconciliation: Bool
    public let exposesLiveCommandSurface: Bool

    public var coordinatorBoundaryHeld: Bool {
        riskEngineBoundary.dependencyDirectionHeld
            && sandboxAdapter.sandboxAdapterBoundaryHeld
            && localTransitionEvidence.transitionEvidenceHeld
            && productionExecutionEnabled == false
            && directTraderAccessAllowed == false
            && directStrategyAccessAllowed == false
            && skipsOMS == false
            && performsReconciliation == false
            && exposesLiveCommandSurface == false
    }

    public init(
        coordinatorID: Identifier = Identifier.constant("gh-463-executionengine-sandbox-path-coordinator"),
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        sandboxAdapter: L4ExecutionClientSandboxVenueAdapter? = nil,
        localTransitionEvidence: L4OMSLocalOrderTransitionEvidence? = nil,
        productionExecutionEnabled: Bool = false,
        directTraderAccessAllowed: Bool = false,
        directStrategyAccessAllowed: Bool = false,
        skipsOMS: Bool = false,
        performsReconciliation: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        let resolvedAdapter = try sandboxAdapter ?? L4ExecutionClientSandboxVenueAdapter.deterministicFixture()
        let resolvedTransitionEvidence = try localTransitionEvidence
            ?? L4OMSLocalOrderTransitionEvidenceBuilder.deterministicFixture().deterministicEvidence()
        guard riskEngineBoundary.dependencyDirectionHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskEngineBoundary",
                expected: "RiskEngine pre-execution boundary held",
                actual: "mismatch"
            )
        }
        guard resolvedAdapter.sandboxAdapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxAdapter",
                expected: "GH-459 sandbox adapter boundary held",
                actual: "mismatch"
            )
        }
        guard resolvedTransitionEvidence.transitionEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "localTransitionEvidence",
                expected: "GH-462 local transition evidence held",
                actual: "mismatch"
            )
        }
        for forbiddenFlag in [
            ("productionExecutionEnabled", productionExecutionEnabled),
            ("directTraderAccessAllowed", directTraderAccessAllowed),
            ("directStrategyAccessAllowed", directStrategyAccessAllowed),
            ("skipsOMS", skipsOMS),
            ("performsReconciliation", performsReconciliation),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.coordinatorID = coordinatorID
        self.riskEngineBoundary = riskEngineBoundary
        self.sandboxAdapter = resolvedAdapter
        self.localTransitionEvidence = resolvedTransitionEvidence
        self.productionExecutionEnabled = productionExecutionEnabled
        self.directTraderAccessAllowed = directTraderAccessAllowed
        self.directStrategyAccessAllowed = directStrategyAccessAllowed
        self.skipsOMS = skipsOMS
        self.performsReconciliation = performsReconciliation
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static func deterministicFixture() throws -> L4ExecutionEngineSandboxPathCoordinator {
        try L4ExecutionEngineSandboxPathCoordinator()
    }

    /// 执行 GH-463 deterministic sandbox path，并返回 command / response / event evidence。
    public func deterministicEvidence() throws -> L4ExecutionEngineSandboxPathEvidence {
        guard coordinatorBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "coordinatorBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let proposals = try L4ExecutionClientSandboxCommandKind.allCases.map(makeProposal)
        let responses = try proposals.map(dispatch)
        let events = try zip(proposals, responses).enumerated().flatMap { index, pair in
            try makeEvents(proposal: pair.0, response: pair.1, baseSequence: index * 4)
        }
        return try L4ExecutionEngineSandboxPathEvidence(
            riskEngineBoundary: riskEngineBoundary,
            sandboxAdapter: sandboxAdapter,
            localTransitionEvidence: localTransitionEvidence,
            proposals: proposals,
            responses: responses,
            events: events
        )
    }

    /// 将单条 GH-463 proposal 派发到 GH-459 sandbox ExecutionClient adapter。
    public func dispatch(
        _ proposal: L4ExecutionEngineSandboxCommandProposal
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        guard coordinatorBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "coordinatorBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let envelope = try proposal.sandboxEnvelope()
        switch proposal.commandKind {
        case .submit:
            return try sandboxAdapter.submit(envelope)
        case .cancel:
            return try sandboxAdapter.cancel(envelope)
        case .replace:
            return try sandboxAdapter.replace(envelope)
        }
    }

    private func makeProposal(
        commandKind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionEngineSandboxCommandProposal {
        try L4ExecutionEngineSandboxCommandProposal(
            proposalID: Identifier.constant("gh-463-\(commandKind.rawValue)-risk-approved-proposal"),
            commandKind: commandKind,
            riskEngineDecisionID: Identifier.constant("gh-463-\(commandKind.rawValue)-risk-decision"),
            omsTransitionEvidenceID: localTransitionEvidence.evidenceID,
            clientOrderID: Identifier.constant("gh-463-\(commandKind.rawValue)-client-order"),
            symbol: "BTCUSDT",
            quantity: "0.0100",
            limitPrice: "42120.70",
            reason: "GH-463 ExecutionEngine handoff for sandbox \(commandKind.rawValue)"
        )
    }

    private func makeEvents(
        proposal: L4ExecutionEngineSandboxCommandProposal,
        response: L4ExecutionClientSandboxCommandResponse,
        baseSequence: Int
    ) throws -> [L4ExecutionEngineSandboxPathEvent] {
        try L4ExecutionEngineSandboxPathEventKind.allCases.enumerated().map { offset, eventKind in
            try L4ExecutionEngineSandboxPathEvent(
                eventID: Identifier.constant("gh-463-\(proposal.commandKind.rawValue)-\(eventKind.rawValue)-event"),
                proposalID: proposal.proposalID,
                eventKind: eventKind,
                commandKind: proposal.commandKind,
                responseID: response.responseID,
                omsTransitionEvidenceID: proposal.omsTransitionEvidenceID,
                sequence: baseSequence + offset + 1
            )
        }
    }
}
