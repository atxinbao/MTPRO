import DomainModel
import Foundation
import MessageBus

/// ReleaseV020ProductAwareEventStoreRecord 是 GH-590 的 append-only schema 单条记录。
///
/// 每条 record 都必须显式保存 venue、productType 和 instrumentID；这些字段来自
/// `InstrumentIdentity`，因此 Spot BTCUSDT 与 USDⓈ-M Perpetual BTCUSDT 不会在 Event Store
/// schema 中碰撞。checksum 是 deterministic 本地校验，不是安全签名，也不用于授权交易。
public struct ReleaseV020ProductAwareEventStoreRecord: Codable, Equatable, Sendable {
    public let sequence: Int
    public let stream: MessageBusJournalStreamID
    public let sourceID: FoundationTargetID
    public let payloadType: String
    public let venue: Identifier
    public let productType: ProductType
    public let instrumentID: InstrumentIdentity
    public let previousChecksum: String
    public let checksum: String
    public let recordedAt: Date

    public init(
        sequence: Int,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        instrumentID: InstrumentIdentity,
        previousChecksum: String,
        checksum: String? = nil,
        recordedAt: Date
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        let normalizedPayloadType = try FoundationTargetID(
            payloadType,
            field: "releaseV020ProductAwareEventStore.payloadType"
        ).rawValue
        let resolvedChecksum = checksum ?? Self.stableChecksum(
            sequence: sequence,
            stream: stream,
            sourceID: sourceID,
            payloadType: normalizedPayloadType,
            instrumentID: instrumentID,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        )
        guard resolvedChecksum == Self.stableChecksum(
            sequence: sequence,
            stream: stream,
            sourceID: sourceID,
            payloadType: normalizedPayloadType,
            instrumentID: instrumentID,
            previousChecksum: previousChecksum,
            recordedAt: recordedAt
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.checksum",
                expected: "stable deterministic checksum",
                actual: resolvedChecksum
            )
        }

        self.sequence = sequence
        self.stream = stream
        self.sourceID = sourceID
        self.payloadType = normalizedPayloadType
        self.venue = instrumentID.venue
        self.productType = instrumentID.productType
        self.instrumentID = instrumentID
        self.previousChecksum = previousChecksum
        self.checksum = resolvedChecksum
        self.recordedAt = recordedAt
    }

    public var recordBoundaryHeld: Bool {
        sequence > 0
            && venue == instrumentID.venue
            && productType == instrumentID.productType
            && ProductType.allCases.contains(productType)
            && checksum == Self.stableChecksum(
                sequence: sequence,
                stream: stream,
                sourceID: sourceID,
                payloadType: payloadType,
                instrumentID: instrumentID,
                previousChecksum: previousChecksum,
                recordedAt: recordedAt
            )
    }

    public static func stableChecksum(
        sequence: Int,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        instrumentID: InstrumentIdentity,
        previousChecksum: String,
        recordedAt: Date
    ) -> String {
        let input = [
            "\(sequence)",
            stream.rawValue,
            sourceID.rawValue,
            payloadType,
            instrumentID.venue.rawValue,
            instrumentID.productType.rawValue,
            instrumentID.rawValue,
            previousChecksum,
            String(format: "%.6f", recordedAt.timeIntervalSince1970)
        ].joined(separator: "|")
        return fnv1a64Hex(input)
    }

    private static func fnv1a64Hex(_ input: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }
}

/// ReleaseV020ProductAwareEventStoreSchema 证明 GH-590 的 append-only schema gate。
///
/// Schema 只消费 product-aware `MessageBusJournalEnvelope`，拒绝缺失 instrumentID 或
/// sequence 越序的 append。它不保存 raw payload、不暴露 SQLite table，也不执行 broker /
/// account / live command side effect。
public struct ReleaseV020ProductAwareEventStoreSchema: Codable, Equatable, Sendable {
    public static let genesisChecksum = "GH-590-GENESIS"

    public private(set) var records: [ReleaseV020ProductAwareEventStoreRecord]

    public init(records: [ReleaseV020ProductAwareEventStoreRecord] = []) throws {
        for (index, record) in records.enumerated() {
            let expectedSequence = index + 1
            let expectedPreviousChecksum = index == 0
                ? Self.genesisChecksum
                : records[index - 1].checksum
            guard record.sequence == expectedSequence,
                  record.previousChecksum == expectedPreviousChecksum,
                  record.recordBoundaryHeld else {
                throw CoreError.invalidSequenceRange
            }
        }
        self.records = records
    }

