import Foundation
import Core

/// BinanceMarketDataBatchReplayParityError 描述本地 batch replay consistency 的失败原因。
/// 错误只覆盖 fixture 输出、metadata 和 deterministic parity hint 的一致性；它不表达真实网络、
/// account、signed endpoint、listenKey、broker 或真实订单状态。
public enum BinanceMarketDataBatchReplayParityError: Error, Equatable, Sendable, CustomStringConvertible {
    case nonLocalReplayContract
    case metadataRecordCountMismatch(expected: Int, actual: Int)
    case metadataSymbolMismatch(expected: String, actual: String)
    case metadataTimeframeMismatch(expected: String, actual: String)
    case metadataTimeWindowMismatch(expected: String, actual: String)
    case outOfOrderRecord(previousStart: Int, currentStart: Int)
    case checksumParityHintMismatch(expected: String, actual: String)

    public var description: String {
        switch self {
        case .nonLocalReplayContract:
            "Binance batch replay parity requires a public read-only local replay contract"
        case let .metadataRecordCountMismatch(expected, actual):
            "Binance batch replay record count mismatch, expected \(expected), actual \(actual)"
        case let .metadataSymbolMismatch(expected, actual):
            "Binance batch replay symbol mismatch, expected \(expected), actual \(actual)"
        case let .metadataTimeframeMismatch(expected, actual):
            "Binance batch replay timeframe mismatch, expected \(expected), actual \(actual)"
        case let .metadataTimeWindowMismatch(expected, actual):
            "Binance batch replay time window mismatch, expected \(expected), actual \(actual)"
        case let .outOfOrderRecord(previousStart, currentStart):
            "Binance batch replay records are out of order, previous \(previousStart), current \(currentStart)"
        case let .checksumParityHintMismatch(expected, actual):
            "Binance batch replay checksum / parity hint mismatch, expected \(expected), actual \(actual)"
        }
    }
}

/// BinanceMarketDataBatchReplayConsistencyEvidence 是 MTP-57 的本地 deterministic replay 证据。
///
/// 输入只允许 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records。
/// 初始化会验证 metadata record count、symbol、interval、time window、record ordering 和
/// checksum / parity hint，且 required validation 必须保持 mock transport / fixture parity /
/// local batch replay。该类型不读取真实 Binance 网络，不写 event log，不触发 projection，
/// 不暴露 adapter request / runtime object，也不授权 Live trading、broker action 或真实订单行为。
public struct BinanceMarketDataBatchReplayConsistencyEvidence: Codable, Equatable, Sendable {
    public let metadata: BinanceMarketDataReplayOperationsMetadata
    public let replayedBars: [MarketBar]
    public let replayOutputSummary: [String]
    public let orderedRecordStarts: [Int]
    public let recordCount: Int
    public let metadataRecordCount: Int
    public let computedChecksumParityHint: String
    public let metadataChecksumParityHint: String
    public let checksumParityHintMatched: Bool
    public let metadataConsistencyHeld: Bool
    public let recordOrderingHeld: Bool
    public let networkIndependent: Bool
    public let requiredValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let optionalValidationModes: [BinanceMarketDataBatchReplayValidationMode]
    public let requiredValidationIsLocalOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let isPublicReadOnly: Bool
    public let isLocalFixtureReplayOnly: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesProductionRuntimeOperations: Bool

