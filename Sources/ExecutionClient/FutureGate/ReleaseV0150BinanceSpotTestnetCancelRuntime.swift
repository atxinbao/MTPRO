import Crypto
import DomainModel
import Foundation

// GH-1069 static contract boundary:
// endpointHost=testnet.binance.vision
// endpointPath=/api/v3/order
// httpMethod=DELETE
// testnetNetworkCancelPerformed=true
// appendOnlyCancelEvidenceCreated=true
// omsStateTransitionIntegrated=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference records the redacted testnet order identity handle.
///
/// The reference is derived from prior #1068 submit runtime evidence. It deliberately does not store the
/// original client order ID or exchange order ID; those values can only enter the runtime as short-lived
/// non-Codable material and must not be persisted in docs, logs, Dashboard state, or event artifacts.
public struct ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference: Codable, Equatable, Sendable, CustomStringConvertible {
    public let referenceID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let intentID: Identifier
    public let redactionPolicy: String
    public let orderIdentityMaterialStored: Bool
    public let exchangeOrderIDStored: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        referenceID: Identifier,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        redactionPolicy: String = Self.requiredRedactionPolicy,
        orderIdentityMaterialStored: Bool = false,
        exchangeOrderIDStored: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.productType == .spot,
              sourceSubmitEvidence.orderLifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.orderIdentity.sourceSubmitEvidence")
        }
        guard redactionPolicy == Self.requiredRedactionPolicy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.orderIdentity.redactionPolicy",
                expected: Self.requiredRedactionPolicy,
                actual: redactionPolicy
            )
        }
        guard referenceID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.orderIdentity.referenceID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
                ).rawValue,
                actual: referenceID.rawValue
            )
        }
        try Self.forbid(orderIdentityMaterialStored, "orderIdentityMaterialStored")
        try Self.forbid(exchangeOrderIDStored, "exchangeOrderIDStored")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.referenceID = referenceID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.intentID = sourceSubmitEvidence.intentID
        self.redactionPolicy = redactionPolicy
        self.orderIdentityMaterialStored = orderIdentityMaterialStored
        self.exchangeOrderIDStored = exchangeOrderIDStored
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        redactionPolicy == Self.requiredRedactionPolicy
            && orderIdentityMaterialStored == false
            && exchangeOrderIDStored == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var redactedDescription: String {
        "\(referenceID.rawValue):<redacted>"
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference(referenceID: \(redactedDescription), sourceSubmitRuntimeEvidenceID: \(sourceSubmitRuntimeEvidenceID.rawValue), orderIdentity: <redacted>)"
    }

    public static let requiredRedactionPolicy = "testnetOrderIdentityReferenceOnly"

    public static func deterministicID(sourceSubmitRuntimeEvidenceID: Identifier) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-order-identity:\(sourceSubmitRuntimeEvidenceID.rawValue)",
            field: "releaseV0150SpotTestnetCancel.orderIdentity.referenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.orderIdentity.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial is the short-lived cancel identity material.
///
/// This type is intentionally not Codable. It is passed only to the injected testnet transport so a real
/// Spot Testnet cancel request can be sent while persisted evidence keeps only redacted references.
public struct ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial: Sendable, CustomStringConvertible {
    public let reference: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference
    private let originalClientOrderID: String

    public init(
        reference: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference,
        originalClientOrderID: String
    ) throws {
        guard reference.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.orderIdentityMaterial.reference")
        }
        let trimmedOrderID = originalClientOrderID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedOrderID.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.orderIdentityMaterial.originalClientOrderID",
                expected: "non-empty Binance Spot Testnet order identity",
                actual: "empty"
            )
        }

        self.reference = reference
        self.originalClientOrderID = trimmedOrderID
    }

    public func binanceOriginalClientOrderID() -> String {
        originalClientOrderID
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial(reference: \(reference.redactedDescription), originalClientOrderID: <redacted>)"
    }
}

/// ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence records the redacted signed cancel request.
///
/// It proves that the runtime constructed a Binance Spot Testnet DELETE order request from prior submit
/// evidence, credential reference, redacted order identity reference, timestamp, recvWindow and HMAC
/// signature. It does not store the raw original client order ID or the full signed query string.
public struct ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence: Codable, Equatable, Sendable, CustomStringConvertible {
    public let requestID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let intentID: Identifier
    public let credentialReferenceID: Identifier
    public let credentialReferenceRedacted: String
    public let cancelOrderIdentityReferenceID: Identifier
    public let cancelOrderIdentityReferenceRedacted: String
    public let productType: ProductType
    public let symbol: Symbol
    public let timestampMilliseconds: Int64
    public let receiveWindowMilliseconds: Int
    public let httpMethod: String
    public let endpointHost: String
    public let endpointPath: String
    public let redactedUnsignedQueryDigest: String
    public let signature: String
    public let signedQueryStringRedacted: Bool
    public let apiKeyHeaderName: String
    public let apiKeyHeaderValueRedacted: Bool
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let orderIdentityMaterialRedacted: Bool
    public let networkCancelPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        requestID: Identifier,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        credentialReference: ReleaseV0150BinanceSpotTestnetCredentialReference,
        cancelOrderIdentityReference: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference,
        symbol: Symbol,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int,
        redactedUnsignedQueryDigest: String,
        signature: String,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        signedQueryStringRedacted: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        orderIdentityMaterialRedacted: Bool = true,
        networkCancelPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.productType == .spot,
              sourceSubmitEvidence.orderLifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.signedRequest.sourceSubmitEvidence")
        }
        guard credentialReference.boundaryHeld,
              credentialReference.referenceID == sourceSubmitEvidence.credentialReferenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.credentialReference",
                expected: sourceSubmitEvidence.credentialReferenceID.rawValue,
                actual: credentialReference.referenceID.rawValue
            )
        }
        guard cancelOrderIdentityReference.boundaryHeld,
              cancelOrderIdentityReference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              cancelOrderIdentityReference.intentID == sourceSubmitEvidence.intentID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.orderIdentityReference",
                expected: sourceSubmitEvidence.runtimeEvidenceID.rawValue,
                actual: cancelOrderIdentityReference.sourceSubmitRuntimeEvidenceID.rawValue
            )
        }
        guard timestampMilliseconds > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.timestampMilliseconds",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds)"
            )
        }
        guard receiveWindowMilliseconds > 0, receiveWindowMilliseconds <= 60_000 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.receiveWindowMilliseconds",
                expected: "1...60000",
                actual: "\(receiveWindowMilliseconds)"
            )
        }
        guard redactedUnsignedQueryDigest.count == 64, redactedUnsignedQueryDigest.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.redactedUnsignedQueryDigest",
                expected: "64 lowercase hex characters",
                actual: redactedUnsignedQueryDigest
            )
        }
        guard signature.count == 64, signature.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.signature",
                expected: "64 lowercase hex characters",
                actual: signature
            )
        }
        guard requestID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelOrderIdentityReferenceID: cancelOrderIdentityReference.referenceID,
            timestampMilliseconds: timestampMilliseconds
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.requestID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                    cancelOrderIdentityReferenceID: cancelOrderIdentityReference.referenceID,
                    timestampMilliseconds: timestampMilliseconds
                ).rawValue,
                actual: requestID.rawValue
            )
        }
        guard explicitTestnetMode,
              spotTestnetOnly,
              signedQueryStringRedacted,
              requestBodyRedacted,
              credentialMaterialRedacted,
              orderIdentityMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.signedRequest.unredactedOrNonTestnet")
        }
        try Self.forbid(networkCancelPerformed, "networkCancelPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.requestID = requestID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.intentID = sourceSubmitEvidence.intentID
        self.credentialReferenceID = credentialReference.referenceID
        self.credentialReferenceRedacted = credentialReference.redactedDescription
        self.cancelOrderIdentityReferenceID = cancelOrderIdentityReference.referenceID
        self.cancelOrderIdentityReferenceRedacted = cancelOrderIdentityReference.redactedDescription
        self.productType = .spot
        self.symbol = symbol
        self.timestampMilliseconds = timestampMilliseconds
        self.receiveWindowMilliseconds = receiveWindowMilliseconds
        self.httpMethod = Self.httpMethod
        self.endpointHost = Self.canonicalSpotTestnetHost
        self.endpointPath = Self.spotOrderEndpointPath
        self.redactedUnsignedQueryDigest = redactedUnsignedQueryDigest
        self.signature = signature
        self.signedQueryStringRedacted = signedQueryStringRedacted
        self.apiKeyHeaderName = Self.apiKeyHeaderName
        self.apiKeyHeaderValueRedacted = true
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.orderIdentityMaterialRedacted = orderIdentityMaterialRedacted
        self.networkCancelPerformed = networkCancelPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && httpMethod == Self.httpMethod
            && endpointHost == Self.canonicalSpotTestnetHost
            && endpointPath == Self.spotOrderEndpointPath
            && redactedUnsignedQueryDigest.count == 64
            && signature.count == 64
            && signedQueryStringRedacted
            && apiKeyHeaderName == Self.apiKeyHeaderName
            && apiKeyHeaderValueRedacted
            && explicitTestnetMode
            && spotTestnetOnly
            && requestBodyRedacted
            && credentialMaterialRedacted
            && orderIdentityMaterialRedacted
            && networkCancelPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence(requestID: \(requestID.rawValue), sourceSubmitRuntimeEvidenceID: \(sourceSubmitRuntimeEvidenceID.rawValue), credentialReference: \(credentialReferenceRedacted), orderIdentity: <redacted>, endpoint: \(endpointHost)\(endpointPath), signedQueryString: <redacted>, apiKeyHeaderValue: <redacted>)"
    }

    public static let canonicalSpotTestnetHost = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
    public static let spotOrderEndpointPath = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
    public static let apiKeyHeaderName = ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.apiKeyHeaderName
    public static let httpMethod = "DELETE"
    public static let requiredValidationAnchors = [
        "GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME",
        "TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL",
        "V0150-004-CANCEL-REQUEST-CONSTRUCTION",
        "V0150-004-SIGNED-TESTNET-TRANSPORT",
        "V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE",
        "V0150-004-OMS-CANCEL-STATE-TRANSITION",
        "V0150-004-APPEND-ONLY-CANCEL-EVENT",
        "V0150-004-PRODUCTION-ENDPOINT-BLOCKED",
        "V0150-004-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        cancelOrderIdentityReferenceID: Identifier,
        timestampMilliseconds: Int64
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-request:\(sourceSubmitRuntimeEvidenceID.rawValue):\(cancelOrderIdentityReferenceID.rawValue):\(timestampMilliseconds)",
            field: "releaseV0150SpotTestnetCancel.signedRequest.requestID"
        )
    }

    public static func timestampMilliseconds(_ timestamp: Date) throws -> Int64 {
        guard timestamp.timeIntervalSince1970.isFinite, timestamp.timeIntervalSince1970 > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest.timestamp",
                expected: "positive unix timestamp",
                actual: "\(timestamp)"
            )
        }
        return Int64((timestamp.timeIntervalSince1970 * 1_000).rounded())
    }

    public static func unsignedCancelOrderQueryString(
        symbol: Symbol,
        originalClientOrderID: String,
        timestampMilliseconds: Int64,
        receiveWindowMilliseconds: Int
    ) -> String {
        [
            "symbol=\(symbol.rawValue)",
            "origClientOrderId=\(originalClientOrderID)",
            "timestamp=\(timestampMilliseconds)",
            "recvWindow=\(receiveWindowMilliseconds)"
        ].joined(separator: "&")
    }

    public static func redactedUnsignedQueryDigest(for unsignedQueryString: String) -> String {
        let payload = "gh-1069-redacted-cancel-query:\(unsignedQueryString)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.signedRequest.\(field)")
        }
    }
}