    @discardableResult
    public mutating func append(
        sourceEnvelope: MessageBusJournalEnvelope
    ) throws -> ReleaseV020ProductAwareEventStoreRecord {
        let expectedSequence = records.count + 1
        guard sourceEnvelope.sequence == expectedSequence else {
            throw CoreError.invalidSequenceRange
        }
        guard let instrumentID = sourceEnvelope.instrumentID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.instrumentID",
                expected: "venue/productType/instrumentID present",
                actual: "nil"
            )
        }
        let previousChecksum = records.last?.checksum ?? Self.genesisChecksum
        let record = try ReleaseV020ProductAwareEventStoreRecord(
            sequence: sourceEnvelope.sequence,
            stream: sourceEnvelope.stream,
            sourceID: sourceEnvelope.sourceID,
            payloadType: sourceEnvelope.payloadType,
            instrumentID: instrumentID,
            previousChecksum: previousChecksum,
            recordedAt: sourceEnvelope.recordedAt
        )
        records.append(record)
        return record
    }

    public var schemaBoundaryHeld: Bool {
        records.isEmpty == false
            && records.allSatisfy(\.recordBoundaryHeld)
            && records.enumerated().allSatisfy { index, record in
                let expectedPreviousChecksum = index == 0
                    ? Self.genesisChecksum
                    : records[index - 1].checksum
                return record.sequence == index + 1
                    && record.previousChecksum == expectedPreviousChecksum
            }
    }

    public var stableChecksum: String {
        records.last?.checksum ?? Self.genesisChecksum
    }

    public var storedProductTypes: Set<ProductType> {
        Set(records.map(\.productType))
    }

    public var storedInstrumentIDs: [InstrumentIdentity] {
        records.map(\.instrumentID)
    }

    public var recomputedStableChecksum: String {
        (try? Self(records: records).stableChecksum) ?? "invalid"
    }
}

/// ReleaseV020ProductAwareEventStoreSchemaEvidence 汇总 GH-590 release evidence。
/// `TVM-RELEASE-V020-PRODUCT-AWARE-EVENT-STORE-SCHEMA`
public struct ReleaseV020ProductAwareEventStoreSchemaEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let schemaColumns: [String]
    public let records: [ReleaseV020ProductAwareEventStoreRecord]
    public let validationAnchors: [String]
    public let venueProductInstrumentStoredForEveryEvent: Bool
    public let outOfOrderAppendRejected: Bool
    public let checksumStable: Bool
    public let appendOnlySchema: Bool
    public let productionTradingEnabledByDefault: Bool
    public let rawPayloadStored: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-590-product-aware-event-store-schema-evidence"),
        issueID: Identifier = Identifier.constant("GH-590"),
        schemaColumns: [String],
        records: [ReleaseV020ProductAwareEventStoreRecord],
        validationAnchors: [String] = ReleaseV020ProductAwareEventStore.requiredValidationAnchors,
        venueProductInstrumentStoredForEveryEvent: Bool = true,
        outOfOrderAppendRejected: Bool,
        checksumStable: Bool,
        appendOnlySchema: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        rawPayloadStored: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-590" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.issueID",
                expected: "GH-590",
                actual: issueID.rawValue
            )
        }
        guard schemaColumns == ReleaseV020ProductAwareEventStore.requiredSchemaColumns else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.schemaColumns",
                expected: ReleaseV020ProductAwareEventStore.requiredSchemaColumns.joined(separator: ","),
                actual: schemaColumns.joined(separator: ",")
            )
        }
        guard records.isEmpty == false,
              records.allSatisfy(\.recordBoundaryHeld),
              Set(records.map(\.productType)) == Set(ProductType.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.records",
                expected: "product-aware Spot and Perp records",
                actual: "\(records.count)"
            )
        }
        guard validationAnchors == ReleaseV020ProductAwareEventStore.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.validationAnchors",
                expected: ReleaseV020ProductAwareEventStore.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("venueProductInstrumentStoredForEveryEvent", venueProductInstrumentStoredForEveryEvent),
            ("outOfOrderAppendRejected", outOfOrderAppendRejected),
            ("checksumStable", checksumStable),
            ("appendOnlySchema", appendOnlySchema)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ProductAwareEventStore.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("rawPayloadStored", rawPayloadStored),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ProductAwareEventStore.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.schemaColumns = schemaColumns
        self.records = records
        self.validationAnchors = validationAnchors
        self.venueProductInstrumentStoredForEveryEvent = venueProductInstrumentStoredForEveryEvent
        self.outOfOrderAppendRejected = outOfOrderAppendRejected
        self.checksumStable = checksumStable
        self.appendOnlySchema = appendOnlySchema
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.rawPayloadStored = rawPayloadStored
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-590"
            && schemaColumns == ReleaseV020ProductAwareEventStore.requiredSchemaColumns
            && records.isEmpty == false
            && records.allSatisfy(\.recordBoundaryHeld)
            && Set(records.map(\.productType)) == Set(ProductType.allCases)
            && validationAnchors == ReleaseV020ProductAwareEventStore.requiredValidationAnchors
            && venueProductInstrumentStoredForEveryEvent
            && outOfOrderAppendRejected
            && checksumStable
            && appendOnlySchema
            && productionTradingEnabledByDefault == false
            && rawPayloadStored == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020ProductAwareEventStore 生成 GH-590 deterministic schema evidence。
