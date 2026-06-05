import Foundation
import DomainModel

/// BinanceMarketDataReplayFreshnessStatus 描述本地 replay batch 相对 retention policy 的 freshness。
///
/// 状态只来自本地 metadata time window、policy window 和评估时间，不读取 SQLite / DuckDB schema，
/// 不触发 adapter request、Runtime 调度、生产清理任务、云端 archive 或 storage tiering。
public enum BinanceMarketDataReplayFreshnessStatus: String, Codable, Equatable, Hashable, Sendable {
    case fresh
    case stale
    case expired
    case notRetained = "not retained"
}

/// BinanceMarketDataReplayRetentionPolicyError 描述 retention / freshness 合同的本地构造错误。
/// 错误只覆盖 policy window 和本地 replay contract 完整性，不表达真实数据清理、broker 或账户状态。
public enum BinanceMarketDataReplayRetentionPolicyError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidWindow(field: String, value: Int)
    case invalidWindowOrder(staleAfterSeconds: Int, expiresAfterSeconds: Int)
    case invalidRetentionWindow(retentionWindowSeconds: Int, expiresAfterSeconds: Int)
    case nonLocalReplayContract

    public var description: String {
        switch self {
        case let .invalidWindow(field, value):
            "Binance replay retention policy window is invalid for \(field): \(value)"
        case let .invalidWindowOrder(staleAfterSeconds, expiresAfterSeconds):
            "Binance replay retention policy stale window \(staleAfterSeconds) must be earlier than expires window \(expiresAfterSeconds)"
        case let .invalidRetentionWindow(retentionWindowSeconds, expiresAfterSeconds):
            "Binance replay retention policy retention window \(retentionWindowSeconds) must cover expires window \(expiresAfterSeconds)"
        case .nonLocalReplayContract:
            "Binance replay freshness evidence requires a public read-only local replay contract"
        }
    }
}

