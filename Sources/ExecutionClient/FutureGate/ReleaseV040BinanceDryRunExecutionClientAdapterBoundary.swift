import DomainModel
import Foundation

/// ReleaseV040BinanceDryRunExecutionClientCommandKind 固定 GH-701 允许映射的 dry-run command。
///
/// 这些 command 只生成 redacted request evidence 和 dry-run acknowledgement，不触发网络请求、
/// broker gateway、真实 submit / cancel / replace 或 production cutover。
public enum ReleaseV040BinanceDryRunExecutionClientCommandKind:
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

/// ReleaseV040BinanceDryRunExecutionClientHTTPMethod 固定 Binance request mapping 的 method evidence。
public enum ReleaseV040BinanceDryRunExecutionClientHTTPMethod:
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

/// ReleaseV040BinanceDryRunExecutionClientQueryItem 是 redacted request 参数。
///
/// query item 不允许承载 signature、API key、secret material 或 raw broker payload。
public struct ReleaseV040BinanceDryRunExecutionClientQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false, trimmedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.queryItem",
                expected: "non-empty name and value",
                actual: "\(trimmedName):\(trimmedValue)"
            )
        }
        guard trimmedName.lowercased() != "signature" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.signatureValue")
        }
        self.name = trimmedName
        self.value = trimmedValue
    }
}

/// ReleaseV040BinanceDryRunExecutionClientOMSHandoff 是 #700 到 #701 的中立 handoff。
///
/// ExecutionClient target 不依赖 ExecutionEngine target，因此该结构只保存 GH-700 lifecycle 的
/// 稳定 issue、runID、state、OMS envelope 和 product-aware order identity。
public struct ReleaseV040BinanceDryRunExecutionClientOMSHandoff: Codable, Equatable, Sendable {
    public let handoffID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let sourceIssueID: Identifier
    public let sourceRiskIssueID: Identifier
    public let sourceLifecycleLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceLifecyclePath: String
    public let sourceFinalState: String
    public let sourceEventIDs: [Identifier]
    public let sourceOMSEnvelopeIDs: [Identifier]
    public let instrument: InstrumentIdentity
    public let targetExposure: TargetExposureIntent
    public let quantity: Quantity
    public let referencePrice: Price
    public let stateEvidence: [String]
    public let sourceReplayEvidenceHeld: Bool
    public let sourceBoundaryHeld: Bool
    public let authorizesProductionOrder: Bool
    public let exposesRawBrokerPayload: Bool

    public var runID: Identifier { runContext.runID }

