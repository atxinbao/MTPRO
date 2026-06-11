import DomainModel
import Foundation
import MessageBus

/// ReleaseV020BinanceSpotExecutionClientCommandKind 固定 #584 允许的 Binance Spot 命令族。
///
/// 这些 case 只表示 submit / cancel / replace 的本地 request mapping 语义，
/// 不代表真实 broker command、production order command 或 execution authorization。
public enum ReleaseV020BinanceSpotExecutionClientCommandKind:
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

/// ReleaseV020BinanceSpotExecutionClientMode 区分 dry-run、testnet 和仍禁止的 production。
public enum ReleaseV020BinanceSpotExecutionClientMode:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case dryRun = "dry-run"
    case testnet
    case production
}

/// ReleaseV020BinanceSpotExecutionClientHTTPMethod 固定 Binance Spot command mapping 使用的 HTTP method。
public enum ReleaseV020BinanceSpotExecutionClientHTTPMethod:
    String,
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    case post = "POST"
    case delete = "DELETE"
}

/// ReleaseV020BinanceSpotExecutionClientQueryItem 是 #584 的 redacted request mapping 参数。
///
/// Query item 只保留参数名和值；signature 和 secret value 不能进入该结构。
public struct ReleaseV020BinanceSpotExecutionClientQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.queryItem.name",
                expected: "non-empty query item name",
                actual: "empty"
            )
        }
        guard trimmedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.queryItem.value",
                expected: "non-empty query item value",
                actual: "empty"
            )
        }
        guard trimmedName.lowercased() != "signature" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.signatureValue"
            )
        }

        self.name = trimmedName
        self.value = trimmedValue
    }
}

/// ReleaseV020BinanceSpotExecutionClientCredentialGate 固定 #584 testnet credential reference 边界。
///
/// Gate 只允许 testnet credential reference 进入 evidence，不保存 key / secret value，
/// 不读取 production secret，也不允许 testnet credential 被提升为 production credential。
/// `GH-584-TESTNET-EVIDENCE-GATE`
public struct ReleaseV020BinanceSpotExecutionClientCredentialGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let credentialReferenceID: Identifier
    public let mode: ReleaseV020BinanceSpotExecutionClientMode
    public let credentialReferenceOnly: Bool
    public let credentialValueStored: Bool
    public let credentialValueExposed: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionCredentialAccepted: Bool
    public let testnetCredentialPromotesProduction: Bool

    public init(
        gateID: Identifier = Identifier.constant("gh-584-testnet-credential-gate"),
        credentialReferenceID: Identifier,
        mode: ReleaseV020BinanceSpotExecutionClientMode = .testnet,
        credentialReferenceOnly: Bool = true,
        credentialValueStored: Bool = false,
        credentialValueExposed: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionCredentialAccepted: Bool = false,
        testnetCredentialPromotesProduction: Bool = false
    ) throws {
        guard mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionCredential"
            )
        }
        guard credentialReferenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.credentialReferenceOnly",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("credentialValueStored", credentialValueStored),
            ("credentialValueExposed", credentialValueExposed),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("productionCredentialAccepted", productionCredentialAccepted),
            ("testnetCredentialPromotesProduction", testnetCredentialPromotesProduction)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.gateID = gateID
        self.credentialReferenceID = credentialReferenceID
        self.mode = mode
        self.credentialReferenceOnly = credentialReferenceOnly
        self.credentialValueStored = credentialValueStored
        self.credentialValueExposed = credentialValueExposed
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionCredentialAccepted = productionCredentialAccepted
        self.testnetCredentialPromotesProduction = testnetCredentialPromotesProduction
    }

    public var gateHeld: Bool {
        mode == .testnet
            && credentialReferenceOnly
            && credentialValueStored == false
            && credentialValueExposed == false
            && productionSecretReadEnabledByDefault == false
            && productionCredentialAccepted == false
            && testnetCredentialPromotesProduction == false
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceSpotExecutionClientCredentialGate {
        try ReleaseV020BinanceSpotExecutionClientCredentialGate(
            credentialReferenceID: Identifier.constant("gh-584-binance-spot-testnet-credential-reference")
        )
    }
}

/// ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence 是 #584 消费 #583 product-aware OMS 的本地交接证据。
///
/// 该结构只在 ExecutionClient 侧保留最低限度的 handoff identity，不依赖 ExecutionEngine target，
/// 同时证明 request mapping 仍然受 OMS / Event Store / kill switch / no-trade gate 约束。
public struct ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence: Codable, Equatable, Sendable {
    public let handoffID: Identifier
    public let sourceIssueID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let side: String
    public let quantity: Quantity
    public let referencePrice: Price
    public let stateEvidence: [String]
    public let sourceValidationAnchors: [String]
    public let eventStream: EventStreamID
    public let sourceBoundaryHeld: Bool
    public let requiresEventStoreWrite: Bool
    public let requiresKillSwitchBeforeExecution: Bool
    public let requiresNoTradeGateBeforeExecution: Bool
    public let productionOMSRuntimeEnabledByDefault: Bool
    public let callsExecutionClientBeforeAdapter: Bool
    public let touchesBrokerGatewayBeforeAdapter: Bool
    public let submitsRealOrderBeforeAdapter: Bool

