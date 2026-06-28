import DomainModel
import Foundation

// GH-1204 static contract boundary:
// typedNamespaceModel=ReleaseV0181TypedNamespaceModel
// typedVenueIDValues=binance,okx
// typedProductKindValues=spot,usdmFutures,swap
// typedTradingEnvironmentValues=testnet,productionShadow,productionLive
// accountProfileIDValidated=true
// allowedVenueProductPairsFailClosed=true
// productionLiveForbiddenByDefault=true
// jsonCodecMigrationEvidence=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1204-VERIFY-V0181-TYPED-NAMESPACE-MODEL
// TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL
// V0181-005-TYPED-VENUE-PRODUCT-ENVIRONMENT
// V0181-005-ACCOUNT-PROFILE-ID
// V0181-005-ALLOWED-PAIRS-FAIL-CLOSED
// V0181-005-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
// V0181-005-JSON-CODEC-MIGRATION
// V0181-005-NO-PRODUCTION-CUTOVER

/// ReleaseV0181VenueID 是 #1204 的 typed venue identity。
///
/// 该类型只表达当前 recovery evidence 可识别的 venue 名称，不创建 venue registry，
/// 不授权 OKX runtime，也不触发任何 endpoint / broker 连接。
public enum ReleaseV0181VenueID: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case binance
    case okx

    public init(validating rawValue: String, field: String = "releaseV0181.venue") throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = Self(rawValue: normalized) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: field,
                expected: Self.allCases.map(\.rawValue).joined(separator: ","),
                actual: rawValue
            )
        }
        self = value
    }
}

/// ReleaseV0181ProductKind 是 #1204 的 typed product namespace。
///
/// `usdmFutures` 是 canonical raw value。初始化器保留少量旧 evidence alias 到 canonical
/// value 的迁移能力，避免历史 `usdm-perpetual` 字符串继续扩散为新的 raw switch。
public enum ReleaseV0181ProductKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case spot
    case usdmFutures
    case swap

    public init(validating rawValue: String, field: String = "releaseV0181.product") throws {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        let resolved: Self? = switch normalized {
        case "spot":
            .spot
        case "swap":
            .swap
        case "usdmfutures", "usdm-futures", "usdm-perpetual":
            .usdmFutures
        default:
            nil
        }
        guard let value = resolved else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: field,
                expected: Self.allCases.map(\.rawValue).joined(separator: ","),
                actual: rawValue
            )
        }
        self = value
    }
}

/// ReleaseV0181TradingEnvironment 是 #1204 的 typed environment namespace。
///
/// `productionLive` 被建模为可识别值，便于 evidence 解释 operator 输入；critical v0.18
/// namespace policy 会默认拒绝它，防止 typed model 被误解为 production cutover 授权。
public enum ReleaseV0181TradingEnvironment: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case testnet
    case productionShadow
    case productionLive

    public init(validating rawValue: String, field: String = "releaseV0181.environment") throws {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        let resolved: Self? = switch normalized {
        case "testnet":
            .testnet
        case "productionshadow", "production-shadow":
            .productionShadow
        case "productionlive", "production-live":
            .productionLive
        default:
            nil
        }
        guard let value = resolved else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: field,
                expected: Self.allCases.map(\.rawValue).joined(separator: ","),
                actual: rawValue
            )
        }
        self = value
    }
}

/// ReleaseV0181AccountProfileID 是 #1204 的 typed account profile wrapper。
///
/// Profile ID 只允许安全本地 evidence label，不保存 API key、secret、listen key 或 raw
/// endpoint response。它不是 credential provider，也不会读取 secret。
public struct ReleaseV0181AccountProfileID:
    Codable,
    Equatable,
    Hashable,
    Sendable,
    CustomStringConvertible
{
    public let rawValue: String

    public var description: String { rawValue }

    public init(_ rawValue: String, field: String = "releaseV0181.accountProfile") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        let safeCharacters = trimmed.allSatisfy { character in
            character.isLetter || character.isNumber || character == "-" || character == "_"
        }
        guard trimmed.isEmpty == false,
              safeCharacters,
              ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers(in: trimmed).isEmpty,
              Self.credentialLikeMarkers.allSatisfy({ lowered.contains($0) == false }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: field,
                expected: "non-empty safe local account profile id without credential markers",
                actual: rawValue
            )
        }
        self.rawValue = trimmed
    }

    public static let credentialLikeMarkers = [
        "api-key",
        "api_key",
        "apikey",
        "listen-key",
        "listen_key",
        "listenkey",
        "secret",
        "signature",
        "x-mbx-apikey"
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// ReleaseV0181VenueProductNamespacePolicy 集中 #1204 的 venue/product/environment allowlist。
///
/// 它替代 v0.18 recovery evidence 中散落的 raw string switch；`productionLive` 默认不允许
/// 进入 critical namespace，因此不会打开 production trading、secret、endpoint 或 broker path。
public enum ReleaseV0181VenueProductNamespacePolicy {
    public static let allowedPairs: Set<ReleaseV0181VenueProductPair> = [
        ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot),
        ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures),
        ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot),
        ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap)
    ]

    public static func supportsPair(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) -> Bool {
        allowedPairs.contains(ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind))
    }

    public static func supportsRawPair(venue: String, product: String) -> Bool {
        guard let venueID = try? ReleaseV0181VenueID(validating: venue),
              let productKind = try? ReleaseV0181ProductKind(validating: product) else {
            return false
        }
        return supportsPair(venueID: venueID, productKind: productKind)
    }

    public static func supportsCriticalNamespaceEnvironment(_ environment: ReleaseV0181TradingEnvironment) -> Bool {
        environment != .productionLive
    }

    public static func supportsCriticalNamespace(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> Bool {
        supportsPair(venueID: venueID, productKind: productKind)
            && supportsCriticalNamespaceEnvironment(tradingEnvironment)
    }
}

/// ReleaseV0181VenueProductPair 是 typed allowlist 的 hashable key。
public struct ReleaseV0181VenueProductPair: Equatable, Hashable, Sendable {
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind

    public init(venueID: ReleaseV0181VenueID, productKind: ReleaseV0181ProductKind) {
        self.venueID = venueID
        self.productKind = productKind
    }
}
