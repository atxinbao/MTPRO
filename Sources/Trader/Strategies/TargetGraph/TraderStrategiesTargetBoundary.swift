import Cache
import DomainModel
import MessageBus
import Portfolio
import RiskEngine

/// `TraderStrategies` target boundary 表达 Trader-owned concrete strategy definitions。
///
/// MTP-228 只把 active target boundary anchor 从 `Sources/TargetGraph/TraderStrategies`
/// 移到真实 strategy root。GH-568 将 target path 从 EMA-only root 提升为
/// `Sources/Trader/Strategies`，当前 release v0.2.0 只允许 EMA + RSI active source。
/// 其他 strategy 只能作为 future candidate 或 historical evidence 出现，不能作为 active
/// source root、target source root 或测试入口回流。
public struct TraderStrategiesTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let portfolioBoundary: PortfolioTargetBoundary
    public let riskEngineBoundary: RiskEngineTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let activeConcreteStrategies: [String]
    public let activeStrategySourceRoots: [String]
    public let nonReleaseActiveStrategySourceRoots: [String]
    public let callsExecutionClient: Bool
    public let callsBrokerOrOMS: Bool
    public let exposesUICommandSurface: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "TraderStrategies",
        canonicalSourceRoot: String = "Sources/Trader/Strategies",
        compiledBoundaryRoot: String = "Sources/Trader/Strategies/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        portfolioBoundary: PortfolioTargetBoundary = .mtp219,
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        activeConcreteStrategies: [String] = Self.requiredActiveConcreteStrategies,
        activeStrategySourceRoots: [String] = Self.requiredActiveStrategySourceRoots,
        nonReleaseActiveStrategySourceRoots: [String] = [],
        callsExecutionClient: Bool = false,
        callsBrokerOrOMS: Bool = false,
        exposesUICommandSurface: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.messageBusBoundary = messageBusBoundary
        self.cacheBoundary = cacheBoundary
        self.portfolioBoundary = portfolioBoundary
        self.riskEngineBoundary = riskEngineBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.activeConcreteStrategies = activeConcreteStrategies
        self.activeStrategySourceRoots = activeStrategySourceRoots
        self.nonReleaseActiveStrategySourceRoots = nonReleaseActiveStrategySourceRoots
        self.callsExecutionClient = callsExecutionClient
        self.callsBrokerOrOMS = callsBrokerOrOMS
        self.exposesUICommandSurface = exposesUICommandSurface
        self.validationAnchors = validationAnchors
    }

    /// Strategies 只能提出 paper-neutral evidence，不能绕过 Trader / Risk / Execution boundary。
    public var dependencyDirectionHeld: Bool {
        targetName == "TraderStrategies"
            && canonicalSourceRoot == "Sources/Trader/Strategies"
            && compiledBoundaryRoot == "Sources/Trader/Strategies/TargetGraph"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && portfolioBoundary.dependencyDirectionHeld
            && riskEngineBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && activeConcreteStrategies == Self.requiredActiveConcreteStrategies
            && activeStrategySourceRoots == Self.requiredActiveStrategySourceRoots
            && nonReleaseActiveStrategySourceRoots.isEmpty
            && callsExecutionClient == false
            && callsBrokerOrOMS == false
            && exposesUICommandSurface == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "Cache",
        "Portfolio",
        "RiskEngine"
    ]

    public static let requiredForbiddenDependencies = [
        "Trader",
        "ExecutionEngine",
        "ExecutionClient",
        "Workbench",
        "Dashboard",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateStreamRuntime",
        "LiveCommandSurface"
    ]

    public static let requiredActiveConcreteStrategies = [
        "EMA",
        "RSI"
    ]

    public static let requiredActiveStrategySourceRoots = [
        "Sources/Trader/Strategies/EMA",
        "Sources/Trader/Strategies/RSI"
    ]

    public static let requiredValidationAnchors = [
        "MTP-219-TRADERSTRATEGIES-TARGET-SPLIT",
        "MTP-219-EMA-ONLY-ACTIVE-STRATEGY-BOUNDARY-HISTORICAL",
        "GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE",
        "MTP-228-TRADERSTRATEGIES-REAL-ROOT-TARGET-PATH",
        "GH-568-TRADERSTRATEGIES-EMA-RSI-ROOT",
        "TVM-RELEASE-V020-TRADERSTRATEGIES-EMA-RSI-ROOT",
        "MTP-219-NO-DIRECT-EXECUTION-GUARD"
    ]

    public static let mtp219 = TraderStrategiesTargetBoundary()
}
