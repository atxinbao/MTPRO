import DomainModel
import Foundation
import MessageBus

/// ReleaseV070LocalRiskPolicyConfigError 描述 GH-789 本地 risk policy config 的合同错误。
///
/// 错误只覆盖本地 no-order session 的 policy 字段、allowlist、artifact replay 和
/// production boundary；不表达真实账户读取、broker margin / leverage、OMS 或订单能力。
public enum ReleaseV070LocalRiskPolicyConfigError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidLimit(field: String, value: Int64)
    case emptyAllowlist(String)
    case duplicateAllowlist(String)
    case disallowedSymbol(String)
    case disallowedProductType(String)
    case runIDMismatch(expected: Identifier, actual: Identifier)
    case missingRiskIntentInput
    case replayMismatch
    case artifactBoundaryMismatch(String)
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case let .invalidLimit(field, value):
            "Release v0.7.0 local risk policy config invalid limit \(field): \(value)"
        case let .emptyAllowlist(field):
            "Release v0.7.0 local risk policy config requires non-empty \(field)"
        case let .duplicateAllowlist(field):
            "Release v0.7.0 local risk policy config rejects duplicate \(field)"
        case let .disallowedSymbol(value):
            "Release v0.7.0 local risk policy config rejected disallowed symbol: \(value)"
        case let .disallowedProductType(value):
            "Release v0.7.0 local risk policy config rejected disallowed product type: \(value)"
        case let .runIDMismatch(expected, actual):
            "Release v0.7.0 local risk policy config runID mismatch: expected \(expected.rawValue), actual \(actual.rawValue)"
        case .missingRiskIntentInput:
            "Release v0.7.0 local risk policy config requires at least one StrategyIntent input"
        case .replayMismatch:
            "Release v0.7.0 local risk policy config replayed decisions do not match persisted records"
        case let .artifactBoundaryMismatch(reason):
            "Release v0.7.0 local risk policy config artifact boundary mismatch: \(reason)"
        case let .forbiddenProductionCapability(capability):
            "Release v0.7.0 local risk policy config rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV070LocalRiskPolicyDecisionScenario 固定 GH-789 deterministic policy coverage。
///
/// 这些 scenario 只证明 local dry-run policy config 可以产出 allow / reject / blocked
/// 风控证据；它们不是 production risk approval，也不会创建下游执行路径。
public enum ReleaseV070LocalRiskPolicyDecisionScenario: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case allow = "allow"
    case maxNotionalRejected = "max-notional-rejected"
    case maxExposureRejected = "max-exposure-rejected"
    case killSwitchBlocked = "kill-switch-blocked"
    case noTradeBlocked = "no-trade-blocked"
}

