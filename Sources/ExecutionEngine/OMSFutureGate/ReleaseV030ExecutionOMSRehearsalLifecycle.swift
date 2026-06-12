import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// ReleaseV030ExecutionOMSRehearsalMode 是 ExecutionEngine 本地 v0.3.0 rehearsal mode。
///
/// ExecutionEngine / OMS 在 #662 只消费 #661 RiskEngine decision evidence，生成本地状态机和
/// append-only replay evidence；它不调用 ExecutionClient、不连接 broker、不提交真实订单，也不授权
/// production cutover。
public enum ReleaseV030ExecutionOMSRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ReleaseV030OMSRehearsalState 固定 GH-662 必须覆盖的 OMS rehearsal 状态。
public enum ReleaseV030OMSRehearsalState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case created
    case accepted
    case submittedTestnetOrDryRun = "submitted-testnet-or-dry-run"
    case cancelled
    case rejected
    case filledSimulated = "filled-simulated"
}

/// ReleaseV030OMSRehearsalTrigger 描述本地 rehearsal transition 的触发原因。
public enum ReleaseV030OMSRehearsalTrigger: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskApproved = "risk approved"
    case riskRejected = "risk rejected"
    case dryRunSubmitted = "dry-run submitted"
    case cancelRequested = "cancel requested"
    case simulatedFillObserved = "simulated fill observed"
}

/// ReleaseV030OMSRehearsalPath 表达 GH-662 覆盖的 deterministic lifecycle path。
public enum ReleaseV030OMSRehearsalPath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case acceptedSubmittedFilled = "accepted-submitted-filled"
    case acceptedSubmittedCancelled = "accepted-submitted-cancelled"
    case riskRejected = "risk-rejected"

    public var requiresAllowedRiskDecision: Bool {
        self != .riskRejected
    }
}

/// ReleaseV030ExecutionOMSRehearsalRequirement 固定 GH-662 的验收要求。
public enum ReleaseV030ExecutionOMSRehearsalRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamRiskEngineRehearsalRequired = "upstream RiskEngine rehearsal evidence required"
    case riskApprovedIntentRequired = "risk-approved intent required"
    case omsLifecycleStateCoverageRequired = "OMS lifecycle state coverage required"
    case illegalTransitionRejectionRequired = "illegal transition rejection required"
    case omsReplayEvidenceRequired = "OMS replay evidence required"
    case noExecutionClientCall = "no ExecutionClient call"
    case noProductionOrderSubmission = "no production order submission"
}

/// ReleaseV030ExecutionOMSRehearsalForbiddenCapability 枚举 GH-662 必须拒绝的漂移。
public enum ReleaseV030ExecutionOMSRehearsalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case executionClientCall = "ExecutionClient call"
    case brokerGatewayAccess = "broker gateway access"
    case productionOMSRuntime = "production OMS runtime"
    case realSubmit = "real submit"
    case realCancel = "real cancel"
    case realReplace = "real replace"
    case reconciliationRuntime = "reconciliation runtime"
    case dashboardCommandSurface = "Dashboard command surface"
    case commandGatewayBypass = "CommandGateway bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case eventStoreBypass = "Event Store bypass"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedStrategy = "unsupported strategy"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030OMSRehearsalOrderIntent 是 #661 allow decision 进入 ExecutionEngine 的本地意图。
///
/// 该 intent 只保存 pre-risk `ProductAwareOrderIntent` 与 risk decision identity；它不是
/// ExecutionClient request，也不授权 broker submit / cancel / replace。
public struct ReleaseV030OMSRehearsalOrderIntent: Codable, Equatable, Sendable {
    public let orderIntentID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let productAwareOrderIntent: ProductAwareOrderIntent
    public let createdAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let authorizesExecutionClientCall: Bool
    public let submitsRealOrder: Bool

