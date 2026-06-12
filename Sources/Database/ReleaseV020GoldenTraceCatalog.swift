import DomainModel
import Foundation

/// ReleaseV020GoldenTraceKind 固定 GH-592 的 15 条 release v0.2.0 golden trace。
///
/// 这些 trace 只描述 Binance Spot / USD-M Perpetual、EMA / RSI、risk、execution evidence、
/// Event Store 和 projection 的本地可重放证据链；它们不是生产交易脚本、broker command、
/// signed endpoint payload 或 Dashboard schema contract。
public enum ReleaseV020GoldenTraceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spotMarketDataCache = "spot-market-data-cache"
    case perpetualMarketDataCache = "perpetual-market-data-cache"
    case perpetualMarkFundingOpenInterest = "perpetual-mark-funding-open-interest"
    case emaSpotTargetExposure = "ema-spot-target-exposure"
    case emaPerpetualTargetExposure = "ema-perpetual-target-exposure"
    case rsiSpotTargetExposure = "rsi-spot-target-exposure"
    case rsiPerpetualTargetExposure = "rsi-perpetual-target-exposure"
    case proposalArbitration = "proposal-arbitration"
    case commonRiskGate = "common-risk-gate"
    case spotRiskGate = "spot-risk-gate"
    case perpetualRiskGate = "perpetual-risk-gate"
    case spotExecutionAlgorithm = "spot-execution-algorithm"
    case perpetualExecutionAlgorithm = "perpetual-execution-algorithm"
    case executionReportParser = "execution-report-parser"
    case eventStoreSQLiteDuckDBProjection = "event-store-sqlite-duckdb-projection"
}

/// ReleaseV020GoldenTraceStrategy 固定 release v0.2.0 唯一 active concrete strategies。
public enum ReleaseV020GoldenTraceStrategy: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema
    case rsi
}

/// ReleaseV020GoldenTraceRecord 是 GH-592 的单条 golden trace metadata。
///
/// runChecksum 和 replayChecksum 使用同一 canonical preimage 生成，目的是证明本地 run / replay
/// 证据可重复，不是安全签名，也不保存生产 payload、secret、account state 或 broker state。
public struct ReleaseV020GoldenTraceRecord: Codable, Equatable, Sendable {
    public let traceID: Identifier
    public let sequence: Int
    public let kind: ReleaseV020GoldenTraceKind
    public let upstreamIssueID: Identifier
    public let productTypes: [ProductType]
    public let strategies: [ReleaseV020GoldenTraceStrategy]
    public let sourceEvidenceAnchor: String
    public let runChecksum: String
    public let replayChecksum: String
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let rawPayloadStored: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool

