import DomainModel
import Foundation
import MessageBus

/// ReleaseV030BinanceAdapterRehearsalCommandKind 固定 GH-663 允许的 Binance command mapping。
///
/// 这些 command 只代表 dry-run / testnet request mapping evidence，不代表真实 broker command、
/// production order command 或 production cutover 授权。
public enum ReleaseV030BinanceAdapterRehearsalCommandKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case replace
}

/// ReleaseV030BinanceAdapterRehearsalMode 区分当前 #663 允许的 dry-run 和 testnet mapping。
public enum ReleaseV030BinanceAdapterRehearsalMode:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case dryRun = "dry-run"
    case testnet
}

/// ReleaseV030BinanceAdapterRehearsalHTTPMethod 固定 Binance command mapping 的本地 HTTP method evidence。
public enum ReleaseV030BinanceAdapterRehearsalHTTPMethod:
    String,
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

/// ReleaseV030BinanceAdapterRehearsalRequirement 固定 GH-663 的验收要求。
public enum ReleaseV030BinanceAdapterRehearsalRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamOMSRehearsalRequired = "upstream GH-662 OMS rehearsal evidence required"
    case submitMappingRequired = "submit mapping evidence required"
    case cancelMappingRequired = "cancel mapping evidence required"
    case replaceMappingRequired = "replace mapping evidence required"
    case dryRunEvidenceRequired = "dry-run evidence required"
    case testnetEvidenceRequired = "testnet evidence required"
    case productionEndpointBlocked = "production endpoint blocked by default"
    case rawBrokerPayloadNotExposedToDashboard = "raw broker payload not exposed to Dashboard"
}

/// ReleaseV030BinanceAdapterRehearsalForbiddenCapability 枚举 #663 必须保持关闭的能力。
public enum ReleaseV030BinanceAdapterRehearsalForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case productionBrokerGateway = "production broker gateway"
    case rawBrokerPayloadDashboardExposure = "raw broker payload Dashboard exposure"
    case liveCommandSurface = "live command surface"
    case commandGatewayBypass = "CommandGateway bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case omsBypass = "OMS bypass"
    case eventStoreBypass = "Event Store bypass"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedStrategy = "unsupported strategy"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030BinanceAdapterRehearsalQueryItem 是 redacted Binance request 参数。
///
/// Query item 只保留参数名和值；signature、API key、secret material 和 raw broker payload 不进入该结构。
public struct ReleaseV030BinanceAdapterRehearsalQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.queryItem.name",
                expected: "non-empty query item name",
                actual: "empty"
            )
        }
        guard trimmedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.queryItem.value",
                expected: "non-empty query item value",
                actual: "empty"
            )
        }
        guard trimmedName.lowercased() != "signature" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.signatureValue")
        }

        self.name = trimmedName
        self.value = trimmedValue
    }
}

/// ReleaseV030BinanceAdapterRehearsalOMSHandoff 是 ExecutionClient 侧消费 #662 的最小 handoff identity。
///
/// ExecutionClient target 不依赖 ExecutionEngine target，因此这里保存 #662 的稳定 issue、order、event
/// 和 validation anchor，不直接 import `ReleaseV030ExecutionOMSRehearsalEvidence`。
public struct ReleaseV030BinanceAdapterRehearsalOMSHandoff: Codable, Equatable, Sendable {
    public let handoffID: Identifier
    public let sourceIssueID: Identifier
    public let sourceRiskIssueID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceLifecyclePath: String
    public let sourceFinalState: String
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let quantity: Quantity
    public let referencePrice: Price
    public let stateEvidence: [String]
    public let sourceValidationAnchors: [String]
    public let sourceReplayEvidenceHeld: Bool
    public let sourceBoundaryHeld: Bool
    public let authorizesProductionOrder: Bool
    public let exposesRawBrokerPayloadToDashboard: Bool

