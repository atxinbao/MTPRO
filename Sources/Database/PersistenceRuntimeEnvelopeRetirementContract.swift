/// PersistenceRuntimeEnvelopeStatus 描述 GH-635 后 Persistence / Runtime envelope 的允许状态。
///
/// GH-635 不删除既有 SwiftPM target 名称；它把 retained source 统一收窄为 Database-owned
/// adapter shim 或 DataEngine / Database workflow shim，防止 envelope 被解释为 active runtime owner。
public enum PersistenceRuntimeEnvelopeStatus: String, Codable, Equatable, Sendable {
    case retainedAdapterShim
    case retainedWorkflowShim
}

/// PersistenceRuntimeRetainedShim 是 Persistence / Runtime compatibility target 的 retained source 记录。
public struct PersistenceRuntimeRetainedShim: Codable, Equatable, Sendable {
    public let envelopeTarget: String
    public let sourcePath: String
    public let realModuleOwners: [String]
    public let status: PersistenceRuntimeEnvelopeStatus
    public let shimRole: String
    public let retentionReason: String
    public let exitPath: String

    public init(
        envelopeTarget: String,
        sourcePath: String,
        realModuleOwners: [String],
        status: PersistenceRuntimeEnvelopeStatus,
        shimRole: String,
        retentionReason: String,
        exitPath: String
    ) {
        self.envelopeTarget = envelopeTarget
        self.sourcePath = sourcePath
        self.realModuleOwners = realModuleOwners
        self.status = status
        self.shimRole = shimRole
        self.retentionReason = retentionReason
        self.exitPath = exitPath
    }
}

/// PersistenceRuntimeEnvelopeNoProductionAuthorization 固定 GH-635 不授权真实交易或生产运行时能力。
public struct PersistenceRuntimeEnvelopeNoProductionAuthorization: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let rawSchemaExposedToDashboard: Bool
    public let runtimeObjectExposedToDashboard: Bool
    public let brokerPayloadPersistenceEnabledByDefault: Bool
    public let accountPayloadPersistenceEnabledByDefault: Bool
    public let brokerGatewayEnabledByDefault: Bool
    public let omsRuntimeEnabledByDefault: Bool
    public let realOrderCommandEnabledByDefault: Bool
    public let reconciliationRuntimeEnabledByDefault: Bool

    public init(
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        rawSchemaExposedToDashboard: Bool,
        runtimeObjectExposedToDashboard: Bool,
        brokerPayloadPersistenceEnabledByDefault: Bool,
        accountPayloadPersistenceEnabledByDefault: Bool,
        brokerGatewayEnabledByDefault: Bool,
        omsRuntimeEnabledByDefault: Bool,
        realOrderCommandEnabledByDefault: Bool,
        reconciliationRuntimeEnabledByDefault: Bool
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.rawSchemaExposedToDashboard = rawSchemaExposedToDashboard
        self.runtimeObjectExposedToDashboard = runtimeObjectExposedToDashboard
        self.brokerPayloadPersistenceEnabledByDefault = brokerPayloadPersistenceEnabledByDefault
        self.accountPayloadPersistenceEnabledByDefault = accountPayloadPersistenceEnabledByDefault
        self.brokerGatewayEnabledByDefault = brokerGatewayEnabledByDefault
        self.omsRuntimeEnabledByDefault = omsRuntimeEnabledByDefault
        self.realOrderCommandEnabledByDefault = realOrderCommandEnabledByDefault
        self.reconciliationRuntimeEnabledByDefault = reconciliationRuntimeEnabledByDefault
    }

    public static let gh635 = PersistenceRuntimeEnvelopeNoProductionAuthorization(
        productionTradingEnabledByDefault: false,
        productionSecretReadEnabledByDefault: false,
        productionEndpointConnectionEnabledByDefault: false,
        rawSchemaExposedToDashboard: false,
        runtimeObjectExposedToDashboard: false,
        brokerPayloadPersistenceEnabledByDefault: false,
        accountPayloadPersistenceEnabledByDefault: false,
        brokerGatewayEnabledByDefault: false,
        omsRuntimeEnabledByDefault: false,
        realOrderCommandEnabledByDefault: false,
        reconciliationRuntimeEnabledByDefault: false
    )

    public var allForbiddenCapabilitiesDisabledByDefault: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && productionEndpointConnectionEnabledByDefault == false
            && rawSchemaExposedToDashboard == false
            && runtimeObjectExposedToDashboard == false
            && brokerPayloadPersistenceEnabledByDefault == false
            && accountPayloadPersistenceEnabledByDefault == false
            && brokerGatewayEnabledByDefault == false
            && omsRuntimeEnabledByDefault == false
            && realOrderCommandEnabledByDefault == false
            && reconciliationRuntimeEnabledByDefault == false
    }
}

/// PersistenceRuntimeEnvelopeRetirementContract 是 GH-635 的 Database-owned envelope 收窄证据。
///
/// Contract 明确 `Persistence` 和 `Runtime` 仍只是 target-level compatibility envelope：
/// Persistence 只保留 Database projection adapter shim，Runtime 只保留 DataEngine / Database
/// replay-ingest workflow shim；二者都不是 active production runtime owner。
public struct PersistenceRuntimeEnvelopeRetirementContract: Codable, Equatable, Sendable {
    public let issue: String
    public let validationAnchors: [String]
    public let persistenceShims: [PersistenceRuntimeRetainedShim]
    public let runtimeShims: [PersistenceRuntimeRetainedShim]
    public let noProductionAuthorization: PersistenceRuntimeEnvelopeNoProductionAuthorization