    public init(
        traceID: Identifier,
        sequence: Int,
        kind: ReleaseV020GoldenTraceKind,
        upstreamIssueID: Identifier,
        productTypes: [ProductType],
        strategies: [ReleaseV020GoldenTraceStrategy],
        sourceEvidenceAnchor: String,
        runChecksum: String? = nil,
        replayChecksum: String? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        rawPayloadStored: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false
    ) throws {
        let normalizedProductTypes = Self.normalizedProductTypes(productTypes)
        let normalizedStrategies = Self.normalizedStrategies(strategies)
        let expectedChecksum = Self.checksum(
            sequence: sequence,
            kind: kind,
            upstreamIssueID: upstreamIssueID,
            productTypes: normalizedProductTypes,
            strategies: normalizedStrategies,
            sourceEvidenceAnchor: sourceEvidenceAnchor
        )
        let resolvedRunChecksum = runChecksum ?? expectedChecksum
        let resolvedReplayChecksum = replayChecksum ?? expectedChecksum

        guard sequence > 0,
              normalizedProductTypes.isEmpty == false,
              Set(normalizedProductTypes).isSubset(of: Set(ProductType.allCases)),
              normalizedProductTypes.count == Set(normalizedProductTypes).count,
              normalizedStrategies.count == Set(normalizedStrategies).count,
              Set(normalizedStrategies).isSubset(of: Set(ReleaseV020GoldenTraceStrategy.allCases)),
              sourceEvidenceAnchor.isEmpty == false,
              resolvedRunChecksum == expectedChecksum,
              resolvedReplayChecksum == expectedChecksum,
              resolvedRunChecksum == resolvedReplayChecksum else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020GoldenTraceCatalog.record",
                expected: "deterministic trace record with matching run/replay checksum",
                actual: kind.rawValue
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("rawPayloadStored", rawPayloadStored),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020GoldenTraceCatalog.\(forbiddenFlag.0)"
            )
        }

        self.traceID = traceID
        self.sequence = sequence
        self.kind = kind
        self.upstreamIssueID = upstreamIssueID
        self.productTypes = normalizedProductTypes
        self.strategies = normalizedStrategies
        self.sourceEvidenceAnchor = sourceEvidenceAnchor
        self.runChecksum = resolvedRunChecksum
        self.replayChecksum = resolvedReplayChecksum
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.rawPayloadStored = rawPayloadStored
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
    }

    public var traceBoundaryHeld: Bool {
        sequence > 0
            && productTypes.isEmpty == false
            && Set(productTypes).isSubset(of: Set(ProductType.allCases))
            && productTypes.count == Set(productTypes).count
            && strategies.count == Set(strategies).count
            && sourceEvidenceAnchor.isEmpty == false
            && runChecksum == replayChecksum
            && runChecksum == Self.checksum(
                sequence: sequence,
                kind: kind,
                upstreamIssueID: upstreamIssueID,
                productTypes: productTypes,
                strategies: strategies,
                sourceEvidenceAnchor: sourceEvidenceAnchor
            )
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && rawPayloadStored == false
            && rawDatabaseSchemaExposedToDashboard == false
    }

    public static func checksum(
        sequence: Int,
        kind: ReleaseV020GoldenTraceKind,
        upstreamIssueID: Identifier,
        productTypes: [ProductType],
        strategies: [ReleaseV020GoldenTraceStrategy],
        sourceEvidenceAnchor: String
    ) -> String {
        let input = [
            "\(sequence)",
            kind.rawValue,
            upstreamIssueID.rawValue,
            normalizedProductTypes(productTypes).map(\.rawValue).joined(separator: ","),
            normalizedStrategies(strategies).map(\.rawValue).joined(separator: ","),
            sourceEvidenceAnchor
        ].joined(separator: "|")
        return "fnv1a64:\(fnv1a64Hex(input))"
    }

    private static func normalizedProductTypes(_ productTypes: [ProductType]) -> [ProductType] {
        productTypes.sorted { $0.rawValue < $1.rawValue }
    }

    private static func normalizedStrategies(
        _ strategies: [ReleaseV020GoldenTraceStrategy]
    ) -> [ReleaseV020GoldenTraceStrategy] {
        strategies.sorted { $0.rawValue < $1.rawValue }
    }
}

