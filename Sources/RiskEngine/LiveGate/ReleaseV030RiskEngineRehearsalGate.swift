import DomainModel
import Foundation
import MessageBus

/// ReleaseV030RiskEngineRehearsalMode 是 RiskEngine 本地的 v0.3.0 rehearsal mode。
///
/// RiskEngine target 不依赖 ExecutionClient / Trader / Runtime；这里只用稳定 raw value
/// 证明 gate 处于 dry-run / testnet / shadow / production-blocked 语义内，但不获得
/// endpoint、secret、broker、OMS 或真实订单能力。
public enum ReleaseV030RiskEngineRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ReleaseV030RiskEngineRehearsalRequirement 固定 GH-661 必须满足的风控 rehearsal 要求。
public enum ReleaseV030RiskEngineRehearsalRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamTraderStrategyRehearsalRequired = "upstream Trader strategy rehearsal evidence required"
    case messageBusIntentTraceRequired = "MessageBus strategy intent trace required"
    case allowDecisionRequired = "valid rehearsal intent allow decision required"
    case invalidRejectDecisionRequired = "invalid rehearsal intent reject decision required"
    case limitGateRequired = "limit gate required"
    case killSwitchRejectRequired = "kill switch reject decision required"
    case noTradeRejectRequired = "no-trade reject decision required"
    case auditableRiskEvidenceRequired = "auditable risk decision evidence required"
}

/// ReleaseV030RiskEngineRehearsalForbiddenCapability 枚举 GH-661 必须拒绝的漂移。
public enum ReleaseV030RiskEngineRehearsalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedStrategy = "unsupported strategy"
    case missingMessageBusTrace = "missing MessageBus trace"
    case commandGatewayBypass = "CommandGateway bypass"
    case executionEngineBypass = "ExecutionEngine bypass"
    case omsBypass = "OMS bypass"
    case executionClientAccess = "ExecutionClient access"
    case brokerGatewayAccess = "broker gateway access"
    case eventStoreBypass = "Event Store bypass"
    case killSwitchBypass = "kill switch bypass"
    case noTradeBypass = "no-trade bypass"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030RiskEngineRehearsalGateType 表达 GH-661 风控 gate 覆盖项。
public enum ReleaseV030RiskEngineRehearsalGateType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case messageBusTrace
    case strategyAllowlist
    case instrumentAllowlist
    case limit
    case killSwitch
    case noTrade
}

/// ReleaseV030RiskEngineRehearsalDecisionStatus 描述 rehearsal risk decision 的输出。
public enum ReleaseV030RiskEngineRehearsalDecisionStatus: String, Codable, Equatable, Sendable {
    case allow
    case reject
}

/// ReleaseV030RiskEngineRehearsalRejectReason 描述 reject 的可审计原因。
public enum ReleaseV030RiskEngineRehearsalRejectReason: String, Codable, Equatable, Hashable, Sendable {
    case missingMessageBusTrace
    case strategyNotAllowed
    case instrumentNotAllowed
    case missingOrderIntent
    case notionalLimitExceeded
    case aggregateExposureLimitExceeded
    case killSwitchActive
    case noTradeActive
}

