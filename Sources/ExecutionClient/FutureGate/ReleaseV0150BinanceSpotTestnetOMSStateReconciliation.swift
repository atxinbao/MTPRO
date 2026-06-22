import DomainModel
import Foundation

// GH-1072 static contract boundary:
// derivedFromNetworkEventLogOnly=true
// appendOnlyNetworkExecutionEventLog=true
// expectedObservedReconciliation=true
// mismatchesFailClosed=true
// submitCancelCancelReplaceCoverage=true
// rawBrokerPayloadIncluded=false
// brokerFillIncluded=false
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind 描述 v0.15.0 OMS reconciliation
/// 可消费的脱敏 Spot Testnet network action observation。
///
/// Observation 只来自 append-only network event artifact；它不是 broker fill、不是 production account
/// 状态，也不会触发新的 submit / cancel / replace 请求。
public enum ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submitAcknowledgement
    case cancelAcknowledgement
    case cancelReplaceAcknowledgement

    public var expectedActionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind {
        switch self {
        case .submitAcknowledgement:
            .submit
        case .cancelAcknowledgement:
            .cancel
        case .cancelReplaceAcknowledgement:
            .cancelReplace
        }
    }

    public var expectedLifecycleStates: Set<OrderLifecycleState> {
        switch self {
        case .submitAcknowledgement:
            [.submittedTestnet, .accepted]
        case .cancelAcknowledgement:
            [.cancelRequested, .cancelled]
        case .cancelReplaceAcknowledgement:
            [.replaceRequested, .replaced]
        }
    }

    public static func from(
        actionKind: ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind
    ) -> ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind {
        switch actionKind {
        case .submit:
            .submitAcknowledgement
        case .cancel:
            .cancelAcknowledgement
        case .cancelReplace:
            .cancelReplaceAcknowledgement
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSReconciliationStatus 是 #1072 reconciliation report 的结果。
public enum ReleaseV0150BinanceSpotTestnetOMSReconciliationStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case passed
    case failed
}

/// ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason 枚举 #1072 必须显式暴露的差异。
public enum ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case snapshotLogMismatch
    case missingStateRecord
    case missingSourceArtifact
    case identityMismatch
    case actionKindMismatch
    case lifecycleStateMismatch
    case actionEvidenceMismatch
    case transportEvidenceMismatch
    case observationCoverageMismatch
}

