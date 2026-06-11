import Foundation

/// InstrumentIdentity 是 release v0.2.0 的规范化工具标识。
///
/// 同一个交易对在 Spot 和 USDⓈ-M Perpetual 下必须成为两个不同 instrument，
/// 因此 identity 强制包含 venue、productType 与 symbol。该类型不包含 broker
/// endpoint、account endpoint、listenKey、order command 或 production trading 授权。
public struct InstrumentIdentity: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let venue: Identifier
    public let productType: ProductType
    public let symbol: Symbol

    public init(
        venue: Identifier,
        productType: ProductType,
        symbol: Symbol
    ) {
        self.venue = venue
        self.productType = productType
        self.symbol = symbol
    }

    public init(
        venue: String,
        productType: ProductType,
        symbol: Symbol
    ) throws {
        self.init(
            venue: try Identifier(venue, field: "instrumentIdentity.venue"),
            productType: productType,
            symbol: symbol
        )
    }

    public init(rawValue: String) throws {
        let components = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":", omittingEmptySubsequences: false)
            .map(String.init)

        guard components.count == 3 else {
            throw DomainModelContractError.invalidInstrumentIdentity(rawValue)
        }

        self.init(
            venue: try Identifier(components[0], field: "instrumentIdentity.venue"),
            productType: try ProductType(contractValue: components[1]),
            symbol: try Symbol(rawValue: components[2])
        )
    }

    /// Release v0.2.0 当前唯一 active venue 的 deterministic fixture 入口。
    public static func binance(
        productType: ProductType,
        symbol: Symbol
    ) -> Self {
        Self(
            venue: .constant("binance", field: "instrumentIdentity.venue"),
            productType: productType,
            symbol: symbol
        )
    }

    public var rawValue: String {
        "\(venue.rawValue):\(productType.rawValue):\(symbol.rawValue)"
    }

    public var description: String {
        rawValue
    }
}
