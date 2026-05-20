import Foundation

/// MarketDataReplayOperationsRetentionStatus 是 Dashboard / Report 展示 retention evidence 的稳定标签。
///
/// 该枚举只表达已经由上游 replay operations read model 计算好的保留状态；
/// 它不执行 retention cleanup、不访问 storage tiering，也不代表 production operations console。
public enum MarketDataReplayOperationsRetentionStatus: String, Codable, Equatable, Hashable, Sendable {
    case retained
    case notRetained = "not retained"
    case expired
}

/// MarketDataReplayOperationsEvidenceItem 是 MTP-59 的 App 层 replay operations 只读证据行。
///
/// 该类型复制 MTP-58 projection consistency summary 中允许进入 UI 的字段：batch / replay id、
/// freshness / retention 状态、event log 与 projection summary，以及全部 boundary flags。
/// 它不持有 Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM model、broker
/// order id 或任何可执行命令。
public struct MarketDataReplayOperationsEvidenceItem: Codable, Equatable, Sendable {
    public let batchID: String
    public let replayRunID: String
    public let symbol: String
    public let timeframe: String
    public let freshnessStatus: String
    public let retentionStatus: MarketDataReplayOperationsRetentionStatus
    public let projectionConsistencySummary: String
    public let metadataRecordCount: Int
    public let eventLogRecordCount: Int
    public let replayedRecordCount: Int
    public let cacheBarCount: Int
    public let analyticalMarketBarCount: Int
    public let eventLogLastSequence: Int?
    public let projectionLastAppliedSequence: Int?
    public let eventLogConsistencyHeld: Bool
    public let projectionSnapshotConsistencyHeld: Bool
    public let deterministicProjectionSummary: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let requiredValidationIsLocalOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLStatement: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool

    public init(
        batchID: String,
        replayRunID: String,
        symbol: String,
        timeframe: String,
        freshnessStatus: String,
        retentionStatus: MarketDataReplayOperationsRetentionStatus,
        projectionConsistencySummary: String,
        metadataRecordCount: Int,
        eventLogRecordCount: Int,
        replayedRecordCount: Int,
        cacheBarCount: Int,
        analyticalMarketBarCount: Int,
        eventLogLastSequence: Int?,
        projectionLastAppliedSequence: Int?,
        eventLogConsistencyHeld: Bool,
        projectionSnapshotConsistencyHeld: Bool,
        deterministicProjectionSummary: Bool,
        readModelOnlyBoundaryHeld: Bool,
        isPublicReadOnly: Bool,
        isLocalFixtureReplayOnly: Bool,
        requiredValidationIsLocalOnly: Bool,
        requiredValidationDependsOnNetwork: Bool,
        exposesSQLiteSchema: Bool,
        exposesDuckDBSchema: Bool,
        exposesAdapterRequest: Bool,
        exposesRuntimeObject: Bool,
        exposesSQLStatement: Bool,
        authorizesLiveTrading: Bool,
        touchesBrokerAction: Bool,
        authorizesTradingExecution: Bool,
        authorizesProductionRuntimeOperations: Bool
    ) {
        self.batchID = batchID
        self.replayRunID = replayRunID
        self.symbol = symbol
        self.timeframe = timeframe
        self.freshnessStatus = freshnessStatus
        self.retentionStatus = retentionStatus
        self.projectionConsistencySummary = projectionConsistencySummary
        self.metadataRecordCount = metadataRecordCount
        self.eventLogRecordCount = eventLogRecordCount
        self.replayedRecordCount = replayedRecordCount
        self.cacheBarCount = cacheBarCount
        self.analyticalMarketBarCount = analyticalMarketBarCount
        self.eventLogLastSequence = eventLogLastSequence
        self.projectionLastAppliedSequence = projectionLastAppliedSequence
        self.eventLogConsistencyHeld = eventLogConsistencyHeld
        self.projectionSnapshotConsistencyHeld = projectionSnapshotConsistencyHeld
        self.deterministicProjectionSummary = deterministicProjectionSummary
        self.readModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
        self.isPublicReadOnly = isPublicReadOnly
        self.isLocalFixtureReplayOnly = isLocalFixtureReplayOnly
        self.requiredValidationIsLocalOnly = requiredValidationIsLocalOnly
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesSQLStatement = exposesSQLStatement
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = authorizesProductionRuntimeOperations
    }

    /// boundaryHeld 汇总 UI 可消费 replay operations evidence 的禁区检查结果。
    public var boundaryHeld: Bool {
        readModelOnlyBoundaryHeld
            && isPublicReadOnly
            && isLocalFixtureReplayOnly
            && requiredValidationIsLocalOnly
            && requiredValidationDependsOnNetwork == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && exposesAdapterRequest == false
            && exposesRuntimeObject == false
            && exposesSQLStatement == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && authorizesProductionRuntimeOperations == false
    }
}