    public var handoffHeld: Bool {
        runContext.mode == .dryRun
            && runContext.boundaryHeld
            && sourceIssueID.rawValue == "GH-700"
            && sourceRiskIssueID.rawValue == "GH-699"
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType)
            && instrument.venue.rawValue == "binance"
            && targetExposure.requiresOrderIntent
            && stateEvidence.contains("submitted-dry-run")
            && ["filled-simulated", "cancelled"].contains(sourceFinalState)
            && sourceEventIDs.isEmpty == false
            && sourceOMSEnvelopeIDs.isEmpty == false
            && quantity.rawValue > 0
            && referencePrice.rawValue > 0
            && sourceReplayEvidenceHeld
            && sourceBoundaryHeld
            && authorizesProductionOrder == false
            && exposesRawBrokerPayload == false
    }

    public init(
        handoffID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        sourceIssueID: Identifier = Identifier.constant("GH-700"),
        sourceRiskIssueID: Identifier = Identifier.constant("GH-699"),
        sourceLifecycleLogID: Identifier,
        sourceOMSOrderID: Identifier,
        sourceLifecyclePath: String,
        sourceFinalState: String,
        sourceEventIDs: [Identifier],
        sourceOMSEnvelopeIDs: [Identifier],
        instrument: InstrumentIdentity,
        targetExposure: TargetExposureIntent,
        quantity: Quantity,
        referencePrice: Price,
        stateEvidence: [String],
        sourceReplayEvidenceHeld: Bool = true,
        sourceBoundaryHeld: Bool = true,
        authorizesProductionOrder: Bool = false,
        exposesRawBrokerPayload: Bool = false
    ) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard sourceIssueID.rawValue == "GH-700", sourceRiskIssueID.rawValue == "GH-699" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.issueChain",
                expected: "GH-701<-GH-700<-GH-699",
                actual: "GH-701<-\(sourceIssueID.rawValue)<-\(sourceRiskIssueID.rawValue)"
            )
        }
        guard instrument.venue.rawValue == "binance" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.nonBinanceVenue")
        }
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(instrument.productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.unsupportedProductType")
        }
        guard targetExposure.requiresOrderIntent else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.targetExposure",
                expected: "order-intent-producing target exposure",
                actual: targetExposure.rawValue
            )
        }
        guard stateEvidence.contains("submitted-dry-run") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.stateEvidence",
                expected: "submitted-dry-run",
                actual: stateEvidence.joined(separator: ",")
            )
        }
        guard ["filled-simulated", "cancelled"].contains(sourceFinalState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.sourceFinalState",
                expected: "filled-simulated or cancelled",
                actual: sourceFinalState
            )
        }
        guard sourceEventIDs.isEmpty == false, sourceOMSEnvelopeIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.sourceEvents",
                expected: "non-empty event and OMS envelope IDs",
                actual: "\(sourceEventIDs.count):\(sourceOMSEnvelopeIDs.count)"
            )
        }
        guard quantity.rawValue > 0, referencePrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.notionalInput",
                expected: "positive quantity and reference price",
                actual: "\(quantity.rawValue)@\(referencePrice.rawValue)"
            )
        }
        guard sourceReplayEvidenceHeld, sourceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.sourceBoundary",
                expected: "held replay and boundary evidence",
                actual: "\(sourceReplayEvidenceHeld):\(sourceBoundaryHeld)"
            )
        }
        try Self.forbid(authorizesProductionOrder, "authorizesProductionOrder")
        try Self.forbid(exposesRawBrokerPayload, "exposesRawBrokerPayload")

        self.handoffID = handoffID
        self.runContext = runContext
        self.sourceIssueID = sourceIssueID
        self.sourceRiskIssueID = sourceRiskIssueID
        self.sourceLifecycleLogID = sourceLifecycleLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceLifecyclePath = sourceLifecyclePath
        self.sourceFinalState = sourceFinalState
        self.sourceEventIDs = sourceEventIDs
        self.sourceOMSEnvelopeIDs = sourceOMSEnvelopeIDs
        self.instrument = instrument
        self.targetExposure = targetExposure
        self.quantity = quantity
        self.referencePrice = referencePrice
        self.stateEvidence = stateEvidence
        self.sourceReplayEvidenceHeld = sourceReplayEvidenceHeld
        self.sourceBoundaryHeld = sourceBoundaryHeld
        self.authorizesProductionOrder = authorizesProductionOrder
        self.exposesRawBrokerPayload = exposesRawBrokerPayload
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.handoff.\(field)")
        }
    }
}

/// ReleaseV040BinanceDryRunExecutionClientRequestIntent 是 adapter 输入侧的本地 request intent。
public struct ReleaseV040BinanceDryRunExecutionClientRequestIntent: Codable, Equatable, Sendable {
    public let requestIntentID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
    public let handoff: ReleaseV040BinanceDryRunExecutionClientOMSHandoff
    public let clientOrderID: Identifier
    public let side: String
    public let positionSide: String?
    public let reduceOnly: Bool
    public let authorizesNetworkCall: Bool
    public let authorizesProductionOrder: Bool

    public var runID: Identifier { runContext.runID }

    public var intentHeld: Bool {
        handoff.handoffHeld
            && handoff.runID == runID
            && side.isEmpty == false
            && (handoff.instrument.productType == .spot ? positionSide == nil && reduceOnly == false : positionSide != nil)
            && authorizesNetworkCall == false
            && authorizesProductionOrder == false
    }

