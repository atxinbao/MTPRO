import DomainModel
import Foundation

// GH-1208 static contract boundary:
// endpointFamilyPairs=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// endpointFamilyEnvironments=testnet,productionShadow
// endpointFamilyStates=activeReference,productionShadow,placeholder,forbidden
// binanceSpotEndpointFamilies=testnet.binance.vision,api.binance.com
// binanceUSDMFuturesEndpointFamilies=testnet.binancefuture.com,fapi.binance.com
// okxEndpointFamilies=www.okx.com
// productionLiveForbiddenByDefault=true
// productionEndpointConnectionEnabled=false
// productionSecretReadEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// productionCutoverAuthorized=false
// GH-1208-VERIFY-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY
// TVM-RELEASE-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY
// V0190-003-ENDPOINT-FAMILY-REGISTRY
// V0190-003-BINANCE-SPOT-TESTNET-PRODUCTION-SHADOW
// V0190-003-BINANCE-USDM-FUTURES-TESTNET-PRODUCTION-SHADOW
// V0190-003-OKX-SPOT-SWAP-PLACEHOLDER
// V0190-003-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
// V0190-003-NO-ENDPOINT-CONNECTION
// V0190-003-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueEndpointFamilyState 描述 endpoint family row 的可用性。
///
/// `activeReference` 只表示 testnet endpoint reference 可被后续显式 runtime issue 复用；
/// 当前 issue 不打开连接。`productionShadow` 只保存 production host family 的 shadow evidence，
/// 不等于 productionLive，也不授权真实 endpoint / broker 连接。
public enum ReleaseV0190VenueEndpointFamilyState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case activeReference
    case productionShadow
    case placeholder
    case forbidden
}

/// ReleaseV0190VenueEndpointHostFamily 是 v0.19.0 的 typed endpoint host family。
///
/// Host family 只保存 canonical scheme / host 字段，避免 endpoint 选择继续散落在 ad hoc
/// string switch 中。OKX family 目前只用于 placeholder evidence，不实现 OKX runtime。
public enum ReleaseV0190VenueEndpointHostFamily: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case binanceSpotTestnet
    case binanceSpotProductionShadow
    case binanceUSDMFuturesTestnet
    case binanceUSDMFuturesProductionShadow
    case okxPlaceholder

    public var scheme: String { "https" }

    public var host: String {
        switch self {
        case .binanceSpotTestnet:
            "testnet.binance.vision"
        case .binanceSpotProductionShadow:
            "api.binance.com"
        case .binanceUSDMFuturesTestnet:
            "testnet.binancefuture.com"
        case .binanceUSDMFuturesProductionShadow:
            "fapi.binance.com"
        case .okxPlaceholder:
            "www.okx.com"
        }
    }
}

/// ReleaseV0190VenueEndpointFamilyEntry 是单个 venue/product/environment 的 endpoint family row。
///
/// Entry 仅用于 contract / audit / adapter registration 前置检查。它不会构造 transport，
/// 不读取 credential，不执行 network request，也不会把 productionShadow 升级为 productionLive。
public struct ReleaseV0190VenueEndpointFamilyEntry: Equatable, Hashable, Sendable {
    public let pair: ReleaseV0181VenueProductPair
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let hostFamily: ReleaseV0190VenueEndpointHostFamily
    public let state: ReleaseV0190VenueEndpointFamilyState
    public let reason: String

    public var scheme: String { hostFamily.scheme }
    public var host: String { hostFamily.host }
    public var reference: String { "\(scheme)://\(host)" }
    public var connectsEndpoint: Bool { false }

    public init(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        hostFamily: ReleaseV0190VenueEndpointHostFamily,
        state: ReleaseV0190VenueEndpointFamilyState,
        reason: String
    ) throws {
        try Self.validate(
            pair: pair,
            tradingEnvironment: tradingEnvironment,
            scheme: hostFamily.scheme,
            host: hostFamily.host,
            hostFamily: hostFamily,
            state: state
        )
        self.pair = pair
        self.tradingEnvironment = tradingEnvironment
        self.hostFamily = hostFamily
        self.state = state
        self.reason = reason
    }