public extension ReleaseV0150BinanceSpotTestnetSignedRequestBuilder {
    /// Builds a redacted signed Binance Spot Testnet cancel request from prior submit runtime evidence.
    ///
    /// The returned evidence proves the deterministic signature and request identity while keeping the
    /// cancel order identity material and complete signed query string out of Codable artifacts.
    func buildCancelRequest(
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        cancelOrderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        symbol: Symbol,
        timestamp: Date,
        receiveWindowMilliseconds: Int = 5_000
    ) throws -> ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.requestBuilder.boundary")
        }
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.credentialReferenceID == credential.reference.referenceID,
              cancelOrderIdentity.reference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.requestBuilder.sourceSubmit",
                expected: sourceSubmitEvidence.runtimeEvidenceID.rawValue,
                actual: cancelOrderIdentity.reference.sourceSubmitRuntimeEvidenceID.rawValue
            )
        }
        let timestampMilliseconds = try ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.timestampMilliseconds(timestamp)
        let unsignedQueryString = ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.unsignedCancelOrderQueryString(
            symbol: symbol,
            originalClientOrderID: cancelOrderIdentity.binanceOriginalClientOrderID(),
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let signature = credential.signature(for: unsignedQueryString)
        let redactedDigest = ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.redactedUnsignedQueryDigest(
            for: unsignedQueryString
        )
        let requestID = ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelOrderIdentityReferenceID: cancelOrderIdentity.reference.referenceID,
            timestampMilliseconds: timestampMilliseconds
        )

        return try ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence(
            requestID: requestID,
            sourceSubmitEvidence: sourceSubmitEvidence,
            credentialReference: credential.reference,
            cancelOrderIdentityReference: cancelOrderIdentity.reference,
            symbol: symbol,
            timestampMilliseconds: timestampMilliseconds,
            receiveWindowMilliseconds: receiveWindowMilliseconds,
            redactedUnsignedQueryDigest: redactedDigest,
            signature: signature
        )
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelOperatorGate records explicit operator approval for a testnet cancel.
///
/// The gate links source submit evidence, redacted order identity, signed cancel request and operator
/// confirmation. It cannot be reused for production endpoints, broker endpoints, or non-Spot products.
public struct ReleaseV0150BinanceSpotTestnetCancelOperatorGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let operatorConfirmationID: Identifier
    public let strategyRunID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let credentialReferenceID: Identifier
    public let signedCancelRequestID: Identifier
    public let cancelOrderIdentityReferenceID: Identifier
    public let explicitTestnetMode: Bool
    public let operatorConfirmedTestnetCancel: Bool
    public let acknowledgesNoProductionTrading: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        gateID: Identifier,
        operatorConfirmationID: Identifier,
        strategyRunID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier,
        credentialReferenceID: Identifier,
        signedCancelRequestID: Identifier,
        cancelOrderIdentityReferenceID: Identifier,
        explicitTestnetMode: Bool = true,
        operatorConfirmedTestnetCancel: Bool = true,
        acknowledgesNoProductionTrading: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard gateID == Self.deterministicID(
            strategyRunID: strategyRunID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
            signedCancelRequestID: signedCancelRequestID,
            cancelOrderIdentityReferenceID: cancelOrderIdentityReferenceID,
            operatorConfirmationID: operatorConfirmationID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.operatorGate.gateID",
                expected: Self.deterministicID(
                    strategyRunID: strategyRunID,
                    sourceSubmitRuntimeEvidenceID: sourceSubmitRuntimeEvidenceID,
                    signedCancelRequestID: signedCancelRequestID,
                    cancelOrderIdentityReferenceID: cancelOrderIdentityReferenceID,
                    operatorConfirmationID: operatorConfirmationID
                ).rawValue,
                actual: gateID.rawValue
            )
        }
        guard explicitTestnetMode, operatorConfirmedTestnetCancel, acknowledgesNoProductionTrading else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.operatorGate.unconfirmed")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.gateID = gateID
        self.operatorConfirmationID = operatorConfirmationID
        self.strategyRunID = strategyRunID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitRuntimeEvidenceID
        self.credentialReferenceID = credentialReferenceID
        self.signedCancelRequestID = signedCancelRequestID
        self.cancelOrderIdentityReferenceID = cancelOrderIdentityReferenceID
        self.explicitTestnetMode = explicitTestnetMode
        self.operatorConfirmedTestnetCancel = operatorConfirmedTestnetCancel
        self.acknowledgesNoProductionTrading = acknowledgesNoProductionTrading
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && operatorConfirmedTestnetCancel
            && acknowledgesNoProductionTrading
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        strategyRunID: Identifier,
        sourceSubmitRuntimeEvidenceID: Identifier,
        signedCancelRequestID: Identifier,
        cancelOrderIdentityReferenceID: Identifier,
        operatorConfirmationID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1069-spot-testnet-cancel-gate",
                strategyRunID.rawValue,
                sourceSubmitRuntimeEvidenceID.rawValue,
                signedCancelRequestID.rawValue,
                cancelOrderIdentityReferenceID.rawValue,
                operatorConfirmationID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0150SpotTestnetCancel.operatorGate.gateID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.operatorGate.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelTransportResult is the redacted result returned by cancel transport.
