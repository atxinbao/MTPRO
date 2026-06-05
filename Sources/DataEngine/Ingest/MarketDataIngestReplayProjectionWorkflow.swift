import DomainModel
import Foundation
import Adapters
import Core
import Persistence

/// DataEngine/Ingest 目录承载 MTP-21 的 public market data ingest 编排边界。
/// 当前 SwiftPM `Runtime` target 仍作为迁移期兼容壳编译本文件，负责把 Binance public read-only
/// client、Core TradingKernel、append-only event log replay 与 Persistence projection 串成本地端到端链路。
/// 该模块不拥有交易策略，不连接 signed endpoint，不读取账户，不提交、取消或替换订单，
/// 也不向 UI 暴露 SQLite / DuckDB schema。

/// PublicMarketDataIngestPlan 描述一次本地行情 ingest 需要读取的 public Binance market data 范围。
///
/// 输入只包含已验证的 symbol、timeframe、时间范围和 public endpoint limit；输出会被
/// `MarketDataIngestReplayProjectionWorkflow` 转换为 Core `MarketEvent`。`firstRecordedAt` 与
/// `recordedAtStride` 用于让 event log recordedAt 在自动测试中保持确定性。
public struct PublicMarketDataIngestPlan: Equatable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let range: DateRange
    public let klineLimit: Int
    public let recentTradeLimit: Int
    public let depthSnapshotLimit: BinanceDepthSnapshotLimit
    public let bestBidAskObservedAt: Date
    public let depthSnapshotObservedAt: Date
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval

    public init(
        symbol: Symbol,
        timeframe: Timeframe,
        range: DateRange,
        klineLimit: Int,
        recentTradeLimit: Int,
        depthSnapshotLimit: BinanceDepthSnapshotLimit,
        bestBidAskObservedAt: Date,
        depthSnapshotObservedAt: Date,
        firstRecordedAt: Date = Date(),
        recordedAtStride: TimeInterval = 1
    ) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
        self.klineLimit = klineLimit
        self.recentTradeLimit = recentTradeLimit
        self.depthSnapshotLimit = depthSnapshotLimit
        self.bestBidAskObservedAt = bestBidAskObservedAt
        self.depthSnapshotObservedAt = depthSnapshotObservedAt
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
    }

    /// 按事件位置生成确定性 recordedAt，保证 replay / projection 测试不会依赖系统当前时间。
    public func recordedAt(forEventAt index: Int) -> Date {
        firstRecordedAt.addingTimeInterval(TimeInterval(index) * recordedAtStride)
    }
}

/// Runtime workflow 错误只描述本地编排前置条件，不代表 Binance 账户、broker 或真实交易状态。
public enum MarketDataIngestReplayProjectionWorkflowError: Error, Equatable, Sendable {
    case fileEventLogStoreAlreadyContainsEvents(Int)
}

/// MarketDataIngestReplayProjectionResult 是 MTP-21 链路的稳定输出。
///
/// `eventEnvelopes` 与 `replayResult` 证明 append-only event log 是事实源；`cacheSnapshot`、
/// `runtimeProjectionSnapshot` 和 `analyticalProjectionSnapshot` 都从 replay envelope 重建，
/// 不暴露 SQLite / DuckDB 表结构，也不包含真实 broker action。
public struct MarketDataIngestReplayProjectionResult: Equatable, Sendable {
    public let ingestedEvents: [MarketEvent]
    public let eventEnvelopes: [EventEnvelope]
    public let replayResult: EventReplayResult
    public let cacheSnapshot: MarketDataCacheSnapshot
    public let runtimeProjectionSnapshot: SQLiteRuntimeProjectionSnapshot
    public let analyticalProjectionSnapshot: DuckDBAnalyticalProjectionSnapshot

    public init(
        ingestedEvents: [MarketEvent],
        eventEnvelopes: [EventEnvelope],
        replayResult: EventReplayResult,
        cacheSnapshot: MarketDataCacheSnapshot,
        runtimeProjectionSnapshot: SQLiteRuntimeProjectionSnapshot,
        analyticalProjectionSnapshot: DuckDBAnalyticalProjectionSnapshot
    ) {
        self.ingestedEvents = ingestedEvents
        self.eventEnvelopes = eventEnvelopes
        self.replayResult = replayResult
        self.cacheSnapshot = cacheSnapshot
        self.runtimeProjectionSnapshot = runtimeProjectionSnapshot
        self.analyticalProjectionSnapshot = analyticalProjectionSnapshot
    }
}

/// MarketDataIngestReplayProjectionWorkflow 串联 public market data ingest 到 replay projection。
///
/// 数据流为：
/// Binance public read-only client -> Core MarketEvent -> TradingKernel / DataEngine ->
/// FileEventLogStore append-only facts -> PersistenceReplayBoundary replay -> SQLite / DuckDB snapshots。
///
/// required validation 应注入 mock transport；真实 Binance 网络 smoke test 只能作为人工可选证据。
/// workflow 不保存 API key，不生成签名，不打开 account/order/listenKey endpoint，不执行 Live trading。
public struct MarketDataIngestReplayProjectionWorkflow: Sendable {
    private let client: BinancePublicMarketDataClient
    private let fileEventLogStore: FileEventLogStore
    private let sqliteRuntimeProjectionAdapter: SQLiteRuntimeProjectionAdapter?
    private let duckDBAnalyticalProjectionAdapter: DuckDBAnalyticalProjectionAdapter?

