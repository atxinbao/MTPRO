/// ExecutionParityOwnershipStatus 描述 ExecutionEngine source 在 CEFR-04 下的归属状态。
public enum ExecutionParityOwnershipStatus: String, Codable, Equatable, Sendable {
    case activeExecutionEngineOwner
    case retainedCompatibilityOnly
}

/// ExecutionParityOwnedSurface 是 ExecutionEngine target 当前直接拥有的 active source。
public struct ExecutionParityOwnedSurface: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let ownerTarget: String
    public let status: ExecutionParityOwnershipStatus
    public let ownershipReason: String

    public init(
        sourcePath: String,
        ownerTarget: String,
        status: ExecutionParityOwnershipStatus,
        ownershipReason: String
    ) {
        self.sourcePath = sourcePath
        self.ownerTarget = ownerTarget
        self.status = status
        self.ownershipReason = ownershipReason
    }
}

/// ExecutionParityRetainedBridge 是仍由 Core 编译的 paper / simulated parity bridge。
public struct ExecutionParityRetainedBridge: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let compiledByCompatibilityEnvelope: String
    public let realModuleOwners: [String]
    public let status: ExecutionParityOwnershipStatus
    public let retentionReason: String
    public let exitPath: String

    public init(
        sourcePath: String,
        compiledByCompatibilityEnvelope: String,
        realModuleOwners: [String],
        status: ExecutionParityOwnershipStatus,
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

/// ExecutionParityNoProductionAuthorization 固定 GH-634 不授权真实交易能力。
public struct ExecutionParityNoProductionAuthorization: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let brokerGatewayEnabledByDefault: Bool
    public let omsRuntimeEnabledByDefault: Bool
    public let realOrderCommandEnabledByDefault: Bool
    public let executionReportRuntimeEnabledByDefault: Bool
    public let brokerFillRuntimeEnabledByDefault: Bool

    public init(
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        brokerGatewayEnabledByDefault: Bool,
        omsRuntimeEnabledByDefault: Bool,
        realOrderCommandEnabledByDefault: Bool,
        executionReportRuntimeEnabledByDefault: Bool,
        brokerFillRuntimeEnabledByDefault: Bool
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.brokerGatewayEnabledByDefault = brokerGatewayEnabledByDefault
        self.omsRuntimeEnabledByDefault = omsRuntimeEnabledByDefault
        self.realOrderCommandEnabledByDefault = realOrderCommandEnabledByDefault
        self.executionReportRuntimeEnabledByDefault = executionReportRuntimeEnabledByDefault
        self.brokerFillRuntimeEnabledByDefault = brokerFillRuntimeEnabledByDefault
    }

    public static let gh634 = ExecutionParityNoProductionAuthorization(
        productionTradingEnabledByDefault: false,
        productionSecretReadEnabledByDefault: false,
        productionEndpointConnectionEnabledByDefault: false,
        brokerGatewayEnabledByDefault: false,
        omsRuntimeEnabledByDefault: false,
        realOrderCommandEnabledByDefault: false,
        executionReportRuntimeEnabledByDefault: false,
        brokerFillRuntimeEnabledByDefault: false
    )

    public var allProductionCapabilitiesDisabledByDefault: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && productionEndpointConnectionEnabledByDefault == false
            && brokerGatewayEnabledByDefault == false
            && omsRuntimeEnabledByDefault == false
            && realOrderCommandEnabledByDefault == false
            && executionReportRuntimeEnabledByDefault == false
            && brokerFillRuntimeEnabledByDefault == false
    }
}

/// ExecutionParityOwnershipContract 是 GH-634 的 ExecutionEngine-owned 归属证据。
///
/// Contract 把 active paper / simulated boundary source 与 Core retained bridge 分开，
/// 证明 Core 不再作为 active execution parity owner。
public struct ExecutionParityOwnershipContract: Codable, Equatable, Sendable {
    public let issue: String
    public let validationAnchors: [String]
    public let activeExecutionSurfaces: [ExecutionParityOwnedSurface]
    public let retainedCompatibilityBridges: [ExecutionParityRetainedBridge]
    public let noProductionAuthorization: ExecutionParityNoProductionAuthorization

    public init(
        issue: String,
        validationAnchors: [String],
        activeExecutionSurfaces: [ExecutionParityOwnedSurface],
        retainedCompatibilityBridges: [ExecutionParityRetainedBridge],
        noProductionAuthorization: ExecutionParityNoProductionAuthorization
    ) {
        self.issue = issue
        self.validationAnchors = validationAnchors
        self.activeExecutionSurfaces = activeExecutionSurfaces
        self.retainedCompatibilityBridges = retainedCompatibilityBridges
        self.noProductionAuthorization = noProductionAuthorization
    }