    public init(
        handoffID: Identifier = Identifier.constant("gh-584-spot-oms-handoff"),
        sourceIssueID: Identifier = Identifier.constant("GH-583"),
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        side: String,
        quantity: Quantity,
        referencePrice: Price,
        stateEvidence: [String],
        sourceValidationAnchors: [String] = [
            "GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE",
            "GH-583-SPOT-LIFECYCLE",
            "TVM-RELEASE-V020-PRODUCT-AWARE-OMS-STATE-MACHINE"
        ],
        eventStream: EventStreamID = EventStreamID(rawValue: "execution-oms-local"),
        sourceBoundaryHeld: Bool = true,
        requiresEventStoreWrite: Bool = true,
        requiresKillSwitchBeforeExecution: Bool = true,
        requiresNoTradeGateBeforeExecution: Bool = true,
        productionOMSRuntimeEnabledByDefault: Bool = false,
        callsExecutionClientBeforeAdapter: Bool = false,
        touchesBrokerGatewayBeforeAdapter: Bool = false,
        submitsRealOrderBeforeAdapter: Bool = false
    ) throws {
        let normalizedSide = side.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard sourceIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.sourceIssueID",
                expected: "GH-583",
                actual: sourceIssueID.rawValue
            )
        }
        guard instrument.productType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.instrument",
                expected: ProductType.spot.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard targetExposure != .hold else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.targetExposure",
                expected: "submit/cancel/replace source must require order intent",
                actual: targetExposure.rawValue
            )
        }
        guard ["BUY", "SELL"].contains(normalizedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.side",
                expected: "BUY or SELL",
                actual: normalizedSide
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.quantity",
                expected: "positive quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard stateEvidence.contains("accepted"), stateEvidence.contains("submitted") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.stateEvidence",
                expected: "accepted and submitted OMS evidence",
                actual: stateEvidence.joined(separator: ",")
            )
        }
        guard sourceValidationAnchors.contains("GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE"),
              sourceValidationAnchors.contains("GH-583-SPOT-LIFECYCLE") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.sourceValidationAnchors",
                expected: "GH-583 anchors present",
                actual: sourceValidationAnchors.joined(separator: ",")
            )
        }
        guard sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.sourceBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard requiresEventStoreWrite else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.requiresEventStoreWrite"
            )
        }
        guard requiresKillSwitchBeforeExecution else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.requiresKillSwitchBeforeExecution"
            )
        }
        guard requiresNoTradeGateBeforeExecution else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.requiresNoTradeGateBeforeExecution"
            )
        }
        for forbiddenFlag in [
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("callsExecutionClientBeforeAdapter", callsExecutionClientBeforeAdapter),
            ("touchesBrokerGatewayBeforeAdapter", touchesBrokerGatewayBeforeAdapter),
            ("submitsRealOrderBeforeAdapter", submitsRealOrderBeforeAdapter)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.handoffID = handoffID
        self.sourceIssueID = sourceIssueID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.side = normalizedSide
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.stateEvidence = stateEvidence
        self.sourceValidationAnchors = sourceValidationAnchors
        self.eventStream = eventStream
        self.sourceBoundaryHeld = sourceBoundaryHeld
        self.requiresEventStoreWrite = requiresEventStoreWrite
        self.requiresKillSwitchBeforeExecution = requiresKillSwitchBeforeExecution
        self.requiresNoTradeGateBeforeExecution = requiresNoTradeGateBeforeExecution
        self.productionOMSRuntimeEnabledByDefault = productionOMSRuntimeEnabledByDefault
        self.callsExecutionClientBeforeAdapter = callsExecutionClientBeforeAdapter
        self.touchesBrokerGatewayBeforeAdapter = touchesBrokerGatewayBeforeAdapter
        self.submitsRealOrderBeforeAdapter = submitsRealOrderBeforeAdapter
    }

    public var handoffBoundaryHeld: Bool {
        sourceIssueID.rawValue == "GH-583"
            && instrument.productType == .spot
            && targetExposure != .hold
            && ["BUY", "SELL"].contains(side)
            && quantity.rawValue > 0
            && stateEvidence.contains("accepted")
            && stateEvidence.contains("submitted")
            && sourceValidationAnchors.contains("GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE")
            && sourceValidationAnchors.contains("GH-583-SPOT-LIFECYCLE")
            && eventStream.rawValue == "execution-oms-local"
            && sourceBoundaryHeld
            && requiresEventStoreWrite
            && requiresKillSwitchBeforeExecution
            && requiresNoTradeGateBeforeExecution
            && productionOMSRuntimeEnabledByDefault == false
            && callsExecutionClientBeforeAdapter == false
            && touchesBrokerGatewayBeforeAdapter == false
            && submitsRealOrderBeforeAdapter == false
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence {
        try ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence(
            sourceOrderIntentID: Identifier.constant("gh-583-spot-order-intent"),
            sourceEventLogID: Identifier.constant("gh-583-spot-filled-event-log"),
            sourceOMSOrderID: Identifier.constant("gh-583-spot-filled-order"),
            instrument: InstrumentIdentity.binance(
                productType: .spot,
                symbol: Symbol.constant("BTCUSDT")
            ),
            targetExposure: .targetLong,
            side: "BUY",
            quantity: try Quantity(0.25, field: "releaseV020BinanceSpotExecutionClient.quantity"),
            referencePrice: try Price(43_500, field: "releaseV020BinanceSpotExecutionClient.referencePrice"),
            stateEvidence: ["new", "accepted", "submitted", "partiallyFilled", "filled"]
        )
    }
}

