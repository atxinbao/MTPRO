import DomainModel
import Foundation

/// ReleaseV0140OrderEventSourcingEventKind 描述 GH-1032 order event sourcing 允许追加的事件类型。
///
/// 这些事件只映射 GH-1031 本地 OMS store 事件，服务 v0.14.0 testnet / dry-run 证据链。
/// 它们不是 production broker event，也不表示真实交易所订单事件已经进入系统。
public enum ReleaseV0140OrderEventSourcingEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case orderAppended
    case lifecycleChanged
}

/// ReleaseV0140OrderEventSourcingEvent 是 GH-1032 的 append-only order event。
///
/// 每条 event 都绑定 correlation、causation、OrderIntent、risk / execution / OMS / adapter
/// evidence ID。risk / execution / adapter ID 由上游证据显式传入；当某个 lifecycle step
/// 尚无对应 adapter 证据时允许为空，但 event 仍必须保留 OMS evidence 和 causation。
public struct ReleaseV0140OrderEventSourcingEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let sequence: Int
    public let kind: ReleaseV0140OrderEventSourcingEventKind
    public let localOrderID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let fromState: OrderLifecycleState
    public let toState: OrderLifecycleState
    public let correlationID: Identifier
    public let causationID: Identifier
    public let orderIntentID: Identifier
    public let riskEvidenceID: Identifier?
    public let executionEvidenceID: Identifier?
    public let omsEvidenceID: Identifier
    public let adapterEvidenceID: Identifier?
    public let sourceOMSStoreEventID: Identifier
    public let appendOnly: Bool
    public let replayable: Bool
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
        eventID: Identifier,
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
        adapterEvidenceID: Identifier?,
        sourceOMSStoreEventID: Identifier,
        appendOnly: Bool = true,
        replayable: Bool = true,
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
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.event.sequence",
                expected: "positive append-only sequence",
                actual: "\(sequence)"
            )
        }
        switch kind {
        case .orderAppended:
            guard fromState == toState else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OrderEventSourcing.orderAppendedState",
                    expected: "matching from/to state",
                    actual: "\(fromState.rawValue)->\(toState.rawValue)"
                )
            }
            guard riskEvidenceID != nil, executionEvidenceID != nil, adapterEvidenceID != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OrderEventSourcing.orderAppendedEvidence",
                    expected: "risk, execution and adapter evidence IDs",
                    actual: "missing required append evidence"
                )
            }
        case .lifecycleChanged:
            guard OrderLifecycleStateMachine.canTransition(from: fromState, to: toState) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OrderEventSourcing.lifecycleTransition",
                    expected: "valid OrderLifecycleStateMachine transition",
                    actual: "\(fromState.rawValue)->\(toState.rawValue)"
                )
            }
        }
        guard appendOnly, replayable, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.nonAppendOnlyReplayableEvent")
        }
        try Self.forbid(rawBrokerPayloadIncluded, "rawBrokerPayloadIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(networkOrderActionPerformed, "networkOrderActionPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard omsEvidenceID == sourceOMSStoreEventID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.omsEvidenceID",
                expected: sourceOMSStoreEventID.rawValue,
                actual: omsEvidenceID.rawValue
            )
        }
        guard eventID == Self.deterministicID(
            sequence: sequence,
            kind: kind,
            localOrderID: localOrderID,
            toState: toState,
            correlationID: correlationID,
            causationID: causationID,
            omsEvidenceID: omsEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.eventID",
                expected: Self.deterministicID(
                    sequence: sequence,
                    kind: kind,
                    localOrderID: localOrderID,
                    toState: toState,
                    correlationID: correlationID,
                    causationID: causationID,
                    omsEvidenceID: omsEvidenceID
                ).rawValue,
                actual: eventID.rawValue
            )
        }

        self.eventID = eventID
        self.sequence = sequence
        self.kind = kind
        self.localOrderID = localOrderID
        self.productType = productType
        self.symbol = symbol
        self.fromState = fromState
        self.toState = toState
        self.correlationID = correlationID
        self.causationID = causationID
        self.orderIntentID = orderIntentID
        self.riskEvidenceID = riskEvidenceID
        self.executionEvidenceID = executionEvidenceID
        self.omsEvidenceID = omsEvidenceID
        self.adapterEvidenceID = adapterEvidenceID
        self.sourceOMSStoreEventID = sourceOMSStoreEventID
        self.appendOnly = appendOnly
        self.replayable = replayable
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
        appendOnly
            && replayable
            && testnetEvidenceOnly
            && rawBrokerPayloadIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && networkOrderActionPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && omsEvidenceID == sourceOMSStoreEventID
            && (kind == .orderAppended ? fromState == toState : OrderLifecycleStateMachine.canTransition(from: fromState, to: toState))
            && (kind == .orderAppended ? riskEvidenceID != nil && executionEvidenceID != nil && adapterEvidenceID != nil : true)
    }

    public static func fromOMSStoreEvent(
        sequence: Int,
        omsEvent: ReleaseV0140OMSLocalOrderStoreEvent,
        correlationID: Identifier,
        riskEvidenceID: Identifier?,
        executionEvidenceID: Identifier?,
        adapterEvidenceID: Identifier?
    ) throws -> ReleaseV0140OrderEventSourcingEvent {
        guard omsEvent.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.unheldOMSEvent")
        }
        let kind = Self.kind(for: omsEvent.kind)
        let causationID = omsEvent.sourceEvidenceID
        let eventID = deterministicID(
            sequence: sequence,
            kind: kind,
            localOrderID: omsEvent.localOrderID,
            toState: omsEvent.toState,
            correlationID: correlationID,
            causationID: causationID,
            omsEvidenceID: omsEvent.eventID
        )
        return try ReleaseV0140OrderEventSourcingEvent(
            eventID: eventID,
            sequence: sequence,
            kind: kind,
            localOrderID: omsEvent.localOrderID,
            productType: omsEvent.productType,
            symbol: omsEvent.symbol,
            fromState: omsEvent.fromState,
            toState: omsEvent.toState,
            correlationID: correlationID,
            causationID: causationID,
            orderIntentID: omsEvent.intentID,
            riskEvidenceID: riskEvidenceID,
            executionEvidenceID: executionEvidenceID,
            omsEvidenceID: omsEvent.eventID,
            adapterEvidenceID: adapterEvidenceID,
            sourceOMSStoreEventID: omsEvent.eventID
        )
    }

    public static func kind(
        for omsEventKind: ReleaseV0140OMSLocalOrderStoreEventKind
    ) -> ReleaseV0140OrderEventSourcingEventKind {
        switch omsEventKind {
        case .appendOrder:
            .orderAppended
        case .lifecycleTransition:
            .lifecycleChanged
        }
    }

    public static func deterministicID(
        sequence: Int,
        kind: ReleaseV0140OrderEventSourcingEventKind,
        localOrderID: Identifier,
        toState: OrderLifecycleState,
        correlationID: Identifier,
        causationID: Identifier,
        omsEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1032-order-event-sourcing:\(sequence):\(kind.rawValue):\(localOrderID.rawValue):\(toState.rawValue):\(correlationID.rawValue):\(causationID.rawValue):\(omsEvidenceID.rawValue)",
            field: "releaseV0140OrderEventSourcing.eventID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.event.\(field)")
        }
    }
}

