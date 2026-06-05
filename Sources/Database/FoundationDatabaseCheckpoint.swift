import DomainModel
import Foundation
import MessageBus

/// FoundationDatabaseCheckpoint 是 Database target 的最小 durable-position 合同。
///
/// 该类型只记录本地 projection checkpoint 的 monotonic sequence，证明 `Database`
/// target 能独立 import `DomainModel` / `MessageBus` 并暴露非 TargetGraph API。
/// 它不打开 SQLite / DuckDB，不暴露 schema，不保存 broker / account payload。
public struct FoundationDatabaseCheckpoint: Codable, Equatable, Sendable {
    public let checkpointID: FoundationTargetID
    public let sourceRoot: String
    public private(set) var lastAppliedSequence: Int

    public init(
        checkpointID: FoundationTargetID,
        sourceRoot: String = "Sources/Database",
        lastAppliedSequence: Int = 0
    ) throws {
        guard lastAppliedSequence >= 0 else {
            throw FoundationTargetOwnershipError.invalidSequence(lastAppliedSequence)
        }
        self.checkpointID = checkpointID
        self.sourceRoot = sourceRoot
        self.lastAppliedSequence = lastAppliedSequence
    }

    public mutating func apply(_ envelope: FoundationMessageEnvelope) throws {
        guard envelope.sequence > lastAppliedSequence else {
            throw FoundationTargetOwnershipError.sequenceRegression(
                current: lastAppliedSequence,
                proposed: envelope.sequence
            )
        }
        lastAppliedSequence = envelope.sequence
    }

    public var ownsDatabaseSourceRoot: Bool {
        sourceRoot == "Sources/Database"
    }
}
