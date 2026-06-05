import DomainModel
import Foundation

/// PaperSessionLifecycleState 定义 Paper session 在 append-only event log 中可观察的本地生命周期。
///
/// 这些状态只描述本地 paper-only session facts：`started` 表示本地会话已由 Core 接收并开始生成
/// 模拟信号，`updated` 表示本地 signal timeline 已刷新，`closed` 表示本地 session 已完成并关闭。
/// 它不代表真实订单、broker session、signed endpoint、account state 或 Live execution。
public enum PaperSessionLifecycleState: String, Codable, CaseIterable, Equatable, Sendable {
    case started
    case updated
    case closed
}

/// PaperSessionStarted 是 Paper session lifecycle 的起始事实。
///
/// 输入来自已通过 `PaperSessionCommand` 校验的 paper-only command；输出只进入 `.paper` event stream，
/// 为后续 replay / projection 提供 session identity、策略、行情查询和 risk profile 的稳定起点。
public struct PaperSessionStarted: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let command: PaperSessionCommand
    public let state: PaperSessionLifecycleState
    public let startedAt: Date

    public init(command: PaperSessionCommand, startedAt: Date) {
        self.sessionID = command.sessionID
        self.command = command
        self.state = .started
        self.startedAt = startedAt
    }
}

/// PaperSessionUpdated 是 Paper session 在本地信号刷新后的生命周期事实。
///
/// `signalCount` 只统计 Core 已生成的 deterministic signal samples，不表示订单数、成交数、
/// broker fill 或 portfolio position。该事件禁止携带任何真实交易能力或外部账户状态。
public struct PaperSessionUpdated: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let command: PaperSessionCommand
    public let state: PaperSessionLifecycleState
    public let signalCount: Int
    public let updatedAt: Date

    public init(
        command: PaperSessionCommand,
        signalCount: Int,
        updatedAt: Date
    ) throws {
        guard signalCount >= 0 else {
            throw CoreError.invalidPaperSessionSignalCount(signalCount)
        }
        self.sessionID = command.sessionID
        self.command = command
        self.state = .updated
        self.signalCount = signalCount
        self.updatedAt = updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let command = try container.decode(PaperSessionCommand.self, forKey: .command)
        let signalCount = try container.decode(Int.self, forKey: .signalCount)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        try self.init(
            command: command,
            signalCount: signalCount,
            updatedAt: updatedAt
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(command, forKey: .command)
        try container.encode(state, forKey: .state)
        try container.encode(signalCount, forKey: .signalCount)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    private enum CodingKeys: String, CodingKey {
        case sessionID
        case command
        case state
        case signalCount
        case updatedAt
    }
}

/// PaperSessionClosed 是 Paper session lifecycle 的关闭事实。
///
/// 输出绑定 `PaperSessionResult`，用于证明本地 session 已完成 signal timeline；它不是订单完成、
/// broker close、account settlement、signed endpoint side effect 或 Live execution fallback。
public struct PaperSessionClosed: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let result: PaperSessionResult
    public let state: PaperSessionLifecycleState
    public let signalCount: Int
    public let closedAt: Date

    public init(result: PaperSessionResult) {
        self.sessionID = result.sessionID
        self.result = result
        self.state = .closed
        self.signalCount = result.signalSamples.count
        self.closedAt = result.completedAt
    }
}

/// PaperSessionEventLogBoundary 是 Paper lifecycle facts 写入 append-only event log 的窄边界。
///
/// 该边界只接收 `PaperEvent`，并固定写入 `.paper` stream；调用方不能借此写入 risk、
/// portfolio、market、broker、signed endpoint 或真实订单事件。`recordedAt` 由调用方显式传入，
/// 让 tests 和 replay evidence 可以保持确定性。
public struct PaperSessionEventLogBoundary: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func append(
        _ event: PaperEvent,
        to eventLog: inout AppendOnlyEventLog,
        recordedAt: Date,
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        try eventLog.append(
            .paper(event),
            stream: .paper,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
    }
}