/// ReleaseV030RiskEngineRehearsalPolicy 是 #661 的 deterministic risk policy。
///
/// Policy 只覆盖 allowlist、notional / aggregate exposure limit、kill switch 和 no-trade。
/// 它不读取 secret、不连接 endpoint、不调用 ExecutionEngine / OMS / ExecutionClient / broker，
/// 也不授权 production trading。
public struct ReleaseV030RiskEngineRehearsalPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let allowedStrategyIDs: [Identifier]
    public let allowedInstruments: [InstrumentIdentity]
    public let maxNotional: Double
    public let maxAggregateExposure: Double
    public let killSwitchActive: Bool
    public let noTradeActive: Bool
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let commandGatewayBypassAllowed: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let eventStoreBypassAllowed: Bool

    public init(
        policyID: Identifier,
        allowedStrategyIDs: [Identifier],
        allowedInstruments: [InstrumentIdentity],
        maxNotional: Double,
        maxAggregateExposure: Double,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false,
        validationAnchors: [String] = ReleaseV030RiskEngineRehearsalEvidence.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        eventStoreBypassAllowed: Bool = false
    ) throws {
        guard allowedStrategyIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.allowedStrategyIDs",
                expected: "EMA and RSI strategy ids",
                actual: "empty"
            )
        }
        guard allowedInstruments.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.allowedInstruments",
                expected: "Binance Spot / USD-M Perp instruments",
                actual: "empty"
            )
        }
        if let forbiddenInstrument = allowedInstruments.first(where: {
            $0.venue.rawValue != "binance" || [.spot, .usdsPerpetual].contains($0.productType) == false
        }) {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.allowedInstruments",
                expected: "Binance Spot or USD-M Perp",
                actual: forbiddenInstrument.rawValue
            )
        }
        guard maxNotional.isFinite && maxNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.maxNotional",
                expected: "finite positive",
                actual: "\(maxNotional)"
            )
        }
        guard maxAggregateExposure.isFinite && maxAggregateExposure > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.maxAggregateExposure",
                expected: "finite positive",
                actual: "\(maxAggregateExposure)"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionEndpointAutoConnectEnabled, "productionEndpointAutoConnectEnabled")
        try Self.forbid(productionSecretAutoReadEnabled, "productionSecretAutoReadEnabled")
        try Self.forbid(productionOrderSubmissionEnabled, "productionOrderSubmissionEnabled")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        try Self.forbid(commandGatewayBypassAllowed, "commandGatewayBypassAllowed")
        try Self.forbid(executionEngineBypassAllowed, "executionEngineBypassAllowed")
        try Self.forbid(omsBypassAllowed, "omsBypassAllowed")
        try Self.forbid(executionClientAccessEnabled, "executionClientAccessEnabled")
        try Self.forbid(brokerGatewayAccessEnabled, "brokerGatewayAccessEnabled")
        try Self.forbid(eventStoreBypassAllowed, "eventStoreBypassAllowed")

        self.policyID = policyID
        self.allowedStrategyIDs = allowedStrategyIDs
        self.allowedInstruments = allowedInstruments
        self.maxNotional = maxNotional
        self.maxAggregateExposure = maxAggregateExposure
        self.killSwitchActive = killSwitchActive
        self.noTradeActive = noTradeActive
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
    }

    public var boundaryHeld: Bool {
        validationAnchors == ReleaseV030RiskEngineRehearsalEvidence.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && commandGatewayBypassAllowed == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && eventStoreBypassAllowed == false
    }

    public var allowedStrategySet: Set<Identifier> {
        Set(allowedStrategyIDs)
    }

    public var allowedInstrumentSet: Set<InstrumentIdentity> {
        Set(allowedInstruments)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030RiskEngine.\(field)")
        }
    }
}

