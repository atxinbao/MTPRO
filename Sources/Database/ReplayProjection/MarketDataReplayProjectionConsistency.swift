import Foundation
import Adapters
import Core
import Persistence

/// MTP-186 将 market data replay projection consistency 迁入 `Sources/Database/ReplayProjection/`。
///
/// 当前文件仍由 `Runtime` target compatibility envelope 编译，因为它串接 DataClient replay
/// metadata、Cache snapshot、SQLite runtime projection 和 DuckDB analytical projection。这里的
/// Database / ReplayProjection 只产出稳定 read-model evidence，不暴露 SQLite / DuckDB schema、
/// Runtime object、Adapter request、broker payload 或 live trading command。
/// MarketDataReplayProjectionConsistencyError 描述 MTP-58 本地 replay consistency 证据链的失败原因。
/// 错误只覆盖本地 batch replay、append-only event log 和 projection snapshot 对齐问题；
/// 它不表达真实 Binance 网络、signed endpoint、account endpoint、broker 或真实订单状态。
public enum MarketDataReplayProjectionConsistencyError: Error, Equatable, Sendable, CustomStringConvertible {
    case nonLocalReplayEvidence
    case freshnessEvidenceMismatch(field: String, expected: String, actual: String)
    case emptyEventLog
    case eventLogStreamMismatch(sequence: Int, actual: String)
    case eventLogNonMarketBarEvent(sequence: Int)
    case eventLogRecordCountMismatch(expected: Int, actual: Int)
    case eventLogReplayOutputMismatch(expected: [String], actual: [String])
    case replayResultMismatch(expectedSequences: [Int], actualSequences: [Int])
    case cacheSnapshotMismatch(expected: [String], actual: [String])
    case analyticalProjectionMismatch(expected: [String], actual: [String])
    case analyticalProjectionLastSequenceMismatch(expected: Int?, actual: Int?)
    case runtimeProjectionNotEmpty
    case projectionSourceBoundaryViolation

    public var description: String {
        switch self {
        case .nonLocalReplayEvidence:
            "Market data replay projection consistency requires public read-only local replay evidence"
        case let .freshnessEvidenceMismatch(field, expected, actual):
            "Market data replay freshness evidence mismatch for \(field), expected \(expected), actual \(actual)"
        case .emptyEventLog:
            "Market data replay projection consistency requires at least one event log fact"
        case let .eventLogStreamMismatch(sequence, actual):
            "Market data replay event log sequence \(sequence) used unexpected stream \(actual)"
        case let .eventLogNonMarketBarEvent(sequence):
            "Market data replay event log sequence \(sequence) is not a market bar fact"
        case let .eventLogRecordCountMismatch(expected, actual):
            "Market data replay event log record count mismatch, expected \(expected), actual \(actual)"
        case let .eventLogReplayOutputMismatch(expected, actual):
            "Market data replay event log summary mismatch, expected \(expected), actual \(actual)"
        case let .replayResultMismatch(expectedSequences, actualSequences):
            "Market data replay result sequences mismatch, expected \(expectedSequences), actual \(actualSequences)"
        case let .cacheSnapshotMismatch(expected, actual):
            "Market data replay cache snapshot mismatch, expected \(expected), actual \(actual)"
        case let .analyticalProjectionMismatch(expected, actual):
            "Market data replay analytical projection mismatch, expected \(expected), actual \(actual)"
        case let .analyticalProjectionLastSequenceMismatch(expected, actual):
            "Market data replay analytical projection last sequence mismatch, expected \(String(describing: expected)), actual \(String(describing: actual))"
        case .runtimeProjectionNotEmpty:
            "Market data replay runtime projection must remain empty for market-only replay facts"
        case .projectionSourceBoundaryViolation:
            "Market data replay projection consistency source exposed schema, runtime, adapter, broker, or trading surface"
        }
    }
}

/// MarketDataReplayProjectionSourceContract 固定 projection consistency summary 的只读来源边界。
///
/// 该 source 表示 UI 后续只能消费稳定 read model / ViewModel 字段，不得直连 SQLite / DuckDB schema、
/// ORM、Runtime object、adapter request 或任何交易执行入口。
public struct MarketDataReplayProjectionSourceContract: Codable, Equatable, Sendable {
    public let sourceKind: String
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesORMModels: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let exposesSQLStatement: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool

