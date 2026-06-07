import DomainModel
import Foundation
import MessageBus

/// ReleaseV010BinanceExecutionReportKind 固定 GH-532 支持的 Binance testnet 回报类型。
///
/// 这些类型只代表 release v0.1.0 的 testnet execution report / broker fill parser evidence。
/// 它们可以进入 ExecutionEngine 的本地事件模型，但不授权 production broker gateway、Portfolio
/// reconciliation 或真实订单生命周期。
public enum ReleaseV010BinanceExecutionReportKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case fullFill = "full fill"
    case partialFill = "partial fill"
    case canceled = "canceled"
    case rejected = "rejected"

    public var executionType: String {
        switch self {
        case .fullFill, .partialFill:
            "TRADE"
        case .canceled:
            "CANCELED"
        case .rejected:
            "REJECTED"
        }
    }

    public var orderStatus: String {
        switch self {
        case .fullFill:
            "FILLED"
        case .partialFill:
            "PARTIALLY_FILLED"
        case .canceled:
            "CANCELED"
        case .rejected:
            "REJECTED"
        }
    }

    public var producesBrokerFill: Bool {
        switch self {
        case .fullFill, .partialFill:
            true
        case .canceled, .rejected:
            false
        }
    }
}

/// ReleaseV010BinanceExecutionReportSourceKind 区分允许的 testnet 回报和仍禁止的 production raw payload。
public enum ReleaseV010BinanceExecutionReportSourceKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case testnetExecutionReport = "testnet execution report"
    case productionRawExecutionReport = "production raw execution report"
}

/// ReleaseV010BinanceExecutionReportInvalidReason 固定 GH-532 的异常回报分类。
///
/// 异常回报只能形成 blocked / invalid evidence，不能被转换成 ExecutionEngine event、broker fill
/// fact、Portfolio update 或 reconciliation input。
public enum ReleaseV010BinanceExecutionReportInvalidReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionRawPayload = "production raw payload"
    case unsupportedExecutionStatus = "unsupported execution status"
    case commandEvidenceMismatch = "command evidence mismatch"
    case rawPayloadExposureAttempt = "raw payload exposure attempt"
}

