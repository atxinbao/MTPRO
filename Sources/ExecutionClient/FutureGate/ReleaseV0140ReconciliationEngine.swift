import DomainModel
import Foundation

/// ReleaseV0140ReconciliationObservationKind 描述 GH-1036 reconciliation 允许消费的 testnet 执行观察类型。
///
/// 这些 case 只表示 redacted acknowledgement / fill summary evidence，不代表原始交易所 payload、
/// production broker event 或真实资金账户状态已经进入系统。
public enum ReleaseV0140ReconciliationObservationKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitAcknowledgement
    case partialFill
    case fullFill
    case cancelAcknowledgement
    case replaceAcknowledgement

    public var expectedLifecycleState: OrderLifecycleState {
        switch self {
        case .submitAcknowledgement:
            .accepted
        case .partialFill:
            .partiallyFilled
        case .fullFill:
            .filled
        case .cancelAcknowledgement:
            .cancelled
        case .replaceAcknowledgement:
            .replaced
        }
    }
}

/// ReleaseV0140ReconciliationStatus 是 GH-1036 reconciliation report 的最终状态。
public enum ReleaseV0140ReconciliationStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case passed
    case failed
}

/// ReleaseV0140ReconciliationFailureReason 枚举 GH-1036 必须显式暴露的 reconciliation mismatch。
public enum ReleaseV0140ReconciliationFailureReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case snapshotStreamMismatch
    case missingStateRecord
    case missingSourceEvent
    case identityMismatch
    case lifecycleStateMismatch
    case executionEvidenceMismatch
    case adapterEvidenceMismatch
    case observationCoverageMismatch
}

/// ReleaseV0140TestnetExecutionObservation 是 GH-1036 的 redacted testnet ack / fill evidence。
///
/// observation 必须绑定 order event、state sync record 和 execution / adapter evidence ID。
/// 它不保存原始 payload，不读取 credential，不连接 endpoint，也不升级为 production fill runtime。
public struct ReleaseV0140TestnetExecutionObservation: Codable, Equatable, Sendable {
    public let observationID: Identifier
    public let kind: ReleaseV0140ReconciliationObservationKind
    public let localOrderID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let orderIntentID: Identifier
    public let sourceEventID: Identifier
    public let targetLifecycleState: OrderLifecycleState
    public let executionEvidenceID: Identifier
    public let adapterEvidenceID: Identifier?
    public let acknowledgedByTestnet: Bool
    public let redactedExecutionSummary: Bool
    public let testnetEvidenceOnly: Bool
    public let rawExecutionPayloadIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        observationID: Identifier,
        kind: ReleaseV0140ReconciliationObservationKind,
        localOrderID: Identifier,
        productType: ProductType,
        symbol: Symbol,
        orderIntentID: Identifier,
        sourceEventID: Identifier,
        targetLifecycleState: OrderLifecycleState,
        executionEvidenceID: Identifier,
        adapterEvidenceID: Identifier?,
        acknowledgedByTestnet: Bool = true,
        redactedExecutionSummary: Bool = true,
        testnetEvidenceOnly: Bool = true,
        rawExecutionPayloadIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard targetLifecycleState == kind.expectedLifecycleState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.observation.lifecycleState",
                expected: kind.expectedLifecycleState.rawValue,
                actual: targetLifecycleState.rawValue
            )
        }
        guard acknowledgedByTestnet, redactedExecutionSummary, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.unheldObservation")
        }
        try Self.forbid(rawExecutionPayloadIncluded, "rawExecutionPayloadIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard observationID == Self.deterministicID(
            kind: kind,
            localOrderID: localOrderID,
            sourceEventID: sourceEventID,
            executionEvidenceID: executionEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.observationID",
                expected: Self.deterministicID(
                    kind: kind,
                    localOrderID: localOrderID,
                    sourceEventID: sourceEventID,
                    executionEvidenceID: executionEvidenceID
                ).rawValue,
                actual: observationID.rawValue
            )
        }

        self.observationID = observationID
        self.kind = kind
        self.localOrderID = localOrderID
        self.productType = productType
        self.symbol = symbol
        self.orderIntentID = orderIntentID
        self.sourceEventID = sourceEventID
        self.targetLifecycleState = targetLifecycleState
        self.executionEvidenceID = executionEvidenceID
        self.adapterEvidenceID = adapterEvidenceID
        self.acknowledgedByTestnet = acknowledgedByTestnet
        self.redactedExecutionSummary = redactedExecutionSummary
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawExecutionPayloadIncluded = rawExecutionPayloadIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        targetLifecycleState == kind.expectedLifecycleState
            && acknowledgedByTestnet
            && redactedExecutionSummary
            && testnetEvidenceOnly
            && rawExecutionPayloadIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        kind: ReleaseV0140ReconciliationObservationKind,
        localOrderID: Identifier,
        sourceEventID: Identifier,
        executionEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1036-reconciliation-observation:\(kind.rawValue):\(localOrderID.rawValue):\(sourceEventID.rawValue):\(executionEvidenceID.rawValue)",
            field: "releaseV0140Reconciliation.observationID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.observation.\(field)")
        }
    }
}