/// ReleaseV030RiskEngineRehearsalDecision 是单条 strategy intent 的风控输出。
///
/// `allow` 只表示 rehearsal risk gate 通过，可继续由后续 #662 ExecutionEngine / OMS gate
/// 处理；它不是 broker command，不绕过 CommandGateway，也不授权真实交易。
public struct ReleaseV030RiskEngineRehearsalDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let policyID: Identifier
    public let message: StrategyIntentMessage
    public let envelope: MessageBusJournalEnvelope?
    public let status: ReleaseV030RiskEngineRehearsalDecisionStatus
    public let rejectReason: ReleaseV030RiskEngineRehearsalRejectReason?
    public let passedGates: [ReleaseV030RiskEngineRehearsalGateType]
    public let proposedNotional: Double?
    public let projectedAggregateExposure: Double?
    public let evaluatedAt: Date
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let commandGatewayBypassAllowed: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let eventStoreBypassAllowed: Bool
    public let killSwitchBypassAllowed: Bool
    public let noTradeBypassAllowed: Bool
    public let productionOrderSubmissionEnabled: Bool

    public init(
        decisionID: Identifier,
        policyID: Identifier,
        message: StrategyIntentMessage,
        envelope: MessageBusJournalEnvelope?,
        status: ReleaseV030RiskEngineRehearsalDecisionStatus,
        rejectReason: ReleaseV030RiskEngineRehearsalRejectReason?,
        passedGates: [ReleaseV030RiskEngineRehearsalGateType],
        proposedNotional: Double?,
        projectedAggregateExposure: Double?,
        evaluatedAt: Date,
        validationAnchors: [String] = ReleaseV030RiskEngineRehearsalEvidence.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        killSwitchBypassAllowed: Bool = false,
        noTradeBypassAllowed: Bool = false,
        productionOrderSubmissionEnabled: Bool = false
    ) throws {
        if status == .allow {
            guard rejectReason == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030RiskEngine.rejectReason",
                    expected: "nil for allow",
                    actual: rejectReason?.rawValue ?? "nil"
                )
            }
            guard Set(passedGates) == Set(ReleaseV030RiskEngineRehearsalGateType.allCases) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030RiskEngine.passedGates",
                    expected: ReleaseV030RiskEngineRehearsalGateType.allCases.map(\.rawValue).joined(separator: ","),
                    actual: passedGates.map(\.rawValue).joined(separator: ",")
                )
            }
        }
        if status == .reject, rejectReason == nil {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.rejectReason",
                expected: "present for reject",
                actual: "nil"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(commandGatewayBypassAllowed, "commandGatewayBypassAllowed")
        try Self.forbid(executionEngineBypassAllowed, "executionEngineBypassAllowed")
        try Self.forbid(omsBypassAllowed, "omsBypassAllowed")
        try Self.forbid(executionClientAccessEnabled, "executionClientAccessEnabled")
        try Self.forbid(brokerGatewayAccessEnabled, "brokerGatewayAccessEnabled")
        try Self.forbid(eventStoreBypassAllowed, "eventStoreBypassAllowed")
        try Self.forbid(killSwitchBypassAllowed, "killSwitchBypassAllowed")
        try Self.forbid(noTradeBypassAllowed, "noTradeBypassAllowed")
        try Self.forbid(productionOrderSubmissionEnabled, "productionOrderSubmissionEnabled")

        self.decisionID = decisionID
        self.policyID = policyID
        self.message = message
        self.envelope = envelope
        self.status = status
        self.rejectReason = rejectReason
        self.passedGates = passedGates
        self.proposedNotional = proposedNotional
        self.projectedAggregateExposure = projectedAggregateExposure
        self.evaluatedAt = evaluatedAt
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.killSwitchBypassAllowed = killSwitchBypassAllowed
        self.noTradeBypassAllowed = noTradeBypassAllowed
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
    }

    public var decisionHeld: Bool {
        validationAnchors == ReleaseV030RiskEngineRehearsalEvidence.requiredValidationAnchors
            && messageTraceHeld
            && boundaryHeld
            && statusRejectPairHeld
    }

    public var isAllowed: Bool {
        status == .allow && rejectReason == nil && decisionHeld
    }

    public var isRejected: Bool {
        status == .reject && rejectReason != nil && decisionHeld
    }

    public var messageTraceHeld: Bool {
        guard let envelope else {
            return rejectReason == .missingMessageBusTrace
        }
        return envelope.instrumentID == message.instrument
            && envelope.payloadType.contains("trader.release-v0.3.0.binance")
            && envelope.payloadType.contains("targetExposureIntent")
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && commandGatewayBypassAllowed == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && eventStoreBypassAllowed == false
            && killSwitchBypassAllowed == false
            && noTradeBypassAllowed == false
            && productionOrderSubmissionEnabled == false
    }

    private var statusRejectPairHeld: Bool {
        switch status {
        case .allow:
            rejectReason == nil
        case .reject:
            rejectReason != nil
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030RiskEngineDecision.\(field)")
        }
    }
}