/// ReleaseV010BinanceExecutionReportFixture 是 GH-532 的 testnet-only parser 输入。
///
/// Fixture 只保存 normalized Binance execution report fields 和 digest identity。它不保存 raw JSON、
/// header、signature、credential value、account payload、production endpoint 或 broker secret。
/// `GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER`
public struct ReleaseV010BinanceExecutionReportFixture: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let sourceKind: ReleaseV010BinanceExecutionReportSourceKind
    public let environment: ReleaseV010BinanceExecutionClientVenueEnvironment
    public let reportKind: ReleaseV010BinanceExecutionReportKind
    public let sourceCommandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    public let sourceCommandRequestID: Identifier
    public let sourceCommandAckID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceOMSEventLogID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let executionType: String
    public let orderStatus: String
    public let cumulativeFilledQuantity: String
    public let lastExecutedQuantity: String
    public let remainingQuantity: String
    public let lastExecutedPrice: String
    public let commissionAsset: String
    public let commissionAmount: String
    public let replaySequence: Int
    public let rawPayloadDigest: String
    public let rawPayloadRetained: Bool
    public let productionPayloadInterpreted: Bool
    public let productionEndpointTouched: Bool
    public let brokerGatewayTouched: Bool

    public var fixtureBoundaryHeld: Bool {
        issueID.rawValue == "GH-532"
            && upstreamIssueID.rawValue == "GH-531"
            && sourceKind == .testnetExecutionReport
            && environment == .testnet
            && executionType == reportKind.executionType
            && orderStatus == reportKind.orderStatus
            && replaySequence > 0
            && allRequiredFieldsPresent
            && allForbiddenFlagsRemainClosed
    }

    private var allRequiredFieldsPresent: Bool {
        [
            symbol,
            executionType,
            orderStatus,
            cumulativeFilledQuantity,
            lastExecutedQuantity,
            remainingQuantity,
            lastExecutedPrice,
            commissionAsset,
            commissionAmount,
            rawPayloadDigest
        ].allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            rawPayloadRetained,
            productionPayloadInterpreted,
            productionEndpointTouched,
            brokerGatewayTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        reportID: Identifier,
        issueID: Identifier = Identifier.constant("GH-532"),
        upstreamIssueID: Identifier = Identifier.constant("GH-531"),
        sourceKind: ReleaseV010BinanceExecutionReportSourceKind = .testnetExecutionReport,
        environment: ReleaseV010BinanceExecutionClientVenueEnvironment = .testnet,
        reportKind: ReleaseV010BinanceExecutionReportKind,
        sourceCommandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        sourceCommandRequestID: Identifier,
        sourceCommandAckID: Identifier,
        sourceOMSOrderID: Identifier,
        sourceOMSEventLogID: Identifier,
        sourceRiskDecisionID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        executionType: String? = nil,
        orderStatus: String? = nil,
        cumulativeFilledQuantity: String,
        lastExecutedQuantity: String,
        remainingQuantity: String,
        lastExecutedPrice: String,
        commissionAsset: String,
        commissionAmount: String,
        replaySequence: Int,
        rawPayloadDigest: String,
        rawPayloadRetained: Bool = false,
        productionPayloadInterpreted: Bool = false,
        productionEndpointTouched: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        let resolvedExecutionType = executionType ?? reportKind.executionType
        let resolvedOrderStatus = orderStatus ?? reportKind.orderStatus
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCumulative = cumulativeFilledQuantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastQuantity = lastExecutedQuantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRemaining = remainingQuantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = lastExecutedPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCommissionAsset = commissionAsset.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCommissionAmount = commissionAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDigest = rawPayloadDigest.trimmingCharacters(in: .whitespacesAndNewlines)

        guard issueID.rawValue == "GH-532" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-532",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-531",
                actual: upstreamIssueID.rawValue
            )
        }
        guard sourceKind == .testnetExecutionReport else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.productionRawPayload")
        }
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.productionEnvironment")
        }
        guard resolvedExecutionType == reportKind.executionType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionType",
                expected: reportKind.executionType,
                actual: resolvedExecutionType
            )
        }
        guard resolvedOrderStatus == reportKind.orderStatus else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "orderStatus",
                expected: reportKind.orderStatus,
                actual: resolvedOrderStatus
            )
        }
        for requiredField in [
            ("symbol", trimmedSymbol),
            ("cumulativeFilledQuantity", trimmedCumulative),
            ("lastExecutedQuantity", trimmedLastQuantity),
            ("remainingQuantity", trimmedRemaining),
            ("lastExecutedPrice", trimmedPrice),
            ("commissionAsset", trimmedCommissionAsset),
            ("commissionAmount", trimmedCommissionAmount),
            ("rawPayloadDigest", trimmedDigest)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty GH-532 execution report fixture value",
                actual: "empty"
            )
        }
        guard replaySequence > 0 else {
            throw CoreError.invalidEventSequence(replaySequence)
        }
        for forbiddenFlag in [
            ("rawPayloadRetained", rawPayloadRetained),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("productionEndpointTouched", productionEndpointTouched),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.\(forbiddenFlag.0)")
        }

        self.reportID = reportID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.sourceKind = sourceKind
        self.environment = environment
        self.reportKind = reportKind
        self.sourceCommandKind = sourceCommandKind
        self.sourceCommandRequestID = sourceCommandRequestID
        self.sourceCommandAckID = sourceCommandAckID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceOMSEventLogID = sourceOMSEventLogID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.clientOrderID = clientOrderID
        self.symbol = trimmedSymbol
        self.executionType = resolvedExecutionType
        self.orderStatus = resolvedOrderStatus
        self.cumulativeFilledQuantity = trimmedCumulative
        self.lastExecutedQuantity = trimmedLastQuantity
        self.remainingQuantity = trimmedRemaining
        self.lastExecutedPrice = trimmedPrice
        self.commissionAsset = trimmedCommissionAsset
        self.commissionAmount = trimmedCommissionAmount
        self.replaySequence = replaySequence
        self.rawPayloadDigest = trimmedDigest
        self.rawPayloadRetained = rawPayloadRetained
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.productionEndpointTouched = productionEndpointTouched
        self.brokerGatewayTouched = brokerGatewayTouched
    }
}