    public init(
        sourceKind: String = "stable market data replay projection consistency read model",
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        exposesORMModels: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesAdapterRequest: Bool = false,
        exposesSQLStatement: Bool = false,
        authorizesLiveTrading: Bool = false,
        touchesBrokerAction: Bool = false,
        authorizesTradingExecution: Bool = false,
        authorizesProductionRuntimeOperations: Bool = false
    ) {
        self.sourceKind = sourceKind
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.exposesORMModels = exposesORMModels
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesSQLStatement = exposesSQLStatement
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = authorizesProductionRuntimeOperations
    }

    /// isReadModelOnly 证明 summary 来源没有把投影实现细节或交易能力暴露给 UI。
    public var isReadModelOnly: Bool {
        sourceKind == "stable market data replay projection consistency read model"
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && exposesORMModels == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && exposesSQLStatement == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && authorizesProductionRuntimeOperations == false
    }
}

/// MarketDataReplayEventLogConsistencyEvidence 汇总 replay output 写入 append-only event log 后的事实证据。
///
/// 该 evidence 只记录 `.market` stream 中的本地 `MarketBar` facts、sequence、record count 和 replay
/// output summary 对齐结果；它不保存数据库表结构、不读取 adapter request、不表达生产运营或交易授权。
public struct MarketDataReplayEventLogConsistencyEvidence: Codable, Equatable, Sendable {
    public let batchID: String
    public let replayRunID: String
    public let eventLogStream: String
    public let eventLogSequences: [Int]
    public let replayResultSequences: [Int]
    public let eventLogRecordCount: Int
    public let metadataRecordCount: Int
    public let replayConsistencyRecordCount: Int
    public let eventLogLastSequence: Int?
    public let replayCommandRange: String
    public let appendOnlyFactsSource: Bool
    public let eventLogMatchesReplayOutput: Bool
    public let summaryLine: String

    public init(
        metadata: BinanceMarketDataReplayOperationsMetadata,
        replayConsistencyEvidence: BinanceMarketDataBatchReplayConsistencyEvidence,
        eventLogSequences: [Int],
        replayResultSequences: [Int],
        appendOnlyFactsSource: Bool
    ) {
        let eventLogLastSequence = eventLogSequences.last
        let eventLogStream = EventStreamID.market.rawValue

        self.batchID = metadata.batchID.rawValue
        self.replayRunID = metadata.replayRunID.rawValue
        self.eventLogStream = eventLogStream
        self.eventLogSequences = eventLogSequences
        self.replayResultSequences = replayResultSequences
        self.eventLogRecordCount = eventLogSequences.count
        self.metadataRecordCount = metadata.recordCount
        self.replayConsistencyRecordCount = replayConsistencyEvidence.recordCount
        self.eventLogLastSequence = eventLogLastSequence
        self.replayCommandRange = eventLogLastSequence.map { "1...\($0)" } ?? "empty"
        self.appendOnlyFactsSource = appendOnlyFactsSource
        self.eventLogMatchesReplayOutput = appendOnlyFactsSource
            && eventLogSequences == replayResultSequences
            && eventLogSequences.count == metadata.recordCount
            && metadata.recordCount == replayConsistencyEvidence.recordCount
        let sequenceSummary = eventLogSequences.map(String.init).joined(separator: ",")
        self.summaryLine = "batch=\(metadata.batchID.rawValue); replay=\(metadata.replayRunID.rawValue); stream=\(eventLogStream); sequences=\(sequenceSummary); appendOnly=\(appendOnlyFactsSource)"
    }
}

