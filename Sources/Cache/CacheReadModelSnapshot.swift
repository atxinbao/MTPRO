import DomainModel
import Foundation
import MessageBus

/// CacheTargetOwnershipError 描述 Cache target smoke surface 的最小合同错误。
///
/// 该错误只服务 GH-395 real target smoke tests，用来证明 `Cache` target 能独立
/// 使用 `DomainModel` 和 `MessageBus` 类型维护可重建 read-model state。
public enum CacheTargetOwnershipError: Error, Equatable, Sendable, CustomStringConvertible {
    case streamMismatch(expected: String, actual: String)

    public var description: String {
        switch self {
        case let .streamMismatch(expected, actual):
            "Cache read model stream mismatch: expected \(expected), actual \(actual)"
        }
    }
}

/// CacheReadModelSnapshot 是 Cache target 自己拥有的最小 read-model snapshot。
///
/// 它只保存可由 message replay 重建的状态计数和 source identity，不拥有 durable
/// facts、database schema、broker state、account payload 或 runtime object。
public struct CacheReadModelSnapshot: Codable, Equatable, Sendable {
    public let snapshotID: FoundationTargetID
    public let stream: MessageBusJournalStreamID
    public let symbol: Symbol
    public private(set) var appliedEventCount: Int
    public let sourceRoot: String
    public let validationAnchors: [String]

    public init(
        snapshotID: FoundationTargetID,
        stream: MessageBusJournalStreamID,
        symbol: Symbol,
        appliedEventCount: Int = 0,
        sourceRoot: String = "Sources/Cache",
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.snapshotID = snapshotID
        self.stream = stream
        self.symbol = symbol
        self.appliedEventCount = appliedEventCount
        self.sourceRoot = sourceRoot
        self.validationAnchors = validationAnchors
    }

    /// 只根据同一 MessageBus stream 的 envelope 推进 read model 计数。
    public mutating func apply(_ envelope: MessageBusJournalEnvelope) throws {
        guard envelope.stream == stream else {
            throw CacheTargetOwnershipError.streamMismatch(
                expected: stream.rawValue,
                actual: envelope.stream.rawValue
            )
        }
        appliedEventCount += 1
    }

    public var readModelBoundaryHeld: Bool {
        sourceRoot == "Sources/Cache"
            && validationAnchors == Self.requiredValidationAnchors
            && ownsDurableFacts == false
            && ownsBrokerState == false
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
    }

    public var ownsDurableFacts: Bool { false }
    public var ownsBrokerState: Bool { false }
    public var exposesDatabaseSchema: Bool { false }
    public var exposesRuntimeObject: Bool { false }

    public static let requiredValidationAnchors = [
        "GH-395-CACHE-REAL-TARGET-SMOKE",
        "GH-395-CACHE-READ-MODEL-SNAPSHOT"
    ]
}