/// ReleaseV070LocalRiskPolicyConfig 是 GH-789 的本地 deterministic risk policy snapshot。
///
/// Policy 字段显式覆盖 maxNotional、maxExposure、killSwitch、noTrade、allowedSymbols
/// 和 allowedProductTypes。该配置只服务 v0.7.0 no-order runtime session 的本地证据，
/// 不读取 production account，不连接 broker，也不授权真实订单。
public struct ReleaseV070LocalRiskPolicyConfig: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let policyID: Identifier
    public let maxNotionalMinorUnits: Int64
    public let maxExposureMinorUnits: Int64
    public let killSwitchActive: Bool
    public let noTradeActive: Bool
    public let allowedSymbols: [Symbol]
    public let allowedProductTypes: [ProductType]
    public let validationAnchors: [String]
    public let productionAccountDataRequired: Bool
    public let brokerMarginLeverageReadEnabled: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var policyHeld: Bool {
        issueID.rawValue == "GH-789"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-761"]
            && releaseVersion == "v0.7.0"
            && policyID.rawValue.isEmpty == false
            && maxNotionalMinorUnits > 0
            && maxExposureMinorUnits > 0
            && allowedSymbols.isEmpty == false
            && allowedProductTypes.isEmpty == false
            && Set(allowedSymbols).count == allowedSymbols.count
            && Set(allowedProductTypes).count == allowedProductTypes.count
            && validationAnchors == ReleaseV070LocalRiskPolicyConfigContract.requiredValidationAnchors
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        productionAccountDataRequired == false
            && brokerMarginLeverageReadEnabled == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-789"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-761")],
        releaseVersion: String = "v0.7.0",
        policyID: Identifier,
        maxNotionalMinorUnits: Int64,
        maxExposureMinorUnits: Int64,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false,
        allowedSymbols: [Symbol],
        allowedProductTypes: [ProductType],
        validationAnchors: [String] = ReleaseV070LocalRiskPolicyConfigContract.requiredValidationAnchors,
        productionAccountDataRequired: Bool = false,
        brokerMarginLeverageReadEnabled: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard maxNotionalMinorUnits > 0 else {
            throw ReleaseV070LocalRiskPolicyConfigError.invalidLimit(field: "maxNotionalMinorUnits", value: maxNotionalMinorUnits)
        }
        guard maxExposureMinorUnits > 0 else {
            throw ReleaseV070LocalRiskPolicyConfigError.invalidLimit(field: "maxExposureMinorUnits", value: maxExposureMinorUnits)
        }
        guard allowedSymbols.isEmpty == false else {
            throw ReleaseV070LocalRiskPolicyConfigError.emptyAllowlist("allowedSymbols")
        }
        guard allowedProductTypes.isEmpty == false else {
            throw ReleaseV070LocalRiskPolicyConfigError.emptyAllowlist("allowedProductTypes")
        }
        guard Set(allowedSymbols).count == allowedSymbols.count else {
            throw ReleaseV070LocalRiskPolicyConfigError.duplicateAllowlist("allowedSymbols")
        }
        guard Set(allowedProductTypes).count == allowedProductTypes.count else {
            throw ReleaseV070LocalRiskPolicyConfigError.duplicateAllowlist("allowedProductTypes")
        }
        try Self.validateForbiddenFlags(
            productionAccountDataRequired: productionAccountDataRequired,
            brokerMarginLeverageReadEnabled: brokerMarginLeverageReadEnabled,
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            executionClientAccessEnabled: executionClientAccessEnabled,
            brokerGatewayAccessEnabled: brokerGatewayAccessEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnected: productionBrokerConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.policyID = policyID
        self.maxNotionalMinorUnits = maxNotionalMinorUnits
        self.maxExposureMinorUnits = maxExposureMinorUnits
        self.killSwitchActive = killSwitchActive
        self.noTradeActive = noTradeActive
        self.allowedSymbols = allowedSymbols
        self.allowedProductTypes = allowedProductTypes
        self.validationAnchors = validationAnchors
        self.productionAccountDataRequired = productionAccountDataRequired
        self.brokerMarginLeverageReadEnabled = brokerMarginLeverageReadEnabled
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard policyHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.artifactBoundaryMismatch("localRiskPolicyConfigDrift")
        }
    }

    public func validate(instrument: InstrumentIdentity) throws {
        guard allowedSymbols.contains(instrument.symbol) else {
            throw ReleaseV070LocalRiskPolicyConfigError.disallowedSymbol(instrument.symbol.rawValue)
        }
        guard allowedProductTypes.contains(instrument.productType) else {
            throw ReleaseV070LocalRiskPolicyConfigError.disallowedProductType(instrument.productType.rawValue)
        }
    }

    public func runtimePolicy(
        deterministicReferencePriceMinorUnits: Int64 = 1,
        currentAggregateExposureMinorUnits: Int64 = 0
    ) throws -> ReleaseV050RiskEngineRuntimePolicy {
        try ReleaseV050RiskEngineRuntimePolicy(
            policyID: policyID,
            maxTargetQuantityMinorUnits: Int64.max / 4,
            maxProjectedNotionalMinorUnits: maxNotionalMinorUnits,
            maxAggregateExposureMinorUnits: maxExposureMinorUnits,
            currentAggregateExposureMinorUnits: currentAggregateExposureMinorUnits,
            deterministicReferencePriceMinorUnits: deterministicReferencePriceMinorUnits,
            killSwitchActive: killSwitchActive,
            noTradeActive: noTradeActive,
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
    }

    public func evaluate(
        input: ReleaseV050RiskEngineRuntimeIntentInput,
        currentAggregateExposureMinorUnits: Int64 = 0
    ) throws -> ReleaseV050RiskEngineRuntimePolicyEvaluation {
        try validate(instrument: input.intent.instrument)
        return try runtimePolicy(currentAggregateExposureMinorUnits: currentAggregateExposureMinorUnits)
            .evaluate(input: input)
    }

    private static func validateForbiddenFlags(
        productionAccountDataRequired: Bool,
        brokerMarginLeverageReadEnabled: Bool,
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        executionClientAccessEnabled: Bool,
        brokerGatewayAccessEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnected: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionAccountDataRequired", productionAccountDataRequired),
            ("brokerMarginLeverageReadEnabled", brokerMarginLeverageReadEnabled),
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("executionClientAccessEnabled", executionClientAccessEnabled),
            ("brokerGatewayAccessEnabled", brokerGatewayAccessEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnected", productionBrokerConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]
        for (field, value) in forbiddenFlags where value {
            throw ReleaseV070LocalRiskPolicyConfigError.forbiddenProductionCapability(field)
        }
    }
}

/// ReleaseV070LocalRiskPolicyDecisionRecord 是单条本地 policy decision 的可持久化记录。
public struct ReleaseV070LocalRiskPolicyDecisionRecord: Codable, Equatable, Sendable {
    public let scenario: ReleaseV070LocalRiskPolicyDecisionScenario
    public let config: ReleaseV070LocalRiskPolicyConfig
    public let intentInput: ReleaseV050RiskEngineRuntimeIntentInput
    public let policyEvaluation: ReleaseV050RiskEngineRuntimePolicyEvaluation
    public let decisionEvent: RiskDecisionEvent
    public let policyArtifactPath: String
    public let decisionArtifactPath: String
    public let downstreamOMSLifecycleCreated: Bool
    public let executionClientRequestCreated: Bool
    public let brokerCommandCreated: Bool
    public let productionAccountDataRead: Bool

    public var recordHeld: Bool {
        config.policyHeld
            && intentInput.inputHeld
            && policyEvaluation.evaluationHeld
            && decisionEvent.sourceIntentID == intentInput.intent.strategyID
            && decisionEvent.decision == policyEvaluation.decision
            && decisionEvent.reason == policyEvaluation.reason.rawValue
            && policyArtifactPath.contains(config.policyID.rawValue)
            && decisionArtifactPath.contains(decisionEvent.decisionID.rawValue)
            && downstreamSuppressionHeld
            && scenarioDecisionHeld
    }

    public var downstreamSuppressionHeld: Bool {
        downstreamOMSLifecycleCreated == false
            && executionClientRequestCreated == false
            && brokerCommandCreated == false
            && productionAccountDataRead == false
    }

    private var scenarioDecisionHeld: Bool {
        switch scenario {
        case .allow:
            policyEvaluation.decision == .allowed && policyEvaluation.reason == .dryRunAllowed
        case .maxNotionalRejected:
            policyEvaluation.decision == .rejected && policyEvaluation.reason == .notionalLimitExceeded
        case .maxExposureRejected:
            policyEvaluation.decision == .rejected && policyEvaluation.reason == .aggregateExposureLimitExceeded
        case .killSwitchBlocked:
            policyEvaluation.decision == .blocked && policyEvaluation.reason == .killSwitchActive
        case .noTradeBlocked:
            policyEvaluation.decision == .blocked && policyEvaluation.reason == .noTradeActive
        }
    }

    public init(
        scenario: ReleaseV070LocalRiskPolicyDecisionScenario,
        config: ReleaseV070LocalRiskPolicyConfig,
        intentInput: ReleaseV050RiskEngineRuntimeIntentInput,
        policyEvaluation: ReleaseV050RiskEngineRuntimePolicyEvaluation,
        decisionEvent: RiskDecisionEvent,
        policyArtifactPath: String? = nil,
        decisionArtifactPath: String? = nil,
        downstreamOMSLifecycleCreated: Bool = false,
        executionClientRequestCreated: Bool = false,
        brokerCommandCreated: Bool = false,
        productionAccountDataRead: Bool = false
    ) throws {
        self.scenario = scenario
        self.config = config
        self.intentInput = intentInput
        self.policyEvaluation = policyEvaluation
        self.decisionEvent = decisionEvent
        self.policyArtifactPath = policyArtifactPath ?? "runs/\(intentInput.runID.rawValue)/risk-policy/\(config.policyID.rawValue).json"
        self.decisionArtifactPath = decisionArtifactPath ?? "runs/\(intentInput.runID.rawValue)/risk-policy/\(decisionEvent.decisionID.rawValue).json"
        self.downstreamOMSLifecycleCreated = downstreamOMSLifecycleCreated
        self.executionClientRequestCreated = executionClientRequestCreated
        self.brokerCommandCreated = brokerCommandCreated
        self.productionAccountDataRead = productionAccountDataRead

        guard recordHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.artifactBoundaryMismatch("decisionRecordDrift")
        }
    }
}

