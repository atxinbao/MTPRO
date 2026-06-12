import DomainModel
import Foundation
import MessageBus

/// ReleaseV020BinanceUSDMPerpExecutionClientCommandKind 固定 GH-585 允许的 Binance USD-M Perp 命令族。
///
/// 这些 case 只表示 submit / cancel / replace 的本地 request mapping 语义，不代表真实 broker command、
/// production order command、leverage action、margin action 或 execution authorization。
public enum ReleaseV020BinanceUSDMPerpExecutionClientCommandKind:
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

/// ReleaseV020BinanceUSDMPerpExecutionClientMode 区分 dry-run、testnet 和仍禁止的 production。
public enum ReleaseV020BinanceUSDMPerpExecutionClientMode:
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

/// ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod 固定 Perp command mapping 使用的 HTTP method。
public enum ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod:
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

/// ReleaseV020BinanceUSDMPerpExecutionClientPositionSide 是 USD-M Perp hedge-side mapping evidence。
///
/// 它只表达 Binance request 参数 `positionSide` 的本地映射，不打开 hedge runtime、broker position
/// sync、leverage action 或 margin action。
public enum ReleaseV020BinanceUSDMPerpExecutionClientPositionSide:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case long = "LONG"
    case short = "SHORT"
}

/// ReleaseV020BinanceUSDMPerpExecutionClientQueryItem 是 GH-585 的 redacted request mapping 参数。
///
/// Query item 只保留参数名和值；signature、API key、secret material 和 raw broker payload 不能进入该结构。
public struct ReleaseV020BinanceUSDMPerpExecutionClientQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.queryItem.name",
                expected: "non-empty query item name",
                actual: "empty"
            )
        }
        guard trimmedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.queryItem.value",
                expected: "non-empty query item value",
                actual: "empty"
            )
        }
        guard trimmedName.lowercased() != "signature" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.signatureValue"
            )
        }

        self.name = trimmedName
        self.value = trimmedValue
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate 固定 GH-585 testnet credential reference 边界。
///
/// Gate 只允许 testnet credential reference 进入 evidence，不保存 key / secret value，不读取 production
/// secret，也不允许 testnet credential 被提升为 production credential。
/// `GH-585-TESTNET-EVIDENCE-GATE`
public struct ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let credentialReferenceID: Identifier
    public let mode: ReleaseV020BinanceUSDMPerpExecutionClientMode
    public let credentialReferenceOnly: Bool
    public let credentialValueStored: Bool
    public let credentialValueExposed: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionCredentialAccepted: Bool
    public let testnetCredentialPromotesProduction: Bool

    public init(
        gateID: Identifier = Identifier.constant("gh-585-testnet-credential-gate"),
        credentialReferenceID: Identifier,
        mode: ReleaseV020BinanceUSDMPerpExecutionClientMode = .testnet,
        credentialReferenceOnly: Bool = true,
        credentialValueStored: Bool = false,
        credentialValueExposed: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionCredentialAccepted: Bool = false,
        testnetCredentialPromotesProduction: Bool = false
    ) throws {
        guard mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.productionCredential"
            )
        }
        guard credentialReferenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.credentialReferenceOnly",
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
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
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

    public static func deterministicFixture() throws -> ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate {
        try ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate(
            credentialReferenceID: Identifier.constant("gh-585-binance-usdm-perp-testnet-credential-reference")
        )
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence 是 #585 消费 #583 Perp OMS 的本地交接证据。
///
/// 该结构只在 ExecutionClient 侧保留最低限度的 handoff identity，不依赖 ExecutionEngine target，
/// 同时证明 request mapping 仍然受 OMS / Event Store / kill switch / no-trade gate 约束。
public struct ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence: Codable, Equatable, Sendable {
    public let handoffID: Identifier
    public let sourceIssueID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let action: String
    public let side: String
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide
    public let reduceOnly: Bool
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
    public let executesLeverageActionBeforeAdapter: Bool
    public let executesMarginActionBeforeAdapter: Bool
    public let submitsRealOrderBeforeAdapter: Bool

    public init(
        handoffID: Identifier = Identifier.constant("gh-585-perp-oms-handoff"),
        sourceIssueID: Identifier = Identifier.constant("GH-583"),
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        action: String,
        side: String,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        reduceOnly: Bool,
        quantity: Quantity,
        referencePrice: Price,
        stateEvidence: [String],
        sourceValidationAnchors: [String] = [
            "GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE",
            "GH-583-PERP-LIFECYCLE",
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
        executesLeverageActionBeforeAdapter: Bool = false,
        executesMarginActionBeforeAdapter: Bool = false,
        submitsRealOrderBeforeAdapter: Bool = false
    ) throws {
        let normalizedSide = side.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedAction = action.trimmingCharacters(in: .whitespacesAndNewlines)
        guard sourceIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.sourceIssueID",
                expected: "GH-583",
                actual: sourceIssueID.rawValue
            )
        }
        guard instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.instrument",
                expected: ProductType.usdsPerpetual.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard targetExposure != .hold else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.targetExposure",
                expected: "submit/cancel/replace source must require Perp order intent",
                actual: targetExposure.rawValue
            )
        }
        guard ["BUY", "SELL"].contains(normalizedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.side",
                expected: "BUY or SELL",
                actual: normalizedSide
            )
        }
        guard Self.positionMappingIsValid(
            action: normalizedAction,
            side: normalizedSide,
            positionSide: positionSide,
            reduceOnly: reduceOnly
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.positionSideReduceOnly",
                expected: "open long/short or reduce-only close long/short mapping",
                actual: "\(normalizedAction) -> \(normalizedSide) -> \(positionSide.rawValue), reduceOnly=\(reduceOnly)"
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.quantity",
                expected: "positive quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard stateEvidence.contains("accepted"), stateEvidence.contains("submitted") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.stateEvidence",
                expected: "accepted and submitted OMS evidence",
                actual: stateEvidence.joined(separator: ",")
            )
        }
        guard sourceValidationAnchors.contains("GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE"),
              sourceValidationAnchors.contains("GH-583-PERP-LIFECYCLE") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.sourceValidationAnchors",
                expected: "GH-583 Perp anchors present",
                actual: sourceValidationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("sourceBoundaryHeld", sourceBoundaryHeld),
            ("requiresEventStoreWrite", requiresEventStoreWrite),
            ("requiresKillSwitchBeforeExecution", requiresKillSwitchBeforeExecution),
            ("requiresNoTradeGateBeforeExecution", requiresNoTradeGateBeforeExecution)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionOMSRuntimeEnabledByDefault", productionOMSRuntimeEnabledByDefault),
            ("callsExecutionClientBeforeAdapter", callsExecutionClientBeforeAdapter),
            ("touchesBrokerGatewayBeforeAdapter", touchesBrokerGatewayBeforeAdapter),
            ("executesLeverageActionBeforeAdapter", executesLeverageActionBeforeAdapter),
            ("executesMarginActionBeforeAdapter", executesMarginActionBeforeAdapter),
            ("submitsRealOrderBeforeAdapter", submitsRealOrderBeforeAdapter)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.handoffID = handoffID
        self.sourceIssueID = sourceIssueID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.action = normalizedAction
        self.side = normalizedSide
        self.positionSide = positionSide
        self.reduceOnly = reduceOnly
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
        self.executesLeverageActionBeforeAdapter = executesLeverageActionBeforeAdapter
        self.executesMarginActionBeforeAdapter = executesMarginActionBeforeAdapter
        self.submitsRealOrderBeforeAdapter = submitsRealOrderBeforeAdapter
    }

    public var handoffBoundaryHeld: Bool {
        sourceIssueID.rawValue == "GH-583"
            && instrument.productType == .usdsPerpetual
            && targetExposure != .hold
            && Self.positionMappingIsValid(action: action, side: side, positionSide: positionSide, reduceOnly: reduceOnly)
            && quantity.rawValue > 0
            && stateEvidence.contains("accepted")
            && stateEvidence.contains("submitted")
            && sourceValidationAnchors.contains("GH-583-PRODUCT-AWARE-OMS-STATE-MACHINE")
            && sourceValidationAnchors.contains("GH-583-PERP-LIFECYCLE")
            && eventStream.rawValue == "execution-oms-local"
            && sourceBoundaryHeld
            && requiresEventStoreWrite
            && requiresKillSwitchBeforeExecution
            && requiresNoTradeGateBeforeExecution
            && productionOMSRuntimeEnabledByDefault == false
            && callsExecutionClientBeforeAdapter == false
            && touchesBrokerGatewayBeforeAdapter == false
            && executesLeverageActionBeforeAdapter == false
            && executesMarginActionBeforeAdapter == false
            && submitsRealOrderBeforeAdapter == false
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence {
        try ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence(
            sourceOrderIntentID: Identifier.constant("gh-583-perp-reduce-only-close-long-intent"),
            sourceEventLogID: Identifier.constant("gh-583-perp-cancelled-event-log"),
            sourceOMSOrderID: Identifier.constant("gh-583-perp-cancelled-order"),
            instrument: InstrumentIdentity.binance(
                productType: .usdsPerpetual,
                symbol: Symbol.constant("BTCUSDT")
            ),
            targetExposure: .targetFlat,
            action: "reduceOnlyCloseLong",
            side: "SELL",
            positionSide: .long,
            reduceOnly: true,
            quantity: try Quantity(0.25, field: "releaseV020BinanceUSDMPerpExecutionClient.quantity"),
            referencePrice: try Price(43_500, field: "releaseV020BinanceUSDMPerpExecutionClient.referencePrice"),
            stateEvidence: ["new", "accepted", "submitted", "cancelled"]
        )
    }

    public static func positionMappingIsValid(
        action: String,
        side: String,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        reduceOnly: Bool
    ) -> Bool {
        switch (action, side, positionSide, reduceOnly) {
        case ("openLong", "BUY", .long, false),
             ("openShort", "SELL", .short, false),
             ("reduceOnlyCloseLong", "SELL", .long, true),
             ("reduceOnlyCloseShort", "BUY", .short, true):
            true
        default:
            false
        }
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping 是 dry-run / testnet 共用的 Perp request evidence。
///
/// Mapping 只固定 redacted query item shape；它不发出网络请求，不读取 secret，不生成真实签名。
public struct ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping: Codable, Equatable, Sendable {
    public let mappingID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind
    public let mode: ReleaseV020BinanceUSDMPerpExecutionClientMode
    public let baseURL: URL
    public let method: ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod
    public let endpointPath: String
    public let credentialReferenceID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let side: String
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide
    public let reduceOnly: Bool
    public let queryItems: [ReleaseV020BinanceUSDMPerpExecutionClientQueryItem]
    public let signatureRequired: Bool
    public let mappingAuditable: Bool
    public let networkCallPerformed: Bool
    public let signatureValueExposed: Bool
    public let productionEndpointTouched: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        mappingID: Identifier,
        issueID: Identifier = Identifier.constant("GH-585"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        commandKind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        mode: ReleaseV020BinanceUSDMPerpExecutionClientMode,
        baseURL: URL = ReleaseV020BinanceUSDMPerpExecutionClientAdapter.defaultTestnetBaseURL,
        method: ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod? = nil,
        endpointPath: String? = nil,
        credentialReferenceID: Identifier,
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        side: String,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        reduceOnly: Bool,
        queryItems: [ReleaseV020BinanceUSDMPerpExecutionClientQueryItem],
        signatureRequired: Bool = true,
        mappingAuditable: Bool = true,
        networkCallPerformed: Bool = false,
        signatureValueExposed: Bool = false,
        productionEndpointTouched: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMethod = method ?? ReleaseV020BinanceUSDMPerpExecutionClientAdapter.method(for: commandKind)
        let resolvedEndpointPath = endpointPath
            ?? ReleaseV020BinanceUSDMPerpExecutionClientAdapter.endpointPath(for: commandKind)
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSide = side.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard issueID.rawValue == "GH-585" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.issueID",
                expected: "GH-585",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.upstreamIssueID",
                expected: "GH-583",
                actual: upstreamIssueID.rawValue
            )
        }
        guard mode == .dryRun || mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.productionEnvironment"
            )
        }
        guard baseURL.scheme == "https",
              baseURL.host?.lowercased() == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.testnetHost else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.productionEndpoint"
            )
        }
        guard resolvedMethod == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.method(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.method",
                expected: ReleaseV020BinanceUSDMPerpExecutionClientAdapter.method(for: commandKind).rawValue,
                actual: resolvedMethod.rawValue
            )
        }
        guard resolvedEndpointPath == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.endpointPath(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.endpointPath",
                expected: ReleaseV020BinanceUSDMPerpExecutionClientAdapter.endpointPath(for: commandKind),
                actual: resolvedEndpointPath
            )
        }
        guard trimmedSymbol.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.symbol",
                expected: "non-empty Binance futures symbol",
                actual: "empty"
            )
        }
        guard ["BUY", "SELL"].contains(normalizedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.side",
                expected: "BUY or SELL",
                actual: normalizedSide
            )
        }
        guard queryItems.map(\.name) == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
        else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.queryItems",
                expected: ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
                    .joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard signatureRequired, mappingAuditable else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.mappingAudit",
                expected: "signature required and mapping auditable",
                actual: "signatureRequired=\(signatureRequired), mappingAuditable=\(mappingAuditable)"
            )
        }
        for forbiddenFlag in [
            ("networkCallPerformed", networkCallPerformed),
            ("signatureValueExposed", signatureValueExposed),
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.mappingID = mappingID
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
        self.side = normalizedSide
        self.positionSide = positionSide
        self.reduceOnly = reduceOnly
        self.queryItems = queryItems
        self.signatureRequired = signatureRequired
        self.mappingAuditable = mappingAuditable
        self.networkCallPerformed = networkCallPerformed
        self.signatureValueExposed = signatureValueExposed
        self.productionEndpointTouched = productionEndpointTouched
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var mappingBoundaryHeld: Bool {
        issueID.rawValue == "GH-585"
            && upstreamIssueID.rawValue == "GH-583"
            && (mode == .dryRun || mode == .testnet)
            && baseURL.host?.lowercased() == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.testnetHost
            && method == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.method(for: commandKind)
            && endpointPath == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.endpointPath(for: commandKind)
            && queryItems.map(\.name) == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredQueryItemNames(for: commandKind)
            && signatureRequired
            && mappingAuditable
            && networkCallPerformed == false
            && signatureValueExposed == false
            && productionEndpointTouched == false
            && productionSecretRead == false
            && brokerGatewayTouched == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck 是 GH-585 deterministic transport acknowledgement evidence。
///
/// Ack 只证明 testnet adapter 接受了 request mapping。它不代表 production exchange fill、broker fill、
/// reconciliation、portfolio update 或真实 order lifecycle。
public struct ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck: Codable, Equatable, Sendable {
    public let ackID: Identifier
    public let requestID: Identifier
    public let commandKind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind
    public let mode: ReleaseV020BinanceUSDMPerpExecutionClientMode
    public let acceptedByTestnetAdapter: Bool
    public let deterministicTraceID: Identifier
    public let responseStatus: String
    public let productionEndpointTouched: Bool
    public let productionOrderTouched: Bool
    public let brokerGatewayTouched: Bool

    public init(
        ackID: Identifier,
        requestID: Identifier,
        commandKind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        mode: ReleaseV020BinanceUSDMPerpExecutionClientMode = .testnet,
        acceptedByTestnetAdapter: Bool = true,
        deterministicTraceID: Identifier,
        responseStatus: String,
        productionEndpointTouched: Bool = false,
        productionOrderTouched: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard mode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.productionAck"
            )
        }
        guard acceptedByTestnetAdapter, responseStatus.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.acknowledgement",
                expected: "accepted testnet acknowledgement with non-empty status",
                actual: "invalid"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionOrderTouched", productionOrderTouched),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
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

/// ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport 是 GH-585 的 testnet transport protocol。
///
/// Protocol 只接受已经过 testnet credential gate 和 GH-583 OMS handoff 绑定的 request mapping。
/// Production URLSession / broker gateway transport 不属于当前 issue。
public protocol ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport: Sendable {
    func send(_ request: ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping) throws
        -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck
}

/// ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport 是 required validation 使用的 testnet fixture。
///
/// 该 transport 不连网、不读 secret、不生成真实签名，只对 request mapping 返回 deterministic ack。
public struct ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport:
    ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport
{
    public init() {}

    public func send(
        _ request: ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck {
        guard request.mode == .testnet, request.mappingBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.requestMappingHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck(
            ackID: Identifier.constant("gh-585-binance-usdm-perp-\(request.commandKind.rawValue)-ack"),
            requestID: request.mappingID,
            commandKind: request.commandKind,
            deterministicTraceID: Identifier.constant("gh-585-binance-usdm-perp-\(request.commandKind.rawValue)-trace"),
            responseStatus: "accepted by deterministic Binance USD-M Perp testnet \(request.commandKind.rawValue) adapter"
        )
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix 固定 GH-585 的 capability / forbidden matrix。
/// `GH-585-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER`
public struct ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix: Codable, Equatable, Sendable {
    public let matrixID: Identifier
    public let releaseVenue: String
    public let releaseProductType: ProductType
    public let releaseStrategyKinds: [String]
    public let supportedCommands: [ReleaseV020BinanceUSDMPerpExecutionClientCommandKind]
    public let supportedPositionSides: [ReleaseV020BinanceUSDMPerpExecutionClientPositionSide]
    public let requiresOMSHandoffEvidence: Bool
    public let requiresPositionSideEvidence: Bool
    public let requiresReduceOnlyEvidence: Bool
    public let requiresDryRunEvidence: Bool
    public let requiresTestnetCredentialGate: Bool
    public let productionDefaultRejectedGateHeld: Bool
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderSubmitted: Bool
    public let realOrderCanceled: Bool
    public let realOrderReplaced: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        matrixID: Identifier = Identifier.constant("gh-585-binance-usdm-perp-capability-matrix"),
        releaseVenue: String = "Binance",
        releaseProductType: ProductType = .usdsPerpetual,
        releaseStrategyKinds: [String] = ["EMA", "RSI"],
        supportedCommands: [ReleaseV020BinanceUSDMPerpExecutionClientCommandKind] =
            ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases,
        supportedPositionSides: [ReleaseV020BinanceUSDMPerpExecutionClientPositionSide] =
            ReleaseV020BinanceUSDMPerpExecutionClientPositionSide.allCases,
        requiresOMSHandoffEvidence: Bool = true,
        requiresPositionSideEvidence: Bool = true,
        requiresReduceOnlyEvidence: Bool = true,
        requiresDryRunEvidence: Bool = true,
        requiresTestnetCredentialGate: Bool = true,
        productionDefaultRejectedGateHeld: Bool = true,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderSubmitted: Bool = false,
        realOrderCanceled: Bool = false,
        realOrderReplaced: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard releaseVenue == "Binance", releaseProductType == .usdsPerpetual, releaseStrategyKinds == ["EMA", "RSI"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.releaseScope",
                expected: "Binance / usdsPerpetual / EMA+RSI",
                actual: "\(releaseVenue) / \(releaseProductType.rawValue) / \(releaseStrategyKinds.joined(separator: ","))"
            )
        }
        guard supportedCommands == ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases,
              supportedPositionSides == ReleaseV020BinanceUSDMPerpExecutionClientPositionSide.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.supportedMapping",
                expected: "all commands and LONG/SHORT positionSide",
                actual: "mismatch"
            )
        }
        for requiredFlag in [
            ("requiresOMSHandoffEvidence", requiresOMSHandoffEvidence),
            ("requiresPositionSideEvidence", requiresPositionSideEvidence),
            ("requiresReduceOnlyEvidence", requiresReduceOnlyEvidence),
            ("requiresDryRunEvidence", requiresDryRunEvidence),
            ("requiresTestnetCredentialGate", requiresTestnetCredentialGate),
            ("productionDefaultRejectedGateHeld", productionDefaultRejectedGateHeld)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.\(requiredFlag.0)",
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
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.matrixID = matrixID
        self.releaseVenue = releaseVenue
        self.releaseProductType = releaseProductType
        self.releaseStrategyKinds = releaseStrategyKinds
        self.supportedCommands = supportedCommands
        self.supportedPositionSides = supportedPositionSides
        self.requiresOMSHandoffEvidence = requiresOMSHandoffEvidence
        self.requiresPositionSideEvidence = requiresPositionSideEvidence
        self.requiresReduceOnlyEvidence = requiresReduceOnlyEvidence
        self.requiresDryRunEvidence = requiresDryRunEvidence
        self.requiresTestnetCredentialGate = requiresTestnetCredentialGate
        self.productionDefaultRejectedGateHeld = productionDefaultRejectedGateHeld
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderSubmitted = realOrderSubmitted
        self.realOrderCanceled = realOrderCanceled
        self.realOrderReplaced = realOrderReplaced
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var matrixHeld: Bool {
        releaseVenue == "Binance"
            && releaseProductType == .usdsPerpetual
            && releaseStrategyKinds == ["EMA", "RSI"]
            && supportedCommands == ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases
            && supportedPositionSides == ReleaseV020BinanceUSDMPerpExecutionClientPositionSide.allCases
            && requiresOMSHandoffEvidence
            && requiresPositionSideEvidence
            && requiresReduceOnlyEvidence
            && requiresDryRunEvidence
            && requiresTestnetCredentialGate
            && productionDefaultRejectedGateHeld
            && productionEndpointEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && brokerGatewayTouched == false
            && realOrderSubmitted == false
            && realOrderCanceled == false
            && realOrderReplaced == false
            && liveCommandSurfaceTouched == false
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix {
        try ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix()
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence 汇总 GH-585 adapter evidence。
/// `GH-585-DRYRUN-EVIDENCE`
/// `TVM-RELEASE-V020-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER`
public struct ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence: Codable, Equatable, Sendable {
    public let capabilityMatrix: ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix
    public let credentialGate: ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate
    public let omsHandoff: ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence
    public let dryRunPreviews: [ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping]
    public let testnetRequests: [ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping]
    public let acknowledgements: [ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck]
    public let validationAnchors: [String]
    public let dryRunEvidenceComplete: Bool
    public let testnetEvidenceGateHeld: Bool
    public let positionSideReduceOnlyMappingHeld: Bool
    public let productionRejectedByDefault: Bool
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderSubmitted: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        capabilityMatrix: ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix,
        credentialGate: ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate,
        omsHandoff: ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence,
        dryRunPreviews: [ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping],
        testnetRequests: [ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping],
        acknowledgements: [ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck],
        validationAnchors: [String] = ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredValidationAnchors,
        dryRunEvidenceComplete: Bool = true,
        testnetEvidenceGateHeld: Bool = true,
        positionSideReduceOnlyMappingHeld: Bool = true,
        productionRejectedByDefault: Bool = true,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderSubmitted: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard capabilityMatrix.matrixHeld, credentialGate.gateHeld, omsHandoff.handoffBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.evidenceInputs",
                expected: "matrix, credential gate and OMS handoff held",
                actual: "mismatch"
            )
        }
        guard Set(dryRunPreviews.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases),
              Set(testnetRequests.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases),
              Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.commandCoverage",
                expected: "submit,cancel,replace",
                actual: "mismatch"
            )
        }
        guard testnetRequests.map(\.mappingID) == acknowledgements.map(\.requestID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.requestAckCorrelation",
                expected: "request IDs match acknowledgement IDs by command order",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.validationAnchors",
                expected: ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("dryRunEvidenceComplete", dryRunEvidenceComplete),
            ("testnetEvidenceGateHeld", testnetEvidenceGateHeld),
            ("positionSideReduceOnlyMappingHeld", positionSideReduceOnlyMappingHeld),
            ("productionRejectedByDefault", productionRejectedByDefault)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.\(requiredFlag.0)",
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
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
            )
        }

        self.capabilityMatrix = capabilityMatrix
        self.credentialGate = credentialGate
        self.omsHandoff = omsHandoff
        self.dryRunPreviews = dryRunPreviews
        self.testnetRequests = testnetRequests
        self.acknowledgements = acknowledgements
        self.validationAnchors = validationAnchors
        self.dryRunEvidenceComplete = dryRunEvidenceComplete
        self.testnetEvidenceGateHeld = testnetEvidenceGateHeld
        self.positionSideReduceOnlyMappingHeld = positionSideReduceOnlyMappingHeld
        self.productionRejectedByDefault = productionRejectedByDefault
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderSubmitted = realOrderSubmitted
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var evidenceBoundaryHeld: Bool {
        capabilityMatrix.matrixHeld
            && credentialGate.gateHeld
            && omsHandoff.handoffBoundaryHeld
            && Set(dryRunPreviews.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases)
            && Set(testnetRequests.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases)
            && Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases)
            && dryRunPreviews.allSatisfy(\.mappingBoundaryHeld)
            && testnetRequests.allSatisfy(\.mappingBoundaryHeld)
            && acknowledgements.allSatisfy(\.ackBoundaryHeld)
            && testnetRequests.map(\.mappingID) == acknowledgements.map(\.requestID)
            && validationAnchors == ReleaseV020BinanceUSDMPerpExecutionClientAdapter.requiredValidationAnchors
            && dryRunEvidenceComplete
            && testnetEvidenceGateHeld
            && positionSideReduceOnlyMappingHeld
            && productionRejectedByDefault
            && productionEndpointEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionSecretReadEnabledByDefault == false
            && brokerGatewayTouched == false
            && realOrderSubmitted == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020BinanceUSDMPerpExecutionClientAdapter 是 GH-585 的 Perp ExecutionClient adapter 实现。
///
/// Adapter 只把 GH-583 Perp OMS handoff identity 映射为 Binance USD-M Futures dry-run preview 和 testnet
/// submit / cancel / replace request，并通过 transport protocol 输出 deterministic ack。
/// `GH-585-PRODUCTION-REJECTED-BY-DEFAULT`
public struct ReleaseV020BinanceUSDMPerpExecutionClientAdapter: Codable, Equatable, Sendable {
    public let adapterID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let capabilityMatrix: ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix
    public let credentialGate: ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate
    public let omsHandoff: ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence
    public let testnetMode: ReleaseV020BinanceUSDMPerpExecutionClientMode
    public let validationAnchors: [String]
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let bypassesNoTradeGate: Bool
    public let executesLeverageAction: Bool
    public let executesMarginAction: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        adapterID: Identifier = Identifier.constant("gh-585-binance-usdm-perp-executionclient-adapter"),
        issueID: Identifier = Identifier.constant("GH-585"),
        upstreamIssueID: Identifier = Identifier.constant("GH-583"),
        capabilityMatrix: ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix? = nil,
        credentialGate: ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate? = nil,
        omsHandoff: ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence? = nil,
        testnetMode: ReleaseV020BinanceUSDMPerpExecutionClientMode = .testnet,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        bypassesNoTradeGate: Bool = false,
        executesLeverageAction: Bool = false,
        executesMarginAction: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMatrix = try capabilityMatrix
            ?? ReleaseV020BinanceUSDMPerpExecutionClientCapabilityMatrix.deterministicFixture()
        let resolvedGate = try credentialGate
            ?? ReleaseV020BinanceUSDMPerpExecutionClientCredentialGate.deterministicFixture()
        let resolvedHandoff = try omsHandoff
            ?? ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence.deterministicFixture()

        guard issueID.rawValue == "GH-585", upstreamIssueID.rawValue == "GH-583" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.issueChain",
                expected: "GH-585 consumes GH-583",
                actual: "\(issueID.rawValue) consumes \(upstreamIssueID.rawValue)"
            )
        }
        guard resolvedMatrix.matrixHeld, resolvedGate.gateHeld, resolvedHandoff.handoffBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.adapterInputs",
                expected: "matrix, credential gate and Perp OMS handoff held",
                actual: "mismatch"
            )
        }
        guard testnetMode == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.productionEnvironment"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.validationAnchors",
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
            ("executesLeverageAction", executesLeverageAction),
            ("executesMarginAction", executesMarginAction),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020BinanceUSDMPerpExecutionClient.\(forbiddenFlag.0)"
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
        self.executesLeverageAction = executesLeverageAction
        self.executesMarginAction = executesMarginAction
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var adapterBoundaryHeld: Bool {
        issueID.rawValue == "GH-585"
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
            && executesLeverageAction == false
            && executesMarginAction == false
            && liveCommandSurfaceTouched == false
    }

    public func dryRunPreview(
        _ kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping {
        try requestMapping(kind: kind, mode: .dryRun)
    }

    public func submit(
        transport: ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport =
            ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck {
        try send(kind: .submit, transport: transport)
    }

    public func cancel(
        transport: ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport =
            ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck {
        try send(kind: .cancel, transport: transport)
    }

    public func replace(
        transport: ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport =
            ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport()
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck {
        try send(kind: .replace, transport: transport)
    }

    public func deterministicAdapterEvidence() throws -> ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence {
        let previews = try ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases.map {
            try dryRunPreview($0)
        }
        let requests = try ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases.map {
            try requestMapping(kind: $0, mode: .testnet)
        }
        let acknowledgements = try requests.map {
            try ReleaseV020BinanceUSDMPerpDeterministicTestnetTransport().send($0)
        }
        return try ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence(
            capabilityMatrix: capabilityMatrix,
            credentialGate: credentialGate,
            omsHandoff: omsHandoff,
            dryRunPreviews: previews,
            testnetRequests: requests,
            acknowledgements: acknowledgements
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceUSDMPerpExecutionClientAdapter {
        try ReleaseV020BinanceUSDMPerpExecutionClientAdapter()
    }

    public static let requiredValidationAnchors = [
        "GH-585-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER",
        "GH-585-SUBMIT-CANCEL-REPLACE-MAPPING",
        "GH-585-POSITIONSIDE-REDUCEONLY-MAPPING",
        "GH-585-DRYRUN-EVIDENCE",
        "GH-585-TESTNET-EVIDENCE-GATE",
        "GH-585-PRODUCTION-REJECTED-BY-DEFAULT",
        "TVM-RELEASE-V020-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER"
    ]

    public static let testnetHost = "testnet.binancefuture.com"

    public static var defaultTestnetBaseURL: URL {
        guard let url = URL(string: "https://\(testnetHost)") else {
            preconditionFailure("Invalid deterministic GH-585 Binance USD-M Perp testnet base URL")
        }
        return url
    }

    static func endpointPath(for kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind) -> String {
        switch kind {
        case .submit, .cancel, .replace:
            "/fapi/v1/order"
        }
    }

    static func method(
        for kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind
    ) -> ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod {
        switch kind {
        case .submit:
            .post
        case .cancel:
            .delete
        case .replace:
            .put
        }
    }

    static func requiredQueryItemNames(for kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind) -> [String] {
        switch kind {
        case .submit:
            [
                "symbol", "side", "positionSide", "type", "timeInForce", "quantity",
                "price", "reduceOnly", "newClientOrderId", "recvWindow", "timestamp"
            ]
        case .cancel:
            ["symbol", "origClientOrderId", "recvWindow", "timestamp"]
        case .replace:
            [
                "symbol", "side", "positionSide", "quantity", "price",
                "reduceOnly", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"
            ]
        }
    }

    private func send(
        kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        transport: ReleaseV020BinanceUSDMPerpExecutionClientTestnetTransport
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientTestnetAck {
        let request = try requestMapping(kind: kind, mode: .testnet)
        return try transport.send(request)
    }

    private func requestMapping(
        kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        mode: ReleaseV020BinanceUSDMPerpExecutionClientMode
    ) throws -> ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping {
        guard adapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020BinanceUSDMPerpExecutionClient.adapterBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let clientOrderID = Self.clientOrderID(for: kind)
        return try ReleaseV020BinanceUSDMPerpExecutionClientRequestMapping(
            mappingID: Identifier.constant("gh-585-\(kind.rawValue)-\(mode.rawValue)-mapping"),
            commandKind: kind,
            mode: mode,
            credentialReferenceID: credentialGate.credentialReferenceID,
            sourceOrderIntentID: omsHandoff.sourceOrderIntentID,
            sourceEventLogID: omsHandoff.sourceEventLogID,
            sourceOMSOrderID: omsHandoff.sourceOMSOrderID,
            clientOrderID: clientOrderID,
            symbol: omsHandoff.instrument.symbol.rawValue,
            side: omsHandoff.side,
            positionSide: omsHandoff.positionSide,
            reduceOnly: omsHandoff.reduceOnly,
            queryItems: try Self.queryItems(kind: kind, handoff: omsHandoff, clientOrderID: clientOrderID)
        )
    }

    private static func clientOrderID(for kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind) -> Identifier {
        Identifier.constant("gh-585-client-order-\(kind.rawValue)")
    }

    private static func queryItems(
        kind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        handoff: ReleaseV020BinanceUSDMPerpExecutionClientOMSHandoffEvidence,
        clientOrderID: Identifier
    ) throws -> [ReleaseV020BinanceUSDMPerpExecutionClientQueryItem] {
        let quantityValue = formatDecimal(handoff.quantity.rawValue)
        let priceValue = formatDecimal(handoff.referencePrice.rawValue)
        let reduceOnlyValue = handoff.reduceOnly ? "true" : "false"
        switch kind {
        case .submit:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "side", value: handoff.side),
                .init(name: "positionSide", value: handoff.positionSide.rawValue),
                .init(name: "type", value: "LIMIT"),
                .init(name: "timeInForce", value: "GTC"),
                .init(name: "quantity", value: quantityValue),
                .init(name: "price", value: priceValue),
                .init(name: "reduceOnly", value: reduceOnlyValue),
                .init(name: "newClientOrderId", value: clientOrderID.rawValue),
                .init(name: "recvWindow", value: "5000"),
                .init(name: "timestamp", value: "1704067200000")
            ]
        case .cancel:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "origClientOrderId", value: Self.clientOrderID(for: .submit).rawValue),
                .init(name: "recvWindow", value: "5000"),
                .init(name: "timestamp", value: "1704067205000")
            ]
        case .replace:
            return try [
                .init(name: "symbol", value: handoff.instrument.symbol.rawValue),
                .init(name: "side", value: handoff.side),
                .init(name: "positionSide", value: handoff.positionSide.rawValue),
                .init(name: "quantity", value: quantityValue),
                .init(name: "price", value: priceValue),
                .init(name: "reduceOnly", value: reduceOnlyValue),
                .init(name: "origClientOrderId", value: Self.clientOrderID(for: .submit).rawValue),
                .init(name: "newClientOrderId", value: clientOrderID.rawValue),
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