    public var activeSourcePaths: [String] {
        activeExecutionSurfaces.map(\.sourcePath)
    }

    public var retainedBridgeSourcePaths: [String] {
        retainedCompatibilityBridges.map(\.sourcePath)
    }

    public var executionEngineOwnsAllActiveSurfaces: Bool {
        activeExecutionSurfaces.allSatisfy { surface in
            surface.ownerTarget == "ExecutionEngine"
                && surface.status == .activeExecutionEngineOwner
        }
    }

    public var retainedBridgesAreCompatibilityOnly: Bool {
        retainedCompatibilityBridges.allSatisfy { bridge in
            bridge.compiledByCompatibilityEnvelope == "Core"
                && bridge.status == .retainedCompatibilityOnly
                && bridge.realModuleOwners.contains("ExecutionEngine")
        }
    }

    public var boundaryHeld: Bool {
        issue == "GH-634"
            && validationAnchors == Self.requiredValidationAnchors
            && Set(activeSourcePaths) == Self.requiredActiveExecutionSourcePaths
            && Set(retainedBridgeSourcePaths) == Self.requiredRetainedBridgeSourcePaths
            && executionEngineOwnsAllActiveSurfaces
            && retainedBridgesAreCompatibilityOnly
            && noProductionAuthorization.allProductionCapabilitiesDisabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT",
        "GH-634-EXECUTION-ACTIVE-SIMULATED-SOURCES",
        "GH-634-CORE-EXECUTION-PARITY-COMPATIBILITY-ONLY",
        "GH-634-NO-PRODUCTION-AUTHORIZATION",
        "TVM-CEFR-PORTFOLIO-EXECUTION-PARITY-OWNERSHIP"
    ]

    public static let requiredActiveExecutionSourcePaths: Set<String> = [
        "Sources/ExecutionEngine/Ownership/ExecutionEnginePaperOwnership.swift",
        "Sources/ExecutionEngine/Ownership/ExecutionParityOwnershipContract.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionWorkflowContract.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperRuntimeKernelBoundary.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlCommand.swift",
        "Sources/ExecutionEngine/SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift"
    ]

    public static let requiredRetainedBridgeSourcePaths: Set<String> = [
        "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionDecision.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionEventLog.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperOrderIntent.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLifecycle.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlEventLog.swift",
        "Sources/ExecutionEngine/PaperLifecycle/PaperSessionReplay.swift",
        "Sources/ExecutionEngine/SimulatedExchange/BacktestPaperSharedOrderSemantics.swift",
        "Sources/ExecutionEngine/SimulatedExchange/MarketLimitSimulatedExecutionSemantics.swift",
        "Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift",
        "Sources/ExecutionEngine/SimulatedExchange/PartialFillLatencyFeeSlippageParity.swift"
    ]

    public static let gh634 = ExecutionParityOwnershipContract(
        issue: "GH-634",
        validationAnchors: requiredValidationAnchors,
        activeExecutionSurfaces: [
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/Ownership/ExecutionEnginePaperOwnership.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "paper execution ownership matrix belongs to ExecutionEngine"
            ),
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/Ownership/ExecutionParityOwnershipContract.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "CEFR execution parity ownership classification belongs to ExecutionEngine"
            ),
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionWorkflowContract.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "paper execution workflow contract belongs to ExecutionEngine"
            ),
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/PaperLifecycle/PaperRuntimeKernelBoundary.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "paper runtime kernel boundary belongs to ExecutionEngine"
            ),
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlCommand.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "paper session local control command belongs to ExecutionEngine"
            ),
            ExecutionParityOwnedSurface(
                sourcePath: "Sources/ExecutionEngine/SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift",
                ownerTarget: "ExecutionEngine",
                status: .activeExecutionEngineOwner,
                ownershipReason: "simulated exchange parity boundary belongs to ExecutionEngine"
            )
        ],
        retainedCompatibilityBridges: requiredRetainedBridgeSourcePaths.sorted().map { sourcePath in
            ExecutionParityRetainedBridge(
                sourcePath: sourcePath,
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["ExecutionEngine"],
                status: .retainedCompatibilityOnly,
                retentionReason: "legacy paper / simulated parity bridge still compiles through Core compatibility envelope",
                exitPath: "split bridge dependencies and move owner-specific payloads into ExecutionEngine in a later CEFR issue"
            )
        },
        noProductionAuthorization: .gh634
    )
}