/// ReleaseV070LocalRiskPolicyRunSessionEvidence 是 RiskEngine 内部的 v0.7 no-order session mirror。
///
/// RiskEngine 不能 import ExecutionClient/FutureGate 的 run session 类型，因此这里仅保存
/// GH-783 已完成 session 的 runID / state / command count 证据，避免反向依赖或执行路径扩张。
public struct ReleaseV070LocalRiskPolicyRunSessionEvidence: Codable, Equatable, Sendable {
    public let upstreamIssueID: Identifier
    public let runID: Identifier
    public let sessionState: String
    public let commandCount: Int
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        upstreamIssueID.rawValue == "GH-783"
            && runID.rawValue.isEmpty == false
            && sessionState == "completed"
            && commandCount == 3
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        upstreamIssueID: Identifier = Identifier.constant("GH-783"),
        runID: Identifier,
        sessionState: String = "completed",
        commandCount: Int = 3,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.upstreamIssueID = upstreamIssueID
        self.runID = runID
        self.sessionState = try FoundationTargetID(sessionState, field: "releaseV070LocalRiskPolicyRunSessionState").rawValue
        self.commandCount = commandCount
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.artifactBoundaryMismatch("runSessionEvidenceDrift")
        }
    }
}

/// ReleaseV070LocalRiskPolicyEvidenceArtifact 汇总 GH-789 的 config、decision 与 replay evidence。
public struct ReleaseV070LocalRiskPolicyEvidenceArtifact: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runSession: ReleaseV070LocalRiskPolicyRunSessionEvidence
    public let sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    public let decisionRecords: [ReleaseV070LocalRiskPolicyDecisionRecord]
    public let replayedDecisionRecords: [ReleaseV070LocalRiskPolicyDecisionRecord]
    public let inspectablePolicyFields: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionAccountDataRequired: Bool
    public let brokerMarginLeverageReadEnabled: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let executionClientAccessEnabled: Bool
    public let brokerGatewayAccessEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var policyConfigs: [ReleaseV070LocalRiskPolicyConfig] {
        decisionRecords.map(\.config)
    }

    public var policyEvaluations: [ReleaseV050RiskEngineRuntimePolicyEvaluation] {
        decisionRecords.map(\.policyEvaluation)
    }

    public var decisionEvents: [RiskDecisionEvent] {
        decisionRecords.map(\.decisionEvent)
    }

    public var artifactHeld: Bool {
        issueID.rawValue == "GH-789"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-761"]
            && previousIssueID.rawValue == "GH-788"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-790", "GH-791", "GH-792"]
            && releaseVersion == "v0.7.0"
            && runSession.runID == sourceRiskResult.runID
            && runSession.evidenceHeld
            && sourceRiskResult.resultHeld
            && decisionRecords.map(\.scenario) == ReleaseV070LocalRiskPolicyDecisionScenario.allCases
            && decisionRecords.allSatisfy(\.recordHeld)
            && replayedDecisionRecords == decisionRecords
            && inspectablePolicyFields == Self.requiredInspectablePolicyFields
            && validationAnchors == ReleaseV070LocalRiskPolicyConfigContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV070LocalRiskPolicyConfigContract.requiredValidationCommands
            && forbiddenBoundaryHeld
    }

    public var replayHeld: Bool {
        replayedDecisionRecords == decisionRecords
            && Set(replayedDecisionRecords.map(\.decisionEvent.decisionID)) == Set(decisionRecords.map(\.decisionEvent.decisionID))
    }

    public var killSwitchNoTradeBlockDownstreamHeld: Bool {
        decisionRecords
            .filter { [.killSwitchBlocked, .noTradeBlocked].contains($0.scenario) }
            .allSatisfy {
                $0.policyEvaluation.decision == .blocked
                    && $0.downstreamSuppressionHeld
            }
    }

    public var forbiddenBoundaryHeld: Bool {
        productionAccountDataRequired == false
            && brokerMarginLeverageReadEnabled == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && executionClientAccessEnabled == false
            && brokerGatewayAccessEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-789"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-761")],
        previousIssueID: Identifier = Identifier.constant("GH-788"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-790"),
            Identifier.constant("GH-791"),
            Identifier.constant("GH-792")
        ],
        releaseVersion: String = "v0.7.0",
        runSession: ReleaseV070LocalRiskPolicyRunSessionEvidence,
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult,
        decisionRecords: [ReleaseV070LocalRiskPolicyDecisionRecord],
        replayedDecisionRecords: [ReleaseV070LocalRiskPolicyDecisionRecord],
        inspectablePolicyFields: [String] = Self.requiredInspectablePolicyFields,
        validationAnchors: [String] = ReleaseV070LocalRiskPolicyConfigContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV070LocalRiskPolicyConfigContract.requiredValidationCommands,
        productionAccountDataRequired: Bool = false,
        brokerMarginLeverageReadEnabled: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        executionClientAccessEnabled: Bool = false,
        brokerGatewayAccessEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard runSession.runID == sourceRiskResult.runID else {
            throw ReleaseV070LocalRiskPolicyConfigError.runIDMismatch(expected: runSession.runID, actual: sourceRiskResult.runID)
        }
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runSession = runSession
        self.sourceRiskResult = sourceRiskResult
        self.decisionRecords = decisionRecords
        self.replayedDecisionRecords = replayedDecisionRecords
        self.inspectablePolicyFields = inspectablePolicyFields
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionAccountDataRequired = productionAccountDataRequired
        self.brokerMarginLeverageReadEnabled = brokerMarginLeverageReadEnabled
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.executionClientAccessEnabled = executionClientAccessEnabled
        self.brokerGatewayAccessEnabled = brokerGatewayAccessEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard replayHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.replayMismatch
        }
        guard artifactHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.artifactBoundaryMismatch("evidenceArtifactDrift")
        }
    }

    public static let requiredInspectablePolicyFields = [
        "maxNotional",
        "maxExposure",
        "killSwitch",
        "noTrade",
        "allowedSymbols",
        "allowedProductTypes"
    ]
}

