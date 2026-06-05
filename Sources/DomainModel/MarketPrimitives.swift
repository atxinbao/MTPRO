import Foundation

/// Core 基础值对象定义 symbol、timeframe、执行模式、日期范围和数值约束，是所有市场数据与策略合同的输入边界。
///
/// GH-394 起这些值对象由 `DomainModel` target 直接编译拥有；`Core` compatibility
/// envelope 只通过 re-export 保留旧 `import Core` 可见性，不再作为 primary source owner。

/// Symbol 表示第一版允许的交易标的集合，输入会规范化为大写并拒绝未授权市场。
public struct Symbol: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let supportedRawValues = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"]

    public let rawValue: String

    public init(rawValue: String) throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard Self.supportedRawValues.contains(normalized) else {
            throw domainModelUnsupportedSymbolError(rawValue)
        }
        self.rawValue = normalized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

/// Timeframe 表示第一版允许的 kline 粒度，只开放 1m 和 5m。
public enum Timeframe: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"

    public static var supportedRawValues: [String] {
        allCases.map(\.rawValue)
    }

    public init(contractValue: String) throws {
        guard let timeframe = Self(rawValue: contractValue) else {
            throw domainModelUnsupportedTimeframeError(contractValue)
        }
        self = timeframe
    }
}

/// ExecutionMode 限定当前只支持 backtest 与 paper，并显式拒绝 live / broker / real 语义。
public enum ExecutionMode: String, Codable, CaseIterable, Equatable, Sendable {
    case backtest
    case paper

    public init(contractValue: String) throws {
        let normalized = contractValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case Self.backtest.rawValue:
            self = .backtest
        case Self.paper.rawValue:
            self = .paper
        case "live", "broker", "real", "production":
            throw domainModelLiveExecutionForbiddenError(contractValue)
        default:
            throw domainModelUnsupportedExecutionModeError(contractValue)
        }
    }
}

/// DateRange 表示查询或行情区间，要求 start 严格早于 end。
public struct DateRange: Codable, Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start < end else {
            throw domainModelInvalidDateRangeError()
        }
        self.start = start
        self.end = end
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(Date.self, forKey: .start)
        let end = try container.decode(Date.self, forKey: .end)
        try self.init(start: start, end: end)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }

    private enum CodingKeys: String, CodingKey {
        case start
        case end
    }
}

/// Identifier 是策略、运行、会话和投影对象的稳定标识，拒绝空白字符串。
public struct Identifier: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String, field: String = "identifier") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw domainModelEmptyIdentifierError(field)
        }
        self.rawValue = trimmed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

/// Price 封装正数价格约束，避免非有限值或非正数进入市场模型。
public struct Price: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "price") throws {
        guard rawValue.isFinite, rawValue > 0 else {
            throw domainModelInvalidPriceError(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Quantity 封装数量约束，允许零数量用于订单簿删除语义但拒绝负数和非有限值。
public struct Quantity: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "quantity") throws {
        guard rawValue.isFinite, rawValue >= 0 else {
            throw domainModelInvalidQuantityError(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

private func domainModelUnsupportedSymbolError(_ value: String) -> any Error {
    DomainModelContractError.unsupportedSymbol(value)
}

private func domainModelUnsupportedTimeframeError(_ value: String) -> any Error {
    DomainModelContractError.unsupportedTimeframe(value)
}

private func domainModelUnsupportedExecutionModeError(_ value: String) -> any Error {
    DomainModelContractError.unsupportedExecutionMode(value)
}

private func domainModelLiveExecutionForbiddenError(_ value: String) -> any Error {
    DomainModelContractError.liveExecutionForbidden(value)
}

private func domainModelInvalidDateRangeError() -> any Error {
    DomainModelContractError.invalidDateRange
}

private func domainModelEmptyIdentifierError(_ field: String) -> any Error {
    DomainModelContractError.emptyIdentifier(field)
}

private func domainModelInvalidPriceError(_ field: String, _ value: Double) -> any Error {
    DomainModelContractError.invalidPrice(field, value)
}

private func domainModelInvalidQuantityError(_ field: String, _ value: Double) -> any Error {
    DomainModelContractError.invalidQuantity(field, value)
}
