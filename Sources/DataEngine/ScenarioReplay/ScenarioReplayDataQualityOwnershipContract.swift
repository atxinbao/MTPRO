/// ScenarioReplayDataQualityOwnershipStatus 描述 DataEngine source 的 CEFR 归属状态。
///
/// GH-633 只收窄 ScenarioReplay / DataQuality active ownership；仍耦合
/// simulated-exchange / shared-order payload 的 deterministic matching bridge
/// 继续作为 Core compatibility-only retained source，等待后续 CEFR parity owner 拆分。
public enum ScenarioReplayDataQualityOwnershipStatus: String, Codable, Equatable, Sendable {
    case activeDataEngineOwner
    case retainedCompatibilityOnly
}

/// ScenarioReplayDataQualityOwnedSurface 是 DataEngine 已直接拥有的 active source。
///
/// 这些 source 只表达 public-data ingest / replay / quality evidence，不读取 secret，
/// 不连接 production endpoint，也不路由 broker、OMS 或真实订单命令。
public struct ScenarioReplayDataQualityOwnedSurface: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let ownerTarget: String
    public let status: ScenarioReplayDataQualityOwnershipStatus
    public let ownershipReason: String

    public init(
        sourcePath: String,
        ownerTarget: String,
        status: ScenarioReplayDataQualityOwnershipStatus,
        ownershipReason: String
    ) {
        self.sourcePath = sourcePath
        self.ownerTarget = ownerTarget
        self.status = status
        self.ownershipReason = ownershipReason
    }
}

/// ScenarioReplayDataQualityRetainedBridge 描述仍留在 Core 的 cross-module deterministic bridge。
///
/// 它不是 active DataEngine business implementation；保留原因必须指向 upper-layer
/// simulated exchange / shared order dependency，退出路径必须要求拆分 owner payload。
public struct ScenarioReplayDataQualityRetainedBridge: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let compiledByCompatibilityEnvelope: String
    public let realModuleOwners: [String]
    public let status: ScenarioReplayDataQualityOwnershipStatus
    public let retentionReason: String
    public let exitPath: String

    public init(
        sourcePath: String,
        compiledByCompatibilityEnvelope: String,
        realModuleOwners: [String],
        status: ScenarioReplayDataQualityOwnershipStatus,
        retentionReason: String,
        exitPath: String
    ) {
        self.sourcePath = sourcePath
        self.compiledByCompatibilityEnvelope = compiledByCompatibilityEnvelope
        self.realModuleOwners = realModuleOwners
        self.status = status
        self.retentionReason = retentionReason
        self.exitPath = exitPath
    }
}

/// ScenarioReplayDataQualityNoProductionAuthorization 固定 GH-633 不授权生产能力。
public struct ScenarioReplayDataQualityNoProductionAuthorization: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let signedEndpointEnabledByDefault: Bool
    public let privateStreamRuntimeEnabledByDefault: Bool
    public let brokerGatewayEnabledByDefault: Bool
    public let realOrderCommandEnabledByDefault: Bool

    public init(
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        signedEndpointEnabledByDefault: Bool,
        privateStreamRuntimeEnabledByDefault: Bool,
        brokerGatewayEnabledByDefault: Bool,
        realOrderCommandEnabledByDefault: Bool
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.signedEndpointEnabledByDefault = signedEndpointEnabledByDefault
        self.privateStreamRuntimeEnabledByDefault = privateStreamRuntimeEnabledByDefault
        self.brokerGatewayEnabledByDefault = brokerGatewayEnabledByDefault
        self.realOrderCommandEnabledByDefault = realOrderCommandEnabledByDefault
    }

    public static let gh633 = ScenarioReplayDataQualityNoProductionAuthorization(
        productionTradingEnabledByDefault: false,
        productionSecretReadEnabledByDefault: false,
        productionEndpointConnectionEnabledByDefault: false,
        signedEndpointEnabledByDefault: false,
        privateStreamRuntimeEnabledByDefault: false,
        brokerGatewayEnabledByDefault: false,
        realOrderCommandEnabledByDefault: false
    )

    public var allProductionCapabilitiesDisabledByDefault: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && productionEndpointConnectionEnabledByDefault == false
            && signedEndpointEnabledByDefault == false
            && privateStreamRuntimeEnabledByDefault == false
            && brokerGatewayEnabledByDefault == false
            && realOrderCommandEnabledByDefault == false
    }
}

/// ScenarioReplayDataQualityOwnershipContract 是 GH-633 的 DataEngine-owned 归属证据。
///
/// Contract 明确哪些 ScenarioReplay / DataQuality source 已经由 DataEngine target
/// 直接拥有，哪些 cross-module bridge 只能作为 Core compatibility-only retained
/// source，避免把 Core 继续写成 active DataEngine business implementation owner。
public struct ScenarioReplayDataQualityOwnershipContract: Codable, Equatable, Sendable {
    public let issue: String
    public let validationAnchors: [String]
    public let activeDataEngineSurfaces: [ScenarioReplayDataQualityOwnedSurface]
    public let retainedCompatibilityBridges: [ScenarioReplayDataQualityRetainedBridge]
    public let noProductionAuthorization: ScenarioReplayDataQualityNoProductionAuthorization

