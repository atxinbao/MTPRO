import Foundation

/// Binance 行情 batch / replay boundary 只定义本地批次回放的合同外壳。
///
/// MTP-54 的职责是固定更长周期 market data replay operations 的第一层边界：
/// public read-only、fixture / batch replay、本地 metadata、required validation 离线可重复。
/// 本文件不实现真实历史下载器、不调度生产 runtime、不接 signed/account/listenKey endpoint，
/// 也不授权 broker action、Live trading 或真实订单提交 / 撤销 / 替换。

/// 批次回放 contract 的最小字段集合。
/// 这些字段只描述本地 replay operations evidence；MTP-55 metadata value model 必须完整覆盖该字段集合。
public enum BinanceMarketDataBatchReplayContractField: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case batchID = "batch id"
    case replayRunID = "replay run id"
    case symbol = "symbol"
    case timeframe = "interval"
    case timeWindow = "time window"
    case fixtureSource = "fixture source"
    case recordCount = "record count"
    case checksumParityHint = "checksum / parity hint"
}

/// 批次回放 validation mode 区分 required 自动验证和 optional 人工证据。
/// required mode 必须使用 mock transport / fixture parity，不能依赖真实 Binance 网络。
public enum BinanceMarketDataBatchReplayValidationMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case mockTransport = "mock transport"
    case fixtureParity = "fixture parity"
    case localBatchReplay = "local batch replay"
    case optionalManualNetworkSmoke = "optional manual Binance public network smoke"
}

/// 批次回放 boundary 明确禁止的能力。
/// 禁区覆盖交易、账户、signed endpoint、listenKey、broker 和生产级数据平台扩展，避免本地 replay 边界被误用为运行时运营能力。
public enum BinanceMarketDataBatchReplayForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case liveTrading = "Live trading"
    case brokerAction = "broker action"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case productionRuntimeOperations = "production runtime operations"
    case largeScaleHistoricalDownloader = "large-scale historical downloader"
    case dataPlatform = "data platform"
}

/// BinanceMarketDataBatchReplayBoundary 是 MTP-54 的稳定 contract fixture。
///
/// 输入字段限定 replay batch 的 symbol / interval / time window / fixture source；
/// 输出字段限定本地 batch id、replay run id、record count 和 checksum / parity hint。
/// 该 boundary 只允许复用现有 Binance public market data capability，且 required validation
/// 必须在本地 mock / fixture 下完成。所有 trading、account、signed、broker 和 production operations
/// 能力都显式保持为 forbidden capability。
public struct BinanceMarketDataBatchReplayBoundary: Codable, Equatable, Sendable {
    public let boundaryName: String
    public let sourceName: String
    public let inputFields: [BinanceMarketDataBatchReplayContractField]
    public let outputFields: [BinanceMarketDataBatchReplayContractField]
    public let metadataFields: [BinanceMarketDataBatchReplayContractField]
    public let allowedMarketDataCapabilities: [BinancePublicMarketDataCapability]
    public let requiredValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let optionalValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability]
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool

    public init(
        boundaryName: String = "Binance public market data batch / replay boundary",
        sourceName: String = "Binance public market data",
        inputFields: [BinanceMarketDataBatchReplayContractField] = [
            .symbol,
            .timeframe,
            .timeWindow,
            .fixtureSource
        ],
        outputFields: [BinanceMarketDataBatchReplayContractField] = [
            .batchID,
            .replayRunID,
            .recordCount,
            .checksumParityHint
        ],
        metadataFields: [BinanceMarketDataBatchReplayContractField] = BinanceMarketDataBatchReplayContractField.allCases,
        allowedMarketDataCapabilities: [BinancePublicMarketDataCapability] = [
            .exchangeInfo,
            .klines,
            .recentTrades,
            .bestBidAsk,
            .depthSnapshot,
            .depthDelta
        ],
        requiredValidationModes: [BinanceMarketDataBatchReplayValidationMode] = [
            .mockTransport,
            .fixtureParity,
            .localBatchReplay
        ],
        optionalValidationModes: [BinanceMarketDataBatchReplayValidationMode] = [
            .optionalManualNetworkSmoke
        ],
        forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability] = BinanceMarketDataBatchReplayForbiddenCapability.allCases,
        isPublicReadOnly: Bool = true,
        isLocalFixtureReplayOnly: Bool = true,
        requiredValidationDependsOnNetwork: Bool = false,
        authorizesTradingExecution: Bool = false,
        authorizesProductionRuntimeOperations: Bool = false
    ) {
        self.boundaryName = boundaryName
        self.sourceName = sourceName
        self.inputFields = inputFields
        self.outputFields = outputFields
        self.metadataFields = metadataFields
        self.allowedMarketDataCapabilities = allowedMarketDataCapabilities
        self.requiredValidationModes = requiredValidationModes
        self.optionalValidationModes = optionalValidationModes
        self.forbiddenCapabilities = forbiddenCapabilities
        self.isPublicReadOnly = isPublicReadOnly
        self.isLocalFixtureReplayOnly = isLocalFixtureReplayOnly
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = authorizesProductionRuntimeOperations
    }

    /// 验证最小 batch / replay contract 字段是否完整覆盖输入、输出和 metadata。
    /// 返回 false 表示后续 issue 在扩展 metadata 前破坏了 MTP-54 的最小合同。
    public var coversMinimumContractFields: Bool {
        let minimumFields = Set(BinanceMarketDataBatchReplayContractField.allCases)
        let coveredFields = Set(inputFields + outputFields + metadataFields)
        return coveredFields.isSuperset(of: minimumFields)
    }

    /// 判断某个 raw capability 是否属于 MTP-54 禁区，供 tests 和后续 validation anchor 复用。
    public func forbidsCapability(_ rawValue: String) -> Bool {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return forbiddenCapabilities.contains { capability in
            capability.rawValue.lowercased() == normalized
        }
    }
}
