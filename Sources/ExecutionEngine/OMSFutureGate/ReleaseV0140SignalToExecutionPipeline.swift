import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ReleaseV0140SignalToExecutionPipelineStage 描述 GH-1037 本地闭环证据链的固定阶段顺序。
///
/// 这些阶段只表达本地 testnet / dry-run 证据如何串联；它们不是生产交易授权，
/// 也不代表任何真实 broker endpoint 已经被连接。
public enum ReleaseV0140SignalToExecutionPipelineStage: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case strategySignal
    case orderIntent
    case riskEngine
    case executionContract
    case binanceTestnetAdapter
    case omsLocalOrderStore
    case orderEventLog
    case omsStateSync
    case reconciliation
}

/// ReleaseV0140SignalToExecutionPipelineStatus 是 GH-1037 pipeline report 的最终状态。
public enum ReleaseV0140SignalToExecutionPipelineStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case passed
    case failedClosed
}

/// ReleaseV0140StrategySignalEnvelope 是 Strategy Signal 进入 v0.14.0 执行前链路的本地 envelope。
///
/// Envelope 只消费 EMA / RSI 已生成的 product-aware pre-risk intent。它不导入、
/// 不调用 ExecutionClient，不保存 broker command，也不允许 hold signal 被升级成订单意图。
public struct ReleaseV0140StrategySignalEnvelope: Codable, Equatable, Sendable {
    public let signalID: Identifier
    public let productAwareOrderIntent: ProductAwareOrderIntent
    public let strategy: OrderIntentStrategyKind
    public let sourceMessageID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int
    public let emittedAt: Date
    public let strategyCallsExecutionClient: Bool
    public let strategyCallsOMS: Bool
    public let strategyCallsBroker: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        signalID: Identifier,
        productAwareOrderIntent: ProductAwareOrderIntent,
        strategy: OrderIntentStrategyKind,
        sourceMessageID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int,
        emittedAt: Date,
        strategyCallsExecutionClient: Bool = false,
        strategyCallsOMS: Bool = false,
        strategyCallsBroker: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard productAwareOrderIntent.isPreRiskGateIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.productAwareIntent",
                expected: "pre-risk product-aware intent",
                actual: "boundary drift"
            )
        }
        guard productAwareOrderIntent.targetExposure.requiresOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.targetExposure",
                expected: "target exposure requiring OrderIntent",
                actual: productAwareOrderIntent.targetExposure.rawValue
            )
        }
        guard OrderIntent.activeStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.nonReleaseStrategy")
        }
        guard OrderIntent.activeProductTypes.contains(productAwareOrderIntent.instrument.productType),
              productAwareOrderIntent.instrument.venue == OrderIntent.activeVenueID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.nonReleaseInstrument")
        }
        guard sourceSequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.sourceSequence",
                expected: "positive sequence",
                actual: "\(sourceSequence)"
            )
        }
        try Self.forbid(strategyCallsExecutionClient, "strategyCallsExecutionClient")
        try Self.forbid(strategyCallsOMS, "strategyCallsOMS")
        try Self.forbid(strategyCallsBroker, "strategyCallsBroker")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        guard signalID == Self.deterministicID(
            productAwareIntentID: productAwareOrderIntent.intentID,
            strategy: strategy,
            sourceMessageID: sourceMessageID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.signalID",
                expected: Self.deterministicID(
                    productAwareIntentID: productAwareOrderIntent.intentID,
                    strategy: strategy,
                    sourceMessageID: sourceMessageID,
                    strategyRunID: strategyRunID,
                    sourceSequence: sourceSequence
                ).rawValue,
                actual: signalID.rawValue
            )
        }

        self.signalID = signalID
        self.productAwareOrderIntent = productAwareOrderIntent
        self.strategy = strategy
        self.sourceMessageID = sourceMessageID
        self.strategyRunID = strategyRunID
        self.sourceSequence = sourceSequence
        self.emittedAt = emittedAt
        self.strategyCallsExecutionClient = strategyCallsExecutionClient
        self.strategyCallsOMS = strategyCallsOMS
        self.strategyCallsBroker = strategyCallsBroker
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    public var boundaryHeld: Bool {
        productAwareOrderIntent.isPreRiskGateIntent
            && productAwareOrderIntent.targetExposure.requiresOrderIntent
            && OrderIntent.activeStrategies.contains(strategy)
            && OrderIntent.activeProductTypes.contains(productAwareOrderIntent.instrument.productType)
            && productAwareOrderIntent.instrument.venue == OrderIntent.activeVenueID
            && sourceSequence > 0
            && strategyCallsExecutionClient == false
            && strategyCallsOMS == false
            && strategyCallsBroker == false
            && productionTradingEnabledByDefault == false
    }

    public var orderIntentSide: OrderIntentSide {
        switch productAwareOrderIntent.targetExposure {
        case .targetLong:
            .buy
        case .targetShort, .targetFlat:
            .sell
        case .hold:
            .buy
        }
    }

    public func makeOrderIntent(
        timeInForce: OrderIntentTimeInForce = .goodTillCanceled
    ) throws -> OrderIntent {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.unheldSignal")
        }
        let policy = try OrderIntentPolicy(timeInForce: timeInForce)
        let correlation = try OrderIntentCorrelationMetadata(
            correlationID: signalID,
            strategySignalID: signalID,
            sourceMessageID: sourceMessageID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence
        )
        return try OrderIntent(
            intentID: OrderIntent.deterministicID(
                instrument: productAwareOrderIntent.instrument,
                side: orderIntentSide,
                quantity: productAwareOrderIntent.quantity,
                strategy: strategy,
                policy: policy,
                correlation: correlation
            ),
            instrument: productAwareOrderIntent.instrument,
            side: orderIntentSide,
            quantity: productAwareOrderIntent.quantity,
            strategy: strategy,
            policy: policy,
            correlation: correlation,
            createdAt: emittedAt
        )
    }

    public static func deterministicID(
        productAwareIntentID: Identifier,
        strategy: OrderIntentStrategyKind,
        sourceMessageID: Identifier,
        strategyRunID: Identifier,
        sourceSequence: Int
    ) -> Identifier {
        .constant(
            "gh-1037-strategy-signal:\(productAwareIntentID.rawValue):\(strategy.rawValue):\(sourceMessageID.rawValue):\(strategyRunID.rawValue):\(sourceSequence)",
            field: "releaseV0140SignalPipeline.signalID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.signal.\(field)")
        }
    }
}