/// MarketDataReplayProjectionSnapshotConsistencySummary 是 MTP-58 的稳定 projection consistency read model。
///
/// Summary 把 replay metadata、freshness evidence、fixture parity、append-only event log replay、
/// cache snapshot、SQLite runtime projection 和 DuckDB analytical projection 串成可审计证据链。
/// 输出只包含 read model 字段和计数 / summary，不暴露 SQLite / DuckDB schema、SQL、ORM、adapter
/// request 或 Runtime object，也不授权 Live trading、broker action 或真实订单行为。
public struct MarketDataReplayProjectionSnapshotConsistencySummary: Codable, Equatable, Sendable {
    public let source: MarketDataReplayProjectionSourceContract
    public let batchID: String
    public let replayRunID: String
    public let symbol: String
    public let timeframe: String
    public let timeWindowDescription: String
    public let freshnessStatus: BinanceMarketDataReplayFreshnessStatus
    public let freshnessSummary: String
    public let eventLogEvidence: MarketDataReplayEventLogConsistencyEvidence
    public let replayOutputSummary: [String]
    public let projectionSnapshotSummary: [String]
    public let cacheSnapshotSummary: [String]
    public let consistencyEvidence: [String]
    public let metadataRecordCount: Int
    public let eventLogRecordCount: Int
    public let replayedRecordCount: Int
    public let cacheMarketEventCount: Int
    public let cacheBarCount: Int
    public let analyticalMarketBarCount: Int
    public let runtimeProjectionPaperSessionCount: Int
    public let runtimeProjectionRiskEvidenceCount: Int
    public let runtimeProjectionPortfolioCount: Int
    public let eventLogLastSequence: Int?
    public let projectionLastAppliedSequence: Int?
    public let appendOnlyFactsSource: Bool
    public let eventLogConsistencyHeld: Bool
    public let projectionSnapshotConsistencyHeld: Bool
    public let deterministicProjectionSummary: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLStatement: Bool
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let requiredValidationIsLocalOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool
    public let summaryLine: String