/// ReleaseV010ExecutionEngineBrokerFillEvent 是 GH-532 的 normalized parser output。
///
/// Event 可以作为 ExecutionEngine 本地事件模型输入。它只包含 normalized fields 和 digest identity，
/// 不携带 raw payload，不写 Portfolio，不执行 reconciliation，也不打开 Dashboard command surface。
/// `GH-532-EXECUTIONENGINE-EVENT-MODEL-HANDOFF`
/// `GH-532-BROKER-FILL-MAPPING`
public struct ReleaseV010ExecutionEngineBrokerFillEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let reportID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let reportKind: ReleaseV010BinanceExecutionReportKind
    public let sourceCommandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    public let sourceCommandRequestID: Identifier
    public let sourceCommandAckID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceOMSEventLogID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let clientOrderID: Identifier
    public let eventStream: EventStreamID
    public let symbol: String
    public let executionType: String
    public let orderStatus: String
    public let cumulativeFilledQuantity: String
    public let lastExecutedQuantity: String
    public let remainingQuantity: String
    public let lastExecutedPrice: String
    public let commissionAsset: String
    public let commissionAmount: String
    public let replaySequence: Int
    public let rawPayloadDigest: String
    public let validationAnchors: [String]
    public let executionEngineEventModelReady: Bool
    public let brokerFillMapped: Bool
    public let invalidOrBlocked: Bool
    public let rawPayloadExposed: Bool
    public let productionPayloadInterpreted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioUpdated: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var eventBoundaryHeld: Bool {
        issueID.rawValue == "GH-532"
            && upstreamIssueID.rawValue == "GH-531"
            && eventStream == .paper
            && executionType == reportKind.executionType
            && orderStatus == reportKind.orderStatus
            && replaySequence > 0
            && validationAnchors == ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors
            && executionEngineEventModelReady
            && brokerFillMapped == reportKind.producesBrokerFill
            && invalidOrBlocked == false
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            rawPayloadExposed,
            productionPayloadInterpreted,
            productionTradingEnabledByDefault,
            brokerGatewayTouched,
            reconciliationProduced,
            portfolioUpdated,
            dashboardCommandSurfaceTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        eventID: Identifier,
        reportID: Identifier,
        issueID: Identifier = Identifier.constant("GH-532"),
        upstreamIssueID: Identifier = Identifier.constant("GH-531"),
        reportKind: ReleaseV010BinanceExecutionReportKind,
        sourceCommandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        sourceCommandRequestID: Identifier,
        sourceCommandAckID: Identifier,
        sourceOMSOrderID: Identifier,
        sourceOMSEventLogID: Identifier,
        sourceRiskDecisionID: Identifier,
        clientOrderID: Identifier,
        eventStream: EventStreamID = .paper,
        symbol: String,
        executionType: String,
        orderStatus: String,
        cumulativeFilledQuantity: String,
        lastExecutedQuantity: String,
        remainingQuantity: String,
        lastExecutedPrice: String,
        commissionAsset: String,
        commissionAmount: String,
        replaySequence: Int,
        rawPayloadDigest: String,
        validationAnchors: [String] = ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors,
        executionEngineEventModelReady: Bool = true,
        brokerFillMapped: Bool? = nil,
        invalidOrBlocked: Bool = false,
        rawPayloadExposed: Bool = false,
        productionPayloadInterpreted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioUpdated: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedBrokerFillMapped = brokerFillMapped ?? reportKind.producesBrokerFill
        guard issueID.rawValue == "GH-532" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-532",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-531",
                actual: upstreamIssueID.rawValue
            )
        }
        guard eventStream == .paper else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.nonPaperEventStream")
        }
        guard executionType == reportKind.executionType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionType",
                expected: reportKind.executionType,
                actual: executionType
            )
        }
        guard orderStatus == reportKind.orderStatus else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "orderStatus",
                expected: reportKind.orderStatus,
                actual: orderStatus
            )
        }
        guard validationAnchors == ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard executionEngineEventModelReady else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionEngineEventModelReady",
                expected: "true",
                actual: "false"
            )
        }
        guard resolvedBrokerFillMapped == reportKind.producesBrokerFill else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "brokerFillMapped",
                expected: "\(reportKind.producesBrokerFill)",
                actual: "\(resolvedBrokerFillMapped)"
            )
        }
        guard invalidOrBlocked == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.invalidEventProduced")
        }
        for forbiddenFlag in [
            ("rawPayloadExposed", rawPayloadExposed),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioUpdated", portfolioUpdated),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.\(forbiddenFlag.0)")
        }

        self.eventID = eventID
        self.reportID = reportID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.reportKind = reportKind
        self.sourceCommandKind = sourceCommandKind
        self.sourceCommandRequestID = sourceCommandRequestID
        self.sourceCommandAckID = sourceCommandAckID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceOMSEventLogID = sourceOMSEventLogID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.clientOrderID = clientOrderID
        self.eventStream = eventStream
        self.symbol = symbol
        self.executionType = executionType
        self.orderStatus = orderStatus
        self.cumulativeFilledQuantity = cumulativeFilledQuantity
        self.lastExecutedQuantity = lastExecutedQuantity
        self.remainingQuantity = remainingQuantity
        self.lastExecutedPrice = lastExecutedPrice
        self.commissionAsset = commissionAsset
        self.commissionAmount = commissionAmount
        self.replaySequence = replaySequence
        self.rawPayloadDigest = rawPayloadDigest
        self.validationAnchors = validationAnchors
        self.executionEngineEventModelReady = executionEngineEventModelReady
        self.brokerFillMapped = resolvedBrokerFillMapped
        self.invalidOrBlocked = invalidOrBlocked
        self.rawPayloadExposed = rawPayloadExposed
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioUpdated = portfolioUpdated
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched
    }
}