    public init(
        handoffID: Identifier,
        sourceIssueID: Identifier = Identifier.constant("GH-662"),
        sourceRiskIssueID: Identifier = Identifier.constant("GH-661"),
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        sourceLifecyclePath: String,
        sourceFinalState: String,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        quantity: Quantity,
        referencePrice: Price,
        stateEvidence: [String],
        sourceValidationAnchors: [String] = [
            "V030-06-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE",
            "V030-06-OMS-REPLAY-EVIDENCE",
            "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE"
        ],
        sourceReplayEvidenceHeld: Bool = true,
        sourceBoundaryHeld: Bool = true,
        authorizesProductionOrder: Bool = false,
        exposesRawBrokerPayloadToDashboard: Bool = false
    ) throws {
        guard sourceIssueID.rawValue == "GH-662" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.sourceIssueID",
                expected: "GH-662",
                actual: sourceIssueID.rawValue
            )
        }
        guard sourceRiskIssueID.rawValue == "GH-661" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.sourceRiskIssueID",
                expected: "GH-661",
                actual: sourceRiskIssueID.rawValue
            )
        }
        guard instrument.productType == .spot || instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.unsupportedProductType")
        }
        guard targetExposure.requiresOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.targetExposure",
                expected: "order-intent-producing target exposure",
                actual: targetExposure.rawValue
            )
        }
        guard quantity.rawValue > 0, referencePrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.notionalInput",
                expected: "positive quantity and reference price",
                actual: "\(quantity.rawValue)@\(referencePrice.rawValue)"
            )
        }
        guard stateEvidence.contains("submitted-testnet-or-dry-run") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.stateEvidence",
                expected: "submitted-testnet-or-dry-run",
                actual: stateEvidence.joined(separator: ",")
            )
        }
        guard ["filled-simulated", "cancelled"].contains(sourceFinalState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.sourceFinalState",
                expected: "filled-simulated or cancelled rehearsal handoff",
                actual: sourceFinalState
            )
        }
        guard sourceValidationAnchors.contains("TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.sourceValidationAnchors",
                expected: "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE",
                actual: sourceValidationAnchors.joined(separator: ",")
            )
        }
        guard sourceReplayEvidenceHeld, sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.sourceBoundary",
                expected: "held replay and boundary evidence",
                actual: "\(sourceReplayEvidenceHeld):\(sourceBoundaryHeld)"
            )
        }
        try Self.forbid(authorizesProductionOrder, "authorizesProductionOrder")
        try Self.forbid(exposesRawBrokerPayloadToDashboard, "exposesRawBrokerPayloadToDashboard")

        self.handoffID = handoffID
        self.sourceIssueID = sourceIssueID
        self.sourceRiskIssueID = sourceRiskIssueID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceLifecyclePath = sourceLifecyclePath
        self.sourceFinalState = sourceFinalState
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.stateEvidence = stateEvidence
        self.sourceValidationAnchors = sourceValidationAnchors
        self.sourceReplayEvidenceHeld = sourceReplayEvidenceHeld
        self.sourceBoundaryHeld = sourceBoundaryHeld
        self.authorizesProductionOrder = authorizesProductionOrder
        self.exposesRawBrokerPayloadToDashboard = exposesRawBrokerPayloadToDashboard
    }

    public var handoffHeld: Bool {
        sourceIssueID.rawValue == "GH-662"
            && sourceRiskIssueID.rawValue == "GH-661"
            && stateEvidence.contains("submitted-testnet-or-dry-run")
            && sourceReplayEvidenceHeld
            && sourceBoundaryHeld
            && authorizesProductionOrder == false
            && exposesRawBrokerPayloadToDashboard == false
    }

    public static func deterministicSpotFixture() throws -> ReleaseV030BinanceAdapterRehearsalOMSHandoff {
        let symbol = Symbol.constant("BTCUSDT")
        return try ReleaseV030BinanceAdapterRehearsalOMSHandoff(
            handoffID: Identifier.constant("gh-663-spot-oms-handoff"),
            sourceOrderIntentID: Identifier.constant("gh-662-accepted-submitted-filled-order-intent"),
            sourceEventLogID: Identifier.constant("gh-662-accepted-submitted-filled-order-event-log"),
            sourceOMSOrderID: Identifier.constant("gh-662-accepted-submitted-filled-order"),
            sourceLifecyclePath: "accepted-submitted-filled",
            sourceFinalState: "filled-simulated",
            instrument: InstrumentIdentity.binance(productType: .spot, symbol: symbol),
            targetExposure: .targetLong,
            quantity: Quantity(0.10, field: "gh663SpotQuantity"),
            referencePrice: Price(43_000, field: "gh663SpotReferencePrice"),
            stateEvidence: ["created", "accepted", "submitted-testnet-or-dry-run", "filled-simulated"]
        )
    }

    public static func deterministicPerpFixture() throws -> ReleaseV030BinanceAdapterRehearsalOMSHandoff {
        let symbol = Symbol.constant("BTCUSDT")
        return try ReleaseV030BinanceAdapterRehearsalOMSHandoff(
            handoffID: Identifier.constant("gh-663-perp-oms-handoff"),
            sourceOrderIntentID: Identifier.constant("gh-662-accepted-submitted-cancelled-order-intent"),
            sourceEventLogID: Identifier.constant("gh-662-accepted-submitted-cancelled-order-event-log"),
            sourceOMSOrderID: Identifier.constant("gh-662-accepted-submitted-cancelled-order"),
            sourceLifecyclePath: "accepted-submitted-cancelled",
            sourceFinalState: "cancelled",
            instrument: InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol),
            targetExposure: .targetShort,
            quantity: Quantity(0.08, field: "gh663PerpQuantity"),
            referencePrice: Price(43_050, field: "gh663PerpReferencePrice"),
            stateEvidence: ["created", "accepted", "submitted-testnet-or-dry-run", "cancelled"]
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.handoff.\(field)")
        }
    }
}

