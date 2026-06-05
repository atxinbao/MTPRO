import DomainModel
import Foundation

/// FoundationMessageTopic 是 MessageBus target 自己拥有的最小 topic 值对象。
///
/// 它只用于本地 target smoke / replay 语义，不暴露 HTTP、broker payload、
/// account payload、database schema 或 UI command surface。
public struct FoundationMessageTopic: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        self.rawValue = try FoundationTargetID(rawValue, field: "messageTopic").rawValue
    }

    public var description: String {
        rawValue
    }
}

/// FoundationMessageEnvelope 是 foundation MessageBus smoke surface 的本地 envelope。
///
/// 该 envelope 只绑定 sequence、topic 和 DomainModel identity，用于证明
/// `MessageBus` target 可独立 import `DomainModel` 并执行最小 publish / replay 行为。
public struct FoundationMessageEnvelope: Codable, Equatable, Sendable {
    public let sequence: Int
    public let topic: FoundationMessageTopic
    public let sourceID: FoundationTargetID
    public let recordedAt: Date

    public init(
        sequence: Int,
        topic: FoundationMessageTopic,
        sourceID: FoundationTargetID,
        recordedAt: Date
    ) throws {
        guard sequence > 0 else {
            throw FoundationTargetOwnershipError.invalidSequence(sequence)
        }
        self.sequence = sequence
        self.topic = topic
        self.sourceID = sourceID
        self.recordedAt = recordedAt
    }
}

/// FoundationMessageStream 是 MessageBus target 的最小 append-only 本地消息流。
///
/// 它不替代仍由 `Core` compatibility envelope 承载的完整 `MessageBus` /
/// event-log implementation；GH-393 只用它证明 foundation target 已拥有可调用 API。
public struct FoundationMessageStream: Equatable, Sendable {
    public private(set) var envelopes: [FoundationMessageEnvelope]

    public init(envelopes: [FoundationMessageEnvelope] = []) throws {
        let expected = envelopes.indices.map { $0 + 1 }
        guard envelopes.map(\.sequence) == expected else {
            throw FoundationTargetOwnershipError.invalidSequence(envelopes.map(\.sequence).first ?? 0)
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func publish(
        topic: FoundationMessageTopic,
        sourceID: FoundationTargetID,
        recordedAt: Date
    ) throws -> FoundationMessageEnvelope {
        let envelope = try FoundationMessageEnvelope(
            sequence: envelopes.count + 1,
            topic: topic,
            sourceID: sourceID,
            recordedAt: recordedAt
        )
        envelopes.append(envelope)
        return envelope
    }

    public func replay(topic: FoundationMessageTopic) -> [FoundationMessageEnvelope] {
        envelopes.filter { $0.topic == topic }
    }
}
