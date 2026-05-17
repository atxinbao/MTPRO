import Foundation

/// TradingKernel actor 串行化只读行情 ingest，当前边界不包含策略调度、数据库或 Live execution。

/// DataEngine 把只读行情事件同时写入 cache 和 MessageBus。
public struct DataEngine: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func ingest(
        _ event: MarketEvent,
        cache: inout MarketDataCache,
        messageBus: inout MessageBus,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        let envelope = try messageBus.publish(
            .market(event),
            stream: .market,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
        cache.ingest(event)
        return envelope
    }
}

/// TradingKernel actor 是当前 issue 的最小运行时边界，不包含策略、数据库或 Live 执行。
public actor TradingKernel {
    private var messageBus: MessageBus
    private var cache: MarketDataCache
    private let dataEngine: DataEngine

    public init(
        messageBus: MessageBus,
        cache: MarketDataCache = MarketDataCache(),
        dataEngine: DataEngine = DataEngine()
    ) {
        self.messageBus = messageBus
        self.cache = cache
        self.dataEngine = dataEngine
    }

    public init() throws {
        self.messageBus = try MessageBus()
        self.cache = MarketDataCache()
        self.dataEngine = DataEngine()
    }

    @discardableResult
    public func ingestMarketEvent(
        _ event: MarketEvent,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        try dataEngine.ingest(
            event,
            cache: &cache,
            messageBus: &messageBus,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID
        )
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        messageBus.replay(command)
    }

    public func eventStream() -> [EventEnvelope] {
        messageBus.envelopes
    }

    public func cacheSnapshot() -> MarketDataCacheSnapshot {
        cache.snapshot
    }

    @discardableResult
    public func rebuildCache(from command: EventReplayCommand) -> MarketDataCacheSnapshot {
        let replay = messageBus.replay(command)
        return cache.rebuild(from: replay.envelopes)
    }
}
