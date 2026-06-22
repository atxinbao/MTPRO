import DomainModel
import Foundation

/// ReleaseV0140BinanceTestnetSubmitOperatorGate 固定 GH-1029 的人工确认门禁。
///
/// 该 gate 只允许显式 Binance testnet submit 证据进入后续链路；它不读取 credential、
/// 不连接生产 endpoint，也不授权 production cutover。operator confirmation 必须与
/// OrderIntent 的 strategy run identity 绑定，避免跨 run 复用确认。
public struct ReleaseV0140BinanceTestnetSubmitOperatorGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let operatorConfirmationID: Identifier
    public let strategyRunID: Identifier
    public let explicitTestnetMode: Bool
    public let operatorConfirmedTestnetSubmit: Bool
    public let acknowledgesNoProductionTrading: Bool
    public let credentialReferenceRedacted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        gateID: Identifier,
        operatorConfirmationID: Identifier,
        strategyRunID: Identifier,
        explicitTestnetMode: Bool = true,
        operatorConfirmedTestnetSubmit: Bool = true,
        acknowledgesNoProductionTrading: Bool = true,
        credentialReferenceRedacted: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard explicitTestnetMode else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.operatorGate.explicitTestnetMode",
                expected: "true",
                actual: "false"
            )
        }
        guard operatorConfirmedTestnetSubmit else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.operatorGate.operatorConfirmedTestnetSubmit",
                expected: "true",
                actual: "false"
            )
        }
        guard acknowledgesNoProductionTrading else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.operatorGate.acknowledgesNoProductionTrading",
                expected: "true",
                actual: "false"
            )
        }
        guard credentialReferenceRedacted else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.operatorGate.credentialReferenceRedacted",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.gateID = gateID
        self.operatorConfirmationID = operatorConfirmationID
        self.strategyRunID = strategyRunID
        self.explicitTestnetMode = explicitTestnetMode
        self.operatorConfirmedTestnetSubmit = operatorConfirmedTestnetSubmit
        self.acknowledgesNoProductionTrading = acknowledgesNoProductionTrading
        self.credentialReferenceRedacted = credentialReferenceRedacted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && operatorConfirmedTestnetSubmit
            && acknowledgesNoProductionTrading
            && credentialReferenceRedacted
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func fixture(
        correlation: OrderIntentCorrelationMetadata
    ) throws -> ReleaseV0140BinanceTestnetSubmitOperatorGate {
        try ReleaseV0140BinanceTestnetSubmitOperatorGate(
            gateID: deterministicGateID(correlation: correlation),
            operatorConfirmationID: deterministicConfirmationID(correlation: correlation),
            strategyRunID: correlation.strategyRunID
        )
    }

    public static func deterministicGateID(correlation: OrderIntentCorrelationMetadata) -> Identifier {
        .constant(
            "gh-1029-binance-testnet-submit-gate:\(correlation.strategyRunID.rawValue):\(correlation.sourceSequence)",
            field: "releaseV0140BinanceTestnetSubmit.gateID"
        )
    }

    public static func deterministicConfirmationID(correlation: OrderIntentCorrelationMetadata) -> Identifier {
        .constant(
            "gh-1029-binance-testnet-submit-confirmation:\(correlation.strategyRunID.rawValue):\(correlation.sourceSequence)",
            field: "releaseV0140BinanceTestnetSubmit.operatorConfirmationID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.operatorGate.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetSubmitRequestEvidence 记录 GH-1029 submit request 的可审计证据。
///
/// 该类型把 OrderIntent、riskAccepted ExecutionContract mapping、Binance testnet endpoint
/// 与 operator gate 绑定。它只保存 redacted request evidence，不创建网络对象、不携带
/// credential material、不提交 production order。
public struct ReleaseV0140BinanceTestnetSubmitRequestEvidence: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let mappingID: Identifier
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int
    public let productType: ProductType
    public let symbol: Symbol
    public let side: OrderIntentSide
    public let quantityText: String
    public let timeInForce: OrderIntentTimeInForce
    public let endpointHost: String
    public let endpointPath: String
    public let operatorGateID: Identifier
    public let explicitTestnetMode: Bool
    public let testnetOnly: Bool
    public let testnetSubmitEvidenceAllowed: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let networkSubmitPerformed: Bool
    public let cancelReplaceIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case requestID
        case mappingID
        case intentID
        case strategyRunID
        case sourceSequence
        case productType
        case symbol
        case side
        case quantityText
        case timeInForce
        case endpointHost
        case endpointPath
        case operatorGateID
        case explicitTestnetMode
        case testnetOnly
        case testnetSubmitEvidenceAllowed
        case requestBodyRedacted
        case credentialMaterialRedacted
        case networkSubmitPerformed
        case cancelReplaceIncluded
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case productionCutoverAuthorized
    }

    public init(
        requestID: Identifier,
        intent: OrderIntent,
        mapping: ExecutionContractRequestMapping,
        endpoint: ReleaseV0140BinanceTestnetEndpointReference,
        operatorGate: ReleaseV0140BinanceTestnetSubmitOperatorGate,
        endpointPath: String? = nil,
        explicitTestnetMode: Bool = true,
        testnetOnly: Bool = true,
        testnetSubmitEvidenceAllowed: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        networkSubmitPerformed: Bool = false,
        cancelReplaceIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard intent.isPreRiskEngineIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.intentBoundary",
                expected: "pre-RiskEngine OrderIntent",
                actual: "non-boundary-held intent"
            )
        }
        guard mapping.boundaryHeld,
              mapping.intentID == intent.intentID,
              mapping.operation == .submit,
              mapping.mode == .binanceTestnet,
              mapping.lifecycleState == .riskAccepted,
              mapping.targetLifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.mapping",
                expected: "riskAccepted Binance testnet submit mapping",
                actual: "\(mapping.operation.rawValue):\(mapping.mode.rawValue):\(mapping.lifecycleState.rawValue)"
            )
        }
        guard endpoint.boundaryHeld, endpoint.productType == intent.instrument.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.endpoint",
                expected: "matching boundary-held Binance testnet endpoint",
                actual: endpoint.productType.rawValue
            )
        }
        guard operatorGate.boundaryHeld, operatorGate.strategyRunID == intent.correlation.strategyRunID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.operatorGate",
                expected: intent.correlation.strategyRunID.rawValue,
                actual: operatorGate.strategyRunID.rawValue
            )
        }
        guard explicitTestnetMode, testnetOnly, testnetSubmitEvidenceAllowed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.nonTestnetSubmitEvidence")
        }
        guard requestBodyRedacted, credentialMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.unredactedRequestEvidence")
        }
        try Self.forbid(networkSubmitPerformed, "networkSubmitPerformed")
        try Self.forbid(cancelReplaceIncluded, "cancelReplaceIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        let resolvedEndpointPath = endpointPath ?? Self.orderEndpointPath(for: endpoint.productType)
        guard resolvedEndpointPath == Self.orderEndpointPath(for: endpoint.productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.endpointPath",
                expected: Self.orderEndpointPath(for: endpoint.productType),
                actual: resolvedEndpointPath
            )
        }
        guard requestID == Self.deterministicID(
            mappingID: mapping.mappingID,
            productType: endpoint.productType,
            sourceSequence: intent.correlation.sourceSequence
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.requestID",
                expected: Self.deterministicID(
                    mappingID: mapping.mappingID,
                    productType: endpoint.productType,
                    sourceSequence: intent.correlation.sourceSequence
                ).rawValue,
                actual: requestID.rawValue
            )
        }

        self.requestID = requestID
        self.mappingID = mapping.mappingID
        self.intentID = intent.intentID
        self.strategyRunID = intent.correlation.strategyRunID
        self.sourceSequence = intent.correlation.sourceSequence
        self.productType = intent.instrument.productType
        self.symbol = intent.instrument.symbol
        self.side = intent.side
        self.quantityText = Self.quantityText(intent.quantity)
        self.timeInForce = intent.policy.timeInForce
        self.endpointHost = endpoint.baseURL.host?.lowercased() ?? ""
        self.endpointPath = resolvedEndpointPath
        self.operatorGateID = operatorGate.gateID
        self.explicitTestnetMode = explicitTestnetMode
        self.testnetOnly = testnetOnly
        self.testnetSubmitEvidenceAllowed = testnetSubmitEvidenceAllowed
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.networkSubmitPerformed = networkSubmitPerformed
        self.cancelReplaceIncluded = cancelReplaceIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestID = try container.decode(Identifier.self, forKey: .requestID)
        self.mappingID = try container.decode(Identifier.self, forKey: .mappingID)
        self.intentID = try container.decode(Identifier.self, forKey: .intentID)
        self.strategyRunID = try container.decode(Identifier.self, forKey: .strategyRunID)
        self.sourceSequence = try container.decode(Int.self, forKey: .sourceSequence)
        self.productType = try container.decode(ProductType.self, forKey: .productType)
        self.symbol = try container.decode(Symbol.self, forKey: .symbol)
        self.side = try container.decode(OrderIntentSide.self, forKey: .side)
        self.quantityText = try container.decode(String.self, forKey: .quantityText)
        self.timeInForce = try container.decode(OrderIntentTimeInForce.self, forKey: .timeInForce)
        self.endpointHost = try container.decode(String.self, forKey: .endpointHost)
        self.endpointPath = try container.decode(String.self, forKey: .endpointPath)
        self.operatorGateID = try container.decode(Identifier.self, forKey: .operatorGateID)
        self.explicitTestnetMode = try container.decode(Bool.self, forKey: .explicitTestnetMode)
        self.testnetOnly = try container.decode(Bool.self, forKey: .testnetOnly)
        self.testnetSubmitEvidenceAllowed = try container.decode(Bool.self, forKey: .testnetSubmitEvidenceAllowed)
        self.requestBodyRedacted = try container.decode(Bool.self, forKey: .requestBodyRedacted)
        self.credentialMaterialRedacted = try container.decode(Bool.self, forKey: .credentialMaterialRedacted)
        self.networkSubmitPerformed = try container.decode(Bool.self, forKey: .networkSubmitPerformed)
        self.cancelReplaceIncluded = try container.decode(Bool.self, forKey: .cancelReplaceIncluded)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretRead = try container.decode(Bool.self, forKey: .productionSecretRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)

        try Self.validateDecoded(sourceSequence > 0, field: "sourceSequence")
        try Self.validateDecoded(quantityText.isEmpty == false, field: "quantityText")
        try Self.validateDecoded(boundaryHeld, field: "boundaryHeld")
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && testnetOnly
            && testnetSubmitEvidenceAllowed
            && requestBodyRedacted
            && credentialMaterialRedacted
            && networkSubmitPerformed == false
            && cancelReplaceIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && endpointHost == ReleaseV0140BinanceTestnetEndpointReference.expectedHost(for: productType)
            && endpointPath == Self.orderEndpointPath(for: productType)
    }

    public static func deterministicID(
        mappingID: Identifier,
        productType: ProductType,
        sourceSequence: Int
    ) -> Identifier {
        .constant(
            "gh-1029-binance-testnet-submit-request:\(mappingID.rawValue):\(productType.rawValue):\(sourceSequence)",
            field: "releaseV0140BinanceTestnetSubmit.requestID"
        )
    }

    public static func orderEndpointPath(for productType: ProductType) -> String {
        switch productType {
        case .spot:
            "/api/v3/order"
        case .usdsPerpetual:
            "/fapi/v1/order"
        }
    }

    public static func quantityText(_ quantity: Quantity) -> String {
        String(format: "%.8f", locale: Locale(identifier: "en_US_POSIX"), quantity.rawValue)
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.requestEvidence.\(field)")
        }
    }

    private static func validateDecoded(_ condition: Bool, field: String) throws {
        guard condition else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.requestEvidence.decode.\(field)",
                expected: "boundary-held decoded evidence",
                actual: "invalid decoded payload"
            )
        }
    }
}

