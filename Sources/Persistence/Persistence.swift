import Foundation
import Core
import CSQLite

public struct PersistenceBoundary: Equatable, Sendable {
    public let factSource: String
    public let sqliteResponsibility: String
    public let duckDBResponsibility: String
    public let uiExposure: String
    public let exposesDatabaseTablesToUI: Bool
    public let persistsRuntimeObjectsAsUIContract: Bool

    public init(
        factSource: String = "append-only event log",
        sqliteResponsibility: String = "runtime state and lightweight projections",
        duckDBResponsibility: String = "market data and backtest analytical projections",
        uiExposure: String = "stable read model projections only",
        exposesDatabaseTablesToUI: Bool = false,
        persistsRuntimeObjectsAsUIContract: Bool = false
    ) {
        self.factSource = factSource
        self.sqliteResponsibility = sqliteResponsibility
        self.duckDBResponsibility = duckDBResponsibility
        self.uiExposure = uiExposure
        self.exposesDatabaseTablesToUI = exposesDatabaseTablesToUI
        self.persistsRuntimeObjectsAsUIContract = persistsRuntimeObjectsAsUIContract
    }
}

/// FileEventLogStore 是 Persistence 层的本地文件事实源边界。
///
/// 输入只接受 Core 已验证的 `EventEnvelope`，输出只返回 `EventEnvelope` 或 `EventReplayResult`。
/// 文件内部使用逐行 JSON 编码保存，但该格式不是 UI、数据库 schema 或 runtime object contract。
/// 每次追加前都会重读并校验现有 sequence，确保只能写入下一个连续事件；这里不连接 Binance、
/// signed endpoint、真实 broker 或任何交易执行能力。
public struct FileEventLogStore: Equatable, Sendable {
    public let fileURL: URL

    /// 初始化文件事件日志边界，只记录落盘位置，不创建数据库、不迁移 schema。
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// 读取文件中的稳定事件事实，返回按文件追加顺序校验过的 envelope 数组。
    /// 空文件或不存在的文件代表尚无事实，不会向 UI 暴露底层文件格式。
    public func readEnvelopes() throws -> [EventEnvelope] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else {
            return []
        }

        let decoder = JSONDecoder()
        let envelopes = try data.split(separator: UInt8(ascii: "\n")).map { line in
            try decoder.decode(EventEnvelope.self, from: Data(line))
        }
        return try AppendOnlyEventLog(envelopes: envelopes).envelopes
    }

    /// 按 replay command 从文件事实源重放事件，输出仍是稳定 read model / projection 输入。
    public func replay(_ command: EventReplayCommand) throws -> EventReplayResult {
        let eventLog = try AppendOnlyEventLog(envelopes: readEnvelopes())
        return eventLog.replay(command)
    }

    /// 追加写入一个已验证 envelope，只允许 sequence 等于当前文件事实数量加一。
    /// 该边界只做本地 facts 持久化，不保存 runtime object，也不会触发订单或 broker side effect。
    public func append(_ envelope: EventEnvelope) throws {
        let existingEnvelopes = try readEnvelopes()
        guard envelope.sequence == existingEnvelopes.count + 1 else {
            throw CoreError.invalidSequenceRange
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var encodedLine = try encoder.encode(envelope)
        encodedLine.append(contentsOf: [0x0A])

        try createParentDirectoryIfNeeded()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            defer {
                try? fileHandle.close()
            }
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: encodedLine)
        } else {
            try encodedLine.write(to: fileURL, options: .atomic)
        }
    }

    /// 批量追加已经按 sequence 排好序的 envelope，用于把内存事件流落盘为后续 replay 事实源。
    public func append(contentsOf envelopes: [EventEnvelope]) throws {
        for envelope in envelopes {
            try append(envelope)
        }
    }

    private func createParentDirectoryIfNeeded() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        guard directoryURL.path.isEmpty == false else {
            return
        }
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}

/// 持久化重放边界复用 Core 只追加事件日志，输出稳定投影而不是数据库表。
public struct PersistenceReplayBoundary: Equatable, Sendable {
    private let eventLog: AppendOnlyEventLog

