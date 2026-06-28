import DomainModel
import Foundation

// GH-1206 static contract boundary:
// venueRegistryValues=binance,okx
// productRegistryValues=spot,usdmFutures,swap
// validTargetCombinations=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// tradingEnvironmentAccountProfileUsage=true
// v0181CloseoutDependencyRequired=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// productionCutoverAuthorized=false
// GH-1206-VERIFY-V0190-VENUE-PRODUCT-REGISTRY
// TVM-RELEASE-V0190-VENUE-PRODUCT-REGISTRY
// V0190-001-VENUE-REGISTRY
// V0190-001-PRODUCT-REGISTRY
// V0190-001-TRADING-ENVIRONMENT-ACCOUNT-PROFILE-USAGE
// V0190-001-VALID-TARGET-COMBINATIONS
// V0190-001-V0181-CLOSEOUT-DEPENDENCY
// V0190-001-PRODUCTION-DISABLED-BY-DEFAULT
// V0190-001-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueRegistryEntry 是 v0.19 的 canonical venue registry row。
///
/// 该 entry 只声明 venue identity 和 release 范围内的 registry 状态，不创建 OKX runtime，
/// 不触发 endpoint / broker 连接，也不授权 production cutover。
public struct ReleaseV0190VenueRegistryEntry: Equatable, Hashable, Sendable {
    public let venueID: ReleaseV0181VenueID
    public let displayName: String
    public let runtimeStatus: ReleaseV0190RegistryRuntimeStatus

    public init(
        venueID: ReleaseV0181VenueID,
        displayName: String,
        runtimeStatus: ReleaseV0190RegistryRuntimeStatus
    ) {
        self.venueID = venueID
        self.displayName = displayName
        self.runtimeStatus = runtimeStatus
    }
}

/// ReleaseV0190ProductRegistryEntry 是 v0.19 的 canonical product registry row。
///
/// `usdmFutures` 表达 Binance USDⓈ-M Futures，`swap` 表达 OKX Swap；本类型只做
/// registry contract，不实现对应 runtime adapter。
public struct ReleaseV0190ProductRegistryEntry: Equatable, Hashable, Sendable {
    public let productKind: ReleaseV0181ProductKind
    public let displayName: String

    public init(productKind: ReleaseV0181ProductKind, displayName: String) {
        self.productKind = productKind
        self.displayName = displayName
    }
}

/// ReleaseV0190RegistryRuntimeStatus 记录 registry row 的 runtime 可用性边界。
///
/// `existingEvidenceOnly` 表示已有历史 evidence / guard 可以引用该 venue；`registryOnly`
/// 表示当前 issue 只登记 identity，后续 runtime adapter 必须由独立 issue 授权。
public enum ReleaseV0190RegistryRuntimeStatus: String, Codable, Equatable, Hashable, Sendable {
    case existingEvidenceOnly
    case registryOnly
}

/// ReleaseV0190VenueRegistry 固定 v0.19 的 venue registry。
///
/// 当前 registry 只有 Binance 和 OKX 两个 canonical venue。OKX 只登记为 future
/// registry target，不实现 OKX runtime，不连接 OKX endpoint。
public enum ReleaseV0190VenueRegistry {
    public static let binance = ReleaseV0190VenueRegistryEntry(
        venueID: .binance,
        displayName: "Binance",
        runtimeStatus: .existingEvidenceOnly
    )

    public static let okx = ReleaseV0190VenueRegistryEntry(
        venueID: .okx,
        displayName: "OKX",
        runtimeStatus: .registryOnly
    )

    public static let all: [ReleaseV0190VenueRegistryEntry] = [
        binance,
        okx
    ]

    public static func entry(for venueID: ReleaseV0181VenueID) throws -> ReleaseV0190VenueRegistryEntry {
        guard let entry = all.first(where: { $0.venueID == venueID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.venueRegistry",
                expected: all.map(\.venueID.rawValue).joined(separator: ","),
                actual: venueID.rawValue
            )
        }
        return entry
    }

    public static func contains(_ venueID: ReleaseV0181VenueID) -> Bool {
        all.contains { $0.venueID == venueID }
    }
}