/// ReleaseV0140SignalToExecutionPipelineReport 汇总 GH-1037 Strategy Signal 到 reconciliation 的闭环证据。
///
/// passed report 必须覆盖 OrderIntent、RiskEngine、ExecutionContract、Binance testnet adapter
/// evidence、OMS event log、state sync 和 reconciliation。failedClosed report 只能停在 RiskEngine，
/// 并证明 adapter submit / OMS / reconciliation 没有被触达。
public struct ReleaseV0140SignalToExecutionPipelineReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let status: ReleaseV0140SignalToExecutionPipelineStatus
    public let completedStages: [ReleaseV0140SignalToExecutionPipelineStage]
    public let signalID: Identifier
    public let orderIntentID: Identifier
    public let riskDecisionID: Identifier
    public let riskOutcome: ReleaseV0140PreTradeRiskOutcome
    public let executionMappingID: Identifier?
    public let submitPathID: Identifier?
    public let localOrderID: Identifier?
    public let omsStoreID: Identifier?
    public let eventStreamID: Identifier?
    public let stateSnapshotID: Identifier?
    public let reconciliationReportID: Identifier?
    public let reconciliationStatus: ReleaseV0140ReconciliationStatus?
    public let strategiesNeverCallExecutionClient: Bool
    public let testnetSubmitEvidenceCreated: Bool
    public let adapterSubmitEvidenceCreated: Bool
    public let networkSubmitAttempted: Bool
    public let networkCancelReplaceAttempted: Bool
    public let omsEventLogCreated: Bool
    public let reconciliationCompleted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    private enum CodingKeys: String, CodingKey {
        case reportID
        case status
        case completedStages
        case signalID
        case orderIntentID
        case riskDecisionID
        case riskOutcome
        case executionMappingID
        case submitPathID
        case localOrderID
        case omsStoreID
        case eventStreamID
        case stateSnapshotID
        case reconciliationReportID
        case reconciliationStatus
        case strategiesNeverCallExecutionClient
        case testnetSubmitEvidenceCreated
        case adapterSubmitEvidenceCreated
        case networkSubmitAttempted
        case networkCancelReplaceAttempted
        case omsEventLogCreated
        case reconciliationCompleted
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case productionSubmitCancelReplace
        case validationAnchors
    }

    public init(
        status: ReleaseV0140SignalToExecutionPipelineStatus,
        completedStages: [ReleaseV0140SignalToExecutionPipelineStage],
        signalID: Identifier,
        orderIntentID: Identifier,
        riskDecisionID: Identifier,
        riskOutcome: ReleaseV0140PreTradeRiskOutcome,
        executionMappingID: Identifier?,
        submitPathID: Identifier?,
        localOrderID: Identifier?,
        omsStoreID: Identifier?,
        eventStreamID: Identifier?,
        stateSnapshotID: Identifier?,
        reconciliationReportID: Identifier?,
        reconciliationStatus: ReleaseV0140ReconciliationStatus?,
        strategiesNeverCallExecutionClient: Bool = true,
        testnetSubmitEvidenceCreated: Bool,
        adapterSubmitEvidenceCreated: Bool,
        networkSubmitAttempted: Bool = false,
        networkCancelReplaceAttempted: Bool = false,
        omsEventLogCreated: Bool,
        reconciliationCompleted: Bool,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard strategiesNeverCallExecutionClient else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.strategyDirectExecutionClient")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        try Self.forbid(networkSubmitAttempted, "networkSubmitAttempted")
        try Self.forbid(networkCancelReplaceAttempted, "networkCancelReplaceAttempted")

        switch status {
        case .passed:
            guard completedStages == Self.requiredPassedStages,
                  riskOutcome == .accepted,
                  executionMappingID != nil,
                  submitPathID != nil,
                  localOrderID != nil,
                  omsStoreID != nil,
                  eventStreamID != nil,
                  stateSnapshotID != nil,
                  reconciliationReportID != nil,
                  reconciliationStatus == .passed,
                  testnetSubmitEvidenceCreated,
                  adapterSubmitEvidenceCreated,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated,
                  reconciliationCompleted else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140SignalPipeline.passedReport",
                    expected: "complete accepted signal-to-reconciliation evidence chain",
                    actual: "\(riskOutcome.rawValue):\(completedStages.map(\.rawValue).joined(separator: ","))"
                )
            }
        case .failedClosed:
            guard completedStages == Self.requiredFailedClosedStages,
                  riskOutcome != .accepted,
                  executionMappingID == nil,
                  submitPathID == nil,
                  localOrderID == nil,
                  omsStoreID == nil,
                  eventStreamID == nil,
                  stateSnapshotID == nil,
                  reconciliationReportID == nil,
                  reconciliationStatus == nil,
                  testnetSubmitEvidenceCreated == false,
                  adapterSubmitEvidenceCreated == false,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated == false,
                  reconciliationCompleted == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140SignalPipeline.failedClosedReport",
                    expected: "RiskEngine stopped before adapter / OMS / reconciliation",
                    actual: "\(riskOutcome.rawValue):\(completedStages.map(\.rawValue).joined(separator: ","))"
                )
            }
        }

        self.reportID = Self.deterministicID(
            status: status,
            signalID: signalID,
            riskDecisionID: riskDecisionID,
            reconciliationReportID: reconciliationReportID
        )
        self.status = status
        self.completedStages = completedStages
        self.signalID = signalID
        self.orderIntentID = orderIntentID
        self.riskDecisionID = riskDecisionID
        self.riskOutcome = riskOutcome
        self.executionMappingID = executionMappingID
        self.submitPathID = submitPathID
        self.localOrderID = localOrderID
        self.omsStoreID = omsStoreID
        self.eventStreamID = eventStreamID
        self.stateSnapshotID = stateSnapshotID
        self.reconciliationReportID = reconciliationReportID
        self.reconciliationStatus = reconciliationStatus
        self.strategiesNeverCallExecutionClient = strategiesNeverCallExecutionClient
        self.testnetSubmitEvidenceCreated = testnetSubmitEvidenceCreated
        self.adapterSubmitEvidenceCreated = adapterSubmitEvidenceCreated
        self.networkSubmitAttempted = networkSubmitAttempted
        self.networkCancelReplaceAttempted = networkCancelReplaceAttempted
        self.omsEventLogCreated = omsEventLogCreated
        self.reconciliationCompleted = reconciliationCompleted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedReportID = try container.decode(Identifier.self, forKey: .reportID)
        try self.init(
            status: try container.decode(ReleaseV0140SignalToExecutionPipelineStatus.self, forKey: .status),
            completedStages: try container.decode([ReleaseV0140SignalToExecutionPipelineStage].self, forKey: .completedStages),
            signalID: try container.decode(Identifier.self, forKey: .signalID),
            orderIntentID: try container.decode(Identifier.self, forKey: .orderIntentID),
            riskDecisionID: try container.decode(Identifier.self, forKey: .riskDecisionID),
            riskOutcome: try container.decode(ReleaseV0140PreTradeRiskOutcome.self, forKey: .riskOutcome),
            executionMappingID: try container.decodeIfPresent(Identifier.self, forKey: .executionMappingID),
            submitPathID: try container.decodeIfPresent(Identifier.self, forKey: .submitPathID),
            localOrderID: try container.decodeIfPresent(Identifier.self, forKey: .localOrderID),
            omsStoreID: try container.decodeIfPresent(Identifier.self, forKey: .omsStoreID),
            eventStreamID: try container.decodeIfPresent(Identifier.self, forKey: .eventStreamID),
            stateSnapshotID: try container.decodeIfPresent(Identifier.self, forKey: .stateSnapshotID),
            reconciliationReportID: try container.decodeIfPresent(Identifier.self, forKey: .reconciliationReportID),
            reconciliationStatus: try container.decodeIfPresent(ReleaseV0140ReconciliationStatus.self, forKey: .reconciliationStatus),
            strategiesNeverCallExecutionClient: try container.decode(Bool.self, forKey: .strategiesNeverCallExecutionClient),
            testnetSubmitEvidenceCreated: try container.decode(Bool.self, forKey: .testnetSubmitEvidenceCreated),
            adapterSubmitEvidenceCreated: try container.decode(Bool.self, forKey: .adapterSubmitEvidenceCreated),
            networkSubmitAttempted: try container.decode(Bool.self, forKey: .networkSubmitAttempted),
            networkCancelReplaceAttempted: try container.decode(Bool.self, forKey: .networkCancelReplaceAttempted),
            omsEventLogCreated: try container.decode(Bool.self, forKey: .omsEventLogCreated),
            reconciliationCompleted: try container.decode(Bool.self, forKey: .reconciliationCompleted),
            productionTradingEnabledByDefault: try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault),
            productionSecretRead: try container.decode(Bool.self, forKey: .productionSecretRead),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionSubmitCancelReplace: try container.decode(Bool.self, forKey: .productionSubmitCancelReplace),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors)
        )
        guard reportID == decodedReportID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.report.decode.reportID",
                expected: reportID.rawValue,
                actual: decodedReportID.rawValue
            )
        }
    }

    public var boundaryHeld: Bool {
        strategiesNeverCallExecutionClient
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && networkSubmitAttempted == false
            && networkCancelReplaceAttempted == false
            && validationAnchors == Self.requiredValidationAnchors
            && (
                (status == .passed
                    && completedStages == Self.requiredPassedStages
                    && riskOutcome == .accepted
                    && reconciliationStatus == .passed
                    && testnetSubmitEvidenceCreated
                    && adapterSubmitEvidenceCreated
                    && omsEventLogCreated
                    && reconciliationCompleted)
                || (status == .failedClosed
                    && completedStages == Self.requiredFailedClosedStages
                    && riskOutcome != .accepted
                    && executionMappingID == nil
                    && adapterSubmitEvidenceCreated == false
                    && reconciliationCompleted == false)
            )
    }

    public static let requiredPassedStages: [ReleaseV0140SignalToExecutionPipelineStage] = [
        .strategySignal,
        .orderIntent,
        .riskEngine,
        .executionContract,
        .binanceTestnetAdapter,
        .omsLocalOrderStore,
        .orderEventLog,
        .omsStateSync,
        .reconciliation
    ]

    public static let requiredFailedClosedStages: [ReleaseV0140SignalToExecutionPipelineStage] = [
        .strategySignal,
        .orderIntent,
        .riskEngine
    ]

    public static let requiredValidationAnchors = [
        "GH-1037-SIGNAL-TO-EXECUTION-PIPELINE",
        "GH-1037-STRATEGY-NO-DIRECT-EXECUTIONCLIENT",
        "GH-1037-RISK-TO-RECONCILIATION-EVIDENCE",
        "TVM-RELEASE-V0140-SIGNAL-EXECUTION-PIPELINE"
    ]

    public static func deterministicID(
        status: ReleaseV0140SignalToExecutionPipelineStatus,
        signalID: Identifier,
        riskDecisionID: Identifier,
        reconciliationReportID: Identifier?
    ) -> Identifier {
        .constant(
            "gh-1037-signal-execution-report:\(status.rawValue):\(signalID.rawValue):\(riskDecisionID.rawValue):\(reconciliationReportID?.rawValue ?? "none")",
            field: "releaseV0140SignalPipeline.reportID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.report.\(field)")
        }
    }
}

