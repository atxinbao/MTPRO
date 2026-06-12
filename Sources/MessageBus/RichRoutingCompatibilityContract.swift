/// MessageBusRichRoutingCompatibilityStatus 标记 rich routing 文件在 CEFR 期间的保留状态。
///
/// GH-632 不把依赖 ExecutionEngine、Portfolio、RiskEngine 或策略 payload 的 rich 文件
/// 强行迁入 `MessageBus` target；这些文件继续由 `Core` compatibility envelope 编译。
/// `MessageBus` target 只拥有可独立 import 的归属判定合同，防止 Core 被误写成 active owner。
public enum MessageBusRichRoutingCompatibilityStatus: String, Codable, Equatable, Sendable {
    case retainedCompatibilityOnly
}

/// MessageBusRichRoutingRetainedSurface 描述一个仍由 Core 编译的 rich routing surface。
///
/// `realModuleOwners` 表示最终应该拆分到的真实 owner；`Core` 只出现在
/// `compiledByCompatibilityEnvelope` 中，不能作为 active implementation owner。
public struct MessageBusRichRoutingRetainedSurface: Codable, Equatable, Sendable {
    public let sourcePath: String
    public let compiledByCompatibilityEnvelope: String
    public let realModuleOwners: [String]
    public let status: MessageBusRichRoutingCompatibilityStatus
    public let retentionReason: String
    public let exitPath: String
    public let messageBusOwnsCompatibilityDecision: Bool

    public init(
        sourcePath: String,
        compiledByCompatibilityEnvelope: String,
        realModuleOwners: [String],
        status: MessageBusRichRoutingCompatibilityStatus,
        retentionReason: String,
        exitPath: String,
        messageBusOwnsCompatibilityDecision: Bool
    ) {
        self.sourcePath = sourcePath
        self.compiledByCompatibilityEnvelope = compiledByCompatibilityEnvelope
        self.realModuleOwners = realModuleOwners
        self.status = status
        self.retentionReason = retentionReason
        self.exitPath = exitPath
        self.messageBusOwnsCompatibilityDecision = messageBusOwnsCompatibilityDecision
    }
}

/// MessageBusRichRoutingNoProductionAuthorization 固定 GH-632 不授权任何生产交易能力。
///
/// 这些 flag 只用于本地归属测试和文档锚点，不读取 secret、不连接 endpoint、
/// 不创建 broker adapter、OMS、真实订单或 Dashboard command surface。
public struct MessageBusRichRoutingNoProductionAuthorization: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let brokerGatewayEnabledByDefault: Bool
    public let realOrderCommandEnabledByDefault: Bool
    public let omsRuntimeEnabledByDefault: Bool
    public let dashboardCommandSurfaceEnabledByDefault: Bool

    public init(
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        brokerGatewayEnabledByDefault: Bool,
        realOrderCommandEnabledByDefault: Bool,
        omsRuntimeEnabledByDefault: Bool,
        dashboardCommandSurfaceEnabledByDefault: Bool
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.brokerGatewayEnabledByDefault = brokerGatewayEnabledByDefault
        self.realOrderCommandEnabledByDefault = realOrderCommandEnabledByDefault
        self.omsRuntimeEnabledByDefault = omsRuntimeEnabledByDefault
        self.dashboardCommandSurfaceEnabledByDefault = dashboardCommandSurfaceEnabledByDefault
    }

    public static let gh632 = MessageBusRichRoutingNoProductionAuthorization(
        productionTradingEnabledByDefault: false,
        productionSecretReadEnabledByDefault: false,
        productionEndpointConnectionEnabledByDefault: false,
        brokerGatewayEnabledByDefault: false,
        realOrderCommandEnabledByDefault: false,
        omsRuntimeEnabledByDefault: false,
        dashboardCommandSurfaceEnabledByDefault: false
    )

    public var allProductionCapabilitiesDisabledByDefault: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && productionEndpointConnectionEnabledByDefault == false
            && brokerGatewayEnabledByDefault == false
            && realOrderCommandEnabledByDefault == false
            && omsRuntimeEnabledByDefault == false
            && dashboardCommandSurfaceEnabledByDefault == false
    }
}

/// MessageBusRichRoutingCompatibilityContract 是 GH-632 的 MessageBus-owned 归属证据。
///
/// 它只列出 retained rich routing surfaces、真实 owner、保留理由和退出路径。
/// 合同本身位于 `MessageBus` target，从而证明 Core 不再拥有 active routing
/// 归属判定；Core 只保留 legacy import compatibility compile path。
public struct MessageBusRichRoutingCompatibilityContract: Codable, Equatable, Sendable {
    public let issue: String
    public let validationAnchors: [String]
    public let retainedSurfaces: [MessageBusRichRoutingRetainedSurface]
    public let noProductionAuthorization: MessageBusRichRoutingNoProductionAuthorization