/// ReleaseV010BinanceExecutionReportInvalidEvidence 是 GH-532 的异常回报 blocked evidence。
/// `GH-532-INVALID-REPORT-BLOCKED-EVIDENCE`
public struct ReleaseV010BinanceExecutionReportInvalidEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let sourceCommandEvidenceID: Identifier
    public let reason: ReleaseV010BinanceExecutionReportInvalidReason
    public let invalidReportBlocked: Bool
    public let executionEngineEventProduced: Bool
    public let brokerFillMapped: Bool
    public let rawPayloadRetained: Bool
    public let productionPayloadInterpreted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioUpdated: Bool

    public var invalidEvidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-532"
            && upstreamIssueID.rawValue == "GH-531"
            && invalidReportBlocked
            && executionEngineEventProduced == false
            && brokerFillMapped == false
            && [
                rawPayloadRetained,
                productionPayloadInterpreted,
                productionTradingEnabledByDefault,
                brokerGatewayTouched,
                reconciliationProduced,
                portfolioUpdated
            ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier,
        issueID: Identifier = Identifier.constant("GH-532"),
        upstreamIssueID: Identifier = Identifier.constant("GH-531"),
        sourceCommandEvidenceID: Identifier,
        reason: ReleaseV010BinanceExecutionReportInvalidReason,
        invalidReportBlocked: Bool = true,
        executionEngineEventProduced: Bool = false,
        brokerFillMapped: Bool = false,
        rawPayloadRetained: Bool = false,
        productionPayloadInterpreted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioUpdated: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-532" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-532",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-531",
                actual: upstreamIssueID.rawValue
            )
        }
        guard invalidReportBlocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "invalidReportBlocked",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("executionEngineEventProduced", executionEngineEventProduced),
            ("brokerFillMapped", brokerFillMapped),
            ("rawPayloadRetained", rawPayloadRetained),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioUpdated", portfolioUpdated)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.invalid.\(forbiddenFlag.0)")
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.sourceCommandEvidenceID = sourceCommandEvidenceID
        self.reason = reason
        self.invalidReportBlocked = invalidReportBlocked
        self.executionEngineEventProduced = executionEngineEventProduced
        self.brokerFillMapped = brokerFillMapped
        self.rawPayloadRetained = rawPayloadRetained
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioUpdated = portfolioUpdated
    }
}