    public init(
        requestIntentID: Identifier,
        commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind,
        handoff: ReleaseV040BinanceDryRunExecutionClientOMSHandoff,
        clientOrderID: Identifier,
        side: String? = nil,
        positionSide: String? = nil,
        reduceOnly: Bool = false,
        authorizesNetworkCall: Bool = false,
        authorizesProductionOrder: Bool = false
    ) throws {
        let resolvedSide = (side ?? Self.side(for: handoff)).uppercased()
        let resolvedPositionSide = positionSide?.uppercased() ?? Self.positionSide(for: handoff)
        guard handoff.handoffHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.handoff",
                expected: "held GH-700 OMS handoff",
                actual: handoff.handoffID.rawValue
            )
        }
        guard ["BUY", "SELL"].contains(resolvedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.side",
                expected: "BUY or SELL",
                actual: resolvedSide
            )
        }
        if handoff.instrument.productType == .spot {
            guard resolvedPositionSide == nil, reduceOnly == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040BinanceDryRun.spotPositionFields",
                    expected: "nil positionSide and reduceOnly false",
                    actual: "\(resolvedPositionSide ?? "nil"):\(reduceOnly)"
                )
            }
        } else {
            guard let resolvedPositionSide, ["LONG", "SHORT"].contains(resolvedPositionSide) else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV040BinanceDryRun.perpPositionSide",
                    expected: "LONG or SHORT",
                    actual: resolvedPositionSide ?? "nil"
                )
            }
        }
        try Self.forbid(authorizesNetworkCall, "authorizesNetworkCall")
        try Self.forbid(authorizesProductionOrder, "authorizesProductionOrder")

        self.requestIntentID = requestIntentID
        self.runContext = handoff.runContext
        self.commandKind = commandKind
        self.handoff = handoff
        self.clientOrderID = clientOrderID
        self.side = resolvedSide
        self.positionSide = resolvedPositionSide
        self.reduceOnly = reduceOnly
        self.authorizesNetworkCall = authorizesNetworkCall
        self.authorizesProductionOrder = authorizesProductionOrder
    }

    private static func side(for handoff: ReleaseV040BinanceDryRunExecutionClientOMSHandoff) -> String {
        switch handoff.targetExposure {
        case .targetLong:
            "BUY"
        case .targetShort, .targetFlat:
            "SELL"
        case .hold:
            "BUY"
        }
    }

    private static func positionSide(for handoff: ReleaseV040BinanceDryRunExecutionClientOMSHandoff) -> String? {
        guard handoff.instrument.productType == .usdsPerpetual else { return nil }
        return switch handoff.targetExposure {
        case .targetShort:
            "SHORT"
        default:
            "LONG"
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.requestIntent.\(field)")
        }
    }
}

