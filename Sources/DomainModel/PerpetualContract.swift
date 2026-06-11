import Foundation

/// PerpetualContract 描述 USDⓈ-M Perpetual instrument 所需的最小合约元数据。
///
/// 该模型只绑定 perpetual 产品身份、保证金 / 结算资产、contract size 与资金费率周期；
/// 它不实现 leverage action、margin action、broker order、execution report 或 production endpoint。
public struct PerpetualContract: Codable, Equatable, Sendable {
    public let instrument: InstrumentIdentity
    public let marginAsset: Identifier
    public let settlementAsset: Identifier
    public let contractSize: Quantity
    public let fundingIntervalHours: Int

    public init(
        instrument: InstrumentIdentity,
        marginAsset: Identifier,
        settlementAsset: Identifier,
        contractSize: Double,
        fundingIntervalHours: Int
    ) throws {
        guard instrument.productType == .usdsPerpetual else {
            throw DomainModelContractError.invalidPerpetualContract(
                "instrument productType must be usdsPerpetual: \(instrument.rawValue)"
            )
        }
        guard fundingIntervalHours > 0 else {
            throw DomainModelContractError.invalidPerpetualContract(
                "fundingIntervalHours must be positive: \(fundingIntervalHours)"
            )
        }
        guard contractSize.isFinite, contractSize > 0 else {
            throw DomainModelContractError.invalidPerpetualContract(
                "contractSize must be finite and positive: \(contractSize)"
            )
        }

        self.instrument = instrument
        self.marginAsset = marginAsset
        self.settlementAsset = settlementAsset
        self.contractSize = try Quantity(contractSize, field: "perpetualContract.contractSize")
        self.fundingIntervalHours = fundingIntervalHours
    }

    /// Release v0.2.0 BTCUSDT USDⓈ-M Perpetual deterministic fixture。
    ///
    /// 该入口保持 throwing，避免在 production source 中新增 `fatalError` 路径；
    /// 调用方必须把 fixture 合同失败当作验证失败处理。
    public static func binanceBTCUSDTFixture() throws -> Self {
        try Self(
            instrument: .binance(
                productType: .usdsPerpetual,
                symbol: .constant("BTCUSDT")
            ),
            marginAsset: .constant("USDT", field: "perpetualContract.marginAsset"),
            settlementAsset: .constant("USDT", field: "perpetualContract.settlementAsset"),
            contractSize: 1,
            fundingIntervalHours: 8
        )
    }
}
