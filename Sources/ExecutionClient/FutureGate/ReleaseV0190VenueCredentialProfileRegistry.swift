import DomainModel
import Foundation

// GH-1209 static contract boundary:
// credentialProfilePairs=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// credentialProfileEnvironments=testnet,productionShadow
// credentialProfileStates=testnetReference,productionShadow,placeholder,forbidden
// credentialIdentityOnly=true
// redactedEvidenceOnly=true
// crossNamespaceReuseFailsClosed=true
// productionLiveForbiddenByDefault=true
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// okxRuntimeImplemented=false
// productionCutoverAuthorized=false
// GH-1209-VERIFY-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY
// TVM-RELEASE-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY
// V0190-004-CREDENTIAL-PROFILE-REGISTRY
// V0190-004-TESTNET-PRODUCTION-SHADOW-PROFILES
// V0190-004-CREDENTIAL-IDENTITY-ONLY
// V0190-004-CROSS-NAMESPACE-REUSE-FAILS-CLOSED
// V0190-004-REDACTED-EVIDENCE-ONLY
// V0190-004-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT
// V0190-004-NO-SECRET-READ
// V0190-004-NO-PRODUCTION-CUTOVER

/// ReleaseV0190VenueCredentialProfileState 描述 credential profile row 的可用性。
///
/// `testnetReference` 和 `productionShadow` 都只表示 typed identity row；它们不包含 secret
/// value，也不读取 secret provider。`placeholder` 用于 OKX future venue/product row。
public enum ReleaseV0190VenueCredentialProfileState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case testnetReference
    case productionShadow
    case placeholder
    case forbidden
}

/// ReleaseV0190VenueCredentialProfileEntry 是 venue/product/environment scoped credential identity。
///
/// Entry 只保存安全 profile identity、namespace 和 redacted evidence reference。它不会保存 API
/// key、secret、listen key、signature 或 raw credential material，也不会连接 endpoint。
public struct ReleaseV0190VenueCredentialProfileEntry: Equatable, Hashable, Sendable {
    public let pair: ReleaseV0181VenueProductPair
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let profileID: ReleaseV0181AccountProfileID
    public let state: ReleaseV0190VenueCredentialProfileState
    public let reason: String
    public let redactedEvidenceReference: String
    public let credentialIdentityOnly: Bool
    public let redactedEvidenceOnly: Bool
    public let readsSecretValue: Bool
    public let storesSecretValue: Bool
    public let connectsEndpoint: Bool

    public var namespaceKey: String {
        [
            pair.venueID.rawValue,
            pair.productKind.rawValue,
            tradingEnvironment.rawValue,
            profileID.rawValue
        ].joined(separator: "/")
    }

    public init(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        profileID: ReleaseV0181AccountProfileID,
        state: ReleaseV0190VenueCredentialProfileState,
        reason: String,
        redactedEvidenceReference: String,
        credentialIdentityOnly: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readsSecretValue: Bool = false,
        storesSecretValue: Bool = false,
        connectsEndpoint: Bool = false
    ) throws {
        try Self.validate(
            pair: pair,
            tradingEnvironment: tradingEnvironment,
            profileID: profileID,
            state: state,
            redactedEvidenceReference: redactedEvidenceReference,
            credentialIdentityOnly: credentialIdentityOnly,
            redactedEvidenceOnly: redactedEvidenceOnly,
            readsSecretValue: readsSecretValue,
            storesSecretValue: storesSecretValue,
            connectsEndpoint: connectsEndpoint
        )

        self.pair = pair
        self.tradingEnvironment = tradingEnvironment
        self.profileID = profileID
        self.state = state
        self.reason = reason
        self.redactedEvidenceReference = redactedEvidenceReference
        self.credentialIdentityOnly = credentialIdentityOnly
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.readsSecretValue = readsSecretValue
        self.storesSecretValue = storesSecretValue
        self.connectsEndpoint = connectsEndpoint
    }