/// ReleaseV040BinanceDryRunExecutionClientRedactedRequest 是 redacted Binance request mapping。
public struct ReleaseV040BinanceDryRunExecutionClientRedactedRequest: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
    public let productType: ProductType
    public let method: ReleaseV040BinanceDryRunExecutionClientHTTPMethod
    public let endpointPath: String
    public let requestIntentID: Identifier
    public let sourceLifecycleLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceOMSEnvelopeID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let side: String
    public let positionSide: String?
    public let reduceOnly: Bool
    public let queryItems: [ReleaseV040BinanceDryRunExecutionClientQueryItem]
    public let executionClientEnvelope: ReleaseV040UnifiedEvidenceEnvelope
    public let redacted: Bool
    public let dryRunOnly: Bool
    public let networkCallPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let brokerGatewayTouched: Bool
    public let rawBrokerPayloadExposed: Bool

    public var runID: Identifier { runContext.runID }

    public var requestHeld: Bool {
        issueID.rawValue == "GH-701"
            && upstreamIssueID.rawValue == "GH-700"
            && runContext.mode == .dryRun
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(productType)
            && method == Self.method(productType: productType, commandKind: commandKind)
            && endpointPath == Self.endpointPath(productType: productType, commandKind: commandKind)
            && queryItems.map(\.name) == Self.requiredQueryItemNames(productType: productType, commandKind: commandKind)
            && executionClientEnvelope.runID == runID
            && executionClientEnvelope.module == .executionClient
            && executionClientEnvelope.sourceIssueID.rawValue == "GH-701"
            && executionClientEnvelope.upstreamEvidenceID == sourceOMSEnvelopeID
            && executionClientEnvelope.validationAnchor == ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor
            && redacted
            && dryRunOnly
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        networkCallPerformed == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && brokerGatewayTouched == false
            && rawBrokerPayloadExposed == false
    }

    public init(
        requestID: Identifier,
        issueID: Identifier = Identifier.constant("GH-701"),
        upstreamIssueID: Identifier = Identifier.constant("GH-700"),
        requestIntent: ReleaseV040BinanceDryRunExecutionClientRequestIntent,
        queryItems: [ReleaseV040BinanceDryRunExecutionClientQueryItem],
        executionClientEnvelope: ReleaseV040UnifiedEvidenceEnvelope,
        redacted: Bool = true,
        dryRunOnly: Bool = true,
        networkCallPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        brokerGatewayTouched: Bool = false,
        rawBrokerPayloadExposed: Bool = false
    ) throws {
        let productType = requestIntent.handoff.instrument.productType
        let commandKind = requestIntent.commandKind
        guard let sourceOMSEnvelopeID = requestIntent.handoff.sourceOMSEnvelopeIDs.last else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.sourceOMSEnvelopeID",
                expected: "non-empty source OMS envelope IDs",
                actual: "empty"
            )
        }
        guard issueID.rawValue == "GH-701", upstreamIssueID.rawValue == "GH-700" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.issueChain",
                expected: "GH-701<-GH-700",
                actual: "\(issueID.rawValue)<-\(upstreamIssueID.rawValue)"
            )
        }
        guard requestIntent.intentHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.requestIntent",
                expected: "held dry-run request intent",
                actual: requestIntent.requestIntentID.rawValue
            )
        }
        guard queryItems.map(\.name) == Self.requiredQueryItemNames(productType: productType, commandKind: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.queryItems",
                expected: Self.requiredQueryItemNames(productType: productType, commandKind: commandKind)
                    .joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard executionClientEnvelope.module == .executionClient,
              executionClientEnvelope.sourceIssueID.rawValue == "GH-701",
              executionClientEnvelope.upstreamEvidenceID == sourceOMSEnvelopeID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.envelope",
                expected: "ExecutionClient GH-701 envelope caused by OMS envelope",
                actual: "\(executionClientEnvelope.module.rawValue):\(executionClientEnvelope.sourceIssueID.rawValue)"
            )
        }
        guard redacted, dryRunOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.redaction",
                expected: "redacted dry-run request",
                actual: "\(redacted):\(dryRunOnly)"
            )
        }
        try Self.validateForbiddenFlags(
            networkCallPerformed: networkCallPerformed,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretRead: productionSecretRead,
            productionOrderSubmitted: productionOrderSubmitted,
            brokerGatewayTouched: brokerGatewayTouched,
            rawBrokerPayloadExposed: rawBrokerPayloadExposed
        )

        self.requestID = requestID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.runContext = requestIntent.runContext
        self.commandKind = commandKind
        self.productType = productType
        self.method = Self.method(productType: productType, commandKind: commandKind)
        self.endpointPath = Self.endpointPath(productType: productType, commandKind: commandKind)
        self.requestIntentID = requestIntent.requestIntentID
        self.sourceLifecycleLogID = requestIntent.handoff.sourceLifecycleLogID
        self.sourceOMSOrderID = requestIntent.handoff.sourceOMSOrderID
        self.sourceOMSEnvelopeID = sourceOMSEnvelopeID
        self.clientOrderID = requestIntent.clientOrderID
        self.symbol = requestIntent.handoff.instrument.symbol.rawValue
        self.side = requestIntent.side
        self.positionSide = requestIntent.positionSide
        self.reduceOnly = requestIntent.reduceOnly
        self.queryItems = queryItems
        self.executionClientEnvelope = executionClientEnvelope
        self.redacted = redacted
        self.dryRunOnly = dryRunOnly
        self.networkCallPerformed = networkCallPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
    }

    public static func endpointPath(
        productType: ProductType,
        commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
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
        commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
    ) -> ReleaseV040BinanceDryRunExecutionClientHTTPMethod {
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
        commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
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

    private static func validateForbiddenFlags(
        networkCallPerformed: Bool,
        productionEndpointConnected: Bool,
        productionSecretRead: Bool,
        productionOrderSubmitted: Bool,
        brokerGatewayTouched: Bool,
        rawBrokerPayloadExposed: Bool
    ) throws {
        let forbiddenFlags = [
            ("networkCallPerformed", networkCallPerformed),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretRead", productionSecretRead),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("rawBrokerPayloadExposed", rawBrokerPayloadExposed)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.request.\(field)")
        }
    }
}

/// ReleaseV040BinanceDryRunExecutionClientAcknowledgement 是 local dry-run ack evidence。
public struct ReleaseV040BinanceDryRunExecutionClientAcknowledgement: Codable, Equatable, Sendable {
    public let acknowledgementID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let requestID: Identifier
    public let commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind
    public let productType: ProductType
    public let acceptedByDryRunAdapter: Bool
    public let dryRunTraceID: Identifier
    public let responseStatus: String
    public let networkCallPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let brokerGatewayTouched: Bool

    public var runID: Identifier { runContext.runID }

    public var acknowledgementHeld: Bool {
        runContext.mode == .dryRun
            && acceptedByDryRunAdapter
            && responseStatus == "dry-run-accepted"
            && networkCallPerformed == false
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
            && brokerGatewayTouched == false
    }

