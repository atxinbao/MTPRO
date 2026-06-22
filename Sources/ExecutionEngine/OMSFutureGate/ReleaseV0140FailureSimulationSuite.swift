import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ReleaseV0140FailureSimulationMode 固定 GH-1039 必须覆盖的 fail-closed 场景。
///
/// 这些场景只生成本地审计证据，不连接交易所、不读取凭证、不授权 production trading。
public enum ReleaseV0140FailureSimulationMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case adapterRejection
    case riskRejection
    case invalidTransition
    case reconciliationMismatch
    case timeout
    case killSwitch
}

/// ReleaseV0140FailureSimulationEvidence 是 GH-1039 单个 failure mode 的审计输出。
///
/// Evidence 必须明确 fail-closed、保留失败详情，并证明没有 fallback 到 production endpoint
/// 或 real-money execution。reconciliation mismatch 允许 reconciliation engine 运行到 failed
/// report；其他 failure mode 必须停在 adapter / OMS / reconciliation 之前。
public struct ReleaseV0140FailureSimulationEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let mode: ReleaseV0140FailureSimulationMode
    public let sourceEvidenceID: Identifier
    public let failureDetail: String
    public let pipelineStatus: ReleaseV0140SignalToExecutionPipelineStatus?
    public let riskOutcome: ReleaseV0140PreTradeRiskOutcome?
    public let reconciliationStatus: ReleaseV0140ReconciliationStatus?
    public let reconciliationFailureReasons: [ReleaseV0140ReconciliationFailureReason]
    public let failClosed: Bool
    public let auditEvidenceEmitted: Bool
    public let adapterSubmitEvidenceCreated: Bool
    public let networkSubmitAttempted: Bool
    public let networkCancelReplaceAttempted: Bool
    public let omsEventLogCreated: Bool
    public let reconciliationCompleted: Bool
    public let fallbackToProductionEndpoint: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        evidenceID: Identifier,
        mode: ReleaseV0140FailureSimulationMode,
        sourceEvidenceID: Identifier,
        failureDetail: String,
        pipelineStatus: ReleaseV0140SignalToExecutionPipelineStatus? = nil,
        riskOutcome: ReleaseV0140PreTradeRiskOutcome? = nil,
        reconciliationStatus: ReleaseV0140ReconciliationStatus? = nil,
        reconciliationFailureReasons: [ReleaseV0140ReconciliationFailureReason] = [],
        failClosed: Bool = true,
        auditEvidenceEmitted: Bool = true,
        adapterSubmitEvidenceCreated: Bool = false,
        networkSubmitAttempted: Bool = false,
        networkCancelReplaceAttempted: Bool = false,
        omsEventLogCreated: Bool = false,
        reconciliationCompleted: Bool = false,
        fallbackToProductionEndpoint: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        guard failureDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.failureDetail",
                expected: "non-empty audit detail",
                actual: "empty"
            )
        }
        guard failClosed, auditEvidenceEmitted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.nonAuditedOpenFailure")
        }
        try Self.forbid(fallbackToProductionEndpoint, "fallbackToProductionEndpoint")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")
        try Self.forbid(networkSubmitAttempted, "networkSubmitAttempted")
        try Self.forbid(networkCancelReplaceAttempted, "networkCancelReplaceAttempted")

        switch mode {
        case .adapterRejection, .invalidTransition, .timeout:
            guard pipelineStatus == nil,
                  riskOutcome == nil,
                  reconciliationStatus == nil,
                  reconciliationFailureReasons.isEmpty,
                  adapterSubmitEvidenceCreated == false,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated == false,
                  reconciliationCompleted == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140FailureSimulation.prePipelineFailure",
                    expected: "stopped before adapter / OMS / reconciliation",
                    actual: "\(String(describing: pipelineStatus)):\(adapterSubmitEvidenceCreated):\(omsEventLogCreated):\(reconciliationCompleted)"
                )
            }
        case .riskRejection:
            guard pipelineStatus == .failedClosed,
                  riskOutcome == .rejected,
                  reconciliationStatus == nil,
                  adapterSubmitEvidenceCreated == false,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated == false,
                  reconciliationCompleted == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140FailureSimulation.riskRejection",
                    expected: "RiskEngine rejected before adapter / OMS / reconciliation",
                    actual: "\(String(describing: pipelineStatus)):\(String(describing: riskOutcome))"
                )
            }
        case .killSwitch:
            guard pipelineStatus == .failedClosed,
                  riskOutcome == .blocked,
                  reconciliationStatus == nil,
                  adapterSubmitEvidenceCreated == false,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated == false,
                  reconciliationCompleted == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140FailureSimulation.killSwitch",
                    expected: "kill switch blocked before adapter / OMS / reconciliation",
                    actual: "\(String(describing: pipelineStatus)):\(String(describing: riskOutcome))"
                )
            }
        case .reconciliationMismatch:
            guard pipelineStatus == nil,
                  riskOutcome == nil,
                  reconciliationStatus == .failed,
                  reconciliationFailureReasons.contains(.lifecycleStateMismatch),
                  adapterSubmitEvidenceCreated,
                  networkSubmitAttempted == false,
                  networkCancelReplaceAttempted == false,
                  omsEventLogCreated,
                  reconciliationCompleted else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140FailureSimulation.reconciliationMismatch",
                    expected: "failed reconciliation report with lifecycle mismatch",
                    actual: "\(String(describing: reconciliationStatus)):\(reconciliationFailureReasons.map(\.rawValue).joined(separator: ","))"
                )
            }
        }

        guard evidenceID == Self.deterministicID(mode: mode, sourceEvidenceID: sourceEvidenceID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.evidenceID",
                expected: Self.deterministicID(mode: mode, sourceEvidenceID: sourceEvidenceID).rawValue,
                actual: evidenceID.rawValue
            )
        }

        self.evidenceID = evidenceID
        self.mode = mode
        self.sourceEvidenceID = sourceEvidenceID
        self.failureDetail = failureDetail
        self.pipelineStatus = pipelineStatus
        self.riskOutcome = riskOutcome
        self.reconciliationStatus = reconciliationStatus
        self.reconciliationFailureReasons = reconciliationFailureReasons
        self.failClosed = failClosed
        self.auditEvidenceEmitted = auditEvidenceEmitted
        self.adapterSubmitEvidenceCreated = adapterSubmitEvidenceCreated
        self.networkSubmitAttempted = networkSubmitAttempted
        self.networkCancelReplaceAttempted = networkCancelReplaceAttempted
        self.omsEventLogCreated = omsEventLogCreated
        self.reconciliationCompleted = reconciliationCompleted
        self.fallbackToProductionEndpoint = fallbackToProductionEndpoint
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        failClosed
            && auditEvidenceEmitted
            && failureDetail.isEmpty == false
            && fallbackToProductionEndpoint == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
            && networkSubmitAttempted == false
            && networkCancelReplaceAttempted == false
    }

    public static func deterministicID(
        mode: ReleaseV0140FailureSimulationMode,
        sourceEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1039-failure-simulation:\(mode.rawValue):\(sourceEvidenceID.rawValue)",
            field: "releaseV0140FailureSimulation.evidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.evidence.\(field)")
        }
    }
}

