import DomainModel
import Foundation
import MessageBus

/// ReleaseV040RiskEnginePreTradeDecisionStatus 描述 GH-699 rehearsal risk gate 输出。
///
/// `allow` 只表示后续 ExecutionEngine rehearsal 可以消费该 intent；`reject` 与 `blocked`
/// 都不能升级为 broker reject、OMS order 或真实交易命令。
public enum ReleaseV040RiskEnginePreTradeDecisionStatus: String, Codable, Equatable, Hashable, Sendable {
    case allow
    case reject
    case blocked
}

/// ReleaseV040RiskEnginePreTradeDecisionReason 是 GH-699 的可审计拒绝 / 阻断原因。
public enum ReleaseV040RiskEnginePreTradeDecisionReason: String, Codable, Equatable, Hashable, Sendable {
    case missingMessageBusTrace
    case strategyNotAllowed
    case instrumentNotAllowed
    case missingOrderIntent
    case notionalLimitExceeded
    case aggregateExposureLimitExceeded
    case killSwitchActive
    case noTradeActive
}

/// ReleaseV040RiskEnginePreTradeGateType 固定 GH-699 风控 gate 覆盖项。
public enum ReleaseV040RiskEnginePreTradeGateType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case messageBusTrace
    case strategyAllowlist
    case instrumentAllowlist
    case limit
    case killSwitch
    case noTrade
}

/// ReleaseV040RiskEngineStrategyIntentInput 是 RiskEngine 消费的 strategy intent 输入。
///
/// 输入只依赖 MessageBus 中立 envelope 和 `StrategyIntentMessage`；RiskEngine 不 import Trader target，
/// 不读取 strategy actor implementation，也不获得 ExecutionClient、broker、OMS 或 command 能力。
public struct ReleaseV040RiskEngineStrategyIntentInput: Codable, Equatable, Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let upstreamEvidenceID: Identifier
    public let intentMessage: StrategyIntentMessage
    public let intentJournalEnvelope: MessageBusJournalEnvelope

    public var runID: Identifier { runContext.runID }

    public var boundaryHeld: Bool {
        runContext.mode == .dryRun
            && runContext.boundaryHeld
            && intentJournalEnvelope.instrumentID == intentMessage.instrument
            && intentJournalEnvelope.payloadType.hasPrefix("trader.release-v0.4.0.binance")
            && intentJournalEnvelope.payloadType.contains("target-exposure-intent")
            && intentMessage.instrument.venue.rawValue == "binance"
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(intentMessage.instrument.productType)
    }

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        upstreamEvidenceID: Identifier,
        intentMessage: StrategyIntentMessage,
        intentJournalEnvelope: MessageBusJournalEnvelope
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard intentJournalEnvelope.instrumentID == intentMessage.instrument else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "intentJournalEnvelope.instrumentID",
                expected: intentMessage.instrument.rawValue,
                actual: intentJournalEnvelope.instrumentID?.rawValue ?? "nil"
            )
        }
        guard intentJournalEnvelope.payloadType.hasPrefix("trader.release-v0.4.0.binance"),
              intentJournalEnvelope.payloadType.contains("target-exposure-intent") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "intentJournalEnvelope.payloadType",
                expected: "trader.release-v0.4.0.binance.*.target-exposure-intent.*",
                actual: intentJournalEnvelope.payloadType
            )
        }
        guard intentMessage.instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonBinanceVenue")
        }
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(intentMessage.instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedProductType")
        }

        self.runContext = runContext
        self.upstreamEvidenceID = upstreamEvidenceID
        self.intentMessage = intentMessage
        self.intentJournalEnvelope = intentJournalEnvelope
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            upstreamEvidenceID: try container.decode(Identifier.self, forKey: .upstreamEvidenceID),
            intentMessage: try container.decode(StrategyIntentMessage.self, forKey: .intentMessage),
            intentJournalEnvelope: try container.decode(MessageBusJournalEnvelope.self, forKey: .intentJournalEnvelope)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case runContext
        case upstreamEvidenceID
        case intentMessage
        case intentJournalEnvelope
    }
}