    public init(
        acknowledgementID: Identifier,
        request: ReleaseV040BinanceDryRunExecutionClientRedactedRequest,
        acceptedByDryRunAdapter: Bool = true,
        dryRunTraceID: Identifier,
        responseStatus: String = "dry-run-accepted",
        networkCallPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard request.requestHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.request",
                expected: "held redacted dry-run request",
                actual: request.requestID.rawValue
            )
        }
        guard acceptedByDryRunAdapter, responseStatus == "dry-run-accepted" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.ack",
                expected: "dry-run-accepted",
                actual: "\(acceptedByDryRunAdapter):\(responseStatus)"
            )
        }
        try Self.validateForbiddenFlags(
            networkCallPerformed: networkCallPerformed,
            productionEndpointConnected: productionEndpointConnected,
            productionOrderSubmitted: productionOrderSubmitted,
            brokerGatewayTouched: brokerGatewayTouched
        )

        self.acknowledgementID = acknowledgementID
        self.runContext = request.runContext
        self.requestID = request.requestID
        self.commandKind = request.commandKind
        self.productType = request.productType
        self.acceptedByDryRunAdapter = acceptedByDryRunAdapter
        self.dryRunTraceID = dryRunTraceID
        self.responseStatus = responseStatus
        self.networkCallPerformed = networkCallPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.brokerGatewayTouched = brokerGatewayTouched
    }

    private static func validateForbiddenFlags(
        networkCallPerformed: Bool,
        productionEndpointConnected: Bool,
        productionOrderSubmitted: Bool,
        brokerGatewayTouched: Bool
    ) throws {
        let forbiddenFlags = [
            ("networkCallPerformed", networkCallPerformed),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceDryRun.ack.\(field)")
        }
    }
}

