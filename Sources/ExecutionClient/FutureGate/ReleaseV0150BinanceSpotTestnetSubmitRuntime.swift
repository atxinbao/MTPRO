import Crypto
import DomainModel
import Foundation

// GH-1068 静态合同边界：
// endpointHost=testnet.binance.vision
// endpointPath=/api/v3/order
// testnetNetworkSubmitPerformed=true
// appendOnlyEvidenceCreated=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetSubmitOperatorGate 记录 v0.15.0 Spot Testnet submit 的人工确认。
///
/// 该 gate 只绑定当前 OrderIntent run、credential reference 和 signed request identity。它不读取
/// secret、不保存 API key，也不能复用于 production endpoint 或后续 cancel / replace。
public struct ReleaseV0150BinanceSpotTestnetSubmitOperatorGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let operatorConfirmationID: Identifier
    public let strategyRunID: Identifier
    public let credentialReferenceID: Identifier
    public let signedRequestID: Identifier
    public let explicitTestnetMode: Bool
    public let operatorConfirmedTestnetSubmit: Bool
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
        credentialReferenceID: Identifier,
        signedRequestID: Identifier,
        explicitTestnetMode: Bool = true,
        operatorConfirmedTestnetSubmit: Bool = true,
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
            credentialReferenceID: credentialReferenceID,
            signedRequestID: signedRequestID,
            operatorConfirmationID: operatorConfirmationID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.operatorGate.gateID",
                expected: Self.deterministicID(
                    strategyRunID: strategyRunID,
                    credentialReferenceID: credentialReferenceID,
                    signedRequestID: signedRequestID,
                    operatorConfirmationID: operatorConfirmationID
                ).rawValue,
                actual: gateID.rawValue
            )
        }
        guard explicitTestnetMode, operatorConfirmedTestnetSubmit, acknowledgesNoProductionTrading else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.operatorGate.unconfirmed")
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
        self.credentialReferenceID = credentialReferenceID
        self.signedRequestID = signedRequestID
        self.explicitTestnetMode = explicitTestnetMode
        self.operatorConfirmedTestnetSubmit = operatorConfirmedTestnetSubmit
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
            && operatorConfirmedTestnetSubmit
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
        credentialReferenceID: Identifier,
        signedRequestID: Identifier,
        operatorConfirmationID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1068-spot-testnet-submit-gate",
                strategyRunID.rawValue,
                credentialReferenceID.rawValue,
                signedRequestID.rawValue,
                operatorConfirmationID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0150SpotTestnetSubmit.operatorGate.gateID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.operatorGate.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetSubmitTransportResult 是 transport 层返回的脱敏结果。