///
/// A concrete transport may execute the Binance Spot Testnet DELETE order request, but this evidence keeps
/// only the status code, redacted response digest and production-disabled flags.
public struct ReleaseV0150BinanceSpotTestnetCancelTransportResult: Codable, Equatable, Sendable, CustomStringConvertible {
    public let transportResultID: Identifier
    public let signedCancelRequestID: Identifier
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let acceptedByTestnet: Bool
    public let exchangeOrderIDRedacted: Bool
    public let responseBodyRedacted: Bool
    public let redactedResponseDigest: String
    public let testnetNetworkCancelPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        transportResultID: Identifier,
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence,
        httpStatusCode: Int,
        redactedResponseDigest: String,
        acceptedByTestnet: Bool = true,
        exchangeOrderIDRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        testnetNetworkCancelPerformed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard signedRequest.boundaryHeld,
              signedRequest.productType == .spot,
              signedRequest.endpointHost == ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.canonicalSpotTestnetHost else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.transportResult.signedRequest")
        }
        guard transportResultID == Self.deterministicID(
            signedCancelRequestID: signedRequest.requestID,
            httpStatusCode: httpStatusCode,
            redactedResponseDigest: redactedResponseDigest
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.transportResultID",
                expected: Self.deterministicID(
                    signedCancelRequestID: signedRequest.requestID,
                    httpStatusCode: httpStatusCode,
                    redactedResponseDigest: redactedResponseDigest
                ).rawValue,
                actual: transportResultID.rawValue
            )
        }
        guard (200..<300).contains(httpStatusCode), acceptedByTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.httpStatusCode",
                expected: "2xx accepted Spot Testnet cancel response",
                actual: "\(httpStatusCode)"
            )
        }
        guard exchangeOrderIDRedacted, responseBodyRedacted, testnetNetworkCancelPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.transportResult.unredactedOrMissingCancel")
        }
        guard redactedResponseDigest.count == 64, redactedResponseDigest.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.redactedResponseDigest",
                expected: "64 lowercase hex characters",
                actual: redactedResponseDigest
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.transportResultID = transportResultID
        self.signedCancelRequestID = signedRequest.requestID
        self.endpointHost = signedRequest.endpointHost
        self.endpointPath = signedRequest.endpointPath
        self.httpStatusCode = httpStatusCode
        self.acceptedByTestnet = acceptedByTestnet
        self.exchangeOrderIDRedacted = exchangeOrderIDRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.redactedResponseDigest = redactedResponseDigest
        self.testnetNetworkCancelPerformed = testnetNetworkCancelPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        endpointHost == ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.spotOrderEndpointPath
            && (200..<300).contains(httpStatusCode)
            && acceptedByTestnet
            && exchangeOrderIDRedacted
            && responseBodyRedacted
            && redactedResponseDigest.count == 64
            && testnetNetworkCancelPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetCancelTransportResult(signedCancelRequestID: \(signedCancelRequestID.rawValue), httpStatusCode: \(httpStatusCode), responseBody: <redacted>, exchangeOrderID: <redacted>, testnetNetworkCancelPerformed: \(testnetNetworkCancelPerformed))"
    }

    public static func redactedDigest(statusCode: Int, acknowledgement: String) -> String {
        let payload = "gh-1069-redacted-cancel-response:\(statusCode):\(acknowledgement)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func deterministicID(
        signedCancelRequestID: Identifier,
        httpStatusCode: Int,
        redactedResponseDigest: String
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-transport-result:\(signedCancelRequestID.rawValue):\(httpStatusCode):\(redactedResponseDigest)",
            field: "releaseV0150SpotTestnetCancel.transportResultID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.transportResult.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelTransport is the injected Spot Testnet cancel transport boundary.
///
/// The protocol receives signed request evidence plus short-lived credential and order identity material.
/// It must return redacted result evidence and must not persist raw secrets, raw order identity or production data.
public protocol ReleaseV0150BinanceSpotTestnetCancelTransport: Sendable {
    func cancelSpotTestnetOrder(
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence,
        orderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial
    ) async throws -> ReleaseV0150BinanceSpotTestnetCancelTransportResult
}

/// ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence captures the local OMS cancel state update.
///
/// The evidence validates `accepted|partiallyFilled|replaced -> cancelRequested -> cancelled` using the shared
/// `OrderLifecycleStateMachine`. It records no broker fill, reconciliation, production position or real account data.
public struct ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence: Codable, Equatable, Sendable {
    public let transitionEvidenceID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let cancelMappingID: Identifier
    public let signedCancelRequestID: Identifier
    public let transportResultID: Identifier
    public let localOrderID: Identifier
    public let intentID: Identifier
    public let fromLifecycleState: OrderLifecycleState
    public let requestLifecycleState: OrderLifecycleState
    public let finalLifecycleState: OrderLifecycleState
    public let requestTransition: OrderLifecycleTransition
    public let finalTransition: OrderLifecycleTransition
    public let stateMachineValidated: Bool
    public let appendOnlyOMSStateTransitionEvidence: Bool
    public let orderIdentityRedacted: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        transitionEvidenceID: Identifier,
        intent: OrderIntent,
        cancelMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence,
        transportResult: ReleaseV0150BinanceSpotTestnetCancelTransportResult,
        cancelOrderIdentityReference: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference,
        stateMachineValidated: Bool = true,
        appendOnlyOMSStateTransitionEvidence: Bool = true,
        orderIdentityRedacted: Bool = true,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard intent.intentID == sourceSubmitEvidence.intentID,
              cancelMapping.intentID == intent.intentID,
              cancelMapping.operation == .cancel,
              cancelMapping.mode == .binanceTestnet,
              cancelMapping.targetLifecycleState == .cancelRequested else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.omsTransition.mapping",
                expected: "Binance Testnet cancel mapping for source submit intent",
                actual: "\(cancelMapping.operation.rawValue):\(cancelMapping.lifecycleState.rawValue)"
            )
        }
        guard sourceSubmitEvidence.boundaryHeld,
              signedRequest.boundaryHeld,
              transportResult.boundaryHeld,
              cancelOrderIdentityReference.boundaryHeld,
              signedRequest.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              signedRequest.requestID == transportResult.signedCancelRequestID,
              cancelOrderIdentityReference.referenceID == signedRequest.cancelOrderIdentityReferenceID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.omsTransition.unlinkedEvidence")
        }
        guard OrderLifecycleStateMachine.canTransition(from: cancelMapping.lifecycleState, to: .cancelRequested),
              OrderLifecycleStateMachine.canTransition(from: .cancelRequested, to: .cancelled) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.omsTransition.stateMachine",
                expected: "valid cancel request and cancelled transitions",
                actual: "\(cancelMapping.lifecycleState.rawValue)->cancelRequested->cancelled"
            )
        }
        let requestTransition = try OrderLifecycleTransition(
            from: cancelMapping.lifecycleState,
            to: .cancelRequested,
            reason: "GH-1069 Spot Testnet cancel request accepted locally"
        )
        let finalTransition = try OrderLifecycleTransition(
            from: .cancelRequested,
            to: .cancelled,
            reason: "GH-1069 Spot Testnet cancel response accepted by testnet"
        )
        let localOrderID = Self.localOrderID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelOrderIdentityReferenceID: cancelOrderIdentityReference.referenceID
        )
        guard transitionEvidenceID == Self.deterministicID(
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            cancelMappingID: cancelMapping.mappingID,
            transportResultID: transportResult.transportResultID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.omsTransition.transitionEvidenceID",
                expected: Self.deterministicID(
                    sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                    cancelMappingID: cancelMapping.mappingID,
                    transportResultID: transportResult.transportResultID
                ).rawValue,
                actual: transitionEvidenceID.rawValue
            )
        }
        guard stateMachineValidated,
              appendOnlyOMSStateTransitionEvidence,
              orderIdentityRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.omsTransition.unheldLocalState")
        }
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.transitionEvidenceID = transitionEvidenceID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.cancelMappingID = cancelMapping.mappingID
        self.signedCancelRequestID = signedRequest.requestID
        self.transportResultID = transportResult.transportResultID
        self.localOrderID = localOrderID
        self.intentID = intent.intentID
        self.fromLifecycleState = cancelMapping.lifecycleState
        self.requestLifecycleState = .cancelRequested
        self.finalLifecycleState = .cancelled
        self.requestTransition = requestTransition
        self.finalTransition = finalTransition
        self.stateMachineValidated = stateMachineValidated
        self.appendOnlyOMSStateTransitionEvidence = appendOnlyOMSStateTransitionEvidence
        self.orderIdentityRedacted = orderIdentityRedacted
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        (fromLifecycleState == .accepted || fromLifecycleState == .partiallyFilled || fromLifecycleState == .replaced)
            && requestLifecycleState == .cancelRequested
            && finalLifecycleState == .cancelled
            && requestTransition.boundaryHeld
            && finalTransition.boundaryHeld
            && stateMachineValidated
            && appendOnlyOMSStateTransitionEvidence
            && orderIdentityRedacted
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static func localOrderID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        cancelOrderIdentityReferenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-local-order:\(sourceSubmitRuntimeEvidenceID.rawValue):\(cancelOrderIdentityReferenceID.rawValue)",
            field: "releaseV0150SpotTestnetCancel.omsTransition.localOrderID"
        )
    }

    public static func deterministicID(
        sourceSubmitRuntimeEvidenceID: Identifier,
        cancelMappingID: Identifier,
        transportResultID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-oms-transition:\(sourceSubmitRuntimeEvidenceID.rawValue):\(cancelMappingID.rawValue):\(transportResultID.rawValue)",
            field: "releaseV0150SpotTestnetCancel.omsTransition.transitionEvidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.omsTransition.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence links cancel request, transport and OMS evidence.
///
/// It proves one guarded Binance Spot Testnet cancel was performed for prior submit runtime evidence and
/// remained inside the production-disabled, redacted, append-only v0.15.0 boundary.
public struct ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence: Codable, Equatable, Sendable {
    public let runtimeEvidenceID: Identifier
    public let intentID: Identifier
    public let cancelMappingID: Identifier
    public let sourceSubmitRuntimeEvidenceID: Identifier
    public let signedCancelRequestID: Identifier
    public let operatorGateID: Identifier
    public let transportResultID: Identifier
    public let omsTransitionEvidenceID: Identifier
    public let credentialReferenceID: Identifier
    public let cancelOrderIdentityReferenceID: Identifier
    public let productType: ProductType
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let orderLifecycleState: OrderLifecycleState
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let operatorConfirmedTestnetCancel: Bool
    public let requestBodyRedacted: Bool
    public let responseBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let orderIdentityMaterialRedacted: Bool
    public let appendOnlyCancelEvidenceCreated: Bool
    public let omsStateTransitionIntegrated: Bool
    public let testnetNetworkCancelPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        runtimeEvidenceID: Identifier,
        intent: OrderIntent,
        cancelMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence,
        operatorGate: ReleaseV0150BinanceSpotTestnetCancelOperatorGate,
        transportResult: ReleaseV0150BinanceSpotTestnetCancelTransportResult,
        omsTransition: ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence,
        orderLifecycleState: OrderLifecycleState = .cancelled,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        requestBodyRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        orderIdentityMaterialRedacted: Bool = true,
        appendOnlyCancelEvidenceCreated: Bool = true,
        omsStateTransitionIntegrated: Bool = true,
        testnetNetworkCancelPerformed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard intent.isPreRiskEngineIntent,
              intent.instrument.productType == .spot,
              cancelMapping.boundaryHeld,
              cancelMapping.intentID == intent.intentID,
              cancelMapping.operation == .cancel,
              cancelMapping.mode == .binanceTestnet,
              cancelMapping.targetLifecycleState == .cancelRequested else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.intentMapping")
        }
        guard sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.intentID == intent.intentID,
              sourceSubmitEvidence.productType == .spot else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.sourceSubmitEvidence")
        }
        guard signedRequest.boundaryHeld,
              signedRequest.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              signedRequest.intentID == intent.intentID,
              signedRequest.credentialReferenceID == sourceSubmitEvidence.credentialReferenceID,
              signedRequest.cancelOrderIdentityReferenceID == operatorGate.cancelOrderIdentityReferenceID,
              signedRequest.requestID == operatorGate.signedCancelRequestID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.signedRequest",
                expected: "boundary-held signed Spot Testnet cancel request linked to source submit evidence",
                actual: signedRequest.requestID.rawValue
            )
        }
        guard operatorGate.boundaryHeld,
              operatorGate.strategyRunID == intent.correlation.strategyRunID,
              operatorGate.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              operatorGate.credentialReferenceID == signedRequest.credentialReferenceID,
              transportResult.boundaryHeld,
              transportResult.signedCancelRequestID == signedRequest.requestID,
              omsTransition.boundaryHeld,
              omsTransition.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              omsTransition.cancelMappingID == cancelMapping.mappingID,
              omsTransition.transportResultID == transportResult.transportResultID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.unlinkedGateTransportOrOMS")
        }
        guard orderLifecycleState == .cancelled,
              explicitTestnetMode,
              spotTestnetOnly,
              operatorGate.operatorConfirmedTestnetCancel,
              requestBodyRedacted,
              responseBodyRedacted,
              credentialMaterialRedacted,
              orderIdentityMaterialRedacted,
              appendOnlyCancelEvidenceCreated,
              omsStateTransitionIntegrated,
              testnetNetworkCancelPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.unheldRuntimeEvidence")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard runtimeEvidenceID == Self.deterministicID(
            intentID: intent.intentID,
            signedCancelRequestID: signedRequest.requestID,
            transportResultID: transportResult.transportResultID,
            omsTransitionEvidenceID: omsTransition.transitionEvidenceID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.runtimeEvidenceID",
                expected: Self.deterministicID(
                    intentID: intent.intentID,
                    signedCancelRequestID: signedRequest.requestID,
                    transportResultID: transportResult.transportResultID,
                    omsTransitionEvidenceID: omsTransition.transitionEvidenceID
                ).rawValue,
                actual: runtimeEvidenceID.rawValue
            )
        }

        self.runtimeEvidenceID = runtimeEvidenceID
        self.intentID = intent.intentID
        self.cancelMappingID = cancelMapping.mappingID
        self.sourceSubmitRuntimeEvidenceID = sourceSubmitEvidence.runtimeEvidenceID
        self.signedCancelRequestID = signedRequest.requestID
        self.operatorGateID = operatorGate.gateID
        self.transportResultID = transportResult.transportResultID
        self.omsTransitionEvidenceID = omsTransition.transitionEvidenceID
        self.credentialReferenceID = signedRequest.credentialReferenceID
        self.cancelOrderIdentityReferenceID = signedRequest.cancelOrderIdentityReferenceID
        self.productType = signedRequest.productType
        self.endpointHost = signedRequest.endpointHost
        self.endpointPath = signedRequest.endpointPath
        self.httpStatusCode = transportResult.httpStatusCode
        self.orderLifecycleState = orderLifecycleState
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.operatorConfirmedTestnetCancel = operatorGate.operatorConfirmedTestnetCancel
        self.requestBodyRedacted = requestBodyRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.orderIdentityMaterialRedacted = orderIdentityMaterialRedacted
        self.appendOnlyCancelEvidenceCreated = appendOnlyCancelEvidenceCreated
        self.omsStateTransitionIntegrated = omsStateTransitionIntegrated
        self.testnetNetworkCancelPerformed = testnetNetworkCancelPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && endpointHost == ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.spotOrderEndpointPath
            && orderLifecycleState == .cancelled
            && explicitTestnetMode
            && spotTestnetOnly
            && operatorConfirmedTestnetCancel
            && requestBodyRedacted
            && responseBodyRedacted
            && credentialMaterialRedacted
            && orderIdentityMaterialRedacted
            && appendOnlyCancelEvidenceCreated
            && omsStateTransitionIntegrated
            && testnetNetworkCancelPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence.requiredValidationAnchors

    public static func deterministicID(
        intentID: Identifier,
        signedCancelRequestID: Identifier,
        transportResultID: Identifier,
        omsTransitionEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-runtime:\(intentID.rawValue):\(signedCancelRequestID.rawValue):\(transportResultID.rawValue):\(omsTransitionEvidenceID.rawValue)",
            field: "releaseV0150SpotTestnetCancel.runtimeEvidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.runtimeEvidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelRuntimeResult bundles cancel evidence and appended network log.
///
/// The result proves the cancel action has been appended after the existing submit network event chain.
public struct ReleaseV0150BinanceSpotTestnetCancelRuntimeResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let cancelEvidence: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence
    public let appendedNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    public let appendedCancelEventID: Identifier
    public let appendedCancelArtifactChecksum: String

    public init(
        resultID: Identifier,
        cancelEvidence: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence,
        appendedNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    ) throws {
        guard cancelEvidence.boundaryHeld, appendedNetworkEventLog.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.runtimeResult.unheldEvidence")
        }
        guard let lastEvent = appendedNetworkEventLog.eventArtifacts.last,
              lastEvent.actionKind == .cancel,
              lastEvent.actionEvidenceID == cancelEvidence.runtimeEvidenceID,
              lastEvent.orderLifecycleState == .cancelled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.runtimeResult.lastNetworkEvent",
                expected: "last event is cancel artifact for cancel runtime evidence",
                actual: appendedNetworkEventLog.eventArtifacts.last?.actionKind.rawValue ?? "missing"
            )
        }
        guard resultID == Self.deterministicID(
            cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
            latestArtifactChecksum: appendedNetworkEventLog.latestArtifactChecksum
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetCancel.runtimeResult.resultID",
                expected: Self.deterministicID(
                    cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
                    latestArtifactChecksum: appendedNetworkEventLog.latestArtifactChecksum
                ).rawValue,
                actual: resultID.rawValue
            )
        }

        self.resultID = resultID
        self.cancelEvidence = cancelEvidence
        self.appendedNetworkEventLog = appendedNetworkEventLog
        self.appendedCancelEventID = lastEvent.eventArtifactID
        self.appendedCancelArtifactChecksum = lastEvent.artifactChecksum
    }

    public var boundaryHeld: Bool {
        cancelEvidence.boundaryHeld
            && appendedNetworkEventLog.boundaryHeld
            && appendedNetworkEventLog.eventArtifacts.last?.actionKind == .cancel
            && appendedNetworkEventLog.eventArtifacts.last?.actionEvidenceID == cancelEvidence.runtimeEvidenceID
    }

    public static func deterministicID(
        cancelRuntimeEvidenceID: Identifier,
        latestArtifactChecksum: String
    ) -> Identifier {
        .constant(
            "gh-1069-spot-testnet-cancel-result:\(cancelRuntimeEvidenceID.rawValue):\(latestArtifactChecksum)",
            field: "releaseV0150SpotTestnetCancel.runtimeResult.resultID"
        )
    }
}