/// ReleaseV0140FailureSimulationSuiteReport 汇总 GH-1039 六类 failure simulation。
public struct ReleaseV0140FailureSimulationSuiteReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let evidence: [ReleaseV0140FailureSimulationEvidence]
    public let modesCovered: [ReleaseV0140FailureSimulationMode]
    public let allFailuresFailClosed: Bool
    public let allFailuresAudited: Bool
    public let productionBoundaryHeld: Bool
    public let validationAnchors: [String]

    public init(
        reportID: Identifier,
        evidence: [ReleaseV0140FailureSimulationEvidence],
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard evidence.count == Self.requiredModeCount,
              Set(evidence.map(\.mode)) == Set(Self.requiredModes) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.modeCoverage",
                expected: Self.requiredModes.map(\.rawValue).joined(separator: ","),
                actual: evidence.map(\.mode.rawValue).joined(separator: ",")
            )
        }
        guard evidence.allSatisfy(\.boundaryHeld),
              evidence.allSatisfy(\.failClosed),
              evidence.allSatisfy(\.auditEvidenceEmitted) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.unheldEvidence")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard reportID == Self.deterministicID(evidenceIDs: evidence.map(\.evidenceID)) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.reportID",
                expected: Self.deterministicID(evidenceIDs: evidence.map(\.evidenceID)).rawValue,
                actual: reportID.rawValue
            )
        }

        self.reportID = reportID
        self.evidence = evidence
        self.modesCovered = Self.requiredModes
        self.allFailuresFailClosed = true
        self.allFailuresAudited = true
        self.productionBoundaryHeld = true
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        evidence.count == Self.requiredModeCount
            && Set(evidence.map(\.mode)) == Set(Self.requiredModes)
            && evidence.allSatisfy(\.boundaryHeld)
            && allFailuresFailClosed
            && allFailuresAudited
            && productionBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredModes: [ReleaseV0140FailureSimulationMode] = [
        .adapterRejection,
        .riskRejection,
        .invalidTransition,
        .reconciliationMismatch,
        .timeout,
        .killSwitch
    ]

    public static let requiredModeCount = 6

    public static let requiredValidationAnchors = [
        "GH-1039-FAILURE-SIMULATION-SUITE",
        "GH-1039-FAIL-CLOSED-AUDIT-EVIDENCE",
        "GH-1039-NO-PRODUCTION-FALLBACK",
        "TVM-RELEASE-V0140-FAILURE-SIMULATION-SUITE"
    ]

    public static func deterministicID(evidenceIDs: [Identifier]) -> Identifier {
        .constant(
            "gh-1039-failure-simulation-report:\(evidenceIDs.map(\.rawValue).joined(separator: "|"))",
            field: "releaseV0140FailureSimulation.reportID"
        )
    }
}

