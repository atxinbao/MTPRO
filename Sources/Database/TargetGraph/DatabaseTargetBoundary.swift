import DomainModel
import MessageBus

/// `Database` target boundary 建立 foundation persistence target 的 SwiftPM 依赖方向。
///
/// MTP-226 只把 active target boundary anchor 从 `Sources/TargetGraph/Database`
/// 移到 `Sources/Database/TargetGraph`。SQLite / DuckDB projection implementation 仍由
/// `Persistence` compatibility envelope 编译，replay projection 仍由 `Runtime` 编译；
/// 当前 issue 不改变 persistence behavior，也不暴露 UI、Trader、broker、account payload 或 live runtime。
public struct DatabaseTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let messageBusBoundary: MessageBusTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let containsRuntimeOrLiveCapability: Bool
    public let exposesSchemaToWorkbench: Bool
    public let persistsBrokerOrAccountPayload: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "Database",
        canonicalSourceRoot: String = "Sources/Database",
        compiledBoundaryRoot: String = "Sources/Database/TargetGraph",
        retainedCompatibilityEnvelope: String = "Persistence",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        messageBusBoundary: MessageBusTargetBoundary = .mtp217,
        allowedDependencies: [String] = Self.requiredAllowedDependencies,
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        containsRuntimeOrLiveCapability: Bool = false,
        exposesSchemaToWorkbench: Bool = false,
        persistsBrokerOrAccountPayload: Bool = false,
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
        self.containsRuntimeOrLiveCapability = containsRuntimeOrLiveCapability
        self.exposesSchemaToWorkbench = exposesSchemaToWorkbench
        self.persistsBrokerOrAccountPayload = persistsBrokerOrAccountPayload
        self.validationAnchors = validationAnchors
    }

    /// Database 只能承接本地 durable facts / projection 边界，不成为 UI schema 或 broker store。
    public var dependencyDirectionHeld: Bool {
        targetName == "Database"
            && canonicalSourceRoot == "Sources/Database"
            && compiledBoundaryRoot == "Sources/Database/TargetGraph"
            && retainedCompatibilityEnvelope == "Persistence"
            && domainModelBoundary.boundaryHeld
            && messageBusBoundary.dependencyDirectionHeld
            && allowedDependencies == Self.requiredAllowedDependencies
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && containsRuntimeOrLiveCapability == false
            && exposesSchemaToWorkbench == false
            && persistsBrokerOrAccountPayload == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredAllowedDependencies = [
        "DomainModel",
        "MessageBus",
        "CSQLite",
        "DuckDB(macOS)"
    ]

    public static let requiredForbiddenDependencies = [
        "DataEngine",
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
        "AccountEndpoint",
        "PrivateStreamRuntime"
    ]

    public static let requiredValidationAnchors = [
        "MTP-217-DATABASE-TARGET-SPLIT",
        "MTP-217-FOUNDATION-DEPENDENCY-DIRECTION",
        "MTP-217-DATABASE-COMPATIBILITY-ENVELOPE-RETAINED",
        "MTP-226-DATABASE-REAL-ROOT-TARGET-PATH",
        "MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD"
    ]

    public static let mtp217 = DatabaseTargetBoundary()
}