/// BinanceMarketDataReplayRetentionPolicy 是 MTP-56 的最小本地 retention policy。
///
/// Policy 只回答本地 batch evidence 在某个评估时间是否仍保留、是否 stale、是否 expired；
/// 它不是 retention engine，不执行删除，不实现云端 archive，也不表达 production runtime operations。
public struct BinanceMarketDataReplayRetentionPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let retainBatchLocally: Bool
    public let staleAfterSeconds: Int
    public let expiresAfterSeconds: Int
    public let retentionWindowSeconds: Int
    public let allowsCloudArchive: Bool
    public let exposesStorageTiering: Bool
    public let authorizesProductionDeletionJob: Bool

    public init(
        policyID: Identifier,
        retainBatchLocally: Bool = true,
        staleAfterSeconds: Int,
        expiresAfterSeconds: Int,
        retentionWindowSeconds: Int,
        allowsCloudArchive: Bool = false,
        exposesStorageTiering: Bool = false,
        authorizesProductionDeletionJob: Bool = false
    ) throws {
        guard staleAfterSeconds >= 0 else {
            throw BinanceMarketDataReplayRetentionPolicyError.invalidWindow(
                field: "staleAfterSeconds",
                value: staleAfterSeconds
            )
        }
        guard expiresAfterSeconds >= 0 else {
            throw BinanceMarketDataReplayRetentionPolicyError.invalidWindow(
                field: "expiresAfterSeconds",
                value: expiresAfterSeconds
            )
        }
        guard retentionWindowSeconds >= 0 else {
            throw BinanceMarketDataReplayRetentionPolicyError.invalidWindow(
                field: "retentionWindowSeconds",
                value: retentionWindowSeconds
            )
        }
        guard staleAfterSeconds < expiresAfterSeconds else {
            throw BinanceMarketDataReplayRetentionPolicyError.invalidWindowOrder(
                staleAfterSeconds: staleAfterSeconds,
                expiresAfterSeconds: expiresAfterSeconds
            )
        }
        guard retentionWindowSeconds >= expiresAfterSeconds else {
            throw BinanceMarketDataReplayRetentionPolicyError.invalidRetentionWindow(
                retentionWindowSeconds: retentionWindowSeconds,
                expiresAfterSeconds: expiresAfterSeconds
            )
        }

        self.policyID = policyID
        self.retainBatchLocally = retainBatchLocally
        self.staleAfterSeconds = staleAfterSeconds
        self.expiresAfterSeconds = expiresAfterSeconds
        self.retentionWindowSeconds = retentionWindowSeconds
        self.allowsCloudArchive = allowsCloudArchive
        self.exposesStorageTiering = exposesStorageTiering
        self.authorizesProductionDeletionJob = authorizesProductionDeletionJob
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let policyID = try container.decode(Identifier.self, forKey: .policyID)
        let retainBatchLocally = try container.decode(Bool.self, forKey: .retainBatchLocally)
        let staleAfterSeconds = try container.decode(Int.self, forKey: .staleAfterSeconds)
        let expiresAfterSeconds = try container.decode(Int.self, forKey: .expiresAfterSeconds)
        let retentionWindowSeconds = try container.decode(Int.self, forKey: .retentionWindowSeconds)
        let allowsCloudArchive = try container.decode(Bool.self, forKey: .allowsCloudArchive)
        let exposesStorageTiering = try container.decode(Bool.self, forKey: .exposesStorageTiering)
        let authorizesProductionDeletionJob = try container.decode(
            Bool.self,
            forKey: .authorizesProductionDeletionJob
        )
        try self.init(
            policyID: policyID,
            retainBatchLocally: retainBatchLocally,
            staleAfterSeconds: staleAfterSeconds,
            expiresAfterSeconds: expiresAfterSeconds,
            retentionWindowSeconds: retentionWindowSeconds,
            allowsCloudArchive: allowsCloudArchive,
            exposesStorageTiering: exposesStorageTiering,
            authorizesProductionDeletionJob: authorizesProductionDeletionJob
        )
    }

    /// 根据 metadata 的 time window end 和 evaluatedAt 计算非负 batch age。
    public func batchAgeSeconds(
        for metadata: BinanceMarketDataReplayOperationsMetadata,
        evaluatedAt: Date
    ) -> Int {
        max(0, Int(evaluatedAt.timeIntervalSince(metadata.timeWindow.end)))
    }

    /// 判断本地 batch freshness；该判断只读 metadata，不执行 retention side effect。
    public func status(
        for metadata: BinanceMarketDataReplayOperationsMetadata,
        evaluatedAt: Date
    ) -> BinanceMarketDataReplayFreshnessStatus {
        guard retainBatchLocally else {
            return .notRetained
        }

        let age = batchAgeSeconds(for: metadata, evaluatedAt: evaluatedAt)
        if age >= expiresAfterSeconds {
            return .expired
        }
        if age >= staleAfterSeconds {
            return .stale
        }
        return .fresh
    }

    private enum CodingKeys: String, CodingKey {
        case policyID
        case retainBatchLocally
        case staleAfterSeconds
        case expiresAfterSeconds
        case retentionWindowSeconds
        case allowsCloudArchive
        case exposesStorageTiering
        case authorizesProductionDeletionJob
    }
}

/// BinanceMarketDataReplayFreshnessSourceContract 固定 freshness evidence 的来源边界。
///
/// 默认来源是稳定 read model evidence，不暴露 SQLite / DuckDB 表结构、ORM、Runtime object、
/// adapter request 或真实交易动作；后续 Report / Dashboard / Event Timeline 只能消费这些字段。
public struct BinanceMarketDataReplayFreshnessSourceContract: Codable, Equatable, Sendable {
    public let sourceKind: String
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesORMModels: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterRequest: Bool
    public let exposesStorageTiering: Bool
    public let exposesCloudArchive: Bool
    public let authorizesProductionDeletionJob: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        sourceKind: String = "stable replay freshness evidence read model",
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        exposesORMModels: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesAdapterRequest: Bool = false,
        exposesStorageTiering: Bool = false,
        exposesCloudArchive: Bool = false,
        authorizesProductionDeletionJob: Bool = false,
        authorizesLiveTrading: Bool = false,
        touchesBrokerAction: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.sourceKind = sourceKind
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.exposesORMModels = exposesORMModels
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesStorageTiering = exposesStorageTiering
        self.exposesCloudArchive = exposesCloudArchive
        self.authorizesProductionDeletionJob = authorizesProductionDeletionJob
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var isReadModelOnly: Bool {
        sourceKind == "stable replay freshness evidence read model"
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && exposesORMModels == false
            && exposesRuntimeObject == false
            && exposesAdapterRequest == false
            && exposesStorageTiering == false
            && exposesCloudArchive == false
            && authorizesProductionDeletionJob == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
    }
}

