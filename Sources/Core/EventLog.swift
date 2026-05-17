import Foundation

/// 事件日志和 MessageBus 只维护 append-only 本地事实流，不写数据库、不读取网络、不触发交易动作。

/// AppendOnlyEventLog 维护单调递增的 append-only 事件数组，是本地事实源。
public struct AppendOnlyEventLog: Equatable, Sendable {
    public private(set) var envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) throws {
        let sequences = envelopes.map(\.sequence)
        let expectedSequences = sequences.indices.map { $0 + 1 }
        guard sequences == expectedSequences else {
            throw CoreError.invalidSequenceRange
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func append(
        _ event: DomainEvent,
        stream: EventStreamID,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        let envelope = try EventEnvelope(
            sequence: envelopes.count + 1,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
        envelopes.append(envelope)
        return envelope
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        let matchedEnvelopes = envelopes.filter { envelope in
            command.range.contains(envelope.sequence)
                && (command.streams.isEmpty || command.streams.contains(envelope.stream))
        }
        return EventReplayResult(command: command, envelopes: matchedEnvelopes)
    }
}

/// MessageBus 只负责把领域事件写入只追加事件流并按命令重放。
public struct MessageBus: Equatable, Sendable {
    private var eventLog: AppendOnlyEventLog

    public init(envelopes: [EventEnvelope] = []) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: envelopes)
    }

    public var envelopes: [EventEnvelope] {
        eventLog.envelopes
    }

    @discardableResult
    public mutating func publish(
        _ event: DomainEvent,
        stream: EventStreamID,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        try eventLog.append(
            event,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        eventLog.replay(command)
    }
}
