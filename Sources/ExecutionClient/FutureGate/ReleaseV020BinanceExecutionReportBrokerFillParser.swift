import DomainModel
import Foundation
import MessageBus

/// ReleaseV020BinanceExecutionReportKind 固定 GH-586 覆盖的 Spot / Perp testnet 回报类型。
///
/// 这些类型只表示 Binance testnet execution report fixture 的 normalized parser evidence，不代表
/// production broker stream、真实 broker fill、Portfolio reconciliation 或 production trading 授权。
public enum ReleaseV020BinanceExecutionReportKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case spotFill = "spot fill"
    case spotPartialFill = "spot partial fill"
    case perpFill = "perp fill"
    case perpPartialFill = "perp partial fill"

    public var productType: ProductType {
        switch self {
        case .spotFill, .spotPartialFill:
            .spot
        case .perpFill, .perpPartialFill:
            .usdsPerpetual
        }
    }

    public var executionType: String {
        "TRADE"
    }

    public var orderStatus: String {
        switch self {
        case .spotFill, .perpFill:
            "FILLED"
        case .spotPartialFill, .perpPartialFill:
            "PARTIALLY_FILLED"
        }
    }

    public var requiresPositionUpdate: Bool {
        productType == .usdsPerpetual
    }
}

/// ReleaseV020BinanceExecutionReportSourceKind 区分允许的 testnet fixture 和仍禁止的 production raw payload。
public enum ReleaseV020BinanceExecutionReportSourceKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case testnetNormalizedExecutionReport = "testnet normalized execution report"
    case productionRawPayload = "production raw payload"
}

/// ReleaseV020BinanceExecutionReportInvalidReason 固定 GH-586 invalid payload blocked evidence。
public enum ReleaseV020BinanceExecutionReportInvalidReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionRawPayload = "production raw payload"
    case unsupportedExecutionStatus = "unsupported execution status"
    case rawPayloadExposureAttempt = "raw payload exposure attempt"
    case adapterEvidenceMismatch = "adapter evidence mismatch"
}

