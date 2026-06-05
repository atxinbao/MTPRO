import Foundation
import DomainModel

/// BinanceMarketDataReplayOperationsMetadataError 描述本地 replay metadata 的构造失败原因。
/// 错误只覆盖本地合同完整性，不表达 Binance account、signed endpoint、broker 或真实订单状态。
public enum BinanceMarketDataReplayOperationsMetadataError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidRecordCount(Int)
    case emptyChecksumParityHint
    case incompleteBoundaryContract

    public var description: String {
        switch self {
        case let .invalidRecordCount(recordCount):
            "Binance replay metadata record count is invalid: \(recordCount)"
        case .emptyChecksumParityHint:
            "Binance replay metadata checksum / parity hint must not be empty"
        case .incompleteBoundaryContract:
            "Binance replay metadata boundary does not cover the minimum batch / replay contract fields"
        }
    }
}

/// BinanceMarketDataReplayOperationsMetadata 是 MTP-55 的本地 replay operations metadata value model。
///
/// 它只描述离线 fixture / batch replay evidence：batch、replay run、symbol、interval、
/// time window、fixture source、record count 和 checksum / parity hint。该类型不读取真实网络，
/// 不保存 API key，不代表 production runtime operations，也不授权 broker action、Live trading
/// 或真实订单提交 / 撤销 / 替换。
public struct BinanceMarketDataReplayOperationsMetadata: Codable, Equatable, Sendable {
    public let batchID: Identifier
    public let replayRunID: Identifier
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let timeWindow: DateRange
    public let fixtureSource: Identifier
    public let recordCount: Int
    public let checksumParityHint: String

    public init(
        batchID: Identifier,
        replayRunID: Identifier,
        symbol: Symbol,
        timeframe: Timeframe,
        timeWindow: DateRange,
        fixtureSource: Identifier,
        recordCount: Int,
        checksumParityHint: String
    ) throws {
        guard recordCount >= 0 else {
            throw BinanceMarketDataReplayOperationsMetadataError.invalidRecordCount(recordCount)
        }

        let normalizedChecksumParityHint = checksumParityHint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedChecksumParityHint.isEmpty == false else {
            throw BinanceMarketDataReplayOperationsMetadataError.emptyChecksumParityHint
        }

        self.batchID = batchID
        self.replayRunID = replayRunID
        self.symbol = symbol
        self.timeframe = timeframe
        self.timeWindow = timeWindow
        self.fixtureSource = fixtureSource
        self.recordCount = recordCount
        self.checksumParityHint = normalizedChecksumParityHint
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let batchID = try container.decode(Identifier.self, forKey: .batchID)
        let replayRunID = try container.decode(Identifier.self, forKey: .replayRunID)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let timeWindow = try container.decode(DateRange.self, forKey: .timeWindow)
        let fixtureSource = try container.decode(Identifier.self, forKey: .fixtureSource)
        let recordCount = try container.decode(Int.self, forKey: .recordCount)
        let checksumParityHint = try container.decode(String.self, forKey: .checksumParityHint)
        try self.init(
            batchID: batchID,
            replayRunID: replayRunID,
            symbol: symbol,
            timeframe: timeframe,
            timeWindow: timeWindow,
            fixtureSource: fixtureSource,
            recordCount: recordCount,
            checksumParityHint: checksumParityHint
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(batchID, forKey: .batchID)
        try container.encode(replayRunID, forKey: .replayRunID)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(timeframe, forKey: .timeframe)
        try container.encode(timeWindow, forKey: .timeWindow)
        try container.encode(fixtureSource, forKey: .fixtureSource)
        try container.encode(recordCount, forKey: .recordCount)
        try container.encode(checksumParityHint, forKey: .checksumParityHint)
    }

    /// contractFields 固定 MTP-55 metadata 必须覆盖的字段集合。
    /// 后续 retention、freshness、parity 和 projection issue 只能消费这些本地 evidence 字段，
    /// 不能把字段集合扩展成 signed endpoint、account、listenKey、broker 或 order surface。
    public var contractFields: [BinanceMarketDataBatchReplayContractField] {
        BinanceMarketDataBatchReplayContractField.allCases
    }

    /// timeWindowDescription 为 deterministic tests 和 PR evidence 提供稳定时间窗口摘要。
    public var timeWindowDescription: String {
        "\(Int(timeWindow.start.timeIntervalSince1970))...\(Int(timeWindow.end.timeIntervalSince1970))"
    }

    /// 返回指定 contract field 的本地 evidence value。
    /// 该方法只读 metadata，不触发网络、runtime 调度、event log 写入或 projection side effect。
    public func value(for field: BinanceMarketDataBatchReplayContractField) -> String {
        switch field {
        case .batchID:
            batchID.rawValue
        case .replayRunID:
            replayRunID.rawValue
        case .symbol:
            symbol.rawValue
        case .timeframe:
            timeframe.rawValue
        case .timeWindow:
            timeWindowDescription
        case .fixtureSource:
            fixtureSource.rawValue
        case .recordCount:
            String(recordCount)
        case .checksumParityHint:
            checksumParityHint
        }
    }

    /// deterministicFieldValues 使用 contract field 顺序生成稳定 evidence surface。
    /// 测试用它验证 metadata 字段完整性，并验证禁止能力没有混入本地 replay contract。
    public var deterministicFieldValues: [String] {
        contractFields.map { field in
            "\(field.rawValue)=\(value(for: field))"
        }
    }

    /// 检查 metadata 的字段名和值是否包含禁区 capability 文本。
    /// 返回 true 表示本地 metadata 被污染，应由 tests 或 validation 阻断。
    public func containsForbiddenCapabilityText(
        _ forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability]
    ) -> Bool {
        let serialized = deterministicFieldValues
            .joined(separator: " ")
            .lowercased()

        return forbiddenCapabilities.contains { capability in
            serialized.contains(capability.rawValue.lowercased())
        }
    }