    public init(
        orderIntentID: Identifier,
        sourceRiskDecision: ReleaseV030RiskEngineRehearsalDecision,
        createdAt: Date,
        productionTradingEnabledByDefault: Bool = false,
        authorizesExecutionClientCall: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sourceRiskDecision.isAllowed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.sourceRiskDecision",
                expected: "allowed risk decision",
                actual: sourceRiskDecision.status.rawValue
            )
        }
        guard let productAwareOrderIntent = sourceRiskDecision.message.productAwareOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.productAwareOrderIntent",
                expected: "risk-approved product-aware order intent",
                actual: "nil"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(authorizesExecutionClientCall, "authorizesExecutionClientCall")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")

        self.orderIntentID = orderIntentID
        self.sourceRiskDecisionID = sourceRiskDecision.decisionID
        self.instrument = sourceRiskDecision.message.instrument
        self.targetExposure = sourceRiskDecision.message.targetExposure
        self.productAwareOrderIntent = productAwareOrderIntent
        self.createdAt = createdAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.authorizesExecutionClientCall = authorizesExecutionClientCall
        self.submitsRealOrder = submitsRealOrder
    }

    public var boundaryHeld: Bool {
        productAwareOrderIntent.isPreRiskGateIntent
            && productionTradingEnabledByDefault == false
            && authorizesExecutionClientCall == false
            && submitsRealOrder == false
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030OMSOrderIntent.\(field)")
        }
    }
}

/// ReleaseV030OMSRehearsalTransition 是单个 OMS 状态迁移证据。
public struct ReleaseV030OMSRehearsalTransition: Codable, Equatable, Sendable {
    public let transitionID: Identifier
    public let orderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let fromState: ReleaseV030OMSRehearsalState
    public let trigger: ReleaseV030OMSRehearsalTrigger
    public let toState: ReleaseV030OMSRehearsalState
    public let sequence: Int
    public let recordedAt: Date
    public let validationAnchors: [String]
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool

    public init(
        transitionID: Identifier,
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        fromState: ReleaseV030OMSRehearsalState,
        trigger: ReleaseV030OMSRehearsalTrigger,
        toState: ReleaseV030OMSRehearsalState,
        sequence: Int,
        recordedAt: Date,
        validationAnchors: [String] = ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        guard Self.isAllowed(from: fromState, trigger: trigger, to: toState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.transition",
                expected: "legal OMS rehearsal transition",
                actual: "\(fromState.rawValue)->\(trigger.rawValue)->\(toState.rawValue)"
            )
        }
        guard validationAnchors == ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.validationAnchors",
                expected: ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(callsExecutionClient, "callsExecutionClient")
        try Self.forbid(touchesBrokerGateway, "touchesBrokerGateway")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")

        self.transitionID = transitionID
        self.orderID = orderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.fromState = fromState
        self.trigger = trigger
        self.toState = toState
        self.sequence = sequence
        self.recordedAt = recordedAt
        self.validationAnchors = validationAnchors
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
    }

    public var transitionHeld: Bool {
        validationAnchors == ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors
            && Self.isAllowed(from: fromState, trigger: trigger, to: toState)
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
    }

    public static func isAllowed(
        from: ReleaseV030OMSRehearsalState,
        trigger: ReleaseV030OMSRehearsalTrigger,
        to: ReleaseV030OMSRehearsalState
    ) -> Bool {
        switch (from, trigger, to) {
        case (.created, .riskApproved, .accepted),
             (.accepted, .dryRunSubmitted, .submittedTestnetOrDryRun),
             (.submittedTestnetOrDryRun, .cancelRequested, .cancelled),
             (.submittedTestnetOrDryRun, .simulatedFillObserved, .filledSimulated),
             (.created, .riskRejected, .rejected):
            true
        default:
            false
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030OMSTransition.\(field)")
        }
    }
}

