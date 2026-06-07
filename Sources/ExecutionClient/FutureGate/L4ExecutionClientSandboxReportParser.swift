import DomainModel
import Foundation

/// L4ExecutionClientSandboxReportKind 固定 GH-460 sandbox parser 必须覆盖的 report / fill 种类。
///
/// 这些 kind 只代表本地 sandbox fixture 被解析后的 evidence taxonomy；它们不是 production
/// execution report、不是真实 broker fill，也不会推进 OMS、reconciliation 或 Live command surface。
public enum L4ExecutionClientSandboxReportKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fill = "fill"
    case partialFill = "partial fill"
    case reject = "reject"
    case cancelAcknowledgement = "cancel acknowledgement"
}

/// L4ExecutionClientSandboxReportSourceKind 区分当前允许的 sandbox fixture 和仍禁止的 production raw payload。
///
/// GH-460 只解析 `sandboxFixture`。`productionRawPayload` 作为 forbidden input 进入 deterministic tests，
/// 不能被解释为当前可用的 production parser。
public enum L4ExecutionClientSandboxReportSourceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandboxFixture = "sandbox fixture"
    case productionRawPayload = "production raw payload"
}

/// L4ExecutionClientSandboxReportForbiddenCapability 枚举 GH-460 必须保持关闭的能力。
///
/// Sandbox parser 只把本地 fixture 变成 replayable audit evidence。它不保存 raw broker payload 到
/// Dashboard，不生成真实 broker fill fact，不推进 OMS / reconciliation，也不打开 production parser。
public enum L4ExecutionClientSandboxReportForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionRawPayloadInterpreted = "production raw payload interpreted"
    case rawPayloadSentToDashboard = "raw payload sent to Dashboard"
    case brokerGatewayTouched = "broker gateway touched"
    case realBrokerFillRecorded = "real broker fill recorded"
    case realExecutionReportIngested = "real execution report ingested"
    case omsStateTransitionProduced = "OMS state transition produced"
    case reconciliationProduced = "reconciliation produced"
    case liveCommandSurfaceTouched = "Live command surface touched"
    case productionTradingEnabledByDefault = "production trading enabled by default"
}

/// L4ExecutionClientSandboxReportFixture 是 GH-460 parser 的 sandbox-only 输入行。
///
/// Fixture 只携带可审计的 sandbox report metadata、digest 和 normalized fixture fields。它不会保存或暴露
/// exchange 原始 JSON、HTTP header、signature、secret、account payload、broker payload 或 production endpoint。
public struct L4ExecutionClientSandboxReportFixture: Codable, Equatable, Sendable {
    public let reportID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let sourceKind: L4ExecutionClientSandboxReportSourceKind
    public let venueMode: L4ExecutionClientSandboxVenueMode
    public let reportKind: L4ExecutionClientSandboxReportKind
    public let relatedCommandKind: L4ExecutionClientSandboxCommandKind
    public let clientOrderID: Identifier
    public let symbol: String
    public let filledQuantity: String
    public let remainingQuantity: String
    public let reportStatus: String
    public let replaySequence: Int
    public let sandboxTraceID: Identifier
    public let rawPayloadDigest: String
    public let productionRawPayloadPresent: Bool
    public let rawPayloadExposedToDashboard: Bool
    public let brokerGatewayTouched: Bool