    private enum CodingKeys: String, CodingKey {
        case batchID
        case replayRunID
        case symbol
        case timeframe
        case timeWindow
        case fixtureSource
        case recordCount
        case checksumParityHint
    }
}

/// BinanceMarketDataBatchReplayContract 将 MTP-55 metadata 绑定到 MTP-54 public read-only boundary。
///
/// Contract 只证明本地 fixture / batch replay 所需字段、required validation mode 和 forbidden
/// capability 一致；它不实现真实历史下载器、不创建 production scheduler、不启动 runtime operations，
/// 也不连接 signed/account/listenKey endpoint、broker 或真实订单通道。
public struct BinanceMarketDataBatchReplayContract: Codable, Equatable, Sendable {
    public let metadata: BinanceMarketDataReplayOperationsMetadata
    public let boundary: BinanceMarketDataBatchReplayBoundary
    public let requiredFields: [BinanceMarketDataBatchReplayContractField]
    public let requiredValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let optionalValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability]
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool

    public init(
        metadata: BinanceMarketDataReplayOperationsMetadata,
        boundary: BinanceMarketDataBatchReplayBoundary = BinanceMarketDataBatchReplayBoundary()
    ) throws {
        let requiredFields = BinanceMarketDataBatchReplayContractField.allCases
        guard boundary.coversMinimumContractFields,
              Set(boundary.metadataFields).isSuperset(of: requiredFields) else {
            throw BinanceMarketDataReplayOperationsMetadataError.incompleteBoundaryContract
        }

        self.metadata = metadata
        self.boundary = boundary
        self.requiredFields = requiredFields
        self.requiredValidationModes = boundary.requiredValidationModes
        self.optionalValidationModes = boundary.optionalValidationModes
        self.forbiddenCapabilities = boundary.forbiddenCapabilities
        self.isPublicReadOnly = boundary.isPublicReadOnly
        self.isLocalFixtureReplayOnly = boundary.isLocalFixtureReplayOnly
        self.requiredValidationDependsOnNetwork = boundary.requiredValidationDependsOnNetwork
        self.authorizesTradingExecution = boundary.authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = boundary.authorizesProductionRuntimeOperations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metadata = try container.decode(
            BinanceMarketDataReplayOperationsMetadata.self,
            forKey: .metadata
        )
        let boundary = try container.decode(
            BinanceMarketDataBatchReplayBoundary.self,
            forKey: .boundary
        )
        try self.init(metadata: metadata, boundary: boundary)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(boundary, forKey: .boundary)
        try container.encode(requiredFields, forKey: .requiredFields)
        try container.encode(requiredValidationModes, forKey: .requiredValidationModes)
        try container.encode(optionalValidationModes, forKey: .optionalValidationModes)
        try container.encode(forbiddenCapabilities, forKey: .forbiddenCapabilities)
        try container.encode(isPublicReadOnly, forKey: .isPublicReadOnly)
        try container.encode(isLocalFixtureReplayOnly, forKey: .isLocalFixtureReplayOnly)
        try container.encode(requiredValidationDependsOnNetwork, forKey: .requiredValidationDependsOnNetwork)
        try container.encode(authorizesTradingExecution, forKey: .authorizesTradingExecution)
        try container.encode(authorizesProductionRuntimeOperations, forKey: .authorizesProductionRuntimeOperations)
    }

    /// coversRequiredFields 证明 metadata、contract 和 boundary 都覆盖 MTP-55 最小字段集合。
    public var coversRequiredFields: Bool {
        Set(metadata.contractFields).isSuperset(of: requiredFields)
            && Set(boundary.metadataFields).isSuperset(of: requiredFields)
            && boundary.coversMinimumContractFields
    }

    /// requiredValidationIsLocalOnly 证明自动验证只依赖 mock / fixture / local replay。
    /// optional manual network smoke 只能留在 optionalValidationModes，不能进入 required validation。
    public var requiredValidationIsLocalOnly: Bool {
        requiredValidationModes == [.mockTransport, .fixtureParity, .localBatchReplay]
            && requiredValidationDependsOnNetwork == false
    }

    /// metadataContainsForbiddenCapabilityText 用于 validation 证明本地 metadata 没有混入禁区字段。
    public var metadataContainsForbiddenCapabilityText: Bool {
        metadata.containsForbiddenCapabilityText(forbiddenCapabilities)
    }

    /// 判断禁区 capability 是否仍由底层 boundary 明确拒绝。
    public func forbidsCapability(_ rawValue: String) -> Bool {
        boundary.forbidsCapability(rawValue)
    }

    private enum CodingKeys: String, CodingKey {
        case metadata
        case boundary
        case requiredFields
        case requiredValidationModes
        case optionalValidationModes
        case forbiddenCapabilities
        case isPublicReadOnly
        case isLocalFixtureReplayOnly
        case requiredValidationDependsOnNetwork
        case authorizesTradingExecution
        case authorizesProductionRuntimeOperations
    }
}

