import Cache
import DomainModel
import MessageBus
import Portfolio
import RiskEngine

/// `TraderStrategies` target boundary 表达 Trader-owned concrete strategy definitions。
///
/// MTP-228 只把 active target boundary anchor 从 `Sources/TargetGraph/TraderStrategies`
/// 移到 `Sources/Trader/Strategies/EMA/TargetGraph`。当前 active concrete strategy 仍只能是 EMA；
/// 非 EMA strategy 只能作为 future candidate 或 historical evidence 出现，不能作为 active
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
    public let nonEMAActiveStrategySourceRoots: [String]
    public let callsExecutionClient: Bool
    public let callsBrokerOrOMS: Bool
    public let exposesUICommandSurface: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "TraderStrategies",
        canonicalSourceRoot: String = "Sources/Trader/Strategies",
        compiledBoundaryRoot: String = "Sources/Trader/Strategies/EMA/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        portfolioBoundary: PortfolioTargetBoundary = .mtp219,
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        activeConcreteStrategies: [String] = ["EMA"],
        activeStrategySourceRoots: [String] = ["Sources/Trader/Strategies/EMA"],
        nonEMAActiveStrategySourceRoots: [String] = [],
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
        self.nonEMAActiveStrategySourceRoots = nonEMAActiveStrategySourceRoots
        self.callsExecutionClient = callsExecutionClient
        self.callsBrokerOrOMS = callsBrokerOrOMS
        self.exposesUICommandSurface = exposesUICommandSurface
        self.validationAnchors = validationAnchors
    }

    /// Strategies 只能提出 paper-neutral evidence，不能绕过 Trader / Risk / Execution boundary。
    public var dependencyDirectionHeld: Bool {
        targetName == "TraderStrategies"
            && canonicalSourceRoot == "Sources/Trader/Strategies"
            && compiledBoundaryRoot == "Sources/Trader/Strategies/EMA/TargetGraph"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && portfolioBoundary.dependencyDirectionHeld
            && riskEngineBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && activeConcreteStrategies == ["EMA"]
            && activeStrategySourceRoots == ["Sources/Trader/Strategies/EMA"]
            && nonEMAActiveStrategySourceRoots.isEmpty
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

    public static let requiredValidationAnchors = [
        "MTP-219-TRADERSTRATEGIES-TARGET-SPLIT",
        "MTP-219-EMA-ONLY-ACTIVE-STRATEGY-BOUNDARY",
        "GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE",
        "MTP-228-TRADERSTRATEGIES-REAL-ROOT-TARGET-PATH",
        "MTP-219-NO-DIRECT-EXECUTION-GUARD"
    ]

    public static let mtp219 = TraderStrategiesTargetBoundary()
}