///
/// 真实 Binance Spot Testnet transport 必须在网络响应进入该类型前完成脱敏，只留下 HTTP 状态、
/// redacted digest 和本地 acknowledgement。该类型不能保存 raw response body、exchange order id、
/// API key、secret 或 production endpoint。
public struct ReleaseV0150BinanceSpotTestnetSubmitTransportResult: Codable, Equatable, Sendable, CustomStringConvertible {
    public let transportResultID: Identifier
    public let signedRequestID: Identifier
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let acceptedByTestnet: Bool
    public let exchangeOrderIDRedacted: Bool
    public let responseBodyRedacted: Bool
    public let redactedResponseDigest: String
    public let testnetNetworkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case transportResultID
        case signedRequestID
        case endpointHost
        case endpointPath
        case httpStatusCode
        case acceptedByTestnet
        case exchangeOrderIDRedacted
        case responseBodyRedacted
        case redactedResponseDigest
        case testnetNetworkSubmitPerformed
        case productionTradingEnabledByDefault
        case productionSecretAutoRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
    }

    public init(
        transportResultID: Identifier,
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence,
        httpStatusCode: Int,
        redactedResponseDigest: String,
        acceptedByTestnet: Bool = true,
        exchangeOrderIDRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        testnetNetworkSubmitPerformed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard signedRequest.boundaryHeld,
              signedRequest.productType == .spot,
              signedRequest.endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.transportResult.signedRequest")
        }
        guard transportResultID == Self.deterministicID(
            signedRequestID: signedRequest.requestID,
            httpStatusCode: httpStatusCode,
            redactedResponseDigest: redactedResponseDigest
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.transportResultID",
                expected: Self.deterministicID(
                    signedRequestID: signedRequest.requestID,
                    httpStatusCode: httpStatusCode,
                    redactedResponseDigest: redactedResponseDigest
                ).rawValue,
                actual: transportResultID.rawValue
            )
        }
        guard (200..<300).contains(httpStatusCode), acceptedByTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.httpStatusCode",
                expected: "2xx accepted Spot Testnet submit response",
                actual: "\(httpStatusCode)"
            )
        }
        guard exchangeOrderIDRedacted, responseBodyRedacted, testnetNetworkSubmitPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.transportResult.unredactedOrMissingSubmit")
        }
        guard redactedResponseDigest.count == 64, redactedResponseDigest.allSatisfy(\.isHexDigit) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.redactedResponseDigest",
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
        self.signedRequestID = signedRequest.requestID
        self.endpointHost = signedRequest.endpointHost
        self.endpointPath = signedRequest.endpointPath
        self.httpStatusCode = httpStatusCode
        self.acceptedByTestnet = acceptedByTestnet
        self.exchangeOrderIDRedacted = exchangeOrderIDRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.redactedResponseDigest = redactedResponseDigest
        self.testnetNetworkSubmitPerformed = testnetNetworkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transportResultID = try container.decode(Identifier.self, forKey: .transportResultID)
        self.signedRequestID = try container.decode(Identifier.self, forKey: .signedRequestID)
        self.endpointHost = try container.decode(String.self, forKey: .endpointHost)
        self.endpointPath = try container.decode(String.self, forKey: .endpointPath)
        self.httpStatusCode = try container.decode(Int.self, forKey: .httpStatusCode)
        self.acceptedByTestnet = try container.decode(Bool.self, forKey: .acceptedByTestnet)
        self.exchangeOrderIDRedacted = try container.decode(Bool.self, forKey: .exchangeOrderIDRedacted)
        self.responseBodyRedacted = try container.decode(Bool.self, forKey: .responseBodyRedacted)
        self.redactedResponseDigest = try container.decode(String.self, forKey: .redactedResponseDigest)
        self.testnetNetworkSubmitPerformed = try container.decode(Bool.self, forKey: .testnetNetworkSubmitPerformed)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretAutoRead = try container.decode(Bool.self, forKey: .productionSecretAutoRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)

        let expectedID = Self.deterministicID(
            signedRequestID: signedRequestID,
            httpStatusCode: httpStatusCode,
            redactedResponseDigest: redactedResponseDigest
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            transportResultID == expectedID,
            field: "releaseV0150SpotTestnetSubmit.transportResultID",
            expected: expectedID.rawValue,
            actual: transportResultID.rawValue
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.isLowercaseSHA256(redactedResponseDigest),
            field: "releaseV0150SpotTestnetSubmit.redactedResponseDigest",
            expected: "lowercase sha256 digest",
            actual: redactedResponseDigest
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SpotTestnetSubmit.transportResult.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
            && (200..<300).contains(httpStatusCode)
            && acceptedByTestnet
            && exchangeOrderIDRedacted
            && responseBodyRedacted
            && redactedResponseDigest.count == 64
            && testnetNetworkSubmitPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var description: String {
        "ReleaseV0150BinanceSpotTestnetSubmitTransportResult(signedRequestID: \(signedRequestID.rawValue), httpStatusCode: \(httpStatusCode), responseBody: <redacted>, exchangeOrderID: <redacted>, testnetNetworkSubmitPerformed: \(testnetNetworkSubmitPerformed))"
    }

    public static func redactedDigest(statusCode: Int, acknowledgement: String) -> String {
        let payload = "gh-1068-redacted-response:\(statusCode):\(acknowledgement)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func deterministicID(
        signedRequestID: Identifier,
        httpStatusCode: Int,
        redactedResponseDigest: String
    ) -> Identifier {
        .constant(
            "gh-1068-spot-testnet-submit-transport-result:\(signedRequestID.rawValue):\(httpStatusCode):\(redactedResponseDigest)",
            field: "releaseV0150SpotTestnetSubmit.transportResultID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.transportResult.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetSubmitTransport 是 #1068 的注入式 Spot Testnet transport 边界。
///
/// 协议允许后续运行时注入真实 Binance Spot Testnet transport，但实现方只能消费已签名的
/// Spot Testnet request evidence 与短生命周期 credential material，并必须返回脱敏结果。
/// 协议本身不提供 production adapter，也不读取环境变量或 secret store。
public protocol ReleaseV0150BinanceSpotTestnetSubmitTransport: Sendable {
    func submitSpotTestnetOrder(
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial
    ) async throws -> ReleaseV0150BinanceSpotTestnetSubmitTransportResult
}

/// ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence 汇总 #1068 的 submit runtime 证据链。
///
/// 该 evidence 表示一次显式确认后的 Binance Spot Testnet submit runtime path 已执行，并且
/// request、response、credential、operator gate 和 production boundary 均可审计。它不是
/// production order，也不授权 cancel / replace、OMS reconciliation 或 Dashboard command surface。
public struct ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence: Codable, Equatable, Sendable {
    public let runtimeEvidenceID: Identifier
    public let intentID: Identifier
    public let mappingID: Identifier
    public let signedRequestID: Identifier
    public let operatorGateID: Identifier
    public let transportResultID: Identifier
    public let credentialReferenceID: Identifier
    public let clientOrderIdentityReferenceID: Identifier
    public let redactedClientOrderIDHash: String
    public let productType: ProductType
    public let endpointHost: String
    public let endpointPath: String
    public let httpStatusCode: Int
    public let orderLifecycleState: OrderLifecycleState
    public let explicitTestnetMode: Bool
    public let spotTestnetOnly: Bool
    public let operatorConfirmedTestnetSubmit: Bool
    public let requestBodyRedacted: Bool
    public let responseBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let clientOrderIdentityMaterialRedacted: Bool
    public let clientOrderIdentityMaterialStored: Bool
    public let appendOnlyEvidenceCreated: Bool
    public let testnetNetworkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    private enum CodingKeys: String, CodingKey {
        case runtimeEvidenceID
        case intentID
        case mappingID
        case signedRequestID
        case operatorGateID
        case transportResultID
        case credentialReferenceID
        case clientOrderIdentityReferenceID
        case redactedClientOrderIDHash
        case productType
        case endpointHost
        case endpointPath
        case httpStatusCode
        case orderLifecycleState
        case explicitTestnetMode
        case spotTestnetOnly
        case operatorConfirmedTestnetSubmit
        case requestBodyRedacted
        case responseBodyRedacted
        case credentialMaterialRedacted
        case clientOrderIdentityMaterialRedacted
        case clientOrderIdentityMaterialStored
        case appendOnlyEvidenceCreated
        case testnetNetworkSubmitPerformed
        case productionTradingEnabledByDefault
        case productionSecretAutoRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionOrderSubmitted
        case productionCutoverAuthorized
        case validationAnchors
    }

    public init(
        runtimeEvidenceID: Identifier,
        intent: OrderIntent,
        mapping: ExecutionContractRequestMapping,
        signedRequest: ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence,
        operatorGate: ReleaseV0150BinanceSpotTestnetSubmitOperatorGate,
        transportResult: ReleaseV0150BinanceSpotTestnetSubmitTransportResult,
        orderLifecycleState: OrderLifecycleState = .submittedTestnet,
        explicitTestnetMode: Bool = true,
        spotTestnetOnly: Bool = true,
        requestBodyRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        clientOrderIdentityMaterialRedacted: Bool = true,
        clientOrderIdentityMaterialStored: Bool = false,
        appendOnlyEvidenceCreated: Bool = true,
        testnetNetworkSubmitPerformed: Bool = true,
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
              mapping.boundaryHeld,
              mapping.intentID == intent.intentID,
              mapping.operation == .submit,
              mapping.mode == .binanceTestnet,
              mapping.lifecycleState == .riskAccepted,
              mapping.targetLifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.intentMapping")
        }
        guard signedRequest.boundaryHeld,
              signedRequest.credentialReferenceID == operatorGate.credentialReferenceID,
              signedRequest.requestID == operatorGate.signedRequestID,
              signedRequest.productType == .spot,
              signedRequest.symbol == intent.instrument.symbol,
              signedRequest.side == intent.side,
              signedRequest.clientOrderIdentityMaterialRedacted,
              signedRequest.clientOrderIdentityMaterialStored == false,
              signedRequest.redactedClientOrderIDHash.count == 64 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.signedRequest",
                expected: "boundary-held signed Spot Testnet request linked to intent and gate",
                actual: signedRequest.requestID.rawValue
            )
        }
        guard operatorGate.boundaryHeld,
              operatorGate.strategyRunID == intent.correlation.strategyRunID,
              transportResult.boundaryHeld,
              transportResult.signedRequestID == signedRequest.requestID else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.unlinkedGateOrTransport")
        }
        guard orderLifecycleState == .submittedTestnet,
              explicitTestnetMode,
              spotTestnetOnly,
              operatorGate.operatorConfirmedTestnetSubmit,
              requestBodyRedacted,
              responseBodyRedacted,
              credentialMaterialRedacted,
              clientOrderIdentityMaterialRedacted,
              clientOrderIdentityMaterialStored == false,
              appendOnlyEvidenceCreated,
              testnetNetworkSubmitPerformed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.unheldRuntimeEvidence")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard runtimeEvidenceID == Self.deterministicID(
            intentID: intent.intentID,
            signedRequestID: signedRequest.requestID,
            transportResultID: transportResult.transportResultID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150SpotTestnetSubmit.runtimeEvidenceID",
                expected: Self.deterministicID(
                    intentID: intent.intentID,
                    signedRequestID: signedRequest.requestID,
                    transportResultID: transportResult.transportResultID
                ).rawValue,
                actual: runtimeEvidenceID.rawValue
            )
        }

        self.runtimeEvidenceID = runtimeEvidenceID
        self.intentID = intent.intentID
        self.mappingID = mapping.mappingID
        self.signedRequestID = signedRequest.requestID
        self.operatorGateID = operatorGate.gateID
        self.transportResultID = transportResult.transportResultID
        self.credentialReferenceID = signedRequest.credentialReferenceID
        self.clientOrderIdentityReferenceID = signedRequest.clientOrderIdentityReferenceID
        self.redactedClientOrderIDHash = signedRequest.redactedClientOrderIDHash
        self.productType = signedRequest.productType
        self.endpointHost = signedRequest.endpointHost
        self.endpointPath = signedRequest.endpointPath
        self.httpStatusCode = transportResult.httpStatusCode
        self.orderLifecycleState = orderLifecycleState
        self.explicitTestnetMode = explicitTestnetMode
        self.spotTestnetOnly = spotTestnetOnly
        self.operatorConfirmedTestnetSubmit = operatorGate.operatorConfirmedTestnetSubmit
        self.requestBodyRedacted = requestBodyRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.clientOrderIdentityMaterialRedacted = clientOrderIdentityMaterialRedacted
        self.clientOrderIdentityMaterialStored = clientOrderIdentityMaterialStored
        self.appendOnlyEvidenceCreated = appendOnlyEvidenceCreated
        self.testnetNetworkSubmitPerformed = testnetNetworkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.runtimeEvidenceID = try container.decode(Identifier.self, forKey: .runtimeEvidenceID)
        self.intentID = try container.decode(Identifier.self, forKey: .intentID)
        self.mappingID = try container.decode(Identifier.self, forKey: .mappingID)
        self.signedRequestID = try container.decode(Identifier.self, forKey: .signedRequestID)
        self.operatorGateID = try container.decode(Identifier.self, forKey: .operatorGateID)
        self.transportResultID = try container.decode(Identifier.self, forKey: .transportResultID)
        self.credentialReferenceID = try container.decode(Identifier.self, forKey: .credentialReferenceID)
        self.clientOrderIdentityReferenceID = try container.decode(Identifier.self, forKey: .clientOrderIdentityReferenceID)
        self.redactedClientOrderIDHash = try container.decode(String.self, forKey: .redactedClientOrderIDHash)
        self.productType = try container.decode(ProductType.self, forKey: .productType)
        self.endpointHost = try container.decode(String.self, forKey: .endpointHost)
        self.endpointPath = try container.decode(String.self, forKey: .endpointPath)
        self.httpStatusCode = try container.decode(Int.self, forKey: .httpStatusCode)
        self.orderLifecycleState = try container.decode(OrderLifecycleState.self, forKey: .orderLifecycleState)
        self.explicitTestnetMode = try container.decode(Bool.self, forKey: .explicitTestnetMode)
        self.spotTestnetOnly = try container.decode(Bool.self, forKey: .spotTestnetOnly)
        self.operatorConfirmedTestnetSubmit = try container.decode(Bool.self, forKey: .operatorConfirmedTestnetSubmit)
        self.requestBodyRedacted = try container.decode(Bool.self, forKey: .requestBodyRedacted)
        self.responseBodyRedacted = try container.decode(Bool.self, forKey: .responseBodyRedacted)
        self.credentialMaterialRedacted = try container.decode(Bool.self, forKey: .credentialMaterialRedacted)
        self.clientOrderIdentityMaterialRedacted = try container.decode(Bool.self, forKey: .clientOrderIdentityMaterialRedacted)
        self.clientOrderIdentityMaterialStored = try container.decode(Bool.self, forKey: .clientOrderIdentityMaterialStored)
        self.appendOnlyEvidenceCreated = try container.decode(Bool.self, forKey: .appendOnlyEvidenceCreated)
        self.testnetNetworkSubmitPerformed = try container.decode(Bool.self, forKey: .testnetNetworkSubmitPerformed)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretAutoRead = try container.decode(Bool.self, forKey: .productionSecretAutoRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.brokerEndpointConnected = try container.decode(Bool.self, forKey: .brokerEndpointConnected)
        self.productionOrderSubmitted = try container.decode(Bool.self, forKey: .productionOrderSubmitted)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        self.validationAnchors = try container.decode([String].self, forKey: .validationAnchors)

        let expectedID = Self.deterministicID(
            intentID: intentID,
            signedRequestID: signedRequestID,
            transportResultID: transportResultID
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            runtimeEvidenceID == expectedID,
            field: "releaseV0150SpotTestnetSubmit.runtimeEvidenceID",
            expected: expectedID.rawValue,
            actual: runtimeEvidenceID.rawValue
        )
        try ReleaseV0151CodableDecodeBoundary.require(
            ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.isLowercaseSHA256(redactedClientOrderIDHash),
            field: "releaseV0150SpotTestnetSubmit.redactedClientOrderIDHash",
            expected: "lowercase sha256 digest",
            actual: redactedClientOrderIDHash
        )
        try ReleaseV0151CodableDecodeBoundary.requireHeld(
            boundaryHeld,
            field: "releaseV0150SpotTestnetSubmit.runtimeEvidence.boundaryHeld"
        )
    }

    public var boundaryHeld: Bool {
        productType == .spot
            && endpointHost == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.canonicalSpotTestnetHost
            && endpointPath == ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence.spotOrderEndpointPath
            && orderLifecycleState == .submittedTestnet
            && explicitTestnetMode
            && spotTestnetOnly
            && operatorConfirmedTestnetSubmit
            && requestBodyRedacted
            && responseBodyRedacted
            && credentialMaterialRedacted
            && clientOrderIdentityMaterialRedacted
            && clientOrderIdentityMaterialStored == false
            && clientOrderIdentityReferenceID.rawValue.hasPrefix("gh-1099-v0151-client-order-reference:")
            && redactedClientOrderIDHash.count == 64
            && appendOnlyEvidenceCreated
            && testnetNetworkSubmitPerformed
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME",
        "TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT",
        "V0150-003-ORDERINTENT-TO-SIGNED-SUBMIT",
        "V0150-003-REDACTED-RESPONSE-EVIDENCE",
        "V0150-003-TESTNET-NETWORK-SUBMIT-PERFORMED",
        "V0150-003-PRODUCTION-ENDPOINT-BLOCKED",
        "V0150-003-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        intentID: Identifier,
        signedRequestID: Identifier,
        transportResultID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1068-spot-testnet-submit-runtime:\(intentID.rawValue):\(signedRequestID.rawValue):\(transportResultID.rawValue)",
            field: "releaseV0150SpotTestnetSubmit.runtimeEvidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.runtimeEvidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetSubmitRuntime 串起 OrderIntent、signed request 和 transport result。
///
/// Runtime 只接受 Binance Spot、RiskEngine 已接受的 ExecutionContract mapping 和显式 operator
/// confirmation。它通过注入式 transport 执行 Spot Testnet submit，并把结果压缩成 redacted
/// evidence；它不创建 production adapter，不读取 production secret，不连接 production host。
public struct ReleaseV0150BinanceSpotTestnetSubmitRuntime: Sendable {
    public let requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder
    private let transport: any ReleaseV0150BinanceSpotTestnetSubmitTransport

    public init(
        requestBuilder: ReleaseV0150BinanceSpotTestnetSignedRequestBuilder,
        transport: any ReleaseV0150BinanceSpotTestnetSubmitTransport
    ) {
        self.requestBuilder = requestBuilder
        self.transport = transport
    }

    public func submitMarketOrder(
        intent: OrderIntent,
        mapping: ExecutionContractRequestMapping,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        operatorConfirmationID: Identifier,
        runtimeGate: ReleaseV0151BinanceSpotTestnetRuntimeInternalGate,
        timestamp: Date,
        receiveWindowMilliseconds: Int = 5_000
    ) async throws -> ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence {
        guard requestBuilder.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.requestBuilder")
        }
        guard intent.isPreRiskEngineIntent,
              intent.instrument.productType == .spot,
              mapping.boundaryHeld,
              mapping.intentID == intent.intentID,
              mapping.operation == .submit,
              mapping.mode == .binanceTestnet,
	              mapping.lifecycleState == .riskAccepted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150SpotTestnetSubmit.intentMapping")
        }
        try runtimeGate.requireTransportAllowed(
            action: .submit,
            intentIDs: [intent.intentID],
            mappingIDs: [mapping.mappingID],
            operatorConfirmationID: operatorConfirmationID
        )

        let signedRequest = try requestBuilder.buildMarketSubmitRequest(
            credential: credential,
            symbol: intent.instrument.symbol,
            side: intent.side,
            quantity: intent.quantity,
            timestamp: timestamp,
            receiveWindowMilliseconds: receiveWindowMilliseconds
        )
        let operatorGate = try ReleaseV0150BinanceSpotTestnetSubmitOperatorGate(
            gateID: ReleaseV0150BinanceSpotTestnetSubmitOperatorGate.deterministicID(
                strategyRunID: intent.correlation.strategyRunID,
                credentialReferenceID: credential.reference.referenceID,
                signedRequestID: signedRequest.requestID,
                operatorConfirmationID: operatorConfirmationID
            ),
            operatorConfirmationID: operatorConfirmationID,
            strategyRunID: intent.correlation.strategyRunID,
            credentialReferenceID: credential.reference.referenceID,
            signedRequestID: signedRequest.requestID
        )
        let transportResult = try await transport.submitSpotTestnetOrder(
            signedRequest: signedRequest,
            credential: credential
        )

        return try ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence(
            runtimeEvidenceID: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence.deterministicID(
                intentID: intent.intentID,
                signedRequestID: signedRequest.requestID,
                transportResultID: transportResult.transportResultID
            ),
            intent: intent,
            mapping: mapping,
            signedRequest: signedRequest,
            operatorGate: operatorGate,
            transportResult: transportResult
        )
    }
}