/// ReleaseV0140BinanceTestnetSubmitResponseEvidence 记录 GH-1029 submit response 的脱敏证据。
///
/// response evidence 只承接 ExecutionContractSubmissionResult 与 acknowledgement，并要求
/// exchange order identity 和 response payload 全部 redacted。它不是 broker fill、不是 OMS
/// reconciliation，也不表示 production order 被接受。
public struct ReleaseV0140BinanceTestnetSubmitResponseEvidence: Codable, Equatable, Sendable {
    public let responseID: Identifier
    public let requestID: Identifier
    public let mappingID: Identifier
    public let resultID: Identifier
    public let acknowledgementID: Identifier
    public let lifecycleState: OrderLifecycleState
    public let acceptedByAdapter: Bool
    public let exchangeOrderIDRedacted: Bool
    public let responseBodyRedacted: Bool
    public let networkSubmitPerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case responseID
        case requestID
        case mappingID
        case resultID
        case acknowledgementID
        case lifecycleState
        case acceptedByAdapter
        case exchangeOrderIDRedacted
        case responseBodyRedacted
        case networkSubmitPerformed
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case productionCutoverAuthorized
    }

    public init(
        responseID: Identifier,
        request: ReleaseV0140BinanceTestnetSubmitRequestEvidence,
        result: ExecutionContractSubmissionResult,
        acknowledgement: ExecutionContractAcknowledgement,
        acceptedByAdapter: Bool = true,
        exchangeOrderIDRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        networkSubmitPerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard request.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.requestEvidence",
                expected: "boundary-held request evidence",
                actual: "invalid request evidence"
            )
        }
        guard result.boundaryHeld,
              result.mappingID == request.mappingID,
              result.operation == .submit,
              result.mode == .binanceTestnet,
              result.lifecycleState == .submittedTestnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.result",
                expected: "submittedTestnet submit result",
                actual: "\(result.operation.rawValue):\(result.mode.rawValue):\(result.lifecycleState.rawValue)"
            )
        }
        guard acknowledgement.resultID == result.resultID,
              acknowledgement.lifecycleState == .accepted,
              acknowledgement.authorizesProductionTrading == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.acknowledgement",
                expected: "accepted acknowledgement for submit result",
                actual: acknowledgement.lifecycleState.rawValue
            )
        }
        guard acceptedByAdapter, exchangeOrderIDRedacted, responseBodyRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.unredactedOrRejectedResponse")
        }
        try Self.forbid(networkSubmitPerformed, "networkSubmitPerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard responseID == Self.deterministicID(
            requestID: request.requestID,
            resultID: result.resultID,
            acknowledgementID: acknowledgement.acknowledgementID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.responseID",
                expected: Self.deterministicID(
                    requestID: request.requestID,
                    resultID: result.resultID,
                    acknowledgementID: acknowledgement.acknowledgementID
                ).rawValue,
                actual: responseID.rawValue
            )
        }

        self.responseID = responseID
        self.requestID = request.requestID
        self.mappingID = request.mappingID
        self.resultID = result.resultID
        self.acknowledgementID = acknowledgement.acknowledgementID
        self.lifecycleState = acknowledgement.lifecycleState
        self.acceptedByAdapter = acceptedByAdapter
        self.exchangeOrderIDRedacted = exchangeOrderIDRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.networkSubmitPerformed = networkSubmitPerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responseID = try container.decode(Identifier.self, forKey: .responseID)
        self.requestID = try container.decode(Identifier.self, forKey: .requestID)
        self.mappingID = try container.decode(Identifier.self, forKey: .mappingID)
        self.resultID = try container.decode(Identifier.self, forKey: .resultID)
        self.acknowledgementID = try container.decode(Identifier.self, forKey: .acknowledgementID)
        self.lifecycleState = try container.decode(OrderLifecycleState.self, forKey: .lifecycleState)
        self.acceptedByAdapter = try container.decode(Bool.self, forKey: .acceptedByAdapter)
        self.exchangeOrderIDRedacted = try container.decode(Bool.self, forKey: .exchangeOrderIDRedacted)
        self.responseBodyRedacted = try container.decode(Bool.self, forKey: .responseBodyRedacted)
        self.networkSubmitPerformed = try container.decode(Bool.self, forKey: .networkSubmitPerformed)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretRead = try container.decode(Bool.self, forKey: .productionSecretRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)

        try Self.validateDecoded(boundaryHeld, field: "boundaryHeld")
    }

    public var boundaryHeld: Bool {
        lifecycleState == .accepted
            && acceptedByAdapter
            && exchangeOrderIDRedacted
            && responseBodyRedacted
            && networkSubmitPerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        requestID: Identifier,
        resultID: Identifier,
        acknowledgementID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1029-binance-testnet-submit-response:\(requestID.rawValue):\(resultID.rawValue):\(acknowledgementID.rawValue)",
            field: "releaseV0140BinanceTestnetSubmit.responseID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.responseEvidence.\(field)")
        }
    }

    private static func validateDecoded(_ condition: Bool, field: String) throws {
        guard condition else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.responseEvidence.decode.\(field)",
                expected: "boundary-held decoded evidence",
                actual: "invalid decoded payload"
            )
        }
    }
}

