import DomainModel
import Foundation
import MessageBus
import TraderStrategies

/// ReleaseV030TraderStrategyRehearsalMode 是 Trader 本地的 v0.3.0 rehearsal mode 表示。
///
/// Trader target 不依赖 ExecutionClient 或 DataEngine target；这里只使用稳定 raw value
/// 记录 rehearsal mode，证明 Trader 策略 rehearsal flow 处于 dry-run / testnet / shadow /
/// production-blocked 语义内，但不获得 endpoint、secret、broker 或 order command 能力。
public enum ReleaseV030TraderStrategyRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ReleaseV030TraderStrategyRuntimeRehearsalRequirement 固定 GH-660 的 Trader rehearsal 要求。
public enum ReleaseV030TraderStrategyRuntimeRehearsalRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamDataEngineRehearsalRequired = "upstream DataEngine rehearsal evidence required"
    case emaTargetExposureIntentRequired = "EMA target exposure intent required"
    case rsiTargetExposureIntentRequired = "RSI target exposure intent required"
    case messageBusIntentEvidenceRequired = "MessageBus intent evidence required"
    case strategyExecutionIsolationRequired = "strategy execution isolation required"
    case noProductionEndpointDependency = "no production endpoint dependency"
    case noProductionSecretAutoRead = "no production secret auto-read"
    case noProductionOrderSubmission = "no production order submission"
    case noProductionCutoverAuthorization = "no production cutover authorization"
}

/// ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability 枚举 GH-660 必须拒绝的漂移。
public enum ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedStrategy = "unsupported strategy"
    case missingEMAIntent = "missing EMA intent"
    case missingRSIIntent = "missing RSI intent"
    case directExecutionClientAccess = "direct ExecutionClient access"
    case directBinanceAdapterAccess = "direct Binance adapter access"
    case commandGatewayBypass = "CommandGateway bypass"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030TraderStrategyRuntimeRehearsalRecord 是单个策略意图进入 MessageBus 的证据。
///
/// record 只描述 Trader 调用现有 EMA / RSI emitter 后得到的 `StrategyIntentMessage`；
/// 它不是订单命令、RiskEngine 决策、ExecutionEngine handoff 或 broker request。
public struct ReleaseV030TraderStrategyRuntimeRehearsalRecord: Codable, Equatable, Sendable {
    public let mode: ReleaseV030TraderStrategyRehearsalMode
    public let strategyName: String
    public let message: StrategyIntentMessage
    public let payloadType: String
    public let directExecutionClientAccessEnabled: Bool
    public let directBinanceAdapterAccessEnabled: Bool
    public let commandGatewayBypassAllowed: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var recordHeld: Bool {
        ["EMA", "RSI"].contains(strategyName)
            && message.instrument.venue.rawValue == "binance"
            && [.spot, .usdsPerpetual].contains(message.instrument.productType)
            && payloadType.contains("trader.release-v0.3.0.binance")
            && payloadType.contains(strategyName.lowercased())
            && orderIntentBoundaryHeld
            && strategyIsolationHeld
            && productionCapabilitiesClosed
    }

    public var orderIntentBoundaryHeld: Bool {
        if message.targetExposure.requiresOrderIntent {
            return message.productAwareOrderIntent?.instrument == message.instrument
        }
        return message.productAwareOrderIntent == nil
    }

    public var strategyIsolationHeld: Bool {
        directExecutionClientAccessEnabled == false
            && directBinanceAdapterAccessEnabled == false
            && commandGatewayBypassAllowed == false
    }

