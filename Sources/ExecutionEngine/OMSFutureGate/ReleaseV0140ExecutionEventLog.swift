import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ReleaseV0140ExecutionEventLogEntryKind 描述 GH-1040 只读执行事件日志展示的事件类型。
///
/// 这些事件来自 v0.14.0 本地 testnet closed-loop 证据链，只是 read-optimized evidence
/// surface，不是生产 broker event，也不授权真实 submit / cancel / replace。
public enum ReleaseV0140ExecutionEventLogEntryKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case strategySignal
    case orderIntent
    case riskDecision
    case adapterSubmit
    case omsLocalOrder
    case orderEventLog
    case reconciliation
}

/// ReleaseV0140ExecutionEventLogEntry 是 GH-1040 的单条只读 execution event log 记录。
///
/// Entry 把 run / signal / order intent / risk / adapter / OMS / reconciliation evidence ID
/// 串成可检索链路。它只保存 redacted evidence reference，不保存原始 broker payload，
/// 不读取 credential，不连接 endpoint，也不执行任何订单命令。
public struct ReleaseV0140ExecutionEventLogEntry: Codable, Equatable, Sendable {
    public let entryID: Identifier
    public let sequence: Int
    public let kind: ReleaseV0140ExecutionEventLogEntryKind
    public let stage: ReleaseV0140SignalToExecutionPipelineStage
    public let runID: Identifier
    public let signalID: Identifier
    public let orderIntentID: Identifier
    public let localOrderID: Identifier?
    public let productType: ProductType
    public let symbol: Symbol
    public let strategy: OrderIntentStrategyKind
    public let riskDecisionID: Identifier?
    public let executionMappingID: Identifier?
    public let adapterEvidenceID: Identifier?
    public let omsStoreID: Identifier?
    public let orderEventStreamID: Identifier?
    public let stateSnapshotID: Identifier?
    public let reconciliationReportID: Identifier?
    public let sourcePipelineReportID: Identifier
    public let sourceSequence: Int
    public let readOptimized: Bool
    public let independentlyInspectable: Bool
    public let redactedEvidenceOnly: Bool
    public let testnetEvidenceOnly: Bool
    public let linkBackComplete: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        entryID: Identifier,
        sequence: Int,
        kind: ReleaseV0140ExecutionEventLogEntryKind,
        stage: ReleaseV0140SignalToExecutionPipelineStage,
        runID: Identifier,
        signalID: Identifier,
        orderIntentID: Identifier,
        localOrderID: Identifier?,
        productType: ProductType,
        symbol: Symbol,
        strategy: OrderIntentStrategyKind,
        riskDecisionID: Identifier?,
        executionMappingID: Identifier?,
        adapterEvidenceID: Identifier?,
        omsStoreID: Identifier?,
        orderEventStreamID: Identifier?,
        stateSnapshotID: Identifier?,
        reconciliationReportID: Identifier?,
        sourcePipelineReportID: Identifier,
        sourceSequence: Int,
        readOptimized: Bool = true,
        independentlyInspectable: Bool = true,
        redactedEvidenceOnly: Bool = true,
        testnetEvidenceOnly: Bool = true,
        linkBackComplete: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard sequence > 0, sourceSequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.sequence",
                expected: "positive entry and source sequence",
                actual: "\(sequence):\(sourceSequence)"
            )
        }
        guard OrderIntent.activeProductTypes.contains(productType),
              OrderIntent.activeStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.nonReleaseScope")
        }
        guard readOptimized, independentlyInspectable, redactedEvidenceOnly, testnetEvidenceOnly, linkBackComplete else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.unheldReadOnlyEntry")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        try Self.validateEvidenceShape(
            kind: kind,
            stage: stage,
            localOrderID: localOrderID,
            riskDecisionID: riskDecisionID,
            executionMappingID: executionMappingID,
            adapterEvidenceID: adapterEvidenceID,
            omsStoreID: omsStoreID,
            orderEventStreamID: orderEventStreamID,
            stateSnapshotID: stateSnapshotID,
            reconciliationReportID: reconciliationReportID
        )
        guard entryID == Self.deterministicID(
            sequence: sequence,
            kind: kind,
            runID: runID,
            signalID: signalID,
            orderIntentID: orderIntentID,
            sourcePipelineReportID: sourcePipelineReportID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.entryID",
                expected: Self.deterministicID(
                    sequence: sequence,
                    kind: kind,
                    runID: runID,
                    signalID: signalID,
                    orderIntentID: orderIntentID,
                    sourcePipelineReportID: sourcePipelineReportID
                ).rawValue,
                actual: entryID.rawValue
            )
        }

        self.entryID = entryID
        self.sequence = sequence
        self.kind = kind
        self.stage = stage
        self.runID = runID
        self.signalID = signalID
        self.orderIntentID = orderIntentID
        self.localOrderID = localOrderID
        self.productType = productType
        self.symbol = symbol
        self.strategy = strategy
        self.riskDecisionID = riskDecisionID
        self.executionMappingID = executionMappingID
        self.adapterEvidenceID = adapterEvidenceID
        self.omsStoreID = omsStoreID
        self.orderEventStreamID = orderEventStreamID
        self.stateSnapshotID = stateSnapshotID
        self.reconciliationReportID = reconciliationReportID
        self.sourcePipelineReportID = sourcePipelineReportID
        self.sourceSequence = sourceSequence
        self.readOptimized = readOptimized
        self.independentlyInspectable = independentlyInspectable
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.linkBackComplete = linkBackComplete
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        sequence > 0
            && sourceSequence > 0
            && OrderIntent.activeProductTypes.contains(productType)
            && OrderIntent.activeStrategies.contains(strategy)
            && readOptimized
            && independentlyInspectable
            && redactedEvidenceOnly
            && testnetEvidenceOnly
            && linkBackComplete
            && rawBrokerPayloadIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        sequence: Int,
        kind: ReleaseV0140ExecutionEventLogEntryKind,
        runID: Identifier,
        signalID: Identifier,
        orderIntentID: Identifier,
        sourcePipelineReportID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1040-execution-event-log-entry:\(sequence):\(kind.rawValue):\(runID.rawValue):\(signalID.rawValue):\(orderIntentID.rawValue):\(sourcePipelineReportID.rawValue)",
            field: "releaseV0140ExecutionEventLog.entryID"
        )
    }

    private static func validateEvidenceShape(
        kind: ReleaseV0140ExecutionEventLogEntryKind,
        stage: ReleaseV0140SignalToExecutionPipelineStage,
        localOrderID: Identifier?,
        riskDecisionID: Identifier?,
        executionMappingID: Identifier?,
        adapterEvidenceID: Identifier?,
        omsStoreID: Identifier?,
        orderEventStreamID: Identifier?,
        stateSnapshotID: Identifier?,
        reconciliationReportID: Identifier?
    ) throws {
        let expectedStage = expectedStage(for: kind)
        guard stage == expectedStage else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.stage",
                expected: expectedStage.rawValue,
                actual: stage.rawValue
            )
        }

        switch kind {
        case .strategySignal:
            break
        case .orderIntent:
            break
        case .riskDecision:
            guard riskDecisionID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140ExecutionEventLog.riskDecisionID",
                    expected: "risk evidence ID",
                    actual: "missing"
                )
            }
        case .adapterSubmit:
            guard localOrderID != nil, riskDecisionID != nil, executionMappingID != nil, adapterEvidenceID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140ExecutionEventLog.adapterEvidence",
                    expected: "local order, risk, execution mapping and adapter evidence IDs",
                    actual: "missing"
                )
            }
        case .omsLocalOrder:
            guard localOrderID != nil, omsStoreID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140ExecutionEventLog.omsEvidence",
                    expected: "local order and OMS store IDs",
                    actual: "missing"
                )
            }
        case .orderEventLog:
            guard localOrderID != nil, omsStoreID != nil, orderEventStreamID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140ExecutionEventLog.orderEventStream",
                    expected: "local order, OMS store and event stream IDs",
                    actual: "missing"
                )
            }
        case .reconciliation:
            guard localOrderID != nil, orderEventStreamID != nil, stateSnapshotID != nil, reconciliationReportID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140ExecutionEventLog.reconciliationEvidence",
                    expected: "local order, event stream, state snapshot and reconciliation report IDs",
                    actual: "missing"
                )
            }
        }
    }

    private static func expectedStage(
        for kind: ReleaseV0140ExecutionEventLogEntryKind
    ) -> ReleaseV0140SignalToExecutionPipelineStage {
        switch kind {
        case .strategySignal:
            .strategySignal
        case .orderIntent:
            .orderIntent
        case .riskDecision:
            .riskEngine
        case .adapterSubmit:
            .binanceTestnetAdapter
        case .omsLocalOrder:
            .omsLocalOrderStore
        case .orderEventLog:
            .orderEventLog
        case .reconciliation:
            .reconciliation
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.entry.\(field)")
        }
    }
}

