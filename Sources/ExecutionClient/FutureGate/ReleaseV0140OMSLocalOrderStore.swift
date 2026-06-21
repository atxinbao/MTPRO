import DomainModel
import Foundation

/// ReleaseV0140OMSLocalOrderStoreEventKind 描述 GH-1031 本地 OMS store 允许记录的事件类型。
///
/// 这些事件只服务 testnet / dry-run lifecycle evidence。它们不是 production OMS 事件，
/// 也不代表交易所真实订单状态或真实账户仓位。
public enum ReleaseV0140OMSLocalOrderStoreEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case appendOrder
    case lifecycleTransition
}

/// ReleaseV0140OMSLocalOrderStoreEvent 是 GH-1031 的 append-only 本地订单事件。
///
/// 事件必须保留 local order identity、状态迁移和 source evidence ID。它不包含交易所原始
/// order id、真实账户余额、production position ownership、broker fill 或 reconciliation 结果。
public struct ReleaseV0140OMSLocalOrderStoreEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let sequence: Int
    public let kind: ReleaseV0140OMSLocalOrderStoreEventKind
    public let localOrderID: Identifier
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let sourceSubmitPathID: Identifier
    public let sourceSubmitResponseID: Identifier?
    public let sourceEvidenceID: Identifier
    public let fromState: OrderLifecycleState
    public let toState: OrderLifecycleState
    public let transition: OrderLifecycleTransition?
    public let orderIdentityRedacted: Bool
    public let replayable: Bool
    public let realAccountBalanceIncluded: Bool
    public let productionPositionOwnershipIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        eventID: Identifier,
        sequence: Int,
        kind: ReleaseV0140OMSLocalOrderStoreEventKind,
        localOrderID: Identifier,
        intentID: Identifier,
        strategyRunID: Identifier,
        productType: ProductType,
        symbol: Symbol,
        sourceSubmitPathID: Identifier,
        sourceSubmitResponseID: Identifier? = nil,
        sourceEvidenceID: Identifier,
        fromState: OrderLifecycleState,
        toState: OrderLifecycleState,
        transition: OrderLifecycleTransition?,
        orderIdentityRedacted: Bool = true,
        replayable: Bool = true,
        realAccountBalanceIncluded: Bool = false,
        productionPositionOwnershipIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.event.sequence",
                expected: "positive append-only sequence",
                actual: "\(sequence)"
            )
        }
        switch kind {
        case .appendOrder:
            guard transition == nil, fromState == toState else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OMSLocalOrderStore.appendEvent",
                    expected: "no transition and matching from/to state",
                    actual: "\(fromState.rawValue)->\(toState.rawValue)"
                )
            }
        case .lifecycleTransition:
            guard let transition,
                  transition.from == fromState,
                  transition.to == toState,
                  transition.boundaryHeld else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140OMSLocalOrderStore.transitionEvent",
                    expected: "boundary-held OrderLifecycleTransition matching from/to state",
                    actual: "\(fromState.rawValue)->\(toState.rawValue)"
                )
            }
        }
        guard orderIdentityRedacted, replayable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unredactedOrNonReplayableEvent")
        }
        try Self.forbid(realAccountBalanceIncluded, "realAccountBalanceIncluded")
        try Self.forbid(productionPositionOwnershipIncluded, "productionPositionOwnershipIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard eventID == Self.deterministicID(
            sequence: sequence,
            kind: kind,
            localOrderID: localOrderID,
            toState: toState,
            sourceEvidenceID: sourceEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.eventID",
                expected: Self.deterministicID(
                    sequence: sequence,
                    kind: kind,
                    localOrderID: localOrderID,
                    toState: toState,
                    sourceEvidenceID: sourceEvidenceID
                ).rawValue,
                actual: eventID.rawValue
            )
        }

        self.eventID = eventID
        self.sequence = sequence
        self.kind = kind
        self.localOrderID = localOrderID
        self.intentID = intentID
        self.strategyRunID = strategyRunID
        self.productType = productType
        self.symbol = symbol
        self.sourceSubmitPathID = sourceSubmitPathID
        self.sourceSubmitResponseID = sourceSubmitResponseID
        self.sourceEvidenceID = sourceEvidenceID
        self.fromState = fromState
        self.toState = toState
        self.transition = transition
        self.orderIdentityRedacted = orderIdentityRedacted
        self.replayable = replayable
        self.realAccountBalanceIncluded = realAccountBalanceIncluded
        self.productionPositionOwnershipIncluded = productionPositionOwnershipIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        orderIdentityRedacted
            && replayable
            && realAccountBalanceIncluded == false
            && productionPositionOwnershipIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && (kind == .appendOrder ? transition == nil && fromState == toState : transition?.boundaryHeld == true)
    }

    public static func append(
        sequence: Int,
        localOrder: ReleaseV0140LocalOMSOrderIdentity
    ) throws -> ReleaseV0140OMSLocalOrderStoreEvent {
        guard localOrder.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unheldLocalOrder")
        }
        let eventID = deterministicID(
            sequence: sequence,
            kind: .appendOrder,
            localOrderID: localOrder.localOrderID,
            toState: localOrder.lifecycleState,
            sourceEvidenceID: localOrder.sourceSubmitPathID
        )
        return try ReleaseV0140OMSLocalOrderStoreEvent(
            eventID: eventID,
            sequence: sequence,
            kind: .appendOrder,
            localOrderID: localOrder.localOrderID,
            intentID: localOrder.intentID,
            strategyRunID: localOrder.strategyRunID,
            productType: localOrder.productType,
            symbol: localOrder.symbol,
            sourceSubmitPathID: localOrder.sourceSubmitPathID,
            sourceSubmitResponseID: localOrder.sourceSubmitResponseID,
            sourceEvidenceID: localOrder.sourceSubmitPathID,
            fromState: localOrder.lifecycleState,
            toState: localOrder.lifecycleState,
            transition: nil
        )
    }

    public static func lifecycleTransition(
        sequence: Int,
        record: ReleaseV0140OMSLocalOrderRecord,
        transition: OrderLifecycleTransition,
        sourceEvidenceID: Identifier
    ) throws -> ReleaseV0140OMSLocalOrderStoreEvent {
        guard record.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unheldRecord")
        }
        guard transition.from == record.currentState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.transition.from",
                expected: record.currentState.rawValue,
                actual: transition.from.rawValue
            )
        }
        let eventID = deterministicID(
            sequence: sequence,
            kind: .lifecycleTransition,
            localOrderID: record.localOrderID,
            toState: transition.to,
            sourceEvidenceID: sourceEvidenceID
        )
        return try ReleaseV0140OMSLocalOrderStoreEvent(
            eventID: eventID,
            sequence: sequence,
            kind: .lifecycleTransition,
            localOrderID: record.localOrderID,
            intentID: record.intentID,
            strategyRunID: record.strategyRunID,
            productType: record.productType,
            symbol: record.symbol,
            sourceSubmitPathID: record.sourceSubmitPathID,
            sourceSubmitResponseID: record.sourceSubmitResponseID,
            sourceEvidenceID: sourceEvidenceID,
            fromState: transition.from,
            toState: transition.to,
            transition: transition
        )
    }

    public static func deterministicID(
        sequence: Int,
        kind: ReleaseV0140OMSLocalOrderStoreEventKind,
        localOrderID: Identifier,
        toState: OrderLifecycleState,
        sourceEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1031-oms-local-order-store-event:\(sequence):\(kind.rawValue):\(localOrderID.rawValue):\(toState.rawValue):\(sourceEvidenceID.rawValue)",
            field: "releaseV0140OMSLocalOrderStore.eventID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.event.\(field)")
        }
    }
}