    public init(envelopes: [EventEnvelope]) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: envelopes)
    }

    /// 从文件事件日志边界构建 replay 边界，仍然只消费稳定 `EventEnvelope`，不暴露文件格式。
    public init(fileStore: FileEventLogStore) throws {
        self.eventLog = try AppendOnlyEventLog(envelopes: fileStore.readEnvelopes())
    }

    public var envelopes: [EventEnvelope] {
        eventLog.envelopes
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        eventLog.replay(command)
    }

    public func rebuildMarketDataCache(from command: EventReplayCommand) -> MarketDataCacheSnapshot {
        let replay = replay(command)
        return MarketDataCache.project(replay.envelopes)
    }

    public func rebuildSQLiteRuntimeProjection(
        from command: EventReplayCommand
    ) -> SQLiteRuntimeProjectionSnapshot {
        let replay = replay(command)
        return SQLiteRuntimeProjectionStore.project(replay.envelopes)
    }

    /// 使用 SQLite 运行投影适配器重建当前 replay 范围内的运行时快照。
    /// 输入仍然是 append-only event log 的 replay envelope；SQLite 只作为私有投影存储，
    /// 输出仍是稳定 `SQLiteRuntimeProjectionSnapshot`，不会把表结构暴露给 UI 或 API。
    public func rebuildSQLiteRuntimeProjection(
        from command: EventReplayCommand,
        using adapter: SQLiteRuntimeProjectionAdapter
    ) throws -> SQLiteRuntimeProjectionSnapshot {
        let replay = replay(command)
        return try adapter.rebuild(from: replay)
    }

    public func rebuildDuckDBAnalyticalProjection(
        from command: EventReplayCommand
    ) -> DuckDBAnalyticalProjectionSnapshot {
        let replay = replay(command)
        return DuckDBAnalyticalProjectionStore.project(replay.envelopes)
    }
}

public enum ProjectionLifecycleState: String, Codable, Equatable, Sendable {
    case requested
    case completed
}

public struct SQLitePaperSessionProjection: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let riskProfileID: Identifier
    public let executionMode: ExecutionMode
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let requestedAt: Date
    public let completedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        sessionID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        riskProfileID: Identifier,
        executionMode: ExecutionMode,
        state: ProjectionLifecycleState,
        signalCount: Int,
        requestedAt: Date,
        completedAt: Date?,
        lastUpdatedAt: Date
    ) {
        self.sessionID = sessionID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
        self.state = state
        self.signalCount = signalCount
        self.requestedAt = requestedAt
        self.completedAt = completedAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}

public enum SQLitePortfolioProjectionState: String, Codable, Equatable, Sendable {
    case requested
    case updated
}

public struct SQLitePortfolioProjection: Codable, Equatable, Sendable {
    public let portfolioID: Identifier
    public let state: SQLitePortfolioProjectionState
    public let requestedAt: Date?
    public let updatedAt: Date?
    public let lastUpdatedAt: Date

    public init(
        portfolioID: Identifier,
        state: SQLitePortfolioProjectionState,
        requestedAt: Date?,
        updatedAt: Date?,
        lastUpdatedAt: Date
    ) {
        self.portfolioID = portfolioID
        self.state = state
        self.requestedAt = requestedAt
        self.updatedAt = updatedAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}

public struct SQLiteRuntimeProjectionSnapshot: Equatable, Sendable {
    public let paperSessions: [Identifier: SQLitePaperSessionProjection]
    public let rejectedPaperOrderIDs: [Identifier]
    public let portfolioProjections: [Identifier: SQLitePortfolioProjection]
    public let lastAppliedSequence: Int?

    public init(
        paperSessions: [Identifier: SQLitePaperSessionProjection] = [:],
        rejectedPaperOrderIDs: [Identifier] = [],
        portfolioProjections: [Identifier: SQLitePortfolioProjection] = [:],
        lastAppliedSequence: Int? = nil
    ) {
        self.paperSessions = paperSessions
        self.rejectedPaperOrderIDs = rejectedPaperOrderIDs
        self.portfolioProjections = portfolioProjections
        self.lastAppliedSequence = lastAppliedSequence
    }
}

/// SQLite 运行投影边界保存轻量运行状态，不暴露 SQL schema 给 UI。
public struct SQLiteRuntimeProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: SQLiteRuntimeProjectionSnapshot