/// ReleaseV0140BinanceTestnetSubmitPath 汇总 GH-1029 submit path 的可审计证据链。
///
/// 该路径只证明 OrderIntent -> ExecutionContract mapping -> testnet submit request/response
/// evidence 的字段绑定关系；它不实现 cancel / replace，不创建 broker adapter，不打开生产交易。
public struct ReleaseV0140BinanceTestnetSubmitPath: Codable, Equatable, Sendable {
    public let pathID: Identifier
    public let boundaryID: Identifier
    public let operatorGateID: Identifier
    public let requestID: Identifier
    public let responseID: Identifier
    public let resultID: Identifier
    public let acknowledgementID: Identifier
    public let testnetSubmitPathAllowed: Bool
    public let testnetSubmitEvidenceOnly: Bool
    public let networkSubmitPerformed: Bool
    public let cancelReplaceIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    private enum CodingKeys: String, CodingKey {
        case pathID
        case boundaryID
        case operatorGateID
        case requestID
        case responseID
        case resultID
        case acknowledgementID
        case testnetSubmitPathAllowed
        case testnetSubmitEvidenceOnly
        case networkSubmitPerformed
        case cancelReplaceIncluded
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case productionCutoverAuthorized
        case validationAnchors
    }

    public init(
        pathID: Identifier,
        boundary: ReleaseV0140BinanceTestnetAdapterBoundary,
        operatorGate: ReleaseV0140BinanceTestnetSubmitOperatorGate,
        request: ReleaseV0140BinanceTestnetSubmitRequestEvidence,
        result: ExecutionContractSubmissionResult,
        acknowledgement: ExecutionContractAcknowledgement,
        response: ReleaseV0140BinanceTestnetSubmitResponseEvidence,
        testnetSubmitPathAllowed: Bool = true,
        testnetSubmitEvidenceOnly: Bool = true,
        networkSubmitPerformed: Bool = false,
        cancelReplaceIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard boundary.boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.boundary",
                expected: "GH-1028 boundary-held adapter boundary",
                actual: "invalid boundary"
            )
        }
        guard operatorGate.boundaryHeld,
              request.boundaryHeld,
              result.boundaryHeld,
              response.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.unheldEvidence")
        }
        guard request.mappingID == result.mappingID,
              response.requestID == request.requestID,
              response.resultID == result.resultID,
              response.acknowledgementID == acknowledgement.acknowledgementID,
              acknowledgement.resultID == result.resultID,
              acknowledgement.authorizesProductionTrading == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.evidenceLinks",
                expected: "request/result/acknowledgement/response IDs linked",
                actual: "unlinked evidence"
            )
        }
        guard testnetSubmitPathAllowed, testnetSubmitEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.nonEvidenceSubmitPath")
        }
        try Self.forbid(networkSubmitPerformed, "networkSubmitPerformed")
        try Self.forbid(cancelReplaceIncluded, "cancelReplaceIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard pathID == Self.deterministicID(
            requestID: request.requestID,
            responseID: response.responseID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.pathID",
                expected: Self.deterministicID(requestID: request.requestID, responseID: response.responseID).rawValue,
                actual: pathID.rawValue
            )
        }

        self.pathID = pathID
        self.boundaryID = boundary.boundaryID
        self.operatorGateID = operatorGate.gateID
        self.requestID = request.requestID
        self.responseID = response.responseID
        self.resultID = result.resultID
        self.acknowledgementID = acknowledgement.acknowledgementID
        self.testnetSubmitPathAllowed = testnetSubmitPathAllowed
        self.testnetSubmitEvidenceOnly = testnetSubmitEvidenceOnly
        self.networkSubmitPerformed = networkSubmitPerformed
        self.cancelReplaceIncluded = cancelReplaceIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pathID = try container.decode(Identifier.self, forKey: .pathID)
        self.boundaryID = try container.decode(Identifier.self, forKey: .boundaryID)
        self.operatorGateID = try container.decode(Identifier.self, forKey: .operatorGateID)
        self.requestID = try container.decode(Identifier.self, forKey: .requestID)
        self.responseID = try container.decode(Identifier.self, forKey: .responseID)
        self.resultID = try container.decode(Identifier.self, forKey: .resultID)
        self.acknowledgementID = try container.decode(Identifier.self, forKey: .acknowledgementID)
        self.testnetSubmitPathAllowed = try container.decode(Bool.self, forKey: .testnetSubmitPathAllowed)
        self.testnetSubmitEvidenceOnly = try container.decode(Bool.self, forKey: .testnetSubmitEvidenceOnly)
        self.networkSubmitPerformed = try container.decode(Bool.self, forKey: .networkSubmitPerformed)
        self.cancelReplaceIncluded = try container.decode(Bool.self, forKey: .cancelReplaceIncluded)
        self.productionTradingEnabledByDefault = try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault)
        self.productionSecretRead = try container.decode(Bool.self, forKey: .productionSecretRead)
        self.productionEndpointConnected = try container.decode(Bool.self, forKey: .productionEndpointConnected)
        self.productionCutoverAuthorized = try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        self.validationAnchors = try container.decode([String].self, forKey: .validationAnchors)

        try Self.validateDecoded(boundaryHeld, field: "boundaryHeld")
    }

    public var boundaryHeld: Bool {
        testnetSubmitPathAllowed
            && testnetSubmitEvidenceOnly
            && networkSubmitPerformed == false
            && cancelReplaceIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1029-BINANCE-TESTNET-SUBMIT-PATH",
        "GH-1029-BINANCE-TESTNET-OPERATOR-GATE",
        "GH-1029-BINANCE-TESTNET-REDACTED-REQUEST-RESPONSE",
        "TVM-RELEASE-V0140-BINANCE-TESTNET-SUBMIT"
    ]

    public static func deterministicID(requestID: Identifier, responseID: Identifier) -> Identifier {
        .constant(
            "gh-1029-binance-testnet-submit-path:\(requestID.rawValue):\(responseID.rawValue)",
            field: "releaseV0140BinanceTestnetSubmit.pathID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetSubmit.path.\(field)")
        }
    }

    private static func validateDecoded(_ condition: Bool, field: String) throws {
        guard condition else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetSubmit.path.decode.\(field)",
                expected: "boundary-held decoded evidence",
                actual: "invalid decoded payload"
            )
        }
    }
}
