import Foundation
import Core
#if canImport(DuckDB)
import DuckDB
#endif

/// DuckDBAnalyticalProjectionAdapterError 表达 DuckDB 分析投影 adapter 的本地读写错误边界。
/// 错误只描述私有分析投影存储失败，不代表 Binance、signed endpoint、broker 或真实订单状态。
public enum DuckDBAnalyticalProjectionAdapterError: Error, Equatable, Sendable {
    case databaseFailure(String)
    case missingProjectionPayload(String)
}

/// DuckDBAnalyticalProjectionAdapter 是 MTP-19 的最小 DuckDB 分析投影适配器。
///
/// 输入只能来自 append-only event log replay 之后的 `EventEnvelope` 或 `EventReplayResult`。
/// adapter 复用 `DuckDBAnalyticalProjectionStore.project` 生成稳定分析 snapshot，再把 market data、
/// backtest run、订单簿研究 run 和 signal timeline 写入 DuckDB 私有表。查询输出只返回
/// `DuckDBAnalyticalProjectionSnapshot`，禁止 UI、API 或 ViewModel 依赖 DuckDB schema、SQL statement
/// 或 payload 编码。该 adapter 不连接 Binance、不读取 API key、不调用 signed endpoint，也不触发
/// Live trading、broker action 或真实订单行为。
public struct DuckDBAnalyticalProjectionAdapter: Equatable, Sendable {
    public let databaseURL: Foundation.URL

    /// 初始化 DuckDB 分析投影适配器，只绑定本地数据库文件路径，不创建完整 schema 设计或 migration framework。
    public init(databaseURL: Foundation.URL) {
        self.databaseURL = databaseURL
    }

    /// 从 replay envelope 重建 DuckDB analytical projection。
    /// 返回值是稳定 snapshot，用于 Market / Strategy / Backtest / Report read model；DuckDB schema 保持私有。
    @discardableResult
    public func rebuild(from envelopes: [EventEnvelope]) throws -> DuckDBAnalyticalProjectionSnapshot {
        #if canImport(DuckDB)
        let snapshot = DuckDBAnalyticalProjectionStore.project(envelopes)
        try DuckDBAnalyticalProjectionDatabase(databaseURL: databaseURL).replace(with: snapshot)
        return snapshot
        #else
        throw Self.unsupportedPlatform()
        #endif
    }

    /// 从 `EventReplayResult` 重建 DuckDB analytical projection。
    /// 该入口明确表达 event log 仍是事实源，adapter 只消费 replay 后的 envelope 集合。
    @discardableResult
    public func rebuild(from replay: EventReplayResult) throws -> DuckDBAnalyticalProjectionSnapshot {
        try rebuild(from: replay.envelopes)
    }

    /// 查询 DuckDB 中保存的最小分析投影，并返回稳定 snapshot。
    /// 调用方拿不到表名、列名或 SQL statement，避免把 DuckDB schema 暴露为 UI 合同。
    public func querySnapshot() throws -> DuckDBAnalyticalProjectionSnapshot {
        #if canImport(DuckDB)
        try DuckDBAnalyticalProjectionDatabase(databaseURL: databaseURL).snapshot()
        #else
        throw Self.unsupportedPlatform()
        #endif
    }

    private static func unsupportedPlatform() -> DuckDBAnalyticalProjectionAdapterError {
        // MTPRO runtime 目标是 macOS；Linux CI 只需要编译公共 API，真实 DuckDB adapter 由 macOS 本地验证覆盖。
        DuckDBAnalyticalProjectionAdapterError.databaseFailure(
            "DuckDB official Swift package is enabled only for the macOS MTPRO runtime target"
        )
    }
}

public extension PersistenceReplayBoundary {
    /// 使用 DuckDB 分析投影适配器重建当前 replay 范围内的分析快照。
    /// 输入仍然是 append-only event log 的 replay envelope；DuckDB 只作为私有分析投影存储，
    /// 输出仍是稳定 `DuckDBAnalyticalProjectionSnapshot`，不会把表结构暴露给 UI 或 API。
    func rebuildDuckDBAnalyticalProjection(
        from command: EventReplayCommand,
        using adapter: DuckDBAnalyticalProjectionAdapter
    ) throws -> DuckDBAnalyticalProjectionSnapshot {
        let replay = replay(command)
        return try adapter.rebuild(from: replay)
    }
}

private enum DuckDBAnalyticalProjectionRecordKind: String {
    case marketBar
    case trade
    case bestBidAsk
    case orderBookSnapshot
    case orderBookDelta
    case backtestRun
    case orderBookResearchRun
    case signalTimeline
}

private struct DuckDBAnalyticalProjectionRow {
    let key: String
    let kind: DuckDBAnalyticalProjectionRecordKind
    let sortOrder: Int
    let payload: String
}

#if canImport(DuckDB)
private struct DuckDBAnalyticalProjectionDatabase {
    let databaseURL: Foundation.URL

