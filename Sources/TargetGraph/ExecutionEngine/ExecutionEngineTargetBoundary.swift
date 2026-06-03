import Cache
import DomainModel
import ExecutionClient
import MessageBus
import Portfolio
import RiskEngine

/// `ExecutionEngine` target boundary 表达 paper / simulated execution lifecycle layer。
///
/// MTP-220 只把 ExecutionEngine 拆成 buildable target anchor，并连接 RiskEngine 与
/// ExecutionClient future gate。它不实现 live execution runtime、OMS、broker gateway、
/// signed endpoint 或真实订单生命周期。
public struct ExecutionEngineTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let portfolioBoundary: PortfolioTargetBoundary
    public let riskEngineBoundary: RiskEngineTargetBoundary
    public let executionClientBoundary: ExecutionClientTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let paperSimulatedLifecycleBoundary: Bool
    public let consumesRiskEngineBoundary: Bool
    public let executionClientFutureGateOnly: Bool
    public let implementsLiveExecutionRuntime: Bool
    public let implementsOMS: Bool
    public let implementsBrokerGateway: Bool
    public let callsSignedOrAccountEndpoint: Bool
    public let createsListenKeyOrPrivateWebSocket: Bool
    public let implementsRealOrderLifecycle: Bool
    public let exposesLiveCommandSurface: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "ExecutionEngine",
        canonicalSourceRoot: String = "Sources/ExecutionEngine",
        compiledBoundaryRoot: String = "Sources/TargetGraph/ExecutionEngine",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        portfolioBoundary: PortfolioTargetBoundary = .mtp219,
        riskEngineBoundary: RiskEngineTargetBoundary = .mtp219,
        executionClientBoundary: ExecutionClientTargetBoundary = .mtp220,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        paperSimulatedLifecycleBoundary: Bool = true,
        consumesRiskEngineBoundary: Bool = true,
        executionClientFutureGateOnly: Bool = true,
        implementsLiveExecutionRuntime: Bool = false,
        implementsOMS: Bool = false,
        implementsBrokerGateway: Bool = false,
        callsSignedOrAccountEndpoint: Bool = false,
        createsListenKeyOrPrivateWebSocket: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
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
        self.portfolioBoundary = portfolioBoundary
        self.riskEngineBoundary = riskEngineBoundary
        self.executionClientBoundary = executionClientBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.paperSimulatedLifecycleBoundary = paperSimulatedLifecycleBoundary
        self.consumesRiskEngineBoundary = consumesRiskEngineBoundary
        self.executionClientFutureGateOnly = executionClientFutureGateOnly
        self.implementsLiveExecutionRuntime = implementsLiveExecutionRuntime
        self.implementsOMS = implementsOMS
        self.implementsBrokerGateway = implementsBrokerGateway
        self.callsSignedOrAccountEndpoint = callsSignedOrAccountEndpoint
        self.createsListenKeyOrPrivateWebSocket = createsListenKeyOrPrivateWebSocket
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.validationAnchors = validationAnchors
    }

    /// ExecutionEngine 只承接 RiskEngine 后的 paper / simulated execution evidence。
    public var dependencyDirectionHeld: Bool {
        targetName == "ExecutionEngine"
            && canonicalSourceRoot == "Sources/ExecutionEngine"
            && compiledBoundaryRoot == "Sources/TargetGraph/ExecutionEngine"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && portfolioBoundary.dependencyDirectionHeld
            && riskEngineBoundary.dependencyDirectionHeld
            && executionClientBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && paperSimulatedLifecycleBoundary
            && consumesRiskEngineBoundary
            && executionClientFutureGateOnly
            && implementsLiveExecutionRuntime == false
            && implementsOMS == false
            && implementsBrokerGateway == false
            && callsSignedOrAccountEndpoint == false
            && createsListenKeyOrPrivateWebSocket == false
            && implementsRealOrderLifecycle == false
            && exposesLiveCommandSurface == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "Cache",
        "Portfolio",
        "RiskEngine",
        "ExecutionClient"
    ]

    public static let requiredForbiddenDependencies = [
        "DataClient",
        "DataEngine",
        "Database",
        "TraderStrategies",
        "Trader",
        "Workbench",
        "Dashboard",
        "Broker",
        "OMSImplementation",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateWebSocketRuntime",
        "RealOrderLifecycle",
        "LiveCommandSurface"
    ]

    public static let requiredValidationAnchors = [
        "MTP-220-EXECUTIONENGINE-TARGET-SPLIT",
        "MTP-220-RISKENGINE-EXECUTIONENGINE-EXECUTIONCLIENT-DIRECTION",
        "MTP-220-NO-BROKER-OMS-REAL-ORDER-GUARD"
    ]

    public static let mtp220 = ExecutionEngineTargetBoundary()
}