    public init(
        issue: String,
        validationAnchors: [String],
        persistenceShims: [PersistenceRuntimeRetainedShim],
        runtimeShims: [PersistenceRuntimeRetainedShim],
        noProductionAuthorization: PersistenceRuntimeEnvelopeNoProductionAuthorization
    ) {
        self.issue = issue
        self.validationAnchors = validationAnchors
        self.persistenceShims = persistenceShims
        self.runtimeShims = runtimeShims
        self.noProductionAuthorization = noProductionAuthorization
    }

    public var persistenceShimSourcePaths: [String] {
        persistenceShims.map(\.sourcePath)
    }

    public var runtimeShimSourcePaths: [String] {
        runtimeShims.map(\.sourcePath)
    }

    public var persistenceEnvelopeIsAdapterShimOnly: Bool {
        persistenceShims.allSatisfy { shim in
            shim.envelopeTarget == "Persistence"
                && shim.realModuleOwners == ["Database"]
                && shim.status == .retainedAdapterShim
                && shim.shimRole == "Database projection adapter shim"
        }
    }

    public var runtimeEnvelopeIsWorkflowShimOnly: Bool {
        runtimeShims.allSatisfy { shim in
            shim.envelopeTarget == "Runtime"
                && shim.status == .retainedWorkflowShim
                && Set(shim.realModuleOwners).isSubset(of: ["DataEngine", "Database"])
                && shim.shimRole == "DataEngine / Database replay-ingest workflow shim"
        }
    }

    public var boundaryHeld: Bool {
        issue == "GH-635"
            && validationAnchors == Self.requiredValidationAnchors
            && Set(persistenceShimSourcePaths) == Self.requiredPersistenceShimSourcePaths
            && Set(runtimeShimSourcePaths) == Self.requiredRuntimeShimSourcePaths
            && persistenceEnvelopeIsAdapterShimOnly
            && runtimeEnvelopeIsWorkflowShimOnly
            && noProductionAuthorization.allForbiddenCapabilitiesDisabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT",
        "GH-635-PERSISTENCE-ADAPTER-SHIM-ONLY",
        "GH-635-RUNTIME-WORKFLOW-SHIM-ONLY",
        "GH-635-PACKAGE-SOURCE-OVERLAP-GUARD",
        "GH-635-NO-PRODUCTION-AUTHORIZATION",
        "TVM-CEFR-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT"
    ]

    public static let requiredPersistenceShimSourcePaths: Set<String> = [
        "Sources/Database/Projections/ReleaseV020SpotPerpDatabaseProjections.swift",
        "Sources/Database/Projections/SQLite/Persistence.swift",
        "Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift"
    ]

    public static let requiredRuntimeShimSourcePaths: Set<String> = [
        "Sources/Database/ReplayProjection/MarketDataReplayProjectionConsistency.swift",
        "Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift"
    ]

    public static let gh635 = PersistenceRuntimeEnvelopeRetirementContract(
        issue: "GH-635",
        validationAnchors: requiredValidationAnchors,
        persistenceShims: [
            PersistenceRuntimeRetainedShim(
                envelopeTarget: "Persistence",
                sourcePath: "Sources/Database/Projections/ReleaseV020SpotPerpDatabaseProjections.swift",
                realModuleOwners: ["Database"],
                status: .retainedAdapterShim,
                shimRole: "Database projection adapter shim",
                retentionReason: "release v0.2.0 projection DTOs still expose stable read model through Persistence import",
                exitPath: "move all callers to Database product and retire Persistence target dependency"
            ),
            PersistenceRuntimeRetainedShim(
                envelopeTarget: "Persistence",
                sourcePath: "Sources/Database/Projections/SQLite/Persistence.swift",
                realModuleOwners: ["Database"],
                status: .retainedAdapterShim,
                shimRole: "Database projection adapter shim",
                retentionReason: "SQLite runtime projection adapter still serves legacy Persistence imports",
                exitPath: "move SQLite projection API to Database product and retire Persistence target dependency"
            ),
            PersistenceRuntimeRetainedShim(
                envelopeTarget: "Persistence",
                sourcePath: "Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift",
                realModuleOwners: ["Database"],
                status: .retainedAdapterShim,
                shimRole: "Database projection adapter shim",
                retentionReason: "DuckDB analytical projection adapter still serves legacy Persistence imports",
                exitPath: "move DuckDB projection API to Database product and retire Persistence target dependency"
            )
        ],
        runtimeShims: [
            PersistenceRuntimeRetainedShim(
                envelopeTarget: "Runtime",
                sourcePath: "Sources/Database/ReplayProjection/MarketDataReplayProjectionConsistency.swift",
                realModuleOwners: ["Database", "DataEngine"],
                status: .retainedWorkflowShim,
                shimRole: "DataEngine / Database replay-ingest workflow shim",
                retentionReason: "replay projection consistency still combines DataEngine replay evidence and Database projection evidence",
                exitPath: "move replay projection proof to Database / DataEngine owners and retire Runtime target source"
            ),
            PersistenceRuntimeRetainedShim(
                envelopeTarget: "Runtime",
                sourcePath: "Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift",
                realModuleOwners: ["DataEngine", "Database"],
                status: .retainedWorkflowShim,
                shimRole: "DataEngine / Database replay-ingest workflow shim",
                retentionReason: "ingest replay projection workflow still composes DataEngine public ingest and Database projection adapters",
                exitPath: "move ingest orchestration proof to DataEngine and projection rebuild proof to Database"
            )
        ],
        noProductionAuthorization: .gh635
    )
}