/// ReleaseV070LocalRiskPolicyConfigBuilder 生成 GH-789 deterministic evidence。
public enum ReleaseV070LocalRiskPolicyConfigBuilder {
    public static func deterministicEvidence(
        sourceRiskResult: ReleaseV060RiskEngineRuntimeRunnerResult
    ) throws -> ReleaseV070LocalRiskPolicyEvidenceArtifact {
        guard let firstInput = sourceRiskResult.intentInputs.first else {
            throw ReleaseV070LocalRiskPolicyConfigError.missingRiskIntentInput
        }
        let secondInput = sourceRiskResult.intentInputs.dropFirst().first ?? firstInput
        let runSession = try ReleaseV070LocalRiskPolicyRunSessionEvidence(runID: sourceRiskResult.runID)
        let allowedSymbols = Array(Set(sourceRiskResult.intentInputs.map(\.intent.instrument.symbol)))
            .sorted { $0.rawValue < $1.rawValue }
        let allowedProductTypes = Array(Set(sourceRiskResult.intentInputs.map(\.intent.instrument.productType)))
            .sorted { $0.rawValue < $1.rawValue }
        let records = try [
            record(
                scenario: .allow,
                input: firstInput,
                config: config(
                    policyID: "gh-789-v070-local-risk-policy-allow",
                    maxNotionalMinorUnits: Int64.max / 4,
                    maxExposureMinorUnits: Int64.max / 4,
                    allowedSymbols: allowedSymbols,
                    allowedProductTypes: allowedProductTypes
                ),
                decisionID: "gh-789-v070-risk-decision-allow"
            ),
            record(
                scenario: .maxNotionalRejected,
                input: secondInput,
                config: config(
                    policyID: "gh-789-v070-local-risk-policy-max-notional",
                    maxNotionalMinorUnits: 1,
                    maxExposureMinorUnits: Int64.max / 4,
                    allowedSymbols: allowedSymbols,
                    allowedProductTypes: allowedProductTypes
                ),
                decisionID: "gh-789-v070-risk-decision-max-notional"
            ),
            record(
                scenario: .maxExposureRejected,
                input: firstInput,
                config: config(
                    policyID: "gh-789-v070-local-risk-policy-max-exposure",
                    maxNotionalMinorUnits: Int64.max / 4,
                    maxExposureMinorUnits: 1,
                    allowedSymbols: allowedSymbols,
                    allowedProductTypes: allowedProductTypes
                ),
                currentAggregateExposureMinorUnits: 0,
                decisionID: "gh-789-v070-risk-decision-max-exposure"
            ),
            record(
                scenario: .killSwitchBlocked,
                input: firstInput,
                config: config(
                    policyID: "gh-789-v070-local-risk-policy-kill-switch",
                    maxNotionalMinorUnits: Int64.max / 4,
                    maxExposureMinorUnits: Int64.max / 4,
                    killSwitchActive: true,
                    allowedSymbols: allowedSymbols,
                    allowedProductTypes: allowedProductTypes
                ),
                decisionID: "gh-789-v070-risk-decision-kill-switch"
            ),
            record(
                scenario: .noTradeBlocked,
                input: secondInput,
                config: config(
                    policyID: "gh-789-v070-local-risk-policy-no-trade",
                    maxNotionalMinorUnits: Int64.max / 4,
                    maxExposureMinorUnits: Int64.max / 4,
                    noTradeActive: true,
                    allowedSymbols: allowedSymbols,
                    allowedProductTypes: allowedProductTypes
                ),
                decisionID: "gh-789-v070-risk-decision-no-trade"
            )
        ]
        return try ReleaseV070LocalRiskPolicyEvidenceArtifact(
            runSession: runSession,
            sourceRiskResult: sourceRiskResult,
            decisionRecords: records,
            replayedDecisionRecords: records
        )
    }