/// ReleaseV040RiskEnginePreTradePolicy 是 GH-699 deterministic pre-trade policy。
///
/// Policy 只覆盖 strategy / instrument allowlist、notional / exposure limit、kill switch 和
/// no-trade。它不读取真实账户、不连接 endpoint、不调用 ExecutionEngine / OMS / ExecutionClient / broker。
public struct ReleaseV040RiskEnginePreTradePolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let allowedStrategyIDs: [Identifier]
    public let allowedInstruments: [InstrumentIdentity]
    public let maxNotional: Double
    public let maxAggregateExposure: Double
    public let killSwitchActive: Bool
    public let noTradeActive: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
    }

    public var allowedStrategySet: Set<Identifier> { Set(allowedStrategyIDs) }
    public var allowedInstrumentSet: Set<InstrumentIdentity> { Set(allowedInstruments) }

    public init(
        policyID: Identifier,
        allowedStrategyIDs: [Identifier],
        allowedInstruments: [InstrumentIdentity],
        maxNotional: Double,
        maxAggregateExposure: Double,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false
    ) throws {
        guard allowedStrategyIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedStrategyIDs",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard allowedInstruments.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedInstruments",
                expected: "non-empty",
                actual: "empty"
            )
        }
        guard maxNotional.isFinite && maxNotional > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "maxNotional",
                expected: "finite positive",
                actual: "\(maxNotional)"
            )
        }
        guard maxAggregateExposure.isFinite && maxAggregateExposure > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "maxAggregateExposure",
                expected: "finite positive",
                actual: "\(maxAggregateExposure)"
            )
        }
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            executionClientAccessEnabled: executionClientAccessEnabled,
            brokerGatewayAccessEnabled: brokerGatewayAccessEnabled
        )

        self.policyID = policyID
        self.allowedStrategyIDs = allowedStrategyIDs
        self.allowedInstruments = allowedInstruments
        self.maxNotional = maxNotional
        self.maxAggregateExposure = maxAggregateExposure
        self.killSwitchActive = killSwitchActive
        self.noTradeActive = noTradeActive
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
    }

    private static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        executionClientAccessEnabled: Bool,
        brokerGatewayAccessEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("executionClientAccessEnabled", executionClientAccessEnabled),
            ("brokerGatewayAccessEnabled", brokerGatewayAccessEnabled)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}

/// ReleaseV040RiskEnginePreTradeDecision 是 GH-699 单条 pre-trade gate 决策。
public struct ReleaseV040RiskEnginePreTradeDecision: Codable, Equatable, Sendable {
    public let decisionID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let input: ReleaseV040RiskEngineStrategyIntentInput
    public let policyID: Identifier
    public let status: ReleaseV040RiskEnginePreTradeDecisionStatus
    public let reason: ReleaseV040RiskEnginePreTradeDecisionReason?
    public let passedGates: [ReleaseV040RiskEnginePreTradeGateType]
    public let proposedNotional: Double?
    public let projectedAggregateExposure: Double?
    public let evaluatedAt: Date
    public let riskEnvelope: ReleaseV040UnifiedEvidenceEnvelope

    public var runID: Identifier { runContext.runID }

    public var executionEligible: Bool {
        status == .allow && reason == nil && decisionHeld
    }

    public var decisionHeld: Bool {
        input.boundaryHeld
            && input.runID == runID
            && riskEnvelope.runID == runID
            && riskEnvelope.module == .riskEngine
            && riskEnvelope.sourceIssueID.rawValue == "GH-699"
            && riskEnvelope.upstreamEvidenceID == input.upstreamEvidenceID
            && statusReasonPairHeld
    }