/// BinanceMarketDataReplayFreshnessEvidenceReadModel 是 MTP-56 的稳定 freshness evidence read model。
///
/// 该 read model 复制必要的 batch / replay evidence 字段、retention policy 摘要和 freshness status，
/// 供后续 Report / Dashboard / Event Timeline 消费。它不暴露底层 persistence schema，不传出
/// adapter request 或 runtime object，也不授权 Live trading、broker action 或真实订单行为。
public struct BinanceMarketDataReplayFreshnessEvidenceReadModel: Codable, Equatable, Sendable {
    public let source: BinanceMarketDataReplayFreshnessSourceContract
    public let batchID: String
    public let replayRunID: String
    public let symbol: String
    public let timeframe: String
    public let timeWindowDescription: String
    public let fixtureSource: String
    public let recordCount: Int
    public let checksumParityHint: String
    public let policyID: String
    public let retainBatchLocally: Bool
    public let staleAfterSeconds: Int
    public let expiresAfterSeconds: Int
    public let retentionWindowSeconds: Int
    public let evaluatedAt: Date
    public let batchWindowEnd: Date
    public let batchAgeSeconds: Int
    public let status: BinanceMarketDataReplayFreshnessStatus
    public let isRetainedLocally: Bool
    public let isStale: Bool
    public let isExpired: Bool
    public let freshnessSummary: String
    public let retentionEvidence: [String]
    public let requiredValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let optionalValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let requiredValidationIsLocalOnly: Bool
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        contract: BinanceMarketDataBatchReplayContract,
        policy: BinanceMarketDataReplayRetentionPolicy,
        evaluatedAt: Date,
        source: BinanceMarketDataReplayFreshnessSourceContract = BinanceMarketDataReplayFreshnessSourceContract()
    ) throws {
        guard contract.isPublicReadOnly,
              contract.isLocalFixtureReplayOnly,
              contract.requiredValidationIsLocalOnly,
              contract.authorizesTradingExecution == false,
              contract.authorizesProductionRuntimeOperations == false else {
            throw BinanceMarketDataReplayRetentionPolicyError.nonLocalReplayContract
        }

        let metadata = contract.metadata
        let status = policy.status(for: metadata, evaluatedAt: evaluatedAt)
        let batchAgeSeconds = policy.batchAgeSeconds(for: metadata, evaluatedAt: evaluatedAt)
        let isExpired = status == .expired
        let isRetainedLocally = policy.retainBatchLocally && status != .notRetained && isExpired == false
        let retentionEvidence = [
            "policy=\(policy.policyID.rawValue)",
            "batch=\(metadata.batchID.rawValue)",
            "status=\(status.rawValue)",
            "ageSeconds=\(batchAgeSeconds)",
            "retained=\(isRetainedLocally)",
            "stale=\(status == .stale)",
            "expired=\(isExpired)",
            "readModelOnly=\(source.isReadModelOnly)"
        ]
        let freshnessSummary = [
            metadata.batchID.rawValue,
            status.rawValue,
            "age=\(batchAgeSeconds)s",
            "retained=\(isRetainedLocally)"
        ].joined(separator: "; ")

        self.source = source
        self.batchID = metadata.batchID.rawValue
        self.replayRunID = metadata.replayRunID.rawValue
        self.symbol = metadata.symbol.rawValue
        self.timeframe = metadata.timeframe.rawValue
        self.timeWindowDescription = metadata.timeWindowDescription
        self.fixtureSource = metadata.fixtureSource.rawValue
        self.recordCount = metadata.recordCount
        self.checksumParityHint = metadata.checksumParityHint
        self.policyID = policy.policyID.rawValue
        self.retainBatchLocally = policy.retainBatchLocally
        self.staleAfterSeconds = policy.staleAfterSeconds
        self.expiresAfterSeconds = policy.expiresAfterSeconds
        self.retentionWindowSeconds = policy.retentionWindowSeconds
        self.evaluatedAt = evaluatedAt
        self.batchWindowEnd = metadata.timeWindow.end
        self.batchAgeSeconds = batchAgeSeconds
        self.status = status
        self.isRetainedLocally = isRetainedLocally
        self.isStale = status == .stale
        self.isExpired = isExpired
        self.freshnessSummary = freshnessSummary
        self.retentionEvidence = retentionEvidence
        self.requiredValidationModes = contract.requiredValidationModes
        self.optionalValidationModes = contract.optionalValidationModes
        self.requiredValidationIsLocalOnly = contract.requiredValidationIsLocalOnly
        self.isPublicReadOnly = contract.isPublicReadOnly
        self.isLocalFixtureReplayOnly = contract.isLocalFixtureReplayOnly
        self.exposesSQLiteSchema = source.exposesSQLiteSchema
        self.exposesDuckDBSchema = source.exposesDuckDBSchema
        self.exposesAdapterRequest = source.exposesAdapterRequest
        self.exposesRuntimeObject = source.exposesRuntimeObject
        self.authorizesLiveTrading = source.authorizesLiveTrading
        self.touchesBrokerAction = source.touchesBrokerAction
        self.authorizesTradingExecution = source.authorizesTradingExecution
        self.readModelOnlyBoundaryHeld = source.isReadModelOnly
            && contract.isPublicReadOnly
            && contract.isLocalFixtureReplayOnly
            && contract.requiredValidationIsLocalOnly
            && contract.metadataContainsForbiddenCapabilityText == false
            && policy.allowsCloudArchive == false
            && policy.exposesStorageTiering == false
            && policy.authorizesProductionDeletionJob == false
            && contract.authorizesTradingExecution == false
            && contract.authorizesProductionRuntimeOperations == false
    }

    /// 检查 freshness read model 是否混入 signed/account/listenKey/broker/order 等禁区文本。
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
                fixtureSource,
                checksumParityHint,
                policyID,
                freshnessSummary
            ] + retentionEvidence
        )
        .joined(separator: " ")
        .lowercased()

        return forbiddenCapabilities.contains { capability in
            serialized.contains(capability.rawValue.lowercased())
        }
    }
}