    public init(
        reportID: Identifier,
        issueID: Identifier = Identifier.constant("GH-460"),
        upstreamIssueID: Identifier = Identifier.constant("GH-459"),
        sourceKind: L4ExecutionClientSandboxReportSourceKind = .sandboxFixture,
        venueMode: L4ExecutionClientSandboxVenueMode = .sandbox,
        reportKind: L4ExecutionClientSandboxReportKind,
        relatedCommandKind: L4ExecutionClientSandboxCommandKind,
        clientOrderID: Identifier,
        symbol: String,
        filledQuantity: String,
        remainingQuantity: String,
        reportStatus: String,
        replaySequence: Int,
        sandboxTraceID: Identifier,
        rawPayloadDigest: String,
        productionRawPayloadPresent: Bool = false,
        rawPayloadExposedToDashboard: Bool = false,
        brokerGatewayTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-460" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-460",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-459",
                actual: upstreamIssueID.rawValue
            )
        }
        guard sourceKind == .sandboxFixture else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("sourceKind.productionRawPayload")
        }
        guard venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        for requiredField in [
            ("symbol", symbol),
            ("filledQuantity", filledQuantity),
            ("remainingQuantity", remainingQuantity),
            ("reportStatus", reportStatus),
            ("rawPayloadDigest", rawPayloadDigest)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty sandbox report fixture value",
                actual: "empty"
            )
        }
        guard replaySequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replaySequence",
                expected: "positive replay sequence",
                actual: "\(replaySequence)"
            )
        }
        guard reportStatus == Self.expectedStatus(for: reportKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reportStatus",
                expected: Self.expectedStatus(for: reportKind),
                actual: reportStatus
            )
        }
        for forbiddenFlag in [
            ("productionRawPayloadPresent", productionRawPayloadPresent),
            ("rawPayloadExposedToDashboard", rawPayloadExposedToDashboard),
            ("brokerGatewayTouched", brokerGatewayTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.reportID = reportID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.sourceKind = sourceKind
        self.venueMode = venueMode
        self.reportKind = reportKind
        self.relatedCommandKind = relatedCommandKind
        self.clientOrderID = clientOrderID
        self.symbol = symbol
        self.filledQuantity = filledQuantity
        self.remainingQuantity = remainingQuantity
        self.reportStatus = reportStatus
        self.replaySequence = replaySequence
        self.sandboxTraceID = sandboxTraceID
        self.rawPayloadDigest = rawPayloadDigest
        self.productionRawPayloadPresent = productionRawPayloadPresent
        self.rawPayloadExposedToDashboard = rawPayloadExposedToDashboard
        self.brokerGatewayTouched = brokerGatewayTouched
    }

    public static func expectedStatus(for kind: L4ExecutionClientSandboxReportKind) -> String {
        switch kind {
        case .fill:
            "filled by deterministic sandbox report"
        case .partialFill:
            "partially filled by deterministic sandbox report"
        case .reject:
            "rejected by deterministic sandbox report"
        case .cancelAcknowledgement:
            "cancel acknowledged by deterministic sandbox report"
        }
    }
}

