import Foundation

/// FoundationTargetOwnershipError 描述 foundation target smoke surface 的最小合同错误。
///
/// 该错误类型只服务 real target ownership smoke tests，用来证明 `DomainModel`
/// target 已能独立编译并暴露非 TargetGraph 的真实 Swift API；它不替代仍由
/// `Core` compatibility envelope 承载的历史 `CoreError`。
public enum FoundationTargetOwnershipError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyIdentifier(String)
    case invalidSequence(Int)
    case sequenceRegression(current: Int, proposed: Int)

    public var description: String {
        switch self {
        case let .emptyIdentifier(field):
            "Foundation target identifier must not be empty: \(field)"
        case let .invalidSequence(value):
            "Foundation target sequence must be positive: \(value)"
        case let .sequenceRegression(current, proposed):
            "Foundation target sequence must be monotonic: current \(current), proposed \(proposed)"
        }
    }
}

/// FoundationTargetID 是 foundation targets 共享的轻量稳定标识。
///
/// 它刻意不读取账户、broker、runtime object 或外部 payload，只提供可测试的
/// local-first identity contract，作为 GH-393 real target smoke tests 的输入。
public struct FoundationTargetID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String, field: String = "foundationTargetID") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw FoundationTargetOwnershipError.emptyIdentifier(field)
        }
        self.rawValue = trimmed
    }

    public var description: String {
        rawValue
    }
}

/// FoundationTargetSourceOwnership 记录一个 foundation API 所属的真实 source root。
///
/// 该类型让 smoke tests 不再只验证 boundary anchor 字符串，而是能创建、比较并
/// 编码 / 解码一个由 `DomainModel` target 自己编译的真实 public value。
public struct FoundationTargetSourceOwnership: Codable, Equatable, Sendable {
    public let ownerID: FoundationTargetID
    public let targetName: String
    public let canonicalSourceRoot: String
    public let ownsRealModuleSourceRoot: Bool

    public init(
        ownerID: FoundationTargetID,
        targetName: String,
        canonicalSourceRoot: String,
        ownsRealModuleSourceRoot: Bool
    ) {
        self.ownerID = ownerID
        self.targetName = targetName
        self.canonicalSourceRoot = canonicalSourceRoot
        self.ownsRealModuleSourceRoot = ownsRealModuleSourceRoot
    }

    public static func domainModel(ownerID: FoundationTargetID) -> FoundationTargetSourceOwnership {
        FoundationTargetSourceOwnership(
            ownerID: ownerID,
            targetName: "DomainModel",
            canonicalSourceRoot: "Sources/DomainModel",
            ownsRealModuleSourceRoot: true
        )
    }
}
