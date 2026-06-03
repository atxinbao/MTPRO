import Cache
import DomainModel
import MessageBus
import Portfolio
import RiskEngine
import TraderStrategies

/// `Trader` target boundary 表达 Accounts + Strategies/EMA + Coordination 的组合容器。
///
/// MTP-219 只建立 Trader coordination boundary 的 SwiftPM target evidence。因为
/// `ExecutionEngine` target 归 MTP-220 拆分，本 target 暂不依赖 `ExecutionEngine`，
/// 只记录后续 dependency gate，避免在 MTP-219 越界拆 execution layer。
public struct TraderTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let strategiesBoundary: TraderStrategiesTargetBoundary
    public let portfolioBoundary: PortfolioTargetBoundary
    public let riskEngineBoundary: RiskEngineTargetBoundary
    public let allowedDependencies: [String]
    public let deferredDependencies: [String]
    public let forbiddenDependencies: [String]
    public let accountContextRoot: String
    public let activeStrategyRoot: String
    public let coordinationRoot: String
    public let activeConcreteStrategies: [String]
    public let implementsTraderRuntime: Bool
    public let callsExecutionClientDirectly: Bool
    public let callsBrokerOrOMS: Bool
    public let readsRealAccountPayload: Bool
    public let exposesLiveCommandSurface: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "Trader",
        canonicalSourceRoot: String = "Sources/Trader",
        compiledBoundaryRoot: String = "Sources/TargetGraph/Trader",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        strategiesBoundary: TraderStrategiesTargetBoundary = .mtp219,
        portfolioBoundary: PortfolioTargetBoundary = .mtp219,
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        deferredDependencies: [String] = ["ExecutionEngine(MTP-220)"],
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        accountContextRoot: String = "Sources/Trader/Accounts",
        activeStrategyRoot: String = "Sources/Trader/Strategies/EMA",
        coordinationRoot: String = "Sources/Trader/Coordination/RiskBinding",
        activeConcreteStrategies: [String] = ["EMA"],
        implementsTraderRuntime: Bool = false,
        callsExecutionClientDirectly: Bool = false,
        callsBrokerOrOMS: Bool = false,
        readsRealAccountPayload: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.messageBusBoundary = messageBusBoundary
        self.cacheBoundary = cacheBoundary
        self.strategiesBoundary = strategiesBoundary
        self.portfolioBoundary = portfolioBoundary
        self.riskEngineBoundary = riskEngineBoundary
        self.allowedDependencies = allowedDependencies
        self.deferredDependencies = deferredDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.accountContextRoot = accountContextRoot
        self.activeStrategyRoot = activeStrategyRoot
        self.coordinationRoot = coordinationRoot
        self.activeConcreteStrategies = activeConcreteStrategies
        self.implementsTraderRuntime = implementsTraderRuntime
        self.callsExecutionClientDirectly = callsExecutionClientDirectly
        self.callsBrokerOrOMS = callsBrokerOrOMS
        self.readsRealAccountPayload = readsRealAccountPayload
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.validationAnchors = validationAnchors
    }

    /// Trader 是 coordination container，不是 live coordinator、broker gateway 或 order command router。
    public var dependencyDirectionHeld: Bool {
        targetName == "Trader"
            && canonicalSourceRoot == "Sources/Trader"
            && compiledBoundaryRoot == "Sources/TargetGraph/Trader"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && strategiesBoundary.dependencyDirectionHeld
            && portfolioBoundary.dependencyDirectionHeld
            && riskEngineBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && deferredDependencies == ["ExecutionEngine(MTP-220)"]
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && accountContextRoot == "Sources/Trader/Accounts"
            && activeStrategyRoot == "Sources/Trader/Strategies/EMA"
            && coordinationRoot == "Sources/Trader/Coordination/RiskBinding"
            && activeConcreteStrategies == ["EMA"]
            && implementsTraderRuntime == false
            && callsExecutionClientDirectly == false
            && callsBrokerOrOMS == false
            && readsRealAccountPayload == false
            && exposesLiveCommandSurface == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "Cache",
        "TraderStrategies",
        "Portfolio",
        "RiskEngine"
    ]

    public static let requiredForbiddenDependencies = [
        "ExecutionClient",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateStreamRuntime",
        "TraderRuntime",
        "StrategyRuntime",
        "LiveCommandSurface",
        "Workbench",
        "Dashboard"
    ]

    public static let requiredValidationAnchors = [
        "MTP-219-TRADER-TARGET-SPLIT",
        "MTP-219-TRADER-CONTAINER-ACCOUNTS-EMA-COORDINATION",
        "MTP-219-NO-DIRECT-EXECUTION-GUARD"
    ]

    public static let mtp219 = TraderTargetBoundary()
}