/// ReleaseV020BinanceExecutionReportFixture 是 GH-586 parser 的 testnet-only normalized 输入。
///
/// Fixture 不保存 raw JSON、header、signature、credential value、account payload、broker payload 或
/// production endpoint，只保留可审计的字段、digest identity 和上游 adapter evidence identity。
/// `GH-586-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER`
public struct ReleaseV020BinanceExecutionReportFixture: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let issueID: Identifier
    public let sourceAdapterIssueID: Identifier
    public let sourceKind: ReleaseV020BinanceExecutionReportSourceKind
    public let reportKind: ReleaseV020BinanceExecutionReportKind
    public let sourceCommandKind: String
    public let sourceCommandRequestID: Identifier
    public let sourceCommandAckID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let instrument: InstrumentIdentity
    public let side: String
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide?
    public let reduceOnly: Bool
    public let cumulativeFilledQuantity: Quantity
    public let lastExecutedQuantity: Quantity
    public let remainingQuantity: Quantity
    public let lastExecutedPrice: Price
    public let commissionAsset: String
    public let commissionAmount: String
    public let previousPositionQuantity: Quantity?
    public let executionType: String
    public let orderStatus: String
    public let replaySequence: Int
    public let rawPayloadDigest: String
    public let rawPayloadRetained: Bool
    public let rawPayloadExposedToDashboard: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool

    public init(
        reportID: Identifier,
        issueID: Identifier = Identifier.constant("GH-586"),
        sourceAdapterIssueID: Identifier,
        sourceKind: ReleaseV020BinanceExecutionReportSourceKind = .testnetNormalizedExecutionReport,
        reportKind: ReleaseV020BinanceExecutionReportKind,
        sourceCommandKind: String,
        sourceCommandRequestID: Identifier,
        sourceCommandAckID: Identifier,
        sourceOrderIntentID: Identifier,
        sourceEventLogID: Identifier,
        sourceOMSOrderID: Identifier,
        clientOrderID: Identifier,
        instrument: InstrumentIdentity,
        side: String,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide? = nil,
        reduceOnly: Bool = false,
        cumulativeFilledQuantity: Quantity,
        lastExecutedQuantity: Quantity,
        remainingQuantity: Quantity,
        lastExecutedPrice: Price,
        commissionAsset: String,
        commissionAmount: String,
        previousPositionQuantity: Quantity? = nil,
        executionType: String? = nil,
        orderStatus: String? = nil,
        replaySequence: Int,
        rawPayloadDigest: String,
        rawPayloadRetained: Bool = false,
        rawPayloadExposedToDashboard: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        let normalizedSide = side.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let trimmedCommandKind = sourceCommandKind.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCommissionAsset = commissionAsset.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCommissionAmount = commissionAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDigest = rawPayloadDigest.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedExecutionType = executionType ?? reportKind.executionType
        let resolvedOrderStatus = orderStatus ?? reportKind.orderStatus

        guard issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.issueID",
                expected: "GH-586",
                actual: issueID.rawValue
            )
        }
        guard sourceAdapterIssueID.rawValue == reportKind.expectedAdapterIssueID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.sourceAdapterIssueID",
                expected: reportKind.expectedAdapterIssueID,
                actual: sourceAdapterIssueID.rawValue
            )
        }
        guard sourceKind == .testnetNormalizedExecutionReport else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.productionRawPayload"
            )
        }
        guard instrument.productType == reportKind.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.productType",
                expected: reportKind.productType.rawValue,
                actual: instrument.productType.rawValue
            )
        }
        guard ["BUY", "SELL"].contains(normalizedSide) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.side",
                expected: "BUY or SELL",
                actual: normalizedSide
            )
        }
        guard trimmedCommandKind.isEmpty == false,
              trimmedCommissionAsset.isEmpty == false,
              trimmedCommissionAmount.isEmpty == false,
              trimmedDigest.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.requiredFields",
                expected: "non-empty command, commission and digest fields",
                actual: "empty"
            )
        }
        guard resolvedExecutionType == reportKind.executionType, resolvedOrderStatus == reportKind.orderStatus else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.status",
                expected: "\(reportKind.executionType) / \(reportKind.orderStatus)",
                actual: "\(resolvedExecutionType) / \(resolvedOrderStatus)"
            )
        }
        guard cumulativeFilledQuantity.rawValue >= 0,
              lastExecutedQuantity.rawValue > 0,
              remainingQuantity.rawValue >= 0,
              lastExecutedPrice.rawValue > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.quantities",
                expected: "positive fill quantity and price with non-negative cumulative / remaining",
                actual: "invalid"
            )
        }
        guard replaySequence > 0 else {
            throw CoreError.invalidEventSequence(replaySequence)
        }
        if reportKind.requiresPositionUpdate {
            guard positionSide != nil, previousPositionQuantity != nil else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020ExecutionReport.perpPositionUpdateSource",
                    expected: "positionSide and previousPositionQuantity",
                    actual: "missing"
                )
            }
        } else {
            guard positionSide == nil, previousPositionQuantity == nil, reduceOnly == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV020ExecutionReport.spotPositionFields",
                    expected: "no Perp position fields for Spot fill",
                    actual: "present"
                )
            }
        }
        for forbiddenFlag in [
            ("rawPayloadRetained", rawPayloadRetained),
            ("rawPayloadExposedToDashboard", rawPayloadExposedToDashboard),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.\(forbiddenFlag.0)"
            )
        }

        self.reportID = reportID
        self.issueID = issueID
        self.sourceAdapterIssueID = sourceAdapterIssueID
        self.sourceKind = sourceKind
        self.reportKind = reportKind
        self.sourceCommandKind = trimmedCommandKind
        self.sourceCommandRequestID = sourceCommandRequestID
        self.sourceCommandAckID = sourceCommandAckID
        self.sourceOrderIntentID = sourceOrderIntentID
        self.sourceEventLogID = sourceEventLogID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.clientOrderID = clientOrderID
        self.instrument = instrument
        self.side = normalizedSide
        self.positionSide = positionSide
        self.reduceOnly = reduceOnly
        self.cumulativeFilledQuantity = cumulativeFilledQuantity
        self.lastExecutedQuantity = lastExecutedQuantity
        self.remainingQuantity = remainingQuantity
        self.lastExecutedPrice = lastExecutedPrice
        self.commissionAsset = trimmedCommissionAsset
        self.commissionAmount = trimmedCommissionAmount
        self.previousPositionQuantity = previousPositionQuantity
        self.executionType = resolvedExecutionType
        self.orderStatus = resolvedOrderStatus
        self.replaySequence = replaySequence
        self.rawPayloadDigest = trimmedDigest
        self.rawPayloadRetained = rawPayloadRetained
        self.rawPayloadExposedToDashboard = rawPayloadExposedToDashboard
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
    }

    public var fixtureBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && sourceAdapterIssueID.rawValue == reportKind.expectedAdapterIssueID
            && sourceKind == .testnetNormalizedExecutionReport
            && instrument.productType == reportKind.productType
            && executionType == reportKind.executionType
            && orderStatus == reportKind.orderStatus
            && replaySequence > 0
            && lastExecutedQuantity.rawValue > 0
            && lastExecutedPrice.rawValue > 0
            && rawPayloadDigest.isEmpty == false
            && rawPayloadRetained == false
            && rawPayloadExposedToDashboard == false
            && productionPayloadInterpreted == false
            && brokerGatewayTouched == false
            && ((reportKind.requiresPositionUpdate && positionSide != nil && previousPositionQuantity != nil)
                || (reportKind.requiresPositionUpdate == false && positionSide == nil && previousPositionQuantity == nil))
    }
}