    public init(
        source: MarketDataReplayProjectionSourceContract,
        contract: BinanceMarketDataBatchReplayContract,
        freshnessEvidence: BinanceMarketDataReplayFreshnessEvidenceReadModel,
        replayConsistencyEvidence: BinanceMarketDataBatchReplayConsistencyEvidence,
        eventLogEvidence: MarketDataReplayEventLogConsistencyEvidence,
        replayOutputSummary: [String],
        projectionSnapshotSummary: [String],
        cacheSnapshotSummary: [String],
        cacheMarketEventCount: Int,
        runtimeProjectionSnapshot: SQLiteRuntimeProjectionSnapshot,
        projectionLastAppliedSequence: Int?
    ) {
        let metadata = contract.metadata
        let runtimeProjectionPaperSessionCount = runtimeProjectionSnapshot.paperSessions.count
        let runtimeProjectionRiskEvidenceCount = runtimeProjectionSnapshot.riskBlockerEvidence.count
        let runtimeProjectionPortfolioCount = runtimeProjectionSnapshot.portfolioProjections.count
        let projectionSnapshotConsistencyHeld = projectionSnapshotSummary == replayOutputSummary
            && cacheSnapshotSummary == replayOutputSummary
            && eventLogEvidence.eventLogMatchesReplayOutput
            && projectionLastAppliedSequence == eventLogEvidence.eventLogLastSequence
            && runtimeProjectionPaperSessionCount == 0
            && runtimeProjectionRiskEvidenceCount == 0
            && runtimeProjectionPortfolioCount == 0
        let authorizesLiveTrading = source.authorizesLiveTrading
            || replayConsistencyEvidence.authorizesLiveTrading
        let touchesBrokerAction = source.touchesBrokerAction
            || replayConsistencyEvidence.touchesBrokerAction
        let authorizesTradingExecution = source.authorizesTradingExecution
            || contract.authorizesTradingExecution
            || replayConsistencyEvidence.authorizesTradingExecution
        let authorizesProductionRuntimeOperations = source.authorizesProductionRuntimeOperations
            || contract.authorizesProductionRuntimeOperations
            || replayConsistencyEvidence.authorizesProductionRuntimeOperations
        let readModelOnlyBoundaryHeld = source.isReadModelOnly
            && freshnessEvidence.readModelOnlyBoundaryHeld
            && contract.isPublicReadOnly
            && contract.isLocalFixtureReplayOnly
            && contract.requiredValidationIsLocalOnly
            && contract.requiredValidationDependsOnNetwork == false
            && replayConsistencyEvidence.networkIndependent
            && replayConsistencyEvidence.authorizesTradingExecution == false
            && replayConsistencyEvidence.authorizesProductionRuntimeOperations == false
        let finalReadModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
            && source.exposesSQLiteSchema == false
            && source.exposesDuckDBSchema == false
            && source.exposesAdapterRequest == false
            && source.exposesRuntimeObject == false
            && source.exposesSQLStatement == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && authorizesProductionRuntimeOperations == false
            && projectionSnapshotConsistencyHeld

        self.source = source
        self.batchID = metadata.batchID.rawValue
        self.replayRunID = metadata.replayRunID.rawValue
        self.symbol = metadata.symbol.rawValue
        self.timeframe = metadata.timeframe.rawValue
        self.timeWindowDescription = metadata.timeWindowDescription
        self.freshnessStatus = freshnessEvidence.status
        self.freshnessSummary = freshnessEvidence.freshnessSummary
        self.eventLogEvidence = eventLogEvidence
        self.replayOutputSummary = replayOutputSummary
        self.projectionSnapshotSummary = projectionSnapshotSummary
        self.cacheSnapshotSummary = cacheSnapshotSummary
        self.metadataRecordCount = metadata.recordCount
        self.eventLogRecordCount = eventLogEvidence.eventLogRecordCount
        self.replayedRecordCount = replayConsistencyEvidence.recordCount
        self.cacheMarketEventCount = cacheMarketEventCount
        self.cacheBarCount = cacheSnapshotSummary.count
        self.analyticalMarketBarCount = projectionSnapshotSummary.count
        self.runtimeProjectionPaperSessionCount = runtimeProjectionPaperSessionCount
        self.runtimeProjectionRiskEvidenceCount = runtimeProjectionRiskEvidenceCount
        self.runtimeProjectionPortfolioCount = runtimeProjectionPortfolioCount
        self.eventLogLastSequence = eventLogEvidence.eventLogLastSequence
        self.projectionLastAppliedSequence = projectionLastAppliedSequence
        self.appendOnlyFactsSource = eventLogEvidence.appendOnlyFactsSource
        self.eventLogConsistencyHeld = eventLogEvidence.eventLogMatchesReplayOutput
        self.projectionSnapshotConsistencyHeld = projectionSnapshotConsistencyHeld
        self.deterministicProjectionSummary = projectionSnapshotConsistencyHeld
            && projectionSnapshotSummary == replayOutputSummary
        self.exposesSQLiteSchema = source.exposesSQLiteSchema
        self.exposesDuckDBSchema = source.exposesDuckDBSchema
        self.exposesAdapterRequest = source.exposesAdapterRequest
        self.exposesRuntimeObject = source.exposesRuntimeObject
        self.exposesSQLStatement = source.exposesSQLStatement
        self.isPublicReadOnly = contract.isPublicReadOnly
        self.isLocalFixtureReplayOnly = contract.isLocalFixtureReplayOnly
        self.requiredValidationIsLocalOnly = contract.requiredValidationIsLocalOnly
        self.requiredValidationDependsOnNetwork = contract.requiredValidationDependsOnNetwork
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = authorizesProductionRuntimeOperations
        self.readModelOnlyBoundaryHeld = finalReadModelOnlyBoundaryHeld
        let projectionLastAppliedSequenceDescription = projectionLastAppliedSequence.map(String.init) ?? "nil"
        self.consistencyEvidence = [
            eventLogEvidence.summaryLine,
            "metadataRecords=\(metadata.recordCount); replayRecords=\(replayConsistencyEvidence.recordCount); eventLogRecords=\(eventLogEvidence.eventLogRecordCount)",
            "cacheBars=\(cacheSnapshotSummary.count); analyticalBars=\(projectionSnapshotSummary.count); projectionLastSequence=\(projectionLastAppliedSequenceDescription)",
            "freshness=\(freshnessEvidence.status.rawValue); readModelOnly=\(finalReadModelOnlyBoundaryHeld)"
        ]
        self.summaryLine = "batch=\(metadata.batchID.rawValue); replay=\(metadata.replayRunID.rawValue); eventLogRecords=\(eventLogEvidence.eventLogRecordCount); replayRecords=\(replayConsistencyEvidence.recordCount); cacheBars=\(cacheSnapshotSummary.count); analyticalBars=\(projectionSnapshotSummary.count); projectionLastSequence=\(projectionLastAppliedSequenceDescription); readModelOnly=\(finalReadModelOnlyBoundaryHeld)"
    }

    /// 检查 summary 字段是否混入 signed/account/listenKey/broker/order 等禁区文本。
    public func containsForbiddenCapabilityText(
        _ forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability]
    ) -> Bool {
        let serialized = (
            [
                batchID,
                replayRunID,
                symbol,
                timeframe,
                timeWindowDescription,
                freshnessSummary,
                source.sourceKind,
                summaryLine
            ] + replayOutputSummary + projectionSnapshotSummary + cacheSnapshotSummary + consistencyEvidence
        )
        .joined(separator: " ")
        .lowercased()

        return forbiddenCapabilities.contains { capability in
            serialized.contains(capability.rawValue.lowercased())
        }
    }
}