    public static func validate(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        scheme: String,
        host: String,
        hostFamily: ReleaseV0190VenueEndpointHostFamily,
        state: ReleaseV0190VenueEndpointFamilyState
    ) throws {
        guard scheme.lowercased() == hostFamily.scheme else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.scheme",
                expected: hostFamily.scheme,
                actual: scheme
            )
        }
        guard host.lowercased() == hostFamily.host else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.host",
                expected: hostFamily.host,
                actual: host
            )
        }
        guard tradingEnvironment != .productionLive else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.environment",
                expected: "testnet or productionShadow; productionLive forbidden by default",
                actual: tradingEnvironment.rawValue
            )
        }
        guard ReleaseV0190VenueProductTargetRegistry.supportsPair(
            venueID: pair.venueID,
            productKind: pair.productKind
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.pair",
                expected: "binance/spot,binance/usdmFutures,okx/spot,okx/swap",
                actual: "\(pair.venueID.rawValue)/\(pair.productKind.rawValue)"
            )
        }
        guard allowedHostFamilies(
            pair: pair,
            tradingEnvironment: tradingEnvironment,
            state: state
        ).contains(hostFamily) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.hostFamily",
                expected: "host family matching venue/product/environment/state",
                actual: "\(pair.venueID.rawValue)/\(pair.productKind.rawValue)/\(tradingEnvironment.rawValue)/\(hostFamily.rawValue)"
            )
        }
    }

    private static func allowedHostFamilies(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        state: ReleaseV0190VenueEndpointFamilyState
    ) -> Set<ReleaseV0190VenueEndpointHostFamily> {
        switch (pair.venueID, pair.productKind, tradingEnvironment, state) {
        case (.binance, .spot, .testnet, .activeReference):
            [.binanceSpotTestnet]
        case (.binance, .spot, .productionShadow, .productionShadow):
            [.binanceSpotProductionShadow]
        case (.binance, .usdmFutures, .testnet, .activeReference):
            [.binanceUSDMFuturesTestnet]
        case (.binance, .usdmFutures, .productionShadow, .productionShadow):
            [.binanceUSDMFuturesProductionShadow]
        case (.okx, .spot, .testnet, .placeholder),
             (.okx, .spot, .productionShadow, .placeholder),
             (.okx, .swap, .testnet, .placeholder),
             (.okx, .swap, .productionShadow, .placeholder):
            [.okxPlaceholder]
        default:
            []
        }
    }
}

/// ReleaseV0190VenueEndpointFamilyRegistry 固定 v0.19.0 的 endpoint family registry。
///
/// Registry 覆盖 Binance Spot / USDⓈ-M Futures 的 testnet 与 productionShadow host family，
/// 以及 OKX Spot / Swap placeholder family。任何 productionLive 选择都 fail closed。
public enum ReleaseV0190VenueEndpointFamilyRegistry {
    public static let productionEndpointConnectionEnabled = false
    public static let productionTradingEnabledByDefault = false
    public static let okxRuntimeImplemented = false

    public static let allEntries: [ReleaseV0190VenueEndpointFamilyEntry] = [
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
            tradingEnvironment: .testnet,
            hostFamily: .binanceSpotTestnet,
            state: .activeReference,
            reason: "Binance Spot testnet endpoint family reference; no connection is opened by v0.19.0 registry"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
            tradingEnvironment: .productionShadow,
            hostFamily: .binanceSpotProductionShadow,
            state: .productionShadow,
            reason: "Binance Spot production host family is shadow evidence only; productionLive remains forbidden"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures),
            tradingEnvironment: .testnet,
            hostFamily: .binanceUSDMFuturesTestnet,
            state: .activeReference,
            reason: "Binance USDⓈ-M Futures testnet endpoint family reference; no connection is opened by v0.19.0 registry"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures),
            tradingEnvironment: .productionShadow,
            hostFamily: .binanceUSDMFuturesProductionShadow,
            state: .productionShadow,
            reason: "Binance USDⓈ-M Futures production host family is shadow evidence only; productionLive remains forbidden"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot),
            tradingEnvironment: .testnet,
            hostFamily: .okxPlaceholder,
            state: .placeholder,
            reason: "OKX Spot endpoint family is placeholder evidence only; no OKX runtime is implemented"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot),
            tradingEnvironment: .productionShadow,
            hostFamily: .okxPlaceholder,
            state: .placeholder,
            reason: "OKX Spot production shadow endpoint family remains placeholder evidence only"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap),
            tradingEnvironment: .testnet,
            hostFamily: .okxPlaceholder,
            state: .placeholder,
            reason: "OKX Swap endpoint family is placeholder evidence only; no OKX runtime is implemented"
        ),
        constantEntry(
            pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap),
            tradingEnvironment: .productionShadow,
            hostFamily: .okxPlaceholder,
            state: .placeholder,
            reason: "OKX Swap production shadow endpoint family remains placeholder evidence only"
        )
    ]

    public static func entry(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) throws -> ReleaseV0190VenueEndpointFamilyEntry {
        guard tradingEnvironment != .productionLive else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.environment",
                expected: "testnet or productionShadow; productionLive forbidden by default",
                actual: tradingEnvironment.rawValue
            )
        }
        guard let entry = allEntries.first(where: {
            $0.pair == ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
                && $0.tradingEnvironment == tradingEnvironment
        }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.entry",
                expected: "endpoint family entry for supported venue/product/environment",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)/\(tradingEnvironment.rawValue)"
            )
        }
        return entry
    }

    public static func requireActiveTestnetReference(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> ReleaseV0190VenueEndpointFamilyEntry {
        let entry = try entry(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: .testnet
        )
        guard entry.state == .activeReference else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.endpointFamily.state",
                expected: ReleaseV0190VenueEndpointFamilyState.activeReference.rawValue,
                actual: "\(entry.state.rawValue): \(entry.reason)"
            )
        }
        return entry
    }

    private static func constantEntry(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        hostFamily: ReleaseV0190VenueEndpointHostFamily,
        state: ReleaseV0190VenueEndpointFamilyState,
        reason: String
    ) -> ReleaseV0190VenueEndpointFamilyEntry {
        do {
            return try ReleaseV0190VenueEndpointFamilyEntry(
                pair: pair,
                tradingEnvironment: tradingEnvironment,
                hostFamily: hostFamily,
                state: state,
                reason: reason
            )
        } catch {
            preconditionFailure("GH-1208 endpoint family entry must be valid: \(error)")
        }
    }
}