/// ReleaseV020BinanceSpotExecutionClientCapabilityMatrix 固定 #584 的 capability / forbidden matrix。
///
/// Matrix 明确 Spot dry-run preview 和 testnet submit / cancel / replace mapping 被当前 issue 授权，
/// 但 production endpoint、production secret、real order、broker gateway 和非 Binance / 非 EMA/RSI
/// scope 仍全部默认关闭。
/// `GH-584-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER`
public struct ReleaseV020BinanceSpotExecutionClientCapabilityMatrix: Codable, Equatable, Sendable {
    public let matrixID: Identifier
    public let releaseVenue: String
    public let releaseProductType: ProductType
    public let releaseStrategyKinds: [String]
    public let supportedCommands: [ReleaseV020BinanceSpotExecutionClientCommandKind]
    public let requiresOMSHandoffEvidence: Bool
    public let requiresDryRunEvidence: Bool
    public let requiresTestnetCredentialGate: Bool
    public let requiresKillSwitchFutureGate: Bool
    public let productionDefaultRejectedGateHeld: Bool
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderSubmitted: Bool
    public let realOrderCanceled: Bool
    public let realOrderReplaced: Bool
    public let liveCommandSurfaceTouched: Bool
    public let nonBinanceVenueEnabled: Bool
    public let unsupportedProductTypeEnabled: Bool
    public let nonEMARSIStrategyEnabled: Bool

    public init(
        matrixID: Identifier = Identifier.constant("gh-584-binance-spot-capability-matrix"),
        releaseVenue: String = "Binance",
        releaseProductType: ProductType = .spot,
        releaseStrategyKinds: [String] = ["EMA", "RSI"],
        supportedCommands: [ReleaseV020BinanceSpotExecutionClientCommandKind] =
            ReleaseV020BinanceSpotExecutionClientCommandKind.allCases,
        requiresOMSHandoffEvidence: Bool = true,
        requiresDryRunEvidence: Bool = true,
        requiresTestnetCredentialGate: Bool = true,
        requiresKillSwitchFutureGate: Bool = true,
        productionDefaultRejectedGateHeld: Bool = true,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderSubmitted: Bool = false,
        realOrderCanceled: Bool = false,
        realOrderReplaced: Bool = false,
        liveCommandSurfaceTouched: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        unsupportedProductTypeEnabled: Bool = false,
        nonEMARSIStrategyEnabled: Bool = false
    ) throws {
        guard releaseVenue == "Binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.nonBinanceVenue"
            )
        }
        guard releaseProductType == .spot else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.releaseProductType",
                expected: ProductType.spot.rawValue,
                actual: releaseProductType.rawValue
            )
        }
        guard releaseStrategyKinds == ["EMA", "RSI"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.releaseStrategyKinds",
                expected: "EMA,RSI",
                actual: releaseStrategyKinds.joined(separator: ",")
            )
        }
        guard supportedCommands == ReleaseV020BinanceSpotExecutionClientCommandKind.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.supportedCommands",
                expected: ReleaseV020BinanceSpotExecutionClientCommandKind.allCases
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: supportedCommands.map(\.rawValue).joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("requiresOMSHandoffEvidence", requiresOMSHandoffEvidence),
            ("requiresDryRunEvidence", requiresDryRunEvidence),
            ("requiresTestnetCredentialGate", requiresTestnetCredentialGate),
            ("requiresKillSwitchFutureGate", requiresKillSwitchFutureGate),
            ("productionDefaultRejectedGateHeld", productionDefaultRejectedGateHeld)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointEnabledByDefault", productionEndpointEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("realOrderSubmitted", realOrderSubmitted),
            ("realOrderCanceled", realOrderCanceled),
            ("realOrderReplaced", realOrderReplaced),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("unsupportedProductTypeEnabled", unsupportedProductTypeEnabled),
            ("nonEMARSIStrategyEnabled", nonEMARSIStrategyEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.matrixID = matrixID
        self.releaseVenue = releaseVenue
        self.releaseProductType = releaseProductType
        self.releaseStrategyKinds = releaseStrategyKinds
        self.supportedCommands = supportedCommands
        self.requiresOMSHandoffEvidence = requiresOMSHandoffEvidence
        self.requiresDryRunEvidence = requiresDryRunEvidence
        self.requiresTestnetCredentialGate = requiresTestnetCredentialGate
        self.requiresKillSwitchFutureGate = requiresKillSwitchFutureGate
        self.productionDefaultRejectedGateHeld = productionDefaultRejectedGateHeld
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderSubmitted = realOrderSubmitted
        self.realOrderCanceled = realOrderCanceled
        self.realOrderReplaced = realOrderReplaced
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.unsupportedProductTypeEnabled = unsupportedProductTypeEnabled
        self.nonEMARSIStrategyEnabled = nonEMARSIStrategyEnabled
    }

    public var matrixHeld: Bool {
        releaseVenue == "Binance"
            && releaseProductType == .spot
            && releaseStrategyKinds == ["EMA", "RSI"]
            && supportedCommands == ReleaseV020BinanceSpotExecutionClientCommandKind.allCases
            && requiresOMSHandoffEvidence
            && requiresDryRunEvidence
            && requiresTestnetCredentialGate
            && requiresKillSwitchFutureGate
            && productionDefaultRejectedGateHeld
            && productionEndpointEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && brokerGatewayTouched == false
            && realOrderSubmitted == false
            && realOrderCanceled == false
            && realOrderReplaced == false
            && liveCommandSurfaceTouched == false
            && nonBinanceVenueEnabled == false
            && unsupportedProductTypeEnabled == false
            && nonEMARSIStrategyEnabled == false
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceSpotExecutionClientCapabilityMatrix {
        try ReleaseV020BinanceSpotExecutionClientCapabilityMatrix()
    }
}

