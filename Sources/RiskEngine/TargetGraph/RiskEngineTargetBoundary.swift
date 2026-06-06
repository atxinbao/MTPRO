import Cache
import DomainModel
import MessageBus
import Portfolio

/// `RiskEngine` target boundary 表达 Portfolio 之后、ExecutionEngine 之前的 pre-execution risk 层。
///
/// MTP-228 只把 active target boundary anchor 从 `Sources/TargetGraph/RiskEngine`
/// 移到 `Sources/RiskEngine/TargetGraph`。GH-417 继续把 pure paper pre-trade
/// implementation ownership 迁入 RiskEngine target；Core 只保留 EventLog publish/replay
/// compatibility bridge。RiskEngine 不升级成 live risk runtime、broker gateway 或
/// ExecutionClient wrapper。
public struct RiskEngineTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let portfolioBoundary: PortfolioTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let preExecutionBoundary: Bool
    public let implementsLiveRiskRuntime: Bool
    public let callsBrokerOrExecutionClient: Bool
    public let readsSignedOrAccountEndpoint: Bool
    public let routesExecutableOrderCommand: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "RiskEngine",
        canonicalSourceRoot: String = "Sources/RiskEngine",
        compiledBoundaryRoot: String = "Sources/RiskEngine/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core(event bridge deferred)",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        portfolioBoundary: PortfolioTargetBoundary = .mtp219,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        preExecutionBoundary: Bool = true,
        implementsLiveRiskRuntime: Bool = false,
        callsBrokerOrExecutionClient: Bool = false,
        readsSignedOrAccountEndpoint: Bool = false,
        routesExecutableOrderCommand: Bool = false,
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
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.preExecutionBoundary = preExecutionBoundary
        self.implementsLiveRiskRuntime = implementsLiveRiskRuntime
        self.callsBrokerOrExecutionClient = callsBrokerOrExecutionClient
        self.readsSignedOrAccountEndpoint = readsSignedOrAccountEndpoint
        self.routesExecutableOrderCommand = routesExecutableOrderCommand
        self.validationAnchors = validationAnchors
    }

    /// RiskEngine 只能做 pre-execution guard，不持有 broker、endpoint 或 executable order path。
    public var dependencyDirectionHeld: Bool {
        targetName == "RiskEngine"
            && canonicalSourceRoot == "Sources/RiskEngine"
            && compiledBoundaryRoot == "Sources/RiskEngine/TargetGraph"
            && retainedCompatibilityEnvelope == "Core(event bridge deferred)"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && portfolioBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && preExecutionBoundary
            && implementsLiveRiskRuntime == false
            && callsBrokerOrExecutionClient == false
            && readsSignedOrAccountEndpoint == false
            && routesExecutableOrderCommand == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "Cache",
        "Portfolio"
    ]

    public static let requiredForbiddenDependencies = [
        "Trader",
        "TraderStrategies",
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
        "LiveRiskRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-219-RISKENGINE-TARGET-SPLIT",
        "MTP-219-PRE-EXECUTION-RISK-BOUNDARY",
        "GH-397-RISKENGINE-REAL-TARGET-SMOKE",
        "MTP-228-RISKENGINE-REAL-ROOT-TARGET-PATH",
        "GH-417-RISKENGINE-PAPER-PRETRADE-OWNERSHIP",
        "GH-417-CORE-RISKENGINE-EVENT-BRIDGE-ONLY",
        "GH-417-RISKENGINE-NO-EXECUTIONCLIENT-OMS-BROKER-GUARD",
        "GH-417-VALIDATION-ANCHORS",
        "MTP-219-NO-DIRECT-EXECUTION-GUARD"
    ]

    public static let mtp219 = RiskEngineTargetBoundary()
}