/// BinanceMarketDataReplayBatchFreshnessSummary 汇总一组 replay batch 的 retention / freshness evidence。
///
/// Summary 只聚合已生成的 freshness read model，供后续 Report / Dashboard / Event Timeline 做只读展示；
/// 它不访问 database schema，不触发 batch replay，不执行 retention cleanup，也不连接 broker / signed endpoint。
public struct BinanceMarketDataReplayBatchFreshnessSummary: Codable, Equatable, Sendable {
    public let source: BinanceMarketDataReplayFreshnessSourceContract
    public let evidence: [BinanceMarketDataReplayFreshnessEvidenceReadModel]
    public let totalBatchCount: Int
    public let freshBatchIDs: [String]
    public let staleBatchIDs: [String]
    public let expiredBatchIDs: [String]
    public let notRetainedBatchIDs: [String]
    public let retainedBatchIDs: [String]
    public let summaryLine: String
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool

    public init(
        evidence: [BinanceMarketDataReplayFreshnessEvidenceReadModel],
        source: BinanceMarketDataReplayFreshnessSourceContract = BinanceMarketDataReplayFreshnessSourceContract()
    ) {
        let sortedEvidence = evidence.sorted { lhs, rhs in
            if lhs.batchID != rhs.batchID {
                return lhs.batchID < rhs.batchID
            }
            return lhs.replayRunID < rhs.replayRunID
        }

        let totalBatchCount = sortedEvidence.count
        let freshBatchIDs = Self.batchIDs(in: sortedEvidence, status: .fresh)
        let staleBatchIDs = Self.batchIDs(in: sortedEvidence, status: .stale)
        let expiredBatchIDs = Self.batchIDs(in: sortedEvidence, status: .expired)
        let notRetainedBatchIDs = Self.batchIDs(in: sortedEvidence, status: .notRetained)
        let retainedBatchIDs = sortedEvidence.filter(\.isRetainedLocally).map(\.batchID)
        let exposesSQLiteSchema = source.exposesSQLiteSchema
            || sortedEvidence.contains(where: \.exposesSQLiteSchema)
        let exposesDuckDBSchema = source.exposesDuckDBSchema
            || sortedEvidence.contains(where: \.exposesDuckDBSchema)
        let exposesAdapterRequest = source.exposesAdapterRequest
            || sortedEvidence.contains(where: \.exposesAdapterRequest)
        let exposesRuntimeObject = source.exposesRuntimeObject
            || sortedEvidence.contains(where: \.exposesRuntimeObject)
        let authorizesLiveTrading = source.authorizesLiveTrading
            || sortedEvidence.contains(where: \.authorizesLiveTrading)
        let touchesBrokerAction = source.touchesBrokerAction
            || sortedEvidence.contains(where: \.touchesBrokerAction)
        let authorizesTradingExecution = source.authorizesTradingExecution
            || sortedEvidence.contains(where: \.authorizesTradingExecution)
        let readModelOnlyBoundaryHeld = source.isReadModelOnly
            && sortedEvidence.allSatisfy(\.readModelOnlyBoundaryHeld)
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && exposesAdapterRequest == false
            && exposesRuntimeObject == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false

        self.source = source
        self.evidence = sortedEvidence
        self.totalBatchCount = totalBatchCount
        self.freshBatchIDs = freshBatchIDs
        self.staleBatchIDs = staleBatchIDs
        self.expiredBatchIDs = expiredBatchIDs
        self.notRetainedBatchIDs = notRetainedBatchIDs
        self.retainedBatchIDs = retainedBatchIDs
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesRuntimeObject = exposesRuntimeObject
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
        self.summaryLine = "batches=\(totalBatchCount); fresh=\(freshBatchIDs.count); stale=\(staleBatchIDs.count); expired=\(expiredBatchIDs.count); notRetained=\(notRetainedBatchIDs.count); retained=\(retainedBatchIDs.count); readModelOnly=\(readModelOnlyBoundaryHeld)"
    }