/// ReleaseV020BinanceSpotExecutionClientDryRunPreview 是 #584 的本地 dry-run request preview evidence。
///
/// Preview 只证明 request mapping 已被构造且可审计；它不执行 network call，不读 secret，
/// 也不触碰 production endpoint 或 broker gateway。
public struct ReleaseV020BinanceSpotExecutionClientDryRunPreview: Codable, Equatable, Sendable {
    public let previewID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind
    public let mode: ReleaseV020BinanceSpotExecutionClientMode
    public let baseURL: URL
    public let method: ReleaseV020BinanceSpotExecutionClientHTTPMethod
    public let endpointPath: String
    public let credentialReferenceID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let queryItems: [ReleaseV020BinanceSpotExecutionClientQueryItem]
    public let signatureRequired: Bool
    public let mappingAuditable: Bool
    public let networkCallPerformed: Bool
    public let signatureValueExposed: Bool
    public let productionEndpointTouched: Bool
    public let productionTradingEnabledByDefault: Bool

    public init(
        previewID: Identifier,
        issueID: Identifier = Identifier.constant("GH-584"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        mode: ReleaseV020BinanceSpotExecutionClientMode = .dryRun,
        baseURL: URL = ReleaseV020BinanceSpotExecutionClientAdapter.defaultTestnetBaseURL,
        method: ReleaseV020BinanceSpotExecutionClientHTTPMethod? = nil,
        endpointPath: String? = nil,
        credentialReferenceID: Identifier,
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        queryItems: [ReleaseV020BinanceSpotExecutionClientQueryItem],
        signatureRequired: Bool = true,
        mappingAuditable: Bool = true,
        networkCallPerformed: Bool = false,
        signatureValueExposed: Bool = false,
        productionEndpointTouched: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        let resolvedMethod = method ?? ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind)
        let resolvedEndpointPath = endpointPath
            ?? ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind)
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)

        guard issueID.rawValue == "GH-584" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.issueID",
                expected: "GH-584",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.upstreamIssueID",
                expected: "GH-583",
                actual: upstreamIssueID.rawValue
            )
        }
        guard mode == .dryRun else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionPreview"
            )
        }
        guard baseURL.scheme == "https", baseURL.host?.lowercased() == ReleaseV020BinanceSpotExecutionClientAdapter.testnetHost
        else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionEndpoint"
            )
        }
        guard resolvedMethod == ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.method",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind).rawValue,
                actual: resolvedMethod.rawValue
            )
        }
        guard resolvedEndpointPath == ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.endpointPath",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind),
                actual: resolvedEndpointPath
            )
        }
        guard trimmedSymbol.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.symbol",
                expected: "non-empty Binance symbol",
                actual: "empty"
            )
        }
        guard queryItems.map(\.name) == ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
        else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.queryItems",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
                    .joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard signatureRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.signatureRequired",
                expected: "true",
                actual: "false"
            )
        }
        guard mappingAuditable else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.mappingAuditable",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("networkCallPerformed", networkCallPerformed),
            ("signatureValueExposed", signatureValueExposed),
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.previewID = previewID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.mode = mode
        self.baseURL = baseURL
        self.method = resolvedMethod
        self.endpointPath = resolvedEndpointPath
        self.credentialReferenceID = credentialReferenceID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.clientOrderID = clientOrderID
        self.symbol = trimmedSymbol
        self.queryItems = queryItems
        self.signatureRequired = signatureRequired
        self.mappingAuditable = mappingAuditable
        self.networkCallPerformed = networkCallPerformed
        self.signatureValueExposed = signatureValueExposed
        self.productionEndpointTouched = productionEndpointTouched
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }

    public var previewBoundaryHeld: Bool {
        issueID.rawValue == "GH-584"
            && upstreamIssueID.rawValue == "GH-583"
            && mode == .dryRun
            && baseURL.host?.lowercased() == ReleaseV020BinanceSpotExecutionClientAdapter.testnetHost
            && method == ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind)
            && endpointPath == ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind)
            && queryItems.map(\.name) == ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
            && signatureRequired
            && mappingAuditable
            && networkCallPerformed == false
            && signatureValueExposed == false
            && productionEndpointTouched == false
            && productionTradingEnabledByDefault == false
    }
}

