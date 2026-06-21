import DomainModel
import Foundation

/// ReleaseV0140OMSStateSyncRecord 是 GH-1033 从 order event stream 推导出的当前本地订单状态。
///
/// record 只保存 replay projection 得到的状态和 evidence ID 链路。它不是 production OMS
/// record，也不代表 broker 当前状态、真实账户持仓、broker fill 或 reconciliation 结果。
public struct ReleaseV0140OMSStateSyncRecord: Codable, Equatable, Sendable {
    public let stateSyncEvidenceID: Identifier
    public let localOrderID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let currentState: OrderLifecycleState
    public let lastEventID: Identifier
    public let eventIDs: [Identifier]
    public let correlationIDs: [Identifier]
    public let causationIDs: [Identifier]
    public let orderIntentID: Identifier
    public let riskEvidenceIDs: [Identifier]
    public let executionEvidenceIDs: [Identifier]
    public let omsEvidenceIDs: [Identifier]
    public let adapterEvidenceIDs: [Identifier]
    public let eventCount: Int
    public let derivedFromEventsOnly: Bool
    public let hiddenRuntimeStateMutated: Bool
    public let testnetEvidenceOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        projection: ReleaseV0140OrderEventSourcingProjection,
        derivedFromEventsOnly: Bool = true,
        hiddenRuntimeStateMutated: Bool = false,
        testnetEvidenceOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard projection.boundaryHeld,
              let lastEventID = projection.eventIDs.last,
              projection.eventIDs.isEmpty == false,
              projection.correlationIDs.isEmpty == false,
              projection.causationIDs.isEmpty == false,
              projection.omsEvidenceIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.invalidProjection")
        }
        guard derivedFromEventsOnly, hiddenRuntimeStateMutated == false, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.hiddenRuntimeState")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.stateSyncEvidenceID = Self.deterministicID(
            localOrderID: projection.localOrderID,
            currentState: projection.currentState,
            lastEventID: lastEventID
        )
        self.localOrderID = projection.localOrderID
        self.productType = projection.productType
        self.symbol = projection.symbol
        self.currentState = projection.currentState
        self.lastEventID = lastEventID
        self.eventIDs = projection.eventIDs
        self.correlationIDs = projection.correlationIDs
        self.causationIDs = projection.causationIDs
        self.orderIntentID = projection.orderIntentID
        self.riskEvidenceIDs = projection.riskEvidenceIDs
        self.executionEvidenceIDs = projection.executionEvidenceIDs
        self.omsEvidenceIDs = projection.omsEvidenceIDs
        self.adapterEvidenceIDs = projection.adapterEvidenceIDs
        self.eventCount = projection.eventIDs.count
        self.derivedFromEventsOnly = derivedFromEventsOnly
        self.hiddenRuntimeStateMutated = hiddenRuntimeStateMutated
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        eventCount == eventIDs.count
            && eventIDs.isEmpty == false
            && correlationIDs.isEmpty == false
            && causationIDs.isEmpty == false
            && omsEvidenceIDs.isEmpty == false
            && derivedFromEventsOnly
            && hiddenRuntimeStateMutated == false
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        localOrderID: Identifier,
        currentState: OrderLifecycleState,
        lastEventID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1033-oms-state-sync-record:\(localOrderID.rawValue):\(currentState.rawValue):\(lastEventID.rawValue)",
            field: "releaseV0140OMSStateSync.recordID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.record.\(field)")
        }
    }
}