/// ReleaseV0150BinanceSpotTestnetCancelRuntime executes the guarded Spot Testnet cancel path.
///
/// The runtime requires prior submit runtime evidence and an existing #1071 network event log. It appends
/// one cancel artifact to the checksum chain and emits local OMS cancel transition evidence.
public struct ReleaseV0150BinanceSpotTestnetCancelRuntime: Sendable {
    public let requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder
    private let transport: any ReleaseV0150BinanceSpotTestnetCancelTransport

    public init(
        requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder,
        transport: any ReleaseV0150BinanceSpotTestnetCancelTransport
    ) {
        self.requestBuilder = requestBuilder
        self.transport = transport
    }

    public func cancelSpotTestnetOrder(
        intent: OrderIntent,
        cancelMapping: ExecutionContractRequestMapping,
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        existingNetworkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        cancelOrderIdentity: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial,
        operatorConfirmationID: Identifier,
        timestamp: Date,
        observedAtMilliseconds: Int64,
        receiveWindowMilliseconds: Int = 5_000
    ) async throws -> ReleaseV0150BinanceSpotTestnetCancelRuntimeResult {
        guard requestBuilder.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.requestBuilder")
        }
        guard intent.isPreRiskEngineIntent,
              intent.instrument.productType == .spot,
              cancelMapping.boundaryHeld,
              cancelMapping.intentID == intent.intentID,
              cancelMapping.operation == .cancel,
              cancelMapping.mode == .binanceTestnet,
              cancelMapping.targetLifecycleState == .cancelRequested,
              sourceSubmitEvidence.boundaryHeld,
              sourceSubmitEvidence.intentID == intent.intentID,
              sourceSubmitEvidence.credentialReferenceID == credential.reference.referenceID,
              cancelOrderIdentity.reference.sourceSubmitRuntimeEvidenceID == sourceSubmitEvidence.runtimeEvidenceID,
              existingNetworkEventLog.boundaryHeld,
              existingNetworkEventLog.eventArtifacts.contains(where: {
                  $0.actionKind == .submit && $0.actionEvidenceID == sourceSubmitEvidence.runtimeEvidenceID
              }) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetCancel.runtimeInputs")
        }

        let signedRequest = try requestBuilder.buildCancelRequest(
            sourceSubmitEvidence: sourceSubmitEvidence,
            credential: credential,
            cancelOrderIdentity: cancelOrderIdentity,
            symbol: intent.instrument.symbol,
            timestamp: timestamp,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let operatorGate = try ReleaseV0150BinanceSpotTestnetCancelOperatorGate(
            gateID: ReleaseV0150BinanceSpotTestnetCancelOperatorGate.deterministicID(
                strategyRunID: intent.correlation.strategyRunID,
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                signedCancelRequestID: signedRequest.requestID,
                cancelOrderIdentityReferenceID: cancelOrderIdentity.reference.referenceID,
                operatorConfirmationID: operatorConfirmationID
            ),
            operatorConfirmationID: operatorConfirmationID,
            strategyRunID: intent.correlation.strategyRunID,
            sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
            credentialReferenceID: credential.reference.referenceID,
            signedCancelRequestID: signedRequest.requestID,
            cancelOrderIdentityReferenceID: cancelOrderIdentity.reference.referenceID
        )
        let transportResult = try await transport.cancelSpotTestnetOrder(
            signedRequest: signedRequest,
            orderIdentity: cancelOrderIdentity,
            credential: credential
        )
        let omsTransition = try ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence(
            transitionEvidenceID: ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence.deterministicID(
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID,
                cancelMappingID: cancelMapping.mappingID,
                transportResultID: transportResult.transportResultID
            ),
            intent: intent,
            cancelMapping: cancelMapping,
            sourceSubmitEvidence: sourceSubmitEvidence,
            signedRequest: signedRequest,
            transportResult: transportResult,
            cancelOrderIdentityReference: cancelOrderIdentity.reference
        )
        let cancelEvidence = try ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence(
            runtimeEvidenceID: ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence.deterministicID(
                intentID: intent.intentID,
                signedCancelRequestID: signedRequest.requestID,
                transportResultID: transportResult.transportResultID,
                omsTransitionEvidenceID: omsTransition.transitionEvidenceID
            ),
            intent: intent,
            cancelMapping: cancelMapping,
            sourceSubmitEvidence: sourceSubmitEvidence,
            signedRequest: signedRequest,
            operatorGate: operatorGate,
            transportResult: transportResult,
            omsTransition: omsTransition
        )
        let cancelEvent = try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.fromCancelRuntimeEvidence(
            cancelEvidence,
            sequenceNumber: existingNetworkEventLog.eventArtifacts.count + 1,
            observedAtMilliseconds: observedAtMilliseconds,
            previousArtifactChecksum: existingNetworkEventLog.latestArtifactChecksum
        )
        let appendedLog = try existingNetworkEventLog.appending(cancelEvent)
        return try ReleaseV0150BinanceSpotTestnetCancelRuntimeResult(
            resultID: ReleaseV0150BinanceSpotTestnetCancelRuntimeResult.deterministicID(
                cancelRuntimeEvidenceID: cancelEvidence.runtimeEvidenceID,
                latestArtifactChecksum: appendedLog.latestArtifactChecksum
            ),
            cancelEvidence: cancelEvidence,
            appendedNetworkEventLog: appendedLog
        )
    }
}