/// ReleaseV020NormalizedBrokerFill 是 GH-586 的 normalized BrokerFill 输出。
///
/// 该 event 只保存 normalized fields、上游 adapter identity 和 raw payload digest，不保存 raw payload，
/// 不写 Portfolio，不执行 reconciliation，也不向 Dashboard 暴露 broker payload。
/// `GH-586-NORMALIZED-BROKER-FILL`
public struct ReleaseV020NormalizedBrokerFill: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let reportID: Identifier
    public let issueID: Identifier
    public let sourceAdapterIssueID: Identifier
    public let reportKind: ReleaseV020BinanceExecutionReportKind
    public let sourceCommandKind: String
    public let sourceCommandRequestID: Identifier
    public let sourceCommandAckID: Identifier
    public let sourceOrderIntentID: Identifier
    public let sourceEventLogID: Identifier
    public let sourceOMSOrderID: Identifier
    public let clientOrderID: Identifier
    public let eventStream: EventStreamID
    public let instrument: InstrumentIdentity
    public let symbol: String
    public let side: String
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide?
    public let reduceOnly: Bool
    public let executionType: String
    public let orderStatus: String
    public let cumulativeFilledQuantity: Quantity
    public let lastExecutedQuantity: Quantity
    public let remainingQuantity: Quantity
    public let lastExecutedPrice: Price
    public let commissionAsset: String
    public let commissionAmount: String
    public let replaySequence: Int
    public let rawPayloadDigest: String
    public let validationAnchors: [String]
    public let normalizedBrokerFillMapped: Bool
    public let dashboardReadModelSafe: Bool
    public let rawPayloadExposedToDashboard: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioUpdated: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        fillID: Identifier,
        fixture: ReleaseV020BinanceExecutionReportFixture,
        eventStream: EventStreamID = EventStreamID(rawValue: "execution-broker-fill-local"),
        validationAnchors: [String] = ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors,
        normalizedBrokerFillMapped: Bool = true,
        dashboardReadModelSafe: Bool = true,
        rawPayloadExposedToDashboard: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioUpdated: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard fixture.fixtureBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.fixtureBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard validationAnchors == ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.validationAnchors",
                expected: ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard normalizedBrokerFillMapped, dashboardReadModelSafe else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.normalizedBrokerFill",
                expected: "mapped and Dashboard-safe",
                actual: "invalid"
            )
        }
        for forbiddenFlag in [
            ("rawPayloadExposedToDashboard", rawPayloadExposedToDashboard),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioUpdated", portfolioUpdated),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.\(forbiddenFlag.0)"
            )
        }

        self.fillID = fillID
        self.reportID = fixture.reportID
        self.issueID = fixture.issueID
        self.sourceAdapterIssueID = fixture.sourceAdapterIssueID
        self.reportKind = fixture.reportKind
        self.sourceCommandKind = fixture.sourceCommandKind
        self.sourceCommandRequestID = fixture.sourceCommandRequestID
        self.sourceCommandAckID = fixture.sourceCommandAckID
        self.sourceOrderIntentID = fixture.sourceOrderIntentID
        self.sourceEventLogID = fixture.sourceEventLogID
        self.sourceOMSOrderID = fixture.sourceOMSOrderID
        self.clientOrderID = fixture.clientOrderID
        self.eventStream = eventStream
        self.instrument = fixture.instrument
        self.symbol = fixture.instrument.symbol.rawValue
        self.side = fixture.side
        self.positionSide = fixture.positionSide
        self.reduceOnly = fixture.reduceOnly
        self.executionType = fixture.executionType
        self.orderStatus = fixture.orderStatus
        self.cumulativeFilledQuantity = fixture.cumulativeFilledQuantity
        self.lastExecutedQuantity = fixture.lastExecutedQuantity
        self.remainingQuantity = fixture.remainingQuantity
        self.lastExecutedPrice = fixture.lastExecutedPrice
        self.commissionAsset = fixture.commissionAsset
        self.commissionAmount = fixture.commissionAmount
        self.replaySequence = fixture.replaySequence
        self.rawPayloadDigest = fixture.rawPayloadDigest
        self.validationAnchors = validationAnchors
        self.normalizedBrokerFillMapped = normalizedBrokerFillMapped
        self.dashboardReadModelSafe = dashboardReadModelSafe
        self.rawPayloadExposedToDashboard = rawPayloadExposedToDashboard
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioUpdated = portfolioUpdated
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var fillBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && sourceAdapterIssueID.rawValue == reportKind.expectedAdapterIssueID
            && instrument.productType == reportKind.productType
            && eventStream.rawValue == "execution-broker-fill-local"
            && executionType == reportKind.executionType
            && orderStatus == reportKind.orderStatus
            && lastExecutedQuantity.rawValue > 0
            && rawPayloadDigest.isEmpty == false
            && validationAnchors == ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors
            && normalizedBrokerFillMapped
            && dashboardReadModelSafe
            && rawPayloadExposedToDashboard == false
            && productionPayloadInterpreted == false
            && brokerGatewayTouched == false
            && reconciliationProduced == false
            && portfolioUpdated == false
            && liveCommandSurfaceTouched == false
    }
}

/// ReleaseV020BinancePerpPositionUpdate 是 GH-586 的 Perp-only position update evidence。
///
/// Position update 只来自 normalized Perp BrokerFill，不读取 account endpoint，不同步 broker position，
/// 不执行 leverage / margin action，也不写 Portfolio runtime。
/// `GH-586-PERP-POSITION-UPDATE`
public struct ReleaseV020BinancePerpPositionUpdate: Codable, Equatable, Sendable {
    public let updateID: Identifier
    public let sourceFillID: Identifier
    public let issueID: Identifier
    public let instrument: InstrumentIdentity
    public let positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide
    public let side: String
    public let reduceOnly: Bool
    public let previousPositionQuantity: Quantity
    public let fillQuantity: Quantity
    public let resultingPositionQuantity: Quantity
    public let positionUpdateMapped: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let leverageActionExecuted: Bool
    public let marginActionExecuted: Bool
    public let portfolioRuntimeUpdated: Bool

