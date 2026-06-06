import DomainModel
import ExecutionEngine
import Foundation
import MessageBus
import Portfolio

/// 领域事件和 envelope 定义 append-only event log 的事实格式，事件只来自 Core 合同内的本地行为。

/// OrderBookImbalanceResearchEvent 表示订单簿研究生命周期事件，不包含交易执行。
public enum OrderBookImbalanceResearchEvent: Codable, Equatable, Sendable {
    case requested(OrderBookImbalanceResearchCommand)
    case signalGenerated(OrderBookImbalanceSignalSample)
    case completed(OrderBookImbalanceResearchResult)
}

/// BacktestEvent 表示回测生命周期事件，只记录本地信号和完成事实。
public enum BacktestEvent: Codable, Equatable, Sendable {
    case requested(BacktestCommand)
    case signalGenerated(EMACrossSignalSample)
    case completed(BacktestResult)
}

/// PaperEvent 表示 Paper 会话生命周期事件，只记录本地 paper-only lifecycle 和模拟信号。
///
/// MTP-31 起新增 `sessionStarted`、`sessionUpdated` 和 `sessionClosed` 作为稳定 lifecycle facts。
/// MTP-35 起新增 `actionProposed`，让 proposal 可以作为 paper-only replay fact 进入 `.paper`
/// stream。MTP-42 起新增 execution decision / paper order / simulated fill facts，用于把
/// allowed 本地执行证据写入 append-only event log 后再 replay。MTP-49 起新增 session-level
/// local control applied / rejected facts，用于把 Workbench 控制意图记录为本地 paper-only
/// evidence；MTP-99 起新增 order local lifecycle transition fact，用于记录本地 lifecycle coordinator
/// 的 proposed / submitted local / accepted local / rejected / cancelled / expired / failed 状态转换。
/// 这些 facts 不创建真实订单、不连接 broker、不调用 signed endpoint。历史 `sessionRequested` /
/// `sessionCompleted` 仍可被 replay，用于兼容既有本地事件日志；新事件流默认写入 started /
/// updated / closed，不连接 broker、不提交订单、不调用 signed endpoint。
public enum PaperEvent: Codable, Equatable, Sendable {
    case sessionStarted(PaperSessionStarted)
    case sessionUpdated(PaperSessionUpdated)
    case sessionClosed(PaperSessionClosed)
    case sessionControlApplied(PaperSessionLocalControlApplied)
    case sessionControlRejected(PaperSessionLocalControlRejection)
    case actionProposed(PaperActionProposal)
    case executionDecisionRecorded(PaperExecutionDecision)
    case orderIntentRecorded(PaperOrderIntent)
    case orderLocalLifecycleTransitionRecorded(PaperOrderLocalLifecycleTransition)
    case simulatedFillRecorded(PaperSimulatedFillEvidence)
    case sessionRequested(PaperSessionCommand)
    case signalGenerated(EMACrossSignalSample)
    case sessionCompleted(PaperSessionResult)
}

/// PortfolioEvent 表示组合投影观察事件，不映射真实账户变更。
public enum PortfolioEvent: Codable, Equatable, Sendable {
    case projectionRequested(PortfolioQuery)
    /// MTP-34 paper-only update 来自 allowed risk decision，只驱动本地 projection，不同步真实账户。
    case paperProjectionUpdated(PaperPortfolioProjectionUpdate)
    /// MTP-101 v2 snapshot 来自 replayed simulated fill evidence，只表达本地 sandbox 账本。
    case paperAccountPortfolioProjectionUpdated(PaperAccountPortfolioProjectionV2Snapshot)
    case exposureUpdated(PortfolioExposureSnapshot)
}

/// ReplayEvent 记录 replay command 和回放数量，用于审计本地重放行为。
public struct ReplayEvent: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let replayedCount: Int

    public init(command: EventReplayCommand, replayedCount: Int) {
        self.command = command
        self.replayedCount = replayedCount
    }
}

/// DomainEvent 聚合所有可写入 append-only event log 的事实类型。
public enum DomainEvent: Codable, Equatable, Sendable {
    case market(MarketEvent)
    case strategySignal(StrategySignalEvent)
    case orderBookImbalanceResearch(OrderBookImbalanceResearchEvent)
    case backtest(BacktestEvent)
    case paper(PaperEvent)
    case risk(RiskEvent)
    case portfolio(PortfolioEvent)
    case replay(ReplayEvent)
}

/// EventEnvelope 包装领域事件、单调 sequence 和因果关系，是事件日志的稳定事实格式。
public struct EventEnvelope: Codable, Equatable, Sendable {
    public let id: UUID
    public let sequence: Int
    public let stream: EventStreamID
    public let recordedAt: Date
    public let correlationID: UUID?
    public let causationID: UUID?
    public let event: DomainEvent

    public init(
        id: UUID = UUID(),
        sequence: Int,
        stream: EventStreamID,
        recordedAt: Date,
        correlationID: UUID? = nil,
        causationID: UUID? = nil,
        event: DomainEvent
    ) throws {
        guard sequence > 0 else {
            throw CoreError.invalidEventSequence(sequence)
        }
        self.id = id
        self.sequence = sequence
        self.stream = stream
        self.recordedAt = recordedAt
        self.correlationID = correlationID
        self.causationID = causationID
        self.event = event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let sequence = try container.decode(Int.self, forKey: .sequence)
        let stream = try container.decode(EventStreamID.self, forKey: .stream)
        let recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        let correlationID = try container.decodeIfPresent(UUID.self, forKey: .correlationID)
        let causationID = try container.decodeIfPresent(UUID.self, forKey: .causationID)
        let event = try container.decode(DomainEvent.self, forKey: .event)
        try self.init(
            id: id,
            sequence: sequence,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(stream, forKey: .stream)
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encodeIfPresent(correlationID, forKey: .correlationID)
        try container.encodeIfPresent(causationID, forKey: .causationID)
        try container.encode(event, forKey: .event)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case sequence
        case stream
        case recordedAt
        case correlationID
        case causationID
        case event
    }
}

/// EventReplayResult 返回 replay command 与匹配 envelope，供 cache 和 projection 重建。
public struct EventReplayResult: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let envelopes: [EventEnvelope]

    public init(command: EventReplayCommand, envelopes: [EventEnvelope]) {
        self.command = command
        self.envelopes = envelopes
    }
}