/// L4ExecutionClientSandboxParsedReportEvent 是 GH-460 的 normalized parser output。
///
/// Event 可进入 audit replay evidence，但只包含 normalized fields 和 digest identity；它不携带 raw payload，
/// 不写 Dashboard raw data，不生成 broker fill fact，不推进 OMS state transition 或 reconciliation。
public struct L4ExecutionClientSandboxParsedReportEvent: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let reportID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let reportKind: L4ExecutionClientSandboxReportKind
    public let relatedCommandKind: L4ExecutionClientSandboxCommandKind
    public let replaySequence: Int
    public let eventStatus: String
    public let clientOrderID: Identifier
    public let symbol: String
    public let filledQuantity: String
    public let remainingQuantity: String
    public let rawPayloadDigest: String
    public let replayable: Bool
    public let auditEvidenceAttached: Bool
    public let dashboardReadModelSafe: Bool
    public let rawPayloadRetainedForDashboard: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerFillFactRecorded: Bool
    public let omsStateTransitionProduced: Bool
    public let reconciliationProduced: Bool

    public var parsedEventBoundaryHeld: Bool {
        issueID.rawValue == "GH-460"
            && upstreamIssueID.rawValue == "GH-459"
            && replaySequence > 0
            && eventStatus == L4ExecutionClientSandboxReportFixture.expectedStatus(for: reportKind)
            && replayable
            && auditEvidenceAttached
            && dashboardReadModelSafe
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            rawPayloadRetainedForDashboard,
            productionPayloadInterpreted,
            brokerFillFactRecorded,
            omsStateTransitionProduced,
            reconciliationProduced
        ].allSatisfy { $0 == false }
    }

    public init(
        eventID: Identifier,
        reportID: Identifier,
        issueID: Identifier = Identifier.constant("GH-460"),
        upstreamIssueID: Identifier = Identifier.constant("GH-459"),
        reportKind: L4ExecutionClientSandboxReportKind,
        relatedCommandKind: L4ExecutionClientSandboxCommandKind,
        replaySequence: Int,
        eventStatus: String,
        clientOrderID: Identifier,
        symbol: String,
        filledQuantity: String,
        remainingQuantity: String,
        rawPayloadDigest: String,
        replayable: Bool = true,
        auditEvidenceAttached: Bool = true,
        dashboardReadModelSafe: Bool = true,
        rawPayloadRetainedForDashboard: Bool = false,
        productionPayloadInterpreted: Bool = false,
        brokerFillFactRecorded: Bool = false,
        omsStateTransitionProduced: Bool = false,
        reconciliationProduced: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-460" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-460",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-459",
                actual: upstreamIssueID.rawValue
            )
        }
        guard replaySequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replaySequence",
                expected: "positive replay sequence",
                actual: "\(replaySequence)"
            )
        }
        guard eventStatus == L4ExecutionClientSandboxReportFixture.expectedStatus(for: reportKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "eventStatus",
                expected: L4ExecutionClientSandboxReportFixture.expectedStatus(for: reportKind),
                actual: eventStatus
            )
        }
        for requiredField in [
            ("symbol", symbol),
            ("filledQuantity", filledQuantity),
            ("remainingQuantity", remainingQuantity),
            ("rawPayloadDigest", rawPayloadDigest)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty parsed sandbox report event value",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("replayable", replayable),
            ("auditEvidenceAttached", auditEvidenceAttached),
            ("dashboardReadModelSafe", dashboardReadModelSafe)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("rawPayloadRetainedForDashboard", rawPayloadRetainedForDashboard),
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerFillFactRecorded", brokerFillFactRecorded),
            ("omsStateTransitionProduced", omsStateTransitionProduced),
            ("reconciliationProduced", reconciliationProduced)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.eventID = eventID
        self.reportID = reportID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.reportKind = reportKind
        self.relatedCommandKind = relatedCommandKind
        self.replaySequence = replaySequence
        self.eventStatus = eventStatus
        self.clientOrderID = clientOrderID
        self.symbol = symbol
        self.filledQuantity = filledQuantity
        self.remainingQuantity = remainingQuantity
        self.rawPayloadDigest = rawPayloadDigest
        self.replayable = replayable
        self.auditEvidenceAttached = auditEvidenceAttached
        self.dashboardReadModelSafe = dashboardReadModelSafe
        self.rawPayloadRetainedForDashboard = rawPayloadRetainedForDashboard
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerFillFactRecorded = brokerFillFactRecorded
        self.omsStateTransitionProduced = omsStateTransitionProduced
        self.reconciliationProduced = reconciliationProduced
    }
}