    public init(snapshot: SQLiteRuntimeProjectionSnapshot = SQLiteRuntimeProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> SQLiteRuntimeProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> SQLiteRuntimeProjectionSnapshot {
        var paperSessions: [Identifier: SQLitePaperSessionProjection] = [:]
        var rejectedPaperOrderIDs: [Identifier] = []
        var portfolioProjections: [Identifier: SQLitePortfolioProjection] = [:]
        var lastAppliedSequence: Int?

        for envelope in envelopes.sorted(by: { $0.sequence < $1.sequence }) {
            switch envelope.event {
            case let .paper(event):
                apply(
                    paperEvent: event,
                    envelope: envelope,
                    paperSessions: &paperSessions
                )
                lastAppliedSequence = envelope.sequence
            case let .risk(event):
                apply(
                    riskEvent: event,
                    rejectedPaperOrderIDs: &rejectedPaperOrderIDs
                )
                lastAppliedSequence = envelope.sequence
            case let .portfolio(event):
                apply(
                    portfolioEvent: event,
                    envelope: envelope,
                    portfolioProjections: &portfolioProjections
                )
                lastAppliedSequence = envelope.sequence
            default:
                continue
            }
        }

        return SQLiteRuntimeProjectionSnapshot(
            paperSessions: paperSessions,
            rejectedPaperOrderIDs: rejectedPaperOrderIDs,
            portfolioProjections: portfolioProjections,
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func apply(
        paperEvent: PaperEvent,
        envelope: EventEnvelope,
        paperSessions: inout [Identifier: SQLitePaperSessionProjection]
    ) {
        switch paperEvent {
        case let .sessionRequested(command):
            let existing = paperSessions[command.sessionID]
            paperSessions[command.sessionID] = SQLitePaperSessionProjection(
                sessionID: command.sessionID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                riskProfileID: command.riskProfileID,
                executionMode: command.executionMode,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                completedAt: existing?.completedAt,
                lastUpdatedAt: envelope.recordedAt
            )

        case .signalGenerated:
            break

        case let .sessionCompleted(result):
            let existing = paperSessions[result.sessionID]
            paperSessions[result.sessionID] = SQLitePaperSessionProjection(
                sessionID: result.sessionID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                riskProfileID: result.command.riskProfileID,
                executionMode: result.command.executionMode,
                state: .completed,
                signalCount: result.signalSamples.count,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                completedAt: result.completedAt,
                lastUpdatedAt: envelope.recordedAt
            )
        }
    }

    private static func apply(
        riskEvent: RiskEvent,
        rejectedPaperOrderIDs: inout [Identifier]
    ) {
        guard case let .rejected(paperOrderID) = riskEvent else {
            return
        }
        if rejectedPaperOrderIDs.contains(paperOrderID) == false {
            rejectedPaperOrderIDs.append(paperOrderID)
        }
    }

    private static func apply(
        portfolioEvent: PortfolioEvent,
        envelope: EventEnvelope,
        portfolioProjections: inout [Identifier: SQLitePortfolioProjection]
    ) {
        switch portfolioEvent {
        case let .projectionRequested(query):
            let existing = portfolioProjections[query.portfolioID]
            portfolioProjections[query.portfolioID] = SQLitePortfolioProjection(
                portfolioID: query.portfolioID,
                state: existing?.state ?? .requested,
                requestedAt: existing?.requestedAt ?? envelope.recordedAt,
                updatedAt: existing?.updatedAt,
                lastUpdatedAt: envelope.recordedAt
            )

        case let .projectionUpdated(portfolioID):
            let existing = portfolioProjections[portfolioID]
            portfolioProjections[portfolioID] = SQLitePortfolioProjection(
                portfolioID: portfolioID,
                state: .updated,
                requestedAt: existing?.requestedAt,
                updatedAt: envelope.recordedAt,
                lastUpdatedAt: envelope.recordedAt
            )
        }
    }
}

/// SQLiteRuntimeProjectionAdapterError 表达 SQLite runtime projection adapter 的本地读写错误边界。
/// 错误只描述私有投影存储失败，不代表 broker、exchange、真实订单或 Live execution 状态。
public enum SQLiteRuntimeProjectionAdapterError: Error, Equatable, Sendable {
    case databaseFailure(String)
    case missingProjectionPayload(String)
}

/// SQLiteRuntimeProjectionAdapter 是 MTP-18 的最小 SQLite 运行时投影适配器。
///
/// 输入只能来自 `EventReplayResult` 或 `EventEnvelope` replay 输出；adapter 会先复用
/// `SQLiteRuntimeProjectionStore.project` 生成稳定 read model snapshot，再用 SQLite3 事务替换私有投影记录。
/// 查询输出仍然是 `SQLiteRuntimeProjectionSnapshot`，禁止 UI、ORM 或 API 直接依赖 SQLite 表结构。
/// 该 adapter 不保存真实 broker 状态，不连接 Binance，不触发 signed endpoint，也不执行任何真实订单动作。
public struct SQLiteRuntimeProjectionAdapter: Equatable, Sendable {
    public let databaseURL: URL

    /// 初始化 SQLite 投影适配器，只绑定本地数据库文件路径，不创建迁移框架或外部系统连接。
    public init(databaseURL: URL) {
        self.databaseURL = databaseURL
    }

    /// 从 replay envelope 重建 SQLite runtime projection。
    /// 返回值是稳定 snapshot，用于 Paper / Risk / Portfolio read model；SQLite schema 保持私有。
    @discardableResult
    public func rebuild(from envelopes: [EventEnvelope]) throws -> SQLiteRuntimeProjectionSnapshot {
        let snapshot = SQLiteRuntimeProjectionStore.project(envelopes)
        try SQLiteRuntimeProjectionDatabase(databaseURL: databaseURL).replace(with: snapshot)
        return snapshot
    }

    /// 从 `EventReplayResult` 重建 SQLite runtime projection。
    /// 该入口明确表达 event log 仍是事实源，adapter 只消费 replay 后的 envelope 集合。
    @discardableResult
    public func rebuild(from replay: EventReplayResult) throws -> SQLiteRuntimeProjectionSnapshot {
        try rebuild(from: replay.envelopes)
    }

    /// 查询 SQLite 中保存的最小运行时投影，并返回稳定 snapshot。
    /// 调用方拿不到表名、列名或 SQL statement，避免把 SQLite schema 暴露为 UI 合同。
    public func querySnapshot() throws -> SQLiteRuntimeProjectionSnapshot {
        try SQLiteRuntimeProjectionDatabase(databaseURL: databaseURL).snapshot()
    }
}

private enum SQLiteRuntimeProjectionRecordKind: String {
    case paperSession
    case rejectedPaperOrder
    case portfolioProjection
}

private struct SQLiteRejectedPaperOrderProjectionRecord: Codable {
    let paperOrderID: Identifier
}

private struct SQLiteRuntimeProjectionRow {
    let key: String
    let kind: SQLiteRuntimeProjectionRecordKind
    let sortOrder: Int
    let payload: String
}

private struct SQLiteRuntimeProjectionDatabase {
    let databaseURL: URL

    private static let transientDestructor = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    func replace(with snapshot: SQLiteRuntimeProjectionSnapshot) throws {
        try createParentDirectoryIfNeeded()
        try withDatabase { database in
            try bootstrap(database)
            try execute("BEGIN IMMEDIATE TRANSACTION", database: database)
            do {
                try execute("DELETE FROM runtime_projection_records", database: database)
                try execute("DELETE FROM runtime_projection_metadata", database: database)
                try insert(snapshot: snapshot, database: database)
                try execute("COMMIT", database: database)
            } catch {
                try? execute("ROLLBACK", database: database)
                throw error
            }
        }
    }

    func snapshot() throws -> SQLiteRuntimeProjectionSnapshot {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return SQLiteRuntimeProjectionSnapshot()
        }

        return try withDatabase { database in
            try bootstrap(database)

            var paperSessions: [Identifier: SQLitePaperSessionProjection] = [:]
            var rejectedPaperOrderIDs: [Identifier] = []
            var portfolioProjections: [Identifier: SQLitePortfolioProjection] = [:]

            for row in try rows(database: database) {
                switch row.kind {
                case .paperSession:
                    let projection = try decode(SQLitePaperSessionProjection.self, from: row.payload)
                    paperSessions[projection.sessionID] = projection

                case .rejectedPaperOrder:
                    let projection = try decode(
                        SQLiteRejectedPaperOrderProjectionRecord.self,
                        from: row.payload
                    )
                    rejectedPaperOrderIDs.append(projection.paperOrderID)

                case .portfolioProjection:
                    let projection = try decode(SQLitePortfolioProjection.self, from: row.payload)
                    portfolioProjections[projection.portfolioID] = projection
                }
            }

            return SQLiteRuntimeProjectionSnapshot(
                paperSessions: paperSessions,
                rejectedPaperOrderIDs: rejectedPaperOrderIDs,
                portfolioProjections: portfolioProjections,
                lastAppliedSequence: try lastAppliedSequence(database: database)
            )
        }
    }

    private func bootstrap(_ database: OpaquePointer) throws {
        try execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_projection_records (
                record_key TEXT PRIMARY KEY NOT NULL,
                record_kind TEXT NOT NULL,
                sort_order INTEGER NOT NULL,
                payload TEXT NOT NULL
            )
            """,
            database: database
        )
        try execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_projection_metadata (
                metadata_key TEXT PRIMARY KEY NOT NULL,
                metadata_value TEXT NOT NULL
            )
            """,
            database: database
        )
    }

    private func insert(snapshot: SQLiteRuntimeProjectionSnapshot, database: OpaquePointer) throws {
        for (index, session) in snapshot.paperSessions.values
            .sorted(by: { $0.sessionID.rawValue < $1.sessionID.rawValue })
            .enumerated() {
            try insert(
                row: SQLiteRuntimeProjectionRow(
                    key: "paper:\(session.sessionID.rawValue)",
                    kind: .paperSession,
                    sortOrder: index,
                    payload: try encode(session)
                ),
                database: database
            )
        }

        for (index, paperOrderID) in snapshot.rejectedPaperOrderIDs.enumerated() {
            try insert(
                row: SQLiteRuntimeProjectionRow(
                    key: "risk-rejection:\(paperOrderID.rawValue)",
                    kind: .rejectedPaperOrder,
                    sortOrder: index,
                    payload: try encode(
                        SQLiteRejectedPaperOrderProjectionRecord(paperOrderID: paperOrderID)
                    )
                ),
                database: database
            )
        }

        for (index, portfolio) in snapshot.portfolioProjections.values
            .sorted(by: { $0.portfolioID.rawValue < $1.portfolioID.rawValue })
            .enumerated() {
            try insert(
                row: SQLiteRuntimeProjectionRow(
                    key: "portfolio:\(portfolio.portfolioID.rawValue)",
                    kind: .portfolioProjection,
                    sortOrder: index,
                    payload: try encode(portfolio)
                ),
                database: database
            )
        }

        if let lastAppliedSequence = snapshot.lastAppliedSequence {
            try insertMetadata(
                key: "lastAppliedSequence",
                value: String(lastAppliedSequence),
                database: database
            )
        }
    }

    private func insert(row: SQLiteRuntimeProjectionRow, database: OpaquePointer) throws {
        try withStatement(
            """
            INSERT INTO runtime_projection_records (
                record_key,
                record_kind,
                sort_order,
                payload
            ) VALUES (?, ?, ?, ?)
            """,
            database: database
        ) { statement in
            try bind(row.key, to: statement, at: 1, database: database)
            try bind(row.kind.rawValue, to: statement, at: 2, database: database)
            try bind(row.sortOrder, to: statement, at: 3, database: database)
            try bind(row.payload, to: statement, at: 4, database: database)
            try stepDone(statement, database: database)
        }
    }

    private func insertMetadata(
        key: String,
        value: String,
        database: OpaquePointer
    ) throws {
        try withStatement(
            """
            INSERT INTO runtime_projection_metadata (
                metadata_key,
                metadata_value
            ) VALUES (?, ?)
            """,
            database: database
        ) { statement in
            try bind(key, to: statement, at: 1, database: database)
            try bind(value, to: statement, at: 2, database: database)
            try stepDone(statement, database: database)
        }
    }

    private func rows(database: OpaquePointer) throws -> [SQLiteRuntimeProjectionRow] {
        try withStatement(
            """
            SELECT record_key, record_kind, sort_order, payload
            FROM runtime_projection_records
            ORDER BY record_kind, sort_order, record_key
            """,
            database: database
        ) { statement in
            var rows: [SQLiteRuntimeProjectionRow] = []
            while true {
                let result = sqlite3_step(statement)
                if result == SQLITE_DONE {
                    return rows
                }
                guard result == SQLITE_ROW else {
                    throw sqliteError(database)
                }

                let kindRawValue = try columnText(statement, at: 1)
                guard let kind = SQLiteRuntimeProjectionRecordKind(rawValue: kindRawValue) else {
                    throw SQLiteRuntimeProjectionAdapterError.databaseFailure(
                        "unknown runtime projection record kind: \(kindRawValue)"
                    )
                }
                rows.append(
                    SQLiteRuntimeProjectionRow(
                        key: try columnText(statement, at: 0),
                        kind: kind,
                        sortOrder: Int(sqlite3_column_int64(statement, 2)),
                        payload: try columnText(statement, at: 3)
                    )
                )
            }
        }
    }

    private func lastAppliedSequence(database: OpaquePointer) throws -> Int? {
        try withStatement(
            """
            SELECT metadata_value
            FROM runtime_projection_metadata
            WHERE metadata_key = ?
            """,
            database: database
        ) { statement in
            try bind("lastAppliedSequence", to: statement, at: 1, database: database)
            let result = sqlite3_step(statement)
            if result == SQLITE_DONE {
                return nil
            }
            guard result == SQLITE_ROW else {
                throw sqliteError(database)
            }
            guard let value = Int(try columnText(statement, at: 0)) else {
                throw SQLiteRuntimeProjectionAdapterError.databaseFailure(
                    "invalid lastAppliedSequence metadata"
                )
            }
            return value
        }
    }

    private func withDatabase<T>(_ body: (OpaquePointer) throws -> T) throws -> T {
        var database: OpaquePointer?
        guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK, let openedDatabase = database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown sqlite open error"
            if let database {
                sqlite3_close(database)
            }
            throw SQLiteRuntimeProjectionAdapterError.databaseFailure(message)
        }
        defer {
            sqlite3_close(openedDatabase)
        }
        return try body(openedDatabase)
    }