/// ReleaseV0140OrderEventSourcingProjection 是 event replay 后的本地订单投影。
///
/// Projection 只由 order event stream 重放得到；它保留 evidence ID 链路，不保存 broker
/// 原始 payload、fill 或 reconciliation runtime 状态。
public struct ReleaseV0140OrderEventSourcingProjection: Codable, Equatable, Sendable {
    public let localOrderID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let currentState: OrderLifecycleState
    public let eventIDs: [Identifier]
    public let correlationIDs: [Identifier]
    public let causationIDs: [Identifier]
    public let orderIntentID: Identifier
    public let riskEvidenceIDs: [Identifier]
    public let executionEvidenceIDs: [Identifier]
    public let omsEvidenceIDs: [Identifier]
    public let adapterEvidenceIDs: [Identifier]
    public let appendOnly: Bool
    public let replayable: Bool
    public let testnetEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        firstEvent: ReleaseV0140OrderEventSourcingEvent,
        appendOnly: Bool = true,
        replayable: Bool = true,
        testnetEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard firstEvent.boundaryHeld, firstEvent.kind == .orderAppended else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.invalidFirstProjectionEvent")
        }
        guard appendOnly, replayable, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.nonReplayableProjection")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.localOrderID = firstEvent.localOrderID
        self.productType = firstEvent.productType
        self.symbol = firstEvent.symbol
        self.currentState = firstEvent.toState
        self.eventIDs = [firstEvent.eventID]
        self.correlationIDs = [firstEvent.correlationID]
        self.causationIDs = [firstEvent.causationID]
        self.orderIntentID = firstEvent.orderIntentID
        self.riskEvidenceIDs = firstEvent.riskEvidenceID.map { [$0] } ?? []
        self.executionEvidenceIDs = firstEvent.executionEvidenceID.map { [$0] } ?? []
        self.omsEvidenceIDs = [firstEvent.omsEvidenceID]
        self.adapterEvidenceIDs = firstEvent.adapterEvidenceID.map { [$0] } ?? []
        self.appendOnly = appendOnly
        self.replayable = replayable
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    private init(
        localOrderID: Identifier,
        productType: ProductType,
        symbol: Symbol,
        currentState: OrderLifecycleState,
        eventIDs: [Identifier],
        correlationIDs: [Identifier],
        causationIDs: [Identifier],
        orderIntentID: Identifier,
        riskEvidenceIDs: [Identifier],
        executionEvidenceIDs: [Identifier],
        omsEvidenceIDs: [Identifier],
        adapterEvidenceIDs: [Identifier],
        appendOnly: Bool,
        replayable: Bool,
        testnetEvidenceOnly: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretRead: Bool,
        productionEndpointConnected: Bool,
        productionCutoverAuthorized: Bool
    ) {
        self.localOrderID = localOrderID
        self.productType = productType
        self.symbol = symbol
        self.currentState = currentState
        self.eventIDs = eventIDs
        self.correlationIDs = correlationIDs
        self.causationIDs = causationIDs
        self.orderIntentID = orderIntentID
        self.riskEvidenceIDs = riskEvidenceIDs
        self.executionEvidenceIDs = executionEvidenceIDs
        self.omsEvidenceIDs = omsEvidenceIDs
        self.adapterEvidenceIDs = adapterEvidenceIDs
        self.appendOnly = appendOnly
        self.replayable = replayable
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        appendOnly
            && replayable
            && testnetEvidenceOnly
            && eventIDs.isEmpty == false
            && correlationIDs.isEmpty == false
            && causationIDs.isEmpty == false
            && omsEvidenceIDs.isEmpty == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public func applying(_ event: ReleaseV0140OrderEventSourcingEvent) throws -> ReleaseV0140OrderEventSourcingProjection {
        guard boundaryHeld, event.boundaryHeld, event.kind == .lifecycleChanged else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.invalidProjectionEvent")
        }
        guard event.localOrderID == localOrderID,
              event.productType == productType,
              event.symbol == symbol,
              event.orderIntentID == orderIntentID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.projectionIdentity",
                expected: localOrderID.rawValue,
                actual: event.localOrderID.rawValue
            )
        }
        guard event.fromState == currentState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.projectionCurrentState",
                expected: currentState.rawValue,
                actual: event.fromState.rawValue
            )
        }
        return ReleaseV0140OrderEventSourcingProjection(
            localOrderID: localOrderID,
            productType: productType,
            symbol: symbol,
            currentState: event.toState,
            eventIDs: eventIDs + [event.eventID],
            correlationIDs: Self.appendUnique(correlationIDs, event.correlationID),
            causationIDs: causationIDs + [event.causationID],
            orderIntentID: orderIntentID,
            riskEvidenceIDs: Self.appendUnique(riskEvidenceIDs, event.riskEvidenceID),
            executionEvidenceIDs: Self.appendUnique(executionEvidenceIDs, event.executionEvidenceID),
            omsEvidenceIDs: omsEvidenceIDs + [event.omsEvidenceID],
            adapterEvidenceIDs: Self.appendUnique(adapterEvidenceIDs, event.adapterEvidenceID),
            appendOnly: appendOnly,
            replayable: replayable,
            testnetEvidenceOnly: testnetEvidenceOnly,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretRead: productionSecretRead,
            productionEndpointConnected: productionEndpointConnected,
            productionCutoverAuthorized: productionCutoverAuthorized
        )
    }

    private static func appendUnique(_ values: [Identifier], _ value: Identifier?) -> [Identifier] {
        guard let value, values.contains(value) == false else {
            return values
        }
        return values + [value]
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.projection.\(field)")
        }
    }
}