/// ReleaseV030RiskEngineRehearsalEvidence 是 GH-661 的 stage-local 风控证据。
public struct ReleaseV030RiskEngineRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamTraderRehearsalAnchor: String
    public let mode: ReleaseV030RiskEngineRehearsalMode
    public let allowDecision: ReleaseV030RiskEngineRehearsalDecision
    public let invalidDecision: ReleaseV030RiskEngineRehearsalDecision
    public let killSwitchDecision: ReleaseV030RiskEngineRehearsalDecision
    public let noTradeDecision: ReleaseV030RiskEngineRehearsalDecision
    public let intentMessages: [StrategyIntentMessage]
    public let eventEnvelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let requirements: [ReleaseV030RiskEngineRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030RiskEngineRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let commandGatewayBypassAllowed: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let eventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-661"
            && upstreamIssueID.rawValue == "GH-660"
            && downstreamIssueID.rawValue == "GH-662"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamTraderRehearsalAnchor == Self.requiredUpstreamTraderRehearsalAnchor
            && mode == .dryRun
            && allowRejectCoverageHeld
            && messageBusTraceHeld
            && auditBoundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && startsNextMilestone == false
    }

    public var allowRejectCoverageHeld: Bool {
        allowDecision.isAllowed
            && allowDecision.rejectReason == nil
            && invalidDecision.isRejected
            && invalidDecision.rejectReason == .notionalLimitExceeded
            && killSwitchDecision.isRejected
            && killSwitchDecision.rejectReason == .killSwitchActive
            && noTradeDecision.isRejected
            && noTradeDecision.rejectReason == .noTradeActive
    }

    public var messageBusTraceHeld: Bool {
        intentMessages.isEmpty == false
            && eventEnvelopes == replayedEnvelopes
            && eventEnvelopes.map(\.instrumentID) == intentMessages.map(\.instrument)
            && eventEnvelopes.allSatisfy { $0.payloadType.contains("trader.release-v0.3.0.binance") }
            && eventEnvelopes.allSatisfy { $0.payloadType.contains("targetExposureIntent") }
    }

    public var auditBoundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && commandGatewayBypassAllowed == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && eventStoreBypassAllowed == false
            && allowDecision.boundaryHeld
            && invalidDecision.boundaryHeld
            && killSwitchDecision.boundaryHeld
            && noTradeDecision.boundaryHeld
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-661-release-v0.3.0-riskengine-rehearsal-gate"),
        issueID: Identifier = Identifier.constant("GH-661"),
        upstreamIssueID: Identifier = Identifier.constant("GH-660"),
        downstreamIssueID: Identifier = Identifier.constant("GH-662"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamTraderRehearsalAnchor: String = Self.requiredUpstreamTraderRehearsalAnchor,
        mode: ReleaseV030RiskEngineRehearsalMode = .dryRun,
        allowDecision: ReleaseV030RiskEngineRehearsalDecision,
        invalidDecision: ReleaseV030RiskEngineRehearsalDecision,
        killSwitchDecision: ReleaseV030RiskEngineRehearsalDecision,
        noTradeDecision: ReleaseV030RiskEngineRehearsalDecision,
        intentMessages: [StrategyIntentMessage],
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        requirements: [ReleaseV030RiskEngineRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030RiskEngineRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamTraderRehearsalAnchor: upstreamTraderRehearsalAnchor,
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
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            executionClientAccessEnabled: executionClientAccessEnabled,
            brokerGatewayAccessEnabled: brokerGatewayAccessEnabled,
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
        self.upstreamTraderRehearsalAnchor = upstreamTraderRehearsalAnchor
        self.mode = mode
        self.allowDecision = allowDecision
        self.invalidDecision = invalidDecision
        self.killSwitchDecision = killSwitchDecision
        self.noTradeDecision = noTradeDecision
        self.intentMessages = intentMessages
        self.eventEnvelopes = eventEnvelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamTraderRehearsalAnchor =
        "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW"
    public static let requiredRequirements = ReleaseV030RiskEngineRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030RiskEngineRehearsalForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V030-05-RISKENGINE-REHEARSAL-GATE",
        "V030-05-MESSAGEBUS-STRATEGY-INTENT-RISK-INPUT",
        "V030-05-ALLOW-REJECT-LIMIT-EVIDENCE",
        "V030-05-KILL-SWITCH-NO-TRADE-REJECT-EVIDENCE",
        "V030-05-AUDITABLE-RISK-DECISION-EVIDENCE",
        "TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030RiskEngineRehearsalGate 执行 GH-661 的本地 deterministic risk gate。
public struct ReleaseV030RiskEngineRehearsalGate: Sendable {
    public init() {}

    public func evaluate(
        decisionID: Identifier,
        message: StrategyIntentMessage,
        envelope: MessageBusJournalEnvelope?,
        policy: ReleaseV030RiskEngineRehearsalPolicy,
        currentAggregateExposure: Double,
        evaluatedAt: Date
    ) throws -> ReleaseV030RiskEngineRehearsalDecision {
        guard currentAggregateExposure.isFinite && currentAggregateExposure >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.currentAggregateExposure",
                expected: "finite non-negative",
                actual: "\(currentAggregateExposure)"
            )
        }
        guard policy.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.policyBoundary",
                expected: "closed production and execution capability flags",
                actual: "open"
            )
        }
        guard let envelope, envelope.instrumentID == message.instrument else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .missingMessageBusTrace,
                passedGates: [],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        guard envelope.payloadType.contains("trader.release-v0.3.0.binance"),
              envelope.payloadType.contains("targetExposureIntent") else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .missingMessageBusTrace,
                passedGates: [],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        guard policy.allowedStrategySet.contains(message.strategyID) else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .strategyNotAllowed,
                passedGates: [.messageBusTrace],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        guard policy.allowedInstrumentSet.contains(message.instrument) else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .instrumentNotAllowed,
                passedGates: [.messageBusTrace, .strategyAllowlist],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }

        let proposedNotional = message.productAwareOrderIntent.map {
            $0.quantity.rawValue * $0.referencePrice.rawValue
        }
        guard message.targetExposure.requiresOrderIntent == false || proposedNotional != nil else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .missingOrderIntent,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        if let proposedNotional, proposedNotional > policy.maxNotional {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .notionalLimitExceeded,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        let projectedAggregateExposure = currentAggregateExposure + (proposedNotional ?? 0)
        guard projectedAggregateExposure <= policy.maxAggregateExposure else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .aggregateExposureLimitExceeded,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist, .limit],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        guard policy.killSwitchActive == false else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .killSwitchActive,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist, .limit],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }
        guard policy.noTradeActive == false else {
            return try reject(
                decisionID: decisionID,
                message: message,
                envelope: envelope,
                policy: policy,
                reason: .noTradeActive,
                passedGates: [
                    .messageBusTrace,
                    .strategyAllowlist,
                    .instrumentAllowlist,
                    .limit,
                    .killSwitch
                ],
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt
            )
        }

        return try ReleaseV030RiskEngineRehearsalDecision(
            decisionID: decisionID,
            policyID: policy.policyID,
            message: message,
            envelope: envelope,
            status: .allow,
            rejectReason: nil,
            passedGates: ReleaseV030RiskEngineRehearsalGateType.allCases,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: projectedAggregateExposure,
            evaluatedAt: evaluatedAt
        )
    }

    public func run(
        upstreamTraderRehearsalAnchor: String =
            ReleaseV030RiskEngineRehearsalEvidence.requiredUpstreamTraderRehearsalAnchor,
        intentMessages: [StrategyIntentMessage],
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        allowPolicy: ReleaseV030RiskEngineRehearsalPolicy,
        invalidPolicy: ReleaseV030RiskEngineRehearsalPolicy,
        killSwitchPolicy: ReleaseV030RiskEngineRehearsalPolicy,
        noTradePolicy: ReleaseV030RiskEngineRehearsalPolicy,
        currentAggregateExposure: Double = 0,
        evaluatedAt: Date
    ) throws -> ReleaseV030RiskEngineRehearsalEvidence {
        guard upstreamTraderRehearsalAnchor ==
                ReleaseV030RiskEngineRehearsalEvidence.requiredUpstreamTraderRehearsalAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamTraderRehearsalAnchor",
                expected: ReleaseV030RiskEngineRehearsalEvidence.requiredUpstreamTraderRehearsalAnchor,
                actual: upstreamTraderRehearsalAnchor
            )
        }
        guard intentMessages.isEmpty == false, eventEnvelopes == replayedEnvelopes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.messageBusTrace",
                expected: "intent messages and replayed envelopes must match",
                actual: "\(intentMessages.count):\(eventEnvelopes.count):\(replayedEnvelopes.count)"
            )
        }
        guard let commandMessage = intentMessages.first(where: { $0.productAwareOrderIntent != nil }),
              let commandEnvelope = eventEnvelopes.first(where: { $0.instrumentID == commandMessage.instrument }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030RiskEngine.commandIntent",
                expected: "at least one product-aware strategy intent with MessageBus envelope",
                actual: "missing"
            )
        }

        let allowDecision = try evaluate(
            decisionID: Identifier.constant("gh-661-riskengine-allow-decision"),
            message: commandMessage,
            envelope: commandEnvelope,
            policy: allowPolicy,
            currentAggregateExposure: currentAggregateExposure,
            evaluatedAt: evaluatedAt
        )
        let invalidDecision = try evaluate(
            decisionID: Identifier.constant("gh-661-riskengine-invalid-reject-decision"),
            message: commandMessage,
            envelope: commandEnvelope,
            policy: invalidPolicy,
            currentAggregateExposure: currentAggregateExposure,
            evaluatedAt: evaluatedAt.addingTimeInterval(1)
        )
        let killSwitchDecision = try evaluate(
            decisionID: Identifier.constant("gh-661-riskengine-kill-switch-reject-decision"),
            message: commandMessage,
            envelope: commandEnvelope,
            policy: killSwitchPolicy,
            currentAggregateExposure: currentAggregateExposure,
            evaluatedAt: evaluatedAt.addingTimeInterval(2)
        )
        let noTradeDecision = try evaluate(
            decisionID: Identifier.constant("gh-661-riskengine-no-trade-reject-decision"),
            message: commandMessage,
            envelope: commandEnvelope,
            policy: noTradePolicy,
            currentAggregateExposure: currentAggregateExposure,
            evaluatedAt: evaluatedAt.addingTimeInterval(3)
        )

        return try ReleaseV030RiskEngineRehearsalEvidence(
            allowDecision: allowDecision,
            invalidDecision: invalidDecision,
            killSwitchDecision: killSwitchDecision,
            noTradeDecision: noTradeDecision,
            intentMessages: intentMessages,
            eventEnvelopes: eventEnvelopes,
            replayedEnvelopes: replayedEnvelopes
        )
    }

    private func reject(
        decisionID: Identifier,
        message: StrategyIntentMessage,
        envelope: MessageBusJournalEnvelope?,
        policy: ReleaseV030RiskEngineRehearsalPolicy,
        reason: ReleaseV030RiskEngineRehearsalRejectReason,
        passedGates: [ReleaseV030RiskEngineRehearsalGateType],
        currentAggregateExposure: Double,
        evaluatedAt: Date
    ) throws -> ReleaseV030RiskEngineRehearsalDecision {
        let proposedNotional = message.productAwareOrderIntent.map {
            $0.quantity.rawValue * $0.referencePrice.rawValue
        }
        return try ReleaseV030RiskEngineRehearsalDecision(
            decisionID: decisionID,
            policyID: policy.policyID,
            message: message,
            envelope: envelope,
            status: .reject,
            rejectReason: reason,
            passedGates: passedGates,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: proposedNotional.map { currentAggregateExposure + $0 },
            evaluatedAt: evaluatedAt
        )
    }
}

private extension ReleaseV030RiskEngineRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamTraderRehearsalAnchor: String,
        mode: ReleaseV030RiskEngineRehearsalMode,
        requirements: [ReleaseV030RiskEngineRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030RiskEngineRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamTraderRehearsalAnchor",
                upstreamTraderRehearsalAnchor == requiredUpstreamTraderRehearsalAnchor,
                requiredUpstreamTraderRehearsalAnchor,
                upstreamTraderRehearsalAnchor
            ),
            ("mode", mode == .dryRun, ReleaseV030RiskEngineRehearsalMode.dryRun.rawValue, mode.rawValue),
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
        commandGatewayBypassAllowed: Bool,
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        executionClientAccessEnabled: Bool,
        brokerGatewayAccessEnabled: Bool,
        eventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("executionClientAccessEnabled", executionClientAccessEnabled),
            ("brokerGatewayAccessEnabled", brokerGatewayAccessEnabled),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, isEnabled) in forbiddenFlags where isEnabled {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
