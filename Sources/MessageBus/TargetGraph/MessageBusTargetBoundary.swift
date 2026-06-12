import DomainModel

/// `MessageBus` target boundary 只允许依赖 `DomainModel`。
///
/// MTP-226 只把 active target boundary anchor 从 `Sources/TargetGraph/MessageBus`
/// 移到 `Sources/MessageBus/TargetGraph`，不把 paper routing / 上层 evidence 类型
/// 强行并入 `MessageBus` target implementation；GH-394 起 `MessageBus` 直接拥有
/// 中立 append-only journal；GH-414 起 `MessageBus` 直接拥有中立 query / replay
/// 合同。旧 paper routing / downstream evidence 仍留在 `Core` compatibility
/// envelope，等待后续专门迁移。GH-632 起 rich routing compatibility 的归属判定
/// 已由 `MessageBus` target 内的 `MessageBusRichRoutingCompatibilityContract` 拥有。
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
        compiledBoundaryRoot: String = "Sources/MessageBus/TargetGraph",
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
            && compiledBoundaryRoot == "Sources/MessageBus/TargetGraph"
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
        "MTP-226-MESSAGEBUS-REAL-ROOT-TARGET-PATH",
        "GH-393-MESSAGEBUS-REAL-TARGET-SMOKE",
        "GH-394-MESSAGEBUS-NEUTRAL-JOURNAL-OWNERSHIP",
        "GH-414-MESSAGEBUS-NEUTRAL-QUERY-REPLAY-OWNERSHIP",
        "GH-414-CORE-RICH-MESSAGEBUS-COMPATIBILITY-ENVELOPE",
        "GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT",
        "MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD"
    ]

    public static let mtp217 = MessageBusTargetBoundary()
}