    public init(
        decisionID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        input: ReleaseV040RiskEngineStrategyIntentInput,
        policyID: Identifier,
        status: ReleaseV040RiskEnginePreTradeDecisionStatus,
        reason: ReleaseV040RiskEnginePreTradeDecisionReason?,
        passedGates: [ReleaseV040RiskEnginePreTradeGateType],
        proposedNotional: Double?,
        projectedAggregateExposure: Double?,
        evaluatedAt: Date,
        riskEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    ) throws {
        guard input.runID == runContext.runID, riskEnvelope.runID == runContext.runID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard riskEnvelope.module == .riskEngine else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskEnvelope.module",
                expected: ReleaseV040UnifiedEvidenceModule.riskEngine.rawValue,
                actual: riskEnvelope.module.rawValue
            )
        }
        guard riskEnvelope.sourceIssueID.rawValue == "GH-699" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskEnvelope.sourceIssueID",
                expected: "GH-699",
                actual: riskEnvelope.sourceIssueID.rawValue
            )
        }
        guard riskEnvelope.upstreamEvidenceID == input.upstreamEvidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskEnvelope.upstreamEvidenceID",
                expected: input.upstreamEvidenceID.rawValue,
                actual: riskEnvelope.upstreamEvidenceID?.rawValue ?? "nil"
            )
        }
        switch status {
        case .allow:
            guard reason == nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "reason",
                    expected: "nil for allow",
                    actual: reason?.rawValue ?? "nil"
                )
            }
            guard Set(passedGates) == Set(ReleaseV040RiskEnginePreTradeGateType.allCases) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "passedGates",
                    expected: ReleaseV040RiskEnginePreTradeGateType.allCases.map(\.rawValue).joined(separator: ","),
                    actual: passedGates.map(\.rawValue).joined(separator: ",")
                )
            }
        case .reject, .blocked:
            guard reason != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "reason",
                    expected: "non-nil for reject/blocked",
                    actual: "nil"
                )
            }
        }

        self.decisionID = decisionID
        self.runContext = runContext
        self.input = input
        self.policyID = policyID
        self.status = status
        self.reason = reason
        self.passedGates = passedGates
        self.proposedNotional = proposedNotional
        self.projectedAggregateExposure = projectedAggregateExposure
        self.evaluatedAt = evaluatedAt
        self.riskEnvelope = riskEnvelope
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decisionID: try container.decode(Identifier.self, forKey: .decisionID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            input: try container.decode(ReleaseV040RiskEngineStrategyIntentInput.self, forKey: .input),
            policyID: try container.decode(Identifier.self, forKey: .policyID),
            status: try container.decode(ReleaseV040RiskEnginePreTradeDecisionStatus.self, forKey: .status),
            reason: try container.decodeIfPresent(ReleaseV040RiskEnginePreTradeDecisionReason.self, forKey: .reason),
            passedGates: try container.decode([ReleaseV040RiskEnginePreTradeGateType].self, forKey: .passedGates),
            proposedNotional: try container.decodeIfPresent(Double.self, forKey: .proposedNotional),
            projectedAggregateExposure: try container.decodeIfPresent(Double.self, forKey: .projectedAggregateExposure),
            evaluatedAt: try container.decode(Date.self, forKey: .evaluatedAt),
            riskEnvelope: try container.decode(ReleaseV040UnifiedEvidenceEnvelope.self, forKey: .riskEnvelope)
        )
    }

    private var statusReasonPairHeld: Bool {
        switch status {
        case .allow:
            reason == nil
        case .reject, .blocked:
            reason != nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case decisionID
        case runContext
        case input
        case policyID
        case status
        case reason
        case passedGates
        case proposedNotional
        case projectedAggregateExposure
        case evaluatedAt
        case riskEnvelope
    }
}

