import Foundation

/// ReleaseV050PrecisionSemantic 固定 v0.5.0 runtime foundation 使用的数值语义。
///
/// 这些语义用于区分 money、notional、exposure、price 和 quantity 的精度方向，
/// 防止不同含义的 fixed-point 值在 runtime foundation 中被混用。
public enum ReleaseV050PrecisionSemantic: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case money
    case notional
    case exposure
    case price
    case quantity
}

/// ReleaseV050InstrumentTradingStatus 是 v0.5.0 InstrumentCatalog 允许表达的交易状态。
///
/// 当前 deterministic catalog 只把 Binance active scope 标为 trading，不表达 production cutover。
public enum ReleaseV050InstrumentTradingStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case trading
    case halted
}

/// ReleaseV050FixedPointValue 是 GH-729 的固定点数值对象。
///
/// 它用 minorUnits + scale 表达 Decimal / fixed-point 方向，避免 runtime foundation
/// 直接依赖 Double 近似值来判断 tickSize、stepSize、minQty 或 minNotional。
public struct ReleaseV050FixedPointValue: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let minorUnits: Int64
    public let scale: Int
    public let semantic: ReleaseV050PrecisionSemantic

    public var description: String {
        guard scale > 0 else {
            return "\(minorUnits)"
        }

        let sign = minorUnits < 0 ? "-" : ""
        let absolute = String(abs(minorUnits))
        if absolute.count <= scale {
            let padded = String(repeating: "0", count: scale - absolute.count + 1) + absolute
            let split = padded.index(padded.endIndex, offsetBy: -scale)
            return "\(sign)\(padded[..<split]).\(padded[split...])"
        }

        let split = absolute.index(absolute.endIndex, offsetBy: -scale)
        return "\(sign)\(absolute[..<split]).\(absolute[split...])"
    }

    public init(
        minorUnits: Int64,
        scale: Int,
        semantic: ReleaseV050PrecisionSemantic,
        allowsZero: Bool = false
    ) throws {
        guard scale >= 0, scale <= 18 else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 precision scale \(scale)")
        }
        if allowsZero {
            guard minorUnits >= 0 else {
                throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 negative \(semantic.rawValue)")
            }
        } else {
            guard minorUnits > 0 else {
                throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 non-positive \(semantic.rawValue)")
            }
        }

        self.minorUnits = minorUnits
        self.scale = scale
        self.semantic = semantic
    }

    public func isMultiple(of step: ReleaseV050FixedPointValue) -> Bool {
        semantic == step.semantic
            && scale == step.scale
            && step.minorUnits > 0
            && minorUnits % step.minorUnits == 0
    }

    public static func price(minorUnits: Int64, scale: Int) throws -> Self {
        try Self(minorUnits: minorUnits, scale: scale, semantic: .price)
    }

    public static func quantity(minorUnits: Int64, scale: Int) throws -> Self {
        try Self(minorUnits: minorUnits, scale: scale, semantic: .quantity)
    }

    public static func notional(minorUnits: Int64, scale: Int) throws -> Self {
        try Self(minorUnits: minorUnits, scale: scale, semantic: .notional)
    }
}

/// ReleaseV050PrecisionPolicy 固定 money / notional / exposure / price / quantity 的 scale。
///
/// Policy 只定义 runtime correctness foundation，不执行 exchange filter 或 order command。
public struct ReleaseV050PrecisionPolicy: Codable, Equatable, Hashable, Sendable {
    public let moneyScale: Int
    public let notionalScale: Int
    public let exposureScale: Int
    public let priceScale: Int
    public let quantityScale: Int

    public var usesFixedPointSemantics: Bool {
        [moneyScale, notionalScale, exposureScale, priceScale, quantityScale].allSatisfy { scale in
            scale >= 0 && scale <= 18
        }
    }

    public init(
        moneyScale: Int,
        notionalScale: Int,
        exposureScale: Int,
        priceScale: Int,
        quantityScale: Int
    ) throws {
        let scales = [
            ("moneyScale", moneyScale),
            ("notionalScale", notionalScale),
            ("exposureScale", exposureScale),
            ("priceScale", priceScale),
            ("quantityScale", quantityScale)
        ]
        if let invalid = scales.first(where: { $0.1 < 0 || $0.1 > 18 }) {
            throw DomainModelContractError.invalidInstrumentIdentity(
                "v0.5.0 precision policy \(invalid.0)=\(invalid.1)"
            )
        }

        self.moneyScale = moneyScale
        self.notionalScale = notionalScale
        self.exposureScale = exposureScale
        self.priceScale = priceScale
        self.quantityScale = quantityScale
    }
}

