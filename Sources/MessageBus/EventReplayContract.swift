import DomainModel

/// EventStreamID 标记本地事实流名称，保证 replay 可按领域 stream 过滤。
///
/// 这里仍只是 MessageBus 的中立 stream identity；具体 event payload 可能仍由
/// Core compatibility envelope 承载，直到后续按模块依赖方向继续拆分。
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