/// BinanceMarketDataReplayOperationsFixture 生成 MTP-55 deterministic metadata / contract evidence。
///
/// Fixture 固定 BTCUSDT、1m、单条本地 kline fixture 和 checksum / parity hint，只用于 XCTest、
/// docs 和 PR evidence；它不代表真实下载规模、生产调度计划或任何可交易授权。
public enum BinanceMarketDataReplayOperationsFixture {
    public static func deterministicMetadata() throws -> BinanceMarketDataReplayOperationsMetadata {
        try BinanceMarketDataReplayOperationsMetadata(
            batchID: Identifier("batch-BTCUSDT-1m-20240101"),
            replayRunID: Identifier("replay-run-BTCUSDT-1m-20240101T000000Z"),
            symbol: Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            timeWindow: DateRange(
                start: Date(timeIntervalSince1970: 1_704_067_200),
                end: Date(timeIntervalSince1970: 1_704_067_260)
            ),
            fixtureSource: Identifier("fixtures/binance/btcusdt-1m-20240101.json"),
            recordCount: 1,
            checksumParityHint: BinanceMarketDataBatchReplayDeterministicParity.checksumParityHint(
                for: deterministicReplayRecords()
            )
        )
    }

    public static func deterministicContract(
        boundary: BinanceMarketDataBatchReplayBoundary = BinanceMarketDataBatchReplayBoundary()
    ) throws -> BinanceMarketDataBatchReplayContract {
        try BinanceMarketDataBatchReplayContract(
            metadata: deterministicMetadata(),
            boundary: boundary
        )
    }
}
