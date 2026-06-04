/// `DomainModel` target boundary 是 MTP-217 引入、MTP-226 迁入真实 module root 的 SwiftPM foundation target 锚点。
///
/// 该类型只描述 foundation target split 事实和禁止项；MTP-226 只把 active target
/// boundary anchor 从 `Sources/TargetGraph/DomainModel` 移到 `Sources/DomainModel/TargetGraph`，
/// 不改变当前 `Core` compatibility envelope 对既有 `Sources/DomainModel/` 业务类型的编译方式。
public struct DomainModelTargetBoundary: Codable, Equatable, Sendable {
    public let targetName: String
    public let canonicalSourceRoot: String
    public let compiledBoundaryRoot: String
    public let retainedCompatibilityEnvelope: String
    public let dependsOnBusinessTarget: Bool
    public let containsRuntimeOrLiveCapability: Bool
    public let validationAnchors: [String]

    public init(
        targetName: String = "DomainModel",
        canonicalSourceRoot: String = "Sources/DomainModel",
        compiledBoundaryRoot: String = "Sources/DomainModel/TargetGraph",
        retainedCompatibilityEnvelope: String = "Core",
        dependsOnBusinessTarget: Bool = false,
        containsRuntimeOrLiveCapability: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.compiledBoundaryRoot = compiledBoundaryRoot
        self.retainedCompatibilityEnvelope = retainedCompatibilityEnvelope
        self.dependsOnBusinessTarget = dependsOnBusinessTarget
        self.containsRuntimeOrLiveCapability = containsRuntimeOrLiveCapability
        self.validationAnchors = validationAnchors
    }

    /// `DomainModel` 必须是 target graph 最底层，不能依赖 engine、adapter、UI 或 runtime。
    public var boundaryHeld: Bool {
        targetName == "DomainModel"
            && canonicalSourceRoot == "Sources/DomainModel"
            && compiledBoundaryRoot == "Sources/DomainModel/TargetGraph"
            && retainedCompatibilityEnvelope == "Core"
            && dependsOnBusinessTarget == false
            && containsRuntimeOrLiveCapability == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "MTP-217-DOMAINMODEL-TARGET-SPLIT",
        "MTP-217-FOUNDATION-COMPATIBILITY-ENVELOPE-RETAINED",
        "MTP-226-DOMAINMODEL-REAL-ROOT-TARGET-PATH",
        "MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD"
    ]

    public static let mtp217 = DomainModelTargetBoundary()
}