    public init(
        issue: String,
        validationAnchors: [String],
        activeDataEngineSurfaces: [ScenarioReplayDataQualityOwnedSurface],
        retainedCompatibilityBridges: [ScenarioReplayDataQualityRetainedBridge],
        noProductionAuthorization: ScenarioReplayDataQualityNoProductionAuthorization
    ) {
        self.issue = issue
        self.validationAnchors = validationAnchors
        self.activeDataEngineSurfaces = activeDataEngineSurfaces
        self.retainedCompatibilityBridges = retainedCompatibilityBridges
        self.noProductionAuthorization = noProductionAuthorization
    }

    public var activeSourcePaths: [String] {
        activeDataEngineSurfaces.map(\.sourcePath)
    }

    public var retainedBridgeSourcePaths: [String] {
        retainedCompatibilityBridges.map(\.sourcePath)
    }

    public var dataEngineOwnsAllActiveSurfaces: Bool {
        activeDataEngineSurfaces.allSatisfy { surface in
            surface.ownerTarget == "DataEngine"
                && surface.status == .activeDataEngineOwner
        }
    }

    public var retainedBridgesAreCompatibilityOnly: Bool {
        retainedCompatibilityBridges.allSatisfy { bridge in
            bridge.compiledByCompatibilityEnvelope == "Core"
                && bridge.status == .retainedCompatibilityOnly
                && bridge.realModuleOwners.contains("DataEngine")
                && bridge.realModuleOwners.contains("ExecutionEngine")
        }
    }

    public var boundaryHeld: Bool {
        issue == "GH-633"
            && validationAnchors == Self.requiredValidationAnchors
            && Set(activeSourcePaths) == Self.requiredActiveDataEngineSourcePaths
            && Set(retainedBridgeSourcePaths) == Self.requiredRetainedBridgeSourcePaths
            && dataEngineOwnsAllActiveSurfaces
            && retainedBridgesAreCompatibilityOnly
            && noProductionAuthorization.allProductionCapabilitiesDisabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT",
        "GH-633-ACTIVE-DATAENGINE-SCENARIO-QUALITY-SOURCES",
        "GH-633-CORE-DETERMINISTIC-MATCHING-COMPATIBILITY-ONLY",
        "GH-633-NO-PRODUCTION-AUTHORIZATION",
        "TVM-CEFR-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP"
    ]

    public static let requiredActiveDataEngineSourcePaths: Set<String> = [
        "Sources/DataEngine/DataQuality/ScenarioDataQualityReportInput.swift",
        "Sources/DataEngine/ScenarioReplay/DataCatalogScenarioReplayBoundary.swift",
        "Sources/DataEngine/ScenarioReplay/ScenarioFixture.swift",
        "Sources/DataEngine/ScenarioReplay/ScenarioManifest.swift",
        "Sources/DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift",
        "Sources/DataEngine/ScenarioReplay/ScenarioReplayEvidence.swift"
    ]

    public static let requiredRetainedBridgeSourcePaths: Set<String> = [
        "Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift"
    ]

    public static let gh633 = ScenarioReplayDataQualityOwnershipContract(
        issue: "GH-633",
        validationAnchors: requiredValidationAnchors,
        activeDataEngineSurfaces: [
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/DataQuality/ScenarioDataQualityReportInput.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "scenario replay quality gates and report input evidence belong to DataEngine"
            ),
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/ScenarioReplay/DataCatalogScenarioReplayBoundary.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "data catalog and scenario replay boundary belongs to DataEngine"
            ),
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/ScenarioReplay/ScenarioFixture.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "deterministic local scenario fixture identity belongs to DataEngine"
            ),
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/ScenarioReplay/ScenarioManifest.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "scenario manifest identity and scope belongs to DataEngine"
            ),
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "CEFR ownership classification is owned by DataEngine"
            ),
            ScenarioReplayDataQualityOwnedSurface(
                sourcePath: "Sources/DataEngine/ScenarioReplay/ScenarioReplayEvidence.swift",
                ownerTarget: "DataEngine",
                status: .activeDataEngineOwner,
                ownershipReason: "replay window, cursor, checksum and freshness evidence belongs to DataEngine"
            )
        ],
        retainedCompatibilityBridges: [
            ScenarioReplayDataQualityRetainedBridge(
                sourcePath: "Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["DataEngine", "ExecutionEngine"],
                status: .retainedCompatibilityOnly,
                retentionReason: "deterministic matching still consumes shared order and simulated exchange payloads",
                exitPath: "split DataEngine replay inputs from ExecutionEngine simulated parity payloads before target migration"
            )
        ],
        noProductionAuthorization: .gh633
    )
}