/// ReleaseV0140OrderEventSourcingStream 汇总 GH-1032 的 append-only order event stream。
///
/// Stream 从 GH-1031 OMS local order store event 追加事件，并能 replay 为同一 projection。
/// 它只保存本地 evidence IDs，不创建网络 request，不读取 credential，不连接 broker endpoint。
public struct ReleaseV0140OrderEventSourcingStream: Codable, Equatable, Sendable {
    public let streamID: Identifier
    public let events: [ReleaseV0140OrderEventSourcingEvent]
    public let projections: [ReleaseV0140OrderEventSourcingProjection]
    public let nextSequence: Int
    public let appendOnly: Bool
    public let replayable: Bool
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
        streamID: Identifier = Identifier.constant("gh-1032-order-event-sourcing-stream"),
        events: [ReleaseV0140OrderEventSourcingEvent] = [],
        projections: [ReleaseV0140OrderEventSourcingProjection] = [],
        nextSequence: Int? = nil,
        appendOnly: Bool = true,
        replayable: Bool = true,
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
        guard appendOnly, replayable, testnetEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.nonReplayableStream")
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
                field: "releaseV0140OrderEventSourcing.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard events.allSatisfy(\.boundaryHeld), projections.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.unheldEventsOrProjections")
        }
        guard Set(events.map { $0.eventID.rawValue }).count == events.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.events",
                expected: "unique event IDs",
                actual: "duplicate event ID"
            )
        }
        let expectedSequences = Self.expectedSequences(count: events.count)
        guard events.map(\.sequence) == expectedSequences || events.isEmpty else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.eventSequence",
                expected: expectedSequences.map(String.init).joined(separator: ","),
                actual: events.map { String($0.sequence) }.joined(separator: ",")
            )
        }
        guard Set(projections.map { $0.localOrderID.rawValue }).count == projections.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.projections",
                expected: "unique local order projections",
                actual: "duplicate projection"
            )
        }

        self.streamID = streamID
        self.events = events
        self.projections = projections
        self.nextSequence = nextSequence ?? (events.count + 1)
        self.appendOnly = appendOnly
        self.replayable = replayable
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
        appendOnly
            && replayable
            && testnetEvidenceOnly
            && events.allSatisfy(\.boundaryHeld)
            && projections.allSatisfy(\.boundaryHeld)
            && events.map(\.sequence) == Self.expectedSequences(count: events.count)
            && nextSequence == events.count + 1
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

    public func projection(for localOrderID: Identifier) -> ReleaseV0140OrderEventSourcingProjection? {
        projections.first { $0.localOrderID == localOrderID }
    }

    public func append(
        omsEvent: ReleaseV0140OMSLocalOrderStoreEvent,
        correlationID: Identifier,
        riskEvidenceID: Identifier?,
        executionEvidenceID: Identifier?,
        adapterEvidenceID: Identifier?
    ) throws -> ReleaseV0140OrderEventSourcingStream {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.unheldStream")
        }
        let event = try ReleaseV0140OrderEventSourcingEvent.fromOMSStoreEvent(
            sequence: nextSequence,
            omsEvent: omsEvent,
            correlationID: correlationID,
            riskEvidenceID: riskEvidenceID,
            executionEvidenceID: executionEvidenceID,
            adapterEvidenceID: adapterEvidenceID
        )
        let updatedProjections = try Self.apply(event: event, to: projections)
        return try ReleaseV0140OrderEventSourcingStream(
            streamID: streamID,
            events: events + [event],
            projections: updatedProjections,
            appendOnly: appendOnly,
            replayable: replayable,
            testnetEvidenceOnly: testnetEvidenceOnly,
            validationAnchors: validationAnchors
        )
    }

    public static func replay(
        streamID: Identifier = Identifier.constant("gh-1032-order-event-sourcing-stream"),
        events: [ReleaseV0140OrderEventSourcingEvent]
    ) throws -> ReleaseV0140OrderEventSourcingStream {
        let sortedEvents = events.sorted { $0.sequence < $1.sequence }
        guard sortedEvents.map(\.eventID) == events.map(\.eventID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OrderEventSourcing.replayOrder",
                expected: "events already sorted by append-only sequence",
                actual: "out-of-order events"
            )
        }
        var projections: [ReleaseV0140OrderEventSourcingProjection] = []
        for event in sortedEvents {
            projections = try apply(event: event, to: projections)
        }
        return try ReleaseV0140OrderEventSourcingStream(
            streamID: streamID,
            events: sortedEvents,
            projections: projections
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1032-ORDER-EVENT-SOURCING",
        "GH-1032-APPEND-ONLY-REPLAY",
        "GH-1032-CORRELATION-CAUSATION-EVIDENCE",
        "TVM-RELEASE-V0140-ORDER-EVENT-SOURCING"
    ]

    private static func apply(
        event: ReleaseV0140OrderEventSourcingEvent,
        to projections: [ReleaseV0140OrderEventSourcingProjection]
    ) throws -> [ReleaseV0140OrderEventSourcingProjection] {
        var updatedProjections = projections
        switch event.kind {
        case .orderAppended:
            guard updatedProjections.contains(where: { $0.localOrderID == event.localOrderID }) == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OrderEventSourcing.append",
                    expected: "new localOrderID",
                    actual: event.localOrderID.rawValue
                )
            }
            updatedProjections.append(try ReleaseV0140OrderEventSourcingProjection(firstEvent: event))
        case .lifecycleChanged:
            guard let index = updatedProjections.firstIndex(where: { $0.localOrderID == event.localOrderID }) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OrderEventSourcing.lifecycle",
                    expected: "existing local order before lifecycle event",
                    actual: event.localOrderID.rawValue
                )
            }
            updatedProjections[index] = try updatedProjections[index].applying(event)
        }
        return updatedProjections
    }

    private static func expectedSequences(count: Int) -> [Int] {
        count == 0 ? [] : Array(1...count)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OrderEventSourcing.stream.\(field)")
        }
    }
}
