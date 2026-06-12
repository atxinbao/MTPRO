import Core
import Database
import Foundation

/// ReleaseV020SpotPerpSQLiteRuntimeProjectionRow 是 GH-591 的 SQLite runtime projection 行。
///
/// 该行只保存来自 GH-590 Event Store schema 和 GH-589 Portfolio attribution evidence 的稳定
/// Spot / Perp read model 字段。`SQLite` 在这里表示 runtime projection ownership 和私有落盘
/// schema，不表示 Dashboard 可以读取 table、SQL、ORM model 或 broker/account payload。
public struct ReleaseV020SpotPerpSQLiteRuntimeProjectionRow: Codable, Equatable, Sendable {
    public let rowID: Identifier
    public let sequence: Int
    public let instrument: InstrumentIdentity
    public let productType: ProductType
    public let eventStoreChecksum: String
    public let exposureNotional: Double
    public let netPnL: Double
    public let sourceEvidenceID: Identifier
    public let projectedAt: Date
    public let productionTradingEnabledByDefault: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool

    public init(
        rowID: Identifier,
        sequence: Int,
        instrument: InstrumentIdentity,
        eventStoreChecksum: String,
        exposureNotional: Double,
        netPnL: Double,
        sourceEvidenceID: Identifier,
        projectedAt: Date,
        productionTradingEnabledByDefault: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false
    ) throws {
        guard sequence > 0,
              exposureNotional.isFinite,
              exposureNotional >= 0,
              netPnL.isFinite,
              eventStoreChecksum.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SQLiteSpotPerpRuntimeProjection.row",
                expected: "finite product-aware projection row",
                actual: "invalid"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SQLiteSpotPerpRuntimeProjection.\(forbiddenFlag.0)"
            )
        }

        self.rowID = rowID
        self.sequence = sequence
        self.instrument = instrument
        self.productType = instrument.productType
        self.eventStoreChecksum = eventStoreChecksum
        self.exposureNotional = exposureNotional
        self.netPnL = netPnL
        self.sourceEvidenceID = sourceEvidenceID
        self.projectedAt = projectedAt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
    }

    public var rowBoundaryHeld: Bool {
        sequence > 0
            && productType == instrument.productType
            && ProductType.allCases.contains(productType)
            && eventStoreChecksum.isEmpty == false
            && exposureNotional.isFinite
            && exposureNotional >= 0
            && netPnL.isFinite
            && productionTradingEnabledByDefault == false
            && rawDatabaseSchemaExposedToDashboard == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
    }
}

/// ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow 是 GH-591 的 DuckDB analytical projection 行。
///
/// 该行面向本地分析与 stage evidence；它把 Spot / Perp exposure、PnL、EMA / RSI attribution、
/// funding / liquidation summary 规范成稳定输出，不把 DuckDB table 或 SQL 变成 UI 合同。
public struct ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow: Codable, Equatable, Sendable {
    public let rowID: Identifier
    public let instrument: InstrumentIdentity
    public let productType: ProductType
    public let exposureNotional: Double
    public let netPnL: Double
    public let strategyAttributionCount: Int
    public let fundingPaymentEstimate: Double
    public let liquidationDistance: Double
    public let sourceEventStoreChecksum: String
    public let sourceEvidenceIDs: [Identifier]
    public let productionTradingEnabledByDefault: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool

    public init(
        rowID: Identifier,
        instrument: InstrumentIdentity,
        exposureNotional: Double,
        netPnL: Double,
        strategyAttributionCount: Int,
        fundingPaymentEstimate: Double,
        liquidationDistance: Double,
        sourceEventStoreChecksum: String,
        sourceEvidenceIDs: [Identifier],
        productionTradingEnabledByDefault: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false
    ) throws {
        guard exposureNotional.isFinite,
              exposureNotional >= 0,
              netPnL.isFinite,
              strategyAttributionCount == ReleaseV020AggregatePortfolioStrategyKind.allCases.count,
              fundingPaymentEstimate.isFinite,
              liquidationDistance.isFinite,
              liquidationDistance >= 0,
              sourceEventStoreChecksum.isEmpty == false,
              sourceEvidenceIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020DuckDBSpotPerpAnalyticalProjection.row",
                expected: "finite product-aware analytical row",
                actual: "invalid"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020DuckDBSpotPerpAnalyticalProjection.\(forbiddenFlag.0)"
            )
        }

        self.rowID = rowID
        self.instrument = instrument
        self.productType = instrument.productType
        self.exposureNotional = exposureNotional
        self.netPnL = netPnL
        self.strategyAttributionCount = strategyAttributionCount
        self.fundingPaymentEstimate = fundingPaymentEstimate
        self.liquidationDistance = liquidationDistance
        self.sourceEventStoreChecksum = sourceEventStoreChecksum
        self.sourceEvidenceIDs = sourceEvidenceIDs
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
    }

    public var rowBoundaryHeld: Bool {
        productType == instrument.productType
            && ProductType.allCases.contains(productType)
            && exposureNotional.isFinite
            && exposureNotional >= 0
            && netPnL.isFinite
            && strategyAttributionCount == ReleaseV020AggregatePortfolioStrategyKind.allCases.count
            && fundingPaymentEstimate.isFinite
            && liquidationDistance >= 0
            && sourceEventStoreChecksum.isEmpty == false
            && sourceEvidenceIDs.isEmpty == false
            && productionTradingEnabledByDefault == false
            && rawDatabaseSchemaExposedToDashboard == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
    }
}