/// ReleaseV0150BinanceSpotTestnetOMSStateRecord 是从 v0.15.0 network event log 推导出的本地 OMS 状态。
///
/// Record 以 intentID 聚合 append-only event artifact，并保留 request / response identity 和 checksum
/// evidence 链路。它不保存原始 broker payload，不表达 broker fill，也不授权 production order。
public struct ReleaseV0150BinanceSpotTestnetOMSStateRecord: Codable, Equatable, Sendable {
    public let stateRecordID: Identifier
    public let intentID: Identifier
    public let currentState: OrderLifecycleState
    public let actionKinds: [ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind]
    public let sourceEventArtifactIDs: [Identifier]
    public let actionEvidenceIDs: [Identifier]
    public let signedRequestIDs: [Identifier]
    public let transportResultIDs: [Identifier]
    public let credentialReferenceIDs: [Identifier]
    public let lastEventArtifactID: Identifier
    public let lastSequenceNumber: Int
    public let lastArtifactChecksum: String
    public let eventCount: Int
    public let derivedFromNetworkEventLogOnly: Bool
    public let appendOnlyNetworkExecutionEventLog: Bool
    public let redactedRequestResponseIdentity: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        eventArtifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact],
        derivedFromNetworkEventLogOnly: Bool = true,
        appendOnlyNetworkExecutionEventLog: Bool = true,
        redactedRequestResponseIdentity: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard eventArtifacts.isEmpty == false,
              eventArtifacts.allSatisfy(\.boundaryHeld),
              Set(eventArtifacts.map(\.intentID)).count == 1,
              let lastEvent = eventArtifacts.last else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.invalidStateRecordSource")
        }
        guard derivedFromNetworkEventLogOnly,
              appendOnlyNetworkExecutionEventLog,
              redactedRequestResponseIdentity else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldStateRecord")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        let orderedArtifacts = eventArtifacts.sorted { $0.sequenceNumber < $1.sequenceNumber }
        let eventIDs = orderedArtifacts.map(\.eventArtifactID)
        self.stateRecordID = Self.deterministicID(
            intentID: lastEvent.intentID,
            currentState: lastEvent.orderLifecycleState,
            lastEventArtifactID: lastEvent.eventArtifactID
        )
        self.intentID = lastEvent.intentID
        self.currentState = lastEvent.orderLifecycleState
        self.actionKinds = orderedArtifacts.map(\.actionKind)
        self.sourceEventArtifactIDs = eventIDs
        self.actionEvidenceIDs = orderedArtifacts.map(\.actionEvidenceID)
        self.signedRequestIDs = orderedArtifacts.map(\.signedRequestID)
        self.transportResultIDs = orderedArtifacts.map(\.transportResultID)
        self.credentialReferenceIDs = orderedArtifacts.map(\.credentialReferenceID)
        self.lastEventArtifactID = lastEvent.eventArtifactID
        self.lastSequenceNumber = lastEvent.sequenceNumber
        self.lastArtifactChecksum = lastEvent.artifactChecksum
        self.eventCount = orderedArtifacts.count
        self.derivedFromNetworkEventLogOnly = derivedFromNetworkEventLogOnly
        self.appendOnlyNetworkExecutionEventLog = appendOnlyNetworkExecutionEventLog
        self.redactedRequestResponseIdentity = redactedRequestResponseIdentity
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        eventCount == sourceEventArtifactIDs.count
            && eventCount == actionEvidenceIDs.count
            && eventCount == signedRequestIDs.count
            && eventCount == transportResultIDs.count
            && eventCount > 0
            && derivedFromNetworkEventLogOnly
            && appendOnlyNetworkExecutionEventLog
            && redactedRequestResponseIdentity
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        intentID: Identifier,
        currentState: OrderLifecycleState,
        lastEventArtifactID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1072-v0150-oms-state-record:\(intentID.rawValue):\(currentState.rawValue):\(lastEventArtifactID.rawValue)",
            field: "releaseV0150OMSStateReconciliation.recordID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.record.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSStateSnapshot 是 #1072 从 network event log 生成的 OMS 状态快照。