/// L4ExecutionClientSandboxReportReplayEvidence 汇总 GH-460 parser 的 replay / audit evidence。
///
/// Evidence 必须覆盖 fill、partial fill、reject 和 cancel acknowledgement，并证明 replay 顺序稳定、
/// raw payload 不进 Dashboard、production parser disabled、OMS / reconciliation / real broker fill 全部关闭。
public struct L4ExecutionClientSandboxReportReplayEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let parsedEvents: [L4ExecutionClientSandboxParsedReportEvent]
    public let validationAnchors: [String]
    public let reportParserReplayable: Bool
    public let eventAuditEvidenceAttached: Bool
    public let rawPayloadExcludedFromDashboard: Bool
    public let productionParserDisabled: Bool
    public let productionPayloadInterpreted: Bool
    public let brokerGatewayTouched: Bool
    public let realBrokerFillRecorded: Bool
    public let omsStateTransitionProduced: Bool
    public let reconciliationProduced: Bool
    public let liveCommandSurfaceTouched: Bool

    public var reportParserEvidenceHeld: Bool {
        issueID.rawValue == "GH-460"
            && upstreamIssueID.rawValue == "GH-459"
            && Set(parsedEvents.map(\.reportKind)) == Set(L4ExecutionClientSandboxReportKind.allCases)
            && parsedEvents.map(\.replaySequence) == [1, 2, 3, 4]
            && parsedEvents.allSatisfy(\.parsedEventBoundaryHeld)
            && validationAnchors == L4ExecutionClientSandboxReportParser.requiredValidationAnchors
            && reportParserReplayable
            && eventAuditEvidenceAttached
            && rawPayloadExcludedFromDashboard
            && productionParserDisabled
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionPayloadInterpreted,
            brokerGatewayTouched,
            realBrokerFillRecorded,
            omsStateTransitionProduced,
            reconciliationProduced,
            liveCommandSurfaceTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-460-execution-report-broker-fill-parser-evidence"),
        issueID: Identifier = Identifier.constant("GH-460"),
        upstreamIssueID: Identifier = Identifier.constant("GH-459"),
        parsedEvents: [L4ExecutionClientSandboxParsedReportEvent],
        validationAnchors: [String] = L4ExecutionClientSandboxReportParser.requiredValidationAnchors,
        reportParserReplayable: Bool = true,
        eventAuditEvidenceAttached: Bool = true,
        rawPayloadExcludedFromDashboard: Bool = true,
        productionParserDisabled: Bool = true,
        productionPayloadInterpreted: Bool = false,
        brokerGatewayTouched: Bool = false,
        realBrokerFillRecorded: Bool = false,
        omsStateTransitionProduced: Bool = false,
        reconciliationProduced: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-460" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-460",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-459",
                actual: upstreamIssueID.rawValue
            )
        }
        guard Set(parsedEvents.map(\.reportKind)) == Set(L4ExecutionClientSandboxReportKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parsedEvents",
                expected: L4ExecutionClientSandboxReportKind.allCases.map(\.rawValue).joined(separator: ","),
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
        guard parsedEvents.allSatisfy(\.parsedEventBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parsedEvents",
                expected: "all parsed event boundaries held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == L4ExecutionClientSandboxReportParser.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: L4ExecutionClientSandboxReportParser.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("reportParserReplayable", reportParserReplayable),
            ("eventAuditEvidenceAttached", eventAuditEvidenceAttached),
            ("rawPayloadExcludedFromDashboard", rawPayloadExcludedFromDashboard),
            ("productionParserDisabled", productionParserDisabled)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("productionPayloadInterpreted", productionPayloadInterpreted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("realBrokerFillRecorded", realBrokerFillRecorded),
            ("omsStateTransitionProduced", omsStateTransitionProduced),
            ("reconciliationProduced", reconciliationProduced),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.parsedEvents = parsedEvents
        self.validationAnchors = validationAnchors
        self.reportParserReplayable = reportParserReplayable
        self.eventAuditEvidenceAttached = eventAuditEvidenceAttached
        self.rawPayloadExcludedFromDashboard = rawPayloadExcludedFromDashboard
        self.productionParserDisabled = productionParserDisabled
        self.productionPayloadInterpreted = productionPayloadInterpreted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realBrokerFillRecorded = realBrokerFillRecorded
        self.omsStateTransitionProduced = omsStateTransitionProduced
        self.reconciliationProduced = reconciliationProduced
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }
}

/// L4ExecutionClientSandboxReportParser 是 GH-460 的 sandbox-only report parser。
///
/// Parser 只能读取 GH-460 本地 sandbox fixtures，并依赖 GH-459 command evidence 作为 upstream gate。
/// 它不解析 production raw payload，不联网，不读取 secret，不触碰 broker gateway，不生成 OMS state
/// transition，也不会把 raw payload 传给 Dashboard。
public struct L4ExecutionClientSandboxReportParser: Codable, Equatable, Sendable {
    public let parserID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandEvidence: L4ExecutionClientSandboxCommandEvidence
    public let venueMode: L4ExecutionClientSandboxVenueMode
    public let forbiddenCapabilities: [L4ExecutionClientSandboxReportForbiddenCapability]
    public let validationAnchors: [String]
    public let productionParserEnabled: Bool
    public let interpretsProductionRawPayload: Bool
    public let exposesRawPayloadToDashboard: Bool
    public let touchesBrokerGateway: Bool
    public let recordsRealBrokerFill: Bool
    public let producesOMSStateTransition: Bool
    public let producesReconciliation: Bool
    public let touchesLiveCommandSurface: Bool

    public var parserBoundaryHeld: Bool {
        issueID.rawValue == "GH-460"
            && upstreamIssueID.rawValue == "GH-459"
            && commandEvidence.commandEvidenceHeld
            && venueMode == .sandbox
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionParserEnabled,
            interpretsProductionRawPayload,
            exposesRawPayloadToDashboard,
            touchesBrokerGateway,
            recordsRealBrokerFill,
            producesOMSStateTransition,
            producesReconciliation,
            touchesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        parserID: Identifier = Identifier.constant("gh-460-execution-report-broker-fill-parser"),
        issueID: Identifier = Identifier.constant("GH-460"),
        upstreamIssueID: Identifier = Identifier.constant("GH-459"),
        commandEvidence: L4ExecutionClientSandboxCommandEvidence? = nil,
        venueMode: L4ExecutionClientSandboxVenueMode = .sandbox,
        forbiddenCapabilities: [L4ExecutionClientSandboxReportForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionParserEnabled: Bool = false,
        interpretsProductionRawPayload: Bool = false,
        exposesRawPayloadToDashboard: Bool = false,
        touchesBrokerGateway: Bool = false,
        recordsRealBrokerFill: Bool = false,
        producesOMSStateTransition: Bool = false,
        producesReconciliation: Bool = false,
        touchesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-460" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-460",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-459",
                actual: upstreamIssueID.rawValue
            )
        }
        let resolvedCommandEvidence = try commandEvidence
            ?? L4ExecutionClientSandboxVenueAdapter.deterministicFixture().deterministicCommandEvidence()
        guard resolvedCommandEvidence.commandEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandEvidence",
                expected: "GH-459 command evidence held",
                actual: "mismatch"
            )
        }
        guard venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
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
            ("productionParserEnabled", productionParserEnabled),
            ("interpretsProductionRawPayload", interpretsProductionRawPayload),
            ("exposesRawPayloadToDashboard", exposesRawPayloadToDashboard),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("recordsRealBrokerFill", recordsRealBrokerFill),
            ("producesOMSStateTransition", producesOMSStateTransition),
            ("producesReconciliation", producesReconciliation),
            ("touchesLiveCommandSurface", touchesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.parserID = parserID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandEvidence = resolvedCommandEvidence
        self.venueMode = venueMode
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.productionParserEnabled = productionParserEnabled
        self.interpretsProductionRawPayload = interpretsProductionRawPayload
        self.exposesRawPayloadToDashboard = exposesRawPayloadToDashboard
        self.touchesBrokerGateway = touchesBrokerGateway
        self.recordsRealBrokerFill = recordsRealBrokerFill
        self.producesOMSStateTransition = producesOMSStateTransition
        self.producesReconciliation = producesReconciliation
        self.touchesLiveCommandSurface = touchesLiveCommandSurface
    }

    /// 解析单条 sandbox fixture，输出可 replay 的 normalized audit event。
    public func parse(
        _ fixture: L4ExecutionClientSandboxReportFixture
    ) throws -> L4ExecutionClientSandboxParsedReportEvent {
        guard parserBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard fixture.sourceKind == .sandboxFixture else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("sourceKind.productionRawPayload")
        }
        guard fixture.venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        return try L4ExecutionClientSandboxParsedReportEvent(
            eventID: Identifier.constant("gh-460-sandbox-\(fixture.reportKind.eventIDComponent)-event"),
            reportID: fixture.reportID,
            reportKind: fixture.reportKind,
            relatedCommandKind: fixture.relatedCommandKind,
            replaySequence: fixture.replaySequence,
            eventStatus: fixture.reportStatus,
            clientOrderID: fixture.clientOrderID,
            symbol: fixture.symbol,
            filledQuantity: fixture.filledQuantity,
            remainingQuantity: fixture.remainingQuantity,
            rawPayloadDigest: fixture.rawPayloadDigest
        )
    }

    /// 生成 GH-460 的 deterministic fill / partial fill / reject / cancel acknowledgement replay evidence。
    public func deterministicReplayEvidence() throws -> L4ExecutionClientSandboxReportReplayEvidence {
        let events = try Self.deterministicFixtures().map(parse)
        return try L4ExecutionClientSandboxReportReplayEvidence(parsedEvents: events)
    }

    public static func deterministicFixture() throws -> L4ExecutionClientSandboxReportParser {
        try L4ExecutionClientSandboxReportParser()
    }

    static func deterministicFixtures() throws -> [L4ExecutionClientSandboxReportFixture] {
        try [
            deterministicFixture(kind: .fill, commandKind: .submit, sequence: 1),
            deterministicFixture(kind: .partialFill, commandKind: .replace, sequence: 2),
            deterministicFixture(kind: .reject, commandKind: .submit, sequence: 3),
            deterministicFixture(kind: .cancelAcknowledgement, commandKind: .cancel, sequence: 4)
        ]
    }

    public static let requiredForbiddenCapabilities = L4ExecutionClientSandboxReportForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER",
        "GH-460-SANDBOX-REPORT-KIND-COVERAGE",
        "GH-460-REPLAYABLE-AUDIT-EVIDENCE",
        "GH-460-RAW-PAYLOAD-DASHBOARD-BLOCK",
        "GH-460-PRODUCTION-PARSER-DISABLED",
        "TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER"
    ]

    private static func deterministicFixture(
        kind: L4ExecutionClientSandboxReportKind,
        commandKind: L4ExecutionClientSandboxCommandKind,
        sequence: Int
    ) throws -> L4ExecutionClientSandboxReportFixture {
        try L4ExecutionClientSandboxReportFixture(
            reportID: Identifier.constant("gh-460-sandbox-\(kind.eventIDComponent)-report"),
            reportKind: kind,
            relatedCommandKind: commandKind,
            clientOrderID: Identifier.constant("gh-459-sandbox-client-order-\(commandKind.rawValue)"),
            symbol: "BTCUSDT",
            filledQuantity: kind.filledQuantity,
            remainingQuantity: kind.remainingQuantity,
            reportStatus: L4ExecutionClientSandboxReportFixture.expectedStatus(for: kind),
            replaySequence: sequence,
            sandboxTraceID: Identifier.constant("gh-459-sandbox-\(commandKind.rawValue)-trace"),
            rawPayloadDigest: "sha256:gh-460-sandbox-\(kind.eventIDComponent)-fixture"
        )
    }
}

extension L4ExecutionClientSandboxReportKind {
    fileprivate var eventIDComponent: String {
        switch self {
        case .fill:
            "fill"
        case .partialFill:
            "partial-fill"
        case .reject:
            "reject"
        case .cancelAcknowledgement:
            "cancel-acknowledgement"
        }
    }

    fileprivate var filledQuantity: String {
        switch self {
        case .fill:
            "0.0100"
        case .partialFill:
            "0.0040"
        case .reject, .cancelAcknowledgement:
            "0.0000"
        }
    }

    fileprivate var remainingQuantity: String {
        switch self {
        case .fill:
            "0.0000"
        case .partialFill:
            "0.0060"
        case .reject, .cancelAcknowledgement:
            "0.0100"
        }
    }
}