/// ReleaseV0140OMSStateSyncSnapshot 是 GH-1033 的当前本地 OMS state sync 结果。
///
/// snapshot 必须从 order event sourcing replay 得到。它不允许把隐藏可变 runtime state
/// 当成当前订单状态来源，也不允许保存 broker payload、fill 或 reconciliation runtime 输出。
public struct ReleaseV0140OMSStateSyncSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let sourceStreamID: Identifier
    public let records: [ReleaseV0140OMSStateSyncRecord]
    public let sourceEventIDs: [Identifier]
    public let sourceProjectionCount: Int
    public let derivedFromEventsOnly: Bool
    public let replayVerified: Bool
    public let missingEventsFailClosed: Bool
    public let hiddenRuntimeStateMutated: Bool
    public let appendOnlySource: Bool
    public let replayableSource: Bool
    public let testnetEvidenceOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        sourceStreamID: Identifier,
        records: [ReleaseV0140OMSStateSyncRecord],
        sourceEventIDs: [Identifier],
        sourceProjectionCount: Int,
        derivedFromEventsOnly: Bool = true,
        replayVerified: Bool = true,
        missingEventsFailClosed: Bool = true,
        hiddenRuntimeStateMutated: Bool = false,
        appendOnlySource: Bool = true,
        replayableSource: Bool = true,
        testnetEvidenceOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard records.isEmpty == false, sourceEventIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.snapshotSource",
                expected: "non-empty event-derived records and source events",
                actual: "empty state sync source"
            )
        }
        guard records.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.unheldRecords")
        }
        guard Set(records.map { $0.localOrderID.rawValue }).count == records.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.records",
                expected: "unique localOrderID records",
                actual: "duplicate localOrderID"
            )
        }
        guard Set(sourceEventIDs.map { $0.rawValue }).count == sourceEventIDs.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.sourceEventIDs",
                expected: "unique append-only source event IDs",
                actual: "duplicate source event ID"
            )
        }
        let coveredEventIDs = Set(records.flatMap { $0.eventIDs }.map { $0.rawValue })
        guard coveredEventIDs == Set(sourceEventIDs.map { $0.rawValue }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.eventCoverage",
                expected: sourceEventIDs.map(\.rawValue).joined(separator: ","),
                actual: coveredEventIDs.sorted().joined(separator: ",")
            )
        }
        guard sourceProjectionCount == records.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.projectionCount",
                expected: "\(records.count)",
                actual: "\(sourceProjectionCount)"
            )
        }
        guard derivedFromEventsOnly,
              replayVerified,
              missingEventsFailClosed,
              hiddenRuntimeStateMutated == false,
              appendOnlySource,
              replayableSource,
              testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.nonEventDerivedSnapshot")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.snapshotID = Self.deterministicID(
            sourceStreamID: sourceStreamID,
            sourceEventIDs: sourceEventIDs
        )
        self.sourceStreamID = sourceStreamID
        self.records = records
        self.sourceEventIDs = sourceEventIDs
        self.sourceProjectionCount = sourceProjectionCount
        self.derivedFromEventsOnly = derivedFromEventsOnly
        self.replayVerified = replayVerified
        self.missingEventsFailClosed = missingEventsFailClosed
        self.hiddenRuntimeStateMutated = hiddenRuntimeStateMutated
        self.appendOnlySource = appendOnlySource
        self.replayableSource = replayableSource
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        records.isEmpty == false
            && sourceEventIDs.isEmpty == false
            && records.allSatisfy(\.boundaryHeld)
            && sourceProjectionCount == records.count
            && derivedFromEventsOnly
            && replayVerified
            && missingEventsFailClosed
            && hiddenRuntimeStateMutated == false
            && appendOnlySource
            && replayableSource
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public func record(for localOrderID: Identifier) -> ReleaseV0140OMSStateSyncRecord? {
        records.first { $0.localOrderID == localOrderID }
    }

    public static func deterministicID(
        sourceStreamID: Identifier,
        sourceEventIDs: [Identifier]
    ) -> Identifier {
        let lastEventID = sourceEventIDs.last?.rawValue ?? "missing"
        return .constant(
            "gh-1033-oms-state-sync-snapshot:\(sourceStreamID.rawValue):\(sourceEventIDs.count):\(lastEventID)",
            field: "releaseV0140OMSStateSync.snapshotID"
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1033-OMS-STATE-SYNC-ENGINE",
        "GH-1033-STATE-DERIVED-FROM-EVENTS",
        "GH-1033-FAIL-CLOSED-MISSING-EVENTS",
        "TVM-RELEASE-V0140-OMS-STATE-SYNC"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.snapshot.\(field)")
        }
    }
}