/// ReleaseV020BinanceSpotExecutionClientTestnetRequest 是 #584 的 Binance Spot testnet request mapping。
///
/// Request 必须引用 #583 product-aware OMS handoff evidence，并只映射到 Binance Spot testnet command endpoint。
/// 它不携带 secret、signature value、production host、broker payload 或 raw fill。
/// `GH-584-SUBMIT-CANCEL-REPLACE-MAPPING`
public struct ReleaseV020BinanceSpotExecutionClientTestnetRequest: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind
    public let mode: ReleaseV020BinanceSpotExecutionClientMode
    public let baseURL: URL
    public let method: ReleaseV020BinanceSpotExecutionClientHTTPMethod
    public let endpointPath: String
    public let credentialReferenceID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let queryItems: [ReleaseV020BinanceSpotExecutionClientQueryItem]
    public let signatureRequired: Bool
    public let signatureValueExposed: Bool
    public let productionEndpointTouched: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        requestID: Identifier,
        issueID: Identifier = Identifier.constant("GH-584"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        mode: ReleaseV020BinanceSpotExecutionClientMode = .testnet,
        baseURL: URL = ReleaseV020BinanceSpotExecutionClientAdapter.defaultTestnetBaseURL,
        method: ReleaseV020BinanceSpotExecutionClientHTTPMethod? = nil,
        endpointPath: String? = nil,
        credentialReferenceID: Identifier,
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        queryItems: [ReleaseV020BinanceSpotExecutionClientQueryItem],
        signatureRequired: Bool = true,
        signatureValueExposed: Bool = false,
        productionEndpointTouched: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMethod = method ?? ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind)
        let resolvedEndpointPath = endpointPath
            ?? ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind)
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)

        guard issueID.rawValue == "GH-584" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.issueID",
                expected: "GH-584",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.upstreamIssueID",
                expected: "GH-583",
                actual: upstreamIssueID.rawValue
            )
        }
        guard mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionEnvironment"
            )
        }
        guard baseURL.scheme == "https", baseURL.host?.lowercased() == ReleaseV020BinanceSpotExecutionClientAdapter.testnetHost
        else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionEndpoint"
            )
        }
        guard resolvedMethod == ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.method",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind).rawValue,
                actual: resolvedMethod.rawValue
            )
        }
        guard resolvedEndpointPath == ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.endpointPath",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind),
                actual: resolvedEndpointPath
            )
        }
        guard trimmedSymbol.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.symbol",
                expected: "non-empty Binance symbol",
                actual: "empty"
            )
        }
        guard queryItems.map(\.name) == ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
        else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.queryItems",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
                    .joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard signatureRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.signatureRequired",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("signatureValueExposed", signatureValueExposed),
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.requestID = requestID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.mode = mode
        self.baseURL = baseURL
        self.method = resolvedMethod
        self.endpointPath = resolvedEndpointPath
        self.credentialReferenceID = credentialReferenceID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.clientOrderID = clientOrderID
        self.symbol = trimmedSymbol
        self.queryItems = queryItems
        self.signatureRequired = signatureRequired
        self.signatureValueExposed = signatureValueExposed
        self.productionEndpointTouched = productionEndpointTouched
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var requestMappingHeld: Bool {
        issueID.rawValue == "GH-584"
            && upstreamIssueID.rawValue == "GH-583"
            && mode == .testnet
            && baseURL.host?.lowercased() == ReleaseV020BinanceSpotExecutionClientAdapter.testnetHost
            && method == ReleaseV020BinanceSpotExecutionClientAdapter.method(for: commandKind)
            && endpointPath == ReleaseV020BinanceSpotExecutionClientAdapter.endpointPath(for: commandKind)
            && queryItems.map(\.name) == ReleaseV020BinanceSpotExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
            && signatureRequired
            && signatureValueExposed == false
            && productionEndpointTouched == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020BinanceSpotExecutionClientTestnetAck 是 #584 testnet transport acknowledgement evidence。
///
/// Ack 只证明 testnet adapter 接受了 request mapping。它不代表 production exchange fill、broker fill、
/// reconciliation、portfolio update 或真实 order lifecycle。
public struct ReleaseV020BinanceSpotExecutionClientTestnetAck: Codable, Equatable, Sendable {
    public let ackID: Identifier
    public let requestID: Identifier
    public let commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind
    public let mode: ReleaseV020BinanceSpotExecutionClientMode
    public let acceptedByTestnetAdapter: Bool
    public let deterministicTraceID: Identifier
    public let responseStatus: String
    public let productionEndpointTouched: Bool
    public let productionOrderTouched: Bool
    public let brokerGatewayTouched: Bool

    public init(
        ackID: Identifier,
        requestID: Identifier,
        commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        mode: ReleaseV020BinanceSpotExecutionClientMode = .testnet,
        acceptedByTestnetAdapter: Bool = true,
        deterministicTraceID: Identifier,
        responseStatus: String,
        productionEndpointTouched: Bool = false,
        productionOrderTouched: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionAck"
            )
        }
        guard acceptedByTestnetAdapter else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.acceptedByTestnetAdapter",
                expected: "true",
                actual: "false"
            )
        }
        guard responseStatus.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.responseStatus",
                expected: "non-empty testnet status",
                actual: "empty"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionOrderTouched", productionOrderTouched),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.ackID = ackID
        self.requestID = requestID
        self.commandKind = commandKind
        self.mode = mode
        self.acceptedByTestnetAdapter = acceptedByTestnetAdapter
        self.deterministicTraceID = deterministicTraceID
        self.responseStatus = responseStatus
        self.productionEndpointTouched = productionEndpointTouched
        self.productionOrderTouched = productionOrderTouched
        self.brokerGatewayTouched = brokerGatewayTouched
    }

    public var ackBoundaryHeld: Bool {
        mode == .testnet
            && acceptedByTestnetAdapter
            && responseStatus.isEmpty == false
            && productionEndpointTouched == false
            && productionOrderTouched == false
            && brokerGatewayTouched == false
    }
}

/// ReleaseV020BinanceSpotExecutionClientTestnetTransport 是 #584 的 testnet transport protocol。
///
/// Protocol 只接受已经过 testnet credential gate 和 #583 OMS handoff 绑定的 request mapping。
/// Production URLSession / broker gateway transport 不属于当前 issue。
public protocol ReleaseV020BinanceSpotExecutionClientTestnetTransport: Sendable {
    func send(_ request: ReleaseV020BinanceSpotExecutionClientTestnetRequest) throws
        -> ReleaseV020BinanceSpotExecutionClientTestnetAck
}

