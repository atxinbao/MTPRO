import Crypto
import DomainModel
import Foundation

// GH-1067 静态合同边界：
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN
// TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN
// V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID
// V0151-006-REDACTED-CLIENT-ORDER-REFERENCE
// V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF
// V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED
// V0151-006-NO-PRODUCTION-CUTOVER

/// ReleaseV0150BinanceSpotTestnetCredentialProviderKind 描述 v0.15.0 允许的 testnet credential 引用来源。
///
/// 该枚举只表达 reference source，不读取环境变量、keychain 或 production secret。真实 secret
/// 只能由调用方以短生命周期 material 注入，且不得写入 evidence、日志、Dashboard 或文档。
public enum ReleaseV0150BinanceSpotTestnetCredentialProviderKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case operatorProvidedReference = "operatorProvidedReference"
    case testnetEnvironmentReference = "testnetEnvironmentReference"
}

/// ReleaseV0150BinanceSpotTestnetCredentialReference 是 GH-1067 的 credential identity gate。
///
/// 它只保存可审计 reference ID 和 provider kind；secret value、API key value、production secret reader
/// 和 broker endpoint 都被明确排除。后续 submit runtime 只能消费该 redacted reference 与短生命周期
/// material，不能把 material 序列化进 request evidence。
public struct ReleaseV0150BinanceSpotTestnetCredentialReference: Codable, Equatable, Sendable, CustomStringConvertible {
    public let referenceID: Identifier
    public let providerKind: ReleaseV0150BinanceSpotTestnetCredentialProviderKind
    public let redactionPolicy: String
    public let operatorConfirmationRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionSecretValueRead: Bool
    public let productionSecretValueStored: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let secretValuePrinted: Bool

    public init(
        referenceID: Identifier,
        providerKind: ReleaseV0150BinanceSpotTestnetCredentialProviderKind,
        redactionPolicy: String = Self.requiredRedactionPolicy,
        operatorConfirmationRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionSecretValueRead: Bool = false,
        productionSecretValueStored: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        secretValuePrinted: Bool = false
    ) throws {
        guard redactionPolicy == Self.requiredRedactionPolicy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialReference.redactionPolicy",
                expected: Self.requiredRedactionPolicy,
                actual: redactionPolicy
            )
        }
        guard operatorConfirmationRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialReference.operatorConfirmationRequired",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionSecretValueRead, "productionSecretValueRead")
        try Self.forbid(productionSecretValueStored, "productionSecretValueStored")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(secretValuePrinted, "secretValuePrinted")

        self.referenceID = referenceID
        self.providerKind = providerKind
        self.redactionPolicy = redactionPolicy
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionSecretValueRead = productionSecretValueRead
        self.productionSecretValueStored = productionSecretValueStored
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.secretValuePrinted = secretValuePrinted
    }

    public var boundaryHeld: Bool {
        redactionPolicy == Self.requiredRedactionPolicy
            && operatorConfirmationRequired
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionSecretValueRead == false
            && productionSecretValueStored == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && secretValuePrinted == false
    }

    public var redactedDescription: String {
        "\(referenceID.rawValue):<redacted>"
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCredentialReference(referenceID: \(redactedDescription), providerKind: \(providerKind.rawValue), redactionPolicy: \(redactionPolicy))"
    }

    public static let requiredRedactionPolicy = "redactedIdentifierOnly"

    public static func deterministicFixture(
        referenceID: Identifier = .constant("gh-1067-binance-spot-testnet-credential")
    ) throws -> ReleaseV0150BinanceSpotTestnetCredentialReference {
        try ReleaseV0150BinanceSpotTestnetCredentialReference(
            referenceID: referenceID,
            providerKind: .operatorProvidedReference
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.credentialReference.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCredentialMaterial 是签名时短生命周期进入内存的 testnet material。
///
/// 该类型不实现 Codable，避免 API key / secret 被持久化。`binanceAPIKeyHeaderValue()` 只服务后续
/// transport handoff；GH-1067 的 signed request evidence 不会保存该 header value。
public struct ReleaseV0150BinanceSpotTestnetCredentialMaterial: Sendable, CustomStringConvertible {
    public let reference: ReleaseV0150BinanceSpotTestnetCredentialReference
    private let apiKeyHeaderValue: String
    private let signingSecretValue: String

    public init(
        reference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        apiKeyHeaderValue: String,
        signingSecretValue: String
    ) throws {
        guard reference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.credentialMaterial.reference")
        }

        let trimmedHeader = apiKeyHeaderValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecret = signingSecretValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedHeader.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialMaterial.apiKeyHeaderValue",
                expected: "non-empty testnet API key header",
                actual: "empty"
            )
        }
        guard trimmedSecret.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.credentialMaterial.signingSecretValue",
                expected: "non-empty testnet signing secret",
                actual: "empty"
            )
        }

        self.reference = reference
        self.apiKeyHeaderValue = trimmedHeader
        self.signingSecretValue = trimmedSecret
    }

    public func binanceAPIKeyHeaderValue() -> String {
        apiKeyHeaderValue
    }

    public func signature(for canonicalQueryString: String) -> String {
        let key = SymmetricKey(data: Data(signingSecretValue.utf8))
        let signature = HMAC<SHA256>.authenticationCode(
            for: Data(canonicalQueryString.utf8),
            using: key
        )
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCredentialMaterial(reference: \(reference.redactedDescription), apiKeyHeaderValue: <redacted>, signingSecretValue: <redacted>)"
    }
}

/// ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference 是 v0.15.1 的 deterministic client order 引用。
///
/// 它只保存由 signed request identity 派生的 redacted/hash 证据。真实 `newClientOrderId`
/// 只允许通过 `ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial` 在内存中短生命周期重建，
/// 不进入 Codable evidence、文档、日志或 Dashboard surface。
public struct ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference: Codable, Equatable, Sendable, CustomStringConvertible {
    public let referenceID: Identifier
    public let sourceSignedRequestID: Identifier
    public let redactedClientOrderIDHash: String
    public let redactionPolicy: String
    public let clientOrderIdentityMaterialStored: Bool
    public let exchangeOrderIDStored: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case referenceID
        case sourceSignedRequestID
        case redactedClientOrderIDHash
        case redactionPolicy
        case clientOrderIdentityMaterialStored
        case exchangeOrderIDStored
        case productionTradingEnabledByDefault
        case productionSecretAutoRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }

    public init(
        referenceID: Identifier,
        sourceSignedRequestID: Identifier,
        redactedClientOrderIDHash: String,
        redactionPolicy: String = Self.requiredRedactionPolicy,
        clientOrderIdentityMaterialStored: Bool = false,
        exchangeOrderIDStored: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard referenceID == Self.deterministicID(sourceSignedRequestID: sourceSignedRequestID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetClientOrderIdentity.referenceID",
                expected: Self.deterministicID(sourceSignedRequestID: sourceSignedRequestID).rawValue,
                actual: referenceID.rawValue
            )
        }
        guard redactedClientOrderIDHash == Self.redactedHash(
            for: ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.deterministicNewClientOrderID(
                sourceSignedRequestID: sourceSignedRequestID
            )
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetClientOrderIdentity.hash",
                expected: Self.redactedHash(
                    for: ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.deterministicNewClientOrderID(
                        sourceSignedRequestID: sourceSignedRequestID
                    )
                ),
                actual: redactedClientOrderIDHash
            )
        }
        guard redactionPolicy == Self.requiredRedactionPolicy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetClientOrderIdentity.redactionPolicy",
                expected: Self.requiredRedactionPolicy,
                actual: redactionPolicy
            )
        }
        try Self.forbid(clientOrderIdentityMaterialStored, "clientOrderIdentityMaterialStored")
        try Self.forbid(exchangeOrderIDStored, "exchangeOrderIDStored")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.referenceID = referenceID
        self.sourceSignedRequestID = sourceSignedRequestID
        self.redactedClientOrderIDHash = redactedClientOrderIDHash
        self.redactionPolicy = redactionPolicy
        self.clientOrderIdentityMaterialStored = clientOrderIdentityMaterialStored
        self.exchangeOrderIDStored = exchangeOrderIDStored
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.referenceID = try container.decode(Identifier.self, forKey: .referenceID)
        self.sourceSignedRequestID = try container.decode(Identifier.self, forKey: .sourceSignedRequestID)
        self.redactedClientOrderIDHash = try container.decode(String.self, forKey: .redactedClientOrderIDHash)
        self.redactionPolicy = try container.decode(String.self, forKey: .redactionPolicy)
        self.clientOrderIdentityMaterialStored = try container.decode(Bool.self, forKey: .clientOrderIdentityMaterialStored)
        self.exchangeOrderIDStored = try container.decode(Bool.self, forKey: .exchangeOrderIDStored)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretAutoRead = try container.decode(Bool.self, forKey: .productionSecretAutoRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)

        let expectedReferenceID = Self.deterministicID(sourceSignedRequestID: sourceSignedRequestID)
        try ReleaseV0151CodableDecodeBoundary.require(
            referenceID == expectedReferenceID,
            field: "releaseV0151ClientOrderIdentityReference.referenceID",
            expected: expectedReferenceID.rawValue,
            actual: referenceID.rawValue
        )
        let expectedHash = Self.redactedHash(
            for: ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.deterministicNewClientOrderID(
                sourceSignedRequestID: sourceSignedRequestID
            )
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            redactedClientOrderIDHash == expectedHash,
            field: "releaseV0151ClientOrderIdentityReference.redactedClientOrderIDHash",
            expected: expectedHash,
            actual: redactedClientOrderIDHash
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0151ClientOrderIdentityReference.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        redactionPolicy == Self.requiredRedactionPolicy
            && redactedClientOrderIDHash.count == 64
            && clientOrderIdentityMaterialStored == false
            && exchangeOrderIDStored == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var redactedDescription: String {
        "\(referenceID.rawValue):sha256:\(redactedClientOrderIDHash.prefix(12)):<redacted>"
    }

    public var description: String {
        "ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference(referenceID: \(redactedDescription), sourceSignedRequestID: \(sourceSignedRequestID.rawValue), clientOrderIdentity: <redacted>)"
    }

    public static let requiredRedactionPolicy = "deterministicClientOrderIDReferenceOnly"
    public static let requiredValidationAnchors = [
        "GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN",
        "TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN",
        "V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID",
        "V0151-006-REDACTED-CLIENT-ORDER-REFERENCE",
        "V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF",
        "V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED",
        "V0151-006-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(sourceSignedRequestID: Identifier) -> Identifier {
        .constant(
            "gh-1099-v0151-client-order-reference:\(sourceSignedRequestID.rawValue)",
            field: "releaseV0151SpotTestnetClientOrderIdentity.referenceID"
        )
    }

    public static func redactedHash(for clientOrderID: String) -> String {
        let digest = SHA256.hash(data: Data("gh-1099-client-order-id:\(clientOrderID)".utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetClientOrderIdentity.\(field)")
        }
    }
}

/// ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial 是短生命周期 `newClientOrderId` material。
///
/// 该类型故意不实现 Codable。真实 client order id 只在 signed submit query 和后续 cancel handoff
/// 需要时由 deterministic source signed request id 重建；持久 evidence 只保存 reference 和 hash。
public struct ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial: Sendable, CustomStringConvertible {
    public let reference: ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference
    private let newClientOrderID: String

    public init(
        reference: ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference,
        newClientOrderID: String
    ) throws {
        guard reference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151SpotTestnetClientOrderIdentityMaterial.reference")
        }
        let trimmed = newClientOrderID.trimmingCharacters(in: .whitespacesAndNewlines)
        let expected = Self.deterministicNewClientOrderID(sourceSignedRequestID: reference.sourceSignedRequestID)
        guard trimmed == expected else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetClientOrderIdentityMaterial.newClientOrderID",
                expected: expected,
                actual: trimmed.isEmpty ? "empty" : "<redacted-mismatch>"
            )
        }
        guard reference.redactedClientOrderIDHash == ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference.redactedHash(for: trimmed) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0151SpotTestnetClientOrderIdentityMaterial.hash",
                expected: reference.redactedClientOrderIDHash,
                actual: ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference.redactedHash(for: trimmed)
            )
        }

        self.reference = reference
        self.newClientOrderID = trimmed
    }

    public func binanceNewClientOrderID() -> String {
        newClientOrderID
    }

    public var description: String {
        "ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial(reference: \(reference.redactedDescription), newClientOrderID: <redacted>)"
    }

    public static func deterministicNewClientOrderID(sourceSignedRequestID: Identifier) -> String {
        let digest = SHA256.hash(data: Data("gh-1099-v0151-new-client-order-id:\(sourceSignedRequestID.rawValue)".utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "mtp\(digest.prefix(32))"
    }

    public static func derived(sourceSignedRequestID: Identifier) throws -> ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial {
        let newClientOrderID = deterministicNewClientOrderID(sourceSignedRequestID: sourceSignedRequestID)
        let reference = try ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference(
            referenceID: ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference.deterministicID(
                sourceSignedRequestID: sourceSignedRequestID
            ),
            sourceSignedRequestID: sourceSignedRequestID,
            redactedClientOrderIDHash: ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference.redactedHash(
                for: newClientOrderID
            )
        )
        return try ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial(
            reference: reference,
            newClientOrderID: newClientOrderID
        )
    }
}

/// ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence 记录 GH-1067 的签名请求构造结果。
///
/// Evidence 只证明 Binance Spot Testnet `/api/v3/order` 的 canonical query 和 signature 构造正确。
/// 它不保存 API key / secret，不创建 URLRequest，不发送网络请求，也不授权 production order。
public struct ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence: Codable, Equatable, Sendable, CustomStringConvertible {
    public let requestID: Identifier
    public let credentialReferenceID: Identifier
    public let credentialReferenceRedacted: String
    public let productType: ProductType
    public let symbol: Symbol
    public let side: OrderIntentSide
    public let orderType: String
    public let quantityText: String
    public let timestampMilliseconds: Int64
    public let receiveWindowMilliseconds: Int
    public let httpMethod: String
    public let endpointHost: String
    public let endpointPath: String
    public let unsignedQueryString: String
    public let signature: String
    public let signedQueryString: String
    public let signedQueryStringRedacted: Bool
    public let redactedUnsignedQueryDigest: String
    public let clientOrderIdentityReferenceID: Identifier
    public let redactedClientOrderIDHash: String
    public let clientOrderIdentityMaterialRedacted: Bool
    public let clientOrderIdentityMaterialStored: Bool
    public let apiKeyHeaderName: String
    public let apiKeyHeaderValueRedacted: Bool
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let networkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    private enum CodingKeys: String, CodingKey {
        case requestID
        case credentialReferenceID
        case credentialReferenceRedacted
        case productType
        case symbol
        case side
        case orderType
        case quantityText
        case timestampMilliseconds
        case receiveWindowMilliseconds
        case httpMethod
        case endpointHost
        case endpointPath
        case unsignedQueryString
        case signature
        case signedQueryString
        case signedQueryStringRedacted
        case redactedUnsignedQueryDigest
        case clientOrderIdentityReferenceID
        case redactedClientOrderIDHash
        case clientOrderIdentityMaterialRedacted
        case clientOrderIdentityMaterialStored
        case apiKeyHeaderName
        case apiKeyHeaderValueRedacted
        case explicitTestnetMode
        case spotTestnetOnly
        case requestBodyRedacted
        case credentialMaterialRedacted
        case networkSubmitPerformed
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case validationAnchors
    }

    public init(
        requestID: Identifier,
        credentialReference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        productType: ProductType,
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int,
        unsignedQueryString: String,
        signature: String,
        clientOrderIdentity: ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial? = nil,
        redactedUnsignedQueryDigest: String? = nil,
        signedQueryStringRedacted: Bool = true,
        clientOrderIdentityMaterialRedacted: Bool = true,
        clientOrderIdentityMaterialStored: Bool = false,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        networkSubmitPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard credentialReference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.unheldCredentialReference")
        }
        guard productType == Self.requiredProductType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.productType",
                expected: Self.requiredProductType.rawValue,
                actual: productType.rawValue
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.quantity",
                expected: "positive Spot Testnet order quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard timestampMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.timestampMilliseconds",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds)"
            )
        }
        guard receiveWindowMilliseconds > 0, receiveWindowMilliseconds <= 60_000 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.receiveWindowMilliseconds",
                expected: "1...60000",
                actual: "\(receiveWindowMilliseconds)"
            )
        }
        guard signature.count == 64, signature.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.signature",
                expected: "64 lowercase hex characters",
                actual: signature
            )
        }
        let resolvedClientOrderIdentity = try clientOrderIdentity
            ?? ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.derived(sourceSignedRequestID: requestID)
        let expectedRawQuery = ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.unsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantity: quantity,
            newClientOrderID: resolvedClientOrderIdentity.binanceNewClientOrderID(),
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let expectedRedactedQuery = ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.redactedUnsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantity: quantity,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let expectedDigest = ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.redactedUnsignedQueryDigest(for: expectedRawQuery)
        guard unsignedQueryString == expectedRedactedQuery,
              redactedUnsignedQueryDigest ?? expectedDigest == expectedDigest,
              resolvedClientOrderIdentity.reference.sourceSignedRequestID == requestID,
              resolvedClientOrderIdentity.reference.redactedClientOrderIDHash == ReleaseV0151BinanceSpotTestnetClientOrderIdentityReference.redactedHash(
                  for: resolvedClientOrderIdentity.binanceNewClientOrderID()
              ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.clientOrderIdentity",
                expected: "redacted deterministic newClientOrderId evidence linked to signed request",
                actual: unsignedQueryString
            )
        }
        guard explicitTestnetMode,
              spotTestnetOnly,
              requestBodyRedacted,
              credentialMaterialRedacted,
              signedQueryStringRedacted,
              clientOrderIdentityMaterialRedacted,
              clientOrderIdentityMaterialStored == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.unredactedOrNonTestnetEvidence")
        }
        try Self.forbid(networkSubmitPerformed, "networkSubmitPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.requestID = requestID
        self.credentialReferenceID = credentialReference.referenceID
        self.credentialReferenceRedacted = credentialReference.redactedDescription
        self.productType = productType
        self.symbol = symbol
        self.side = side
        self.orderType = Self.marketOrderType
        self.quantityText = Self.quantityText(quantity)
        self.timestampMilliseconds = timestampMilliseconds
        self.receiveWindowMilliseconds = receiveWindowMilliseconds
        self.httpMethod = Self.httpMethod
        self.endpointHost = Self.canonicalSpotTestnetHost
        self.endpointPath = Self.spotOrderEndpointPath
        self.unsignedQueryString = unsignedQueryString
        self.signature = signature
        self.signedQueryString = "\(unsignedQueryString)&signature=<redacted>"
        self.signedQueryStringRedacted = signedQueryStringRedacted
        self.redactedUnsignedQueryDigest = expectedDigest
        self.clientOrderIdentityReferenceID = resolvedClientOrderIdentity.reference.referenceID
        self.redactedClientOrderIDHash = resolvedClientOrderIdentity.reference.redactedClientOrderIDHash
        self.clientOrderIdentityMaterialRedacted = clientOrderIdentityMaterialRedacted
        self.clientOrderIdentityMaterialStored = clientOrderIdentityMaterialStored
        self.apiKeyHeaderName = Self.apiKeyHeaderName
        self.apiKeyHeaderValueRedacted = true
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.networkSubmitPerformed = networkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestID = try container.decode(Identifier.self, forKey: .requestID)
        self.credentialReferenceID = try container.decode(Identifier.self, forKey: .credentialReferenceID)
        self.credentialReferenceRedacted = try container.decode(String.self, forKey: .credentialReferenceRedacted)
        self.productType = try container.decode(ProductType.self, forKey: .productType)
        self.symbol = try container.decode(Symbol.self, forKey: .symbol)
        self.side = try container.decode(OrderIntentSide.self, forKey: .side)
        self.orderType = try container.decode(String.self, forKey: .orderType)
        self.quantityText = try container.decode(String.self, forKey: .quantityText)
        self.timestampMilliseconds = try container.decode(Int64.self, forKey: .timestampMilliseconds)
        self.receiveWindowMilliseconds = try container.decode(Int.self, forKey: .receiveWindowMilliseconds)
        self.httpMethod = try container.decode(String.self, forKey: .httpMethod)
        self.endpointHost = try container.decode(String.self, forKey: .endpointHost)
        self.endpointPath = try container.decode(String.self, forKey: .endpointPath)
        self.unsignedQueryString = try container.decode(String.self, forKey: .unsignedQueryString)
        self.signature = try container.decode(String.self, forKey: .signature)
        self.signedQueryString = try container.decode(String.self, forKey: .signedQueryString)
        self.signedQueryStringRedacted = try container.decode(Bool.self, forKey: .signedQueryStringRedacted)
        self.redactedUnsignedQueryDigest = try container.decode(String.self, forKey: .redactedUnsignedQueryDigest)
        self.clientOrderIdentityReferenceID = try container.decode(Identifier.self, forKey: .clientOrderIdentityReferenceID)
        self.redactedClientOrderIDHash = try container.decode(String.self, forKey: .redactedClientOrderIDHash)
        self.clientOrderIdentityMaterialRedacted = try container.decode(Bool.self, forKey: .clientOrderIdentityMaterialRedacted)
        self.clientOrderIdentityMaterialStored = try container.decode(Bool.self, forKey: .clientOrderIdentityMaterialStored)
        self.apiKeyHeaderName = try container.decode(String.self, forKey: .apiKeyHeaderName)
        self.apiKeyHeaderValueRedacted = try container.decode(Bool.self, forKey: .apiKeyHeaderValueRedacted)
        self.explicitTestnetMode = try container.decode(Bool.self, forKey: .explicitTestnetMode)
        self.spotTestnetOnly = try container.decode(Bool.self, forKey: .spotTestnetOnly)
        self.requestBodyRedacted = try container.decode(Bool.self, forKey: .requestBodyRedacted)
        self.credentialMaterialRedacted = try container.decode(Bool.self, forKey: .credentialMaterialRedacted)
        self.networkSubmitPerformed = try container.decode(Bool.self, forKey: .networkSubmitPerformed)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretRead = try container.decode(Bool.self, forKey: .productionSecretRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        self.validationAnchors = try container.decode([String].self, forKey: .validationAnchors)

        let expectedRequestID = Self.deterministicID(
            credentialReferenceID: credentialReferenceID,
            symbol: symbol,
            side: side,
            timestampMilliseconds: timestampMilliseconds
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            requestID == expectedRequestID,
            field: "releaseV0150SignedRequest.requestID",
            expected: expectedRequestID.rawValue,
            actual: requestID.rawValue
        )
        let expectedUnsignedQuery = [
            "symbol=\(symbol.rawValue)",
            "side=\(side.rawValue.uppercased())",
            "type=\(Self.marketOrderType)",
            "quantity=\(quantityText)",
            "newClientOrderId=<redacted>",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
        try ReleaseV0151CodableDecodeBoundary.require(
            unsignedQueryString == expectedUnsignedQuery,
            field: "releaseV0150SignedRequest.unsignedQueryString",
            expected: expectedUnsignedQuery,
            actual: unsignedQueryString
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            signedQueryString == "\(unsignedQueryString)&signature=<redacted>",
            field: "releaseV0150SignedRequest.signedQueryString",
            expected: "redacted signed query string",
            actual: signedQueryString
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.isLowercaseSHA256(signature)
                && ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.isLowercaseSHA256(redactedUnsignedQueryDigest)
                && ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.isLowercaseSHA256(redactedClientOrderIDHash),
            field: "releaseV0150SignedRequest.hashFields",
            expected: "lowercase sha256 evidence",
            actual: "signature=\(signature.count):digest=\(redactedUnsignedQueryDigest.count):clientOrder=\(redactedClientOrderIDHash.count)"
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SignedRequest.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        productType == Self.requiredProductType
            && orderType == Self.marketOrderType
            && httpMethod == Self.httpMethod
            && endpointHost == Self.canonicalSpotTestnetHost
            && endpointPath == Self.spotOrderEndpointPath
            && apiKeyHeaderName == Self.apiKeyHeaderName
            && apiKeyHeaderValueRedacted
            && signedQueryStringRedacted
            && redactedUnsignedQueryDigest.count == 64
            && clientOrderIdentityReferenceID.rawValue.hasPrefix("gh-1099-v0151-client-order-reference:")
            && redactedClientOrderIDHash.count == 64
            && clientOrderIdentityMaterialRedacted
            && clientOrderIdentityMaterialStored == false
            && explicitTestnetMode
            && spotTestnetOnly
            && requestBodyRedacted
            && credentialMaterialRedacted
            && networkSubmitPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && signedQueryString == "\(unsignedQueryString)&signature=<redacted>"
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence(requestID: \(requestID.rawValue), credentialReference: \(credentialReferenceRedacted), endpoint: \(endpointHost)\(endpointPath), apiKeyHeaderValue: <redacted>, credentialMaterial: <redacted>, networkSubmitPerformed: \(networkSubmitPerformed))"
    }

    public static let requiredProductType: ProductType = .spot
    public static let canonicalSpotTestnetHost = "testnet.binance.vision"
    public static let spotOrderEndpointPath = "/api/v3/order"
    public static let httpMethod = "POST"
    public static let marketOrderType = "MARKET"
    public static let apiKeyHeaderName = "X-MBX-APIKEY"
    public static let requiredValidationAnchors = [
        "GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST",
        "TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST",
        "V0150-002-CREDENTIAL-REFERENCE",
        "V0150-002-HMAC-SHA256-SIGNED-REQUEST",
        "V0150-002-BINANCE-SPOT-TESTNET-ONLY",
        "V0150-002-NO-PRODUCTION-SECRET-AUTO-READ",
        "V0150-002-PRODUCTION-ENDPOINT-BLOCKED",
        "V0150-002-REDACTED-EVIDENCE",
        "V0150-002-NO-NETWORK-ACTION"
    ]

    public static func deterministicID(
        credentialReferenceID: Identifier,
        symbol: Symbol,
        side: OrderIntentSide,
        timestampMilliseconds: Int64
    ) -> Identifier {
        .constant(
            "gh-1067-binance-spot-testnet-signed-request:\(credentialReferenceID.rawValue):\(symbol.rawValue):\(side.rawValue):\(timestampMilliseconds)",
            field: "releaseV0150SignedRequest.requestID"
        )
    }

    public static func quantityText(_ quantity: Quantity) -> String {
        String(format: "%.8f", locale: Locale(identifier: "en_US_POSIX"), quantity.rawValue)
    }

    public func binanceUnsignedQueryStringForTransport() -> String {
        let material = ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.deterministicNewClientOrderID(
            sourceSignedRequestID: requestID
        )
        return ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.unsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantityText: quantityText,
            newClientOrderID: material,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
    }

    public func binanceSignedQueryStringForTransport() -> String {
        "\(binanceUnsignedQueryStringForTransport())&signature=\(signature)"
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.evidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetSignedRequestBuilder 构造 GH-1067 的 Spot Testnet signed request evidence。
///
/// Builder 只接受 canonical `https://testnet.binance.vision` 和 `/api/v3/order`。它不创建
/// URLRequest、不调用 URLSession、不读取 secret store，也不把 Binance Spot Testnet 扩大到
/// USDⓈ-M Perpetual 或 production endpoint。
public struct ReleaseV0150BinanceSpotTestnetSignedRequestBuilder: Equatable, Sendable {
    public let baseURL: URL
    public let productType: ProductType
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool

    public init(
        baseURL: URL? = nil,
        productType: ProductType = .spot,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false
    ) throws {
        let resolvedBaseURL = try baseURL ?? Self.canonicalBaseURL()
        guard explicitTestnetMode, spotTestnetOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.nonTestnetMode")
        }
        guard productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.productType",
                expected: ProductType.spot.rawValue,
                actual: productType.rawValue
            )
        }
        try Self.validateCanonicalBaseURL(resolvedBaseURL)
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")

        self.baseURL = resolvedBaseURL
        self.productType = productType
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && explicitTestnetMode
            && spotTestnetOnly
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && baseURL.scheme?.lowercased() == "https"
            && baseURL.host?.lowercased() == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && (baseURL.path.isEmpty || baseURL.path == "/")
            && baseURL.query == nil
            && baseURL.fragment == nil
            && baseURL.user == nil
            && baseURL.password == nil
    }

    public func buildMarketSubmitRequest(
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestamp: Date,
        receiveWindowMilliseconds: Int = 5_000
    ) throws -> ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.boundary")
        }
        let timestampMilliseconds = try Self.timestampMilliseconds(timestamp)
        let requestID = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.deterministicID(
            credentialReferenceID: credential.reference.referenceID,
            symbol: symbol,
            side: side,
            timestampMilliseconds: timestampMilliseconds
        )
        let clientOrderIdentity = try ReleaseV0151BinanceSpotTestnetClientOrderIdentityMaterial.derived(
            sourceSignedRequestID: requestID
        )
        let unsignedQueryString = Self.unsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantity: quantity,
            newClientOrderID: clientOrderIdentity.binanceNewClientOrderID(),
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let signature = credential.signature(for: unsignedQueryString)

        return try ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence(
            requestID: requestID,
            credentialReference: credential.reference,
            productType: productType,
            symbol: symbol,
            side: side,
            quantity: quantity,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds,
            unsignedQueryString: Self.redactedUnsignedMarketOrderQueryString(
                symbol: symbol,
                side: side,
                quantity: quantity,
                timestampMilliseconds: timestampMilliseconds,
                receiveWindowMilliseconds: receiveWindowMilliseconds
            ),
            signature: signature,
            clientOrderIdentity: clientOrderIdentity,
            redactedUnsignedQueryDigest: Self.redactedUnsignedQueryDigest(for: unsignedQueryString)
        )
    }

    public static func canonicalBaseURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
        guard let url = components.url else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.canonicalBaseURL",
                expected: "https://testnet.binance.vision",
                actual: "unconstructable"
            )
        }
        return url
    }

    public static func unsignedMarketOrderQueryString(
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        newClientOrderID: String,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        unsignedMarketOrderQueryString(
            symbol: symbol,
            side: side,
            quantityText: ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.quantityText(quantity),
            newClientOrderID: newClientOrderID,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
    }

    public static func unsignedMarketOrderQueryString(
        symbol: Symbol,
        side: OrderIntentSide,
        quantityText: String,
        newClientOrderID: String,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        [
            "symbol=\(symbol.rawValue)",
            "side=\(side.rawValue.uppercased())",
            "type=\(ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.marketOrderType)",
            "quantity=\(quantityText)",
            "newClientOrderId=\(newClientOrderID)",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
    }

    public static func redactedUnsignedMarketOrderQueryString(
        symbol: Symbol,
        side: OrderIntentSide,
        quantity: Quantity,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        [
            "symbol=\(symbol.rawValue)",
            "side=\(side.rawValue.uppercased())",
            "type=\(ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.marketOrderType)",
            "quantity=\(ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.quantityText(quantity))",
            "newClientOrderId=<redacted>",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
    }

    public static func redactedUnsignedQueryDigest(for unsignedQueryString: String) -> String {
        let digest = SHA256.hash(data: Data("gh-1099-redacted-submit-query:\(unsignedQueryString)".utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static let forbiddenProductionHosts: Set<String> = [
        "api.binance.com",
        "fapi.binance.com",
        "dapi.binance.com"
    ]

    private static func validateCanonicalBaseURL(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.baseURL",
                expected: "https://testnet.binance.vision",
                actual: url.absoluteString
            )
        }
        let host = components.host?.lowercased() ?? ""
        guard forbiddenProductionHosts.contains(host) == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.productionHost")
        }
        guard components.scheme?.lowercased() == "https",
              host == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost,
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.percentEncodedPath.isEmpty,
              components.percentEncodedQuery == nil,
              components.percentEncodedFragment == nil else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.baseURL",
                expected: "https://testnet.binance.vision",
                actual: url.absoluteString
            )
        }
    }

    private static func timestampMilliseconds(_ timestamp: Date) throws -> Int64 {
        guard timestamp.timeIntervalSince1970.isFinite, timestamp.timeIntervalSince1970 > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SignedRequest.builder.timestamp",
                expected: "positive unix timestamp",
                actual: "\(timestamp)"
            )
        }
        return Int64((timestamp.timeIntervalSince1970 * 1_000).rounded())
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SignedRequest.builder.\(field)")
        }
    }
}
