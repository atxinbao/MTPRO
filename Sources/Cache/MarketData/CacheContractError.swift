import Foundation

/// Cache target 自有 contract error。
///
/// GH-396 后 `Sources/Cache/MarketData` 由 `Cache` target 编译，不能继续依赖
/// `CoreError`。这里的错误只表达 read-model cache 输入不一致，不代表 broker state、
/// durable database fact、signed endpoint、account payload 或 live trading runtime。
public enum CacheContractError: Error, Equatable, Sendable, CustomStringConvertible {
    case marketDataMismatch(field: String, expected: String, actual: String)

    public var description: String {
        switch self {
        case let .marketDataMismatch(field, expected, actual):
            "Cache market data mismatch for \(field): expected \(expected), actual \(actual)"
        }
    }
}