/// ReleaseV0140ExecutionEventLogReport 汇总 GH-1040 可读 event log surface。
///
/// Report 要求覆盖 Strategy Signal、OrderIntent、RiskEngine、testnet adapter、
/// OMS local store、order event log 与 reconciliation 七类事件，并保留完整 ID 链路。
public struct ReleaseV0140ExecutionEventLogReport: Codable, Equatable, Sendable {
    public let logID: Identifier
    public let runID: Identifier
    public let sourcePipelineReportID: Identifier
    public let sourceOrderEventStreamID: Identifier
    public let sourceReconciliationReportID: Identifier
    public let entries: [ReleaseV0140ExecutionEventLogEntry]
    public let entryKindsCovered: [ReleaseV0140ExecutionEventLogEntryKind]
    public let orderIntentIDs: [Identifier]
    public let localOrderIDs: [Identifier]
    public let riskDecisionIDs: [Identifier]
    public let adapterEvidenceIDs: [Identifier]
    public let omsStoreIDs: [Identifier]
    public let stateSnapshotIDs: [Identifier]
    public let reconciliationReportIDs: [Identifier]
    public let readOptimized: Bool
    public let independentlyInspectable: Bool
    public let redactedEvidenceOnly: Bool
    public let productionBoundaryHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        logID: Identifier,
        runID: Identifier,
        sourcePipelineReport: ReleaseV0140SignalToExecutionPipelineReport,
        entries: [ReleaseV0140ExecutionEventLogEntry],
        readOptimized: Bool = true,
        independentlyInspectable: Bool = true,
        redactedEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourcePipelineReport.boundaryHeld,
              sourcePipelineReport.status == .passed,
              let sourceOrderEventStreamID = sourcePipelineReport.eventStreamID,
              let sourceReconciliationReportID = sourcePipelineReport.reconciliationReportID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.sourcePipeline",
                expected: "passed pipeline report with event stream and reconciliation IDs",
                actual: sourcePipelineReport.status.rawValue
            )
        }
        guard entries.count == Self.requiredEventKinds.count,
              entries.map(\.sequence) == Self.expectedSequences,
              entries.map(\.kind) == Self.requiredEventKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.entries",
                expected: Self.requiredEventKinds.map(\.rawValue).joined(separator: ","),
                actual: entries.map(\.kind.rawValue).joined(separator: ",")
            )
        }
        guard entries.allSatisfy(\.boundaryHeld), entries.allSatisfy({ $0.runID == runID }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.unheldEntries")
        }
        guard entries.allSatisfy({ $0.sourcePipelineReportID == sourcePipelineReport.reportID }),
              entries.contains(where: { $0.orderEventStreamID == sourceOrderEventStreamID }),
              entries.contains(where: { $0.reconciliationReportID == sourceReconciliationReportID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.linkBack",
                expected: "entries linked to pipeline, order event stream and reconciliation report",
                actual: "missing link"
            )
        }
        guard readOptimized, independentlyInspectable, redactedEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.unheldReportSurface")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard logID == Self.deterministicID(
            runID: runID,
            sourcePipelineReportID: sourcePipelineReport.reportID,
            entryIDs: entries.map(\.entryID)
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.logID",
                expected: Self.deterministicID(
                    runID: runID,
                    sourcePipelineReportID: sourcePipelineReport.reportID,
                    entryIDs: entries.map(\.entryID)
                ).rawValue,
                actual: logID.rawValue
            )
        }

        self.logID = logID
        self.runID = runID
        self.sourcePipelineReportID = sourcePipelineReport.reportID
        self.sourceOrderEventStreamID = sourceOrderEventStreamID
        self.sourceReconciliationReportID = sourceReconciliationReportID
        self.entries = entries
        self.entryKindsCovered = entries.map(\.kind)
        self.orderIntentIDs = Self.unique(entries.map(\.orderIntentID))
        self.localOrderIDs = Self.unique(entries.compactMap(\.localOrderID))
        self.riskDecisionIDs = Self.unique(entries.compactMap(\.riskDecisionID))
        self.adapterEvidenceIDs = Self.unique(entries.compactMap(\.adapterEvidenceID))
        self.omsStoreIDs = Self.unique(entries.compactMap(\.omsStoreID))
        self.stateSnapshotIDs = Self.unique(entries.compactMap(\.stateSnapshotID))
        self.reconciliationReportIDs = Self.unique(entries.compactMap(\.reconciliationReportID))
        self.readOptimized = readOptimized
        self.independentlyInspectable = independentlyInspectable
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.productionBoundaryHeld = true
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        entries.count == Self.requiredEventKinds.count
            && entryKindsCovered == Self.requiredEventKinds
            && entries.allSatisfy(\.boundaryHeld)
            && entries.allSatisfy { $0.runID == runID }
            && entries.allSatisfy { $0.sourcePipelineReportID == sourcePipelineReportID }
            && entries.contains { $0.orderEventStreamID == sourceOrderEventStreamID }
            && entries.contains { $0.reconciliationReportID == sourceReconciliationReportID }
            && orderIntentIDs.isEmpty == false
            && localOrderIDs.isEmpty == false
            && riskDecisionIDs.isEmpty == false
            && adapterEvidenceIDs.isEmpty == false
            && omsStoreIDs.isEmpty == false
            && stateSnapshotIDs.isEmpty == false
            && reconciliationReportIDs == [sourceReconciliationReportID]
            && readOptimized
            && independentlyInspectable
            && redactedEvidenceOnly
            && productionBoundaryHeld
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public func entry(
        for kind: ReleaseV0140ExecutionEventLogEntryKind
    ) -> ReleaseV0140ExecutionEventLogEntry? {
        entries.first { $0.kind == kind }
    }

    public static let requiredEventKinds: [ReleaseV0140ExecutionEventLogEntryKind] = ReleaseV0140ExecutionEventLogEntryKind.allCases
    public static let expectedSequences = Array(1...ReleaseV0140ExecutionEventLogEntryKind.allCases.count)
    public static let requiredValidationAnchors = [
        "GH-1040-EXECUTION-EVENT-LOG",
        "GH-1040-RUN-ORDER-INTENT-LINKAGE",
        "GH-1040-REDACTED-READONLY-SURFACE",
        "TVM-RELEASE-V0140-EXECUTION-EVENT-LOG"
    ]

    public static func deterministicID(
        runID: Identifier,
        sourcePipelineReportID: Identifier,
        entryIDs: [Identifier]
    ) -> Identifier {
        .constant(
            "gh-1040-execution-event-log:\(runID.rawValue):\(sourcePipelineReportID.rawValue):\(entryIDs.map(\.rawValue).joined(separator: "|"))",
            field: "releaseV0140ExecutionEventLog.logID"
        )
    }

    private static func unique(_ values: [Identifier]) -> [Identifier] {
        values.reduce(into: []) { result, value in
            if result.contains(value) == false {
                result.append(value)
            }
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.report.\(field)")
        }
    }
}