    public init(
        updateID: Identifier,
        fill: ReleaseV020NormalizedBrokerFill,
        previousPositionQuantity: Quantity,
        resultingPositionQuantity: Quantity,
        positionUpdateMapped: Bool = true,
        accountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        leverageActionExecuted: Bool = false,
        marginActionExecuted: Bool = false,
        portfolioRuntimeUpdated: Bool = false
    ) throws {
        guard fill.fillBoundaryHeld, fill.instrument.productType == .usdsPerpetual else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.perpFill",
                expected: "held USD-M Perpetual BrokerFill",
                actual: "mismatch"
            )
        }
        guard let resolvedPositionSide = fill.positionSide else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.positionSide",
                expected: "Perp positionSide",
                actual: "missing"
            )
        }
        guard positionUpdateMapped else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.positionUpdateMapped",
                expected: "true",
                actual: "false"
            )
        }
        let expectedQuantity = Self.expectedResultingQuantity(fill: fill, previous: previousPositionQuantity)
        guard abs(expectedQuantity - resultingPositionQuantity.rawValue) < 0.000_000_01 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.resultingPositionQuantity",
                expected: "\(expectedQuantity)",
                actual: "\(resultingPositionQuantity.rawValue)"
            )
        }
        for forbiddenFlag in [
            ("accountEndpointRead", accountEndpointRead),
            ("brokerPositionSynced", brokerPositionSynced),
            ("leverageActionExecuted", leverageActionExecuted),
            ("marginActionExecuted", marginActionExecuted),
            ("portfolioRuntimeUpdated", portfolioRuntimeUpdated)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.\(forbiddenFlag.0)"
            )
        }

        self.updateID = updateID
        self.sourceFillID = fill.fillID
        self.issueID = fill.issueID
        self.instrument = fill.instrument
        self.positionSide = resolvedPositionSide
        self.side = fill.side
        self.reduceOnly = fill.reduceOnly
        self.previousPositionQuantity = previousPositionQuantity
        self.fillQuantity = fill.lastExecutedQuantity
        self.resultingPositionQuantity = resultingPositionQuantity
        self.positionUpdateMapped = positionUpdateMapped
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.leverageActionExecuted = leverageActionExecuted
        self.marginActionExecuted = marginActionExecuted
        self.portfolioRuntimeUpdated = portfolioRuntimeUpdated
    }

    public var positionUpdateBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && instrument.productType == .usdsPerpetual
            && positionUpdateMapped
            && abs(
                resultingPositionQuantity.rawValue
                    - Self.expectedResultingQuantity(side: side, positionSide: positionSide, reduceOnly: reduceOnly,
                                                      fillQuantity: fillQuantity, previous: previousPositionQuantity)
            ) < 0.000_000_01
            && accountEndpointRead == false
            && brokerPositionSynced == false
            && leverageActionExecuted == false
            && marginActionExecuted == false
            && portfolioRuntimeUpdated == false
    }

    private static func expectedResultingQuantity(fill: ReleaseV020NormalizedBrokerFill, previous: Quantity) -> Double {
        guard let positionSide = fill.positionSide else {
            return previous.rawValue
        }
        return expectedResultingQuantity(
            side: fill.side,
            positionSide: positionSide,
            reduceOnly: fill.reduceOnly,
            fillQuantity: fill.lastExecutedQuantity,
            previous: previous
        )
    }

    private static func expectedResultingQuantity(
        side: String,
        positionSide: ReleaseV020BinanceUSDMPerpExecutionClientPositionSide,
        reduceOnly: Bool,
        fillQuantity: Quantity,
        previous: Quantity
    ) -> Double {
        switch (side, positionSide, reduceOnly) {
        case ("SELL", .long, true), ("BUY", .short, true):
            max(0, previous.rawValue - fillQuantity.rawValue)
        case ("BUY", .long, false), ("SELL", .short, false):
            previous.rawValue + fillQuantity.rawValue
        default:
            previous.rawValue
        }
    }
}

/// ReleaseV020BinanceExecutionReportParseResult 汇总单条 report 的 fill 和 Perp position update。
public struct ReleaseV020BinanceExecutionReportParseResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let brokerFill: ReleaseV020NormalizedBrokerFill
    public let positionUpdate: ReleaseV020BinancePerpPositionUpdate?

    public var resultBoundaryHeld: Bool {
        brokerFill.fillBoundaryHeld
            && ((brokerFill.instrument.productType == .spot && positionUpdate == nil)
                || (brokerFill.instrument.productType == .usdsPerpetual
                    && positionUpdate?.positionUpdateBoundaryHeld == true))
    }
}

/// ReleaseV020BinanceExecutionReportInvalidEvidence 是 GH-586 的 invalid payload blocked evidence。
/// `GH-586-INVALID-PAYLOAD-BLOCKED`
public struct ReleaseV020BinanceExecutionReportInvalidEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let reason: ReleaseV020BinanceExecutionReportInvalidReason
    public let invalidPayloadBlocked: Bool
    public let brokerFillProduced: Bool
    public let positionUpdateProduced: Bool
    public let rawPayloadRetained: Bool
    public let rawPayloadExposedToDashboard: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool

    public init(
        evidenceID: Identifier,
        issueID: Identifier = Identifier.constant("GH-586"),
        reason: ReleaseV020BinanceExecutionReportInvalidReason,
        invalidPayloadBlocked: Bool = true,
        brokerFillProduced: Bool = false,
        positionUpdateProduced: Bool = false,
        rawPayloadRetained: Bool = false,
        rawPayloadExposedToDashboard: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.invalid.issueID",
                expected: "GH-586",
                actual: issueID.rawValue
            )
        }
        guard invalidPayloadBlocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.invalidPayloadBlocked",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("brokerFillProduced", brokerFillProduced),
            ("positionUpdateProduced", positionUpdateProduced),
            ("rawPayloadRetained", rawPayloadRetained),
            ("rawPayloadExposedToDashboard", rawPayloadExposedToDashboard),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.invalid.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.reason = reason
        self.invalidPayloadBlocked = invalidPayloadBlocked
        self.brokerFillProduced = brokerFillProduced
        self.positionUpdateProduced = positionUpdateProduced
        self.rawPayloadRetained = rawPayloadRetained
        self.rawPayloadExposedToDashboard = rawPayloadExposedToDashboard
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
    }

    public var invalidEvidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && invalidPayloadBlocked
            && brokerFillProduced == false
            && positionUpdateProduced == false
            && rawPayloadRetained == false
            && rawPayloadExposedToDashboard == false
            && productionPayloadInterpreted == false
            && brokerGatewayTouched == false
    }
}

