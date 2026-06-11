import DomainModel
import Foundation

/// MessageBusJournalError 描述 `MessageBus` target 自己拥有的 append-only journal 合同错误。
///
/// 它只覆盖本地消息序列和 stream 过滤，不引用 Trader、RiskEngine、ExecutionEngine、
/// ExecutionClient、broker payload、account payload、OMS 或 Live runtime 类型。
public enum MessageBusJournalError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidSequence(Int)
    case nonContiguousSequence(expected: Int, actual: Int)

    public var description: String {
        switch self {
        case let .invalidSequence(value):
            "Message sequence must be positive: \(value)"
        case let .nonContiguousSequence(expected, actual):
            "Message sequence must be contiguous: expected \(expected), actual \(actual)"
        }
    }
}

/// MessageBusJournalStreamID 是 `MessageBus` target 的中性 stream identity。
///
/// 它通过 `DomainModel.FoundationTargetID` 复用底层 identity 校验，但不表达具体
/// paper、portfolio、risk 或 execution payload，因此不会形成上层模块反向依赖。
public struct MessageBusJournalStreamID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        self.rawValue = try FoundationTargetID(rawValue, field: "messageBusJournalStream").rawValue
    }

    public var description: String {
        rawValue
    }
}

/// MessageBusJournalEnvelope 是 `MessageBus` target 直接拥有的 append-only envelope。
///
/// `payloadType` 只保存可审计的类型标签，不保存 runtime object、broker payload、
/// account payload、database schema 或 UI command；真实业务 payload 的 rich event
/// compatibility 仍由 `Core` envelope 后续分阶段迁移。
public struct MessageBusJournalEnvelope: Codable, Equatable, Sendable {
    public let sequence: Int
    public let stream: MessageBusJournalStreamID
    public let sourceID: FoundationTargetID
    public let payloadType: String
    public let instrumentID: InstrumentIdentity?
    public let recordedAt: Date

    public init(
        sequence: Int,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        instrumentID: InstrumentIdentity?,
        recordedAt: Date
    ) throws {
        guard sequence > 0 else {
            throw MessageBusJournalError.invalidSequence(sequence)
        }
        self.sequence = sequence
        self.stream = stream
        self.sourceID = sourceID
        self.payloadType = try FoundationTargetID(payloadType, field: "messageBusJournalPayloadType").rawValue
        self.instrumentID = instrumentID
        self.recordedAt = recordedAt
    }

    public init(
        sequence: Int,
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        recordedAt: Date
    ) throws {
        try self.init(
            sequence: sequence,
            stream: stream,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: nil,
            recordedAt: recordedAt
        )
    }

    public var productType: ProductType? {
        instrumentID?.productType
    }
}

/// MessageBusAppendOnlyJournal 是 `MessageBus` target 的真实 source-root journal 实现。
///
/// 它用于证明 `MessageBus` 不再只是 `TargetGraph` boundary anchor：target 内已经
/// 有可独立 import、append、replay 的本地消息实现。该实现故意保持中性，不接入
/// signed endpoint、account endpoint、broker、OMS、ExecutionClient implementation、
/// Trader runtime、Strategy runtime、Live runtime 或 L4 command path。
public struct MessageBusAppendOnlyJournal: Equatable, Sendable {
    public private(set) var envelopes: [MessageBusJournalEnvelope]

    public init(envelopes: [MessageBusJournalEnvelope] = []) throws {
        for (index, envelope) in envelopes.enumerated() {
            let expected = index + 1
            guard envelope.sequence == expected else {
                throw MessageBusJournalError.nonContiguousSequence(
                    expected: expected,
                    actual: envelope.sequence
                )
            }
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func append(
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        instrumentID: InstrumentIdentity?,
        recordedAt: Date
    ) throws -> MessageBusJournalEnvelope {
        let envelope = try MessageBusJournalEnvelope(
            sequence: envelopes.count + 1,
            stream: stream,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: instrumentID,
            recordedAt: recordedAt
        )
        envelopes.append(envelope)
        return envelope
    }

    @discardableResult
    public mutating func append(
        stream: MessageBusJournalStreamID,
        sourceID: FoundationTargetID,
        payloadType: String,
        recordedAt: Date
    ) throws -> MessageBusJournalEnvelope {
        try append(
            stream: stream,
            sourceID: sourceID,
            payloadType: payloadType,
            instrumentID: nil,
            recordedAt: recordedAt
        )
    }

    public func replay(stream: MessageBusJournalStreamID) -> [MessageBusJournalEnvelope] {
        envelopes.filter { $0.stream == stream }
    }
}
