import Foundation

/// ProductType 表示 release v0.2.0 当前允许的 Binance 产品类型边界。
///
/// 该枚举只允许 Spot 与 USDⓈ-M Perpetual，明确拒绝 COIN-M、options、margin
/// 或第三 active product type，防止后续 runtime、risk 或 execution evidence 混用产品语义。
public enum ProductType: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spot
    case usdsPerpetual

    public static var supportedRawValues: [String] {
        allCases.map(\.rawValue)
    }

    public init(contractValue: String) throws {
        let normalized = contractValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")

        switch normalized {
        case Self.spot.rawValue:
            self = .spot
        case "usdsperpetual":
            self = .usdsPerpetual
        default:
            throw DomainModelContractError.unsupportedProductType(contractValue)
        }
    }

    /// 当前 product type 是否需要 perpetual 合约元数据。
    public var requiresPerpetualContract: Bool {
        self == .usdsPerpetual
    }
}