/// MarketDataReplayProjectionConsistency 负责构造 MTP-58 的最小 consistency evidence。
///
/// 该工具只消费本地 replay metadata / freshness / parity evidence 与 append-only event log facts，
/// 并从同一 replay command 生成 cache、SQLite runtime 和 DuckDB analytical projection snapshots。
/// 输出是稳定 summary，不把 projection schema 或 adapter/runtime 对象暴露给 UI。
public enum MarketDataReplayProjectionConsistency {
    public static func summarize(
        contract: BinanceMarketDataBatchReplayContract,
        freshnessEvidence: BinanceMarketDataReplayFreshnessEvidenceReadModel,
        replayConsistencyEvidence: BinanceMarketDataBatchReplayConsistencyEvidence,
        eventLogEnvelopes: [EventEnvelope],
        source: MarketDataReplayProjectionSourceContract = MarketDataReplayProjectionSourceContract()
    ) throws -> MarketDataReplayProjectionSnapshotConsistencySummary {
        try validateBoundary(
            contract: contract,
            freshnessEvidence: freshnessEvidence,
            replayConsistencyEvidence: replayConsistencyEvidence,
            source: source
        )
        guard eventLogEnvelopes.isEmpty == false else {
            throw MarketDataReplayProjectionConsistencyError.emptyEventLog
        }

        let validatedEventLog = try AppendOnlyEventLog(envelopes: eventLogEnvelopes)
        let command = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 1, upperBound: eventLogEnvelopes.count),
            streams: [.market]
        )
        let replayBoundary = try PersistenceReplayBoundary(envelopes: validatedEventLog.envelopes)
        let replay = replayBoundary.replay(command)

        return try summarize(
            contract: contract,
            freshnessEvidence: freshnessEvidence,
            replayConsistencyEvidence: replayConsistencyEvidence,
            eventLogEnvelopes: validatedEventLog.envelopes,
            replayResult: replay,
            cacheSnapshot: replayBoundary.rebuildMarketDataCache(from: command),
            runtimeProjectionSnapshot: replayBoundary.rebuildSQLiteRuntimeProjection(from: command),
            analyticalProjectionSnapshot: replayBoundary.rebuildDuckDBAnalyticalProjection(from: command),
            source: source
        )
    }

    public static func summarize(
        contract: BinanceMarketDataBatchReplayContract,
        freshnessEvidence: BinanceMarketDataReplayFreshnessEvidenceReadModel,
        replayConsistencyEvidence: BinanceMarketDataBatchReplayConsistencyEvidence,
        eventLogEnvelopes: [EventEnvelope],
        replayResult: EventReplayResult,
        cacheSnapshot: MarketDataCacheSnapshot,
        runtimeProjectionSnapshot: SQLiteRuntimeProjectionSnapshot,
        analyticalProjectionSnapshot: DuckDBAnalyticalProjectionSnapshot,
        source: MarketDataReplayProjectionSourceContract = MarketDataReplayProjectionSourceContract()
    ) throws -> MarketDataReplayProjectionSnapshotConsistencySummary {
        try validateBoundary(
            contract: contract,
            freshnessEvidence: freshnessEvidence,
            replayConsistencyEvidence: replayConsistencyEvidence,
            source: source
        )
        guard eventLogEnvelopes.isEmpty == false else {
            throw MarketDataReplayProjectionConsistencyError.emptyEventLog
        }

        let eventLog = try AppendOnlyEventLog(envelopes: eventLogEnvelopes)
        let metadata = contract.metadata
        try validateFreshnessEvidence(freshnessEvidence, metadata: metadata)

        let replayResultSequences = replayResult.envelopes.map(\.sequence)
        let eventLogSequences = eventLog.envelopes.map(\.sequence)
        guard replayResultSequences == eventLogSequences else {
            throw MarketDataReplayProjectionConsistencyError.replayResultMismatch(
                expectedSequences: eventLogSequences,
                actualSequences: replayResultSequences
            )
        }

        let eventLogBars = try marketBars(from: eventLog.envelopes)
        guard eventLogBars.count == metadata.recordCount else {
            throw MarketDataReplayProjectionConsistencyError.eventLogRecordCountMismatch(
                expected: metadata.recordCount,
                actual: eventLogBars.count
            )
        }

        let eventLogSummary = BinanceMarketDataBatchReplayDeterministicParity
            .canonicalReplaySummary(for: eventLogBars)
        guard eventLogSummary == replayConsistencyEvidence.replayOutputSummary else {
            throw MarketDataReplayProjectionConsistencyError.eventLogReplayOutputMismatch(
                expected: replayConsistencyEvidence.replayOutputSummary,
                actual: eventLogSummary
            )
        }

        let cacheSummary = BinanceMarketDataBatchReplayDeterministicParity
            .canonicalReplaySummary(for: cacheBars(from: cacheSnapshot))
        guard cacheSummary == replayConsistencyEvidence.replayOutputSummary else {
            throw MarketDataReplayProjectionConsistencyError.cacheSnapshotMismatch(
                expected: replayConsistencyEvidence.replayOutputSummary,
                actual: cacheSummary
            )
        }

        let analyticalSummary = BinanceMarketDataBatchReplayDeterministicParity
            .canonicalReplaySummary(for: analyticalProjectionSnapshot.marketBars)
        guard analyticalSummary == replayConsistencyEvidence.replayOutputSummary else {
            throw MarketDataReplayProjectionConsistencyError.analyticalProjectionMismatch(
                expected: replayConsistencyEvidence.replayOutputSummary,
                actual: analyticalSummary
            )
        }

        guard analyticalProjectionSnapshot.lastAppliedSequence == eventLogSequences.last else {
            throw MarketDataReplayProjectionConsistencyError.analyticalProjectionLastSequenceMismatch(
                expected: eventLogSequences.last,
                actual: analyticalProjectionSnapshot.lastAppliedSequence
            )
        }

        guard runtimeProjectionSnapshot.paperSessions.isEmpty,
              runtimeProjectionSnapshot.riskBlockerEvidence.isEmpty,
              runtimeProjectionSnapshot.portfolioProjections.isEmpty else {
            throw MarketDataReplayProjectionConsistencyError.runtimeProjectionNotEmpty
        }

        let eventLogEvidence = MarketDataReplayEventLogConsistencyEvidence(
            metadata: metadata,
            replayConsistencyEvidence: replayConsistencyEvidence,
            eventLogSequences: eventLogSequences,
            replayResultSequences: replayResultSequences,
            appendOnlyFactsSource: true
        )

        return MarketDataReplayProjectionSnapshotConsistencySummary(
            source: source,
            contract: contract,
            freshnessEvidence: freshnessEvidence,
            replayConsistencyEvidence: replayConsistencyEvidence,
            eventLogEvidence: eventLogEvidence,
            replayOutputSummary: replayConsistencyEvidence.replayOutputSummary,
            projectionSnapshotSummary: analyticalSummary,
            cacheSnapshotSummary: cacheSummary,
            cacheMarketEventCount: cacheSnapshot.marketEventCount,
            runtimeProjectionSnapshot: runtimeProjectionSnapshot,
            projectionLastAppliedSequence: analyticalProjectionSnapshot.lastAppliedSequence
        )
    }

    private static func validateBoundary(
        contract: BinanceMarketDataBatchReplayContract,
        freshnessEvidence: BinanceMarketDataReplayFreshnessEvidenceReadModel,
        replayConsistencyEvidence: BinanceMarketDataBatchReplayConsistencyEvidence,
        source: MarketDataReplayProjectionSourceContract
    ) throws {
        guard contract.isPublicReadOnly,
              contract.isLocalFixtureReplayOnly,
              contract.requiredValidationIsLocalOnly,
              contract.requiredValidationDependsOnNetwork == false,
              contract.authorizesTradingExecution == false,
              contract.authorizesProductionRuntimeOperations == false,
              freshnessEvidence.readModelOnlyBoundaryHeld,
              replayConsistencyEvidence.networkIndependent,
              replayConsistencyEvidence.authorizesTradingExecution == false,
              replayConsistencyEvidence.authorizesProductionRuntimeOperations == false else {
            throw MarketDataReplayProjectionConsistencyError.nonLocalReplayEvidence
        }

        guard source.isReadModelOnly else {
            throw MarketDataReplayProjectionConsistencyError.projectionSourceBoundaryViolation
        }
    }

    private static func validateFreshnessEvidence(
        _ freshnessEvidence: BinanceMarketDataReplayFreshnessEvidenceReadModel,
        metadata: BinanceMarketDataReplayOperationsMetadata
    ) throws {
        let expectedFields: [(field: String, expected: String, actual: String)] = [
            ("batchID", metadata.batchID.rawValue, freshnessEvidence.batchID),
            ("replayRunID", metadata.replayRunID.rawValue, freshnessEvidence.replayRunID),
            ("symbol", metadata.symbol.rawValue, freshnessEvidence.symbol),
            ("timeframe", metadata.timeframe.rawValue, freshnessEvidence.timeframe),
            ("timeWindowDescription", metadata.timeWindowDescription, freshnessEvidence.timeWindowDescription),
            ("fixtureSource", metadata.fixtureSource.rawValue, freshnessEvidence.fixtureSource),
            ("checksumParityHint", metadata.checksumParityHint, freshnessEvidence.checksumParityHint)
        ]

        for field in expectedFields where field.expected != field.actual {
            throw MarketDataReplayProjectionConsistencyError.freshnessEvidenceMismatch(
                field: field.field,
                expected: field.expected,
                actual: field.actual
            )
        }

        guard metadata.recordCount == freshnessEvidence.recordCount else {
            throw MarketDataReplayProjectionConsistencyError.freshnessEvidenceMismatch(
                field: "recordCount",
                expected: String(metadata.recordCount),
                actual: String(freshnessEvidence.recordCount)
            )
        }
    }

    private static func marketBars(from envelopes: [EventEnvelope]) throws -> [MarketBar] {
        try envelopes.map { envelope in
            guard envelope.stream == .market else {
                throw MarketDataReplayProjectionConsistencyError.eventLogStreamMismatch(
                    sequence: envelope.sequence,
                    actual: envelope.stream.rawValue
                )
            }
            guard case let .market(.bar(bar)) = envelope.event else {
                throw MarketDataReplayProjectionConsistencyError.eventLogNonMarketBarEvent(
                    sequence: envelope.sequence
                )
            }
            return bar
        }
    }

    private static func cacheBars(from snapshot: MarketDataCacheSnapshot) -> [MarketBar] {
        snapshot.barsBySeries
            .sorted { lhs, rhs in
                if lhs.key.symbol.rawValue != rhs.key.symbol.rawValue {
                    return lhs.key.symbol.rawValue < rhs.key.symbol.rawValue
                }
                return lhs.key.timeframe.rawValue < rhs.key.timeframe.rawValue
            }
            .flatMap { element in
                element.value.sorted {
                    $0.interval.start < $1.interval.start
                }
            }
    }
}