/// ReleaseV030BinanceAdapterRehearsalRequestMapping 是 dry-run / testnet 共用的 redacted mapping evidence。
public struct ReleaseV030BinanceAdapterRehearsalRequestMapping: Codable, Equatable, Sendable {
    public let mappingID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind
    public let mode: ReleaseV030BinanceAdapterRehearsalMode
    public let productType: ProductType
    public let baseURL: URL
    public let method: ReleaseV030BinanceAdapterRehearsalHTTPMethod
    public let endpointPath: String
    public let credentialReferenceID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let side: String
    public let positionSide: String?
    public let reduceOnly: Bool
    public let queryItems: [ReleaseV030BinanceAdapterRehearsalQueryItem]
    public let signatureRequired: Bool
    public let mappingAuditable: Bool
    public let networkCallPerformed: Bool
    public let signatureValueExposed: Bool
    public let productionEndpointTouched: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let brokerGatewayTouched: Bool
    public let rawBrokerPayloadExposedToDashboard: Bool

    public init(
        mappingID: Identifier,
        issueID: Identifier = Identifier.constant("GH-663"),
        upstreamIssueID: Identifier = Identifier.constant("GH-662"),
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind,
        mode: ReleaseV030BinanceAdapterRehearsalMode,
        productType: ProductType,
        baseURL: URL? = nil,
        method: ReleaseV030BinanceAdapterRehearsalHTTPMethod? = nil,
        endpointPath: String? = nil,
        credentialReferenceID: Identifier,
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        side: String,
        positionSide: String? = nil,
        reduceOnly: Bool = false,
        queryItems: [ReleaseV030BinanceAdapterRehearsalQueryItem],
        signatureRequired: Bool = true,
        mappingAuditable: Bool = true,
        networkCallPerformed: Bool = false,
        signatureValueExposed: Bool = false,
        productionEndpointTouched: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        brokerGatewayTouched: Bool = false,
        rawBrokerPayloadExposedToDashboard: Bool = false
    ) throws {
        let resolvedBaseURL = try baseURL ?? Self.defaultTestnetBaseURL(for: productType)
        let resolvedMethod = method ?? Self.method(productType: productType, commandKind: commandKind)
        let resolvedEndpointPath = endpointPath ?? Self.endpointPath(productType: productType, commandKind: commandKind)
        let normalizedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedSide = side.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedPositionSide = positionSide?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard issueID.rawValue == "GH-663", upstreamIssueID.rawValue == "GH-662" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.issueChain",
                expected: "GH-663<-GH-662",
                actual: "\(issueID.rawValue)<-\(upstreamIssueID.rawValue)"
            )
        }
        guard productType == .spot || productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.unsupportedProductType")
        }
        try Self.validateTestnetBaseURL(resolvedBaseURL, productType: productType)
        guard resolvedMethod == Self.method(productType: productType, commandKind: commandKind),
              resolvedEndpointPath == Self.endpointPath(productType: productType, commandKind: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.endpointMapping",
                expected: "\(Self.method(productType: productType, commandKind: commandKind).rawValue) "
                    + Self.endpointPath(productType: productType, commandKind: commandKind),
                actual: "\(resolvedMethod.rawValue) \(resolvedEndpointPath)"
            )
        }
        guard normalizedSymbol.isEmpty == false, ["BUY", "SELL"].contains(normalizedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.symbolSide",
                expected: "non-empty symbol and BUY/SELL side",
                actual: "\(normalizedSymbol):\(normalizedSide)"
            )
        }
        if productType == .spot {
            guard normalizedPositionSide == nil, reduceOnly == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030BinanceAdapter.spotPositionFields",
                    expected: "nil positionSide and reduceOnly false",
                    actual: "\(normalizedPositionSide ?? "nil"):\(reduceOnly)"
                )
            }
        } else {
            guard let normalizedPositionSide,
                  ["LONG", "SHORT"].contains(normalizedPositionSide) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV030BinanceAdapter.perpPositionSide",
                    expected: "LONG or SHORT",
                    actual: normalizedPositionSide ?? "nil"
                )
            }
        }
        guard queryItems.map(\.name) == Self.requiredQueryItemNames(productType: productType, commandKind: commandKind)
        else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.queryItems",
                expected: Self.requiredQueryItemNames(productType: productType, commandKind: commandKind)
                    .joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard signatureRequired, mappingAuditable else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.mappingAudit",
                expected: "signature required and mapping auditable",
                actual: "\(signatureRequired):\(mappingAuditable)"
            )
        }
        try Self.forbid(networkCallPerformed, "networkCallPerformed")
        try Self.forbid(signatureValueExposed, "signatureValueExposed")
        try Self.forbid(productionEndpointTouched, "productionEndpointTouched")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(brokerGatewayTouched, "brokerGatewayTouched")
        try Self.forbid(rawBrokerPayloadExposedToDashboard, "rawBrokerPayloadExposedToDashboard")

        self.mappingID = mappingID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.mode = mode
        self.productType = productType
        self.baseURL = resolvedBaseURL
        self.method = resolvedMethod
        self.endpointPath = resolvedEndpointPath
        self.credentialReferenceID = credentialReferenceID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.clientOrderID = clientOrderID
        self.symbol = normalizedSymbol
        self.side = normalizedSide
        self.positionSide = normalizedPositionSide
        self.reduceOnly = reduceOnly
        self.queryItems = queryItems
        self.signatureRequired = signatureRequired
        self.mappingAuditable = mappingAuditable
        self.networkCallPerformed = networkCallPerformed
        self.signatureValueExposed = signatureValueExposed
        self.productionEndpointTouched = productionEndpointTouched
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.rawBrokerPayloadExposedToDashboard = rawBrokerPayloadExposedToDashboard
    }

    public var mappingHeld: Bool {
        issueID.rawValue == "GH-663"
            && upstreamIssueID.rawValue == "GH-662"
            && Self.isCanonicalTestnetBaseURL(baseURL, productType: productType)
            && method == Self.method(productType: productType, commandKind: commandKind)
            && endpointPath == Self.endpointPath(productType: productType, commandKind: commandKind)
            && queryItems.map(\.name) == Self.requiredQueryItemNames(productType: productType, commandKind: commandKind)
            && signatureRequired
            && mappingAuditable
            && networkCallPerformed == false
            && signatureValueExposed == false
            && productionEndpointTouched == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && brokerGatewayTouched == false
            && rawBrokerPayloadExposedToDashboard == false
    }

    public static func testnetHost(for productType: ProductType) -> String {
        switch productType {
        case .spot:
            "testnet.binance.vision"
        case .usdsPerpetual:
            "testnet.binancefuture.com"
        }
    }

    public static func defaultTestnetBaseURL(for productType: ProductType) throws -> URL {
        guard let url = URL(string: "https://\(testnetHost(for: productType))") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.baseURL",
                expected: "valid deterministic testnet URL",
                actual: productType.rawValue
            )
        }
        return url
    }

    private static func validateTestnetBaseURL(_ baseURL: URL, productType: ProductType) throws {
        guard baseURL.scheme?.lowercased() == "https" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.nonHTTPSBaseURL")
        }
        guard baseURL.host?.lowercased() == testnetHost(for: productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.productionEndpoint")
        }
        guard baseURL.user == nil, baseURL.password == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.baseURLUserInfo")
        }
        guard hasNoPath(baseURL) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.baseURLPath")
        }
        guard baseURL.query == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.baseURLQuery")
        }
    }

    private static func isCanonicalTestnetBaseURL(_ baseURL: URL, productType: ProductType) -> Bool {
        baseURL.scheme?.lowercased() == "https"
            && baseURL.host?.lowercased() == testnetHost(for: productType)
            && baseURL.user == nil
            && baseURL.password == nil
            && hasNoPath(baseURL)
            && baseURL.query == nil
    }

    private static func hasNoPath(_ baseURL: URL) -> Bool {
        baseURL.path.isEmpty || baseURL.path == "/"
    }

    public static func endpointPath(
        productType: ProductType,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind
    ) -> String {
        switch (productType, commandKind) {
        case (.spot, .submit), (.spot, .cancel):
            "/api/v3/order"
        case (.spot, .replace):
            "/api/v3/order/cancelReplace"
        case (.usdsPerpetual, .submit), (.usdsPerpetual, .cancel), (.usdsPerpetual, .replace):
            "/fapi/v1/order"
        }
    }

    public static func method(
        productType: ProductType,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind
    ) -> ReleaseV030BinanceAdapterRehearsalHTTPMethod {
        switch (productType, commandKind) {
        case (.spot, .submit), (.spot, .replace), (.usdsPerpetual, .submit):
            .post
        case (.spot, .cancel), (.usdsPerpetual, .cancel):
            .delete
        case (.usdsPerpetual, .replace):
            .put
        }
    }

    public static func requiredQueryItemNames(
        productType: ProductType,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind
    ) -> [String] {
        switch (productType, commandKind) {
        case (.spot, .submit):
            ["symbol", "side", "type", "timeInForce", "quantity", "price", "newClientOrderId", "recvWindow", "timestamp"]
        case (.spot, .cancel):
            ["symbol", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"]
        case (.spot, .replace):
            [
                "symbol", "side", "type", "timeInForce", "quantity", "price",
                "cancelOrigClientOrderId", "newClientOrderId", "cancelReplaceMode", "recvWindow", "timestamp"
            ]
        case (.usdsPerpetual, .submit):
            [
                "symbol", "side", "positionSide", "type", "timeInForce", "quantity",
                "price", "reduceOnly", "newClientOrderId", "recvWindow", "timestamp"
            ]
        case (.usdsPerpetual, .cancel):
            ["symbol", "origClientOrderId", "recvWindow", "timestamp"]
        case (.usdsPerpetual, .replace):
            [
                "symbol", "side", "positionSide", "quantity", "price",
                "reduceOnly", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"
            ]
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.mapping.\(field)")
        }
    }
}