    public static func validate(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        profileID: ReleaseV0181AccountProfileID,
        state: ReleaseV0190VenueCredentialProfileState,
        redactedEvidenceReference: String,
        credentialIdentityOnly: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readsSecretValue: Bool = false,
        storesSecretValue: Bool = false,
        connectsEndpoint: Bool = false
    ) throws {
        guard credentialIdentityOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.identityOnly",
                expected: "credential identity only",
                actual: "credentialIdentityOnly=false"
            )
        }
        guard redactedEvidenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.redactedEvidenceOnly",
                expected: "redacted evidence only",
                actual: "redactedEvidenceOnly=false"
            )
        }
        guard readsSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.credentialProfile.readsSecretValue")
        }
        guard storesSecretValue == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.credentialProfile.storesSecretValue")
        }
        guard connectsEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0190.credentialProfile.connectsEndpoint")
        }
        guard tradingEnvironment != .productionLive else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.environment",
                expected: "testnet or productionShadow; productionLive forbidden by default",
                actual: tradingEnvironment.rawValue
            )
        }
        guard ReleaseV0190VenueProductTargetRegistry.supportsPair(
            venueID: pair.venueID,
            productKind: pair.productKind
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.pair",
                expected: "binance/spot,binance/usdmFutures,okx/spot,okx/swap",
                actual: "\(pair.venueID.rawValue)/\(pair.productKind.rawValue)"
            )
        }
        guard expectedState(pair: pair, tradingEnvironment: tradingEnvironment) == state else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.state",
                expected: expectedState(pair: pair, tradingEnvironment: tradingEnvironment).rawValue,
                actual: state.rawValue
            )
        }
        guard expectedProfileID(pair: pair, tradingEnvironment: tradingEnvironment) == profileID.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.namespaceReuse",
                expected: expectedProfileID(pair: pair, tradingEnvironment: tradingEnvironment),
                actual: profileID.rawValue
            )
        }
        guard redactedEvidenceReference == expectedRedactedReference(
            pair: pair,
            tradingEnvironment: tradingEnvironment
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.redactedEvidenceReference",
                expected: expectedRedactedReference(pair: pair, tradingEnvironment: tradingEnvironment),
                actual: redactedEvidenceReference
            )
        }
    }

    public static func expectedProfileID(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> String {
        [
            pair.venueID.rawValue,
            pair.productKind.rawValue,
            tradingEnvironment.rawValue,
            "credential-profile-ref"
        ].joined(separator: "-")
    }

    public static func expectedRedactedReference(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> String {
        [
            "redacted-credential-profile",
            pair.venueID.rawValue,
            pair.productKind.rawValue,
            tradingEnvironment.rawValue
        ].joined(separator: ":")
    }

    public static func expectedState(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> ReleaseV0190VenueCredentialProfileState {
        switch (pair.venueID, pair.productKind, tradingEnvironment) {
        case (.binance, .spot, .testnet),
             (.binance, .usdmFutures, .testnet):
            .testnetReference
        case (.binance, .spot, .productionShadow),
             (.binance, .usdmFutures, .productionShadow):
            .productionShadow
        case (.okx, .spot, .testnet),
             (.okx, .spot, .productionShadow),
             (.okx, .swap, .testnet),
             (.okx, .swap, .productionShadow):
            .placeholder
        default:
            .forbidden
        }
    }
}

/// ReleaseV0190VenueCredentialProfileRegistry 固定 v0.19.0 的 credential profile registry。
///
/// Registry 覆盖 Binance Spot / USDⓈ-M Futures 和 OKX Spot / Swap 的 testnet 与
/// productionShadow identity row。所有 row 都是 redacted evidence only，productionLive
/// 默认 fail closed，跨 namespace profile reuse 也必须 fail closed。
public enum ReleaseV0190VenueCredentialProfileRegistry {
    public static let credentialIdentityOnly = true
    public static let redactedEvidenceOnly = true
    public static let productionSecretReadEnabled = false
    public static let productionTradingEnabledByDefault = false
    public static let productionEndpointConnectionEnabled = false
    public static let okxRuntimeImplemented = false

    public static let allEntries: [ReleaseV0190VenueCredentialProfileEntry] = [
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot), tradingEnvironment: .testnet),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .spot), tradingEnvironment: .productionShadow),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures), tradingEnvironment: .testnet),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .binance, productKind: .usdmFutures), tradingEnvironment: .productionShadow),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot), tradingEnvironment: .testnet),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .spot), tradingEnvironment: .productionShadow),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap), tradingEnvironment: .testnet),
        constantEntry(pair: ReleaseV0181VenueProductPair(venueID: .okx, productKind: .swap), tradingEnvironment: .productionShadow)
    ]

    public static func entry(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) throws -> ReleaseV0190VenueCredentialProfileEntry {
        guard tradingEnvironment != .productionLive else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.environment",
                expected: "testnet or productionShadow; productionLive forbidden by default",
                actual: tradingEnvironment.rawValue
            )
        }
        guard let entry = allEntries.first(where: {
            $0.pair == ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
                && $0.tradingEnvironment == tradingEnvironment
        }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.entry",
                expected: "credential profile entry for supported venue/product/environment",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)/\(tradingEnvironment.rawValue)"
            )
        }
        return entry
    }

    public static func requireTestnetCredentialReference(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> ReleaseV0190VenueCredentialProfileEntry {
        let entry = try entry(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: .testnet
        )
        guard entry.state == .testnetReference else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0190.credentialProfile.state",
                expected: ReleaseV0190VenueCredentialProfileState.testnetReference.rawValue,
                actual: "\(entry.state.rawValue): \(entry.reason)"
            )
        }
        return entry
    }

    private static func constantEntry(
        pair: ReleaseV0181VenueProductPair,
        tradingEnvironment: ReleaseV0181TradingEnvironment
    ) -> ReleaseV0190VenueCredentialProfileEntry {
        let state = ReleaseV0190VenueCredentialProfileEntry.expectedState(
            pair: pair,
            tradingEnvironment: tradingEnvironment
        )
        let reason: String = switch state {
        case .testnetReference:
            "\(pair.venueID.rawValue)/\(pair.productKind.rawValue) testnet credential profile identity only; no secret value is read"
        case .productionShadow:
            "\(pair.venueID.rawValue)/\(pair.productKind.rawValue) production shadow credential profile identity only; productionLive remains forbidden"
        case .placeholder:
            "\(pair.venueID.rawValue)/\(pair.productKind.rawValue) credential profile placeholder evidence only; no runtime adapter is implemented"
        case .forbidden:
            "forbidden credential profile namespace"
        }

        do {
            return try ReleaseV0190VenueCredentialProfileEntry(
                pair: pair,
                tradingEnvironment: tradingEnvironment,
                profileID: ReleaseV0181AccountProfileID(
                    ReleaseV0190VenueCredentialProfileEntry.expectedProfileID(
                        pair: pair,
                        tradingEnvironment: tradingEnvironment
                    )
                ),
                state: state,
                reason: reason,
                redactedEvidenceReference: ReleaseV0190VenueCredentialProfileEntry.expectedRedactedReference(
                    pair: pair,
                    tradingEnvironment: tradingEnvironment
                )
            )
        } catch {
            preconditionFailure("GH-1209 credential profile entry must be valid: \(error)")
        }
    }
}