/// ReleaseV0140ReconciliationFailure 是 GH-1036 report 暴露的单条 mismatch。
///
/// failure 保留 expected / actual 文本和关联 evidence ID，确保 mismatch 被显式报告，
/// 而不是在 reconciliation 中被静默接受。
public struct ReleaseV0140ReconciliationFailure: Codable, Equatable, Sendable {
    public let failureID: Identifier
    public let reason: ReleaseV0140ReconciliationFailureReason
    public let localOrderID: Identifier?
    public let sourceEventID: Identifier?
    public let observationID: Identifier?
    public let expected: String
    public let actual: String
    public let failClosed: Bool

    public init(
        failureID: Identifier,
        reason: ReleaseV0140ReconciliationFailureReason,
        localOrderID: Identifier?,
        sourceEventID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String,
        failClosed: Bool = true
    ) throws {
        guard expected.isEmpty == false, actual.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.failureDetail",
                expected: "non-empty expected and actual values",
                actual: "empty mismatch detail"
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.nonFailClosedMismatch")
        }
        guard failureID == Self.deterministicID(
            reason: reason,
            localOrderID: localOrderID,
            sourceEventID: sourceEventID,
            observationID: observationID,
            expected: expected,
            actual: actual
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.failureID",
                expected: Self.deterministicID(
                    reason: reason,
                    localOrderID: localOrderID,
                    sourceEventID: sourceEventID,
                    observationID: observationID,
                    expected: expected,
                    actual: actual
                ).rawValue,
                actual: failureID.rawValue
            )
        }

        self.failureID = failureID
        self.reason = reason
        self.localOrderID = localOrderID
        self.sourceEventID = sourceEventID
        self.observationID = observationID
        self.expected = expected
        self.actual = actual
        self.failClosed = failClosed
    }

    public var boundaryHeld: Bool {
        expected.isEmpty == false
            && actual.isEmpty == false
            && failClosed
    }

    public static func deterministicID(
        reason: ReleaseV0140ReconciliationFailureReason,
        localOrderID: Identifier?,
        sourceEventID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String
    ) -> Identifier {
        .constant(
            "gh-1036-reconciliation-failure:\(reason.rawValue):\(localOrderID?.rawValue ?? "none"):\(sourceEventID?.rawValue ?? "none"):\(observationID?.rawValue ?? "none"):\(expected):\(actual)",
            field: "releaseV0140Reconciliation.failureID"
        )
    }
}