/// ReleaseV0140SignalToExecutionPipeline 串联 GH-1037 的本地 signal -> reconciliation 证据。
///
/// Pipeline 只在 accepted risk decision 后生成 testnet submit evidence，并保持
/// `networkOrderActionPerformed == false`。RiskEngine rejected / blocked 会直接返回
/// failed-closed report，不产生 adapter、OMS 或 reconciliation evidence。
public struct ReleaseV0140SignalToExecutionPipeline: Codable, Equatable, Sendable {
    public let pipelineID: Identifier
    public let strategiesNeverCallExecutionClient: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let validationAnchors: [String]

    public init(
        pipelineID: Identifier = Identifier.constant("gh-1037-signal-to-execution-pipeline"),
        strategiesNeverCallExecutionClient: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        validationAnchors: [String] = ReleaseV0140SignalToExecutionPipelineReport.requiredValidationAnchors
    ) throws {
        guard strategiesNeverCallExecutionClient else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.strategyDirectExecutionClient")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        guard validationAnchors == ReleaseV0140SignalToExecutionPipelineReport.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.pipeline.validationAnchors",
                expected: ReleaseV0140SignalToExecutionPipelineReport.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.pipelineID = pipelineID
        self.strategiesNeverCallExecutionClient = strategiesNeverCallExecutionClient
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        strategiesNeverCallExecutionClient
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && validationAnchors == ReleaseV0140SignalToExecutionPipelineReport.requiredValidationAnchors
    }