/// ReleaseV040BinanceDryRunExecutionClientAdapterEvidence 汇总 GH-701 dry-run adapter evidence。
public struct ReleaseV040BinanceDryRunExecutionClientAdapterEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let supportedProductTypes: [ProductType]
    public let supportedCommands: [ReleaseV040BinanceDryRunExecutionClientCommandKind]
    public let omsHandoffs: [ReleaseV040BinanceDryRunExecutionClientOMSHandoff]
    public let requestIntents: [ReleaseV040BinanceDryRunExecutionClientRequestIntent]
    public let redactedRequests: [ReleaseV040BinanceDryRunExecutionClientRedactedRequest]
    public let acknowledgements: [ReleaseV040BinanceDryRunExecutionClientAcknowledgement]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let networkCallPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let brokerGatewayTouched: Bool
    public let rawBrokerPayloadExposed: Bool
    public let productionCutoverAuthorized: Bool
    public let nonBinanceVenueEnabled: Bool
    public let startsNextMilestone: Bool

    public var unifiedEnvelopes: [ReleaseV040UnifiedEvidenceEnvelope] {
        redactedRequests.map(\.executionClientEnvelope)
    }

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-701"
            && upstreamIssueID.rawValue == "GH-700"
            && downstreamIssueID.rawValue == "GH-702"
            && runContext.mode == .dryRun
            && supportedProductTypes == ReleaseV040RehearsalRunContext.requiredProductTypes
            && supportedCommands == ReleaseV040BinanceDryRunExecutionClientCommandKind.allCases
            && adapterCoverageHeld
            && runScopedEvidenceHeld
            && boundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
    }

    public var adapterCoverageHeld: Bool {
        let expected = Set(
            supportedProductTypes.flatMap { productType in
                supportedCommands.map { "\(productType.rawValue):\($0.rawValue)" }
            }
        )
        let actual = Set(redactedRequests.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })
        return expected == actual
            && requestIntents.count == redactedRequests.count
            && acknowledgements.count == redactedRequests.count
            && redactedRequests.allSatisfy(\.requestHeld)
            && acknowledgements.allSatisfy(\.acknowledgementHeld)
    }

    public var runScopedEvidenceHeld: Bool {
        omsHandoffs.allSatisfy { $0.runID == runContext.runID && $0.handoffHeld }
            && requestIntents.allSatisfy { $0.runID == runContext.runID && $0.intentHeld }
            && redactedRequests.allSatisfy { $0.runID == runContext.runID && $0.requestHeld }
            && acknowledgements.allSatisfy { $0.runID == runContext.runID && $0.acknowledgementHeld }
            && unifiedEnvelopes.allSatisfy { $0.runID == runContext.runID }
            && unifiedEnvelopes.map(\.module) == Array(
                repeating: ReleaseV040UnifiedEvidenceModule.executionClient,
                count: unifiedEnvelopes.count
            )
            && unifiedEnvelopes.map(\.sequence) == Array(1...unifiedEnvelopes.count)
    }

    public var boundaryHeld: Bool {
        networkCallPerformed == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && brokerGatewayTouched == false
            && rawBrokerPayloadExposed == false
            && productionCutoverAuthorized == false
            && nonBinanceVenueEnabled == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-701-v040-binance-dryrun-executionclient-adapter"),
        issueID: Identifier = Identifier.constant("GH-701"),
        upstreamIssueID: Identifier = Identifier.constant("GH-700"),
        downstreamIssueID: Identifier = Identifier.constant("GH-702"),
        runContext: ReleaseV040RehearsalRunContext,
        supportedProductTypes: [ProductType] = ReleaseV040RehearsalRunContext.requiredProductTypes,
        supportedCommands: [ReleaseV040BinanceDryRunExecutionClientCommandKind] =
            ReleaseV040BinanceDryRunExecutionClientCommandKind.allCases,
        omsHandoffs: [ReleaseV040BinanceDryRunExecutionClientOMSHandoff],
        requestIntents: [ReleaseV040BinanceDryRunExecutionClientRequestIntent],
        redactedRequests: [ReleaseV040BinanceDryRunExecutionClientRedactedRequest],
        acknowledgements: [ReleaseV040BinanceDryRunExecutionClientAcknowledgement],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        networkCallPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        brokerGatewayTouched: Bool = false,
        rawBrokerPayloadExposed: Bool = false,
        productionCutoverAuthorized: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-701" else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "issueID", expected: "GH-701", actual: issueID.rawValue)
        }
        guard upstreamIssueID.rawValue == "GH-700" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-700",
                actual: upstreamIssueID.rawValue
            )
        }
        guard downstreamIssueID.rawValue == "GH-702" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "downstreamIssueID",
                expected: "GH-702",
                actual: downstreamIssueID.rawValue
            )
        }
        guard omsHandoffs.isEmpty == false,
              requestIntents.isEmpty == false,
              redactedRequests.isEmpty == false,
              acknowledgements.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.evidenceSets",
                expected: "non-empty handoffs, intents, requests and acknowledgements",
                actual: "\(omsHandoffs.count):\(requestIntents.count):\(redactedRequests.count):\(acknowledgements.count)"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        try Self.validateForbiddenFlags(
            networkCallPerformed: networkCallPerformed,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretRead: productionSecretRead,
            productionOrderSubmitted: productionOrderSubmitted,
            brokerGatewayTouched: brokerGatewayTouched,
            rawBrokerPayloadExposed: rawBrokerPayloadExposed,
            productionCutoverAuthorized: productionCutoverAuthorized,
            nonBinanceVenueEnabled: nonBinanceVenueEnabled,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.runContext = runContext
        self.supportedProductTypes = supportedProductTypes
        self.supportedCommands = supportedCommands
        self.omsHandoffs = omsHandoffs
        self.requestIntents = requestIntents
        self.redactedRequests = redactedRequests
        self.acknowledgements = acknowledgements
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.networkCallPerformed = networkCallPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.startsNextMilestone = startsNextMilestone
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            upstreamIssueID: try container.decode(Identifier.self, forKey: .upstreamIssueID),
            downstreamIssueID: try container.decode(Identifier.self, forKey: .downstreamIssueID),
            runContext: try container.decode(ReleaseV040RehearsalRunContext.self, forKey: .runContext),
            supportedProductTypes: try container.decode([ProductType].self, forKey: .supportedProductTypes),
            supportedCommands: try container.decode(
                [ReleaseV040BinanceDryRunExecutionClientCommandKind].self,
                forKey: .supportedCommands
            ),
            omsHandoffs: try container.decode([ReleaseV040BinanceDryRunExecutionClientOMSHandoff].self, forKey: .omsHandoffs),
            requestIntents: try container.decode(
                [ReleaseV040BinanceDryRunExecutionClientRequestIntent].self,
                forKey: .requestIntents
            ),
            redactedRequests: try container.decode(
                [ReleaseV040BinanceDryRunExecutionClientRedactedRequest].self,
                forKey: .redactedRequests
            ),
            acknowledgements: try container.decode(
                [ReleaseV040BinanceDryRunExecutionClientAcknowledgement].self,
                forKey: .acknowledgements
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            networkCallPerformed: try container.decode(Bool.self, forKey: .networkCallPerformed),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            productionSecretRead: try container.decode(Bool.self, forKey: .productionSecretRead),
            productionOrderSubmitted: try container.decode(Bool.self, forKey: .productionOrderSubmitted),
            brokerGatewayTouched: try container.decode(Bool.self, forKey: .brokerGatewayTouched),
            rawBrokerPayloadExposed: try container.decode(Bool.self, forKey: .rawBrokerPayloadExposed),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized),
            nonBinanceVenueEnabled: try container.decode(Bool.self, forKey: .nonBinanceVenueEnabled),
            startsNextMilestone: try container.decode(Bool.self, forKey: .startsNextMilestone)
        )
    }

    public static let validationAnchor = "TVM-RELEASE-V040-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER"

    public static let requiredValidationAnchors = [
        "V040-08-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER",
        "V040-08-REQUEST-INTENT-REDACTED-REQUEST-ACK",
        "V040-08-SPOT-PERP-MAPPING-ONLY",
        "V040-08-NETWORK-PRODUCTION-ORDER-BLOCKED",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH701BinanceDryRunExecutionClientAdapterMapsLifecycleRequestsWithoutNetworkCalls",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private enum CodingKeys: String, CodingKey {
        case evidenceID
        case issueID
        case upstreamIssueID
        case downstreamIssueID
        case runContext
        case supportedProductTypes
        case supportedCommands
        case omsHandoffs
        case requestIntents
        case redactedRequests
        case acknowledgements
        case validationAnchors
        case requiredValidationCommands
        case networkCallPerformed
        case productionEndpointConnected
        case productionSecretRead
        case productionOrderSubmitted
        case brokerGatewayTouched
        case rawBrokerPayloadExposed
        case productionCutoverAuthorized
        case nonBinanceVenueEnabled
        case startsNextMilestone
    }
}