/// ReleaseV0140ReconciliationReport 是 GH-1036 reconciliation 的可审计输出。
///
/// passed report 必须没有 failures 且 observation coverage 完整；failed report 必须携带
/// fail-closed failures。report 保持 testnet / dry-run scoped，不执行任何 adapter action。
public struct ReleaseV0140ReconciliationReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let sourceSnapshotID: Identifier
    public let sourceStreamID: Identifier
    public let sourceEventIDs: [Identifier]
    public let observationIDs: [Identifier]
    public let status: ReleaseV0140ReconciliationStatus
    public let failures: [ReleaseV0140ReconciliationFailure]
    public let evidenceCoverageComplete: Bool
    public let mismatchesFailClosed: Bool
    public let testnetDryRunScoped: Bool
    public let rawExecutionPayloadIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        sourceSnapshotID: Identifier,
        sourceStreamID: Identifier,
        sourceEventIDs: [Identifier],
        observations: [ReleaseV0140TestnetExecutionObservation],
        status: ReleaseV0140ReconciliationStatus,
        failures: [ReleaseV0140ReconciliationFailure],
        evidenceCoverageComplete: Bool,
        mismatchesFailClosed: Bool = true,
        testnetDryRunScoped: Bool = true,
        rawExecutionPayloadIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceEventIDs.isEmpty == false, observations.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.reportSource",
                expected: "non-empty source events and observations",
                actual: "empty reconciliation source"
            )
        }
        guard observations.allSatisfy(\.boundaryHeld), failures.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.unheldReportInputs")
        }
        switch status {
        case .passed:
            guard failures.isEmpty, evidenceCoverageComplete else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140Reconciliation.passedReport",
                    expected: "no failures and complete evidence coverage",
                    actual: "failures or incomplete coverage present"
                )
            }
        case .failed:
            guard failures.isEmpty == false, evidenceCoverageComplete == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140Reconciliation.failedReport",
                    expected: "failures and incomplete coverage",
                    actual: "missing failure evidence"
                )
            }
        }
        guard Set(observations.map { $0.observationID.rawValue }).count == observations.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.observations",
                expected: "unique observation IDs",
                actual: "duplicate observation ID"
            )
        }
        guard mismatchesFailClosed, testnetDryRunScoped else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.nonFailClosedOrNonTestnetReport")
        }
        try Self.forbid(rawExecutionPayloadIncluded, "rawExecutionPayloadIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.reportID = Self.deterministicID(
            sourceSnapshotID: sourceSnapshotID,
            observationIDs: observations.map(\.observationID),
            failureIDs: failures.map(\.failureID)
        )
        self.sourceSnapshotID = sourceSnapshotID
        self.sourceStreamID = sourceStreamID
        self.sourceEventIDs = sourceEventIDs
        self.observationIDs = observations.map(\.observationID)
        self.status = status
        self.failures = failures
        self.evidenceCoverageComplete = evidenceCoverageComplete
        self.mismatchesFailClosed = mismatchesFailClosed
        self.testnetDryRunScoped = testnetDryRunScoped
        self.rawExecutionPayloadIncluded = rawExecutionPayloadIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        sourceEventIDs.isEmpty == false
            && observationIDs.isEmpty == false
            && (status == .passed ? failures.isEmpty && evidenceCoverageComplete : failures.isEmpty == false && evidenceCoverageComplete == false)
            && failures.allSatisfy(\.boundaryHeld)
            && mismatchesFailClosed
            && testnetDryRunScoped
            && rawExecutionPayloadIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1036-RECONCILIATION-ENGINE",
        "GH-1036-MISMATCH-FAILURE-SURFACE",
        "GH-1036-TESTNET-DRYRUN-SCOPED",
        "TVM-RELEASE-V0140-RECONCILIATION-ENGINE"
    ]

    public static func deterministicID(
        sourceSnapshotID: Identifier,
        observationIDs: [Identifier],
        failureIDs: [Identifier]
    ) -> Identifier {
        let lastObservation = observationIDs.last?.rawValue ?? "none"
        let lastFailure = failureIDs.last?.rawValue ?? "none"
        return .constant(
            "gh-1036-reconciliation-report:\(sourceSnapshotID.rawValue):\(observationIDs.count):\(lastObservation):\(failureIDs.count):\(lastFailure)",
            field: "releaseV0140Reconciliation.reportID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.report.\(field)")
        }
    }
}

