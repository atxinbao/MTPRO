import Foundation

/// DatabaseRuntimeOwnershipMatrix 固定 GH-419 的 Database / Persistence / Runtime 当前归属。
/// GH-419 Database / Persistence / Runtime current ownership matrix.
/// GH-635 进一步把 Persistence / Runtime retained sources 收窄为明确 adapter/workflow shim。
///
/// 这个类型只描述 target ownership 和 compatibility envelope，不打开数据库、不执行 replay、
/// 不暴露 SQLite / DuckDB schema，也不把 Runtime、broker、account 或 live command 引入 Database。
public struct DatabaseRuntimeOwnershipMatrix: Codable, Equatable, Sendable {
    public let databaseTargetRole: String
    public let persistenceEnvelopeRole: String
    public let runtimeEnvelopeRole: String
    public let databaseOwnedPaths: [String]
    public let persistenceEnvelopePaths: [String]
    public let runtimeEnvelopePaths: [String]
    public let coreDependencyReason: String
    public let deferredExitGate: String
    public let exposesSchemaToDashboard: Bool
    public let ownsRuntimeObject: Bool
    public let persistsBrokerOrAccountPayload: Bool
    public let implementsTraderRuntime: Bool
    public let implementsStrategyRuntime: Bool
    public let implementsLiveRuntime: Bool
    public let implementsExecutionClient: Bool
    public let implementsOMS: Bool
    public let implementsBrokerGateway: Bool
    public let advancesL4: Bool
    public let validationAnchors: [String]

    public init(
        databaseTargetRole: String = "real Database source root owner for durable boundary and local projection vocabulary",
        persistenceEnvelopeRole: String = "retained compatibility envelope for SQLite and DuckDB projection adapters",
        runtimeEnvelopeRole: String = "retained composition envelope for replay projection and ingest workflow",
        databaseOwnedPaths: [String] = Self.requiredDatabaseOwnedPaths,
        persistenceEnvelopePaths: [String] = Self.requiredPersistenceEnvelopePaths,
        runtimeEnvelopePaths: [String] = Self.requiredRuntimeEnvelopePaths,
        coreDependencyReason: String = "projection adapters still consume rich EventEnvelope, paper, risk and portfolio payloads retained by Core",
        deferredExitGate: String = "move neutral event payloads and projection DTOs out of Core before retiring Persistence and Runtime envelopes",
        exposesSchemaToDashboard: Bool = false,
        ownsRuntimeObject: Bool = false,
        persistsBrokerOrAccountPayload: Bool = false,
        implementsTraderRuntime: Bool = false,
        implementsStrategyRuntime: Bool = false,
        implementsLiveRuntime: Bool = false,
        implementsExecutionClient: Bool = false,
        implementsOMS: Bool = false,
        implementsBrokerGateway: Bool = false,
        advancesL4: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.databaseTargetRole = databaseTargetRole
        self.persistenceEnvelopeRole = persistenceEnvelopeRole
        self.runtimeEnvelopeRole = runtimeEnvelopeRole
        self.databaseOwnedPaths = databaseOwnedPaths
        self.persistenceEnvelopePaths = persistenceEnvelopePaths
        self.runtimeEnvelopePaths = runtimeEnvelopePaths
        self.coreDependencyReason = coreDependencyReason
        self.deferredExitGate = deferredExitGate
        self.exposesSchemaToDashboard = exposesSchemaToDashboard
        self.ownsRuntimeObject = ownsRuntimeObject
        self.persistsBrokerOrAccountPayload = persistsBrokerOrAccountPayload
        self.implementsTraderRuntime = implementsTraderRuntime
        self.implementsStrategyRuntime = implementsStrategyRuntime
        self.implementsLiveRuntime = implementsLiveRuntime
        self.implementsExecutionClient = implementsExecutionClient
        self.implementsOMS = implementsOMS
        self.implementsBrokerGateway = implementsBrokerGateway
        self.advancesL4 = advancesL4
        self.validationAnchors = validationAnchors
    }

    /// 当前 Database 归属完整性：Database 是真实 source root，Persistence / Runtime 只是明确的兼容壳。
    public var ownershipBoundaryHeld: Bool {
        databaseTargetRole == "real Database source root owner for durable boundary and local projection vocabulary"
            && persistenceEnvelopeRole == "retained compatibility envelope for SQLite and DuckDB projection adapters"
            && runtimeEnvelopeRole == "retained composition envelope for replay projection and ingest workflow"
            && databaseOwnedPaths == Self.requiredDatabaseOwnedPaths
            && persistenceEnvelopePaths == Self.requiredPersistenceEnvelopePaths
            && runtimeEnvelopePaths == Self.requiredRuntimeEnvelopePaths
            && coreDependencyReason == "projection adapters still consume rich EventEnvelope, paper, risk and portfolio payloads retained by Core"
            && deferredExitGate == "move neutral event payloads and projection DTOs out of Core before retiring Persistence and Runtime envelopes"
            && exposesSchemaToDashboard == false
            && ownsRuntimeObject == false
            && persistsBrokerOrAccountPayload == false
            && implementsTraderRuntime == false
            && implementsStrategyRuntime == false
            && implementsLiveRuntime == false
            && implementsExecutionClient == false
            && implementsOMS == false
            && implementsBrokerGateway == false
            && advancesL4 == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredDatabaseOwnedPaths = [
        "Sources/Database/DatabaseRuntimeOwnershipMatrix.swift",
        "Sources/Database/FoundationDatabaseCheckpoint.swift",
        "Sources/Database/TargetGraph/DatabaseTargetBoundary.swift"
    ]

    public static let requiredPersistenceEnvelopePaths = [
        "Sources/Database/Projections/SQLite/Persistence.swift",
        "Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift"
    ]

    public static let requiredRuntimeEnvelopePaths = [
        "Sources/Database/ReplayProjection",
        "Sources/DataEngine/Ingest"
    ]

    public static let requiredValidationAnchors = [
        "GH-419-DATABASE-PERSISTENCE-RUNTIME-OWNERSHIP-MATRIX",
        "GH-419-PERSISTENCE-CORE-DEPENDENCY-DEFERRED-ONLY",
        "GH-419-RUNTIME-REPLAY-INGEST-COMPOSITION-ONLY",
        "GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT",
        "GH-419-NO-SCHEMA-RUNTIME-BROKER-L4-GUARD"
    ]

    public static let gh419 = DatabaseRuntimeOwnershipMatrix()
}
