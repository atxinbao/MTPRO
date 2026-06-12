/// PortfolioParityOwnershipStatus 描述 Portfolio source 在 CEFR-04 下的归属状态。
///
/// GH-634 不把仍消费 ExecutionEngine simulated fill / parity evidence 的 source
/// 强行迁入 Portfolio target；Portfolio target 只拥有主动 projection 和归属判定。
public enum PortfolioParityOwnershipStatus: String, Codable, Equatable, Sendable {
    case activePortfolioOwner
    case retainedCompatibilityOnly
}

/// PortfolioParityOwnedSurface 是 Portfolio target 当前直接拥有的 active source。
public struct PortfolioParityOwnedSurface: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let ownerTarget: String
    public let status: PortfolioParityOwnershipStatus
    public let ownershipReason: String

    public init(
        sourcePath: String,
        ownerTarget: String,
        status: PortfolioParityOwnershipStatus,
        ownershipReason: String
    ) {
        self.sourcePath = sourcePath
        self.ownerTarget = ownerTarget
        self.status = status
        self.ownershipReason = ownershipReason
    }
}

/// PortfolioParityRetainedBridge 是仍由 Core 编译的 Portfolio parity bridge。
///
/// 这些 source 不能被描述为 Core active owner；Core 只保留 legacy import 和
/// cross-module parity bridge 编译路径。
public struct PortfolioParityRetainedBridge: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let compiledByCompatibilityEnvelope: String
    public let realModuleOwners: [String]
    public let status: PortfolioParityOwnershipStatus
    public let retentionReason: String
    public let exitPath: String

    public init(
        sourcePath: String,
        compiledByCompatibilityEnvelope: String,
        realModuleOwners: [String],
        status: PortfolioParityOwnershipStatus,
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

/// PortfolioParityNoProductionAuthorization 固定 GH-634 不授权真实交易能力。
public struct PortfolioParityNoProductionAuthorization: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let brokerGatewayEnabledByDefault: Bool
    public let realOrderCommandEnabledByDefault: Bool
    public let reconciliationRuntimeEnabledByDefault: Bool

    public init(
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        brokerGatewayEnabledByDefault: Bool,
        realOrderCommandEnabledByDefault: Bool,
        reconciliationRuntimeEnabledByDefault: Bool
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.brokerGatewayEnabledByDefault = brokerGatewayEnabledByDefault
        self.realOrderCommandEnabledByDefault = realOrderCommandEnabledByDefault
        self.reconciliationRuntimeEnabledByDefault = reconciliationRuntimeEnabledByDefault
    }

    public static let gh634 = PortfolioParityNoProductionAuthorization(
        productionTradingEnabledByDefault: false,
        productionSecretReadEnabledByDefault: false,
        productionEndpointConnectionEnabledByDefault: false,
        brokerGatewayEnabledByDefault: false,
        realOrderCommandEnabledByDefault: false,
        reconciliationRuntimeEnabledByDefault: false
    )

    public var allProductionCapabilitiesDisabledByDefault: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && productionEndpointConnectionEnabledByDefault == false
            && brokerGatewayEnabledByDefault == false
            && realOrderCommandEnabledByDefault == false
            && reconciliationRuntimeEnabledByDefault == false
    }
}

/// PortfolioParityOwnershipContract 是 GH-634 的 Portfolio-owned 归属证据。
///
/// Contract 明确 active Portfolio source 与 retained Core compatibility bridge，
/// 防止 Core 被继续写成 portfolio projection / parity active owner。
public struct PortfolioParityOwnershipContract: Codable, Equatable, Sendable {
    public let issue: String
    public let validationAnchors: [String]
    public let activePortfolioSurfaces: [PortfolioParityOwnedSurface]
    public let retainedCompatibilityBridges: [PortfolioParityRetainedBridge]
    public let noProductionAuthorization: PortfolioParityNoProductionAuthorization

    public init(
        issue: String,
        validationAnchors: [String],
        activePortfolioSurfaces: [PortfolioParityOwnedSurface],
        retainedCompatibilityBridges: [PortfolioParityRetainedBridge],
        noProductionAuthorization: PortfolioParityNoProductionAuthorization
    ) {
        self.issue = issue
        self.validationAnchors = validationAnchors
        self.activePortfolioSurfaces = activePortfolioSurfaces
        self.retainedCompatibilityBridges = retainedCompatibilityBridges
        self.noProductionAuthorization = noProductionAuthorization
    }