public struct ReleaseV020SpotPerpSQLiteRuntimeProjectionSnapshot: Codable, Equatable, Sendable {
    public let rows: [ReleaseV020SpotPerpSQLiteRuntimeProjectionRow]
    public let lastAppliedSequence: Int
    public let privateSQLiteSchemaName: String
    public let dashboardConsumesStableReadModelOnly: Bool
    public let exposesRawSQLiteSchemaToDashboard: Bool

    public init(
        rows: [ReleaseV020SpotPerpSQLiteRuntimeProjectionRow],
        lastAppliedSequence: Int,
        privateSQLiteSchemaName: String = "release_v020_runtime_projection_records",
        dashboardConsumesStableReadModelOnly: Bool = true,
        exposesRawSQLiteSchemaToDashboard: Bool = false
    ) throws {
        guard rows.isEmpty == false,
              rows.allSatisfy(\.rowBoundaryHeld),
              Set(rows.map(\.productType)) == Set(ProductType.allCases),
              lastAppliedSequence == rows.map(\.sequence).max(),
              privateSQLiteSchemaName == "release_v020_runtime_projection_records",
              dashboardConsumesStableReadModelOnly,
              exposesRawSQLiteSchemaToDashboard == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SQLiteSpotPerpRuntimeProjection.snapshot",
                expected: "Spot and Perp stable SQLite runtime projection",
                actual: "\(rows.count)"
            )
        }

        self.rows = rows.sortedByReleaseV020SQLiteRuntimeProjection()
        self.lastAppliedSequence = lastAppliedSequence
        self.privateSQLiteSchemaName = privateSQLiteSchemaName
        self.dashboardConsumesStableReadModelOnly = dashboardConsumesStableReadModelOnly
        self.exposesRawSQLiteSchemaToDashboard = exposesRawSQLiteSchemaToDashboard
    }

    public var storedProductTypes: Set<ProductType> {
        Set(rows.map(\.productType))
    }

    public var storedInstrumentIDs: [InstrumentIdentity] {
        rows.map(\.instrument)
    }

    public var snapshotBoundaryHeld: Bool {
        rows.allSatisfy(\.rowBoundaryHeld)
            && storedProductTypes == Set(ProductType.allCases)
            && lastAppliedSequence == rows.map(\.sequence).max()
            && privateSQLiteSchemaName == "release_v020_runtime_projection_records"
            && dashboardConsumesStableReadModelOnly
            && exposesRawSQLiteSchemaToDashboard == false
    }
}

public struct ReleaseV020SpotPerpDuckDBAnalyticalProjectionSnapshot: Codable, Equatable, Sendable {
    public let rows: [ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow]
    public let lastAppliedSequence: Int
    public let privateDuckDBSchemaName: String
    public let dashboardConsumesStableReadModelOnly: Bool
    public let exposesRawDuckDBSchemaToDashboard: Bool