    public func run(
        signal: ReleaseV0140StrategySignalEnvelope,
        referencePrice: Double,
        riskGate: ReleaseV0140PreTradeRiskEngineGate,
        noTradeStateActive: Bool = false,
        killSwitchActive: Bool = false,
        productionTradingRequested: Bool = false
    ) throws -> ReleaseV0140SignalToExecutionPipelineReport {
        guard boundaryHeld, signal.boundaryHeld, riskGate.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.unheldInputs")
        }
        let intent = try signal.makeOrderIntent()
        let riskDecision = try riskGate.evaluate(
            intent: intent,
            referencePrice: referencePrice,
            noTradeStateActive: noTradeStateActive,
            killSwitchActive: killSwitchActive,
            productionTradingRequested: productionTradingRequested
        )

        guard riskDecision.outcome == .accepted else {
            return try ReleaseV0140SignalToExecutionPipelineReport(
                status: .failedClosed,
                completedStages: ReleaseV0140SignalToExecutionPipelineReport.requiredFailedClosedStages,
                signalID: signal.signalID,
                orderIntentID: intent.intentID,
                riskDecisionID: riskDecision.decisionID,
                riskOutcome: riskDecision.outcome,
                executionMappingID: nil,
                submitPathID: nil,
                localOrderID: nil,
                omsStoreID: nil,
                eventStreamID: nil,
                stateSnapshotID: nil,
                reconciliationReportID: nil,
                reconciliationStatus: nil,
                strategiesNeverCallExecutionClient: strategiesNeverCallExecutionClient,
                testnetSubmitEvidenceCreated: false,
                adapterSubmitEvidenceCreated: false,
                omsEventLogCreated: false,
                reconciliationCompleted: false,
                validationAnchors: validationAnchors
            )
        }