/// ReleaseV0140OMSStateSyncEngine 是 GH-1033 的无状态本地 state sync engine。
///
/// engine 每次都 replay order event stream 并生成 snapshot，不缓存 current state，不连接 broker，
/// 不读取 credential，也不执行 submit / cancel / replace。任何缺失或不连续事件都会通过 replay
/// 合同 fail closed。
public struct ReleaseV0140OMSStateSyncEngine: Codable, Equatable, Sendable {
    public let engineID: Identifier
    public let derivedFromEventsOnly: Bool
    public let hiddenRuntimeStateMutated: Bool
    public let missingEventsFailClosed: Bool
    public let testnetEvidenceOnly: Bool
    public let rawBrokerPayloadIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let networkOrderActionPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        engineID: Identifier = Identifier.constant("gh-1033-oms-state-sync-engine"),
        derivedFromEventsOnly: Bool = true,
        hiddenRuntimeStateMutated: Bool = false,
        missingEventsFailClosed: Bool = true,
        testnetEvidenceOnly: Bool = true,
        rawBrokerPayloadIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        networkOrderActionPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0140OMSStateSyncSnapshot.requiredValidationAnchors
    ) throws {
        guard derivedFromEventsOnly,
              hiddenRuntimeStateMutated == false,
              missingEventsFailClosed,
              testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.engineBoundary")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == ReleaseV0140OMSStateSyncSnapshot.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.engine.validationAnchors",
                expected: ReleaseV0140OMSStateSyncSnapshot.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.engineID = engineID
        self.derivedFromEventsOnly = derivedFromEventsOnly
        self.hiddenRuntimeStateMutated = hiddenRuntimeStateMutated
        self.missingEventsFailClosed = missingEventsFailClosed
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.rawBrokerPayloadIncluded = rawBrokerPayloadIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.networkOrderActionPerformed = networkOrderActionPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        derivedFromEventsOnly
            && hiddenRuntimeStateMutated == false
            && missingEventsFailClosed
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == ReleaseV0140OMSStateSyncSnapshot.requiredValidationAnchors
    }

    public func sync(
        stream: ReleaseV0140OrderEventSourcingStream
    ) throws -> ReleaseV0140OMSStateSyncSnapshot {
        guard boundaryHeld, stream.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.unheldSourceStream")
        }
        guard stream.events.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.events",
                expected: "at least one append-only order event",
                actual: "empty event stream"
            )
        }
        let replayed = try ReleaseV0140OrderEventSourcingStream.replay(
            streamID: stream.streamID,
            events: stream.events
        )
        guard replayed.projections == stream.projections else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.streamProjectionReplay",
                expected: "stream projections exactly match replayed event-derived projections",
                actual: "projection drift from source events"
            )
        }
        return try Self.snapshot(
            streamID: stream.streamID,
            events: stream.events,
            projections: replayed.projections
        )
    }

    public func sync(
        events: [ReleaseV0140OrderEventSourcingEvent],
        streamID: Identifier = Identifier.constant("gh-1032-order-event-sourcing-stream")
    ) throws -> ReleaseV0140OMSStateSyncSnapshot {
        guard events.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSStateSync.events",
                expected: "at least one append-only order event",
                actual: "empty event list"
            )
        }
        let stream = try ReleaseV0140OrderEventSourcingStream.replay(
            streamID: streamID,
            events: events
        )
        return try sync(stream: stream)
    }

    private static func snapshot(
        streamID: Identifier,
        events: [ReleaseV0140OrderEventSourcingEvent],
        projections: [ReleaseV0140OrderEventSourcingProjection]
    ) throws -> ReleaseV0140OMSStateSyncSnapshot {
        let records = try projections.map { try ReleaseV0140OMSStateSyncRecord(projection: $0) }
        return try ReleaseV0140OMSStateSyncSnapshot(
            sourceStreamID: streamID,
            records: records,
            sourceEventIDs: events.map(\.eventID),
            sourceProjectionCount: projections.count
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSStateSync.engine.\(field)")
        }
    }
}