/// ReleaseV010BinanceExecutionReportParserEvidence 汇总 GH-532 的 parser / broker fill evidence。
/// `GH-532-PARTIAL-CANCEL-REJECT-EVIDENCE`
/// `TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER`
public struct ReleaseV010BinanceExecutionReportParserEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let parsedEvents: [ReleaseV010ExecutionEngineBrokerFillEvent]
    public let invalidReports: [ReleaseV010BinanceExecutionReportInvalidEvidence]
    public let validationAnchors: [String]
    public let executionEngineEventModelReady: Bool
    public let brokerFillMappingEvidenceComplete: Bool
    public let partialFillCancelRejectCovered: Bool
    public let invalidReportBlockedEvidenceComplete: Bool
    public let productionParserDisabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioUpdated: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-532"
            && upstreamIssueID.rawValue == "GH-531"
            && Set(parsedEvents.map(\.reportKind)) == Set(ReleaseV010BinanceExecutionReportKind.allCases)
            && parsedEvents.map(\.replaySequence) == [1, 2, 3, 4]
            && parsedEvents.allSatisfy(\.eventBoundaryHeld)
            && invalidReports.isEmpty == false
            && invalidReports.allSatisfy(\.invalidEvidenceBoundaryHeld)
            && validationAnchors == ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors
            && executionEngineEventModelReady
            && brokerFillMappingEvidenceComplete
            && partialFillCancelRejectCovered
            && invalidReportBlockedEvidenceComplete
            && productionParserDisabled
            && [
                productionTradingEnabledByDefault,
                productionPayloadInterpreted,
                brokerGatewayTouched,
                reconciliationProduced,
                portfolioUpdated,
                dashboardCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-532-binance-execution-report-parser-evidence"),
        issueID: Identifier = Identifier.constant("GH-532"),
        upstreamIssueID: Identifier = Identifier.constant("GH-531"),
        parsedEvents: [ReleaseV010ExecutionEngineBrokerFillEvent],
        invalidReports: [ReleaseV010BinanceExecutionReportInvalidEvidence],
        validationAnchors: [String] = ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors,
        executionEngineEventModelReady: Bool = true,
        brokerFillMappingEvidenceComplete: Bool = true,
        partialFillCancelRejectCovered: Bool = true,
        invalidReportBlockedEvidenceComplete: Bool = true,
        productionParserDisabled: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioUpdated: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-532" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-532",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-531",
                actual: upstreamIssueID.rawValue
            )
        }
        guard Set(parsedEvents.map(\.reportKind)) == Set(ReleaseV010BinanceExecutionReportKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parsedEvents",
                expected: ReleaseV010BinanceExecutionReportKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: parsedEvents.map { $0.reportKind.rawValue }.joined(separator: ",")
            )
        }
        guard parsedEvents.map(\.replaySequence) == [1, 2, 3, 4] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replaySequence",
                expected: "1,2,3,4",
                actual: parsedEvents.map { "\($0.replaySequence)" }.joined(separator: ",")
            )
        }
        guard parsedEvents.allSatisfy(\.eventBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parsedEvents",
                expected: "all GH-532 parsed event boundaries held",
                actual: "mismatch"
            )
        }
        guard invalidReports.isEmpty == false, invalidReports.allSatisfy(\.invalidEvidenceBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "invalidReports",
                expected: "non-empty invalid report blocked evidence",
                actual: "missing or mismatched"
            )
        }
        guard validationAnchors == ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010BinanceExecutionReportParser.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("executionEngineEventModelReady", executionEngineEventModelReady),
            ("brokerFillMappingEvidenceComplete", brokerFillMappingEvidenceComplete),
            ("partialFillCancelRejectCovered", partialFillCancelRejectCovered),
            ("invalidReportBlockedEvidenceComplete", invalidReportBlockedEvidenceComplete),
            ("productionParserDisabled", productionParserDisabled)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("reconciliationProduced", reconciliationProduced),
            ("portfolioUpdated", portfolioUpdated),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.\(forbiddenFlag.0)")
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.parsedEvents = parsedEvents
        self.invalidReports = invalidReports
        self.validationAnchors = validationAnchors
        self.executionEngineEventModelReady = executionEngineEventModelReady
        self.brokerFillMappingEvidenceComplete = brokerFillMappingEvidenceComplete
        self.partialFillCancelRejectCovered = partialFillCancelRejectCovered
        self.invalidReportBlockedEvidenceComplete = invalidReportBlockedEvidenceComplete
        self.productionParserDisabled = productionParserDisabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioUpdated = portfolioUpdated
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched
    }
}