public enum ReleaseV020ProductAwareEventStore {
    public static let requiredSchemaColumns = [
        "sequence",
        "stream",
        "venue",
        "productType",
        "instrumentID",
        "payloadType",
        "previousChecksum",
        "checksum",
        "recordedAt"
    ]

    public static let requiredValidationAnchors = [
        "GH-590-PRODUCT-AWARE-EVENT-STORE-SCHEMA",
        "GH-590-EVENT-CONTEXT-VENUE-PRODUCT-INSTRUMENT",
        "GH-590-OUT-OF-ORDER-APPEND-REJECTED",
        "GH-590-STABLE-CHECKSUM",
        "GH-590-NO-PRODUCTION-EVENT-STORE-SIDE-EFFECT",
        "TVM-RELEASE-V020-PRODUCT-AWARE-EVENT-STORE-SCHEMA"
    ]

    public static func deterministicEvidence() throws -> ReleaseV020ProductAwareEventStoreSchemaEvidence {
        var schema = try ReleaseV020ProductAwareEventStoreSchema()
        for envelope in try deterministicSourceEnvelopes() {
            try schema.append(sourceEnvelope: envelope)
        }
        return try ReleaseV020ProductAwareEventStoreSchemaEvidence(
            schemaColumns: requiredSchemaColumns,
            records: schema.records,
            outOfOrderAppendRejected: outOfOrderAppendRejected(),
            checksumStable: schema.stableChecksum == schema.recomputedStableChecksum
        )
    }

    public static func deterministicSourceEnvelopes() throws -> [MessageBusJournalEnvelope] {
        let stream = try MessageBusJournalStreamID("release-v020-event-store")
        let source = try FoundationTargetID("gh-590", field: "releaseV020ProductAwareEventStore.sourceID")
        let btc = Symbol.constant("BTCUSDT")
        let recordedAt = Date(timeIntervalSince1970: 1_801_353_600)
        return try [
            MessageBusJournalEnvelope(
                sequence: 1,
                stream: stream,
                sourceID: source,
                payloadType: "gh-590-spot-portfolio-event",
                instrumentID: .binance(productType: .spot, symbol: btc),
                recordedAt: recordedAt
            ),
            MessageBusJournalEnvelope(
                sequence: 2,
                stream: stream,
                sourceID: source,
                payloadType: "gh-590-perpetual-portfolio-event",
                instrumentID: .binance(productType: .usdsPerpetual, symbol: btc),
                recordedAt: recordedAt.addingTimeInterval(1)
            )
        ]
    }

    public static func outOfOrderAppendRejected() throws -> Bool {
        var schema = try ReleaseV020ProductAwareEventStoreSchema()
        let stream = try MessageBusJournalStreamID("release-v020-event-store")
        let source = try FoundationTargetID("gh-590", field: "releaseV020ProductAwareEventStore.sourceID")
        let envelope = try MessageBusJournalEnvelope(
            sequence: 2,
            stream: stream,
            sourceID: source,
            payloadType: "gh-590-out-of-order-event",
            instrumentID: .binance(productType: .spot, symbol: Symbol.constant("BTCUSDT")),
            recordedAt: Date(timeIntervalSince1970: 1_801_353_600)
        )
        do {
            try schema.append(sourceEnvelope: envelope)
            return false
        } catch CoreError.invalidSequenceRange {
            return true
        } catch {
            throw error
        }
    }
}