    private func withStatement<T>(
        _ sql: String,
        database: OpaquePointer,
        body: (OpaquePointer) throws -> T
    ) throws -> T {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let preparedStatement = statement else {
            throw sqliteError(database)
        }
        defer {
            sqlite3_finalize(preparedStatement)
        }
        return try body(preparedStatement)
    }

    private func execute(_ sql: String, database: OpaquePointer) throws {
        guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
            throw sqliteError(database)
        }
    }

    private func bind(
        _ value: String,
        to statement: OpaquePointer,
        at index: Int32,
        database: OpaquePointer
    ) throws {
        let result = value.withCString { cString in
            sqlite3_bind_text(statement, index, cString, -1, Self.transientDestructor)
        }
        guard result == SQLITE_OK else {
            throw sqliteError(database)
        }
    }

    private func bind(
        _ value: Int,
        to statement: OpaquePointer,
        at index: Int32,
        database: OpaquePointer
    ) throws {
        guard sqlite3_bind_int64(statement, index, sqlite3_int64(value)) == SQLITE_OK else {
            throw sqliteError(database)
        }
    }

    private func stepDone(_ statement: OpaquePointer, database: OpaquePointer) throws {
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw sqliteError(database)
        }
    }

    private func columnText(_ statement: OpaquePointer, at index: Int32) throws -> String {
        guard let pointer = sqlite3_column_text(statement, index) else {
            throw SQLiteRuntimeProjectionAdapterError.missingProjectionPayload(
                "missing text column at index \(index)"
            )
        }
        return String(cString: UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
    }

    private func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        guard let encoded = String(data: data, encoding: .utf8) else {
            throw SQLiteRuntimeProjectionAdapterError.databaseFailure("unable to encode projection payload")
        }
        return encoded
    }

    private func decode<T: Decodable>(_ type: T.Type, from payload: String) throws -> T {
        guard let data = payload.data(using: .utf8) else {
            throw SQLiteRuntimeProjectionAdapterError.missingProjectionPayload(
                "projection payload is not valid UTF-8"
            )
        }
        return try JSONDecoder().decode(type, from: data)
    }

    private func sqliteError(_ database: OpaquePointer) -> SQLiteRuntimeProjectionAdapterError {
        SQLiteRuntimeProjectionAdapterError.databaseFailure(String(cString: sqlite3_errmsg(database)))
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

public enum DuckDBSignalSource: String, Codable, Equatable, Sendable {
    case backtest
    case orderBookImbalanceResearch
}

public struct DuckDBSignalTimelineProjection: Codable, Equatable, Sendable {
    public let source: DuckDBSignalSource
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let generatedAt: Date
    public let direction: SignalDirection
    public let close: Double?
    public let shortEMA: Double?
    public let longEMA: Double?
    public let bidNotional: Double?
    public let askNotional: Double?
    public let imbalanceRatio: Double?
    /// 订单簿研究信号的本地输入来源，只记录 snapshot / delta evidence，不暴露 DuckDB schema 或交易执行能力。
    public let orderBookInputSource: OrderBookReadModelSource?

    public init(
        source: DuckDBSignalSource,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        generatedAt: Date,
        direction: SignalDirection,
        close: Double? = nil,
        shortEMA: Double? = nil,
        longEMA: Double? = nil,
        bidNotional: Double? = nil,
        askNotional: Double? = nil,
        imbalanceRatio: Double? = nil,
        orderBookInputSource: OrderBookReadModelSource? = nil
    ) {
        self.source = source
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.generatedAt = generatedAt
        self.direction = direction
        self.close = close
        self.shortEMA = shortEMA
        self.longEMA = longEMA
        self.bidNotional = bidNotional
        self.askNotional = askNotional
        self.imbalanceRatio = imbalanceRatio
        self.orderBookInputSource = orderBookInputSource
    }
}

public struct DuckDBBacktestProjection: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        runID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        state: ProjectionLifecycleState,
        signalCount: Int,
        completedAt: Date?
    ) {
        self.runID = runID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.state = state
        self.signalCount = signalCount
        self.completedAt = completedAt
    }
}