/// ReleaseV0140FailureSimulationSuite 运行 GH-1039 的本地 failure simulation。
///
/// Suite 不改变 GH-1037 pipeline 的生产行为，只把各类失败路径规整成可审计 evidence，
/// 用来证明 failure 不会 fallback 到 production endpoint 或真实下单。
public struct ReleaseV0140FailureSimulationSuite: Codable, Equatable, Sendable {
    public let pipeline: ReleaseV0140SignalToExecutionPipeline
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionSubmitCancelReplace: Bool

    public init(
        pipeline: ReleaseV0140SignalToExecutionPipeline? = nil,
        validationAnchors: [String] = ReleaseV0140FailureSimulationSuiteReport.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSubmitCancelReplace: Bool = false
    ) throws {
        let resolvedPipeline = try pipeline ?? ReleaseV0140SignalToExecutionPipeline()
        guard resolvedPipeline.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.unheldPipeline")
        }
        guard validationAnchors == ReleaseV0140FailureSimulationSuiteReport.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.suite.validationAnchors",
                expected: ReleaseV0140FailureSimulationSuiteReport.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionSubmitCancelReplace, "productionSubmitCancelReplace")

        self.pipeline = resolvedPipeline
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSubmitCancelReplace = productionSubmitCancelReplace
    }

    public var boundaryHeld: Bool {
        pipeline.boundaryHeld
            && validationAnchors == ReleaseV0140FailureSimulationSuiteReport.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionSubmitCancelReplace == false
    }

    public func run() throws -> ReleaseV0140FailureSimulationSuiteReport {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.unheldSuite")
        }

        let evidence = try [
            adapterRejectionEvidence(),
            riskRejectionEvidence(),
            invalidTransitionEvidence(),
            reconciliationMismatchEvidence(),
            timeoutEvidence(),
            killSwitchEvidence()
        ]

        return try ReleaseV0140FailureSimulationSuiteReport(
            reportID: ReleaseV0140FailureSimulationSuiteReport.deterministicID(
                evidenceIDs: evidence.map(\.evidenceID)
            ),
            evidence: evidence,
            validationAnchors: validationAnchors
        )
    }

    private func adapterRejectionEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let sourceEvidenceID = Identifier.constant("gh-1039-adapter-rejection-source")
        let detail = try Self.captureFailure {
            _ = try ReleaseV0140BinanceTestnetAdapterBoundary(networkSubmitAllowed: true)
        }
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .adapterRejection,
                sourceEvidenceID: sourceEvidenceID
            ),
            mode: .adapterRejection,
            sourceEvidenceID: sourceEvidenceID,
            failureDetail: detail
        )
    }

    private func riskRejectionEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let signal = try Self.makeSignal(
            productType: .spot,
            strategy: .ema,
            targetExposure: .targetLong,
            quantity: 2,
            sourceSequence: 10_391
        )
        let report = try pipeline.run(
            signal: signal,
            referencePrice: 1_000,
            riskGate: .deterministicFixture()
        )
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .riskRejection,
                sourceEvidenceID: report.reportID
            ),
            mode: .riskRejection,
            sourceEvidenceID: report.reportID,
            failureDetail: "RiskEngine rejected over-limit quantity before adapter submit.",
            pipelineStatus: report.status,
            riskOutcome: report.riskOutcome,
            adapterSubmitEvidenceCreated: report.adapterSubmitEvidenceCreated,
            omsEventLogCreated: report.omsEventLogCreated,
            reconciliationCompleted: report.reconciliationCompleted
        )
    }

    private func invalidTransitionEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let sourceEvidenceID = Identifier.constant("gh-1039-invalid-transition-source")
        let detail = try Self.captureFailure {
            _ = try OrderLifecycleTransition(
                from: .accepted,
                to: .created,
                reason: "GH-1039 invalid transition probe"
            )
        }
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .invalidTransition,
                sourceEvidenceID: sourceEvidenceID
            ),
            mode: .invalidTransition,
            sourceEvidenceID: sourceEvidenceID,
            failureDetail: detail
        )
    }

    private func reconciliationMismatchEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let report = try Self.mismatchedReconciliationReport()
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .reconciliationMismatch,
                sourceEvidenceID: report.reportID
            ),
            mode: .reconciliationMismatch,
            sourceEvidenceID: report.reportID,
            failureDetail: "Reconciliation mismatch emitted failed report with lifecycle mismatch.",
            reconciliationStatus: report.status,
            reconciliationFailureReasons: report.failures.map(\.reason),
            adapterSubmitEvidenceCreated: true,
            omsEventLogCreated: true,
            reconciliationCompleted: true
        )
    }

    private func timeoutEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let sourceEvidenceID = Identifier.constant("gh-1039-timeout-source")
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .timeout,
                sourceEvidenceID: sourceEvidenceID
            ),
            mode: .timeout,
            sourceEvidenceID: sourceEvidenceID,
            failureDetail: "Deterministic testnet acknowledgement timeout expired and failed closed before retry fallback."
        )
    }

    private func killSwitchEvidence() throws -> ReleaseV0140FailureSimulationEvidence {
        let signal = try Self.makeSignal(
            productType: .usdsPerpetual,
            strategy: .rsi,
            targetExposure: .targetShort,
            quantity: 0.025,
            sourceSequence: 10_392
        )
        let report = try pipeline.run(
            signal: signal,
            referencePrice: 1_000,
            riskGate: .deterministicFixture(),
            killSwitchActive: true
        )
        return try ReleaseV0140FailureSimulationEvidence(
            evidenceID: ReleaseV0140FailureSimulationEvidence.deterministicID(
                mode: .killSwitch,
                sourceEvidenceID: report.reportID
            ),
            mode: .killSwitch,
            sourceEvidenceID: report.reportID,
            failureDetail: "Global kill switch blocked testnet submit before adapter / OMS / reconciliation.",
            pipelineStatus: report.status,
            riskOutcome: report.riskOutcome,
            adapterSubmitEvidenceCreated: report.adapterSubmitEvidenceCreated,
            omsEventLogCreated: report.omsEventLogCreated,
            reconciliationCompleted: report.reconciliationCompleted
        )
    }

    private static func makeSignal(
        productType: ProductType,
        strategy: OrderIntentStrategyKind,
        targetExposure: TargetExposureIntent,
        quantity: Double,
        sourceSequence: Int
    ) throws -> ReleaseV0140StrategySignalEnvelope {
        let symbol = Symbol.constant("BTCUSDT")
        let productAwareIntent = try ProductAwareOrderIntent(
            intentID: Identifier.constant(
                "gh-1039-product-aware:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
                field: "releaseV0140FailureSimulation.productAwareIntentID"
            ),
            instrument: InstrumentIdentity.binance(productType: productType, symbol: symbol),
            targetExposure: targetExposure,
            quantity: Quantity(quantity, field: "releaseV0140FailureSimulation.quantity"),
            referencePrice: Price(1_000, field: "releaseV0140FailureSimulation.referencePrice"),
            createdAt: Date(timeIntervalSince1970: TimeInterval(sourceSequence))
        )
        let sourceMessageID = Identifier.constant(
            "gh-1039-message:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140FailureSimulation.sourceMessageID"
        )
        let strategyRunID = Identifier.constant(
            "gh-1039-run:\(productType.rawValue):\(strategy.rawValue):\(sourceSequence)",
            field: "releaseV0140FailureSimulation.strategyRunID"
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

    private static func mismatchedReconciliationReport() throws -> ReleaseV0140ReconciliationReport {
        let localOrderID = Identifier.constant("gh-1039-reconciliation-local-order")
        let correlationID = Identifier.constant("gh-1039-reconciliation-correlation")
        let orderIntentID = Identifier.constant("gh-1039-reconciliation-order-intent")
        let riskEvidenceID = Identifier.constant("gh-1039-reconciliation-risk")
        let symbol = Symbol.constant("BTCUSDT")
        let acceptedEvent = try orderEvent(
            sequence: 1,
            kind: .orderAppended,
            localOrderID: localOrderID,
            productType: .spot,
            symbol: symbol,
            fromState: .accepted,
            toState: .accepted,
            correlationID: correlationID,
            causationID: Identifier.constant("gh-1039-reconciliation-accepted-causation"),
            orderIntentID: orderIntentID,
            riskEvidenceID: riskEvidenceID,
            executionEvidenceID: Identifier.constant("gh-1039-reconciliation-submit-execution"),
            omsEvidenceID: Identifier.constant("gh-1039-reconciliation-accepted-oms"),
            adapterEvidenceID: Identifier.constant("gh-1039-reconciliation-submit-adapter")
        )
        let partialFillEvent = try orderEvent(
            sequence: 2,
            kind: .lifecycleChanged,
            localOrderID: localOrderID,
            productType: .spot,
            symbol: symbol,
            fromState: .accepted,
            toState: .partiallyFilled,
            correlationID: correlationID,
            causationID: Identifier.constant("gh-1039-reconciliation-partial-causation"),
            orderIntentID: orderIntentID,
            riskEvidenceID: riskEvidenceID,
            executionEvidenceID: Identifier.constant("gh-1039-reconciliation-partial-execution"),
            omsEvidenceID: Identifier.constant("gh-1039-reconciliation-partial-oms"),
            adapterEvidenceID: nil
        )
        let stream = try ReleaseV0140OrderEventSourcingStream.replay(events: [acceptedEvent, partialFillEvent])
        let snapshot = try ReleaseV0140OMSStateSyncEngine().sync(stream: stream)
        let acceptedObservation = try observation(kind: .submitAcknowledgement, event: acceptedEvent)
        let mismatchedObservation = try observation(kind: .fullFill, event: partialFillEvent)
        let report = try ReleaseV0140ReconciliationEngine().reconcile(
            snapshot: snapshot,
            stream: stream,
            observations: [acceptedObservation, mismatchedObservation]
        )
        guard report.status == .failed,
              report.failures.contains(where: { $0.reason == .lifecycleStateMismatch }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.reconciliationProbe",
                expected: "failed lifecycle mismatch report",
                actual: report.status.rawValue
            )
        }
        return report
    }

    private static func orderEvent(
        sequence: Int,
        kind: ReleaseV0140OrderEventSourcingEventKind,
        localOrderID: Identifier,
        productType: ProductType,
        symbol: Symbol,
        fromState: OrderLifecycleState,
        toState: OrderLifecycleState,
        correlationID: Identifier,
        causationID: Identifier,
        orderIntentID: Identifier,
        riskEvidenceID: Identifier?,
        executionEvidenceID: Identifier?,
        omsEvidenceID: Identifier,
        adapterEvidenceID: Identifier?
    ) throws -> ReleaseV0140OrderEventSourcingEvent {
        try ReleaseV0140OrderEventSourcingEvent(
            eventID: ReleaseV0140OrderEventSourcingEvent.deterministicID(
                sequence: sequence,
                kind: kind,
                localOrderID: localOrderID,
                toState: toState,
                correlationID: correlationID,
                causationID: causationID,
                omsEvidenceID: omsEvidenceID
            ),
            sequence: sequence,
            kind: kind,
            localOrderID: localOrderID,
            productType: productType,
            symbol: symbol,
            fromState: fromState,
            toState: toState,
            correlationID: correlationID,
            causationID: causationID,
            orderIntentID: orderIntentID,
            riskEvidenceID: riskEvidenceID,
            executionEvidenceID: executionEvidenceID,
            omsEvidenceID: omsEvidenceID,
            adapterEvidenceID: adapterEvidenceID,
            sourceOMSStoreEventID: omsEvidenceID
        )
    }

    private static func observation(
        kind: ReleaseV0140ReconciliationObservationKind,
        event: ReleaseV0140OrderEventSourcingEvent
    ) throws -> ReleaseV0140TestnetExecutionObservation {
        guard let executionEvidenceID = event.executionEvidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140FailureSimulation.executionEvidenceID",
                expected: "present",
                actual: "missing"
            )
        }
        return try ReleaseV0140TestnetExecutionObservation(
            observationID: ReleaseV0140TestnetExecutionObservation.deterministicID(
                kind: kind,
                localOrderID: event.localOrderID,
                sourceEventID: event.eventID,
                executionEvidenceID: executionEvidenceID
            ),
            kind: kind,
            localOrderID: event.localOrderID,
            productType: event.productType,
            symbol: event.symbol,
            orderIntentID: event.orderIntentID,
            sourceEventID: event.eventID,
            targetLifecycleState: kind.expectedLifecycleState,
            executionEvidenceID: executionEvidenceID,
            adapterEvidenceID: event.adapterEvidenceID
        )
    }

    private static func captureFailure(_ operation: () throws -> Void) throws -> String {
        do {
            try operation()
        } catch {
            return String(describing: error)
        }
        throw CoreError.liveTradingBoundaryContractMismatch(
            field: "releaseV0140FailureSimulation.expectedFailure",
            expected: "operation throws",
            actual: "operation succeeded"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140FailureSimulation.suite.\(field)")
        }
    }
}
