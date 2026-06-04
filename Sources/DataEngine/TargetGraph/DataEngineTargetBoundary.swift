import Cache
import DataClient
import DomainModel
import MessageBus

/// `DataEngine` target boundary 表达内部 ingestion / replay / quality layer。
///
/// MTP-227 只把 active target boundary anchor 从 `Sources/TargetGraph/DataEngine`
/// 移到 `Sources/DataEngine/TargetGraph`。现有 ingest / replay / quality implementation
/// 仍由 `Core` / `Runtime` compatibility envelope 编译，不新增 streaming runtime、
/// private stream、account endpoint 或 broker path。
public struct DataEngineTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let dataClientBoundary: DataClientTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let cacheBoundary: CacheTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let ingestReplayQualityBoundary: Bool
    public let implementsPrivateStreamRuntime: Bool
    public let callsSignedOrAccountEndpoint: Bool
    public let routesBrokerOrExecutionCommand: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "DataEngine",
        canonicalSourceRoot: String = "Sources/DataEngine",
        compiledBoundaryRoot: String = "Sources/DataEngine/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core/Runtime",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        dataClientBoundary: DataClientTargetBoundary = .mtp218,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        cacheBoundary: CacheTargetBoundary = .mtp218,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        ingestReplayQualityBoundary: Bool = true,
        implementsPrivateStreamRuntime: Bool = false,
        callsSignedOrAccountEndpoint: Bool = false,
        routesBrokerOrExecutionCommand: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.dataClientBoundary = dataClientBoundary
        self.messageBusBoundary = messageBusBoundary
        self.cacheBoundary = cacheBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.ingestReplayQualityBoundary = ingestReplayQualityBoundary
        self.implementsPrivateStreamRuntime = implementsPrivateStreamRuntime
        self.callsSignedOrAccountEndpoint = callsSignedOrAccountEndpoint
        self.routesBrokerOrExecutionCommand = routesBrokerOrExecutionCommand
        self.validationAnchors = validationAnchors
    }

    /// DataEngine 只能解释 public data / replay / quality evidence，不能绕到 broker 或 UI。
    public var dependencyDirectionHeld: Bool {
        targetName == "DataEngine"
            && canonicalSourceRoot == "Sources/DataEngine"
            && compiledBoundaryRoot == "Sources/DataEngine/TargetGraph"
            && retainedCompatibilityEnvelope == "Core/Runtime"
            && domainModelBoundary.boundaryHeld
            && dataClientBoundary.dependencyDirectionHeld
            && messageBusBoundary.dependencyDirectionHeld
            && cacheBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && ingestReplayQualityBoundary
            && implementsPrivateStreamRuntime == false
            && callsSignedOrAccountEndpoint == false
            && routesBrokerOrExecutionCommand == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "DataClient",
        "MessageBus",
        "Cache"
    ]

    public static let requiredForbiddenDependencies = [
        "Trader",
        "TraderStrategies",
        "Portfolio",
        "RiskEngine",
        "ExecutionEngine",
        "ExecutionClient",
        "Workbench",
        "Dashboard",
        "Broker",
        "OMS",
        "SignedEndpoint",
        "AccountEndpoint",
        "ListenKey",
        "PrivateStreamRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-218-DATAENGINE-TARGET-SPLIT",
        "MTP-218-DATACLIENT-DATAENGINE-CACHE-DEPENDENCY-DIRECTION",
        "MTP-227-DATAENGINE-REAL-ROOT-TARGET-PATH",
        "MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD"
    ]

    public static let mtp218 = DataEngineTargetBoundary()
}