    private static func config(
        policyID: String,
        maxNotionalMinorUnits: Int64,
        maxExposureMinorUnits: Int64,
        killSwitchActive: Bool = false,
        noTradeActive: Bool = false,
        allowedSymbols: [Symbol],
        allowedProductTypes: [ProductType]
    ) throws -> ReleaseV070LocalRiskPolicyConfig {
        try ReleaseV070LocalRiskPolicyConfig(
            policyID: Identifier.constant(policyID),
            maxNotionalMinorUnits: maxNotionalMinorUnits,
            maxExposureMinorUnits: maxExposureMinorUnits,
            killSwitchActive: killSwitchActive,
            noTradeActive: noTradeActive,
            allowedSymbols: allowedSymbols,
            allowedProductTypes: allowedProductTypes
        )
    }

    private static func record(
        scenario: ReleaseV070LocalRiskPolicyDecisionScenario,
        input: ReleaseV050RiskEngineRuntimeIntentInput,
        config: ReleaseV070LocalRiskPolicyConfig,
        currentAggregateExposureMinorUnits: Int64 = 0,
        decisionID: String
    ) throws -> ReleaseV070LocalRiskPolicyDecisionRecord {
        let evaluation = try config.evaluate(
            input: input,
            currentAggregateExposureMinorUnits: currentAggregateExposureMinorUnits
        )
        let decisionEvent = try RiskDecisionEvent(
            decisionID: Identifier.constant(decisionID),
            sourceIntentID: input.intent.strategyID,
            decision: evaluation.decision,
            reason: evaluation.reason.rawValue
        )
        return try ReleaseV070LocalRiskPolicyDecisionRecord(
            scenario: scenario,
            config: config,
            intentInput: input,
            policyEvaluation: evaluation,
            decisionEvent: decisionEvent
        )
    }
}