/// ReleaseV030OMSRehearsalEventLog 是单条本地 order lifecycle 的 append-only 证据。
public struct ReleaseV030OMSRehearsalEventLog: Codable, Equatable, Sendable {
    public let eventLogID: Identifier
    public let path: ReleaseV030OMSRehearsalPath
    public let orderID: Identifier
    public let orderIntent: ReleaseV030OMSRehearsalOrderIntent?
    public let sourceRiskDecision: ReleaseV030RiskEngineRehearsalDecision
    public let transitions: [ReleaseV030OMSRehearsalTransition]
    public let envelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let validationAnchors: [String]
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public init(
        eventLogID: Identifier,
        path: ReleaseV030OMSRehearsalPath,
        orderID: Identifier,
        orderIntent: ReleaseV030OMSRehearsalOrderIntent?,
        sourceRiskDecision: ReleaseV030RiskEngineRehearsalDecision,
        transitions: [ReleaseV030OMSRehearsalTransition],
        envelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        validationAnchors: [String] = ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        guard transitions.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.transitions",
                expected: "non-empty transition set",
                actual: "empty"
            )
        }
        guard envelopes == replayedEnvelopes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.replay",
                expected: "append-only envelopes replay exactly",
                actual: "\(envelopes.count):\(replayedEnvelopes.count)"
            )
        }
        if path.requiresAllowedRiskDecision {
            guard sourceRiskDecision.isAllowed, orderIntent?.boundaryHeld == true else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030OMS.orderIntent",
                    expected: "allowed risk decision with local order intent",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
        } else {
            guard sourceRiskDecision.isRejected, orderIntent == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030OMS.rejectedPath",
                    expected: "rejected risk decision without order intent",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
        }
        try Self.forbid(callsExecutionClient, "callsExecutionClient")
        try Self.forbid(touchesBrokerGateway, "touchesBrokerGateway")
        try Self.forbid(productionOMSRuntimeEnabledByDefault, "productionOMSRuntimeEnabledByDefault")
        try Self.forbid(submitsRealOrder, "submitsRealOrder")
        try Self.forbid(cancelsRealOrder, "cancelsRealOrder")
        try Self.forbid(replacesRealOrder, "replacesRealOrder")

        self.eventLogID = eventLogID
        self.path = path
        self.orderID = orderID
        self.orderIntent = orderIntent
        self.sourceRiskDecision = sourceRiskDecision
        self.transitions = transitions
        self.envelopes = envelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.validationAnchors = validationAnchors
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public var finalState: ReleaseV030OMSRehearsalState {
        transitions.last?.toState ?? .created
    }

    public var replayRestoresFinalState: Bool {
        envelopes == replayedEnvelopes
            && envelopes.count == transitions.count
            && finalState == transitions.last?.toState
    }

    public var eventLogHeld: Bool {
        transitions.allSatisfy(\.transitionHeld)
            && replayRestoresFinalState
            && validationAnchors == ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && productionOMSRuntimeEnabledByDefault == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030OMSEventLog.\(field)")
        }
    }
}