/// ReleaseV0140ExecutionEventLog 生成 GH-1040 的只读 execution event log surface。
///
/// Builder 复用 GH-1037 pipeline report，不重新执行 adapter runtime，也不保存原始 payload。
/// 产物面向 Dashboard / CLI 只读检查，后续 UI 只能消费这些 redacted evidence IDs。
public struct ReleaseV0140ExecutionEventLog: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let pipeline: ReleaseV0140SignalToExecutionPipeline
    public let productType: ProductType
    public let strategy: OrderIntentStrategyKind
    public let targetExposure: TargetExposureIntent
    public let sourceSequence: Int
    public let referencePrice: Double
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        runID: Identifier = Identifier.constant("gh-1040-execution-event-log-run"),
        pipeline: ReleaseV0140SignalToExecutionPipeline? = nil,
        productType: ProductType = .spot,
        strategy: OrderIntentStrategyKind = .ema,
        targetExposure: TargetExposureIntent = .targetLong,
        sourceSequence: Int = 1_040,
        referencePrice: Double = 1_000.0,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0140ExecutionEventLogReport.requiredValidationAnchors
    ) throws {
        let resolvedPipeline = try pipeline ?? ReleaseV0140SignalToExecutionPipeline()
        guard resolvedPipeline.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.unheldPipeline")
        }
        guard OrderIntent.activeProductTypes.contains(productType),
              OrderIntent.activeStrategies.contains(strategy),
              targetExposure.isPreOrderAllowed(for: productType),
              targetExposure.requiresOrderIntent,
              sourceSequence > 0,
              referencePrice > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.fixture",
                expected: "release product / strategy / positive source and price",
                actual: "\(productType.rawValue):\(strategy.rawValue):\(sourceSequence):\(referencePrice)"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0140ExecutionEventLogReport.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.builder.validationAnchors",
                expected: ReleaseV0140ExecutionEventLogReport.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.runID = runID
        self.pipeline = resolvedPipeline
        self.productType = productType
        self.strategy = strategy
        self.targetExposure = targetExposure
        self.sourceSequence = sourceSequence
        self.referencePrice = referencePrice
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        pipeline.boundaryHeld
            && OrderIntent.activeProductTypes.contains(productType)
            && OrderIntent.activeStrategies.contains(strategy)
            && targetExposure.isPreOrderAllowed(for: productType)
            && targetExposure.requiresOrderIntent
            && sourceSequence > 0
            && referencePrice > 0
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0140ExecutionEventLogReport.requiredValidationAnchors
    }

    public func build() throws -> ReleaseV0140ExecutionEventLogReport {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.unheldBuilder")
        }
        let signal = try makeSignal()
        let pipelineReport = try pipeline.run(
            signal: signal,
            referencePrice: referencePrice,
            riskGate: ReleaseV0140PreTradeRiskEngineGate.deterministicFixture()
        )
        guard pipelineReport.status == .passed,
              let localOrderID = pipelineReport.localOrderID,
              let omsStoreID = pipelineReport.omsStoreID,
              let eventStreamID = pipelineReport.eventStreamID,
              let stateSnapshotID = pipelineReport.stateSnapshotID,
              let reconciliationReportID = pipelineReport.reconciliationReportID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140ExecutionEventLog.pipelineReport",
                expected: "passed pipeline with local order, OMS, event stream, state sync and reconciliation IDs",
                actual: pipelineReport.status.rawValue
            )
        }

        let entries = try Self.entryDefinitions.map { definition in
            try ReleaseV0140ExecutionEventLogEntry(
                entryID: ReleaseV0140ExecutionEventLogEntry.deterministicID(
                    sequence: definition.sequence,
                    kind: definition.kind,
                    runID: runID,
                    signalID: signal.signalID,
                    orderIntentID: pipelineReport.orderIntentID,
                    sourcePipelineReportID: pipelineReport.reportID
                ),
                sequence: definition.sequence,
                kind: definition.kind,
                stage: definition.stage,
                runID: runID,
                signalID: signal.signalID,
                orderIntentID: pipelineReport.orderIntentID,
                localOrderID: definition.includesLocalOrder ? localOrderID : nil,
                productType: productType,
                symbol: signal.productAwareOrderIntent.instrument.symbol,
                strategy: strategy,
                riskDecisionID: definition.includesRisk ? pipelineReport.riskDecisionID : nil,
                executionMappingID: definition.includesAdapter ? pipelineReport.executionMappingID : nil,
                adapterEvidenceID: definition.includesAdapter ? pipelineReport.submitPathID : nil,
                omsStoreID: definition.includesOMS ? omsStoreID : nil,
                orderEventStreamID: definition.includesEventStream ? eventStreamID : nil,
                stateSnapshotID: definition.includesStateSync ? stateSnapshotID : nil,
                reconciliationReportID: definition.includesReconciliation ? reconciliationReportID : nil,
                sourcePipelineReportID: pipelineReport.reportID,
                sourceSequence: sourceSequence
            )
        }

        return try ReleaseV0140ExecutionEventLogReport(
            logID: ReleaseV0140ExecutionEventLogReport.deterministicID(
                runID: runID,
                sourcePipelineReportID: pipelineReport.reportID,
                entryIDs: entries.map(\.entryID)
            ),
            runID: runID,
            sourcePipelineReport: pipelineReport,
            entries: entries,
            validationAnchors: validationAnchors
        )
    }

    private func makeSignal() throws -> ReleaseV0140StrategySignalEnvelope {
        let productAwareIntent = try ProductAwareOrderIntent(
            intentID: Identifier.constant(
                "gh-1040-product-aware:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
                field: "releaseV0140ExecutionEventLog.productAwareIntentID"
            ),
            instrument: InstrumentIdentity.binance(productType: productType, symbol: Symbol.constant("BTCUSDT")),
            targetExposure: targetExposure,
            quantity: Quantity(0.025, field: "releaseV0140ExecutionEventLog.quantity"),
            referencePrice: Price(referencePrice, field: "releaseV0140ExecutionEventLog.referencePrice"),
            createdAt: Date(timeIntervalSince1970: TimeInterval(sourceSequence))
        )
        let sourceMessageID = Identifier.constant(
            "gh-1040-message:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140ExecutionEventLog.sourceMessageID"
        )
        let strategyRunID = Identifier.constant(
            "gh-1040-run:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140ExecutionEventLog.strategyRunID"
        )
        return try ReleaseV0140StrategySignalEnvelope(
            signalID: ReleaseV0140StrategySignalEnvelope.deterministicID(
                productAwareIntentID: productAwareIntent.intentID,
                strategy: strategy,
                sourceMessageID: sourceMessageID,
                strategyRunID: strategyRunID,
                sourceSequence: sourceSequence
            ),
            productAwareOrderIntent: productAwareIntent,
            strategy: strategy,
            sourceMessageID: sourceMessageID,
            strategyRunID: strategyRunID,
            sourceSequence: sourceSequence,
            emittedAt: Date(timeIntervalSince1970: TimeInterval(sourceSequence))
        )
    }

    private struct EntryDefinition {
        let sequence: Int
        let kind: ReleaseV0140ExecutionEventLogEntryKind
        let stage: ReleaseV0140SignalToExecutionPipelineStage
        let includesLocalOrder: Bool
        let includesRisk: Bool
        let includesAdapter: Bool
        let includesOMS: Bool
        let includesEventStream: Bool
        let includesStateSync: Bool
        let includesReconciliation: Bool
    }

    private static let entryDefinitions: [EntryDefinition] = [
        EntryDefinition(sequence: 1, kind: .strategySignal, stage: .strategySignal, includesLocalOrder: false, includesRisk: false, includesAdapter: false, includesOMS: false, includesEventStream: false, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 2, kind: .orderIntent, stage: .orderIntent, includesLocalOrder: false, includesRisk: false, includesAdapter: false, includesOMS: false, includesEventStream: false, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 3, kind: .riskDecision, stage: .riskEngine, includesLocalOrder: false, includesRisk: true, includesAdapter: false, includesOMS: false, includesEventStream: false, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 4, kind: .adapterSubmit, stage: .binanceTestnetAdapter, includesLocalOrder: true, includesRisk: true, includesAdapter: true, includesOMS: false, includesEventStream: false, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 5, kind: .omsLocalOrder, stage: .omsLocalOrderStore, includesLocalOrder: true, includesRisk: true, includesAdapter: true, includesOMS: true, includesEventStream: false, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 6, kind: .orderEventLog, stage: .orderEventLog, includesLocalOrder: true, includesRisk: true, includesAdapter: true, includesOMS: true, includesEventStream: true, includesStateSync: false, includesReconciliation: false),
        EntryDefinition(sequence: 7, kind: .reconciliation, stage: .reconciliation, includesLocalOrder: true, includesRisk: true, includesAdapter: true, includesOMS: true, includesEventStream: true, includesStateSync: true, includesReconciliation: true)
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140ExecutionEventLog.builder.\(field)")
        }
    }
}