/// ReleaseV010BinanceExecutionReportParser 是 GH-532 的 Binance testnet execution report parser。
///
/// Parser 消费 GH-531 command evidence，输出 ExecutionEngine 可消费的 normalized event evidence。
/// 它不联网、不读取 secret、不解释 production raw payload、不执行 reconciliation、不更新 Portfolio。
public struct ReleaseV010BinanceExecutionReportParser: Codable, Equatable, Sendable {
    public let parserID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence
    public let validationAnchors: [String]
    public let productionParserEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let reconciliationProduced: Bool
    public let portfolioUpdated: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var parserBoundaryHeld: Bool {
        issueID.rawValue == "GH-532"
            && upstreamIssueID.rawValue == "GH-531"
            && commandEvidence.evidenceBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && [
                productionParserEnabledByDefault,
                productionTradingEnabledByDefault,
                productionPayloadInterpreted,
                brokerGatewayTouched,
                reconciliationProduced,
                portfolioUpdated,
                dashboardCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    public init(
        parserID: Identifier = Identifier.constant("gh-532-binance-execution-report-parser"),
        issueID: Identifier = Identifier.constant("GH-532"),
        upstreamIssueID: Identifier = Identifier.constant("GH-531"),
        commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionParserEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        reconciliationProduced: Bool = false,
        portfolioUpdated: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedCommandEvidence = try commandEvidence
            ?? ReleaseV010BinanceExecutionClientTestnetAdapter.deterministicFixture().deterministicCommandEvidence()
        guard issueID.rawValue == "GH-532" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-532",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-531",
                actual: upstreamIssueID.rawValue
            )
        }
        guard resolvedCommandEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence",
                expected: "GH-531 command evidence held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
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
            ("portfolioUpdated", portfolioUpdated),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.\(forbiddenFlag.0)")
        }