/// ReleaseV030ExecutionOMSRehearsalEvidence 是 GH-662 的完整 lifecycle evidence。
public struct ReleaseV030ExecutionOMSRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamRiskEngineRehearsalAnchor: String
    public let mode: ReleaseV030ExecutionOMSRehearsalMode
    public let eventLogs: [ReleaseV030OMSRehearsalEventLog]
    public let requirements: [ReleaseV030ExecutionOMSRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030ExecutionOMSRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let performsReconciliation: Bool
    public let exposesDashboardCommandSurface: Bool
    public let commandGatewayBypassAllowed: Bool
    public let riskEngineBypassAllowed: Bool
    public let eventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-662"
            && upstreamIssueID.rawValue == "GH-661"
            && downstreamIssueID.rawValue == "GH-663"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamRiskEngineRehearsalAnchor == Self.requiredUpstreamRiskEngineRehearsalAnchor
            && mode == .dryRun
            && lifecycleCoverageHeld
            && replayCoverageHeld
            && boundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && startsNextMilestone == false
    }

    public var lifecycleCoverageHeld: Bool {
        Set(eventLogs.flatMap { log in log.transitions.flatMap { [$0.fromState, $0.toState] } })
            == Set(ReleaseV030OMSRehearsalState.allCases)
            && eventLogs.contains { $0.path == .acceptedSubmittedFilled && $0.finalState == .filledSimulated }
            && eventLogs.contains { $0.path == .acceptedSubmittedCancelled && $0.finalState == .cancelled }
            && eventLogs.contains { $0.path == .riskRejected && $0.finalState == .rejected }
    }

    public var replayCoverageHeld: Bool {
        eventLogs.allSatisfy(\.eventLogHeld)
            && eventLogs.allSatisfy(\.replayRestoresFinalState)
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && productionOMSRuntimeEnabledByDefault == false
            && performsReconciliation == false
            && exposesDashboardCommandSurface == false
            && commandGatewayBypassAllowed == false
            && riskEngineBypassAllowed == false
            && eventStoreBypassAllowed == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-662-release-v0.3.0-execution-oms-rehearsal-lifecycle"),
        issueID: Identifier = Identifier.constant("GH-662"),
        upstreamIssueID: Identifier = Identifier.constant("GH-661"),
        downstreamIssueID: Identifier = Identifier.constant("GH-663"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamRiskEngineRehearsalAnchor: String = Self.requiredUpstreamRiskEngineRehearsalAnchor,
        mode: ReleaseV030ExecutionOMSRehearsalMode = .dryRun,
        eventLogs: [ReleaseV030OMSRehearsalEventLog],
        requirements: [ReleaseV030ExecutionOMSRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030ExecutionOMSRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        performsReconciliation: Bool = false,
        exposesDashboardCommandSurface: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        riskEngineBypassAllowed: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamRiskEngineRehearsalAnchor: upstreamRiskEngineRehearsalAnchor,
            mode: mode,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            callsExecutionClient: callsExecutionClient,
            touchesBrokerGateway: touchesBrokerGateway,
            productionOMSRuntimeEnabledByDefault: productionOMSRuntimeEnabledByDefault,
            performsReconciliation: performsReconciliation,
            exposesDashboardCommandSurface: exposesDashboardCommandSurface,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            riskEngineBypassAllowed: riskEngineBypassAllowed,
            eventStoreBypassAllowed: eventStoreBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamRiskEngineRehearsalAnchor = upstreamRiskEngineRehearsalAnchor
        self.mode = mode
        self.eventLogs = eventLogs
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.performsReconciliation = performsReconciliation
        self.exposesDashboardCommandSurface = exposesDashboardCommandSurface
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.riskEngineBypassAllowed = riskEngineBypassAllowed
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamRiskEngineRehearsalAnchor =
        "TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE"
    public static let requiredRequirements = ReleaseV030ExecutionOMSRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030ExecutionOMSRehearsalForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V030-06-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE",
        "V030-06-RISK-APPROVED-INTENT-TO-OMS",
        "V030-06-OMS-STATE-COVERAGE",
        "V030-06-ILLEGAL-TRANSITION-REJECTED",
        "V030-06-OMS-REPLAY-EVIDENCE",
        "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030ExecutionOMSRehearsalLifecycle 生成 #662 本地 OMS rehearsal lifecycle。
public struct ReleaseV030ExecutionOMSRehearsalLifecycle: Sendable {
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID

    public init(
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil
    ) throws {
        if let sourceID {
            self.sourceID = sourceID
        } else {
            self.sourceID = try FoundationTargetID("gh-662-execution-oms-rehearsal-source")
        }
        if let streamID {
            self.streamID = streamID
        } else {
            self.streamID = try MessageBusJournalStreamID("execution.release-v0.3.0.oms-rehearsal")
        }
    }

    public func run(
        upstreamRiskEngineRehearsalAnchor: String =
            ReleaseV030ExecutionOMSRehearsalEvidence.requiredUpstreamRiskEngineRehearsalAnchor,
        riskEvidence: ReleaseV030RiskEngineRehearsalEvidence,
        recordedAt: Date
    ) throws -> ReleaseV030ExecutionOMSRehearsalEvidence {
        guard upstreamRiskEngineRehearsalAnchor ==
                ReleaseV030ExecutionOMSRehearsalEvidence.requiredUpstreamRiskEngineRehearsalAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamRiskEngineRehearsalAnchor",
                expected: ReleaseV030ExecutionOMSRehearsalEvidence.requiredUpstreamRiskEngineRehearsalAnchor,
                actual: upstreamRiskEngineRehearsalAnchor
            )
        }
        guard riskEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030OMS.riskEvidence",
                expected: "held GH-661 RiskEngine rehearsal evidence",
                actual: riskEvidence.issueID.rawValue
            )
        }

        let acceptedFilled = try eventLog(
            path: .acceptedSubmittedFilled,
            sourceRiskDecision: riskEvidence.allowDecision,
            sequenceBase: 100,
            recordedAt: recordedAt
        )
        let acceptedCancelled = try eventLog(
            path: .acceptedSubmittedCancelled,
            sourceRiskDecision: riskEvidence.allowDecision,
            sequenceBase: 200,
            recordedAt: recordedAt.addingTimeInterval(10)
        )
        let riskRejected = try eventLog(
            path: .riskRejected,
            sourceRiskDecision: riskEvidence.invalidDecision,
            sequenceBase: 300,
            recordedAt: recordedAt.addingTimeInterval(20)
        )

        return try ReleaseV030ExecutionOMSRehearsalEvidence(
            eventLogs: [acceptedFilled, acceptedCancelled, riskRejected]
        )
    }

    public func eventLog(
        path: ReleaseV030OMSRehearsalPath,
        sourceRiskDecision: ReleaseV030RiskEngineRehearsalDecision,
        sequenceBase: Int,
        recordedAt: Date
    ) throws -> ReleaseV030OMSRehearsalEventLog {
        guard sequenceBase > 0 else {
            throw CoreError.invalidEventSequence(sequenceBase)
        }
        let orderID = try Identifier("gh-662-\(path.rawValue)-order")
        let orderIntent: ReleaseV030OMSRehearsalOrderIntent?
        if path.requiresAllowedRiskDecision {
            orderIntent = try ReleaseV030OMSRehearsalOrderIntent(
                orderIntentID: try Identifier("\(orderID.rawValue)-intent"),
                sourceRiskDecision: sourceRiskDecision,
                createdAt: recordedAt
            )
        } else {
            guard sourceRiskDecision.isRejected else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030OMS.riskRejectedPath",
                    expected: "rejected risk decision",
                    actual: sourceRiskDecision.status.rawValue
                )
            }
            orderIntent = nil
        }

        let transitions = try self.transitions(
            orderID: orderID,
            sourceRiskDecisionID: sourceRiskDecision.decisionID,
            path: path,
            sequenceBase: sequenceBase,
            recordedAt: recordedAt
        )
        let (envelopes, replayedEnvelopes) = try replayEvidence(
            path: path,
            orderID: orderID,
            transitions: transitions
        )

        return try ReleaseV030OMSRehearsalEventLog(
            eventLogID: try Identifier("\(orderID.rawValue)-event-log"),
            path: path,
            orderID: orderID,
            orderIntent: orderIntent,
            sourceRiskDecision: sourceRiskDecision,
            transitions: transitions,
            envelopes: envelopes,
            replayedEnvelopes: replayedEnvelopes
        )
    }

    private func transitions(
        orderID: Identifier,
        sourceRiskDecisionID: Identifier,
        path: ReleaseV030OMSRehearsalPath,
        sequenceBase: Int,
        recordedAt: Date
    ) throws -> [ReleaseV030OMSRehearsalTransition] {
        switch path {
        case .acceptedSubmittedFilled:
            return try [
                transition(orderID, sourceRiskDecisionID, .created, .riskApproved, .accepted, sequenceBase + 1, recordedAt),
                transition(
                    orderID,
                    sourceRiskDecisionID,
                    .accepted,
                    .dryRunSubmitted,
                    .submittedTestnetOrDryRun,
                    sequenceBase + 2,
                    recordedAt.addingTimeInterval(1)
                ),
                transition(
                    orderID,
                    sourceRiskDecisionID,
                    .submittedTestnetOrDryRun,
                    .simulatedFillObserved,
                    .filledSimulated,
                    sequenceBase + 3,
                    recordedAt.addingTimeInterval(2)
                )
            ]
        case .acceptedSubmittedCancelled:
            return try [
                transition(orderID, sourceRiskDecisionID, .created, .riskApproved, .accepted, sequenceBase + 1, recordedAt),
                transition(
                    orderID,
                    sourceRiskDecisionID,
                    .accepted,
                    .dryRunSubmitted,
                    .submittedTestnetOrDryRun,
                    sequenceBase + 2,
                    recordedAt.addingTimeInterval(1)
                ),
                transition(
                    orderID,
                    sourceRiskDecisionID,
                    .submittedTestnetOrDryRun,
                    .cancelRequested,
                    .cancelled,
                    sequenceBase + 3,
                    recordedAt.addingTimeInterval(2)
                )
            ]
        case .riskRejected:
            return try [
                transition(orderID, sourceRiskDecisionID, .created, .riskRejected, .rejected, sequenceBase + 1, recordedAt)
            ]
        }
    }

    private func transition(
        _ orderID: Identifier,
        _ sourceRiskDecisionID: Identifier,
        _ fromState: ReleaseV030OMSRehearsalState,
        _ trigger: ReleaseV030OMSRehearsalTrigger,
        _ toState: ReleaseV030OMSRehearsalState,
        _ sequence: Int,
        _ recordedAt: Date
    ) throws -> ReleaseV030OMSRehearsalTransition {
        try ReleaseV030OMSRehearsalTransition(
            transitionID: try Identifier("\(orderID.rawValue)-\(sequence)-\(toState.rawValue)"),
            orderID: orderID,
            sourceRiskDecisionID: sourceRiskDecisionID,
            fromState: fromState,
            trigger: trigger,
            toState: toState,
            sequence: sequence,
            recordedAt: recordedAt
        )
    }

    private func replayEvidence(
        path: ReleaseV030OMSRehearsalPath,
        orderID: Identifier,
        transitions: [ReleaseV030OMSRehearsalTransition]
    ) throws -> ([MessageBusJournalEnvelope], [MessageBusJournalEnvelope]) {
        var journal = try MessageBusAppendOnlyJournal()
        var envelopes: [MessageBusJournalEnvelope] = []
        for transition in transitions {
            let payloadType =
                "execution.release-v0.3.0.oms.\(path.rawValue).\(transition.toState.rawValue).\(orderID.rawValue)"
            let envelope = try journal.append(
                stream: streamID,
                sourceID: sourceID,
                payloadType: payloadType,
                instrumentID: nil,
                recordedAt: transition.recordedAt
            )
            envelopes.append(envelope)
        }
        return (envelopes, journal.replay(stream: streamID))
    }
}

private extension ReleaseV030ExecutionOMSRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamRiskEngineRehearsalAnchor: String,
        mode: ReleaseV030ExecutionOMSRehearsalMode,
        requirements: [ReleaseV030ExecutionOMSRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030ExecutionOMSRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamRiskEngineRehearsalAnchor",
                upstreamRiskEngineRehearsalAnchor == requiredUpstreamRiskEngineRehearsalAnchor,
                requiredUpstreamRiskEngineRehearsalAnchor,
                upstreamRiskEngineRehearsalAnchor
            ),
            ("mode", mode == .dryRun, ReleaseV030ExecutionOMSRehearsalMode.dryRun.rawValue, mode.rawValue),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        callsExecutionClient: Bool,
        touchesBrokerGateway: Bool,
        productionOMSRuntimeEnabledByDefault: Bool,
        performsReconciliation: Bool,
        exposesDashboardCommandSurface: Bool,
        commandGatewayBypassAllowed: Bool,
        riskEngineBypassAllowed: Bool,
        eventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("performsReconciliation", performsReconciliation),
            ("exposesDashboardCommandSurface", exposesDashboardCommandSurface),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("riskEngineBypassAllowed", riskEngineBypassAllowed),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, isEnabled) in forbiddenFlags where isEnabled {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