    public init(
        rows: [ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow],
        lastAppliedSequence: Int,
        privateDuckDBSchemaName: String = "release_v020_analytical_projection_records",
        dashboardConsumesStableReadModelOnly: Bool = true,
        exposesRawDuckDBSchemaToDashboard: Bool = false
    ) throws {
        guard rows.isEmpty == false,
              rows.allSatisfy(\.rowBoundaryHeld),
              Set(rows.map(\.productType)) == Set(ProductType.allCases),
              lastAppliedSequence > 0,
              privateDuckDBSchemaName == "release_v020_analytical_projection_records",
              dashboardConsumesStableReadModelOnly,
              exposesRawDuckDBSchemaToDashboard == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020DuckDBSpotPerpAnalyticalProjection.snapshot",
                expected: "Spot and Perp stable DuckDB analytical projection",
                actual: "\(rows.count)"
            )
        }

        self.rows = rows.sortedByReleaseV020DuckDBAnalyticalProjection()
        self.lastAppliedSequence = lastAppliedSequence
        self.privateDuckDBSchemaName = privateDuckDBSchemaName
        self.dashboardConsumesStableReadModelOnly = dashboardConsumesStableReadModelOnly
        self.exposesRawDuckDBSchemaToDashboard = exposesRawDuckDBSchemaToDashboard
    }

    public var storedProductTypes: Set<ProductType> {
        Set(rows.map(\.productType))
    }

    public var storedInstrumentIDs: [InstrumentIdentity] {
        rows.map(\.instrument)
    }

    public var snapshotBoundaryHeld: Bool {
        rows.allSatisfy(\.rowBoundaryHeld)
            && storedProductTypes == Set(ProductType.allCases)
            && lastAppliedSequence > 0
            && privateDuckDBSchemaName == "release_v020_analytical_projection_records"
            && dashboardConsumesStableReadModelOnly
            && exposesRawDuckDBSchemaToDashboard == false
    }
}

/// ReleaseV020SpotPerpDatabaseProjectionInput 把 GH-590 Event Store schema 与 GH-589 aggregate
/// attribution 绑定为 GH-591 的投影输入。
public struct ReleaseV020SpotPerpDatabaseProjectionInput: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let eventStoreEvidence: ReleaseV020ProductAwareEventStoreSchemaEvidence
    public let aggregateEvidence: ReleaseV020AggregatePortfolioAttributionEvidence
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let rawDatabaseSchemaExposedToDashboard: Bool

    public init(
        issueID: Identifier = Identifier.constant("GH-591"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-589"),
            Identifier.constant("GH-590")
        ],
        eventStoreEvidence: ReleaseV020ProductAwareEventStoreSchemaEvidence,
        aggregateEvidence: ReleaseV020AggregatePortfolioAttributionEvidence,
        validationAnchors: [String] = ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        rawDatabaseSchemaExposedToDashboard: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-591",
              upstreamIssueIDs.map(\.rawValue) == ["GH-589", "GH-590"],
              eventStoreEvidence.issueID.rawValue == "GH-590",
              eventStoreEvidence.evidenceBoundaryHeld,
              aggregateEvidence.issueID.rawValue == "GH-589",
              aggregateEvidence.evidenceBoundaryHeld,
              Set(eventStoreEvidence.records.map(\.productType)) == Set(ProductType.allCases),
              validationAnchors == ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPerpDatabaseProjection.input",
                expected: "GH-589/GH-590 Spot and Perp projection input",
                actual: issueID.rawValue
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("rawDatabaseSchemaExposedToDashboard", rawDatabaseSchemaExposedToDashboard)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPerpDatabaseProjection.\(forbiddenFlag.0)"
            )
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.eventStoreEvidence = eventStoreEvidence
        self.aggregateEvidence = aggregateEvidence
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.rawDatabaseSchemaExposedToDashboard = rawDatabaseSchemaExposedToDashboard
    }

    public var inputBoundaryHeld: Bool {
        issueID.rawValue == "GH-591"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-589", "GH-590"]
            && eventStoreEvidence.evidenceBoundaryHeld
            && aggregateEvidence.evidenceBoundaryHeld
            && validationAnchors == ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && rawDatabaseSchemaExposedToDashboard == false
    }
}

public enum ReleaseV020SpotPerpSQLiteRuntimeProjectionStore {
    public static func project(
        _ input: ReleaseV020SpotPerpDatabaseProjectionInput
    ) throws -> ReleaseV020SpotPerpSQLiteRuntimeProjectionSnapshot {
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SQLiteSpotPerpRuntimeProjection.inputBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        let rows = try input.eventStoreEvidence.records.map { record in
            let source = projectionSource(for: record.productType, aggregate: input.aggregateEvidence)
            return try ReleaseV020SpotPerpSQLiteRuntimeProjectionRow(
                rowID: Identifier.constant("gh-591-sqlite-\(record.productType.rawValue)-runtime-projection"),
                sequence: record.sequence,
                instrument: record.instrumentID,
                eventStoreChecksum: record.checksum,
                exposureNotional: source.exposureNotional,
                netPnL: source.netPnL,
                sourceEvidenceID: source.sourceEvidenceID,
                projectedAt: record.recordedAt
            )
        }

        return try ReleaseV020SpotPerpSQLiteRuntimeProjectionSnapshot(
            rows: rows,
            lastAppliedSequence: input.eventStoreEvidence.records.map(\.sequence).max() ?? 0
        )
    }
}