    public var activeSourcePaths: [String] {
        activePortfolioSurfaces.map(\.sourcePath)
    }

    public var retainedBridgeSourcePaths: [String] {
        retainedCompatibilityBridges.map(\.sourcePath)
    }

    public var portfolioOwnsAllActiveSurfaces: Bool {
        activePortfolioSurfaces.allSatisfy { surface in
            surface.ownerTarget == "Portfolio"
                && surface.status == .activePortfolioOwner
        }
    }

    public var retainedBridgesAreCompatibilityOnly: Bool {
        retainedCompatibilityBridges.allSatisfy { bridge in
            bridge.compiledByCompatibilityEnvelope == "Core"
                && bridge.status == .retainedCompatibilityOnly
                && bridge.realModuleOwners.contains("Portfolio")
        }
    }

    public var boundaryHeld: Bool {
        issue == "GH-634"
            && validationAnchors == Self.requiredValidationAnchors
            && Set(activeSourcePaths) == Self.requiredActivePortfolioSourcePaths
            && Set(retainedBridgeSourcePaths) == Self.requiredRetainedBridgeSourcePaths
            && portfolioOwnsAllActiveSurfaces
            && retainedBridgesAreCompatibilityOnly
            && noProductionAuthorization.allProductionCapabilitiesDisabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT",
        "GH-634-PORTFOLIO-ACTIVE-PROJECTION-SOURCES",
        "GH-634-CORE-PORTFOLIO-PARITY-COMPATIBILITY-ONLY",
        "GH-634-NO-PRODUCTION-AUTHORIZATION",
        "TVM-CEFR-PORTFOLIO-EXECUTION-PARITY-OWNERSHIP"
    ]

    public static let requiredActivePortfolioSourcePaths: Set<String> = [
        "Sources/Portfolio/PaperPortfolioProjectionUpdate.swift",
        "Sources/Portfolio/PortfolioFinancialStateProjection.swift",
        "Sources/Portfolio/PortfolioParityOwnershipContract.swift"
    ]

    public static let requiredRetainedBridgeSourcePaths: Set<String> = [
        "Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift",
        "Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift"
    ]

    public static let gh634 = PortfolioParityOwnershipContract(
        issue: "GH-634",
        validationAnchors: requiredValidationAnchors,
        activePortfolioSurfaces: [
            PortfolioParityOwnedSurface(
                sourcePath: "Sources/Portfolio/PaperPortfolioProjectionUpdate.swift",
                ownerTarget: "Portfolio",
                status: .activePortfolioOwner,
                ownershipReason: "paper portfolio projection update is active Portfolio-owned read-model evidence"
            ),
            PortfolioParityOwnedSurface(
                sourcePath: "Sources/Portfolio/PortfolioFinancialStateProjection.swift",
                ownerTarget: "Portfolio",
                status: .activePortfolioOwner,
                ownershipReason: "financial state projection is active Portfolio-owned read-model evidence"
            ),
            PortfolioParityOwnedSurface(
                sourcePath: "Sources/Portfolio/PortfolioParityOwnershipContract.swift",
                ownerTarget: "Portfolio",
                status: .activePortfolioOwner,
                ownershipReason: "CEFR portfolio parity ownership classification belongs to Portfolio"
            )
        ],
        retainedCompatibilityBridges: [
            PortfolioParityRetainedBridge(
                sourcePath: "Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["Portfolio"],
                status: .retainedCompatibilityOnly,
                retentionReason: "legacy Dashboard/App tests still consume paper account projection through Core",
                exitPath: "move projection snapshot API to Portfolio consumers and retire Core import path"
            ),
            PortfolioParityRetainedBridge(
                sourcePath: "Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["Portfolio", "ExecutionEngine"],
                status: .retainedCompatibilityOnly,
                retentionReason: "projection parity still consumes simulated execution fill evidence",
                exitPath: "split execution fill evidence to ExecutionEngine and projection updates to Portfolio"
            )
        ],
        noProductionAuthorization: .gh634
    )
}