public struct DuckDBOrderBookResearchProjection: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let strategyID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let depth: Int
    public let state: ProjectionLifecycleState
    public let signalCount: Int
    public let completedAt: Date?

    public init(
        researchID: Identifier,
        strategyID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        depth: Int,
        state: ProjectionLifecycleState,
        signalCount: Int,
        completedAt: Date?
    ) {
        self.researchID = researchID
        self.strategyID = strategyID
        self.symbol = symbol
        self.timeframe = timeframe
        self.depth = depth
        self.state = state
        self.signalCount = signalCount
        self.completedAt = completedAt
    }
}

public struct DuckDBAnalyticalProjectionSnapshot: Equatable, Sendable {
    public let marketBars: [MarketBar]
    public let trades: [TradeTick]
    public let bestBidAsks: [BestBidAsk]
    public let orderBookSnapshots: [OrderBookSnapshot]
    public let orderBookDeltas: [OrderBookDelta]
    public let backtestRuns: [Identifier: DuckDBBacktestProjection]
    public let orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection]
    public let signalTimeline: [DuckDBSignalTimelineProjection]
    public let lastAppliedSequence: Int?

    public init(
        marketBars: [MarketBar] = [],
        trades: [TradeTick] = [],
        bestBidAsks: [BestBidAsk] = [],
        orderBookSnapshots: [OrderBookSnapshot] = [],
        orderBookDeltas: [OrderBookDelta] = [],
        backtestRuns: [Identifier: DuckDBBacktestProjection] = [:],
        orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection] = [:],
        signalTimeline: [DuckDBSignalTimelineProjection] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.marketBars = marketBars
        self.trades = trades
        self.bestBidAsks = bestBidAsks
        self.orderBookSnapshots = orderBookSnapshots
        self.orderBookDeltas = orderBookDeltas
        self.backtestRuns = backtestRuns
        self.orderBookResearchRuns = orderBookResearchRuns
        self.signalTimeline = signalTimeline
        self.lastAppliedSequence = lastAppliedSequence
    }
}