    public init(
        contract: BinanceMarketDataBatchReplayContract,
        replayedBars: [MarketBar]
    ) throws {
        guard contract.isPublicReadOnly,
              contract.isLocalFixtureReplayOnly,
              contract.requiredValidationIsLocalOnly,
              contract.requiredValidationDependsOnNetwork == false,
              contract.authorizesTradingExecution == false,
              contract.authorizesProductionRuntimeOperations == false else {
            throw BinanceMarketDataBatchReplayParityError.nonLocalReplayContract
        }

        let metadata = contract.metadata
        guard metadata.recordCount == replayedBars.count else {
            throw BinanceMarketDataBatchReplayParityError.metadataRecordCountMismatch(
                expected: metadata.recordCount,
                actual: replayedBars.count
            )
        }

        let expectedSymbol = metadata.symbol.rawValue
        let expectedTimeframe = metadata.timeframe.rawValue
        for bar in replayedBars {
            guard bar.symbol.rawValue == expectedSymbol else {
                throw BinanceMarketDataBatchReplayParityError.metadataSymbolMismatch(
                    expected: expectedSymbol,
                    actual: bar.symbol.rawValue
                )
            }
            guard bar.timeframe.rawValue == expectedTimeframe else {
                throw BinanceMarketDataBatchReplayParityError.metadataTimeframeMismatch(
                    expected: expectedTimeframe,
                    actual: bar.timeframe.rawValue
                )
            }
        }

        try Self.validateRecordOrdering(replayedBars)

        let actualTimeWindow = Self.timeWindowDescription(for: replayedBars)
        guard actualTimeWindow == metadata.timeWindowDescription else {
            throw BinanceMarketDataBatchReplayParityError.metadataTimeWindowMismatch(
                expected: metadata.timeWindowDescription,
                actual: actualTimeWindow
            )
        }

        let replayOutputSummary = BinanceMarketDataBatchReplayDeterministicParity
            .canonicalReplaySummary(for: replayedBars)
        let computedChecksumParityHint = BinanceMarketDataBatchReplayDeterministicParity
            .checksumParityHint(forCanonicalSummary: replayOutputSummary)
        guard computedChecksumParityHint == metadata.checksumParityHint else {
            throw BinanceMarketDataBatchReplayParityError.checksumParityHintMismatch(
                expected: metadata.checksumParityHint,
                actual: computedChecksumParityHint
            )
        }

        self.metadata = metadata
        self.replayedBars = replayedBars
        self.replayOutputSummary = replayOutputSummary
        self.orderedRecordStarts = replayedBars.map { Int($0.interval.start.timeIntervalSince1970) }
        self.recordCount = replayedBars.count
        self.metadataRecordCount = metadata.recordCount
        self.computedChecksumParityHint = computedChecksumParityHint
        self.metadataChecksumParityHint = metadata.checksumParityHint
        self.checksumParityHintMatched = true
        self.metadataConsistencyHeld = true
        self.recordOrderingHeld = true
        self.requiredValidationModes = contract.requiredValidationModes
        self.optionalValidationModes = contract.optionalValidationModes
        self.requiredValidationIsLocalOnly = contract.requiredValidationIsLocalOnly
        self.requiredValidationDependsOnNetwork = contract.requiredValidationDependsOnNetwork
        self.isPublicReadOnly = contract.isPublicReadOnly
        self.isLocalFixtureReplayOnly = contract.isLocalFixtureReplayOnly
        self.authorizesLiveTrading = false
        self.touchesBrokerAction = false
        self.authorizesTradingExecution = contract.authorizesTradingExecution
        self.authorizesProductionRuntimeOperations = contract.authorizesProductionRuntimeOperations
        self.networkIndependent = contract.requiredValidationIsLocalOnly
            && contract.requiredValidationDependsOnNetwork == false
    }

    /// 检查 consistency evidence 是否混入 signed/account/listenKey/broker/order 等禁区文本。
    public func containsForbiddenCapabilityText(
        _ forbiddenCapabilities: [BinanceMarketDataBatchReplayForbiddenCapability]
    ) -> Bool {
        let serialized = (
            replayOutputSummary + [
                metadata.batchID.rawValue,
                metadata.replayRunID.rawValue,
                metadata.symbol.rawValue,
                metadata.timeframe.rawValue,
                metadata.timeWindowDescription,
                metadata.fixtureSource.rawValue,
                metadata.checksumParityHint,
                computedChecksumParityHint
            ]
        )
        .joined(separator: " ")
        .lowercased()

        return forbiddenCapabilities.contains { capability in
            serialized.contains(capability.rawValue.lowercased())
        }
    }