/// ReleaseV040RiskEnginePreTradeRehearsalGateEvidence 汇总 GH-699 的 run-scoped risk decisions。
public struct ReleaseV040RiskEnginePreTradeRehearsalGateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let strategyIntentInputs: [ReleaseV040RiskEngineStrategyIntentInput]
    public let allowDecision: ReleaseV040RiskEnginePreTradeDecision
    public let rejectDecision: ReleaseV040RiskEnginePreTradeDecision
    public let killSwitchDecision: ReleaseV040RiskEnginePreTradeDecision
    public let noTradeDecision: ReleaseV040RiskEnginePreTradeDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var decisions: [ReleaseV040RiskEnginePreTradeDecision] {
        [allowDecision, rejectDecision, killSwitchDecision, noTradeDecision]
    }

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        decisions.map(\.riskEnvelope)
    }

    public var executionEligibleInputs: [StrategyIntentMessage] {
        decisions.filter(\.executionEligible).map(\.input.intentMessage)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-699"
            && upstreamIssueID.rawValue == "GH-698"
            && downstreamIssueID.rawValue == "GH-700"
            && runContext.mode == .dryRun
            && strategyIntentInputs.allSatisfy(\.boundaryHeld)
            && strategyIntentInputs.allSatisfy { $0.runID == runContext.runID }
            && decisionCoverageHeld
            && runScopedRiskEvidenceHeld
            && downstreamBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var decisionCoverageHeld: Bool {
        allowDecision.status == .allow
            && allowDecision.reason == nil
            && rejectDecision.status == .reject
            && rejectDecision.reason == .notionalLimitExceeded
            && killSwitchDecision.status == .blocked
            && killSwitchDecision.reason == .killSwitchActive
            && noTradeDecision.status == .blocked
            && noTradeDecision.reason == .noTradeActive
            && executionEligibleInputs == [allowDecision.input.intentMessage]
    }

    public var runScopedRiskEvidenceHeld: Bool {
        decisions.allSatisfy(\.decisionHeld)
            && unifiedEnvelopes.allSatisfy { $0.runID == runContext.runID }
            && unifiedEnvelopes.map(\.module) == [.riskEngine, .riskEngine, .riskEngine, .riskEngine]
            && unifiedEnvelopes.map(\.sequence) == Array(1...unifiedEnvelopes.count)
    }

    public var downstreamBoundaryHeld: Bool {
        executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-699-v040-riskengine-pretrade-rehearsal-gate"),
        issueID: Identifier = Identifier.constant("GH-699"),
        upstreamIssueID: Identifier = Identifier.constant("GH-698"),
        downstreamIssueID: Identifier = Identifier.constant("GH-700"),
        runContext: ReleaseV040RehearsalRunContext,
        strategyIntentInputs: [ReleaseV040RiskEngineStrategyIntentInput],
        allowDecision: ReleaseV040RiskEnginePreTradeDecision,
        rejectDecision: ReleaseV040RiskEnginePreTradeDecision,
        killSwitchDecision: ReleaseV040RiskEnginePreTradeDecision,
        noTradeDecision: ReleaseV040RiskEnginePreTradeDecision,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-699" else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "issueID", expected: "GH-699", actual: issueID.rawValue)
        }
        guard upstreamIssueID.rawValue == "GH-698" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-698",
                actual: upstreamIssueID.rawValue
            )
        }
        guard downstreamIssueID.rawValue == "GH-700" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "downstreamIssueID",
                expected: "GH-700",
                actual: downstreamIssueID.rawValue
            )
        }
        guard strategyIntentInputs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "strategyIntentInputs",
                expected: "non-empty",
                actual: "empty"
            )
        }
        let decisions = [allowDecision, rejectDecision, killSwitchDecision, noTradeDecision]
        guard decisions.allSatisfy({ $0.runID == runContext.runID }),
              strategyIntentInputs.allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        try Self.validateForbiddenFlags(
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            executionClientAccessEnabled: executionClientAccessEnabled,
            brokerGatewayAccessEnabled: brokerGatewayAccessEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.runContext = runContext
        self.strategyIntentInputs = strategyIntentInputs
        self.allowDecision = allowDecision
        self.rejectDecision = rejectDecision
        self.killSwitchDecision = killSwitchDecision
        self.noTradeDecision = noTradeDecision
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            upstreamIssueID: try container.decode(Identifier.self, forKey: .upstreamIssueID),
            downstreamIssueID: try container.decode(Identifier.self, forKey: .downstreamIssueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            strategyIntentInputs: try container.decode([ReleaseV040RiskEngineStrategyIntentInput].self, forKey: .strategyIntentInputs),
            allowDecision: try container.decode(ReleaseV040RiskEnginePreTradeDecision.self, forKey: .allowDecision),
            rejectDecision: try container.decode(ReleaseV040RiskEnginePreTradeDecision.self, forKey: .rejectDecision),
            killSwitchDecision: try container.decode(ReleaseV040RiskEnginePreTradeDecision.self, forKey: .killSwitchDecision),
            noTradeDecision: try container.decode(ReleaseV040RiskEnginePreTradeDecision.self, forKey: .noTradeDecision),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            executionEngineBypassAllowed: try container.decode(Bool.self, forKey: .executionEngineBypassAllowed),
            omsBypassAllowed: try container.decode(Bool.self, forKey: .omsBypassAllowed),
            executionClientAccessEnabled: try container.decode(Bool.self, forKey: .executionClientAccessEnabled),
            brokerGatewayAccessEnabled: try container.decode(Bool.self, forKey: .brokerGatewayAccessEnabled),
            productionTradingEnabledByDefault: try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionSecretAutoReadEnabled: try container.decode(Bool.self, forKey: .productionSecretAutoReadEnabled),
            productionBrokerConnected: try container.decode(Bool.self, forKey: .productionBrokerConnected),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        )
    }

    public static let validationAnchor = "TVM-RELEASE-V040-RISKENGINE-PRETRADE-REHEARSAL-GATE"

    public static let requiredValidationAnchors = [
        "V040-06-RISKENGINE-PRETRADE-REHEARSAL-GATE",
        "V040-06-ALLOW-REJECT-BLOCK-DECISIONS",
        "V040-06-KILL-SWITCH-NO-TRADE-GUARDS",
        "V040-06-EXECUTIONENGINE-RISK-APPROVED-ONLY",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH699RiskEnginePreTradeRehearsalGateAllowsRejectsAndBlocksRunScopedIntents",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private enum CodingKeys: String, CodingKey {
        case evidenceID
        case issueID
        case upstreamIssueID
        case downstreamIssueID
        case runContext
        case strategyIntentInputs
        case allowDecision
        case rejectDecision
        case killSwitchDecision
        case noTradeDecision
        case validationAnchors
        case requiredValidationCommands
        case executionEngineBypassAllowed
        case omsBypassAllowed
        case executionClientAccessEnabled
        case brokerGatewayAccessEnabled
        case productionTradingEnabledByDefault
        case productionEndpointConnected
        case productionSecretAutoReadEnabled
        case productionBrokerConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }
}