/// ReleaseV020BinanceSpotDeterministicTestnetTransport 是 required validation 使用的 testnet transport fixture。
///
/// 该 transport 不连网、不读 secret、不生成真实签名，只对 request mapping 返回 deterministic ack。
public struct ReleaseV020BinanceSpotDeterministicTestnetTransport:
    ReleaseV020BinanceSpotExecutionClientTestnetTransport
{
    public init() {}

    public func send(
        _ request: ReleaseV020BinanceSpotExecutionClientTestnetRequest
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetAck {
        guard request.requestMappingHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.requestMappingHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try ReleaseV020BinanceSpotExecutionClientTestnetAck(
            ackID: Identifier.constant("gh-584-binance-spot-\(request.commandKind.rawValue)-ack"),
            requestID: request.requestID,
            commandKind: request.commandKind,
            deterministicTraceID: Identifier.constant("gh-584-binance-spot-\(request.commandKind.rawValue)-trace"),
            responseStatus: "accepted by deterministic Binance Spot testnet \(request.commandKind.rawValue) adapter"
        )
    }
}

/// ReleaseV020BinanceSpotExecutionClientAdapterEvidence 汇总 #584 dry-run / testnet adapter evidence。
///
/// Evidence 必须覆盖 submit / cancel / replace、dry-run preview、testnet credential gate、#583 OMS handoff
/// source identity 和 production rejected by default。
/// `GH-584-DRYRUN-EVIDENCE`
/// `TVM-RELEASE-V020-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER`
public struct ReleaseV020BinanceSpotExecutionClientAdapterEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let capabilityMatrix: ReleaseV020BinanceSpotExecutionClientCapabilityMatrix
    public let credentialGate: ReleaseV020BinanceSpotExecutionClientCredentialGate
    public let omsHandoff: ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence
    public let dryRunPreviews: [ReleaseV020BinanceSpotExecutionClientDryRunPreview]
    public let testnetRequests: [ReleaseV020BinanceSpotExecutionClientTestnetRequest]
    public let acknowledgements: [ReleaseV020BinanceSpotExecutionClientTestnetAck]
    public let validationAnchors: [String]
    public let dryRunEvidenceComplete: Bool
    public let testnetEvidenceGateHeld: Bool
    public let productionRejectedByDefault: Bool
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderSubmitted: Bool
    public let realOrderCanceled: Bool
    public let realOrderReplaced: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-584-binance-spot-adapter-evidence"),
        issueID: Identifier = Identifier.constant("GH-584"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        capabilityMatrix: ReleaseV020BinanceSpotExecutionClientCapabilityMatrix,
        credentialGate: ReleaseV020BinanceSpotExecutionClientCredentialGate,
        omsHandoff: ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence,
        dryRunPreviews: [ReleaseV020BinanceSpotExecutionClientDryRunPreview],
        testnetRequests: [ReleaseV020BinanceSpotExecutionClientTestnetRequest],
        acknowledgements: [ReleaseV020BinanceSpotExecutionClientTestnetAck],
        validationAnchors: [String] = ReleaseV020BinanceSpotExecutionClientAdapter.requiredValidationAnchors,
        dryRunEvidenceComplete: Bool = true,
        testnetEvidenceGateHeld: Bool = true,
        productionRejectedByDefault: Bool = true,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderSubmitted: Bool = false,
        realOrderCanceled: Bool = false,
        realOrderReplaced: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-584" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.issueID",
                expected: "GH-584",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.upstreamIssueID",
                expected: "GH-583",
                actual: upstreamIssueID.rawValue
            )
        }
        guard capabilityMatrix.matrixHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.capabilityMatrix",
                expected: "GH-584 capability matrix held",
                actual: "mismatch"
            )
        }
        guard credentialGate.gateHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.credentialGate",
                expected: "GH-584 testnet credential gate held",
                actual: "mismatch"
            )
        }
        guard omsHandoff.handoffBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.omsHandoff",
                expected: "GH-583 OMS handoff held",
                actual: "mismatch"
            )
        }
        guard Set(dryRunPreviews.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.dryRunPreviews",
                expected: ReleaseV020BinanceSpotExecutionClientCommandKind.allCases
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: dryRunPreviews.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(testnetRequests.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.testnetRequests",
                expected: ReleaseV020BinanceSpotExecutionClientCommandKind.allCases
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: testnetRequests.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.acknowledgements",
                expected: ReleaseV020BinanceSpotExecutionClientCommandKind.allCases
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: acknowledgements.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard testnetRequests.map(\.requestID) == acknowledgements.map(\.requestID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.requestAckCorrelation",
                expected: "request IDs match acknowledgement IDs by command order",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020BinanceSpotExecutionClientAdapter.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.validationAnchors",
                expected: ReleaseV020BinanceSpotExecutionClientAdapter.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("dryRunEvidenceComplete", dryRunEvidenceComplete),
            ("testnetEvidenceGateHeld", testnetEvidenceGateHeld),
            ("productionRejectedByDefault", productionRejectedByDefault)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointEnabledByDefault", productionEndpointEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("realOrderSubmitted", realOrderSubmitted),
            ("realOrderCanceled", realOrderCanceled),
            ("realOrderReplaced", realOrderReplaced),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.capabilityMatrix = capabilityMatrix
        self.credentialGate = credentialGate
        self.omsHandoff = omsHandoff
        self.dryRunPreviews = dryRunPreviews
        self.testnetRequests = testnetRequests
        self.acknowledgements = acknowledgements
        self.validationAnchors = validationAnchors
        self.dryRunEvidenceComplete = dryRunEvidenceComplete
        self.testnetEvidenceGateHeld = testnetEvidenceGateHeld
        self.productionRejectedByDefault = productionRejectedByDefault
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderSubmitted = realOrderSubmitted
        self.realOrderCanceled = realOrderCanceled
        self.realOrderReplaced = realOrderReplaced
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-584"
            && upstreamIssueID.rawValue == "GH-583"
            && capabilityMatrix.matrixHeld
            && credentialGate.gateHeld
            && omsHandoff.handoffBoundaryHeld
            && Set(dryRunPreviews.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases)
            && Set(testnetRequests.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases)
            && Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases)
            && dryRunPreviews.allSatisfy(\.previewBoundaryHeld)
            && testnetRequests.allSatisfy(\.requestMappingHeld)
            && acknowledgements.allSatisfy(\.ackBoundaryHeld)
            && testnetRequests.map(\.requestID) == acknowledgements.map(\.requestID)
            && validationAnchors == ReleaseV020BinanceSpotExecutionClientAdapter.requiredValidationAnchors
            && dryRunEvidenceComplete
            && testnetEvidenceGateHeld
            && productionRejectedByDefault
            && productionEndpointEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && brokerGatewayTouched == false
            && realOrderSubmitted == false
            && realOrderCanceled == false
            && realOrderReplaced == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020BinanceSpotExecutionClientAdapter 是 #584 的 Spot ExecutionClient adapter 实现。
///
/// Adapter 只把 #583 Spot OMS handoff identity 映射为 Binance Spot dry-run preview 和 testnet
/// submit / cancel / replace request，并通过 transport protocol 输出 deterministic ack。
/// 它不连接 production endpoint，不读取 production secret，不生成真实订单，也不触碰 broker gateway。
/// `GH-584-PRODUCTION-REJECTED-BY-DEFAULT`
public struct ReleaseV020BinanceSpotExecutionClientAdapter: Codable, Equatable, Sendable {
    public let adapterID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let capabilityMatrix: ReleaseV020BinanceSpotExecutionClientCapabilityMatrix
    public let credentialGate: ReleaseV020BinanceSpotExecutionClientCredentialGate
    public let omsHandoff: ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence
    public let testnetMode: ReleaseV020BinanceSpotExecutionClientMode
    public let validationAnchors: [String]
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeGate: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        adapterID: Identifier = Identifier.constant("gh-584-binance-spot-executionclient-adapter"),
        issueID: Identifier = Identifier.constant("GH-584"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        capabilityMatrix: ReleaseV020BinanceSpotExecutionClientCapabilityMatrix? = nil,
        credentialGate: ReleaseV020BinanceSpotExecutionClientCredentialGate? = nil,
        omsHandoff: ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence? = nil,
        testnetMode: ReleaseV020BinanceSpotExecutionClientMode = .testnet,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeGate: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMatrix = try capabilityMatrix ?? ReleaseV020BinanceSpotExecutionClientCapabilityMatrix.deterministicFixture()
        let resolvedGate = try credentialGate ?? ReleaseV020BinanceSpotExecutionClientCredentialGate.deterministicFixture()
        let resolvedHandoff = try omsHandoff ?? ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence.deterministicFixture()

        guard issueID.rawValue == "GH-584" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.issueID",
                expected: "GH-584",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.upstreamIssueID",
                expected: "GH-583",
                actual: upstreamIssueID.rawValue
            )
        }
        guard resolvedMatrix.matrixHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.capabilityMatrix",
                expected: "GH-584 capability matrix held",
                actual: "mismatch"
            )
        }
        guard resolvedGate.gateHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.credentialGate",
                expected: "GH-584 credential gate held",
                actual: "mismatch"
            )
        }
        guard resolvedHandoff.handoffBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.omsHandoff",
                expected: "GH-583 Spot OMS handoff held",
                actual: "mismatch"
            )
        }
        guard testnetMode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.productionEnvironment"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionEndpointEnabledByDefault", productionEndpointEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("bypassesOMS", bypassesOMS),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("bypassesNoTradeGate", bypassesNoTradeGate),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceSpotExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.adapterID = adapterID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.capabilityMatrix = resolvedMatrix
        self.credentialGate = resolvedGate
        self.omsHandoff = resolvedHandoff
        self.testnetMode = testnetMode
        self.validationAnchors = validationAnchors
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.bypassesOMS = bypassesOMS
        self.bypassesKillSwitch = bypassesKillSwitch
        self.bypassesNoTradeGate = bypassesNoTradeGate
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var adapterBoundaryHeld: Bool {
        issueID.rawValue == "GH-584"
            && upstreamIssueID.rawValue == "GH-583"
            && capabilityMatrix.matrixHeld
            && credentialGate.gateHeld
            && omsHandoff.handoffBoundaryHeld
            && testnetMode == .testnet
            && validationAnchors == Self.requiredValidationAnchors
            && productionEndpointEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && brokerGatewayTouched == false
            && bypassesOMS == false
            && bypassesKillSwitch == false
            && bypassesNoTradeGate == false
            && liveCommandSurfaceTouched == false
    }

    public func dryRunPreview(
        _ kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) throws -> ReleaseV020BinanceSpotExecutionClientDryRunPreview {
        guard adapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.adapterBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let clientOrderID = Self.clientOrderID(for: kind)
        return try ReleaseV020BinanceSpotExecutionClientDryRunPreview(
            previewID: Identifier.constant("gh-584-\(kind.rawValue)-dry-run-preview"),
            commandKind: kind,
            credentialReferenceID: credentialGate.credentialReferenceID,
            sourceOrderIntentID: omsHandoff.sourceOrderIntentID,
            sourceEventLogID: omsHandoff.sourceEventLogID,
            sourceOMSOrderID: omsHandoff.sourceOMSOrderID,
            clientOrderID: clientOrderID,
            symbol: omsHandoff.instrument.symbol.rawValue,
            queryItems: try Self.queryItems(
                kind: kind,
                handoff: omsHandoff,
                clientOrderID: clientOrderID
            )
        )
    }

    public func submit(
        transport: ReleaseV020BinanceSpotExecutionClientTestnetTransport =
            ReleaseV020BinanceSpotDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetAck {
        try send(kind: .submit, transport: transport)
    }

    public func cancel(
        transport: ReleaseV020BinanceSpotExecutionClientTestnetTransport =
            ReleaseV020BinanceSpotDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetAck {
        try send(kind: .cancel, transport: transport)
    }

    public func replace(
        transport: ReleaseV020BinanceSpotExecutionClientTestnetTransport =
            ReleaseV020BinanceSpotDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetAck {
        try send(kind: .replace, transport: transport)
    }

    public func deterministicAdapterEvidence() throws -> ReleaseV020BinanceSpotExecutionClientAdapterEvidence {
        let previews = try ReleaseV020BinanceSpotExecutionClientCommandKind.allCases.map(dryRunPreview)
        let requests = try ReleaseV020BinanceSpotExecutionClientCommandKind.allCases.map(testnetRequest)
        let acknowledgements = try requests.map { request in
            try ReleaseV020BinanceSpotDeterministicTestnetTransport().send(request)
        }
        return try ReleaseV020BinanceSpotExecutionClientAdapterEvidence(
            capabilityMatrix: capabilityMatrix,
            credentialGate: credentialGate,
            omsHandoff: omsHandoff,
            dryRunPreviews: previews,
            testnetRequests: requests,
            acknowledgements: acknowledgements
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceSpotExecutionClientAdapter {
        try ReleaseV020BinanceSpotExecutionClientAdapter()
    }

    public static let requiredValidationAnchors = [
        "GH-584-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER",
        "GH-584-SUBMIT-CANCEL-REPLACE-MAPPING",
        "GH-584-DRYRUN-EVIDENCE",
        "GH-584-TESTNET-EVIDENCE-GATE",
        "GH-584-PRODUCTION-REJECTED-BY-DEFAULT",
        "TVM-RELEASE-V020-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER"
    ]

    public static let testnetHost = "testnet.binance.vision"

    public static var defaultTestnetBaseURL: URL {
        guard let url = URL(string: "https://\(testnetHost)") else {
            preconditionFailure("Invalid deterministic GH-584 Binance Spot testnet base URL")
        }
        return url
    }

    static func endpointPath(
        for kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) -> String {
        switch kind {
        case .submit, .cancel:
            "/api/v3/order"
        case .replace:
            "/api/v3/order/cancelReplace"
        }
    }

    static func method(
        for kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) -> ReleaseV020BinanceSpotExecutionClientHTTPMethod {
        switch kind {
        case .submit, .replace:
            .post
        case .cancel:
            .delete
        }
    }

    static func requiredQueryItemNames(
        for kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) -> [String] {
        switch kind {
        case .submit:
            ["symbol", "side", "type", "timeInForce", "quantity", "price", "newClientOrderId", "recvWindow", "timestamp"]
        case .cancel:
            ["symbol", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"]
        case .replace:
            [
                "symbol",
                "side",
                "type",
                "timeInForce",
                "quantity",
                "price",
                "cancelOrigClientOrderId",
                "newClientOrderId",
                "cancelReplaceMode",
                "recvWindow",
                "timestamp"
            ]
        }
    }

    private func testnetRequest(
        _ kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetRequest {
        guard adapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceSpotExecutionClient.adapterBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let clientOrderID = Self.clientOrderID(for: kind)
        return try ReleaseV020BinanceSpotExecutionClientTestnetRequest(
            requestID: Identifier.constant("gh-584-\(kind.rawValue)-testnet-request"),
            commandKind: kind,
            credentialReferenceID: credentialGate.credentialReferenceID,
            sourceOrderIntentID: omsHandoff.sourceOrderIntentID,
            sourceEventLogID: omsHandoff.sourceEventLogID,
            sourceOMSOrderID: omsHandoff.sourceOMSOrderID,
            clientOrderID: clientOrderID,
            symbol: omsHandoff.instrument.symbol.rawValue,
            queryItems: try Self.queryItems(
                kind: kind,
                handoff: omsHandoff,
                clientOrderID: clientOrderID
            )
        )
    }

    private func send(
        kind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        transport: ReleaseV020BinanceSpotExecutionClientTestnetTransport
    ) throws -> ReleaseV020BinanceSpotExecutionClientTestnetAck {
        let request = try testnetRequest(kind)
        return try transport.send(request)
    }

    private static func clientOrderID(
        for kind: ReleaseV020BinanceSpotExecutionClientCommandKind
    ) -> Identifier {
        Identifier.constant("gh-584-client-order-\(kind.rawValue)")
    }

    private static func queryItems(
        kind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        handoff: ReleaseV020BinanceSpotExecutionClientOMSHandoffEvidence,
        clientOrderID: Identifier
    ) throws -> [ReleaseV020BinanceSpotExecutionClientQueryItem] {
        let quantityValue = formatDecimal(handoff.quantity.rawValue)
        let priceValue = formatDecimal(handoff.referencePrice.rawValue)
        switch kind {
        case .submit:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "side", value: handoff.side),
                .init(name: "type", value: "LIMIT"),
                .init(name: "timeInForce", value: "GTC"),
                .init(name: "quantity", value: quantityValue),
                .init(name: "price", value: priceValue),
                .init(name: "newClientOrderId", value: clientOrderID.rawValue),
                .init(name: "recvWindow", value: "5000"),
                .init(name: "timestamp", value: "1704067200000")
            ]
        case .cancel:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "origClientOrderId", value: Self.clientOrderID(for: .submit).rawValue),
                .init(name: "newClientOrderId", value: clientOrderID.rawValue),
                .init(name: "recvWindow", value: "5000"),
                .init(name: "timestamp", value: "1704067205000")
            ]
        case .replace:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "side", value: handoff.side),
                .init(name: "type", value: "LIMIT"),
                .init(name: "timeInForce", value: "GTC"),
                .init(name: "quantity", value: quantityValue),
                .init(name: "price", value: priceValue),
                .init(name: "cancelOrigClientOrderId", value: Self.clientOrderID(for: .submit).rawValue),
                .init(name: "newClientOrderId", value: clientOrderID.rawValue),
                .init(name: "cancelReplaceMode", value: "ALLOW_FAILURE"),
                .init(name: "recvWindow", value: "5000"),
                .init(name: "timestamp", value: "1704067210000")
            ]
        }
    }

    private static func formatDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
