import DomainModel
import Foundation

/// PaperSessionLocalControlApplied 是 accepted session-level command 写入 event log 后的本地事实。
///
/// 输入只能是 MTP-48 已校验通过的 `PaperSessionLocalControlCommand`；输出固定属于 `.paper`
/// stream，并保留 command 原文供后续 evidence / read model 消费。该 fact 只表示本地 Paper
/// session control 已被记录，不代表 order submit / cancel / replace、broker action、signed
/// endpoint、account endpoint、listenKey、真实订单或 Live execution 授权。
public struct PaperSessionLocalControlApplied: Codable, Equatable, Sendable {
    public let command: PaperSessionLocalControlCommand
    public let eventStream: EventStreamID
    public let appliedAt: Date

    public var commandID: Identifier {
        command.commandID
    }

    public var sessionID: Identifier {
        command.sessionID
    }

    public var control: PaperSessionLocalControlAction {
        command.control
    }

    public var paperOnlyBoundaryHeld: Bool {
        eventStream == .paper && command.paperOnlyBoundaryHeld
    }

    /// 从 accepted command 构造可追加的本地 Paper session control fact。
    ///
    /// 输入必须保持 `paperOnlyBoundaryHeld == true`；输出只进入 `.paper` event stream，并显式拒绝
    /// 任何通过 Codable payload 把 fact 改写成非 `.paper` stream 或交易执行授权的尝试。
    public init(
        command: PaperSessionLocalControlCommand,
        appliedAt: Date
    ) throws {
        guard command.paperOnlyBoundaryHeld else {
            throw CoreError.paperSessionLocalControlMismatch(
                field: "paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        self.command = command
        self.eventStream = .paper
        self.appliedAt = appliedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let command = try container.decode(PaperSessionLocalControlCommand.self, forKey: .command)
        let eventStream = try container.decode(EventStreamID.self, forKey: .eventStream)
        let appliedAt = try container.decode(Date.self, forKey: .appliedAt)

        guard eventStream == .paper else {
            throw CoreError.paperSessionLocalControlMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: eventStream.rawValue
            )
        }
        try self.init(command: command, appliedAt: appliedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(command, forKey: .command)
        try container.encode(eventStream, forKey: .eventStream)
        try container.encode(appliedAt, forKey: .appliedAt)
    }

    private enum CodingKeys: String, CodingKey {
        case command
        case eventStream
        case appliedAt
    }
}

/// PaperSessionLocalControlEventAppendResult 记录 MTP-49 event boundary 的一次追加结果。
///
/// accepted path 只会产生 `acceptedFact`，rejected path 只会保留 `rejection`；两者都共享同一个
/// append-only envelope，方便后续 replay / read model 在不读取 Runtime object 或数据库 schema 的
/// 情况下消费 session control evidence。
public struct PaperSessionLocalControlEventAppendResult: Equatable, Sendable {
    public let envelope: EventEnvelope
    public let acceptedFact: PaperSessionLocalControlApplied?
    public let rejection: PaperSessionLocalControlRejection?

    public init(
        envelope: EventEnvelope,
        acceptedFact: PaperSessionLocalControlApplied?,
        rejection: PaperSessionLocalControlRejection?
    ) {
        self.envelope = envelope
        self.acceptedFact = acceptedFact
        self.rejection = rejection
    }
}

/// PaperSessionLocalControlEventLogBoundary 把 session-level local control validation 写入 `.paper` stream。
///
/// 该边界只消费 `PaperSessionLocalControlValidation`，并把 accepted command 映射为
/// `sessionControlApplied` fact，把 rejected reason 映射为 `sessionControlRejected` fact。它不生成
/// order command、不调用 Runtime / Adapter、不连接 broker、不读取 account endpoint、不创建 listenKey、
/// 不提交 / 取消 / 替换真实订单，也不提供 Live trading fallback。
public struct PaperSessionLocalControlEventLogBoundary: Equatable, Sendable {
    public init() {}

    /// 追加 session control validation 结果到 append-only event log。
    ///
    /// 输入是 MTP-48 的 validation 结果和显式 `recordedAt`；输出是 `.paper` stream envelope。
    /// sequence 仍由 `AppendOnlyEventLog` 单调分配，调用方不能指定或覆盖 sequence，因此该边界
    /// 保持 append-only facts source 语义。
    @discardableResult
    public func append(
        _ validation: PaperSessionLocalControlValidation,
        to eventLog: inout AppendOnlyEventLog,
        recordedAt: Date
    ) throws -> PaperSessionLocalControlEventAppendResult {
        switch validation {
        case let .accepted(command):
            let fact = try PaperSessionLocalControlApplied(
                command: command,
                appliedAt: recordedAt
            )
            let envelope = try eventLog.append(
                .paper(.sessionControlApplied(fact)),
                stream: .paper,
                recordedAt: recordedAt
            )
            return PaperSessionLocalControlEventAppendResult(
                envelope: envelope,
                acceptedFact: fact,
                rejection: nil
            )
        case let .rejected(rejection):
            let envelope = try eventLog.append(
                .paper(.sessionControlRejected(rejection)),
                stream: .paper,
                recordedAt: recordedAt
            )
            return PaperSessionLocalControlEventAppendResult(
                envelope: envelope,
                acceptedFact: nil,
                rejection: rejection
            )
        }
    }
}