/// ReleaseV050InstrumentCatalogEntry 是 GH-729 的 product-aware instrument row。
///
/// Row 显式记录 venue、productType、symbol、assets、precision、tickSize、stepSize、minQty、
/// minNotional、contractSize、funding interval 和 trading status，不携带 endpoint 或 secret。
public struct ReleaseV050InstrumentCatalogEntry: Codable, Equatable, Hashable, Sendable {
    public let instrument: InstrumentIdentity
    public let baseAsset: Identifier
    public let quoteAsset: Identifier
    public let marginAsset: Identifier?
    public let precisionPolicy: ReleaseV050PrecisionPolicy
    public let tickSize: ReleaseV050FixedPointValue
    public let stepSize: ReleaseV050FixedPointValue
    public let minQuantity: ReleaseV050FixedPointValue
    public let minNotional: ReleaseV050FixedPointValue
    public let contractSize: ReleaseV050FixedPointValue?
    public let fundingIntervalHours: Int?
    public let tradingStatus: ReleaseV050InstrumentTradingStatus
    public let productionTradingEnabledByDefault: Bool

    public var entryHeld: Bool {
        instrument.venue.rawValue == "binance"
            && ProductType.allCases.contains(instrument.productType)
            && precisionPolicy.usesFixedPointSemantics
            && tickSize.semantic == .price
            && stepSize.semantic == .quantity
            && minQuantity.semantic == .quantity
            && minNotional.semantic == .notional
            && minQuantity.isMultiple(of: stepSize)
            && tradingStatus == .trading
            && productionTradingEnabledByDefault == false
            && productBoundaryHeld
    }

    private var productBoundaryHeld: Bool {
        switch instrument.productType {
        case .spot:
            return marginAsset == nil
                && contractSize == nil
                && fundingIntervalHours == nil
        case .usdsPerpetual:
            return marginAsset?.rawValue == "USDT"
                && contractSize?.semantic == .quantity
                && fundingIntervalHours == 8
        }
    }

    public init(
        instrument: InstrumentIdentity,
        baseAsset: Identifier,
        quoteAsset: Identifier,
        marginAsset: Identifier?,
        precisionPolicy: ReleaseV050PrecisionPolicy,
        tickSize: ReleaseV050FixedPointValue,
        stepSize: ReleaseV050FixedPointValue,
        minQuantity: ReleaseV050FixedPointValue,
        minNotional: ReleaseV050FixedPointValue,
        contractSize: ReleaseV050FixedPointValue?,
        fundingIntervalHours: Int?,
        tradingStatus: ReleaseV050InstrumentTradingStatus,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        guard instrument.venue.rawValue == "binance" else {
            throw DomainModelContractError.invalidInstrumentIdentity(
                "v0.5.0 unsupported venue \(instrument.venue.rawValue)"
            )
        }
        guard ProductType.allCases.contains(instrument.productType) else {
            throw DomainModelContractError.unsupportedProductType(instrument.productType.rawValue)
        }
        guard precisionPolicy.usesFixedPointSemantics else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 precision policy invalid")
        }
        guard tickSize.semantic == .price else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 tickSize must be price")
        }
        guard stepSize.semantic == .quantity else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 stepSize must be quantity")
        }
        guard minQuantity.semantic == .quantity else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 minQty must be quantity")
        }
        guard minNotional.semantic == .notional else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 minNotional must be notional")
        }
        guard minQuantity.isMultiple(of: stepSize) else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 minQty must align with stepSize")
        }
        guard productionTradingEnabledByDefault == false else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 production trading default enabled")
        }

        self.instrument = instrument
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        self.marginAsset = marginAsset
        self.precisionPolicy = precisionPolicy
        self.tickSize = tickSize
        self.stepSize = stepSize
        self.minQuantity = minQuantity
        self.minNotional = minNotional
        self.contractSize = contractSize
        self.fundingIntervalHours = fundingIntervalHours
        self.tradingStatus = tradingStatus
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault

        guard entryHeld else {
            throw DomainModelContractError.invalidInstrumentIdentity(
                "v0.5.0 instrument catalog product boundary \(instrument.rawValue)"
            )
        }
    }
}