    private static func batchIDs(
        in evidence: [BinanceMarketDataReplayFreshnessEvidenceReadModel],
        status: BinanceMarketDataReplayFreshnessStatus
    ) -> [String] {
        evidence.filter { $0.status == status }.map(\.batchID)
    }
}

public extension BinanceMarketDataReplayOperationsFixture {
    /// deterministicRetentionPolicy 提供本地 batch replay retention 的稳定测试合同。
    ///
    /// 5 分钟后标记 stale、1 小时后 expired、2 小时内为本地 retention window；该 policy
    /// 不执行清理、不启用 cloud archive / storage tiering，也不代表 production retention service。
    static func deterministicRetentionPolicy() throws -> BinanceMarketDataReplayRetentionPolicy {
        try BinanceMarketDataReplayRetentionPolicy(
            policyID: Identifier("local-replay-retention-policy-v1"),
            staleAfterSeconds: 300,
            expiresAfterSeconds: 3_600,
            retentionWindowSeconds: 7_200
        )
    }

    static func deterministicFreshnessEvidence(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_704_067_380)
    ) throws -> BinanceMarketDataReplayFreshnessEvidenceReadModel {
        try BinanceMarketDataReplayFreshnessEvidenceReadModel(
            contract: deterministicContract(),
            policy: deterministicRetentionPolicy(),
            evaluatedAt: evaluatedAt
        )
    }

    static func deterministicBatchFreshnessSummary(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_704_067_380)
    ) throws -> BinanceMarketDataReplayBatchFreshnessSummary {
        try BinanceMarketDataReplayBatchFreshnessSummary(
            evidence: [
                deterministicFreshnessEvidence(evaluatedAt: evaluatedAt)
            ]
        )
    }
}