/// ReleaseV040RiskEnginePreTradeRehearsalGate 执行 GH-699 local dry-run 风控 gate。
public struct ReleaseV040RiskEnginePreTradeRehearsalGate: Sendable {
    public let runContext: ReleaseV040RehearsalRunContext
    public let firstEvaluatedAt: Date
    public let evaluatedAtStride: TimeInterval

    public init(
        runContext: ReleaseV040RehearsalRunContext,
        firstEvaluatedAt: Date = Date(timeIntervalSince1970: 1_705_001_200),
        evaluatedAtStride: TimeInterval = 1
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard evaluatedAtStride > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "evaluatedAtStride",
                expected: "positive",
                actual: "\(evaluatedAtStride)"
            )
        }
        self.runContext = runContext
        self.firstEvaluatedAt = firstEvaluatedAt
        self.evaluatedAtStride = evaluatedAtStride
    }

    public func run(
        intentInputs: [ReleaseV040RiskEngineStrategyIntentInput],
        currentAggregateExposure: Double = 0
    ) throws -> ReleaseV040RiskEnginePreTradeRehearsalGateEvidence {
        guard intentInputs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingStrategyIntentInput")
        }
        guard intentInputs.allSatisfy({ $0.runID == runContext.runID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "intentInputs.runID",
                expected: runContext.runID.rawValue,
                actual: "split"
            )
        }
        guard currentAggregateExposure.isFinite && currentAggregateExposure >= 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "currentAggregateExposure",
                expected: "finite non-negative",
                actual: "\(currentAggregateExposure)"
            )
        }
        guard let commandInput = intentInputs.first(where: { $0.intentMessage.productAwareOrderIntent != nil }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("missingProductAwareOrderIntent")
        }

        let allowedStrategies = intentInputs.map(\.intentMessage.strategyID)
        let allowedInstruments = intentInputs.map(\.intentMessage.instrument)
        let allowPolicy = try ReleaseV040RiskEnginePreTradePolicy(
            policyID: Identifier.constant("gh-699-v040-riskengine-allow-policy"),
            allowedStrategyIDs: allowedStrategies,
            allowedInstruments: allowedInstruments,
            maxNotional: 100_000,
            maxAggregateExposure: 200_000
        )
        let rejectPolicy = try ReleaseV040RiskEnginePreTradePolicy(
            policyID: Identifier.constant("gh-699-v040-riskengine-reject-policy"),
            allowedStrategyIDs: allowedStrategies,
            allowedInstruments: allowedInstruments,
            maxNotional: 1,
            maxAggregateExposure: 200_000
        )
        let killSwitchPolicy = try ReleaseV040RiskEnginePreTradePolicy(
            policyID: Identifier.constant("gh-699-v040-riskengine-kill-switch-policy"),
            allowedStrategyIDs: allowedStrategies,
            allowedInstruments: allowedInstruments,
            maxNotional: 100_000,
            maxAggregateExposure: 200_000,
            killSwitchActive: true
        )
        let noTradePolicy = try ReleaseV040RiskEnginePreTradePolicy(
            policyID: Identifier.constant("gh-699-v040-riskengine-no-trade-policy"),
            allowedStrategyIDs: allowedStrategies,
            allowedInstruments: allowedInstruments,
            maxNotional: 100_000,
            maxAggregateExposure: 200_000,
            noTradeActive: true
        )

        let allowDecision = try evaluate(
            decisionID: Identifier.constant("gh-699-v040-riskengine-allow-decision"),
            input: commandInput,
            policy: allowPolicy,
            currentAggregateExposure: currentAggregateExposure,
            sequence: 1
        )
        let rejectDecision = try evaluate(
            decisionID: Identifier.constant("gh-699-v040-riskengine-reject-decision"),
            input: commandInput,
            policy: rejectPolicy,
            currentAggregateExposure: currentAggregateExposure,
            sequence: 2
        )
        let killSwitchDecision = try evaluate(
            decisionID: Identifier.constant("gh-699-v040-riskengine-kill-switch-block-decision"),
            input: commandInput,
            policy: killSwitchPolicy,
            currentAggregateExposure: currentAggregateExposure,
            sequence: 3
        )
        let noTradeDecision = try evaluate(
            decisionID: Identifier.constant("gh-699-v040-riskengine-no-trade-block-decision"),
            input: commandInput,
            policy: noTradePolicy,
            currentAggregateExposure: currentAggregateExposure,
            sequence: 4
        )

        return try ReleaseV040RiskEnginePreTradeRehearsalGateEvidence(
            runContext: runContext,
            strategyIntentInputs: intentInputs,
            allowDecision: allowDecision,
            rejectDecision: rejectDecision,
            killSwitchDecision: killSwitchDecision,
            noTradeDecision: noTradeDecision
        )
    }

    public func evaluate(
        decisionID: Identifier,
        input: ReleaseV040RiskEngineStrategyIntentInput,
        policy: ReleaseV040RiskEnginePreTradePolicy,
        currentAggregateExposure: Double,
        sequence: Int
    ) throws -> ReleaseV040RiskEnginePreTradeDecision {
        guard policy.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "policy.boundary",
                expected: "closed production and execution bypass flags",
                actual: "open"
            )
        }
        guard input.boundaryHeld else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .missingMessageBusTrace,
                passedGates: [],
                proposedNotional: nil,
                projectedAggregateExposure: nil,
                sequence: sequence
            )
        }
        guard policy.allowedStrategySet.contains(input.intentMessage.strategyID) else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .strategyNotAllowed,
                passedGates: [.messageBusTrace],
                proposedNotional: nil,
                projectedAggregateExposure: nil,
                sequence: sequence
            )
        }
        guard policy.allowedInstrumentSet.contains(input.intentMessage.instrument) else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .instrumentNotAllowed,
                passedGates: [.messageBusTrace, .strategyAllowlist],
                proposedNotional: nil,
                projectedAggregateExposure: nil,
                sequence: sequence
            )
        }

        let proposedNotional = input.intentMessage.productAwareOrderIntent.map {
            $0.quantity.rawValue * $0.referencePrice.rawValue
        }
        guard input.intentMessage.targetExposure.requiresOrderIntent == false || proposedNotional != nil else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .missingOrderIntent,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist],
                proposedNotional: nil,
                projectedAggregateExposure: nil,
                sequence: sequence
            )
        }
        if let proposedNotional, proposedNotional > policy.maxNotional {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .notionalLimitExceeded,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist],
                proposedNotional: proposedNotional,
                projectedAggregateExposure: currentAggregateExposure + proposedNotional,
                sequence: sequence
            )
        }
        let projectedAggregateExposure = currentAggregateExposure + (proposedNotional ?? 0)
        guard projectedAggregateExposure <= policy.maxAggregateExposure else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .reject,
                reason: .aggregateExposureLimitExceeded,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist, .limit],
                proposedNotional: proposedNotional,
                projectedAggregateExposure: projectedAggregateExposure,
                sequence: sequence
            )
        }
        guard policy.killSwitchActive == false else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .blocked,
                reason: .killSwitchActive,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist, .limit],
                proposedNotional: proposedNotional,
                projectedAggregateExposure: projectedAggregateExposure,
                sequence: sequence
            )
        }
        guard policy.noTradeActive == false else {
            return try decision(
                decisionID: decisionID,
                input: input,
                policy: policy,
                status: .blocked,
                reason: .noTradeActive,
                passedGates: [.messageBusTrace, .strategyAllowlist, .instrumentAllowlist, .limit, .killSwitch],
                proposedNotional: proposedNotional,
                projectedAggregateExposure: projectedAggregateExposure,
                sequence: sequence
            )
        }

        return try decision(
            decisionID: decisionID,
            input: input,
            policy: policy,
            status: .allow,
            reason: nil,
            passedGates: ReleaseV040RiskEnginePreTradeGateType.allCases,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: projectedAggregateExposure,
            sequence: sequence
        )
    }

    private func decision(
        decisionID: Identifier,
        input: ReleaseV040RiskEngineStrategyIntentInput,
        policy: ReleaseV040RiskEnginePreTradePolicy,
        status: ReleaseV040RiskEnginePreTradeDecisionStatus,
        reason: ReleaseV040RiskEnginePreTradeDecisionReason?,
        passedGates: [ReleaseV040RiskEnginePreTradeGateType],
        proposedNotional: Double?,
        projectedAggregateExposure: Double?,
        sequence: Int
    ) throws -> ReleaseV040RiskEnginePreTradeDecision {
        let riskEnvelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("gh-699-v040-riskengine-decision-\(sequence)-envelope"),
            runContext: runContext,
            module: .riskEngine,
            sourceIssueID: Identifier.constant("GH-699"),
            evidenceID: decisionID,
            upstreamEvidenceID: input.upstreamEvidenceID,
            validationAnchor: ReleaseV040RiskEnginePreTradeRehearsalGateEvidence.validationAnchor,
            sequence: sequence
        )
        return try ReleaseV040RiskEnginePreTradeDecision(
            decisionID: decisionID,
            runContext: runContext,
            input: input,
            policyID: policy.policyID,
            status: status,
            reason: reason,
            passedGates: passedGates,
            proposedNotional: proposedNotional,
            projectedAggregateExposure: projectedAggregateExposure,
            evaluatedAt: firstEvaluatedAt.addingTimeInterval(TimeInterval(sequence - 1) * evaluatedAtStride),
            riskEnvelope: riskEnvelope
        )
    }
}

private extension ReleaseV040RiskEnginePreTradeRehearsalGateEvidence {
    static func validateForbiddenFlags(
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        executionClientAccessEnabled: Bool,
        brokerGatewayAccessEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("executionClientAccessEnabled", executionClientAccessEnabled),
            ("brokerGatewayAccessEnabled", brokerGatewayAccessEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