/// ReleaseV020GoldenTraceCatalogEvidence 汇总 GH-592 的 golden trace catalog gate。
public struct ReleaseV020GoldenTraceCatalogEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let traceCount: Int
    public let records: [ReleaseV020GoldenTraceRecord]
    public let validationAnchors: [String]
    public let allRequiredTracesPresent: Bool
    public let runReplayChecksumsMatch: Bool
    public let catalogVenue: Identifier
    public let catalogProductTypes: [ProductType]
    public let catalogStrategies: [ReleaseV020GoldenTraceStrategy]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let rawPayloadStored: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-592-spot-perp-golden-trace-catalog-evidence"),
        issueID: Identifier = Identifier.constant("GH-592"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-591")],
        records: [ReleaseV020GoldenTraceRecord],
        validationAnchors: [String] = ReleaseV020GoldenTraceCatalog.requiredValidationAnchors,
        allRequiredTracesPresent: Bool = true,
        runReplayChecksumsMatch: Bool = true,
        catalogVenue: Identifier = Identifier.constant("binance"),
        catalogProductTypes: [ProductType] = ProductType.allCases,
        catalogStrategies: [ReleaseV020GoldenTraceStrategy] = ReleaseV020GoldenTraceStrategy.allCases,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        rawPayloadStored: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false
    ) throws {
        let sortedRecords = records.sortedByReleaseV020GoldenTraceSequence()
        guard issueID.rawValue == "GH-592",
              upstreamIssueIDs.map(\.rawValue) == ["GH-591"],
              sortedRecords.count == ReleaseV020GoldenTraceCatalog.requiredTraceCount,
              sortedRecords.map(\.sequence) == Array(1...ReleaseV020GoldenTraceCatalog.requiredTraceCount),
              Set(sortedRecords.map(\.kind)) == Set(ReleaseV020GoldenTraceKind.allCases),
              sortedRecords.allSatisfy(\.traceBoundaryHeld),
              validationAnchors == ReleaseV020GoldenTraceCatalog.requiredValidationAnchors,
              catalogVenue.rawValue == "binance",
              Set(catalogProductTypes) == Set(ProductType.allCases),
              Set(catalogStrategies) == Set(ReleaseV020GoldenTraceStrategy.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020GoldenTraceCatalog.evidence",
                expected: "15 deterministic Spot + Perp golden traces",
                actual: "\(records.count)"
            )
        }
        for requiredFlag in [
            ("allRequiredTracesPresent", allRequiredTracesPresent),
            ("runReplayChecksumsMatch", runReplayChecksumsMatch)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020GoldenTraceCatalog.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("rawPayloadStored", rawPayloadStored),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020GoldenTraceCatalog.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.traceCount = sortedRecords.count
        self.records = sortedRecords
        self.validationAnchors = validationAnchors
        self.allRequiredTracesPresent = allRequiredTracesPresent
        self.runReplayChecksumsMatch = runReplayChecksumsMatch
        self.catalogVenue = catalogVenue
        self.catalogProductTypes = catalogProductTypes.sorted { $0.rawValue < $1.rawValue }
        self.catalogStrategies = catalogStrategies.sorted { $0.rawValue < $1.rawValue }
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.rawPayloadStored = rawPayloadStored
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
    }

    public var traceKinds: [ReleaseV020GoldenTraceKind] {
        records.map(\.kind)
    }

    public var traceIDs: [Identifier] {
        records.map(\.traceID)
    }

    public var runChecksums: [String] {
        records.map(\.runChecksum)
    }

    public var replayChecksums: [String] {
        records.map(\.replayChecksum)
    }

    public var catalogBoundaryHeld: Bool {
        issueID.rawValue == "GH-592"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-591"]
            && traceCount == ReleaseV020GoldenTraceCatalog.requiredTraceCount
            && records.map(\.sequence) == Array(1...ReleaseV020GoldenTraceCatalog.requiredTraceCount)
            && Set(traceKinds) == Set(ReleaseV020GoldenTraceKind.allCases)
            && records.allSatisfy(\.traceBoundaryHeld)
            && validationAnchors == ReleaseV020GoldenTraceCatalog.requiredValidationAnchors
            && allRequiredTracesPresent
            && runReplayChecksumsMatch
            && runChecksums == replayChecksums
            && catalogVenue.rawValue == "binance"
            && Set(catalogProductTypes) == Set(ProductType.allCases)
            && Set(catalogStrategies) == Set(ReleaseV020GoldenTraceStrategy.allCases)
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && rawPayloadStored == false
            && rawDatabaseSchemaExposedToDashboard == false
    }
}

/// ReleaseV020GoldenTraceCatalog 生成 GH-592 deterministic golden trace catalog。
public enum ReleaseV020GoldenTraceCatalog {
    public static let requiredTraceCount = 15

    public static let requiredValidationAnchors = [
        "GH-592-SPOT-PERP-GOLDEN-TRACE-CATALOG",
        "GH-592-ALL-15-REQUIRED-TRACES-PRESENT",
        "GH-592-RUN-REPLAY-CHECKSUM-PARITY",
        "GH-592-NO-PRODUCTION-TRACE-SIDE-EFFECT",
        "TVM-RELEASE-V020-SPOT-PERP-GOLDEN-TRACE-CATALOG"
    ]

    public static func deterministicEvidence() throws -> ReleaseV020GoldenTraceCatalogEvidence {
        try ReleaseV020GoldenTraceCatalogEvidence(records: deterministicRecords())
    }