/// ReleaseV070LocalRiskPolicyConfigContract 固定 GH-789 issue-level 验收合同。
public struct ReleaseV070LocalRiskPolicyConfigContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-789"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-783", "GH-761"]
            && previousIssueID.rawValue == "GH-788"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-790", "GH-791", "GH-792"]
            && releaseVersion == "v0.7.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-789"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-783"), Identifier.constant("GH-761")],
        previousIssueID: Identifier = Identifier.constant("GH-788"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-790"),
            Identifier.constant("GH-791"),
            Identifier.constant("GH-792")
        ],
        releaseVersion: String = "v0.7.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV070LocalRiskPolicyConfigError.artifactBoundaryMismatch("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV070LocalRiskPolicyConfigContract {
        try ReleaseV070LocalRiskPolicyConfigContract()
    }

    public static let requiredValidationAnchors = [
        "GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG",
        "TVM-RELEASE-V070-LOCAL-RISK-POLICY-CONFIG",
        "V070-011-LOCAL-RISK-POLICY-FIELDS",
        "V070-011-RISK-POLICY-ARTIFACTS-REPLAY",
        "V070-011-KILL-SWITCH-NO-TRADE-BLOCKS-DOWNSTREAM",
        "V070-011-ALLOWED-SYMBOLS-PRODUCT-TYPES",
        "V070-011-NO-PRODUCTION-ACCOUNT-DATA"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH789LocalRiskPolicyConfigPersistsReplayablePolicyAndDecisionEvidence",
        "bash checks/verify-v0.7.0-local-risk-policy-config.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