        self.parserID = parserID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandEvidence = resolvedCommandEvidence
        self.validationAnchors = validationAnchors
        self.productionParserEnabledByDefault = productionParserEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.reconciliationProduced = reconciliationProduced
        self.portfolioUpdated = portfolioUpdated
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched
    }

    /// 将单条 Binance testnet report fixture 转成 ExecutionEngine event model evidence。
    public func parse(
        _ fixture: ReleaseV010BinanceExecutionReportFixture
    ) throws -> ReleaseV010ExecutionEngineBrokerFillEvent {
        guard parserBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard fixture.fixtureBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "fixtureBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard commandEvidence.requests.contains(where: { $0.requestID == fixture.sourceCommandRequestID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceCommandRequestID",
                expected: commandEvidence.requests.map(\.requestID.rawValue).joined(separator: ","),
                actual: fixture.sourceCommandRequestID.rawValue
            )
        }
        guard commandEvidence.acknowledgements.contains(where: { $0.ackID == fixture.sourceCommandAckID }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceCommandAckID",
                expected: commandEvidence.acknowledgements.map(\.ackID.rawValue).joined(separator: ","),
                actual: fixture.sourceCommandAckID.rawValue
            )
        }

        return try ReleaseV010ExecutionEngineBrokerFillEvent(
            eventID: Identifier.constant("gh-532-binance-\(fixture.reportKind.eventIDComponent)-event"),
            reportID: fixture.reportID,
            reportKind: fixture.reportKind,
            sourceCommandKind: fixture.sourceCommandKind,
            sourceCommandRequestID: fixture.sourceCommandRequestID,
            sourceCommandAckID: fixture.sourceCommandAckID,
            sourceOMSOrderID: fixture.sourceOMSOrderID,
            sourceOMSEventLogID: fixture.sourceOMSEventLogID,
            sourceRiskDecisionID: fixture.sourceRiskDecisionID,
            clientOrderID: fixture.clientOrderID,
            symbol: fixture.symbol,
            executionType: fixture.executionType,
            orderStatus: fixture.orderStatus,
            cumulativeFilledQuantity: fixture.cumulativeFilledQuantity,
            lastExecutedQuantity: fixture.lastExecutedQuantity,
            remainingQuantity: fixture.remainingQuantity,
            lastExecutedPrice: fixture.lastExecutedPrice,
            commissionAsset: fixture.commissionAsset,
            commissionAmount: fixture.commissionAmount,
            replaySequence: fixture.replaySequence,
            rawPayloadDigest: fixture.rawPayloadDigest
        )
    }

    /// 为异常回报生成 blocked / invalid evidence，不产生 ExecutionEngine event。
    public func invalidEvidence(
        reason: ReleaseV010BinanceExecutionReportInvalidReason,
        evidenceID: Identifier? = nil
    ) throws -> ReleaseV010BinanceExecutionReportInvalidEvidence {
        guard parserBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try ReleaseV010BinanceExecutionReportInvalidEvidence(
            evidenceID: evidenceID ?? Identifier.constant("gh-532-invalid-\(reason.eventIDComponent)-evidence"),
            sourceCommandEvidenceID: commandEvidence.evidenceID,
            reason: reason
        )
    }

    /// 生成 GH-532 deterministic fill / partial fill / cancel / reject parser evidence。
    public func deterministicParserEvidence() throws -> ReleaseV010BinanceExecutionReportParserEvidence {
        let events = try Self.deterministicFixtures(commandEvidence: commandEvidence).map(parse)
        let invalid = try [
            invalidEvidence(reason: .unsupportedExecutionStatus),
            invalidEvidence(reason: .productionRawPayload)
        ]
        return try ReleaseV010BinanceExecutionReportParserEvidence(
            parsedEvents: events,
            invalidReports: invalid
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010BinanceExecutionReportParser {
        try ReleaseV010BinanceExecutionReportParser()
    }

    public static let requiredValidationAnchors = [
        "GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER",
        "GH-532-EXECUTIONENGINE-EVENT-MODEL-HANDOFF",
        "GH-532-BROKER-FILL-MAPPING",
        "GH-532-PARTIAL-CANCEL-REJECT-EVIDENCE",
        "GH-532-INVALID-REPORT-BLOCKED-EVIDENCE",
        "GH-532-PRODUCTION-PARSER-DISABLED",
        "TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER"
    ]

    static func deterministicFixtures(
        commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence
    ) throws -> [ReleaseV010BinanceExecutionReportFixture] {
        try [
            deterministicFixture(kind: .fullFill, commandKind: .submit, sequence: 1, commandEvidence: commandEvidence),
            deterministicFixture(kind: .partialFill, commandKind: .replace, sequence: 2, commandEvidence: commandEvidence),
            deterministicFixture(kind: .canceled, commandKind: .cancel, sequence: 3, commandEvidence: commandEvidence),
            deterministicFixture(kind: .rejected, commandKind: .submit, sequence: 4, commandEvidence: commandEvidence)
        ]
    }

    private static func deterministicFixture(
        kind: ReleaseV010BinanceExecutionReportKind,
        commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        sequence: Int,
        commandEvidence: ReleaseV010BinanceExecutionClientTestnetCommandEvidence
    ) throws -> ReleaseV010BinanceExecutionReportFixture {
        guard let request = commandEvidence.requests.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence.requests",
                expected: commandKind.rawValue,
                actual: commandEvidence.requests.map(\.commandKind.rawValue).joined(separator: ",")
            )
        }
        guard let ack = commandEvidence.acknowledgements.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence.acknowledgements",
                expected: commandKind.rawValue,
                actual: commandEvidence.acknowledgements.map(\.commandKind.rawValue).joined(separator: ",")
            )
        }
        return try ReleaseV010BinanceExecutionReportFixture(
            reportID: Identifier.constant("gh-532-binance-\(kind.eventIDComponent)-report"),
            reportKind: kind,
            sourceCommandKind: commandKind,
            sourceCommandRequestID: request.requestID,
            sourceCommandAckID: ack.ackID,
            sourceOMSOrderID: request.sourceOMSOrderID,
            sourceOMSEventLogID: request.sourceOMSEventLogID,
            sourceRiskDecisionID: request.sourceRiskDecisionID,
            clientOrderID: request.clientOrderID,
            symbol: request.symbol,
            cumulativeFilledQuantity: kind.cumulativeFilledQuantity,
            lastExecutedQuantity: kind.lastExecutedQuantity,
            remainingQuantity: kind.remainingQuantity,
            lastExecutedPrice: kind.lastExecutedPrice,
            commissionAsset: "USDT",
            commissionAmount: kind.commissionAmount,
            replaySequence: sequence,
            rawPayloadDigest: "sha256:gh-532-binance-\(kind.eventIDComponent)-testnet-report"
        )
    }
}