/// ReleaseV030BinanceAdapterRehearsalAcknowledgement 是 deterministic testnet adapter ack evidence。
public struct ReleaseV030BinanceAdapterRehearsalAcknowledgement: Codable, Equatable, Sendable {
    public let acknowledgementID: Identifier
    public let mappingID: Identifier
    public let commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind
    public let productType: ProductType
    public let mode: ReleaseV030BinanceAdapterRehearsalMode
    public let acceptedByTestnetAdapter: Bool
    public let deterministicTraceID: Identifier
    public let responseStatus: String
    public let productionEndpointTouched: Bool
    public let productionOrderSubmitted: Bool
    public let brokerGatewayTouched: Bool
    public let rawBrokerPayloadExposedToDashboard: Bool

    public init(
        acknowledgementID: Identifier,
        mappingID: Identifier,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind,
        productType: ProductType,
        mode: ReleaseV030BinanceAdapterRehearsalMode = .testnet,
        acceptedByTestnetAdapter: Bool = true,
        deterministicTraceID: Identifier,
        responseStatus: String,
        productionEndpointTouched: Bool = false,
        productionOrderSubmitted: Bool = false,
        brokerGatewayTouched: Bool = false,
        rawBrokerPayloadExposedToDashboard: Bool = false
    ) throws {
        guard mode == .testnet, acceptedByTestnetAdapter, responseStatus.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.ack",
                expected: "accepted testnet acknowledgement",
                actual: "\(mode.rawValue):\(acceptedByTestnetAdapter):\(responseStatus)"
            )
        }
        try Self.forbid(productionEndpointTouched, "productionEndpointTouched")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(brokerGatewayTouched, "brokerGatewayTouched")
        try Self.forbid(rawBrokerPayloadExposedToDashboard, "rawBrokerPayloadExposedToDashboard")

        self.acknowledgementID = acknowledgementID
        self.mappingID = mappingID
        self.commandKind = commandKind
        self.productType = productType
        self.mode = mode
        self.acceptedByTestnetAdapter = acceptedByTestnetAdapter
        self.deterministicTraceID = deterministicTraceID
        self.responseStatus = responseStatus
        self.productionEndpointTouched = productionEndpointTouched
        self.productionOrderSubmitted = productionOrderSubmitted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.rawBrokerPayloadExposedToDashboard = rawBrokerPayloadExposedToDashboard
    }

    public var acknowledgementHeld: Bool {
        mode == .testnet
            && acceptedByTestnetAdapter
            && responseStatus.isEmpty == false
            && productionEndpointTouched == false
            && productionOrderSubmitted == false
            && brokerGatewayTouched == false
            && rawBrokerPayloadExposedToDashboard == false
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.ack.\(field)")
        }
    }
}