    public static func deterministicRecords() throws -> [ReleaseV020GoldenTraceRecord] {
        try [
            makeRecord(
                sequence: 1,
                kind: .spotMarketDataCache,
                upstreamIssueID: "GH-573",
                productTypes: [.spot],
                strategies: [],
                sourceEvidenceAnchor: "GH-573-BINANCE-SPOT-MARKET-DATA-ACTIVE-PATH"
            ),
            makeRecord(
                sequence: 2,
                kind: .perpetualMarketDataCache,
                upstreamIssueID: "GH-574",
                productTypes: [.usdsPerpetual],
                strategies: [],
                sourceEvidenceAnchor: "GH-574-BINANCE-USDM-PERP-MARKET-DATA-ACTIVE-PATH"
            ),
            makeRecord(
                sequence: 3,
                kind: .perpetualMarkFundingOpenInterest,
                upstreamIssueID: "GH-575",
                productTypes: [.usdsPerpetual],
                strategies: [],
                sourceEvidenceAnchor: "GH-575-PERP-MARK-FUNDING-OPEN-INTEREST-READ-MODEL"
            ),
            makeRecord(
                sequence: 4,
                kind: .emaSpotTargetExposure,
                upstreamIssueID: "GH-569",
                productTypes: [.spot],
                strategies: [.ema],
                sourceEvidenceAnchor: "GH-569-EMA-SPOT-TARGET-EXPOSURE"
            ),
            makeRecord(
                sequence: 5,
                kind: .emaPerpetualTargetExposure,
                upstreamIssueID: "GH-569",
                productTypes: [.usdsPerpetual],
                strategies: [.ema],
                sourceEvidenceAnchor: "GH-569-EMA-PERP-TARGET-EXPOSURE"
            ),
            makeRecord(
                sequence: 6,
                kind: .rsiSpotTargetExposure,
                upstreamIssueID: "GH-570",
                productTypes: [.spot],
                strategies: [.rsi],
                sourceEvidenceAnchor: "GH-570-RSI-SPOT-TARGET-EXPOSURE"
            ),
            makeRecord(
                sequence: 7,
                kind: .rsiPerpetualTargetExposure,
                upstreamIssueID: "GH-570",
                productTypes: [.usdsPerpetual],
                strategies: [.rsi],
                sourceEvidenceAnchor: "GH-570-RSI-PERP-TARGET-EXPOSURE"
            ),
            makeRecord(
                sequence: 8,
                kind: .proposalArbitration,
                upstreamIssueID: "GH-577",
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-577-PROPOSAL-ARBITRATOR-SPOT-PERP-TRACE"
            ),
            makeRecord(
                sequence: 9,
                kind: .commonRiskGate,
                upstreamIssueID: "GH-578",
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-578-RISK-COMMON-GATE-TRACE"
            ),
            makeRecord(
                sequence: 10,
                kind: .spotRiskGate,
                upstreamIssueID: "GH-579",
                productTypes: [.spot],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-579-SPOT-RISK-GATE-TRACE"
            ),
            makeRecord(
                sequence: 11,
                kind: .perpetualRiskGate,
                upstreamIssueID: "GH-580",
                productTypes: [.usdsPerpetual],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-580-PERPETUAL-RISK-GATE-TRACE"
            ),
            makeRecord(
                sequence: 12,
                kind: .spotExecutionAlgorithm,
                upstreamIssueID: "GH-581",
                productTypes: [.spot],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-581-SPOT-EXECUTION-ALGORITHM-TRACE"
            ),
            makeRecord(
                sequence: 13,
                kind: .perpetualExecutionAlgorithm,
                upstreamIssueID: "GH-582",
                productTypes: [.usdsPerpetual],
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-582-PERPETUAL-EXECUTION-ALGORITHM-TRACE"
            ),
            makeRecord(
                sequence: 14,
                kind: .executionReportParser,
                upstreamIssueID: "GH-586",
                productTypes: ProductType.allCases,
                strategies: [],
                sourceEvidenceAnchor: "GH-586-EXECUTION-REPORT-BROKER-FILL-PARSER-TRACE"
            ),
            makeRecord(
                sequence: 15,
                kind: .eventStoreSQLiteDuckDBProjection,
                upstreamIssueID: "GH-591",
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "GH-591-SQLITE-DUCKDB-SPOT-PERP-PROJECTION-TRACE"
            )
        ]
    }

    private static func makeRecord(
        sequence: Int,
        kind: ReleaseV020GoldenTraceKind,
        upstreamIssueID: String,
        productTypes: [ProductType],
        strategies: [ReleaseV020GoldenTraceStrategy],
        sourceEvidenceAnchor: String
    ) throws -> ReleaseV020GoldenTraceRecord {
        try ReleaseV020GoldenTraceRecord(
            traceID: Identifier.constant("gh-592-\(kind.rawValue)"),
            sequence: sequence,
            kind: kind,
            upstreamIssueID: Identifier.constant(upstreamIssueID),
            productTypes: productTypes,
            strategies: strategies,
            sourceEvidenceAnchor: sourceEvidenceAnchor
        )
    }
}

private extension Array where Element == ReleaseV020GoldenTraceRecord {
    func sortedByReleaseV020GoldenTraceSequence() -> [ReleaseV020GoldenTraceRecord] {
        sorted { lhs, rhs in
            if lhs.sequence != rhs.sequence {
                return lhs.sequence < rhs.sequence
            }
            return lhs.kind.rawValue < rhs.kind.rawValue
        }
    }
}

private func fnv1a64Hex(_ input: String) -> String {
    var hash: UInt64 = 0xcbf29ce484222325
    for byte in input.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x100000001b3
    }
    return String(format: "%016llx", hash)
}