    private static func validateRecordOrdering(_ replayedBars: [MarketBar]) throws {
        var previousStart: Int?
        for bar in replayedBars {
            let currentStart = Int(bar.interval.start.timeIntervalSince1970)
            if let previousStart, currentStart <= previousStart {
                throw BinanceMarketDataBatchReplayParityError.outOfOrderRecord(
                    previousStart: previousStart,
                    currentStart: currentStart
                )
            }
            previousStart = currentStart
        }
    }

    private static func timeWindowDescription(for replayedBars: [MarketBar]) -> String {
        guard let first = replayedBars.first,
              let last = replayedBars.last else {
            return "empty"
        }
        return "\(Int(first.interval.start.timeIntervalSince1970))...\(Int(last.interval.end.timeIntervalSince1970))"
    }
}

/// BinanceMarketDataBatchReplayDeterministicParity 提供 MTP-57 的本地 parity 计算函数。
///
/// 该工具只对已经 replay 到 Core `MarketBar` 的本地 fixture records 生成 canonical summary
/// 和稳定 FNV-1a parity hint；它不读取文件系统、不调用网络、不访问 Binance adapter request，
/// 也不代表任何生产数据校验平台。
public enum BinanceMarketDataBatchReplayDeterministicParity {
    public static func canonicalReplaySummary(for replayedBars: [MarketBar]) -> [String] {
        replayedBars.map { bar in
            [
                bar.symbol.rawValue,
                bar.timeframe.rawValue,
                "\(Int(bar.interval.start.timeIntervalSince1970))...\(Int(bar.interval.end.timeIntervalSince1970))",
                "open=\(scaledDecimalToken(bar.open.rawValue))",
                "high=\(scaledDecimalToken(bar.high.rawValue))",
                "low=\(scaledDecimalToken(bar.low.rawValue))",
                "close=\(scaledDecimalToken(bar.close.rawValue))",
                "volume=\(scaledDecimalToken(bar.volume.rawValue))"
            ].joined(separator: "|")
        }
    }

    public static func checksumParityHint(for replayedBars: [MarketBar]) -> String {
        checksumParityHint(forCanonicalSummary: canonicalReplaySummary(for: replayedBars))
    }

    public static func checksumParityHint(forCanonicalSummary summary: [String]) -> String {
        let canonicalPayload = summary.joined(separator: "\n")
        return "fnv1a64:\(fnv1a64Hex(canonicalPayload))"
    }

    public static func validate(
        contract: BinanceMarketDataBatchReplayContract,
        replayedBars: [MarketBar]
    ) throws -> BinanceMarketDataBatchReplayConsistencyEvidence {
        try BinanceMarketDataBatchReplayConsistencyEvidence(
            contract: contract,
            replayedBars: replayedBars
        )
    }

    private static func scaledDecimalToken(_ value: Double) -> String {
        String(Int((value * 1_000_000).rounded()))
    }

    private static func fnv1a64Hex(_ payload: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in payload.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        let hex = String(hash, radix: 16)
        return String(repeating: "0", count: max(0, 16 - hex.count)) + hex
    }
}

public extension BinanceMarketDataReplayOperationsFixture {
    /// deterministicReplayRecords 提供 MTP-57 的本地 batch replay output fixture。
    /// 输出只包含 Binance public kline 解码后的 Core `MarketBar`，用于验证 metadata parity、
    /// record ordering 和 checksum / parity hint，不代表真实历史下载规模或生产 replay job。
    static func deterministicReplayRecords() throws -> [MarketBar] {
        [
            try MarketBar(
                symbol: Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                interval: DateRange(
                    start: Date(timeIntervalSince1970: 1_704_067_200),
                    end: Date(timeIntervalSince1970: 1_704_067_260)
                ),
                open: 42_000.10,
                high: 42_100.20,
                low: 41_900.30,
                close: 42_050.40,
                volume: 12.345
            )
        ]
    }

    static func deterministicReplayConsistencyEvidence() throws -> BinanceMarketDataBatchReplayConsistencyEvidence {
        try BinanceMarketDataBatchReplayDeterministicParity.validate(
            contract: deterministicContract(),
            replayedBars: deterministicReplayRecords()
        )
    }
}