private extension ReleaseV010BinanceExecutionReportKind {
    var eventIDComponent: String {
        switch self {
        case .fullFill:
            "full-fill"
        case .partialFill:
            "partial-fill"
        case .canceled:
            "canceled"
        case .rejected:
            "rejected"
        }
    }

    var cumulativeFilledQuantity: String {
        switch self {
        case .fullFill:
            "0.0100"
        case .partialFill:
            "0.0040"
        case .canceled, .rejected:
            "0.0000"
        }
    }

    var lastExecutedQuantity: String {
        switch self {
        case .fullFill:
            "0.0100"
        case .partialFill:
            "0.0040"
        case .canceled, .rejected:
            "0.0000"
        }
    }

    var remainingQuantity: String {
        switch self {
        case .fullFill:
            "0.0000"
        case .partialFill:
            "0.0060"
        case .canceled, .rejected:
            "0.0100"
        }
    }

    var lastExecutedPrice: String {
        switch self {
        case .fullFill:
            "42120.70"
        case .partialFill:
            "42130.70"
        case .canceled, .rejected:
            "0.00"
        }
    }

    var commissionAmount: String {
        switch self {
        case .fullFill:
            "0.000010"
        case .partialFill:
            "0.000004"
        case .canceled, .rejected:
            "0.000000"
        }
    }
}

private extension ReleaseV010BinanceExecutionReportInvalidReason {
    var eventIDComponent: String {
        switch self {
        case .productionRawPayload:
            "production-raw-payload"
        case .unsupportedExecutionStatus:
            "unsupported-status"
        case .commandEvidenceMismatch:
            "command-evidence-mismatch"
        case .rawPayloadExposureAttempt:
            "raw-payload-exposure"
        }
    }
}
