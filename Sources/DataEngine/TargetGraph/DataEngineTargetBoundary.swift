import Cache
import DataClient
import DomainModel
import MessageBus

/// `DataEngine` target boundary 表达内部 ingestion / replay / quality layer。
///
/// MTP-227 把 active target boundary anchor 从 `Sources/TargetGraph/DataEngine`
/// 移到 `Sources/DataEngine/TargetGraph`。GH-396 确认 DataEngine 已有 read-only
/// replay plan real target smoke，但 scenario replay / quality implementation 仍因 `CoreError`
/// 依赖保留在 `Core` compatibility envelope，ingest workflow 仍由 `Runtime` envelope 串接
/// DataClient + Persistence。本边界不新增 streaming runtime、private stream、account endpoint
/// 或 broker path。
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
        retainedCompatibilityEnvelope: String = "Core/Runtime(scenario replay, quality, ingest workflow)",
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
            && retainedCompatibilityEnvelope == "Core/Runtime(scenario replay, quality, ingest workflow)"
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
        "MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD",
        "GH-395-DATAENGINE-REAL-TARGET-SMOKE",
        "GH-395-DATAENGINE-READ-ONLY-REPLAY-PLAN",
        "GH-396-DATAENGINE-REPLAY-QUALITY-COREERROR-ENVELOPE-DOCUMENTED",
        "GH-396-DATAENGINE-INGEST-RUNTIME-ENVELOPE-DOCUMENTED"
    ]

    public static let mtp218 = DataEngineTargetBoundary()
}