/// ReleaseV0140OMSLocalOrderRecord 是本地 OMS order store 的当前订单快照。
///
/// record 只从 append-only event replay 得到；它保留 order identity 与 lifecycle evidence
/// 指针，不拥有真实账户余额、production position 或 broker fill。
public struct ReleaseV0140OMSLocalOrderRecord: Codable, Equatable, Sendable {
    public let localOrderID: Identifier
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let sourceSubmitPathID: Identifier
    public let sourceSubmitResponseID: Identifier?
    public let currentState: OrderLifecycleState
    public let eventIDs: [Identifier]
    public let orderIdentityRedacted: Bool
    public let replayable: Bool
    public let realAccountBalanceIncluded: Bool
    public let productionPositionOwnershipIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        appendEvent: ReleaseV0140OMSLocalOrderStoreEvent,
        sourceSubmitResponseID: Identifier? = nil,
        orderIdentityRedacted: Bool = true,
        replayable: Bool = true,
        realAccountBalanceIncluded: Bool = false,
        productionPositionOwnershipIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard appendEvent.boundaryHeld, appendEvent.kind == .appendOrder else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.invalidAppendEvent")
        }
        guard orderIdentityRedacted, replayable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unredactedOrNonReplayableRecord")
        }
        try Self.forbid(realAccountBalanceIncluded, "realAccountBalanceIncluded")
        try Self.forbid(productionPositionOwnershipIncluded, "productionPositionOwnershipIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.localOrderID = appendEvent.localOrderID
        self.intentID = appendEvent.intentID
        self.strategyRunID = appendEvent.strategyRunID
        self.productType = appendEvent.productType
        self.symbol = appendEvent.symbol
        self.sourceSubmitPathID = appendEvent.sourceSubmitPathID
        self.sourceSubmitResponseID = sourceSubmitResponseID ?? appendEvent.sourceSubmitResponseID
        self.currentState = appendEvent.toState
        self.eventIDs = [appendEvent.eventID]
        self.orderIdentityRedacted = orderIdentityRedacted
        self.replayable = replayable
        self.realAccountBalanceIncluded = realAccountBalanceIncluded
        self.productionPositionOwnershipIncluded = productionPositionOwnershipIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    private init(
        localOrderID: Identifier,
        intentID: Identifier,
        strategyRunID: Identifier,
        productType: ProductType,
        symbol: Symbol,
        sourceSubmitPathID: Identifier,
        sourceSubmitResponseID: Identifier?,
        currentState: OrderLifecycleState,
        eventIDs: [Identifier],
        orderIdentityRedacted: Bool,
        replayable: Bool,
        realAccountBalanceIncluded: Bool,
        productionPositionOwnershipIncluded: Bool,
        brokerFillIncluded: Bool,
        reconciliationIncluded: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretRead: Bool,
        productionEndpointConnected: Bool,
        productionCutoverAuthorized: Bool
    ) {
        self.localOrderID = localOrderID
        self.intentID = intentID
        self.strategyRunID = strategyRunID
        self.productType = productType
        self.symbol = symbol
        self.sourceSubmitPathID = sourceSubmitPathID
        self.sourceSubmitResponseID = sourceSubmitResponseID
        self.currentState = currentState
        self.eventIDs = eventIDs
        self.orderIdentityRedacted = orderIdentityRedacted
        self.replayable = replayable
        self.realAccountBalanceIncluded = realAccountBalanceIncluded
        self.productionPositionOwnershipIncluded = productionPositionOwnershipIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        orderIdentityRedacted
            && replayable
            && eventIDs.isEmpty == false
            && realAccountBalanceIncluded == false
            && productionPositionOwnershipIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public func applying(_ event: ReleaseV0140OMSLocalOrderStoreEvent) throws -> ReleaseV0140OMSLocalOrderRecord {
        guard boundaryHeld, event.boundaryHeld, event.kind == .lifecycleTransition else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.invalidTransitionEvent")
        }
        guard event.localOrderID == localOrderID,
              event.intentID == intentID,
              event.strategyRunID == strategyRunID,
              event.productType == productType,
              event.symbol == symbol,
              event.sourceSubmitPathID == sourceSubmitPathID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.recordIdentity",
                expected: localOrderID.rawValue,
                actual: event.localOrderID.rawValue
            )
        }
        guard event.fromState == currentState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.recordCurrentState",
                expected: currentState.rawValue,
                actual: event.fromState.rawValue
            )
        }
        return ReleaseV0140OMSLocalOrderRecord(
            localOrderID: localOrderID,
            intentID: intentID,
            strategyRunID: strategyRunID,
            productType: productType,
            symbol: symbol,
            sourceSubmitPathID: sourceSubmitPathID,
            sourceSubmitResponseID: sourceSubmitResponseID,
            currentState: event.toState,
            eventIDs: eventIDs + [event.eventID],
            orderIdentityRedacted: orderIdentityRedacted,
            replayable: replayable,
            realAccountBalanceIncluded: realAccountBalanceIncluded,
            productionPositionOwnershipIncluded: productionPositionOwnershipIncluded,
            brokerFillIncluded: brokerFillIncluded,
            reconciliationIncluded: reconciliationIncluded,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretRead: productionSecretRead,
            productionEndpointConnected: productionEndpointConnected,
            productionCutoverAuthorized: productionCutoverAuthorized
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.record.\(field)")
        }
    }
}