public enum ReleaseV020SpotPerpDuckDBAnalyticalProjectionStore {
    public static func project(
        _ input: ReleaseV020SpotPerpDatabaseProjectionInput
    ) throws -> ReleaseV020SpotPerpDuckDBAnalyticalProjectionSnapshot {
        guard input.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020DuckDBSpotPerpAnalyticalProjection.inputBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        let rows = try input.eventStoreEvidence.records.map { record in
            let source = projectionSource(for: record.productType, aggregate: input.aggregateEvidence)
            let fundingSummary = input.aggregateEvidence.fundingLiquidationSummary
            return try ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow(
                rowID: Identifier.constant("gh-591-duckdb-\(record.productType.rawValue)-analytical-projection"),
                instrument: record.instrumentID,
                exposureNotional: source.exposureNotional,
                netPnL: source.netPnL,
                strategyAttributionCount: input.aggregateEvidence.strategyAttributionSummaries.count,
                fundingPaymentEstimate: record.productType == .usdsPerpetual
                    ? fundingSummary.fundingPaymentEstimate
                    : 0,
                liquidationDistance: record.productType == .usdsPerpetual
                    ? fundingSummary.liquidationDistance
                    : 0,
                sourceEventStoreChecksum: record.checksum,
                sourceEvidenceIDs: [
                    source.sourceEvidenceID,
                    input.aggregateEvidence.evidenceID,
                    input.eventStoreEvidence.evidenceID
                ]
            )
        }

        return try ReleaseV020SpotPerpDuckDBAnalyticalProjectionSnapshot(
            rows: rows,
            lastAppliedSequence: input.eventStoreEvidence.records.map(\.sequence).max() ?? 0
        )
    }
}

/// ReleaseV020SpotPerpDatabaseProjectionEvidence 汇总 GH-591 release evidence。
/// `TVM-RELEASE-V020-SQLITE-DUCKDB-SPOT-PERP-PROJECTIONS`
public struct ReleaseV020SpotPerpDatabaseProjectionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sqliteRuntimeProjection: ReleaseV020SpotPerpSQLiteRuntimeProjectionSnapshot
    public let duckDBAnalyticalProjection: ReleaseV020SpotPerpDuckDBAnalyticalProjectionSnapshot
    public let validationAnchors: [String]
    public let runtimeProjectionInSQLite: Bool
    public let analyticalProjectionInDuckDB: Bool
    public let dashboardDoesNotDependOnRawDatabaseSchema: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let accountEndpointRead: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-591-sqlite-duckdb-spot-perp-projection-evidence"),
        issueID: Identifier = Identifier.constant("GH-591"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-589"),
            Identifier.constant("GH-590")
        ],
        sqliteRuntimeProjection: ReleaseV020SpotPerpSQLiteRuntimeProjectionSnapshot,
        duckDBAnalyticalProjection: ReleaseV020SpotPerpDuckDBAnalyticalProjectionSnapshot,
        validationAnchors: [String] = ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors,
        runtimeProjectionInSQLite: Bool = true,
        analyticalProjectionInDuckDB: Bool = true,
        dashboardDoesNotDependOnRawDatabaseSchema: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        accountEndpointRead: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-591",
              upstreamIssueIDs.map(\.rawValue) == ["GH-589", "GH-590"],
              sqliteRuntimeProjection.snapshotBoundaryHeld,
              duckDBAnalyticalProjection.snapshotBoundaryHeld,
              sqliteRuntimeProjection.storedProductTypes == Set(ProductType.allCases),
              duckDBAnalyticalProjection.storedProductTypes == Set(ProductType.allCases),
              validationAnchors == ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPerpDatabaseProjection.evidence",
                expected: "SQLite runtime and DuckDB analytical Spot/Perp projections",
                actual: issueID.rawValue
            )
        }
        for requiredFlag in [
            ("runtimeProjectionInSQLite", runtimeProjectionInSQLite),
            ("analyticalProjectionInDuckDB", analyticalProjectionInDuckDB),
            ("dashboardDoesNotDependOnRawDatabaseSchema", dashboardDoesNotDependOnRawDatabaseSchema)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020SpotPerpDatabaseProjection.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("accountEndpointRead", accountEndpointRead),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020SpotPerpDatabaseProjection.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sqliteRuntimeProjection = sqliteRuntimeProjection
        self.duckDBAnalyticalProjection = duckDBAnalyticalProjection
        self.validationAnchors = validationAnchors
        self.runtimeProjectionInSQLite = runtimeProjectionInSQLite
        self.analyticalProjectionInDuckDB = analyticalProjectionInDuckDB
        self.dashboardDoesNotDependOnRawDatabaseSchema = dashboardDoesNotDependOnRawDatabaseSchema
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.accountEndpointRead = accountEndpointRead
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-591"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-589", "GH-590"]
            && sqliteRuntimeProjection.snapshotBoundaryHeld
            && duckDBAnalyticalProjection.snapshotBoundaryHeld
            && validationAnchors == ReleaseV020SpotPerpDatabaseProjections.requiredValidationAnchors
            && runtimeProjectionInSQLite
            && analyticalProjectionInDuckDB
            && dashboardDoesNotDependOnRawDatabaseSchema
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && accountEndpointRead == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020SpotPerpDatabaseProjections 生成 GH-591 deterministic projection evidence。
public enum ReleaseV020SpotPerpDatabaseProjections {
    public static let requiredValidationAnchors = [
        "GH-591-SQLITE-SPOT-PERP-RUNTIME-PROJECTION",
        "GH-591-DUCKDB-SPOT-PERP-ANALYTICAL-PROJECTION",
        "GH-591-DASHBOARD-STABLE-READ-MODEL-ONLY",
        "GH-591-NO-PRODUCTION-DATABASE-SIDE-EFFECT",
        "TVM-RELEASE-V020-SQLITE-DUCKDB-SPOT-PERP-PROJECTIONS"
    ]