/// ReleaseV040BinanceDryRunExecutionClientAdapter 生成 GH-701 deterministic dry-run adapter evidence。
public struct ReleaseV040BinanceDryRunExecutionClientAdapter: Sendable {
    public let runContext: ReleaseV040RehearsalRunContext

    public init(runContext: ReleaseV040RehearsalRunContext) throws {
        guard runContext.mode == .dryRun else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.dryRun.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        self.runContext = runContext
    }

    public func run(
        omsHandoffs: [ReleaseV040BinanceDryRunExecutionClientOMSHandoff]
    ) throws -> ReleaseV040BinanceDryRunExecutionClientAdapterEvidence {
        guard Set(omsHandoffs.map(\.instrument.productType)) == Set(ReleaseV040RehearsalRunContext.requiredProductTypes) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.productCoverage",
                expected: ReleaseV040RehearsalRunContext.requiredProductTypes.map(\.rawValue).joined(separator: ","),
                actual: omsHandoffs.map(\.instrument.productType.rawValue).joined(separator: ",")
            )
        }
        guard omsHandoffs.allSatisfy({ $0.runID == runContext.runID && $0.handoffHeld }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.handoffs",
                expected: "held GH-700 handoffs sharing one runID",
                actual: omsHandoffs.map(\.handoffID.rawValue).joined(separator: ",")
            )
        }

        var requestIntents: [ReleaseV040BinanceDryRunExecutionClientRequestIntent] = []
        var redactedRequests: [ReleaseV040BinanceDryRunExecutionClientRedactedRequest] = []
        var acknowledgements: [ReleaseV040BinanceDryRunExecutionClientAcknowledgement] = []
        var sequence = 1
        for handoff in omsHandoffs {
            for commandKind in ReleaseV040BinanceDryRunExecutionClientCommandKind.allCases {
                let intent = try requestIntent(commandKind: commandKind, handoff: handoff)
                let request = try redactedRequest(requestIntent: intent, sequence: sequence)
                let acknowledgement = try acknowledgement(request: request)
                requestIntents.append(intent)
                redactedRequests.append(request)
                acknowledgements.append(acknowledgement)
                sequence += 1
            }
        }

        return try ReleaseV040BinanceDryRunExecutionClientAdapterEvidence(
            runContext: runContext,
            omsHandoffs: omsHandoffs,
            requestIntents: requestIntents,
            redactedRequests: redactedRequests,
            acknowledgements: acknowledgements
        )
    }

    private func requestIntent(
        commandKind: ReleaseV040BinanceDryRunExecutionClientCommandKind,
        handoff: ReleaseV040BinanceDryRunExecutionClientOMSHandoff
    ) throws -> ReleaseV040BinanceDryRunExecutionClientRequestIntent {
        try ReleaseV040BinanceDryRunExecutionClientRequestIntent(
            requestIntentID: Identifier.constant("gh-701-\(handoff.handoffID.rawValue)-\(commandKind.rawValue)-intent"),
            commandKind: commandKind,
            handoff: handoff,
            clientOrderID: Identifier.constant("gh-701-\(handoff.sourceOMSOrderID.rawValue)-\(commandKind.rawValue)")
        )
    }

    private func redactedRequest(
        requestIntent: ReleaseV040BinanceDryRunExecutionClientRequestIntent,
        sequence: Int
    ) throws -> ReleaseV040BinanceDryRunExecutionClientRedactedRequest {
        let requestID = Identifier.constant("gh-701-\(requestIntent.requestIntentID.rawValue)-redacted-request")
        guard let sourceOMSEnvelopeID = requestIntent.handoff.sourceOMSEnvelopeIDs.last else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceDryRun.sourceOMSEnvelopeID",
                expected: "non-empty source OMS envelope IDs",
                actual: "empty"
            )
        }
        let envelope = try ReleaseV040UnifiedEvidenceEnvelope(
            envelopeID: Identifier.constant("\(requestID.rawValue)-executionclient-envelope"),
            runContext: runContext,
            module: .executionClient,
            sourceIssueID: Identifier.constant("GH-701"),
            evidenceID: requestID,
            upstreamEvidenceID: sourceOMSEnvelopeID,
            validationAnchor: ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor,
            sequence: sequence
        )
        return try ReleaseV040BinanceDryRunExecutionClientRedactedRequest(
            requestID: requestID,
            requestIntent: requestIntent,
            queryItems: Self.queryItems(for: requestIntent),
            executionClientEnvelope: envelope
        )
    }

    private func acknowledgement(
        request: ReleaseV040BinanceDryRunExecutionClientRedactedRequest
    ) throws -> ReleaseV040BinanceDryRunExecutionClientAcknowledgement {
        try ReleaseV040BinanceDryRunExecutionClientAcknowledgement(
            acknowledgementID: Identifier.constant("gh-701-\(request.requestID.rawValue)-ack"),
            request: request,
            dryRunTraceID: Identifier.constant("gh-701-\(request.requestID.rawValue)-trace")
        )
    }

    private static func queryItems(
        for intent: ReleaseV040BinanceDryRunExecutionClientRequestIntent
    ) throws -> [ReleaseV040BinanceDryRunExecutionClientQueryItem] {
        let names = ReleaseV040BinanceDryRunExecutionClientRedactedRequest.requiredQueryItemNames(
            productType: intent.handoff.instrument.productType,
            commandKind: intent.commandKind
        )
        return try names.map { name in
            try ReleaseV040BinanceDryRunExecutionClientQueryItem(
                name: name,
                value: queryValue(name: name, intent: intent)
            )
        }
    }

    private static func queryValue(
        name: String,
        intent: ReleaseV040BinanceDryRunExecutionClientRequestIntent
    ) -> String {
        switch name {
        case "symbol":
            intent.handoff.instrument.symbol.rawValue
        case "side":
            intent.side
        case "positionSide":
            intent.positionSide ?? "LONG"
        case "type":
            "LIMIT"
        case "timeInForce":
            "GTC"
        case "quantity":
            String(format: "%.2f", intent.handoff.quantity.rawValue)
        case "price":
            String(format: "%.0f", intent.handoff.referencePrice.rawValue)
        case "reduceOnly":
            intent.reduceOnly ? "true" : "false"
        case "newClientOrderId":
            intent.clientOrderID.rawValue
        case "origClientOrderId", "cancelOrigClientOrderId":
            intent.handoff.sourceOMSOrderID.rawValue
        case "cancelReplaceMode":
            "STOP_ON_FAILURE"
        case "recvWindow":
            "5000"
        case "timestamp":
            "1705001400000"
        default:
            "redacted-\(name)"
        }
    }
}

private extension ReleaseV040BinanceDryRunExecutionClientAdapterEvidence {
    static func validateForbiddenFlags(
        networkCallPerformed: Bool,
        productionEndpointConnected: Bool,
        productionSecretRead: Bool,
        productionOrderSubmitted: Bool,
        brokerGatewayTouched: Bool,
        rawBrokerPayloadExposed: Bool,
        productionCutoverAuthorized: Bool,
        nonBinanceVenueEnabled: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("networkCallPerformed", networkCallPerformed),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretRead", productionSecretRead),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("rawBrokerPayloadExposed", rawBrokerPayloadExposed),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