    public var productionCapabilitiesClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        mode: ReleaseV030TraderStrategyRehearsalMode,
        strategyName: String,
        message: StrategyIntentMessage,
        payloadType: String,
        directExecutionClientAccessEnabled: Bool = false,
        directBinanceAdapterAccessEnabled: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard ["EMA", "RSI"].contains(strategyName) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedStrategy")
        }
        guard message.instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonBinanceVenue")
        }
        guard [.spot, .usdsPerpetual].contains(message.instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("unsupportedProductType")
        }
        guard payloadType.contains("trader.release-v0.3.0.binance"),
              payloadType.contains(strategyName.lowercased()) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "payloadType",
                expected: "trader.release-v0.3.0.binance.\(strategyName.lowercased())",
                actual: payloadType
            )
        }
        guard directExecutionClientAccessEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("directExecutionClientAccessEnabled")
        }
        guard directBinanceAdapterAccessEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("directBinanceAdapterAccessEnabled")
        }
        guard commandGatewayBypassAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("commandGatewayBypassAllowed")
        }
        guard productionEndpointAutoConnectEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
        }
        guard productionSecretAutoReadEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionSecretAutoReadEnabled")
        }
        guard productionOrderSubmissionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionOrderSubmissionEnabled")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionCutoverAuthorized")
        }

        self.mode = mode
        self.strategyName = strategyName
        self.message = message
        self.payloadType = payloadType
        self.directExecutionClientAccessEnabled = directExecutionClientAccessEnabled
        self.directBinanceAdapterAccessEnabled = directBinanceAdapterAccessEnabled
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV030TraderStrategyRuntimeRehearsalEvidence 是 GH-660 的 Trader strategy evidence。
///
/// Evidence 证明 EMA 与 RSI 均能在 Trader runtime rehearsal 中生成 `TargetExposureIntent`
/// 并写入 MessageBus；策略仍不接触 ExecutionClient、Binance adapter、production endpoint 或订单命令。
public struct ReleaseV030TraderStrategyRuntimeRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamDataEngineRehearsalAnchor: String
    public let mode: ReleaseV030TraderStrategyRehearsalMode
    public let emaRecord: ReleaseV030TraderStrategyRuntimeRehearsalRecord
    public let rsiRecord: ReleaseV030TraderStrategyRuntimeRehearsalRecord
    public let intentMessages: [StrategyIntentMessage]
    public let eventEnvelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let requirements: [ReleaseV030TraderStrategyRuntimeRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let directExecutionClientAccessEnabled: Bool
    public let directBinanceAdapterAccessEnabled: Bool
    public let commandGatewayBypassAllowed: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-660"
            && upstreamIssueID.rawValue == "GH-659"
            && downstreamIssueID.rawValue == "GH-661"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamDataEngineRehearsalAnchor == Self.requiredUpstreamDataEngineRehearsalAnchor
            && mode == .dryRun
            && emaRecord.recordHeld
            && rsiRecord.recordHeld
            && intentCoverageHeld
            && messageBusTraceHeld
            && strategyIsolationHeld
            && productionCapabilitiesClosed
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && startsNextMilestone == false
    }

    public var intentCoverageHeld: Bool {
        intentMessages.count == 2
            && intentMessages.contains(emaRecord.message)
            && intentMessages.contains(rsiRecord.message)
            && emaRecord.strategyName == "EMA"
            && rsiRecord.strategyName == "RSI"
            && TargetExposureIntent.allCases.contains(emaRecord.message.targetExposure)
            && TargetExposureIntent.allCases.contains(rsiRecord.message.targetExposure)
            && emaRecord.orderIntentBoundaryHeld
            && rsiRecord.orderIntentBoundaryHeld
    }

    public var messageBusTraceHeld: Bool {
        eventEnvelopes.count == intentMessages.count
            && eventEnvelopes == replayedEnvelopes
            && eventEnvelopes.map(\.instrumentID) == intentMessages.map(\.instrument)
            && eventEnvelopes.allSatisfy { $0.payloadType.contains("trader.release-v0.3.0.binance") }
    }

    public var strategyIsolationHeld: Bool {
        directExecutionClientAccessEnabled == false
            && directBinanceAdapterAccessEnabled == false
            && commandGatewayBypassAllowed == false
            && emaRecord.strategyIsolationHeld
            && rsiRecord.strategyIsolationHeld
    }

    public var productionCapabilitiesClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && emaRecord.productionCapabilitiesClosed
            && rsiRecord.productionCapabilitiesClosed
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-660-release-v0.3.0-trader-strategy-runtime-rehearsal-flow"),
        issueID: Identifier = Identifier.constant("GH-660"),
        upstreamIssueID: Identifier = Identifier.constant("GH-659"),
        downstreamIssueID: Identifier = Identifier.constant("GH-661"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamDataEngineRehearsalAnchor: String = Self.requiredUpstreamDataEngineRehearsalAnchor,
        mode: ReleaseV030TraderStrategyRehearsalMode = .dryRun,
        emaRecord: ReleaseV030TraderStrategyRuntimeRehearsalRecord,
        rsiRecord: ReleaseV030TraderStrategyRuntimeRehearsalRecord,
        intentMessages: [StrategyIntentMessage],
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        requirements: [ReleaseV030TraderStrategyRuntimeRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        directExecutionClientAccessEnabled: Bool = false,
        directBinanceAdapterAccessEnabled: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamDataEngineRehearsalAnchor: upstreamDataEngineRehearsalAnchor,
            mode: mode,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            directExecutionClientAccessEnabled: directExecutionClientAccessEnabled,
            directBinanceAdapterAccessEnabled: directBinanceAdapterAccessEnabled,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamDataEngineRehearsalAnchor = upstreamDataEngineRehearsalAnchor
        self.mode = mode
        self.emaRecord = emaRecord
        self.rsiRecord = rsiRecord
        self.intentMessages = intentMessages
        self.eventEnvelopes = eventEnvelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.directExecutionClientAccessEnabled = directExecutionClientAccessEnabled
        self.directBinanceAdapterAccessEnabled = directBinanceAdapterAccessEnabled
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamDataEngineRehearsalAnchor = "TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW"
    public static let requiredRequirements = ReleaseV030TraderStrategyRuntimeRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V030-04-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW",
        "V030-04-EMA-TARGET-EXPOSURE-INTENT-MESSAGEBUS",
        "V030-04-RSI-TARGET-EXPOSURE-INTENT-MESSAGEBUS",
        "V030-04-NO-STRATEGY-EXECUTIONCLIENT-OR-BINANCE-ADAPTER-ACCESS",
        "V030-04-TRACEABLE-TRADER-STRATEGY-REHEARSAL-EVIDENCE",
        "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030TraderStrategyRuntimeRehearsalFlow 由 Trader target 协调 EMA / RSI strategy intent。
public struct ReleaseV030TraderStrategyRuntimeRehearsalFlow: Sendable {
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil,
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_704_068_100),
        recordedAtStride: TimeInterval = 1
    ) throws {
        guard recordedAtStride > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordedAtStride",
                expected: "positive",
                actual: "\(recordedAtStride)"
            )
        }
        if let sourceID {
            self.sourceID = sourceID
        } else {
            self.sourceID = try FoundationTargetID("gh-660-trader-strategy-rehearsal-source")
        }
        if let streamID {
            self.streamID = streamID
        } else {
            self.streamID = try MessageBusJournalStreamID("trader.release-v0.3.0.strategy-intent-rehearsal")
        }
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    public func run(
        mode: ReleaseV030TraderStrategyRehearsalMode = .dryRun,
        upstreamDataEngineRehearsalAnchor: String =
            ReleaseV030TraderStrategyRuntimeRehearsalEvidence.requiredUpstreamDataEngineRehearsalAnchor,
        emaRuntime: EMAProposalRuntime,
        rsiEmitter: RSITargetExposureIntentEmitter,
        emaBars: [MarketBar],
        rsiBars: [MarketBar],
        emaInstrument: InstrumentIdentity,
        rsiInstrument: InstrumentIdentity,
        quantity: Quantity,
        emittedAt: Date
    ) throws -> ReleaseV030TraderStrategyRuntimeRehearsalEvidence {
        guard upstreamDataEngineRehearsalAnchor ==
                ReleaseV030TraderStrategyRuntimeRehearsalEvidence.requiredUpstreamDataEngineRehearsalAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamDataEngineRehearsalAnchor",
                expected: ReleaseV030TraderStrategyRuntimeRehearsalEvidence.requiredUpstreamDataEngineRehearsalAnchor,
                actual: upstreamDataEngineRehearsalAnchor
            )
        }

        let emaMessage = try emaRuntime.generateTargetExposureIntent(
            from: emaBars,
            instrument: emaInstrument,
            sourceSequence: 1,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let rsiMessage = try rsiEmitter.generateTargetExposureIntent(
            from: rsiBars,
            instrument: rsiInstrument,
            sourceSequence: 2,
            quantity: quantity,
            emittedAt: emittedAt.addingTimeInterval(1)
        )

        let emaPayloadType = payloadType(strategyName: "EMA", message: emaMessage)
        let rsiPayloadType = payloadType(strategyName: "RSI", message: rsiMessage)
        var journal = try MessageBusAppendOnlyJournal()
        let emaEnvelope = try appendEnvelope(
            journal: &journal,
            payloadType: emaPayloadType,
            message: emaMessage,
            sequence: 0
        )
        let rsiEnvelope = try appendEnvelope(
            journal: &journal,
            payloadType: rsiPayloadType,
            message: rsiMessage,
            sequence: 1
        )
        let eventEnvelopes = [emaEnvelope, rsiEnvelope]
        let replayedEnvelopes = journal.replay(stream: streamID)
        let emaRecord = try ReleaseV030TraderStrategyRuntimeRehearsalRecord(
            mode: mode,
            strategyName: "EMA",
            message: emaMessage,
            payloadType: emaPayloadType
        )
        let rsiRecord = try ReleaseV030TraderStrategyRuntimeRehearsalRecord(
            mode: mode,
            strategyName: "RSI",
            message: rsiMessage,
            payloadType: rsiPayloadType
        )

        return try ReleaseV030TraderStrategyRuntimeRehearsalEvidence(
            upstreamDataEngineRehearsalAnchor: upstreamDataEngineRehearsalAnchor,
            mode: mode,
            emaRecord: emaRecord,
            rsiRecord: rsiRecord,
            intentMessages: [emaMessage, rsiMessage],
            eventEnvelopes: eventEnvelopes,
            replayedEnvelopes: replayedEnvelopes
        )
    }

    private func appendEnvelope(
        journal: inout MessageBusAppendOnlyJournal,
        payloadType: String,
        message: StrategyIntentMessage,
        sequence: Int
    ) throws -> MessageBusJournalEnvelope {
        try journal.append(
            stream: streamID,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: message.instrument,
            recordedAt: firstRecordedAt.addingTimeInterval(TimeInterval(sequence) * recordedAtStride)
        )
    }

    private func payloadType(strategyName: String, message: StrategyIntentMessage) -> String {
        "trader.release-v0.3.0.binance.\(message.instrument.productType.rawValue).\(strategyName.lowercased()).targetExposureIntent.\(message.instrument.symbol.rawValue)"
    }
}

private extension ReleaseV030TraderStrategyRuntimeRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamDataEngineRehearsalAnchor: String,
        mode: ReleaseV030TraderStrategyRehearsalMode,
        requirements: [ReleaseV030TraderStrategyRuntimeRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamDataEngineRehearsalAnchor",
                upstreamDataEngineRehearsalAnchor == requiredUpstreamDataEngineRehearsalAnchor,
                requiredUpstreamDataEngineRehearsalAnchor,
                upstreamDataEngineRehearsalAnchor
            ),
            ("mode", mode == .dryRun, ReleaseV030TraderStrategyRehearsalMode.dryRun.rawValue, mode.rawValue),
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
        directExecutionClientAccessEnabled: Bool,
        directBinanceAdapterAccessEnabled: Bool,
        commandGatewayBypassAllowed: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("directExecutionClientAccessEnabled", directExecutionClientAccessEnabled),
            ("directBinanceAdapterAccessEnabled", directBinanceAdapterAccessEnabled),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, isEnabled) in forbiddenFlags where isEnabled {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