/// ReleaseV030BinanceAdapterRehearsalEvidence 汇总 GH-663 的 dry-run / testnet adapter rehearsal 证据。
public struct ReleaseV030BinanceAdapterRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamOMSRehearsalAnchor: String
    public let supportedProductTypes: [ProductType]
    public let supportedCommands: [ReleaseV030BinanceAdapterRehearsalCommandKind]
    public let omsHandoffs: [ReleaseV030BinanceAdapterRehearsalOMSHandoff]
    public let dryRunMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping]
    public let testnetMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping]
    public let testnetAcknowledgements: [ReleaseV030BinanceAdapterRehearsalAcknowledgement]
    public let eventEnvelopes: [MessageBusJournalEnvelope]
    public let replayedEnvelopes: [MessageBusJournalEnvelope]
    public let requirements: [ReleaseV030BinanceAdapterRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030BinanceAdapterRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let exposesRawBrokerPayloadToDashboard: Bool
    public let commandGatewayBypassAllowed: Bool
    public let riskEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let eventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-663"
            && upstreamIssueID.rawValue == "GH-662"
            && downstreamIssueID.rawValue == "GH-664"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamOMSRehearsalAnchor == Self.requiredUpstreamOMSRehearsalAnchor
            && supportedProductTypes == Self.requiredProductTypes
            && supportedCommands == ReleaseV030BinanceAdapterRehearsalCommandKind.allCases
            && mappingCoverageHeld
            && replayCoverageHeld
            && boundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var mappingCoverageHeld: Bool {
        let expectedPairs = Set(Self.requiredProductTypes.flatMap { productType in
            ReleaseV030BinanceAdapterRehearsalCommandKind.allCases.map { "\(productType.rawValue):\($0.rawValue)" }
        })
        let dryRunPairs = Set(dryRunMappings.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })
        let testnetPairs = Set(testnetMappings.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })
        let ackPairs = Set(testnetAcknowledgements.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })

        return omsHandoffs.count == Self.requiredProductTypes.count
            && omsHandoffs.allSatisfy(\.handoffHeld)
            && dryRunPairs == expectedPairs
            && testnetPairs == expectedPairs
            && ackPairs == expectedPairs
            && dryRunMappings.allSatisfy { $0.mode == .dryRun && $0.mappingHeld }
            && testnetMappings.allSatisfy { $0.mode == .testnet && $0.mappingHeld }
            && testnetAcknowledgements.allSatisfy(\.acknowledgementHeld)
    }

    public var replayCoverageHeld: Bool {
        eventEnvelopes == replayedEnvelopes
            && eventEnvelopes.count == dryRunMappings.count + testnetMappings.count + testnetAcknowledgements.count
            && eventEnvelopes.allSatisfy { $0.payloadType.contains("executionclient.release-v0.3.0.binance") }
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && exposesRawBrokerPayloadToDashboard == false
            && commandGatewayBypassAllowed == false
            && riskEngineBypassAllowed == false
            && omsBypassAllowed == false
            && eventStoreBypassAllowed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-663-release-v0.3.0-binance-adapter-rehearsal"),
        issueID: Identifier = Identifier.constant("GH-663"),
        upstreamIssueID: Identifier = Identifier.constant("GH-662"),
        downstreamIssueID: Identifier = Identifier.constant("GH-664"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamOMSRehearsalAnchor: String = Self.requiredUpstreamOMSRehearsalAnchor,
        supportedProductTypes: [ProductType] = Self.requiredProductTypes,
        supportedCommands: [ReleaseV030BinanceAdapterRehearsalCommandKind] =
            ReleaseV030BinanceAdapterRehearsalCommandKind.allCases,
        omsHandoffs: [ReleaseV030BinanceAdapterRehearsalOMSHandoff],
        dryRunMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping],
        testnetMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping],
        testnetAcknowledgements: [ReleaseV030BinanceAdapterRehearsalAcknowledgement],
        eventEnvelopes: [MessageBusJournalEnvelope],
        replayedEnvelopes: [MessageBusJournalEnvelope],
        requirements: [ReleaseV030BinanceAdapterRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030BinanceAdapterRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        exposesRawBrokerPayloadToDashboard: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        riskEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamOMSRehearsalAnchor: upstreamOMSRehearsalAnchor,
            supportedProductTypes: supportedProductTypes,
            supportedCommands: supportedCommands,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            exposesRawBrokerPayloadToDashboard: exposesRawBrokerPayloadToDashboard,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            riskEngineBypassAllowed: riskEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            eventStoreBypassAllowed: eventStoreBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamOMSRehearsalAnchor = upstreamOMSRehearsalAnchor
        self.supportedProductTypes = supportedProductTypes
        self.supportedCommands = supportedCommands
        self.omsHandoffs = omsHandoffs
        self.dryRunMappings = dryRunMappings
        self.testnetMappings = testnetMappings
        self.testnetAcknowledgements = testnetAcknowledgements
        self.eventEnvelopes = eventEnvelopes
        self.replayedEnvelopes = replayedEnvelopes
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.exposesRawBrokerPayloadToDashboard = exposesRawBrokerPayloadToDashboard
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.riskEngineBypassAllowed = riskEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamOMSRehearsalAnchor =
        "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE"
    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredRequirements = ReleaseV030BinanceAdapterRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030BinanceAdapterRehearsalForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V030-07-BINANCE-TESTNET-DRYRUN-ADAPTER-REHEARSAL",
        "V030-07-SUBMIT-CANCEL-REPLACE-MAPPING",
        "V030-07-DRYRUN-EVIDENCE",
        "V030-07-TESTNET-EVIDENCE",
        "V030-07-PRODUCTION-ENDPOINT-BLOCKED",
        "V030-07-NO-RAW-BROKER-PAYLOAD-DASHBOARD",
        "TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL"
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030BinanceAdapterRehearsal 生成 GH-663 的 deterministic adapter rehearsal evidence。
public struct ReleaseV030BinanceAdapterRehearsal: Sendable {
    public let credentialReferenceID: Identifier
    public let sourceID: FoundationTargetID
    public let streamID: MessageBusJournalStreamID

    public init(
        credentialReferenceID: Identifier = Identifier.constant("gh-663-binance-testnet-credential-reference"),
        sourceID: FoundationTargetID? = nil,
        streamID: MessageBusJournalStreamID? = nil
    ) throws {
        self.credentialReferenceID = credentialReferenceID
        if let sourceID {
            self.sourceID = sourceID
        } else {
            self.sourceID = try FoundationTargetID("gh-663-binance-adapter-rehearsal-source")
        }
        if let streamID {
            self.streamID = streamID
        } else {
            self.streamID = try MessageBusJournalStreamID("executionclient.release-v0.3.0.binance-adapter-rehearsal")
        }
    }

    public func run(
        upstreamOMSRehearsalAnchor: String =
            ReleaseV030BinanceAdapterRehearsalEvidence.requiredUpstreamOMSRehearsalAnchor,
        omsHandoffs: [ReleaseV030BinanceAdapterRehearsalOMSHandoff] = [],
        recordedAt: Date
    ) throws -> ReleaseV030BinanceAdapterRehearsalEvidence {
        guard upstreamOMSRehearsalAnchor ==
                ReleaseV030BinanceAdapterRehearsalEvidence.requiredUpstreamOMSRehearsalAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamOMSRehearsalAnchor",
                expected: ReleaseV030BinanceAdapterRehearsalEvidence.requiredUpstreamOMSRehearsalAnchor,
                actual: upstreamOMSRehearsalAnchor
            )
        }
        let resolvedHandoffs = try omsHandoffs.isEmpty ? Self.deterministicHandoffs() : omsHandoffs
        guard Set(resolvedHandoffs.map(\.instrument.productType)) ==
                Set(ReleaseV030BinanceAdapterRehearsalEvidence.requiredProductTypes),
              resolvedHandoffs.allSatisfy(\.handoffHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030BinanceAdapter.omsHandoffs",
                expected: "held Spot and USDⓈ-M Perpetual GH-662 handoffs",
                actual: resolvedHandoffs.map(\.instrument.productType.rawValue).joined(separator: ",")
            )
        }

        let dryRunMappings = try mappings(mode: .dryRun, handoffs: resolvedHandoffs)
        let testnetMappings = try mappings(mode: .testnet, handoffs: resolvedHandoffs)
        let acknowledgements = try testnetMappings.map(acknowledgement)
        let (envelopes, replayed) = try replayEvidence(
            dryRunMappings: dryRunMappings,
            testnetMappings: testnetMappings,
            acknowledgements: acknowledgements,
            recordedAt: recordedAt
        )

        return try ReleaseV030BinanceAdapterRehearsalEvidence(
            omsHandoffs: resolvedHandoffs,
            dryRunMappings: dryRunMappings,
            testnetMappings: testnetMappings,
            testnetAcknowledgements: acknowledgements,
            eventEnvelopes: envelopes,
            replayedEnvelopes: replayed
        )
    }

    public static func deterministicHandoffs() throws -> [ReleaseV030BinanceAdapterRehearsalOMSHandoff] {
        [
            try ReleaseV030BinanceAdapterRehearsalOMSHandoff.deterministicSpotFixture(),
            try ReleaseV030BinanceAdapterRehearsalOMSHandoff.deterministicPerpFixture()
        ]
    }

    private func mappings(
        mode: ReleaseV030BinanceAdapterRehearsalMode,
        handoffs: [ReleaseV030BinanceAdapterRehearsalOMSHandoff]
    ) throws -> [ReleaseV030BinanceAdapterRehearsalRequestMapping] {
        try handoffs.flatMap { handoff in
            try ReleaseV030BinanceAdapterRehearsalCommandKind.allCases.map { commandKind in
                try mapping(mode: mode, commandKind: commandKind, handoff: handoff)
            }
        }
    }

    private func mapping(
        mode: ReleaseV030BinanceAdapterRehearsalMode,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind,
        handoff: ReleaseV030BinanceAdapterRehearsalOMSHandoff
    ) throws -> ReleaseV030BinanceAdapterRehearsalRequestMapping {
        let clientOrderID = Self.clientOrderID(mode: mode, commandKind: commandKind, productType: handoff.instrument.productType)
        let side = Self.side(for: handoff)
        let positionSide = Self.positionSide(for: handoff)
        let reduceOnly = handoff.instrument.productType == .usdsPerpetual && handoff.targetExposure == .targetFlat
        return try ReleaseV030BinanceAdapterRehearsalRequestMapping(
            mappingID: Identifier.constant(
                "gh-663-\(handoff.instrument.productType.rawValue)-\(commandKind.rawValue)-\(mode.rawValue)-mapping"
            ),
            commandKind: commandKind,
            mode: mode,
            productType: handoff.instrument.productType,
            credentialReferenceID: credentialReferenceID,
            sourceOrderIntentID: handoff.sourceOrderIntentID,
            sourceEventLogID: handoff.sourceEventLogID,
            sourceOMSOrderID: handoff.sourceOMSOrderID,
            clientOrderID: clientOrderID,
            symbol: handoff.instrument.symbol.rawValue,
            side: side,
            positionSide: positionSide,
            reduceOnly: reduceOnly,
            queryItems: try Self.queryItems(
                commandKind: commandKind,
                handoff: handoff,
                clientOrderID: clientOrderID,
                side: side,
                positionSide: positionSide,
                reduceOnly: reduceOnly
            )
        )
    }

    private func acknowledgement(
        for mapping: ReleaseV030BinanceAdapterRehearsalRequestMapping
    ) throws -> ReleaseV030BinanceAdapterRehearsalAcknowledgement {
        try ReleaseV030BinanceAdapterRehearsalAcknowledgement(
            acknowledgementID: Identifier.constant(
                "gh-663-\(mapping.productType.rawValue)-\(mapping.commandKind.rawValue)-testnet-ack"
            ),
            mappingID: mapping.mappingID,
            commandKind: mapping.commandKind,
            productType: mapping.productType,
            deterministicTraceID: Identifier.constant(
                "gh-663-\(mapping.productType.rawValue)-\(mapping.commandKind.rawValue)-testnet-trace"
            ),
            responseStatus: "accepted-by-deterministic-testnet-adapter"
        )
    }

    private func replayEvidence(
        dryRunMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping],
        testnetMappings: [ReleaseV030BinanceAdapterRehearsalRequestMapping],
        acknowledgements: [ReleaseV030BinanceAdapterRehearsalAcknowledgement],
        recordedAt: Date
    ) throws -> ([MessageBusJournalEnvelope], [MessageBusJournalEnvelope]) {
        var journal = try MessageBusAppendOnlyJournal()
        var envelopes: [MessageBusJournalEnvelope] = []
        var sequence = 0
        for mapping in dryRunMappings + testnetMappings {
            sequence += 1
            let payloadType =
                "executionclient.release-v0.3.0.binance.\(mapping.productType.rawValue)."
                + "\(mapping.mode.rawValue).\(mapping.commandKind.rawValue).mapping"
            envelopes.append(
                try journal.append(
                    stream: streamID,
                    sourceID: sourceID,
                    payloadType: payloadType,
                    instrumentID: nil,
                    recordedAt: recordedAt.addingTimeInterval(TimeInterval(sequence))
                )
            )
        }
        for acknowledgement in acknowledgements {
            sequence += 1
            let payloadType =
                "executionclient.release-v0.3.0.binance.\(acknowledgement.productType.rawValue)."
                + "testnet.\(acknowledgement.commandKind.rawValue).ack"
            envelopes.append(
                try journal.append(
                    stream: streamID,
                    sourceID: sourceID,
                    payloadType: payloadType,
                    instrumentID: nil,
                    recordedAt: recordedAt.addingTimeInterval(TimeInterval(sequence))
                )
            )
        }
        return (envelopes, journal.replay(stream: streamID))
    }

    private static func clientOrderID(
        mode: ReleaseV030BinanceAdapterRehearsalMode,
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind,
        productType: ProductType
    ) -> Identifier {
        Identifier.constant("gh-663-\(productType.rawValue)-\(mode.rawValue)-\(commandKind.rawValue)-client-order")
    }

    private static func side(for handoff: ReleaseV030BinanceAdapterRehearsalOMSHandoff) -> String {
        switch handoff.targetExposure {
        case .targetLong:
            "BUY"
        case .targetShort, .targetFlat:
            "SELL"
        case .hold:
            "BUY"
        }
    }

    private static func positionSide(for handoff: ReleaseV030BinanceAdapterRehearsalOMSHandoff) -> String? {
        guard handoff.instrument.productType == .usdsPerpetual else {
            return nil
        }
        switch handoff.targetExposure {
        case .targetShort:
            return "SHORT"
        case .targetLong, .targetFlat, .hold:
            return "LONG"
        }
    }

    private static func queryItems(
        commandKind: ReleaseV030BinanceAdapterRehearsalCommandKind,
        handoff: ReleaseV030BinanceAdapterRehearsalOMSHandoff,
        clientOrderID: Identifier,
        side: String,
        positionSide: String?,
        reduceOnly: Bool
    ) throws -> [ReleaseV030BinanceAdapterRehearsalQueryItem] {
        let productType = handoff.instrument.productType
        let originalClientOrderID = "\(clientOrderID.rawValue)-original"
        let values: [String: String] = [
            "symbol": handoff.instrument.symbol.rawValue,
            "side": side,
            "positionSide": positionSide ?? "",
            "type": "LIMIT",
            "timeInForce": "GTC",
            "quantity": "\(handoff.quantity.rawValue)",
            "price": "\(handoff.referencePrice.rawValue)",
            "reduceOnly": reduceOnly ? "true" : "false",
            "origClientOrderId": originalClientOrderID,
            "cancelOrigClientOrderId": originalClientOrderID,
            "newClientOrderId": clientOrderID.rawValue,
            "cancelReplaceMode": "STOP_ON_FAILURE",
            "recvWindow": "5000",
            "timestamp": "1704068600000"
        ]
        return try ReleaseV030BinanceAdapterRehearsalRequestMapping
            .requiredQueryItemNames(productType: productType, commandKind: commandKind)
            .map { name in
                guard let value = values[name], value.isEmpty == false else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV030BinanceAdapter.queryItem.\(name)",
                        expected: "deterministic redacted value",
                        actual: "missing"
                    )
                }
                return try ReleaseV030BinanceAdapterRehearsalQueryItem(name: name, value: value)
            }
    }
}