    func replace(with snapshot: DuckDBAnalyticalProjectionSnapshot) throws {
        try createParentDirectoryIfNeeded()
        try withConnection { connection in
            try bootstrap(connection)
            try connection.execute("BEGIN TRANSACTION")
            do {
                try connection.execute("DELETE FROM analytical_projection_records")
                try connection.execute("DELETE FROM analytical_projection_metadata")
                try insert(snapshot: snapshot, connection: connection)
                try connection.execute("COMMIT")
            } catch {
                try? connection.execute("ROLLBACK")
                throw error
            }
        }
    }

    func snapshot() throws -> DuckDBAnalyticalProjectionSnapshot {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return DuckDBAnalyticalProjectionSnapshot()
        }

        return try withConnection { connection in
            try bootstrap(connection)

            var marketBars: [MarketBar] = []
            var trades: [TradeTick] = []
            var bestBidAsks: [BestBidAsk] = []
            var orderBookSnapshots: [OrderBookSnapshot] = []
            var orderBookDeltas: [OrderBookDelta] = []
            var backtestRuns: [Identifier: DuckDBBacktestProjection] = [:]
            var orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection] = [:]
            var signalTimeline: [DuckDBSignalTimelineProjection] = []

            for row in try rows(connection: connection) {
                switch row.kind {
                case .marketBar:
                    marketBars.append(try decode(MarketBar.self, from: row.payload))

                case .trade:
                    trades.append(try decode(TradeTick.self, from: row.payload))

                case .bestBidAsk:
                    bestBidAsks.append(try decode(BestBidAsk.self, from: row.payload))

                case .orderBookSnapshot:
                    orderBookSnapshots.append(try decode(OrderBookSnapshot.self, from: row.payload))

                case .orderBookDelta:
                    orderBookDeltas.append(try decode(OrderBookDelta.self, from: row.payload))

                case .backtestRun:
                    let projection = try decode(DuckDBBacktestProjection.self, from: row.payload)
                    backtestRuns[projection.runID] = projection

                case .orderBookResearchRun:
                    let projection = try decode(
                        DuckDBOrderBookResearchProjection.self,
                        from: row.payload
                    )
                    orderBookResearchRuns[projection.researchID] = projection

                case .signalTimeline:
                    signalTimeline.append(try decode(DuckDBSignalTimelineProjection.self, from: row.payload))
                }
            }

