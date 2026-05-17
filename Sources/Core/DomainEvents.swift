import Foundation

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

/// PaperEvent 表示 Paper 会话生命周期事件，只记录本地模拟信号。
public enum PaperEvent: Codable, Equatable, Sendable {
    case sessionRequested(PaperSessionCommand)
    case signalGenerated(EMACrossSignalSample)
    case sessionCompleted(PaperSessionResult)
}

/// RiskEvent 表示风险评估观察事件，当前只覆盖 Paper 拒绝事实。
public enum RiskEvent: Codable, Equatable, Sendable {
    case evaluationRequested(RiskEvaluationQuery)
    case rejected(Identifier)
}

/// PortfolioEvent 表示组合投影观察事件，不映射真实账户变更。
public enum PortfolioEvent: Codable, Equatable, Sendable {
    case projectionRequested(PortfolioQuery)
    case projectionUpdated(Identifier)
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

/// EventStreamID 标记事件流名称，保证 replay 可按领域 stream 过滤。
public struct EventStreamID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let market = EventStreamID(rawValue: "market")
    public static let strategy = EventStreamID(rawValue: "strategy")
    public static let backtest = EventStreamID(rawValue: "backtest")
    public static let paper = EventStreamID(rawValue: "paper")
    public static let risk = EventStreamID(rawValue: "risk")
    public static let portfolio = EventStreamID(rawValue: "portfolio")
    public static let replay = EventStreamID(rawValue: "replay")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
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

/// EventSequenceRange 表示 replay sequence 过滤范围，拒绝非法边界。
public struct EventSequenceRange: Codable, Equatable, Sendable {
    public let lowerBound: Int?
    public let upperBound: Int?

    public init(lowerBound: Int? = nil, upperBound: Int? = nil) throws {
        if let lowerBound, lowerBound < 1 {
            throw CoreError.invalidSequenceRange
        }
        if let upperBound, upperBound < 1 {
            throw CoreError.invalidSequenceRange
        }
        if let lowerBound, let upperBound, lowerBound > upperBound {
            throw CoreError.invalidSequenceRange
        }
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lowerBound = try container.decodeIfPresent(Int.self, forKey: .lowerBound)
        let upperBound = try container.decodeIfPresent(Int.self, forKey: .upperBound)
        try self.init(lowerBound: lowerBound, upperBound: upperBound)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lowerBound, forKey: .lowerBound)
        try container.encodeIfPresent(upperBound, forKey: .upperBound)
    }

    public func contains(_ sequence: Int) -> Bool {
        if let lowerBound, sequence < lowerBound {
            return false
        }
        if let upperBound, sequence > upperBound {
            return false
        }
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
    }
}

/// EventReplayCommand 描述本地事件重放请求，可按 sequence range 和 stream 过滤。
public struct EventReplayCommand: Codable, Equatable, Sendable {
    public let range: EventSequenceRange
    public let streams: Set<EventStreamID>

    public init(range: EventSequenceRange, streams: Set<EventStreamID> = []) {
        self.range = range
        self.streams = streams
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