/// ReleaseV050InstrumentCatalog 是 GH-729 的 Binance Spot / USDⓈ-M Perpetual catalog。
///
/// Catalog 只提供本地 deterministic instrument metadata，不读取 exchangeInfo endpoint，
/// 不连接 broker，不授权生产下单。
public struct ReleaseV050InstrumentCatalog: Codable, Equatable, Sendable {
    public let catalogID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let entries: [ReleaseV050InstrumentCatalogEntry]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]

    public var catalogHeld: Bool {
        guard let requiredEntries = try? Self.requiredEntries() else {
            return false
        }

        return issueID.rawValue == "GH-729"
            && upstreamIssueID.rawValue == "GH-726"
            && previousIssueID.rawValue == "GH-728"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-734", "GH-736", "GH-739"]
            && entries == requiredEntries
            && entries.allSatisfy(\.entryHeld)
            && Set(entries.map(\.instrument.productType)) == Set(ProductType.allCases)
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public init(
        catalogID: Identifier = Identifier.constant("gh-729-release-v0.5.0-instrument-catalog"),
        issueID: Identifier = Identifier.constant("GH-729"),
        upstreamIssueID: Identifier = Identifier.constant("GH-726"),
        previousIssueID: Identifier = Identifier.constant("GH-728"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-734"),
            Identifier.constant("GH-736"),
            Identifier.constant("GH-739")
        ],
        entries: [ReleaseV050InstrumentCatalogEntry]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands
    ) throws {
        let resolvedEntries = try entries ?? Self.requiredEntries()
        guard downstreamIssueIDs.map(\.rawValue) == ["GH-734", "GH-736", "GH-739"] else {
            throw DomainModelContractError.invalidInstrumentIdentity(
                "v0.5.0 downstream issue list \(downstreamIssueIDs.map(\.rawValue).joined(separator: ","))"
            )
        }
        guard resolvedEntries == (try Self.requiredEntries()) else {
            throw DomainModelContractError.invalidInstrumentIdentity(
                "v0.5.0 catalog entries \(resolvedEntries.map(\.instrument.rawValue).joined(separator: ","))"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 validation anchors mismatch")
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw DomainModelContractError.invalidInstrumentIdentity("v0.5.0 validation commands mismatch")
        }

        self.catalogID = catalogID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.entries = resolvedEntries
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
    }

    public func entry(for identity: InstrumentIdentity) -> ReleaseV050InstrumentCatalogEntry? {
        entries.first { $0.instrument == identity }
    }

    public static func deterministicFixture() throws -> ReleaseV050InstrumentCatalog {
        try ReleaseV050InstrumentCatalog()
    }

    public static func requiredEntries() throws -> [ReleaseV050InstrumentCatalogEntry] {
        [
            try ReleaseV050InstrumentCatalogEntry(
                instrument: .binance(productType: .spot, symbol: .constant("BTCUSDT")),
                baseAsset: .constant("BTC", field: "instrumentCatalog.baseAsset"),
                quoteAsset: .constant("USDT", field: "instrumentCatalog.quoteAsset"),
                marginAsset: nil,
                precisionPolicy: try ReleaseV050PrecisionPolicy(
                    moneyScale: 8,
                    notionalScale: 8,
                    exposureScale: 8,
                    priceScale: 2,
                    quantityScale: 6
                ),
                tickSize: try .price(minorUnits: 1, scale: 2),
                stepSize: try .quantity(minorUnits: 1, scale: 6),
                minQuantity: try .quantity(minorUnits: 1_000, scale: 6),
                minNotional: try .notional(minorUnits: 1_000_000_000, scale: 8),
                contractSize: nil,
                fundingIntervalHours: nil,
                tradingStatus: .trading
            ),
            try ReleaseV050InstrumentCatalogEntry(
                instrument: .binance(productType: .usdsPerpetual, symbol: .constant("BTCUSDT")),
                baseAsset: .constant("BTC", field: "instrumentCatalog.baseAsset"),
                quoteAsset: .constant("USDT", field: "instrumentCatalog.quoteAsset"),
                marginAsset: .constant("USDT", field: "instrumentCatalog.marginAsset"),
                precisionPolicy: try ReleaseV050PrecisionPolicy(
                    moneyScale: 8,
                    notionalScale: 8,
                    exposureScale: 8,
                    priceScale: 1,
                    quantityScale: 3
                ),
                tickSize: try .price(minorUnits: 1, scale: 1),
                stepSize: try .quantity(minorUnits: 1, scale: 3),
                minQuantity: try .quantity(minorUnits: 1, scale: 3),
                minNotional: try .notional(minorUnits: 500_000_000, scale: 8),
                contractSize: try .quantity(minorUnits: 1_000, scale: 3),
                fundingIntervalHours: 8,
                tradingStatus: .trading
            )
        ]
    }

    public static let requiredValidationAnchors = [
        "V050-04-PRECISION-PRIMITIVES-INSTRUMENT-CATALOG",
        "V050-04-FIXED-POINT-MONEY-NOTIONAL-EXPOSURE-PRICE-QUANTITY",
        "V050-04-BINANCE-SPOT-PERP-INSTRUMENT-FILTERS",
        "V050-04-STRICT-PRODUCTTYPE-PARSING",
        "TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH729PrecisionPrimitivesAndInstrumentCatalogAreStrict",
        "bash checks/verify-v0.5.0-instrument-catalog.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