/// ReleaseV020BinanceExecutionReportParserEvidence 汇总 GH-586 Spot / Perp parser evidence。
/// `TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER`
public struct ReleaseV020BinanceExecutionReportParserEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let parseResults: [ReleaseV020BinanceExecutionReportParseResult]
    public let invalidPayloads: [ReleaseV020BinanceExecutionReportInvalidEvidence]
    public let validationAnchors: [String]
    public let spotBrokerFillParserComplete: Bool
    public let perpBrokerFillParserComplete: Bool
    public let perpPositionUpdateEvidenceComplete: Bool
    public let invalidPayloadBlockedEvidenceComplete: Bool
    public let rawPayloadNotExposedToDashboard: Bool
    public let productionParserDisabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioRuntimeUpdated: Bool
    public let dashboardRawPayloadExposed: Bool

    public init(
        evidenceID: Identifier = Identifier.constant("gh-586-binance-execution-report-parser-evidence"),
        issueID: Identifier = Identifier.constant("GH-586"),
        parseResults: [ReleaseV020BinanceExecutionReportParseResult],
        invalidPayloads: [ReleaseV020BinanceExecutionReportInvalidEvidence],
        validationAnchors: [String] = ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors,
        spotBrokerFillParserComplete: Bool = true,
        perpBrokerFillParserComplete: Bool = true,
        perpPositionUpdateEvidenceComplete: Bool = true,
        invalidPayloadBlockedEvidenceComplete: Bool = true,
        rawPayloadNotExposedToDashboard: Bool = true,
        productionParserDisabled: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioRuntimeUpdated: Bool = false,
        dashboardRawPayloadExposed: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.evidenceIssueID",
                expected: "GH-586",
                actual: issueID.rawValue
            )
        }
        guard Set(parseResults.map(\.brokerFill.reportKind)) == Set(ReleaseV020BinanceExecutionReportKind.allCases),
              parseResults.allSatisfy(\.resultBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.parseResults",
                expected: ReleaseV020BinanceExecutionReportKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: parseResults.map { $0.brokerFill.reportKind.rawValue }.joined(separator: ",")
            )
        }
        guard invalidPayloads.isEmpty == false, invalidPayloads.allSatisfy(\.invalidEvidenceBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.invalidPayloads",
                expected: "non-empty blocked invalid payload evidence",
                actual: "missing or invalid"
            )
        }
        guard validationAnchors == ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.validationAnchors",
                expected: ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("spotBrokerFillParserComplete", spotBrokerFillParserComplete),
            ("perpBrokerFillParserComplete", perpBrokerFillParserComplete),
            ("perpPositionUpdateEvidenceComplete", perpPositionUpdateEvidenceComplete),
            ("invalidPayloadBlockedEvidenceComplete", invalidPayloadBlockedEvidenceComplete),
            ("rawPayloadNotExposedToDashboard", rawPayloadNotExposedToDashboard),
            ("productionParserDisabled", productionParserDisabled)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.\(requiredFlag.0)",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioRuntimeUpdated", portfolioRuntimeUpdated),
            ("dashboardRawPayloadExposed", dashboardRawPayloadExposed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.\(forbiddenFlag.0)"
            )
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.parseResults = parseResults
        self.invalidPayloads = invalidPayloads
        self.validationAnchors = validationAnchors
        self.spotBrokerFillParserComplete = spotBrokerFillParserComplete
        self.perpBrokerFillParserComplete = perpBrokerFillParserComplete
        self.perpPositionUpdateEvidenceComplete = perpPositionUpdateEvidenceComplete
        self.invalidPayloadBlockedEvidenceComplete = invalidPayloadBlockedEvidenceComplete
        self.rawPayloadNotExposedToDashboard = rawPayloadNotExposedToDashboard
        self.productionParserDisabled = productionParserDisabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioRuntimeUpdated = portfolioRuntimeUpdated
        self.dashboardRawPayloadExposed = dashboardRawPayloadExposed
    }

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && Set(parseResults.map(\.brokerFill.reportKind)) == Set(ReleaseV020BinanceExecutionReportKind.allCases)
            && parseResults.allSatisfy(\.resultBoundaryHeld)
            && invalidPayloads.allSatisfy(\.invalidEvidenceBoundaryHeld)
            && validationAnchors == ReleaseV020BinanceExecutionReportParser.requiredValidationAnchors
            && spotBrokerFillParserComplete
            && perpBrokerFillParserComplete
            && perpPositionUpdateEvidenceComplete
            && invalidPayloadBlockedEvidenceComplete
            && rawPayloadNotExposedToDashboard
            && productionParserDisabled
            && productionTradingEnabledByDefault == false
            && productionPayloadInterpreted == false
            && brokerGatewayTouched == false
            && reconciliationProduced == false
            && portfolioRuntimeUpdated == false
            && dashboardRawPayloadExposed == false
    }
}