private extension ReleaseV030BinanceAdapterRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamOMSRehearsalAnchor: String,
        supportedProductTypes: [ProductType],
        supportedCommands: [ReleaseV030BinanceAdapterRehearsalCommandKind],
        requirements: [ReleaseV030BinanceAdapterRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030BinanceAdapterRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamOMSRehearsalAnchor",
                upstreamOMSRehearsalAnchor == requiredUpstreamOMSRehearsalAnchor,
                requiredUpstreamOMSRehearsalAnchor,
                upstreamOMSRehearsalAnchor
            ),
            (
                "supportedProductTypes",
                supportedProductTypes == requiredProductTypes,
                requiredProductTypes.map(\.rawValue).joined(separator: ","),
                supportedProductTypes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "supportedCommands",
                supportedCommands == ReleaseV030BinanceAdapterRehearsalCommandKind.allCases,
                ReleaseV030BinanceAdapterRehearsalCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                supportedCommands.map(\.rawValue).joined(separator: ",")
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        exposesRawBrokerPayloadToDashboard: Bool,
        commandGatewayBypassAllowed: Bool,
        riskEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        eventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("exposesRawBrokerPayloadToDashboard", exposesRawBrokerPayloadToDashboard),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("riskEngineBypassAllowed", riskEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.evidence.\(field)")
        }
    }
}