/// DuckDB 分析投影边界面向 market data、backtest 和研究分析，不保存运行时对象。
public struct DuckDBAnalyticalProjectionStore: Equatable, Sendable {
    public private(set) var snapshot: DuckDBAnalyticalProjectionSnapshot

    public init(snapshot: DuckDBAnalyticalProjectionSnapshot = DuckDBAnalyticalProjectionSnapshot()) {
        self.snapshot = snapshot
    }

    @discardableResult
    public mutating func rebuild(from envelopes: [EventEnvelope]) -> DuckDBAnalyticalProjectionSnapshot {
        snapshot = Self.project(envelopes)
        return snapshot
    }

    public static func project(_ envelopes: [EventEnvelope]) -> DuckDBAnalyticalProjectionSnapshot {
        var marketBars: [MarketBar] = []
        var trades: [TradeTick] = []
        var bestBidAsks: [BestBidAsk] = []
        var orderBookSnapshots: [OrderBookSnapshot] = []
        var orderBookDeltas: [OrderBookDelta] = []
        var backtestRuns: [Identifier: DuckDBBacktestProjection] = [:]
        var orderBookResearchRuns: [Identifier: DuckDBOrderBookResearchProjection] = [:]
        var signalTimeline: [DuckDBSignalTimelineProjection] = []
        var lastAppliedSequence: Int?

        for envelope in envelopes.sorted(by: { $0.sequence < $1.sequence }) {
            switch envelope.event {
            case let .market(event):
                apply(
                    marketEvent: event,
                    marketBars: &marketBars,
                    trades: &trades,
                    bestBidAsks: &bestBidAsks,
                    orderBookSnapshots: &orderBookSnapshots,
                    orderBookDeltas: &orderBookDeltas
                )
                lastAppliedSequence = envelope.sequence
            case let .backtest(event):
                apply(
                    backtestEvent: event,
                    backtestRuns: &backtestRuns,
                    signalTimeline: &signalTimeline
                )
                lastAppliedSequence = envelope.sequence
            case let .orderBookImbalanceResearch(event):
                apply(
                    researchEvent: event,
                    orderBookResearchRuns: &orderBookResearchRuns,
                    signalTimeline: &signalTimeline
                )
                lastAppliedSequence = envelope.sequence
            default:
                continue
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
            lastAppliedSequence: lastAppliedSequence
        )
    }

    private static func apply(
        marketEvent: MarketEvent,
        marketBars: inout [MarketBar],
        trades: inout [TradeTick],
        bestBidAsks: inout [BestBidAsk],
        orderBookSnapshots: inout [OrderBookSnapshot],
        orderBookDeltas: inout [OrderBookDelta]
    ) {
        switch marketEvent {
        case let .bar(bar):
            marketBars.append(bar)
        case let .trade(trade):
            trades.append(trade)
        case let .bestBidAsk(bestBidAsk):
            bestBidAsks.append(bestBidAsk)
        case let .orderBookSnapshot(snapshot):
            orderBookSnapshots.append(snapshot)
        case let .orderBookDelta(delta):
            orderBookDeltas.append(delta)
        }
    }

    private static func apply(
        backtestEvent: BacktestEvent,
        backtestRuns: inout [Identifier: DuckDBBacktestProjection],
        signalTimeline: inout [DuckDBSignalTimelineProjection]
    ) {
        switch backtestEvent {
        case let .requested(command):
            let existing = backtestRuns[command.runID]
            backtestRuns[command.runID] = DuckDBBacktestProjection(
                runID: command.runID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                completedAt: existing?.completedAt
            )

        case let .signalGenerated(sample):
            signalTimeline.append(signalProjection(from: sample))

        case let .completed(result):
            backtestRuns[result.runID] = DuckDBBacktestProjection(
                runID: result.runID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                state: .completed,
                signalCount: result.signalSamples.count,
                completedAt: result.completedAt
            )
        }
    }

    private static func apply(
        researchEvent: OrderBookImbalanceResearchEvent,
        orderBookResearchRuns: inout [Identifier: DuckDBOrderBookResearchProjection],
        signalTimeline: inout [DuckDBSignalTimelineProjection]
    ) {
        switch researchEvent {
        case let .requested(command):
            let existing = orderBookResearchRuns[command.researchID]
            orderBookResearchRuns[command.researchID] = DuckDBOrderBookResearchProjection(
                researchID: command.researchID,
                strategyID: command.strategyID,
                symbol: command.strategy.symbol,
                timeframe: command.strategy.timeframe,
                depth: command.strategy.depth,
                state: existing?.state ?? .requested,
                signalCount: existing?.signalCount ?? 0,
                completedAt: existing?.completedAt
            )

        case let .signalGenerated(sample):
            signalTimeline.append(signalProjection(from: sample))

        case let .completed(result):
            orderBookResearchRuns[result.researchID] = DuckDBOrderBookResearchProjection(
                researchID: result.researchID,
                strategyID: result.command.strategyID,
                symbol: result.command.strategy.symbol,
                timeframe: result.command.strategy.timeframe,
                depth: result.command.strategy.depth,
                state: .completed,
                signalCount: result.signalSamples.count,
                completedAt: result.completedAt
            )
        }
    }

    private static func signalProjection(
        from sample: EMACrossSignalSample
    ) -> DuckDBSignalTimelineProjection {
        DuckDBSignalTimelineProjection(
            source: .backtest,
            strategyID: sample.signal.strategyID,
            symbol: sample.signal.symbol,
            timeframe: sample.signal.timeframe,
            generatedAt: sample.signal.generatedAt,
            direction: sample.signal.direction,
            close: sample.close.rawValue,
            shortEMA: sample.shortEMA.rawValue,
            longEMA: sample.longEMA.rawValue
        )
    }

    private static func signalProjection(
        from sample: OrderBookImbalanceSignalSample
    ) -> DuckDBSignalTimelineProjection {
        DuckDBSignalTimelineProjection(
            source: .orderBookImbalanceResearch,
            strategyID: sample.signal.strategyID,
            symbol: sample.signal.symbol,
            timeframe: sample.signal.timeframe,
            generatedAt: sample.signal.generatedAt,
            direction: sample.signal.direction,
            bidNotional: sample.bidNotional,
            askNotional: sample.askNotional,
            imbalanceRatio: sample.imbalanceRatio,
            orderBookInputSource: sample.inputSource
        )
    }
}