/// ReleaseV0140OMSLocalOrderStore 是 GH-1031 的本地 OMS order store 快照。
///
/// Store 是纯本地、可重放、append-only evidence container。append 和 update 都返回新快照；
/// 任何生产交易、真实账户余额、production position ownership、broker fill 或 reconciliation
/// 能力都会 fail closed。
public struct ReleaseV0140OMSLocalOrderStore: Codable, Equatable, Sendable {
    public let storeID: Identifier
    public let records: [ReleaseV0140OMSLocalOrderRecord]
    public let events: [ReleaseV0140OMSLocalOrderStoreEvent]
    public let nextSequence: Int
    public let testnetOrDryRunOnly: Bool
    public let appendOnly: Bool
    public let replayable: Bool
    public let realAccountBalanceIncluded: Bool
    public let productionPositionOwnershipIncluded: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        storeID: Identifier = Identifier.constant("gh-1031-oms-local-order-store"),
        records: [ReleaseV0140OMSLocalOrderRecord] = [],
        events: [ReleaseV0140OMSLocalOrderStoreEvent] = [],
        nextSequence: Int? = nil,
        testnetOrDryRunOnly: Bool = true,
        appendOnly: Bool = true,
        replayable: Bool = true,
        realAccountBalanceIncluded: Bool = false,
        productionPositionOwnershipIncluded: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard testnetOrDryRunOnly, appendOnly, replayable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.nonLocalReplayableStore")
        }
        try Self.forbid(realAccountBalanceIncluded, "realAccountBalanceIncluded")
        try Self.forbid(productionPositionOwnershipIncluded, "productionPositionOwnershipIncluded")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard records.allSatisfy(\.boundaryHeld), events.allSatisfy(\.boundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unheldRecordsOrEvents")
        }
        guard Set(records.map { $0.localOrderID.rawValue }).count == records.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.records",
                expected: "unique localOrderID records",
                actual: "duplicate localOrderID"
            )
        }
        guard Set(events.map { $0.eventID.rawValue }).count == events.count else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.events",
                expected: "unique eventID sequence",
                actual: "duplicate eventID"
            )
        }
        let expectedSequences = Self.expectedSequences(count: events.count)
        guard events.map(\.sequence) == expectedSequences || events.isEmpty else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.eventSequence",
                expected: expectedSequences.map(String.init).joined(separator: ","),
                actual: events.map { String($0.sequence) }.joined(separator: ",")
            )
        }

        self.storeID = storeID
        self.records = records
        self.events = events
        self.nextSequence = nextSequence ?? (events.count + 1)
        self.testnetOrDryRunOnly = testnetOrDryRunOnly
        self.appendOnly = appendOnly
        self.replayable = replayable
        self.realAccountBalanceIncluded = realAccountBalanceIncluded
        self.productionPositionOwnershipIncluded = productionPositionOwnershipIncluded
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        testnetOrDryRunOnly
            && appendOnly
            && replayable
            && records.allSatisfy(\.boundaryHeld)
            && events.allSatisfy(\.boundaryHeld)
            && events.map(\.sequence) == Self.expectedSequences(count: events.count)
            && nextSequence == events.count + 1
            && realAccountBalanceIncluded == false
            && productionPositionOwnershipIncluded == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public func record(for localOrderID: Identifier) -> ReleaseV0140OMSLocalOrderRecord? {
        records.first { $0.localOrderID == localOrderID }
    }

    public func append(localOrder: ReleaseV0140LocalOMSOrderIdentity) throws -> ReleaseV0140OMSLocalOrderStore {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unheldStore")
        }
        guard record(for: localOrder.localOrderID) == nil else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.append",
                expected: "new localOrderID",
                actual: localOrder.localOrderID.rawValue
            )
        }
        let event = try ReleaseV0140OMSLocalOrderStoreEvent.append(
            sequence: nextSequence,
            localOrder: localOrder
        )
        let record = try ReleaseV0140OMSLocalOrderRecord(
            appendEvent: event,
            sourceSubmitResponseID: localOrder.sourceSubmitResponseID
        )
        return try ReleaseV0140OMSLocalOrderStore(
            storeID: storeID,
            records: records + [record],
            events: events + [event],
            testnetOrDryRunOnly: testnetOrDryRunOnly,
            appendOnly: appendOnly,
            replayable: replayable,
            validationAnchors: validationAnchors
        )
    }

    public func update(
        localOrderID: Identifier,
        to targetState: OrderLifecycleState,
        reason: String,
        sourceEvidenceID: Identifier,
        stateMachine: OrderLifecycleStateMachine? = nil
    ) throws -> ReleaseV0140OMSLocalOrderStore {
        let resolvedStateMachine: OrderLifecycleStateMachine
        if let stateMachine {
            resolvedStateMachine = stateMachine
        } else {
            resolvedStateMachine = try OrderLifecycleStateMachine()
        }
        guard boundaryHeld, resolvedStateMachine.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.unheldUpdateBoundary")
        }
        guard let index = records.firstIndex(where: { $0.localOrderID == localOrderID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.update",
                expected: "existing localOrderID",
                actual: localOrderID.rawValue
            )
        }
        let record = records[index]
        let transition = try resolvedStateMachine.transition(
            from: record.currentState,
            to: targetState,
            reason: reason
        )
        let event = try ReleaseV0140OMSLocalOrderStoreEvent.lifecycleTransition(
            sequence: nextSequence,
            record: record,
            transition: transition,
            sourceEvidenceID: sourceEvidenceID
        )
        let updatedRecord = try record.applying(event)
        var updatedRecords = records
        updatedRecords[index] = updatedRecord
        return try ReleaseV0140OMSLocalOrderStore(
            storeID: storeID,
            records: updatedRecords,
            events: events + [event],
            testnetOrDryRunOnly: testnetOrDryRunOnly,
            appendOnly: appendOnly,
            replayable: replayable,
            validationAnchors: validationAnchors
        )
    }

    public static func replay(
        storeID: Identifier = Identifier.constant("gh-1031-oms-local-order-store"),
        events: [ReleaseV0140OMSLocalOrderStoreEvent]
    ) throws -> ReleaseV0140OMSLocalOrderStore {
        let sortedEvents = events.sorted { $0.sequence < $1.sequence }
        guard sortedEvents.map(\.eventID) == events.map(\.eventID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140OMSLocalOrderStore.replayOrder",
                expected: "events already sorted by append-only sequence",
                actual: "out-of-order events"
            )
        }
        var records: [ReleaseV0140OMSLocalOrderRecord] = []
        for event in sortedEvents {
            switch event.kind {
            case .appendOrder:
                guard records.contains(where: { $0.localOrderID == event.localOrderID }) == false else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV0140OMSLocalOrderStore.replay.append",
                        expected: "single append event per local order",
                        actual: event.localOrderID.rawValue
                    )
                }
                records.append(try ReleaseV0140OMSLocalOrderRecord(appendEvent: event))
            case .lifecycleTransition:
                guard let index = records.firstIndex(where: { $0.localOrderID == event.localOrderID }) else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV0140OMSLocalOrderStore.replay.transition",
                        expected: "existing local order before transition",
                        actual: event.localOrderID.rawValue
                    )
                }
                records[index] = try records[index].applying(event)
            }
        }
        return try ReleaseV0140OMSLocalOrderStore(
            storeID: storeID,
            records: records,
            events: sortedEvents
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1031-OMS-LOCAL-ORDER-STORE",
        "GH-1031-OMS-APPEND-UPDATE-REPLAY",
        "GH-1031-OMS-NO-REAL-ACCOUNT-OR-PRODUCTION-POSITION",
        "TVM-RELEASE-V0140-OMS-LOCAL-ORDER-STORE"
    ]

    private static func expectedSequences(count: Int) -> [Int] {
        count == 0 ? [] : Array(1...count)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140OMSLocalOrderStore.\(field)")
        }
    }
}
