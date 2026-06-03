import DomainModel
import MessageBus

/// `ExecutionClient` target boundary 表达 future-gated outgoing adapter contract。
///
/// MTP-220 只建立可编译的 SwiftPM target anchor。该 target 不能变成 broker SDK wrapper、
/// signed request client、order submit / cancel / replace runtime、execution report parser 或
/// reconciliation runtime；真实交易执行能力继续保持 future-gated。
public struct ExecutionClientTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let futureGateOnly: Bool
    public let implementsBrokerGateway: Bool
    public let implementsSignedEndpoint: Bool
    public let readsAccountEndpointOrListenKey: Bool
    public let connectsPrivateWebSocketRuntime: Bool
    public let implementsOrderSubmitCancelReplace: Bool
    public let parsesExecutionReportOrBrokerFill: Bool
    public let runsReconciliationRuntime: Bool
    public let exposesLiveCommandSurface: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "ExecutionClient",
        canonicalSourceRoot: String = "Sources/ExecutionClient",
        compiledBoundaryRoot: String = "Sources/TargetGraph/ExecutionClient",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        futureGateOnly: Bool = true,
        implementsBrokerGateway: Bool = false,
        implementsSignedEndpoint: Bool = false,
        readsAccountEndpointOrListenKey: Bool = false,
        connectsPrivateWebSocketRuntime: Bool = false,
        implementsOrderSubmitCancelReplace: Bool = false,
        parsesExecutionReportOrBrokerFill: Bool = false,
        runsReconciliationRuntime: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.messageBusBoundary = messageBusBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.futureGateOnly = futureGateOnly
        self.implementsBrokerGateway = implementsBrokerGateway
        self.implementsSignedEndpoint = implementsSignedEndpoint
        self.readsAccountEndpointOrListenKey = readsAccountEndpointOrListenKey
        self.connectsPrivateWebSocketRuntime = connectsPrivateWebSocketRuntime
        self.implementsOrderSubmitCancelReplace = implementsOrderSubmitCancelReplace
        self.parsesExecutionReportOrBrokerFill = parsesExecutionReportOrBrokerFill
        self.runsReconciliationRuntime = runsReconciliationRuntime
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.validationAnchors = validationAnchors
    }

    /// ExecutionClient 只能表达 outgoing adapter future gate，不能持有任何真实 broker / endpoint path。
    public var dependencyDirectionHeld: Bool {
        targetName == "ExecutionClient"
            && canonicalSourceRoot == "Sources/ExecutionClient"
            && compiledBoundaryRoot == "Sources/TargetGraph/ExecutionClient"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && futureGateOnly
            && implementsBrokerGateway == false
            && implementsSignedEndpoint == false
            && readsAccountEndpointOrListenKey == false
            && connectsPrivateWebSocketRuntime == false
            && implementsOrderSubmitCancelReplace == false
            && parsesExecutionReportOrBrokerFill == false
            && runsReconciliationRuntime == false
            && exposesLiveCommandSurface == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus"
    ]

    public static let requiredForbiddenDependencies = [
        "DataClient",
        "DataEngine",
        "Cache",
        "Database",
        "Portfolio",
        "RiskEngine",
        "ExecutionEngine",
        "TraderStrategies",
        "Trader",
        "Workbench",
        "Dashboard",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateWebSocketRuntime",
        "RealOrderLifecycle",
        "LiveCommandSurface"
    ]

    public static let requiredValidationAnchors = [
        "MTP-220-EXECUTIONCLIENT-TARGET-SPLIT",
        "MTP-220-EXECUTIONCLIENT-FUTURE-GATE-ONLY",
        "MTP-220-NO-BROKER-OMS-REAL-ORDER-GUARD"
    ]

    public static let mtp220 = ExecutionClientTargetBoundary()
}
