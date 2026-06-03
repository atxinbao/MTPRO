import DomainModel
import MessageBus

/// `Cache` target boundary 表达可从 facts / replay 重建的 read-model state surface。
///
/// MTP-218 不把 Cache 升级成 durable store、Redis clone、broker state cache 或 UI contract；
/// 既有 `Sources/Cache/` implementation 仍由 `Core` compatibility envelope 编译。
public struct CacheTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let readModelStateSurface: Bool
    public let ownsDurableFacts: Bool
    public let ownsBrokerState: Bool
    public let exposesDatabaseSchema: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "Cache",
        canonicalSourceRoot: String = "Sources/Cache",
        compiledBoundaryRoot: String = "Sources/TargetGraph/Cache",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        allowedDependencies: [String] = ["DomainModel", "MessageBus"],
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        readModelStateSurface: Bool = true,
        ownsDurableFacts: Bool = false,
        ownsBrokerState: Bool = false,
        exposesDatabaseSchema: Bool = false,
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
        self.readModelStateSurface = readModelStateSurface
        self.ownsDurableFacts = ownsDurableFacts
        self.ownsBrokerState = ownsBrokerState
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.validationAnchors = validationAnchors
    }

    /// Cache 只能保存可重建 read-model state，不能拥有 durable facts 或 broker state。
    public var dependencyDirectionHeld: Bool {
        targetName == "Cache"
            && canonicalSourceRoot == "Sources/Cache"
            && compiledBoundaryRoot == "Sources/TargetGraph/Cache"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && allowedDependencies == ["DomainModel", "MessageBus"]
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && readModelStateSurface
            && ownsDurableFacts == false
            && ownsBrokerState == false
            && exposesDatabaseSchema == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredForbiddenDependencies = [
        "DatabaseSchema",
        "Trader",
        "TraderStrategies",
        "RiskEngine",
        "ExecutionEngine",
        "ExecutionClient",
        "Workbench",
        "Dashboard",
        "Broker",
        "AccountEndpoint",
        "PrivateStreamRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-218-CACHE-TARGET-SPLIT",
        "MTP-218-READMODEL-STATE-SURFACE",
        "MTP-218-NO-BROKER-STATE-CACHE-GUARD"
    ]

    public static let mtp218 = CacheTargetBoundary()
}