/// MarketDataReplayOperationsEvidenceReadModel 汇总 Report / Dashboard / Event Timeline 的 replay 输入。
///
/// 上游 Runtime / Adapter 层可以把已验证 summary 转换为这些稳定字段；App 层只排序和聚合，
/// 不触发 replay、不读取 database schema、不调用 adapter，也不执行 retention 或 projection side effect。
public struct MarketDataReplayOperationsEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [MarketDataReplayOperationsEvidenceItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        items: [MarketDataReplayOperationsEvidenceItem] = [],
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.items = items.sorted { left, right in
            if left.batchID != right.batchID {
                return left.batchID < right.batchID
            }
            return left.replayRunID < right.replayRunID
        }
        self.lastAppliedSequence = Self.maxSequence(
            lastAppliedSequence,
            items.compactMap(\.eventLogLastSequence).max(),
            items.compactMap(\.projectionLastAppliedSequence).max()
        )
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly && items.allSatisfy(\.boundaryHeld)
    }

    private static func maxSequence(_ values: Int?...) -> Int? {
        values.compactMap { $0 }.max()
    }
}

/// MarketDataReplayOperationsEvidenceViewModel 是 Dashboard 可编码的 replay operations 观察快照。
///
/// ViewModel 只从 `MarketDataReplayOperationsEvidenceReadModel` 派生计数、ID、状态和 boundary
/// flags。它不提供按钮、表单、query language、Runtime command、order-level command 或交易授权。
public struct MarketDataReplayOperationsEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let items: [MarketDataReplayOperationsEvidenceItem]
    public let evidenceCount: Int
    public let batchIDs: [String]
    public let replayRunIDs: [String]
    public let freshnessStatuses: [String]
    public let retentionStatuses: [MarketDataReplayOperationsRetentionStatus]
    public let projectionConsistencySummaries: [String]
    public let consistentProjectionCount: Int
    public let freshBatchCount: Int
    public let retainedBatchCount: Int
    public let eventLogRecordCount: Int
    public let replayedRecordCount: Int
    public let latestEventLogSequence: Int?
    public let latestProjectionSequence: Int?
    public let eventLogConsistencyHeld: Bool
    public let projectionSnapshotConsistencyHeld: Bool
    public let deterministicProjectionSummary: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let exposesSQLStatement: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let supportsQueryLanguage: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: MarketDataReplayOperationsEvidenceReadModel) {
        let items = readModel.items
        let source = readModel.source
        let exposesDatabaseSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || items.contains { $0.exposesSQLiteSchema || $0.exposesDuckDBSchema }
        let exposesRuntimeObject = source.exposesRuntimeObjects
            || items.contains(where: \.exposesRuntimeObject)
        let exposesAdapterRequest = source.callsBinanceAdapter
            || items.contains(where: \.exposesAdapterRequest)
        let exposesSQLStatement = items.contains(where: \.exposesSQLStatement)
        let authorizesLiveTrading = items.contains(where: \.authorizesLiveTrading)
        let touchesBrokerAction = items.contains(where: \.touchesBrokerAction)
        let authorizesTradingExecution = source.providesLiveOrderAction
            || items.contains(where: \.authorizesTradingExecution)
        let authorizesProductionRuntimeOperations = items.contains {
            $0.authorizesProductionRuntimeOperations
        }
        let providesCommandSurface = false
        let providesOrderLevelCommand = false
        let supportsQueryLanguage = false

        self.source = source
        self.items = items
        self.evidenceCount = items.count
        self.batchIDs = items.map(\.batchID).uniqueSortedStrings()
        self.replayRunIDs = items.map(\.replayRunID).uniqueSortedStrings()
        self.freshnessStatuses = items.map(\.freshnessStatus).uniqueSortedStrings()
        self.retentionStatuses = items.map(\.retentionStatus).uniqueRetentionStatuses()
        self.projectionConsistencySummaries = items.map(\.projectionConsistencySummary)
        self.consistentProjectionCount = items.filter(\.projectionSnapshotConsistencyHeld).count
        self.freshBatchCount = items.filter { $0.freshnessStatus == "fresh" }.count
        self.retainedBatchCount = items.filter { $0.retentionStatus == .retained }.count
        self.eventLogRecordCount = items.reduce(0) { $0 + $1.eventLogRecordCount }
        self.replayedRecordCount = items.reduce(0) { $0 + $1.replayedRecordCount }
        self.latestEventLogSequence = items.compactMap(\.eventLogLastSequence).max()
        self.latestProjectionSequence = items.compactMap(\.projectionLastAppliedSequence).max()
        self.eventLogConsistencyHeld = items.isEmpty || items.allSatisfy(\.eventLogConsistencyHeld)
        self.projectionSnapshotConsistencyHeld = items.isEmpty
            || items.allSatisfy(\.projectionSnapshotConsistencyHeld)
        self.deterministicProjectionSummary = items.isEmpty
            || items.allSatisfy(\.deterministicProjectionSummary)
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesSQLStatement = exposesSQLStatement
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.supportsQueryLanguage = supportsQueryLanguage
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = authorizesProductionRuntimeOperations
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && exposesSQLStatement == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && supportsQueryLanguage == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && authorizesProductionRuntimeOperations == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}

private extension Array where Element == MarketDataReplayOperationsRetentionStatus {
    func uniqueRetentionStatuses() -> [MarketDataReplayOperationsRetentionStatus] {
        var seen = Set<MarketDataReplayOperationsRetentionStatus>()
        var values: [MarketDataReplayOperationsRetentionStatus] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}