/// MarketDataReplayProjectionConsistencyFixture 提供 MTP-58 deterministic evidence fixture。
/// Fixture 只在本地构造 append-only market event log 和 projection summary，不读取文件系统、
/// 不调用 Binance 网络，不连接 broker，也不执行真实订单动作。
public enum MarketDataReplayProjectionConsistencyFixture {
    public static func deterministicEventLogEnvelopes() throws -> [EventEnvelope] {
        let replayRecords = try BinanceMarketDataReplayOperationsFixture.deterministicReplayRecords()
        var eventLog = try AppendOnlyEventLog()
        for (index, record) in replayRecords.enumerated() {
            try eventLog.append(
                .market(.bar(record)),
                stream: .market,
                recordedAt: Date(timeIntervalSince1970: 1_704_067_300 + TimeInterval(index))
            )
        }
        return eventLog.envelopes
    }

    public static func deterministicSummary(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_704_067_380)
    ) throws -> MarketDataReplayProjectionSnapshotConsistencySummary {
        let contract = try BinanceMarketDataReplayOperationsFixture.deterministicContract()
        return try MarketDataReplayProjectionConsistency.summarize(
            contract: contract,
            freshnessEvidence: try BinanceMarketDataReplayOperationsFixture.deterministicFreshnessEvidence(
                evaluatedAt: evaluatedAt
            ),
            replayConsistencyEvidence: try BinanceMarketDataReplayOperationsFixture
                .deterministicReplayConsistencyEvidence(),
            eventLogEnvelopes: deterministicEventLogEnvelopes()
        )
    }
}