    public init(
        client: BinancePublicMarketDataClient,
        fileEventLogStore: FileEventLogStore,
        sqliteRuntimeProjectionAdapter: SQLiteRuntimeProjectionAdapter? = nil,
        duckDBAnalyticalProjectionAdapter: DuckDBAnalyticalProjectionAdapter? = nil
    ) {
        self.client = client
        self.fileEventLogStore = fileEventLogStore
        self.sqliteRuntimeProjectionAdapter = sqliteRuntimeProjectionAdapter
        self.duckDBAnalyticalProjectionAdapter = duckDBAnalyticalProjectionAdapter
    }

    /// 执行完整本地链路并返回 replay 后的稳定 snapshots。
    ///
    /// 输入来自 `PublicMarketDataIngestPlan` 和注入的 Binance public client；输出只包含 Core / Persistence
    /// 稳定模型。方法要求传入空的 file event log store，避免把新 ingest run 追加到未知历史后破坏
    /// sequence 单调性；多 run 续写应在后续 issue 另行定义事实源游标合同。
    public func run(_ plan: PublicMarketDataIngestPlan) async throws -> MarketDataIngestReplayProjectionResult {
        let existingEnvelopes = try fileEventLogStore.readEnvelopes()
        guard existingEnvelopes.isEmpty else {
            throw MarketDataIngestReplayProjectionWorkflowError
                .fileEventLogStoreAlreadyContainsEvents(existingEnvelopes.count)
        }

        let events = try await loadMarketEvents(for: plan)
        let kernel = try TradingKernel()
        for (index, event) in events.enumerated() {
            try await kernel.ingestMarketEvent(
                event,
                recordedAt: plan.recordedAt(forEventAt: index)
            )
        }

        let envelopes = await kernel.eventStream()
        try fileEventLogStore.append(contentsOf: envelopes)

        let replayBoundary = try PersistenceReplayBoundary(fileStore: fileEventLogStore)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: envelopes.count),
            streams: [.market]
        )
        let replay = replayBoundary.replay(command)
        let cacheSnapshot = replayBoundary.rebuildMarketDataCache(from: command)
        let runtimeProjection = try rebuildRuntimeProjection(from: command, using: replayBoundary)
        let analyticalProjection = try rebuildAnalyticalProjection(from: command, using: replayBoundary)

        return MarketDataIngestReplayProjectionResult(
            ingestedEvents: events,
            eventEnvelopes: envelopes,
            replayResult: replay,
            cacheSnapshot: cacheSnapshot,
            runtimeProjectionSnapshot: runtimeProjection,
            analyticalProjectionSnapshot: analyticalProjection
        )
    }

    private func loadMarketEvents(for plan: PublicMarketDataIngestPlan) async throws -> [MarketEvent] {
        let bars = try await client.klines(
            symbol: plan.symbol,
            timeframe: plan.timeframe,
            range: plan.range,
            limit: plan.klineLimit
        )
        let trades = try await client.recentTrades(
            symbol: plan.symbol,
            limit: plan.recentTradeLimit
        )
        let bestBidAsk = try await client.bestBidAsk(
            symbol: plan.symbol,
            observedAt: plan.bestBidAskObservedAt
        )
        let snapshot = try await client.depthSnapshot(
            symbol: plan.symbol,
            limit: plan.depthSnapshotLimit,
            observedAt: plan.depthSnapshotObservedAt
        )
        let delta = try await client.depthDelta(symbol: plan.symbol)

        return bars.map(MarketEvent.bar)
            + trades.map(MarketEvent.trade)
            + [
                .bestBidAsk(bestBidAsk),
                .orderBookSnapshot(snapshot),
                .orderBookDelta(delta)
            ]
    }

    private func rebuildRuntimeProjection(
        from command: EventReplayCommand,
        using replayBoundary: PersistenceReplayBoundary
    ) throws -> SQLiteRuntimeProjectionSnapshot {
        if let sqliteRuntimeProjectionAdapter {
            return try replayBoundary.rebuildSQLiteRuntimeProjection(
                from: command,
                using: sqliteRuntimeProjectionAdapter
            )
        }
        return replayBoundary.rebuildSQLiteRuntimeProjection(from: command)
    }

    private func rebuildAnalyticalProjection(
        from command: EventReplayCommand,
        using replayBoundary: PersistenceReplayBoundary
    ) throws -> DuckDBAnalyticalProjectionSnapshot {
        if let duckDBAnalyticalProjectionAdapter {
            return try replayBoundary.rebuildDuckDBAnalyticalProjection(
                from: command,
                using: duckDBAnalyticalProjectionAdapter
            )
        }
        return replayBoundary.rebuildDuckDBAnalyticalProjection(from: command)
    }
}
