import Foundation

/// DomainModelContractError 是 `DomainModel` target 自己拥有的基础合同错误。
///
/// 该错误只覆盖 symbol、timeframe、execution mode、date range、identifier、price
/// 和 quantity 这些 foundation value object 校验；它不包含 paper、Trader、
/// RiskEngine、ExecutionEngine、ExecutionClient、broker、OMS 或 Live runtime 语义，
/// 防止底层 DomainModel 反向依赖上层业务模块。
public enum DomainModelContractError: Error, Equatable, Sendable, CustomStringConvertible {
    case unsupportedSymbol(String)
    case unsupportedTimeframe(String)
    case unsupportedExecutionMode(String)
    case liveExecutionForbidden(String)
    case invalidDateRange
    case emptyIdentifier(String)
    case invalidPrice(String, Double)
    case invalidQuantity(String, Double)
    case unsupportedProductType(String)
    case invalidInstrumentIdentity(String)
    case invalidPerpetualContract(String)
    case invalidTargetExposureIntent(String)
    case invalidProductAwareOrderIntent(String)
    case invalidOrderIntent(String)

    public var description: String {
        switch self {
        case let .unsupportedSymbol(value):
            "Unsupported symbol: \(value)"
        case let .unsupportedTimeframe(value):
            "Unsupported timeframe: \(value)"
        case let .unsupportedExecutionMode(value):
            "Unsupported execution mode: \(value)"
        case let .liveExecutionForbidden(value):
            "Live execution is forbidden: \(value)"
        case .invalidDateRange:
            "Date range must have start before end"
        case let .emptyIdentifier(field):
            "Identifier must not be empty: \(field)"
        case let .invalidPrice(field, value):
            "Price must be finite and positive for \(field): \(value)"
        case let .invalidQuantity(field, value):
            "Quantity must be finite and non-negative for \(field): \(value)"
        case let .unsupportedProductType(value):
            "Unsupported product type: \(value)"
        case let .invalidInstrumentIdentity(value):
            "Instrument identity is invalid: \(value)"
        case let .invalidPerpetualContract(value):
            "Perpetual contract is invalid: \(value)"
        case let .invalidTargetExposureIntent(value):
            "Target exposure intent is invalid: \(value)"
        case let .invalidProductAwareOrderIntent(value):
            "Product-aware order intent is invalid: \(value)"
        case let .invalidOrderIntent(value):
            "Order intent is invalid: \(value)"
        }
    }
}