/// ReleaseV020BinanceExecutionReportParser 是 GH-586 的 Spot / Perp execution report parser。
///
/// Parser 消费 GH-584 Spot adapter evidence 和 GH-585 Perp adapter evidence，只输出 normalized
/// BrokerFill / Perp position update evidence。它不联网、不读 secret、不解释 production raw payload、
/// 不执行 reconciliation、不更新 Portfolio runtime，也不向 Dashboard 暴露 raw payload。
public struct ReleaseV020BinanceExecutionReportParser: Codable, Equatable, Sendable {
    public let parserID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let spotAdapterEvidence: ReleaseV020BinanceSpotExecutionClientAdapterEvidence
    public let perpAdapterEvidence: ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence
    public let validationAnchors: [String]
    public let productionParserEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioRuntimeUpdated: Bool
    public let dashboardRawPayloadExposed: Bool
    public let liveCommandSurfaceTouched: Bool

    public init(
        parserID: Identifier = Identifier.constant("gh-586-binance-execution-report-parser"),
        issueID: Identifier = Identifier.constant("GH-586"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-584"), Identifier.constant("GH-585")],
        spotAdapterEvidence: ReleaseV020BinanceSpotExecutionClientAdapterEvidence? = nil,
        perpAdapterEvidence: ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionParserEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioRuntimeUpdated: Bool = false,
        dashboardRawPayloadExposed: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedSpot = try spotAdapterEvidence
            ?? ReleaseV020BinanceSpotExecutionClientAdapter.deterministicFixture().deterministicAdapterEvidence()
        let resolvedPerp = try perpAdapterEvidence
            ?? ReleaseV020BinanceUSDMPerpExecutionClientAdapter.deterministicFixture().deterministicAdapterEvidence()
        guard issueID.rawValue == "GH-586" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.parserIssueID",
                expected: "GH-586",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-584", "GH-585"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.upstreamIssueIDs",
                expected: "GH-584,GH-585",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard resolvedSpot.evidenceBoundaryHeld, resolvedPerp.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.adapterEvidence",
                expected: "GH-584 Spot and GH-585 Perp adapter evidence held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionParserEnabledByDefault", productionParserEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioRuntimeUpdated", portfolioRuntimeUpdated),
            ("dashboardRawPayloadExposed", dashboardRawPayloadExposed),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV020ExecutionReport.\(forbiddenFlag.0)"
            )
        }

        self.parserID = parserID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.spotAdapterEvidence = resolvedSpot
        self.perpAdapterEvidence = resolvedPerp
        self.validationAnchors = validationAnchors
        self.productionParserEnabledByDefault = productionParserEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioRuntimeUpdated = portfolioRuntimeUpdated
        self.dashboardRawPayloadExposed = dashboardRawPayloadExposed
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public var parserBoundaryHeld: Bool {
        issueID.rawValue == "GH-586"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-584", "GH-585"]
            && spotAdapterEvidence.evidenceBoundaryHeld
            && perpAdapterEvidence.evidenceBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && productionParserEnabledByDefault == false
            && productionTradingEnabledByDefault == false
            && productionPayloadInterpreted == false
            && brokerGatewayTouched == false
            && reconciliationProduced == false
            && portfolioRuntimeUpdated == false
            && dashboardRawPayloadExposed == false
            && liveCommandSurfaceTouched == false
    }

