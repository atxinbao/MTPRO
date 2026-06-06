import DomainModel

/// MarketDataQuery 是 MessageBus 层可复用的只读行情查询合同。
///
/// 它只描述 symbol、timeframe 和时间范围，不读取交易所、不触发 DataClient 请求、
/// 不暴露 adapter request，也不代表 live command。
public struct MarketDataQuery: Codable, Equatable, Sendable {
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let range: DateRange

    public init(symbol: Symbol, timeframe: Timeframe, range: DateRange) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
    }
}