    public init(
        issue: String,
        validationAnchors: [String],
        retainedSurfaces: [MessageBusRichRoutingRetainedSurface],
        noProductionAuthorization: MessageBusRichRoutingNoProductionAuthorization
    ) {
        self.issue = issue
        self.validationAnchors = validationAnchors
        self.retainedSurfaces = retainedSurfaces
        self.noProductionAuthorization = noProductionAuthorization
    }

    public var retainedSourcePaths: [String] {
        retainedSurfaces.map(\.sourcePath)
    }

    public var allSurfacesAreCompatibilityOnly: Bool {
        retainedSurfaces.allSatisfy { surface in
            surface.compiledByCompatibilityEnvelope == "Core"
                && surface.status == .retainedCompatibilityOnly
                && surface.messageBusOwnsCompatibilityDecision
                && surface.realModuleOwners.contains("MessageBus")
        }
    }

    public var boundaryHeld: Bool {
        issue == "GH-632"
            && validationAnchors == Self.requiredValidationAnchors
            && Set(retainedSourcePaths) == Self.requiredRetainedSourcePaths
            && allSurfacesAreCompatibilityOnly
            && noProductionAuthorization.allProductionCapabilitiesDisabledByDefault
    }

    public static let requiredValidationAnchors = [
        "GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT",
        "GH-632-CORE-RICH-ROUTING-COMPATIBILITY-ONLY",
        "GH-632-MESSAGEBUS-OWNED-ROUTING-CLASSIFICATION",
        "GH-632-DASHBOARD-CLI-BOUNDARY-HELD",
        "GH-632-NO-PRODUCTION-AUTHORIZATION",
        "TVM-CEFR-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY"
    ]

    public static let requiredRetainedSourcePaths: Set<String> = [
        "Sources/MessageBus/CommandsAndQueries.swift",
        "Sources/MessageBus/DomainEvents.swift",
        "Sources/MessageBus/EventLog.swift",
        "Sources/MessageBus/PaperRuntimeBusRouting.swift"
    ]

    public static let gh632 = MessageBusRichRoutingCompatibilityContract(
        issue: "GH-632",
        validationAnchors: requiredValidationAnchors,
        retainedSurfaces: [
            MessageBusRichRoutingRetainedSurface(
                sourcePath: "Sources/MessageBus/CommandsAndQueries.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["MessageBus", "TraderStrategies", "ExecutionEngine", "RiskEngine", "Portfolio"],
                status: .retainedCompatibilityOnly,
                retentionReason: "rich commands and queries still reference upper-layer strategy, paper execution, risk and portfolio payloads",
                exitPath: "split neutral command/query vocabulary into MessageBus and upper-layer payloads into their owning modules",
                messageBusOwnsCompatibilityDecision: true
            ),
            MessageBusRichRoutingRetainedSurface(
                sourcePath: "Sources/MessageBus/DomainEvents.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["MessageBus", "DomainModel", "ExecutionEngine", "Portfolio"],
                status: .retainedCompatibilityOnly,
                retentionReason: "rich event enum still aggregates cross-module paper lifecycle, simulated fill and portfolio facts",
                exitPath: "split neutral event envelope semantics into MessageBus and rich event payloads into the owner modules",
                messageBusOwnsCompatibilityDecision: true
            ),
            MessageBusRichRoutingRetainedSurface(
                sourcePath: "Sources/MessageBus/EventLog.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["MessageBus", "Database", "ExecutionEngine"],
                status: .retainedCompatibilityOnly,
                retentionReason: "append-only log remains coupled to rich Core event payloads during compatibility retirement",
                exitPath: "move neutral journal semantics to MessageBus and persistence-facing records to Database",
                messageBusOwnsCompatibilityDecision: true
            ),
            MessageBusRichRoutingRetainedSurface(
                sourcePath: "Sources/MessageBus/PaperRuntimeBusRouting.swift",
                compiledByCompatibilityEnvelope: "Core",
                realModuleOwners: ["MessageBus", "ExecutionEngine", "RiskEngine", "Portfolio"],
                status: .retainedCompatibilityOnly,
                retentionReason: "paper runtime routing still bridges risk, execution and portfolio evidence for legacy Core imports",
                exitPath: "split routing contracts into MessageBus and move engine-specific evidence to the owning targets",
                messageBusOwnsCompatibilityDecision: true
            )
        ],
        noProductionAuthorization: .gh632
    )
}