    /// 将单条 normalized report fixture 转成 BrokerFill 和 Perp position update evidence。
    public func parse(
        _ fixture: ReleaseV020BinanceExecutionReportFixture
    ) throws -> ReleaseV020BinanceExecutionReportParseResult {
        guard parserBoundaryHeld, fixture.fixtureBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.parseBoundary",
                expected: "parser and fixture boundaries held",
                actual: "mismatch"
            )
        }
        guard adapterEvidenceMatches(fixture) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.adapterEvidenceMatch",
                expected: fixture.sourceCommandRequestID.rawValue,
                actual: "missing"
            )
        }
        let fill = try ReleaseV020NormalizedBrokerFill(
            fillID: Identifier.constant("gh-586-\(fixture.reportKind.eventIDComponent)-broker-fill"),
            fixture: fixture
        )
        let update = try positionUpdateIfNeeded(fill: fill, fixture: fixture)
        return ReleaseV020BinanceExecutionReportParseResult(
            resultID: Identifier.constant("gh-586-\(fixture.reportKind.eventIDComponent)-parse-result"),
            brokerFill: fill,
            positionUpdate: update
        )
    }

    /// 为异常 payload 生成 blocked evidence，不产生 BrokerFill 或 position update。
    public func invalidEvidence(
        reason: ReleaseV020BinanceExecutionReportInvalidReason
    ) throws -> ReleaseV020BinanceExecutionReportInvalidEvidence {
        guard parserBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.parserBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try ReleaseV020BinanceExecutionReportInvalidEvidence(
            evidenceID: Identifier.constant("gh-586-invalid-\(reason.eventIDComponent)-evidence"),
            reason: reason
        )
    }

    /// 生成 GH-586 deterministic Spot / Perp fill parser evidence。
    public func deterministicParserEvidence() throws -> ReleaseV020BinanceExecutionReportParserEvidence {
        let fixtures = try Self.deterministicFixtures(
            spotEvidence: spotAdapterEvidence,
            perpEvidence: perpAdapterEvidence
        )
        let results = try fixtures.map(parse)
        let invalid = try [
            invalidEvidence(reason: .productionRawPayload),
            invalidEvidence(reason: .unsupportedExecutionStatus),
            invalidEvidence(reason: .rawPayloadExposureAttempt)
        ]
        return try ReleaseV020BinanceExecutionReportParserEvidence(
            parseResults: results,
            invalidPayloads: invalid
        )
    }

    public static func deterministicFixture() throws -> ReleaseV020BinanceExecutionReportParser {
        try ReleaseV020BinanceExecutionReportParser()
    }

    public static let requiredValidationAnchors = [
        "GH-586-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER",
        "GH-586-SPOT-BROKER-FILL-PARSER",
        "GH-586-PERP-BROKER-FILL-PARSER",
        "GH-586-NORMALIZED-BROKER-FILL",
        "GH-586-PERP-POSITION-UPDATE",
        "GH-586-INVALID-PAYLOAD-BLOCKED",
        "GH-586-RAW-PAYLOAD-NOT-EXPOSED-TO-DASHBOARD",
        "GH-586-PRODUCTION-PARSER-DISABLED",
        "TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER"
    ]

    private func adapterEvidenceMatches(_ fixture: ReleaseV020BinanceExecutionReportFixture) -> Bool {
        switch fixture.reportKind.productType {
        case .spot:
            spotAdapterEvidence.testnetRequests.contains {
                $0.requestID == fixture.sourceCommandRequestID
                    && $0.clientOrderID == fixture.clientOrderID
            } && spotAdapterEvidence.acknowledgements.contains {
                $0.ackID == fixture.sourceCommandAckID
                    && $0.requestID == fixture.sourceCommandRequestID
            }
        case .usdsPerpetual:
            perpAdapterEvidence.testnetRequests.contains {
                $0.mappingID == fixture.sourceCommandRequestID
                    && $0.clientOrderID == fixture.clientOrderID
            } && perpAdapterEvidence.acknowledgements.contains {
                $0.ackID == fixture.sourceCommandAckID
                    && $0.requestID == fixture.sourceCommandRequestID
            }
        }
    }

    private func positionUpdateIfNeeded(
        fill: ReleaseV020NormalizedBrokerFill,
        fixture: ReleaseV020BinanceExecutionReportFixture
    ) throws -> ReleaseV020BinancePerpPositionUpdate? {
        guard fixture.reportKind.requiresPositionUpdate else {
            return nil
        }
        let previous = try XCTUnwrapLike(
            fixture.previousPositionQuantity,
            field: "releaseV020ExecutionReport.previousPositionQuantity"
        )
        let resulting = try Quantity(
            ReleaseV020BinancePerpPositionUpdateResultCalculator.resultingQuantity(fill: fill, previous: previous),
            field: "releaseV020ExecutionReport.resultingPositionQuantity"
        )
        return try ReleaseV020BinancePerpPositionUpdate(
            updateID: Identifier.constant("gh-586-\(fixture.reportKind.eventIDComponent)-position-update"),
            fill: fill,
            previousPositionQuantity: previous,
            resultingPositionQuantity: resulting
        )
    }

    static func deterministicFixtures(
        spotEvidence: ReleaseV020BinanceSpotExecutionClientAdapterEvidence,
        perpEvidence: ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence
    ) throws -> [ReleaseV020BinanceExecutionReportFixture] {
        try [
            spotFixture(kind: .spotFill, commandKind: .submit, sequence: 1, evidence: spotEvidence),
            spotFixture(kind: .spotPartialFill, commandKind: .replace, sequence: 2, evidence: spotEvidence),
            perpFixture(kind: .perpFill, commandKind: .submit, sequence: 3, evidence: perpEvidence),
            perpFixture(kind: .perpPartialFill, commandKind: .replace, sequence: 4, evidence: perpEvidence)
        ]
    }

    private static func spotFixture(
        kind: ReleaseV020BinanceExecutionReportKind,
        commandKind: ReleaseV020BinanceSpotExecutionClientCommandKind,
        sequence: Int,
        evidence: ReleaseV020BinanceSpotExecutionClientAdapterEvidence
    ) throws -> ReleaseV020BinanceExecutionReportFixture {
        guard let request = evidence.testnetRequests.first(where: { $0.commandKind == commandKind }),
              let ack = evidence.acknowledgements.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.spotAdapterEvidence",
                expected: commandKind.rawValue,
                actual: evidence.testnetRequests.map(\.commandKind.rawValue).joined(separator: ",")
            )
        }
        return try ReleaseV020BinanceExecutionReportFixture(
            reportID: Identifier.constant("gh-586-\(kind.eventIDComponent)-report"),
            sourceAdapterIssueID: Identifier.constant("GH-584"),
            reportKind: kind,
            sourceCommandKind: commandKind.rawValue,
            sourceCommandRequestID: request.requestID,
            sourceCommandAckID: ack.ackID,
            sourceOrderIntentID: request.sourceOrderIntentID,
            sourceEventLogID: request.sourceEventLogID,
            sourceOMSOrderID: request.sourceOMSOrderID,
            clientOrderID: request.clientOrderID,
            instrument: InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant(request.symbol)),
            side: "BUY",
            cumulativeFilledQuantity: try Quantity(kind.cumulativeQuantity, field: "releaseV020ExecutionReport.spotCumulative"),
            lastExecutedQuantity: try Quantity(kind.lastQuantity, field: "releaseV020ExecutionReport.spotLast"),
            remainingQuantity: try Quantity(kind.remainingQuantity, field: "releaseV020ExecutionReport.spotRemaining"),
            lastExecutedPrice: try Price(kind.lastPrice, field: "releaseV020ExecutionReport.spotPrice"),
            commissionAsset: "USDT",
            commissionAmount: kind.commissionAmount,
            replaySequence: sequence,
            rawPayloadDigest: "sha256:gh-586-\(kind.eventIDComponent)-normalized-testnet-report"
        )
    }

    private static func perpFixture(
        kind: ReleaseV020BinanceExecutionReportKind,
        commandKind: ReleaseV020BinanceUSDMPerpExecutionClientCommandKind,
        sequence: Int,
        evidence: ReleaseV020BinanceUSDMPerpExecutionClientAdapterEvidence
    ) throws -> ReleaseV020BinanceExecutionReportFixture {
        guard let request = evidence.testnetRequests.first(where: { $0.commandKind == commandKind }),
              let ack = evidence.acknowledgements.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV020ExecutionReport.perpAdapterEvidence",
                expected: commandKind.rawValue,
                actual: evidence.testnetRequests.map(\.commandKind.rawValue).joined(separator: ",")
            )
        }
        return try ReleaseV020BinanceExecutionReportFixture(
            reportID: Identifier.constant("gh-586-\(kind.eventIDComponent)-report"),
            sourceAdapterIssueID: Identifier.constant("GH-585"),
            reportKind: kind,
            sourceCommandKind: commandKind.rawValue,
            sourceCommandRequestID: request.mappingID,
            sourceCommandAckID: ack.ackID,
            sourceOrderIntentID: request.sourceOrderIntentID,
            sourceEventLogID: request.sourceEventLogID,
            sourceOMSOrderID: request.sourceOMSOrderID,
            clientOrderID: request.clientOrderID,
            instrument: InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: Symbol.constant(request.symbol)),
            side: request.side,
            positionSide: request.positionSide,
            reduceOnly: request.reduceOnly,
            cumulativeFilledQuantity: try Quantity(kind.cumulativeQuantity, field: "releaseV020ExecutionReport.perpCumulative"),
            lastExecutedQuantity: try Quantity(kind.lastQuantity, field: "releaseV020ExecutionReport.perpLast"),
            remainingQuantity: try Quantity(kind.remainingQuantity, field: "releaseV020ExecutionReport.perpRemaining"),
            lastExecutedPrice: try Price(kind.lastPrice, field: "releaseV020ExecutionReport.perpPrice"),
            commissionAsset: "USDT",
            commissionAmount: kind.commissionAmount,
            previousPositionQuantity: try Quantity(0.25, field: "releaseV020ExecutionReport.previousPositionQuantity"),
            replaySequence: sequence,
            rawPayloadDigest: "sha256:gh-586-\(kind.eventIDComponent)-normalized-testnet-report"
        )
    }
}