/// ReleaseV0140ReconciliationEngine 对齐本地 OMS state、event log 和 testnet ack / fill evidence。
///
/// engine 是无状态校验器：它不缓存 runtime state、不创建 request、不读取 credential、不连接
/// endpoint。所有 mismatch 都进入 failed report，作为后续 Dashboard 只读面可以展示的 evidence。
public struct ReleaseV0140ReconciliationEngine: Codable, Equatable, Sendable {
    public let engineID: Identifier
    public let mismatchesFailClosed: Bool
    public let testnetDryRunScoped: Bool
    public let rawExecutionPayloadIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        engineID: Identifier = Identifier.constant("gh-1036-reconciliation-engine"),
        mismatchesFailClosed: Bool = true,
        testnetDryRunScoped: Bool = true,
        rawExecutionPayloadIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0140ReconciliationReport.requiredValidationAnchors
    ) throws {
        guard mismatchesFailClosed, testnetDryRunScoped else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.engineBoundary")
        }
        try Self.forbid(rawExecutionPayloadIncluded, "rawExecutionPayloadIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0140ReconciliationReport.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140Reconciliation.engine.validationAnchors",
                expected: ReleaseV0140ReconciliationReport.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.engineID = engineID
        self.mismatchesFailClosed = mismatchesFailClosed
        self.testnetDryRunScoped = testnetDryRunScoped
        self.rawExecutionPayloadIncluded = rawExecutionPayloadIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        mismatchesFailClosed
            && testnetDryRunScoped
            && rawExecutionPayloadIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0140ReconciliationReport.requiredValidationAnchors
    }

    public func reconcile(
        snapshot: ReleaseV0140OMSStateSyncSnapshot,
        stream: ReleaseV0140OrderEventSourcingStream,
        observations: [ReleaseV0140TestnetExecutionObservation]
    ) throws -> ReleaseV0140ReconciliationReport {
        guard boundaryHeld, snapshot.boundaryHeld, stream.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.unheldSource")
        }
        guard observations.isEmpty == false, observations.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.unheldObservations")
        }

        var failures: [ReleaseV0140ReconciliationFailure] = []
        if snapshot.sourceStreamID != stream.streamID || snapshot.sourceEventIDs != stream.events.map(\.eventID) {
            failures.append(try failure(
                reason: .snapshotStreamMismatch,
                localOrderID: nil,
                sourceEventID: nil,
                observationID: nil,
                expected: snapshot.sourceEventIDs.map(\.rawValue).joined(separator: ","),
                actual: stream.events.map { $0.eventID.rawValue }.joined(separator: ",")
            ))
        }

        for observation in observations {
            let record = snapshot.record(for: observation.localOrderID)
            let event = stream.events.first { $0.eventID == observation.sourceEventID }

            guard let record else {
                failures.append(try failure(
                    reason: .missingStateRecord,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: "state sync record for local order",
                    actual: "missing"
                ))
                continue
            }
            guard let event else {
                failures.append(try failure(
                    reason: .missingSourceEvent,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: "order event in source stream",
                    actual: "missing"
                ))
                continue
            }

            if record.eventIDs.contains(observation.sourceEventID) == false {
                failures.append(try failure(
                    reason: .observationCoverageMismatch,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: "source event covered by state sync record",
                    actual: "not covered"
                ))
            }
            if event.localOrderID != observation.localOrderID
                || event.productType != observation.productType
                || event.symbol != observation.symbol
                || event.orderIntentID != observation.orderIntentID {
                failures.append(try failure(
                    reason: .identityMismatch,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: "\(event.localOrderID.rawValue):\(event.productType.rawValue):\(event.symbol.rawValue):\(event.orderIntentID.rawValue)",
                    actual: "\(observation.localOrderID.rawValue):\(observation.productType.rawValue):\(observation.symbol.rawValue):\(observation.orderIntentID.rawValue)"
                ))
            }
            if event.toState != observation.targetLifecycleState {
                failures.append(try failure(
                    reason: .lifecycleStateMismatch,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: event.toState.rawValue,
                    actual: observation.targetLifecycleState.rawValue
                ))
            }
            if event.executionEvidenceID != observation.executionEvidenceID {
                failures.append(try failure(
                    reason: .executionEvidenceMismatch,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: event.executionEvidenceID?.rawValue ?? "missing",
                    actual: observation.executionEvidenceID.rawValue
                ))
            }
            if event.adapterEvidenceID != observation.adapterEvidenceID {
                failures.append(try failure(
                    reason: .adapterEvidenceMismatch,
                    localOrderID: observation.localOrderID,
                    sourceEventID: observation.sourceEventID,
                    observationID: observation.observationID,
                    expected: event.adapterEvidenceID?.rawValue ?? "none",
                    actual: observation.adapterEvidenceID?.rawValue ?? "none"
                ))
            }
        }

        let expectedObservationEventIDs = Set(
            stream.events
                .filter { Self.requiresObservation($0.toState) }
                .map(\.eventID)
        )
        let observedEventIDs = Set(observations.map(\.sourceEventID))
        if observedEventIDs != expectedObservationEventIDs {
            failures.append(try failure(
                reason: .observationCoverageMismatch,
                localOrderID: nil,
                sourceEventID: nil,
                observationID: nil,
                expected: expectedObservationEventIDs.map(\.rawValue).sorted().joined(separator: ","),
                actual: observedEventIDs.map(\.rawValue).sorted().joined(separator: ",")
            ))
        }

        let status: ReleaseV0140ReconciliationStatus = failures.isEmpty ? .passed : .failed
        return try ReleaseV0140ReconciliationReport(
            sourceSnapshotID: snapshot.snapshotID,
            sourceStreamID: stream.streamID,
            sourceEventIDs: stream.events.map(\.eventID),
            observations: observations,
            status: status,
            failures: failures,
            evidenceCoverageComplete: failures.isEmpty,
            mismatchesFailClosed: mismatchesFailClosed,
            testnetDryRunScoped: testnetDryRunScoped,
            validationAnchors: validationAnchors
        )
    }

    public static func requiresObservation(_ state: OrderLifecycleState) -> Bool {
        switch state {
        case .accepted, .partiallyFilled, .filled, .cancelled, .replaced:
            true
        case .created, .riskAccepted, .riskRejected, .submittedTestnet, .submittedDryRun,
             .cancelRequested, .replaceRequested, .rejected, .expired, .failedClosed:
            false
        }
    }

    private func failure(
        reason: ReleaseV0140ReconciliationFailureReason,
        localOrderID: Identifier?,
        sourceEventID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String
    ) throws -> ReleaseV0140ReconciliationFailure {
        try ReleaseV0140ReconciliationFailure(
            failureID: ReleaseV0140ReconciliationFailure.deterministicID(
                reason: reason,
                localOrderID: localOrderID,
                sourceEventID: sourceEventID,
                observationID: observationID,
                expected: expected,
                actual: actual
            ),
            reason: reason,
            localOrderID: localOrderID,
            sourceEventID: sourceEventID,
            observationID: observationID,
            expected: expected,
            actual: actual
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140Reconciliation.engine.\(field)")
        }
    }
}