/// ReleaseV0190ProductRegistry 固定 v0.19 的 product registry。
///
/// Registry row 不代表 runtime activation。Spot / USDⓈ-M Futures / Swap 的 adapter
/// 能力、endpoint family 和 credential profile 必须由后续 issue 单独声明。
public enum ReleaseV0190ProductRegistry {
    public static let spot = ReleaseV0190ProductRegistryEntry(
        productKind: .spot,
        displayName: "Spot"
    )

    public static let usdmFutures = ReleaseV0190ProductRegistryEntry(
        productKind: .usdmFutures,
        displayName: "USDⓈ-M Futures"
    )

    public static let swap = ReleaseV0190ProductRegistryEntry(
        productKind: .swap,
        displayName: "Swap"
    )

    public static let all: [ReleaseV0190ProductRegistryEntry] = [
        spot,
        usdmFutures,
        swap
    ]

    public static func entry(for productKind: ReleaseV0181ProductKind) throws -> ReleaseV0190ProductRegistryEntry {
        guard let entry = all.first(where: { $0.productKind == productKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.productRegistry",
                expected: all.map(\.productKind.rawValue).joined(separator: ","),
                actual: productKind.rawValue
            )
        }
        return entry
    }

    public static func contains(_ productKind: ReleaseV0181ProductKind) -> Bool {
        all.contains { $0.productKind == productKind }
    }
}

/// ReleaseV0190VenueProductTarget 是后续 capability / adapter issue 可复用的 typed target。
///
/// Target 必须同时携带 venue、product、environment 和 accountProfile。productionLive
/// 默认拒绝，避免 registry 被误用为 production trading 授权。
public struct ReleaseV0190VenueProductTarget: Equatable, Hashable, Sendable {
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let accountProfileID: ReleaseV0181AccountProfileID

    public var pair: ReleaseV0181VenueProductPair {
        ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
    }

    public var namespaceKey: String {
        [
            venueID.rawValue,
            productKind.rawValue,
            tradingEnvironment.rawValue,
            accountProfileID.rawValue
        ].joined(separator: "/")
    }

    public init(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws {
        try ReleaseV0190VenueProductTargetRegistry.validate(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment
        )
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.accountProfileID = accountProfileID
    }
}

/// ReleaseV0190VenueProductTargetRegistry 固定 v0.19 的合法 venue/product target 组合。
///
/// 允许组合为 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap。所有其它
/// venue/product pair 以及 productionLive environment 都必须 fail closed。
public enum ReleaseV0190VenueProductTargetRegistry {
    public static let productionTradingEnabledByDefault = false
    public static let okxRuntimeImplemented = false

    public static let validPairs: Set<ReleaseV0181VenueProductPair> = [
        ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
        ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures),
        ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot),
        ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap)
    ]

    public static func supportsPair(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) -> Bool {
        validPairs.contains(ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind))
    }

    public static func supportsTarget(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> Bool {
        supportsPair(venueID: venueID, productKind: productKind)
            && tradingEnvironment != .productionLive
            && productionTradingEnabledByDefault == false
    }

    public static func validate(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) throws {
        _ = try ReleaseV0190VenueRegistry.entry(for: venueID)
        _ = try ReleaseV0190ProductRegistry.entry(for: productKind)

        guard supportsTarget(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.venueProductTarget",
                expected: "binance/spot,binance/usdmFutures,okx/spot,okx/swap with productionLive disabled",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)/\(tradingEnvironment.rawValue)"
            )
        }
    }

    public static func validTargets(
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        accountProfileID: ReleaseV0181AccountProfileID
    ) throws -> [ReleaseV0190VenueProductTarget] {
        try validPairs
            .sorted { lhs, rhs in
                "\(lhs.venueID.rawValue)/\(lhs.productKind.rawValue)" < "\(rhs.venueID.rawValue)/\(rhs.productKind.rawValue)"
            }
            .map {
                try ReleaseV0190VenueProductTarget(
                    venueID: $0.venueID,
                    productKind: $0.productKind,
                    tradingEnvironment: tradingEnvironment,
                    accountProfileID: accountProfileID
                )
            }
    }
}