            return DuckDBAnalyticalProjectionSnapshot(
                marketBars: marketBars,
                trades: trades,
                bestBidAsks: bestBidAsks,
                orderBookSnapshots: orderBookSnapshots,
                orderBookDeltas: orderBookDeltas,
                backtestRuns: backtestRuns,
                orderBookResearchRuns: orderBookResearchRuns,
                signalTimeline: signalTimeline,
                lastAppliedSequence: try lastAppliedSequence(connection: connection)
            )
        }
    }

    private func bootstrap(_ connection: Connection) throws {
        try connection.execute(
            """
            CREATE TABLE IF NOT EXISTS analytical_projection_records (
                record_key VARCHAR NOT NULL,
                record_kind VARCHAR NOT NULL,
                sort_order BIGINT NOT NULL,
                payload VARCHAR NOT NULL
            )
            """
        )
        try connection.execute(
            """
            CREATE TABLE IF NOT EXISTS analytical_projection_metadata (
                metadata_key VARCHAR NOT NULL,
                metadata_value VARCHAR NOT NULL
            )
            """
        )
    }

    private func insert(
        snapshot: DuckDBAnalyticalProjectionSnapshot,
        connection: Connection
    ) throws {
        let statement = try PreparedStatement(
            connection: connection,
            query: """
            INSERT INTO analytical_projection_records (
                record_key,
                record_kind,
                sort_order,
                payload
            ) VALUES ($1, $2, $3, $4)
            """
        )

        for (index, bar) in snapshot.marketBars.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "market-bar:\(index)",
                    kind: .marketBar,
                    sortOrder: index,
                    payload: try encode(bar)
                ),
                using: statement
            )
        }

        for (index, trade) in snapshot.trades.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "trade:\(index)",
                    kind: .trade,
                    sortOrder: index,
                    payload: try encode(trade)
                ),
                using: statement
            )
        }

        for (index, bestBidAsk) in snapshot.bestBidAsks.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "best-bid-ask:\(index)",
                    kind: .bestBidAsk,
                    sortOrder: index,
                    payload: try encode(bestBidAsk)
                ),
                using: statement
            )
        }

        for (index, orderBookSnapshot) in snapshot.orderBookSnapshots.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "order-book-snapshot:\(index)",
                    kind: .orderBookSnapshot,
                    sortOrder: index,
                    payload: try encode(orderBookSnapshot)
                ),
                using: statement
            )
        }

        for (index, orderBookDelta) in snapshot.orderBookDeltas.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "order-book-delta:\(index)",
                    kind: .orderBookDelta,
                    sortOrder: index,
                    payload: try encode(orderBookDelta)
                ),
                using: statement
            )
        }

        for (index, backtest) in snapshot.backtestRuns.values
            .sorted(by: { $0.runID.rawValue < $1.runID.rawValue })
            .enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "backtest:\(backtest.runID.rawValue)",
                    kind: .backtestRun,
                    sortOrder: index,
                    payload: try encode(backtest)
                ),
                using: statement
            )
        }

        for (index, research) in snapshot.orderBookResearchRuns.values
            .sorted(by: { $0.researchID.rawValue < $1.researchID.rawValue })
            .enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "order-book-research:\(research.researchID.rawValue)",
                    kind: .orderBookResearchRun,
                    sortOrder: index,
                    payload: try encode(research)
                ),
                using: statement
            )
        }

        for (index, signal) in snapshot.signalTimeline.enumerated() {
            try insert(
                row: DuckDBAnalyticalProjectionRow(
                    key: "signal:\(index)",
                    kind: .signalTimeline,
                    sortOrder: index,
                    payload: try encode(signal)
                ),
                using: statement
            )
        }

        if let lastAppliedSequence = snapshot.lastAppliedSequence {
            try insertMetadata(
                key: "lastAppliedSequence",
                value: String(lastAppliedSequence),
                connection: connection
            )
        }
    }

    private func insert(
        row: DuckDBAnalyticalProjectionRow,
        using statement: PreparedStatement
    ) throws {
        try statement.bind(row.key, at: 1)
        try statement.bind(row.kind.rawValue, at: 2)
        try statement.bind(Int64(row.sortOrder), at: 3)
        try statement.bind(row.payload, at: 4)
        _ = try statement.execute()
    }

    private func insertMetadata(
        key: String,
        value: String,
        connection: Connection
    ) throws {
        let statement = try PreparedStatement(
            connection: connection,
            query: """
            INSERT INTO analytical_projection_metadata (
                metadata_key,
                metadata_value
            ) VALUES ($1, $2)
            """
        )
        try statement.bind(key, at: 1)
        try statement.bind(value, at: 2)
        _ = try statement.execute()
    }

    private func rows(connection: Connection) throws -> [DuckDBAnalyticalProjectionRow] {
        let result = try connection.query(
            """
            SELECT record_key, record_kind, sort_order, payload
            FROM analytical_projection_records
            ORDER BY record_kind, sort_order, record_key
            """
        )
        let keys = result[0].cast(to: String.self)
        let kinds = result[1].cast(to: String.self)
        let sortOrders = result[2].cast(to: Int64.self)
        let payloads = result[3].cast(to: String.self)

        var rows: [DuckDBAnalyticalProjectionRow] = []
        for index in 0..<result.rowCount {
            guard let key = keys[index],
                  let kindRawValue = kinds[index],
                  let kind = DuckDBAnalyticalProjectionRecordKind(rawValue: kindRawValue),
                  let sortOrder = sortOrders[index],
                  let payload = payloads[index] else {
                throw DuckDBAnalyticalProjectionAdapterError.missingProjectionPayload(
                    "missing analytical projection row at index \(index)"
                )
            }
            rows.append(
                DuckDBAnalyticalProjectionRow(
                    key: key,
                    kind: kind,
                    sortOrder: Int(sortOrder),
                    payload: payload
                )
            )
        }
        return rows
    }

    private func lastAppliedSequence(connection: Connection) throws -> Int? {
        let statement = try PreparedStatement(
            connection: connection,
            query: """
            SELECT metadata_value
            FROM analytical_projection_metadata
            WHERE metadata_key = $1
            """
        )
        try statement.bind("lastAppliedSequence", at: 1)
        let result = try statement.execute()
        guard result.rowCount > 0 else {
            return nil
        }
        guard let rawValue = result[0].cast(to: String.self)[0],
              let sequence = Int(rawValue) else {
            throw DuckDBAnalyticalProjectionAdapterError.databaseFailure(
                "invalid lastAppliedSequence metadata"
            )
        }
        return sequence
    }

    private func withConnection<T>(_ body: (Connection) throws -> T) throws -> T {
        let database = try Database(store: .file(at: databaseURL))
        let connection = try database.connect()
        return try body(connection)
    }

    private func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        guard let encoded = String(data: data, encoding: .utf8) else {
            throw DuckDBAnalyticalProjectionAdapterError.databaseFailure(
                "unable to encode analytical projection payload"
            )
        }
        return encoded
    }

    private func decode<T: Decodable>(_ type: T.Type, from payload: String) throws -> T {
        guard let data = payload.data(using: .utf8) else {
            throw DuckDBAnalyticalProjectionAdapterError.missingProjectionPayload(
                "analytical projection payload is not valid UTF-8"
            )
        }
        return try JSONDecoder().decode(type, from: data)
    }

    private func createParentDirectoryIfNeeded() throws {
        let directoryURL = databaseURL.deletingLastPathComponent()
        guard directoryURL.path.isEmpty == false else {
            return
        }
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}
#endif