    public static func deterministicEvidence() throws -> ReleaseV020SpotPerpDatabaseProjectionEvidence {
        let eventStoreEvidence = try ReleaseV020ProductAwareEventStore.deterministicEvidence()
        let aggregateEvidence = try ReleaseV020AggregatePortfolioAttribution
            .deterministicFixture()
            .deterministicEvidence()
        let input = try ReleaseV020SpotPerpDatabaseProjectionInput(
            eventStoreEvidence: eventStoreEvidence,
            aggregateEvidence: aggregateEvidence
        )
        return try ReleaseV020SpotPerpDatabaseProjectionEvidence(
            sqliteRuntimeProjection: ReleaseV020SpotPerpSQLiteRuntimeProjectionStore.project(input),
            duckDBAnalyticalProjection: ReleaseV020SpotPerpDuckDBAnalyticalProjectionStore.project(input)
        )
    }
}

private struct ReleaseV020SpotPerpProjectionSource {
    let sourceEvidenceID: Identifier
    let exposureNotional: Double
    let netPnL: Double
}

private func projectionSource(
    for productType: ProductType,
    aggregate: ReleaseV020AggregatePortfolioAttributionEvidence
) -> ReleaseV020SpotPerpProjectionSource {
    switch productType {
    case .spot:
        ReleaseV020SpotPerpProjectionSource(
            sourceEvidenceID: aggregate.sourceSpotEvidenceID,
            exposureNotional: aggregate.exposureSummary.spotGrossExposureNotional,
            netPnL: aggregate.exposureSummary.spotNetPnL
        )

    case .usdsPerpetual:
        ReleaseV020SpotPerpProjectionSource(
            sourceEvidenceID: aggregate.sourcePerpetualEvidenceID,
            exposureNotional: aggregate.exposureSummary.perpetualGrossExposureNotional,
            netPnL: aggregate.exposureSummary.perpetualNetPnL
        )
    }
}

private extension Array where Element == ReleaseV020SpotPerpSQLiteRuntimeProjectionRow {
    func sortedByReleaseV020SQLiteRuntimeProjection() -> [ReleaseV020SpotPerpSQLiteRuntimeProjectionRow] {
        sorted { lhs, rhs in
            if lhs.sequence != rhs.sequence {
                return lhs.sequence < rhs.sequence
            }
            return lhs.instrument.rawValue < rhs.instrument.rawValue
        }
    }
}

private extension Array where Element == ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow {
    func sortedByReleaseV020DuckDBAnalyticalProjection() -> [ReleaseV020SpotPerpDuckDBAnalyticalProjectionRow] {
        sorted { lhs, rhs in
            if lhs.productType != rhs.productType {
                return lhs.productType.rawValue < rhs.productType.rawValue
            }
            return lhs.instrument.rawValue < rhs.instrument.rawValue
        }
    }
}