private enum ReleaseV020BinancePerpPositionUpdateResultCalculator {
    static func resultingQuantity(fill: ReleaseV020NormalizedBrokerFill, previous: Quantity) -> Double {
        guard let positionSide = fill.positionSide else {
            return previous.rawValue
        }
        return switch (fill.side, positionSide, fill.reduceOnly) {
        case ("SELL", .long, true), ("BUY", .short, true):
            max(0, previous.rawValue - fill.lastExecutedQuantity.rawValue)
        case ("BUY", .long, false), ("SELL", .short, false):
            previous.rawValue + fill.lastExecutedQuantity.rawValue
        default:
            previous.rawValue
        }
    }
}

private extension ReleaseV020BinanceExecutionReportKind {
    var expectedAdapterIssueID: String {
        switch productType {
        case .spot:
            "GH-584"
        case .usdsPerpetual:
            "GH-585"
        }
    }

    var eventIDComponent: String {
        switch self {
        case .spotFill:
            "spot-fill"
        case .spotPartialFill:
            "spot-partial-fill"
        case .perpFill:
            "perp-fill"
        case .perpPartialFill:
            "perp-partial-fill"
        }
    }

    var cumulativeQuantity: Double {
        switch self {
        case .spotFill:
            0.01
        case .spotPartialFill:
            0.004
        case .perpFill:
            0.25
        case .perpPartialFill:
            0.10
        }
    }

    var lastQuantity: Double {
        cumulativeQuantity
    }

    var remainingQuantity: Double {
        switch self {
        case .spotFill, .perpFill:
            0
        case .spotPartialFill:
            0.006
        case .perpPartialFill:
            0.15
        }
    }

    var lastPrice: Double {
        switch self {
        case .spotFill:
            42_120.70
        case .spotPartialFill:
            42_130.70
        case .perpFill:
            43_500
        case .perpPartialFill:
            43_510
        }
    }

    var commissionAmount: String {
        switch self {
        case .spotFill:
            "0.000010"
        case .spotPartialFill:
            "0.000004"
        case .perpFill:
            "0.000125"
        case .perpPartialFill:
            "0.000050"
        }
    }
}

private extension ReleaseV020BinanceExecutionReportInvalidReason {
    var eventIDComponent: String {
        switch self {
        case .productionRawPayload:
            "production-raw-payload"
        case .unsupportedExecutionStatus:
            "unsupported-status"
        case .rawPayloadExposureAttempt:
            "raw-payload-exposure"
        case .adapterEvidenceMismatch:
            "adapter-evidence-mismatch"
        }
    }
}

private func XCTUnwrapLike<T>(_ value: T?, field: String) throws -> T {
    guard let value else {
        throw CoreError.liveTradingBoundaryContractMismatch(
            field: field,
            expected: "non-nil",
            actual: "nil"
        )
    }
    return value
}