        let mapping = try ExecutionContractRequestMapping(
            mappingID: ExecutionContractRequestMapping.deterministicID(
                intentID: intent.intentID,
                operation: .submit,
                mode: .binanceTestnet,
                lifecycleState: riskDecision.nextLifecycleState
            ),
            intent: intent,
            operation: .submit,
            mode: .binanceTestnet,
            lifecycleState: riskDecision.nextLifecycleState
        )
        let result = try ExecutionContractSubmissionResult(
            resultID: ExecutionContractSubmissionResult.deterministicID(
                mappingID: mapping.mappingID,
                state: mapping.targetLifecycleState
            ),
            mapping: mapping
        )
        let acknowledgement = try ExecutionContractAcknowledgement(
            acknowledgementID: ExecutionContractAcknowledgement.deterministicID(resultID: result.resultID),
            result: result
        )
        let adapterBoundary = try ReleaseV0140BinanceTestnetAdapterBoundary()
        let endpoint = try endpointReference(
            for: intent.instrument.productType,
            boundary: adapterBoundary
        )
        let operatorGate = try ReleaseV0140BinanceTestnetSubmitOperatorGate.fixture(correlation: intent.correlation)
        let request = try ReleaseV0140BinanceTestnetSubmitRequestEvidence(
            requestID: ReleaseV0140BinanceTestnetSubmitRequestEvidence.deterministicID(
                mappingID: mapping.mappingID,
                productType: intent.instrument.productType,
                sourceSequence: intent.correlation.sourceSequence
            ),
            intent: intent,
            mapping: mapping,
            endpoint: endpoint,
            operatorGate: operatorGate
        )
        let response = try ReleaseV0140BinanceTestnetSubmitResponseEvidence(
            responseID: ReleaseV0140BinanceTestnetSubmitResponseEvidence.deterministicID(
                requestID: request.requestID,
                resultID: result.resultID,
                acknowledgementID: acknowledgement.acknowledgementID
            ),
            request: request,
            result: result,
            acknowledgement: acknowledgement
        )
        let submitPath = try ReleaseV0140BinanceTestnetSubmitPath(
            pathID: ReleaseV0140BinanceTestnetSubmitPath.deterministicID(
                requestID: request.requestID,
                responseID: response.responseID
            ),
            boundary: adapterBoundary,
            operatorGate: operatorGate,
            request: request,
            result: result,
            acknowledgement: acknowledgement,
            response: response
        )
        let localOrder = try ReleaseV0140LocalOMSOrderIdentity(
            localOrderID: ReleaseV0140LocalOMSOrderIdentity.deterministicID(
                responseID: response.responseID,
                lifecycleState: .accepted
            ),
            submitRequest: request,
            submitResponse: response,
            submitPath: submitPath
        )
        let omsStore = try ReleaseV0140OMSLocalOrderStore().append(localOrder: localOrder)
        let omsEvent = try firstOMSEvent(from: omsStore)
        let orderEvent = try ReleaseV0140OrderEventSourcingEvent.fromOMSStoreEvent(
            sequence: 1,
            omsEvent: omsEvent,
            correlationID: intent.correlation.correlationID,
            riskEvidenceID: riskDecision.decisionID,
            executionEvidenceID: response.responseID,
            adapterEvidenceID: submitPath.pathID
        )
        let stream = try ReleaseV0140OrderEventSourcingStream.replay(events: [orderEvent])
        let snapshot = try ReleaseV0140OMSStateSyncEngine().sync(stream: stream)
        let observation = try ReleaseV0140TestnetExecutionObservation(
            observationID: ReleaseV0140TestnetExecutionObservation.deterministicID(
                kind: .submitAcknowledgement,
                localOrderID: localOrder.localOrderID,
                sourceEventID: orderEvent.eventID,
                executionEvidenceID: response.responseID
            ),
            kind: .submitAcknowledgement,
            localOrderID: localOrder.localOrderID,
            productType: intent.instrument.productType,
            symbol: intent.instrument.symbol,
            orderIntentID: intent.intentID,
            sourceEventID: orderEvent.eventID,
            targetLifecycleState: .accepted,
            executionEvidenceID: response.responseID,
            adapterEvidenceID: submitPath.pathID
        )
        let reconciliation = try ReleaseV0140ReconciliationEngine().reconcile(
            snapshot: snapshot,
            stream: stream,
            observations: [observation]
        )