public struct ReleaseV0150BinanceSpotTestnetOMSStateSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceLatestArtifactChecksum: String
    public let records: [ReleaseV0150BinanceSpotTestnetOMSStateRecord]
    public let sourceEventArtifactIDs: [Identifier]
    public let coveredActionKinds: [ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind]
    public let sourceArtifactCount: Int
    public let derivedFromNetworkEventLogOnly: Bool
    public let appendOnlyNetworkExecutionEventLog: Bool
    public let checksumChainVerified: Bool
    public let missingEventsFailClosed: Bool
    public let hiddenRuntimeStateMutated: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let expectedObservedReconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        sourceEventLogID: Identifier,
        sourceLatestArtifactChecksum: String,
        records: [ReleaseV0150BinanceSpotTestnetOMSStateRecord],
        sourceEventArtifactIDs: [Identifier],
        coveredActionKinds: [ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind],
        sourceArtifactCount: Int,
        derivedFromNetworkEventLogOnly: Bool = true,
        appendOnlyNetworkExecutionEventLog: Bool = true,
        checksumChainVerified: Bool = true,
        missingEventsFailClosed: Bool = true,
        hiddenRuntimeStateMutated: Bool = false,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        expectedObservedReconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard records.isEmpty == false, sourceEventArtifactIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.snapshotSource",
                expected: "non-empty network-event-derived records",
                actual: "empty snapshot source"
            )
        }
        guard records.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldRecords")
        }
        let coveredEventIDs = Set(records.flatMap(\.sourceEventArtifactIDs).map(\.rawValue))
        let expectedEventIDs = Set(sourceEventArtifactIDs.map(\.rawValue))
        guard coveredEventIDs == expectedEventIDs, sourceArtifactCount == sourceEventArtifactIDs.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.eventCoverage",
                expected: sourceEventArtifactIDs.map(\.rawValue).joined(separator: ","),
                actual: coveredEventIDs.sorted().joined(separator: ",")
            )
        }
        guard Set(sourceEventArtifactIDs.map(\.rawValue)).count == sourceEventArtifactIDs.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.sourceEventArtifactIDs",
                expected: "unique append-only artifact IDs",
                actual: "duplicate artifact ID"
            )
        }
        guard derivedFromNetworkEventLogOnly,
              appendOnlyNetworkExecutionEventLog,
              checksumChainVerified,
              missingEventsFailClosed,
              hiddenRuntimeStateMutated == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.nonEventDerivedSnapshot")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(expectedObservedReconciliationIncluded, "expectedObservedReconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.snapshot.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.snapshotID = Self.deterministicID(
            sourceEventLogID: sourceEventLogID,
            sourceLatestArtifactChecksum: sourceLatestArtifactChecksum,
            sourceEventArtifactIDs: sourceEventArtifactIDs
        )
        self.sourceEventLogID = sourceEventLogID
        self.sourceLatestArtifactChecksum = sourceLatestArtifactChecksum
        self.records = records
        self.sourceEventArtifactIDs = sourceEventArtifactIDs
        self.coveredActionKinds = coveredActionKinds
        self.sourceArtifactCount = sourceArtifactCount
        self.derivedFromNetworkEventLogOnly = derivedFromNetworkEventLogOnly
        self.appendOnlyNetworkExecutionEventLog = appendOnlyNetworkExecutionEventLog
        self.checksumChainVerified = checksumChainVerified
        self.missingEventsFailClosed = missingEventsFailClosed
        self.hiddenRuntimeStateMutated = hiddenRuntimeStateMutated
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.expectedObservedReconciliationIncluded = expectedObservedReconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        records.isEmpty == false
            && sourceEventArtifactIDs.isEmpty == false
            && records.allSatisfy(\.boundaryHeld)
            && sourceArtifactCount == sourceEventArtifactIDs.count
            && derivedFromNetworkEventLogOnly
            && appendOnlyNetworkExecutionEventLog
            && checksumChainVerified
            && missingEventsFailClosed
            && hiddenRuntimeStateMutated == false
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && expectedObservedReconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public func record(for intentID: Identifier) -> ReleaseV0150BinanceSpotTestnetOMSStateRecord? {
        records.first { $0.intentID == intentID }
    }

    public static let requiredValidationAnchors = [
        "GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION",
        "TVM-RELEASE-V0150-OMS-STATE-SYNC-RECONCILIATION",
        "V0150-007-CONSUMES-NETWORK-EVENT-LOG",
        "V0150-007-OMS-STATE-SYNC-FROM-APPEND-ONLY-EVIDENCE",
        "V0150-007-EXPECTED-OBSERVED-RECONCILIATION",
        "V0150-007-MISMATCH-FAIL-CLOSED",
        "V0150-007-SUBMIT-CANCEL-CANCEL-REPLACE-COVERAGE",
        "V0150-007-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        sourceEventLogID: Identifier,
        sourceLatestArtifactChecksum: String,
        sourceEventArtifactIDs: [Identifier]
    ) -> Identifier {
        .constant(
            [
                "gh-1072-v0150-oms-state-snapshot",
                sourceEventLogID.rawValue,
                "\(sourceEventArtifactIDs.count)",
                sourceEventArtifactIDs.last?.rawValue ?? "missing",
                sourceLatestArtifactChecksum
            ].joined(separator: ":"),
            field: "releaseV0150OMSStateReconciliation.snapshotID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.snapshot.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence 是 reconciliation 的 expected / observed 对照输入。
public struct ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence: Codable, Equatable, Sendable {
    public let observationID: Identifier
    public let kind: ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind
    public let intentID: Identifier
    public let sourceEventArtifactID: Identifier
    public let sourceSequenceNumber: Int
    public let observedLifecycleState: OrderLifecycleState
    public let actionEvidenceID: Identifier
    public let signedRequestID: Identifier
    public let transportResultID: Identifier
    public let latestArtifactChecksum: String
    public let acknowledgedBySpotTestnet: Bool
    public let redactedRequestResponseIdentity: Bool
    public let derivedFromNetworkEventLogOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        observationID: Identifier,
        kind: ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind,
        eventArtifact: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact,
        observedLifecycleState: OrderLifecycleState? = nil,
        acknowledgedBySpotTestnet: Bool = true,
        redactedRequestResponseIdentity: Bool = true,
        derivedFromNetworkEventLogOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let lifecycleState = observedLifecycleState ?? eventArtifact.orderLifecycleState
        guard eventArtifact.boundaryHeld,
              kind.expectedActionKind == eventArtifact.actionKind,
              kind.expectedLifecycleStates.contains(lifecycleState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.observation",
                expected: "\(kind.expectedActionKind.rawValue):\(kind.expectedLifecycleStates.map(\.rawValue).sorted().joined(separator: "|"))",
                actual: "\(eventArtifact.actionKind.rawValue):\(lifecycleState.rawValue)"
            )
        }
        guard acknowledgedBySpotTestnet,
              redactedRequestResponseIdentity,
              derivedFromNetworkEventLogOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldObservation")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard observationID == Self.deterministicID(
            kind: kind,
            intentID: eventArtifact.intentID,
            sourceEventArtifactID: eventArtifact.eventArtifactID,
            actionEvidenceID: eventArtifact.actionEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.observationID",
                expected: Self.deterministicID(
                    kind: kind,
                    intentID: eventArtifact.intentID,
                    sourceEventArtifactID: eventArtifact.eventArtifactID,
                    actionEvidenceID: eventArtifact.actionEvidenceID
                ).rawValue,
                actual: observationID.rawValue
            )
        }

        self.observationID = observationID
        self.kind = kind
        self.intentID = eventArtifact.intentID
        self.sourceEventArtifactID = eventArtifact.eventArtifactID
        self.sourceSequenceNumber = eventArtifact.sequenceNumber
        self.observedLifecycleState = lifecycleState
        self.actionEvidenceID = eventArtifact.actionEvidenceID
        self.signedRequestID = eventArtifact.signedRequestID
        self.transportResultID = eventArtifact.transportResultID
        self.latestArtifactChecksum = eventArtifact.artifactChecksum
        self.acknowledgedBySpotTestnet = acknowledgedBySpotTestnet
        self.redactedRequestResponseIdentity = redactedRequestResponseIdentity
        self.derivedFromNetworkEventLogOnly = derivedFromNetworkEventLogOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        kind.expectedLifecycleStates.contains(observedLifecycleState)
            && acknowledgedBySpotTestnet
            && redactedRequestResponseIdentity
            && derivedFromNetworkEventLogOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func from(
        eventArtifact: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact
    ) throws -> ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence {
        let kind = ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind.from(
            actionKind: eventArtifact.actionKind
        )
        return try ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence(
            observationID: deterministicID(
                kind: kind,
                intentID: eventArtifact.intentID,
                sourceEventArtifactID: eventArtifact.eventArtifactID,
                actionEvidenceID: eventArtifact.actionEvidenceID
            ),
            kind: kind,
            eventArtifact: eventArtifact
        )
    }

    public static func deterministicID(
        kind: ReleaseV0150BinanceSpotTestnetOMSReconciliationObservationKind,
        intentID: Identifier,
        sourceEventArtifactID: Identifier,
        actionEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1072-v0150-oms-observation:\(kind.rawValue):\(intentID.rawValue):\(sourceEventArtifactID.rawValue):\(actionEvidenceID.rawValue)",
            field: "releaseV0150OMSStateReconciliation.observationID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.observation.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure 是 #1072 的 fail-closed mismatch 证据。
public struct ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure: Codable, Equatable, Sendable {
    public let failureID: Identifier
    public let reason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason
    public let intentID: Identifier?
    public let sourceEventArtifactID: Identifier?
    public let observationID: Identifier?
    public let expected: String
    public let actual: String
    public let failClosed: Bool

    public init(
        failureID: Identifier,
        reason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason,
        intentID: Identifier?,
        sourceEventArtifactID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String,
        failClosed: Bool = true
    ) throws {
        guard expected.isEmpty == false, actual.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.failureDetail",
                expected: "non-empty expected and actual values",
                actual: "empty mismatch detail"
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.nonFailClosedMismatch")
        }
        guard failureID == Self.deterministicID(
            reason: reason,
            intentID: intentID,
            sourceEventArtifactID: sourceEventArtifactID,
            observationID: observationID,
            expected: expected,
            actual: actual
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.failureID",
                expected: Self.deterministicID(
                    reason: reason,
                    intentID: intentID,
                    sourceEventArtifactID: sourceEventArtifactID,
                    observationID: observationID,
                    expected: expected,
                    actual: actual
                ).rawValue,
                actual: failureID.rawValue
            )
        }

        self.failureID = failureID
        self.reason = reason
        self.intentID = intentID
        self.sourceEventArtifactID = sourceEventArtifactID
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
        reason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason,
        intentID: Identifier?,
        sourceEventArtifactID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String
    ) -> Identifier {
        .constant(
            "gh-1072-v0150-oms-reconciliation-failure:\(reason.rawValue):\(intentID?.rawValue ?? "none"):\(sourceEventArtifactID?.rawValue ?? "none"):\(observationID?.rawValue ?? "none"):\(expected):\(actual)",
            field: "releaseV0150OMSStateReconciliation.failureID"
        )
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSReconciliationReport 固定 #1072 expected / observed 对齐结果。
public struct ReleaseV0150BinanceSpotTestnetOMSReconciliationReport: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let sourceSnapshotID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceLatestArtifactChecksum: String
    public let sourceEventArtifactIDs: [Identifier]
    public let observationIDs: [Identifier]
    public let status: ReleaseV0150BinanceSpotTestnetOMSReconciliationStatus
    public let failures: [ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure]
    public let evidenceCoverageComplete: Bool
    public let expectedObservedReconciliation: Bool
    public let mismatchesFailClosed: Bool
    public let derivedFromNetworkEventLogOnly: Bool
    public let testnetEvidenceOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        sourceSnapshotID: Identifier,
        sourceEventLogID: Identifier,
        sourceLatestArtifactChecksum: String,
        sourceEventArtifactIDs: [Identifier],
        observations: [ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence],
        status: ReleaseV0150BinanceSpotTestnetOMSReconciliationStatus,
        failures: [ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure],
        evidenceCoverageComplete: Bool,
        expectedObservedReconciliation: Bool = true,
        mismatchesFailClosed: Bool = true,
        derivedFromNetworkEventLogOnly: Bool = true,
        testnetEvidenceOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors
    ) throws {
        guard sourceEventArtifactIDs.isEmpty == false, observations.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.reportSource",
                expected: "non-empty source artifacts and observations",
                actual: "empty report source"
            )
        }
        guard observations.allSatisfy(\.boundaryHeld), failures.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldReportEvidence")
        }
        guard status == .passed ? failures.isEmpty && evidenceCoverageComplete : failures.isEmpty == false && evidenceCoverageComplete == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.reportStatus",
                expected: "passed without failures or failed with fail-closed failures",
                actual: "\(status.rawValue):failures=\(failures.count):coverage=\(evidenceCoverageComplete)"
            )
        }
        guard expectedObservedReconciliation,
              mismatchesFailClosed,
              derivedFromNetworkEventLogOnly,
              testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldReportBoundary")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.report.validationAnchors",
                expected: ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.reportID = Self.deterministicID(
            sourceSnapshotID: sourceSnapshotID,
            observationIDs: observations.map(\.observationID),
            failureIDs: failures.map(\.failureID)
        )
        self.sourceSnapshotID = sourceSnapshotID
        self.sourceEventLogID = sourceEventLogID
        self.sourceLatestArtifactChecksum = sourceLatestArtifactChecksum
        self.sourceEventArtifactIDs = sourceEventArtifactIDs
        self.observationIDs = observations.map(\.observationID)
        self.status = status
        self.failures = failures
        self.evidenceCoverageComplete = evidenceCoverageComplete
        self.expectedObservedReconciliation = expectedObservedReconciliation
        self.mismatchesFailClosed = mismatchesFailClosed
        self.derivedFromNetworkEventLogOnly = derivedFromNetworkEventLogOnly
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        sourceEventArtifactIDs.isEmpty == false
            && observationIDs.isEmpty == false
            && (status == .passed ? failures.isEmpty && evidenceCoverageComplete : failures.isEmpty == false && evidenceCoverageComplete == false)
            && failures.allSatisfy(\.boundaryHeld)
            && expectedObservedReconciliation
            && mismatchesFailClosed
            && derivedFromNetworkEventLogOnly
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors
    }

    public static func deterministicID(
        sourceSnapshotID: Identifier,
        observationIDs: [Identifier],
        failureIDs: [Identifier]
    ) -> Identifier {
        .constant(
            [
                "gh-1072-v0150-oms-reconciliation-report",
                sourceSnapshotID.rawValue,
                "\(observationIDs.count)",
                observationIDs.last?.rawValue ?? "none",
                "\(failureIDs.count)",
                failureIDs.last?.rawValue ?? "none"
            ].joined(separator: ":"),
            field: "releaseV0150OMSStateReconciliation.reportID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.report.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetOMSStateReconciliationEngine 是 #1072 的无状态本地校验器。
///
/// Engine 只消费已存在的 append-only network event log；它不构造 request、不读取 credential、
/// 不连接 endpoint，也不发送任何新的 testnet 或 production order。
public struct ReleaseV0150BinanceSpotTestnetOMSStateReconciliationEngine: Codable, Equatable, Sendable {
    public let engineID: Identifier
    public let derivedFromNetworkEventLogOnly: Bool
    public let expectedObservedReconciliation: Bool
    public let mismatchesFailClosed: Bool
    public let testnetEvidenceOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        engineID: Identifier = Identifier.constant("gh-1072-v0150-oms-state-reconciliation-engine"),
        derivedFromNetworkEventLogOnly: Bool = true,
        expectedObservedReconciliation: Bool = true,
        mismatchesFailClosed: Bool = true,
        testnetEvidenceOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors
    ) throws {
        guard derivedFromNetworkEventLogOnly,
              expectedObservedReconciliation,
              mismatchesFailClosed,
              testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.engineBoundary")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150OMSStateReconciliation.engine.validationAnchors",
                expected: ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.engineID = engineID
        self.derivedFromNetworkEventLogOnly = derivedFromNetworkEventLogOnly
        self.expectedObservedReconciliation = expectedObservedReconciliation
        self.mismatchesFailClosed = mismatchesFailClosed
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        derivedFromNetworkEventLogOnly
            && expectedObservedReconciliation
            && mismatchesFailClosed
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0150BinanceSpotTestnetOMSStateSnapshot.requiredValidationAnchors
    }

    public func sync(
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    ) throws -> ReleaseV0150BinanceSpotTestnetOMSStateSnapshot {
        guard boundaryHeld, networkEventLog.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldNetworkEventLog")
        }
        let groupedArtifacts = Dictionary(grouping: networkEventLog.eventArtifacts, by: \.intentID)
        let records = try groupedArtifacts.values
            .map { try ReleaseV0150BinanceSpotTestnetOMSStateRecord(eventArtifacts: $0) }
            .sorted { $0.lastSequenceNumber < $1.lastSequenceNumber }
        return try ReleaseV0150BinanceSpotTestnetOMSStateSnapshot(
            sourceEventLogID: networkEventLog.logID,
            sourceLatestArtifactChecksum: networkEventLog.latestArtifactChecksum,
            records: records,
            sourceEventArtifactIDs: networkEventLog.eventArtifacts.map(\.eventArtifactID),
            coveredActionKinds: Self.coveredActionKinds(networkEventLog.eventArtifacts),
            sourceArtifactCount: networkEventLog.eventArtifacts.count
        )
    }

    public func observations(
        from networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    ) throws -> [ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence] {
        guard networkEventLog.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldObservationLog")
        }
        return try networkEventLog.eventArtifacts.map {
            try ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence.from(eventArtifact: $0)
        }
    }

    public func reconcile(
        snapshot: ReleaseV0150BinanceSpotTestnetOMSStateSnapshot,
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        observations: [ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence]
    ) throws -> ReleaseV0150BinanceSpotTestnetOMSReconciliationReport {
        guard boundaryHeld, snapshot.boundaryHeld, networkEventLog.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldReconciliationSource")
        }
        guard observations.isEmpty == false, observations.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.unheldObservations")
        }

        var failures: [ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure] = []
        if snapshot.sourceEventLogID != networkEventLog.logID
            || snapshot.sourceLatestArtifactChecksum != networkEventLog.latestArtifactChecksum
            || snapshot.sourceEventArtifactIDs != networkEventLog.eventArtifacts.map(\.eventArtifactID) {
            failures.append(try failure(
                reason: .snapshotLogMismatch,
                intentID: nil,
                sourceEventArtifactID: nil,
                observationID: nil,
                expected: snapshot.sourceEventArtifactIDs.map(\.rawValue).joined(separator: ","),
                actual: networkEventLog.eventArtifacts.map { $0.eventArtifactID.rawValue }.joined(separator: ",")
            ))
        }

        for observation in observations {
            let record = snapshot.record(for: observation.intentID)
            let artifact = networkEventLog.eventArtifacts.first { $0.eventArtifactID == observation.sourceEventArtifactID }

            guard let record else {
                failures.append(try failure(
                    reason: .missingStateRecord,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: "state sync record for intent",
                    actual: "missing"
                ))
                continue
            }
            guard let artifact else {
                failures.append(try failure(
                    reason: .missingSourceArtifact,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: "network event artifact in source log",
                    actual: "missing"
                ))
                continue
            }

            if record.sourceEventArtifactIDs.contains(observation.sourceEventArtifactID) == false {
                failures.append(try failure(
                    reason: .observationCoverageMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: "source artifact covered by state record",
                    actual: "not covered"
                ))
            }
            if artifact.intentID != observation.intentID
                || artifact.sequenceNumber != observation.sourceSequenceNumber
                || artifact.signedRequestID != observation.signedRequestID {
                failures.append(try failure(
                    reason: .identityMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: "\(artifact.intentID.rawValue):\(artifact.sequenceNumber):\(artifact.signedRequestID.rawValue)",
                    actual: "\(observation.intentID.rawValue):\(observation.sourceSequenceNumber):\(observation.signedRequestID.rawValue)"
                ))
            }
            if artifact.actionKind != observation.kind.expectedActionKind {
                failures.append(try failure(
                    reason: .actionKindMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: artifact.actionKind.rawValue,
                    actual: observation.kind.expectedActionKind.rawValue
                ))
            }
            if artifact.orderLifecycleState != observation.observedLifecycleState {
                failures.append(try failure(
                    reason: .lifecycleStateMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: artifact.orderLifecycleState.rawValue,
                    actual: observation.observedLifecycleState.rawValue
                ))
            }
            if artifact.actionEvidenceID != observation.actionEvidenceID {
                failures.append(try failure(
                    reason: .actionEvidenceMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: artifact.actionEvidenceID.rawValue,
                    actual: observation.actionEvidenceID.rawValue
                ))
            }
            if artifact.transportResultID != observation.transportResultID {
                failures.append(try failure(
                    reason: .transportEvidenceMismatch,
                    intentID: observation.intentID,
                    sourceEventArtifactID: observation.sourceEventArtifactID,
                    observationID: observation.observationID,
                    expected: artifact.transportResultID.rawValue,
                    actual: observation.transportResultID.rawValue
                ))
            }
        }

        let expectedObservationArtifactIDs = Set(networkEventLog.eventArtifacts.map(\.eventArtifactID))
        let observedArtifactIDs = Set(observations.map(\.sourceEventArtifactID))
        if observedArtifactIDs != expectedObservationArtifactIDs {
            failures.append(try failure(
                reason: .observationCoverageMismatch,
                intentID: nil,
                sourceEventArtifactID: nil,
                observationID: nil,
                expected: expectedObservationArtifactIDs.map(\.rawValue).sorted().joined(separator: ","),
                actual: observedArtifactIDs.map(\.rawValue).sorted().joined(separator: ",")
            ))
        }

        let status: ReleaseV0150BinanceSpotTestnetOMSReconciliationStatus = failures.isEmpty ? .passed : .failed
        return try ReleaseV0150BinanceSpotTestnetOMSReconciliationReport(
            sourceSnapshotID: snapshot.snapshotID,
            sourceEventLogID: networkEventLog.logID,
            sourceLatestArtifactChecksum: networkEventLog.latestArtifactChecksum,
            sourceEventArtifactIDs: networkEventLog.eventArtifacts.map(\.eventArtifactID),
            observations: observations,
            status: status,
            failures: failures,
            evidenceCoverageComplete: failures.isEmpty,
            validationAnchors: validationAnchors
        )
    }

    private static func coveredActionKinds(
        _ artifacts: [ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact]
    ) -> [ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind] {
        ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind.allCases.filter { actionKind in
            artifacts.contains { $0.actionKind == actionKind }
        }
    }

    private func failure(
        reason: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailureReason,
        intentID: Identifier?,
        sourceEventArtifactID: Identifier?,
        observationID: Identifier?,
        expected: String,
        actual: String
    ) throws -> ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure {
        try ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure(
            failureID: ReleaseV0150BinanceSpotTestnetOMSReconciliationFailure.deterministicID(
                reason: reason,
                intentID: intentID,
                sourceEventArtifactID: sourceEventArtifactID,
                observationID: observationID,
                expected: expected,
                actual: actual
            ),
            reason: reason,
            intentID: intentID,
            sourceEventArtifactID: sourceEventArtifactID,
            observationID: observationID,
            expected: expected,
            actual: actual
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150OMSStateReconciliation.engine.\(field)")
        }
    }
}
