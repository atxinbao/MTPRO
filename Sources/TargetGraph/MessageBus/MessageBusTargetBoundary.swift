import DomainModel

/// `MessageBus` target boundary 只允许依赖 `DomainModel`。
///
/// 现有 `Sources/MessageBus/` 仍含 paper routing 和上层 evidence 类型，MTP-217
/// 不把这些高耦合文件强行搬入新 target；本锚点先建立可编译依赖方向，后续 issue
/// 再按合同退休兼容 envelope。
public struct MessageBusTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let domainModelBoundary: DomainModelTargetBoundary
    public let allowedDependencies: [String]
    public let forbiddenDependencies: [String]
    public let containsRuntimeOrLiveCapability: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "MessageBus",
        canonicalSourceRoot: String = "Sources/MessageBus",
        compiledBoundaryRoot: String = "Sources/TargetGraph/MessageBus",
        retainedCompatibilityEnvelope: String = "Core",
        domainModelBoundary: DomainModelTargetBoundary = .mtp217,
        allowedDependencies: [String] = ["DomainModel"],
        forbiddenDependencies: [String] = Self.requiredForbiddenDependencies,
        containsRuntimeOrLiveCapability: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.domainModelBoundary = domainModelBoundary
        self.allowedDependencies = allowedDependencies
        self.forbiddenDependencies = forbiddenDependencies
        self.containsRuntimeOrLiveCapability = containsRuntimeOrLiveCapability
        self.validationAnchors = validationAnchors
    }

    /// MessageBus 只能站在 DomainModel 之上，不能反向依赖 engine、Trader、UI 或 broker。
    public var dependencyDirectionHeld: Bool {
        targetName == "MessageBus"
            && canonicalSourceRoot == "Sources/MessageBus"
            && compiledBoundaryRoot == "Sources/TargetGraph/MessageBus"
            && retainedCompatibilityEnvelope == "Core"
            && domainModelBoundary.boundaryHeld
            && allowedDependencies == ["DomainModel"]
            && forbiddenDependencies == Self.requiredForbiddenDependencies
            && containsRuntimeOrLiveCapability == false
            && validationAnchors == Self.requiredValidationAnchors
    }

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
        "OMS"
    ]

    public static let requiredValidationAnchors = [
        "MTP-217-MESSAGEBUS-TARGET-SPLIT",
        "MTP-217-FOUNDATION-DEPENDENCY-DIRECTION",
        "MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD"
    ]

    public static let mtp217 = MessageBusTargetBoundary()
}