        return try ReleaseV0140SignalToExecutionPipelineReport(
            status: .passed,
            completedStages: ReleaseV0140SignalToExecutionPipelineReport.requiredPassedStages,
            signalID: signal.signalID,
            orderIntentID: intent.intentID,
            riskDecisionID: riskDecision.decisionID,
            riskOutcome: riskDecision.outcome,
            executionMappingID: mapping.mappingID,
            submitPathID: submitPath.pathID,
            localOrderID: localOrder.localOrderID,
            omsStoreID: omsStore.storeID,
            eventStreamID: stream.streamID,
            stateSnapshotID: snapshot.snapshotID,
            reconciliationReportID: reconciliation.reportID,
            reconciliationStatus: reconciliation.status,
            strategiesNeverCallExecutionClient: strategiesNeverCallExecutionClient,
            testnetSubmitEvidenceCreated: true,
            adapterSubmitEvidenceCreated: true,
            omsEventLogCreated: true,
            reconciliationCompleted: true,
            validationAnchors: validationAnchors
        )
    }

    private func endpointReference(
        for productType: ProductType,
        boundary: ReleaseV0140BinanceTestnetAdapterBoundary
    ) throws -> ReleaseV0140BinanceTestnetEndpointReference {
        guard let endpoint = boundary.endpoints.first(where: { $0.productType == productType }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.endpoint",
                expected: productType.rawValue,
                actual: "missing"
            )
        }
        return endpoint
    }

    private func firstOMSEvent(
        from store: ReleaseV0140OMSLocalOrderStore
    ) throws -> ReleaseV0140OMSLocalOrderStoreEvent {
        guard let event = store.events.first else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140SignalPipeline.omsEvent",
                expected: "appended local OMS event",
                actual: "missing"
            )
        }
        return event
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140SignalPipeline.pipeline.\(field)")
        }
    }
}
